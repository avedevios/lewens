//
//  KeychainHelperTests.swift
//  lewensTests
//

import Testing
import Foundation
@testable import lewens

@Suite("KeychainHelper", .serialized)
struct KeychainHelperTests {

    private let sut     = KeychainHelper.shared
    private let service = "lewens-test"
    private let account = "test-account"

    @Test("Saves and reads back correct data")
    func saveAndRead() {
        defer { sut.delete(service: service, account: account) }

        let data = "hello keychain".data(using: .utf8)!
        sut.save(data, service: service, account: account)

        #expect(sut.read(service: service, account: account) == data)
    }

    @Test("Returns nil when nothing saved")
    func readReturnsNil() {
        #expect(sut.read(service: service, account: "nonexistent-\(UUID())") == nil)
    }

    @Test("Overwrite replaces existing item")
    func overwrite() {
        defer { sut.delete(service: service, account: account) }

        sut.save("first".data(using: .utf8)!,  service: service, account: account)
        sut.save("second".data(using: .utf8)!, service: service, account: account)

        #expect(sut.read(service: service, account: account) == "second".data(using: .utf8)!)
    }

    @Test("Handles empty data")
    func emptyData() {
        defer { sut.delete(service: service, account: account) }

        sut.save(Data(), service: service, account: account)
        #expect(sut.read(service: service, account: account) == Data())
    }

    @Test("Handles large data (10 KB)")
    func largeData() {
        defer { sut.delete(service: service, account: account) }

        let large = Data(repeating: 0xAB, count: 10_000)
        sut.save(large, service: service, account: account)
        #expect(sut.read(service: service, account: account) == large)
    }

    @Test("Delete removes saved item")
    func deleteRemovesItem() {
        sut.save("to delete".data(using: .utf8)!, service: service, account: account)
        sut.delete(service: service, account: account)
        #expect(sut.read(service: service, account: account) == nil)
    }

    @Test("Delete does not crash when item does not exist")
    func deleteNonexistent() {
        sut.delete(service: service, account: "ghost-\(UUID())")
    }

    @Test("Different accounts are isolated", arguments: [
        ("acc1", "data1"),
        ("acc2", "data2"),
    ])
    func accountIsolation(account: String, value: String) {
        defer { sut.delete(service: service, account: account) }

        let data = value.data(using: .utf8)!
        sut.save(data, service: service, account: account)
        #expect(sut.read(service: service, account: account) == data)
    }

    @Test("Different services are isolated")
    func serviceIsolation() {
        let serviceA = "service-a-\(UUID())"
        let serviceB = "service-b-\(UUID())"
        defer {
            sut.delete(service: serviceA, account: account)
            sut.delete(service: serviceB, account: account)
        }

        let data = "shared".data(using: .utf8)!
        sut.save(data, service: serviceA, account: account)
        sut.save(data, service: serviceB, account: account)

        sut.delete(service: serviceA, account: account)

        #expect(sut.read(service: serviceA, account: account) == nil)
        #expect(sut.read(service: serviceB, account: account) == data)
    }
}
