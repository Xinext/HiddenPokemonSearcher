//
//  ViewController.swift
//  HiddenPokemonSearcher
//
//  Created by Hiroaki Fujisawa on 2016/10/22.
//  Copyright © 2016年 xinext. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var mainContentsView: UIView!
    @IBOutlet weak var mainContentsBottomLayoutConstraint: NSLayoutConstraint!
    
    var adMgr = AdModMgr()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        mainContentsView.layer.borderWidth = 5.0
        mainContentsView.layer.borderColor = UIColor.red.cgColor
        
        adMgr.initManager(pvc:self, cv:mainContentsView, lc: mainContentsBottomLayoutConstraint)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        adMgr.dispAdView(pos: AdModMgr.DISP_POSITION.BOTTOM)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

