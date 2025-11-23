import Foundation
import EventKit

actor CalendarActor {
    let eventStore = EKEventStore()
    var isAccessGranted: Bool = false
    
    func setAccessGranted(_ granted: Bool) {
        self.isAccessGranted = granted
    }
}
