//
//  Contact.swift
//  CallDataKit
//
//  Created by Chris Ballinger on 10/27/17.
//  Copyright © 2017 Chris Ballinger. All rights reserved.
//

import Foundation
import CallKit

public struct Contact: Codable {
    /// Phone number
    public var number: CXCallDirectoryPhoneNumber
    
    public init(number: CXCallDirectoryPhoneNumber) {
        self.number = number
    }
}
