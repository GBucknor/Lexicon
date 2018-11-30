//
//  WGViewController.swift
//  Lexicon
//
//  Created by Garel Bucknor on 2018-10-06.
//  Copyright © 2018 Garel Bucknor. All rights reserved.
//

import UIKit

class WGViewController: MasterViewController {
    
    @IBOutlet var catButtons: [UIButton]!
    var catArray: [NSDictionary] = []
    var catTitle: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = colorWithHexString(hexString: "#4281A4")
        for button in self.catButtons {
            button.layer.cornerRadius = 10
        }
    }
    
    @IBAction func getWordList(_ sender: UIButton) {
        let senderTitle = (sender.titleLabel?.text)!
        let appId = "52a4a509"
        let appKey = "0e4140c7beac18571782bb7039b8f2da"
        let language = Locale.current.languageCode?.lowercased()
        let filters = "domains=" + senderTitle
        let url = URL(string: "https://od-api.oxforddictionaries.com:443/api/v1/wordlist/\(language ?? "en")/\(filters)")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(appId, forHTTPHeaderField: "app_id")
        request.addValue(appKey, forHTTPHeaderField: "app_key")
        self.catTitle = senderTitle
        download(request)
    }
    
    private func download(_ request : URLRequest) {
        let sv = UIViewController.displaySpinner(onView: self.view)
        let session = URLSession.shared
        _ = session.dataTask(with: request, completionHandler: { data, response, error in
            if let _ = response,
                let data = data,
                let jsonData = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    as! [String : Any] {
                let resultArray = jsonData["results"] as! [NSDictionary]
                let group = DispatchGroup()
                group.enter()
                DispatchQueue.main.async {
                    self.catArray = resultArray
                    group.leave()
                }
                group.notify(queue: .main) {
                    UIViewController.removeSpinner(spinner: sv)
                    self.performSegue(withIdentifier: "WGGameSegue", sender: self)
                }
            } else {
                print(error ?? "Wordlist error: undefined")
                print(NSString.init(data: data!, encoding: String.Encoding.utf8.rawValue)!)
            }
        }).resume()
    }
    
    @IBAction func returnToMenuPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is WGGameViewController {
            let vc = segue.destination as! WGGameViewController
            vc.category = catTitle
            vc.wordArray = catArray
        }
    }
}
