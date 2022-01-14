import Foundation

public enum MPUserIdentifier {
    case user(user: String)
    case thirdparty(medium: String, address: String)
    case phone(country: String, phone: String)

    enum CodingKeys: String, CodingKey {
        case type
        case user
        case medium
        case address
        case country
        case phone
    }
}

public protocol MPAuthMethod: Encodable {
    var type: String { get }
}

public struct MPDummyAuth: MPAuthMethod {
    public let type: String = "m.login.dummy"
}

public struct MPPasswordAuth: MPAuthMethod {
    public let type: String = "m.login.password"
    public var identifier: MPUserIdentifier
    public var password: String
}

public struct MPReCaptchaAuth: MPAuthMethod {
    public let type: String = "m.login.recaptcha"
    public var response: String
}

public struct MPTokenAuth: MPAuthMethod {
    public let type: String = "m.login.token"
    public var token: String
}

public struct MPThirdPartyCredentials: Encodable {
    public var sid: String
    public var clientSecret: String
    public var idServer: URL?
    public var idAccessToken: String
}

public struct MPEmailAuth: MPAuthMethod {
    public let type: String = "m.login.email.identity"
    public var threepidCreds: MPThirdPartyCredentials

    enum CodingKeys: String, CodingKey {
        case type
        case threepidCreds = "threepid_creds"
    }
}

public struct MPMsisdnAuth: MPAuthMethod {
    public let type: String = "m.login.msisdn"
    public var threepidCreds: MPThirdPartyCredentials

    enum CodingKeys: String, CodingKey {
        case type
        case threepidCreds = "threepid_creds"
    }
}

extension MPUserIdentifier: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .user(let user):
            try container.encode("m.id.user", forKey: .type)
            try container.encode(user, forKey: .user)
        case .thirdparty(let medium, let address):
            try container.encode("m.id.thirdparty", forKey: .type)
            try container.encode(medium, forKey: .medium)
            try container.encode(address, forKey: .address)
        case .phone(let country, let phone):
            try container.encode("m.id.phone", forKey: .type)
            try container.encode(country, forKey: .country)
            try container.encode(phone, forKey: .phone)
        }
    }
}
