import Foundation
import Observation

@Observable
final class AlarmEditViewModel {
    var hour: Int = 7
    var minute: Int = 0
    var label: String = ""
    var repeatMode: RepeatMode = .none
    var ringtone: String = "radar"
    var snoozeDuration: Int = 5
    var advanceMinutes: Int = 0
    var deleteAfterRing: Bool = false
    var isEnabled: Bool = true
    var skipHolidays: Bool = true
    var ringOnMakeupDays: Bool = true

    var isEditing: Bool { existingAlarm != nil }
    private var existingAlarm: Alarm?

    func load(from alarm: Alarm?) {
        guard let alarm else { return }
        existingAlarm = alarm
        hour = alarm.hour
        minute = alarm.minute
        label = alarm.label
        repeatMode = alarm.repeatMode
        ringtone = alarm.ringtone
        snoozeDuration = alarm.snoozeDuration
        advanceMinutes = alarm.advanceMinutes
        deleteAfterRing = alarm.deleteAfterRing
        isEnabled = alarm.isEnabled
        skipHolidays = alarm.skipHolidays
        ringOnMakeupDays = alarm.ringOnMakeupDays
    }

    func save(to alarm: Alarm?) -> Alarm {
        let target = alarm ?? Alarm()
        target.hour = hour
        target.minute = minute
        target.label = label
        target.repeatMode = repeatMode
        target.ringtone = ringtone
        target.snoozeDuration = snoozeDuration
        target.advanceMinutes = advanceMinutes
        target.deleteAfterRing = deleteAfterRing
        target.isEnabled = isEnabled
        target.skipHolidays = skipHolidays
        target.ringOnMakeupDays = ringOnMakeupDays
        target.updatedAt = Date()

        let alarmRef = target
        nonisolated(unsafe) let unsafeAlarmRef = alarmRef
        Task {
            let provider = HolidayDataProvider()
            let year = Calendar.current.component(.year, from: Date())
            let holidays = provider.holidays(for: year)
            let makeupDays = provider.makeupDays(for: year)
            try? await AlarmScheduler.shared.scheduleAlarm(unsafeAlarmRef, holidays: holidays, makeupDays: makeupDays)
        }

        return target
    }

    func deleteAlarm(_ alarm: Alarm) {
        let alarmId = alarm.id
        Task {
            try? await AlarmScheduler.shared.cancelAlarm(alarmId)
        }
    }

    var advanceMinutesText: String {
        let l = LocaleManager.shared
        return advanceMinutes == 0 ? l.localizedString("不提前") : "\(advanceMinutes) " + l.localizedString("分钟")
    }

    var snoozeDurationText: String {
        let l = LocaleManager.shared
        return snoozeDuration == 0 ? l.localizedString("关闭") : "\(snoozeDuration) " + l.localizedString("分钟")
    }

    static let ringtoneOptions = ["radar", "beacon", "chimes", "circuit", "constellation", "cosmic", "crystals", "hillside", "nightowl", "playtime", "presto", "radar", "reflection", "sencha", "signal", "silk", "slow_rise", "stargaze", "summit", "twinkle", "uplift"]

    static let snoozeOptions = [0, 1, 3, 5, 10, 15, 30]

    static let advanceOptions = [0, 5, 10, 15, 30, 60]
}
