//
//  ViewController.swift
//  Cloudy
//
//  Created by Павло Тимощук on 25.11.2020.
//

import UIKit
import Photos
class ViewController: UIViewController {
    
    var backgroundImageView: UIImageView!
    var currentImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.insertSubview(imageForBackground(), at: 0)
    }
    
    @IBAction func uploadImageButton(_ sender: Any) {
        ImagePickerManager().pickImage(self){ image in
            self.currentImage = image
            self.addPhotoToBackground()
        }
    }

    
    func addPhotoToBackground() {
        backgroundImageView.image = currentImage
    }
    
    func imageForBackground() -> UIImageView {
        backgroundImageView = .init(frame: self.view.frame)
        backgroundImageView.image = currentImage
        backgroundImageView.contentMode = .scaleAspectFit
        return backgroundImageView
    }

    
}
