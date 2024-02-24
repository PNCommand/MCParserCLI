import Foundation
import ArgumentParser
import LvDBWrapper
import CoreBedrock
import CoreGraphics

extension MCParserCLI {
    struct Map: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "map",
            abstract: "generate top-down map for a chunk",
            discussion: "Generate top-down map for a chunk.",
            shouldDisplay: true
        )

        @Option(name: .customLong("src"), help: "Path of a db directory.")
        var srcDir: String

        @Option(name: .customShort("d"), help: "World dimension. overworld = 0, theNether = 1, theEnd = 2")
        var dimension: Int32 = 0
        @Option(name: .customShort("x"), help: "X index of a chunk.")
        var xIndex: Int32
        @Option(name: .customShort("z"), help: "Z index of a chunk.")
        var zIndex: Int32

        func run() throws {
//            guard let dimension = MCDimension(rawValue: dimension) else {
//                fatalError("Error: wrong dimension")
//            }
//            guard let db = LvDB(dbPath: srcDir) else {
//                fatalError("Error: can't open db \(srcDir)")
//            }

//            let chunk = MCChunk(lvDB: db, x: xIndex, z: zIndex, dimension: dimension)
//            let image = chunk.getTopDownView()
//            image.save(to: "./map.png")
        }
    }
}

//extension MCChunk {
//    func aaa() {
//        let view = [MCBlockType]()
//        var rgbaPixels = view.map { $0.color }
//        let image = rgbaPixels.withUnsafeMutableBytes { (ptr) -> CGImage in
//            let ctx = CGContext(
//                data: ptr.baseAddress,
//                width: MCSubChunk.length,
//                height: MCSubChunk.length,
//                bitsPerComponent: 8,
//                bytesPerRow: 4 * MCSubChunk.length,
//                space: CGColorSpace(name: CGColorSpace.sRGB)!,
//                bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue +
//                            CGImageAlphaInfo.premultipliedFirst.rawValue
//            )!
//            ctx.translateBy(x: 0, y: -1)
//            ctx.rotate(by: 90)
//            ctx.scaleBy(x: 0, y: -1)
//            return ctx.makeImage()!
//        }
//        print(image)
//    }
//
//    func bbb() {
//        let view = [MCBlockType]()
//        var rgbaPixels = view.map { $0.color }
//
//        let image = rgbaPixels.withUnsafeMutableBytes { (ptr) -> CGImage in
//            let ctx = CGContext(
//                data: ptr.baseAddress,
//                width: MCSubChunk.length,
//                height: MCSubChunk.length,
//                bitsPerComponent: 8,
//                bytesPerRow: 4 * MCSubChunk.length,
//                space: CGColorSpace(name: CGColorSpace.sRGB)!,
//                bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue +
//                            CGImageAlphaInfo.premultipliedFirst.rawValue
//            )!
//
//            // 画像を水平にフリップする変換行列を設定する
//            var transform = CGAffineTransform.identity
//            transform = transform.scaledBy(x: -1.0, y: 1.0)
//            transform = transform.translatedBy(x: -CGFloat(MCSubChunk.length), y: 0.0)
//            ctx.concatenate(transform)
//
//            // 画像を左に90度回転する変換行列を設定する
//            let rotateTransform = CGAffineTransform(rotationAngle: -CGFloat.pi/2.0)
//            let translateTransform = CGAffineTransform(translationX: 0.0, y: CGFloat(MCSubChunk.length))
//            let finalTransform = rotateTransform.concatenating(translateTransform)
//            ctx.concatenate(finalTransform)
//
//            return ctx.makeImage()!
//        }
//
//        let pixelData = UnsafeMutableRawPointer(mutating: rgbaPixels)
//        let context = CGContext(
//            data: pixelData,
//            width: MCSubChunk.length,
//            height: MCSubChunk.length,
//            bitsPerComponent: 8,
//            bytesPerRow: 4 * MCSubChunk.length,
//            space: CGColorSpace(name: CGColorSpace.sRGB)!,
//            bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue +
//                        CGImageAlphaInfo.premultipliedFirst.rawValue
//        )!
//
//        print(image)
//    }
//}
