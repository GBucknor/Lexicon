//
//  WGGameViewController.swift
//  Lexicon
//
//  Created by Garel Bucknor on 2018-10-25.
//  Copyright © 2018 Garel Bucknor. All rights reserved.
//

import UIKit

class WGGameViewController: UIViewController {
    
    // Array of words from the current category.
    var wordArray: [NSDictionary] = []
    var category: String = ""
    var word: String = ""
    
    @IBOutlet weak var mysteryDescription: UILabel!
    @IBOutlet weak var guessArea: UITextField!
    
    @IBOutlet weak var categoryTitle: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        categoryTitle.text = category
        word = getRandomWord()
        print(word)
        setDescription()
        guessArea.spellCheckingType = UITextSpellCheckingType.no
        guessArea.text = ""
    }
    
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
            word = getRandomWord()
            setDescription()
        }
    }
    
    private func getRandomWord() -> String {
        var temp = wordArray[Int.random(in: 0 ..< wordArray.count)].value(forKey: "word") as! String
        while (temp.contains(",")) {
            temp = wordArray[Int.random(in: 0 ..< wordArray.count)].value(forKey: "word") as! String
        }
        return temp
    }
    
    @IBAction func quitPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func checkGuess(_ sender: Any) {
        if ((guessArea.text?.lowercased().elementsEqual(word))!) {
            viewDidLoad()
        } else {
            let animation = CABasicAnimation(keyPath: "position")
            animation.duration = 0.05
            animation.repeatCount = 2
            animation.autoreverses = true
            animation.fromValue = NSValue(cgPoint: CGPoint(x: guessArea.center.x - 10, y: guessArea.center.y))
            animation.toValue = NSValue(cgPoint: CGPoint(x: guessArea.center.x + 10, y: guessArea.center.y))
            guessArea.layer.add(animation, forKey: "position")
            guessArea.text = ""
        }
    }
}

extension String {
    func stringByAddingPercentEncodingForRFC3986() -> String? {
        let unreserved = "-._~/?"
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: unreserved)
        return addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
    }
}
