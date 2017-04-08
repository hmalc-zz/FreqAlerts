//
//  PreferencesVC.swift
//  FreqAlerts
//
//  Created by Hayden Malcomson on 2017-04-08.
//  Copyright © 2017 Hayden Malcomson. All rights reserved.
//

import UIKit

class PreferencesVC: UIViewController {

    @IBOutlet weak var preferencesCollectionView: UICollectionView!
    
    var preferences = freqPreferences
    
    var screenSize = UIScreen.main.bounds.size
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    func configureUI(){
        configureCollectionView()
    }
    
    func configureCollectionView(){
        let imageNib = UINib(nibName: "NotificationTypeCell", bundle: nil)
        preferencesCollectionView.register(imageNib, forCellWithReuseIdentifier: "NotificationTypeCell")
        preferencesCollectionView.delegate = self
        preferencesCollectionView.dataSource = self
        preferencesCollectionView.contentInset.left = 8
        preferencesCollectionView.reloadData()
    }
}

extension PreferencesVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return preferences.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NotificationTypeCell", for: indexPath) as? NotificationTypeCell {
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let heightDim: CGFloat = 80
        let widthDim: CGFloat = screenSize.width
        return CGSize(width: widthDim, height: heightDim)
    }
    
}
