import Cocoa

class ViewController: NSViewController {
    static let urlNotificationName = Notification.Name("urlNotification")

    var webViewController: BrowserViewController?
    var popupController: NSWindowController?

    @IBOutlet weak var urlField: NSTextField!

    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: ViewController.urlNotificationName, object: nil)
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "webViewSegue" {
            if let destination = segue.destinationController as? BrowserViewController {
                webViewController = destination
            }
        }
    }

    @IBAction func urlEntered(_ sender: NSTextField) {
        var string = sender.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if !string.contains("://") {
            string = "http://" + string
        }
        if let webView = webViewController?.webView {
            if let url = URL(string: string) {
                let request = URLRequest(url: url)
                webView.load(request)
                sender.stringValue = ""
            }
        }
    }
    
    @IBAction func backClicked(_ sender: NSButton) {
        if let webView = webViewController?.webView {
            webView.goBack()
        }
    }
    
    @IBAction func popupClicked(_ sender: Any) {
        let (popup, error, errorDetails) = Manifest.instance.getDefaultPopup()
        if popup == nil {
            alert(messageText: error!, informativeText: errorDetails!)
        }
        else {
            let storyboard = NSStoryboard(name: "Main", bundle: nil)
            popupController = storyboard.instantiateController(identifier: "popupWindow")
            popupController?.showWindow(nil)
        }
    }
    
    @objc func onNotification(notification: Notification) {
        if let url = notification.userInfo!["url"] as? String,
           let webView = webViewController?.webView {
            webView.load(URLRequest(url: URL(string: url)!))
            popupController?.close()
        }
    }
    
    private func alert(messageText: String, informativeText: String) {
        let alert = NSAlert()
        alert.messageText = messageText
        alert.informativeText = informativeText
        alert.addButton(withTitle: "OK")
        alert.alertStyle = .warning
        alert.runModal()
    }
}
