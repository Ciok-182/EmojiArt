//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by Jorge Encinas on 16/01/20.
//  Copyright © 2020 Jorge Encinas. All rights reserved.
//

import Foundation


struct EmojiArt {
    var url: URL
    var emojis = [EmojiInfo]()
    
    struct EmojiInfo {
        let x: Int
        let y: Int
        let text: String
        let size: Int
    }
    
    init(url: URL, emojis: [EmojiInfo]) {
        self.url = url
        self.emojis = emojis
    }
}
