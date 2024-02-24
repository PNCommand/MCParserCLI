import Foundation
import ArgumentParser
import CoreBedrock

fileprivate enum PaletteType: UInt8 {
    case persistence = 0
    case runtime = 1
}

fileprivate func parsePalette(_ byte: UInt8) -> (type: PaletteType, blocksPerWord: Int) {
    let paletteType = PaletteType(rawValue: byte & 0x1)!
    let bitsType = Int(byte >> 1)
    switch bitsType {
    case 1...6, 8, 16:
        return (paletteType, 32 / bitsType)
    default:
        fatalError("")
    }
}

extension MCParserCLI {
    struct ParseSubChunk: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "parse-subchunk",
            abstract: "parse data from subchunk",
            discussion: "Parse data from sunchunk.",
            shouldDisplay: true
        )

        @Option(name: .customLong("src"), help: "Path to a file stored subChunk data.")
        var srcFilePath: String

        func run() throws {
            let srcURL = URL(fileURLWithPath: srcFilePath)
            let subChunkData = try Data(contentsOf: srcURL)
            guard subChunkData.count >= 4 else {
                print("Broken file.")
                return
            }

            // 11, -14
            // x: 176 ~ 191
            // y:
            // z: -209 ~ -224

            let subChunkVersion = subChunkData[0]
            let storageLayerCount = subChunkData[1]
            let subChunkYIndex = subChunkData[2].data.int8
            print("========== ========== ========== ========== ========== ==========")
            print("chunk data       : \(subChunkData.count) bytes")
            print("chunk y index    : \(subChunkYIndex)")
            print("version          : \(subChunkVersion)")
            print("storage layer    : \(storageLayerCount)")
            print("")

            var offset = 3
            for layerIndex in 1...storageLayerCount {
                offset += try parseLayer(layerData: Data(subChunkData[3...]), layerIndex: layerIndex)
            }

            print(offset == subChunkData.count ? "All bytes parsed.\n" : "\(subChunkData.count-offset) remaining bytes not parsed.\n")
        }

        func parseLayer(layerData: Data, layerIndex: UInt8) throws -> Int {
            let (paletteType, blocksPerWord) = parsePalette(layerData[0])
            print("========== storage layer \(layerIndex) ==========")

            let totalWords = Int(ceil(16 * 16 * 16 / Double(blocksPerWord)))
            let blockDataCount = totalWords * 4

            var offset = 1
            var blocks = [UInt32]()
            var parsedBlockCount = 0
            for i in 0..<totalWords {
                let wordOffset = offset + i * 4
                let wordData = Data(layerData[wordOffset..<wordOffset+4])
                let blocksInWord = parseWord(word: wordData, blocksPerWord: blocksPerWord)
                blocks.append(contentsOf: blocksInWord)
                parsedBlockCount += blocksPerWord
                if parsedBlockCount >= 4096 {
                    break
                }
            }
            if blocks.count > 4096 {
                blocks.removeLast(blocks.count - 4096)
            }

            offset += blockDataCount
            let paletteCount = Data(layerData[offset..<offset+4]).int32!
            offset += 4

            var palettelist = [CompoundTag]()
            let reader = CBReader(CBBuffer(layerData[offset...]))
            for _ in 0..<paletteCount {
                let paletteTag = try reader.readAsTag() as! CompoundTag
                palettelist.append(paletteTag)
                reader.resetState()
            }
            offset += reader.baseStream.position

            print("blocks data      : \(blockDataCount) bytes")
            print("word count       : \(totalWords)")
            print("blocks per word  : \(blocksPerWord)")
            print("bits per block   : \(32 / blocksPerWord)")
            print("padding per word : \(32 % blocksPerWord)")
            print("---------- ----------")
            print("palette data     : \(reader.baseStream.position + 4) bytes")
            print("palette type     : \(paletteType)")
            print("palette count    : \(paletteCount)")
            let digits = String(paletteCount).count
            for (i, paletteTag) in palettelist.enumerated() {
                let index = String(format: "%\(digits)d", i)
                let nameTag = (paletteTag["name"]!) as! StringTag

                if let stateTag = paletteTag["states"] as? CompoundTag, !stateTag.isEmpty {
                    var states = [String]()
                    stateTag.makeIterator().forEach {tag in
                        let name = tag.name ?? "unknown"
                        let value: String
                        switch tag.tagType {
                        case .string:
                            value = tag.stringValue
                        case .int:
                            value = String(tag.intValue)
                        case .byte:
                            value = String(tag.byteValue)
                        default:
                            value = "Unsupported type"
                        }
                        states.append("\(name)=\(value)")
                    }
                    print("\(index): \(nameTag.value)\n    (\(states.joined(separator: ", ")))")
                } else {
                    print("\(index): \(nameTag.value)")
                }
            }
            print("---------- ----------")
            print("blocks count     : \(blocks.count)")
            for (i, block) in blocks.enumerated() {
                print(String(format: "%02d", block), terminator: " ")
                if i != 0 && i % 16 == 15 {
                    print("")
                }
            }
            print("")

            return offset
        }

        func parseWord(word: Data, blocksPerWord: Int, isBigEndian: Bool = false) -> [UInt32] {
            let bitsPerBlock = 32 / blocksPerWord
            var word = word.uint32!
            var mask = UInt32(0)
            for _ in 1...bitsPerBlock {
                mask <<= 1
                mask |= 0x1
            }

            var blocks = [UInt32]()
            var offset = 0
            while offset < 32 && blocks.count < blocksPerWord {
                let block = word & mask
                blocks.append(block)
                word >>= bitsPerBlock
                offset += bitsPerBlock
            }
            return blocks
        }
    }
}
