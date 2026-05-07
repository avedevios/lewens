//
//  CustomerTests.swift
//  lewensTests
//

import Testing
import Foundation
@testable import lewens

@Suite("Customer Model")
struct CustomerTests {

    @Test("Decodes customer with all fields")
    func decodeCustomer() throws {
        let json = """
        {
            "id": "c1",
            "name": "Acme GmbH",
            "description": "Top customer",
            "price": 1500.50,
            "available": true
        }
        """.data(using: .utf8)!

        let customer = try JSONDecoder().decode(Customer.self, from: json)

        #expect(customer.id          == "c1")
        #expect(customer.name        == "Acme GmbH")
        #expect(customer.description == "Top customer")
        #expect(abs(customer.price - 1500.50) < 0.001)
        #expect(customer.available   == true)
    }

    @Test("available flag", arguments: [true, false])
    func availableFlag(available: Bool) throws {
        let json = """
        { "id": "x", "name": "X", "description": "", "price": 0, "available": \(available) }
        """.data(using: .utf8)!

        let customer = try JSONDecoder().decode(Customer.self, from: json)
        #expect(customer.available == available)
    }

    @Test("Codable round-trip")
    func roundTrip() throws {
        let original = Customer(id: "x", name: "Test", description: "Desc", price: 99.9, available: true)
        let data     = try JSONEncoder().encode(original)
        let decoded  = try JSONDecoder().decode(Customer.self, from: data)

        #expect(decoded.id   == original.id)
        #expect(decoded.name == original.name)
        #expect(abs(decoded.price - original.price) < 0.001)
    }

    @Test("Decodes PageableResponse with content")
    func decodePageableResponse() throws {
        let json = """
        {
            "content": [
                { "id": "1", "name": "A", "description": "d", "price": 10.0, "available": true }
            ],
            "pageable": {
                "pageNumber": 0, "pageSize": 20,
                "sort": { "empty": true, "sorted": false, "unsorted": true },
                "offset": 0, "paged": true, "unpaged": false
            },
            "totalElements": 1, "totalPages": 1,
            "last": true, "size": 20, "number": 0,
            "sort": { "empty": true, "sorted": false, "unsorted": true },
            "numberOfElements": 1, "first": true, "empty": false
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(PageableResponse<Customer>.self, from: json)

        #expect(response.content.count       == 1)
        #expect(response.totalElements       == 1)
        #expect(response.first               == true)
        #expect(response.last                == true)
        #expect(response.empty               == false)
        #expect(response.content.first?.name == "A")
    }

    @Test("Decodes empty PageableResponse")
    func decodeEmptyPageableResponse() throws {
        let json = """
        {
            "content": [],
            "pageable": {
                "pageNumber": 0, "pageSize": 20,
                "sort": { "empty": true, "sorted": false, "unsorted": true },
                "offset": 0, "paged": true, "unpaged": false
            },
            "totalElements": 0, "totalPages": 0,
            "last": true, "size": 20, "number": 0,
            "sort": { "empty": true, "sorted": false, "unsorted": true },
            "numberOfElements": 0, "first": true, "empty": true
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(PageableResponse<Customer>.self, from: json)

        #expect(response.content.isEmpty)
        #expect(response.empty         == true)
        #expect(response.totalElements == 0)
    }
}
