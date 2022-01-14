import Foundation

@testable import Metropolis

func AssertThrowsStandardError(errcode: String, _ block: () async throws -> Void) async throws {
    do {
        try await block()
    }
    catch let err as MPStandardError where err.errcode == errcode {
        return
    }
    throw AssertionError.shouldThrow(errcode)
}

enum AssertionError: Error {
    case shouldThrow(String)
}

actor TestAccount {
    let url: URL
    let anonClient: MPClient
    var authClient: MPClient?

    init(url: URL) {
        self.url = url
        self.anonClient = try! MPClient(url: url)
    }

    func getAuthClient() async throws -> MPClient {
        if authClient == nil {
            let anon = try MPClient(url: url)
            let request = MPRegistrationRequest(password: testPassword)
            let interactiveAuth = anon.registerUser(request: request)
            if case .failure(let state) = try await interactiveAuth.authenticate() {
                if case .success(let response) = try await interactiveAuth.authenticate(
                    method: MPDummyAuth(), state: state)
                {
                    authClient = try MPClient(
                        client: RESTClient(baseUrl: url, accessToken: response.accessToken),
                        deviceId: response.deviceId,
                        userId: response.userId)
                }
            }
            _ = try await authClient!.createRoom(room: MPRoomCreationRequest())
        }
        return authClient!
    }
}

let testAccount: TestAccount = TestAccount(url: testServerUrl)

let testPassword: String = "test_PNZkPoKDm6S7WKcbQf42xmAbvvM"
let testServerUrl: URL = URL(string: "http://localhost:8080")!

func getAnonClient() -> MPClient {
    return testAccount.anonClient
}

func getTestAuthClient() async -> MPClient {
    try! await testAccount.getAuthClient()
}
