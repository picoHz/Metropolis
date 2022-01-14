import XCTest

@testable import Metropolis

final class DeviceTests: XCTestCase {
    func testGetDevices() async throws {
        _ = try await getTestAuthClient().getDevices()
    }

    func testGetDevice() async throws {
        let devices = try await getTestAuthClient().getDevices()
        let deviceId = devices[0].deviceId
        let device = try await getTestAuthClient().getDevice(deviceId: deviceId)
        XCTAssertEqual(device.deviceId, deviceId)
    }

    func testUpdateDevice() async throws {
        let devices = try await getTestAuthClient().getDevices()
        let deviceId = devices[0].deviceId
        let newDisplayName = "New Display Name"
        _ = try await getTestAuthClient()
            .updateDevice(deviceId: deviceId, displayName: newDisplayName)
        let device = try await getTestAuthClient().getDevice(deviceId: deviceId)
        XCTAssertEqual(device.displayName, newDisplayName)
    }

    func testdeleteDevice() async throws {
        let userId = await getTestAuthClient().userId!
        let client = try MPClient(url: testServerUrl)
        let method = MPPasswordAuth(identifier: .user(user: userId), password: testPassword)
        let authClient = try await client.login(method: method)

        let interactiveAuth = authClient.deleteDevice(deviceId: authClient.deviceId!)
        guard case .failure(let state) = try await interactiveAuth.authenticate() else {
            XCTFail()
            return
        }
        let result = try await interactiveAuth.authenticate(method: method, state: state)
        _ = try result.get()

        try await AssertThrowsStandardError(errcode: "M_UNKNOWN_TOKEN") {
            _ = try await authClient.getCapabilities()
        }
    }

    func testdeleteDevices() async throws {
        let userId = await getTestAuthClient().userId!
        let client = try MPClient(url: testServerUrl)
        let method = MPPasswordAuth(identifier: .user(user: userId), password: testPassword)
        let authClient = try await client.login(method: method)

        let interactiveAuth = authClient.deleteDevices(devices: [authClient.deviceId!])
        guard case .failure(let state) = try await interactiveAuth.authenticate() else {
            XCTFail()
            return
        }
        let result = try await interactiveAuth.authenticate(method: method, state: state)
        _ = try result.get()

        try await AssertThrowsStandardError(errcode: "M_UNKNOWN_TOKEN") {
            _ = try await authClient.getCapabilities()
        }
    }
}
