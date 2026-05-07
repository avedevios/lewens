//
//  UserInfoService.swift
//  lewens
//
//  Fetches and parses the Keycloak /userinfo endpoint.
//

import Foundation

final class UserInfoService {

    private let session: URLSession
    private let userInfoURL: URL

    init(session: URLSession = .shared, userInfoURL: URL? = nil) {
        self.session = session
        // Allow injecting a custom URL for testing; fall back to config in production
        if let url = userInfoURL {
            self.userInfoURL = url
        } else if let url = URL(string: KeycloakConfig.userInfoEndpoint) {
            self.userInfoURL = url
        } else {
            // Fallback placeholder — fetchUserInfo will throw .badURL if this is hit
            self.userInfoURL = URL(string: "https://invalid")!
        }
    }

    private struct UserInfoResponse: Decodable {
        let sub: String?
        let email: String?
        let given_name: String?
        let family_name: String?
        let preferred_username: String?
    }

    func fetchUserInfo(accessToken: String) async throws -> User {
        var request = URLRequest(url: userInfoURL)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)

        if let http = response as? HTTPURLResponse, http.statusCode >= 400 {
            throw URLError(.badServerResponse)
        }

        let info = try JSONDecoder().decode(UserInfoResponse.self, from: data)

        return User(
            id: info.sub ?? UUID().uuidString,
            email: info.email ?? "",
            firstName: info.given_name,
            lastName: info.family_name,
            username: info.preferred_username
        )
    }
}
