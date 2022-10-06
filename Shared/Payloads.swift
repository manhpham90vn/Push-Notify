//
//  Payloads.swift
//  Push Notify
//
//  Created by Manh Pham on 05/10/2022.
//

import Foundation

struct Payload: Codable {
    var aps: APN
}

struct APN: Codable {
    var badge: Int
    var alert: Alert
}

struct Alert: Codable {
    var title: String
    var subtitle: String
    var body: String
}
