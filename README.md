<div align="center">
  <img src="design/lewens_logo_small.png" alt="Lewens Logo" width="180" />
  <h1>Lewens iOS</h1>
  <p>Production-focused SwiftUI app with enterprise Keycloak authentication</p>
</div>

---

## Overview

`Lewens iOS` is a portfolio project that demonstrates how to build a secure, scalable mobile app around modern iOS architecture and enterprise identity requirements.

This app was built as an **MVP for a German company**, with a focus on delivering business value quickly while keeping the codebase production-ready.

The primary focus is robust **Keycloak integration** (token-based auth flow, protected API access, and auth-aware app state), backed by a maintainable Swift codebase and a growing automated test suite.

## Keycloak Integration Focus

- Secure sign-in flow designed around Keycloak/OIDC concepts.
- Access-token-based API authorization for protected endpoints.
- Centralized auth handling to keep networking and UI state consistent.
- Architecture that supports extending identity flows (refresh, logout, role-based behavior).

## Tech Stack

- **Language:** Swift 5
- **UI:** SwiftUI
- **Architecture:** MVVM with service-oriented modules
- **Concurrency:** async/await + MainActor where UI safety is required
- **Networking:** URLSession-based services with explicit decoding/error handling
- **Reactive state:** Combine-powered observable service state
- **Tooling:** Xcode, XCTest/Swift Testing, GitHub-based workflow

## Testing

The project includes unit and state-focused tests to validate core behavior and reduce regression risk:

- Network service tests (success, error, edge cases, partial failures).
- UI state tests for loading, empty, content, and error scenarios.
- Mocked URL loading for deterministic API behavior in tests.
- Ongoing expansion of coverage for auth and data flow reliability.

## What This Project Demonstrates

- Integration of enterprise authentication into a SwiftUI app.
- Clean separation between view logic, app state, and network layer.
- Practical testing strategy for asynchronous and state-driven code.
- Production-minded engineering: readability, resilience, and maintainability.

## Run Locally

1. Open `lewens.xcodeproj` in Xcode.
2. Select the `lewens` target.
3. Build and run on a simulator or device (iOS 16+).

## License

Proprietary - © Lewens Markisen. All rights reserved.