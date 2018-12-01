//
//  WGGameViewController.swift
//  Lexicon
//
//  Created by Garel Bucknor on 2018-10-25.
//  Copyright © 2018 Garel Bucknor. All rights reserved.
//

import UIKit

class WGGameViewController: MasterViewController {
    
    // Array of words from the current category.
    var wordArray: [NSDictionary] = []
    var category: String = ""
    var word: String = ""
    var seconds: Int = 25
    var timer: Timer = Timer()
    var currentScore: Int = 0
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var mysteryDescription: UILabel!
    @IBOutlet var gameBtns: [UIButton]!
    @IBOutlet weak var guessArea: UITextField!
    @IBOutlet weak var categoryTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = colorWithHexString(hexString: "#4281A4")
        self.hideKeyboardWhenTappedAround()
        for button in gameBtns {
            button.layer.cornerRadius = 15
        }
        categoryTitle.text = category
        guessArea.spellCheckingType = UITextSpellCheckingType.no
        setUpGuessArea()
    }
    
    // Creates a timer for the current match.
    private func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(self.updateTimer)), userInfo: nil, repeats: true)
    }
    
    // Updates the number of seconds left for a guess.
    // Resets the time if the seconds get to 0.
    @objc private func updateTimer() {
        seconds -= 1
        timerLabel.text = "\(seconds)"
        if (seconds == 5) {
            timerLabel.textColor = UIColor.red
        }
        if (seconds <= 0) {
            timer.invalidate()
            setUpGuessArea()
        }
    }
    
    // Sets up the ui of the game.
    private func setUpGuessArea() {
        seconds = 15
        timerLabel.textColor = UIColor.white
        timerLabel.text = "\(seconds)"
        word = getRandomWord()
        print(word)
        setDescription()
        guessArea.text = ""
        runTimer()
    }
    
    // Picks a random word from the currently set category array.
    private func getRandomWord() -> String {
        var temp = wordArray[Int.random(in: 0 ..< wordArray.count)].value(forKey: "word") as! String
        while (temp.contains(",")) {
            temp = wordArray[Int.random(in: 0 ..< wordArray.count)].value(forKey: "word") as! String
        }
        return temp
    }
    
    // Shakes the textfield
    private func shakeAnimation() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 2
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: guessArea.center.x - 10, y: guessArea.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: guessArea.center.x + 10, y: guessArea.center.y))
        guessArea.layer.add(animation, forKey: "position")
        guessArea.text = ""
    }
    
    // Closes the current view
    @IBAction func quitPressed(_ sender: Any) {
        timer.invalidate()
        dismiss(animated: true, completion: nil)
    }
    
    // Checks guesses
    @IBAction func checkGuess(_ sender: Any) {
        if ((guessArea.text?.lowercased().elementsEqual(word))!) {
            timer.invalidate()
            setUpGuessArea()
            currentScore += 1
            let score = UserDefaults.standard.integer(forKey: "score")
            if currentScore > score {
                UserDefaults.standard.set(score + 1, forKey: "score")
            }
            showToast(message: "+1")
        } else {
            shakeAnimation()
        }
    }
    
    /* API REQUEST FUNCTIONS */
    
    // Creates an api request for the dictionary definition of the currently selected word.
    private func setDescription() {
        let appId = "52a4a509"
        let appKey = "0e4140c7beac18571782bb7039b8f2da"
        let language = Locale.current.languageCode?.lowercased()
        let word_id = word.replacingOccurrences(of: " ", with: "_").lowercased().stringByAddingPercentEncodingForRFC3986()
        let url = URL(string: "https://od-api.oxforddictionaries.com:443/api/v1/entries/\(language ?? "en")/\(word_id ?? "test")")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(appId, forHTTPHeaderField: "app_id")
        request.addValue(appKey, forHTTPHeaderField: "app_key")
        getDefReq(request)
    }
    
    // Parses a JSON response as an array of dictionary objects.
    private func getDefReq(_ request : URLRequest) {
        let session = URLSession.shared
        _ = session.dataTask(with: request, completionHandler: { data, response, error in
            if let _ = response,
                let data = data,
                let jsonData = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    as! [String:Any]{
                self.getDef(jsonData["results"] as! [NSDictionary])
            } else {
                print(error ?? "Word Entry error")
                print(NSString.init(data: data!, encoding: String.Encoding.utf8.rawValue) as Any)
            }
        }).resume()
    }
    
    // Searches for word definitions through dictionary objects.
    private func getDef(_ results : [NSDictionary]) {
        let l_entries = results[0].value(forKey: "lexicalEntries") as! [NSDictionary]
        let entries = l_entries[0].value(forKey: "entries") as! [NSDictionary]
        let senses = entries[0].value(forKey: "senses") as! [NSDictionary]
        if let definitions = senses[0].value(forKey: "definitions") as? [String] {
            DispatchQueue.main.async {
                self.mysteryDescription.text = definitions[0]
                self.mysteryDescription.lineBreakMode = .byWordWrapping
                self.mysteryDescription.numberOfLines = 4
            }
        } else {
            setUpGuessArea()
        }
    }
    
    /* END API REQUEST FUNCTIONS (thanks Oxford) */
}

// Converts certain special characters to rfc3986 for api calls.
extension String {
    func stringByAddingPercentEncodingForRFC3986() -> String? {
        let unreserved = "-._~/?"
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: unreserved)
        return addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
    }
}

// Displays toasts that slide upwards and then disappear.
extension UIViewController {
    func showToast(message: String) {
        let toastLabel = UILabel(frame: CGRect(
            x: self.view.frame.size.width/2 - 25,
            y: self.view.frame.size.height-100,
            width: 50,
            height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 2.0,
                       delay: 0.1,
                       options: .curveEaseOut,
                       animations: {
                        let top = CGAffineTransform(translationX: 0, y: -300)
                        toastLabel.alpha = 0.0
                        toastLabel.transform = top
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}

// Hides the keyboard when other areas of the screen are tapped.
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
