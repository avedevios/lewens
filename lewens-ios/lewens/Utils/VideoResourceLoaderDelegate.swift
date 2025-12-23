import Foundation
import AVFoundation
import MobileCoreServices

class VideoResourceLoaderDelegate: NSObject, AVAssetResourceLoaderDelegate {
    private let token: String
    
    init(token: String) {
        self.token = token
        super.init()
    }
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        guard let url = loadingRequest.request.url else { return false }
        
        // Construct the actual URL (replace custom scheme if we use one, or just use as is)
        // We will use a custom scheme 'lewens-auth' to trigger this delegate, so we need to replace it back to 'http' or 'https'
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.scheme = "http" // Or https, depending on your server. The current server is http.
        
        guard let actualURL = components?.url else { return false }
        
        var request = URLRequest(url: actualURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Handle Range Request
        if let dataRequest = loadingRequest.dataRequest {
            let lower = dataRequest.requestedOffset
            let upper = lower + Int64(dataRequest.requestedLength) - 1
            let rangeHeader = "bytes=\(lower)-\(upper)"
            request.setValue(rangeHeader, forHTTPHeaderField: "Range")
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Resource Loader Error: \(error)")
                loadingRequest.finishLoading(with: error)
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse else {
                loadingRequest.finishLoading(with: NSError(domain: "com.lewens.error", code: -1, userInfo: nil))
                return
            }
            
            if response.statusCode >= 400 {
                print("❌ Server returned error status: \(response.statusCode)")
                loadingRequest.finishLoading(with: NSError(domain: "com.lewens.error", code: response.statusCode, userInfo: nil))
                return
            }
            
            // Fill Content Information
            if let contentInformationRequest = loadingRequest.contentInformationRequest {
                contentInformationRequest.contentType = response.mimeType ?? "video/mp4"
                contentInformationRequest.contentLength = response.expectedContentLength
                
                // Check if server supports ranges (206 Partial Content or Accept-Ranges header)
                let supportsRanges = (response.statusCode == 206) || ((response.allHeaderFields["Accept-Ranges"] as? String) == "bytes")
                contentInformationRequest.isByteRangeAccessSupported = supportsRanges
                
                // If Content-Range header is present, parse total length from it
                if let contentRange = response.allHeaderFields["Content-Range"] as? String {
                    // Example: bytes 0-1023/2048
                    if let totalLengthString = contentRange.components(separatedBy: "/").last,
                       let totalLength = Int64(totalLengthString) {
                        contentInformationRequest.contentLength = totalLength
                    }
                }
            }
            
            // Respond with data
            if let dataRequest = loadingRequest.dataRequest {
                dataRequest.respond(with: data)
            }
            
            loadingRequest.finishLoading()
        }
        
        task.resume()
        return true
    }
}
