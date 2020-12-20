import WebKit

class PopupViewController: WebViewController, WKScriptMessageHandler {
    
    private var extensionHandler = ExtensionURLSchemeHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configuration = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        let browser = """
            var browser = {
                topSites: {
                    get: function () {
                        return new Promise(resolve => {
                            browser.resolve = resolve;
                            window.webkit.messageHandlers.topSites.postMessage(12)
                        });
                    }
                },
                storage: {
                    local: {
                        get: value => {
                            return new Promise(resolve => {
                                resolve(value);
                            });
                        }
                    }
                },
                tabs: {
                    create: info => {
                        window.webkit.messageHandlers.tabs.postMessage(info)
                    }
                }
            };
            browser.tabs.update = browser.tabs.create;
        """
        let script = WKUserScript(source: browser, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        contentController.addUserScript(script)
        contentController.add(self, name: "topSites")
        contentController.add(self, name: "tabs")
        configuration.userContentController = contentController
        configuration.setURLSchemeHandler(extensionHandler, forURLScheme: "extension")
        createWebView(frame: CGRect(x: 0, y: 0, width: 300, height: 500), configuration: configuration)

        let (popup, _, errorDetails) = Manifest.instance.getDefaultPopup()
        if popup == nil {
            webView.loadHTMLString(errorDetails!, baseURL: URL(string: "about:blank"))
        }
        else {
            if let url = URL(string: "extension://current/" + popup!) {
                webView.load(URLRequest(url: url))
            }
        }
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "topSites":
            if let limit = message.body as? Int {
                do {
                    let data = try JSONSerialization.data(withJSONObject: History.instance.getEntries(limit: limit))
                    if let json = String(data: data, encoding: .utf8) {
                        webView.evaluateJavaScript("browser.resolve(JSON.parse('" + json + "'))")
                    }
                }
                catch {
                    print(error)
                }
            }
            break
        case "tabs":
            if let info = message.body as? [String: Any],
               let url = info["url"] {
                NotificationCenter.default.post(name: ViewController.urlNotificationName, object: nil, userInfo: ["url": url])
            }
            break
        default:
            break
        }
    }

}
