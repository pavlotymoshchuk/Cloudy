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
        return skyImageView
    }

    
}
