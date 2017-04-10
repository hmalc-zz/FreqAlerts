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
import KDCircularProgress
import Charts

enum RecordingState: Int {
    case noTestAvailable = 0
    case notRecording = 1
    case recording = 2
    case testing = 3
    case alarmOn = 4
}

class ViewController: UIViewController {
    
    @IBOutlet weak var waveform: SwiftSiriWaveformView!
    @IBOutlet weak var mainButton: UIButton!
    
    @IBOutlet weak var welcomeString: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    
    var player: AVAudioPlayer?
    var timer: Timer?
    
    var mic: AKMicrophone!
    var tracker: AKFrequencyTracker!
    var silence: AKBooster!
    
    var currentState: RecordingState!
    
    var gainCutoff: Double?
    var frequencyCutoff: Double?
    
    var listeningPeriod: Double = 5
    var frequencySamples: [Double] = []
    var gainSamples: [Double] = []
    
    var lastSecondGainSamples: [Double] = []
    var lastSecondFrequencySamples: [Double] = []
    
    var medianFrequency: Double?
    var medianGain: Double?
    var allowanceFactor: Double = 0.95
    
    var countdownTimer: Timer?
    var didStartListeningTimeStamp: Date?

    @IBOutlet weak var volumePie: WaveAlertPieChart!
    @IBOutlet weak var frequencyPie: WaveAlertPieChart!
    
    @IBOutlet weak var gainLabel: UILabel!
    @IBOutlet weak var frequencyLabel: UILabel!

    @IBOutlet weak var circularProgress: KDCircularProgress!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AKSettings.audioInputEnabled = true
        mic = AKMicrophone()
        tracker = AKFrequencyTracker(mic)
        silence = AKBooster(tracker, gain: 0)
        currentState = .notRecording
        AudioKit.output = silence
        AudioKit.start()
        
        if UserDefaultsService.getBoolValueForKey(keyString: UserDefaultsService.FIRST_LOAD) == false {
            UserDefaultsService.setAllToTrue()
            UserDefaultsService.setBoolValueForKey(keyString: UserDefaultsService.FIRST_LOAD, bool: true)
        }
        timer = Timer.scheduledTimer(timeInterval: 0.01666,target: self, selector: #selector(updateUI), userInfo: nil, repeats: true)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillLayoutSubviews() {
        mainButton.layer.cornerRadius = mainButton.bounds.size.height/2
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserDefaultsService.getValueForKey(keyString: UserDefaultsService.GAIN_CUTOFF_VALUE) == nil || UserDefaultsService.getValueForKey(keyString: UserDefaultsService.FREQUENCY_CUTOFF_VALUE) == nil {
            currentState = .noTestAvailable
            mainButton.setTitle("Test new Alarm", for: .normal)
        } else {
            gainCutoff = UserDefaultsService.getValueForKey(keyString: UserDefaultsService.GAIN_CUTOFF_VALUE)
            frequencyCutoff = UserDefaultsService.getValueForKey(keyString: UserDefaultsService.FREQUENCY_CUTOFF_VALUE)
        }
        configureAppearance()

    }
    
    func resetCharts(){
        self.frequencyPie.setPieChart(value: 0, cutoff: 0)
        self.volumePie.setPieChart(value: 0, cutoff: 0)
    }
    
    func configureAppearance(){
        switch self.currentState! {
        case .noTestAvailable:
            mainButton.setTitle("Test Alarm", for: .normal)
            welcomeString.text = "Welcome to WaveAlerts"
            subtitle.text = "You don't have an alarm set up yet!"
            gainLabel.isHidden = true
            frequencyLabel.isHidden = true
            resetCharts()
        case .notRecording:
            mainButton.setTitle("Start Listening", for: .normal)
            
            welcomeString.text = "WaveAlerts"
            
            if let gain = gainCutoff, let frequency = frequencyCutoff {
                let titleString = "Your alarm is current set as \(gain.formatGain()) volume at \(frequency.formatFrequency())"
                let coloredComponents = ["\(gain.formatGain())", "\(frequency.formatFrequency())"]
                subtitle.attributedText = AttributedStringHelper.setAttributedStringWithColoredSection(baseString: titleString, replacementStrings: coloredComponents)
                
            } else {
                subtitle.text = "Tap to start listening for an alarm"
            }
            
            gainLabel.isHidden = true
            frequencyLabel.isHidden = true
            resetCharts()
            
        case .recording:
            mainButton.setTitle("Stop Listening", for: .normal)
            
            welcomeString.text = "Listening... "
            subtitle.text = "We'll alert you when your alarm goes off!"
            
            gainLabel.isHidden = false
            frequencyLabel.isHidden = false
            gainLabel.text = gainCutoff?.formatGain()
            frequencyLabel.text = frequencyCutoff?.formatFrequency()
            
        case .testing:
            
            mainButton.setTitle("Stop Listening", for: .normal)
            
            welcomeString.text = "Learning new alarm ..."
            
            let titleString = "Keep your alarm on for \(Int(listeningPeriod)) seconds"
            let coloredComponents = ["\(Int(listeningPeriod))"]
            subtitle.attributedText = AttributedStringHelper.setAttributedStringWithColoredSection(baseString: titleString, replacementStrings: coloredComponents)

            gainLabel.isHidden = false
            frequencyLabel.isHidden = false
            gainLabel.text = gainCutoff?.formatGain()
            frequencyLabel.text = frequencyCutoff?.formatFrequency()
            resetCharts()
            
        case .alarmOn:
            
            mainButton.setTitle("Stop Alarm", for: .normal)
            
            welcomeString.text = "Alarm Detected!"
            subtitle.text = "A sound played that sounded like your alarm"
            
            gainLabel.isHidden = true
            frequencyLabel.isHidden = true
            resetCharts()
        
        }
    }
    
    func updateUI() {
        
        self.waveform.amplitude = CGFloat(self.tracker.amplitude)
        
        switch self.currentState! {
            case .testing:
                executeTesting()
            case .notRecording:
                print("")
            case .recording:
                updateStats()
                
                lastSecondGainSamples.append(self.tracker.amplitude)
                if lastSecondGainSamples.count > 60 {
                    lastSecondGainSamples.removeFirst()
                    self.medianGain = lastSecondGainSamples.reduce(0,+)/lastSecondGainSamples.count
                }
                lastSecondFrequencySamples.append(self.tracker.frequency)
                if lastSecondFrequencySamples.count > 60 {
                    lastSecondFrequencySamples.removeFirst()
                    self.medianFrequency = lastSecondFrequencySamples.reduce(0,+)/lastSecondFrequencySamples.count
                }
                
                guard let gain = self.gainCutoff else { return }
                guard let frequency = self.frequencyCutoff else { return }
                guard let averageGain = self.medianGain else { return }
                guard let averageFrequency = self.medianFrequency else { return }
                
                volumePie.setPieChart(value: averageGain, cutoff: gainCutoff!)
                frequencyPie.setPieChart(value: averageFrequency, cutoff: frequencyCutoff!)
                
                if averageGain > gain && averageFrequency > frequency {
                    lastSecondFrequencySamples = []
                    lastSecondGainSamples = []
                    self.triggerFlash(switchOn: true)
                    self.triggerSound()
                    self.currentState = .alarmOn
                    configureAppearance()
                } else {
                    self.triggerFlash(switchOn: false)
                }
            case .noTestAvailable:
                print("")
        case .alarmOn:
                print("")
            }
    }
    
    func executeTesting(){
        updateStats()
        if let started = didStartListeningTimeStamp {
            let timeElapsed = Date().timeIntervalSince(started)
            if timeElapsed > listeningPeriod {
                self.currentState = .notRecording
                circularProgress.angle = 0
                if let frequency = medianFrequency {
                    frequencyCutoff = frequency * allowanceFactor
                    UserDefaultsService.setValueForKey(keyString: UserDefaultsService.FREQUENCY_CUTOFF_VALUE, value: frequencyCutoff!)
                    self.medianFrequency = 0
                }
                
                if let gain = medianGain {
                    gainCutoff = gain * allowanceFactor
                    UserDefaultsService.setValueForKey(keyString: UserDefaultsService.GAIN_CUTOFF_VALUE, value: gainCutoff!)
                    self.medianGain = 0
                }
                configureAppearance()
                return
            }
            circularProgress.angle = 360 * (timeElapsed/listeningPeriod)
            mainButton.setTitle("\(Int(ceil(listeningPeriod - timeElapsed)))", for: .normal)
        }
        frequencySamples.append(tracker.frequency)
        frequencySamples = frequencySamples.sorted()
        if frequencySamples.count > 0 {
            let index = Int(floor(Double(frequencySamples.count)/2))
            frequencyLabel.text = frequencySamples[index].formatFrequency()
            medianFrequency = frequencySamples[index]
        }
        gainSamples.append(tracker.amplitude)
        gainSamples = gainSamples.sorted()
        if gainSamples.count > 0 {
            let index = Int(floor(Double(gainSamples.count)/2))
            gainLabel.text = gainSamples[index].formatGain()
            medianGain = gainSamples[index]
        }
    }
    
    func updateStats(){
        
        self.gainLabel.isHidden = false
        self.frequencyLabel.isHidden = false
        self.gainLabel.text = self.tracker.amplitude.formatGain()
        self.frequencyLabel.text = self.tracker.frequency.formatFrequency()
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
        
        if UserDefaultsService.getBoolValueForKey(keyString: UserDefaultsService.SHOULD_VIBRATE) {
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        }
        
        let url = Bundle.main.url(forResource: "slowrise", withExtension: "m4r")!
        
        do {
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
        } catch _ {
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            player.prepareToPlay()
            if UserDefaultsService.getBoolValueForKey(keyString: UserDefaultsService.SHOULD_PLAY_SOUND) == false {
               player.volume = 0
            } else {
                player.volume = 1
            }
            player.numberOfLoops = 0
            player.play()
            player.delegate = self
        } catch let error {
            print(error.localizedDescription)
        }

    }
    
    @IBAction func handleListen(_ sender: Any) {
        player?.stop()
        triggerFlash(switchOn: false)
        switch currentState! {
        case .notRecording:
            self.currentState = .recording
        case .recording:
            self.currentState = .notRecording
        case .noTestAvailable:
            triggerNewTest()
        case .testing:
            print("Still testing")
        case .alarmOn:
            self.currentState = .notRecording
        }
        configureAppearance()
    }
    
    func triggerNewTest(){
        player?.stop()
        self.didStartListeningTimeStamp = Date()
        self.currentState = .testing
        frequencySamples = []
        gainSamples = []
        configureAppearance()
    }
    
    
    @IBAction func handleNewTest(_ sender: Any) {
        triggerNewTest()
    }
    
    @IBAction func handleSettings(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PreferencesVC") as! PreferencesVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ViewController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if self.currentState == .alarmOn {
            player.stop()
            self.currentState = .recording
            triggerFlash(switchOn: false)
            configureAppearance()
        }
    }
}




