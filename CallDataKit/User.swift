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

extension Contact {
    /// Ordered insertion of contacts
    static func insert(_ contacts: [Contact], into: [Contact]) -> [Contact] {
        let set = Set(into)
        let out = set.union(contacts).sorted()
        return out
    }
    
    /// Ordered removal of contacts
    static func remove(_ contacts: [Contact], from: [Contact]) -> [Contact] {
        let set = Set(from)
        let out = set.subtracting(contacts).sorted()
        return out
    }
}

public struct User: Codable {
    
    // MARK: Properties
    
    /// Phone number of user
    public var me: Contact
    /// Ordered block list of phone numbers. Do not edit these directly, use mutating functions below.
    public var blocklist: [Contact] {
        get {
            return _blocklist.toContacts()
        }
        set {
            _blocklist = newValue.toRawNumbers()
        }
    }
    /// Ordered white list of phone numbers. Do not edit these directly, use mutating functions below.
    public var whitelist: [Contact] {
        get {
            return _whitelist.toContacts()
        }
        set {
            _whitelist = newValue.toRawNumbers()
        }
    }

    private var _blocklist: [CXCallDirectoryPhoneNumber] = []
    private var _whitelist: [CXCallDirectoryPhoneNumber] = []
    
    /// Extra blocking of NPA-NX* (e.g. 555-55X-XXXX)
    public var extraBlocking: Bool? = false
    
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
    
    // MARK: Blocklist Generation
    
    /**
     * Returns the full blocklist without subtracting any whitelist
     */
    public func fullBlocklist() -> Set<Contact> {
        var blocklist: Set<Contact> = []
        // If regular NPA-NXX we want to block 555-555-XXX
        // but with "extra blocking" we want to block 555-55X-XXXX
        var maxBlockedNumbers: Int64 = 10_000
        if extraBlocking ?? false {
            maxBlockedNumbers = 100_000
        }
        let startNumber = (me.rawNumber / maxBlockedNumbers) * maxBlockedNumbers
        
        for i in 0..<maxBlockedNumbers {
            let rawNumber = startNumber + CXCallDirectoryPhoneNumber(i)
            let contact = Contact(rawNumber: rawNumber)
            blocklist.insert(contact)
        }
        return blocklist
    }
    
    // MARK: Editing
    
    public mutating func addToWhitelist(_ contact: Contact) {
        addToWhitelist([contact])
    }
    
    public mutating func addToWhitelist(_ contacts: [Contact]) {
        self.whitelist = Contact.insert(contacts, into: whitelist)
        self.blocklist = Contact.remove(contacts, from: self.blocklist)
    }
    
    public mutating func removeFromWhitelist(_ contact: Contact) {
        removeFromWhitelist([contact])
    }
    
    public mutating func removeFromWhitelist(_ contacts: [Contact]) {
        self.whitelist = Contact.remove(contacts, from: whitelist)
    }
    
    public mutating func addToBlocklist(_ contact: Contact) {
        addToBlocklist([contact])
    }
    
    public mutating func addToBlocklist(_ contacts: [Contact]) {
        self.blocklist = Contact.insert(contacts, into: blocklist)
        self.whitelist = Contact.remove(contacts, from: self.whitelist)
    }
    
    public mutating func removeFromBlocklist(_ contact: Contact) {
        removeFromBlocklist([contact])
    }
    
    public mutating func removeFromBlocklist(_ contacts: [Contact]) {
        self.blocklist = Contact.remove(contacts, from: blocklist)
    }
    
    /**
     * Refreshes NPA-NXX block list for your number, minus whitelist
     */
    public mutating func refreshBlocklist() {
        var blocklist = self.fullBlocklist()
        blocklist.remove(me)
        blocklist.subtract(whitelist)
        self.blocklist = blocklist.sorted()
    }
}
