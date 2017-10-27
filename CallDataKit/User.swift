//
//  User.swift
//  CallDataKit
//
//  Created by Chris Ballinger on 10/27/17.
//  Copyright © 2017 Chris Ballinger. All rights reserved.
//

import Foundation
import CallKit

public class User {
    /// Phone number or NPA-NXX prefix. e.g. "800-555" part of "800-555-5555"
    public var phoneNumber: CXCallDirectoryPhoneNumber?
    
    public init() {
        
    }
}
