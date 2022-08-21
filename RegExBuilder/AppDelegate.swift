//
//  AppDelegate.swift
//  RegExBuilder
//
//  Created by Robert Dodson on 8/20/22.
//

import Cocoa



@main
class AppDelegate: NSObject, NSApplicationDelegate
{
    @IBOutlet var window: NSWindow!

    @IBOutlet weak var regexTextField: NSTextField!
    @IBOutlet var textField: NSTextView!
    
    func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        let text = "The first month of your subscription is free."
        var astr = AttributedString(text)
       
        if let range1 = astr.range(of: text)
        {
            astr[range1].foregroundColor = .black
            astr[range1].font = NSFont.systemFont(ofSize: 18)
            textField.textStorage?.setAttributedString(NSAttributedString(astr))
        }
        
        regexTextField.stringValue = "free"
    }
    
    
    func applicationWillTerminate(_ aNotification: Notification)
    {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool
    {
        return true
    }

    @IBAction func regexAction(_ sender: Any)
    {
        do
        {
            let regex = try Regex(regexTextField.stringValue)
            let text = textField.string
            
            var astr = AttributedString(text)
            if let range1 = astr.range(of: text)
            {
                astr[range1].foregroundColor = .black
                astr[range1].font = NSFont.systemFont(ofSize: 18)
                
                let matches = text.matches(of: regex)
                for match in matches
                {
                    let subtext = text[match.range] //text.substring(with: match.range)
                    if let range1 = astr.range(of: subtext)
                    {
                        astr[range1].foregroundColor = .green
                    }
                }
                textField.textStorage?.setAttributedString(NSAttributedString(astr))
            }
        }
        catch
        {
            Alert.showAlertInWindow(window: window, message: "Error in regexAction:", info: "\(error)")
            {
            }
        cancel:
            {
            }

        }
        
        
    }
    
}

