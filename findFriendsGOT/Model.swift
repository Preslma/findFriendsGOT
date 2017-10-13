//
//  Model.swift
//  findFriendsGOT
//
//  Created by Mark Presley on 10/13/17.
//  Copyright © 2017 Mark Presley. All rights reserved.
//

import Foundation
import UIKit

struct Contact {
    var name: String {
        didSet {
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
    }
    var description: String?
    var photo: UIImage?
    var location: Location?
    
    init(name: String, description: String?) {
        self.name = name
        self.description = description
    }
    
    init(name: String) {
        self.name = name
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
