import ArgumentParser
import LvDBWrapper
import os

extension MCParserCLI {
    struct ExtractKey: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "extract-key",
            abstract: "extract data using a specified key and save to a file",
            discussion: "Use this subcommand to extract data using a specified key.",
            shouldDisplay: true
        )
        
        @Option(name: .customLong("src"), help: "Path of a db directory.")
        var srcDir: String
        
        @Option(name: .customLong("dst"), help: "Path where output directory is.")
        var dstDir: String
        
        @Option(name: .customLong("key"), help: "A leveldb key, hex string.")
        var keyStr: String
        
        func run() throws {
            guard let keyData = keyStr.hexData else {
                fatalError("Error: wrong leveldb key")
            }
            guard let db = LvDB(dbPath: srcDir) else {
                fatalError("Error: can't open db \(srcDir)")
            }
            guard let value = db.get(keyData), value.count > 0 else {
                print("Error: data not found. key=\(keyStr)")
                os.exit(0)
            }
            print("\n========== ========== ========== ========== ========== ==========")
            print("Extract data from \(srcDir)")
            print("    to \(dstDir)")
            
            let url = URL(fileURLWithPath: dstDir + "/" + keyStr + ".dat")
            try value.write(to: url)
            
            // ~/Downloads/mcp extract-key --src w01 --dst . --key 0x64696770_00000000_02000000
            // 00000001_00000002
            // 00000001_0000001b
            
            // ~/Downloads/mcp extract-key --src w01 --dst . --key 0x6163746f72707265666978_00000001_00000002
        }
    }
}
