//
//  virtualizedDataSource.swift
//  GanttisDemo
//
//  Created by DlhSoft on 28/12/2018.
//

import Foundation
import Ganttis

let virtualizedProjectStart = Time.reference.weekStart

class VirtualizedItemManager: GanttChartItemManager {
    init(withAutoDependencies: Bool = false) {
        self.withAutoDependencies = withAutoDependencies
    }
    
    static let initialTotalRowCount = 400_000_000 // 400 million rows.
    var currentTotalRowCount = initialTotalRowCount
    override var sourceTotalRowCount: Int { return currentTotalRowCount }
    
    override var sourcePreferredTimeline: TimeRange {
        let start = virtualizedProjectStart
        let finish = start.adding(weeks: 4_000_000) // About 76,000 years.
        return TimeRange(from: start, to: finish)
    }
    
    override var sourceFilteredItems: [GanttChartItem] {
        return currentItems(range: range, timeline: timeline)
    }
    override var sourceFilteredDependencies: [GanttChartDependency] {
        return currentDependencies(range: range, timeline: timeline)
    }
    
    override func addNewSourceItem(row: Row, time: Time,
                                   isMilestone: Bool) -> GanttChartItem {
        currentTotalRowCount = max(row + 1, currentTotalRowCount)
        let item = super.addNewSourceItem(row: row, time: time, isMilestone: isMilestone)
        addedItems.append(item)
        return item
    }
    override func removeSourceItem(_ item: GanttChartItem) {
        super.removeSourceItem(item)
        addedItems.removeAll { existing in existing === item }
        addedDependencies.removeAll { dependency in
            dependency.from === item || dependency.to === item }
        let key = GanttChartItemKey(row: item.row, time: item.time)
        if cache[key] != nil {
            cache.removeValue(forKey: key)
            removedItemKeys.append(key)
        }
    }
    
    override func addNewSourceDependency(
        from: GanttChartItem, to: GanttChartItem,
        type: GanttChartDependencyType) -> GanttChartDependency {
        let dependency = super.addNewSourceDependency(from: from, to: to, type: type)
        addedDependencies.append(dependency)
        from.hasChanged = true
        to.hasChanged = true
        return dependency
    }
    override func removeSourceDependency(_ dependency: GanttChartDependency) {
        super.removeSourceDependency(dependency)
        addedDependencies.removeAll { existing in existing === dependency }
    }
    
    func currentItems(range: RowRange, timeline: TimeRange) -> [GanttChartItem] {
        return cacheItems(range: range, timeline: timeline) + addedItems
    }
    func currentDependencies(range: RowRange,
                             timeline: TimeRange) -> [GanttChartDependency] {
        return (withAutoDependencies
            ? autoDependencies(cacheItems(range: range, timeline: timeline)) : [])
            + addedDependencies
    }
    
    var addedItems = [GanttChartItem]()
    var addedDependencies = [GanttChartDependency]()
    
    func cacheItems(range: RowRange, timeline: TimeRange) -> [GanttChartItem] {
        cleanupCache(range: range, timeline: timeline)
        let weekStart = timeline.start.weekStart
        let initialLastRow = VirtualizedItemManager.initialTotalRowCount - 1
        for row in range.first...min(range.last, initialLastRow) {
            for week in -1...Int(timeline.duration.value(in: .weeks) + 1) {
                for day in 0..<6 where day % 3 == 0 {
                    cacheItem(row: row, weekStart: weekStart, week: week, day: day)
                }
            }
        }
        return cachedItems
    }
    func cacheItem(row: Row, weekStart: Time, week: Int, day: Int) {
        let start = weekStart.adding(weeks: week).adding(days: day + row % 3)
        let finish = start.adding(days: 2)
        let key = GanttChartItemKey(row: row,
                                    time: TimeRange(from: start, to: finish))
        guard !removedItemKeys.contains(key) && cache[key] == nil else { return }
        cache[key] = GanttChartItem(
            label: "\(row + 1).\(start.week + 1).\(start.dayOfWeek / 3 + 1)",
            row: row, start: start, finish: finish)
    }
    func cleanupCache(range: RowRange, timeline: TimeRange) {
        for (key, _) in cache.filter({ key, item in !item.hasChanged
            && (!range.contains(item.row) || !timeline.intersects(item.time)) }) {
                cache.removeValue(forKey: key)
        }
    }
    
    var cache = [GanttChartItemKey: GanttChartItem]()
    var cachedItems: [GanttChartItem] { return Array(cache.values) }
    var removedItemKeys = [GanttChartItemKey]()
    struct GanttChartItemKey: Hashable {
        var row: Row
        var time: TimeRange
    }
    
    var withAutoDependencies: Bool
    func autoDependencies(_ items: [GanttChartItem]) -> [GanttChartDependency] {
        var dependencies = [GanttChartDependency]()
        for sourceItem in items {
            let dependentItems = items.filter { item in item !== sourceItem
                && item.row >= sourceItem.row
                && item.row <= sourceItem.row + 1
                && item.start >= sourceItem.finish
                && item.start < sourceItem.finish.adding(days: 2) }
            for item in dependentItems {
                let dependency = GanttChartDependency(from: sourceItem, to: item)
                dependency.settings.isReadOnly = true
                dependencies.append(dependency)
            }
        }
        return dependencies
    }
}

func prepareVirtualizedDataManager() -> GanttChartItemManager {
    return VirtualizedItemManager()
}
var virtualizedDataManager = prepareVirtualizedDataManager()

let virtualizedScheduleHighlighters = [ScheduleTimeSelector]()
let virtualizedIntervalHighlighters = [TimeSelector(.weeks)]
let virtualizedTimeScale = TimeScale.continuous
let virtualizedHeaderRows = [
    GanttChartHeaderRow(.weeks,
                        format: .numeric(since: virtualizedProjectStart, in: .weeks)),
    GanttChartHeaderRow(.days, format: .dayOfWeekShortAbbreviation)]
let virtualizedCustomZoomInHeaderRows = [
    GanttChartHeaderRow(.weeks,
                        format: .numeric(since: virtualizedProjectStart, in: .weeks)),
    GanttChartHeaderRow(.days, format: .dayOfWeekShortAbbreviation),
    GanttChartHeaderRow(.halfdays)]
let virtualizedCustomZoomInHourWidth = 2.4
