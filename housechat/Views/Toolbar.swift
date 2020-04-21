//
//  toolbar.swift
//  housechat
//
//  Created by Samuel Tsokwa on 2020-03-10.
//  Copyright © 2020 Samuel Tsokwa. All rights reserved.
//

import UIKit

class Toolbar: UIView {
    

    @IBOutlet var contentView: UIView!
    
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var addImage: UIButton!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
   

    func commonInit() 
    {
        let view = Bundle.main.loadNibNamed("toolbar", owner: self, options: nil)?.first as! UIView
            //addSubview(contentview)
        view.frame = self.bounds
        self.addSubview(view)
        view.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        
        
    }
    func createAccessoryView() -> UIView {
        let view = Bundle.main.loadNibNamed("toolbar", owner: self, options: nil)?.first as! UIView
        addSubview(contentView)
        return view
    }
    
   
//
}
