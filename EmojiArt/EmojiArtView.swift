//
//  EmojiArtView.swift
//  EmojiArt
//
//  Created by Jorge Encinas on 16/12/19.
//  Copyright © 2019 Jorge Encinas. All rights reserved.
//

import UIKit

class EmojiArtView: UIView {
    
    var backgroundImage : UIImage?{
        didSet{
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        backgroundImage?.draw(in: bounds)
    }
    
    
}
