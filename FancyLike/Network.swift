//
//  Network.swift
//  TestAppTurbo
//
//  Created by Ronaël Bajazet on 09/01/2016.
//  Copyright © 2016 AppTurbo. All rights reserved.
//

import Foundation

class Network {
    
    // Mark: - Class method
    class func isReachable() -> (status: Bool, error: String) {
        let url = NSURL(string: "https://google.com/")
        let request = NSMutableURLRequest(URL: url!)
        request.timeoutInterval = 10.0
        
        var response: NSURLResponse?
        do {
            _ = try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response) as NSData?
        } catch {
            print("Connection failed: \((error as NSError).localizedDescription)")
            return (false, "\((error as NSError).localizedDescription)")
        }
        return (true, "")
    }
}