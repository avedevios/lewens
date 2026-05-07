//
//  NetworkTests.swift
//  lewensTests
//
//  All network tests in one serialized suite to prevent MockURLProtocol
//  race conditions when tests run in parallel.
//

import Testing
import Foundation
import Combine
@testable import lewens

@Suite("Network Tests", .serialized)
struct NetworkTests {

    // MARK: - UserInfoService

    @Suite("UserInfoService")
    struct UserInfoServiceTests {

        private let stubURL = URL(string: "https://test.lewens.com/userinfo")!

        private func makeSUT() -> UserInfoService {
            UserInfoService(session: .mock, userInfoURL: stubURL)
        }

        @Test("Parses full userinfo response")
        func parsesFullResponse() async throws {
            let sut = makeSUT()
            stub(json: #"{"sub":"user-abc","email":"anna@lewens.com","given_name":"Anna","family_name":"Mueller","preferred_username":"anna.mueller"}"#, statusCode: 200)

            let user = try await sut.fetchUserInfo(accessToken: "test-token")

            #expect(user.id        == "user-abc")
            #expect(user.email     == "anna@lewens.com")
            #expect(user.firstName == "Anna")
            #expect(user.lastName  == "Mueller")
            #expect(user.username  == "anna.mueller")
        }

        @Test("Parses partial response — missing optional fields")
        func parsesPartialResponse() async throws {
            let sut = makeSUT()
            stub(json: #"{"sub":"user-xyz","email":"x@y.com"}"#, statusCode: 200)

            let user = try await sut.fetchUserInfo(accessToken: "token")

            #expect(user.id        == "user-xyz")
            #expect(user.email     == "x@y.com")
            #expect(user.firstName == nil)
            #expect(user.lastName  == nil)
            #expect(user.username  == nil)
        }

        @Test("Generates fallback UUID when sub is missing")
        func generatesFallbackID() async throws {
            let sut = makeSUT()
            stub(json: #"{"email":"no-sub@test.com"}"#, statusCode: 200)

            let user = try await sut.fetchUserInfo(accessToken: "token")

            #expect(!user.id.isEmpty)
            #expect(user.email == "no-sub@test.com")
        }

        @Test("Sends correct Authorization and Accept headers")
        func sendsCorrectHeaders() async throws {
            let sut = makeSUT()
            var capturedRequest: URLRequest?

            MockURLProtocol.requestHandler = { request in
                capturedRequest = request
                return (makeResponse(url: request.url!, statusCode: 200),
                        #"{"sub":"u1","email":"a@b.com"}"#.data(using: .utf8)!)
            }

            _ = try await sut.fetchUserInfo(accessToken: "my-secret-token")

            #expect(capturedRequest?.value(forHTTPHeaderField: "Authorization") == "Bearer my-secret-token")
            #expect(capturedRequest?.value(forHTTPHeaderField: "Accept") == "application/json")
        }

        @Test("Throws badServerResponse on 4xx/5xx", arguments: [401, 403, 404, 500, 503])
        func throwsOnHTTPError(statusCode: Int) async {
            let sut = makeSUT()
            stub(json: "", statusCode: statusCode)

            await #expect(throws: URLError.self) {
                _ = try await sut.fetchUserInfo(accessToken: "token")
            }
        }

        @Test("Throws on network error")
        func throwsOnNetworkError() async {
            let sut = makeSUT()
            MockURLProtocol.requestHandler = { _ in throw URLError(.notConnectedToInternet) }

            await #expect(throws: URLError.self) {
                _ = try await sut.fetchUserInfo(accessToken: "token")
            }
        }

        @Test("Throws DecodingError on invalid JSON")
        func throwsOnInvalidJSON() async {
            let sut = makeSUT()
            stub(raw: "not json", statusCode: 200)

            await #expect(throws: DecodingError.self) {
                _ = try await sut.fetchUserInfo(accessToken: "token")
            }
        }

        @Test("Throws on empty body")
        func throwsOnEmptyBody() async {
            let sut = makeSUT()
            MockURLProtocol.requestHandler = { request in
                (makeResponse(url: request.url!, statusCode: 200), Data())
            }

            await #expect(throws: (any Error).self) {
                _ = try await sut.fetchUserInfo(accessToken: "token")
            }
        }

        private func stub(json: String, statusCode: Int) { stub(raw: json, statusCode: statusCode) }
        private func stub(raw: String, statusCode: Int) {
            MockURLProtocol.requestHandler = { request in
                (makeResponse(url: request.url!, statusCode: statusCode), raw.data(using: .utf8)!)
            }
        }
    }

    // MARK: - DownloadsService

    @Suite("DownloadsService")
    @MainActor
    struct DownloadsServiceTests {

        private func makeSUT() -> DownloadsService {
            DownloadsService(session: .mock, apiURL: { category in
                switch category {
                case .pdf:   return "https://test.lewens.com/pdf"
                case .video: return "https://test.lewens.com/video"
                }
            })
        }

        @Test("Extracts URL from flat item")
        func flatItem() async throws {
            let sut = makeSUT()
            stubBoth(pdf: #"[{"url":"/a.pdf"}]"#, video: "[]")
            try await fetch(sut, accessToken: "t")
            #expect(sut.pdfDownloads   == ["/a.pdf"])
            #expect(sut.videoDownloads.isEmpty)
        }

        @Test("Extracts URLs from nested directory")
        func nestedDirectory() async throws {
            let sut = makeSUT()
            stubBoth(pdf: #"[{"directory":true,"children":[{"url":"/a.pdf"},{"url":"/b.pdf"}]}]"#, video: "[]")
            try await fetch(sut, accessToken: "t")
            #expect(sut.pdfDownloads.sorted() == ["/a.pdf", "/b.pdf"])
        }

        @Test("Extracts URLs from deeply nested directories")
        func deeplyNested() async throws {
            let sut = makeSUT()
            stubBoth(pdf: #"[{"directory":true,"children":[{"directory":true,"children":[{"url":"/deep.pdf"}]}]}]"#, video: "[]")
            try await fetch(sut, accessToken: "t")
            #expect(sut.pdfDownloads == ["/deep.pdf"])
        }

        @Test("Skips items without URL")
        func skipsItemsWithoutURL() async throws {
            let sut = makeSUT()
            stubBoth(pdf: #"[{"directory":true},{"url":"/has.pdf"}]"#, video: "[]")
            try await fetch(sut, accessToken: "t")
            #expect(sut.pdfDownloads == ["/has.pdf"])
        }

        @Test("Handles single item response (not array)")
        func singleItemResponse() async throws {
            let sut = makeSUT()
            stubBoth(pdf: #"{"url":"/single.pdf"}"#, video: "[]")
            try await fetch(sut, accessToken: "t")
            #expect(sut.pdfDownloads == ["/single.pdf"])
        }

        @Test("Populates both PDF and video categories")
        func populatesBothCategories() async throws {
            let sut = makeSUT()
            stubBoth(pdf: #"[{"url":"/a.pdf"},{"url":"/b.pdf"}]"#, video: #"[{"url":"/v1.mp4"}]"#)
            try await fetch(sut, accessToken: "token")
            #expect(sut.pdfDownloads.count   == 2)
            #expect(sut.videoDownloads.count == 1)
            #expect(sut.videoDownloads.first == "/v1.mp4")
        }

        @Test("Sends Authorization header with token")
        func sendsAuthorizationHeader() async throws {
            let sut = makeSUT()
            var capturedHeaders: [String] = []
            MockURLProtocol.requestHandler = { request in
                if let auth = request.value(forHTTPHeaderField: "Authorization") {
                    capturedHeaders.append(auth)
                }
                return (makeResponse(url: request.url!, statusCode: 200), "[]".data(using: .utf8)!)
            }
            try await fetch(sut, accessToken: "bearer-xyz")
            #expect(capturedHeaders.allSatisfy { $0 == "Bearer bearer-xyz" })
            #expect(!capturedHeaders.isEmpty)
        }

        @Test("Sets errorMessage on 500")
        func setsErrorOn500() async throws {
            let sut = makeSUT()
            MockURLProtocol.requestHandler = { request in
                (makeResponse(url: request.url!, statusCode: 500), Data())
            }
            try await fetch(sut, accessToken: "token")
            #expect(sut.errorMessage?.contains("500") == true)
        }

        @Test("Sets errorMessage on network error")
        func setsErrorOnNetworkError() async throws {
            let sut = makeSUT()
            MockURLProtocol.requestHandler = { _ in throw URLError(.notConnectedToInternet) }
            try await fetch(sut, accessToken: "token")
            #expect(sut.errorMessage != nil)
        }

        @Test("Sets rawResponse and errorMessage on parse failure")
        func setsRawResponseOnParseFailure() async throws {
            let sut = makeSUT()
            stubBoth(pdf: "not json", video: "not json")
            try await fetch(sut, accessToken: "token")
            #expect(!sut.rawResponse.isEmpty)
            #expect(sut.errorMessage != nil)
        }

        @Test("isLoading is false after fetch completes")
        func isLoadingFalseAfterFetch() async throws {
            let sut = makeSUT()
            stubBoth(pdf: "[]", video: "[]")
            try await fetch(sut, accessToken: "token")
            #expect(sut.isLoading == false)
        }

        @Test("Clears previous results before new fetch")
        func clearsPreviousResults() async throws {
            let sut = makeSUT()
            stubBoth(pdf: #"[{"url":"/old.pdf"}]"#, video: "[]")
            try await fetch(sut, accessToken: "token")
            #expect(sut.pdfDownloads == ["/old.pdf"])

            stubBoth(pdf: #"[{"url":"/new.pdf"}]"#, video: "[]")
            try await fetch(sut, accessToken: "token")
            #expect(sut.pdfDownloads == ["/new.pdf"])
        }

        @Test("Does not make network requests when token is nil")
        func noNetworkRequestsWithoutToken() async {
            let sut = makeSUT()
            var requestCount = 0
            MockURLProtocol.requestHandler = { request in
                requestCount += 1
                return (makeResponse(url: request.url!, statusCode: 200), "[]".data(using: .utf8)!)
            }
            sut.fetchDownloads(accessToken: nil)
            try? await Task.sleep(nanoseconds: 100_000_000)
            #expect(requestCount == 0)
        }

        private func stubBoth(pdf: String, video: String) {
            MockURLProtocol.requestHandler = { request in
                let path = request.url?.path ?? ""
                let body = path.contains("pdf") ? pdf : video
                return (makeResponse(url: request.url!, statusCode: 200), body.data(using: .utf8)!)
            }
        }

        private func fetch(_ sut: DownloadsService, accessToken: String) async throws {
            try await withCheckedThrowingContinuation { continuation in
                var cancellable: AnyCancellable?
                cancellable = sut.$isLoading
                    .dropFirst()
                    .filter { !$0 }
                    .first()
                    .sink { _ in
                        cancellable?.cancel()
                        continuation.resume()
                    }
                sut.fetchDownloads(accessToken: accessToken)
            }
        }
    }
}
