import Foundation
import ActivityKit

/// Defines the attributes for the mood selection Live Activity. There is no
/// dynamic content state since the activity does not update externally.
struct MoodSelectionAttributes: ActivityAttributes {
    public typealias ContentState = Void
    // No dynamic properties needed
}