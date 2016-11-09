//
//  MarkdownNotesViewController.swift
//  Notes
//
//  Created by Yohannes Wijaya on 9/23/16.
//  Copyright © 2016 Yohannes Wijaya. All rights reserved.
//

import UIKit
import SafariServices

class MarkdownNotesViewController: UIViewController {
  
  // MARK: - Stored Properties
  
  var note: Notes?
  
  enum HTTP: String {
    case Secured = "https://", NonSecured = "http://"
  }
  
  // MARK: - IBOutlet Properties
  
  @IBOutlet weak var markdownNotesTextView: UITextView! {
    didSet {
      guard let validNote = self.note else { return }
      guard let validAvenirFont = UIFont(name: "AvenirNext-Regular", size: 20) else { return }
      let markdownParser = MarkdownParser(font: validAvenirFont, automaticLinkDetectionEnabled: true, customElements: [])
      self.markdownNotesTextView.attributedText = markdownParser.parse(validNote.entry)
    }
  }
  
  // MARK: - UIViewController Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.markdownNotesTextView.delegate = self
    self.markdownNotesTextView.textColor = UIColor(hexString: "#6F7B91")
    
    self.navigationItem.title = "Markdown"
  }
  
  // MARK: - Helper Methods
  
  func canOpenThisURL(_ URLString: String) -> Bool {
    let linkDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    guard let matches = linkDetector?.numberOfMatches(in: URLString, options: [], range: NSRange(location: 0, length: URLString.utf16.count)) else { return false }
    return matches > 0 ? true : false
  }
}

// MARK: - UITextFieldDelegate Definition

extension MarkdownNotesViewController: UITextViewDelegate {
  func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
    
    guard self.canOpenThisURL(URL.absoluteString.lowercased()) else {
      let alertController = UIAlertController(title: "Invalid URL Link", message: "Please double check your URL in the previous page", preferredStyle: .alert)
      let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
      alertController.addAction(alertAction)
      self.present(alertController, animated: true, completion: nil)
      return false
    }
    
    var copiedURL = URL
    if copiedURL.absoluteString.lowercased().hasPrefix(HTTP.Secured.rawValue) == false && copiedURL.absoluteString.lowercased().hasPrefix(HTTP.NonSecured.rawValue) == false {
      copiedURL = NSURL(string: HTTP.NonSecured.rawValue.appending(copiedURL.absoluteString)) as! URL
    }
    let safariViewController = SFSafariViewController(url: copiedURL)
    self.present(safariViewController, animated: true, completion: nil)
    return false
  }
}
