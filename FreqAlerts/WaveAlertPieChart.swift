//
//  WaveAlertPieChart.swift
//  FreqAlerts
//
//  Created by Hayden Malcomson on 2017-04-09.
//  Copyright © 2017 Hayden Malcomson. All rights reserved.
//

import Foundation
import Charts

class WaveAlertPieChart: PieChartView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configurePieChart()
    }
    
    func configurePieChart(){
        
        self.holeRadiusPercent = 0.9
        self.transparentCircleColor = UIColor.clear
        self.holeColor = UIColor.clear
        self.chartDescription?.text = ""
        self.legend.enabled = false
        self.noDataText = ""
    }
    
    func setPieChart(value: Double, cutoff: Double) {
        
        var value2 = cutoff - value
        var exceedLimit = false
        
        if value > cutoff {
            value2 = 0
            exceedLimit = true
        }
        
        let dataEntry: [PieChartDataEntry] = [PieChartDataEntry(value: value),PieChartDataEntry(value: value2)]
        let pieChartDataSet = PieChartDataSet(values: dataEntry, label: "")
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        pieChartData.setValueTextColor(UIColor.clear)
        self.data = pieChartData
        
        if exceedLimit {
            let colors: [UIColor] = [
                UIColor(hex: "080f91"),
                UIColor.clear
            ]
            pieChartDataSet.colors = colors
        } else {
            let colors: [UIColor] = [
                UIColor(hex: "7B81F7"),
                UIColor.clear
            ]
            pieChartDataSet.colors = colors
        }
        

    }
    
    
}
