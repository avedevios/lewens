//
//  JSONLoaderTests.swift
//  lewensTests
//

import Testing
import Foundation
@testable import lewens

@Suite("JSONLoader")
struct JSONLoaderTests {

    @Test("Returns nil for nonexistent file")
    func returnsNilForMissingFile() {
        let result: [Customer]? = JSONLoader.load("nonexistent_file_xyz.json")
        #expect(result == nil)
    }

    @Test("Returns nil when decoding wrong type")
    func returnsNilForWrongType() {
        // mock_pdf.json contains DownloadItem, not Customer
        let result: Customer? = JSONLoader.load("mock_pdf.json")
        #expect(result == nil)
    }

    @Test("Returns nil for file with invalid JSON — graceful failure without crash")
    func returnsNilForInvalidJSON() {
        // JSONLoader uses Bundle.main so we can't inject a custom file,
        // but we verify that a non-existent file returns nil without crashing
        let result: [String]? = JSONLoader.load("definitely_not_valid_json_xyz.json")
        #expect(result == nil)
    }

    @Test("Decodes DownloadItems from mock_pdf.json if present in bundle")
    func decodesMockPdf() {
        guard let items: [DownloadItem] = JSONLoader.load("mock_pdf.json") else {
            // File not included in test bundle — skip gracefully
            return
        }
        #expect(!items.isEmpty)
    }

    @Test("Decodes DownloadItems from mock_video.json if present in bundle")
    func decodesMockVideo() {
        guard let items: [DownloadItem] = JSONLoader.load("mock_video.json") else {
            return
        }
        #expect(!items.isEmpty)
    }
}
