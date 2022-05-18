//
//  TextToSpeech.swift
//  VisualizingSceneSemantics
//
//  Created by Kennard Peters on 3/27/21.
//  Copyright © 2021 Apple. All rights reserved.
//

import Foundation
import AVFoundation
import NaturalLanguage

class TTS {
    //variable to store speech utterance
    var utterance: AVSpeechUtterance!
    //variable to store speech synthesizer
    var synthesizer: AVSpeechSynthesizer!
    required init(speechStr: String, synthesizer: AVSpeechSynthesizer) {
        self.utterance = AVSpeechUtterance(string: speechStr)
        self.synthesizer = synthesizer
        //Detect the language of inputted text
        guard let lang = self.detectedLanguage(speechStr: speechStr) else {
//            print("Translation Failed")
            return
        }
        //For Debugging Purposes
//        print(lang)
        //Used for mandarin detection
        let regString = lang as NSString
        //If language detected contains Chinese assign the voice (Used for specific instances where strings do not input correctly into AVSpeechVoice
        if (regString.contains("Chinese")) {
            self.utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        } else if lang == "Russian" {
            self.utterance.voice = AVSpeechSynthesisVoice(language: "ru-RU")
        } else if lang == "Hindi" {
            self.utterance.voice = AVSpeechSynthesisVoice(language: "hi-IN")
        } else if lang == "Arabic" {
            self.utterance.voice = AVSpeechSynthesisVoice(language: "ar-SA")
        //Sets English accent to British
        } else if lang == "en" {
            self.utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        //Sets Spanish accent to Latin American Spanish
        } else if lang == "es" {
            self.utterance.voice = AVSpeechSynthesisVoice(language: "es-MX")
        }
        else {
            self.utterance.voice = AVSpeechSynthesisVoice(language: lang)
        }
        //Assign speech rate
        self.utterance.rate = AVSpeechUtteranceMaximumSpeechRate / 2
        //Assign speech volume
        self.utterance.volume = 1.0
    }
    func pronounce() {
        //Assign speech volume
        self.utterance.volume = 1.0
        if self.synthesizer.isSpeaking == false {
            self.synthesizer.speak(self.utterance)
        }
        else {
            //Add UILabel to let the user know that the app is already speaking
        }
    }
    //Function using NLP to recognize the language of input text
    private func detectedLanguage(speechStr: String) -> String? {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(speechStr)
        //Get language based on estimated dominant language of text
        guard let languageCode = recognizer.dominantLanguage?.rawValue else { return nil }
        //For debugging purposes
        print(languageCode)
        //Option for getting exact language (Code is preferred)
//        let detectedLanguage = Locale.current.localizedString(forIdentifier: languageCode)
        //reset recognizer to prevent bias on next string of words
        recognizer.reset()
        return languageCode
    }
}
