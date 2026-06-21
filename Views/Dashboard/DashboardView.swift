//
//  DashboardView.swift
//  HABITUS
//
//  Created by Ava Thomas on 13/01/2026.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var dayStore = DayDashboardStore()
    @StateObject private var sessionsStore = TodaySessionsStore()
    @StateObject private var goalsStore = GoalsStore()
    @State private var selectedDate: Date = Date()
    @State private var sessionPendingDeletion: SessionRowItem?
    @State private var sessionPendingEdit: SessionRowItem?
    @State private var isDeletingSession = false

    private var selectedDateKey: String {
        DayKey.from(date: selectedDate)
    }

    private var selectedDayTitle: String {
        let calendar = Calendar.current

        if calendar.isDateInToday(selectedDate) {
            return "Today"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: selectedDate)
    }

    private var selectedDateSubtitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: selectedDate)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(selectedDayTitle)
                                .font(.system(size: 32, weight: .bold, design: .rounded))

                            Text(selectedDateSubtitle)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        WeekStripView(selectedDate: $selectedDate)

                        guidanceHero
                    }

                    VStack(spacing: 16) {
                        MetricRing(
                            title: "Strain",
                            valueText: String(format: "%.1f", dayStore.strainScore),
                            subtitle: strainSubtitle,
                            progress: min(dayStore.strainScore / 21.0, 1.0)
                        )

                        MetricRing(
                            title: "Recovery",
                            valueText: recoveryValueText,
                            subtitle: dayStore.recoveryGuidance.isEmpty ?
                                "Add sleep soon" :
                                dayStore.recoveryGuidance,
                            progress: recoveryProgress,
                            color: recoveryColor
                        )
                    }

                    if !dayStore.weeklyProgressDays.isEmpty {
                        weeklyProgressCard
                    }

                    habitStreakCard

                    if !dayStore.smartPlanItems.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            sectionHeader(
                                title: "Today's plan",
                                subtitle: dayStore.smartPlanSummary.isEmpty ?
                                    "Suggested sessions based on your current recovery and load." :
                                    dayStore.smartPlanSummary
                            )

                            if !dayStore.smartPlanSummary.isEmpty {
                                plannerRationaleCard
                            }

                            if !dayStore.calendarPlanningMessage.isEmpty {
                                calendarPlanningNotice
                            }

                            if dayStore.scheduledPlanItems.isEmpty && !dayStore.smartPlanItems.isEmpty {
                                VStack(spacing: 14) {
                                    ForEach(dayStore.smartPlanItems) { item in
                                        SmartPlanCard(item: item)
                                    }
                                }
                            } else {
                                VStack(spacing: 14) {
                                    ForEach(dayStore.scheduledPlanItems) { item in
                                        ScheduledPlanCard(item: item)
                                    }
                                }
                            }
                        }
                    }

                    if !goalsStore.goals.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            sectionHeader(
                                title: "Weekly progress",
                                subtitle: "Track consistency across your goals, not just today's output."
                            )

                            VStack(alignment: .leading, spacing: 14) {
                                ForEach(goalsStore.goals) { goal in
                                    GoalProgressRow(
                                        title: goal.type.title,
                                        currentValue: goal.currentValue,
                                        targetValue: goal.targetValue,
                                        unit: goal.type.unit
                                    )
                                }
                            }
                            .padding(20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        sectionHeader(
                            title: "Day log",
                            subtitle: dayStore.sessionCount == 0 ?
                                "No sessions logged for this day yet." :
                                "\(dayStore.sessionCount) session\(dayStore.sessionCount == 1 ? "" : "s") logged"
                        )

                        if sessionsStore.sessions.isEmpty {
                            Text("No activities logged yet.")
                                .foregroundStyle(.secondary)
                                .padding(.vertical, 6)
                        } else {
                            VStack(spacing: 14) {
                                ForEach(sessionsStore.sessions) { item in
                                    SessionRowView(
                                        item: item,
                                        onEdit: {
                                            sessionPendingEdit = item
                                        },
                                        onDelete: {
                                            sessionPendingDeletion = item
                                        }
                                    )
                                }
                            }
                        }

                        if let errorMessage = sessionsStore.errorMessage {
                            Text(errorMessage)
                                .font(.subheadline)
                                .foregroundStyle(.red)
                        }
                    }
                    .padding(.top, 4)

                    Spacer(minLength: 12)
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .onAppear {
                dayStore.startListening(dateKey: selectedDateKey)
                sessionsStore.startListening(dateKey: selectedDateKey)
                goalsStore.startListening()

                Task {
                    await dayStore.generateSmartPlan(dateKey: selectedDateKey)
                    await dayStore.loadWeeklyProgress(containing: selectedDate)
                    await dayStore.loadHabitStreaks(endingAt: selectedDate)
                }
            }
            .onReceive(
                NotificationCenter.default.publisher(
                    for: Notification.Name("dailyInputsSaved")
                )
            ) { _ in
                Task {
                    await dayStore.generateSmartPlan(dateKey: selectedDateKey)
                    await dayStore.loadWeeklyProgress(containing: selectedDate)
                    await dayStore.loadHabitStreaks(endingAt: selectedDate)
                }
            }
            .onChange(of: goalsStore.goals) {
                Task {
                    await dayStore.generateSmartPlan(dateKey: selectedDateKey)
                    await dayStore.loadWeeklyProgress(containing: selectedDate)
                    await dayStore.loadHabitStreaks(endingAt: selectedDate)
                }
            }
            .onReceive(sessionsStore.$sessions) { _ in
                Task {
                    await dayStore.loadWeeklyProgress(containing: selectedDate)
                    await dayStore.loadHabitStreaks(endingAt: selectedDate)
                }
            }
            .onChange(of: selectedDate) {
                dayStore.stopListening()
                sessionsStore.stopListening()

                dayStore.startListening(dateKey: selectedDateKey)
                sessionsStore.startListening(dateKey: selectedDateKey)

                Task {
                    await dayStore.generateSmartPlan(dateKey: selectedDateKey)
                    await dayStore.loadWeeklyProgress(containing: selectedDate)
                    await dayStore.loadHabitStreaks(endingAt: selectedDate)
                }
            }
            .onDisappear {
                dayStore.stopListening()
                sessionsStore.stopListening()
                goalsStore.stopListening()
            }
            .alert(
                "Delete activity?",
                isPresented: deleteAlertBinding,
                presenting: sessionPendingDeletion
            ) { item in
                Button("Cancel", role: .cancel) {
                    sessionPendingDeletion = nil
                }

                Button("Delete", role: .destructive) {
                    Task {
                        await deleteSession(item)
                    }
                }
                .disabled(isDeletingSession)
            } message: { item in
                Text("This removes \(item.modality) from your day log and recalculates today's strain.")
            }
            .sheet(item: $sessionPendingEdit) { item in
                EditSessionSheet(item: item) { payload in
                    try await updateSession(payload)
                }
            }
        }
    }

    private var deleteAlertBinding: Binding<Bool> {
        Binding(
            get: { sessionPendingDeletion != nil },
            set: { isPresented in
                if !isPresented {
                    sessionPendingDeletion = nil
                }
            }
        )
    }

    private func deleteSession(_ item: SessionRowItem) async {
        isDeletingSession = true

        do {
            try await sessionsStore.deleteSession(item.id)
            await dayStore.generateSmartPlan(dateKey: selectedDateKey)
            await dayStore.loadWeeklyProgress(containing: selectedDate)
            await dayStore.loadHabitStreaks(endingAt: selectedDate)
        } catch {
            print("deleteSession failed:", error)
        }

        isDeletingSession = false
        sessionPendingDeletion = nil
    }

    private func updateSession(_ payload: SessionEditPayload) async throws {
        try await sessionsStore.updateSession(payload)
        await dayStore.generateSmartPlan(dateKey: selectedDateKey)
        await dayStore.loadWeeklyProgress(containing: selectedDate)
        await dayStore.loadHabitStreaks(endingAt: selectedDate)
        sessionPendingEdit = nil
    }

    private var recoveryValueText: String {
        guard let score = dayStore.recoveryScore else { return "--" }
        return String(format: "%.0f", score)
    }

    private var recoveryProgress: Double {
        guard let score = dayStore.recoveryScore else { return 0 }
        return min(max(score / 100.0, 0), 1)
    }

    private var recoveryColor: Color {
        guard let score = dayStore.recoveryScore else {
            return .gray
        }

        if score >= 70 {
            return .green
        } else if score >= 40 {
            return .orange
        } else {
            return .red
        }
    }

    private var strainSubtitle: String {
        switch dayStore.strainScore {
        case ..<0.1:
            return "Log an activity to begin"
        case ..<7:
            return "Light day so far"
        case ..<14:
            return "Training load in range"
        default:
            return "High load prioritise recovery"
        }
    }

    private var readinessBadgeText: String {
        if let score = dayStore.recoveryScore {
            if score >= 70 { return "High readiness" }
            if score >= 40 { return "Moderate readiness" }
            return "Recovery focus"
        }

        return "Awaiting recovery"
    }

    private var readinessBadgeColor: Color {
        if let score = dayStore.recoveryScore {
            if score >= 70 { return .green }
            if score >= 40 { return .orange }
            return .red
        }

        return .gray
    }

    private var guidanceHero: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(readinessBadgeText.uppercased())
                .font(.caption.weight(.bold))
                .tracking(1.1)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(readinessBadgeColor.opacity(0.14))
                .foregroundStyle(readinessBadgeColor)
                .clipShape(Capsule())

            Text(dayStore.recommendationTitle.isEmpty ? "Build today's guidance" : dayStore.recommendationTitle)
                .font(.system(size: 26, weight: .bold, design: .rounded))

            Text(dayStore.recommendationSubtitle.isEmpty ? "Add sleep and recovery inputs to personalise your training plan." : dayStore.recommendationSubtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                summaryPill(label: "Strain", value: String(format: "%.1f", dayStore.strainScore))
                summaryPill(label: "Recovery", value: recoveryValueText)
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    readinessBadgeColor.opacity(0.16),
                    Color(.secondarySystemBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color.white.opacity(0.5), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 28))
    }

    private func sectionHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private func summaryPill(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.headline.weight(.semibold))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var weeklyProgressCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                title: "Weekly snapshot",
                subtitle: weeklySnapshotSubtitle
            )

            HStack(alignment: .bottom, spacing: 10) {
                ForEach(dayStore.weeklyProgressDays) { day in
                    weeklyDayColumn(day)
                }
            }
            .frame(maxWidth: .infinity)

            HStack(spacing: 12) {
                summaryPill(label: "Avg strain", value: String(format: "%.1f", weeklyAverageStrain))
                summaryPill(label: "Avg recovery", value: weeklyAverageRecoveryText)
                summaryPill(label: "Sessions", value: "\(weeklySessionTotal)")
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private var habitStreakCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(
                title: "Habit streaks",
                subtitle: habitStreakSubtitle
            )

            HStack(spacing: 12) {
                streakPill(
                    title: "Check-ins",
                    value: dayStore.habitStreak.checkInDays,
                    caption: "sleep data"
                )

                streakPill(
                    title: "Activity",
                    value: dayStore.habitStreak.activityDays,
                    caption: "logged days"
                )
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private var habitStreakSubtitle: String {
        let checkIns = dayStore.habitStreak.checkInDays
        let activities = dayStore.habitStreak.activityDays

        if checkIns == 0 && activities == 0 {
            return "Start a streak with a sleep check-in or logged activity."
        }

        if checkIns >= 3 || activities >= 3 {
            return "Consistency is building across your recent routine."
        }

        return "Keep repeating the small actions that feed your plan."
    }

    private func streakPill(title: String, value: Int, caption: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(value)")
                    .font(.system(size: 30, weight: .bold, design: .rounded))

                Text("day\(value == 1 ? "" : "s")")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            Text(caption)
                .font(.caption2.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func weeklyDayColumn(_ day: WeeklyProgressDay) -> some View {
        VStack(spacing: 8) {
            Text(day.dayLabel)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            ZStack(alignment: .bottom) {
                Capsule()
                    .fill(Color.white.opacity(0.65))
                    .frame(width: 18, height: 86)

                Capsule()
                    .fill(day.hasData ? strainColor(for: day.strainScore) : Color.gray.opacity(0.25))
                    .frame(
                        width: 18,
                        height: max(8, min(CGFloat(day.strainScore / 21.0) * 86, 86))
                    )
            }
            .accessibilityLabel("\(day.dayLabel) strain \(String(format: "%.1f", day.strainScore))")

            Circle()
                .fill(recoveryDotColor(for: day.hasData ? day.recoveryScore : nil))
                .frame(width: 8, height: 8)

            Text("\(day.sessionCount)")
                .font(.caption2.weight(.bold))
                .foregroundStyle(day.sessionCount > 0 ? .primary : .secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var weeklySnapshotSubtitle: String {
        if weeklySessionTotal == 0 && weeklyAverageStrain == 0 && weeklyAverageRecovery == nil {
            return "Log activities and sleep check-ins to build your weekly trend."
        }

        return "Seven-day view of strain, recovery, and logged sessions."
    }

    private var weeklyAverageStrain: Double {
        let days = dayStore.weeklyProgressDays.filter { $0.hasData }
        guard !days.isEmpty else { return 0 }
        return days.reduce(0) { $0 + $1.strainScore } / Double(days.count)
    }

    private var weeklyAverageRecovery: Double? {
        let scores = dayStore.weeklyProgressDays
            .filter { $0.hasData }
            .compactMap(\.recoveryScore)
        guard !scores.isEmpty else { return nil }
        return scores.reduce(0, +) / Double(scores.count)
    }

    private var weeklyAverageRecoveryText: String {
        guard let weeklyAverageRecovery else { return "--" }
        return String(format: "%.0f", weeklyAverageRecovery)
    }

    private var weeklySessionTotal: Int {
        dayStore.weeklyProgressDays.reduce(0) { $0 + $1.sessionCount }
    }

    private func strainColor(for score: Double) -> Color {
        if score >= 14 { return .red }
        if score >= 7 { return .orange }
        return .blue
    }

    private func recoveryDotColor(for score: Double?) -> Color {
        guard let score else { return .gray.opacity(0.35) }
        if score >= 70 { return .green }
        if score >= 40 { return .orange }
        return .red
    }

    private var plannerRationaleCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Why this plan?")
                .font(.subheadline.weight(.semibold))

            Text(dayStore.smartPlanSummary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var calendarPlanningNotice: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(calendarPlanningColor)
                .frame(width: 8, height: 8)
                .padding(.top, 5)

            VStack(alignment: .leading, spacing: 2) {
                Text(calendarPlanningTitle)
                    .font(.caption.weight(.semibold))

                Text(dayStore.calendarPlanningMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var calendarPlanningTitle: String {
        switch dayStore.calendarPlanningState {
        case .scheduled:
            return "Calendar scheduled"
        case .partial:
            return "Calendar partially scheduled"
        case .permissionDenied:
            return "Calendar access needed"
        case .noAvailability:
            return "No calendar slot found"
        case .unavailable:
            return "Calendar unavailable"
        case .idle:
            return "Calendar planning"
        }
    }

    private var calendarPlanningColor: Color {
        switch dayStore.calendarPlanningState {
        case .scheduled:
            return .green
        case .partial:
            return .orange
        case .permissionDenied, .noAvailability, .unavailable:
            return .gray
        case .idle:
            return .secondary
        }
    }
}

private struct EditSessionSheet: View {
    let item: SessionRowItem
    let onSave: (SessionEditPayload) async throws -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var type: String
    @State private var duration: Double
    @State private var distanceKm: Double
    @State private var intensity: Double
    @State private var isSaving = false
    @State private var errorMessage: String?

    private let types = ["Strength", "Run", "Hyrox", "Mobility", "Yoga", "Walk", "Other"]

    init(
        item: SessionRowItem,
        onSave: @escaping (SessionEditPayload) async throws -> Void
    ) {
        self.item = item
        self.onSave = onSave

        let resolvedType = Self.displayType(for: item)
        _type = State(initialValue: resolvedType)
        _duration = State(initialValue: Double(item.durationMinutes))
        _distanceKm = State(initialValue: max(item.distanceKm, 0.5))
        _intensity = State(initialValue: Double(item.rpe))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Activity") {
                    Picker("Type", selection: $type) {
                        ForEach(types, id: \.self) { Text($0) }
                    }

                    HStack {
                        Text("Duration (min)")
                        Spacer()
                        Text("\(Int(duration))")
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $duration, in: 5...180, step: 5)

                    if type == "Run" {
                        HStack {
                            Text("Distance (km)")
                            Spacer()
                            Text(String(format: "%.1f", distanceKm))
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $distanceKm, in: 0.5...30, step: 0.5)
                    }

                    HStack {
                        Text("Intensity (1-10)")
                        Spacer()
                        Text("\(Int(intensity))")
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $intensity, in: 1...10, step: 1)
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.subheadline)
                    }
                }

                Section {
                    Button {
                        Task {
                            await save()
                        }
                    } label: {
                        if isSaving {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Save changes")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(isSaving)
                }
            }
            .navigationTitle("Edit Activity")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isSaving)
                }
            }
        }
    }

    private func save() async {
        isSaving = true
        errorMessage = nil

        do {
            try await onSave(
                SessionEditPayload(
                    sessionId: item.id,
                    activityType: type,
                    modality: backendModality(for: type),
                    durationMinutes: Int(duration),
                    rpe: Int(intensity),
                    distanceKm: type == "Run" ? distanceKm : 0
                )
            )

            isSaving = false
            dismiss()
        } catch {
            isSaving = false
            errorMessage = "Could not update activity. Please try again."
        }
    }

    private static func displayType(for item: SessionRowItem) -> String {
        if !item.activityType.isEmpty {
            return item.activityType
        }

        switch item.modality {
        case "HIIT":
            return "Hyrox"
        case "Endurance":
            return "Run"
        case "Strength":
            return "Strength"
        case "Mobility":
            return "Mobility"
        default:
            return "Other"
        }
    }

    private func backendModality(for type: String) -> String {
        switch type {
        case "Hyrox":
            return "HIIT"
        case "Run":
            return "Endurance"
        case "Strength":
            return "Strength"
        case "Mobility", "Yoga", "Walk":
            return "Mobility"
        default:
            return "Endurance"
        }
    }
}
