//
//  MasterViewController.swift
//  Lexicon
//
//  Created by Garel Bucknor on 2018-11-30.
//  Copyright © 2018 Garel Bucknor. All rights reserved.
//

import UIKit

class MasterViewController: UIViewController, HexColorHelper {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.style
    }
    
    var style: UIStatusBarStyle = .default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        style = .lightContent
        setNeedsStatusBarAppearanceUpdate()
        // Do any additional setup after loading the view.
    }
}
