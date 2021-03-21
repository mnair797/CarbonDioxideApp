//
//  CameraViewController.swift
//  CarbonDioxideApp
//
//  Created by Meenakshi Nair on 3/16/21.
//

import UIKit
import Vision
import VisionKit

class CameraViewController: UIViewController, VNDocumentCameraViewControllerDelegate {

   
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    var co2level=0;
    var tempReading=0.0;
    var humidityReading=0;
    var manufacturer="Unknown";
    let co2limit=250; // Number above is CO2 ppm
    let humidityLimit=5; // Ignore numbers below
    
    
    @IBAction func btnTakePicture(_ sender: UIButton) {
        let scannerViewController = VNDocumentCameraViewController()
        scannerViewController.delegate = self
        present(scannerViewController, animated: true)
    }
    
    
    var textRecognitionRequest = VNRecognizeTextRequest(completionHandler: nil)
    private let textRecognitionWorkQueue = DispatchQueue(label: "MyVisionScannerQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.isEditable = false
        setupVision()
    }

    
    
    func initReading() {
        co2level=0;
        tempReading=0;
        humidityReading=0;
        manufacturer="Unknown"
    }
    
    func createReading() -> String {
        let s=String(format:"CO2 %d Temp %.1f Humidity %d",co2level,tempReading,humidityReading)
        return s;
    }
    
    func processString(_ s:String) {
        let cs = CharacterSet.init(charactersIn: "01234567890 .").inverted
        let results = s.components(separatedBy: cs)
        print("Processing string:",s);
        for i in results {
            //print("Saw:",i," count",i.count);
            if(i.count<=1) {
                continue
            }
            if(i.contains(".")) { // Floating point - Temperature
                tempReading=Double(i) ?? 0.0
            } else {
                let j=Int(i) ?? 0
                if(j>=co2limit) {
                    co2level = j
                } else if(j>=humidityLimit){
                    humidityReading = j
                }
                
        };
    }
    }
    
    private func setupVision() {
        textRecognitionRequest = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            var detectedText = ""
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { return }
                //print("text \(topCandidate.string) has confidence \(topCandidate.confidence)");
                self.processString(topCandidate.string);
    
                detectedText += topCandidate.string;
                detectedText += "\n";
                
            
            }
            let s=self.createReading()
            print("Final reading:",s)
            let cdt = self.getCurrentDateTime()
            GoogleSheetsIntegration.recordSensor(source:"Photo",co2:self.co2level,timestamp:cdt, tempF:Float(self.tempReading), pressure:0, humidity:self.humidityReading,battery:0)
            
            DispatchQueue.main.async {
                self.textView.text = detectedText
                
                self.textView.flashScrollIndicators()

            }
        }

        textRecognitionRequest.recognitionLevel = .accurate
    }
    
    /*
     text 72.5°F 34 ® has confidence 1.0
     text 628 has confidence 1.0
     text O has confidence 0.5
     text ppm COz has confidence 0.5
     text * has confidence 0.5
     text aranet4 has confidence 0.5
     */
    
    private func processImage(_ image: UIImage) {
        imageView.image = image
        recognizeTextInImage(image)
    }
    
    private func recognizeTextInImage(_ image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        textView.text = ""
        textRecognitionWorkQueue.async {
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try requestHandler.perform([self.textRecognitionRequest])
            } catch {
                print(error)
            }
        }
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        guard scan.pageCount >= 1 else {
            controller.dismiss(animated: true)
            return
        }
        
        let originalImage = scan.imageOfPage(at: 0)
        let newImage = compressedImage(originalImage)
        controller.dismiss(animated: true)
        
        processImage(newImage)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        print(error)
        controller.dismiss(animated: true)
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true)
    }

    func compressedImage(_ originalImage: UIImage) -> UIImage {
        guard let imageData = originalImage.jpegData(compressionQuality: 1),
            let reloadedImage = UIImage(data: imageData) else {
                return originalImage
        }
        return reloadedImage
    }
    
    func getCurrentDateTime() -> String {
           let currentDateTime=Date()
           let formatter=DateFormatter()
           formatter.timeStyle = .medium
           formatter.dateStyle = .none
           let dateTimeStr=formatter.string(from: currentDateTime)
           return dateTimeStr
       }
}




