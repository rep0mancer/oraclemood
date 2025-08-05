import XCTest

final class OnboardingUITests: XCTestCase {

    override func setUpWithError() throws {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
    }

    func testOnboardingPrivacyScreen_ContinueButtonExists() throws {
        // Launch the application.
        let app = XCUIApplication()
        
        // Set a launch argument to ensure the onboarding flow is always shown for this test.
        app.launchArguments += ["-hasSeenOnboarding", "NO"]
        app.launch()

        // Verify the "Continue" button on the privacy screen exists.
        // The accessibilityIdentifier was set in OnboardingFlowView.swift.
        let privacyContinueButton = app.buttons["PrivacyContinueButton"]
        
        // Assert that the button exists and is hittable after a reasonable wait time.
        XCTAssertTrue(
            privacyContinueButton.waitForExistence(timeout: 5),
            "The continue button on the privacy screen should exist."
        )
        XCTAssertTrue(
            privacyContinueButton.isHittable,
            "The continue button should be hittable."
        )
    }
}

