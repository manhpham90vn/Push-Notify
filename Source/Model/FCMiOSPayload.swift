//
//  FCMiOSPayload.swift
//  Push Notify
//
//  Created by Manh Pham on 08/10/2022.
//

import Foundation

struct FCMiOSPayload: Codable {
    var to: String
    var notification: Notification
    
    struct Notification: Codable {
        var title: String
        var subtitle: String
        var body: String
        var badge: String
    }
}


