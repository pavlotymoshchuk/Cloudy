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
        else {
            return nil
        }
        guard let skyImage = createMask(of: self.photo, fromMask: mask) else { return nil }
        return skyImage
    }
    
    func getCloudPercentage(image: UIImage) -> Float? {
        let averageColor = image.averageColor
        print("Average image colors: ", averageColor)
        print("Normal colors:   0.6   0.75    0.85")
        let rCorrection = Float((averageColor?.rgba.red)!).normalizeValue(by: 0.6)
        let gCorrection = Float((averageColor?.rgba.green)!).normalizeValue(by: 0.75)
        let bCorrection = Float((averageColor?.rgba.blue)!).normalizeValue(by: 0.85)
        print("Color correction: ", rCorrection, gCorrection, bCorrection)
        
        if let imageData = getDataFrom(image: image) {
            let accuracyValue = 5
            var pixelCount = 0
            var cloudPixelCount = 0
            for y in 0 ..< imageData.height {
                for x in 0 ..< imageData.width {
                    let index = y * imageData.width + x
                    let pixel = imageData.pixels[index]
                    if pixel.alpha != 0 && x%accuracyValue == y%accuracyValue {
                        if calculateVSC(pixel: pixel, colorCorrection: (rCorrection, gCorrection, bCorrection)) < 0 {
                            cloudPixelCount += 1
                        }
                        pixelCount += 1
                    }
                }
            }
            return Float(cloudPixelCount) / Float(pixelCount) * 100
        } else {
            return nil
        }
    }
    
    func getDataFrom(image: UIImage) -> (width: Int, height: Int, pixels: UnsafeMutableBufferPointer<Pixel>)? {
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
        return (width, height, UnsafeMutableBufferPointer<Pixel>(start: imageData, count: width * height))
    }
    
    func calculateVSC(pixel: Pixel, colorCorrection: (r: Float, g: Float, b: Float)) -> Float {
        //        (0.822368 0.842105 0.888158) cloudPecentage: (First itteration) 61%  (Second itteration) 72%  (80-90%)
        //        (0.521472 0.662577 0.846626) cloudPecentage: (First itteration) 68%  (Second itteration) 11%    (40-50%)
        //        (0.247934 0.586777 0.867769) cloudPecentage: (First itteration) 12%  (Second itteration) 0.06%    (0-5%)
        //        (0.60 0.75 0.85)             cloudPecentage: (First itteration) 45%  (Second itteration) 45%    (40-50%)
        //        (0.623762 0.69802 0.80198)   cloudPecentage: (First itteration) 55%  (Second itteration) 54%    (70-80%)
        
        var vsc: Float = 0
        let r = Float(pixel.red)/255
        let g = Float(pixel.green)/255
        let b = Float(pixel.blue)/255
        let v = ([r,g,b].max()! + [r,g,b].min()!)/2
        let scyl: Float = ([r,g,b].max()! - [r,g,b].min()!) == 0 ? 0 : ([r,g,b].max()!-[r,g,b].min()!)/(1-abs(2*v-1))
        //        let scone: Float = 0
        let br = (b-r)/(b+r)
        
        //        vsc = -6.28*r + 0.454*g - 4.11*b - 1.81*scyl - 4.04*scone + 8.88*v + 1.53*br + 0.586
        vsc = -6.28*r*colorCorrection.r + 0.454*g*colorCorrection.g - 4.11*b*colorCorrection.b - 1.8*scyl + 8.88*v + 1.53*br + 0.586
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
    
    var averageColor: UIColor? {
        var bitmap = [UInt8](repeating: 0, count: 4)
        if #available(iOS 9.0, *) {
            let context = CIContext()
            let inputImage: CIImage = ciImage ?? CoreImage.CIImage(cgImage: cgImage!)
            let extent = inputImage.extent
            let inputExtent = CIVector(x: extent.origin.x, y: extent.origin.y, z: extent.size.width, w: extent.size.height)
            let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: inputExtent])!
            let outputImage = filter.outputImage!
            let outputExtent = outputImage.extent
            assert(outputExtent.size.width == 1 && outputExtent.size.height == 1)
            
            context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())
        } else {
            let context = CGContext(data: &bitmap, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)!
            let inputImage = cgImage ?? CIContext().createCGImage(ciImage!, from: ciImage!.extent)
            
            context.draw(inputImage!, in: CGRect(x: 0, y: 0, width: 1, height: 1))
        }
        
        let alpha: CGFloat = CGFloat(bitmap[3]) / 255.0
        let multiplier: CGFloat = alpha*255.0
        
        return UIColor(red: CGFloat(bitmap[0])/multiplier, green: CGFloat(bitmap[1])/multiplier, blue: CGFloat(bitmap[2])/multiplier, alpha: alpha)
        
    }
}

extension UIColor {
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return (red, green, blue, alpha)
    }
}

extension Float {
    
    func normalizeValue(by: Float) -> Float {
        if self > by { return 1+(self-by)/by }
        else if self < by { return 1-(by-self)/by }
        else { return 1 }
    }
}
