import Quick
import Nimble
import OracleLightShared

@testable import OracleLightApp

final class SettingsTests: QuickSpec {
    override class func spec() {
        describe("Settings") {
            it("provides sensible defaults") {
                let defaults = Settings.default
                expect(defaults.promptTimes).to(equal(["07:30", "12:30", "17:30", "22:00"]))
                expect(defaults.minimumIntervalMinutes).to(equal(60))
                expect(defaults.palette).to(equal(.vivid))
            }
        }
        describe("ColorPalette") {
            it("returns a colour for each mood and palette") {
                for palette in Palette.allCases {
                    for mood in Mood.allCases {
                        let colour = ColorPalette.color(for: mood, palette: palette)
                        // We can't easily assert equality on Color so we check that
                        // the opacity is 1 which is true for all defined colours.
                        expect(colour.opacity).to(equal(1))
                    }
                }
            }
        }
    }
}
