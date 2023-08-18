//
//  ViewController.swift
//  OpenImageSampleSwift
//
//  Created by FLIR on 2020-08-17.
//  Copyright © 2020 FLIR Systems AB. All rights reserved.
//

import UIKit
import ThermalSDK

class ViewController: UIViewController {

    @IBOutlet weak var msxImageView: UIImageView!
    @IBOutlet weak var irImageView: UIImageView!
    @IBOutlet weak var visualImageView: UIImageView!

    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var maxLabel: UILabel!
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var spotLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var minTempSlider: UISlider!
    @IBOutlet weak var maxTempSlider: UISlider!
    @IBOutlet weak var minTempMinusButton: UIButton!
    @IBOutlet weak var minTempPlusButton: UIButton!
    @IBOutlet weak var maxTempMinusButton: UIButton!
    @IBOutlet weak var maxTempPlusButton: UIButton!

    var thermalImage:FLIRThermalImageFile = FLIRThermalImageFile();
    
    @IBAction func minTempSlider_ValueChanged(sender: UISlider) {
        if let scale = thermalImage.getScale() {
            let flirThermalValue = FLIRThermalValue(value: Double(sender.value), andUnit: TemperatureUnit.CELSIUS);
            if (flirThermalValue != nil) {
                scale.setRangeMin(flirThermalValue!);
                refreshScale();
                refreshImages();
            }
        }
    }

    @IBAction func maxTempSlider_ValueChanged(sender: UISlider) {
        if let scale = thermalImage.getScale() {
            let flirThermalValue = FLIRThermalValue(value: Double(sender.value), andUnit: TemperatureUnit.CELSIUS);
            if (flirThermalValue != nil) {
                scale.setRangeMax(flirThermalValue!);
                refreshScale();
                refreshImages();
            }
        }
    }

    @IBAction func button_TouchUpInside(sender: UIButton) {
        if let scale = thermalImage.getScale() {
            if (sender.titleLabel?.text == "Min-") {
                scale.setRangeMin(FLIRThermalValue(value: Double(scale.getRangeMin().asCelsius().value - 1), andUnit: TemperatureUnit.CELSIUS));
            } else if (sender.titleLabel?.text == "Min+") {
                scale.setRangeMin(FLIRThermalValue(value: Double(scale.getRangeMin().asCelsius().value + 1), andUnit: TemperatureUnit.CELSIUS));
            } else if (sender.titleLabel?.text == "Max-") {
                scale.setRangeMax(FLIRThermalValue(value: Double(scale.getRangeMax().asCelsius().value - 1), andUnit: TemperatureUnit.CELSIUS));
            } else if (sender.titleLabel?.text == "Max+") {
                scale.setRangeMax(FLIRThermalValue(value: Double(scale.getRangeMax().asCelsius().value + 1), andUnit: TemperatureUnit.CELSIUS));
            }
            refreshScale();
            refreshImages();
        }
    }

    fileprivate func refreshScale() {
        if let scale = thermalImage.getScale() {
            minTempLabel.text = "\(scale.getRangeMin().asCelsius().value)";
            maxTempLabel.text = "\(scale.getRangeMax().asCelsius().value)";
            let minTemp = Float(scale.getRangeMin().asCelsius().value);
            minTempSlider.value = minTemp;
            let maxTemp = Float(scale.getRangeMax().asCelsius().value);
            maxTempSlider.value = maxTemp;
        }
    }
    
    fileprivate func refreshImages() {
        if let fusion = thermalImage.getFusion() {
            fusion.setFusionMode(FUSION_MSX_MODE)
            msxImageView.image = thermalImage.getImage()
            
            fusion.setFusionMode(IR_MODE)
            irImageView.image = thermalImage.getImage()
            
            fusion.setFusionMode(VISUAL_MODE)
            visualImageView.image = thermalImage.getImage()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let imagePath = Bundle.main.path(forResource: "FLIR05961", ofType: "jpg") else {
            return
        }
        thermalImage.open(imagePath)

        thermalImage.setTemperatureUnit(.CELSIUS)

        refreshImages()

        if let statistics = thermalImage.getStatistics() {
            let min = statistics.getMin()
            minLabel.text = "\(min)"
            let max = statistics.getMax()
            maxLabel.text = "\(max)"
            let average = statistics.getAverage()
            averageLabel.text = "\(average)"
        }
        
        if let spot = thermalImage.measurements?.getAllSpots().first {
            spotLabel.text = "\(spot.getValue())"
        }
        
        refreshScale()
    }
}
