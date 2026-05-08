да# lewensTests

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
│   ├── MockURLProtocol.swift          — URLSession interceptor for stubbed responses
│   └── UserFixtures.swift             — test data factories
├── Models/
│   ├── UserTests.swift                — fullName, displayName, Equatable, Codable, Unicode
│   ├── CustomerTests.swift            — Customer, SortInfo, PageableInfo, PageableResponse
│   ├── DownloadItemTests.swift        — flat/nested/deep, url+children, empty children
│   └── KeycloakConfigTests.swift      — URL building, scopes, non-empty values
├── Services/
│   ├── TokenStoreTests.swift          — save/load/delete/overwrite, Unicode, isolation
│   ├── KeycloakServiceTests.swift     — logout, clearStoredData, handleOAuthCallback, login
│   ├── NetworkTests.swift             — UserInfoService, DownloadsService, downloadFile
│   └── NotificationTests.swift        — notification names, logout posts, userInfo
└── Utils/
    ├── KeychainHelperTests.swift       — save/read/delete, isolation
    ├── LocalizationManagerTests.swift  — languages, keys, persistence
    ├── JSONLoaderTests.swift           — missing file, wrong type, invalid JSON
    ├── LSSColorsTests.swift            — RGB regression, distinctness
    ├── StringLocalizationTests.swift   — .localized, .localized(with:)
    └── VideoResourceLoaderDelegateTests.swift — URL scheme, Range header, DownloadCategory
```

## Coverage

| Component | Tests | Notes |
|---|---|---|
| `User` | 13 | Equatable, Unicode, empty username edge case |
| `Customer` | 8 | SortInfo, PageableInfo, multiple elements |
| `DownloadItem` | 9 | url+children, empty children array |
| `KeycloakConfig` | 8 | URL building, scopes, redirectURI scheme |
| `TokenStore` | 12 | Unicode, legacy key cleanup, instance isolation |
| `KeycloakService` | 8 | logout, clearStoredData, handleOAuthCallback |
| `UserInfoService` | 8 | HTTP errors (parameterized), network, headers |
| `DownloadsService` | 16 | URL extraction, fetch, downloadFile |
| `NotificationCenter` | 5 | names, logout notification, userInfo |
| `KeychainHelper` | 8 | save/read/delete, isolation |
| `LocalizationManager` | 12 | languages, keys, persistence |
| `JSONLoader` | 5 | missing file, wrong type, invalid JSON |
| `LSSColors` | 9 | RGB regression, distinctness |
| `String.localized` | 5 | format strings, language switching |
| `VideoResourceLoaderDelegate` | 7 | URL scheme, Range header, Content-Range |
| `DownloadCategory` | 3 | both cases exist, are distinct |

**Total: ~130 tests**

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

**`@MainActor`** — for tests touching `@Published` properties or `LocalizationManager`:
```swift
@Suite("LocalizationManager", .serialized)
@MainActor
struct LocalizationManagerTests { ... }
```
