import WebKit
import Zip

class BrowserViewController: WebViewController, WKNavigationDelegate, WKScriptMessageHandler {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configuration = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        let script = WKUserScript(source: "window.webkit.messageHandlers.history.postMessage({title: document.title, url: location.href})", injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        contentController.addUserScript(script)
        contentController.add(self, name: "history")
        configuration.userContentController = contentController
        createWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        guard let response = navigationResponse.response as? HTTPURLResponse,
              let headers = response.allHeaderFields as? [String: Any],
              let contentType = headers["Content-Type"] as? String,
              contentType == "application/x-xpinstall"
        else {
            decisionHandler(.allow)
            return
        }
        let fm = FileManager.default
        let file = fm.temporaryDirectory.appendingPathComponent("extension.zip")
        let directory = fm.temporaryDirectory.appendingPathComponent("extension", isDirectory: true)
        URLSession.shared.dataTask(with: navigationResponse.response.url!) { data, response, error in
            if data == nil || error != nil {
                return
            }
            do {
                try data!.write(to: file, options: .atomic)
                if fm.fileExists(atPath: directory.path) {
                    try fm.removeItem(at: directory)
                }
                try fm.createDirectory(at: directory, withIntermediateDirectories: false, attributes: nil)
                try Zip.unzipFile(file, destination: directory, overwrite: true, password: nil)
            }
            catch {
                print(error)
            }
        }.resume()
        decisionHandler(.cancel)
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "history",
           let body = message.body as? [String: String],
           let title = body["title"],
           let url = body["url"] {
            History.instance.addEntry(title: title, url: url)
        }
    }
    
}
