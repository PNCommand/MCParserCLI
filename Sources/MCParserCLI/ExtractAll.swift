import ArgumentParser
import LvDBWrapper
import CoreBedrock

fileprivate class KeyCounter: Decodable {
    var total = 0
    var extracted = 0
    var unknown = 0

    var actorKeys = 0
    var digpKeys = 0
    var mapKeys = 0
    var villageKeys = 0
    var overworldChunkKeys = 0
    var netherKeys = 0
    var endKeys = 0

    var otherKeys: Int {
        return total - actorKeys - digpKeys
                - mapKeys - villageKeys
                - overworldChunkKeys - netherKeys
                - endKeys
    }
}

extension MCParserCLI {
    struct ExtractAll: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "extract-all",
            abstract: "extract all keys and save their data to files",
            discussion: "Use this subcommand to extract all data from leveldb.",
            shouldDisplay: true
        )
        
        @Option(name: .customLong("src"), help: "Path of a world directory.")
        var srcDir: String
        @Option(name: .customLong("dst"), help: "Path where output directory is.")
        var dstDir: String

        @Flag(name: .customLong("dry-run"), help: "Dry run command without saving anything")
        var dryRun = false
        @Flag(name: .customLong("override"), help: "Override output directory if exists.")
        var overrideOutputDir = false

        @Flag(name: .customShort("a"), help: "Extract keys for actorprefix")
        var saveActor = false
        @Flag(name: .customShort("c"), help: "Extract keys for subchunk")
        var saveChunk = false
        @Flag(name: .customShort("d"), help: "Extract keys for digp")
        var saveDigp = false
        @Flag(name: .customShort("m"), help: "Extract keys for map")
        var saveMap = false
        @Flag(name: .customShort("v"), help: "Extract keys for village")
        var saveVillage = false

        @Option(name: .customShort("l"), help: "Limit output for each directory.")
        var limit = 100
        
        private var overworldDir    : String { return dstDir + "/chunks/overworld/" }
        private var netherdDir      : String { return dstDir + "/chunks/nether/" }
        private var endDir          : String { return dstDir + "/chunks/end/" }
        
        private var mapDir          : String { return dstDir + "/maps/" }
        private var playerDir       : String { return dstDir + "/players/" }
        private var villageDir      : String { return dstDir + "/villages/" }
        private var wellKnownDir    : String { return dstDir + "/wellKnown/" }
        private var structureDir    : String { return dstDir + "/structures/" }
        
        private var actorprefixDir  : String { return dstDir + "/actorprefix/" }
        private var digpDir         : String { return dstDir + "/digp/" }
        private var unknownDir      : String { return dstDir + "/Unknown/" }

        private func createDirectories() throws {
            guard !dryRun else { return }
            let fileManager = FileManager.default

            if fileManager.fileExists(atPath: dstDir) {
                if overrideOutputDir {
                    try fileManager.removeItem(atPath: dstDir)
                } else {
                    fatalError("Error: Output directory already exists --> \(dstDir)")
                }
            }

            try? fileManager.createDirectory(atPath: dstDir, withIntermediateDirectories: true)

            try? fileManager.createDirectory(atPath: overworldDir, withIntermediateDirectories: true)
            try? fileManager.createDirectory(atPath: netherdDir, withIntermediateDirectories: true)
            try? fileManager.createDirectory(atPath: endDir, withIntermediateDirectories: true)

            try? fileManager.createDirectory(atPath: wellKnownDir, withIntermediateDirectories: true)
            try? fileManager.createDirectory(atPath: playerDir, withIntermediateDirectories: true)
            try? fileManager.createDirectory(atPath: mapDir, withIntermediateDirectories: true)
            try? fileManager.createDirectory(atPath: villageDir, withIntermediateDirectories: true)
            try? fileManager.createDirectory(atPath: structureDir, withIntermediateDirectories: true)

            try? fileManager.createDirectory(atPath: actorprefixDir, withIntermediateDirectories: true)
            try? fileManager.createDirectory(atPath: digpDir, withIntermediateDirectories: true)

            try? fileManager.createDirectory(atPath: unknownDir, withIntermediateDirectories: true)
        }

        private func parseWellKnownKey(_ keyData: Data) -> String? {
            guard let keyStr = String(data: keyData, encoding: .utf8),
                  let _ = MCWellKnownKey(rawValue: keyStr)
            else {
                return nil
            }
            return keyStr
        }

        private func parsePrefixedKey(_ keyData: Data, counter: KeyCounter) -> (dirName: String?, keyName: String, isNBT: Bool)? {
            guard let prefix = String(data: keyData[0...2], encoding: .utf8) else {
                return nil
            }
            var keyName = "skip"
            switch prefix {
            case "pla":
                keyName = String(data: keyData, encoding: .utf8)!
                return (playerDir, keyName, true)
            case "str":
                keyName = "structure(" + keyData.hexString + ")"
                return (structureDir, keyName, true)
            case "map":
                keyName = String(data: keyData, encoding: .utf8)!
                counter.mapKeys += 1
                if !saveMap || counter.mapKeys > limit {
                    return (nil, keyName, true)
                }
                return (mapDir, keyName, true)
            case "VIL":
                keyName = String(data: keyData, encoding: .utf8)!
                counter.villageKeys += 1
                if !saveVillage || counter.villageKeys > limit {
                    return (nil, keyName, true)
                }
                return (villageDir, keyName, true)
            case "act":
                let id = keyData[11...].hexString
                keyName = "actorprefix_\(id)"
                counter.actorKeys += 1
                if !saveActor || counter.actorKeys > limit {
                    return ("", keyName, true)
                }
                return (actorprefixDir, keyName, true)
            case "dig":
                let x = keyData[4...7].int32!
                let z = keyData[8...11].int32!
                keyName = "digp_(\(x),\(z))"
                counter.digpKeys += 1
                if !saveDigp || counter.digpKeys > limit {
                    return ("", keyName, false)
                }
                return (digpDir, keyName, false)
            default:
                return nil
            }
        }

        private func parseChunkKey(_ keyData: Data, counter: KeyCounter) -> (dirName: String?, keyName: String)? {
            guard [9, 10, 13, 14].contains(keyData.count) else { return nil }

            var index = 0
            let x = keyData[index..<(index+4)].int32!
            index += 4

            let z = keyData[index..<(index+4)].int32!
            index += 4

            var dimension = MCDimension.overworld
            if keyData.count > 10 {
                dimension = MCDimension(rawValue: keyData[index..<(index+4)].int32!)!
                index += 4
            }

            var type: String
            if let chunkType = MCChunkKeyType(rawValue: keyData[index]) {
                type = "\(chunkType)"
                if chunkType == .subChunkPrefix {
                    type += "(\(keyData[index+1].data.int8))"
                }
            } else {
                type = keyData[index...].hexString
            }

            let keyName = "(\(x),\(z))_\(type)"
            var dirName: String
            switch dimension {
            case .overworld:
                dirName = overworldDir
                counter.overworldChunkKeys += 1
                if counter.overworldChunkKeys > limit {
                    return (nil, keyName)
                }
            case .theNether:
                dirName = netherdDir
                counter.netherKeys += 1
                if counter.netherKeys > limit {
                    return (nil, keyName)
                }
            case .theEnd:
                dirName = endDir
                counter.endKeys += 1
                if counter.endKeys > limit {
                    return (nil, keyName)
                }
            }

            return (dirName, keyName)
        }

        func run() throws {
            try createDirectories()
            let dirURL = URL(fileURLWithPath: srcDir)
            let dbPath = dirURL.appendingPathComponent("db", isDirectory: true).path
            print("\n========== ========== ========== ========== ========== ==========")
            print("Extracting data ...)")
            print("    from \(dbPath)")
            print("    to \(dstDir)\n")

            guard let db = LvDB(dbPath: dbPath) else {
                throw CBLvDBError.failedOpenWorld(dirURL)
            }

            let counter = KeyCounter()
            db.seekToFirst()
            while db.valid() {
                defer {
                    counter.total += 1
                    db.next()
                }
                guard let keyData = db.key() else { continue }

                if let wellKnownKey = parseWellKnownKey(keyData) {
                    counter.extracted += 1
                    try save(to: wellKnownDir, fileName: wellKnownKey, value: db.value(), isNBT: true)
                    print("Extracted: \(wellKnownKey)")
                    continue
                }

                if let (dstDir, prefixedKey, isNBT) = parsePrefixedKey(keyData, counter: counter), prefixedKey != "skip" {
                    if let dstDir = dstDir {
                        counter.extracted += 1
                        try save(to: dstDir, fileName: prefixedKey, value: db.value(), isNBT: isNBT)
                        print("Extracted: \(prefixedKey)")
                    } else {
                        print("Skipped  : \(prefixedKey)")
                    }
                    continue
                }

                if let (dstDir, chunkKey) = parseChunkKey(keyData, counter: counter) {
                    if saveChunk, let dstDir = dstDir {
                        counter.extracted += 1
                        try save(to: dstDir, fileName: chunkKey, value: db.value(), isNBT: false)
                        print("Extracted: \(chunkKey)")
                    } else {
                        print("Skipped  : \(chunkKey)")
                    }
                    continue
                }

                counter.unknown += 1
                try save(to: unknownDir, fileName: keyData.hexString, value: db.value(), isNBT: false)
                print("Skipped unknown key: \(keyData.hexString)")
            }

            if !dryRun {
                try deleteEmptyDir(in: dstDir)
            }
            print("\nDone!")
            print("============= keys =============")
            print("Total     : \(counter.total)")
            print("Extracted : \(counter.extracted)")
            print("Unknown   : \(counter.unknown)")
            print("--------------------------------")
            print("Output limit for each directory is \(limit).")
            print("Actor     : \(counter.actorKeys)")
            print("Digp      : \(counter.digpKeys)")
            print("Map       : \(counter.mapKeys)")
            print("Village   : \(counter.villageKeys)")
            print("Subchunk  : Overworld=\(counter.overworldChunkKeys), TheNether=\(counter.netherKeys), TheEnd=\(counter.endKeys)")
            print("Others    : \(counter.otherKeys)")
        }

        private func save(to dirPath: String, fileName: String, value: Data, isNBT: Bool) throws {
            guard !dryRun else { return }
            let filePath = dirPath + fileName + (isNBT ? ".nbt" : "") + (value.count == 0 ? ".empty" : "")
            let url = URL(fileURLWithPath: filePath)
            try value.write(to: url)
        }

        @inlinable
        public func isDir(path: String) throws -> Bool {
            var isDirectory: ObjCBool = false
            FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
            return isDirectory.boolValue
        }

        @inlinable
        public func isEmptyDir(path: String) throws -> Bool {
            let contents = try FileManager.default.contentsOfDirectory(atPath: path)
            return contents.count == 0
        }

        private func deleteEmptyDir(in rootDir: String) throws {
            guard try isDir(path: rootDir) else { return }

            let contents = try FileManager.default.contentsOfDirectory(atPath: rootDir)
            for content in contents {
                let contentPath = "\(rootDir)/\(content)"
                guard try isDir(path: contentPath) else { continue }

                if try isEmptyDir(path: contentPath) {
                    try FileManager.default.removeItem(atPath: contentPath)
                    print("Remove empty directory: \(contentPath)")
                } else {
                    try deleteEmptyDir(in: contentPath)
                }
            }
        }
    }
}
