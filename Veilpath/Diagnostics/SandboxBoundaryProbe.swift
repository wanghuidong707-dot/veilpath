import Foundation

/// Non-destructive probes. A successful operation proves only the specific
/// path and access method used; it never implies arbitrary access to /var.
enum SandboxBoundaryProbe {
    nonisolated static func run() -> [SelfTestReport.Check] {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return [
            canaryRoundTrip(in: documents, label: "Own sandbox canary roundtrip", permissionDenialIsUnsupported: false),
            directoryEnumeration(at: "/var/mobile/Library", label: "Direct /var/mobile/Library enumeration"),
            directoryEnumeration(at: "/var/mobile/Containers/Data/Application", label: "Direct application-container enumeration"),
            canaryRoundTrip(in: URL(fileURLWithPath: "/var/tmp", isDirectory: true),
                            label: "Outside-sandbox /var/tmp fresh-file roundtrip",
                            permissionDenialIsUnsupported: true)
        ]
    }

    nonisolated private static func directoryEnumeration(at path: String, label: String) -> SelfTestReport.Check {
        let start = ContinuousClock.now
        do {
            // Never describe this as file-read access or a writable directory.
            let children = try FileManager.default.contentsOfDirectory(atPath: path)
            return check(label, path: path, status: .passed,
                         detail: "operation=contentsOfDirectory; childCount=\(children.count); method=direct; no file contents read",
                         since: start)
        } catch {
            return check(label, path: path, status: .unsupported,
                         detail: "operation=contentsOfDirectory; result=denied_or_unavailable; \(errorSummary(error))",
                         since: start)
        }
    }

    nonisolated private static func canaryRoundTrip(
        in directory: URL,
        label: String,
        permissionDenialIsUnsupported: Bool
    ) -> SelfTestReport.Check {
        let start = ContinuousClock.now
        // A newly generated name ensures no existing file is overwritten.
        let fileURL = directory.appendingPathComponent("veilpath-permission-probe-\(UUID().uuidString).txt")
        let contents = Data("veilpath-canary-\(UUID().uuidString)".utf8)
        var mayNeedCleanup = false
        defer {
            if mayNeedCleanup {
                try? FileManager.default.removeItem(at: fileURL)
            }
        }

        do {
            try contents.write(to: fileURL, options: .atomic)
            mayNeedCleanup = true
        } catch {
            return check(label, path: directory.path, status: permissionDenialIsUnsupported ? .unsupported : .failed,
                         detail: "operation=create_new_file; result=denied_or_unavailable; \(errorSummary(error)); no protected file touched",
                         since: start)
        }

        do {
            let recovered = try Data(contentsOf: fileURL)
            guard recovered == contents else {
                return check(label, path: directory.path, status: .failed,
                             detail: "operation=readback; result=content_mismatch", since: start)
            }

            try FileManager.default.removeItem(at: fileURL)
            mayNeedCleanup = false
            guard !FileManager.default.fileExists(atPath: fileURL.path) else {
                return check(label, path: directory.path, status: .failed,
                             detail: "operation=cleanup; result=still_exists", since: start)
            }
            return check(label, path: directory.path, status: .passed,
                         detail: "operations=create_new_file,readback_exact_bytes,delete; bytes=\(contents.count); cleanup=verified; existing_files=untouched",
                         since: start)
        } catch {
            return check(label, path: directory.path, status: .failed,
                         detail: "operation=readback_or_cleanup; \(errorSummary(error)); best_effort_cleanup=requested",
                         since: start)
        }
    }

    nonisolated private static func errorSummary(_ error: Error) -> String {
        let nsError = error as NSError
        return "errorDomain=\(nsError.domain); errorCode=\(nsError.code)"
    }

    nonisolated private static func check(
        _ name: String,
        path: String,
        status: SelfTestReport.Check.Status,
        detail: String,
        since start: ContinuousClock.Instant
    ) -> SelfTestReport.Check {
        let interval = start.duration(to: .now)
        let duration = Int(interval.components.seconds * 1_000
                           + interval.components.attoseconds / 1_000_000_000_000_000)
        return .init(name: name, path: path, status: status, detail: detail, durationMilliseconds: duration)
    }
}
