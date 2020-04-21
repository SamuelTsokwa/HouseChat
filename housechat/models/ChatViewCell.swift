//
//  ChatViewCell.swift
//  housechat
//
//  Created by Samuel Tsokwa on 2020-03-07.
//  Copyright © 2020 Samuel Tsokwa. All rights reserved.
//

import UIKit

class ChatViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var profileimage: UIImageView!
    @IBOutlet weak var contactname: UILabel!
    @IBOutlet weak var numberofunread: UIImageView!
    @IBOutlet weak var chattext: UILabel!
    @IBOutlet weak var chattime: UILabel!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        profileimage.clipsToBounds = true
        profileimage.translatesAutoresizingMaskIntoConstraints = false
        profileimage.layer.masksToBounds = true
    }
    
}
