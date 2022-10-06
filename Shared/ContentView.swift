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
        main.navigationBarTitleDisplayMode(.inline)
    }
    #else
    var body: some View {
        main.frame(minWidth: 600, minHeight: 500)
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
    
    @State var file: URL?
    @State var keyID = "VY9C3JRPD3"
    @State var teamID = "UPJRMYQ38F"
    @State var bundleID = "com.manhpham.myapp.debug"
    @State var deviceToken = "ec8c6fc31b3a7f7455607a0dedb42b00593715348aa9e578ff5b78866a488a59"
    @State var fullText: String = ""
    @State var badge: String = "1"
    @State var title: String = "Hello"
    @State var subtitle: String = "Sub title"
    @State var bodyText: String = "Body"
    
    var main: some View {
        VStack {
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
            .padding(.top, 20)
            if isCheckAPNS {
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
            if isCheckAuthenticationKey && isCheckAPNS {
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
                    
                    HStack(alignment: .center, spacing: 20) {
                        HStack {
                            Text("Key ID")
                            TextField("Key ID", text: $keyID)
                        }.frame(minWidth: 0, maxWidth: .infinity)
                        
                        HStack {
                            Text("Team ID")
                            TextField("Team ID", text: $teamID)
                        }.frame(minWidth: 0, maxWidth: .infinity)
                    }.padding([.leading, .trailing], 20)
                    
                    HStack(alignment: .center, spacing: 20) {
                        HStack(alignment: .center) {
                            Text(file?.lastPathComponent ?? "Filename")
                            Button {
                                #if os(macOS)
                                let panel = NSOpenPanel()
                                panel.allowsMultipleSelection = false
                                panel.canChooseDirectories = false
                                panel.canCreateDirectories = false
                                panel.title = "Select P8 file"
                                
                                if panel.runModal() == .OK,
                                    let url = panel.url {
                                    self.file = url
                                }
                                #endif
                            } label: {
                                Text("Select P8 File")
                            }
                        }.frame(minWidth: 0, maxWidth: .infinity)
                        
                        HStack {
                            Text("Bundle ID")
                            TextField("Bundle ID", text: $bundleID)
                        }.frame(minWidth: 0, maxWidth: .infinity)
                    }.padding([.leading, .trailing], 20)
                    
                    HStack {
                        Text("Device Token")
                        TextField("Device Token", text: $deviceToken)
                    }.padding([.leading, .trailing], 20)
                    
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
                    }.padding([.leading, .trailing], 20)
                    
                    HStack(alignment: .center, spacing: 20) {
                        HStack {
                            Text("Sub title")
                            TextField("Sub title", text: $subtitle)
                        }.frame(minWidth: 0, maxWidth: .infinity)
                        
                        HStack {
                            Text("Body")
                            TextField("Body", text: $bodyText)
                        }.frame(minWidth: 0, maxWidth: .infinity)
                    }.padding([.leading, .trailing], 20)
                                        
                    TextEditor(text: $fullText)
                    Button("Submit") {
                        let env = isCheckProduction ? APNSENV.production : APNSENV.sanbox
                        let payload = Payload(aps: APN(badge: Int(badge) ?? 0, alert: .init(title: title, subtitle: subtitle, body: bodyText)))
                        if let file = file, let content = try? String(contentsOf: file) {
                            Task {
                                do {
                                    fullText = try String(data: JSONEncoder().encode(payload), encoding: .utf8) ?? ""
                                    let statusCode = try await Push.push(env: env, deviceToken: deviceToken, aps: payload, keyID: keyID, teamID: teamID, privateKey: content, bundleID: bundleID)
                                    print(statusCode)
                                } catch let error {
                                    print(error.localizedDescription)
                                }
                            }
                        } else {
                            print("p8 file not found")
                        }
                    }
                }
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
