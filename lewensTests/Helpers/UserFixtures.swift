//
//  UserFixtures.swift
//  lewensTests
//

import Foundation
@testable import lewens

extension User {
    static func fixture(
        id: String = "user-123",
        email: String = "test@lewens.com",
        firstName: String? = "Anna",
        lastName: String? = "Mueller",
        username: String? = "anna.mueller"
    ) -> User {
        User(id: id, email: email, firstName: firstName, lastName: lastName, username: username)
    }
}

extension DownloadItem {
    static func fixture(
        name: String? = "document.pdf",
        url: String? = "/api/v1/files/document.pdf",
        directory: Bool? = false,
        children: [DownloadItem]? = nil
    ) -> DownloadItem {
        DownloadItem(name: name, url: url, directory: directory, children: children)
    }

    static func directoryFixture(children: [DownloadItem]) -> DownloadItem {
        DownloadItem(name: "folder", url: nil, directory: true, children: children)
    }
}
