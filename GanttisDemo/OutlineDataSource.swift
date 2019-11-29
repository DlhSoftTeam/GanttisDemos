//
//  OutlineDataSource.swift
//  GanttisDemo
//
//  Created by DlhSoft on 02/11/2019.
//

import Foundation
import Ganttis

class OutlineDataSource: OutlineGanttChartDataSource {
    init(for outlineGanttChart: OutlineGanttChart) {
        self.outlineGanttChart = outlineGanttChart
        
        let projectStart = classicProjectStart
        rows = []
        chartDependencies = []
        
        let planningStart = projectStart.adding(days: 0)
        let planning =
            Row(label: "Planning",
                start: planningStart.adding(days: 1).adding(hours: 8),
                finish: planningStart.adding(days: 5).adding(hours: 16),
                completion: 0.75, type: .summary)
        rows.append(planning)
        let analysis =
            Row(label: "Analysis",
                start: planningStart.adding(days: 1).adding(hours: 8),
                finish: planningStart.adding(days: 2).adding(hours: 16),
                completion: 1, details: "Brainstorming")
        let requirements =
            Row(label: "Requirements",
                start: planningStart.adding(days: 3).adding(hours: 8),
                finish: planningStart.adding(days: 5).adding(hours: 16),
                completion: 0.75, attachment: "Robert Bright", details: "Document")
        let architecture =
            Row(label: "Architecture",
                start: planningStart.adding(days: 3).adding(hours: 8),
                finish: planningStart.adding(days: 4).adding(hours: 16),
                completion: 1, attachment: "Jane Gershwin")
        planning.children = [analysis, requirements, architecture]
        chartDependencies.append(ChartDependency(from: analysis, to: requirements))
        chartDependencies.append(ChartDependency(from: analysis, to: architecture))
        let requirementsComplete =
            Row(outlineLabel: "Requirements complete", time: planningStart.adding(days: 7),
                details: "Ready for development",
                schedule: .continuous, type: .milestone)
        rows.append(requirementsComplete)
        chartDependencies.append(ChartDependency(from: requirements, to: requirementsComplete))
        
        let developmentStart = planningStart.adding(days: 7)
        let development =
            Row(label: "Development",
                start: developmentStart.adding(days: 1).adding(hours: 8),
                finish: developmentStart.adding(days: 40).adding(hours: 16),
                type: .summary)
        rows.append(development)
        chartDependencies.append(ChartDependency(from: requirementsComplete, to: development))
        let dateTimes =
            Row(label: "Date-times",
                start: developmentStart.adding(days: 1).adding(hours: 8),
                finish: developmentStart.adding(days: 2).adding(hours: 16),
                attachment: "Diane McField")
        let schedules =
            Row(label: "Schedules",
                start: developmentStart.adding(days: 3).adding(hours: 8),
                finish: developmentStart.adding(days: 5).adding(hours: 16),
                attachment: "Albert Makhav")
        let diagram =
            Row(label: "Diagram",
                start: developmentStart.adding(days: 1).adding(hours: 8),
                finish: developmentStart.adding(days: 3).adding(hours: 12),
                attachment: "Diane McField")
        let bars =
            Row(label: "Bars",
                start: developmentStart.adding(days: 3).adding(hours: 12),
                finish: developmentStart.adding(days: 5).adding(hours: 16),
                attachment: "Albert Makhav")
        let milestones =
            Row(label: "Milestones",
                start: developmentStart.adding(days: 8).adding(hours: 8),
                finish: developmentStart.adding(days: 9).adding(hours: 12),
                attachment: "Diane McField")
        let summaries =
            Row(label: "Summaries",
                start: developmentStart.adding(days: 8).adding(hours: 8),
                finish: developmentStart.adding(days: 9).adding(hours: 16),
                attachment: "Albert Makhav")
        let completion =
            Row(label: "Completion",
                start: developmentStart.adding(days: 9).adding(hours: 12),
                finish: developmentStart.adding(days: 10).adding(hours: 12),
                attachment: "Diane McField", details: "Completion bars")
        let dependencyLines =
            Row(label: "Dependency lines",
                start: developmentStart.adding(days: 10).adding(hours: 8),
                finish: developmentStart.adding(days: 12).adding(hours: 16),
                attachment: "Albert Makhav")
        let highlightedTimes =
            Row(label: "Highlighted times",
                start: developmentStart.adding(days: 15).adding(hours: 8),
                finish: developmentStart.adding(days: 16).adding(hours: 16),
                attachment: "Diane McField",
                details: "Highlighting schedule times or specific intervals")
        let alternativeRows =
            Row(label: "Alternative rows",
                start: developmentStart.adding(days: 15).adding(hours: 8),
                finish: developmentStart.adding(days: 16).adding(hours: 16),
                attachment: "Albert Makhav")
        let headers =
            Row(label: "Headers",
                start: developmentStart.adding(days: 17).adding(hours: 8),
                finish: developmentStart.adding(days: 19).adding(hours: 16),
                attachment: "Diane McField")
        let dragging =
            Row(label: "Dragging",
                start: developmentStart.adding(days: 17).adding(hours: 8),
                finish: developmentStart.adding(days: 19).adding(hours: 16),
                attachment: "Albert Makhav")
        let zooming =
            Row(label: "Zooming",
                start: developmentStart.adding(days: 22).adding(hours: 8),
                finish: developmentStart.adding(days: 23).adding(hours: 12),
                attachment: "Diane McField")
        let contextMenus =
            Row(label: "Context menus",
                start: developmentStart.adding(days: 22).adding(hours: 8),
                finish: developmentStart.adding(days: 23).adding(hours: 16),
                attachment: "Albert Makhav")
        let selection =
            Row(label: "Selection",
                start: developmentStart.adding(days: 23).adding(hours: 12),
                finish: developmentStart.adding(days: 24).adding(hours: 16),
                attachment: "Diane McField")
        let options =
            Row(label: "Options",
                start: developmentStart.adding(days: 24).adding(hours: 8),
                finish: developmentStart.adding(days: 25).adding(hours: 16),
                attachment: "Albert Makhav")
        let behaviors =
            Row(label: "Behaviors",
                start: developmentStart.adding(days: 25).adding(hours: 8),
                finish: developmentStart.adding(days: 26).adding(hours: 16),
                attachment: "Diane McField")
        let style =
            Row(label: "Style",
                start: developmentStart.adding(days: 29).adding(hours: 8),
                finish: developmentStart.adding(days: 30).adding(hours: 16),
                attachment: "Albert Makhav")
        let themes =
            Row(label: "Themes",
                start: developmentStart.adding(days: 31).adding(hours: 8),
                finish: developmentStart.adding(days: 31).adding(hours: 16),
                attachment: "Diane McField")
        let export =
            Row(label: "Export",
                start: developmentStart.adding(days: 31).adding(hours: 8),
                finish: developmentStart.adding(days: 31).adding(hours: 16),
                attachment: "Albert Makhav", details: "PNG image")
        let touchSupport =
            Row(label: "Touch support",
                start: developmentStart.adding(days: 32).adding(hours: 8),
                finish: developmentStart.adding(days: 34).adding(hours: 16),
                attachment: "Albert Makhav", details: "iOS")
        let documentation =
            Row(label: "Documentation",
                start: developmentStart.adding(days: 36).adding(hours: 8),
                finish: developmentStart.adding(days: 40).adding(hours: 16),
                attachment: "Diane McField", details: "Reference and samples")
        development.children = [dateTimes, schedules, diagram, bars, milestones, summaries,
                                completion, dependencyLines, highlightedTimes, alternativeRows,
                                headers, dragging, zooming, contextMenus, selection, options,
                                behaviors, style, themes, export, touchSupport, documentation]
        chartDependencies.append(ChartDependency(from: dateTimes, to: schedules))
        chartDependencies.append(ChartDependency(from: diagram, to: bars))
        chartDependencies.append(ChartDependency(from: bars, to: milestones))
        chartDependencies.append(ChartDependency(from: bars, to: summaries))
        chartDependencies.append(ChartDependency(from: bars, to: completion))
        chartDependencies.append(ChartDependency(from: summaries, to: dependencyLines))
        chartDependencies.append(ChartDependency(from: dependencyLines, to: highlightedTimes))
        chartDependencies.append(ChartDependency(from: dependencyLines, to: alternativeRows))
        chartDependencies.append(ChartDependency(from: alternativeRows, to: headers))
        chartDependencies.append(ChartDependency(from: alternativeRows, to: dragging))
        chartDependencies.append(ChartDependency(from: dragging, to: zooming))
        chartDependencies.append(ChartDependency(from: dragging, to: contextMenus))
        chartDependencies.append(ChartDependency(from: zooming, to: selection))
        chartDependencies.append(ChartDependency(from: zooming, to: options))
        chartDependencies.append(ChartDependency(from: selection, to: behaviors))
        chartDependencies.append(ChartDependency(from: behaviors, to: style))
        chartDependencies.append(ChartDependency(from: style, to: themes))
        chartDependencies.append(ChartDependency(from: style, to: export))
        chartDependencies.append(ChartDependency(from: export, to: touchSupport))
        chartDependencies.append(ChartDependency(from: touchSupport, to: documentation))
        let codeComplete =
            Row(outlineLabel: "Code complete",
                time: developmentStart.adding(days: 42),
                details: "Ready for quality assurance",
                schedule: .continuous, type: .milestone)
        rows.append(codeComplete)
        chartDependencies.append(ChartDependency(from: documentation, to: codeComplete))
        
        let qualityAssuranceStart = developmentStart.adding(days: 42)
        let qualityAssurance =
            Row(label: "Quality assurance",
                start: qualityAssuranceStart.adding(days: 1).adding(hours: 8),
                finish: qualityAssuranceStart.adding(days: 12).adding(hours: 16),
                type: .summary)
        rows.append(qualityAssurance)
        chartDependencies.append(ChartDependency(from: codeComplete, to: qualityAssurance))
        let testing =
            Row(label: "Testing",
                start: qualityAssuranceStart.adding(days: 1).adding(hours: 8),
                finish: qualityAssuranceStart.adding(days: 5).adding(hours: 16),
                attachment: "Victor O'Reilly")
        let resolutions =
            Row(label: "Resolutions",
                start: qualityAssuranceStart.adding(days: 8).adding(hours: 8),
                finish: qualityAssuranceStart.adding(days: 12).adding(hours: 16),
                attachment: "Albert Makhav")
        qualityAssurance.children = [testing, resolutions]
        chartDependencies.append(ChartDependency(from: testing, to: resolutions))
        let developmentComplete =
            Row(outlineLabel: "Development complete",
                time: qualityAssuranceStart.adding(days: 14),
                details: "Ready to release",
                schedule: .continuous, type: .milestone)
        rows.append(developmentComplete)
        chartDependencies.append(ChartDependency(from: resolutions, to: developmentComplete))
        
        let releaseStart = qualityAssuranceStart.adding(days: 14)
        let release =
            Row(label: "Release",
                start: releaseStart.adding(days: 1).adding(hours: 8),
                finish: releaseStart.adding(days: 5).adding(hours: 16),
                type: .summary)
        rows.append(release)
        chartDependencies.append(ChartDependency(from: developmentComplete, to: release))
        let packaging =
            Row(label: "Packaging",
                start: releaseStart.adding(days: 1).adding(hours: 8),
                finish: releaseStart.adding(days: 2).adding(hours: 16),
                attachment: "Albert Makhav")
        let deployment =
            Row(label: "Deployment",
                start: releaseStart.adding(days: 3).adding(hours: 8),
                finish: releaseStart.adding(days: 5).adding(hours: 16),
                attachment: "Diane McField")
        release.children = [packaging, deployment]
        chartDependencies.append(ChartDependency(from: packaging, to: deployment))
        let releaseComplete =
            Row(outlineLabel: "Release complete",
                time: releaseStart.adding(days: 7),
                details: "Ready for end users",
                schedule: .continuous, type: .milestone)
        rows.append(releaseComplete)
        chartDependencies.append(ChartDependency(from: deployment, to: releaseComplete))
        
        outlineGanttChart.schedule = .standard
        
        let columns = outlineView.tableColumns.filter { column in column != outlineColumn }
        for column in columns {
            outlineView.removeTableColumn(column)
        }
        
        outlineColumn.title = "Tasks"
        outlineColumn.width = 180
        outlineColumn.minWidth = 120
        
        startColumn.title = "Start"
        startColumn.minWidth = 120
        startColumnCell.font =
            NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        outlineView.addTableColumn(startColumn)
        finishColumn.title = "Finish"
        finishColumn.minWidth = 120
        finishColumnCell.font =
            NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        outlineView.addTableColumn(finishColumn)
        
        completionColumn.title = "Compl. (%)"
        completionColumn.width = 60
        completionColumnCell.alignment = .right
        completionColumnCell.font =
            NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        outlineView.addTableColumn(completionColumn)
        
        dateFormatter.timeZone = Time.calendar.timeZone
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        attachmentColumn.title = "Assignments"
        outlineView.addTableColumn(attachmentColumn)
        
        detailsColumn.title = "Details"
        detailsColumn.minWidth = 120
        outlineView.addTableColumn(detailsColumn)
        
        outlineHeaderSpacingLabel.stringValue = "My project"
    }
    
    let outlineGanttChart: OutlineGanttChart
    
    var splitView: NSSplitView { return outlineGanttChart.splitView }
    var outlineView: NSOutlineView { return outlineGanttChart.outlineView }
    var outlineHeaderSpacingLabel: NSTextField {
        return outlineGanttChart.outlineHeaderSpacingLabel }
    var outlineColumn: NSTableColumn { return outlineView.outlineTableColumn! }
    let startColumn = NSTableColumn(), finishColumn = NSTableColumn()
    let completionColumn = NSTableColumn(), attachmentColumn = NSTableColumn()
    let detailsColumn = NSTableColumn()
    var startColumnCell: NSCell { return startColumn.dataCell as! NSCell }
    var finishColumnCell: NSCell { return finishColumn.dataCell as! NSCell }
    var completionColumnCell: NSCell { return completionColumn.dataCell as! NSCell }
    var dateFormatter = DateFormatter()
    var numberFormatter = NumberFormatter()
    
    var rows: [Row]
    var chartDependencies: [ChartDependency]
    
    func outlineGanttChart(_ outlineGanttChart: OutlineGanttChart, child index: Int, ofItem item: OutlineGanttChartRow?) -> OutlineGanttChartRow {
        let localItem = item == nil ? rows[index]
            : (item!.context as! Row).children[index]
        return localItem.outlineItem
    }
    func outlineGanttChart(_ outlineGanttChart: OutlineGanttChart, isItemExpandable item: OutlineGanttChartRow) -> Bool {
        return (item.context as! Row).children.count > 0
    }
    func outlineGanttChart(_ outlineGanttChart: OutlineGanttChart, numberOfChildrenOfItem item: OutlineGanttChartRow?) -> Int {
        return item == nil ? rows.count
            : (item!.context as! Row).children.count
    }
    func outlineGanttChart(_ outlineGanttChart: OutlineGanttChart, objectValueFor tableColumn: NSTableColumn?, byItem item: OutlineGanttChartRow?) -> Any? {
        let item = item!, chartItem = item.chartItems.first!
        switch tableColumn {
        case startColumn:
            return dateFormatter.string(from: chartItem.start)
        case finishColumn:
            return dateFormatter.string(from: chartItem.finish)
        case completionColumn:
            return String(format: "%.2f", chartItem.completion * 100)
        case attachmentColumn:
            return chartItem.attachment
        case detailsColumn:
            return chartItem.details
        default:
            return item.label ?? chartItem.label
        }
    }
    func outlineGanttChart(_ outlineGanttChart: OutlineGanttChart, setObjectValue object: Any?, for tableColumn: NSTableColumn?, byItem item: OutlineGanttChartRow?) {
        let item = item!, localItem = item.context as! Row, chartItem = item.chartItems.first!
        let localChartItem = chartItem.context as! ChartItem
        switch tableColumn {
        case startColumn:
            guard let time = dateFormatter.dateTime(from: object as! String) else { return }
            chartItem.start = time
            if chartItem.isMilestone {
                chartItem.finish = time
            }
            outlineGanttChart.applySchedule(for: chartItem)
            outlineGanttChart.applyBehavior(for: chartItem)
            localChartItem.start = chartItem.start
            localChartItem.finish = chartItem.finish
        case finishColumn:
            guard let time = dateFormatter.dateTime(from: object as! String) else { return }
            chartItem.finish = time
            if chartItem.isMilestone {
                chartItem.start = time
            }
            outlineGanttChart.applySchedule(for: chartItem)
            outlineGanttChart.applyBehavior(for: chartItem)
            localChartItem.finish = chartItem.finish
            localChartItem.start = chartItem.start
        case completionColumn:
            guard let percent = Double(object as! String) else { return }
            chartItem.completion = max(0, min(1, percent / 100))
            outlineGanttChart.applyBehavior(for: chartItem)
            localChartItem.completion = chartItem.completion
        case attachmentColumn:
            chartItem.attachment = object as? String
            localChartItem.attachment = chartItem.attachment
        case detailsColumn:
            chartItem.details = object as? String
            localChartItem.details = chartItem.details
        default:
            if localItem.label != nil {
                item.label = object as? String
                localItem.label = item.label
            } else {
                chartItem.label = object as? String
                localChartItem.label = chartItem.label
            }
        }
    }
    func outlineGanttChart(_ outlineGanttChart: OutlineGanttChart, dependenciesFor items: [OutlineGanttChartItem]) -> [OutlineGanttChartDependency] {
        return chartDependencies.map { dependency in dependency.outlineChartDependency }
            .filter { dependency in
                items.contains { item in item === dependency.from || item === dependency.to }
            }
    }
    func outlineGanttChart(_ outlineGanttChart: OutlineGanttChart, timeDidChangeFor item: OutlineGanttChartItem, from originalValue: TimeRange) {
        let localChartItem = item.context as! ChartItem
        localChartItem.start = item.start
        localChartItem.finish = item.finish
    }
    func outlineGanttChart(_ outlineGanttChart: OutlineGanttChart, completionDidChangeFor item: OutlineGanttChartItem, from originalValue: Double) {
        let localChartItem = item.context as! ChartItem
        localChartItem.completion = item.completion
    }
    func outlineGanttChart(_ outlineGanttChart: OutlineGanttChart, didAddDependency dependency: OutlineGanttChartDependency) {
        let localChartDependency = ChartDependency(
            label: dependency.label,
            from: dependency.from.context as! ChartItem,
            to: dependency.to.context as! ChartItem,
            details: dependency.details,
            type: dependency.type)
        chartDependencies.append(localChartDependency)
        dependency.context = localChartDependency
        outlineGanttChart.applyBehavior(for: dependency.from)
    }
    func outlineGanttChart(_ outlineGanttChart: OutlineGanttChart, didRemoveDependency dependency: OutlineGanttChartDependency) {
        chartDependencies.removeAll { localChartDependency in
            localChartDependency === dependency.context as! ChartDependency
        }
    }
    
    class Row {
        init(label: String? = nil, chartItems: [ChartItem] = [], children: [Row] = []) {
            self.label = label
            self.chartItems = chartItems
            self.children = children
        }
        var label: String?
        var chartItems: [ChartItem]
        var chartItem: ChartItem { return chartItems.first! }
        
        convenience init(label: String? = nil, chartItem: ChartItem) {
            self.init(label: label, chartItems: [chartItem])
        }
        var children: [Row]
        
        convenience init(label: String? = nil, start: Time, finish: Time, completion: Double = 0,
                         attachment: String? = nil, details: String? = nil,
                         schedule: Schedule? = nil, type: GanttChartItemType? = nil) {
            self.init(chartItem: ChartItem(label: label, start: start, finish: finish,
                                           completion: completion, attachment: attachment,
                                           details: details, schedule: schedule, type: type))
        }
        convenience init(label: String? = nil, time: Time,
                         attachment: String? = nil, details: String? = nil,
                         schedule: Schedule? = nil, type: GanttChartItemType? = nil) {
            self.init(chartItem: ChartItem(label: label, time: time, attachment: attachment,
                                           details: details, schedule: schedule, type: type))
        }
        convenience init(outlineLabel: String? = nil, label: String? = nil,
                         start: Time, finish: Time, completion: Double = 0,
                         attachment: String? = nil, details: String? = nil,
                         schedule: Schedule? = nil, type: GanttChartItemType? = nil) {
            self.init(label: outlineLabel,
                      chartItem: ChartItem(label: label, start: start, finish: finish,
                                           completion: completion, attachment: attachment,
                                           details: details, schedule: schedule, type: type))
        }
        convenience init(outlineLabel: String? = nil, label: String? = nil, time: Time,
                         attachment: String? = nil, details: String? = nil,
                         schedule: Schedule? = nil, type: GanttChartItemType? = nil) {
            self.init(label: outlineLabel,
                      chartItem: ChartItem(label: label, time: time, attachment: attachment,
                                           details: details, schedule: schedule, type: type))
        }
        
        lazy var outlineItem = OutlineGanttChartRow(
            label: label,
            chartItems: chartItems.map { chartItem in chartItem.outlineChartItem },
            context: self)
    }
    class ChartItem {
        init(label: String? = nil, start: Time, finish: Time, completion: Double = 0,
             attachment: String? = nil, details: String? = nil,
             schedule: Schedule? = nil, type: GanttChartItemType? = nil) {
            self.label = label
            self.start = start
            self.finish = finish
            self.completion = completion
            self.attachment = attachment
            self.details = details
            self.schedule = schedule
            self.type = type ?? .standard
        }
        convenience init(label: String? = nil, time: Time,
                         attachment: String? = nil, details: String? = nil,
                         schedule: Schedule? = nil, type: GanttChartItemType? = nil) {
            self.init(label: label, start: time, finish: time, completion: 0,
                      attachment: attachment, details: details, schedule: schedule, type: type)
        }
        var label: String?
        var start, finish: Time
        var completion: Double
        var attachment: String?
        var details: String?
        var schedule: Schedule?
        var type: GanttChartItemType
        
        lazy var outlineChartItem = OutlineGanttChartItem(
            label: label, start: start, finish: finish, completion: completion,
            attachment: attachment, details: details, schedule: schedule, type: type, context: self)
    }
    class ChartDependency {
        init(label: String? = nil, from: ChartItem, to: ChartItem,
             details: String? = nil, type: GanttChartDependencyType? = nil) {
            self.label = label
            self.from = from
            self.to = to
            self.details = details
            self.type = type ?? .fromFinishToStart
        }
        var label: String?
        var from, to: ChartItem
        var details: String?
        var type: GanttChartDependencyType
        
        convenience init(label: String? = nil, from: Row, to: Row,
                         details: String? = nil, type: GanttChartDependencyType? = nil) {
            self.init(label: label, from: from.chartItem, to: to.chartItem,
                      details: details, type: type)
        }
        
        lazy var outlineChartDependency = OutlineGanttChartDependency(
            label: label, from: from.outlineChartItem, to: to.outlineChartItem,
            details: details, type: type, context: self)
    }
}
