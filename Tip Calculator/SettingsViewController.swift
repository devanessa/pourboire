//
//  SettingsViewController.swift
//  Tip Calculator
//
//  Created by Vanessa Li on 8/16/14.
//  Copyright (c) 2014 Vanessa Li. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UIPickerViewDelegate {

    @IBOutlet weak var xButton: UIBarButtonItem!

    @IBOutlet weak var tipStepper: UIStepper!
    @IBOutlet weak var tipAmount: UILabel!
    
    @IBOutlet weak var incrStepper: UIStepper!
    @IBOutlet weak var incrLabel: UILabel!

    @IBOutlet weak var symbolControl: UISegmentedControl!
    
    @IBOutlet weak var formatPicker: UIPickerView!
    
    let formatDisplay = ["$1,000.00", "1 000,00$", "1.000,00$", "$1'000.00"]
    var selectedFormatIdx = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formatPicker.delegate=self
        self.view.addSubview(formatPicker)
        
        loadSettings()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        saveSettings()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView!) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView!, numberOfRowsInComponent component: Int) -> Int {
        return formatDisplay.count
    }
    
    func pickerView(pickerView: UIPickerView!, titleForRow row: Int, forComponent component: Int) -> String {
        return formatDisplay[row]
    }
    
    func pickerView(pickerView: UIPickerView!, didSelectRow row: Int, inComponent component: Int) {
        selectedFormatIdx = row
    }
    
    @IBAction func didPressX(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func stepperChanged(sender: UIStepper) {
        let stepper_value = Int(sender.value)
        if sender == tipStepper {
            tipAmount.text = "\(stepper_value)%"
        } else {
            incrLabel.text = "\(stepper_value)%"
        }
    }
    
    func loadSettings() {
        var defaults = NSUserDefaults.standardUserDefaults()
        
        var default_tip:Int? = defaults.integerForKey("default_tip")
        let tip = default_tip!
        
        if tip != nil && tip > 0 {
            tipAmount.text = "\(tip)%"
            tipStepper.value = Double(tip)
        } else {
            tipAmount.text = "18%"
            tipStepper.value = 18
        }
        
        var inc_val:Int? = defaults.integerForKey("increment_value")
        let incr = inc_val!
        
        if incr != nil && incr > 0 {
            incrLabel.text = "\(incr)%"
            incrStepper.value = Double(incr)
        } else {
            incrLabel.text = "3%"
            incrStepper.value = 3
        }
        
        let symbolIndex:Int? = defaults.integerForKey("currency_code")
        let idx = symbolIndex!
        
        if idx != nil {
            symbolControl.selectedSegmentIndex = idx
        } else {
            symbolControl.selectedSegmentIndex = 0
        }
        
        let localeIdx:Int? = defaults.integerForKey("locale_code")
        let lIdx = localeIdx!
        
        if lIdx != nil {
            formatPicker.selectRow(lIdx, inComponent: 0, animated: false)
            selectedFormatIdx = lIdx
        }
    }
    
    func saveSettings() {
        var defaults = NSUserDefaults.standardUserDefaults()
        
        let default_tip = Int(tipStepper.value)
        defaults.setInteger(default_tip, forKey: "default_tip")
        
        let incr_val = Int(incrStepper.value)
        defaults.setInteger(incr_val, forKey: "increment_value")
        
        let index = symbolControl.selectedSegmentIndex
        defaults.setObject(index, forKey: "currency_code")
        
        defaults.setInteger(selectedFormatIdx, forKey: "locale_code")
        
        defaults.synchronize()
    }
}
