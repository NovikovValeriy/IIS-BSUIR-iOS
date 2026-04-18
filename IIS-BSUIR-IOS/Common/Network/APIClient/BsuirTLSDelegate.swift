//
//  BsuirTLSDelegate.swift
//  IIS-BSUIR-IOS
//
//  Created by Valery Novikau on 18.04.26.
//

import Foundation

final class BsuirTLSDelegate: NSObject, URLSessionDelegate {
    private let trustedCert: SecCertificate

    init?(bundle: Bundle = .main) {
        guard
            let url = bundle.url(forResource: "globalsign_intermediate_ca", withExtension: "pem"),
            let pem = try? String(contentsOf: url, encoding: .utf8),
            let der = Self.derFromPEM(pem),
            let cert = SecCertificateCreateWithData(nil, der as CFData)
        else { return nil }
        trustedCert = cert
    }

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard
            challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
            let serverTrust = challenge.protectionSpace.serverTrust
        else {
            completionHandler(.performDefaultHandling, nil)
            return
        }

        SecTrustSetAnchorCertificates(serverTrust, [trustedCert] as CFArray)
        // false = also trust system roots, not only our injected intermediate
        SecTrustSetAnchorCertificatesOnly(serverTrust, false)

        var error: CFError?
        if SecTrustEvaluateWithError(serverTrust, &error) {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }

    private static func derFromPEM(_ pem: String) -> Data? {
        let lines = pem.components(separatedBy: "\n")
            .filter { !$0.hasPrefix("-----") && !$0.isEmpty }
        return Data(base64Encoded: lines.joined())
    }
}
