//
//  TwitterLoginViewController.swift
//  TwitterSample
//
//  Created by Karunakaran on 10/02/19.
//  Copyright © 2019 Karunakaran. All rights reserved.
//

import UIKit
import TwitterKit


class TwitterLoginViewController: UIViewController{
    
    
    
    @IBOutlet weak var BtnBarGraph: UIButton!
    @IBOutlet weak var last_followers_count: UILabel!
    @IBOutlet weak var last_hashtag_count: UILabel!
    @IBOutlet weak var last_week_count: UILabel!
    @IBOutlet weak var imgView_profilePic: UIImageView!
    @IBOutlet weak var lbl_name: UILabel!
    @IBOutlet weak var label_usrName: UILabel!
    
    var tweets = [String]()
    var count : Int = 0
    var follower_count : Int = 0
    var date_array = [String]()
    var futureDate = Date()
    var daily_tweet_count = [Int]()
    var loggedinUsr = String()
    
    
    //    @IBOutlet weak var lbl_name: UILabel!
    //    @IBOutlet weak var label_usrName: UILabel!
    var loginButton : TWTRLogInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton = TWTRLogInButton (logInCompletion: {session,error in
            if let unwrappedsession = session {
                let client = TWTRAPIClient()
                
                client.loadUser(withID: (unwrappedsession.userID), completion: {(user1,error) in
                    
                    if let user = user1
                    {
                        self.lbl_name.text=user.name
                        self.label_usrName.text=unwrappedsession.userName
                        
                        
                        let url = URL(string: user.profileImageURL)
                        if let urlImg = url
                        {
                            let data = try?Data(contentsOf: urlImg)
                            if let imgData = data
                            {
                                self.imgView_profilePic.image=UIImage(data: imgData)
                                
                            }
                        }
                        self.loggedinUsr = unwrappedsession.userName
                        self.loadTwit(username: unwrappedsession.userName)
                        
                        
                    }
                    else{
                        print("error: \(String(describing: error?.localizedDescription))");
                    }
                    
                })
            }
            else{
                print("error: \(error?.localizedDescription ?? "error")");
            }
            
        })
        loginButton.center = self.view.center
        self.view.addSubview(loginButton)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    func loadTwit(username: String!)
    {
        let client = TWTRAPIClient.withCurrentUser()
        
        let currentDate = NSDate() as Date
        let lastWeekDate = NSCalendar.current.date(byAdding: .weekOfYear, value: -1, to: NSDate() as Date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let convertedDate:String=dateFormatter.string(from:currentDate)
        let aWeekBefore:String = dateFormatter.string(from: lastWeekDate!)
        let usernamenew  = username.replacingOccurrences(of: "\"", with: "")
        
        if(self.BtnBarGraph.isEnabled==false)
        {
            let url = encodedUrl(from:"https://api.twitter.com/1.1/search/tweets.json?q=from:\(usernamenew) since:\(aWeekBefore) until:\(convertedDate)")
            
            
            
            
            let req = URLRequest(url: url!)
            client.sendTwitterRequest(req) { (res, data, error) in
                if(error == nil)
                {
                    do {
                        
                        let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String: AnyObject]
                        //statuses
                        if let names = json["statuses"] as? NSArray {
                            for dic in names
                                
                            {
                                if let dic1 = dic as? NSDictionary
                                {
                                    self.tweets.append(dic1["text"] as! String)
                                    
                                    let entities = (dic1["entities"] as (AnyObject))
                                    let hashtags = (entities["hashtags"] as! NSArray)
                                    
                                    self.count += hashtags.count
                                    
                                    
                                    
                                    
                                    
                                    print("dic1 is \(dic1)")
                                }
                            }
                            
                            print("count \(self.count)")
                            self.last_week_count.text = "\(self.tweets.count)"
                            self.last_hashtag_count.text = "\(self.count)"
                            
                        }
                    } catch let error as NSError {
                        print("Failed to load: \(error.localizedDescription)")
                    }
                }
                
                
            }
            let url_follower = encodedUrl(from:"https://api.twitter.com/1.1/followers/list.json?  screen_name=\(usernamenew)&amp;skip_status=true&amp;include_user_entities=false")
            
            
            let req_follower = URLRequest(url: url_follower!)
            client.sendTwitterRequest(req_follower) { (res, data, error) in
                if(error == nil)
                {
                    do {
                        
                        let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String: AnyObject]
                        //statuses
                        if let users = json["users"] as? NSArray {
                            for dic in users
                                
                            {
                                if let dic1 = dic as? NSDictionary
                                {
                                    
                                    let created = dic1["created_at"] as! String
                                    
                                    var outputDateFormat = "hh:mm a dd:MM:yy"
                                    
                                    let created_at_date = self.parseTwitterDate(twitterDate: created, outputDateFormat: outputDateFormat)
                                    
                                    dateFormatter.dateFormat = "hh:mm a dd:MM:yy"
                                    // let convertedDate:String=dateFormatter.string(from:currentDate)
                                    
                                    let aWeekBefore:String = dateFormatter.string(from:lastWeekDate!)
                                    
                                    let aWeekBeforedate = dateFormatter.date(from:aWeekBefore)
                                    let final_date = dateFormatter.date(from: created_at_date!)
                                    
                                    print("lastWeekdate is \(aWeekBefore)")
                                    if(final_date?.compare(aWeekBeforedate!)) == ComparisonResult.orderedAscending {
                                        //Do Something...
                                        self.follower_count += 0
                                    }
                                    else if(final_date?.compare(aWeekBeforedate!)) == ComparisonResult.orderedDescending
                                    {
                                        self.follower_count += 1
                                    }
                                }
                            }
                            self.last_followers_count.text = "\(self.follower_count)"
                            self.BtnBarGraph.isHidden = false
                            self.BtnBarGraph.isEnabled = true
                            self.loadTwit(username: self.loggedinUsr)
                            
                        }
                        
                    } catch let error as NSError {
                        print("Failed to load: \(error.localizedDescription)")
                    }
                }
                
                
            }
            
        }
        else
        {
            self.daily_tweet_count = []
            self.dateComponents(aWeekBefore: lastWeekDate!)
            var dateComponent = DateComponents()
            let minusdays = -1
            dateComponent.day = minusdays
            let previousDate = Calendar.current.date(byAdding: dateComponent, to: lastWeekDate!)!
            dateFormatter.dateFormat = "yyyy-MM-dd"
            var previousDateStr:String=dateFormatter.string(from:previousDate)
            for i in 0 ..< self.date_array.count{
                let  fetch_date: String = self.date_array[i]
                
                
                if(i>0)
                {
                    previousDateStr = self.date_array[i-1]
                    
                }
                
                let url1 = encodedUrl(from:"https://api.twitter.com/1.1/search/tweets.json?q=from:\(usernamenew) since:\(previousDateStr) until:\(fetch_date)")
                
                let req1 = URLRequest(url:url1!)
                
                client.sendTwitterRequest(req1) { (res, data, error) in
                    if(error == nil)
                    {
                        do {
                            
                            let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String: AnyObject]
                            //statuses
                            if let names = json["statuses"] as? NSArray {
                                self.daily_tweet_count.append(names.count)
                                
                                
                            }
                            
                        } catch let error as NSError {
                            print("Failed to load: \(error.localizedDescription)")
                        }
                    }
                    
                    
                }
                
                
                
            }
            
            
            
        }
        
        
        
    }
    
    
    func tweetView(tweetView: TWTRTweetView, didSelectTweet tweet: TWTRTweet) {
        print("Selected tweet with ID: \(tweet.tweetID)")
    }
    
    
    
    
    func parseTwitterDate(twitterDate:String, outputDateFormat:String)->String?{
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        
        var indate = formatter.date(from: twitterDate)
        var outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "hh:mm a dd:MM:yy"
        var outputDate:String?
        if let d = indate {
            outputDate = outputFormatter.string(from: d)
        }
        return outputDate;
    }
    func dateComponents(aWeekBefore:Date) -> Array<String> {
        self.date_array = []
        
        var dateComponent = DateComponents()
        let dateFormatter = DateFormatter()
        
        for i in 0...6
        {
            let daystoadd = i
            dateComponent.day = daystoadd
            
            
            futureDate = Calendar.current.date(byAdding: dateComponent, to: aWeekBefore)!
            
            
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let convertedDate:String=dateFormatter.string(from:futureDate)
            
            self.date_array.append(convertedDate)
            
        }
        
        print("self.date_array is\(self.date_array)")
        //self.loggedinUsr
        
        
        
        return self.date_array
    }
    
    func encodedUrl(from string: String) -> URL? {
        // Remove preexisting encoding
        guard let decodedString = string.removingPercentEncoding,
            // Reencode, to revert decoding while encoding missed characters
            let percentEncodedString = decodedString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                // Coding failed
                return nil
        }
        // Create URL from encoded string, or nil if failed
        return URL(string: percentEncodedString)
    }
    
    @IBAction func clickonBargraph(_ sender: Any)
    {
        
        print("self.daily_tweet_count is \(self.daily_tweet_count)")
        UserDefaults.standard.set(self.date_array, forKey: "key_date_arr")
        UserDefaults.standard.set(self.daily_tweet_count, forKey: "key_daily_tweet")
        
        let modalViewController = ModalViewController()
        
        modalViewController.modalPresentationStyle = .overCurrentContext
        
        present(modalViewController, animated:true, completion: nil)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
