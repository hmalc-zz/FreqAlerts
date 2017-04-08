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

class ViewController: UIViewController {
    
    @IBOutlet weak var waveform: SwiftSiriWaveformView!
    
    var mic: AKMicrophone!
    var tracker: AKFrequencyTracker!
    var silence: AKBooster!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AKSettings.audioInputEnabled = true
        mic = AKMicrophone()
        tracker = AKFrequencyTracker(mic)
        silence = AKBooster(tracker, gain: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AudioKit.output = silence
        AudioKit.start()
        Timer.scheduledTimer(timeInterval: 1,
                             target: self,
                             selector: #selector(ViewController.updateUI),
                             userInfo: nil,
                             repeats: true)
    }
    
    func updateUI() {
        
        if tracker.amplitude > 0.1 && tracker.frequency > 1000 {
            toggleFlash(switchOn: true)
        } else {
            toggleFlash(switchOn: false)
        }
        
    }
    
    func toggleFlash(switchOn: Bool) {
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
    
    @IBAction func handleListen(_ sender: Any) {
        
        
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







