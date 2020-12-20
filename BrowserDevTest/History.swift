import Foundation

class History {
    
    private var entries = [[String: Any]]()
    
    static let instance = History()
    
    private let saveTo = FileManager.default.temporaryDirectory.appendingPathComponent("history.data")
    
    func addEntry(title: String, url: String) {
        for (index, entry) in entries.enumerated() {
            if let eurl = entry["url"] as? String,
               eurl == url,
               let visits = entry["visits"] as? Int {
                entries[index]["visits"] = visits + 1
                return
            }
        }
        entries.append(["title": title, "url": url, "visits": 1])
    }
    
    func getEntries(limit: Int) -> [[String: String]] {
        entries.sort {
            if let first = $0["visits"] as? Int,
               let second = $1["visits"] as? Int {
                return first > second
            }
            return false
        }
        var result = [[String: String]]()
        for entry in entries {
            if result.count >= limit {
                break
            }
            if let title = entry["title"] as? String,
               let url = entry["url"] as? String {
                var add = [String: String]()
                add["title"] = title
                add["url"] = url
                result.append(add)
            }
        }
        return result
    }
    
    func save() {
        do {
            let data = try JSONSerialization.data(withJSONObject: entries)
            try data.write(to: saveTo, options: .atomic)
        }
        catch {
            print(error)
        }
    }
    
    func restore() {
        do {
            let data = try Data(contentsOf: saveTo)
            let json = try JSONSerialization.jsonObject(with: data)
            if let root = json as? [[String: Any]] {
                entries = root
            }
        }
        catch {
        }
    }
    
}
