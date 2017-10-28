//
//  CallDirectoryHandler.swift
//  CallDirectoryExtension
//
//  Created by Chris Ballinger on 10/27/17.
//  Copyright © 2017 Chris Ballinger. All rights reserved.
//

import Foundation
import CallKit
import CallDataKit
import CocoaLumberjackSwift

class CallDirectoryHandler: CXCallDirectoryProvider {
    
    private let database = DatabaseManager.shared
    
    deinit {
        DDLog.remove(DDTTYLogger.sharedInstance)
    }
    
    override init() {
        DDLog.add(DDTTYLogger.sharedInstance)
    }
    
    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        context.delegate = self
        
        guard let user = database.user else {
            DDLogWarn("CallDirectoryHandler: No user configured")
            context.completeRequest()
            return
        }

        // Check whether this is an "incremental" data request. If so, only provide the set of phone number blocking
        // and identification entries which have been added or removed since the last time this extension's data was loaded.
        // But the extension must still be prepared to provide the full set of data at any time, so add all blocking
        // and identification phone numbers if the request is not incremental.
        if #available(iOSApplicationExtension 11.0, *) {
            if context.isIncremental {
                context.removeAllBlockingEntries()
                context.removeAllIdentificationEntries()
            }
        }
        for blockedContact in user.blocklist {
            let number = blockedContact.rawNumber
            context.addBlockingEntry(withNextSequentialPhoneNumber: number)
            context.addIdentificationEntry(withNextSequentialPhoneNumber: number, label: "🚫 NPA-NXX Spam")
        }
        
        DDLogInfo("Blocked \(user.blocklist.count) numbers")

        context.completeRequest()
    }

}

extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {

    func requestFailed(for extensionContext: CXCallDirectoryExtensionContext, withError error: Error) {
        DDLogError("CallDirectoryHandler error: \(error)")
        // An error occurred while adding blocking or identification entries, check the NSError for details.
        // For Call Directory error codes, see the CXErrorCodeCallDirectoryManagerError enum in <CallKit/CXError.h>.
        //
        // This may be used to store the error details in a location accessible by the extension's containing app, so that the
        // app may be notified about errors which occured while loading data even if the request to load data was initiated by
        // the user in Settings instead of via the app itself.
    }

}
