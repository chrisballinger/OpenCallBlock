//
//  YapObject.swift
//  CallDataKit
//
//  Created by Chris Ballinger on 9/21/17.
//  Copyright © 2017 Chris Ballinger. All rights reserved.
//

import Foundation
import YapDatabase

public protocol YapStorable {
    var yapKey: String { get }
    var yapCollection: String { get }
    /// Default collection for objects of this type
    static var yapDefaultCollection: String { get }
}

public protocol YapObjectFetching: YapStorable {
    func refetch(_ transaction: YapDatabaseReadTransaction) -> Self?
    func refetch<T: YapObjectProtocol>(_ transaction: YapDatabaseReadTransaction, ofType: T.Type) -> T?
    /// Fetches from default collection `yapDefaultCollection`
    static func fetch(_ transaction: YapDatabaseReadTransaction, yapKey: String) -> Self?
    static func fetch(_ transaction: YapDatabaseReadTransaction, yapKey: String, yapCollection: String) -> Self?
    static func fetch<T: YapObjectProtocol>(_ transaction: YapDatabaseReadTransaction, yapKey: String, yapCollection: String, ofType: T.Type) -> T?
    func exists(_ transaction: YapDatabaseReadTransaction) -> Bool
}

public extension YapObjectProtocol {
    
    func exists(_ transaction: YapDatabaseReadTransaction) -> Bool {
        return transaction.hasObject(forKey: yapKey, inCollection: yapCollection)
    }
    
    public static func fetch<T: YapObjectProtocol>(_ transaction: YapDatabaseReadTransaction, yapKey: String, yapCollection: String, ofType: T.Type) -> T? {
        let object = transaction.object(forKey: yapKey, inCollection: yapCollection) as? T
        return object
    }
    
    public func refetch<T: YapObjectProtocol>(_ transaction: YapDatabaseReadTransaction, ofType: T.Type) -> T?
 {
        let object: T? = ofType.fetch(transaction, yapKey: yapKey, yapCollection: yapCollection)
        return object
    }
}

public protocol YapObjectSaving {
    func touch(_ transaction: YapDatabaseReadWriteTransaction)
    func save(_ transaction: YapDatabaseReadWriteTransaction, metadata: Any?)
    func upsert(_ transaction: YapDatabaseReadWriteTransaction, metadata: Any?)
    func replace(_ transaction: YapDatabaseReadWriteTransaction)
    func remove(_ transaction: YapDatabaseReadWriteTransaction)
}

public protocol YapObjectProtocol: YapObjectSaving, YapObjectFetching { }

public extension YapObjectProtocol {
    public func touch(_ transaction: YapDatabaseReadWriteTransaction) {
        transaction.touchObject(forKey: yapKey, inCollection: yapCollection)
    }
    
    public func save(_ transaction: YapDatabaseReadWriteTransaction, metadata: Any?) {
        transaction.setObject(self, forKey: yapKey, inCollection: yapCollection, withMetadata: metadata)
    }
    
    public func upsert(_ transaction: YapDatabaseReadWriteTransaction, metadata: Any?) {
        if exists(transaction) && metadata == nil {
            replace(transaction)
        } else {
            save(transaction, metadata: metadata)
        }
    }
    
    public func replace(_ transaction: YapDatabaseReadWriteTransaction) {
        transaction.replace(self, forKey: yapKey, inCollection: yapCollection)
    }
    
    public func remove(_ transaction: YapDatabaseReadWriteTransaction) {
        transaction.removeObject(forKey: yapKey, inCollection: yapCollection)
    }
}

public class YapObject: YapObjectProtocol {
    open var yapKey: String
    
    public init(yapKey: String) {
        self.yapKey = yapKey
    }
}

extension YapObject: YapObjectFetching {
    /// Fetches from class's default collection `defaultYapCollection`
    public static func fetch(_ transaction: YapDatabaseReadTransaction, yapKey: String) -> Self? {
        let object = fetch(transaction, yapKey: yapKey, yapCollection: yapDefaultCollection)
        return object
    }
    
    public static func fetch(_ transaction: YapDatabaseReadTransaction, yapKey: String, yapCollection: String) -> Self? {
        let object = YapObject.fetch(transaction, yapKey: yapKey, yapCollection: yapCollection, ofType: self)
        return object
    }
    
    public func refetch(_ transaction: YapDatabaseReadTransaction) -> Self? {
        let object = refetch(transaction, ofType: type(of: self))
        return object
    }
}

extension YapObject: YapStorable {
    
    open var yapCollection: String {
        return type(of: self).yapDefaultCollection
    }
    
    public static var yapDefaultCollection: String {
        return "\(self)"
    }
}


