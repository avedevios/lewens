//
//  DownloadItem.swift
//  lewens
//

import Foundation

struct DownloadItem: Codable {
    let name: String?
    let url: String?
    let directory: Bool?
    let children: [DownloadItem]?
}

enum DownloadCategory {
    case pdf
    case video
}
