import Foundation

public protocol MPAccountAPI {
    /// Checks to see if a username is available on the server.
    ///
    /// The method returns normally if the given `username` is valid and available.
    /// Otherwise, the method throws an error.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#get_matrixclientv3registeravailable) for
    /// more informataion.
    func checkUsernameAvailability(username: String) async throws

    /// Register for an account on this homeserver.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#post_matrixclientv3register) for
    /// more informataion.
    func registerUser(request: MPRegistrationRequest, kind: MPRegistrationKind) async throws
        -> MPInteractiveAuthSession<MPRegistrationResponse>

    /// Deactivate a user's account.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#post_matrixclientv3accountdeactivate) for
    /// more informataion.
    func deactivateUser(idServer: URL?) async throws -> MPInteractiveAuthSession<MPUnbindResult>

    /// Gets information about the owner of an access token.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#get_matrixclientv3accountwhoami) for
    /// more informataion.
    func getCurrentUser() async throws -> MPCurrentUser

    /// Gets a list of a user's third party identifiers.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#get_matrixclientv3account3pid) for
    /// more informataion.
    func getThirdPartyIdentifiers() async throws -> [MPThirdPartyIdentifier]

    /// Adds contact information to the user's account.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#post_matrixclientv3account3pidadd) for
    /// more informataion.
    func addThirdPartyIdentifier(sid: String, clientSecret: String) async throws
        -> MPInteractiveAuthSession<Void>

    /// Binds a 3PID to the user's account through an Identity Service.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#post_matrixclientv3account3pidbind) for
    /// more informataion.
    func bindThirdPartyIdentifier(
        clientSecret: String, idAccessToken: String, idServer: String, sid: String) async throws

    /// Deletes a third party identifier from the user's account.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#post_matrixclientv3account3piddelete) for
    /// more informataion.
    func deleteThirdPartyIdentifier(address: String, medium: MPThirdPartyMedium, idServer: URL?)
        async throws -> MPUnbindResult

    /// Removes a user's third party identifier from an identity server.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#post_matrixclientv3account3pidunbind) for
    /// more informataion.
    func unbindThirdPartyIdentifier(address: String, medium: MPThirdPartyMedium, idServer: URL?)
        async throws -> MPUnbindResult

    /// Changes a user's password.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#post_matrixclientv3accountpassword) for
    /// more informataion.
    func changePassword(newPassword: String, logoutDevices: Bool?) async throws
        -> MPInteractiveAuthSession<Void>

    /// Begins the validation process for an email to be used during registration.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#post_matrixclientv3registeremailrequesttoken) for
    /// more informataion.
    func requestRegistrationEmailValidation(request: MPEmailValidationRequest) async throws
        -> MPValidationResponse

    /// Begins the validation process for an email address for association with the user's account.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#post_matrixclientv3account3pidemailrequesttoken) for
    /// more informataion.
    func requestAssociationEmailValidation(request: MPEmailValidationRequest) async throws
        -> MPValidationResponse

    /// Requests a validation token be sent to the given email address for the purpose of resetting a user's password.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#post_matrixclientv3accountpasswordemailrequesttoken) for
    /// more informataion.
    func requestPasswordResetEmailValidation(request: MPEmailValidationRequest) async throws
        -> MPValidationResponse

    /// Requests a validation token be sent to the given phone number for the purpose of registering an account.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#post_matrixclientv3registermsisdnrequesttoken) for
    /// more informataion.
    func requestRegistrationPhoneValidation(request: MPPhoneValidationRequest) async throws
        -> MPValidationResponse

    /// Begins the validation process for a phone number for association with the user's account.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#post_matrixclientv3account3pidmsisdnrequesttoken) for
    /// more informataion.
    func requestAssociationPhoneValidation(request: MPPhoneValidationRequest) async throws
        -> MPValidationResponse

    /// Requests a validation token be sent to the given phone number for the purpose of resetting a user's password.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#post_matrixclientv3accountpasswordmsisdnrequesttoken) for
    /// more informataion.
    func requestPasswordResetPhoneValidation(request: MPPhoneValidationRequest) async throws
        -> MPValidationResponse

    /// Get an OpenID token object to verify the requester's identity.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#post_matrixclientv3useruseridopenidrequest_token) for
    /// more informataion.
    func getOpenIDToken(userId: String) async throws -> MPOpenIDToken
}

public struct MPCurrentUser: Decodable {
    public var deviceId: String?
    public var userId: String
}

public enum MPThirdPartyMedium: String, Codable {
    case email
    case msisdn
}

public enum MPUnbindResult: String, Decodable {
    case noSupport = "no-suport"
    case success
}

public struct MPThirdPartyIdentifier: Decodable {
    public var addedAt: Int
    public var address: URL
    public var medium: MPThirdPartyMedium
    public var validatedAt: Int
}

public struct MPEmailValidationRequest: Encodable {
    public var clientSecret: String
    public var email: String
    public var idServer: String?
    public var idAccessToken: String?
    public var nextLink: String?
    public var sendAttempt: Int
}

public struct MPPhoneValidationRequest: Encodable {
    public var clientSecret: String
    public var country: String
    public var idServer: String?
    public var idAccessToken: String?
    public var nextLink: String?
    public var phoneNumber: String
    public var sendAttempt: Int
}

public struct MPValidationResponse: Decodable {
    public var sid: String
    public var submitUrl: URL?
}

public struct MPOpenIDToken: Decodable {
    public var accessToken: String
    public var expiresIn: Int
    public var matrixServerName: String
    public var tokenType: String
}

public enum MPRegistrationKind: String {
    case user
    case guest
}

public struct MPRegistrationRequest: Encodable {
    public var deviceId: String?
    public var inhibitLogin: Bool?
    public var initialDeviceDisplayName: String?
    public var password: String?
    public var username: String?
}

public struct MPRegistrationResponse: Decodable {
    public var accessToken: String?
    public var deviceId: String?
    public var userId: String
}

extension MPClient: MPAccountAPI {
    public func checkUsernameAvailability(username: String) async throws {
        let path: SafePath = "_matrix/client/v3/register/available"
        let query = [("username", username)]
        try await self.send(.get(path.encoded, query: query))
    }

    public func registerUser(request: MPRegistrationRequest, kind: MPRegistrationKind = .user)
        -> MPInteractiveAuthSession<MPRegistrationResponse>
    {
        let path: SafePath = "_matrix/client/v3/register"
        let query = [("kind", kind.rawValue)]
        return self.startInteractiveAuth(body: request) {
            client, body in
            try await client.send(.post(path.encoded, query: query, body: body)).value
        }
    }

    public func deactivateUser(idServer: URL? = nil) -> MPInteractiveAuthSession<MPUnbindResult> {
        struct Deactivation: Encodable {
            var idServer: URL?
        }

        struct Response: Decodable {
            var idServerUnbindResult: MPUnbindResult
        }

        let path: SafePath = "_matrix/client/v3/account/deactivate"

        return self.startInteractiveAuth(body: Deactivation(idServer: idServer)) {
            client, body in
            let response: Response = try await client.send(.post(path.encoded, body: body)).value
            return response.idServerUnbindResult
        }
    }

    public func getCurrentUser() async throws -> MPCurrentUser {
        let path: SafePath = "_matrix/client/v3/account/whoami"
        return try await self.send(.get(path.encoded)).value
    }

    public func getThirdPartyIdentifiers() async throws -> [MPThirdPartyIdentifier] {
        struct List: Decodable {
            var threepids: [MPThirdPartyIdentifier]
        }

        let path: SafePath = "_matrix/client/v3/account/3pid"
        let list: List = try await self.send(.get(path.encoded)).value
        return list.threepids
    }

    public func addThirdPartyIdentifier(sid: String, clientSecret: String)
        -> MPInteractiveAuthSession<Void>
    {
        struct AddThirdParty: Encodable {
            var sid: String
            var clientSecret: String
        }

        let path: SafePath = "_matrix/client/v3/account/3pid/add"
        return self.startInteractiveAuth(body: AddThirdParty(sid: sid, clientSecret: clientSecret))
        {
            client, body in try await client.send(.post(path.encoded, body: body))
        }
    }

    public func bindThirdPartyIdentifier(
        clientSecret: String, idAccessToken: String, idServer: String, sid: String
    ) async throws {
        struct BindThirdParty: Encodable {
            var clientSecret: String
            var idAccessToken: String
            var idServer: String
            var sid: String
        }

        let path: SafePath = "_matrix/client/v3/account/3pid/bind"
        let bind = BindThirdParty(
            clientSecret: clientSecret, idAccessToken: idAccessToken, idServer: idServer, sid: sid)
        try await self.send(.post(path.encoded, body: bind)).value
    }

    public func deleteThirdPartyIdentifier(
        address: String, medium: MPThirdPartyMedium, idServer: URL? = nil
    ) async throws -> MPUnbindResult {
        struct DeleteThirdParty: Encodable {
            var address: String
            var idServer: URL?
            var medium: MPThirdPartyMedium
        }

        struct Response: Decodable {
            var idServerUnbindResult: MPUnbindResult
        }

        let path: SafePath = "_matrix/client/v3/account/3pid/delete"
        let delete = DeleteThirdParty(address: address, idServer: idServer, medium: medium)
        let response: Response = try await self.send(.post(path.encoded, body: delete)).value
        return response.idServerUnbindResult
    }

    public func unbindThirdPartyIdentifier(
        address: String, medium: MPThirdPartyMedium, idServer: URL? = nil
    ) async throws -> MPUnbindResult {
        struct DeleteThirdParty: Encodable {
            var address: String
            var idServer: URL?
            var medium: MPThirdPartyMedium
        }

        struct Response: Decodable {
            var idServerUnbindResult: MPUnbindResult
        }

        let path: SafePath = "_matrix/client/v3/account/3pid/unbind"
        let delete = DeleteThirdParty(address: address, idServer: idServer, medium: medium)
        let response: Response = try await self.send(.post(path.encoded, body: delete)).value
        return response.idServerUnbindResult
    }

    public func changePassword(newPassword: String, logoutDevices: Bool? = nil)
        -> MPInteractiveAuthSession<Void>
    {
        struct PasswordChange: Encodable {
            var newPassword: String
            var logoutDevices: Bool?
        }

        let path: SafePath = "_matrix/client/v3/account/password"
        return self.startInteractiveAuth(
            body: PasswordChange(newPassword: newPassword, logoutDevices: logoutDevices)
        ) {
            client, body in try await client.send(.post(path.encoded, body: body))
        }
    }

    public func requestRegistrationEmailValidation(request: MPEmailValidationRequest) async throws
        -> MPValidationResponse
    {
        let path: SafePath = "_matrix/client/v3/register/email/requestToken"
        return try await self.send(.post(path.encoded, body: request)).value
    }

    public func requestAssociationEmailValidation(request: MPEmailValidationRequest) async throws
        -> MPValidationResponse
    {
        let path: SafePath = "_matrix/client/v3/account/3pid/email/requestToken"
        return try await self.send(.post(path.encoded, body: request)).value
    }

    public func requestPasswordResetEmailValidation(request: MPEmailValidationRequest) async throws
        -> MPValidationResponse
    {
        let path: SafePath = "_matrix/client/v3/account/password/email/requestToken"
        return try await self.send(.post(path.encoded, body: request)).value
    }

    public func requestRegistrationPhoneValidation(request: MPPhoneValidationRequest) async throws
        -> MPValidationResponse
    {
        let path: SafePath = "_matrix/client/v3/register/msisdn/requestToken"
        return try await self.send(.post(path.encoded, body: request)).value
    }

    public func requestAssociationPhoneValidation(request: MPPhoneValidationRequest) async throws
        -> MPValidationResponse
    {
        let path: SafePath = "_matrix/client/v3/account/3pid/msisdn/requestToken"
        return try await self.send(.post(path.encoded, body: request)).value
    }

    public func requestPasswordResetPhoneValidation(request: MPPhoneValidationRequest) async throws
        -> MPValidationResponse
    {
        let path: SafePath = "_matrix/client/v3/account/password/msisdn/requestToken"
        return try await self.send(.post(path.encoded, body: request)).value
    }

    public func getOpenIDToken(userId: String) async throws -> MPOpenIDToken {
        let path: SafePath = "_matrix/client/v3/user/\(userId)/openid/request_token"
        return try await self.send(.post(path.encoded)).value
    }
}
