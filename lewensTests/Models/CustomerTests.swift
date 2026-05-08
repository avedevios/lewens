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
        #expect(response.empty == true)
        #expect(response.totalElements == 0)
    }

    @Test("Decodes PageableResponse with multiple elements")
    func decodePageableResponseMultipleElements() throws {
        let json = """
        {
            "content": [
                { "id": "1", "name": "A", "description": "d1", "price": 10.0, "available": true },
                { "id": "2", "name": "B", "description": "d2", "price": 20.0, "available": false },
                { "id": "3", "name": "C", "description": "d3", "price": 30.0, "available": true }
            ],
            "pageable": {
                "pageNumber": 0, "pageSize": 20,
                "sort": { "empty": false, "sorted": true, "unsorted": false },
                "offset": 0, "paged": true, "unpaged": false
            },
            "totalElements": 3, "totalPages": 1,
            "last": true, "size": 20, "number": 0,
            "sort": { "empty": false, "sorted": true, "unsorted": false },
            "numberOfElements": 3, "first": true, "empty": false
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(PageableResponse<Customer>.self, from: json)

        #expect(response.content.count == 3)
        #expect(response.totalElements == 3)
        #expect(response.content[1].name == "B")
        #expect(response.content[2].available == true)
    }

    @Test("Decodes SortInfo correctly")
    func decodeSortInfo() throws {
        let json = #"{ "empty": false, "sorted": true, "unsorted": false }"#.data(using: .utf8)!
        let sort = try JSONDecoder().decode(SortInfo.self, from: json)

        #expect(sort.empty    == false)
        #expect(sort.sorted   == true)
        #expect(sort.unsorted == false)
    }

    @Test("Decodes PageableInfo correctly")
    func decodePageableInfo() throws {
        let json = """
        {
            "pageNumber": 2, "pageSize": 10,
            "sort": { "empty": true, "sorted": false, "unsorted": true },
            "offset": 20, "paged": true, "unpaged": false
        }
        """.data(using: .utf8)!

        let info = try JSONDecoder().decode(PageableInfo.self, from: json)

        #expect(info.pageNumber == 2)
        #expect(info.pageSize   == 10)
        #expect(info.offset     == 20)
        #expect(info.paged      == true)
        #expect(info.unpaged    == false)
    }
}
