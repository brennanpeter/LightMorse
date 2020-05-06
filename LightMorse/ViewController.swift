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
    
    let duration = UInt32(250000)    // length of a 1 morse unit in milliseconds
    
    var totalPreviousLuma = 0
    
    var onTimer: Timer!
    var offTimer: Timer!
    
    var onTimerDuration: Int!
    var offTimerDuration: Int!
    
    var currentLetter: String!
    var currentMorse: String!
    
    // hiding and showing the main menu
    func toggleButtons(){
        decodeButton.isHidden =  !decodeButton.isHidden
        encodeButton.isHidden =  !encodeButton.isHidden
        helpButton.isHidden =  !helpButton.isHidden
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
    // dictionary of characters and their corresponding codes
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
        ".----|":"1",
        "..---|":"2",
        "...--|":"3",
        "....-|":"4",
        ".....|":"5",
        "-....|":"6",
        "--...|":"7",
        "---..|":"8",
        "----.|":"9",
        "-----|":"0"
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
        let inputLabel = UILabel(frame: CGRect(x: 10, y: 10, width: 100, height: 50))
        inputLabel.text = "Input"
        self.view.addSubview(inputLabel)
        
        // add a text box programatically
        //https://stackoverflow.com/questions/24710041/adding-uitextfield-on-uiview-programmatically-swift/32602425
        textInput = UITextField(frame: CGRect(x: 50, y: 50, width: 300, height: 50))
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
        self.view.addSubview(textInput)
        
        let outputLabel = UILabel(frame: CGRect(x: 10, y: 270, width: 100, height: 50))
        outputLabel.text = "Output"
        self.view.addSubview(outputLabel)
        
        
        morseOutput = UITextView(frame: CGRect(x: 50, y: 120, width: 300, height: 200))
        morseOutput.font = UIFont.systemFont(ofSize: 18)
        morseOutput.textAlignment = NSTextAlignment.left
        morseOutput.layer.borderColor = UIColor.lightGray.cgColor
        morseOutput.layer.borderWidth = 1
        morseOutput.layer.cornerRadius = 6
        morseOutput.text = ""
        morseOutput.isEditable = false
        self.view.addSubview(morseOutput)
        
        // add an output window showing the converted morse
        // add a button to start encoding
        let sendButton = UIButton(frame: CGRect(x: 100, y: 420, width: 200, height: 100))
        sendButton.backgroundColor = .purple
        sendButton.layer.cornerRadius = 6
        sendButton.setTitle("Send", for: .normal)
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        self.view.addSubview(sendButton)
        
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
        // To learn about making a live AVcapture seesion I watched the tutorial at:
        // https://www.youtube.com/watch?v=p6GA8ODlnX0
        
        // Set up for the camera     Lots of boilerplate :(
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
            print("ON")
            triggerOn()
        }
        else if(totatLuma - totalPreviousLuma < -100000){
            print("OFF")
            triggerOff()
        }
 
        totalPreviousLuma = totatLuma
        
    }
    
    // *******         the real meat and potatos of the program          ********
    
    /*
     called whenever we detect the flashlight turning on
     this is where we start the on phase and more importantly
     this is where we address the most recent off phase
    */
    func triggerOn(){
        // Check to see if we have already detected an on state recently and if so ignore this one
        if (onTimerDuration < 1 && onTimer != nil){
            print("ON:  Ignore")
            return
        }
        
        // start on phase timer
        onTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(fireOnTimer), userInfo: nil, repeats: true)
        RunLoop.current.add(onTimer, forMode: .common)
        
        // check off phase timer
        // if off phase timer does not exist -> ignore it
        if offTimer != nil {
            
            // else we must check for the 3 cases of why our light would be off:
            if (offTimerDuration >= 6){
                // if the torch has been off for more than 7 duration units we append a space to the result
                print("ON:  Ignore")
            }
            else if(offTimerDuration >= 2 && offTimerDuration <= 4) {
                // else if the torch has been off from about 2 < duration < 4 units we
                // know the current letter is over so we search the dictionary, print the character
                // and wait for a new letter
                if (morseToCharsDict.keys.contains(currentMorse)){
                    currentLetter = morseToCharsDict[currentMorse]
                    print("Letter is: " + currentLetter)
                }
                else {
                    currentMorse = ""
                    currentLetter = "?"
                    print("Letter is: " + currentLetter)
                }
                
            }

            // else if the torch was only off for less than 2 duration units, we know we are
            // still working on the current letter so dont do anything
            
            // becuase the torch is on we disable the offTimer
            offTimer.invalidate()
            offTimerDuration = 0
            
        }
    }
    
    @objc func fireOnTimer(){
        self.onTimerDuration += 1
        print("On Timer fired!")
    }
    
    /*
     called whenever we detect the flashlight turning off
     this is where we start the off phase and more importantly
     this is where we check the length of the most recent on phase
    */
    func triggerOff(){
        // Check to see if we have already detected an off state recently
        //  (within 1 duration) and if so ignore this one
        if (offTimerDuration < 1 && offTimer != nil){
            return
        }
        
        // start off timer
        offTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(fireOffTimer), userInfo: nil, repeats: true)
        RunLoop.current.add(offTimer, forMode: .common)
        
        if onTimer != nil {
            
            // if the most recent off state was more than 2 durations ago,
            // then we add a dash to the current character stack
            if (onTimerDuration >= 2) {
                currentMorse += "-"
                print("Detected: -")
            }
            // else add a dot
            else {
                currentMorse += "."
                print("Detected: .")
            }
            
            // invalidate the on timer becuase the torch is now off
            onTimer.invalidate()
            onTimerDuration = 0
            
        }
        
    }
    
    @objc func fireOffTimer(){
        self.offTimerDuration += 1
        print("Off Timer fired!")
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
