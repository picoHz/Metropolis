import XCTest

@testable import Metropolis

final class AdminTests: XCTestCase {
    func testGetUserInfo() async throws {
        let authClient = await getTestAuthClient()
        _ = try await authClient.getUserInfo(userId: authClient.userId!)
    }
}
