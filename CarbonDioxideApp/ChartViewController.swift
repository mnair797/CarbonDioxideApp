//
//  ChartViewController.swift
//  CarbonDioxideApp
//
//  Created by Meenakshi Nair on 3/10/21.
//

import Highcharts
import UIKit
import Foundation

class ChartViewController: UIViewController {
    
    @IBOutlet weak var firstDate: UIDatePicker!
    @IBOutlet weak var secondDate: UIDatePicker!
    @IBOutlet weak var drawButton: UIButton!
    @IBOutlet weak var mainView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //chartIrregularTime()
        GoogleSheetsIntegration.getSheet()
        //chartZoomableTime()
    }
    
    @IBAction func firstDatePressed(_ sender: Any) {
        print("First date chosen")
    }
    
    
    @IBAction func secondDateChosen(_ sender: Any) {
        print("Second date chosen")
    }
    
    
    @IBAction func buttonPressed(_ sender: Any) {
        chartZoomableTime()
    }
    
    func chartZoomableTime() {
        let chartView = HIChartView(frame: view.bounds)
        //let chartView = mainView as! HIChartView;
        
        let options = HIOptions()
        
        let chart = HIChart()
        chart.zoomType = "x"
        //chart.inverted = true
        //chart.backgroundColor=HIColor(linearGradient: ["x1": 0, "y1": 0, "x2": 0, "y2": 0.5], stops: [[0, "rgba(255,255,255, 0.75)"], [1, "rgba(255,255,255, 0.02)"]])
        
        options.chart = chart
        
        let title = HITitle()
        title.text = "CO2 level (ppm) over time"
        options.title = title
        
        let subtitle = HISubtitle()
        subtitle.text = "Pinch the chart to zoom in"
        options.subtitle = subtitle
        
        let xAxis = HIXAxis()
        xAxis.type = "datetime"
        options.xAxis = [xAxis]
        
        let yAxis = HIYAxis()
        yAxis.title = HITitle()
        yAxis.title.text = "CO2 level (ppm)"
        options.yAxis = [yAxis]
        
        let legend = HILegend()
        legend.enabled = false
        options.legend = legend
        
        let plotOptions = HIPlotOptions()
        plotOptions.area = HIArea()
        plotOptions.area.fillColor = HIColor(linearGradient: ["x1": 0, "y1": 0, "x2:": 0, "y2": 1],
                                             stops: [[0, "rgb(47,126,216)"], [1, "rgba(47,126,216,0)"]])
        plotOptions.area.marker = HIMarker()
        plotOptions.area.marker.radius = 2
        plotOptions.area.lineWidth = 1
        plotOptions.area.states = HIStates()
        plotOptions.area.states.hover = HIHover()
        plotOptions.area.states.hover.lineWidth = 1
        options.plotOptions = plotOptions
        
        let area = HIArea()
        area.name = "CO2 ppm"
        //GoogleSheetsIntegration.getSheet()
        debugPrint("Invoked Google Sheets integration")
        //area.data = GoogleSheetsIntegration.dataset
        area.data=data()
        
        var ls = [HILabels()]
        for(idx,val) in [1607509860000: "Open windows. End of trip.", 1607506800000: "Opened windows.", 1607505300000: "Starting trip. Windows closed but with outside air.", 1607508660000: "Opened windows.", 1607507340000: "Ventilation off.", 1607509140000: "Starting again with ventilation off."]{
            let l=HILabels()
            l.point=HIPoint()
            l.point.xAxis=0
            l.point.yAxis=0
            l.point.x=NSNumber(value: idx)
            l.point.y=100
            l.text=val
            ls.append(l)
        }
        
        let annotations1=HIAnnotations()
        annotations1.labelOptions = HILabelOptions()
        annotations1.labelOptions.backgroundColor = HIColor(name: "rgba(255,255,255,0.5)")
        annotations1.labelOptions.verticalAlign = "top"
        annotations1.labelOptions.y = 15
        annotations1.labels=ls
        
        print("LS is:",ls)
        print("Annotations labels=",annotations1.labels!)

            
        
        options.series = [area]
        options.annotations=[annotations1]
        
        
        //[1607509860000: "Open windows. End of trip.", 1607508660000: "Opened windows.", 1607505300000: "Starting trip. Windows closed but with outside air.", 1607509140000: "Starting again with ventilation off.", 1607506800000: "Opened windows.", 1607507340000: "Ventilation off."]
        
        
        chartView.options = options
        
        self.view.addSubview(chartView)
    }
    
    private func data() -> [Any] {
        let l=GoogleSheetsIntegration.dataset
        let st=firstDate.date.timeIntervalSince1970
        let en=secondDate.date.timeIntervalSince1970
        let st1000=1000*Int(st)
        let en1000=1000*Int(en)+1000*24*60*60
        print("First:",st,";Second:",en)
        var l2:[[Int]] = []
        for record in l {
            let t=record[0]
            if( (t>=st1000) && (t<=en1000)) {
                l2.append(record)
            }
        }
        print("L2 now has",l2.count,"records")
        print(l2)
        return l2
    }
    
    private func annotations() -> [Int:String] {
        let st=firstDate.date.timeIntervalSince1970
        let en=secondDate.date.timeIntervalSince1970
        let st1000=1000*Int(st)
        let en1000=1000*Int(en)+1000*24*60*60
        print("Annotations: First:",st,";Second:",en)
        var c2:[Int:String]=[:]
        for (idx,keyval) in GoogleSheetsIntegration.comments {
            if( (idx>=st1000) && (idx<=en1000) ) {
                c2[idx]=keyval
            }
        }
        print("C2 now has",c2.count,"records")
        print(c2)
        return c2
    }
    
    private func data1() -> [Any] {
        print("THIS SHOULD NOT RUN")
        return([[]])
        //  return[[1607815080000, 409], [1607815140000, 409], [1607815140000, 409], [1607815140000, 409], [1607815260000, 411], [1607815260000, 411], [1607815260000, 411], [1607815260000, 411], [1607815320000, 411], [1607815320000, 411], [1607815320000, 411], [1607815320000, 411], [1607815320000, 411], [1607815440000, 411], [1607815440000, 411], [1607815500000, 411], [1607815500000, 411], [1607815560000, 411], [1607815560000, 411], [1607815560000, 411], [1607815560000, 411], [1607815560000, 411], [1607815560000, 411], [1607815620000, 411], [1607815620000, 411], [1607815860000, 408], [1607815860000, 408], [1607815860000, 408], [1607815920000, 408], [1607815920000, 408], [1607816100000, 408], [1607816160000, 433], [1607816160000, 433], [1607816160000, 433], [1607816160000, 433], [1607816160000, 433], [1607816160000, 433], [1607816160000, 433], [1607816160000, 433], [1607816160000, 433], [1607816160000, 433], [1607816160000, 433], [1607816160000, 433], [1607816160000, 433], [1607816160000, 433], [1607816340000, 433], [1607816460000, 412], [1607816460000, 412]]
    }
    
}


