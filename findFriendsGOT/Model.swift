//
//  Model.swift
//  findFriendsGOT
//
//  Created by Mark Presley on 10/13/17.
//  Copyright © 2017 Mark Presley. All rights reserved.
//

import Foundation
import UIKit

class Contact {
    var name: String
    var shortName: String?
    var description: String?
    var photo: UIImage?
    var location: Location?
    
    init(name: String, description: String?) {
        self.name = name
        self.description = description
        setPhoto()
        setShortName()
    }
    
    func setPhoto() {
        switch name {
        case KnownContactNames.WhiteWalker.rawValue:
            photo = #imageLiteral(resourceName: "White Walker")
        case KnownContactNames.Daenerys.rawValue:
            photo = #imageLiteral(resourceName: "Daenerys")
        case KnownContactNames.Jaime.rawValue:
            photo = #imageLiteral(resourceName: "Jaime")
        case KnownContactNames.JonSnow.rawValue:
            photo = #imageLiteral(resourceName: "John Snow")
        case KnownContactNames.AryaStark.rawValue:
            photo = #imageLiteral(resourceName: "Arya")
        case KnownContactNames.BranStark.rawValue:
            photo = #imageLiteral(resourceName: "Bran")
        default:
            return
        }
    }
    
    func setShortName() {
        switch name {
        case KnownContactNames.WhiteWalker.rawValue:
            shortName = "Wight"
        case KnownContactNames.Daenerys.rawValue:
            shortName = "Daenerys"
        case KnownContactNames.Jaime.rawValue:
            shortName = "Jaime"
        case KnownContactNames.JonSnow.rawValue:
            shortName = "Jon"
        case KnownContactNames.AryaStark.rawValue:
            shortName = "Aryna"
        case KnownContactNames.BranStark.rawValue:
            shortName = "Bran"
        default:
            return
        }
    }
    
    init(name: String) {
        self.name = name
        setPhoto()
        setShortName()
    }
}

struct Location {
    var direction: Direction
    var distance: Int
    var region: String?
}

enum Direction: String {
    case North = "N"
    case South = "S"
    case East = "E"
    case West = "W"
}

enum KnownContactNames: String {
    case WhiteWalker = "White Walker"
    case Daenerys = "Daenerys Targaryen"
    case JonSnow = "Jon Snow"
    case AryaStark = "Arya Stark"
    case BranStark = "Bran Stark"
    case Jaime = "Jaime Lannister"
}
