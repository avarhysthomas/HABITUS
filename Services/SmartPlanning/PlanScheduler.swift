//
//  PlanScheduler.swift
//  HABITUS
//
//  Created by Ava Thomas on 16/03/2026.
//

import Foundation

final class PlanScheduler {

    func schedule(
        items: [SmartPlanItem],
        into slots: [TimeSlot]
    ) -> [ScheduledPlanItem] {
        var remainingSlots = applyHardConstraints(to: slots)
        var scheduled: [ScheduledPlanItem] = []

        for item in items {
            let candidates = remainingSlots.filter {
                $0.durationMinutes >= item.durationMinutes
            }

            guard !candidates.isEmpty else { continue }

            guard let chosenSlot = candidates.max(by: {
                score(slot: $0, for: item) < score(slot: $1, for: item)
            }) else {
                continue
            }

            let start = chosenSlot.start
            let end = Calendar.current.date(
                byAdding: .minute,
                value: item.durationMinutes,
                to: start
            )!

            scheduled.append(
                ScheduledPlanItem(
                    item: item,
                    start: start,
                    end: end
                )
            )

            remainingSlots = updateSlots(
                remainingSlots,
                using: chosenSlot,
                scheduledStart: start,
                scheduledEnd: end
            )
        }

        return scheduled.sorted { $0.start < $1.start }
    }

    private func applyHardConstraints(to slots: [TimeSlot]) -> [TimeSlot] {
        slots.filter { slot in
            let startHour = Calendar.current.component(.hour, from: slot.start)
            let endHour = Calendar.current.component(.hour, from: slot.end)

            return slot.durationMinutes >= 10 &&
                startHour >= 6 &&
                endHour <= 21
        }
    }

    private func score(slot: TimeSlot, for item: SmartPlanItem) -> Double {
        let hour = Calendar.current.component(.hour, from: slot.start)

        let energyMatch = energyMatchScore(
            hour: hour,
            activityType: item.activityType
        )

        let context = contextScore(
            slot: slot,
            item: item
        )

        let goalAlignment = goalAlignmentScore(for: item)
        let streakBonus = 0.0

        let w1 = 0.35
        let w2 = 0.10
        let w3 = 0.20
        let w4 = 0.35

        return
            (w1 * energyMatch) +
            (w2 * streakBonus) +
            (w3 * goalAlignment) +
            (w4 * context)
    }

    private func energyMatchScore(
        hour: Int,
        activityType: String
    ) -> Double {
        switch activityType {
        case "strength", "hyrox", "run":
            if (6...9).contains(hour) { return 1.0 }
            if (17...20).contains(hour) { return 0.9 }
            if (12...14).contains(hour) { return 0.5 }
            return 0.2

        case "walk":
            if (12...14).contains(hour) { return 1.0 }
            if (15...17).contains(hour) { return 0.8 }
            if (6...9).contains(hour) { return 0.5 }
            return 0.3

        case "mobility", "recovery":
            if (18...21).contains(hour) { return 1.0 }
            if (12...14).contains(hour) { return 0.7 }
            if (6...9).contains(hour) { return 0.5 }
            return 0.3

        case "meditation":
            if (7...9).contains(hour) { return 0.9 }
            if (12...14).contains(hour) { return 0.8 }
            if (20...21).contains(hour) { return 1.0 }
            return 0.4

        default:
            return 0.5
        }
    }

    private func contextScore(
        slot: TimeSlot,
        item: SmartPlanItem
    ) -> Double {
        let extraMinutes = max(slot.durationMinutes - item.durationMinutes, 0)

        if extraMinutes == 0 { return 1.0 }
        if extraMinutes <= 15 { return 0.9 }
        if extraMinutes <= 30 { return 0.75 }
        return 0.5
    }

    private func goalAlignmentScore(for item: SmartPlanItem) -> Double {
        switch item.activityType {
        case "strength", "hyrox", "run":
            return 0.9
        case "mobility", "recovery":
            return 0.7
        case "walk":
            return 0.6
        case "meditation":
            return 0.8
        default:
            return 0.5
        }
    }

    private func updateSlots(
        _ slots: [TimeSlot],
        using chosenSlot: TimeSlot,
        scheduledStart: Date,
        scheduledEnd: Date
    ) -> [TimeSlot] {
        var updated: [TimeSlot] = []

        for slot in slots {
            if slot.id != chosenSlot.id {
                updated.append(slot)
                continue
            }

            if scheduledStart > slot.start {
                updated.append(
                    TimeSlot(
                        start: slot.start,
                        end: scheduledStart
                    )
                )
            }

            if scheduledEnd < slot.end {
                updated.append(
                    TimeSlot(
                        start: scheduledEnd,
                        end: slot.end
                    )
                )
            }
        }

        return updated.filter { $0.durationMinutes >= 10 }
    }
}
