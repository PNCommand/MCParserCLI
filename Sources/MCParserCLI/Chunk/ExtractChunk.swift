import ArgumentParser
import LvDBWrapper
import CoreBedrock

extension MCParserCLI {
    struct ExtractChunk: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "extract-chunk",
            abstract: "extract and save data in a chunk",
            discussion: "Use this subcommand to extract data from a chunk.",
            shouldDisplay: true
        )
        
        @Option(name: .customLong("src"), help: "Path of a db directory.")
        var srcDir: String
        
        @Option(name: .customLong("dst"), help: "Path where output directory is.")
        var dstDir: String
        
        @Option(name: .customShort("d"), help: "World dimension. overworld = 0, theNether = 1, theEnd = 2")
        var dimension: Int32 = 0
        @Option(name: .customLong("xindex"), help: "X index of a chunk.")
        var xIndex: Int32
        @Option(name: .customLong("zindex"), help: "Z index of a chunk.")
        var zIndex: Int32
        
        func run() throws {
            guard let dimension = MCDimension(rawValue: dimension) else {
                fatalError("Error: wrong dimension")
            }
            guard let db = LvDB(dbPath: srcDir) else {
                fatalError("Error: can't open db \(srcDir)")
            }
            print("\n========== ========== ========== ========== ========== ==========")
            print("Extract chunk \(dimension)(\(xIndex), \(zIndex)) from \(srcDir)/db")
            print("    to \(dstDir)")

            let rootDirURL = URL(fileURLWithPath: "\(dstDir)/\(xIndex)_\(zIndex)")
            if FileManager.default.fileExists(atPath: rootDirURL.path) {
                try FileManager.default.removeItem(atPath: rootDirURL.path)
            } else {
                try FileManager.default.createDirectory(at: rootDirURL, withIntermediateDirectories: true)
            }

            for key in db.getChunkKeys(x: xIndex, z: zIndex, dimension: dimension) {
                try saveValue(db: db, rootDirURL: rootDirURL, key: key)
                print("    Extract key: \(key.hexString)")
            }

            let prefix = LvDBKey.makeChunkKeyPrefix(x: xIndex, z: zIndex, dimension: dimension)
            let digp = "digp".data(using: .utf8)! + prefix
            if let digpData = db.get(digp), digpData.count > 0, digpData.count % 8 == 0 {
                for i in 0..<digpData.count/8 {
                    let actorprefix = "actorprefix".data(using: .utf8)! + digpData[i*8...i*8+7]
                    try saveValue(db: db, rootDirURL: rootDirURL, key: actorprefix)
                    print("    Extract key: actorprefix_\(digpData[i*8...i*8+7].hexString)")
                }
                try saveValue(db: db, rootDirURL: rootDirURL, key: digp)
                print("    Extract key: digp_\(prefix.hexString)")
            }
            
        }
        
        func saveValue(db: LvDB, rootDirURL: URL, key: Data) throws {
            if let value = db.get(key) {
                let dstFileURL = rootDirURL.appendingPathComponent(key.hexString)
                try value.write(to: dstFileURL)
            }
        }
    }
}
