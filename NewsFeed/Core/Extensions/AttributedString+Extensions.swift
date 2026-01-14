//
//  AttributedString+Extensions.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import UIKit

extension NSMutableAttributedString {
    convenience init(string: String, font: UIFont, color: UIColor, alignment: NSTextAlignment? = nil) {
        self.init(string: string)
        
        let range = (string as NSString).range(of: string)
        addAttribute(.font, value: font, range: range)
        addAttribute(.foregroundColor, value: color, range: range)
        
        if let alignment {
            let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = alignment
            addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
        }
    }
}
