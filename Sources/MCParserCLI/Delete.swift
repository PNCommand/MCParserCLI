import Foundation
import ArgumentParser
import LvDBWrapper
import CoreBedrock

extension MCParserCLI {
    struct Delete: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "delete",
            abstract: "delete chunks from leveldb",
            discussion: "Use this subcommand to delete chunks within the specified range.",
            shouldDisplay: true
        )
        
        @Option(name: .customLong("src"), help: "Path of a db directory.")
        var srcDir: String
        
        @Option(name: .customShort("d"), help: "World dimension. overworld = 0, theNether = 1, theEnd = 2")
        var dimension: Int32
        @Option(name: .customLong("xstart"), help: "X index of a chunk.")
        var xStart: Int32
        @Option(name: .customLong("xend"), help: "X index of a chunk.")
        var xEnd: Int32
        @Option(name: .customLong("zstart"), help: "Z index of a chunk.")
        var zStart: Int32
        @Option(name: .customLong("zend"), help: "Z index of a chunk.")
        var zEnd: Int32
        
        func run() throws {
            guard let dimension = MCDimension(rawValue: dimension) else {
                fatalError("Error: wrong dimension")
            }
            guard xStart <= xEnd, zStart <= zEnd else {
                fatalError("Error: wrong range")
            }
            guard let db = LvDB(dbPath: srcDir) else {
                fatalError("Error: can't open db \(srcDir)")
            }
            print("\n========== ========== ========== ========== ========== ==========")
            print("Delete data from \(srcDir)/db")
            print("\(dimension) ==> xRange: \(xStart...xEnd), zRange: \(zStart...zEnd)")
            
            for x in xStart...xEnd {
                for z in zStart...zEnd {
                    
                    print("========== ========== ========== ========== ==========")
                    print("Delete chunk (\(x), \(z))")
                    let prefix = dimension == .overworld ? x.data + z.data : x.data + z.data + dimension.rawValue.data
                    let start = prefix + Data([MCChunkKeyType.keyTypeStartWith])
                    db.seek(start)
                    while db.valid() {
                        guard let key = db.key(), key[0..<prefix.count] == prefix else { break }
                        
                        if db.remove(key) {
                            print("    Delete key: \(key.hexString)")
                        } else {
                            print("    Error ==> Delete key: \(key.hexString)")
                        }
                        db.next()
                    }
                    
                    print("Delete digp & actorprefix in chunk (\(x), \(z))")
                    let digp = "digp".data(using: .utf8)! + prefix
                    if let digpData = db.get(digp), digpData.count > 0, digpData.count % 8 == 0 {
                        for i in 0..<digpData.count/8 {
                            let actorprefix = "actorprefix".data(using: .utf8)! + digpData[i*8...i*8+7]
                            if db.remove(actorprefix) {
                                print("    Delete actorprefix: \(actorprefix.hexString)")
                            } else {
                                print("    Error ==> Delete actorprefix: \(actorprefix.hexString)")
                            }
                        }
                        if db.remove(digp) {
                            print("    Delete digp: \(digp.hexString)")
                        } else {
                            print("    Delete digp: \(digp.hexString)")
                        }
                    }
                    
                    print("")
                }
            }
            
            print("done!\n")
        }
    }
}
