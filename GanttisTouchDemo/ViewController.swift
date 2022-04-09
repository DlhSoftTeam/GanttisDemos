//
//  ViewController.swift
//  GanttisTouchDemo
//
//  Created by DlhSoft on 08/12/2018.
//

import UIKit
import GanttisTouch

class ViewController: UIViewController, GanttChartItemObserver, GanttChartContentSelectionObserver {
    @IBOutlet weak var ganttChart: GanttChart!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var removeButton: UIBarButtonItem!
    
    var itemSource: GanttChartItemSource!
    var itemManager: GanttChartItemManager!
    var contentController: GanttChartContentController!
    var headerController: GanttChartHeaderController!
    var controller: GanttChartController!
    var zoom = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        initializeClassicDataSource()
    }
    
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
        headerController = GanttChartHeaderController()
        headerController.rows = classicHeaderRows
        initializeAutoShiftingScrollableTimeline()
        initializeGanttChart()
        contentController.scrollVisibleTimeline(toStartOn: classicProjectStart)
        initializeObservers()
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
        contentController.settings.showsCompletionBarsForSummaryItems = false
        contentController.settings.allowsSelectingElements = true
        contentController.settings.selectsNewlyCreatedElements = true
        contentController.settings.temporaryBarWidth = contentController.hourWidth * 24
        contentController.zoom = zoom
        headerController.settings.minZoom = 0.67
        headerController.settings.maxZoom = 8
        controller = GanttChartController(headerController: headerController,
                                          contentController: contentController)
        ganttChart.controller = controller
        contentController.scrollVertically(to: Row(0))
    }
    func initializeObservers() {
        itemManager?.itemObserver = self
        contentController.selectionObserver = self
    }
    
    @IBAction func resetDataSource(_ button: UIBarButtonItem) {
        contentController.selectedItem = nil
        classicDataSource = prepareClassicDataSource()
        initializeClassicDataSource()
    }
    
    @IBAction func addItem(_ button: UIBarButtonItem) {
        guard contentController.settings.allowsCreatingBars else { return }
        isAddingItemInternally = true
        let row = itemManager.totalRowCount
        let time = contentController.visibleTimeline.start
        let item = itemManager.addNewItem(on: row, at: time)
        contentController.selectedItem = item
        contentController.scrollVertically(to: row)
        isAddingItemInternally = false
    }
    func itemWasAdded(_ item: GanttChartItem) {
        if !item.isMilestone {
            item.label = "New item"
            item.finish = itemManager.schedule.finish(from: item.start, for: 24, in: .hours)
        }
        guard !isAddingItemInternally else { return }
        guard let parent = itemSource.items
            .filter({ item in item.type == .summary })
            .filter({ parent in parent.row <= item.row }).last else { return }
        itemSource.addHierarchicalRelation(parent: parent, item: item)
        itemSource.applyBehavior(for: item)
    }
    var isAddingItemInternally = false
    
    @IBAction func removeItem(_ button: UIBarButtonItem) {
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
    func itemWasRemoved(_ item: GanttChartItem) {
        itemSource.removeFromHierarchy(item: item)
        itemSource.applyBehavior()
    }
    
    @IBAction func setTheme(_ button: UIBarButtonItem) {
        switch button.title {
        case "Standard":
            controller.theme = .standard
        case "Aqua":
            controller.theme = .aqua
        case "Jewel":
            controller.theme = .jewel
        case "Dark":
            if #available(iOS 13.0, macCatalyst 13.0, *) {
                ganttChart.overrideUserInterfaceStyle =
                    ganttChart.overrideUserInterfaceStyle != .dark ? .dark : .light
            } else {
                controller.mode = controller.mode != .dark ? .dark : .light
            }
        default: break
        }
    }
    
    func selectionDidChange() {
        let selectedItem = contentController.selectedItem
        selectedItem?.hasChanged = true
        let isItemSelected = selectedItem != nil
        editButton.isEnabled = isItemSelected
        removeButton.isEnabled = isItemSelected
    }
    
    @IBAction func editItem(_ button: UIBarButtonItem) {
        let editViewController = EditViewController()
        editViewController.itemManager = itemManager
        editViewController.item = contentController.selectedItem
        present(editViewController, animated: true) { [unowned self] in
            self.itemManager.collectionDidChange()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        if super.prefersStatusBarHidden { return true }
        if #available(iOS 14.0, *) {
            return ProcessInfo.processInfo.isiOSAppOnMac
        }
        return false
    }
}
