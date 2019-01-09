//
//  ViewController.swift
//  TweetFeeling
//
//  Created by Bold Lion on 2.01.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON

class ViewController: UIViewController {

    @IBOutlet weak var feelLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    var tweetsArray = [TweetSentimentClassifierInput]()
    let classifier = TweetSentimentClassifier()
    
    let tweetCount = 100
    
    var keys: NSDictionary?
    
    var swifter: Swifter!

    override func viewDidLoad() {
        super.viewDidLoad()
        setSwifterApiKeys()
    }

    fileprivate func setSwifterApiKeys() {
        if let path = Bundle.main.path(forResource: "SecretApi", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)
        }
        if let dict = keys {
            guard let consumerKey = dict["ConsumerKey"] as? String else { fatalError("Consumer key was not set")}
            guard let consumerSecret = dict["ConsumerSecret"] as? String else { fatalError("Consumer secret was not set")}

            swifter = Swifter(consumerKey: consumerKey, consumerSecret: consumerSecret)
        }
    }
    
    @IBAction func predictTapped(_ sender: Any) {
        if let searchText = textField.text, searchText != "" {
            getTweets(with: searchText)
        }
    }
    
    func getTweets(with searchText: String) {
        swifter.searchTweet(using: searchText, lang: "en", count: tweetCount, tweetMode: .extended, success: { results, metadata in
            for i in 0..<self.tweetCount {
                if let tweet = results[i]["full_text"].string {
                    let tweetForClassification = TweetSentimentClassifierInput(text: tweet)
                    self.tweetsArray.append(tweetForClassification)
                }
            }
            self.makePredictions()
        }, failure: { error in
            print("There was an error with Twitter Api Request", error.localizedDescription)
        })
    }
    
    func makePredictions() {
        do {
            let predictions = try self.classifier.predictions(inputs: self.tweetsArray)
            var score = 0
            for prediction in predictions {
                let opinion = prediction.label
                if opinion == "Pos" {
                    score += 1
                }
                else if opinion == "Neg" {
                    score -= 1
                }
            }
            self.updateUI(score: score)
            self.textField.text = ""
            score = 0
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func updateUI(score: Int) {
        if score > 20 {
            feelLabel.text = "😍"
        } else if score > 10 {
            feelLabel.text = "🙃"
        } else if score > 0 {
            feelLabel.text = "🙂"
        } else if score == 0 {
            feelLabel.text = "😐"
        } else if score > -10 {
            feelLabel.text = "😠"
        } else if score > -20 {
            feelLabel.text = "😡"
        }
    }
    
}

