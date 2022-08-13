import Foundation
import ArgumentParser
import CoreBedrock

extension MCParserCLI {
    struct Delete: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "delete",
            abstract: "delete chunks from leveldb",
            discussion: "Use this subcommand to delete chunks within the specified range.",
            shouldDisplay: true
        )
        
        @Option(name: .customLong("src"), help: "Path of a world directory.")
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

            let world = try MCWorld(from: URL(fileURLWithPath: srcDir), storeKeys: false)
            world.removeChunks(dimension, xRange: xStart...xEnd, zRange: zStart...zEnd)

            print("done!\n")
        }
    }
}
