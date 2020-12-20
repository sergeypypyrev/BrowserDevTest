import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        History.instance.restore()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        History.instance.save()
    }

}

