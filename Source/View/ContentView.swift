//
//  ContentView.swift
//  Shared
//
//  Created by Manh Pham on 05/10/2022.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
        main.frame(minWidth: 600, minHeight: 700).padding(.all, 20)
    }

    // common
    @State var bundleID = ""
    @State var message = ""
    @State var serverKey = ""
    
    // payload
    @State var badge: String = ""
    @State var title: String = ""
    @State var subtitle: String = ""
    @State var bodyText: String = ""
    
    // push type
    @State var isCheckAPNS = true
    @State var isCheckFCM = false
    @State var isCheckAndroid = false
    @State var isCheckSimulator = false
    
    // apns type
    @State var isCheckAuthenticationKey = true
    @State var isCheckCertificates = false
    @State var isCheckProduction = false
    @State var isCHeckSanbox = true
    @State var fileP8: URL?
    @State var fileP12: URL?
    @State var keyID = ""
    @State var teamID = ""
    @State var deviceToken = ""
    @State var password: String = ""
    @State var payloadAPNS: String = ""
    
    // fcm-ios
    @State var fcmToken = ""
    @State var payloadFCMiOS: String = ""
    
    // fcm-android
    @State var androidFCMToken = ""
    @State var payloadFCMAndroid: String = ""
    
    // simulator
    @State var payloadSimulator: String = ""

    var selectPushTypeView: some View {
        VStack {
            Text("Select Push Notification Type")
            HStack(alignment: .bottom, spacing: 20) {
                
                CheckboxView(text: "APNS", isChecked: $isCheckAPNS) { _ in
                    isCheckFCM = false
                    isCheckAndroid = false
                    isCheckSimulator = false
                }
                
                CheckboxView(text: "FCM-iOS", isChecked: $isCheckFCM) { _ in
                    isCheckAPNS = false
                    isCheckAndroid = false
                    isCheckSimulator = false
                }
                
                CheckboxView(text: "FCM-Android", isChecked: $isCheckAndroid) { _ in
                    isCheckAPNS = false
                    isCheckFCM = false
                    isCheckSimulator = false
                }

                CheckboxView(text: "Simulator", isChecked: $isCheckSimulator) { _ in
                    isCheckAPNS = false
                    isCheckFCM = false
                    isCheckAndroid = false
                }
            }
        }
    }

    var selectAPNSTypeView: some View {
        VStack {
            Text("Select APNs Type")
            HStack {
                CheckboxView(text: "Authentication Key", isChecked: $isCheckAuthenticationKey) { _ in
                    isCheckCertificates = false
                }
                
                CheckboxView(text: "Certificates", isChecked: $isCheckCertificates) { _ in
                    isCheckAuthenticationKey = false
                }
            }
        }
    }

    var authenKeyView: some View {
        VStack {
            
            HStack {
                CheckboxView(text: "Production", isChecked: $isCheckProduction) { _ in
                    isCHeckSanbox = false
                }

                CheckboxView(text: "Sanbox", isChecked: $isCHeckSanbox) { _ in
                    isCheckProduction = false
                }
            }
            
            VStack(alignment: .leading) {
                
                SelectFileView(label: "Select P8 file", fileType: "p8", file: $fileP8)
                
                TextFieldView(label: "Key ID", text: $keyID)
                
                TextFieldView(label: "Team ID", text: $teamID)
                
                TextFieldView(label: "Bundle ID", text: $bundleID)
                
                TextFieldView(label: "Device Token", text: $deviceToken)
            }

            Spacer(minLength: 20)
            
            VStack(alignment: .leading) {
                
                Text("Config Payload")
                
                TextFieldView(label: "Badge", text: $badge)
                
                TextFieldView(label: "Title", text: $title)
                
                TextFieldView(label: "Sub title", text: $subtitle)
                
                TextFieldView(label: "Body", text: $bodyText)
            }
            
            Spacer(minLength: 20)
            
            VStack(alignment: .leading) {
                Text("Preview Payload")
                
                TextEditor(text: $payloadAPNS)
                
                Button("Submit") {
                    let env = isCheckProduction ? APNSENV.production : APNSENV.sanbox
                    let payload = APNsPayload(aps: APS(badge: Int(badge) ?? 0, alert: .init(title: title, subtitle: subtitle, body: bodyText)))
                    if let file = fileP8 {
                        Task {
                            do {
                                payloadAPNS = try String(data: JSONEncoder().encode(payload), encoding: .utf8) ?? ""
                                let content = try String(contentsOf: file)
                                let statusCode = try await Push.shared.push(env: env, deviceToken: deviceToken, aps: payload, keyID: keyID, teamID: teamID, privateKey: content, bundleID: bundleID)
                                message = statusCode == 200 ? "Send Success: status code \(statusCode)": "Send Failed: status code \(statusCode)"
                                await MainActor.run(body: {
                                    showAlert(message: message)
                                })
                            } catch let error {
                                message = "\(error)"
                                showAlert(message: message)
                            }
                        }
                    } else {
                        message = "p8 file not found"
                        showAlert(message: message)
                    }
                }

            }
        }
    }

    var cerView: some View {
        VStack {
            
            HStack {
                CheckboxView(text: "Production", isChecked: $isCheckProduction) { _ in
                    isCHeckSanbox = false
                }
                
                CheckboxView(text: "Sanbox", isChecked: $isCHeckSanbox) { _ in
                    isCheckProduction = false
                }
            }
            
            VStack(alignment: .leading) {
                
                SelectFileView(label: "Select P12 file", fileType: "p12", file: $fileP12)
                
                TextFieldView(label: "Password", text: $password)
                
                TextFieldView(label: "Bundle ID", text: $bundleID)
                
                TextFieldView(label: "Device Token", text: $deviceToken)
            }

            Spacer(minLength: 20)
                        
            VStack(alignment: .leading) {
                
                Text("Config Payload")
                
                TextFieldView(label: "Badge", text: $badge)
                
                TextFieldView(label: "Title", text: $title)
                
                TextFieldView(label: "Sub title", text: $subtitle)
                
                TextFieldView(label: "Body", text: $bodyText)
            }
            
            Spacer(minLength: 20)
            
            VStack(alignment: .leading) {
                Text("Preview Payload")
                
                TextEditor(text: $payloadAPNS)
                
                Button("Submit") {
                    let env = isCheckProduction ? APNSENV.production : APNSENV.sanbox
                    let payload = APNsPayload(aps: APS(badge: Int(badge) ?? 0, alert: .init(title: title, subtitle: subtitle, body: bodyText)))
                    if let file = fileP12 {
                        Task {
                            do {
                                payloadAPNS = try String(data: JSONEncoder().encode(payload), encoding: .utf8) ?? ""
                                let data = try Data(contentsOf: file)
                                let content = try PKCS12(pkcs12Data: data, password: password)
                                if let identity = content.identity {
                                    let statusCode = try await Push.shared.push(env: env, deviceToken: deviceToken, aps: payload, bundleID: bundleID, identity: identity)
                                    message = statusCode == 200 ? "Send Success: status code \(statusCode)": "Send Failed: status code \(statusCode)"
                                    await MainActor.run(body: {
                                        showAlert(message: message)
                                    })
                                } else {
                                    message = "SecIdentity not found"
                                    showAlert(message: message)
                                }
                            } catch let error {
                                message = "\(error)"
                                showAlert(message: message)
                            }
                        }
                    } else {
                        message = "p12 file not found"
                        showAlert(message: message)
                    }
                }
            }
        }
    }

    var fcmView: some View {
        VStack(alignment: .leading) {
            
            Group {
                Spacer(minLength: 30)
                
                TextFieldView(label: "Server key", text: $serverKey)
                
                TextFieldView(label: "FCM Token", text: $fcmToken)
            }
            
            Group {
                Spacer(minLength: 30)
                
                Text("Config Payload")
                
                TextFieldView(label: "Badge", text: $badge)
                
                TextFieldView(label: "Title", text: $title)
                
                TextFieldView(label: "Sub title", text: $subtitle)
                
                TextFieldView(label: "Body", text: $bodyText)
            }

            Group {
                Spacer(minLength: 30)
                
                Text("Preview Payload")
                
                TextEditor(text: $payloadFCMiOS)
            }
        
            Button("Submit") {
                let payload = FCMPayload(to: fcmToken, notification: .init(title: title, subtitle: subtitle, body: bodyText, badge: badge))
                Task {
                    do {
                        payloadFCMiOS = try String(data: JSONEncoder().encode(payload), encoding: .utf8) ?? ""
                        let statusCode = try await Push.shared.push(serverKey: serverKey, aps: payload)
                        message = statusCode == 200 ? "Send Success: status code \(statusCode)": "Send Failed: status code \(statusCode)"
                        await MainActor.run(body: {
                            showAlert(message: message)
                        })
                    } catch let error {
                        message = "\(error)"
                        showAlert(message: message)
                    }
                }
            }
        }
    }
    
    var androidView: some View {
        VStack(alignment: .leading) {
            
            Group {
                Spacer(minLength: 30)
                
                TextFieldView(label: "Server key", text: $serverKey)
                
                TextFieldView(label: "FCM Token", text: $androidFCMToken)
            }
            
            Group {
                Spacer(minLength: 30)
                
                Text("Config Payload")
                
                TextFieldView(label: "Title", text: $title)
                            
                TextFieldView(label: "Body", text: $bodyText)
            }
            
            Group {
                Spacer(minLength: 30)
                
                Text("Preview Payload")
                
                TextEditor(text: $payloadFCMAndroid)
            }
            
            Button("Submit") {
                Task {
                    let payload = FCMPayload(to: androidFCMToken, notification: .init(title: title, body: bodyText))
                    do {
                        payloadFCMAndroid = try String(data: JSONEncoder().encode(payload), encoding: .utf8) ?? ""
                        let statusCode = try await Push.shared.push(serverKey: serverKey, aps: payload)
                        message = statusCode == 200 ? "Send Success: status code \(statusCode)": "Send Failed: status code \(statusCode)"
                        await MainActor.run(body: {
                            showAlert(message: message)
                        })
                    } catch let error {
                        message = "\(error)"
                        showAlert(message: message)
                    }
                }
            }
        }
    }
    
    var simulatorView: some View {
        VStack(alignment: .center) {

            Spacer(minLength: 30)

            TextFieldView(label: "Bundle ID", text: $bundleID)
            
            TextFieldView(label: "Badge", text: $badge)
            
            TextFieldView(label: "Title", text: $title)
            
            TextFieldView(label: "Sub title", text: $subtitle)
            
            TextFieldView(label: "Body", text: $bodyText)
            
            TextEditor(text: $payloadSimulator)
            
            Button("Submit") {
                let payload = SimulatorPayload(bundle: bundleID, aps: .init(badge: Int(badge) ?? 0, alert: .init(title: title, subtitle: subtitle, body: bodyText)))
                do {
                    payloadSimulator = try String(data: JSONEncoder().encode(payload), encoding: .utf8) ?? ""
                    let statusCode = try Push.shared.push(aps: payload, bundleID: bundleID)
                    message = statusCode == 0 ? "Send Success: status code \(statusCode)": "Send Failed: status code \(statusCode)"
                    showAlert(message: message)
                } catch let error {
                    message = "\(error)"
                    showAlert(message: message)
                }
            }
        }
    }
    
    var main: some View {
        VStack {
            selectPushTypeView
            if isCheckAPNS {
                selectAPNSTypeView
                Text("Select Environment")
                if isCheckAuthenticationKey {
                    authenKeyView
                }
                if isCheckCertificates {
                    cerView
                }
            } else if isCheckFCM {
                fcmView
            } else if isCheckAndroid {
                androidView
            } else if isCheckSimulator {
                simulatorView
            }
            Spacer()
        }
    }
    
    func showAlert(message: String) {
        let alert = NSAlert()
        alert.messageText = message
        alert.addButton(withTitle: "OK")
        alert.alertStyle = .warning
        alert.runModal()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
