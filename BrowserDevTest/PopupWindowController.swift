import Cocoa

class PopupWindowController: NSWindowController, NSWindowDelegate {
    
    override func windowDidLoad() {
        if window != nil {
            window!.delegate = self
        }
    }
    
    func windowDidResignKey(_ notification: Notification) {
        window!.close()
    }
    
}
