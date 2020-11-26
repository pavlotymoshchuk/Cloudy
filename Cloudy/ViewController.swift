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
                UIImageWriteToSavedPhotosAlbum(imageToDownload, self, nil, nil)
                UIImageWriteToSavedPhotosAlbum(imageToDownload.withAdjustment(bySaturationVal: 0, byContrastVal: 1.35), self, nil, nil)
                self.alert(alertTitle: "Saved", alertMessage: "Image was saved", alertActionTitle: "OK")
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
