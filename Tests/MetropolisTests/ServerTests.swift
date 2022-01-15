import XCTest

@testable import Metropolis

final class ServerTests: XCTestCase {
    func testGetServerVersions() async throws {
        _ = try await getAnonClient().getServerVersions()
    }

    func testGetTURNServerCredentials() async throws {
        try await AssertThrowsStandardError(errcode: "M_MISSING_TOKEN") {
            _ = try await getAnonClient().getTURNServerCredentials()
        }
        _ = try await getTestAuthClient().getTURNServerCredentials()
    }

    func testGetCapabilities() async throws {
        try await AssertThrowsStandardError(errcode: "M_MISSING_TOKEN") {
            _ = try await getAnonClient().getCapabilities()
        }
        _ = try await getTestAuthClient().getCapabilities()
    }
}
