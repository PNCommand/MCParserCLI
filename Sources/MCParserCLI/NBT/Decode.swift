import Foundation
import ArgumentParser
import CoreBedrock

extension MCParserCLI {
    struct Decode: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "decode",
            abstract: "decode nbt data",
            discussion: "Use this subcommand to decode nbt data and save to a file.",
            shouldDisplay: true
        )
        
        @Option(name: .customLong("src"), help: "Path of a nbt data file.")
        var srcFilePath: String
        @Option(name: .customLong("dst"), help: "Path of the output.")
        var dstFilePath: String

        @Option(name: .customLong("skip"), help: "Skip leading bytes.")
        var skipped = 0
        @Flag(name: .customShort("o"), help: "Omit skipped bytes.")
        var omit = false
        
        func run() throws {
            print("\n========== ========== ========== ========== ========== ==========")
            print("Decode nbt file \(srcFilePath)")

            let srcURL = URL(fileURLWithPath: srcFilePath)
            let destURL = URL(fileURLWithPath: dstFilePath)

            let nbtData = try Data(contentsOf: srcURL)
            guard nbtData.count > skipped else {
                print("Skipped all \(nbtData.count) bytes.")
                return
            }
            let stream = CBBuffer(nbtData[skipped...])
            let reader = CBReader(stream)
            
            let rootTag = try reader.readAsTag() as! CompoundTag
            if skipped > 0 {
                let skipped = omit ? "\(nbtData[...skipped].count) bytes" : nbtData[...skipped].hexString
                let output = "Skipped data:\n\(skipped)\n\n" + rootTag.description
                try output.write(toFile: destURL.path, atomically: true, encoding: .utf8)
            } else {
                try rootTag.description.write(toFile: destURL.path, atomically: true, encoding: .utf8)
            }
            
            print("done!\n")
        }
    }
}
