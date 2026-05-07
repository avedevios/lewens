# lewensTests

Tests are written using **Swift Testing** (iOS 16+, available from Xcode 16).

## Running tests

Press `Cmd+U` in Xcode — the `lewensTests` target already exists in the project.

If new files are not picked up automatically:
1. Right-click the `lewensTests` folder in Xcode
2. Add Files → select the `Helpers/`, `Models/`, `Services/`, `Utils/` folders
3. Make sure the target is `lewensTests`, not `lewens`

## Structure

```
lewensTests/
├── Helpers/
│   ├── MockURLProtocol.swift       — URLSession interceptor for stubbed responses
│   └── UserFixtures.swift          — test data factories
├── Models/
│   ├── UserTests.swift             — fullName (parameterized), displayName, Codable
│   ├── CustomerTests.swift         — Customer, PageableResponse, available flag
│   └── DownloadItemTests.swift     — flat/nested/deep, Codable, array decode
├── Services/
│   ├── TokenStoreTests.swift       — save/load/delete/overwrite User, Keychain no-crash
│   ├── UserInfoServiceTests.swift  — /userinfo parsing, HTTP errors (parameterized), network
│   └── DownloadsServiceTests.swift — URL extraction, both categories, auth header, errors
└── Utils/
    ├── KeychainHelperTests.swift        — save/read/delete, account and service isolation
    ├── LocalizationManagerTests.swift   — languages, keys, persistence (parameterized)
    ├── JSONLoaderTests.swift            — missing file, wrong type
    └── StringLocalizationTests.swift    — .localized, .localized(with:)
```

## Coverage

| Component | Tests | Notes |
|---|---|---|
| `User` | 9 | parameterized `fullName` |
| `Customer` | 5 | parameterized `available` flag |
| `DownloadItem` | 6 | nesting up to 3 levels |
| `TokenStore` | 9 | isolated `UserDefaults` |
| `UserInfoService` | 8 | parameterized HTTP errors (401/403/404/500/503) |
| `DownloadsService` | 11 | `.serialized` due to `@MainActor` |
| `KeychainHelper` | 8 | `.serialized`, isolation |
| `LocalizationManager` | 10 | parameterized languages and names |
| `JSONLoader` | 4 | graceful skip if file not in bundle |
| `String.localized` | 5 | format strings |

## Key patterns

**Parameterized tests** — instead of duplication:
```swift
@Test("HTTP errors", arguments: [401, 403, 404, 500, 503])
func throwsOnHTTPError(statusCode: Int) async { ... }
```

**MockURLProtocol** — intercepts network requests without a real server:
```swift
MockURLProtocol.requestHandler = { request in
    (makeResponse(url: request.url!, statusCode: 200), data)
}
```

**`.serialized`** — for tests sharing global state (Keychain, `LocalizationManager.shared`):
```swift
@Suite("KeychainHelper", .serialized)
```
