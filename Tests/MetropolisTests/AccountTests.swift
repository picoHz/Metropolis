import XCTest

@testable import Metropolis

final class AccountTests: XCTestCase {
    func testCheckUsernameAvailability() async throws {
        try await getAnonClient().checkUsernameAvailability(username: "available_username")
    }

    func testGetCurrentUser() async throws {
        let authClient = await getTestAuthClient()
        let currentUser = try await authClient.getCurrentUser()
        XCTAssertEqual(currentUser.userId, authClient.userId)
        XCTAssertEqual(currentUser.deviceId, authClient.deviceId)
    }

    func testGetThirdPartyIdentifiers() async throws {
        let authClient = await getTestAuthClient()
        _ = try await authClient.getThirdPartyIdentifiers()
    }

    func testChangePassword() async throws {
        let authClient = await getTestAuthClient()
        let interactiveAuth = authClient.changePassword(newPassword: testPassword)
        guard case .failure(let state) = try await interactiveAuth.authenticate() else {
            XCTFail()
            return
        }
        XCTAssertTrue(state.flows[0].stages.contains("m.login.password"))
        let method = MPPasswordAuth(
            identifier: .user(user: authClient.userId!),
            password: testPassword)
        let result = try await interactiveAuth.authenticate(method: method, state: state)
        _ = try result.get()
    }

    func testDeactivateUser() async throws {
        let anon = getAnonClient()
        let request = MPRegistrationRequest(password: testPassword)
        let interactiveAuth = anon.registerUser(request: request)
        guard case .failure(let state) = try await interactiveAuth.authenticate() else {
            XCTFail()
            return
        }
        guard
            case .success(let response) = try await interactiveAuth.authenticate(
                method: MPDummyAuth(), state: state)
        else {
            XCTFail()
            return
        }

        let method = MPPasswordAuth(
            identifier: .user(user: response.userId),
            password: testPassword)
        let authClient = try await anon.login(method: method)
        let deactivationAuth = authClient.deactivateUser()
        guard case .failure(let state) = try await deactivationAuth.authenticate() else {
            XCTFail()
            return
        }
        let result = try await deactivationAuth.authenticate(method: method, state: state)
        _ = try result.get()
    }
}
