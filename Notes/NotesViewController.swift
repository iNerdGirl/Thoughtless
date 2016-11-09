//
//  NotesViewController.swift
//  Notes
//
//  Created by Yohannes Wijaya on 8/18/16.
//  Copyright © 2016 Yohannes Wijaya. All rights reserved.
//

import UIKit
import SafariServices

class NotesViewController: UIViewController {
  
  // MARK: - Stored Properties
  
  var note: Notes?
  
  let saveOrNotSaveAlertView: FCAlertView = {
    let alertView = FCAlertView(type: .caution)
    alertView.dismissOnOutsideTouch = true
    alertView.hideDoneButton = true
    return alertView
  }()
  
  let emptyNoteDeterrentAlertview: FCAlertView = {
    let alertView = FCAlertView(type: .warning)
    alertView.dismissOnOutsideTouch = true
    alertView.hideDoneButton = true
    return alertView
  }()
  
  enum MarkdownSymbols: String {
    case hash = "#", asterisk = "*", underscore = "_", greaterThan = ">", dash = "-", grave = "`", done = "⌨"
    static let items = [hash, asterisk, underscore, greaterThan, dash, grave, done]
  }
  
  // MARK: - IBOutlet Properties
  
  @IBOutlet weak var textView: UITextView! {
    didSet {
      if let validNote = self.note {
        self.textView.text = validNote.entry
      }
      else {
        self.textView.sizeToFit()
        self.textView.becomeFirstResponder()
      }
    }
  }
  
  @IBOutlet weak var saveButton: UIBarButtonItem!
  @IBOutlet weak var cancelButton: UIBarButtonItem!

  // MARK: - IBAction Methods
  
  @IBAction func cancelButtonDidTouch(sender: UIBarButtonItem) {
    self.textView.resignFirstResponder()
    
    // Check the type of an object #1. More: http://stackoverflow.com/a/25345480/2229062
//    print("a) I am of type: \(self.presentingViewController.self)")
    
    // Check the type of an object #2. More: http://stackoverflow.com/a/33001534/2229062
//    if let unknown: AnyObject = self.presentingViewController {
//      let reflection = Mirror(reflecting: unknown)
//      print("b) I am of type: \(reflection.subjectType)")
//    }
//    else {
//      print("c) I am of type: \(type(of:self.presentingViewController))")
//    }
    
    let isPresentingFromAddButton = self.presentingViewController is UINavigationController
    if isPresentingFromAddButton {
      self.dismiss(animated: true, completion: nil)
    }
    else {
//      print("d) I am of type: \(type(of: self.presentingViewController))")
      _ = self.navigationController?.popViewController(animated: true)
    }
  }
  
  @IBAction func markdownUserGuideButtonDidTouch(_ sender: UIButton) {
    guard let validURL = URL(string: "http://commonmark.org/help/") else { return }
    let safariViewController = SFSafariViewController(url: validURL)
    self.present(safariViewController, animated: true, completion: nil)
  }
  
  @IBAction func previewMarkdownButtonDidTouch(_ sender: UIButton) {
    guard self.note != nil else { return }
    self.performSegue(withIdentifier: "showSegueToMarkdownNotesViewController", sender: self)
  }
  
  @IBAction func swipeLeftFromRightScreenEdgeGestureToShowMarkdown(_ sender: UIScreenEdgePanGestureRecognizer) {
    guard self.note != nil else { return }
    if sender.state == .ended {
      self.performSegue(withIdentifier: "showSegueToMarkdownNotesViewController", sender: self)
    }
  }
  
  @IBAction func swipeRightFromLeftScreenEdgeGestureToCancelOrSave(_ sender: UIScreenEdgePanGestureRecognizer) {
    self.textView.endEditing(true)

    saveOrNotSaveAlertView.showAlert(inView: self,
                          withTitle: "Pardon the Interruption",
                          withSubtitle: "Do you want to save or not save?",
                          withCustomImage: nil,
                          withDoneButtonTitle: nil,
                          andButtons: ["Don't Save", "Save"])
  }
  
  @IBAction func swipeDownGestureToDismissKeyboard(_ sender: UISwipeGestureRecognizer) {
    self.textView.resignFirstResponder()
  }
  
  // MARK: - UIViewController Methods
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let validBarButtonItem = sender as? UIBarButtonItem, validBarButtonItem === self.saveButton {
      let entry = self.textView.text ?? ""
      self.note = Notes(entry: entry, dateOfCreation: CurrentDateAndTimeHelper.get())
    }
    else if segue.identifier == "showSegueToMarkdownNotesViewController" {
      guard let validMarkdownNotesViewController = segue.destination as? MarkdownNotesViewController, let validNote = self.note else { return }
      validMarkdownNotesViewController.note = validNote
    }
    else if segue.identifier == "unwindToNotesTableViewControllerFromNotesViewController" {
      let entry = self.textView.text ?? ""
      self.note = Notes(entry: entry, dateOfCreation: CurrentDateAndTimeHelper.get())
    }
  }
  
  override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
    guard !textView.text.isEmpty else {
      self.textView.endEditing(true)
      emptyNoteDeterrentAlertview.showAlert(inView: self,
                            withTitle: "Empty Note Detected",
                            withSubtitle: "You aren't allowed to save an empty note.",
                            withCustomImage: nil,
                            withDoneButtonTitle: nil,
                            andButtons: ["Understood"])
      return false
    }
    if identifier == "unwindToNotesTableViewControllerFromNotesViewController" {
      self.performSegue(withIdentifier: identifier, sender: self)
    }
    return true
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.setupKeyboardToolBarWithBarButtonItems()
    
    self.saveOrNotSaveAlertView.delegate = self
    self.emptyNoteDeterrentAlertview.delegate = self
    
    self.textView.textColor = UIColor(hexString: "#6F7B91")
  }
  
  // MARK: - Local Methods
  
  func barButtonItemOnToolBarDidTouch(sender: UIBarButtonItem) {
    guard let validButtonTitle = sender.title else { return }
    if sender.title == "⌨" {
      self.textView.endEditing(true)
    }
    else {
      self.textView.insertText(validButtonTitle)
    }
  }
  
  fileprivate func setupKeyboardToolBarWithBarButtonItems() {
    let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
    toolBar.isTranslucent = false
    toolBar.barTintColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
    toolBar.tintColor = UIColor.black
    
    var barButtonItems = [UIBarButtonItem]()
    for (index, value) in MarkdownSymbols.items.enumerated() {
      let barButtonItem = self.setupBarButtonItemOnKeyboardToolbarWith(title: value.rawValue)
      barButtonItems.append(barButtonItem)
      if index < MarkdownSymbols.items.count - 1 {
        barButtonItems.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
      }
    }
    
    toolBar.items = barButtonItems
    self.textView.inputAccessoryView = toolBar
  }
  
  fileprivate func setupBarButtonItemOnKeyboardToolbarWith(title: String) -> UIBarButtonItem {
    let barButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(NotesViewController.barButtonItemOnToolBarDidTouch(sender:)))
    return barButtonItem
  }
}

// MARK: - FCalertViewDelegate Definition

extension NotesViewController: FCAlertViewDelegate {
  
  func alertView(_ alertView: FCAlertView, clickedButtonIndex index: Int, buttonTitle title: String) {
    if title == "Save" {
      self.textView.endEditing(true)
      let _ = self.shouldPerformSegue(withIdentifier: "unwindToNotesTableViewControllerFromNotesViewController", sender: self)
    }
    else if title == "Don't Save" {
      self.cancelButtonDidTouch(sender: self.cancelButton)
    }
    else if title == "Understood" {
      self.textView.becomeFirstResponder()
    }
  }
}
