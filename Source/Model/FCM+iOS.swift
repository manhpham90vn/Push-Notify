//
//  FCM+iOS.swift
//  Push Notify
//
//  Created by Manh Pham on 08/10/2022.
//

import Foundation

struct FCMiOS: Codable {
    var to: String
    var notification: AlertiOS
}

struct AlertiOS: Codable {
    var title: String
    var subtitle: String
    var body: String
    var badge: String
}
