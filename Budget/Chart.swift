//
//  Chart.swift
//  Budget
//
//  Created by linoj ravindran on 24/03/2018.
//  Copyright © 2018 linoj ravindran. All rights reserved.
//
import Foundation
import Charts
import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
class Chart: UIViewController, ChartViewDelegate{
    var ref: DatabaseReference!
    var databaseHandle: DatabaseHandle?
    var months = [String]()
    var unitsSold = [Double]()
    @IBOutlet weak var pieChartView: PieChartView!
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        databaseHandle = ref.child("Budget").observe(.childAdded, with: { (snapshot) -> Void in
            let value1 = snapshot.value as? NSDictionary
            for (key, value) in value1! {
                let notenu = key as! String
                if(notenu == "Budget navn"){
                    self.months.append(value as! String)
                }
                else if(notenu == "Penge tilbage"){
                    self.unitsSold.append(value as! Double)
                }
                else{
                    
                }
            }
            self.setChart(dataPoints :self.months, values: self.unitsSold)
        })
    }
    func setChart(dataPoints: [String], values: [Double]) {
        var dataEntries: [PieChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = PieChartDataEntry(value: values[i], label: dataPoints[i])
            dataEntries.append(dataEntry)
        }
        let pieChartDataSet = PieChartDataSet(values: dataEntries, label: "")
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        pieChartDataSet.sliceSpace = 2
        pieChartView.data = pieChartData
        
        var colors: [UIColor] = []
        
        for _ in 0..<dataPoints.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        pieChartDataSet.colors = colors
        pieChartView.chartDescription?.text = "Budgets"
        pieChartView.notifyDataSetChanged()
        pieChartView.drawHoleEnabled = false
        pieChartView.noDataText = "No data to display"
    }
}

