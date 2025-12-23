//
//  DownloadsService.swift
//  lewens
//
//  Created by AI Assistant on 2025-11-23.
//

import Foundation
import Combine

class DownloadsService: ObservableObject {
    static let shared = DownloadsService()
    
    @Published var pdfDownloads: [String] = []
    @Published var videoDownloads: [String] = []
    @Published var rawResponse: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let pdfApiUrl = "http://188.245.191.46:8082/api/v1/downloads-instructions-pdf"
    private let videoApiUrl = "http://188.245.191.46:8082/api/v1/downloads-instructions-video"
    
    struct DownloadItem: Codable {
        let name: String?
        let url: String?
        let directory: Bool?
        let children: [DownloadItem]?
    }
    
    func fetchDownloads() {
        // fetchData(from: pdfApiUrl, isVideo: false)
        // fetchData(from: videoApiUrl, isVideo: true)
        loadLocalData()
    }
    
    private func loadLocalData() {
        print("📁 Loading mock data from local files...")
        isLoading = true
        errorMessage = nil
        
        // Load PDF mock
        if let pdfItems: [DownloadItem] = JSONLoader.load("mock_pdf.json") {
            var urls: [String] = []
            for item in pdfItems {
                urls.append(contentsOf: extractUrls(from: item))
            }
            self.pdfDownloads = urls
        } else {
            print("⚠️ Failed to load mock_pdf.json")
        }
        
        // Load Video mock
        if let videoItems: [DownloadItem] = JSONLoader.load("mock_video.json") {
            var urls: [String] = []
            for item in videoItems {
                urls.append(contentsOf: extractUrls(from: item))
            }
            self.videoDownloads = urls
        } else {
            print("⚠️ Failed to load mock_video.json")
        }
        
        isLoading = false
    }
    
    private func fetchData(from urlString: String, isVideo: Bool) {
        /*
        guard let accessToken = KeycloakService.shared.currentUserToken else {
            self.errorMessage = "No access token available. Please login first."
            return
        }
        */
        let accessToken = "mock-token" // Placeholder
        
        guard let url = URL(string: urlString) else {
            self.errorMessage = "Invalid API URL"
            return
        }
        
        isLoading = true
        errorMessage = nil
        if isVideo {
            videoDownloads = []
        } else {
            pdfDownloads = []
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        print("🚀 Fetching data from: \(urlString)")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Error fetching data: \(error.localizedDescription)"
                    print("❌ Error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "No data received"
                    return
                }
                
                // Parse JSON
                do {
                    var urls: [String] = []
                    
                    // Try to decode as a single item first
                    if let item = try? JSONDecoder().decode(DownloadItem.self, from: data) {
                        urls = self?.extractUrls(from: item) ?? []
                    } 
                    // Fallback: maybe it's an array?
                    else if let items = try? JSONDecoder().decode([DownloadItem].self, from: data) {
                        for item in items {
                            urls.append(contentsOf: self?.extractUrls(from: item) ?? [])
                        }
                    } else {
                        self?.errorMessage = "Failed to parse response"
                        // Debug raw response
                        if let stringResponse = String(data: data, encoding: .utf8) {
                            self?.rawResponse = stringResponse
                        }
                        return
                    }
                    
                    if isVideo {
                        self?.videoDownloads = urls
                    } else {
                        self?.pdfDownloads = urls
                    }
                    
                } catch {
                    print("⚠️ JSON Parsing Error: \(error)")
                }
            }
        }.resume()
    }
    
    private func extractUrls(from item: DownloadItem) -> [String] {
        var urls: [String] = []
        if let url = item.url {
            urls.append(url)
        }
        
        if let children = item.children {
            for child in children {
                urls.append(contentsOf: extractUrls(from: child))
            }
        }
        return urls
    }
    
    // Download file from URL
    func downloadFile(urlPath: String, completion: @escaping (URL?) -> Void) {
        /*
        guard let accessToken = KeycloakService.shared.currentUserToken else {
            print("❌ No access token for download")
            completion(nil)
            return
        }
        */
        let accessToken = "mock-token" // Placeholder
        
        // Construct full URL (assuming the API returns relative paths starting with /api/...)
        // The base URL is http://188.245.191.46:8082
        let baseURL = "http://188.245.191.46:8082"
        let fullString = urlPath.hasPrefix("http") ? urlPath : baseURL + urlPath
        
        guard let url = URL(string: fullString) else {
            print("❌ Invalid URL: \(fullString)")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        print("⬇️ Downloading file from: \(url.absoluteString)")
        
        URLSession.shared.downloadTask(with: request) { localURL, response, error in
            guard let localURL = localURL, error == nil else {
                print("❌ Download failed: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            // Move file to Documents directory with correct name
            do {
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                // Extract filename from URL path
                let filename = url.lastPathComponent.components(separatedBy: "?")[0] // Remove query params
                let savedURL = documentsURL.appendingPathComponent(filename)
                
                // Remove existing file if needed
                if FileManager.default.fileExists(atPath: savedURL.path) {
                    try FileManager.default.removeItem(at: savedURL)
                }
                
                try FileManager.default.moveItem(at: localURL, to: savedURL)
                print("✅ File saved to: \(savedURL.path)")
                
                DispatchQueue.main.async {
                    completion(savedURL)
                }
            } catch {
                print("❌ File save failed: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }
}
