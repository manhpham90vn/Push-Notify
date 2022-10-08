//
//  Simulator.swift
//  Push Notify
//
//  Created by Manh Pham on 08/10/2022.
//

import Foundation

struct Simulator: Codable {
    var bundle: String
    var aps: APN
    
    private enum CodingKeys : String, CodingKey {
        case bundle = "Simulator Target Bundle"
        case aps
    }
}
