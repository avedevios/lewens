//
//  NotificationTests.swift
//  lewensTests
//
//  Tests for NotificationCenter events posted by KeycloakService.
//

import Testing
import Foundation
@testable import lewens

@Suite("Notification Names")
struct NotificationNamesTests {

    @Test("userDidLogin notification name is non-empty")
    func userDidLoginName() {
        #expect(!Notification.Name.userDidLogin.rawValue.isEmpty)
    }

    @Test("userDidLogout notification name is non-empty")
    func userDidLogoutName() {
        #expect(!Notification.Name.userDidLogout.rawValue.isEmpty)
    }

    @Test("userDidLogin and userDidLogout have different names")
    func namesAreDistinct() {
        #expect(Notification.Name.userDidLogin != Notification.Name.userDidLogout)
    }
}

@Suite("NotificationCenter integration", .serialized)
@MainActor
struct NotificationIntegrationTests {

    @Test("userDidLogout is posted when logout is called")
    func logoutPostsNotification() async {
        var received = false
        let observer = NotificationCenter.default.addObserver(
            forName: .userDidLogout,
            object: nil,
            queue: .main
        ) { _ in received = true }
        defer { NotificationCenter.default.removeObserver(observer) }

        KeycloakService.shared.logout()
        try? await Task.sleep(nanoseconds: 50_000_000)

        #expect(received == true)
    }

    @Test("userDidLogout notification carries no userInfo")
    func logoutNotificationHasNoUserInfo() async {
        var notificationUserInfo: [AnyHashable: Any]? = ["placeholder": true]

        let observer = NotificationCenter.default.addObserver(
            forName: .userDidLogout,
            object: nil,
            queue: .main
        ) { notification in
            notificationUserInfo = notification.userInfo
        }
        defer { NotificationCenter.default.removeObserver(observer) }

        KeycloakService.shared.logout()
        try? await Task.sleep(nanoseconds: 50_000_000)

        #expect(notificationUserInfo == nil)
    }

    @Test("Can observe userDidLogin notification")
    func canObserveLoginNotification() {
        // Just verify the notification can be observed without crashing
        let observer = NotificationCenter.default.addObserver(
            forName: .userDidLogin,
            object: nil,
            queue: .main
        ) { _ in }
        NotificationCenter.default.removeObserver(observer)
    }

    @Test("Manually posting userDidLogin delivers correct userInfo")
    func manualLoginNotificationUserInfo() async {
        let user = User.fixture()
        var receivedUser: User?

        let observer = NotificationCenter.default.addObserver(
            forName: .userDidLogin,
            object: nil,
            queue: .main
        ) { notification in
            receivedUser = notification.userInfo?["user"] as? User
        }
        defer { NotificationCenter.default.removeObserver(observer) }

        NotificationCenter.default.post(
            name: .userDidLogin,
            object: nil,
            userInfo: ["user": user]
        )

        try? await Task.sleep(nanoseconds: 50_000_000)

        #expect(receivedUser?.id    == user.id)
        #expect(receivedUser?.email == user.email)
    }
}
