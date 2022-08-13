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
        
        func run() throws {
            print("\n========== ========== ========== ========== ========== ==========")
            print("Decode nbt file \(srcFilePath)")
            
            let srcURL = URL(fileURLWithPath: srcFilePath)
            let destURL = URL(fileURLWithPath: dstFilePath)
            
            let nbtData = try! Data(contentsOf: srcURL)
            let stream = CBBuffer(nbtData)
            let reader = CBReader(stream)
            
            let rootTag = try reader.readAsTag() as! CompoundTag
            if rootTag.tagType != .compound {
                fatalError("Faild to pase NBT Tags...")
            }
            
            try rootTag.description.write(toFile: destURL.path, atomically: true, encoding: .utf8)
            
            print("done!\n")
        }
    }
}
