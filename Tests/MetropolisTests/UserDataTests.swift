import Get
import SwiftyJSON
import XCTest

@testable import Metropolis

final class UserDataTests: XCTestCase {
    func testDisplayName() async throws {
        let newName = "New Display Name"
        let authClient = await getTestAuthClient()
        try await authClient.setDisplayName(userId: authClient.userId!, displayName: newName)

        let displayName = try await authClient.getDisplayName(userId: authClient.userId!)
        XCTAssertEqual(displayName, newName)

        let profile = try await authClient.getProfile(userId: authClient.userId!)
        XCTAssertEqual(profile.dictionaryValue["displayname"]!.stringValue, newName)
    }

    func testAvatarUrl() async throws {
        let newAvatar = URL(string: "https://example.com/avatar")!
        let authClient = await getTestAuthClient()
        try await authClient.setAvatarUrl(userId: authClient.userId!, avatarUrl: newAvatar)

        let avatarUrl = try await authClient.getAvatarUrl(userId: authClient.userId!)
        XCTAssertEqual(avatarUrl, newAvatar)

        let profile = try await authClient.getProfile(userId: authClient.userId!)
        XCTAssertEqual(URL(string: profile.dictionaryValue["avatar_url"]!.stringValue)!, newAvatar)
    }

    func testGetProfile() async throws {
        let authClient = await getTestAuthClient()
        _ = try await authClient.getProfile(userId: authClient.userId!)
    }

    func testPresence() async throws {
        let newPresence = MPUserPresence(presence: .offline, statusMsg: "zzz")
        let authClient = await getTestAuthClient()
        try await authClient.updatePresence(userId: authClient.userId!, presence: newPresence)
        let presence = try await authClient.getPresence(userId: authClient.userId!)
        XCTAssertEqual(presence.presence, newPresence.presence)
        XCTAssertEqual(presence.statusMsg, newPresence.statusMsg)
    }

    func testAccountData() async throws {
        let type = "swift.metropolis.test"
        let newData: [String: JSON] = ["client": "[metropolis]", "version": 1]
        let authClient = await getTestAuthClient()
        try await authClient.setAccountData(userId: authClient.userId!, type: type, data: newData)
        let data = try await authClient.getAccountData(userId: authClient.userId!, type: type)
        XCTAssertEqual(data.dictionaryValue, newData)
    }

    func testRoomAccountData() async throws {
        let type = "swift.metropolis.test"
        let newData: [String: JSON] = ["client": "[metropolis]", "version": 1]
        let authClient = await getTestAuthClient()

        let roomId = try await authClient.createRoom(room: MPRoomCreationRequest())
        try await authClient.setAccountData(
            userId: authClient.userId!, roomId: roomId, type: type, data: newData)
        let data = try await authClient.getAccountData(
            userId: authClient.userId!, roomId: roomId, type: type)
        XCTAssertEqual(data.dictionaryValue, newData)
    }

    func testAddTag() async throws {
        let tag = "thank you"
        let order: Float = 0.5
        let authClient = await getTestAuthClient()
        let room = MPRoomCreationRequest()
        let roomId = try await authClient.createRoom(room: room)
        _ = try await authClient.addTag(
            userId: authClient.userId!, roomId: roomId, tag: "thank you", order: order)
        let tags = try await authClient.getTags(userId: authClient.userId!, roomId: roomId)
        XCTAssertEqual(tags[tag]?.order, order)
    }

    func testDeleteTag() async throws {
        let tag = "thank you"
        let authClient = await getTestAuthClient()
        let room = MPRoomCreationRequest()
        let roomId = try await authClient.createRoom(room: room)
        _ = try await authClient.addTag(
            userId: authClient.userId!, roomId: roomId, tag: tag)
        _ = try await authClient.removeTag(userId: authClient.userId!, roomId: roomId, tag: tag)
        let tags = try await authClient.getTags(userId: authClient.userId!, roomId: roomId)
        XCTAssertNil(tags[tag])
    }
}
