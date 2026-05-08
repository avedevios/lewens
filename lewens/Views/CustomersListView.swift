import SwiftUI

struct CustomersListView: View {
    @State private var pageableResponse: PageableResponse<Customer>?
    @State private var showLanguagePicker = false

    var body: some View {
        AppScreen(showLanguagePicker: $showLanguagePicker, spacing: 16) {
            VStack(spacing: 8) {
                LocalizedText(LocalizationKeys.customers)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.lssPrimaryText)

                LocalizedText(LocalizationKeys.customersDescription)
                    .font(.system(size: 16))
                    .foregroundColor(.lssSecondaryText)
                    .multilineTextAlignment(.center)
            }

            customersContent
                .padding(.top, 16)
        }
        .onAppear {
            loadData()
        }
    }

    @ViewBuilder
    private var customersContent: some View {
        if let customers = pageableResponse?.content, !customers.isEmpty {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(customers) { customer in
                        CustomerCard(customer: customer)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 4)
            }
            .frame(maxHeight: 420)
        } else {
            Text("No customers loaded")
                .font(.subheadline)
                .foregroundColor(.lssSecondaryText)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.lssSurface)
                .cornerRadius(10)
                .padding(.horizontal, 20)
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

private struct CustomerCard: View {
    let customer: Customer

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(customer.name)
                    .font(.headline)
                    .foregroundColor(.lssPrimaryText)

                Spacer()

                Text(String(format: "$%.2f", customer.price))
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.lssSecondaryText)
            }

            Text(customer.description)
                .font(.body)
                .foregroundColor(.lssPrimaryText)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                Circle()
                    .fill(customer.available ? Color.green : Color.red)
                    .frame(width: 8, height: 8)

                Text(customer.available ? "Active" : "Inactive")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.lssSecondaryText)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.lssSurface)
        .cornerRadius(10)
    }
}

struct CustomersListView_Previews: PreviewProvider {
    static var previews: some View {
        CustomersListView()
            .environmentObject(LocalizationManager.shared)
            .environmentObject(ThemeManager.shared)
    }
}
