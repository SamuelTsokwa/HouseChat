//
//  ContactsCell.swift
//  housechat
//
//  Created by Samuel Tsokwa on 2020-03-26.
//  Copyright © 2020 Samuel Tsokwa. All rights reserved.
//

import UIKit

class ContactsCell: UICollectionViewCell {

    @IBOutlet var deleteview: UIView!
    @IBOutlet var deletebutton: UIButton!
    
    @IBOutlet var contactimage: UIImageView!
    @IBOutlet var contactname: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//           super.setSelected(selected, animated: animated)
//
//           // Configure the view for the selected state
//       }

}
