//
//  InterfaceController.swift
//  watchTracker Extension
//
//  Created by Mark Presley on 10/13/17.
//  Copyright © 2017 Mark Presley. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    
    @IBOutlet var nameLabel: WKInterfaceLabel!
    @IBOutlet var photoImageView: WKInterfaceImage!
    @IBOutlet var locationRegionLabel: WKInterfaceLabel!
    @IBOutlet var locationDirectionImageView: WKInterfaceImage!
    @IBOutlet var locationDistanceLabel: WKInterfaceLabel!
    @IBOutlet var spinnerImageGroup: WKInterfaceGroup!
    
    var justAwoke = false
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)        
        // Configure interface objects here.
        justAwoke = true
        updateModel()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if dataUpdatedRecently() || justAwoke {
            updateUI()
            if justAwoke { justAwoke = false }
        } else {
            updateModel()
        }
    }

    func updateUI() {
        
        guard let contact = (WKExtension.shared().delegate as? ExtensionDelegate)?.selectedContact else {
            return
        }
        
        nameLabel.setText(contact.name)
        photoImageView.setImage(contact.photo)
        locationRegionLabel.setText(contact.location?.region ?? "")
        if let distance = contact.location?.distance {
            locationDistanceLabel.setText("\(String(distance)) leagues")
        } else {
            locationDistanceLabel.setText("")
        }
        
        if let direction = contact.location?.direction {
            switch direction {
            case .East:
                locationDirectionImageView.setImage(#imageLiteral(resourceName: "CompassEast"))
            case .North:
                locationDirectionImageView.setImage(#imageLiteral(resourceName: "CompassNorth"))
            case .South:
                locationDirectionImageView.setImage(#imageLiteral(resourceName: "CompassSouth"))
            case .West:
                locationDirectionImageView.setImage(#imageLiteral(resourceName: "CompassWest"))
            }
        } else {
            locationDirectionImageView.setImage(nil)
        }
    }
    
    func updateModel() {
        if WKExtension.shared().applicationState == .active {
            startSpinner()
            (WKExtension.shared().delegate as? ExtensionDelegate)?.getContactLocation {
                self.stopSpinner()
                // Model update calls updateUI(), so I don't need to do it here
            }
        }
    }
    
    func dataUpdatedRecently() -> Bool {
        return false // can implement caching of some sort if desired
    }
    
    private func startSpinner() {
        spinnerImageGroup.setHidden(false)
        spinnerImageGroup.setBackgroundImageNamed("spinner")
        spinnerImageGroup.startAnimatingWithImages(in: NSMakeRange(1,42), duration: 1.5, repeatCount: 0)
    }
    
    private func stopSpinner() {
        self.spinnerImageGroup.stopAnimating()
        self.spinnerImageGroup.setHidden(true)
    }
}
