//
//  FCM+Android.swift
//  Push Notify
//
//  Created by Manh Pham on 08/10/2022.
//

import Foundation

struct FCMAndroidPayload: Codable {
    var to: String
    var notification: AlertAndroid
    
    struct AlertAndroid: Codable {
        var title: String
        var body: String
    }
}
