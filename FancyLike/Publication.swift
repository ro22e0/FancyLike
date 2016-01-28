//
//  Publication.swift
//  FancyLike
//
//  Created by Ronaël Bajazet on 09/01/2016.
//  Copyright © 2016 Ro22e0. All rights reserved.
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
    private var _task: NSURLSessionTask!

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
            _image = value
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
    var Task: NSURLSessionTask! {
        get {
            return _task
        }
        set (value) {
            _task = value
        }
    }

    // MARK: - Initialization

    init?(imageUrl: String, title: String, description: String) {
        
        self._imageUrl = imageUrl
        self._image = nil
        self._title = title
        self._description = description
        self._nbLike = 0
        self._task = nil

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
}