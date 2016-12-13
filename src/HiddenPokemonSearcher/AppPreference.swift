//
//  AppPreference.swift
//  For HiddenPokemonSearcher
//

import Foundation

/**
 - [ENG]The preferences manager for this application.
 - [JPN]アプリケーション設定マネージャー
 - Author: xinext
 - Copyright: xinext
 - Date: 2016/10/28
 - Version: 1.0.0
 */
class AppPreference {

    /**
     Save all parameters.
     - parameter value: The hidden radius.
     */
    static func SaveAllParameters() {
        UserDefaults.standard.synchronize()
    }
    
    /* parameter keys */
    enum Keys: String {
        case HiddenRadius = "HiddenRadius"
    }

    /* ***** The Hidden Radius. ***** */
    /* かくれたポケモンが表示される半径 */
    static let DEF_HiddenRadius: Int32 = 200    // 200m
    
    /**
     Set parameter of hidden radius.
     - parameter value: The hidden radius.
     */
    static func SetHiddenRadius(value: Int32) {
        UserDefaults.standard.set(value, forKey: Keys.HiddenRadius.rawValue)
    }
    
    /**
     Get parameter of hidden radius.
     - returns: The hidden radius.
     */
    static func GetHiddenRadius() -> Int32 {
        var radius: Int32?  = UserDefaults.standard.object(forKey: Keys.HiddenRadius.rawValue) as! Int32?
        
        if ( radius != nil ) {
            // Data is OK
        }
        else {
            AppPreference.SetHiddenRadius(value: DEF_HiddenRadius)
            radius = DEF_HiddenRadius
        }
        
        return radius!
    }
}
