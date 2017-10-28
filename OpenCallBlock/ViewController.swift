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
import CallKit
import Contacts

private struct Constants {
    static let CallDirectoryExtensionIdentifier = "io.ballinger.OpenCallBlock.CallDirectoryExtension"
}

private struct UIStrings {
    static let ExtensionActive = "Extension Active"
    static let NpaNxxPrefix = "NPA-NXX Prefix"
    static let Whitelist = "Whitelist"
    static let Blocked = "Blocked"
    static let Numbers = "numbers"
}

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
    @IBOutlet weak var extensionActiveLabel: UILabel!
    @IBOutlet weak var blockedLabel: UILabel!
    @IBOutlet weak var whitelistLabel: UILabel!
    
    let numberKit = PhoneNumberKit()
    private let database = DatabaseManager.shared

    /// Check whether or not extension is active
    private func refreshExtensionState() {
        CXCallDirectoryManager.sharedInstance.getEnabledStatusForExtension(withIdentifier: Constants.CallDirectoryExtensionIdentifier) { (status, error) in
            DispatchQueue.main.async {
                if status == .enabled {
                    self.extensionActiveLabel.text = "\(UIStrings.ExtensionActive): ✅"
                } else {
                    self.extensionActiveLabel.text = "\(UIStrings.ExtensionActive): ❌"
                }
            }
        }
    }
    
    /// Refresh UI from User data
    private func refreshUserState(_ user: User?) {
        if let number = user?.me.rawNumber {
            numberField.text = "\(number)"
            refreshNpaNxx(numberString: "\(number)")
        } else {
            numberField.text = ""
        }
        whitelistLabel.text = "\(UIStrings.Whitelist): \(user?.whitelist.count ?? 0) \(UIStrings.Numbers)"
        blockedLabel.text = "\(UIStrings.Blocked): \(user?.blocklist.count ?? 0) \(UIStrings.Numbers)"

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        numberField.delegate = self
        numberField.maxDigits = 10
        numberField.withPrefix = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        refreshExtensionState()
        refreshUserState(database.user)
    }
    
    @IBAction func refreshWhitelist(_ sender: Any) {
        guard var user = database.user else {
            DDLogError("Must create a user first")
            return
        }
        
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (success, error) in
            if let error = error {
                DDLogError("Contacts permission error: \(error)")
                return
            }
            var whitelist: Set<Contact> = []
            do {
                let request = CNContactFetchRequest(keysToFetch: [CNContactPhoneNumbersKey as CNKeyDescriptor])
                try store.enumerateContacts(with: request, usingBlock: { (contact, stop) in
                    for number in contact.phoneNumbers {
                        do {
                            let numberString = number.value.stringValue
                            let phoneNumber = try self.numberKit.parse(numberString, withRegion: "us", ignoreType: true)
                            let contact = Contact(phoneNumber: phoneNumber)
                            whitelist.insert(contact)
                        } catch {
                            DDLogError("Error parsing phone number: \(error)")
                        }
                    }
                })
            } catch {
                DDLogError("Could not enumerate contacts \(error)")
            }
            user.whitelist = whitelist
            user.refreshBlocklist()
            self.database.user = user
            DispatchQueue.main.async {
                self.refreshUserState(user)
            }
        }
    }
    
    @IBAction func numberFieldEditingChanged(_ sender: Any) {
        guard let numberString = numberField.text else {
            return
        }
        refreshNpaNxx(numberString: numberString, shouldSave: true)
    }
    
    /// Refreshes NPA-NXX field, optionally saving User data
    func refreshNpaNxx(numberString: String, shouldSave: Bool = false) {
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
        prefixLabel.text = "\(UIStrings.NpaNxxPrefix): \(npaNxx)"
        
        if shouldSave {
            var user = database.user
            user?.me = Contact(phoneNumber: number)
            if user == nil {
                user = User(phoneNumber: number)
            }
            // TODO: move this
            user?.refreshBlocklist()
            if let user = user {
                database.user = user
            }
            refreshUserState(user)
        }
    }

}


extension ViewController: UITextFieldDelegate {
}
