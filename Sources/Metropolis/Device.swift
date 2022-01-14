import Foundation

public protocol MPDeviceAPI {
    /// List registered devices for the current user.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#get_matrixclientv3devices) for
    /// more informataion.
    func getDevices() async throws -> [MPDeviceState]

    /// Gets information on a single device, by device id.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#get_matrixclientv3devicesdeviceid) for
    /// more informataion.
    func getDevice(deviceId: String) async throws -> MPDeviceState

    /// Update a device.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#put_matrixclientv3devicesdeviceid) for
    /// more informataion.
    func updateDevice(deviceId: String, displayName: String?) async throws

    /// Delete a device.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#delete_matrixclientv3devicesdeviceid) for
    /// more informataion.
    func deleteDevice(deviceId: String) async throws -> MPInteractiveAuthSession<Void>

    /// Bulk deletion of devices.
    ///
    /// See [Specification](https://spec.matrix.org/v1.1/client-server-api/#put_matrixclientv3devicesdeviceid) for
    /// more informataion.
    func deleteDevices(devices: [String]) async throws -> MPInteractiveAuthSession<Void>
}

public struct MPDeviceState: Decodable {
    public var deviceId: String
    public var displayName: String?
    public var lastSeenIp: String?
    public var lastSeenTs: Int?
}

extension MPClient: MPDeviceAPI {
    public func getDevices() async throws -> [MPDeviceState] {
        struct DeviceList: Decodable {
            var devices: [MPDeviceState]
        }

        let path: SafePath = "_matrix/client/v3/devices"
        let list: DeviceList = try await self.send(.get(path.encoded)).value
        return list.devices
    }

    public func getDevice(deviceId: String) async throws -> MPDeviceState {
        let path: SafePath = "_matrix/client/v3/devices/\(deviceId)"
        return try await self.send(.get(path.encoded)).value
    }

    public func updateDevice(deviceId: String, displayName: String? = nil) async throws {
        struct Device: Encodable {
            var displayName: String?
        }

        let path: SafePath = "_matrix/client/v3/devices/\(deviceId)"
        try await self.send(.put(path.encoded, body: Device(displayName: displayName)))
    }

    public func deleteDevice(deviceId: String) -> MPInteractiveAuthSession<Void> {
        let path: SafePath = "_matrix/client/v3/devices/\(deviceId)"
        return self.startInteractiveAuth {
            client, body in try await client.send(.delete(path.encoded, body: body))
        }
    }

    public func deleteDevices(devices: [String]) -> MPInteractiveAuthSession<Void> {
        struct DeviceList: Encodable {
            var devices: [String]
        }

        let path: SafePath = "_matrix/client/v3/delete_devices"
        return self.startInteractiveAuth(body: DeviceList(devices: devices)) {
            client, body in try await client.send(.post(path.encoded, body: body))
        }
    }
}
