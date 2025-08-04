import Foundation
import StoreKit

/// Handles loading and purchasing the one‑time non‑consumable product used to
/// unlock premium features. On initialisation it queries the App Store for
/// the product and checks current entitlements. When purchased, the
/// `isPurchased` property updates allowing the UI to react.
@MainActor
final class PurchaseController: ObservableObject {
    @Published private(set) var product: Product?
    @Published private(set) var isPurchased: Bool = false

    /// The identifier of the non‑consumable product. This must match the
    /// identifier configured in App Store Connect.
    private let productID = "oraclelight.pro"

    init() {
        Task { await load() }
    }

    /// Loads the product information from the App Store and determines if the
    /// user already owns the product.
    private func load() async {
        do {
            let products = try await Product.products(for: [productID])
            self.product = products.first
            // Check if the product is already purchased
            for await entitlement in Transaction.currentEntitlements {
                if case .verified(let transaction) = entitlement, transaction.productID == productID {
                    self.isPurchased = true
                    return
                }
            }
        } catch {
            // ignore errors; product will remain nil
        }
    }

    /// Initiates a purchase of the product. Updates `isPurchased` on success.
    func purchase() async {
        guard let product = self.product else { return }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(_) = verification {
                    self.isPurchased = true
                }
            default:
                break
            }
        } catch {
            // ignore
        }
    }
}