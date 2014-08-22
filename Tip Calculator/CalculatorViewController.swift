//
//  ViewController.swift
//  Tip Calculator
//
//  Created by Vanessa Li on 8/15/14.
//  Copyright (c) 2014 Vanessa Li. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var billField: UITextField!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var tipControl: UISegmentedControl!
    
    let currencyCodeArray = ["USD", "EUR", "GBP", "JPY"]
    let localeArray = ["en_US", "fr_FR", "de_DE", "fr_CH"]
    
    var currentCurrencyIdx:Int = 0
    var currentLocaleIdx:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        updateCalculatorValues()
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        saveData()
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        saveData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didTap(sender: AnyObject) {
        view.endEditing(true)
    }
    
    @IBAction func onEditingChanged(sender: AnyObject) {
        updateCalculatorValues()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        var defaults = NSUserDefaults.standardUserDefaults()
        
        loadData()
        updateCalculatorValues()
    }
    
    func loadData() {
        var defaults = NSUserDefaults.standardUserDefaults()
        
        let defaultTip:Int? = defaults.integerForKey("default_tip")
        let defaultInc:Int? = defaults.integerForKey("increment_value")
        
        let tip = defaultTip!
        let inc = defaultInc!
        
        if tip != nil && tip > 0 && inc != nil && inc > 0 {
            setTipPercentages(default_tip: tip, inc_val: inc)
        }
        else {
            setTipPercentages()
        }
        
        let lastLoadTime:NSDate? = defaults.objectForKey("last_load_time") as?NSDate
        let now = NSDate()
        
        billField.text = ""
        
        // Load last bill value if the time elapsed since the calculator was last
        // opened is less than 10 minutes (600 seconds)
        if lastLoadTime != nil && now.timeIntervalSinceDate(lastLoadTime!) < 600 {
            let lastInputValue:Double? = defaults.doubleForKey("last_input_value")
            if let billVal = lastInputValue {
                if billVal != 0 {
                    billField.text = "\(billVal.format())"
                }
            }
        }
        
        let currency_index:Int? = defaults.integerForKey("currency_code")
        let locale_index:Int? = defaults.integerForKey("locale_code")
        
        if let cIdx = currency_index {
            currentCurrencyIdx = cIdx
        }
        if let lIdx = locale_index {
            currentLocaleIdx = lIdx
        }
    }
    
    func saveData() {
        var defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(NSDate(), forKey: "last_load_time")
        defaults.setDouble((billField.text as NSString).doubleValue, forKey: "last_input_value")
        
        defaults.synchronize()
    }
    
    func updateCalculatorValues() {
        var currencyCode = currencyCodeArray[currentCurrencyIdx]
        var localeCode = localeArray[currentLocaleIdx]
        
        var tipPercentages = getTipPercentages()
        var selectedTip = tipPercentages[tipControl.selectedSegmentIndex]
        
        var billAmt = (billField.text as NSString).doubleValue
        var tip = billAmt * selectedTip
        var total = billAmt + tip
        
        tipLabel.text = "\(tip.format(currencyCode: currencyCode, locale: localeCode))"
        totalLabel.text = "\(total.format(currencyCode: currencyCode, locale: localeCode))"
    }
    
    func setTipPercentages(default_tip: Int = 18, inc_val: Int = 3) {
        // Set the default tip from user settings as central value in
        // segmented control and determine the outer tip values. 
        // Don't allow the value to go below 0.
        var tip_val = default_tip - inc_val
        if tip_val < 0 {
            tip_val = 0
        }
        
        for idx in 0...2 {
            tipControl.setTitle("\(tip_val)%", forSegmentAtIndex:idx)
            tip_val += inc_val
        }
        
        // Reset segment control to central (default) value
        tipControl.selectedSegmentIndex = 1
    }
    
    func getTipPercentages() -> Array<Double> {
        var tip_values = [Double](count: 3, repeatedValue: 0.0)
        
        for idx in 0...2 {
            var int_val = tipControl.titleForSegmentAtIndex(idx)
            tip_values[idx] = (int_val as NSString).doubleValue / 100
        }
        return tip_values
    }
}

extension Double {
    func format(f: String = ".2", currencyCode: String = "", locale: String = "en_US") -> String {
        let number = NSNumber(double: self)
        var numberFormatter = NSNumberFormatter()
        
        if currencyCode != "" {
            numberFormatter.numberStyle = .CurrencyStyle
            numberFormatter.locale = NSLocale(localeIdentifier: locale)
            numberFormatter.currencyCode = currencyCode
            return numberFormatter.stringFromNumber(number)
        }
        return NSString(format: "%\(f)f", self)
    }
}
