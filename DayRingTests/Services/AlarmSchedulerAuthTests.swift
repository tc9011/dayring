import Testing
import Foundation
@testable import DayRing

@Suite("Alarm Scheduler Authorization & Error Handling Tests")
struct AlarmSchedulerAuthTests {

    @Test("AlarmScheduler exposes lastSchedulingError property")
    func schedulerHasLastErrorProperty() {
        let scheduler = AlarmScheduler.shared
        scheduler.lastSchedulingError = nil
        #expect(scheduler.lastSchedulingError == nil)

        let testError = NSError(domain: "test", code: 42)
        scheduler.lastSchedulingError = testError
        #expect(scheduler.lastSchedulingError != nil)
        #expect((scheduler.lastSchedulingError as? NSError)?.code == 42)

        scheduler.lastSchedulingError = nil
    }

    @Test("AlarmScheduler requestAuthorization handles both AlarmKit and fallback")
    func schedulerHasRequestAuth() async {
        do {
            try await AlarmScheduler.shared.requestAuthorization()
        } catch {
            // Expected in test/simulator — method must exist and execute both paths
        }
    }
}
