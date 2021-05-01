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

class PhotoAnalyzer {
    
    init(_ photo: UIImage){
        self.photo = photo
    }
    
    var photo = UIImage()
    var visionModel = FritzVisionSkySegmentationModelAccurate()
    let context = CIContext()
    
    func createSkyImage() -> UIImage? {
        let fritzImage = FritzVisionImage(image: self.photo)
        guard let result = try? visionModel.predict(fritzImage),
              let mask = result.buildSingleClassMask(
                forClass: FritzVisionSkyClass.sky
              )
        else { return nil }
        guard let skyImage = createMask(of: self.photo, fromMask: mask) else { return nil }
        return skyImage
    }
    
    func getCloudPercentage(image: UIImage) -> Float? {
        guard let cgImage = image.cgImage else { return nil }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue
        bitmapInfo |= CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        let width = Int(image.size.width)
        let height = Int(image.size.height)
        let bytesPerRow = width * 4
        let imageData = UnsafeMutablePointer<Pixel>.allocate(capacity: width * height)
        guard let imageContext = CGContext(
            data: imageData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else { return nil }
        imageContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        let pixels = UnsafeMutableBufferPointer<Pixel>(start: imageData, count: width * height)
        
        var cloudPercentage: Float = 0
        print(width,height)
        
        var pixelCount = 0
        var cloudPixelCount = 0
        
        let accuracyValue = 5
        
        for y in 0..<height {
            for x in 0..<width {
                let index = y * width + x
                let pixel = pixels[index]
                if pixel.alpha != 0 && x%accuracyValue==y%accuracyValue {
                    if calculateVSC(pixel: pixel) < 0 {
                        cloudPixelCount += 1
                    }
                    pixelCount += 1
                }
            }
        }
        cloudPercentage = Float(cloudPixelCount) / Float(pixelCount) * 100
        print(cloudPercentage,"%")
        
        return cloudPercentage
    }
    
    func calculateVSC(pixel: Pixel) -> Float {
        var vsc: Float = 0
        let r = Float(pixel.red)/255
        let g = Float(pixel.green)/255
        let b = Float(pixel.blue)/255
        let v = ([r,g,b].max()! + [r,g,b].min()!)/2
        let scyl: Float = ([r,g,b].max()! - [r,g,b].min()!) == 0 ? 0 : ([r,g,b].max()!-[r,g,b].min()!)/(1-abs(2*v-1))
//        let scone: Float = 0
        let br = (b-r)/(b+r)
        
//        vsc = -6.28*r + 0.454*g - 4.11*b - 1.81*scyl - 4.04*scone + 8.88*v + 1.53*br + 0.586
        vsc = -6.28*r + 0.454*g - 4.11*b - 1.8*scyl + 8.88*v + 1.53*br + 0.586
        return vsc
    }
    
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
    
    struct Pixel {
        public var value: UInt32
        
        public var red: UInt8 {
            get {
                return UInt8(value & 0xFF)
            } set {
                value = UInt32(newValue) | (value & 0xFFFFFF00)
            }
        }
        public var green: UInt8 {
            get {
                return UInt8((value >> 8) & 0xFF)
            } set {
                value = (UInt32(newValue) << 8) | (value & 0xFFFF00FF)
            }
        }
        public var blue: UInt8 {
            get {
                return UInt8((value >> 16) & 0xFF)
            } set {
                value = (UInt32(newValue) << 16) | (value & 0xFF00FFFF)
            }
        }
        public var alpha: UInt8 {
            get {
                return UInt8((value >> 24) & 0xFF)
            } set {
                value = (UInt32(newValue) << 24) | (value & 0x00FFFFFF)
            }
        }
    }
    
}

extension UIImage {
    func withAdjustment(bySaturationVal: CGFloat, byContrastVal: CGFloat) -> UIImage {
        guard let cgImage = self.cgImage else { return self }
        guard let filter = CIFilter(name: "CIColorControls") else { return self }
        filter.setValue(CIImage(cgImage: cgImage), forKey: kCIInputImageKey)
        filter.setValue(bySaturationVal, forKey: kCIInputSaturationKey)
        filter.setValue(byContrastVal, forKey: kCIInputContrastKey)
        guard let result = filter.value(forKey: kCIOutputImageKey) as? CIImage else { return self }
        guard let newCgImage = CIContext(options: nil).createCGImage(result, from: result.extent) else { return self }
        let image = UIImage(cgImage: newCgImage, scale: UIScreen.main.scale, orientation: imageOrientation)
        return UIImage(data: image.pngData()!)!
    }
}
