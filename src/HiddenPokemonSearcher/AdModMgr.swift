//
//  AdModMgr.swift
//

import UIKit
import GoogleMobileAds

/**
 - [ENG]The UIViewController for AdMod.
 - [JPN]AdMod管理用 UIViewController
 - Author: Hiroaki Fujisawa
 - Copyright: xinext
 - Date: 2016/10/19
 - Version: 1.0.0
 */
class AdModMgr: UIViewController, GADBannerViewDelegate {

    // *** internal ***
    let adBannerView = GADBannerView(adSize:kGADAdSizeSmartBannerPortrait)
    
    // *** private ***
    private var _contentsView: UIView!
    private var _layoutConstraint: NSLayoutConstraint? = nil
    
    enum DISP_POSITION: Int {
        case TOP = 0
        case BOTTOM
    }
    
    /**
     Initialization of processing
     - parameter pvc: ViewController Parent ViewController.
     - parameter cv: UIView The view of contents related to AD.
     - parameter cv: UIView The layout constraint of contents view.
     - returns: nothing
     */
    func initManager(pvc: UIViewController, cv: UIView, lc: NSLayoutConstraint) {
        
        pvc.addChildViewController(self)
        
        _contentsView = cv
        _layoutConstraint = lc
        
        adBannerView.isHidden = true
        adBannerView.adUnitID = ADMOD_UNITID
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        
        let gadRequest:GADRequest = GADRequest()
        adBannerView.load(gadRequest)
        
        self.parent?.view.addSubview(adBannerView)
    }

    /**
     Display AdView.
     - parameter pos: DISP_POSITION
     - returns: nothing
     */
    func dispAdView(pos: DISP_POSITION) {
        
        var rectBanner: CGRect
        
        let banner_x: CGFloat = 0.0
        let banner_width: CGFloat = adBannerView.frame.size.width
        let banner_height: CGFloat = adBannerView.frame.size.height
        let banner_y: CGFloat
        switch pos {
        case DISP_POSITION.TOP:
            banner_y = _contentsView!.frame.origin.y
        default:    // bottom
            banner_y = self.view.frame.size.height - adBannerView.frame.size.height
        }
        rectBanner = CGRect(x: banner_x, y: banner_y, width: banner_width, height: banner_height)
        
        adBannerView.frame = rectBanner
        
        if ( adBannerView.isHidden == true ) {
            _layoutConstraint?.constant += adBannerView.frame.size.height
        }
        else {
            // do nothign.
        }
        
        adBannerView.isHidden = false
    }

    /**
     Hide AdView.
     - parameter pos: DISP_POSITION
     - returns: nothing
     */
    func hideAdView() {
        
        if ( adBannerView.isHidden == false ) {
            _layoutConstraint?.constant -= adBannerView.frame.size.height
        }
        else {
            // do nothign.
        }
        
        adBannerView.isHidden = true
    }
}
