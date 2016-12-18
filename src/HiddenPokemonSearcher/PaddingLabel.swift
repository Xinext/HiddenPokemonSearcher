//
//  PaddingLabel.swift
//  HiddenPokemonSearcher
//
//  Created by Hiroaki Fujisawa on 2016/11/16.
//  Copyright © 2016年 xinext. All rights reserved.
//

import UIKit

class PaddingLabel: UILabel {

    // paddingの値
    let padding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    
    override func drawText(in rect: CGRect) {
        let newRect = UIEdgeInsetsInsetRect(rect, padding)
        super.drawText(in: newRect)
    }
    

    override public var intrinsicContentSize: CGSize {
        var intrinsicContentSize = super.intrinsicContentSize
        intrinsicContentSize.height += padding.top + padding.bottom
        intrinsicContentSize.width += padding.left + padding.right
        return intrinsicContentSize
    }
    
    func fontSizeToFit() {
        
        self.fontSizeToFit(minimumFontScale: 0.2, diminishRate: 0.5)
    }
    
    func fontSizeToFit(minimumFontScale: CGFloat, diminishRate: CGFloat) {
        let text = self.text!
        if (text.characters.count == 0) {
            return
        }
        var size = self.frame.size
        size.height = (size.height) - (padding.bottom + padding.top)
        size.width = (size.width) - (padding.left + padding.right)
        
        let fontName = self.font.fontName
        let fontSize = self.font.pointSize
        let minimumFontSize = fontSize * minimumFontScale
        let isOneLine = (self.numberOfLines == 1)
        
        var boundingSize = CGSize.zero
        var area = CGSize.zero
        var font = UIFont()
        var fs = fontSize
        var newAttributes = [String : Any]()
        self.attributedText?.enumerateAttributes(in: NSMakeRange(0, text.characters.count), options: .longestEffectiveRangeNotRequired, using: {
            (attributes: [String : Any], range: NSRange, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            newAttributes = attributes
        })
        if newAttributes.count == 0 {
            return
        }
        while (true) {
            font = UIFont(name: fontName, size: fs)!
            newAttributes[NSFontAttributeName] = font
            
            if isOneLine {
                boundingSize = CGSize(width: CGFloat(MAXFLOAT), height: size.height)
            }
            else {
                boundingSize = CGSize(width: size.width, height: CGFloat(MAXFLOAT))
            }
            area = NSString(string: text).boundingRect(with: boundingSize, options: .usesLineFragmentOrigin, attributes: newAttributes, context: nil).size
            
            if isOneLine {
                if area.width <= size.width {
                    break;
                }
            }
            else {
                if area.height <= size.height {
                    break;
                }
            }
            
            if fs == minimumFontSize {
                break;
            }
            
            fs -= diminishRate
            if fs < minimumFontSize {
                fs = minimumFontSize
            }
        }
        
        self.font = font
    }
}
