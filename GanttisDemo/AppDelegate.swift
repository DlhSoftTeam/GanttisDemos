//
//  AppDelegate.swift
//  GanttisDemo
//
//  Created by DlhSoft on 08/12/2018.
//

import Cocoa
import Ganttis

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    override init() {
        super.init()
        Ganttis.license = "..."
    }
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        return true
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
