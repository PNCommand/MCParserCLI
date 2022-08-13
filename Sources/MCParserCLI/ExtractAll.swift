import ArgumentParser
import LvDBWrapper
import CoreBedrock

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
        
//        @Flag(name: .customShort("d"), help: "Delete output directory if exists.")
//        var deleteIfExists: Bool
        
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
        
        func run() throws {
            try createDirectories(true)
            print("\n========== ========== ========== ========== ========== ==========")
            print("Extract data from \(srcDir)")
            print("    to \(dstDir)")
            
            let dirURL = URL(fileURLWithPath: srcDir)
            let world = try MCDir(dirURL: dirURL, useSecurityScope: false).parser(onlyConnectDB: false)
            
            for key in world.wellKnownKeys {
                if let keyData = key.rawValue.data(using: .utf8), let value = world.db.get(keyData) {
                    let url = URL(fileURLWithPath: wellKnownDir + key.rawValue + ".nbt")
                    try value.write(to: url)
                }
            }
            for key in world.serverPlayers {
                if let keyData = key.serverID.data(using: .utf8), let value = world.db.get(keyData) {
                    let url = URL(fileURLWithPath: playerDir + key.serverID + ".nbt")
                    try value.write(to: url)
                    
                    let txtPath = playerDir + key.serverID + ".txt"
                    let playerIDs = key.serverID + "\n" + key.msaID + "\n" + key.signedID + "\n"
                    try playerIDs.write(toFile: txtPath, atomically: false, encoding: .utf8)
                }
            }
            for key in world.maps {
                if let value = world.db.get(key) {
                    let fileName = String(data: key, encoding: .utf8) ?? key.hexString
                    let url = URL(fileURLWithPath: mapDir + fileName + ".nbt")
                    try value.write(to: url)
                }
            }
            for key in world.villages {
                if let value = world.db.get(key) {
                    let fileName = String(data: key, encoding: .utf8) ?? key.hexString
                    let url = URL(fileURLWithPath: villageDir + fileName + ".nbt")
                    try value.write(to: url)
                }
            }
            for key in world.structures {
                if let value = world.db.get(key) {
                    let fileName = String(data: key, encoding: .utf8) ?? key.hexString
                    let url = URL(fileURLWithPath: structureDir + fileName + ".nbt")
                    try value.write(to: url)
                }
            }
            
            print("done! Total keys: \(world.keysCount)\n")
        }
        
        private func createDirectories(_ deleteIfExist: Bool = false) throws {
            let fileManager = FileManager.default
            
            if fileManager.fileExists(atPath: dstDir) {
                if deleteIfExist {
                    try fileManager.removeItem(atPath: dstDir)
                } else {
                    fatalError("Error: Output directory already exists --> \(dstDir)")
                }
            }
            
            try? fileManager.createDirectory(atPath: dstDir, withIntermediateDirectories: true)
            
//            try? fileManager.createDirectory(atPath: overworldDir, withIntermediateDirectories: true)
//            try? fileManager.createDirectory(atPath: netherdDir, withIntermediateDirectories: true)
//            try? fileManager.createDirectory(atPath: endDir, withIntermediateDirectories: true)
            
            try? fileManager.createDirectory(atPath: wellKnownDir, withIntermediateDirectories: true)
            try? fileManager.createDirectory(atPath: playerDir, withIntermediateDirectories: true)
            try? fileManager.createDirectory(atPath: mapDir, withIntermediateDirectories: true)
            try? fileManager.createDirectory(atPath: villageDir, withIntermediateDirectories: true)
            try? fileManager.createDirectory(atPath: structureDir, withIntermediateDirectories: true)
            
//            try? fileManager.createDirectory(atPath: actorprefixDir, withIntermediateDirectories: true)
//            try? fileManager.createDirectory(atPath: digpDir, withIntermediateDirectories: true)
            
//            try? fileManager.createDirectory(atPath: dstDir+"/Unknown", withIntermediateDirectories: true)
        }
    }
}
