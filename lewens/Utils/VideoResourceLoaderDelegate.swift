import Foundation
import AVFoundation

/// Intercepts AVPlayer resource loading requests to inject a Bearer token.
/// Uses downloadTask so video data is streamed to disk rather than held in memory.
class VideoResourceLoaderDelegate: NSObject, AVAssetResourceLoaderDelegate {
    private let token: String

    init(token: String) {
        self.token = token
        super.init()
    }

    func resourceLoader(
        _ resourceLoader: AVAssetResourceLoader,
        shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest
    ) -> Bool {
        guard let url = loadingRequest.request.url,
              var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return false
        }

        // Replace custom scheme back to http/https
        components.scheme = url.scheme == "lewens-auth" ? "http" : url.scheme

        guard let actualURL = components.url else { return false }

        var request = URLRequest(url: actualURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // Forward range request if present
        if let dataRequest = loadingRequest.dataRequest {
            let lower = dataRequest.requestedOffset
            let upper = lower + Int64(dataRequest.requestedLength) - 1
            request.setValue("bytes=\(lower)-\(upper)", forHTTPHeaderField: "Range")
        }

        // Use downloadTask — data is written to a temp file, not held in memory
        let task = URLSession.shared.downloadTask(with: request) { tempURL, response, error in
            if let error = error {
                #if DEBUG
                print("❌ Resource Loader Error: \(error)")
                #endif
                loadingRequest.finishLoading(with: error)
                return
            }

            guard let tempURL = tempURL,
                  let response = response as? HTTPURLResponse else {
                loadingRequest.finishLoading(with: NSError(
                    domain: "com.lewens.error", code: -1, userInfo: nil
                ))
                return
            }

            if response.statusCode >= 400 {
                #if DEBUG
                print("❌ Server returned error status: \(response.statusCode)")
                #endif
                loadingRequest.finishLoading(with: NSError(
                    domain: "com.lewens.error", code: response.statusCode, userInfo: nil
                ))
                return
            }

            // Fill content information
            if let contentInfo = loadingRequest.contentInformationRequest {
                contentInfo.contentType = response.mimeType ?? "video/mp4"
                contentInfo.contentLength = response.expectedContentLength

                let supportsRanges = response.statusCode == 206
                    || (response.allHeaderFields["Accept-Ranges"] as? String) == "bytes"
                contentInfo.isByteRangeAccessSupported = supportsRanges

                if let contentRange = response.allHeaderFields["Content-Range"] as? String,
                   let totalStr = contentRange.components(separatedBy: "/").last,
                   let total = Int64(totalStr) {
                    contentInfo.contentLength = total
                }
            }

            // Read downloaded data from temp file and respond
            if let dataRequest = loadingRequest.dataRequest,
               let data = try? Data(contentsOf: tempURL) {
                dataRequest.respond(with: data)
            }

            loadingRequest.finishLoading()
        }

        task.resume()
        return true
    }
}
