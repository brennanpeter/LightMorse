//
//  ViewController.swift
//  LightMorse
//
//  Created by Yeeter Brennan on 5/1/20.
//  Copyright © 2020 Peter Brennan. All rights reserved.
//

import UIKit
import AVKit
import CoreImage

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, UITextFieldDelegate {
    
    // main menu UI components
    var decodeButton: UIButton!
    var encodeButton: UIButton!
    var helpButton: UIButton!
    var backButton: UIButton!
    var sendButton: UIButton!
    
    // encode page
    var textInput: UITextField!
    var morseOutput: UITextView!
    var encodeMessage: String!
    var prettyEncodedMessage: String!
    
    var captureSession: AVCaptureSession!
    var decodeOutput: UITextView!
    
    let duration = UInt32(250000)    // length of a 1 morse unit in milliseconds
    
    var totalPreviousLuma = 0
    
    var timer: Timer!
    
    var onTimerDuration: Int!
    var offTimerDuration: Int!
    
    var currentLetter: String!
    var currentMorse: String!
    var currentMessage: String!
    
    var decodeDetectsFlash: Bool!
    
    var encodeView: UIView!
    var decodeView: UIView!
    
    // hiding and showing the main menu
    func toggleButtons(){
        decodeButton.isHidden =  !decodeButton.isHidden
        encodeButton.isHidden =  !encodeButton.isHidden
    }
    
    func toggleEncodeView() {
        encodeView.isHidden = !encodeView.isHidden
    }
    
    func toggleDecodeView() {
        decodeView.isHidden = !decodeView.isHidden
    }
    
    // dictionary of characters and their corresponding codes
    var charsToMorseDict: [String: String] = [
        "A":".-|",
        "B":"-...|",
        "C":"-.-.|",
        "D":"-..|",
        "E":".|",
        "F":"..-.|",
        "G":"--.|",
        "H":"....|",
        "I":"..|",
        "J":".---|",
        "K":"-.-|",
        "L":".-..|",
        "M":"--|",
        "N":"-.|",
        "O":"---|",
        "P":".--.|",
        "Q":"--.-|",
        "R":".-.|",
        "S":"...|",
        "T":"-|",
        "U":"..-|",
        "V":"...-|",
        "W":".--|",
        "X":"-..-|",
        "Y":"-.--|",
        "Z":"--..|",
        "1":".----|",
        "2":"..---|",
        "3":"...--|",
        "4":"....-|",
        "5":".....|",
        "6":"-....|",
        "7":"--...|",
        "8":"---..|",
        "9":"----.|",
        "0":"-----|"
    ]
    // dictionary of morse and their corresponding characters
       var morseToCharsDict: [String: String] = [
        ".-":"A",
        "-...":"B",
        "-.-.":"C",
        "-..":"D",
        ".":"E",
        "..-.":"F",
        "--.":"G",
        "....":"H",
        "..":"I",
        ".---":"J",
        "-.-":"K",
        ".-..":"L",
        "--":"M",
        "-.":"N",
        "---":"O",
        ".--.":"P",
        "--.-":"Q",
        ".-.":"R",
        "...":"S",
        "-":"T",
        "..-":"U",
        "...-":"V",
        ".--":"W",
        "-..-":"X",
        "-.--":"Y",
        "--..":"Z",
        ".----":"1",
        "..---":"2",
        "...--":"3",
        "....-":"4",
        ".....":"5",
        "-....":"6",
        "--...":"7",
        "---..":"8",
        "----.":"9",
        "-----":"0"
       ]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Initializing some variables for the decode process
        onTimerDuration = 0
        offTimerDuration = 0
        currentMorse = ""
        currentLetter = ""
        
        // Display the main menu options
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
    
    func encodeMorse() {
        
        encodeView = UIView(frame: CGRect( x: 0, y: 0, width: UIScreen.main.bounds.width , height: UIScreen.main.bounds.height) )
        
        let inputLabel = UILabel(frame: CGRect(x: 60, y: 30, width: 100, height: 50))
        inputLabel.text = "Input"
        encodeView.addSubview(inputLabel)
        
        // add a text box programatically
        //https://stackoverflow.com/questions/24710041/adding-uitextfield-on-uiview-programmatically-swift/32602425
        textInput = UITextField(frame: CGRect(x: 50, y: 80, width: 300, height: 50))
        textInput.placeholder = "Enter your message here"
        textInput.font = UIFont.systemFont(ofSize: 18)
        textInput.borderStyle = UITextField.BorderStyle.roundedRect
        textInput.layer.borderColor = UIColor.black.cgColor
        textInput.autocorrectionType = UITextAutocorrectionType.no
        textInput.keyboardType = UIKeyboardType.default
        textInput.returnKeyType = UIReturnKeyType.done
        textInput.clearButtonMode = UITextField.ViewMode.whileEditing
        textInput.contentVerticalAlignment = UIControl.ContentVerticalAlignment.top
        textInput.delegate = self
        textInput.addTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingChanged)
        encodeView.addSubview(textInput)
        
        let outputLabel = UILabel(frame: CGRect(x: 50, y: 150, width: 100, height: 50))
        outputLabel.text = "Output"
        encodeView.addSubview(outputLabel)
        
        morseOutput = UITextView(frame: CGRect(x: 50, y: 200, width: 300, height: 200))
        morseOutput.font = UIFont.systemFont(ofSize: 18)
        morseOutput.textAlignment = NSTextAlignment.left
        morseOutput.layer.borderColor = UIColor.lightGray.cgColor
        morseOutput.layer.borderWidth = 1
        morseOutput.layer.cornerRadius = 6
        morseOutput.text = ""
        morseOutput.isEditable = false
        encodeView.addSubview(morseOutput)
        
        // add an output window showing the converted morse
        // add a button to start encoding
        let sendButton = UIButton(frame: CGRect(x: 150, y: 420, width: 200, height: 100))
        sendButton.backgroundColor = .purple
        sendButton.layer.cornerRadius = 6
        sendButton.setTitle("Send", for: .normal)
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        encodeView.addSubview(sendButton)
        
        let encodeBackButton = UIButton(frame: CGRect(x: 80, y: 440, width: 60, height: 60))
        encodeBackButton.backgroundColor = .red
        encodeBackButton.layer.cornerRadius = 6
        encodeBackButton.setTitle("Back", for: .normal)
        encodeBackButton.addTarget(self, action: #selector(encodeBack), for: .touchUpInside)
        encodeView.addSubview(encodeBackButton)
        
        self.view.addSubview(encodeView)
        
    }
    
    @objc func encodeBack (sender: UIButton) {
        // hide the content on the encode page
        toggleEncodeView()
        toggleButtons()
    }
    
    
    
    @objc func textFieldDidChange (sender: UITextField) {
        encodeMessage = convertToMorseChars(chars: sender.text!)
        
        morseOutput.text = encodeMessage.replacingOccurrences(of: "|", with: "")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func sleepForUnit(numUnits: Int){
        for _ in (0...numUnits){
            usleep(duration)      // Declare a unit
            //print("sleep")
        }
    }
    
    @objc func sendMessage (sender: UIButton) {
        print("Sending")
        
        for c in encodeMessage {
            switch c {
            case ".":
                print(".")
                // turn on the torch
                toggleTorch(on: true)
                // wait 1 unit
                sleepForUnit(numUnits: 1)
                // turn off the torch
                toggleTorch(on: false)
                // wait 1 unit
                sleepForUnit(numUnits: 1)
            case "-":
                print("-")
                // turn on the torch
                toggleTorch(on: true)
                // wait 3 units
                sleepForUnit(numUnits: 3)
                // turn off the torch
                toggleTorch(on: false)
                // wait 1 unit
                sleepForUnit(numUnits: 1)
            case "|":
                print("|")
                // wait for 2 extra units
                sleepForUnit(numUnits: 2)
                // to get the 3 unit wait time at the end of a letter
            case " ":
                print("Space")
                // wait for 4 extra units
                sleepForUnit(numUnits: 4)
                // we will have just finished a letter so we only need to wait for an additional 4 units
            default:
                print("Unexpected Character in Morse String")
                
            }
            
        }
    }
    
    func decodeMorse(){
        
        decodeView = UIView(frame: CGRect( x: 0, y: 0, width: UIScreen.main.bounds.width , height: UIScreen.main.bounds.height) )
        
        self.decodeDetectsFlash = false
        self.currentMessage = ""
        timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .common)
        
        // To learn about making a live AVcapture seesion I watched the tutorial at:
        // https://www.youtube.com/watch?v=p6GA8ODlnX0
        
        // Set up for the camera     Lots of boilerplate :(
        captureSession = AVCaptureSession()
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        captureSession.addInput(input)
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        decodeView.layer.addSublayer(previewLayer)
        previewLayer.frame = decodeView.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "video queue"))
        captureSession.addOutput(dataOutput)
        
        
        // Add a button to close the cpature window and bring us back to the main menu
        backButton = UIButton(frame: CGRect(x: 10, y: 10, width: 50, height: 50))
        backButton.backgroundColor = .red
        backButton.layer.cornerRadius = 6
        backButton.setTitle("Back", for: .normal)
        backButton.addTarget(self, action: #selector(decodeBack), for: .touchUpInside)
        
        decodeOutput = UITextView(frame: CGRect(x: 100, y: 10, width: 200, height: 60))
        decodeOutput.font = UIFont.systemFont(ofSize: 18)
        decodeOutput.textAlignment = NSTextAlignment.left
        decodeOutput.layer.borderColor = UIColor.lightGray.cgColor
        decodeOutput.layer.borderWidth = 1
        decodeOutput.layer.cornerRadius = 6
        decodeOutput.text = ""
        decodeOutput.isEditable = false
        decodeView.addSubview(decodeOutput)

        decodeView.addSubview(backButton)
        
        self.view.addSubview(decodeView)
        
    }
    
    @objc func decodeBack (sender: UIButton) {
        // hide the content on the encode page
        captureSession.stopRunning()
        currentMessage = ""     // delete the current message content
        toggleDecodeView()
        toggleButtons()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        //print("Captured a frame: ", Date())
        
        /*
         I learned how to get the raw pixel information out of the swift 3 solution on
         https://stackoverflow.com/questions/34569750/get-pixel-value-from-cvpixelbufferref-in-swift
         but i had to scrap this becuase I wanted to calculate the histograms for the images using apples own functions
         I found documentation here
         
         on how to do this
         https://developer.apple.com/documentation/accelerate/1545752-vimagehistogramcalculation_argbf
            and
         http://flexmonkey.blogspot.com/2016/04/vimage-histogram-functions-part-ii.html
         
         but then i found *better* documentation here:
         https://developer.apple.com/documentation/accelerate/applying_vimage_operations_to_video_sample_buffers
         
         so I used this guide to calculate the luminance of the image
         */

        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        // claim the pixelBuffer for my own use #manifestDestiny
        CVPixelBufferLockBaseAddress(pixelBuffer,
                                     CVPixelBufferLockFlags.readOnly)
        // this where my code will be
        //displayEqualizedPixelBuffer(pixelBuffer: pixelBuffer)
        calculateLuminance(pixelBuffer: pixelBuffer)
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer,
                                       CVPixelBufferLockFlags.readOnly)
        
    }
    
    func calculateLuminance(pixelBuffer: CVImageBuffer){
        //print("calculate luminance")
        
        let baseAddress = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0)
        let bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0)
        let width = CVPixelBufferGetWidthOfPlane(pixelBuffer, 0) / 4
        let height = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0) / 4
        let byteBuffer = baseAddress?.assumingMemoryBound(to: UInt32.self)

        // Get luma value for pixel (43, 17)
        
        var totatLuma = 0
        
        for x in (0...width){
            for y in (0...height){
                let luma = ((byteBuffer?[y * bytesPerRow + x])!) & 0b11111111
                totatLuma += Int(luma)
            }
        }
        
        // initialize the total previous luma if it does not yet have a value
        if (totalPreviousLuma == 0){
            totalPreviousLuma = totatLuma
        }
        
        if (totatLuma - totalPreviousLuma > 100000){
            //print("ON")
            triggerOn()
        }
        else if(totatLuma - totalPreviousLuma < -100000){
            //print("OFF")
            triggerOff()
        }
        
        // Handle the spaces and end of transmission
        if (offTimerDuration > 45){
            print("Detected Space")
            popMorseStack()
            currentMessage += " "
            print("Message: " + currentMessage)
            
            offTimerDuration = 0
            
            // We have to do UI updates Async like this
            DispatchQueue.main.async {
                self.decodeOutput.text = self.currentMessage
            }
            
            
        }
 
        totalPreviousLuma = totatLuma
        
    }
    
    func popMorseStack(){
        print("Letter end")
        // else if the torch has been off from about 2 < duration < 4 units we
        // know the current letter is over so we search the dictionary, print the character
        // and wait for a new letter
        if (morseToCharsDict.keys.contains(currentMorse)){
            currentLetter = morseToCharsDict[currentMorse]
            print("Letter is: " + currentLetter)
            currentMessage += currentLetter
            print("Message: " + currentMessage)
            
            currentMorse = ""   // empty current morse so it can find the next character
            // We have to do UI updates Async like this
            DispatchQueue.main.async {
                self.decodeOutput.text = self.currentMessage
            }
            
            
        }
        else {
            currentMorse = ""
            currentLetter = "?"
            currentMessage += currentLetter
            print("Letter is: " + currentLetter)
            print("Message: " + currentMessage)
            DispatchQueue.main.async {
                self.decodeOutput.text = self.currentMessage
            }

        }
    }
    
    // *******         the real meat and potatos of the program          ********
    
    /*
     called whenever we detect the flashlight turning on
     this is where we start the on phase and more importantly
     this is where we address the most recent off phase
    */
    func triggerOn(){
        self.decodeDetectsFlash = true
        
        print("On")
        print("On time: " + String(self.onTimerDuration) + " Off time: " + String(self.offTimerDuration))
        
        // check off phase timer
        // if off phase timer does not exist -> ignore it
 
        if offTimerDuration != 0 {
            
            // else we must check for the other 2 cases of why our light would be off:
            
            // else if the torch has been off from about 2 < duration < 4 units we
            // know the current letter is over so we search the dictionary, print the character
            // and wait for a new letter
            if(offTimerDuration >= 20 && offTimerDuration <= 45) {
                popMorseStack()
            }

            // else if the torch was only off for less than 2 duration units, we know we are
            // still working on the current letter so dont do anything
            // becuase the torch is on we disable the offTimer
            offTimerDuration = 0
            
        }
    }
    
    @objc func fireTimer(){
        if (self.decodeDetectsFlash == true){
            self.onTimerDuration += 1     // our timer steps  times a duration
        }
        else {
            self.offTimerDuration += 1
        }
        
        print("On time: " + String(self.onTimerDuration) + " Off time: " + String(self.offTimerDuration))
        
    }
    
    /*
     called whenever we detect the flashlight turning off
     this is where we start the off phase and more importantly
     this is where we check the length of the most recent on phase
    */
    func triggerOff(){
        self.decodeDetectsFlash = false
        
        if onTimerDuration != 0 {
            
            // if the most recent off state was more than 2 durations ago,
            // then we add a dash to the current character stack
            if (onTimerDuration >= 15) {
                currentMorse += "-"
                print("Detected: -")
            }
            // else add a dot
            else {
                currentMorse += "."
                print("Detected: .")
                print("CurrentMorse: " + currentMorse)
            }

            // invalidate the on timer becuase the torch is now off
            onTimerDuration = 0
            
        }
        
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
                result = result + " "
            }
            else {
                result = result + (charsToMorseDict[ String(c) ] ?? "")
            }
            
        }
        
        return result
    }
    
    // This is the boilerplate checks for seeing if the torch can be used
    // Only 1 app can use the torch at 1 time and some devices
    // don't have torches so we need to check for those as well
    func toggleTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }

        if device.hasTorch {
            do {
                try device.lockForConfiguration()

                if on == true {
                    device.torchMode = .on
                } else {
                    device.torchMode = .off
                }

                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }
    
}
