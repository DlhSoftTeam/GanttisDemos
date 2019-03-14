//
//  EditViewController.swift
//  GanttisTouchDemo
//
//  Created by Sorin Dolha on 01/02/2019.
//

import UIKit
import GanttisTouch

class EditViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var labelTextField: UITextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var finishDatePicker: UIDatePicker!
    @IBOutlet weak var completionTextField: UITextField!
    @IBOutlet weak var attachmentTextField: UITextField!
    @IBOutlet weak var typePicker: UIPickerView!
    @IBOutlet weak var rowTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initializeTextFields()
        initializeDatePickers()
        initializePickers()
        initializeItem()
    }
    
    func initializeTextFields() {
        labelTextField.delegate = self
        completionTextField.delegate = self
        attachmentTextField.delegate = self
        rowTextField.delegate = self
    }
    func initializeDatePickers() {
        let calendar = Time.calendar
        let timeZone = calendar.timeZone
        for datePicker: UIDatePicker in [startDatePicker, finishDatePicker] {
            datePicker.calendar = calendar
            datePicker.timeZone = timeZone
        }
    }
    func initializePickers() {
        typePicker.dataSource = self
        typePicker.delegate = self
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int,
                    forComponent component: Int) -> String? {
        switch row {
        case 0: return "Standard"
        case 1: return "Milestone"
        case 2: return "Summary"
        default: return nil
        }
    }
    
    func initializeItem() {
        labelTextField.text = item.label
        startDatePicker.date = Date(item.start.asStart.dayStart)
        finishDatePicker.date = Date(item.finish.asFinish.dayStart)
        completionTextField.text = String(item.completion * 100)
        attachmentTextField.text = item.attachment
        switch item.type {
        case .standard:
            typePicker.selectRow(0, inComponent: 0, animated: false)
        case .milestone:
            typePicker.selectRow(1, inComponent: 0, animated: false)
        case .summary:
            typePicker.selectRow(2, inComponent: 0, animated: false)
        }
        rowTextField.text = String(item.row)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    var itemManager: GanttChartItemManager!
    var item: GanttChartItem!
    
    @IBAction func done(_ button: UIBarButtonItem) {
        updateItem()
        dismiss(animated: true)
    }
    @IBAction func cancel(_ button: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    func updateItem() {
        item.label = labelTextField.text
        itemManager.updateTime(for: item, toStartOn: Time(startDatePicker.date))
        itemManager.updateDuration(for: item, toFinishOn: Time(finishDatePicker.date),
                                   preservingCompletedDuration: true)
        item.completion = (Double(completionTextField.text!) ?? 0) / 100
        item.attachment = attachmentTextField.text
        switch typePicker.selectedRow(inComponent: 0) {
        case 0:
            item.type = .standard
        case 1:
            item.type = .milestone
            item.finish = item.start
        case 2:
            item.type = .summary
        default:
            item.type = .standard
        }
        itemManager.updateRow(for: item, to: Int(rowTextField.text!) ?? 0)
    }
}
