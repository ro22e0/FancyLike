//
//  Publication.swift
//  TestAppTurbo
//
//  Created by Ronaël Bajazet on 09/01/2016.
//  Copyright © 2016 AppTurbo. All rights reserved.
//

import UIKit

// Publication model
class Publication {

    // MARK: - Properties
    
    private var _imageUrl: String
    private var _image: UIImage?
    private var _title: String
    private var _description: String
    private var _nbLike: UInt
    
    // MARK: - Getters/Setters
    
    var ImageUrl: String {
        get {
            return _imageUrl
        }
    }
    var Image: UIImage? {
        get {
            return _image
        }
        set (value) {
            _image = value!
        }
    }
    var Title: String {
        get {
            return _title
        }
    }
    var Description: String {
        get {
            return _description
        }
    }
    var Like: UInt {
        get {
            return _nbLike
        }
        set (value) {
            _nbLike = value
        }
    }

    // MARK: - Initialization

    init?(imageUrl: String, title: String, description: String) {
        
        self._imageUrl = imageUrl
        self._image = nil
        self._title = title
        self._description = description
        self._nbLike = 0

        if (_imageUrl.isEmpty || _title.isEmpty) {
            return nil
        }
    }
    
    init() {
        self._imageUrl = ""
        self._image = nil
        self._title = ""
        self._description = ""
        self._nbLike = 0
    }
    
    // MARK: - Methods
    
    func loadImage(sender: UITableViewController) {
        if let url = NSURL(string: self.ImageUrl) {
            let request = NSURLRequest(URL: url)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {
                (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                if error != nil {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    print("\((error! as NSError).localizedDescription)")
                } else {
                    // Create image from data
                    if let imageData = data as NSData? {
                        if (UIImage(data: imageData) != nil) {
                            self._image = UIImage(data: imageData)
                        } else {
                            self._image = nil
                            print("Failed to load the image")
                        }
                    }
                    // update some UI
                    dispatch_async(dispatch_get_main_queue()) {
                        sender.tableView.reloadData()
                    }
                    // Hide status bar loading icon
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                }
            }
        }
    }

}