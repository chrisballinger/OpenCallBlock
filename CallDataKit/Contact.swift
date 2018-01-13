//
//  Contact.swift
//  CallDataKit
//
//  Created by Chris Ballinger on 10/27/17.
//  Copyright © 2017 Chris Ballinger. All rights reserved.
//

import Foundation
import CallKit
import PhoneNumberKit

extension Collection where Self.Element == Contact, Self.Index == Int {
    public func toRawNumbers() -> [CXCallDirectoryPhoneNumber] {
        var nums: [CXCallDirectoryPhoneNumber] = []
        forEach { (contact) in
            nums.append(contact.rawNumber)
        }
        return nums
    }
}

extension Collection where Self.Element == CXCallDirectoryPhoneNumber, Self.Index == Int {
    public func toContacts() -> [Contact] {
        var contacts: [Contact] = []
        forEach { (number) in
            let contact = Contact(rawNumber: number)
            contacts.append(contact)
        }
        return contacts
    }
}

public struct Contact: Codable, Hashable, Comparable {
    
    /// Raw phone number - Int64
    public var rawNumber: CXCallDirectoryPhoneNumber
    
    public func phoneNumber(_ numberKit: PhoneNumberKit) -> PhoneNumber? {
        let numberString = "\(rawNumber)"
        guard let number = try? numberKit.parse(numberString, withRegion: "us", ignoreType: true) else {
            return nil
        }
        return number
    }
    
    public init(rawNumber: CXCallDirectoryPhoneNumber) {
        self.rawNumber = rawNumber
    }
    
    public init?(numberString: String) {
        let numberKit = PhoneNumberKit()
        guard let number = try? numberKit.parse(numberString, withRegion: "us", ignoreType: true) else {
            return nil
        }
        self.init(phoneNumber: number)
    }
    
    public init(phoneNumber: PhoneNumber) {
        let rawNumber = phoneNumber.countryCode * 10_000_000_000 + phoneNumber.nationalNumber
        self.rawNumber = CXCallDirectoryPhoneNumber(rawNumber)
    }
    
    // MARK: Hashable
    
    public var hashValue: Int {
        return Int(rawNumber)
    }
    
    public static func ==(lhs: Contact, rhs: Contact) -> Bool {
        return lhs.rawNumber == rhs.rawNumber
    }
    
    // MARK: Comparable
    
    public static func <(lhs: Contact, rhs: Contact) -> Bool {
        return lhs.rawNumber < rhs.rawNumber
    }
}
