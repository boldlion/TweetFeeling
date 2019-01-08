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
    
    let swifter = Swifter(consumerKey: "cw1XBcTqJYLWh2UxG0pn5UDQJ", consumerSecret: "PH7aBoZBUE93wzLgICbtkjC6bOizp9lbEy2eAMRTPqzeAByqXJ")
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func predictTapped(_ sender: Any) {
        if let searchText = textField.text, searchText != "" {
            swifter.searchTweet(using: searchText, lang: "en", count: 100, tweetMode: .extended, success: { results, metadata in
                for i in 0..<100 {
                    if let tweet = results[i]["full_text"].string {
                        let tweetForClassification = TweetSentimentClassifierInput(text: tweet)
                        self.tweetsArray.append(tweetForClassification)
                    }
                }
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
                    print("Score is: ", score)
                    self.updateFeelLabel(score: score)
                    self.textField.text = ""
                    score = 0
                }
                catch {
                    print(error.localizedDescription)
                }
            }, failure: { error in
                print("There was an error with Twitter Api Request", error.localizedDescription)
            })
        }
    }
    
    func updateFeelLabel(score: Int) {
        if score > 20 {
            feelLabel.text = "🥰"
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

