//
//  ClassicDataSource.swift
//  GanttisDemo
//
//  Created by DlhSoft on 28/12/2018.
//

import Foundation
import Ganttis

let classicProjectStart = Time.current.weekStart

func prepareClassicDataSource() -> GanttChartItemSource {
    let projectStart = classicProjectStart
    var items = [GanttChartItem]()
    var dependencies = [GanttChartDependency]()
    var hierarchy = [GanttChartItemHierarchicalRelation]()
    
    let planningStart = projectStart.adding(days: 0)
    let planningRow = 0
    let planning =
        GanttChartItem(label: "Planning", row: planningRow,
                       start: planningStart.adding(days: 1).adding(hours: 8),
                       finish: planningStart.adding(days: 5).adding(hours: 16),
                       completion: 0.75, type: .summary)
    items.append(planning)
    let analysis =
        GanttChartItem(label: "Analysis", row: planningRow + 1,
                       start: planningStart.adding(days: 1).adding(hours: 8),
                       finish: planningStart.adding(days: 2).adding(hours: 16),
                       completion: 1, details: "Brainstorming")
    let requirements =
        GanttChartItem(label: "Requirements", row: planningRow + 2,
                       start: planningStart.adding(days: 3).adding(hours: 8),
                       finish: planningStart.adding(days: 5).adding(hours: 16),
                       completion: 0.75, attachment: "Robert Bright", details: "Document")
    let architecture =
        GanttChartItem(label: "Architecture", row: planningRow + 3,
                       start: planningStart.adding(days: 3).adding(hours: 8),
                       finish: planningStart.adding(days: 4).adding(hours: 16),
                       completion: 1, attachment: "Jane Gershwin")
    let planningItems = [analysis, requirements, architecture]
    items.append(contentsOf: planningItems)
    dependencies.append(GanttChartDependency(from: analysis, to: requirements))
    dependencies.append(GanttChartDependency(from: analysis, to: architecture))
    hierarchy.append(GanttChartItemHierarchicalRelation(parent: planning,
                                                        children: planningItems))
    let requirementsComplete =
        GanttChartItem(row: planningRow + 4,
                       time: planningStart.adding(days: 7),
                       details: "Ready for development",
                       schedule: .continuous, type: .milestone)
    items.append(requirementsComplete)
    dependencies.append(GanttChartDependency(from: requirements, to: requirementsComplete))
    
    let developmentStart = planningStart.adding(days: 7)
    let developmentRow = planningRow + 5
    let development =
        GanttChartItem(label: "Development", row: developmentRow,
                       start: developmentStart.adding(days: 1).adding(hours: 8),
                       finish: developmentStart.adding(days: 40).adding(hours: 16),
                       type: .summary)
    items.append(development)
    dependencies.append(GanttChartDependency(from: requirementsComplete, to: development))
    let dateTimes =
        GanttChartItem(label: "Date-times", row: developmentRow + 1,
                       start: developmentStart.adding(days: 1).adding(hours: 8),
                       finish: developmentStart.adding(days: 2).adding(hours: 16),
                       attachment: "Diane McField")
    let schedules =
        GanttChartItem(label: "Schedules", row: developmentRow + 2,
                       start: developmentStart.adding(days: 3).adding(hours: 8),
                       finish: developmentStart.adding(days: 5).adding(hours: 16),
                       attachment: "Albert Makhav")
    let diagram =
        GanttChartItem(label: "Diagram", row: developmentRow + 3,
                       start: developmentStart.adding(days: 1).adding(hours: 8),
                       finish: developmentStart.adding(days: 3).adding(hours: 12),
                       attachment: "Diane McField")
    let bars =
        GanttChartItem(label: "Bars", row: developmentRow + 4,
                       start: developmentStart.adding(days: 3).adding(hours: 12),
                       finish: developmentStart.adding(days: 5).adding(hours: 16),
                       attachment: "Albert Makhav")
    let milestones =
        GanttChartItem(label: "Milestones", row: developmentRow + 5,
                       start: developmentStart.adding(days: 8).adding(hours: 8),
                       finish: developmentStart.adding(days: 9).adding(hours: 12),
                       attachment: "Diane McField")
    let summaries =
        GanttChartItem(label: "Summaries", row: developmentRow + 6,
                       start: developmentStart.adding(days: 8).adding(hours: 8),
                       finish: developmentStart.adding(days: 9).adding(hours: 16),
                       attachment: "Albert Makhav")
    let completion =
        GanttChartItem(label: "Completion", row: developmentRow + 7,
                       start: developmentStart.adding(days: 9).adding(hours: 12),
                       finish: developmentStart.adding(days: 10).adding(hours: 12),
                       attachment: "Diane McField", details: "Completion bars")
    let dependencyLines =
        GanttChartItem(label: "Dependency lines", row: developmentRow + 8,
                       start: developmentStart.adding(days: 10).adding(hours: 8),
                       finish: developmentStart.adding(days: 12).adding(hours: 16),
                       attachment: "Albert Makhav")
    let highlightedTimes =
        GanttChartItem(label: "Highlighted times", row: developmentRow + 9,
                       start: developmentStart.adding(days: 15).adding(hours: 8),
                       finish: developmentStart.adding(days: 16).adding(hours: 16),
                       attachment: "Diane McField",
                       details: "Highlighting schedule times or specific intervals")
    let alternativeRows =
        GanttChartItem(label: "Alternative rows", row: developmentRow + 10,
                       start: developmentStart.adding(days: 15).adding(hours: 8),
                       finish: developmentStart.adding(days: 16).adding(hours: 16),
                       attachment: "Albert Makhav")
    let headers =
        GanttChartItem(label: "Headers", row: developmentRow + 11,
                       start: developmentStart.adding(days: 17).adding(hours: 8),
                       finish: developmentStart.adding(days: 19).adding(hours: 16),
                       attachment: "Diane McField")
    let dragging =
        GanttChartItem(label: "Dragging", row: developmentRow + 12,
                       start: developmentStart.adding(days: 17).adding(hours: 8),
                       finish: developmentStart.adding(days: 19).adding(hours: 16),
                       attachment: "Albert Makhav")
    let zooming =
        GanttChartItem(label: "Zooming", row: developmentRow + 13,
                       start: developmentStart.adding(days: 22).adding(hours: 8),
                       finish: developmentStart.adding(days: 23).adding(hours: 12),
                       attachment: "Diane McField")
    let contextMenus =
        GanttChartItem(label: "Context menus", row: developmentRow + 14,
                       start: developmentStart.adding(days: 22).adding(hours: 8),
                       finish: developmentStart.adding(days: 23).adding(hours: 16),
                       attachment: "Albert Makhav")
    let selection =
        GanttChartItem(label: "Selection", row: developmentRow + 15,
                       start: developmentStart.adding(days: 23).adding(hours: 12),
                       finish: developmentStart.adding(days: 24).adding(hours: 16),
                       attachment: "Diane McField")
    let options =
        GanttChartItem(label: "Options", row: developmentRow + 16,
                       start: developmentStart.adding(days: 24).adding(hours: 8),
                       finish: developmentStart.adding(days: 25).adding(hours: 16),
                       attachment: "Albert Makhav")
    let behaviors =
        GanttChartItem(label: "Behaviors", row: developmentRow + 17,
                       start: developmentStart.adding(days: 25).adding(hours: 8),
                       finish: developmentStart.adding(days: 26).adding(hours: 16),
                       attachment: "Diane McField")
    let style =
        GanttChartItem(label: "Style", row: developmentRow + 18,
                       start: developmentStart.adding(days: 29).adding(hours: 8),
                       finish: developmentStart.adding(days: 30).adding(hours: 16),
                       attachment: "Albert Makhav")
    let themes =
        GanttChartItem(label: "Themes", row: developmentRow + 19,
                       start: developmentStart.adding(days: 31).adding(hours: 8),
                       finish: developmentStart.adding(days: 31).adding(hours: 16),
                       attachment: "Diane McField")
    let export =
        GanttChartItem(label: "Export", row: developmentRow + 20,
                       start: developmentStart.adding(days: 31).adding(hours: 8),
                       finish: developmentStart.adding(days: 31).adding(hours: 16),
                       attachment: "Albert Makhav", details: "PNG image")
    let touchSupport =
        GanttChartItem(label: "Touch support", row: developmentRow + 21,
                       start: developmentStart.adding(days: 32).adding(hours: 8),
                       finish: developmentStart.adding(days: 34).adding(hours: 16),
                       attachment: "Albert Makhav", details: "iOS")
    let documentation =
        GanttChartItem(label: "Documentation", row: developmentRow + 22,
                       start: developmentStart.adding(days: 36).adding(hours: 8),
                       finish: developmentStart.adding(days: 40).adding(hours: 16),
                       attachment: "Diane McField", details: "Reference and samples")
    let developmentItems = [dateTimes, schedules, diagram, bars, milestones, summaries,
                            completion, dependencyLines, highlightedTimes, alternativeRows,
                            headers, dragging, zooming, contextMenus, selection, options,
                            behaviors, style, themes, export, touchSupport, documentation]
    items.append(contentsOf: developmentItems)
    dependencies.append(GanttChartDependency(from: dateTimes, to: schedules))
    dependencies.append(GanttChartDependency(from: diagram, to: bars))
    dependencies.append(GanttChartDependency(from: bars, to: milestones))
    dependencies.append(GanttChartDependency(from: bars, to: summaries))
    dependencies.append(GanttChartDependency(from: bars, to: completion))
    dependencies.append(GanttChartDependency(from: summaries, to: dependencyLines))
    dependencies.append(GanttChartDependency(from: dependencyLines, to: highlightedTimes))
    dependencies.append(GanttChartDependency(from: dependencyLines, to: alternativeRows))
    dependencies.append(GanttChartDependency(from: alternativeRows, to: headers))
    dependencies.append(GanttChartDependency(from: alternativeRows, to: dragging))
    dependencies.append(GanttChartDependency(from: dragging, to: zooming))
    dependencies.append(GanttChartDependency(from: dragging, to: contextMenus))
    dependencies.append(GanttChartDependency(from: zooming, to: selection))
    dependencies.append(GanttChartDependency(from: zooming, to: options))
    dependencies.append(GanttChartDependency(from: selection, to: behaviors))
    dependencies.append(GanttChartDependency(from: behaviors, to: style))
    dependencies.append(GanttChartDependency(from: style, to: themes))
    dependencies.append(GanttChartDependency(from: style, to: export))
    dependencies.append(GanttChartDependency(from: export, to: touchSupport))
    dependencies.append(GanttChartDependency(from: touchSupport, to: documentation))
    hierarchy.append(GanttChartItemHierarchicalRelation(parent: development,
                                                        children: developmentItems))
    let codeComplete =
        GanttChartItem(row: developmentRow + 23,
                       time: developmentStart.adding(days: 42),
                       details: "Ready for quality assurance",
                       schedule: .continuous, type: .milestone)
    items.append(codeComplete)
    dependencies.append(GanttChartDependency(from: documentation, to: codeComplete))
    
    let qualityAssuranceStart = developmentStart.adding(days: 42)
    let qualityAssuranceRow = developmentRow + 24
    let qualityAssurance =
        GanttChartItem(label: "Quality assurance", row: qualityAssuranceRow,
                       start: qualityAssuranceStart.adding(days: 1).adding(hours: 8),
                       finish: qualityAssuranceStart.adding(days: 12).adding(hours: 16),
                       type: .summary)
    items.append(qualityAssurance)
    dependencies.append(GanttChartDependency(from: codeComplete, to: qualityAssurance))
    let testing =
        GanttChartItem(label: "Testing", row: qualityAssuranceRow + 1,
                       start: qualityAssuranceStart.adding(days: 1).adding(hours: 8),
                       finish: qualityAssuranceStart.adding(days: 5).adding(hours: 16),
                       attachment: "Victor O'Reilly")
    let resolutions =
        GanttChartItem(label: "Resolutions", row: qualityAssuranceRow + 2,
                       start: qualityAssuranceStart.adding(days: 8).adding(hours: 8),
                       finish: qualityAssuranceStart.adding(days: 12).adding(hours: 16),
                       attachment: "Albert Makhav")
    let qualityAssuranceItems = [testing, resolutions]
    items.append(contentsOf: qualityAssuranceItems)
    dependencies.append(GanttChartDependency(from: testing, to: resolutions))
    hierarchy.append(GanttChartItemHierarchicalRelation(parent: qualityAssurance,
                                                        children: qualityAssuranceItems))
    let developmentComplete =
        GanttChartItem(row: qualityAssuranceRow + 3,
                       time: qualityAssuranceStart.adding(days: 14),
                       details: "Ready to release",
                       schedule: .continuous, type: .milestone)
    items.append(developmentComplete)
    dependencies.append(GanttChartDependency(from: resolutions, to: developmentComplete))
    
    let releaseStart = qualityAssuranceStart.adding(days: 14)
    let releaseRow = qualityAssuranceRow + 4
    let release =
        GanttChartItem(label: "Release", row: releaseRow,
                       start: releaseStart.adding(days: 1).adding(hours: 8),
                       finish: releaseStart.adding(days: 5).adding(hours: 16),
                       type: .summary)
    items.append(release)
    dependencies.append(GanttChartDependency(from: developmentComplete, to: release))
    let packaging =
        GanttChartItem(label: "Packaging", row: releaseRow + 1,
                       start: releaseStart.adding(days: 1).adding(hours: 8),
                       finish: releaseStart.adding(days: 2).adding(hours: 16),
                       attachment: "Albert Makhav")
    let deployment =
        GanttChartItem(label: "Deployment", row: releaseRow + 2,
                       start: releaseStart.adding(days: 3).adding(hours: 8),
                       finish: releaseStart.adding(days: 5).adding(hours: 16),
                       attachment: "Diane McField")
    let releaseItems = [packaging, deployment]
    items.append(contentsOf: releaseItems)
    dependencies.append(GanttChartDependency(from: packaging, to: deployment))
    hierarchy.append(GanttChartItemHierarchicalRelation(parent: release,
                                                        children: releaseItems))
    let releaseComplete =
        GanttChartItem(row: releaseRow + 3,
                       time: releaseStart.adding(days: 7),
                       details: "Ready for end users",
                       schedule: .continuous, type: .milestone)
    items.append(releaseComplete)
    dependencies.append(GanttChartDependency(from: deployment, to: releaseComplete))
    
    let itemSource = GanttChartItemSource(items: items, dependencies: dependencies)
    itemSource.schedule = .standard
    itemSource.isColumn = true
    itemSource.hierarchicalRelations = hierarchy
    return itemSource
}

var classicDataSource = prepareClassicDataSource()

var classicScrollableTimeline: TimeRange {
    let projectStart = classicProjectStart
    return TimeRange(from: projectStart, to: projectStart.adding(days: 71))
}

let classicHourWidth = 5.0
let classicVisibilitySchedule = Schedule.fullWeek

let classicScheduleHighlighters = [ScheduleTimeSelector(.weekends)]
let classicIntervalHighlighters = [TimeSelector(.weeks),
                                   TimeSelector(.time(classicProjectStart.adding(days: 4)))]
let classicHeaderRows =
    [GanttChartHeaderRow(.weeks, format: "dd MMM"),
     GanttChartHeaderRow(.days, format: .dayOfWeekShortAbbreviation)]
let classicCustomZoomOutHeaderRows =
    [GanttChartHeaderRow(.months),
     GanttChartHeaderRow(.weeks, format: "dd"),
     GanttChartHeaderRow(.days, format: .dayOfWeekShortAbbreviation)]
let classicCustomZoomOutHourWidth = 7.5
