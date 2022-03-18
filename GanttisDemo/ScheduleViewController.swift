//
//  ScheduleViewController.swift
//  GanttisDemo
//
//  Created by DlhSoft on 23/01/2019.
//

import Cocoa
import Ganttis

class ScheduleViewController: NSViewController, ExcludedTimeIntervalProvider {
    @IBOutlet weak var dayStartTimePicker: NSDatePicker!
    @IBOutlet weak var dayFinishTimePicker: NSDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        initializeDatePickers()
    }
    
    func initializeDatePickers() {
        let calendar = Time.calendar
        let timeZone = calendar.timeZone
        let minDate = Date(Time.reference)
        let maxDate = Date(Time.reference.adding(hours: 23).adding(minutes: 59))
        for timePicker: NSDatePicker in [dayStartTimePicker, dayFinishTimePicker] {
            timePicker.calendar = calendar
            timePicker.timeZone = timeZone
            timePicker.minDate = minDate
            timePicker.maxDate = maxDate
        }
    }
    
    var schedule: ScheduleDefinition! {
        didSet {
            isInitializingInternally = true
            weekStart = value(from: schedule.weekInterval.start)
            weekFinish = value(from: schedule.weekInterval.finish)
            dayStart = value(from: schedule.dayInterval.start)
            dayFinish = value(from: schedule.dayInterval.finish)
            if let schedule = schedule as? Schedule,
                schedule.excludedIntervalProvider != nil {
                excludingIntervals = 1
            } else {
                excludingIntervals = 0
            }
            isInitializingInternally = false
        }
    }
    
    @objc dynamic var weekStart: NSNumber? {
        didSet {
            guard weekStart != oldValue else { return }
            if weekFinish?.doubleValue ?? 6 < weekStart?.doubleValue ?? 0 {
                let wasInitializingInternally = isInitializingInternally
                isInitializingInternally = true
                weekFinish = weekStart
                isInitializingInternally = wasInitializingInternally
            }
            updateSchedule()
        }
    }
    @objc dynamic var weekFinish: NSNumber? {
        didSet {
            guard weekFinish != oldValue else { return }
            if weekStart?.doubleValue ?? 0 > weekFinish?.doubleValue ?? 6 {
                let wasInitializingInternally = isInitializingInternally
                isInitializingInternally = true
                weekStart = weekFinish
                isInitializingInternally = wasInitializingInternally
            }
            updateSchedule()
        }
    }
    
    @objc dynamic var dayStart = Date() {
        didSet {
            guard dayStart != oldValue else { return }
            if actualDayFinish <= dayStart {
                let wasInitializingInternally = isInitializingInternally
                isInitializingInternally = true
                actualDayFinish = Date(Time(dayStart).adding(minutes: 1))
                isInitializingInternally = wasInitializingInternally
            }
            updateSchedule()
        }
    }
    @objc dynamic var dayFinish = Date() {
        didSet {
            guard dayFinish != oldValue else { return }
            if dayStart >= actualDayFinish {
                let wasInitializingInternally = isInitializingInternally
                isInitializingInternally = true
                dayStart = Date(Time(actualDayFinish).adding(minutes: -1))
                isInitializingInternally = wasInitializingInternally
            }
            updateSchedule()
        }
    }
    var actualDayFinish: Date {
        get {
            let time = Time(dayFinish)
            return time.timeOfDay > 0 ? dayFinish : Date(Time.reference.adding(days: 1))
        }
        set {
            let time = Time(newValue)
            dayFinish = time.timeOfDay > 0 ? newValue: Date(Time.reference)
        }
    }
    
    @objc dynamic var excludingIntervals: NSNumber? {
        didSet {
            guard !isInitializingInternally else { return }
            updateSchedule()
        }
    }
    
    func updateSchedule() {
        guard !isInitializingInternally else { return }
        schedule = Schedule(weekInterval: WeekRange(from: dayOfWeek(from: weekStart),
                                                    to: dayOfWeek(from: weekFinish)),
                            dayInterval: DayRange(from: timeOfDay(from: dayStart),
                                                  to: timeOfDay(from: actualDayFinish)),
                            excludedIntervalProvider: excludingIntervals == 1 ? self : nil)
        observer?.scheduleDidChange(on: self)
    }
    var isInitializingInternally = false
    
    func value(from dayOfWeek: DayOfWeek) -> NSNumber? {
        switch dayOfWeek {
        case .sunday: return 0
        case .monday: return 1
        case .tuesday: return 2
        case .wednesday: return 3
        case .thursday: return 4
        case .friday: return 5
        case .saturday: return 6
        default: return 0
        }
    }
    func dayOfWeek(from value: NSNumber?) -> DayOfWeek {
        switch value {
        case 0: return .sunday
        case 1: return .monday
        case 2: return .tuesday
        case 3: return .wednesday
        case 4: return .thursday
        case 5: return .friday
        case 6: return .saturday
        default: return .sunday
        }
    }
    
    func value(from timeOfDay: TimeOfDay) -> Date {
        let time = Time.reference.adding(duration: timeOfDay)
        return time.dayStart == Time.reference ?
            Date(time) : Date(Time.reference)
    }
    func timeOfDay(from value: Date) -> TimeOfDay {
        let time = Time(value)
        return time.dayStart == Time.reference ?
            time.timeOfDay : TimeOfDay(from: 24, in: .hours)
    }
    
    func excludedIntervals(for time: Time, towards limit: Time) -> [TimeRange] {
        let start = time.dayStart, finish = limit.dayStart
        var intervals = [TimeRange](), date = start
        while limit >= time ? date <= finish : date >= finish {
            let dateIntervals = excludedIntervals(for: date)
            intervals.append(contentsOf: dateIntervals)
            if date != start && !dateIntervals.isEmpty { break }
            date = date.adding(days: limit >= time ? 1 : -1)
        }
        return intervals
    }
    func excludedIntervals(for date: Time) -> [TimeRange] {
        var intervals = [TimeRange]()
        if date.day == 1 || date.day == 16 {
            intervals.append(TimeRange(from: date.dayStart, to: date.dayFinish))
        }
        if date.dayOfWeek == .friday {
            intervals.append(TimeRange(from: date.adding(hours: 12), to: date.dayFinish))
        }
        intervals.append(TimeRange(from: date.adding(hours: 13), to: date.adding(hours: 14)))
        return intervals
    }
    
    @objc dynamic var isExcludedIntervalsEditingEnabled = true
    @objc dynamic var isEnabled = true
    
    weak var observer: ScheduleViewObserver?
}

protocol ScheduleViewObserver: AnyObject {
    func scheduleDidChange(on controller: ScheduleViewController)
}
