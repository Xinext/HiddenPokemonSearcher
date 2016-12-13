//
//  CommonUtility.swift
//

import Foundation
import UIKit

/**
 - [ENG]MessageBox Utilty
 - [JPN]メセージボックスユーティリティー
 - Author: xinext HF
 - Copyright: xinext
 - Date: 2016/11/02
 - Version: 1.0.0
 */
class SimpleAlert {
    
    /**
     Alert message.
     - parameter pvc: ViewController Parent ViewController.
     - parameter msg: Display message.
     */
    static func AlertMsg( pcv:UIViewController, msg: String ){
        
        let titleText = NSLocalizedString("MSG_ALERT", comment: "")
        let alertController: UIAlertController = UIAlertController(title: titleText, message: msg, preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "OK", style: .default){
            (action) -> Void in
        }
        alertController.addAction(actionOK)
        pcv.present(alertController, animated: true, completion: nil)
    }
    
    /**
     Navigated to a setting page.
     - parameter pvc: ViewController Parent ViewController.
     - parameter msg: Display message.
     */
    static func NaviToSetPageMsg( pcv:UIViewController, msg: String ){
        
        let titleText = NSLocalizedString("MSG_ALERT", comment: "")
        let alertController: UIAlertController = UIAlertController(title: titleText, message: msg, preferredStyle: .alert)
        
        // Create action and added.
        // Cancel
        let cancelAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("MSG_CANCEL", comment: ""),
                                                       style: UIAlertActionStyle.cancel,
                                                       handler:{(action:UIAlertAction!) -> Void in })
        
        // To Setting page
        let defaultAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("MSG_TO_SETTING_PAGE", comment: ""),
                                                        style: UIAlertActionStyle.default,
                                                        handler:{
                                                            (action:UIAlertAction!) -> Void in
                                                            let url = NSURL(string:UIApplicationOpenSettingsURLString)
                                                            UIApplication.shared.openURL(url as! URL)
                                                        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(defaultAction)
        
        pcv.present(alertController, animated: true, completion: nil)
    }
}

/**
 - UIColorへ１６進数にてRGB指定できる機能を拡張
 */
extension UIColor {
    class func hexStr ( hexStr : NSString, alpha : CGFloat) -> UIColor {
        let alpha = alpha
        var hexStr = hexStr
        hexStr = hexStr.replacingOccurrences(of: "#", with: "") as NSString
        let scanner = Scanner(string: hexStr as String)
        var color: UInt32 = 0
        if scanner.scanHexInt32(&color) {
            let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((color & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(color & 0x0000FF) / 255.0
            return UIColor(red:r,green:g,blue:b,alpha:alpha)
        } else {
            print("invalid hex string")
            return UIColor.white;
        }
    }
}

/**
 - UIImageへ画像サイズ調整機能を拡張
 */
extension UIImage{
    func ResizeUIImage(width : CGFloat, height : CGFloat)-> UIImage!{
        
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
