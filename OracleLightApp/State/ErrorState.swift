import SwiftUI

@MainActor
final class ErrorState: ObservableObject {
    @Published var isPresentingError = false
    @Published var errorMessage = ""

    func present(error: Error) {
        errorMessage = error.localizedDescription
        isPresentingError = true
    }

    func present(message: String) {
        errorMessage = message
        isPresentingError = true
    }
}
