import WebKit

enum ExtensionError: Error {
    case initializationError
    case inputError
}

class ExtensionURLSchemeHandler: NSObject, WKURLSchemeHandler {
    
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let url = urlSchemeTask.request.url else {
            urlSchemeTask.didFailWithError(ExtensionError.initializationError)
            return
        }
        let file = FileManager.default.temporaryDirectory.appendingPathComponent("extension" + url.path)
        do {
            let data = try Data(contentsOf: file)
            var mimeType = "text/plain"
            switch url.pathExtension.lowercased() {
            case "js":
                mimeType = "text/javascript"
            case "html", "htm":
                mimeType = "text/html"
            case "css":
                mimeType = "text/css"
            case "png":
                mimeType = "image/png"
            case "json":
                mimeType = "application/json"
            default:
                break
            }
            urlSchemeTask.didReceive(URLResponse(url: url, mimeType: mimeType, expectedContentLength: data.count, textEncodingName: nil))
            urlSchemeTask.didReceive(data)
            urlSchemeTask.didFinish()
        }
        catch {
            urlSchemeTask.didFailWithError(ExtensionError.inputError)
        }
    }

    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
    }
        
}
