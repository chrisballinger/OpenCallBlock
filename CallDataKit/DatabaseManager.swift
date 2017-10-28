//
//  DatabaseManager.swift
//  CallDataKit
//
//  Created by Chris Ballinger on 10/27/17.
//  Copyright © 2017 Chris Ballinger. All rights reserved.
//

import Foundation
import CocoaLumberjackSwift

private struct Constants {
    static let AppGroupName = "group.io.ballinger.OpenCallBlock"
    static let UserKey = "UserKey"
}

public class DatabaseManager {
    public static let shared = DatabaseManager()
    
    private var defaults = UserDefaults(suiteName: Constants.AppGroupName)
    private let encoder = PropertyListEncoder()
    private let decoder = PropertyListDecoder()
    
    /// Fetches or saves User data to shared storage
    public var user: User {
        get {
            var user: User? = nil
            if let userData = defaults?.object(forKey: Constants.UserKey) as? Data {
                user = try? decoder.decode(User.self, from: userData)
            }
            if let user = user {
                return user
            } else {
                return User()
            }
        }
        set {
            do {
                let userData = try encoder.encode(newValue)
                defaults?.set(userData, forKey: Constants.UserKey)
                defaults?.synchronize()
            } catch {
                DDLogError("Could not encode User: \(error)")
            }
        }
    }
}
