//
//  ViewController.swift
//  LightMorse
//
//  Created by Yeeter Brennan on 5/1/20.
//  Copyright © 2020 Peter Brennan. All rights reserved.
//

import UIKit
import AVKit

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var decodeButton: UIButton!
    var encodeButton: UIButton!
    var helpButton: UIButton!
    
    func toggleButtons(){
        decodeButton.isHidden =  !decodeButton.isHidden
        encodeButton.isHidden =  !encodeButton.isHidden
        helpButton.isHidden =  !helpButton.isHidden
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // I made the buttons on the screen by modifying the method show here
        // https://stackoverflow.com/questions/24030348/how-to-create-a-button-programmatically
        decodeButton = UIButton(frame: CGRect(x: 100, y: 100, width: 200, height: 100))
        decodeButton.backgroundColor = .green
        decodeButton.layer.cornerRadius = 6
        decodeButton.setTitle("Decode", for: .normal)
        decodeButton.addTarget(self, action: #selector(decodeButtonAction), for: .touchUpInside)

        self.view.addSubview(decodeButton)
        
        encodeButton = UIButton(frame: CGRect(x: 100, y: 210, width: 200, height: 100))
        encodeButton.backgroundColor = .blue
        encodeButton.layer.cornerRadius = 6
        encodeButton.setTitle("Encode", for: .normal)
        encodeButton.addTarget(self, action: #selector(encodeButtonAction), for: .touchUpInside)

        self.view.addSubview(encodeButton)
        
        helpButton = UIButton(frame: CGRect(x: 100, y: 320, width: 200, height: 100))
        helpButton.backgroundColor = .red
        helpButton.layer.cornerRadius = 6
        helpButton.setTitle("Help", for: .normal)
        helpButton.addTarget(self, action: #selector(helpButtonAction), for: .touchUpInside)

        self.view.addSubview(helpButton)
    }
    
    @objc func decodeButtonAction(sender: UIButton!) {
        print("Decode Button tapped")
        toggleButtons()
        decodeMorse()
    }
    
    @objc func encodeButtonAction(sender: UIButton!) {
        print("Encode Button tapped")
        toggleButtons()
        encodeMorse()
    }
    
    @objc func helpButtonAction(sender: UIButton!) {
        print("Help Button tapped")
        toggleButtons()
        showHelp()
    }
    
    func encodeMorse(){
        // add a text box
        let textInput = UITextField(frame: CGRect(x: 100, y: 310, width: 200, height: 100))
        //encodeButton.insertTextPlaceholder(with: <#T##CGSize#>)("Encode", for: .normal)
        let textView = UIView(frame: textInput.frame)
        textView.addSubview(textInput)
        
        // add an output window showing the converted morse
        // add a button to start encoding
        
    }
    
    func decodeMorse(){
        // To learn about making a live AVcapture seesion I watched the tutorial at:
        // https://www.youtube.com/watch?v=p6GA8ODlnX0
        
        // Set up for the camera
        let captureSession = AVCaptureSession()
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        captureSession.addInput(input)
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "video queue"))
        captureSession.addOutput(dataOutput)
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        print("Captured a frame: ", Date())
        
        let pixelMap = CMSampleBufferGetImageBuffer(sampleBuffer)!
        
    }
    
    func showHelp(){
        
    }

}

