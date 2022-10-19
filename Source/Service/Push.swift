//
//  Push.swift
//  Push Notify
//
//  Created by Manh Pham on 05/10/2022.
//

import Foundation
import Alamofire
import Security

enum APNSENV {
    case sanbox
    case production
    
    var url: String {
        switch self {
        case .sanbox:
            return "https://api.development.push.apple.com/3/device/"
        case .production:
            return "https://api.push.apple.com/3/device/"
        }
    }
}

enum PushError: Error {
    case unknown
}

class Push: NSObject {

    static let shared = Push()

    func push(env: APNSENV, deviceToken: String, aps: APNsPayload, keyID: String, teamID: String, privateKey: String, bundleID: String) async throws -> Int {
        let iat = UInt64(Date().timeIntervalSince1970)
        let header: [String: String] = ["alg": "ES256", "typ": "JWT", "kid": keyID]
        let claims: [String: Any] = ["iat": iat, "iss": teamID]
        let jwtHeader = try JSONSerialization.data(withJSONObject: header).base64EncodedString()
        let jwtClaims = try JSONSerialization.data(withJSONObject: claims).base64EncodedString()
        let unsignedJWT = "\(jwtHeader).\(jwtClaims)"
        let ecPrivateKey = try ECPrivateKey(key: privateKey)
        let signature = try unsignedJWT.sign(with: ecPrivateKey)
        let token = "\(unsignedJWT).\(signature.asn1.base64EncodedString())"

        let url = env.url + deviceToken
        let bearerToken = HTTPHeader.authorization(bearerToken: token)
        let apnsTopic = HTTPHeader(name: "apns-topic", value: bundleID)
        let httpHeaders = HTTPHeaders([bearerToken, apnsTopic])
        let request = AF.request(url, method: .post, parameters: aps, encoder: JSONParameterEncoder.default, headers: httpHeaders).serializingDecodable(Empty.self)
        return await request.response.response?.statusCode ?? 0
    }

    func push(env: APNSENV, deviceToken: String, aps: APNsPayload, bundleID: String, identity: SecIdentity) async throws -> Int {
        let url = env.url + deviceToken
        let apnsTopic = HTTPHeader(name: "apns-topic", value: bundleID)
        let httpHeaders = HTTPHeaders([apnsTopic])

        var certificate: SecCertificate?
        SecIdentityCopyCertificate(identity, &certificate)
        if let cert = certificate {
            let cred = URLCredential(identity: identity, certificates: [cert], persistence: .forSession)
            certificate = nil

            let request = AF.request(url, method: .post, parameters: aps, encoder: JSONParameterEncoder.default, headers: httpHeaders)
                .authenticate(with: cred)
                .serializingDecodable(Empty.self)

            return await request.response.response?.statusCode ?? 0
        }
        throw PushError.unknown
    }

    func push(serverKey: String, aps: FCMPayload) async throws -> Int {
        let url = "https://fcm.googleapis.com/fcm/send"
        let token = HTTPHeader.authorization("key=\(serverKey)")
        let httpHeaders = HTTPHeaders([token])
        let request = AF.request(url, method: .post, parameters: aps, encoder: JSONParameterEncoder.default, headers: httpHeaders).serializingDecodable(Empty.self)
        return await request.response.response?.statusCode ?? 0
    }

    func push(aps: SimulatorPayload, bundleID: String) throws -> Int {
        let task = Process()
        let errorPipe = Pipe()
        let outputPipe = Pipe()
        let encode = JSONEncoder()
        encode.outputFormatting = .prettyPrinted

        let data = try encode.encode(aps)
        let string = String(data: data, encoding: .utf8) ?? ""
        let folder = NSTemporaryDirectory()
        let fileName = UUID().uuidString + ".aps"
        guard let file =  NSURL.fileURL(withPathComponents: [folder, fileName]) else { return -1 }
        try string.write(to: file, atomically: true, encoding: .utf8)
        var fileString = file.absoluteString
        fileString = fileString.replacingOccurrences(of: "file://", with: "")

        let command = "xcrun simctl push booted \(bundleID) \(fileString)"
        task.standardError = errorPipe
        task.standardOutput = outputPipe
        task.arguments = ["-c", command]
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")

        try task.run()
        task.waitUntilExit()

        return Int(task.terminationStatus)
    }
}
