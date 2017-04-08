//
//  ListenVC.swift
//  FreqAlerts
//
//  Created by Hayden Malcomson on 2017-04-08.
//  Copyright © 2017 Hayden Malcomson. All rights reserved.
//

import UIKit
import AudioKit
import SwiftSiriWaveformView
import KDCircularProgress

class ListenVC: UIViewController {

    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var countdownTimerLabel: UILabel!
    @IBOutlet weak var outputValuesStackView: UIStackView!
    
    @IBOutlet weak var volumeLabel: UILabel!
    @IBOutlet weak var frequencyLabel: UILabel!
    
    @IBOutlet weak var listeningLabelStackView: UIStackView!
    @IBOutlet weak var listeningLabel: UILabel!
    @IBOutlet weak var alarmOnNotification: UILabel!
    
    
    @IBOutlet weak var waveView: SwiftSiriWaveformView!
    @IBOutlet weak var circularProgress: KDCircularProgress!
    
    var mic: AKMicrophone!
    var tracker: AKFrequencyTracker!
    var silence: AKBooster!
    
    var listeningPeriod: Double = 5
    var isListening = false
    var frequencySamples: [Double] = []
    var gainSamples: [Double] = []
    
    var medianFrequency: Double?
    var medianGain: Double?
    
    var timer:Timer?
    var countdownTimer: Timer?
    var didStartListeningTimeStamp: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.waveView.density = 1.0
        AKSettings.audioInputEnabled = true
        mic = AKMicrophone()
        tracker = AKFrequencyTracker(mic)
        silence = AKBooster(tracker, gain: 0)
        timer = Timer.scheduledTimer(timeInterval: 0.01666, target: self, selector: #selector(sampleAudio(_:)), userInfo: nil, repeats: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AudioKit.output = silence
        AudioKit.start()
    }
    
    internal func sampleAudio(_:Timer) {
        
        if isListening {
            if let started = didStartListeningTimeStamp {
               let timeElapsed = Date().timeIntervalSince(started)
                if timeElapsed > listeningPeriod {
                    listeningPeriodDidFinish()
                    return
                }
                circularProgress.angle = 360 * (timeElapsed/listeningPeriod)
                countdownTimerLabel.text = "\(Int(ceil(listeningPeriod - timeElapsed)))"
            }
            frequencySamples.append(tracker.frequency)
            frequencySamples = frequencySamples.sorted()
            if frequencySamples.count > 0 {
                let index = Int(floor(Double(frequencySamples.count)/2))
                frequencyLabel.text = frequencySamples[index].formatFrequency()
            }
            gainSamples.append(tracker.amplitude)
            gainSamples = gainSamples.sorted()
            if gainSamples.count > 0 {
                let index = Int(floor(Double(gainSamples.count)/2))
                volumeLabel.text = gainSamples[index].formatGain()
            }
        }
        
        waveView.amplitude = CGFloat(tracker.amplitude)
    }
    
    func listeningPeriodDidFinish(){
        isListening = false
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PreferencesVC") as! PreferencesVC
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func handleAppearance(){
        circularProgress.isHidden = !isListening
        countdownTimerLabel.isHidden = !isListening
        welcomeLabel.isHidden = isListening
        subtitle.isHidden = isListening
        outputValuesStackView.isHidden = !isListening
        listeningLabelStackView.isHidden = !isListening
    }
    
    @IBAction func handleListen(_ sender: Any) {
        isListening = true
        handleAppearance()
        didStartListeningTimeStamp = Date()
        circularProgress.progress = 0
        frequencySamples = []
        gainSamples = []
    }
}











