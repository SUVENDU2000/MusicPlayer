//
//  Utility.swift
//  MusicPlayer
//
//  Created by Suvendu Kumar on 07/04/24.
//

import Foundation
import UIKit

// Method for converting HEX color code to UIColor
func colorFromHex(hex : String) -> UIColor
{
    return colorWithHexString(hex, alpha: 1.0)
}


func colorWithHexString(_ stringToConvert:String, alpha:CGFloat) -> UIColor {

    var cString:String = stringToConvert.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }

    if ((cString.count) != 6) {
        return UIColor.gray
    }

    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)

    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: alpha
    )
}

extension UIView {
    // Method for applying Gradient to any view
    func applyGradientColor(accentColor : String) {
        let topColor = colorFromHex(hex: accentColor)
        let bottomColor = UIColor.black.cgColor

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = [topColor.cgColor, bottomColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)

        self.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}

// Heptic Feedback Generator Method
func hepticFeedBackGenerator() {
    let feedBack = UIImpactFeedbackGenerator(style: .light)
    feedBack.prepare()
    feedBack.impactOccurred()
}


// Tap Gesture Action Block
open class TapGestureActionBlock : UITapGestureRecognizer {
    var action : (() -> Void)? = nil
}

extension UIView {
    // Method for adding Tap Gesture to any view
    public func addTapGesture(action: @escaping () -> Void) {
        self.endEditing(true)
        let tapgesture = TapGestureActionBlock(target: self, action: #selector(self.handleTap(_:)))
        tapgesture.action = action
        tapgesture.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapgesture)
        self.isUserInteractionEnabled = true
    }
    
    @objc public func handleTap(_ sender: TapGestureActionBlock) {
        sender.action!()
    }
}
