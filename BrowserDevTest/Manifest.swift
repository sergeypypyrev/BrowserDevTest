import WebKit

class Manifest {
    
    static let instance = Manifest()
    
    func getDefaultPopup() -> (popup: String?, error: String?, errorDetails: String?) {
        let fm = FileManager.default
        let manifest = fm.temporaryDirectory.appendingPathComponent("extension/manifest.json")
        guard fm.isReadableFile(atPath: manifest.path) else {
            return (popup: nil, error: "Not installed", errorDetails: "Extension not installed")
        }
        do {
            let data = try Data(contentsOf: manifest)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            if let root = json as? [String: Any],
               let browserAction = root["browser_action"] as? [String: Any],
               let popup = browserAction["default_popup"] as? String {
                return (popup: popup, error: nil, errorDetails: nil)
            }
        }
        catch {
            print(error)
        }
        return (popup: nil, error: "No popup", errorDetails: "Extension does not have default popup")
    }
    
}
