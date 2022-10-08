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

    var identity: SecIdentity?

    func push(env: APNSENV, deviceToken: String, aps: Payload, keyID: String, teamID: String, privateKey: String, bundleID: String) async throws -> Int {
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

    func push(env: APNSENV, deviceToken: String, aps: Payload, bundleID: String) async throws -> Int {
        let rootQueue = DispatchQueue(label: "com.manhpham.Push-Notify")
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.underlyingQueue = rootQueue
        let delegate = SessionDelegate()
        let urlSession = URLSession(configuration: .ephemeral, delegate: delegate, delegateQueue: queue)
        let session = Session(session: urlSession, delegate: delegate, rootQueue: rootQueue)
        let url = env.url + deviceToken
        let apnsTopic = HTTPHeader(name: "apns-topic", value: bundleID)
        let httpHeaders = HTTPHeaders([apnsTopic])
        if let identity = identity {
            var certificate: SecCertificate?
            SecIdentityCopyCertificate(identity, &certificate)
            if let cert = certificate {
                let cred = URLCredential(identity: identity, certificates: [cert], persistence: .forSession)
                certificate = nil
                
                let request = session.request(url, method: .post, parameters: aps, encoder: JSONParameterEncoder.default, headers: httpHeaders)
                    .authenticate(with: cred)
                    .serializingDecodable(Empty.self)
                
                return await request.response.response?.statusCode ?? 0
            }
        }
        throw PushError.unknown
    }
}
