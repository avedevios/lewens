//
//  DownloadsViewTests.swift
//  lewensTests
//
//  Tests for Downloads view state logic.
//

import Testing
import Combine
import Foundation
@testable import lewens

@Suite("DownloadsView State Tests")
@MainActor
struct DownloadsViewStateTests {

    @Test("Empty state when both lists are empty")
    func emptyState() {
        let service = DownloadsService()
        service.pdfDownloads = []
        service.videoDownloads = []
        
        let hasContent = !service.pdfDownloads.isEmpty || !service.videoDownloads.isEmpty
        #expect(hasContent == false)
    }

    @Test("Has content when PDFs available")
    func hasPDFContent() {
        let service = DownloadsService()
        service.pdfDownloads = ["/file1.pdf", "/file2.pdf"]
        service.videoDownloads = []
        
        let hasContent = !service.pdfDownloads.isEmpty || !service.videoDownloads.isEmpty
        #expect(hasContent == true)
    }

    @Test("Has content when videos available")
    func hasVideoContent() {
        let service = DownloadsService()
        service.pdfDownloads = []
        service.videoDownloads = ["/video1.mp4"]
        
        let hasContent = !service.pdfDownloads.isEmpty || !service.videoDownloads.isEmpty
        #expect(hasContent == true)
    }

    @Test("Has content when both types available")
    func hasBothContent() {
        let service = DownloadsService()
        service.pdfDownloads = ["/file1.pdf"]
        service.videoDownloads = ["/video1.mp4"]
        
        #expect(!service.pdfDownloads.isEmpty)
        #expect(!service.videoDownloads.isEmpty)
    }

    @Test("Error state shown when error message set")
    func errorState() {
        let service = DownloadsService()
        service.errorMessage = "Network error occurred"
        
        let shouldShowError = service.errorMessage != nil
        #expect(shouldShowError == true)
    }

    @Test("Loading state shown when isLoading true")
    func loadingState() {
        let service = DownloadsService()
        service.isLoading = true
        
        #expect(service.isLoading == true)
    }

    @Test("Raw response shown when JSON parsing fails")
    func rawResponseState() {
        let service = DownloadsService()
        service.rawResponse = "Invalid JSON here"
        service.pdfDownloads = []
        service.videoDownloads = []
        
        let shouldShowRawResponse = !service.rawResponse.isEmpty 
            && service.pdfDownloads.isEmpty 
            && service.videoDownloads.isEmpty
        #expect(shouldShowRawResponse == true)
    }

    @Test("refreshDownloads waits for isLoading to become false")
    func refreshDownloadsWaitsForCompletion() async throws {
        let service = DownloadsService(session: .mock, apiURL: { _ in "https://test.lewens.com/empty" })
        
        MockURLProtocol.requestHandler = { request in
            (makeResponse(url: request.url!, statusCode: 200), "[]".data(using: .utf8)!)
        }
        
        // Simulate the refreshDownloads logic
        var cancellable: AnyCancellable?
        try await withCheckedThrowingContinuation { continuation in
            cancellable = service.$isLoading
                .dropFirst()
                .filter { !$0 }
                .first()
                .sink { _ in
                    cancellable?.cancel()
                    continuation.resume()
                }
            service.fetchDownloads(accessToken: "token")
        }
        
        #expect(service.isLoading == false)
    }
}
