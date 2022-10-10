//
//  APNsPayload.swift
//  Push Notify
//
//  Created by Manh Pham on 08/10/2022.
//

import Foundation

struct APNsPayload: Codable {
    var aps: APS
}

struct APS: Codable {
    var badge: Int
    var alert: Alert
}

struct Alert: Codable {
    var title: String
    var subtitle: String
    var body: String
}
