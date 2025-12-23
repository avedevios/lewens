//
//  DownloadsView.swift
//  lewens
//
//  Created by Anton Averianov on 2025-09-02.
//

import SwiftUI

struct DownloadsView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var showLanguagePicker = false
    @ObservedObject private var languageManager = LanguageManager.shared
    @ObservedObject private var downloadsService = DownloadsService.shared
    
    @State private var previewURL: URL?
    @State private var playVideoURL: URL?
    @State private var isDownloading = false
    
    var body: some View {
        ZStack {
            // Unified app background
            AppBackground()
            
            VStack {
                // Logo header
                LogoHeader(
                    showLanguageButton: false,
                    showLanguagePicker: $showLanguagePicker,
                    languageManager: languageManager,
                    localizationManager: localizationManager
                )
                
                Spacer()
                
                // Title
                LocalizedText(LocalizationKeys.downloads)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                LocalizedText(LocalizationKeys.downloadsDescription)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.top, 10)
                
                // Debug Section
                VStack(spacing: 20) {
                    Button(action: {
                        DownloadsService.shared.fetchDownloads()
                    }) {
                        Text("Fetch Downloads List")
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                    
                    if DownloadsService.shared.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                    
                // PDF Grid View
                if !DownloadsService.shared.pdfDownloads.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            Text(localizationManager.localizedString(for: LocalizationKeys.documents))
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 20) {
                                ForEach(DownloadsService.shared.pdfDownloads, id: \.self) { urlPath in
                                    Button(action: {
                                        downloadAndOpenFile(urlPath: urlPath)
                                    }) {
                                        VStack {
                                            Image(systemName: "doc.text.fill")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(height: 40)
                                                .foregroundColor(.white)
                                            
                                            Text(extractFilename(from: urlPath))
                                                .font(.caption)
                                                .foregroundColor(.white)
                                                .multilineTextAlignment(.center)
                                                .lineLimit(2)
                                        }
                                        .padding()
                                        .background(Color.white.opacity(0.1))
                                        .cornerRadius(10)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            // Video Grid View
                            if !DownloadsService.shared.videoDownloads.isEmpty {
                                Text(localizationManager.localizedString(for: LocalizationKeys.videos))
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                    .padding(.top, 10)
                                
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 20) {
                                    ForEach(DownloadsService.shared.videoDownloads, id: \.self) { urlPath in
                                        Button(action: {
                                            downloadAndOpenFile(urlPath: urlPath)
                                        }) {
                                            VStack {
                                                Image(systemName: "play.rectangle.fill")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(height: 40)
                                                    .foregroundColor(.white)
                                                
                                                Text(extractFilename(from: urlPath))
                                                    .font(.caption)
                                                    .foregroundColor(.white)
                                                    .multilineTextAlignment(.center)
                                                    .lineLimit(2)
                                            }
                                            .padding()
                                            .background(Color.white.opacity(0.1))
                                            .cornerRadius(10)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                } else if !DownloadsService.shared.rawResponse.isEmpty {
                        // Fallback to raw response if parsing failed but we have data
                        ScrollView {
                            Text(DownloadsService.shared.rawResponse)
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.5))
                                .cornerRadius(8)
                        }
                        .frame(maxHeight: 300)
                        .padding(.horizontal)
                    }
                    
                    if let error = DownloadsService.shared.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                .padding(.top, 30)
                
                Spacer()
                
                // Copyright text - bottom
                LocalizedText(LocalizationKeys.copyright)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.bottom, 20)
            }
        }
        .sheet(item: $previewURL) { url in
            QuickLookPreview(url: url)
        }
        .sheet(item: $playVideoURL) { url in
            VideoPlayerView(url: url, token: KeycloakService.shared.currentUserToken)
                .edgesIgnoringSafeArea(.all)
        }
        .overlay(
            Group {
                if isDownloading {
                    ZStack {
                        Color.black.opacity(0.4)
                            .edgesIgnoringSafeArea(.all)
                        ProgressView("Downloading...")
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                }
            }
        )
    }
    
    private func extractFilename(from urlPath: String) -> String {
        // Extract filename from URL path and remove extension
        let filenameWithExt = urlPath.components(separatedBy: "/").last?.components(separatedBy: "?")[0] ?? "Unknown"
        return filenameWithExt
            .replacingOccurrences(of: ".pdf", with: "")
            .replacingOccurrences(of: ".mp4", with: "")
            .replacingOccurrences(of: ".mov", with: "")
    }
    
    private func downloadAndOpenFile(urlPath: String) {
        // Check file extension to decide how to open
        let ext = urlPath.components(separatedBy: "?")[0].components(separatedBy: ".").last?.lowercased() ?? ""
        
        if ext == "mp4" || ext == "mov" || ext == "m4v" {
            // Stream video directly
            let baseURL = "http://188.245.191.46:8082"
            let fullString = urlPath.hasPrefix("http") ? urlPath : baseURL + urlPath
            if let url = URL(string: fullString) {
                playVideoURL = url
            }
        } else {
            // Download other files (PDFs)
            isDownloading = true
            DownloadsService.shared.downloadFile(urlPath: urlPath) { localURL in
                isDownloading = false
                if let url = localURL {
                    previewURL = url
                }
            }
        }
    }
}

// Extension to make URL Identifiable for sheet
extension URL: Identifiable {
    public var id: String { absoluteString }
}

import QuickLook

struct QuickLookPreview: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, QLPreviewControllerDataSource {
        let parent: QuickLookPreview
        
        init(parent: QuickLookPreview) {
            self.parent = parent
        }
        
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return 1
        }
        
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            return parent.url as QLPreviewItem
        }
    }
}

#Preview {
    DownloadsView()
}

import AVKit
import AVFoundation

struct VideoPlayerView: UIViewControllerRepresentable {
    let url: URL
    let token: String?
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        
        let player: AVPlayer
        if let token = token {
            // Use custom scheme to trigger resource loader delegate
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.scheme = "lewens-auth"
            
            if let customURL = components?.url {
                let asset = AVURLAsset(url: customURL)
                let loaderDelegate = VideoResourceLoaderDelegate(token: token)
                
                // Keep a strong reference to the delegate in the coordinator
                context.coordinator.loaderDelegate = loaderDelegate
                asset.resourceLoader.setDelegate(loaderDelegate, queue: DispatchQueue.global(qos: .userInitiated))
                
                let playerItem = AVPlayerItem(asset: asset)
                player = AVPlayer(playerItem: playerItem)
                
                // Observe status via coordinator
                context.coordinator.observePlayerItem(playerItem)
            } else {
                player = AVPlayer(url: url)
            }
        } else {
            player = AVPlayer(url: url)
        }
        
        controller.player = player
        controller.player?.play() // Auto-play
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject {
        var itemObserver: NSKeyValueObservation?
        var loaderDelegate: VideoResourceLoaderDelegate? // Keep strong reference
        
        func observePlayerItem(_ item: AVPlayerItem) {
            itemObserver = item.observe(\.status) { item, _ in
                if item.status == .failed {
                    print("❌ Video Player Error: \(String(describing: item.error))")
                    if let errorLog = item.errorLog() {
                        print("❌ Error Log Events: \(errorLog.events)")
                    }
                }
            }
        }
    }
}
