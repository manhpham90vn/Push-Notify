//
//  PKCS12.swift
//  Push Notify (iOS)
//
//  Created by Manh Pham on 08/10/2022.
//

import Foundation

enum PKCS12Error: Error {
    case incorrectPassword
    case canNotImportPKCS12Data
    case unKnown
}

class PKCS12 {
    let label: String?
    let keyID: NSData?
    let trust: SecTrust?
    let certChain: [SecTrust]?
    let identity: SecIdentity?
    
    public init(pkcs12Data: Data, password: String) throws {
        let importPasswordOption: NSDictionary = [kSecImportExportPassphrase as NSString: password]
        var items: CFArray?
        let secError: OSStatus = SecPKCS12Import(pkcs12Data as NSData, importPasswordOption, &items)
        guard secError == errSecSuccess else {
            if secError == errSecAuthFailed {
                throw PKCS12Error.incorrectPassword
            }
            throw PKCS12Error.canNotImportPKCS12Data
        }
        guard let theItemsCFArray = items else {
            throw PKCS12Error.unKnown
        }
        let theItemsNSArray: NSArray = theItemsCFArray as NSArray
        guard let dictArray = theItemsNSArray as? [[String: AnyObject]] else {
            throw PKCS12Error.unKnown
        }
        self.label = PKCS12.f(key: kSecImportItemLabel, dictArray: dictArray)
        self.keyID = PKCS12.f(key: kSecImportItemKeyID, dictArray: dictArray)
        self.trust = PKCS12.f(key: kSecImportItemTrust, dictArray: dictArray)
        self.certChain = PKCS12.f(key: kSecImportItemCertChain, dictArray: dictArray)
        self.identity = PKCS12.f(key: kSecImportItemIdentity, dictArray: dictArray)
    }
    
    static func f<T>(key: CFString, dictArray: [[String : AnyObject]]) -> T? {
        for dict in dictArray {
            if let value = dict[key as String] as? T {
                return value
            }
        }
        return nil
    }
}
