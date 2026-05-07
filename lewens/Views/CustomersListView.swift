import SwiftUI

struct CustomersListView: View {
    @State private var pageableResponse: PageableResponse<Customer>?
    
    var body: some View {
        NavigationStack {
            List {
                if let customers = pageableResponse?.content {
                    ForEach(customers) { customer in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(customer.name)
                                    .font(.headline)
                                Spacer()
                                Text(String(format: "$%.2f", customer.price))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text(customer.description)
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            HStack {
                                Circle()
                                    .fill(customer.available ? Color.green : Color.red)
                                    .frame(width: 8, height: 8)
                                Text(customer.available ? "Active" : "Inactive")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                } else {
                    Text("No customers loaded")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Customers")
            .onAppear {
                loadData()
            }
        }
    }
    
    private func loadData() {
        if let loaded: PageableResponse<Customer> = JSONLoader.load("test_data.json") {
            self.pageableResponse = loaded
        } else {
            print("Failed to load test_data.json.")
        }
    }
}

struct CustomersListView_Previews: PreviewProvider {
    static var previews: some View {
        CustomersListView()
    }
}
