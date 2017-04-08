//
//  ViewController.swift
//  FreqAlerts
//
//  Created by Hayden Malcomson on 2017-04-07.
//  Copyright © 2017 Hayden Malcomson. All rights reserved.
//

import UIKit
import AudioKit
import SwiftSiriWaveformView
import AVFoundation
import AudioToolbox

class ViewController: UIViewController {
    
    @IBOutlet weak var waveform: SwiftSiriWaveformView!
    @IBOutlet weak var mainButton: UIButton!
    
    var player: AVAudioPlayer?
    var timer: Timer?
    
    var mic: AKMicrophone!
    var tracker: AKFrequencyTracker!
    var silence: AKBooster!
    
    var noTestValue = false
    var recording = false
    
    var gainCutoff: Double?
    var frequencyCutoff: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AKSettings.audioInputEnabled = true
        mic = AKMicrophone()
        tracker = AKFrequencyTracker(mic)
        silence = AKBooster(tracker, gain: 0)
        
        if UserDefaultsService.getBoolValueForKey(keyString: UserDefaultsService.FIRST_LOAD) == false {
            UserDefaultsService.setAllToTrue()
            UserDefaultsService.setBoolValueForKey(keyString: UserDefaultsService.FIRST_LOAD, bool: true)
        }
        
        if UserDefaultsService.getValueForKey(keyString: UserDefaultsService.GAIN_CUTOFF_VALUE) == nil || UserDefaultsService.getValueForKey(keyString: UserDefaultsService.FREQUENCY_CUTOFF_VALUE) == nil {
            noTestValue = true
            mainButton.setTitle("Test new Alarm", for: .normal)
        } else {
            gainCutoff = UserDefaultsService.getValueForKey(keyString: UserDefaultsService.GAIN_CUTOFF_VALUE)
            frequencyCutoff = UserDefaultsService.getValueForKey(keyString: UserDefaultsService.FREQUENCY_CUTOFF_VALUE)
        }
        
    }
    
    func updateUI() {
        
        guard let gain = gainCutoff else { return }
        guard let frequency = frequencyCutoff else { return }
        if recording == false { return }
        
        if tracker.amplitude > gain && tracker.frequency > frequency {
            recording = false
            triggerFlash(switchOn: true)
            triggerSound()
        } else {
            triggerFlash(switchOn: false)
        }
    }
    
    func triggerFlash(switchOn: Bool) {
        
        if UserDefaultsService.getBoolValueForKey(keyString: UserDefaultsService.SHOULD_FLASH) == false {
            return
        }
        
        if let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo), device.hasTorch {
            do {
                try device.lockForConfiguration()
                let torchOn = switchOn
                if torchOn {
                    try device.setTorchModeOnWithLevel(1.0)
                }
                device.torchMode = torchOn ? .on : .off
                device.unlockForConfiguration()
            } catch {
                print("error")
            }
        }
    }
    
    func triggerSound(){
        
        let url = Bundle.main.url(forResource: "slowrise", withExtension: "m4r")!
        
        do {
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
        } catch _ {
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            player.prepareToPlay()
            if UserDefaultsService.getBoolValueForKey(keyString: UserDefaultsService.SHOULD_FLASH) == false {
               player.volume = 0
            } else {
                player.volume = 1
            }
            player.numberOfLoops = 1
            player.play()
            player.delegate = self
        } catch let error {
            print(error.localizedDescription)
        }
        
        if UserDefaultsService.getBoolValueForKey(keyString: UserDefaultsService.SHOULD_VIBRATE) {
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        }

    }
    
    @IBAction func handleListen(_ sender: Any) {
        if noTestValue {
            AudioKit.stop()
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ListenVC") as! ListenVC
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            AudioKit.output = silence
            AudioKit.start()
            recording = true
            timer = Timer.scheduledTimer(timeInterval: 0.1,target: self, selector: #selector(updateUI), userInfo: nil, repeats: true)
        }
    }
    
    
    @IBAction func handleNewTest(_ sender: Any) {
        AudioKit.stop()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ListenVC") as! ListenVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func handleSettings(_ sender: Any) {
        AudioKit.stop()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PreferencesVC") as! PreferencesVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ViewController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        recording = true
        AudioKit.start()
        
    }
    
}






