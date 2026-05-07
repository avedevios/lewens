//
//  KeycloakService.swift
//  lewens
//
//  Responsible for the OAuth browser flow, token refresh, and session state.
//  Persistence is delegated to TokenStore; user info fetching to UserInfoService.
//

import Foundation
import AppAuth

class KeycloakService: NSObject, ObservableObject {

    // MARK: - Published state

    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Singleton

    static let shared = KeycloakService()

    // MARK: - Dependencies

    private let tokenStore = TokenStore()
    private let userInfoService = UserInfoService()

    // MARK: - Private state

    private var authState: OIDAuthState?
    private var currentAuthorizationFlow: OIDExternalUserAgentSession?

    // MARK: - Public token accessor

    /// Returns the current access token. Restores from Keychain if not in memory.
    /// Note: Keychain read is synchronous — call from a background context when possible.
    var currentUserToken: String? {
        if let token = authState?.lastTokenResponse?.accessToken {
            return token
        }
        if let restored = tokenStore.loadAuthState() {
            self.authState = restored
            return restored.lastTokenResponse?.accessToken
        }
        return nil
    }

    // MARK: - Init

    private override init() {
        super.init()
        restoreSessionInBackground()
    }

    // MARK: - Login

    func login(username: String = "", password: String = "") {
        isLoading = true
        errorMessage = nil
        clearStoredData()
        startAuthorizationFlow()
    }

    // MARK: - Logout

    func logout() {
        NotificationCenter.default.post(name: .userDidLogout, object: nil)
        authState = nil
        currentAuthorizationFlow = nil
        currentUser = nil
        isAuthenticated = false
        tokenStore.clearAll()

        // Clear Keycloak-domain cookies only
        if let serverURL = URL(string: KeycloakConfig.serverURL),
           let cookies = HTTPCookieStorage.shared.cookies(for: serverURL) {
            cookies.forEach { HTTPCookieStorage.shared.deleteCookie($0) }
        }
    }

    // MARK: - OAuth callback

    func handleOAuthCallback(url: URL) {
        guard let currentFlow = currentAuthorizationFlow else { return }
        if currentFlow.resumeExternalUserAgentFlow(with: url) {
            currentAuthorizationFlow = nil
        } else {
            errorMessage = "Authentication failed"
            isLoading = false
        }
    }

    // MARK: - Token refresh

    func refreshToken() {
        guard let authState else { return }

        // Skip if token is still valid
        if let expiry = authState.lastTokenResponse?.accessTokenExpirationDate,
           expiry > Date() {
            return
        }

        authState.performAction { [weak self] _, _, error in
            DispatchQueue.main.async {
                if let error {
                    #if DEBUG
                    print("Token refresh failed: \(error.localizedDescription)")
                    #endif
                    self?.logout()
                } else {
                    #if DEBUG
                    print("✅ Token refreshed")
                    #endif
                    if let state = self?.authState {
                        self?.tokenStore.saveAuthState(state)
                    }
                }
            }
        }
    }

    // MARK: - Clear stored data (pre-login reset)

    func clearStoredData() {
        tokenStore.clearAll()
        authState = nil
        currentUser = nil
        isAuthenticated = false
        isLoading = false
        currentAuthorizationFlow = nil

        if let serverURL = URL(string: KeycloakConfig.serverURL),
           let cookies = HTTPCookieStorage.shared.cookies(for: serverURL) {
            cookies.forEach { HTTPCookieStorage.shared.deleteCookie($0) }
        }
    }

    // MARK: - Private helpers

    private func restoreSessionInBackground() {
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else { return }

            // Restore user from UserDefaults (fast)
            if let user = self.tokenStore.loadUser() {
                await MainActor.run {
                    self.currentUser = user
                    self.isAuthenticated = true
                }
            }

            // Restore auth state from Keychain
            if let state = self.tokenStore.loadAuthState() {
                await MainActor.run { self.authState = state }
            }

            // Refresh token in background after a short delay
            try? await Task.sleep(nanoseconds: 500_000_000)
            await MainActor.run { self.refreshToken() }
        }
    }

    private func startAuthorizationFlow() {
        guard let authEndpoint = URL(string: KeycloakConfig.authorizationEndpoint),
              let tokenEndpoint = URL(string: KeycloakConfig.tokenEndpoint),
              let redirectURI = URL(string: KeycloakConfig.redirectURI) else {
            errorMessage = "Invalid Keycloak configuration"
            isLoading = false
            return
        }

        let configuration = OIDServiceConfiguration(
            authorizationEndpoint: authEndpoint,
            tokenEndpoint: tokenEndpoint
        )

        let request = OIDAuthorizationRequest(
            configuration: configuration,
            clientId: KeycloakConfig.clientId,
            scopes: KeycloakConfig.scopes,
            redirectURL: redirectURI,
            responseType: OIDResponseTypeCode,
            additionalParameters: ["prompt": "login", "max_age": "0"]
        )

        presentAuthorizationFlow(request: request)
    }

    private func presentAuthorizationFlow(request: OIDAuthorizationRequest) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootVC = window.rootViewController,
              let agent = OIDExternalUserAgentIOS(presenting: rootVC) else {
            errorMessage = "Unable to present authorization flow"
            isLoading = false
            return
        }

        currentAuthorizationFlow = OIDAuthState.authState(
            byPresenting: request,
            externalUserAgent: agent
        ) { [weak self] authState, error in
            DispatchQueue.main.async {
                self?.currentAuthorizationFlow = nil
                if let authState {
                    self?.handleSuccessfulAuth(authState: authState)
                } else {
                    self?.errorMessage = "Authentication failed: \(error?.localizedDescription ?? "Unknown error")"
                    self?.isLoading = false
                }
            }
        }
    }

    private func handleSuccessfulAuth(authState: OIDAuthState) {
        self.authState = authState

        guard let accessToken = authState.lastTokenResponse?.accessToken else {
            errorMessage = "No access token received"
            isLoading = false
            return
        }

        #if DEBUG
        print("🔑 Access Token received")
        #endif

        Task { @MainActor in
            do {
                let user = try await userInfoService.fetchUserInfo(accessToken: accessToken)
                self.currentUser = user
                self.isAuthenticated = true
                self.isLoading = false
                self.tokenStore.saveAuthState(authState)
                self.tokenStore.saveUser(user)
                NotificationCenter.default.post(
                    name: .userDidLogin,
                    object: nil,
                    userInfo: ["user": user]
                )
            } catch {
                self.errorMessage = "Failed to fetch user info: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
}
