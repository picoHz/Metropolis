import XCTest

@testable import Metropolis

final class RoomTests: XCTestCase {
    func testCreateRoom() async throws {
        let room = MPRoomCreationRequest(
            name: "The Grand Duke Pub",
            preset: .publicChat,
            roomVersion: "1",
            topic: "All about happy hour")
        _ = try await getTestAuthClient().createRoom(room: room)
    }

    func testUpgradeRoom() async throws {
        let newVersion = "2"
        let authClient = await getTestAuthClient()
        let room = MPRoomCreationRequest(roomVersion: "1")
        let roomId = try await authClient.createRoom(room: room)
        _ = try await authClient.upgradeRoom(roomId: roomId, newVersion: newVersion)
    }

    func testRoomVisiblity() async throws {
        let newVisibility = MPRoomVisibility.privateRoom
        let authClient = await getTestAuthClient()
        let room = MPRoomCreationRequest(visibility: .publicRoom)
        let roomId = try await authClient.createRoom(room: room)
        _ = try await authClient.setRoomVisibility(roomId: roomId, visibility: newVisibility)
        let visibility = try await authClient.getRoomVisibility(roomId: roomId)
        XCTAssertEqual(visibility, newVisibility)
    }

    func testGetLocalRoomAliases() async throws {
        let authClient = await getTestAuthClient()
        let room = MPRoomCreationRequest()
        let roomId = try await authClient.createRoom(room: room)
        _ = try await authClient.getLocalRoomAliases(roomId: roomId)
    }

    func testGetJoinedRooms() async throws {
        _ = try await getTestAuthClient().getJoinedRooms()
    }

    func testGetPublicRooms() async throws {
        let authClient = await getTestAuthClient()
        let room = MPRoomCreationRequest(visibility: .publicRoom)
        _ = try await authClient.createRoom(room: room)
        let stream = try await authClient.getPublicRooms(limit: 5)
        for try await _ in stream {}

        var iter = stream.makeAsyncIterator()
        while try await iter.next() != nil {}
    }

    func testGetJoinedUsers() async throws {
        let authClient = await getTestAuthClient()
        let room = MPRoomCreationRequest()
        let roomId = try await authClient.createRoom(room: room)
        _ = try await authClient.getJoinedUsers(roomId: roomId)
    }

    func testGetRoomMembers() async throws {
        let authClient = await getTestAuthClient()
        let room = MPRoomCreationRequest()
        let roomId = try await authClient.createRoom(room: room)
        _ = try await authClient.getRoomMembers(roomId: roomId)
    }
}
