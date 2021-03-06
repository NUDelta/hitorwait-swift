//
//  tabBarViewController.swift
//  hitorwait
//
//  Created by Yongsung on 3/28/17.
//  Copyright © 2017 Delta. All rights reserved.
//

import UIKit

var CURRENT_USER:User?
var SEARCH_REGIONS = [LostItemRegion]()

class tabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        Pretracker.sharedManager.locationManager?.startUpdatingLocation()
        
        let nc = NotificationCenter.default
        
        nc.addObserver(forName: Notification.Name(rawValue:"PushReceived"), object: nil, queue: OperationQueue.main, using: setVC)
        
        nc.addObserver(forName: Notification.Name(rawValue:"ESMSent"), object: nil, queue: OperationQueue.main, using: setVC)
    }
    
    func setVC(notification: Notification) -> Void {
        if notification.name.rawValue=="ESMSent" {
            self.selectedIndex = 2
        }
        
        if notification.name.rawValue=="PushReceived" {
            self.selectedIndex = 0
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
