//
//  ViewController.swift
//  Lexicon
//
//  Created by Garel Bucknor on 2018-10-06.
//  Copyright © 2018 Garel Bucknor. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var scoreLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        displayScore()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        displayScore()
    }
    
    private func displayScore() {
        let score = UserDefaults.standard.value(forKey: "score") ?? nil
        if score == nil {
            UserDefaults.standard.set(0, forKey: "score")
        } else if score as! Int != 0 {
            scoreLabel.text = "High score: " + (String(score as! Int)) + "pts!"
        }
    }

    @IBAction func wordGuess(_ sender: Any) {
        performSegue(withIdentifier: "WGSegue", sender: self)
    }
    
}

