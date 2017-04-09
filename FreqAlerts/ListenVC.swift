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
    
    @IBOutlet weak var listeningButton: UIButton!
    
    @IBOutlet weak var waveView: SwiftSiriWaveformView!
    @IBOutlet weak var circularProgress: KDCircularProgress!
    
    var mic: AKMicrophone!
    var tracker: AKFrequencyTracker!
    var silence: AKBooster!
    
    
}











