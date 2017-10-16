//
//  WatchConnectivityManager.swift
//  findFriendsGOT
//
//  Created by Mark Presley on 10/13/17.
//  Copyright © 2017 Mark Presley. All rights reserved.
//

import Foundation
import WatchConnectivity

class WatchConnectivityManager: NSObject, WCSessionDelegate {
    
    static let sharedInstance = WatchConnectivityManager()
    
    private var session: WCSession? {
        didSet {
            if let session = session {
                session.delegate = self
                session.activate()
            }
        }
    }
    
    private override init() {
        super.init()
        if WCSession.isSupported() {
            setSession()
        }
    }
    
    private func setSession() {
        self.session = WCSession.default
    }
    
    var selectedContact: Contact? {
        didSet {
            if let selectedContact = selectedContact {
                sendImmediateMessageToWatch(withData: ["selectedContact": selectedContact.name])
            }
        }
    }
    
    // MARK: - Watch Connectivity
    
    func sessionWatchStateDidChange(_ session: WCSession) {
        print("Watch state changed. isPaired: \(session.isPaired), isWatchAppInstalled: \(session.isWatchAppInstalled), isComplicationEnabled: \(session.isComplicationEnabled)")
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("Watch reachability changed. isReachable: \(session.isReachable)")
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated && session.isPaired && session.isWatchAppInstalled {
            if let selectedContact = selectedContact {
                sendImmediateMessageToWatch(withData: ["selectedContact": selectedContact.name])
            }
        }
    }
    
    // MARK: - Watch Communication
    
    private func sendImmediateMessageToWatch(withData data: [String: Any]) {
        
        guard session?.activationState ?? .notActivated == .activated else {
            return
        }
        
        guard session?.isReachable ?? false else {
            sendLazyReplaceableMessageToWatch(withData: data)
            return
        }
        
        print("Sending immediate message to watch: \(data), not requesting response")
        
        session?.sendMessage(data, replyHandler: nil, errorHandler: { error in
            print("Failed to send direct message \(data) from phone to watch. The paired device might be unreachable. Error: \(error.localizedDescription)")
            self.sendLazyReplaceableMessageToWatch(withData: data)
        })
    }
    
    private func sendLazyReplaceableMessageToWatch(withData data: [String: Any]) {
        
        guard session?.activationState ?? .notActivated == .activated else {
            return
        }
        
        print("Sending lazy replaceable message to watch: \(data)")
        
        do {
            try session?.updateApplicationContext(data)
            print("Phone sent lazy replaceable message to watch: \(data)")
        } catch {
            print("Failed to update data on watch with context \(data).")
        }
    }
    
    // MARK: - Pairing for multiple watches support
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        //TODO
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        //TODO
    }
}
