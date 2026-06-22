//
//  HABITUSTests.swift
//  HABITUSTests
//
//  Created by Ava Thomas on 13/01/2026.
//

import Testing
import Foundation
@testable import HABITUS

struct HABITUSTests {

    @Test func dayKeyFormatsFixedDateAsRepositoryDateKey() async throws {
        let date = try fixedDate(year: 2026, month: 6, day: 21, hour: 12)

        #expect(DayKey.from(date: date) == "2026-06-21")
    }

    @Test func goalProgressClampsAtOneAndRemainingDoesNotGoNegative() async throws {
        let goal = Goal(
            id: "workouts",
            type: .workoutCount,
            targetValue: 4,
            currentValue: 6,
            isActive: true,
            weekStart: "2026-06-15"
        )

        #expect(goal.progress == 1.0)
        #expect(goal.remainingValue == 0)
    }

    @Test func goalProgressReturnsZeroWhenTargetIsMissing() async throws {
        let goal = Goal(
            id: "mobility",
            type: .mobilitySessions,
            targetValue: 0,
            currentValue: 2,
            isActive: true,
            weekStart: "2026-06-15"
        )

        #expect(goal.progress == 0)
        #expect(goal.remainingValue == 0)
    }

    @Test func planSchedulerChoosesHighScoringSlotForTraining() async throws {
        let scheduler = PlanScheduler()
        let day = try fixedDate(year: 2026, month: 6, day: 21, hour: 0)
        let morningSlot = try slot(on: day, startHour: 7, durationMinutes: 60)
        let afternoonSlot = try slot(on: day, startHour: 15, durationMinutes: 60)
        let item = planItem(activityType: "strength", durationMinutes: 45)

        let scheduled = scheduler.schedule(
            items: [item],
            into: [afternoonSlot, morningSlot]
        )

        #expect(scheduled.count == 1)
        #expect(scheduled.first?.item.activityType == "strength")
        #expect(scheduled.first?.start == morningSlot.start)
        #expect(scheduled.first?.end == morningSlot.start.addingTimeInterval(45 * 60))
    }

    @Test func planSchedulerSkipsItemsWithoutLongEnoughSlots() async throws {
        let scheduler = PlanScheduler()
        let day = try fixedDate(year: 2026, month: 6, day: 21, hour: 0)
        let shortSlot = try slot(on: day, startHour: 13, durationMinutes: 10)
        let item = planItem(activityType: "run", durationMinutes: 30)

        let scheduled = scheduler.schedule(
            items: [item],
            into: [shortSlot]
        )

        #expect(scheduled.isEmpty)
    }

    @Test func planSchedulerDoesNotOverlapMultipleItemsInSameSlot() async throws {
        let scheduler = PlanScheduler()
        let day = try fixedDate(year: 2026, month: 6, day: 21, hour: 0)
        let slot = try slot(on: day, startHour: 12, durationMinutes: 60)
        let walk = planItem(activityType: "walk", durationMinutes: 15)
        let meditation = planItem(activityType: "meditation", durationMinutes: 10)

        let scheduled = scheduler.schedule(
            items: [walk, meditation],
            into: [slot]
        )

        #expect(scheduled.count == 2)
        #expect(scheduled[0].end <= scheduled[1].start)
        #expect(scheduled[0].start >= slot.start)
        #expect(scheduled[1].end <= slot.end)
    }

    private func fixedDate(
        year: Int,
        month: Int,
        day: Int,
        hour: Int
    ) throws -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let date = calendar.date(
            from: DateComponents(
                timeZone: TimeZone(secondsFromGMT: 0),
                year: year,
                month: month,
                day: day,
                hour: hour
            )
        )

        return try #require(date)
    }

    private func slot(
        on day: Date,
        startHour: Int,
        durationMinutes: Int
    ) throws -> TimeSlot {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let start = calendar.date(
            bySettingHour: startHour,
            minute: 0,
            second: 0,
            of: day
        )

        return TimeSlot(
            start: try #require(start),
            end: try #require(start).addingTimeInterval(
                TimeInterval(durationMinutes * 60)
            )
        )
    }

    private func planItem(
        activityType: String,
        durationMinutes: Int
    ) -> SmartPlanItem {
        SmartPlanItem(
            activityType: activityType,
            title: "Test",
            subtitle: "Unit test",
            reason: "Validation",
            durationMinutes: durationMinutes,
            intensity: 4
        )
    }

}
