//
//  BarchartViewController.swift
//  Budget
//
//  Created by linoj ravindran on 21/05/2018.
//  Copyright © 2018 linoj ravindran. All rights reserved.
//

import UIKit
import Charts
import Firebase
import FirebaseDatabase
import FirebaseAuth

class BarchartViewController: UIViewController, ChartViewDelegate{
    var udgifter = [Detail]()
    @IBOutlet var barChart: BarChartView!
    var antalUdgifter = [BarChartDataEntry]()
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (self.isMovingFromParent) {
            UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        canRotate()
        barChart.delegate = self
        barChart.noDataText = "Der er intet data at vise"
        navigationItem.title = "Grafisk oversigt over udgifter"
        barChart.chartDescription?.text = ""
        self.generateBarChart()
        self.updateChart()
        barChart.doubleTapToZoomEnabled = false
        barChart.pinchZoomEnabled = true
        
    }
    func generateBarChart(){
        for index in 0...udgifter.count-1 {
            let udgift1 = BarChartDataEntry(x: Double(index), yValues: [Double(udgifter[index].beløb)])
            antalUdgifter.append(udgift1)
        }
    }
    func updateChart(){
        let chartDataSet = BarChartDataSet(values: antalUdgifter, label: "Udgifter")
        let chartData = BarChartData(dataSet: chartDataSet)
        barChart.data = chartData
        chartDataSet.colors = ChartColorTemplates.colorful()
        barChart.xAxis.labelPosition = .bottom
        barChart.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
        let xaxis = barChart.xAxis
        xaxis.drawGridLinesEnabled = false
        
    }
    public func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let udgiftNavn = String(udgifter[Int(highlight.x)].detaljeNavn)
        let alertController = UIAlertController(title: "Info", message: "Navn: \(udgiftNavn) \n Beløb: \(Int(highlight.y)) kr.", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    @objc func canRotate() -> Void {}
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        barChart.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.RawValue(UInt8(UIView.AutoresizingMask.flexibleWidth.rawValue) | UInt8(UIView.AutoresizingMask.flexibleHeight.rawValue)))
    }
}
