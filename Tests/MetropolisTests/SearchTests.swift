import XCTest

@testable import Metropolis

final class SearchTests: XCTestCase {
    func testSearchUserDiractory() async throws {
        let searchTerm = "aaa"
        let acceptLanguage = "fr-CH, fr;q=0.9, en;q=0.8, de;q=0.7, *;q=0.5"
        _ = try await getTestAuthClient()
            .searchUserDirectory(
                searchTerm: searchTerm,
                limit: 100,
                acceptLanguage: acceptLanguage)
    }

    func testSearchFullText() async throws {
        let searchQuery = MPFullTextSearchQuery(
            roomEvents: MPFullTextSearchQuery.RoomEvents(searchTerm: "hello"))
        let stream = await getTestAuthClient().searchFullText(searchQuery: searchQuery)
        for try await _ in stream {}
    }
}
