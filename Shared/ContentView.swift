//
//  ContentView.swift
//  Shared
//
//  Created by Manh Pham on 05/10/2022.
//

import SwiftUI

struct ContentView: View {

    #if !os(macOS)
    var body: some View {
        main.navigationBarTitleDisplayMode(.inline).padding(.all, 20)
    }
    #else
    var body: some View {
        main.frame(minWidth: 600, minHeight: 500).padding(.all, 20)
    }
    #endif

    @State var isCheckAPNS = true
    @State var isCheckFCM = false
    @State var isCheckAndroid = false
    @State var isCheckSimulator = false

    @State var isCheckAuthenticationKey = true
    @State var isCheckCertificates = false
    @State var isCheckProduction = false
    @State var isCHeckSanbox = true

    @State var fileP8: URL?
    @State var fileP12: URL?
    @State var keyID = "M48UHK248C"
    @State var teamID = "UPJRMYQ38F"
    @State var bundleID = "com.manhpham.myapp.debug"
    @State var deviceToken = "ec8c6fc31b3a7f7455607a0dedb42b00593715348aa9e578ff5b78866a488a59"
    @State var fullText: String = ""
    @State var badge: String = "1"
    @State var title: String = "Hello"
    @State var subtitle: String = "Sub title"
    @State var bodyText: String = "Body"
    @State var password: String = "123456"

    @State var isOn = false
    @State var message = ""
    
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
                Text("FCM")
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
                Text("Android")
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

            Spacer(minLength: 30)

            VStack(alignment: .leading) {
                HStack(alignment: .center) {
                    Text(fileP8?.lastPathComponent ?? "Filename")
                    Button {
                        #if os(macOS)
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
                        #endif
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

            TextEditor(text: $fullText)
            Button("Submit") {
                let env = isCheckProduction ? APNSENV.production : APNSENV.sanbox
                let payload = Payload(aps: APN(badge: Int(badge) ?? 0, alert: .init(title: title, subtitle: subtitle, body: bodyText)))
                if let file = fileP8 {
                    Task {
                        do {
                            fullText = try String(data: JSONEncoder().encode(payload), encoding: .utf8) ?? ""
                            let content = try String(contentsOf: file)
                            let statusCode = try await Push.shared.push(env: env, deviceToken: deviceToken, aps: payload, keyID: keyID, teamID: teamID, privateKey: content, bundleID: bundleID)
                            isOn = true
                            message = statusCode == 200 ? "Send Success: status code \(statusCode)": "Send Failed: status code \(statusCode)"
                        } catch let error {
                            isOn = true
                            message = "\(error)"
                        }
                    }
                } else {
                    isOn = true
                    message = "p8 file not found"
                }
            }.alert(message, isPresented: $isOn) {
                Button("OK") {
                    isOn = false
                    message = ""
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

            Spacer(minLength: 30)
            
            VStack(alignment: .leading) {
                HStack {
                    Text(fileP12?.lastPathComponent ?? "Filename")
                    Button {
                        #if os(macOS)
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
                        #endif
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

            TextEditor(text: $fullText)
            Button("Submit") {
                let env = isCheckProduction ? APNSENV.production : APNSENV.sanbox
                let payload = Payload(aps: APN(badge: Int(badge) ?? 0, alert: .init(title: title, subtitle: subtitle, body: bodyText)))
                if let file = fileP12 {
                    Task {
                        do {
                            fullText = try String(data: JSONEncoder().encode(payload), encoding: .utf8) ?? ""
                            let data = try Data(contentsOf: file)
                            let content = try PKCS12(pkcs12Data: data, password: password)
                            if let identity = content.identity {
                                let statusCode = try await Push.shared.push(env: env, deviceToken: deviceToken, aps: payload, bundleID: bundleID, identity: identity)
                                isOn = true
                                message = statusCode == 200 ? "Send Success: status code \(statusCode)": "Send Failed: status code \(statusCode)"
                            } else {
                                isOn = true
                                message = "SecIdentity not found"
                            }
                        } catch let error {
                            isOn = true
                            message = "\(error)"
                        }
                    }
                } else {
                    isOn = true
                    message = "p12 file not found"
                }
            }.alert(message, isPresented: $isOn) {
                Button("OK") {
                    isOn = false
                    message = ""
                }
            }
        }
    }

    var main: some View {
        VStack {
            selectPushTypeView
            if isCheckAPNS {
                selectAPNSTypeView
            }
            if isCheckAuthenticationKey && isCheckAPNS {
                authenKeyView
            }
            if isCheckCertificates && isCheckAPNS {
                cerView
            }
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
