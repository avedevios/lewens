import Foundation

struct Customer: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let price: Double // Keeping price for now as in JSON, but could be 'balance'
    let available: Bool // Keeping as 'active' status
}

struct PageableResponse<T: Codable>: Codable {
    let content: [T]
    let pageable: PageableInfo
    let totalElements: Int
    let totalPages: Int
    let last: Bool
    let size: Int
    let number: Int
    let sort: SortInfo
    let numberOfElements: Int
    let first: Bool
    let empty: Bool
}

struct PageableInfo: Codable {
    let pageNumber: Int
    let pageSize: Int
    let sort: SortInfo
    let offset: Int
    let paged: Bool
    let unpaged: Bool
}

struct SortInfo: Codable {
    let empty: Bool
    let sorted: Bool
    let unsorted: Bool
}
