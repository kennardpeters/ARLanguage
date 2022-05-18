//
//  Record.swift
//  VisualizingSceneSemantics
//
//  Created by Kennard Peters on 3/26/21.
//  Copyright © 2021 Apple. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

#warning("This app has crashed because it attempted to access privacy-sensitive data without a usage description.  The app's Info.plist must contain an NSMicrophoneUsageDescription key with a string value explaining to the user how the app uses this data.")

// Info.plist             Privacy - Microphone Usage Description              This app use the microphone to record audio

// Note: You may need a different AVAudioSession.Mode and a different AVAudioSession.CategoryOptions

class RecordViewController: UIViewController, AVSpeechSynthesizer, AVAudioRecorderDelegate {
    var viewController: UIViewController!
    let session = AVAudioSession.sharedInstance()
    var audioRecorder: AVAudioRecorder?
    let synthesizer = AVSpeechSynthesizer()
    var string: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        synthesizer.delegate = self
        
        audioSession = AVAudioSession.sharedInstance()
        
        
        //Need to take out audio recorder and run it inside VC
        recordAudio()
        audioRecorder.delegate = self
        let TextToSpeech = TTS(speechStr: "Let's Augment Reality Together", synthesizer: self.synthesizer)
        //Plays pronunciation
        TextToSpeech.pronounce()
    }
    
    lazy var speechUtterance : AVSpeechUtterance = {
        let string = self.string //need parameters
        let utterance = AVSpeechUtterance(string: string!)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        return utterance
    }()
    
    func speak(){
        print("\(type(of:self)) \(#function)")
        synthesizer.delegate = self.viewController as? AVSpeechSynthesizerDelegate //need parameter for arView
        synthesizer.speak(speechUtterance)
    }
    func recordAudio() {
        print("\(type(of: self)) \(#function)")
        audioSession.requestRecordPermission() { [unowned self] (granted) in
            DispatchQueue.main.async {
                if granted {
//                    guard let strongSelf = self else {
//                        return
//                    }
            
                do {
                    try self.audioSession.setCategory(.playAndRecord, mode: .default)
                
                    try self.audioSession.setActive(true)
                    let recordingFileName = "recording.m4a"
                    let recordingURL = self.saveDocumentDirectory().appendingPathComponent(recordingFileName)
                    print("Saved File: \(recordingURL.absoluteString)")
    //                let recordingURL = initialPath.appendPathComponent(recordingFileName)
                    
                    let settings: [String: Any] = [
                        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
                        AVSampleRateKey: 12000,
                        AVNumberOfChannelsKey: 1,
                        AVFormatIDKey: Int(kAudioFormatMPEG4AAC)
                    ]
                
                    try self.audioRecorder = AVAudioRecorder(
                        url: recordingURL,
                        settings: settings
                    )
                    self.audioRecorder.delegate = self
                    self.audioRecorder.record()
                    } catch let error {
                        print("error recordAudio: \(error)")
                    }
                }
            }
        }
    }
    
    private func saveDocumentDirectory() -> URL {
        print("\(type(of: self)) \(#function)")
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("recording Failed")
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("recording Failed")
        }
    }
//    func recordAudio() {
//        session.requestRecordPermission { [weak self] (granted) in
//            guard granted else {
//                return
//            }
//
////            guard let strongSelf = self!.viewController else {
////                return
////            }
//
//            do {
//                try self?.session.setCategory(.playAndRecord, mode: .spokenAudio, options: [.defaultToSpeaker])
//
//                try self?.session.setActive(true)
//                let recordingFileName = "recording.m4a"
//                let recordingURL = self!.saveDocumentDirectory().appendingPathComponent(recordingFileName)
////                let recordingURL = initialPath.appendPathComponent(recordingFileName)
//
//                let settings: [String: Any] = [
//                    AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
//                    AVSampleRateKey: 12000.0,
//                    AVNumberOfChannelsKey: 1,
//                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC)
//                ]
//
//                try self?.audioRecorder = AVAudioRecorder(
//                    url: recordingURL,
//                    settings: settings
//                )
//                self?.audioRecorder?.record()
//            } catch let error {
//                print("error recordAudio: \(error)")
//            }
//        }
//    }
    func saveDocumentDirectory() -> URL {
        print("\(type(of: self)) \(#function)")
        let documentsPath = FileManager.default.urls(for: .downloadsDirectory, in: .allDomainsMask)[0]
        let documentsPathStr = NSSearchPathForDirectoriesInDomains(.downloadsDirectory, .allDomainsMask, true)[0]
        print(documentsPathStr)
        return documentsPath
        
        
//        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
    }
    private func documentsDirectoryURL() -> URL {
        print("\(type(of: self)) \(#function)")
        let urls = FileManager.default.urls(for: .userDirectory, in: .allDomainsMask)
//        let urlsNew = urls[urls.count - 1].appendingPathComponent(newFile)
//        let urlReturn = urlsNew.appendPathComponent(newFile)
        return urls[urls.count - 1]
//        return urlsNew
    }
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        recordAudio()
//        speak()
//    }
}
//extension ViewController{
//
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
//        print("\(type(of: self)) \(#function)")
//        self.audioRecorder?.stop()
//    }
//}
//extension ViewController {
//    
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
//        print("\(type(of: self)) \(#function)")
//        self.audioRecorder.stop()
//        print(self.audioRecorder.isRecording)
//        let recordingFileName = "recording.m4a"
//        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(recordingFileName)
////        let documentsPathStr = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0].app
//        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (timer) in
//            print("Found: \(FileManager.default.fileExists(atPath: "///var/mobile/Containers/Data/Application/4481AE2A-EEA4-492A-8DBF-DA65DF20EE49/Documents/recording.m4a"))")
//            print("Location Checked: \(documentsPath.absoluteString)")
//        }
//        
//    }
//}

