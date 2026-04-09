import Foundation

extension Date {
    var dateKey: String {
        Alarm.dateKey(for: self)
    }
}
