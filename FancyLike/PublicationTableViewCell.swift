//
//  PublicationTableViewCell.swift
//  FancyLike
//
//  Created by Ronaël Bajazet on 09/01/2016.
//  Copyright © 2016 Ro22e0. All rights reserved.
//

import UIKit

class PublicationTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    @IBOutlet weak var imagePubView: UIImageView!
    @IBOutlet weak var titlePubLabel: UILabel!
    @IBOutlet weak var descriptionPubLabel: UILabel!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var reloadButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        reloadButton.hidden = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}