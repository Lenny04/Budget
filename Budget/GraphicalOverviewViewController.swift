//
//  GraphicalOverviewViewController.swift
//  Budget
//
//  Created by linoj ravindran on 06/05/2018.
//  Copyright © 2018 linoj ravindran. All rights reserved.
//

import UIKit
import Charts
import Firebase
import FirebaseDatabase
import FirebaseAuth

class GraphicalOverviewViewController: UIViewController{
    var udgifter = [Detail]()
    @IBOutlet var pieChart: PieChartView!
    var antalUdgifter = [PieChartDataEntry]()
    override func viewDidAppear(_ animated: Bool) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Grafisk oversigt over udgifter"
        pieChart.chartDescription?.text = "Udgifter"
        self.generatePieChart()
        self.updateChart()
        
    }
    func generatePieChart(){
        for index in 0...udgifter.count-1 {
            let udgift1 = PieChartDataEntry(value: 0)
            udgift1.value = Double(udgifter[index].getBeløb())
            udgift1.label = udgifter[index].getName()
            antalUdgifter.append(udgift1)
        }
    }
    func updateChart(){
        let chartDataSet = PieChartDataSet(values: antalUdgifter, label: nil)
        let chartData = PieChartData(dataSet: chartDataSet)
        let blue = UIColor.blue
        let green = UIColor(red: 0.051, green: 0.6471, blue: 0, alpha: 1.0)
        let red = UIColor(red: 0.7569, green: 0, blue: 0, alpha: 1.0)
        let turkish = UIColor(red: 0, green: 0.702, blue: 0.7373, alpha: 1.0)
        let purple = UIColor(red: 0.6941, green: 0, blue: 0.7176, alpha: 1.0)
        let orange = UIColor(red: 0.8667, green: 0.6196, blue: 0, alpha: 1.0)
        let grey = UIColor(red: 0.5765, green: 0.5765, blue: 0.5765, alpha: 1.0)
        let colors = [blue, green, red, turkish, purple, orange, grey]
        chartDataSet.colors = colors
        pieChart.data = chartData
        pieChart.holeRadiusPercent = 0 // Fjerner hullet i midten af Piechart
        pieChart.transparentCircleRadiusPercent = 0 // Fjerner transparent cirkel i midten
        pieChart.drawEntryLabelsEnabled = false // Fjerner teksten fra hver pie slice
    }
}
