//
//  ExtensionDelegate.swift
//  watchTracker Extension
//
//  Created by Mark Presley on 10/13/17.
//  Copyright © 2017 Mark Presley. All rights reserved.
//

import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate, URLSessionDownloadDelegate {
    
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
        setSession()
    }
    
    private func setSession() {
        self.session = WCSession.default
    }
    
    // MARK: - Application Lifecycle

    func applicationDidFinishLaunching() {
        scheduleExtensionBackgroundRefresh()
        
        if UserDefaults.standard.value(forKey: "JsonFileNumber") as? Int == nil {
            UserDefaults.standard.set(0, forKey: "JsonFileNumber")
            UserDefaults.standard.synchronize()
        }
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }
    
    // MARK: - iPhone Connectivity
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Watch activation completed")
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("iOS app reachability changed. isReachable: \(session.isReachable)")
    }
    
    // MARK: - iPhone Communication
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        print("Watch received message data from phone: \(message), not requesting response")
        handleIncomingPhoneData(withData: message)
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        print("Watch received application context data from phone: \(applicationContext)")
        handleIncomingPhoneData(withData: applicationContext)
    }
    
    func handleIncomingPhoneData(withData message: [String: Any]) {
        if let contactName = message["selectedContact"] as? String, let _ = KnownContactNames(rawValue: contactName)  {
            UserDefaults.standard.set(contactName, forKey: "SelectedContactName")
            UserDefaults.standard.synchronize()
            getContactLocation() {}
        }
    }
    
    // MARK: - Background Processing
    
    func scheduleExtensionBackgroundRefresh() {
        if let preferredDate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) {
            WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: preferredDate, userInfo: nil) { error in
                if error == nil {
                    print("The background refresh process was successfully scheduled for \(preferredDate).")
                }
            }
        }
    }

    var pendingUrlSessionRefreshTasksBySession = [URLSession: WKRefreshBackgroundTask]()
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                
                getContactLocation() {
                    self.scheduleExtensionBackgroundRefresh()
                    backgroundTask.setTaskCompletedWithSnapshot(false)
                }
                
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
          
                updateWatchAppUI()
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
                
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                
                let backgroundConfigObject = URLSessionConfiguration.background(withIdentifier: urlSessionTask.sessionIdentifier)
                let session = URLSession(configuration: backgroundConfigObject, delegate: self, delegateQueue: nil)
                pendingUrlSessionRefreshTasksBySession[session] = urlSessionTask
                
            default:
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }
    
    // MARK: - Data Fetch
    
    var selectedContact: Contact? {
        guard let selectedContactName = UserDefaults.standard.value(forKey: "SelectedContactName") as? String else {
            return nil
        }
        let contact = Contact(name: selectedContactName)
        if let directionString = UserDefaults.standard.value(forKey: "CurrentContactDirection") as? String,
            let direction = Direction(rawValue: directionString),
            let distance = UserDefaults.standard.value(forKey: "CurrentContactDistance") as? Int,
            let region = UserDefaults.standard.value(forKey: "CurrentContactRegion") as? String {
            contact.location = Location(direction: direction, distance: distance, region: region)
        }
        return contact
    }
    var fileNum = 0 {
        didSet {
            UserDefaults.standard.set(fileNum, forKey: "JsonFileNumber")
            UserDefaults.standard.synchronize()
        }
    }
    
    func getContactLocation(completion: @escaping () -> Void) {
        
        // To simulate dynamic server response, just cycle through /distances1.json through /distances9.json static text files
        var fileNum = UserDefaults.standard.value(forKey: "JsonFileNumber") as? Int ?? self.fileNum
        if fileNum < 9 {
            fileNum += 1
        } else {
            fileNum = 1
        }
        self.fileNum = fileNum
        
        let serviceUrl = "\(Constants.LocationServiceURL)distances_\(fileNum).json"
        print("\(serviceUrl) (\(WKExtension.shared().applicationState == .background ? "background" : WKExtension.shared().applicationState == .active ? "active" : "inactive"))")
        
        if WKExtension.shared().applicationState == .background {
            let uniqueString = UUID().uuidString
            print("Setting up background request with id \(uniqueString)")
            let sessionConfig = URLSessionConfiguration.background(withIdentifier: uniqueString)
            let session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
            let _ = session.downloadTask(with: URLRequest(url: URL(string: serviceUrl)!)).resume()
            completion()
        } else {
            let sessionConfig = URLSessionConfiguration.ephemeral
            let session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: OperationQueue.main)
            let _ = session.dataTask(with: URLRequest(url: URL(string: serviceUrl)!)) { responseData, responseCode, error in
            
                guard error == nil,
                      let responseCode = responseCode as? HTTPURLResponse, responseCode.statusCode == 200,
                      let responseData = responseData, !responseData.isEmpty else {
                    print("Error occurred during network request.")
                    completion()
                    return
                }
                
                self.parseLocationData(data: responseData)
                completion()
                
            }.resume()
        }
    }
    
    func parseLocationData(data: Data) {
        
        guard let selectedContact = selectedContact else {
            return
        }
        
        if let contactLocations = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [[String: AnyObject]],
            let matchingContactLocation = contactLocations?.filter( { $0["contactName"] as? String == selectedContact.name } ).first,
            let locationDistance = matchingContactLocation["distance"] as? Int,
            let locationDirection = matchingContactLocation["direction"] as? String,
            let locationRegion = matchingContactLocation["region"] as? String {
            
            UserDefaults.standard.set(locationDirection, forKey: "CurrentContactDirection")
            UserDefaults.standard.set(locationDistance, forKey: "CurrentContactDistance")
            UserDefaults.standard.set(locationRegion, forKey: "CurrentContactRegion")
            UserDefaults.standard.synchronize()
            
            updateComplicationTimeline()
            updateWatchAppUI()
            scheduleExtensionBackgroundRefresh()
            WKInterfaceDevice.current().play(.success)
        }
    }
    
    // MARK: UI Updates
    
    func updateWatchAppUI() {
        (WKExtension.shared().visibleInterfaceController as? InterfaceController)?.updateUI()
    }
    
    func updateComplicationTimeline() {
        let complicationServer = CLKComplicationServer.sharedInstance()
        complicationServer.activeComplications?.forEach { complicationServer.reloadTimeline(for: $0) }
    }
    
    // MARK: Networking For Background Network Requests (URLSessionDownloadDelegate)

    var responseData: Data?
    var responseStatusCode: Int?
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        responseData = try? Data(contentsOf: location)
        responseStatusCode = (downloadTask.response as? HTTPURLResponse)?.statusCode
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        guard let code = responseStatusCode, code == 200,
              let responseData = responseData, !responseData.isEmpty else {
            WKInterfaceDevice.current().play(.failure)
            return
        }
        
        parseLocationData(data: responseData)
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            self.pendingUrlSessionRefreshTasksBySession.removeValue(forKey: session)?.setTaskCompletedWithSnapshot(false)
        }
        session.finishTasksAndInvalidate()
    }
}
