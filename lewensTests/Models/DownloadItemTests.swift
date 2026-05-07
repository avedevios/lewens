//
//  DownloadItemTests.swift
//  lewensTests
//

import Testing
import Foundation
@testable import lewens

@Suite("DownloadItem Model")
struct DownloadItemTests {

    @Test("Decodes flat item")
    func decodeFlatItem() throws {
        let json = """
        { "name": "manual.pdf", "url": "/files/manual.pdf", "directory": false }
        """.data(using: .utf8)!

        let item = try JSONDecoder().decode(DownloadItem.self, from: json)

        #expect(item.name      == "manual.pdf")
        #expect(item.url       == "/files/manual.pdf")
        #expect(item.directory == false)
        #expect(item.children  == nil)
    }

    @Test("Decodes directory with children")
    func decodeDirectoryWithChildren() throws {
        let json = """
        {
            "name": "docs",
            "url": null,
            "directory": true,
            "children": [
                { "name": "a.pdf", "url": "/files/a.pdf", "directory": false },
                { "name": "b.pdf", "url": "/files/b.pdf", "directory": false }
            ]
        }
        """.data(using: .utf8)!

        let item = try JSONDecoder().decode(DownloadItem.self, from: json)

        #expect(item.directory            == true)
        #expect(item.children?.count      == 2)
        #expect(item.children?.first?.url == "/files/a.pdf")
    }

    @Test("Decodes deeply nested directories")
    func decodeDeeplyNested() throws {
        let json = """
        {
            "name": "root", "directory": true,
            "children": [{
                "name": "sub", "directory": true,
                "children": [
                    { "name": "deep.pdf", "url": "/files/deep.pdf", "directory": false }
                ]
            }]
        }
        """.data(using: .utf8)!

        let item = try JSONDecoder().decode(DownloadItem.self, from: json)
        let deep = item.children?.first?.children?.first

        #expect(deep?.url == "/files/deep.pdf")
    }

    @Test("Decodes empty object — all fields nil")
    func decodeEmptyObject() throws {
        let item = try JSONDecoder().decode(DownloadItem.self, from: "{}".data(using: .utf8)!)

        #expect(item.name      == nil)
        #expect(item.url       == nil)
        #expect(item.directory == nil)
        #expect(item.children  == nil)
    }

    @Test("Round-trip preserves structure")
    func roundTrip() throws {
        let original = DownloadItem.directoryFixture(children: [
            .fixture(name: "a.pdf", url: "/a.pdf"),
            .fixture(name: "b.mp4", url: "/b.mp4")
        ])

        let data    = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(DownloadItem.self, from: data)

        #expect(decoded.name             == original.name)
        #expect(decoded.children?.count  == 2)
        #expect(decoded.children?[1].url == "/b.mp4")
    }

    @Test("Decodes array of items")
    func decodeArray() throws {
        let json = """
        [
            { "name": "a.pdf", "url": "/a.pdf" },
            { "name": "b.pdf", "url": "/b.pdf" }
        ]
        """.data(using: .utf8)!

        let items = try JSONDecoder().decode([DownloadItem].self, from: json)

        #expect(items.count  == 2)
        #expect(items[0].url == "/a.pdf")
        #expect(items[1].url == "/b.pdf")
    }
}
