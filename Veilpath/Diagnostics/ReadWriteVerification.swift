import Foundation

/// Verifies genuine file writes within this application's own temporary directory.
enum ReadWriteVerification {
    static func run() -> (success: Bool, message: String) {
        let fm = FileManager.default
        let root = fm.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        let item = root.appendingPathComponent("check.txt")
        do {
            try fm.createDirectory(at: root, withIntermediateDirectories: false)
            defer { try? fm.removeItem(at: root) }
            let first = Data("first".utf8)
            try first.write(to: item, options: .atomic)
            guard try Data(contentsOf: item) == first else { return (false, "first readback mismatch") }
            let second = Data("second".utf8)
            try second.write(to: item, options: .atomic)
            guard try Data(contentsOf: item) == second else { return (false, "second readback mismatch") }
            try fm.removeItem(at: item)
            guard !fm.fileExists(atPath: item.path) else { return (false, "delete failed") }
            return (true, "read/write/modify/delete verified in app temporary directory")
        } catch {
            return (false, error.localizedDescription)
        }
    }
}
