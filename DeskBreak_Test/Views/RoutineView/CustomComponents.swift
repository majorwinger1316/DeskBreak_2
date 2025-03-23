//
//  CustomComponents.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 21/03/25.

import Foundation

class RoutineStore {
    static let shared = RoutineStore()
    private let routinesKey = "savedRoutines"
    
    var routines: [Routine] {
        get {
            if let data = UserDefaults.standard.data(forKey: routinesKey),
               let savedRoutines = try? JSONDecoder().decode([Routine].self, from: data) {
                return savedRoutines
            }
            return []
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: routinesKey)
            }
        }
    }
    
    // Get routines sorted by the next upcoming occurrence
    func getSortedRoutines() -> [Routine] {
        let now = Date()
        return routines.sorted { routine1, routine2 in
            let nextOccurrence1 = routine1.nextOccurrence(after: now) ?? Date.distantFuture
            let nextOccurrence2 = routine2.nextOccurrence(after: now) ?? Date.distantFuture
            return nextOccurrence1 < nextOccurrence2
        }
    }
    
    // Get the next upcoming routine
    func getNextUpcomingRoutine() -> Routine? {
        let now = Date()
        let sortedRoutines = getSortedRoutines()
        
        for routine in sortedRoutines {
            if let nextOccurrence = routine.nextOccurrence(after: now), nextOccurrence > now {
                return routine
            }
        }
        return nil
    }
    
    func saveRoutine(_ routine: Routine) {
        var currentRoutines = routines
        currentRoutines.append(routine)
        routines = currentRoutines
    }
    
    func removeRoutine(at index: Int) {
        var currentRoutines = routines
        currentRoutines.remove(at: index)
        routines = currentRoutines
    }
    
    // Helper method to get the next occurrence of a routine after a given date
    private func getNextOccurrence(of weekday: WeekdayCode, at time: Date, after date: Date) -> Date? {
        let calendar = Calendar.current
        let targetWeekday = weekday.rawValue
        
        // Get the components for the target time
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        
        // Get the current date's weekday
        let currentWeekday = calendar.component(.weekday, from: date)
        
        // Calculate the days to add to reach the target weekday
        var daysToAdd = targetWeekday - currentWeekday
        if daysToAdd <= 0 {
            daysToAdd += 7 // Move to the next week
        }
        
        // Get the next occurrence date
        guard let nextDate = calendar.date(byAdding: .day, value: daysToAdd, to: date) else {
            return nil
        }
        
        // Set the time for the next occurrence
        var components = calendar.dateComponents([.year, .month, .day], from: nextDate)
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute
        
        return calendar.date(from: components)
    }
}
