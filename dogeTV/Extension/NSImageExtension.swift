//
//  NSImageExtension.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/22.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa

extension NSImage {
    var pngData: Data? {
        guard let tiffRepresentation = tiffRepresentation,
            let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
        return bitmapImage.representation(using: .png, properties: [:])
    }
    
    @discardableResult
    func saveAsLogo(options: Data.WritingOptions = .atomic) -> Bool {
        do {
            let url = URL(fileURLWithPath: ENV.iconPath)
            try pngData?.write(to: url, options: options)
            return true
        } catch {
            print(error)
            return false
        }
    }
}
