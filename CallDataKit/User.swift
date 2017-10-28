//
//  User.swift
//  CallDataKit
//
//  Created by Chris Ballinger on 10/27/17.
//  Copyright © 2017 Chris Ballinger. All rights reserved.
//

import Foundation
import CallKit
import PhoneNumberKit

public struct User: Codable {
    
    // MARK: Properties
    
    /// Phone number of user
    public var me: Contact
    public var blocklist: Set<Contact> = []
    public var whitelist: Set<Contact> = []
    
    // MARK: Init
    
    public init(phoneNumber: PhoneNumber) {
        self.me = Contact(phoneNumber: phoneNumber)
    }
    
    public init(rawNumber: CXCallDirectoryPhoneNumber) {
        self.me = Contact(rawNumber: rawNumber)
    }
    
    public init(me: Contact) {
        self.me = me
    }
    
    // MARK: Refresh
    
    /**
     * Refreshes NPA-NXX block list for your number, minus whitelist
     */
    public mutating func refreshBlocklist() {
        var blocklist: Set<Contact> = []
        let startNumber = (me.rawNumber / 10_000) * 10_000
        
        for i in 0..<10_000 {
            let rawNumber = startNumber + CXCallDirectoryPhoneNumber(i)
            let contact = Contact(rawNumber: rawNumber)
            blocklist.insert(contact)
        }
        
        blocklist.remove(me)
        blocklist.subtract(whitelist)
        self.blocklist = blocklist
    }
}
