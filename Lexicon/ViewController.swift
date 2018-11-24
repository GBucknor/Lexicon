//
//  ViewController.swift
//  Lexicon
//
//  Created by Garel Bucknor on 2018-10-06.
//  Copyright © 2018 Garel Bucknor. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var mainTitleLabel: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //phoneBackground.image = phoneBackground.image?.tinted(color: UIColor.black)
        self.view.backgroundColor = colorWithHexString(hexString: "#4281A4")
        playBtn.layer.cornerRadius = 20
        mainTitleLabel.layer.cornerRadius = 15
        mainTitleLabel.layer.borderColor = UIColor.white.cgColor
        mainTitleLabel.layer.borderWidth = 3.0
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
    
    private func colorWithHexString(hexString: String, alpha:CGFloat? = 1.0) -> UIColor {
        
        // Convert hex string to an integer
        let hexint = Int(self.intFromHexString(hexStr: hexString))
        let red = CGFloat((hexint & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hexint & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hexint & 0xff) >> 0) / 255.0
        let alpha = alpha!
        
        // Create color object, specifying alpha as well
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }
    
    private func intFromHexString(hexStr: String) -> UInt32 {
        var hexInt: UInt32 = 0
        // Create scanner
        let scanner: Scanner = Scanner(string: hexStr)
        // Tell scanner to skip the # character
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
        // Scan hex value
        scanner.scanHexInt32(&hexInt)
        return hexInt
    }

    @IBAction func wordGuess(_ sender: Any) {
        performSegue(withIdentifier: "WGSegue", sender: self)
    }
}
