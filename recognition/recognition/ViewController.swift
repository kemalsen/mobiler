//
//  ViewController.swift
//  recognition
//
//  Created by Kemal Şen on 19.10.2019.
//  Copyright © 2019 Kemal Şen. All rights reserved.
//

import UIKit
import CoreML
import Vision

// MARK: - Methods
extension ViewController {
    
    func detectScene(image: CIImage) {
        guessText.text = "Görüntü işleniyor..."
        
        // Load the ML model through its generated class
        guard let model = try? VNCoreMLModel(for: MobileNetV2().model) else {
            fatalError("Yüklenemedi!")
        }
        
        // Create a Vision request with completion handler
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let topResult = results.first else {
                    fatalError("VNCoreMLRequest oluşturulamadı.")
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.guessText.text = "\(topResult.identifier). \n\n Doğruluk Oranı : %\(Int(topResult.confidence * 100))"
            }
        }
        
        // Run the Core ML GoogLeNetPlaces classifier on global dispatch queue
        let handler = VNImageRequestHandler(ciImage: image)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
        }
    }
}

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var guessText: UILabel!
    
    @IBOutlet weak var image: UIImageView!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imagePicker.delegate = self
        
        guard let ciImage = CIImage(image: UIImage(named: "lion.jpg")!) else {
            fatalError("couldn't convert UIImage to CIImage")
        }
        
        detectScene(image: ciImage)
    }

    @IBAction func openGallery(_ sender: Any) {
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            image.contentMode = .scaleAspectFit
            image.image = pickedImage
            
            guard let ciImage = CIImage(image: pickedImage) else {
                fatalError("couldn't convert UIImage to CIImage")
            }
            
            detectScene(image: ciImage)
        }
        
        dismiss(animated: true, completion: nil)
    }
}
