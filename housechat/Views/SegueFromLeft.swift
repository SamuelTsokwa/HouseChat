//
//  File.swift
//  housechat
//
//  Created by Samuel Tsokwa on 2020-03-13.
//  Copyright © 2020 Samuel Tsokwa. All rights reserved.
//

import Foundation
import UIKit

class SegueFromLeft: UIStoryboardSegue
{
    override func perform()
    {
        let src = self.source
        let dst = self.destination

        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.transform = CGAffineTransform(translationX: -src.view.frame.size.width, y: 0)

        UIView.animate(withDuration: 0.25,
            delay: 0.0,
            options: UIView.AnimationOptions.curveEaseInOut,
            animations: {
                dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
            },
            completion: { finished in
                src.present(dst, animated: false, completion: nil)
            }
        )
    }
}
