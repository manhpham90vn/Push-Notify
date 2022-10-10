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
        HStack(alignment: .bottom, spacing: 20) {
            HStack {
                Button {
                    isCheckAPNS = true
                    isCheckFCM = false
                    isCheckAndroid = false
                    isCheckSimulator = false
                } label: {
                    Image(systemName: isCheckAPNS ? "checkmark.square" : "square")
                }
                Text("APNS")
            }

            HStack {
                Button {
                    isCheckFCM = true
                    isCheckAPNS = false
                    isCheckAndroid = false
                    isCheckSimulator = false
                } label: {
                    Image(systemName: isCheckFCM ? "checkmark.square" : "square")
                }
                Text("FCM-iOS")
            }

            HStack {
                Button {
                    isCheckAPNS = false
                    isCheckFCM = false
                    isCheckSimulator = false
                    isCheckAndroid = true
                } label: {
                    Image(systemName: isCheckAndroid ? "checkmark.square" : "square")
                }
                Text("FCM-Android")
            }

            HStack {
                Button {
                    isCheckAPNS = false
                    isCheckFCM = false
                    isCheckAndroid = false
                    isCheckSimulator = true
                } label: {
                    Image(systemName: isCheckSimulator ? "checkmark.square" : "square")
                }
                Text("Simulator")
            }
        }
    }

    var selectAPNSTypeView: some View {
        HStack {
            HStack {
                Button {
                    isCheckAuthenticationKey = true
                    isCheckCertificates = false
                } label: {
                    Image(systemName: isCheckAuthenticationKey ? "checkmark.square" : "square")
                }
                Text("Authentication Key")
            }

            HStack {
                Button {
                    isCheckAuthenticationKey = false
                    isCheckCertificates = true
                } label: {
                    Image(systemName: isCheckCertificates ? "checkmark.square" : "square")
                }
                Text("Certificates")
            }
        }
    }

    var authenKeyView: some View {
        VStack {
            
            HStack {
                HStack {
                    Button {
                        isCheckProduction = true
                        isCHeckSanbox = false
                    } label: {
                        Image(systemName: isCheckProduction ? "checkmark.square" : "square")
                    }
                    Text("Production")
                }

                HStack {
                    Button {
                        isCheckProduction = false
                        isCHeckSanbox = true
                    } label: {
                        Image(systemName: isCHeckSanbox ? "checkmark.square" : "square")
                    }
                    Text("Sanbox")
                }
            }
            
            VStack(alignment: .leading) {
                
                HStack {
                    Text(fileP8?.lastPathComponent ?? "Filename")
                    Button {
                        let panel = NSOpenPanel()
                        panel.allowedFileTypes = ["p8"]
                        panel.allowsMultipleSelection = false
                        panel.canChooseDirectories = false
                        panel.canCreateDirectories = false
                        panel.title = "Select P8 file"

                        if panel.runModal() == .OK,
                            let url = panel.url {
                            self.fileP8 = url
                        }
                    } label: {
                        Text("Select P8 File")
                    }
                }

                HStack {
                    Text("Key ID")
                    TextField("Key ID", text: $keyID)
                }

                HStack {
                    Text("Team ID")
                    TextField("Team ID", text: $teamID)
                }

                HStack {
                    Text("Bundle ID")
                    TextField("Bundle ID", text: $bundleID)
                }

                HStack {
                    Text("Device Token")
                    TextField("Device Token", text: $deviceToken)
                }
            }

            Spacer(minLength: 20)
            
            VStack(alignment: .leading) {
                
                Text("Config Payload")
                
                HStack {
                    Text("Badge")
                    TextField("Badge", text: $badge)
                }

                HStack {
                    Text("Title")
                    TextField("Title", text: $title)
                }

                HStack {
                    Text("Sub title")
                    TextField("Sub title", text: $subtitle)
                }

                HStack {
                    Text("Body")
                    TextField("Body", text: $bodyText)
                }
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
                HStack {
                    Button {
                        isCheckProduction = true
                        isCHeckSanbox = false
                    } label: {
                        Image(systemName: isCheckProduction ? "checkmark.square" : "square")
                    }
                    Text("Production")
                }

                HStack {
                    Button {
                        isCheckProduction = false
                        isCHeckSanbox = true
                    } label: {
                        Image(systemName: isCHeckSanbox ? "checkmark.square" : "square")
                    }
                    Text("Sanbox")
                }
            }
            
            VStack(alignment: .leading) {
                
                HStack {
                    Text(fileP12?.lastPathComponent ?? "Filename")
                    Button {
                        let panel = NSOpenPanel()
                        panel.allowedFileTypes = ["p12"]
                        panel.allowsMultipleSelection = false
                        panel.canChooseDirectories = false
                        panel.canCreateDirectories = false
                        panel.title = "Select P12 file"

                        if panel.runModal() == .OK,
                            let url = panel.url {
                            self.fileP12 = url
                        }
                    } label: {
                        Text("Select P12 File")
                    }
                }

                HStack {
                    Text("Password")
                    TextField("Password", text: $password)
                }

                HStack {
                    Text("Bundle ID")
                    TextField("Bundle ID", text: $bundleID)
                }

                HStack {
                    Text("Device Token")
                    TextField("Device Token", text: $deviceToken)
                }
            }

            Spacer(minLength: 20)
                        
            VStack(alignment: .leading) {
                
                Text("Config Payload")
                
                HStack {
                    Text("Badge")
                    TextField("Badge", text: $badge)
                }
                
                HStack {
                    Text("Title")
                    TextField("Title", text: $title)
                }
                
                HStack {
                    Text("Sub title")
                    TextField("Sub title", text: $subtitle)
                }
                
                HStack {
                    Text("Body")
                    TextField("Body", text: $bodyText)
                }
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
        VStack(alignment: .center) {
            
            Spacer(minLength: 30)
            
            HStack {
                Text("Server key")
                TextField("Server key", text: $serverKey)
            }
            
            HStack {
                Text("FCM Token")
                TextField("FCM Token", text: $fcmToken)
            }
            
            Spacer(minLength: 30)
            
            HStack(alignment: .center, spacing: 20) {
                HStack {
                    Text("Badge")
                    TextField("Badge", text: $badge)
                }.frame(minWidth: 0, maxWidth: .infinity)
                
                HStack {
                    Text("Title")
                    TextField("Title", text: $title)
                }.frame(minWidth: 0, maxWidth: .infinity)
            }

            HStack(alignment: .center, spacing: 20) {
                HStack {
                    Text("Sub title")
                    TextField("Sub title", text: $subtitle)
                }.frame(minWidth: 0, maxWidth: .infinity)
                
                HStack {
                    Text("Body")
                    TextField("Body", text: $bodyText)
                }.frame(minWidth: 0, maxWidth: .infinity)
            }

            TextEditor(text: $payloadFCMiOS)
            Button("Submit") {
                let payload = FCMiOSPayload(to: fcmToken, notification: .init(title: title, subtitle: subtitle, body: bodyText, badge: badge))
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
        VStack(alignment: .center) {
            
            Spacer(minLength: 30)
            
            HStack {
                Text("Server key")
                TextField("Server key", text: $serverKey)
            }
            
            HStack {
                Text("FCM Token")
                TextField("FCM Token", text: $androidFCMToken)
            }
            
            Spacer(minLength: 30)
            
            HStack(alignment: .center, spacing: 20) {
                HStack {
                    Text("Title")
                    TextField("Title", text: $title)
                }.frame(minWidth: 0, maxWidth: .infinity)
                
                HStack {
                    Text("Body")
                    TextField("Body", text: $bodyText)
                }.frame(minWidth: 0, maxWidth: .infinity)
            }

            TextEditor(text: $payloadFCMAndroid)
            Button("Submit") {
                Task {
                    let payload = FCMAndroidPayload(to: androidFCMToken, notification: .init(title: title, body: bodyText))
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

            HStack {
                Text("Bundle ID")
                TextField("Bundle ID", text: $bundleID)
            }
            
            HStack(alignment: .center, spacing: 20) {
                HStack {
                    Text("Badge")
                    TextField("Badge", text: $badge)
                }.frame(minWidth: 0, maxWidth: .infinity)
                
                HStack {
                    Text("Title")
                    TextField("Title", text: $title)
                }.frame(minWidth: 0, maxWidth: .infinity)
            }

            HStack(alignment: .center, spacing: 20) {
                HStack {
                    Text("Sub title")
                    TextField("Sub title", text: $subtitle)
                }.frame(minWidth: 0, maxWidth: .infinity)
                
                HStack {
                    Text("Body")
                    TextField("Body", text: $bodyText)
                }.frame(minWidth: 0, maxWidth: .infinity)
            }

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
            Text("Select Push Notification Type")
            selectPushTypeView
            if isCheckAPNS {
                Text("Select APNs Type")
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
