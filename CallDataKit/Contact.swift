//
//  Contact.swift
//  CallDataKit
//
//  Created by Chris Ballinger on 10/27/17.
//  Copyright © 2017 Chris Ballinger. All rights reserved.
//

import Foundation

struct Contact {
    /// Phone number
    var number: UInt
    /// Whether or not to exclude this entry from the blocklist
    var whitelist: Bool
}
