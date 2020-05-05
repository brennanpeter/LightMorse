//
//  ViewController.swift
//  LightMorse
//
//  Created by Yeeter Brennan on 5/1/20.
//  Copyright © 2020 Peter Brennan. All rights reserved.
//

import UIKit
import AVKit

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, UITextFieldDelegate {
    
    var decodeButton: UIButton!
    var encodeButton: UIButton!
    var helpButton: UIButton!
    var backButton: UIButton!
    
    
    var textInput: UITextField!
    var morseOutput: UITextView!
    var encodeMessage: String!
    
    
    func toggleButtons(){
        decodeButton.isHidden =  !decodeButton.isHidden
        encodeButton.isHidden =  !encodeButton.isHidden
        helpButton.isHidden =  !helpButton.isHidden
    }
    
    // dictionary of characters and their corresponding codes
    var morseCharsDict: [String: String] = [
        "A":".-",
        "B":"-...",
        "C":"-.-.",
        "D":"-..",
        "E":".",
        "F":"..-.",
        "G":"--.",
        "H":"....",
        "I":"..",
        "J":".---",
        "K":"-.-",
        "L":".-..",
        "M":"--",
        "N":"-.",
        "O":"---",
        "P":".--.",
        "Q":"--.-",
        "R":".-.",
        "S":"...",
        "T":"-",
        "U":"..-",
        "V":"...-",
        "W":".--",
        "X":"-..-",
        "Y":"-.--",
        "Z":"--..",
        "1":".----",
        "2":"..---",
        "3":"...--",
        "4":"....-",
        "5":".....",
        "6":"-....",
        "7":"--...",
        "8":"---..",
        "9":"----.",
        "0":"-----"
    ]

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
        // add a text box programatically
        //https://stackoverflow.com/questions/24710041/adding-uitextfield-on-uiview-programmatically-swift/32602425
        textInput = UITextField(frame: CGRect(x: 20, y: 100, width: 200, height: 40))
        textInput.placeholder = "Enter your message here"
        textInput.font = UIFont.systemFont(ofSize: 15)
        textInput.borderStyle = UITextField.BorderStyle.roundedRect
        textInput.layer.borderColor = UIColor.black.cgColor
        textInput.autocorrectionType = UITextAutocorrectionType.no
        textInput.keyboardType = UIKeyboardType.default
        textInput.returnKeyType = UIReturnKeyType.done
        textInput.clearButtonMode = UITextField.ViewMode.whileEditing
        textInput.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        textInput.delegate = self
        textInput.addTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingChanged)
        self.view.addSubview(textInput)
        
        
        morseOutput = UITextView(frame: CGRect(x: 20, y: 150, width: 300, height: 200))
        morseOutput.center = self.view.center
        morseOutput.font = UIFont.systemFont(ofSize: 15)
        morseOutput.textAlignment = NSTextAlignment.left
        morseOutput.layer.borderColor = UIColor.lightGray.cgColor
        morseOutput.layer.borderWidth = 1
        morseOutput.layer.cornerRadius = 6
        morseOutput.text = convertToMorseChars(chars: textInput.text!)
        self.view.addSubview(morseOutput)
        
        // add an output window showing the converted morse
        // add a button to start encoding
        
    }
    
    @objc func textFieldDidChange (sender: UITextField) {
        encodeMessage = convertToMorseChars(chars: sender.text!)
        morseOutput.text = encodeMessage
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
        
        // Add a button to close the cpature window and bring us back to the main menu
        backButton = UIButton(frame: CGRect(x: 10, y: 10, width: 50, height: 50))
        backButton.backgroundColor = .red
        backButton.layer.cornerRadius = 6
        backButton.setTitle("Back", for: .normal)
        backButton.addTarget(self, action: #selector(helpButtonAction), for: .touchUpInside)

        self.view.addSubview(backButton)
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        print("Captured a frame: ", Date())
        
        let pixelMap = CMSampleBufferGetImageBuffer(sampleBuffer)!
        
    }
    
    func showHelp(){
        
    }
    
    func convertToMorseChars(chars: String) -> String {
        // first we should convert the input to uppercase so that we can use the dictionary
        var localChars = chars
        localChars = chars.uppercased()
        
        // initialize a return variable
        var result = ""
        
        for c in localChars {
            if c == " " {
                result = result + "       "
            }
            else {
                result = result + (morseCharsDict[ String(c) ] ?? "") + " "
            }
            
        }
        
        return result
    }
    
}

