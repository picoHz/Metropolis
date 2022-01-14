import XCTest

@testable import Metropolis

final class EventTests: XCTestCase {
    func testSync() async throws {
        let filter = MPFilter(
            eventFields: ["type", "content", "sender"],
            eventFormat: .client,
            presence: MPFilter.EventFilter(notSenders: ["@alice:example.com"]))
        let stream = try await getTestAuthClient().sync(filter: filter)
        for try await _ in stream {}
    }

    func testInformTyping() async throws {
        let authClient = await getTestAuthClient()
        let room = MPRoomCreationRequest()
        let roomId = try await authClient.createRoom(room: room)
        try await authClient.informTyping(
            roomId: roomId,
            userId: authClient.userId!,
            typing: true,
            timeout: 100)
    }

    func testGetStateEvents() async throws {
        let authClient = await getTestAuthClient()
        let room = MPRoomCreationRequest()
        let roomId = try await authClient.createRoom(room: room)
        _ = try await authClient.getStateEvents(roomId: roomId)
    }
}
