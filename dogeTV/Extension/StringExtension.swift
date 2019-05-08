//
//  StringExtension.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/15.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa

extension String {
    var base64String: String {
        guard let data = self.data(using: String.Encoding.utf8) else {
            return ""
        }
        
        return data.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
    }
    
    func widthOfString(usingFont font: NSFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    
    func extractURLs() -> [URL] {
        var urls : [URL] = []
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            detector.enumerateMatches(in: self, options: [], range: NSMakeRange(0, self.count), using: { (result, _, _) in
                if let match = result, let url = match.url {
                    urls.append(url)
                }
            })
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return urls
    }

    var encodedURI: String {
        var characterSet = CharacterSet.alphanumerics
        characterSet.insert(charactersIn: "-_.!~*'()")
        return self.addingPercentEncoding(withAllowedCharacters: characterSet) ?? self
    }
    
}


extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
