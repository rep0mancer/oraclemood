import Foundation
import StoreKit
import OracleLightShared
import os.log

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
    private let productID = AppConfig.proProductID

    init() {
        Task { await load() }
        Task { await observeTransactions() }
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
                    await transaction.finish()
                    return
                }
            }
        } catch {
            os_log("Failed to load products from App Store: %{public}@", log: .default, type: .error, String(describing: error))
        }
    }

    /// Initiates a purchase of the product. Updates `isPurchased` on success.
    func purchase(errorHandler: ErrorState) async {
        guard let product = self.product else { return }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    self.isPurchased = true
                    await transaction.finish()
                }
            default:
                break
            }
        } catch {
            await errorHandler.present(error: error)
        }
    }

    private func observeTransactions() async {
        for await update in Transaction.updates {
            if case .verified(let transaction) = update, transaction.productID == productID {
                self.isPurchased = true
                await transaction.finish()
            }
        }
    }
}

