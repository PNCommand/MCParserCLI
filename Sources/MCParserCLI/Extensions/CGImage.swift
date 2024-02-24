import Foundation
import CoreGraphics
import ImageIO

extension CGImage {
    public func save(to path: String) {
        let cfdata: CFMutableData = CFDataCreateMutable(nil, 0)
        guard let destination = CGImageDestinationCreateWithData(cfdata, kUTTypePNG as CFString, 1, nil) else { return }

        CGImageDestinationAddImage(destination, self, nil)
        if CGImageDestinationFinalize(destination) {
            let data = cfdata as Data
            let url = URL(fileURLWithPath: path, isDirectory: false)
            try? data.write(to: url)
        }
    }
}
