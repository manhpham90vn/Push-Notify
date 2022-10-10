//
//  Simulator.swift
//  Push Notify
//
//  Created by Manh Pham on 08/10/2022.
//

import Foundation

struct SimulatorPayload: Codable {
    var bundle: String
    var aps: APS
    
    private enum CodingKeys : String, CodingKey {
        case bundle = "Simulator Target Bundle"
        case aps
    }
}
