import ArgumentParser
import LvDBWrapper
import CoreBedrock

extension MCParserCLI {
    struct BlockPalette: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "block-palette",
            abstract: "extract block palettes from a chunk",
            discussion: "Use this subcommand to extract block palettes from a chunk.",
            shouldDisplay: true
        )

        @Option(name: .customLong("src"), help: "Path of a db directory.")
        var srcDir: String

        @Option(name: .customShort("d"), help: "World dimension. overworld = 0, theNether = 1, theEnd = 2")
        var dimension: Int32 = 0
        @Option(name: .customLong("xindex"), help: "X index of a chunk.")
        var xIndex: Int32
        @Option(name: .customLong("zindex"), help: "Z index of a chunk.")
        var zIndex: Int32

        @Flag(name: .customLong("unknown"), help: "Only print unknown type.")
        var unknownOnly = false
        @Flag(name: .customLong("state"), help: "Print block state.")
        var printState = false

        func run() throws {
            guard let dimension = MCDimension(rawValue: dimension) else {
                fatalError("Error: wrong dimension")
            }
            guard let db = LvDB(dbPath: srcDir) else {
                fatalError("Error: can't open db \(srcDir)")
            }
            print("\n========== ========== ========== ========== ========== ==========")
            print("Extract block palettes in \(dimension)(\(xIndex), \(zIndex)) from \(srcDir)/db")

            for key in db.getChunkKeys(x: xIndex, z: zIndex, dimension: dimension) {
                let lvdbKey = LvDBKey.parse(data: key)
                guard case LvDBKeyType.subChunk(_, let t) = lvdbKey.type,
                      t == .subChunkPrefix
                else {
                    continue
                }
                if let data = db.get(key) {
                    printPalettes(in: data)
                } else {
                    print("Empty data with key: \(key.hexString)")
                }
            }

            print("\nDone!")
        }

        func printPalettes(in subChunkData: Data) {
//            let subChunkVersion = subChunkData[0]
            let storageLayerCount = Int(subChunkData[1])
            let subChunkYIndex = subChunkData[2].data.int8

            let decoder = BlockDecoder()
            var blockLayers = [MCBlockLayer]()
            do {
                if let layers = try decoder.decode(data: subChunkData, offset: 3, layerCount: storageLayerCount) {
                    blockLayers.append(contentsOf: layers)
                }
            } catch {
                print(error)
                return
            }

            for i in 0..<blockLayers.count {
                print("\n\n========== ========== ========== Y(\(subChunkYIndex)) Layer \(i)")
                blockLayers[i].palettes.forEach { palette in
                    if unknownOnly && palette.type != .unknown {
                        return
                    }
                    print(palette.name)
                    if printState {
                        print(palette.states)
                        print("---------- ----------")
                    }
                }
            }
        }
    }
}
