//
//  ViewController.swift
//  GanttisDemo
//
//  Created by DlhSoft on 08/12/2018.
//

import Cocoa
import Ganttis

class ViewController: NSViewController, GanttChartItemObserver, GanttChartContentSelectionObserver, GanttChartContentViewportObserver, GanttChartRangeObserver, GanttChartTimelineObserver, GanttChartContentStyleObserver, GanttChartHeaderRowSelector, GanttChartHeaderStyleObserver, ScheduleViewObserver, NSOutlineViewDelegate {
    @IBOutlet weak var outlineGanttChart: OutlineGanttChart!
    @IBOutlet weak var ganttChart: GanttChart!
    @IBOutlet weak var editTabView: NSTabView!
    @IBOutlet weak var timelineStartDatePicker: NSDatePicker!
    @IBOutlet weak var timelineFinishDatePicker: NSDatePicker!
    @IBOutlet weak var itemStartDatePicker: NSDatePicker!
    @IBOutlet weak var itemFinishDatePicker: NSDatePicker!
    @IBOutlet weak var itemMinStartDatePicker: NSDatePicker!
    @IBOutlet weak var itemMaxStartDatePicker: NSDatePicker!
    @IBOutlet weak var itemMinFinishDatePicker: NSDatePicker!
    @IBOutlet weak var itemMaxFinishDatePicker: NSDatePicker!
    @IBOutlet weak var selectableHeaderRowIndexesMenu: NSMenu!
    
    lazy var outlineView: NSOutlineView = outlineGanttChart.outlineView
    
    var itemSource: GanttChartItemSource!
    var itemManager: GanttChartItemManager!
    var contentController: GanttChartContentController!
    var headerController: GanttChartHeaderController!
    var controller: GanttChartController!
    var zoom = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        initializeDatePickers()
        initializeOutlineView()
        initializeOutlineDataSource()
    }
    
    func initializeDatePickers() {
        let calendar = Time.calendar
        let timeZone = calendar.timeZone
        for datePicker: NSDatePicker in [
            timelineStartDatePicker, timelineFinishDatePicker,
            itemStartDatePicker, itemFinishDatePicker,
            itemMinStartDatePicker, itemMaxStartDatePicker,
            itemMinFinishDatePicker, itemMaxFinishDatePicker] {
            datePicker.calendar = calendar
            datePicker.timeZone = timeZone
        }
    }
    func initializeOutlineView() {
        outlineView.delegate = self
    }
    
    func initializeOutlineDataSource() {
        initializeControllers()
        outlineGanttChart.dataSource = outlineDataSource
        outlineView.expandItem(nil, expandChildren: true)
        controller = outlineGanttChart.ganttChart.controller
        headerController = controller.headerController
        contentController = controller.contentController
        itemManager = contentController.itemManager
        contentController.scrollableTimeline = classicScrollableTimeline
        contentController.visibilitySchedule = classicVisibilitySchedule
        contentController.hourWidth = classicHourWidth
        contentController.scheduleHighlighters = classicScheduleHighlighters
        contentController.intervalHighlighters = classicIntervalHighlighters
        contentController.timeScale = classicTimeScale
        headerController.rows = classicHeaderRows
        initializeAutoShiftingScrollableTimeline()
        initializeGanttChart()
        contentController.scrollVisibleTimeline(toStartOn: classicProjectStart)
        initializeObservers()
        prepareCustomTheme()
        initializeTheme()
        isTimelineEditingEnabled = true
        isRowCountEditingEnabled = false
        isItemRowEditingEnabled = false
        isVisibilityScheduleExcludedIntervalsEditingEnabled = true
        initializeEditableValues()
        minHeaderRowCount = 1
        minHeaderRowHeight = defaultHeaderRowHeight as NSNumber
        outlineGanttChart.autoApplySchedule = true
    }
    lazy var outlineDataSource = OutlineDataSource(for: outlineGanttChart)
    
    func initializeClassicDataSource() {
        initializeControllers()
        itemSource = classicDataSource
        itemManager = itemSource
        contentController = GanttChartContentController()
        contentController.itemManager = itemManager
        contentController.scrollableTimeline = classicScrollableTimeline
        contentController.visibilitySchedule = classicVisibilitySchedule
        contentController.hourWidth = classicHourWidth
        contentController.scheduleHighlighters = classicScheduleHighlighters
        contentController.intervalHighlighters = classicIntervalHighlighters
        contentController.timeScale = classicTimeScale
        headerController = GanttChartHeaderController()
        initializeAutoShiftingScrollableTimeline()
        initializeGanttChart()
        contentController.scrollVisibleTimeline(toStartOn: classicProjectStart)
        initializeObservers()
        prepareCustomTheme()
        initializeTheme()
        isTimelineEditingEnabled = true
        isRowCountEditingEnabled = true
        isItemRowEditingEnabled = true
        isVisibilityScheduleExcludedIntervalsEditingEnabled = true
        initializeEditableValues()
        minHeaderRowCount = nil
        minHeaderRowHeight = nil
    }
    func initializeVirtualizedDataSource() {
        initializeControllers()
        itemManager = virtualizedDataManager
        contentController = GanttChartContentController()
        contentController.itemManager = itemManager
        contentController.extraRowCount = 0
        contentController.preferredTimelineMargin = 0
        contentController.scheduleHighlighters = virtualizedScheduleHighlighters
        contentController.intervalHighlighters = virtualizedIntervalHighlighters
        contentController.timeScale = virtualizedTimeScale
        headerController = GanttChartHeaderController()
        headerController.rows = virtualizedHeaderRows
        initializeGanttChart()
        contentController.scroll(to: virtualizedProjectStart)
        initializeObservers()
        prepareCustomTheme()
        initializeTheme()
        isTimelineEditingEnabled = false
        isRowCountEditingEnabled = false
        isItemRowEditingEnabled = true
        isVisibilityScheduleExcludedIntervalsEditingEnabled = false
        initializeEditableValues()
        minHeaderRowCount = nil
        minHeaderRowHeight = nil
    }
    func initializeControllers() {
        controller = nil
        contentController = nil
        headerController = nil
        itemManager = nil
        itemSource = nil
    }
    func initializeAutoShiftingScrollableTimeline() {
        contentController.settings.autoShiftsScrollableTimelineBy =
            TimeInterval(from: 1, in: .weeks)
    }
    func initializeGanttChart() {
        contentController.settings.allowsSelectingElements = true
        contentController.settings.selectsNewlyCreatedElements = true
        contentController.settings.numberOfClicksRequiredToActivateElements = 2
        contentController.settings.activationTogglesExpansionForSummaryItems =
            outlineGanttChart.isHidden
        contentController.settings.showsCompletionBarsForSummaryItems = false
        contentController.settings.temporaryBarWidth = contentController.hourWidth * 24
        contentController.zoom = zoom
        headerController.settings.minZoom = 0.4
        headerController.settings.maxZoom = 8
        if !outlineGanttChart.isHidden {
            outlineGanttChart.scrollRowToVisible(0)
            outlineGanttChart.scrollColumnToVisible(0)
        } else {
            controller = GanttChartController(headerController: headerController,
                                              contentController: contentController)
            ganttChart.controller = controller
            contentController.scrollVertically(to: Row(0))
        }
    }
    func initializeObservers() {
        if outlineGanttChart.isHidden {
            itemManager.itemObserver = self
        } else {
            outlineGanttChart.ganttChartItemObserver = self
        }
        contentController.selectionObserver = self
        contentController.viewportObserver = self
        controller.rangeObserver = self
        controller.timelineObserver = self
        contentController.styleObserver = self
        headerController.styleObserver = self
    }
    
    @IBAction func dataSourceSelectionDidChange(_ segmentedControl: NSSegmentedControl) {
        outlineView.selectRowIndexes([], byExtendingSelection: false)
        contentController.selectedItem = nil
        switch segmentedControl.label(forSegment: segmentedControl.selectedSegment) {
        case "Outline":
            setGanttChartVisibility(outline: true)
            initializeOutlineDataSource()
        case "Chart":
            setGanttChartVisibility(outline: false)
            initializeClassicDataSource()
        case "Virtualized":
            setGanttChartVisibility(outline: false)
            initializeVirtualizedDataSource()
        default: break
        }
    }
    func setGanttChartVisibility(outline: Bool) {
        outlineGanttChart.isHidden = !outline
        ganttChart.isHidden = outline
    }
    
    @IBAction func zoomSelectionDidChange(_ popUpButton: NSPopUpButton) {
        switch popUpButton.selectedItem!.title {
        case "50%":
            zoom = 0.5
        case "75%":
            zoom = 0.75
        case "100%":
            zoom = 1
        case "150%":
            zoom = 1.5
        case "200%":
            zoom = 2
        default: break
        }
        let timelineCenter = headerController.visibleTimelineCenter
        headerController.zoom = zoom
        headerController.scrollVisibleTimeline(toCenterOn: timelineCenter)
        let selectedItem = popUpButton.selectedItem!
        let menu = popUpButton.menu!
        for (index, item) in menu.items.enumerated() {
            if index == 0 {
                item.title = selectedItem.title
            } else {
                item.state = item == selectedItem ? .on : .off
            }
        }
    }
    func zoomDidChange(to value: Double, from originalValue: Double) {
        zoom = value
        let popUpButton = view.window!.toolbar!.items
            .filter { item in item.label == "Zoom" }.first!.view as! NSPopUpButton
        for (index, item) in popUpButton.menu!.items.enumerated() {
            if index == 0 {
                item.title = "\(Int(round(value * 100)))%"
            } else {
                item.state = value == 1 && item.title == "100%" ? .on : .off
            }
        }
        contentController.settings.temporaryBarWidth = contentController.actualHourWidth * 24
        if useCustomHeaders == 1 {
            headerRowHeight = NSNumber(value: headerController.rowHeight)
        }
        isUseCustomHeadersEnabled = outlineGanttChart.isHidden &&
            zoom == 1 && hourWidth == defaultHourWidth as NSNumber
    }
    
    @IBAction func resetDataSource(_ button: NSButton) {
        contentController.selectedItem = nil
        if !outlineGanttChart.isHidden {
            outlineDataSource = OutlineDataSource(for: outlineGanttChart)
            initializeOutlineDataSource()
            outlineGanttChart.reloadData()
            outlineView.expandItem(nil, expandChildren: true)
        } else if itemSource === classicDataSource {
            classicDataSource = prepareClassicDataSource()
            initializeClassicDataSource()
        } else {
            virtualizedDataManager = prepareVirtualizedDataManager()
            initializeVirtualizedDataSource()
        }
    }
    
    @IBAction func addItem(_ button: NSButton) {
        let time = contentController.visibleTimeline.start
        if !outlineGanttChart.isHidden {
            let row = outlineView.numberOfRows, schedule = itemManager.schedule
            let start = schedule.nextTime(for: time)
            let finish = max(start, schedule.previousTime(for: start.adding(hours: 24)))
            outlineDataSource.rows.append(OutlineDataSource.Row(
                chartItems: [OutlineDataSource.ChartItem(
                    label: "New item", start: start, finish: finish)],
                children: []))
            outlineGanttChart.reloadData()
            outlineGanttChart.scrollRowToVisible(row)
            outlineView.selectRowIndexes([row], byExtendingSelection: false)
        } else {
            guard contentController.settings.allowsCreatingBars else { return }
            isAddingItemInternally = true
            let row = min(itemManager.totalRowCount, VirtualizedItemManager.initialTotalRowCount - 1)
            let item = itemManager.addNewItem(on: row, at: time)
            contentController.selectedItem = item
            contentController.scrollVertically(to: row)
            isAddingItemInternally = false
        }
    }
    func itemWasAdded(_ item: GanttChartItem) {
        if !item.isMilestone {
            item.label = "New item"
            item.finish = itemManager.schedule.finish(from: item.start, for: 24, in: .hours)
        }
        guard hierarchicalBehavior == 1 else { return }
        guard !isAddingItemInternally else { return }
        guard let parent = itemSource.items
            .filter({ item in item.type == .summary })
            .filter({ parent in parent.row <= item.row }).last else { return }
        itemSource.addHierarchicalRelation(parent: parent, item: item)
        itemSource.applyBehavior(for: item)
        defaultHierarchicalRelations = itemSource.hierarchicalRelations
    }
    var isAddingItemInternally = false
    
    @IBAction func removeItem(_ button: NSButton) {
        if !outlineGanttChart.isHidden {
            let selectedRowIndexes = outlineView.selectedRowIndexes
            if selectedRowIndexes.count > 0 {
                let selectedRows = selectedRowIndexes.map { index in
                    outlineView.item(atRow: index) as! OutlineGanttChartRow }
                removeOutlineItemsFor(selectedRows, from: &outlineDataSource.rows)
                outlineGanttChart.reloadData()
            }
        } else {
            if let item = contentController.selectedItem {
                guard contentController.settings.allowsDeletingBar(for: item)
                    else { return }
                itemManager.removeItem(item)
            } else if let dependency = contentController.selectedDependency {
                guard contentController.settings.allowsDeletingDependencyLine(for: dependency)
                    else { return }
                itemManager.removeDependency(dependency)
            }
            contentController.selectedItem = nil
        }
    }
    func removeOutlineItemsFor(_ selectedRows: [OutlineGanttChartRow],
                               from array: inout [OutlineDataSource.Row]) {
        array.removeAll { row in selectedRows.contains { selectedRow in
            selectedRow.context as! OutlineDataSource.Row === row }}
        for item in array {
            removeOutlineItemsFor(selectedRows, from: &item.children)
        }
    }
    func itemWasRemoved(_ item: GanttChartItem) {
        guard hierarchicalBehavior == 1 else { return }
        itemSource.removeFromHierarchy(item: item)
        itemSource.applyBehavior()
        defaultHierarchicalRelations = itemSource.hierarchicalRelations
    }
    
    @IBAction func exportImage(_ button: NSButton) {
        if !outlineGanttChart.isHidden {
            outlineView.selectRowIndexes([], byExtendingSelection: false)
        }
        contentController.selectedItem = nil
        let savePanel = NSSavePanel()
        savePanel.allowedFileTypes = ["png"]
        if savePanel.runModal() == NSApplication.ModalResponse.OK {
            let filename = savePanel.url!
            let imageData = !outlineGanttChart.isHidden
                ? outlineGanttChart.imageData : ganttChart.imageData
            do { try imageData.write(to: filename) } catch { }
        }
    }
    
    func prepareCustomTheme() {
        let themeName = "Demo"
        var style = GanttChartContentBaseStyle(.standard)
        style.backgroundColor = Color(red: 0.5, green: 0.75, blue: 1, alpha: 0.125)
        style.barFillColor = .orange
        style.selectionColor = Color(red: 0.7, green: 0.7, blue: 0.7)
        var darkStyle = GanttChartContentBaseStyle(.standard, mode: .dark)
        darkStyle.backgroundColor = Color(red: 0.25, green: 0.375, blue: 0.5, alpha: 0.25)
        darkStyle.barFillColor = .orange
        darkStyle.selectionColor = Color(red: 0.7, green: 0.7, blue: 0.7)
        var headerStyle = GanttChartHeaderBaseStyle(.standard)
        headerStyle.labelForegroundColor = Color(red: 0.25, green: 0.5, blue: 0.75)
        var darkHeaderStyle = GanttChartHeaderBaseStyle(.standard, mode: .dark)
        darkHeaderStyle.labelForegroundColor = Color(red: 0.5, green: 0.75, blue: 0.875)
        contentController.setStyleForTheme(themeName, to: style)
        contentController.setStyleForTheme(themeName, mode: .dark, to: darkStyle)
        headerController.setStyleForTheme(themeName, to: headerStyle)
        headerController.setStyleForTheme(themeName, mode: .dark, to: darkHeaderStyle)
    }
    func initializeTheme() {
        controller.theme = theme
    }
    @IBAction func themeSelectionDidChange(_ segmentedControl: NSSegmentedControl) {
        initializeTheme()
    }
    var theme: Theme {
        guard let window = view.window else { return .standard }
        let toolbarItems = window.toolbar!.items
        let themeToolbarItem = toolbarItems.filter { item in item.label == "Theme" }.first!
        let themeSegmentedControl = themeToolbarItem.view as! NSSegmentedControl
        switch themeSegmentedControl.selectedSegment {
        case 0:
            return .standard
        case 1:
            return .aqua
        case 2:
            return .jewel
        case 3:
            return .custom(name: "Demo")
        default: fatalError()
        }
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        if !outlineGanttChart.isHidden {
            let toolbarItems = view.window!.toolbar!.items
            let removeItem = toolbarItems.filter { item in item.label == "Remove" }.first!
            removeItem.isEnabled = outlineView.selectedRowIndexes.count > 0
        }
        if !outlineGanttChart.isHidden && !outlineView.selectedRowIndexes.isEmpty {
            contentController.selectedItem = nil
        }
    }
    func selectionDidChange() {
        let selectedItem = contentController.selectedItem
        selectedItem?.hasChanged = true
        let isItemSelected = selectedItem != nil
        let toolbarItems = view.window!.toolbar!.items
        if outlineGanttChart.isHidden {
            let removeItem = toolbarItems.filter { item in item.label == "Remove" }.first!
            removeItem.isEnabled = isItemSelected
        }
        let editSegmentedControl =
            toolbarItems.filter { item in item.label == "Edit" }.first!
                .view as! NSSegmentedControl
        editSegmentedControl.setLabel(isItemSelected ? "Item" : "Diagram", forSegment: 0)
        editSegmentedControl.selectedSegment = 0
        editTabView.selectTabViewItem(at: 0)
        for tabViewItem in editTabView.tabViewItems {
            let selectionTabView = tabViewItem.view?.subviews.first as! NSTabView
            selectionTabView.selectTabViewItem(at: isItemSelected ? 1 : 0)
        }
        initializeItem()
        if !outlineGanttChart.isHidden && selectedItem != nil {
            outlineView.selectRowIndexes([], byExtendingSelection: false)
        }
    }
    @IBAction func editTabSelectionDidChange(_ segmentedControl: NSSegmentedControl) {
        let tabIndex = segmentedControl.selectedSegment
        guard contentController.selectedElement == nil ||
            editTabView.tabViewItem(at: tabIndex) != editTabView.selectedTabViewItem else {
            guard tabIndex == 0 else { return }
            contentController.selectedItem = nil
            return
        }
        editTabView.selectTabViewItem(at: tabIndex)
        if tabIndex == 3 && !NSColorPanel.sharedColorPanelExists {
            NSColorPanel.setPickerMask([.crayonModeMask, .rgbModeMask])
            NSColorPanel.setPickerMode(.crayon)
            NSColorPanel.shared.showsAlpha = true
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldEdit tableColumn: NSTableColumn?, item: Any) -> Bool {
        let outlineItem = item as! OutlineGanttChartRow, chartItem = outlineItem.chartItems.first!
        return !contentSettings.isReadOnly && !chartItem.settings.isReadOnly
    }
    
    func initializeEditableValues() {
        initializeTimeline()
        rowCount = contentController.actualRowCount as NSNumber
        defaultHourWidth = headerController.hourWidth
        hourWidth = defaultHourWidth as NSNumber
        defaultRowHeight = contentController.rowHeight
        rowHeight = defaultRowHeight as NSNumber
        defaultAttachmentLabelWidth = contentController.attachmentLabelWidth
        initializeHeaderRows()
        defaultHeaderRowHeight = controller.headerRowHeight
        headerRowHeight = defaultHeaderRowHeight as NSNumber
        highlightingType = highlighter?.forTimeouts ?? true ? 1 : 0
        initializeSeparators()
        initializeItemUpdateGranularity()
        initializeSettings()
        initializeVisibilitySchedule()
        initializeHighlightingSchedule()
        initializeItemsSchedule()
        initializeStyle()
    }
    
    func initializeTimeline() {
        let timeline = contentController.actualTimeline
        isInitializingTimelineInternally = true
        timelineStart = Date(timeline.start)
        timelineFinish = Date(timeline.finish)
        isInitializingTimelineInternally = false
    }
    @objc dynamic var timelineStart = Date() {
        didSet {
            guard timelineStart != oldValue else { return }
            if timelineFinish < timelineStart {
                let wasInitialzingInternally = isInitializingTimelineInternally
                isInitializingTimelineInternally = true
                timelineFinish = timelineStart
                isInitializingTimelineInternally = wasInitialzingInternally
            }
            updateTimeline()
        }
    }
    @objc dynamic var timelineFinish = Date() {
        didSet {
            guard timelineFinish != oldValue else { return }
            if timelineStart > timelineFinish {
                let wasInitialzingInternally = isInitializingTimelineInternally
                isInitializingTimelineInternally = true
                timelineStart = timelineFinish
                isInitializingTimelineInternally = wasInitialzingInternally
            }
            updateTimeline()
        }
    }
    func updateTimeline() {
        guard !isInitializingTimelineInternally else { return }
        contentController.scrollableTimeline = TimeRange(from: Time(timelineStart),
                                                         to: Time(timelineFinish))
    }
    var isInitializingTimelineInternally = false
    @objc dynamic var isTimelineEditingEnabled = true
    
    @objc dynamic var rowCount: NSNumber? {
        didSet {
            guard rowCount != oldValue else { return }
            guard let contentController = contentController else { return }
            contentController.desiredScrollableRowCount = rowCount as? Int
        }
    }
    @objc dynamic var isRowCountEditingEnabled = true
    
    func totalContentRowCountDidChange() {
        guard contentController != nil else { return }
        rowCount = contentController.actualRowCount as NSNumber
    }
    func timelineDidChange() {
        guard contentController != nil else { return }
        let timeline = contentController.actualTimeline
        timelineStart = Date(timeline.start)
        timelineFinish = Date(timeline.finish)
    }
    
    @objc dynamic var hourWidth: NSNumber? {
        didSet {
            guard hourWidth != oldValue else { return }
            guard let headerController = headerController else { return }
            headerController.hourWidth = hourWidth as? Double ?? defaultHourWidth
            isUseCustomHeadersEnabled = outlineGanttChart.isHidden &&
                zoom == 1 && hourWidth == defaultHourWidth as NSNumber
        }
    }
    var defaultHourWidth: Double!
    @objc dynamic var rowHeight: NSNumber? {
        didSet {
            guard rowHeight != oldValue else { return }
            guard let contentController = contentController else { return }
            contentController.rowHeight = rowHeight as? Double ?? defaultRowHeight
        }
    }
    var defaultRowHeight: Double!
    
    func initializeHeaderRows() {
        isInitializingHeaderRowsInternally = true
        selectedHeaderRowIndex = nil
        headerRowCount = headerController.rowCount as NSNumber
        useCustomHeaders = 0
        isUseCustomHeadersEnabled = outlineGanttChart.isHidden &&
            zoom == 1 && hourWidth == defaultHourWidth as NSNumber
        selectedHeaderRowIndex = 0
        isInitializingHeaderRowsInternally = false
    }
    
    @objc dynamic var headerRowCount: NSNumber? {
        didSet {
            guard headerRowCount != oldValue else { return }
            let count = headerRowCount as? Int ?? 2
            selectableHeaderRowIndexesMenu.removeAllItems()
            for index in 0..<count {
                let menuItem = NSMenuItem()
                menuItem.title = "Header \(index + 1)"
                selectableHeaderRowIndexesMenu.addItem(menuItem)
            }
            selectedHeaderRowIndex = nil
            updateHeaderRows()
        }
    }
    @objc dynamic var minHeaderRowCount: NSNumber?
    @objc dynamic var isHeaderRowCountEditingEnabled = true
    @objc dynamic var useCustomHeaders = NSNumber() {
        didSet {
            guard useCustomHeaders != oldValue else { return }
            guard isUseCustomHeadersEnabled else { return }
            isHeaderRowCountEditingEnabled = useCustomHeaders == 0
            updateHeaderRows()
        }
    }
    @objc dynamic var isUseCustomHeadersEnabled = true
    
    @objc dynamic var selectedHeaderRowIndex: NSNumber? {
        didSet {
            guard selectedHeaderRowIndex != oldValue else { return }
            guard let index = selectedHeaderRowIndex as? Int else { return }
            guard let headerController = headerController else { return }
            let headerRow = headerController.rows[index]
            let selector = headerRow.selectors.first!
            
            var intervalSelector = selector.intervalSelector
            if let enclosedSelector = intervalSelector as? EnclosedTimeIntervalSelector {
                intervalSelector = enclosedSelector.selector
                headerRowSeparatorsBoundToVisibleTimeline = 1
            } else {
                headerRowSeparatorsBoundToVisibleTimeline = 0
            }
            if let periodSelector = intervalSelector as? CalendarPeriodSelector {
                switch periodSelector.unit {
                case .years:
                    headerRowSeparatorsOn = 0
                case .quarters:
                    headerRowSeparatorsOn = 1
                case .months:
                    headerRowSeparatorsOn = 2
                default: break
                }
                headerRowSeparatorsPeriod = periodSelector.period as NSNumber
            } else if let periodSelector = intervalSelector as? PeriodSelector {
                switch periodSelector.unit {
                case .weeks:
                    headerRowSeparatorsOn = 3
                    switch periodSelector.origin.dayOfWeek {
                    case .sunday:
                        headerRowWeekSeparatorsStartingOn = 0
                    case .monday:
                        headerRowWeekSeparatorsStartingOn = 1
                    case .saturday:
                        headerRowWeekSeparatorsStartingOn = 2
                    default: break
                    }
                case .days:
                    headerRowSeparatorsOn = 4
                case .halfdays:
                    headerRowSeparatorsOn = 5
                case .hours:
                    headerRowSeparatorsOn = 6
                case .minutes:
                    headerRowSeparatorsOn = 7
                default: break
                }
                headerRowSeparatorsPeriod = periodSelector.period as NSNumber
            }
            
            let labelGenerator = selector.labelGenerator
            var formatter: DateFormatter? = nil
            var numericUnit: TimeUnit? = nil
            if let labelGenerator = labelGenerator
                as? FormattedTimeIntervalLabelGenerator {
                headerRowDisplayingIntervals = 1
                formatter = labelGenerator.formatter
            } else if let labelGenerator = labelGenerator
                as? DurationTimeIntervalLabelGenerator {
                headerRowDisplayingIntervals = 1
                headerRowFormat = 39
                numericUnit = labelGenerator.unit
                headerRowNumericFormatOnPeriodsOfType =
                    labelGenerator.schedule == nil ? 0 : 1
                headerRowNumericFormatStartingAtZero =
                    labelGenerator.zeroBased == true ? 1 : 0
                headerRowNumericFormatShowingNegativeValues =
                    labelGenerator.includingNegativeValues == true ? 1 : 0
            } else if let labelGenerator = labelGenerator
                as? FormattedTimeLabelGenerator {
                headerRowDisplayingIntervals = 0
                formatter = labelGenerator.formatter
            } else if let labelGenerator = labelGenerator
                as? DurationTimeLabelGenerator {
                headerRowDisplayingIntervals = 0
                headerRowFormat = 39
                numericUnit = labelGenerator.unit
                headerRowNumericFormatOnPeriodsOfType =
                    labelGenerator.schedule == nil ? 0 : 1
                headerRowNumericFormatStartingAtZero =
                    labelGenerator.zeroBased == true ? 1 : 0
                headerRowNumericFormatShowingNegativeValues =
                    labelGenerator.includingNegativeValues == true ? 1 : 0
            }
            if let unit = numericUnit {
                switch unit {
                case .weeks:
                    headerRowNumericFormatOnPeriodsOfUnit = 0
                case .days:
                    headerRowNumericFormatOnPeriodsOfUnit = 1
                case .hours:
                    headerRowNumericFormatOnPeriodsOfUnit = 2
                case .minutes:
                    headerRowNumericFormatOnPeriodsOfUnit = 3
                case .seconds:
                    headerRowNumericFormatOnPeriodsOfUnit = 4
                default: break
                }
            }
            if let formatter = formatter {
                if formatter.dateStyle == .short && formatter.timeStyle == .short {
                    headerRowFormat = 0
                } else {
                    switch formatter.dateStyle {
                    case .full:
                        headerRowFormat = 1
                    case .medium:
                        headerRowFormat = 2
                    case .short:
                        headerRowFormat = 3
                    default:
                        switch formatter.timeStyle {
                            case .medium:
                                headerRowFormat = 4
                            case .short:
                                headerRowFormat = 5
                            default:
                                switch formatter.dateFormat {
                                case "d":
                                    headerRowFormat = 6
                                case "dd":
                                    headerRowFormat = 7
                                case "d MMMM":
                                    headerRowFormat = 8
                                case "d MMMM yyyy":
                                    headerRowFormat = 9
                                case "D":
                                    headerRowFormat = 10
                                case "DDD":
                                    headerRowFormat = 11
                                case "EEEE":
                                    headerRowFormat = 12
                                case "EEEEE":
                                    headerRowFormat = 13
                                case "EEEEEE":
                                    headerRowFormat = 14
                                case "E":
                                    headerRowFormat = 15
                                case "W":
                                    headerRowFormat = 16
                                case "w":
                                    headerRowFormat = 17
                                case "ww":
                                    headerRowFormat = 18
                                case "MMMM":
                                    headerRowFormat = 19
                                case "MMMMM":
                                    headerRowFormat = 20
                                case "MMM":
                                    headerRowFormat = 21
                                case "M":
                                    headerRowFormat = 22
                                case "MM":
                                    headerRowFormat = 23
                                case "MMMM yyyy":
                                    headerRowFormat = 24
                                case "QQQ":
                                    headerRowFormat = 25
                                case "Q":
                                    headerRowFormat = 26
                                case "QQQ yyyy":
                                    headerRowFormat = 27
                                case "yyyy":
                                    headerRowFormat = 28
                                case "yy":
                                    headerRowFormat = 29
                                case "a":
                                    headerRowFormat = 30
                                case "H":
                                    headerRowFormat = 31
                                case "HH":
                                    headerRowFormat = 32
                                case "h":
                                    headerRowFormat = 33
                                case "hh":
                                    headerRowFormat = 34
                                case "m":
                                    headerRowFormat = 35
                                case "mm":
                                    headerRowFormat = 36
                                case "s":
                                    headerRowFormat = 37
                                case "ss":
                                    headerRowFormat = 38
                                default:
                                    headerRowFormat = 40
                                }
                        }
                    }
                }
                if headerRowFormat!.intValue >= 6 && headerRowFormat!.intValue != 39 {
                    headerRowCustomFormat = formatter.dateFormat
                }
            }
        }
    }
    
    @objc dynamic var headerRowSeparatorsOn: NSNumber? {
        didSet {
            guard headerRowSeparatorsOn != oldValue else { return }
            areHeaderRowSeparatorsOnWeeks = headerRowSeparatorsOn == 3 ? 1 : 0
            updateHeaderRows()
        }
    }
    @objc dynamic var areHeaderRowSeparatorsOnWeeks: NSNumber?
    @objc dynamic var headerRowWeekSeparatorsStartingOn: NSNumber? {
        didSet {
            guard headerRowWeekSeparatorsStartingOn != oldValue else { return }
            updateHeaderRows()
        }
    }
    @objc dynamic var headerRowSeparatorsPeriod: NSNumber? {
        didSet {
            guard headerRowSeparatorsPeriod != oldValue else { return }
            updateHeaderRows()
        }
    }
    @objc dynamic var headerRowSeparatorsBoundToVisibleTimeline: NSNumber? {
        didSet {
            guard headerRowSeparatorsBoundToVisibleTimeline != oldValue else { return }
            updateHeaderRows()
        }
    }
    @objc dynamic var headerRowFormat: NSNumber? {
        didSet {
            guard headerRowFormat != oldValue else { return }
            updateHeaderRows()
            switch headerRowFormat {
            case 6:
                headerRowCustomFormat = "d"
            case 7:
                headerRowCustomFormat = "dd"
            case 8:
                headerRowCustomFormat = "d MMMM"
            case 9:
                headerRowCustomFormat = "d MMMM yyyy"
            case 10:
                headerRowCustomFormat = "D"
            case 11:
                headerRowCustomFormat = "DDD"
            case 12:
                headerRowCustomFormat = "EEEE"
            case 13:
                headerRowCustomFormat = "EEEEE"
            case 14:
                headerRowCustomFormat = "EEEEEE"
            case 15:
                headerRowCustomFormat = "E"
            case 16:
                headerRowCustomFormat = "W"
            case 17:
                headerRowCustomFormat = "w"
            case 18:
                headerRowCustomFormat = "ww"
            case 19:
                headerRowCustomFormat = "MMMM"
            case 20:
                headerRowCustomFormat = "MMMMM"
            case 21:
                headerRowCustomFormat = "MMM"
            case 22:
                headerRowCustomFormat = "M"
            case 23:
                headerRowCustomFormat = "MM"
            case 24:
                headerRowCustomFormat = "MMMM yyyy"
            case 25:
                headerRowCustomFormat = "QQQ"
            case 26:
                headerRowCustomFormat = "Q"
            case 27:
                headerRowCustomFormat = "QQQ yyyy"
            case 28:
                headerRowCustomFormat = "yyyy"
            case 29:
                headerRowCustomFormat = "yy"
            case 30:
                headerRowCustomFormat = "a"
            case 31:
                headerRowCustomFormat = "H"
            case 32:
                headerRowCustomFormat = "HH"
            case 33:
                headerRowCustomFormat = "h"
            case 34:
                headerRowCustomFormat = "hh"
            case 35:
                headerRowCustomFormat = "m"
            case 36:
                headerRowCustomFormat = "mm"
            case 37:
                headerRowCustomFormat = "s"
            case 38:
                headerRowCustomFormat = "ss"
            case 40: break
            default:
                headerRowCustomFormat = nil
            }
            isHeaderRowFormatNumeric = headerRowFormat == 39 ? 1 : 0
            isHeaderRowFormatCustom = headerRowFormat == 40 ? 1 : 0
        }
    }
    @objc dynamic var isHeaderRowFormatNumeric: NSNumber?
    @objc dynamic var isHeaderRowFormatCustom: NSNumber?
    @objc dynamic var headerRowCustomFormat: String? {
        didSet {
            guard headerRowCustomFormat != oldValue else { return }
            updateHeaderRows()
        }
    }
    @objc dynamic var headerRowNumericFormatOnPeriodsOfType: NSNumber? {
        didSet {
            guard headerRowNumericFormatOnPeriodsOfType != oldValue else { return }
            updateHeaderRows()
        }
    }
    @objc dynamic var headerRowNumericFormatOnPeriodsOfUnit: NSNumber? {
        didSet {
            guard headerRowNumericFormatOnPeriodsOfUnit != oldValue else { return }
            updateHeaderRows()
        }
    }
    @objc dynamic var headerRowNumericFormatStartingAtZero: NSNumber? {
        didSet {
            guard headerRowNumericFormatStartingAtZero != oldValue else { return }
            updateHeaderRows()
        }
    }
    @objc dynamic var headerRowNumericFormatShowingNegativeValues: NSNumber? {
        didSet {
            guard headerRowNumericFormatShowingNegativeValues != oldValue else { return }
            updateHeaderRows()
        }
    }
    @objc dynamic var headerRowDisplayingIntervals: NSNumber? {
        didSet {
            guard headerRowDisplayingIntervals != oldValue else { return }
            updateHeaderRows()
        }
    }
    
    func updateHeaderRows() {
        guard !isInitializingHeaderRowsInternally else { return }
        if useCustomHeaders == 1 {
            headerController.rowSelector = self
        } else {
            headerController.rowSelector = nil
            let count = headerRowCount as? Int ?? 2, existingCount = headerController.rows.count
            let countDiff = count - existingCount
            if countDiff < 0 {
                headerController.rows.removeLast(-countDiff)
            } else {
                for _ in existingCount..<count {
                    headerController.rows.append(GanttChartHeaderRow(.weeks))
                }
            }
            isAnyHeaderRowSelectable = count > 0
            if let index = selectedHeaderRowIndex as? Int {
                headerController.rows[index] = headerRow
            } else if count > 0 {
                selectedHeaderRowIndex = count - 1 as NSNumber
            }
        }
    }
    @objc dynamic var isAnyHeaderRowSelectable = true
    var isInitializingHeaderRowsInternally = false
    
    var headerRow: GanttChartHeaderRow {
        var type: TimeIntervalType
        let weekStartingOn: DayOfWeek
        switch headerRowWeekSeparatorsStartingOn {
        case 0:
            weekStartingOn = .sunday
        case 1:
            weekStartingOn = .monday
        case 2:
            weekStartingOn = .saturday
        default:
            weekStartingOn = .sunday
        }
        let period = headerRowSeparatorsPeriod as? Double ?? 1
        let intPeriod = headerRowSeparatorsPeriod as? Int ?? 1
        switch headerRowSeparatorsOn {
        case 0:
            type = .years(period: intPeriod)
        case 1:
            type = .quarters(period: intPeriod)
        case 2:
            type = .months(period: intPeriod)
        case 3:
            type = .weeks(period: period, startingOn: weekStartingOn)
        case 4:
            type = .days(period: period)
        case 5:
            type = .halfdays(period: period)
        case 6:
            type = .hours(period: period)
        case 7:
            type = .minutes(period: period)
        default:
            type = .weeks(period: period, startingOn: weekStartingOn)
        }
        if headerRowSeparatorsBoundToVisibleTimeline == 1 {
            type = .visibleTimeline(type)
        }
        
        var format: TimeLabelFormat? = nil
        switch headerRowFormat {
        case 0:
            format = .dateTime
        case 1:
            format = .longDate
        case 2:
            format = .date
        case 3:
            format = .shortDate
        case 4:
            format = .time
        case 5:
            format = .shortTime
        case 6:
            format = .day
        case 7:
            format = .dayWithLeadingZero
        case 8:
            format = .dayMonth
        case 9:
            format = .dayMonthYear
        case 10:
            format = .dayOfYear
        case 11:
            format = .dayOfYearWithLeadingZeroes
        case 12:
            format = .dayOfWeek
        case 13:
            format = .dayOfWeekShortAbbreviation
        case 14:
            format = .dayOfWeekAbbreviation
        case 15:
            format = .dayOfWeekLongAbbreviation
        case 16:
            format = .weekOfMonth
        case 17:
            format = .weekOfYear
        case 18:
            format = .weekOfYearWithLeadingZero
        case 19:
            format = .month
        case 20:
            format = .monthShortAbbreviation
        case 21:
            format = .monthAbbreviation
        case 22:
            format = .monthNumber
        case 23:
            format = .monthNumberWithLeadingZero
        case 24:
            format = .monthYear
        case 25:
            format = .quarter
        case 26:
            format = .quarterNumber
        case 27:
            format = .quarterYear
        case 28:
            format = .year
        case 29:
            format = .yearOfCentury
        case 30:
            format = .periodOfDay
        case 31:
            format = .hour
        case 32:
            format = .hourWithLeadingZero
        case 33:
            format = .hourOfPeriod
        case 34:
            format = .hourOfPeriodWithLeadingZero
        case 35:
            format = .minute
        case 36:
            format = .minuteWithLeadingZero
        case 37:
            format = .second
        case 38:
            format = .secondWithLeadingZero
        case 39:
            let schedule: Schedule?
            switch headerRowNumericFormatOnPeriodsOfType {
            case 0:
                schedule = nil
            case 1:
                schedule = .standard
            default:
                schedule = nil
            }
            let unit: TimeUnit
            switch headerRowNumericFormatOnPeriodsOfUnit {
            case 0:
                unit = .weeks
            case 1:
                unit = .days
            case 2:
                unit = .hours
            case 3:
                unit = .minutes
            case 4:
                unit = .seconds
            default:
                unit = .weeks
            }
            let since = !outlineGanttChart.isHidden || itemSource === classicDataSource
                ? Time.current.weekStart : Time.reference
            format = .numeric(since: since, in: unit, schedule: schedule,
                              zeroBased: headerRowNumericFormatStartingAtZero == 1,
                              includingNegativeValues: headerRowNumericFormatShowingNegativeValues == 1)
        default:
            format = nil
        }
        
        let selector: TimeSelector
        let intervals = headerRowDisplayingIntervals == 1
        if let format = format {
            selector = TimeSelector(type, format: format, intervals: intervals)
        } else {
            selector = TimeSelector(type, format: headerRowCustomFormat ?? "dd MMM",
                                    intervals: intervals)
        }
        return GanttChartHeaderRow(selector)
    }
    
    func rows(for hourWidth: Double) -> [GanttChartHeaderRow]? {
        if !outlineGanttChart.isHidden || itemSource === classicDataSource {
            if outlineGanttChart.isHidden && hourWidth < classicCustomZoomOutHourWidth {
                return classicCustomZoomOutHeaderRows
            } else {
                return classicHeaderRows
            }
        } else {
            if hourWidth <= virtualizedCustomZoomInHourWidth {
                return virtualizedHeaderRows
            } else {
                return virtualizedCustomZoomInHeaderRows
            }
        }
    }
    
    @objc dynamic var headerRowHeight: NSNumber? {
        didSet {
            guard headerRowHeight != oldValue else { return }
            guard let controller = controller else { return }
            controller.headerRowHeight = headerRowHeight as? Double ?? defaultHeaderRowHeight
        }
    }
    var defaultHeaderRowHeight: Double!
    @objc dynamic var minHeaderRowHeight: NSNumber?

    @objc dynamic var highlightingType: NSNumber? {
        didSet {
            guard highlightingType != oldValue else { return }
            updateHighlightingSchedule()
        }
    }
    
    func initializeSeparators() {
        let selector = contentController.intervalHighlighters.first!
        var intervalSelector = selector.intervalSelector
        if let enclosedSelector = intervalSelector as? EnclosedTimeIntervalSelector {
            intervalSelector = enclosedSelector.selector
        }
        if let periodSelector = intervalSelector as? CalendarPeriodSelector {
            switch periodSelector.unit {
            case .years:
                separatorsOn = 0
            case .quarters:
                separatorsOn = 1
            case .months:
                separatorsOn = 2
            default: break
            }
            separatorsPeriod = periodSelector.period as NSNumber
        } else if let periodSelector = intervalSelector as? PeriodSelector {
            switch periodSelector.unit {
            case .weeks:
                separatorsOn = 3
                switch periodSelector.origin.dayOfWeek {
                case .sunday:
                    weekSeparatorsStartingOn = 0
                case .monday:
                    weekSeparatorsStartingOn = 1
                case .saturday:
                    weekSeparatorsStartingOn = 2
                default: break
                }
            case .days:
                separatorsOn = 4
            case .halfdays:
                separatorsOn = 5
            case .hours:
                separatorsOn = 6
            case .minutes:
                separatorsOn = 7
            default: break
            }
            separatorsPeriod = periodSelector.period as NSNumber
        }
    }
    @objc dynamic var separatorsOn: NSNumber? {
        didSet {
            guard separatorsOn != oldValue else { return }
            areSeparatorsOnWeeks = separatorsOn == 3 ? 1 : 0
            updateSeparators()
        }
    }
    @objc dynamic var areSeparatorsOnWeeks: NSNumber?
    @objc dynamic var weekSeparatorsStartingOn: NSNumber? {
        didSet {
            guard weekSeparatorsStartingOn != oldValue else { return }
            updateSeparators()
        }
    }
    @objc dynamic var separatorsPeriod: NSNumber? {
        didSet {
            guard separatorsPeriod != oldValue else { return }
            updateSeparators()
        }
    }
    func updateSeparators() {
        var type: TimeIntervalType
        let weekStartingOn: DayOfWeek
        switch weekSeparatorsStartingOn {
        case 0:
            weekStartingOn = .sunday
        case 1:
            weekStartingOn = .monday
        case 2:
            weekStartingOn = .saturday
        default:
            weekStartingOn = .sunday
        }
        let period = separatorsPeriod as? Double ?? 1
        let intPeriod = separatorsPeriod as? Int ?? 1
        switch separatorsOn {
        case 0:
            type = .years(period: intPeriod)
        case 1:
            type = .quarters(period: intPeriod)
        case 2:
            type = .months(period: intPeriod)
        case 3:
            type = .weeks(period: period, startingOn: weekStartingOn)
        case 4:
            type = .days(period: period)
        case 5:
            type = .halfdays(period: period)
        case 6:
            type = .hours(period: period)
        case 7:
            type = .minutes(period: period)
        default:
            type = .weeks(period: period, startingOn: weekStartingOn)
        }
        contentController.intervalHighlighters =
            [TimeSelector(type), contentController.intervalHighlighters[1]]
    }
    
    func initializeItemUpdateGranularity() {
        guard let contentController = contentController else { return }
        isInitializingItemUpdateGranularityInternally = true
        switch contentController.timeScale {
        case .continuous:
            itemUpdateGranularity = 4
            itemUpdateGranularityPeriod = 1
        case .intervals(let period, let unit, _, _):
            switch unit {
            case .weeks:
                itemUpdateGranularity = 0
            case .days:
                itemUpdateGranularity = 1
            case .hours:
                itemUpdateGranularity = 2
            case .minutes:
                itemUpdateGranularity = 3
            default:
                itemUpdateGranularity = 3
            }
            itemUpdateGranularityPeriod = period as NSNumber?
        @unknown default:
            fatalError()
        }
        isInitializingItemUpdateGranularityInternally = false
    }
    @objc dynamic var itemUpdateGranularity: NSNumber? {
        didSet {
            let isContinuous = itemUpdateGranularity == 4
            isItemUpdateGranularityPeriodical = !isContinuous ? 1 : 0
            if isContinuous {
                let wasInitialzingInternally = isInitializingItemUpdateGranularityInternally
                isInitializingItemUpdateGranularityInternally = true
                itemUpdateGranularityPeriod = 1
                isInitializingItemUpdateGranularityInternally = wasInitialzingInternally
            }
            updateItemUpdateGranularity()
        }
    }
    @objc dynamic var isItemUpdateGranularityPeriodical = NSNumber()
    @objc dynamic var itemUpdateGranularityPeriod: NSNumber? {
        didSet {
            updateItemUpdateGranularity()
        }
    }
    func updateItemUpdateGranularity() {
        guard !isInitializingItemUpdateGranularityInternally else { return }
        let period = itemUpdateGranularityPeriod as? Double ?? 1
        switch itemUpdateGranularity {
        case 4:
            contentController.timeScale = .continuous
        case 0:
            contentController.timeScale = .intervalsWith(period: period, in: .weeks)
        case 1:
            contentController.timeScale = .intervalsWith(period: period, in: .days)
        case 2:
            contentController.timeScale = .intervalsWith(period: period, in: .hours)
        case 3:
            contentController.timeScale = .intervalsWith(period: period, in: .minutes)
        default:
            contentController.timeScale = .continuous
        }
    }
    var isInitializingItemUpdateGranularityInternally = false
    
    func initializeSettings() {
        isInitializingSettingsInternally = true
        showsLabels = contentSettings.showsLabels ? 1 : 0
        showsAttachments = contentController.showsAttachments ? 1 : 0
        attachmentLabelWidth = contentController.attachmentLabelWidth as NSNumber
        showsToolTips = contentSettings.showsToolTips ? 1 : 0
        showsCompletionBars = contentSettings.showsCompletionBars ? 1 : 0
        showsDependencyLines = contentSettings.showsDependencyLines ? 1 : 0
        drawsVerticallyEndingDependencyLinesWhenApplicable = contentSettings.drawsVerticallyEndingDependencyLinesWhenApplicable ? 1 : 0
        drawsDependencyLinesSpanningHorizontalDistancePrimarilyOnSourceRow = contentSettings.drawsDependencyLinesSpanningHorizontalDistancePrimarilyOnSourceRow ? 1 : 0
        allowsMovingBars = contentSettings.allowsMovingBars ? 1 : 0
        allowsResizingBars = contentSettings.allowsResizingBars ? 1 : 0
        allowsResizingBarsAtStart = contentSettings.allowsResizingBarsAtStart ? 1 : 0
        allowsMovingBarsVertically = contentSettings.allowsMovingBarsVertically ? 1 : 0
        allowsResizingCompletionBars = contentSettings.allowsResizingCompletionBars ? 1 : 0
        preservesCompletedDurationUponResizingBars = contentSettings.preservesCompletedDurationUponResizingBars ? 1 : 0
        allowsCreatingBars = contentSettings.allowsCreatingBars ? 1 : 0
        allowsCreatingMilestones = contentSettings.allowsCreatingMilestones ? 1 : 0
        allowsDeletingBars = contentSettings.allowsDeletingBars ? 1 : 0
        allowsCreatingDependencyLines = contentSettings.allowsCreatingDependencyLines ? 1 : 0
        allowsCreatingDependencyLinesFromStart = contentSettings.allowsCreatingDependencyLinesFromStart ? 1 : 0
        allowsCreatingDependencyLinesToFinish = contentSettings.allowsCreatingDependencyLinesToFinish ? 1 : 0
        allowsDeletingDependencyLines = contentSettings.allowsDeletingDependencyLines ? 1 : 0
        isReadOnly = contentSettings.isReadOnly ? 1 : 0
        allowsSelectingElements = contentSettings.allowsSelectingElements ? 1 : 0
        allowsZooming = headerSettings.allowsZooming ? 1 : 0
        itemSourceBehaviorsEnabled = itemSource != nil ? 1 : 0
        isAutoSchedulingBehaviorEnabled = !outlineGanttChart.isHidden || itemSource != nil ? 1 : 0
        columnBehavior = !outlineGanttChart.isHidden || itemSource?.isColumn ?? false ? 1 : 0
        hierarchicalBehavior = !outlineGanttChart.isHidden || itemSource?.hierarchicalRelations != nil ? 1 : 0
        defaultHierarchicalRelations = itemSource?.hierarchicalRelations
        autoSchedulingBehavior = itemSource?.isAutoScheduling ?? false ? 1 : 0
        isInitializingSettingsInternally = false
    }
    @objc dynamic var showsLabels = NSNumber() {
        didSet {
            guard !isInitializingSettingsInternally else { return }
            contentSettings.showsLabels = showsLabels == 1
            contentController.settingsDidChange()
        }
    }
    @objc dynamic var showsAttachments = NSNumber() {
        didSet {
            guard !isInitializingSettingsInternally else { return }
            contentController.showsAttachments = showsAttachments == 1
        }
    }
    @objc dynamic var attachmentLabelWidth: NSNumber? {
        didSet {
            guard attachmentLabelWidth != oldValue else { return }
            guard let contentController = contentController else { return }
            contentController.attachmentLabelWidth =
                attachmentLabelWidth as? Double ?? defaultAttachmentLabelWidth
        }
    }
    var defaultAttachmentLabelWidth: Double!
    @objc dynamic var showsToolTips = NSNumber() {
        didSet {
            guard !isInitializingSettingsInternally else { return }
            contentSettings.showsToolTips = showsToolTips == 1
        }
    }
    @objc dynamic var showsCompletionBars = NSNumber() {
        didSet {
            guard !isInitializingSettingsInternally else { return }
            contentSettings.showsCompletionBars = showsCompletionBars == 1
            contentController.settingsDidChange()
        }
    }
    @objc dynamic var showsDependencyLines = NSNumber() {
        didSet {
            guard !isInitializingSettingsInternally else { return }
            contentSettings.showsDependencyLines = showsDependencyLines == 1
            contentController.settingsDidChange()
        }
    }
    @objc dynamic var drawsVerticallyEndingDependencyLinesWhenApplicable = NSNumber() {
        didSet {
            guard !isInitializingSettingsInternally else { return }
            contentSettings.drawsVerticallyEndingDependencyLinesWhenApplicable = drawsVerticallyEndingDependencyLinesWhenApplicable == 1
            contentController.settingsDidChange()
        }
    }
    @objc dynamic var drawsDependencyLinesSpanningHorizontalDistancePrimarilyOnSourceRow
        = NSNumber() {
        didSet {
            guard !isInitializingSettingsInternally else { return }
            
            contentSettings.drawsDependencyLinesSpanningHorizontalDistancePrimarilyOnSourceRow = drawsDependencyLinesSpanningHorizontalDistancePrimarilyOnSourceRow == 1
            contentController.settingsDidChange()
        }
    }
    @objc dynamic var allowsMovingBars = NSNumber() {
        didSet {
            guard !isInitializingSettingsInternally else { return }
            contentSettings.allowsMovingBars = allowsMovingBars == 1
        }
    }
    @objc dynamic var allowsResizingBars = NSNumber() {
        didSet {
            guard !isInitializingSettingsInternally else { return }
            contentSettings.allowsResizingBars = allowsResizingBars == 1
        }
    }
    @objc dynamic var allowsResizingBarsAtStart = NSNumber() {
        didSet {
            guard !isInitializingSettingsInternally else { return }
            contentSettings.allowsResizingBarsAtStart = allowsResizingBarsAtStart == 1
        }
    }
    @objc dynamic var allowsMovingBarsVertically = NSNumber() {
        didSet {
            guard !isInitializingSettingsInternally else { return }
            contentSettings.allowsMovingBarsVertically = allowsMovingBarsVertically == 1
        }
    }
    @objc dynamic var allowsResizingCompletionBars = NSNumber() {
        didSet {
            guard !isInitializingSettingsInternally else { return }
            contentSettings.allowsResizingCompletionBars = allowsResizingCompletionBars == 1
        }
    }
    @objc dynamic var preservesCompletedDurationUponResizingBars = NSNumber() {
        didSet {
            guard !isInitializingSettingsInternally else { return }
            contentSettings.preservesCompletedDurationUponResizingBars = preservesCompletedDurationUponResizingBars == 1
        }
    }
    @objc dynamic var allowsCreatingBars = NSNumber() {
        didSet {
            guard !isInitializingSettingsInternally else { return }
            contentSettings.allowsCreatingBars = allowsCreatingBars == 1
        }
    }
    @objc dynamic var allowsCreatingMilestones = NSNumber() {
        didSet {
            guard !isInitializingSettingsInternally else { return }
            contentSettings.allowsCreatingMilestones = allowsCreatingMilestones == 1
        }
    }
    @objc dynamic var allowsDeletingBars = NSNumber() {
        didSet {
            guard !isInitializingSettingsInternally else { return }
            contentSettings.allowsDeletingBars = allowsDeletingBars == 1
        }
    }
    @objc dynamic var allowsCreatingDependencyLines = NSNumber() {
        didSet {
            guard !isInitializingSettingsInternally else { return }
            contentSettings.allowsCreatingDependencyLines = allowsCreatingDependencyLines == 1
        }
    }
    @objc dynamic var allowsCreatingDependencyLinesFromStart = NSNumber() {
        didSet {
            guard !isInitializingSettingsInternally else { return }
            contentSettings.allowsCreatingDependencyLinesFromStart = allowsCreatingDependencyLinesFromStart == 1
        }
    }
    @objc dynamic var allowsCreatingDependencyLinesToFinish = NSNumber() {
        didSet {
            guard !isInitializingSettingsInternally else { return }
            contentSettings.allowsCreatingDependencyLinesToFinish = allowsCreatingDependencyLinesToFinish == 1
        }
    }
    @objc dynamic var allowsDeletingDependencyLines = NSNumber() {
        didSet {
            guard !isInitializingSettingsInternally else { return }
            contentSettings.allowsDeletingDependencyLines = allowsDeletingDependencyLines == 1
        }
    }
    @objc dynamic var isReadOnly = NSNumber() {
        didSet {
            guard !isInitializingSettingsInternally else { return }
            contentSettings.isReadOnly = isReadOnly == 1
            let wasInitializingInternally = isInitializingSettingsInternally
            isInitializingSettingsInternally = true
            initializeSettings()
            isInitializingSettingsInternally = wasInitializingInternally
        }
    }
    @objc dynamic var allowsSelectingElements = NSNumber() {
        didSet {
            guard !isInitializingSettingsInternally else { return }
            contentSettings.allowsSelectingElements = allowsSelectingElements == 1
        }
    }
    @objc dynamic var allowsZooming = NSNumber() {
        didSet {
            guard !isInitializingSettingsInternally else { return }
            headerSettings.allowsZooming = allowsZooming == 1
        }
    }
    @objc dynamic var itemSourceBehaviorsEnabled = NSNumber()
    @objc dynamic var columnBehavior = NSNumber() {
        didSet {
            guard !isInitializingSettingsInternally else { return }
            itemSource?.isColumn = columnBehavior == 1
            itemSource?.applyBehavior()
        }
    }
    @objc dynamic var hierarchicalBehavior = NSNumber() {
        didSet {
            guard !isInitializingSettingsInternally else { return }
            itemSource?.hierarchicalRelations =
                hierarchicalBehavior == 1 ? defaultHierarchicalRelations : nil
            itemSource?.applyBehavior()
        }
    }
    var defaultHierarchicalRelations: [GanttChartItemHierarchicalRelation]!
    @objc dynamic var autoSchedulingBehavior = NSNumber() {
        didSet {
            guard !isInitializingSettingsInternally else { return }
            if !outlineGanttChart.isHidden {
                outlineGanttChart.isAutoScheduling = autoSchedulingBehavior == 1
                outlineGanttChart.applyBehavior()
                outlineGanttChart.autoApplyBehavior = outlineGanttChart.isAutoScheduling
            } else {
                itemSource?.isAutoScheduling = autoSchedulingBehavior == 1
                itemSource?.applyBehavior()
            }
        }
    }
    @objc dynamic var isAutoSchedulingBehaviorEnabled = NSNumber()
    var isInitializingSettingsInternally = false
    var contentSettings: GanttChartContentSettings {
        get { return contentController.settings }
        set { contentController.settings = newValue }
    }
    var headerSettings: GanttChartHeaderSettings {
        get { return headerController.settings }
        set { headerController.settings = newValue }
    }
    
    func initializeStyle() {
        isInitializingStyleInternally = true
        isBackgroundEnabled = contentStyle.backgroundColor != nil ? 1 : 0
        background = NSColor(contentStyle.backgroundColor)
        barFill = NSColor(contentStyle.barFillColor)
        isSecondaryBarFillEnabled = contentStyle.secondaryBarFillColor != nil ? 1 : 0
        secondaryBarFill = NSColor(contentStyle.secondaryBarFillColor)
        isBarStrokeEnabled = contentStyle.barStrokeColor != nil ? 1 : 0
        barStroke = NSColor(contentStyle.barStrokeColor)
        labelForeground = NSColor(contentStyle.labelForegroundColor)
        milestoneBarFill = NSColor(contentStyle.barFillColorForType[.milestone])
        isSecondaryMilestoneBarFillEnabled = contentStyle.secondaryBarFillColorForType[.milestone] != nil ? 1 : 0
        secondaryMilestoneBarFill = NSColor(contentStyle.secondaryBarFillColorForType[.milestone])
        isMilestoneBarStrokeEnabled = contentStyle.barStrokeColorForType[.milestone] != nil ? 1 : 0
        milestoneBarStroke = NSColor(contentStyle.barStrokeColorForType[.milestone])
        isMilestoneLabelForegroundEnabled = contentStyle.labelForegroundColorForType[.milestone] != nil ? 1 : 0
        milestoneLabelForeground = NSColor(contentStyle.labelForegroundColorForType[.milestone])
        summaryBarFill = NSColor(contentStyle.barFillColorForType[.summary])
        isSecondarySummaryBarFillEnabled = contentStyle.secondaryBarFillColorForType[.summary] != nil ? 1 : 0
        secondarySummaryBarFill = NSColor(contentStyle.secondaryBarFillColorForType[.summary])
        isSummaryBarStrokeEnabled = contentStyle.barStrokeColorForType[.summary] != nil ? 1 : 0
        summaryBarStroke = NSColor(contentStyle.barStrokeColorForType[.summary])
        isSummaryLabelForegroundEnabled = contentStyle.labelForegroundColorForType[.summary] != nil ? 1 : 0
        summaryLabelForeground = NSColor(contentStyle.labelForegroundColorForType[.summary])
        barStrokeWidth = contentStyle.barStrokeWidth as NSNumber?
        completionBarFill = NSColor(contentStyle.completionBarFillColor)
        isSecondaryCompletionBarFillEnabled = contentStyle.secondaryCompletionBarFillColor != nil ? 1 : 0
        secondaryCompletionBarFill = NSColor(contentStyle.secondaryCompletionBarFillColor)
        isCompletionBarStrokeEnabled = contentStyle.completionBarStrokeColor != nil ? 1 : 0
        completionBarStroke = NSColor(contentStyle.completionBarStrokeColor)
        completionBarStrokeWidth = contentStyle.completionBarStrokeWidth as NSNumber?
        cornerRadius = contentStyle.cornerRadius as NSNumber?
        completionCornerRadius = contentStyle.completionCornerRadius as NSNumber?
        barInset = contentStyle.verticalBarInset as NSNumber?
        completionBarInset = contentStyle.verticalCompletionBarInset as NSNumber?
        isFocusBorderEnabled = contentStyle.focusColor != nil ? 1 : 0
        focusBorder = NSColor(contentStyle.focusColor)
        focusBorderWidth = contentStyle.focusWidth as NSNumber?
        isSelectionBorderEnabled = contentStyle.selectionColor != nil ? 1 : 0
        selectionBorder = NSColor(contentStyle.selectionColor)
        selectionBorderWidth = contentStyle.selectionWidth as NSNumber?
        switch contentStyle.labelAlignment {
        case .left: labelAlignment = 0
        case .center: labelAlignment = 1
        case .right: labelAlignment = 2
        case .none: labelAlignment = nil
        @unknown default: fatalError()
        }
        labelInset = contentStyle.horizontalLabelInset as NSNumber?
        attachmentForeground = NSColor(contentStyle.attachmentForegroundColor)
        attachmentInset = contentStyle.horizontalAttachmentInset as NSNumber?
        isDependencyLineStrokeEnabled = contentStyle.dependencyLineColor != nil ? 1 : 0
        dependencyLineStroke = NSColor(contentStyle.dependencyLineColor)
        dependencyLineWidth = contentStyle.dependencyLineWidth as NSNumber?
        dependencyLineFocusWidth = contentStyle.dependencyLineFocusWidth as NSNumber?
        dependencyLineSelectionWidth = contentStyle.dependencyLineSelectionWidth as NSNumber?
        isAlternativeRowsBackgroundEnabled = contentStyle.alternativeRowStyle?.backgroundColor != nil ? 1 : 0
        alternativeRowsBackground = NSColor(contentStyle.alternativeRowStyle?.backgroundColor)
        scheduleHighlight = NSColor(contentStyle.highlightingTimeoutFillColor)
        isHeaderBackgroundEnabled = headerStyle.backgroundColor != nil ? 1 : 0
        headerBackground = NSColor(headerStyle.backgroundColor)
        headerLabelForeground = NSColor(headerStyle.labelForegroundColor)
        isInitializingStyleInternally = false
    }
    @objc dynamic var background: NSColor? { didSet { updateStyle() } }
    @objc dynamic var isBackgroundEnabled = NSNumber() { didSet { updateStyle() } }
    @objc dynamic var barFill: NSColor? { didSet { updateStyle() } }
    @objc dynamic var isSecondaryBarFillEnabled = NSNumber() { didSet { updateStyle() } }
    @objc dynamic var secondaryBarFill: NSColor? { didSet { updateStyle() } }
    @objc dynamic var isBarStrokeEnabled = NSNumber() { didSet { updateStyle() } }
    @objc dynamic var barStroke: NSColor? { didSet { updateStyle() } }
    @objc dynamic var labelForeground: NSColor? { didSet { updateStyle() } }
    @objc dynamic var milestoneBarFill: NSColor? { didSet { updateStyle() } }
    @objc dynamic var isSecondaryMilestoneBarFillEnabled = NSNumber() { didSet { updateStyle() } }
    @objc dynamic var secondaryMilestoneBarFill: NSColor? { didSet { updateStyle() } }
    @objc dynamic var isMilestoneBarStrokeEnabled = NSNumber() { didSet { updateStyle() } }
    @objc dynamic var milestoneBarStroke: NSColor? { didSet { updateStyle() } }
    @objc dynamic var isMilestoneLabelForegroundEnabled = NSNumber() { didSet { updateStyle() } }
    @objc dynamic var milestoneLabelForeground: NSColor? { didSet { updateStyle() } }
    @objc dynamic var summaryBarFill: NSColor? { didSet { updateStyle() } }
    @objc dynamic var isSecondarySummaryBarFillEnabled = NSNumber() { didSet { updateStyle() } }
    @objc dynamic var secondarySummaryBarFill: NSColor? { didSet { updateStyle() } }
    @objc dynamic var isSummaryBarStrokeEnabled = NSNumber() { didSet { updateStyle() } }
    @objc dynamic var summaryBarStroke: NSColor? { didSet { updateStyle() } }
    @objc dynamic var isSummaryLabelForegroundEnabled = NSNumber() { didSet { updateStyle() } }
    @objc dynamic var summaryLabelForeground: NSColor? { didSet { updateStyle() } }
    @objc dynamic var barStrokeWidth: NSNumber? { didSet { updateStyle() } }
    @objc dynamic var completionBarFill: NSColor? { didSet { updateStyle() } }
    @objc dynamic var isSecondaryCompletionBarFillEnabled = NSNumber() { didSet { updateStyle() } }
    @objc dynamic var secondaryCompletionBarFill: NSColor? { didSet { updateStyle() } }
    @objc dynamic var isCompletionBarStrokeEnabled = NSNumber() { didSet { updateStyle() } }
    @objc dynamic var completionBarStroke: NSColor? { didSet { updateStyle() } }
    @objc dynamic var completionBarStrokeWidth: NSNumber? { didSet { updateStyle() } }
    @objc dynamic var cornerRadius: NSNumber? { didSet { updateStyle() } }
    @objc dynamic var completionCornerRadius: NSNumber? { didSet { updateStyle() } }
    @objc dynamic var barInset: NSNumber? { didSet { updateStyle() } }
    @objc dynamic var completionBarInset: NSNumber? { didSet { updateStyle() } }
    @objc dynamic var isFocusBorderEnabled = NSNumber() { didSet { updateStyle() } }
    @objc dynamic var focusBorder: NSColor? { didSet { updateStyle() } }
    @objc dynamic var focusBorderWidth: NSNumber? { didSet { updateStyle() } }
    @objc dynamic var isSelectionBorderEnabled = NSNumber() { didSet { updateStyle() } }
    @objc dynamic var selectionBorder: NSColor? { didSet { updateStyle() } }
    @objc dynamic var selectionBorderWidth: NSNumber? { didSet { updateStyle() } }
    @objc dynamic var labelAlignment: NSNumber? { didSet { updateStyle() } }
    @objc dynamic var labelInset: NSNumber? { didSet { updateStyle() } }
    @objc dynamic var attachmentForeground: NSColor? { didSet { updateStyle() } }
    @objc dynamic var attachmentInset: NSNumber? { didSet { updateStyle() } }
    @objc dynamic var isDependencyLineStrokeEnabled = NSNumber() { didSet { updateStyle() } }
    @objc dynamic var dependencyLineStroke: NSColor? { didSet { updateStyle() } }
    @objc dynamic var dependencyLineWidth: NSNumber? { didSet { updateStyle() } }
    @objc dynamic var dependencyLineFocusWidth: NSNumber? { didSet { updateStyle() } }
    @objc dynamic var dependencyLineSelectionWidth: NSNumber? { didSet { updateStyle() } }
    @objc dynamic var isAlternativeRowsBackgroundEnabled: NSNumber? { didSet { updateStyle() } }
    @objc dynamic var alternativeRowsBackground: NSColor? { didSet { updateStyle() } }
    @objc dynamic var scheduleHighlight: NSColor? { didSet { updateStyle() } }
    @objc dynamic var isHeaderBackgroundEnabled: NSNumber? { didSet { updateStyle() } }
    @objc dynamic var headerBackground: NSColor? { didSet { updateStyle() } }
    @objc dynamic var headerLabelForeground: NSColor? { didSet { updateStyle() } }
    func updateStyle() {
        guard !isInitializingStyleInternally else { return }
        contentStyle.backgroundColor = isBackgroundEnabled == 1 ? Color(background) : nil
        contentStyle.barFillColor = Color(barFill)
        contentStyle.secondaryBarFillColor = isSecondaryBarFillEnabled == 1 ? Color(secondaryBarFill) : nil
        contentStyle.barStrokeColor = isBarStrokeEnabled == 1 ? Color(barStroke) : nil
        contentStyle.labelForegroundColor = Color(labelForeground)
        contentStyle.barFillColorForType[.milestone] = Color(milestoneBarFill)
        contentStyle.secondaryBarFillColorForType[.milestone] = isSecondaryMilestoneBarFillEnabled == 1 ? Color(secondaryMilestoneBarFill) : nil
        contentStyle.barStrokeColorForType[.milestone] = isMilestoneBarStrokeEnabled == 1 ? Color(milestoneBarStroke) : nil
        contentStyle.labelForegroundColorForType[.milestone] = isMilestoneLabelForegroundEnabled == 1 ? Color(milestoneLabelForeground) : nil
        contentStyle.barFillColorForType[.summary] = Color(summaryBarFill)
        contentStyle.secondaryBarFillColorForType[.summary] = isSecondarySummaryBarFillEnabled == 1 ? Color(secondarySummaryBarFill) : nil
        contentStyle.barStrokeColorForType[.summary] = isSummaryBarStrokeEnabled == 1 ? Color(summaryBarStroke) : nil
        contentStyle.labelForegroundColorForType[.summary] = isSummaryLabelForegroundEnabled == 1 ? Color(summaryLabelForeground) : nil
        contentStyle.barStrokeWidth = barStrokeWidth as? Double
        contentStyle.completionBarFillColor = Color(completionBarFill)
        contentStyle.secondaryCompletionBarFillColor = isSecondaryCompletionBarFillEnabled == 1 ? Color(secondaryCompletionBarFill) : nil
        contentStyle.completionBarStrokeColor = isCompletionBarStrokeEnabled == 1 ? Color(completionBarStroke) : nil
        contentStyle.completionBarStrokeWidth = completionBarStrokeWidth as? Double
        contentStyle.cornerRadius = cornerRadius as? Double
        contentStyle.completionCornerRadius = completionCornerRadius as? Double
        contentStyle.verticalBarInset = barInset as? Double
        contentStyle.verticalCompletionBarInset = completionBarInset as? Double
        contentStyle.horizontalCompletionBarInset = contentStyle.verticalCompletionBarInset != nil ? min(1, contentStyle.verticalCompletionBarInset!) : nil
        contentStyle.focusColor = isFocusBorderEnabled == 1 ? Color(focusBorder) : nil
        contentStyle.focusWidth = focusBorderWidth as? Double
        contentStyle.selectionColor = isSelectionBorderEnabled == 1 ? Color(selectionBorder) : nil
        contentStyle.selectionWidth = selectionBorderWidth as? Double
        switch labelAlignment {
        case 0: contentStyle.labelAlignment = .left
        case 1: contentStyle.labelAlignment = .center
        case 2: contentStyle.labelAlignment = .right
        default: contentStyle.labelAlignment = .left
        }
        contentStyle.horizontalLabelInset = labelInset as? Double
        contentStyle.attachmentForegroundColor = Color(attachmentForeground)
        contentStyle.horizontalAttachmentInset = attachmentInset as? Double
        contentStyle.dependencyLineColor = isDependencyLineStrokeEnabled == 1 ? Color(dependencyLineStroke) : nil
        contentStyle.dependencyLineWidth = dependencyLineWidth as? Double
        contentStyle.dependencyLineFocusWidth = dependencyLineFocusWidth as? Double
        contentStyle.dependencyLineSelectionWidth = dependencyLineSelectionWidth as? Double
        contentStyle.alternativeRowStyle = isAlternativeRowsBackgroundEnabled == 1 && alternativeRowsBackground != nil ? GanttChartRowStyle(backgroundColor: Color(alternativeRowsBackground)) : nil
        contentStyle.highlightingTimeoutFillColor = Color(scheduleHighlight)
        contentStyle.highlightingTimeFillColor = contentStyle.highlightingTimeoutFillColor
        contentController.settingsDidChange()
        headerStyle.backgroundColor = isHeaderBackgroundEnabled == 1 ? Color(headerBackground) : nil
        headerStyle.labelForegroundColor = Color(headerLabelForeground)
        headerController.settingsDidChange()
    }
    var isInitializingStyleInternally = false
    var contentStyle: GanttChartContentStyle {
        get { return contentController.style }
        set { contentController.style = newValue }
    }
    var headerStyle: GanttChartHeaderStyle {
        get { return headerController.style }
        set { headerController.style = newValue }
    }
    
    @objc dynamic var mode: NSNumber = 0 {
        didSet {
            if #available(OSX 10.14, *) {
                switch mode {
                case 0:
                    outlineGanttChart.appearance = nil
                    ganttChart.appearance = nil
                case 1:
                    let appearance = NSAppearance(named: .aqua)
                    outlineGanttChart.appearance = appearance
                    ganttChart.appearance = appearance
                case 2:
                    let appearance = NSAppearance(named: .darkAqua)
                    outlineGanttChart.appearance = appearance
                    ganttChart.appearance = appearance
                default:
                    outlineGanttChart.appearance = nil
                    ganttChart.appearance = nil
                }
            } else {
                switch mode {
                case 0:
                    controller.mode = nil
                case 1:
                    controller.mode = .light
                case 2:
                    controller.mode = .dark
                default:
                    controller.mode = nil
                }
            }
        }
    }
    
    func styleDidChange(to value: GanttChartContentStyle,
                        from originalValue: GanttChartContentStyle) {
        initializeStyle()
    }
    func styleDidChange(to value: GanttChartHeaderStyle,
                        from originalValue: GanttChartHeaderStyle) {
        initializeStyle()
    }
    
    func initializeItem() {
        guard let item = selectedItem else { return }
        isInitializingItemInternally = true
        itemLabel = item.label
        itemStart = Date(item.start)
        itemFinish = Date(item.finish)
        itemDuration = itemManager.schedule(for: item)
            .duration(of: item.time, in: .hours) as NSNumber?
        itemCompletion = item.completion as NSNumber?
        itemAttachment = item.attachment
        itemDetails = item.details
        switch item.type {
        case .standard:
            itemType = 0
        case .milestone:
            itemType = 1
        case .summary:
            itemType = 2
        @unknown default:
            fatalError()
        }
        itemRow = item.row as NSNumber?
        initializeItemConstraints()
        itemScheduleInherits = item.schedule == nil ? 1 : 0
        initializeSelectedItemSchedule()
        initializeItemSettings()
        initializeItemStyle()
        isInitializingItemInternally = false
    }
    @objc dynamic var itemLabel: String? {
        didSet {
            guard itemLabel != oldValue else { return }
            guard !isInitializingItemInternally else { return }
            guard let item = selectedItem else { return }
            item.label = itemLabel
            contentController.collectionDidChange()
            if !outlineGanttChart.isHidden {
                let outlineItem = outlineView.item(atRow: item.row) as! OutlineGanttChartRow
                outlineItem.chartItems.first!.label = item.label
                outlineView.reloadItem(outlineItem)
            }
        }
    }
    @objc dynamic var itemStart = Date() {
        didSet {
            guard itemStart != oldValue else { return }
            guard !isInitializingItemInternally else { return }
            guard let item = selectedItem else { return }
            itemManager.updateTime(for: item, toStartOn: Time(itemStart))
        }
    }
    @objc dynamic var itemFinish = Date() {
        didSet {
            guard itemFinish != oldValue else { return }
            guard !isInitializingItemInternally else { return }
            guard let item = selectedItem else { return }
            itemManager.updateDuration(for: item, toFinishOn: Time(itemFinish),
                                       preservingCompletedDuration: true)
        }
    }
    @objc dynamic var itemDuration: NSNumber?
    @objc dynamic var itemCompletion: NSNumber? {
        didSet {
            guard !isInitializingItemInternally else { return }
            guard itemCompletion != oldValue else { return }
            guard let item = selectedItem else { return }
            item.completion = itemCompletion as? Double ?? 0
            itemManager.collectionDidChange()
            if !outlineGanttChart.isHidden {
                let outlineItem = outlineView.item(atRow: item.row) as! OutlineGanttChartRow
                outlineItem.chartItems.first!.completion = item.completion
                outlineView.reloadItem(outlineItem)
            }
        }
    }
    @objc dynamic var itemAttachment: String? {
        didSet {
            guard itemAttachment != oldValue else { return }
            guard !isInitializingItemInternally else { return }
            guard let item = selectedItem else { return }
            item.attachment = itemAttachment
            contentController.collectionDidChange()
            if !outlineGanttChart.isHidden {
                let outlineItem = outlineView.item(atRow: item.row) as! OutlineGanttChartRow
                outlineItem.chartItems.first!.attachment = item.attachment
                outlineView.reloadItem(outlineItem)
            }
        }
    }
    @objc dynamic var itemDetails: String? {
        didSet {
            guard itemDetails != oldValue else { return }
            guard !isInitializingItemInternally else { return }
            guard let item = selectedItem else { return }
            item.details = itemDetails
            if !outlineGanttChart.isHidden {
                let outlineItem = outlineView.item(atRow: item.row) as! OutlineGanttChartRow
                outlineItem.chartItems.first!.details = item.details
                outlineView.reloadItem(outlineItem)
            }
        }
    }
    @objc dynamic var itemType: NSNumber? {
        didSet {
            guard itemType != oldValue else { return }
            guard !isInitializingItemInternally else { return }
            guard let item = selectedItem else { return }
            switch itemType {
            case 0:
                item.type = .standard
            case 1:
                item.type = .milestone
                item.finish = item.start
                timeDidChange(for: item)
                if !outlineGanttChart.isHidden {
                    let outlineItem = outlineView.item(atRow: item.row) as! OutlineGanttChartRow
                    outlineItem.chartItems.first!.finish = item.finish
                    outlineView.reloadItem(outlineItem)
                }
            case 2:
                item.type = .summary
            default:
                item.type = .standard
            }
            contentController.collectionDidChange()
        }
    }
    @objc dynamic var itemRow: NSNumber? {
        didSet {
            guard itemRow != oldValue else { return }
            guard !isInitializingItemInternally else { return }
            guard let item = selectedItem else { return }
            itemManager.updateRow(for: item, to: itemRow as? Int ?? 0)
        }
    }
    @objc dynamic var isItemRowEditingEnabled = true
    
    func initializeItemConstraints() {
        guard let item = selectedItem else { return }
        if let itemSource = itemSource {
            areItemConstraintsEnabled = 1
            let constraints = itemSource.constraints(of: item) ?? GanttChartItemConstraints()
            isItemMinStartEnabled = constraints.minStart != nil ? 1 : 0
            isItemMaxStartEnabled = constraints.maxStart != nil ? 1 : 0
            isItemMinFinishEnabled = constraints.minFinish != nil ? 1 : 0
            isItemMaxFinishEnabled = constraints.maxFinish != nil ? 1 : 0
            itemMinStart = Date(constraints.minStart ?? item.start)
            minItemMaxStart = Date(item.start)
            itemMaxStart = Date(constraints.maxStart ?? item.start)
            maxItemMinFinish = Date(item.finish)
            itemMinFinish = Date(constraints.minFinish ?? item.finish)
            itemMaxFinish = Date(constraints.maxFinish ?? item.finish)
        } else {
            areItemConstraintsEnabled = 0
        }
    }
    @objc dynamic var itemMinStart = Date() {
        didSet {
            guard itemMinStart != oldValue else { return }
            updateItemConstraints()
        }
    }
    @objc dynamic var isItemMinStartEnabled = NSNumber() {
        didSet {
            guard isItemMinStartEnabled != oldValue else { return }
            guard let item = selectedItem else { return }
            let wasInitialzingInternally = isInitializingItemInternally
            isInitializingItemInternally = true
            itemMinStart = Date(item.start)
            isInitializingItemInternally = wasInitialzingInternally
            updateItemConstraints()
        }
    }
    @objc dynamic var itemMaxStart = Date() {
        didSet {
            guard itemMaxStart != oldValue else { return }
            updateItemConstraints()
        }
    }
    @objc dynamic var isItemMaxStartEnabled = NSNumber() {
        didSet {
            guard isItemMaxStartEnabled != oldValue else { return }
            guard let item = selectedItem else { return }
            let wasInitialzingInternally = isInitializingItemInternally
            isInitializingItemInternally = true
            minItemMaxStart = Date(item.start)
            itemMaxStart = Date(item.start)
            isInitializingItemInternally = wasInitialzingInternally
            updateItemConstraints()
        }
    }
    @objc dynamic var minItemMaxStart = Date()
    @objc dynamic var itemMinFinish = Date() {
        didSet {
            guard itemMinFinish != oldValue else { return }
            updateItemConstraints()
        }
    }
    @objc dynamic var isItemMinFinishEnabled = NSNumber() {
        didSet {
            guard isItemMinFinishEnabled != oldValue else { return }
            guard let item = selectedItem else { return }
            let wasInitialzingInternally = isInitializingItemInternally
            isInitializingItemInternally = true
            maxItemMinFinish = Date(item.finish)
            itemMinFinish = Date(item.finish)
            isInitializingItemInternally = wasInitialzingInternally
            updateItemConstraints()
        }
    }
    @objc dynamic var maxItemMinFinish = Date()
    @objc dynamic var itemMaxFinish = Date() {
        didSet {
            guard itemMaxFinish != oldValue else { return }
            updateItemConstraints()
        }
    }
    @objc dynamic var isItemMaxFinishEnabled = NSNumber() {
        didSet {
            guard isItemMaxFinishEnabled != oldValue else { return }
            guard let item = selectedItem else { return }
            let wasInitialzingInternally = isInitializingItemInternally
            isInitializingItemInternally = true
            itemMaxFinish = Date(item.finish)
            isInitializingItemInternally = wasInitialzingInternally
            updateItemConstraints()
        }
    }
    func updateItemConstraints() {
        guard !isInitializingItemInternally else { return }
        guard let itemSource = itemSource else { return }
        guard let item = selectedItem else { return }
        itemSource.setConstraints(for: item, to: GanttChartItemConstraints(
            minStart: isItemMinStartEnabled == 1 ? Time(itemMinStart) : nil,
            maxStart: isItemMaxStartEnabled == 1 ? Time(itemMaxStart) : nil,
            minFinish: isItemMinFinishEnabled == 1 ? Time(itemMinFinish) : nil,
            maxFinish: isItemMaxFinishEnabled == 1 ? Time(itemMaxFinish) : nil))
        itemSource.applyBehavior(for: item)
    }
    @objc dynamic var areItemConstraintsEnabled = NSNumber()
    
    @objc dynamic var itemScheduleInherits = NSNumber() {
        didSet {
            guard itemScheduleInherits != oldValue else { return }
            guard let item = selectedItem else { return }
            if itemScheduleInherits == 1 {
                item.schedule = nil
                itemManager.applySchedule(for: item)
            }
            initializeSelectedItemSchedule()
        }
    }
    
    func initializeItemSettings() {
        guard let item = selectedItem else { return }
        let settings = item.settings
        allowsMovingItemBar = settings.allowsMovingBar ? 1 : 0
        allowsResizingItemBar = settings.allowsResizingBar ? 1 : 0
        allowsResizingItemBarAtStart = settings.allowsResizingBarAtStart ? 1 : 0
        allowsMovingItemBarVertically = settings.allowsMovingBarVertically ? 1 : 0
        allowsResizingItemCompletionBar = settings.allowsResizingCompletionBar ? 1 : 0
        allowsDeletingItemBar = settings.allowsDeletingBar ? 1 : 0
        allowsCreatingDependencyLinesToItem = settings.allowsCreatingDependencyLinesTo ? 1 : 0
        allowsCreatingDependencyLinesFromItem = settings.allowsCreatingDependencyLinesFrom ? 1 : 0
        allowsDeletingDependencyLinesToItem = settings.allowsDeletingDependencyLinesTo ? 1 : 0
        allowsDeletingDependencyLinesFromItem = settings.allowsDeletingDependencyLinesFrom ? 1 : 0
        itemIsReadOnly = settings.isReadOnly ? 1 : 0
    }
    @objc dynamic var allowsMovingItemBar = NSNumber() {
        didSet {
            guard !isInitializingItemInternally else { return }
            guard let item = selectedItem else { return }
            item.settings.allowsMovingBar = allowsMovingItemBar == 1
        }
    }
    @objc dynamic var allowsResizingItemBarAtStart = NSNumber() {
        didSet {
            guard !isInitializingItemInternally else { return }
            guard let item = selectedItem else { return }
            item.settings.allowsResizingBarAtStart = allowsResizingItemBarAtStart == 1
        }
    }
    @objc dynamic var allowsResizingItemBar = NSNumber() {
        didSet {
            guard !isInitializingItemInternally else { return }
            guard let item = selectedItem else { return }
            item.settings.allowsResizingBar = allowsResizingItemBar == 1
        }
    }
    @objc dynamic var allowsMovingItemBarVertically = NSNumber() {
        didSet {
            guard !isInitializingItemInternally else { return }
            guard let item = selectedItem else { return }
            item.settings.allowsMovingBarVertically = allowsMovingItemBarVertically == 1
        }
    }
    @objc dynamic var allowsResizingItemCompletionBar = NSNumber() {
        didSet {
            guard !isInitializingItemInternally else { return }
            guard let item = selectedItem else { return }
            item.settings.allowsResizingCompletionBar = allowsResizingItemCompletionBar == 1
        }
    }
    @objc dynamic var allowsDeletingItemBar = NSNumber() {
        didSet {
            guard !isInitializingItemInternally else { return }
            guard let item = selectedItem else { return }
            item.settings.allowsDeletingBar = allowsDeletingItemBar == 1
        }
    }
    @objc dynamic var allowsCreatingDependencyLinesToItem = NSNumber() {
        didSet {
            guard !isInitializingItemInternally else { return }
            guard let item = selectedItem else { return }
            item.settings.allowsCreatingDependencyLinesTo = allowsCreatingDependencyLinesToItem == 1
        }
    }
    @objc dynamic var allowsCreatingDependencyLinesFromItem = NSNumber() {
        didSet {
            guard !isInitializingItemInternally else { return }
            guard let item = selectedItem else { return }
            item.settings.allowsCreatingDependencyLinesFrom = allowsCreatingDependencyLinesFromItem == 1
        }
    }
    @objc dynamic var allowsDeletingDependencyLinesToItem = NSNumber() {
        didSet {
            guard !isInitializingItemInternally else { return }
            guard let item = selectedItem else { return }
            item.settings.allowsDeletingDependencyLinesTo = allowsDeletingDependencyLinesToItem == 1
        }
    }
    @objc dynamic var allowsDeletingDependencyLinesFromItem = NSNumber() {
        didSet {
            guard !isInitializingItemInternally else { return }
            guard let item = selectedItem else { return }
            item.settings.allowsDeletingDependencyLinesFrom = allowsDeletingDependencyLinesFromItem == 1
        }
    }
    @objc dynamic var itemIsReadOnly = NSNumber() {
        didSet {
            guard !isInitializingItemInternally else { return }
            guard let item = selectedItem else { return }
            item.settings.isReadOnly = itemIsReadOnly == 1
            let wasInitializingInternally = isInitializingItemInternally
            isInitializingItemInternally = true
            initializeItemSettings()
            isInitializingItemInternally = wasInitializingInternally
            if let outlineChartItem = item.context as? OutlineGanttChartItem {
                outlineChartItem.settings.isReadOnly = item.settings.isReadOnly
            }
        }
    }
    
    func initializeItemStyle() {
        guard let item = selectedItem else { return }
        let style = item.style
        isItemBarFillEnabled = style.barFillColor != nil ? 1 : 0
        itemBarFill = NSColor(style.barFillColor)
        isItemSecondaryBarFillEnabled = style.secondaryBarFillColor != nil ? 1 : 0
        itemSecondaryBarFill = NSColor(style.secondaryBarFillColor)
        isItemBarStrokeEnabled = style.barStrokeColor != nil ? 1 : 0
        itemBarStroke = NSColor(style.barStrokeColor)
        isItemLabelForegroundEnabled = style.labelForegroundColor != nil ? 1 : 0
        itemLabelForeground = NSColor(style.labelForegroundColor)
        isItemCompletionBarFillEnabled = style.completionBarFillColor != nil ? 1 : 0
        itemCompletionBarFill = NSColor(style.completionBarFillColor)
        isItemSecondaryCompletionBarFillEnabled = style.secondaryCompletionBarFillColor != nil ? 1 : 0
        itemSecondaryCompletionBarFill = NSColor(style.secondaryCompletionBarFillColor)
        isItemCompletionBarStrokeEnabled = style.completionBarStrokeColor != nil ? 1 : 0
        itemCompletionBarStroke = NSColor(style.completionBarStrokeColor)
        isItemAttachmentForegroundEnabled = style.attachmentForegroundColor != nil ? 1 : 0
        itemAttachmentForeground = NSColor(style.attachmentForegroundColor)
    }
    @objc dynamic var isItemBarFillEnabled = NSNumber() { didSet { updateItemStyle() } }
    @objc dynamic var itemBarFill: NSColor? { didSet { updateItemStyle() } }
    @objc dynamic var isItemSecondaryBarFillEnabled = NSNumber() { didSet { updateItemStyle() } }
    @objc dynamic var itemSecondaryBarFill: NSColor? { didSet { updateItemStyle() } }
    @objc dynamic var isItemBarStrokeEnabled = NSNumber() { didSet { updateItemStyle() } }
    @objc dynamic var itemBarStroke: NSColor? { didSet { updateItemStyle() } }
    @objc dynamic var isItemLabelForegroundEnabled = NSNumber() { didSet { updateItemStyle() } }
    @objc dynamic var itemLabelForeground: NSColor? { didSet { updateItemStyle() } }
    @objc dynamic var isItemCompletionBarFillEnabled = NSNumber() { didSet { updateItemStyle() } }
    @objc dynamic var itemCompletionBarFill: NSColor? { didSet { updateItemStyle() } }
    @objc dynamic var isItemSecondaryCompletionBarFillEnabled = NSNumber() { didSet { updateItemStyle() } }
    @objc dynamic var itemSecondaryCompletionBarFill: NSColor? { didSet { updateItemStyle() } }
    @objc dynamic var isItemCompletionBarStrokeEnabled = NSNumber() { didSet { updateItemStyle() } }
    @objc dynamic var itemCompletionBarStroke: NSColor? { didSet { updateItemStyle() } }
    @objc dynamic var isItemAttachmentForegroundEnabled = NSNumber() { didSet { updateItemStyle() } }
    @objc dynamic var itemAttachmentForeground: NSColor? { didSet { updateItemStyle() } }
    func updateItemStyle() {
        guard !isInitializingItemInternally else { return }
        guard let item = selectedItem else { return }
        var style = item.style
        style.barFillColor = isItemBarFillEnabled == 1 ? Color(itemBarFill) : nil
        style.secondaryBarFillColor = isItemSecondaryBarFillEnabled == 1 ? Color(itemSecondaryBarFill) : nil
        style.barStrokeColor = isItemBarStrokeEnabled == 1 ? Color(itemBarStroke) : nil
        style.labelForegroundColor = isItemLabelForegroundEnabled == 1 ? Color(itemLabelForeground) : nil
        style.completionBarFillColor = isItemCompletionBarFillEnabled == 1 ? Color(itemCompletionBarFill) : nil
        style.secondaryCompletionBarFillColor =
            isItemSecondaryCompletionBarFillEnabled == 1 ? Color(itemSecondaryCompletionBarFill) : nil
        style.completionBarStrokeColor = isItemCompletionBarStrokeEnabled == 1 ? Color(itemCompletionBarStroke) : nil
        style.attachmentForegroundColor = isItemAttachmentForegroundEnabled == 1 ? Color(itemAttachmentForeground) : nil
        item.style = style
        contentController.settingsDidChange()
    }
    
    var isInitializingItemInternally = false
    var selectedItem: GanttChartItem? { return contentController?.selectedItem }
    
    func timeDidChange(for item: GanttChartItem, from originalValue: TimeRange) {
        timeDidChange(for: item)
    }
    func timeDidChange(for item: GanttChartItem) {
        guard item === selectedItem else { return }
        isInitializingItemInternally = true
        itemStart = Date(item.start)
        itemFinish = Date(item.finish)
        itemDuration = itemManager.schedule(for: item)
            .duration(of: item.time, in: .hours) as NSNumber?
        if isItemMinStartEnabled == 0 {
            itemMinStart = Date(item.start)
        }
        if isItemMaxStartEnabled == 0 {
            minItemMaxStart = Date(item.start)
            itemMaxStart = Date(item.start)
        }
        if isItemMinFinishEnabled == 0 {
            maxItemMinFinish = Date(item.finish)
            itemMinFinish = Date(item.finish)
        }
        if isItemMaxFinishEnabled == 0 {
            itemMaxFinish = Date(item.finish)
        }
        isInitializingItemInternally = false
    }
    func completionDidChange(for item: GanttChartItem, from originalValue: Double) {
        guard item === selectedItem else { return }
        isInitializingItemInternally = true
        itemCompletion = item.completion as NSNumber?
        isInitializingItemInternally = false
    }
    func rowDidChange(for item: GanttChartItem, from originalValue: Row) {
        guard item === selectedItem else { return }
        isInitializingItemInternally = true
        itemRow = item.row as NSNumber?
        isInitializingItemInternally = false
    }
    
    @IBSegueAction func visibilityScheduleViewController(coder: NSCoder) -> ScheduleViewController? {
        visibilityScheduleViewController = ScheduleViewController(coder: coder)
        visibilityScheduleViewController.observer = self
        return visibilityScheduleViewController
    }
    @IBSegueAction func highlightingScheduleViewController(coder: NSCoder) -> ScheduleViewController? {
        highlightingScheduleViewController = ScheduleViewController(coder: coder)
        highlightingScheduleViewController.observer = self
        return highlightingScheduleViewController
    }
    @IBSegueAction func itemsScheduleViewController(coder: NSCoder) -> ScheduleViewController? {
        itemsScheduleViewController = ScheduleViewController(coder: coder)
        itemsScheduleViewController.observer = self
        return itemsScheduleViewController
    }
    @IBSegueAction func selectedItemScheduleViewController(coder: NSCoder) -> ScheduleViewController? {
        selectedItemScheduleViewController = ScheduleViewController(coder: coder)
        selectedItemScheduleViewController.observer = self
        return selectedItemScheduleViewController
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        guard #available(macOS 10.15, *) else {
            switch segue.identifier {
            case "visibilityScheduleSegue":
                visibilityScheduleViewController =
                    segue.destinationController as? ScheduleViewController
                visibilityScheduleViewController.observer = self
            case "highlightingScheduleSegue":
                highlightingScheduleViewController =
                    segue.destinationController as? ScheduleViewController
                highlightingScheduleViewController.observer = self
            case "itemsScheduleSegue":
                itemsScheduleViewController =
                    segue.destinationController as? ScheduleViewController
                itemsScheduleViewController.observer = self
            case "selectedItemScheduleSegue":
                selectedItemScheduleViewController =
                    segue.destinationController as? ScheduleViewController
                selectedItemScheduleViewController.observer = self
            default: break
            }
            return
        }
    }
    
    var visibilityScheduleViewController: ScheduleViewController! {
        didSet { initializeVisibilitySchedule() }
    }
    func initializeVisibilitySchedule() {
        guard visibilityScheduleViewController != nil, contentController != nil else { return }
        visibilityScheduleViewController.schedule = contentController.visibilitySchedule
        visibilityScheduleViewController.isExcludedIntervalsEditingEnabled =
            isVisibilityScheduleExcludedIntervalsEditingEnabled
    }
    var isVisibilityScheduleExcludedIntervalsEditingEnabled = true
    
    var highlightingScheduleViewController: ScheduleViewController! {
        didSet { initializeHighlightingSchedule() }
    }
    func initializeHighlightingSchedule() {
        guard highlightingScheduleViewController != nil else { return }
        highlightingScheduleViewController.schedule = highlighter?.schedule ?? .continuous
    }
    
    var itemsScheduleViewController: ScheduleViewController! {
        didSet { initializeItemsSchedule() }
    }
    func initializeItemsSchedule() {
        guard itemsScheduleViewController != nil, itemManager != nil else { return }
        itemsScheduleViewController.schedule = itemManager.schedule
    }
    
    var selectedItemScheduleViewController: ScheduleViewController! {
        didSet { initializeSelectedItemSchedule() }
    }
    func initializeSelectedItemSchedule() {
        guard selectedItemScheduleViewController != nil, itemManager != nil else { return }
        selectedItemScheduleViewController.schedule = selectedItem?.schedule
            ?? itemManager.schedule
        selectedItemScheduleViewController.isEnabled = itemScheduleInherits == 0
    }
    
    var highlighter: ScheduleTimeSelector? {
        guard contentController != nil else { return nil }
        return contentController.scheduleHighlighters.first
    }
    
    func scheduleDidChange(on scheduleViewController: ScheduleViewController) {
        guard let contentController = contentController else { return }
        switch scheduleViewController {
        case visibilityScheduleViewController:
            contentController.visibilitySchedule = visibilityScheduleViewController.schedule
        case highlightingScheduleViewController:
            updateHighlightingSchedule()
        case itemsScheduleViewController:
            itemManager.schedule = itemsScheduleViewController.schedule
            itemManager.applySchedule()
        case selectedItemScheduleViewController:
            guard let item = selectedItem else { return }
            item.schedule =
                itemScheduleInherits == 1 ? nil : selectedItemScheduleViewController.schedule
            itemManager.applySchedule(for: item)
            initializeItem()
        default: break
        }
    }
    
    func updateHighlightingSchedule() {
        guard let schedule = highlightingScheduleViewController?.schedule else { return }
        contentController.scheduleHighlighters = [highlightingType == 0
            ? ScheduleTimeSelector(timesOf: schedule)
            : ScheduleTimeSelector(timeoutsOf: schedule)
        ]
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}
