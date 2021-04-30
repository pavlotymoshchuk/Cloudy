//
//  ViewController.swift
//  Cloudy
//
//  Created by Павло Тимощук on 25.11.2020.
//

import UIKit
import Photos

class ViewController: UIViewController {
    
    var imageView: UIImageView!
    var skyImageView: UIImageView!
    var currentImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.insertSubview(imageViewCreating(), at: 0)
        self.view.insertSubview(skyImageViewCreating(), at: 0)
    }
    
    @IBAction func uploadImageButton(_ sender: Any) {
        ImagePickerManager().pickImage(self){ image in
            self.currentImage = image
            self.addPhotoToBackground()
        }
    }
    
    func addPhotoToBackground() {
        imageView.image = currentImage
        
        if let image = AnalyzingPhoto(currentImage).createSkyImage(currentImage) {
            skyImageView.image = image
        } else {
            print("ERROR")
        }
        
    }
    
    func imageViewCreating() -> UIImageView {
        imageView = .init()
        imageView.frame.size = CGSize(width: self.view.frame.width/2, height: self.view.frame.height-200)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    func skyImageViewCreating() -> UIImageView {
        skyImageView = .init()
        skyImageView.frame.size = CGSize(width: self.view.frame.width/2, height: self.view.frame.height-200)
        skyImageView.frame.origin.x = self.view.frame.width/2
        skyImageView.contentMode = .scaleAspectFit
        
        skyImageView.isUserInteractionEnabled = true
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressed))
        longPressRecognizer.minimumPressDuration = 0.5
        skyImageView.addGestureRecognizer(longPressRecognizer)
        return skyImageView
    }
    
    @objc func longPressed(recognizer:UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .began:
            UIView.animate(withDuration: 0.1,
                           animations: {
                            self.skyImageView.transform = CGAffineTransform.init(scaleX: 0.8, y: 0.8)
                           },
                           completion: nil)
        case .ended:
            UIView.animate(withDuration: 0.05) {
                self.skyImageView.transform = CGAffineTransform.identity
                let imageToDownload = UIImage(data: self.skyImageView.image!.pngData()!)!
//                UIImageWriteToSavedPhotosAlbum(imageToDownload, self, nil, nil)
//                let imageWithAdjustmentToDownload = imageToDownload.withAdjustment(bySaturationVal: 0, byContrastVal: 1.35)
//                UIImageWriteToSavedPhotosAlbum(imageWithAdjustmentToDownload, self, nil, nil)
                let cloudPercentage = self.getAverageColorOfImage(image: imageToDownload)!
                self.alert(alertTitle: "Saved", alertMessage: "Image was saved" + "\n" + "Cloud Percentage " + String(cloudPercentage) + "%", alertActionTitle: "OK")
            }
        default: break
        }
        
    }
    
    // MARK: - Make ALERT
    func alert(alertTitle: String, alertMessage: String, alertActionTitle: String) {
        AudioServicesPlaySystemSound(SystemSoundID(4095))
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: alertActionTitle, style: .cancel) { (action) in }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }

    
    func getAverageColorOfImage(image: UIImage) -> Float? /*-> (UInt8, UInt8, UInt8, Float)?*/ {
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

        for y in 0..<height {
            for x in 0..<width {
                let index = y * width + x
                let pixel = pixels[index]
                if pixel.alpha != 0 {
//                    print(pixel.red,pixel.green,pixel.blue)
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
        let scone:Float = 0
        let br = (b-r)/(b+r)
            
//        vsc = -6.28*r + 0.454*g - 4.11*b - 1.81*scyl - 4.04*scone + 8.88*v + 1.53*br + 0.586
        vsc = -6.28*r + 0.454*g - 4.11*b - 2.5*scyl + 8.88*v + 1.53*br + 0.586
        return vsc
    }
    
}

public struct Pixel {
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
