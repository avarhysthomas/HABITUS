//
//  CalendarAvailabilityService.swift
//  HABITUS
//
//  Created by Ava Thomas on 16/03/2026.
//

import Foundation
import EventKit

final class CalendarAvailabilityService {
    private let eventStore = EKEventStore()

    func requestAccess() async throws -> Bool {
        try await eventStore.requestFullAccessToEvents()
    }

    func events(for date: Date) -> [EKEvent] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let predicate = eventStore.predicateForEvents(
            withStart: startOfDay,
            end: endOfDay,
            calendars: nil
        )

        return eventStore.events(matching: predicate)
            .sorted { $0.startDate < $1.startDate }
    }

    func freeSlots(
        for date: Date,
        dayStartHour: Int = 6,
        dayEndHour: Int = 21
    ) -> [TimeSlot] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)

        guard
            let configuredDayStart = calendar.date(
                bySettingHour: dayStartHour,
                minute: 0,
                second: 0,
                of: startOfDay
            ),
            let dayEnd = calendar.date(
                bySettingHour: dayEndHour,
                minute: 0,
                second: 0,
                of: startOfDay
            )
        else {
            return []
        }

        let dayStart = effectiveStart(
            configuredStart: configuredDayStart,
            dayEnd: dayEnd,
            date: date
        )

        guard dayStart < dayEnd else {
            return []
        }

        let eventsToday = events(for: date)
            .filter(isBlockingEvent)
            .filter { $0.endDate > dayStart && $0.startDate < dayEnd }

        if eventsToday.isEmpty {
            return splitLargeSlotIfNeeded(TimeSlot(start: dayStart, end: dayEnd))
                .filter { isReasonableCandidate($0) }
                .sorted { $0.start < $1.start }
        }

        var rawFreeSlots: [TimeSlot] = []
        var cursor = dayStart

        for event in eventsToday {
            let busyStart = max(event.startDate, dayStart)
            let busyEnd = min(event.endDate, dayEnd)

            if busyStart > cursor {
                rawFreeSlots.append(TimeSlot(start: cursor, end: busyStart))
            }

            if busyEnd > cursor {
                cursor = busyEnd
            }
        }

        if cursor < dayEnd {
            rawFreeSlots.append(TimeSlot(start: cursor, end: dayEnd))
        }

        let filtered = rawFreeSlots
            .filter { $0.durationMinutes >= 10 }
            .flatMap { splitLargeSlotIfNeeded($0) }
            .filter { isReasonableCandidate($0) }

        return filtered.sorted { $0.start < $1.start }
    }

    private func effectiveStart(
        configuredStart: Date,
        dayEnd: Date,
        date: Date
    ) -> Date {
        let calendar = Calendar.current

        guard calendar.isDateInToday(date) else {
            return configuredStart
        }

        let now = Date()
        guard now > configuredStart else {
            return configuredStart
        }

        guard now < dayEnd else {
            return dayEnd
        }

        let minute = calendar.component(.minute, from: now)
        let roundedMinute = Int(ceil(Double(minute) / 15.0) * 15.0)

        if roundedMinute >= 60 {
            return calendar.date(
                bySettingHour: calendar.component(.hour, from: now) + 1,
                minute: 0,
                second: 0,
                of: now
            ) ?? now
        }

        return calendar.date(
            bySettingHour: calendar.component(.hour, from: now),
            minute: roundedMinute,
            second: 0,
            of: now
        ) ?? now
    }

    private func isBlockingEvent(_ event: EKEvent) -> Bool {
        guard !event.isAllDay else {
            return false
        }

        guard event.status != .canceled else {
            return false
        }

        return event.availability != .free
    }

    private func splitLargeSlotIfNeeded(_ slot: TimeSlot) -> [TimeSlot] {
        let calendar = Calendar.current

        // Keep small/medium slots as-is.
        if slot.durationMinutes <= 90 {
            return [slot]
        }

        // Split very large free windows into more realistic chunks.
        var result: [TimeSlot] = []
        var currentStart = slot.start

        while currentStart < slot.end {
            guard let nextEnd = calendar.date(
                byAdding: .minute,
                value: 60,
                to: currentStart
            ) else {
                break
            }

            let segmentEnd = min(nextEnd, slot.end)

            result.append(
                TimeSlot(start: currentStart, end: segmentEnd)
            )

            guard let nextStart = calendar.date(
                byAdding: .minute,
                value: 60,
                to: currentStart
            ) else {
                break
            }

            currentStart = nextStart
        }

        return result.filter { $0.durationMinutes >= 10 }
    }

    private func isReasonableCandidate(_ slot: TimeSlot) -> Bool {
        let calendar = Calendar.current
        let startHour = calendar.component(.hour, from: slot.start)
        let endHour = calendar.component(.hour, from: slot.end)

        // Avoid unrealistic times.
        guard startHour >= 6, endHour <= 21 else {
            return false
        }

        return true
    }
}
