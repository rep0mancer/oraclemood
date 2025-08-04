import SwiftUI
import Charts

/// Top level home view containing daily, weekly and monthly tabs with charts.
struct HomeView: View {
    @EnvironmentObject var moodStore: MoodStore
    @State private var selection: Tab = .daily
    @State private var ruleEvents: [RuleEvent] = []

    enum Tab: String, CaseIterable, Identifiable {
        case daily
        case weekly
        case monthly
        var id: String { rawValue }
    }

    var body: some View {
        NavigationStack {
            TabView(selection: $selection) {
                DailyChartView(entries: moodStore.entries)
                    .tabItem { Label(L10n.homeTabDaily, systemImage: "chart.bar.fill") }
                    .tag(Tab.daily)
                WeeklyChartView(entries: moodStore.entries)
                    .tabItem { Label(L10n.homeTabWeekly, systemImage: "calendar") }
                    .tag(Tab.weekly)
                MonthlyChartView(entries: moodStore.entries)
                    .tabItem { Label(L10n.homeTabMonthly, systemImage: "calendar.circle") }
                    .tag(Tab.monthly)
            }
            .onAppear {
                Task {
                    self.ruleEvents = (try? await DatabaseService.shared.fetchRuleEvents()) ?? []
                }
            }
            .navigationTitle(L10n.homeTitle)
            .toolbar {
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gearshape")
                }
            }
        }
    }
}

/// Renders a bar chart of mood entries for the current day. Each bar's colour
/// corresponds to the selected palette and the mood value.
struct DailyChartView: View {
    let entries: [MoodEntry]
    var body: some View {
        let todayEntries = entries.filter { Calendar.current.isDateInToday($0.timestamp) }
        Chart {
            ForEach(todayEntries) { entry in
                BarMark(
                    x: .value(L10n.chartXAxisTime, entry.timestamp, unit: .hour),
                    y: .value(L10n.chartYAxisMood, entry.mood.rawValue)
                )
                .foregroundStyle(by: .value(L10n.chartYAxisMood, entry.mood.localizedDescription))
            }
        }
        .chartYAxisLabel(L10n.chartYAxisMood)
        .chartXAxisLabel(L10n.chartXAxisTime)
    }
}

/// Renders a weekly heatmap grid using Swift Charts' heatmap API. Weeks start on
/// Monday. Each cell's intensity corresponds to mood value.
struct WeeklyChartView: View {
    let entries: [MoodEntry]
    var body: some View {
        // Build data grouped by day of week (0 = Monday) and hour bucket (0–23)
        let calendar = Calendar.current
        let weekEntries = entries.filter { calendar.isDate($0.timestamp, equalTo: Date(), toGranularity: .weekOfYear) }
        let points = weekEntries.map { entry -> (Int, Int, Int) in
            let comps = calendar.dateComponents([.weekday, .hour], from: entry.timestamp)
            let weekday = (comps.weekday ?? 1) - 1 // 0-indexed
            let hour = comps.hour ?? 0
            return (weekday, hour, entry.mood.rawValue)
        }
        Chart {
            ForEach(points, id: \ .0) { point in
                RectangleMark(
                    x: .value(L10n.chartXAxisDayOfWeek, point.0),
                    y: .value(L10n.chartYAxisHour, point.1),
                    color: .value(L10n.chartYAxisMood, point.2)
                )
            }
        }
        .chartXAxisLabel(L10n.chartXAxisDayOfWeek)
        .chartYAxisLabel(L10n.chartYAxisHour)
    }
}

/// Renders a monthly heatmap grid similar to weekly but aggregated by day of month
/// and hour.
struct MonthlyChartView: View {
    let entries: [MoodEntry]
    var body: some View {
        let calendar = Calendar.current
        let monthEntries = entries.filter { calendar.isDate($0.timestamp, equalTo: Date(), toGranularity: .month) }
        let points = monthEntries.map { entry -> (Int, Int, Int) in
            let comps = calendar.dateComponents([.day, .hour], from: entry.timestamp)
            let day = (comps.day ?? 1) - 1
            let hour = comps.hour ?? 0
            return (day, hour, entry.mood.rawValue)
        }
        Chart {
            ForEach(points, id: \ .0) { point in
                RectangleMark(
                    x: .value(L10n.chartXAxisDay, point.0),
                    y: .value(L10n.chartYAxisHour, point.1),
                    color: .value(L10n.chartYAxisMood, point.2)
                )
            }
        }
        .chartXAxisLabel(L10n.chartXAxisDay)
        .chartYAxisLabel(L10n.chartYAxisHour)
    }
}