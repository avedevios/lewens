//
//  DownloadsService.swift
//  lewens
//

import Foundation

class DownloadsService: ObservableObject {

    static let shared = DownloadsService()

    // MARK: - Published state

    @Published var pdfDownloads: [String] = []
    @Published var videoDownloads: [String] = []
    @Published var rawResponse: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Dependencies

    private let session: URLSession
    private let apiURL: (DownloadCategory) -> String

    init(
        session: URLSession = .shared,
        apiURL: ((DownloadCategory) -> String)? = nil
    ) {
        self.session = session
        self.apiURL = apiURL ?? { category in
            let base = KeycloakConfig.apiBaseURL
            switch category {
            case .pdf:   return "\(base)/api/v1/downloads-instructions-pdf"
            case .video: return "\(base)/api/v1/downloads-instructions-video"
            }
        }
    }

    // MARK: - Public API

    /// Fetches downloads. Pass a valid access token to hit the real API,
    /// or nil to fall back to local mock data.
    func fetchDownloads(accessToken: String?) {
        if let token = accessToken {
            Task { @MainActor in
                await fetchFromAPI(token: token)
            }
        } else {
            loadLocalData()
        }
    }

    func downloadFile(urlPath: String, accessToken: String, baseURL: String? = nil, completion: @escaping (URL?) -> Void) {
        let base = baseURL ?? KeycloakConfig.apiBaseURL
        let fullString = urlPath.hasPrefix("http") ? urlPath : base + urlPath

        guard let url = URL(string: fullString) else {
            #if DEBUG
            print("❌ Invalid URL: \(fullString)")
            #endif
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        #if DEBUG
        print("⬇️ Downloading: \(url.absoluteString)")
        #endif

        URLSession.shared.downloadTask(with: request) { tempURL, _, error in
            guard let tempURL, error == nil else {
                #if DEBUG
                print("❌ Download failed: \(error?.localizedDescription ?? "Unknown")")
                #endif
                completion(nil)
                return
            }

            do {
                let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let filename = url.lastPathComponent.components(separatedBy: "?")[0]
                let dest = docs.appendingPathComponent(filename)

                if FileManager.default.fileExists(atPath: dest.path) {
                    try FileManager.default.removeItem(at: dest)
                }
                try FileManager.default.moveItem(at: tempURL, to: dest)

                #if DEBUG
                print("✅ Saved to: \(dest.path)")
                #endif

                DispatchQueue.main.async { completion(dest) }
            } catch {
                #if DEBUG
                print("❌ File save failed: \(error.localizedDescription)")
                #endif
                completion(nil)
            }
        }.resume()
    }

    // MARK: - Private helpers

    private func fetchFromAPI(token: String) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
            pdfDownloads = []
            videoDownloads = []
        }

        async let pdfs  = fetchCategory(.pdf,   token: token)
        async let videos = fetchCategory(.video, token: token)

        let (pdfURLs, videoURLs) = await (pdfs, videos)

        await MainActor.run {
            pdfDownloads  = pdfURLs
            videoDownloads = videoURLs
            isLoading = false
        }
    }

    private func fetchCategory(_ category: DownloadCategory, token: String) async -> [String] {
        let urlString = apiURL(category)
        guard let url = URL(string: urlString) else { return [] }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await session.data(for: request)

            if let http = response as? HTTPURLResponse, http.statusCode >= 400 {
                await MainActor.run {
                    errorMessage = "Server error \(http.statusCode)"
                }
                return []
            }

            // Try array first, then single item
            if let items = try? JSONDecoder().decode([DownloadItem].self, from: data) {
                return items.flatMap { extractURLs(from: $0) }
            } else if let item = try? JSONDecoder().decode(DownloadItem.self, from: data) {
                return extractURLs(from: item)
            } else {
                await MainActor.run {
                    rawResponse = String(data: data, encoding: .utf8) ?? ""
                    errorMessage = "Failed to parse response"
                }
                return []
            }
        } catch {
            await MainActor.run {
                errorMessage = "Error: \(error.localizedDescription)"
            }
            return []
        }
    }

    private func loadLocalData() {
        #if DEBUG
        print("📁 Loading mock data from local files...")
        #endif
        isLoading = true
        errorMessage = nil

        if let items: [DownloadItem] = JSONLoader.load("mock_pdf.json") {
            pdfDownloads = items.flatMap { extractURLs(from: $0) }
        }
        if let items: [DownloadItem] = JSONLoader.load("mock_video.json") {
            videoDownloads = items.flatMap { extractURLs(from: $0) }
        }

        isLoading = false
    }

    private func extractURLs(from item: DownloadItem) -> [String] {
        var urls = item.url.map { [$0] } ?? []
        urls += (item.children ?? []).flatMap { extractURLs(from: $0) }
        return urls
    }
}
