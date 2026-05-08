//
//  DownloadsView.swift
//  lewens
//
//  Created by Anton Averianov on 2025-09-02.
//

import SwiftUI
import QuickLook
import AVKit
import AVFoundation
import Combine

struct DownloadsView: View {
    @EnvironmentObject private var keycloakService: KeycloakService
    @EnvironmentObject private var downloadsService: DownloadsService
    @EnvironmentObject private var localizationManager: LocalizationManager

    @State private var showLanguagePicker = false
    @State private var previewURL: URL?
    @State private var playVideoURL: URL?
    @State private var isDownloading = false

    var body: some View {
        AppScreen(showLanguagePicker: $showLanguagePicker) {
            ScrollView {
                VStack(spacing: 20) {
                    if downloadsService.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .lssPrimaryText))
                            .padding(.top, 20)
                    }

                    if !downloadsService.pdfDownloads.isEmpty || !downloadsService.videoDownloads.isEmpty {
                        downloadsGrid
                    } else if !downloadsService.rawResponse.isEmpty {
                        rawResponseView
                    }

                    if let error = downloadsService.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                .padding(.top, 20)
            }
            .refreshable {
                await refreshDownloads()
            }
            .onAppear {
                downloadsService.fetchDownloads(accessToken: keycloakService.currentUserToken)
            }
        }
        .sheet(item: $previewURL) { url in
            QuickLookPreview(url: url)
        }
        .sheet(item: $playVideoURL) { url in
            VideoPlayerView(url: url, token: keycloakService.currentUserToken)
                .edgesIgnoringSafeArea(.all)
        }
        .overlay {
            if isDownloading {
                ZStack {
                    Color.lssOverlay.edgesIgnoringSafeArea(.all)
                    ProgressView("Downloading...")
                        .padding()
                        .background(Color.lssElevatedSurface)
                        .cornerRadius(10)
                }
            }
        }
    }

    // MARK: - Subviews

    private var downloadsGrid: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                fileGrid(
                    title: localizationManager.localizedString(for: LocalizationKeys.documents),
                    items: downloadsService.pdfDownloads,
                    icon: "doc.text.fill"
                )

                if !downloadsService.videoDownloads.isEmpty {
                    fileGrid(
                        title: localizationManager.localizedString(for: LocalizationKeys.videos),
                        items: downloadsService.videoDownloads,
                        icon: "play.rectangle.fill"
                    )
                }
            }
            .padding(.vertical)
        }
    }

    private func fileGrid(title: String, items: [String], icon: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.lssPrimaryText)
                .padding(.horizontal)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 20) {
                ForEach(items, id: \.self) { urlPath in
                    Button(action: { openFile(urlPath: urlPath) }) {
                        VStack {
                            Image(systemName: icon)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 40)
                                .foregroundColor(.lssPrimaryText)

                            Text(displayName(for: urlPath))
                                .font(.caption)
                                .foregroundColor(.lssPrimaryText)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                        .padding()
                        .background(Color.lssSurface)
                        .cornerRadius(10)
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private var rawResponseView: some View {
        ScrollView {
            Text(downloadsService.rawResponse)
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.lssPrimaryText)
                .padding()
                .background(Color.lssCodeBackground)
                .cornerRadius(8)
        }
        .frame(maxHeight: 300)
        .padding(.horizontal)
    }

    // MARK: - Helpers

    private func displayName(for urlPath: String) -> String {
        (urlPath.components(separatedBy: "/").last?
            .components(separatedBy: "?").first ?? "Unknown")
            .replacingOccurrences(of: ".pdf", with: "")
            .replacingOccurrences(of: ".mp4", with: "")
            .replacingOccurrences(of: ".mov", with: "")
    }

    private func openFile(urlPath: String) {
        let ext = urlPath.components(separatedBy: "?")[0]
            .components(separatedBy: ".").last?.lowercased() ?? ""

        if ["mp4", "mov", "m4v"].contains(ext) {
            let base = KeycloakConfig.apiBaseURL
            let full = urlPath.hasPrefix("http") ? urlPath : base + urlPath
            if let url = URL(string: full) { playVideoURL = url }
        } else {
            guard let token = keycloakService.currentUserToken else { return }
            isDownloading = true
            downloadsService.downloadFile(urlPath: urlPath, accessToken: token) { localURL in
                isDownloading = false
                if let url = localURL { previewURL = url }
            }
        }
    }

    private func refreshDownloads() async {
        await withCheckedContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = downloadsService.$isLoading
                .dropFirst()
                .filter { !$0 }
                .first()
                .sink { _ in
                    cancellable?.cancel()
                    continuation.resume()
                }
            downloadsService.fetchDownloads(accessToken: keycloakService.currentUserToken)
        }
    }
}

// MARK: - URL Identifiable

extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}

// MARK: - QuickLook Preview

struct QuickLookPreview: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    class Coordinator: NSObject, QLPreviewControllerDataSource {
        let parent: QuickLookPreview
        init(parent: QuickLookPreview) { self.parent = parent }
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int { 1 }
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            parent.url as QLPreviewItem
        }
    }
}

// MARK: - Video Player

struct VideoPlayerView: UIViewControllerRepresentable {
    let url: URL
    let token: String?

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        let player: AVPlayer

        if let token = token, url.scheme == "http" || url.scheme == "https" {
            let asset = AVURLAsset(url: url, options: ["AVURLAssetHTTPHeaderFieldsKey": ["Authorization": "Bearer \(token)"]])

            if url.pathExtension.lowercased() == "m3u8" {
                let item = AVPlayerItem(asset: asset)
                context.coordinator.observePlayerItem(item)
                player = AVPlayer(playerItem: item)
            } else {
                player = AVPlayer(url: url)
            }
        } else {
            player = AVPlayer(url: url)
        }

        controller.player = player
        controller.player?.play()
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator() }

    class Coordinator: NSObject {
        var itemObserver: NSKeyValueObservation?
        var loaderDelegate: VideoResourceLoaderDelegate?

        func observePlayerItem(_ item: AVPlayerItem) {
            itemObserver = item.observe(\.status) { item, _ in
                #if DEBUG
                if item.status == .failed {
                    print("❌ Video error: \(String(describing: item.error))")
                }
                #endif
            }
        }
    }
}

#Preview {
    DownloadsView()
        .environmentObject(KeycloakService.shared)
        .environmentObject(DownloadsService.shared)
        .environmentObject(LocalizationManager.shared)
        .environmentObject(ThemeManager.shared)
}
