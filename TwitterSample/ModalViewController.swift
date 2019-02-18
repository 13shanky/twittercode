//
//  ModalViewController.swift
//  TwitterSample
//
//  Created by Karunakaran on 18/02/19.
//  Copyright © 2019 Karunakaran. All rights reserved.
//

import UIKit
import TwitterKit



class ModalViewController: UIViewController {
    
    var date_arr = [String]()
    var tweet_arr = [Int]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.date_arr = (UserDefaults.standard.object(forKey: "key_date_arr") as? [String])!
        self.tweet_arr = (UserDefaults.standard.object(forKey: "key_daily_tweet") as? [Int])!
        UserDefaults.standard.removeObject(forKey:"key_date_arr")
        UserDefaults.standard.removeObject(forKey:"key_daily_tweet")
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickonBarButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
