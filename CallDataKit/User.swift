//
//  User.swift
//  CallDataKit
//
//  Created by Chris Ballinger on 10/27/17.
//  Copyright © 2017 Chris Ballinger. All rights reserved.
//

import Foundation
import CallKit

public struct User: Codable {
    /// Phone number of user
    public var phoneNumber: CXCallDirectoryPhoneNumber?
    public var blocklist: [Contact] = []
    public var whitelist: [Contact] = []
    
    public init() {}
}
