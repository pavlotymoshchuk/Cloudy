//
//  AnalyzingPhoto.swift
//  Cloudy
//
//  Created by Павло Тимощук on 25.11.2020.
//

import Foundation
import AVFoundation
import UIKit
import Vision
import Fritz
import FritzVisionSkySegmentationModelAccurate

class AnalyzingPhoto {
    
    var photo = UIImage()
    
    init(_ photo: UIImage){
        self.photo = photo
        
    }
    
    func analyzingPhoto() -> Double? {
        var percentageOfCloud: Double? = 0
        createSkyImage(self.photo)
        return percentageOfCloud
    }
    
    var visionModel = FritzVisionSkySegmentationModelAccurate()
    let context = CIContext()
    
    func createMask(of image: UIImage, fromMask mask: UIImage, withBackground background: UIImage? = nil) -> UIImage? {
        guard let imageCG = image.cgImage, let maskCI = mask.ciImage else { return nil }
        let imageCI = CIImage(cgImage: imageCG)
        let background = background?.cgImage != nil ? CIImage(cgImage: background!.cgImage!) : CIImage.empty()
        guard let filter = CIFilter(name: "CIBlendWithAlphaMask") else { return nil }
        filter.setValue(imageCI, forKey: "inputImage")
        filter.setValue(maskCI, forKey: "inputMaskImage")
        filter.setValue(background, forKey: "inputBackgroundImage")
        guard let maskedImage = context.createCGImage(filter.outputImage!, from: maskCI.extent) else {
            return nil
        }
        return UIImage(cgImage: maskedImage)
    }
    
    func createSkyImage(_ image: UIImage) -> UIImage? {
        let fritzImage = FritzVisionImage(image: image)
        guard let result = try? visionModel.predict(fritzImage),
              let mask = result.buildSingleClassMask(
                forClass: FritzVisionSkyClass.sky
              )
        else { return nil }
        guard let skyImage = createMask(of: image, fromMask: mask) else { return nil }
        return skyImage
    }
    
    
}
