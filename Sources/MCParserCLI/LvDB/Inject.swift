import ArgumentParser
import LvDBWrapper

extension MCParserCLI {
    struct Inject: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "inject",
            abstract: "inject data into leveldb",
            discussion: "Use this subcommand to inject data into dleveldb. The data source is file in specified directory, and the file name will be used as a key.",
            shouldDisplay: true
        )

        @Option(name: .customLong("dst"), help: "Path of a db directory.")
        var dbDirPath: String
        
        @Option(name: .customLong("data"), help: "Path of a directory that contains data source files.")
        var dataDirPath: String

        func run() throws {
            guard let db = LvDB(dbPath: dbDirPath) else {
                fatalError("Error: can't open db \(dbDirPath)")
            }
            print("\n========== ========== ========== ========== ========== ==========")
            print("Inject data from \(dataDirPath)")
            print("    to \(dbDirPath)")
            
            let fileManager = FileManager.default
            let files = try fileManager.contentsOfDirectory(atPath: dataDirPath).sorted()
            
            for fileName in files {
                guard let keyData = fileName.hexData else {
                    print("    Error ==> Inject: key \(fileName)")
                    continue
                }
                
                let data = try Data(contentsOf: URL(fileURLWithPath: dataDirPath + "/" + fileName))
                if db.put(keyData, data) {
                    print("    Inject: \(String(format: "%06d", data.count)) bytes of key \(fileName)")
                } else {
                    print("    Error ==> Inject: \(String(format: "%05d", data.count)) bytes of key \(fileName)")
                }
            }
        }
    }
}
