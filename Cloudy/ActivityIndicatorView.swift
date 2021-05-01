//
//  ActivityIndicatorView.swift
//  word-search-ios
//

import Foundation
import UIKit

class Indicator {

    var blurImg = UIImageView()
    var indicator = UIActivityIndicatorView()

    init() {
        blurImg.frame = UIScreen.main.bounds
        blurImg.backgroundColor = UIColor.black
        blurImg.isUserInteractionEnabled = true
        blurImg.alpha = 0.5
        indicator.style = .whiteLarge
        indicator.center = blurImg.center
        indicator.startAnimating()
    }

    func showIndicator() {
        DispatchQueue.main.async(execute: {
            UIApplication.shared.keyWindow?.addSubview(self.blurImg)
            UIApplication.shared.keyWindow?.addSubview(self.indicator)
        })
    }
    
    func hideIndicator() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.blurImg.removeFromSuperview()
            self.indicator.removeFromSuperview()
        })
    }
}
