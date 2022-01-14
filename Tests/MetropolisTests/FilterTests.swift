import XCTest

@testable import Metropolis

final class FilterTests: XCTestCase {
    func testUploadDownloadFilter() async throws {
        let filter = MPFilter(
            eventFields: ["type", "content", "sender"],
            eventFormat: .client,
            presence: MPFilter.EventFilter(notSenders: ["@alice:example.com"]))

        let authClient = await getTestAuthClient()
        let userId = authClient.userId!

        let filterId = try await authClient.uploadFilter(userId: userId, filter: filter)
        let downloadedFilter = try await authClient.downloadFilter(
            userId: userId, filterId: filterId)
        XCTAssertEqual(downloadedFilter, downloadedFilter)
    }
}
