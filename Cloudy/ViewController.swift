//
//  ViewController.swift
//  Cloudy
//
//  Created by Павло Тимощук on 25.11.2020.
//

import UIKit
import Photos
class ViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    var imagePickerController: UIImagePickerController!
    var imageView: UIImageView!
    var currentImage = UIImage()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self;
    }
    @IBAction func uploadImageButton(_ sender: UIButton) {
        openPhotoGallery()
        addPhotoToImageView()
    }
    
    func openPhotoGallery() {
        PHPhotoLibrary.requestAuthorization { (status) in
                switch status {
                case .authorized:
                    print("You Are Authrized To Access")
                    let fetchOptions = PHFetchOptions()
                    let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                    print("Found number of:  \(allPhotos.count) images")
                case .denied, .restricted:
                    print("Not allowed")
                case .notDetermined:
                    print("Not determined yet")
                case .limited:
                    print("You Are Authrized To Access")
                    let fetchOptions = PHFetchOptions()
                    let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                    print("Found number of:  \(allPhotos.count) images")
                @unknown default:
                    print("Not allowed")
                }
            }
        self.imagePickerController.sourceType =  UIImagePickerController.SourceType.photoLibrary
        self.present(self.imagePickerController, animated: true, completion: nil)
    }
    
    func addPhotoToImageView() {
        imageView = UIImageView()
        imageView.frame.size = self.view.frame.size
        imageView.contentMode = .scaleAspectFill
        imageView.image = currentImage
        self.view.addSubview(imageView)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        currentImage = image
        dismiss(animated: true, completion: nil)
        
    }
        
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    
}
