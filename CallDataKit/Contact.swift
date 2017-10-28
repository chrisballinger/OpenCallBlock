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

public struct Contact: Codable, Hashable, Comparable {
    
    /// Raw phone number
    public var rawNumber: CXCallDirectoryPhoneNumber
    
    public init(rawNumber: CXCallDirectoryPhoneNumber) {
        self.rawNumber = rawNumber
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
