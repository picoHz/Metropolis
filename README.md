<div align="center">
<h1>Metropolis</h1>
        
<a href="https://unsplash.com/photos/ZETyWNCn5bw">
<img alt="metropolis" src="metropolis.png" height="100" />
</a>

Async/await-based Matrix client library in Swift

<a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-56f.svg" alt="MIT License"></a>
<a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-5.5-F05138?logo=swift&logoColor=white" alt="Swift 5.5"></a>

</div>

<div align="center">
<h4>🚧 This package is not production-ready 🚧</h4>  
</div>

- [About](#about)
- [Supported Features](#supported-features)
- [Installation](#installation)
- [Usage](#usage)
  - [Anonymous Access](#anonymous-access)
  - [Authorization](#authorization)
  - [User-Interactive Authentication](#user-interactive-authentication)
  - [Custom Authorization Method](#custom-authorization-method)
  - [Pagination](#pagination)
  - [Media Downloading and Uploading](#media-downloading-and-uploading)
  - [Handling Schema-free JSON Objects](handling-schema-free-json-objects)
- [Testing](#testing)
- [License](#license)

## About

Metropolis is an asynchronous client library for [Matrix Messaging Protocol](https://matrix.org/)
written in pure Swift.
It provides a low-level wrapper for client-server API integrated with the Swift type system.

### What is Matrix?

> Matrix is an open standard for interoperable, decentralised, real-time communication over IP. It can be used to power Instant Messaging, VoIP/WebRTC signalling, Internet of Things communication - or anywhere you need a standard HTTP API for publishing and subscribing to data whilst tracking the conversation history.

<div align="right">https://matrix.org/faq</div>

## Supported Features

- [x] Account Management
- [x] Session Management
- [x] Device Management
- [x] Room Directory
- [x] Room Participation
- [x] Presence
- [x] Media
- [x] User Data
- [x] User Directory
- [x] Full Text Search
- [ ] Push Notifications
- [ ] End-To-End Encryption

## Installation

### Swift Package Manager

Metropolis supports installation via Swift Package Manager.
To add the package as your project's dependency, put the repository url into the dependencies section in `Package.swift` like this:

```swift
// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "PackageName",
    dependencies: [
        .package(url: "https://github.com/picoHz/Metropolis.git", .branch("main"))
    ]
)
```
You can also add dependencies from Xcode.
https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app

## Usage

Note that this library is basically just a thin wrapper of Matrix client-server API and does not provide high-level functionalities, so you need to read the [Matrix Specification](https://spec.matrix.org/v1.1/client-server-api) to understand how these endpoints work.

### Anonymous Access

Public endpoints are accessible without login.

```swift
let client = try MPClient(url: URL(string: "https://matrix.org")!)
try await client.checkUsernameAvailability(username: "metro")
```

### Authorization

```swift 
let client = try MPClient(url: URL(string: "https://matrix.org")!)

let method = MPPasswordAuth(
    identifier: .user(user: "metro"),
    password: "pass")

let authClient = try await client.login(method: method)
```

#### Custom Authorization Method

`client.login()` method accepts any objects that conform to `MPAuthMethod` protocol.

```swift
public protocol MPAuthMethod: Encodable {
    var type: String { get }
}
```

```swift
public struct CustomAuth: MPAuthMethod {
    let type: String = "com.example.custom"
    var customName: String
    var customList: [String]
}

let authClient = try await client.login(method: CustomAuth(customName: "aaa", customList: ["bbb"]))

```

The property names will be converted to snakecase.
For example, `CustomAuth` will be encoded into the following JSON.

```json
{
    "type": "com.example.custom",
    "custom_name": "aaa",
    "custom_list": ["bbb"]
}
```

### User-Interactive Authentication

```swift
var interactiveAuth = try await authClient.changePassword(newPassword: "new_password")

guard case .failure(var state) = try await interactiveAuth.authenticate(method: method) {
    return
}

while true {
    if !state.flows[0].stages.contains("m.login.password") {
        // Password authentication is not supported.
        break
    }

    // Ask user to authenticate.
    let method = MPPasswordAuth(
        identifier: .user(user: "metro"),
        password: "old_password")

    switch try await interactiveAuth.authenticate(method: method, state: state) {
    case .success(_):
        break
    case .failure(let newState):
        // Authentication failed or needs additional authentication.
        state = newState
        continue
    }
}
```

### Pagination

Paginated endpoints return a stream object that implements [`AsyncSequence`](https://developer.apple.com/documentation/swift/asyncsequence).

```swift
let stream = try await client.getPublicRooms(limit: 100)

for try await chunk in stream {
    // Fetch results.
}

// Iterate manually.
var iter = stream.makeAsyncIterator()
let chunk = try await iter.next()

// Get an estimated room count from the iterator.
iter.totalRoomCountEstimate

// Resume the iteration using a pagination token.
let newStream = try await client.getPublicRooms(limit: 100, since: iter.nextBatch)
```

#### Backward Pagination

Public Room Directory supports bidirectional pagination.
You can make a backward iterator using `prevBatch` token.

```swift
let stream = try await client.getPublicRooms(limit: 100)

var iter = stream.makeAsyncIterator()
while try await iter.next() != nil {}

let backwardStream = try await client.getPublicRooms(limit: 100, since: iter.prevBatch)
for try await chunk in backwardStream {
    // Fetch backward results.
}
```

### Media Downloading and Uploading

Metropolis does not directly provide methods to download/upload media.
Instead, it provides the following methods returning URLs for downloading or uploading so you can use your favorite HTTP client library to handle them.

```swift
public protocol MPMediaAPI {
    func getMediaDownloadUrl(serverName: String, mediaId: String) -> URL
    func getMediaThumbnailUrl(serverName: String, mediaId: String) -> URL
    func getMediaUploadUrl() -> URL
}
```

### Handling Schema-free JSON Objects

Some endpoints use unstructured (a.k.a schema-free) JSON objects.
Metropolis handles them with [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON).

```swift
let profile: JSON = try await client.getProfile(userId: "@metro@example.com")

// Access as a JSON object
if let displayName = profile.dictionaryValue["displayname"].string {
    print(displayName)
}

// Decode as a struct
struct Profile: Decodable { var displayname: String }
let data = try JSONDecoder().decode(Profile.self, from: profile.rawData())
print(data.displayname)
```

## Testing

To run tests, you need running a matrix instance on `localhost:8080`.

The following commands run up-to-date demo server instances.
Please check [Synapse Documantation](https://github.com/matrix-org/synapse#quick-start)
for more information about Matrix servers.

```bash
git clone https://github.com/matrix-org/synapse.git
cd synapse

python3 -m venv ./env
source ./env/bin/activate
pip install -e ".[all,dev]"

./demo/start.sh
```

If there is already a running matrix instance on `localhost:8080`,
you can simply run `swift test`.

## License

Metropolis is released under the MIT license.

Headline Photo by [Leonhard Niederwimmer](https://unsplash.com/@lnlnln) on [Unsplash](https://unsplash.com/photos/ZETyWNCn5bw)
