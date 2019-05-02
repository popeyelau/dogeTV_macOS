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
    func save(isLogo: Bool = false, options: Data.WritingOptions = .atomic) -> URL? {
        var url: URL!
        if isLogo {
            url = URL(fileURLWithPath: ENV.iconPath)
        } else {
            let directory = NSTemporaryDirectory()
            let fileName = NSUUID().uuidString
            url = NSURL.fileURL(withPathComponents: [directory, fileName])!
        }
        do {
            try pngData?.write(to: url, options: options)
            return url
        } catch {
            print(error)
            return nil
        }
    }
}
