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

        @Test("isLoading is true during fetch and false after")
        func isLoadingTogglesCorrectly() async throws {
            let sut = makeSUT()
            stubBoth(pdf: "[]", video: "[]")

            // Before fetch
            #expect(sut.isLoading == false)

            // Start fetch
            sut.fetchDownloads(accessToken: "token")
            try? await Task.sleep(nanoseconds: 1_000_000) // 1ms delay
            #expect(sut.isLoading == true)

            // Wait for completion
            try await fetch(sut, accessToken: "token")
            #expect(sut.isLoading == false)
        }

        @Test("Handles empty arrays from API without error")
        func handlesEmptyArrays() async throws {
            let sut = makeSUT()
            stubBoth(pdf: "[]", video: "[]")
            try await fetch(sut, accessToken: "token")
            #expect(sut.pdfDownloads.isEmpty)
            #expect(sut.videoDownloads.isEmpty)
            #expect(sut.errorMessage == nil)
        }

        @Test("Handles partial failure — PDF fails but video succeeds")
        func handlesPartialFailure() async throws {
            let sut = makeSUT()
            MockURLProtocol.requestHandler = { request in
                let path = request.url?.path ?? ""
                if path.contains("pdf") {
                    return (makeResponse(url: request.url!, statusCode: 500), Data())
                } else {
                    return (makeResponse(url: request.url!, statusCode: 200), #"[{"url":"/video.mp4"}]"#.data(using: .utf8)!)
                }
            }
            try await fetch(sut, accessToken: "token")
            #expect(sut.pdfDownloads.isEmpty)
            #expect(sut.videoDownloads == ["/video.mp4"])
            #expect(sut.errorMessage?.contains("500") == true)
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

    // MARK: - DownloadsService.downloadFile

    @Suite("DownloadsService.downloadFile")
    @MainActor
    struct DownloadFileTests {

        private func makeSUT() -> DownloadsService {
            DownloadsService(session: .mock, apiURL: { category in
                switch category {
                case .pdf:   return "https://test.lewens.com/pdf"
                case .video: return "https://test.lewens.com/video"
                }
            })
        }

        @Test("downloadFile calls completion with nil on network error")
        func returnsNilOnNetworkError() async {
            let sut = makeSUT()
            MockURLProtocol.requestHandler = { _ in throw URLError(.notConnectedToInternet) }

            let result: URL? = await withCheckedContinuation { continuation in
                sut.downloadFile(urlPath: "/files/doc.pdf", accessToken: "token", session: .mock) { url in
                    continuation.resume(returning: url)
                }
            }

            #expect(result == nil)
        }

        @Test("downloadFile calls completion with nil on invalid URL")
        func returnsNilOnInvalidURL() async {
            let sut = makeSUT()

            let result: URL? = await withCheckedContinuation { continuation in
                // Empty path + empty base = invalid URL
                sut.downloadFile(urlPath: "", accessToken: "token", baseURL: "", session: .mock) { url in
                    continuation.resume(returning: url)
                }
            }

            #expect(result == nil)
        }

        @Test("downloadFile uses absolute URL when path starts with http")
        func usesAbsoluteURL() async {
            let sut = makeSUT()
            var capturedURL: URL?

            MockURLProtocol.requestHandler = { request in
                capturedURL = request.url
                throw URLError(.cancelled) // stop after capturing
            }

            await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                sut.downloadFile(
                    urlPath: "https://cdn.example.com/file.pdf",
                    accessToken: "token",
                    session: .mock
                ) { _ in continuation.resume() }
            }

            #expect(capturedURL?.absoluteString == "https://cdn.example.com/file.pdf")
        }

        @Test("downloadFile strips query params from filename when building dest path")
        func filenameStripsQueryParams() {
            // Test the URL parsing logic directly — lastPathComponent + split on "?"
            let urlPath = "/files/report.pdf?token=abc&v=2"
            let url = URL(string: "https://base.com" + urlPath)!
            let filename = url.lastPathComponent.components(separatedBy: "?")[0]
            #expect(filename == "report.pdf")
        }

        @Test("downloadFile prepends base URL for relative paths")
        func prependsBaseURL() async {
            let sut = makeSUT()
            var capturedURL: URL?

            MockURLProtocol.requestHandler = { request in
                capturedURL = request.url
                throw URLError(.cancelled)
            }

            await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                sut.downloadFile(
                    urlPath: "/api/v1/files/doc.pdf",
                    accessToken: "token",
                    baseURL: "https://test.lewens.com",
                    session: .mock
                ) { _ in continuation.resume() }
            }

            #expect(capturedURL?.absoluteString == "https://test.lewens.com/api/v1/files/doc.pdf")
        }

        @Test("downloadFile sends Authorization header")
        func sendsAuthorizationHeader() async {
            let sut = makeSUT()
            var capturedAuth: String?

            MockURLProtocol.requestHandler = { request in
                capturedAuth = request.value(forHTTPHeaderField: "Authorization")
                throw URLError(.cancelled)
            }

            await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                sut.downloadFile(
                    urlPath: "https://test.lewens.com/files/doc.pdf",
                    accessToken: "my-token",
                    session: .mock
                ) { _ in continuation.resume() }
            }

            #expect(capturedAuth == "Bearer my-token")
        }
    }
}
