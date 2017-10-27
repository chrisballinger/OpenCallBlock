//
//  ViewController.swift
//  OpenCallBlock
//
//  Created by Chris Ballinger on 10/27/17.
//  Copyright © 2017 Chris Ballinger. All rights reserved.
//

import UIKit
import CallDataKit
import PhoneNumberKit
import CocoaLumberjackSwift

extension PhoneNumber {
    /// Returns NPA-NXX prefix of US number e.g. 800-555-5555 returns 800-555
    var npaNxx: UInt64? {
        guard countryCode == 1 else { return nil }
        return nationalNumber/10_000
    }
    var npaNxxString: String? {
        guard let npaNxx = self.npaNxx else { return nil }
        return "\(npaNxx / 1000)-\(npaNxx % 1000)"
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var numberField: PhoneNumberTextField!
    @IBOutlet weak var prefixLabel: UILabel!

    let numberKit = PhoneNumberKit()
    let user = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        numberField.delegate = self
        numberField.maxDigits = 10
        numberField.withPrefix = false
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func numberFieldEditingChanged(_ sender: Any) {
        guard let numberString = numberField.text else {
            return
        }
        //DDLogVerbose("Number changed \(numberString)")
        
        var _number: PhoneNumber? = nil
        do {
            _number = try numberKit.parse(numberString, withRegion: "us", ignoreType: true)
        } catch {
            //DDLogWarn("Bad number \(error)")
        }
        guard let number = _number,
        let npaNxx = number.npaNxxString else { return }
        
        // valid number found
        numberField.resignFirstResponder()
        prefixLabel.text = "NPA-NXX Prefix: \(npaNxx)"
    }
    
}

extension ViewController: UITextFieldDelegate {
}
