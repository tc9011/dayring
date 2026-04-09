import Foundation
import Observation

@Observable
final class AlarmEditViewModel {
    var hour: Int = 7
    var minute: Int = 0
    var label: String = ""
    var repeatMode: RepeatMode = .weekly(days: Weekday.workdays)
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
        return target
    }

    var advanceMinutesText: String {
        advanceMinutes == 0 ? "不提前" : "\(advanceMinutes) 分钟"
    }

    var snoozeDurationText: String {
        snoozeDuration == 0 ? "关闭" : "\(snoozeDuration) 分钟"
    }
}
