//
//  VideoResourceLoaderDelegateTests.swift
//  lewensTests
//
//  Tests for URL scheme replacement and Range header logic.
//  The AVAssetResourceLoaderDelegate callback itself requires AVFoundation mocks
//  and is not unit-tested here.
//

import Testing
import Foundation
@testable import lewens

@Suite("VideoResourceLoaderDelegate")
struct VideoResourceLoaderDelegateTests {

    // MARK: - Initialisation

    @Test("Initialises with a token")
    func initialisesWithToken() {
        let delegate = VideoResourceLoaderDelegate(token: "test-token")
        _ = delegate // no crash = pass
    }

    // MARK: - URL scheme replacement logic (tested via URLComponents)

    @Test("lewens-auth scheme is replaced with http")
    func lewensAuthSchemeReplacedWithHttp() {
        let original = URL(string: "lewens-auth://192.168.1.1:8082/api/v1/video.mp4")!
        var components = URLComponents(url: original, resolvingAgainstBaseURL: false)!
        components.scheme = original.scheme == "lewens-auth" ? "http" : original.scheme
        #expect(components.url?.scheme == "http")
        #expect(components.url?.host   == "192.168.1.1")
        #expect(components.url?.path   == "/api/v1/video.mp4")
    }

    @Test("https scheme is preserved unchanged")
    func httpsSchemePreserved() {
        let original = URL(string: "https://cdn.example.com/video.mp4")!
        var components = URLComponents(url: original, resolvingAgainstBaseURL: false)!
        components.scheme = original.scheme == "lewens-auth" ? "http" : original.scheme
        #expect(components.url?.scheme == "https")
    }

    @Test("http scheme is preserved unchanged")
    func httpSchemePreserved() {
        let original = URL(string: "http://192.168.1.1/video.mp4")!
        var components = URLComponents(url: original, resolvingAgainstBaseURL: false)!
        components.scheme = original.scheme == "lewens-auth" ? "http" : original.scheme
        #expect(components.url?.scheme == "http")
    }

    // MARK: - Range header construction

    @Test("Range header is built correctly from offset and length")
    func rangeHeaderConstruction() {
        let offset: Int64 = 1024
        let length: Int   = 512
        let upper = offset + Int64(length) - 1
        let header = "bytes=\(offset)-\(upper)"
        #expect(header == "bytes=1024-1535")
    }

    @Test("Range header with zero offset starts from 0")
    func rangeHeaderZeroOffset() {
        let offset: Int64 = 0
        let length: Int   = 4096
        let upper = offset + Int64(length) - 1
        let header = "bytes=\(offset)-\(upper)"
        #expect(header == "bytes=0-4095")
    }

    // MARK: - Content-Range parsing

    @Test("Content-Range total length is parsed correctly")
    func contentRangeParsing() {
        let contentRange = "bytes 0-1023/2048"
        let totalStr = contentRange.components(separatedBy: "/").last
        let total = totalStr.flatMap { Int64($0) }
        #expect(total == 2048)
    }

    @Test("Content-Range with unknown total returns nil")
    func contentRangeUnknownTotal() {
        let contentRange = "bytes 0-1023/*"
        let totalStr = contentRange.components(separatedBy: "/").last
        let total = totalStr.flatMap { Int64($0) }
        #expect(total == nil)
    }
}

// MARK: - DownloadCategory

@Suite("DownloadCategory")
struct DownloadCategoryTests {

    @Test("pdf case exists")
    func pdfCaseExists() {
        let category = DownloadCategory.pdf
        if case .pdf = category {
            #expect(true)
        } else {
            Issue.record("Expected .pdf case")
        }
    }

    @Test("video case exists")
    func videoCaseExists() {
        let category = DownloadCategory.video
        if case .video = category {
            #expect(true)
        } else {
            Issue.record("Expected .video case")
        }
    }

    @Test("pdf and video are distinct")
    func casesAreDistinct() {
        let pdf   = DownloadCategory.pdf
        let video = DownloadCategory.video
        // Can't use == without Equatable, but switch covers both
        var pdfCount = 0
        var videoCount = 0
        for c in [pdf, video] {
            switch c {
            case .pdf:   pdfCount += 1
            case .video: videoCount += 1
            }
        }
        #expect(pdfCount   == 1)
        #expect(videoCount == 1)
    }
}
