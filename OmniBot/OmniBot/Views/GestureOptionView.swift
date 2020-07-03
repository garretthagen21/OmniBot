//
//  GestureOptionView.swift
//  OmniBot
//
//  Created by Garrett Hagen on 7/2/20.
//  Copyright © 2020 Garrett Hagen. All rights reserved.
//

import Foundation
import UIKit


class GestureOptionView : UIView
{
    let kCONTENT_XIB_NAME = "GestureOptionView"
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var optionsLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        contentView = Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)!.first as? UIView
        self.addSubview(contentView)
        self.contentView.frame = self.bounds
        self.contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
    }
        

}

/// Implementation of dashboard functionality
extension GestureOptionView{
    func setOptions(gestureOptions:[GestureViewController.HandGesture])
    {
        // Clear the options
        optionsLabel.text = ""
        
        // Draw all the options
        for option in gestureOptions{
            optionsLabel.text! += option.symbol+" "+option.description+" • "+option.action
            optionsLabel.text! += "\n"
        }
        
    }
    
    
}
