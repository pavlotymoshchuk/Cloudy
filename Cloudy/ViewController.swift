//
//  ViewController.swift
//  Cloudy
//
//  Created by Павло Тимощук on 25.11.2020.
//

import UIKit
import Photos

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imageView: UIImageView!
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBackground(view: self.view)
        addSelectImageButton(view: self.view)
        
        self.view.insertSubview(imageViewCreating(), at: 0)
        
    }
    
    func addBackground(view: UIView) {
        let layer0 = CAGradientLayer()
        layer0.colors = [
            UIColor(red: 0.883, green: 0.968, blue: 1, alpha: 1).cgColor,
            UIColor(red: 0.351, green: 0.816, blue: 0.992, alpha: 1).cgColor,
            UIColor(red: 0.197, green: 0.269, blue: 0.296, alpha: 1).cgColor
        ]
        layer0.locations = [0, 0.5, 1]
        layer0.startPoint = CGPoint(x: 0.25, y: 0.5)
        layer0.endPoint = CGPoint(x: 0.75, y: 0.5)
        layer0.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: 1, ty: 0))
        layer0.bounds = view.bounds.insetBy(dx: -1*view.bounds.size.width, dy: -1*view.bounds.size.height)
        layer0.position = view.center
        view.layer.addSublayer(layer0)
        
        let imageSize: CGFloat = 150
        let padding = (view.frame.height - 3*imageSize)/6
        
        let sunImage = UIImageView()
        sunImage.layer.opacity = 0.4
        sunImage.frame = CGRect(x: (view.frame.width-imageSize)/2,
                                y: padding,
                                width: imageSize,
                                height: imageSize)
        sunImage.image = UIImage(named: "sun-image")
        view.addSubview(sunImage)
        
        let cloudedSun = UIImageView()
        cloudedSun.layer.opacity = 0.4
        cloudedSun.frame = CGRect(x: (view.frame.width-imageSize)/2,
                                  y: (view.frame.height-imageSize)/2,
                                  width: imageSize,
                                  height: imageSize)
        cloudedSun.image = UIImage(named: "clouded-sun-image")
        view.addSubview(cloudedSun)
        
        let cloud = UIImageView()
        cloud.layer.opacity = 0.4
        cloud.frame = CGRect(x: (view.frame.width-imageSize)/2,
                             y: view.frame.height-imageSize-padding,
                             width: imageSize,
                             height: imageSize)
        cloud.image = UIImage(named: "cloud-image")
        view.addSubview(cloud)
    }
    
    func addSelectImageButton(view: UIView) {
        let selectImageButton = UIButton()
        let selectImageButtonSize = CGSize(width: 230, height: 60)
        selectImageButton.frame = CGRect(x: (view.frame.width-selectImageButtonSize.width)/2,
                                         y: view.frame.height/2 + 115,
                                         width: selectImageButtonSize.width,
                                         height: selectImageButtonSize.height)
        selectImageButton.addTarget(self, action: #selector(selectImageButtonAction), for: .touchUpInside)
        
        let shadows = UIView()
        shadows.isUserInteractionEnabled = false
        shadows.frame = CGRect(x: 0,
                               y: 0,
                               width: selectImageButtonSize.width,
                               height: selectImageButtonSize.height)
        shadows.clipsToBounds = false
        selectImageButton.addSubview(shadows)
        let shadowPath0 = UIBezierPath(roundedRect: shadows.bounds, cornerRadius: 20)
        let layer0 = CALayer()
        layer0.shadowPath = shadowPath0.cgPath
        layer0.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        layer0.shadowOpacity = 1
        layer0.shadowRadius = 3
        layer0.shadowOffset = CGSize(width: 4, height: 4)
        layer0.bounds = shadows.bounds
        layer0.position = shadows.center
        shadows.layer.addSublayer(layer0)
        let layer1 = CALayer()
        layer1.bounds = shadows.bounds
        layer1.position = shadows.center
        layer1.cornerRadius = 20
        layer1.borderWidth = 3
        layer1.borderColor = UIColor(red: 0.355, green: 0.717, blue: 0.979, alpha: 1).cgColor
        layer1.backgroundColor = UIColor(red: 0.302, green: 0.635, blue: 0.765, alpha: 1).cgColor
        shadows.layer.addSublayer(layer1)
        
        let selectImageButtonText = UILabel()
        selectImageButtonText.frame = CGRect(x: 0, y: 0, width: 230, height: 60)
        selectImageButtonText.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        selectImageButtonText.font = UIFont(name: "Roboto-Regular", size: 30)
        selectImageButtonText.text = "Select image"
        selectImageButton.addSubview(selectImageButtonText)
        selectImageButtonText.textAlignment = .center
        
        view.addSubview(selectImageButton)
    }
    
    @objc func selectImageButtonAction() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        
        guard let image = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        self.imageView.image = image
        self.view.bringSubviewToFront(self.imageView)
        let indicator = Indicator()
        indicator.showIndicator()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.addPhotoAndCalculateCloudPercentage(image: image)
            indicator.hideIndicator()
        }
    }
    
    func addPhotoAndCalculateCloudPercentage(image: UIImage) {
        let photoAnalyzer = PhotoAnalyzer(image)
        if let image = photoAnalyzer.createSkyImage() {
            let cloudPercentage = photoAnalyzer.getCloudPercentage(image: image)!
            if !cloudPercentage.isNaN {
                self.alert(alertTitle: "", alertMessage: "Cloud Percentage " + String(cloudPercentage) + "%", alertActionTitle: "OK")
            } else {
                self.alert(alertTitle: "", alertMessage: "Sky is undetected", alertActionTitle: "OK")
            }
        } else {
            print("ERROR")
        }
    }
    
    func imageViewCreating() -> UIImageView {
        imageView = .init()
        imageView.frame.size = CGSize(width: self.view.frame.width, height: self.view.frame.height-200)
        imageView.contentMode = .scaleAspectFit
        self.view.bringSubviewToFront(imageView)
        return imageView
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
