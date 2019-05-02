//
//  Helpers.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/3/15.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

func attempt<T>(maximumRetryCount: Int = 3, delayBeforeRetry: DispatchTimeInterval = .seconds(2), _ body: @escaping () -> Promise<T>) -> Promise<T> {
    var attempts = 0
    func attempt() -> Promise<T> {
        attempts += 1
        return body().recover { error -> Promise<T> in
            guard attempts < maximumRetryCount else { throw error }
            return after(delayBeforeRetry).then(on: nil, attempt)
        }
    }
    return attempt()
}


struct QRCode {
    private static func generateOriginQRImage(message: String) -> CIImage? {
        let messageData = message.data(using: .utf8)
        guard let qrCIFilter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }
        qrCIFilter.setValue(messageData, forKey: "inputMessage")
        qrCIFilter.setValue("H", forKey: "inputCorrectionLevel")
        return qrCIFilter.outputImage
    }

    static func createQRImage(message: String, size: NSSize = NSSize(width: 200, height: 200), backgroundColor: CIColor = .white, foregroundColor: CIColor = .black) -> NSImage? {
        guard let originImage = generateOriginQRImage(message: message) else {
            fatalError("failed to generate a QRImage")
        }
        guard let colorFilter = CIFilter(name: "CIFalseColor") else {
            fatalError("failed to generate a QRImage")
        }

        colorFilter.setValue(originImage, forKey: "inputImage")
        colorFilter.setValue(foregroundColor, forKey: "inputColor0")
        colorFilter.setValue(backgroundColor, forKey: "inputColor1")

        let scaleX = size.width / originImage.extent.width
        let scaleY = size.height / originImage.extent.height
        guard let colorImage = colorFilter.outputImage?.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY)) else {
            fatalError("failed to generate the colorImage")
        }

        let image = NSImage(cgImage: convertCIImageToCGImage(inputImage: colorImage)!, size: size)
        return image
    }

    private static func convertCIImageToCGImage(inputImage: CIImage) -> CGImage? {
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(inputImage, from: inputImage.extent) {
            return cgImage
        }
        return nil
    }
}
