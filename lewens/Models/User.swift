//
//  User.swift
//  lewens
//
//  Created by Anton Averianov on 2025-09-02.
//

import Foundation

// Simple user model to start with
struct User: Codable, Identifiable, Equatable {
    let id: String
    let email: String
    let firstName: String?
    let lastName: String?
    let username: String?
    
    // Initializer for creating user
    init(id: String, email: String, firstName: String? = nil, lastName: String? = nil, username: String? = nil) {
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
    }
    
    // Computed property for full name
    var fullName: String {
        if let firstName = firstName, let lastName = lastName {
            return "\(firstName) \(lastName)"
        } else if let firstName = firstName {
            return firstName
        } else if let lastName = lastName {
            return lastName
        } else {
            return email
        }
    }
    
    // Computed property for display name
    var displayName: String {
        return username ?? fullName
    }
}
