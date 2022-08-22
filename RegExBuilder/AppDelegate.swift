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
            astr[range1].foregroundColor = NSColor.systemBrown
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
            let font = NSFont(name: "Helvetica Neue", size: 18.0)
            let regex = try Regex(regexTextField.stringValue)
            let text = textField.string
            
            let astr = NSMutableAttributedString(string:text)
            let wholerange = NSRange(location: 0, length: astr.length)
            astr.addAttributes([.foregroundColor:NSColor.systemBrown,.font:font!], range: wholerange)
            
            
            let matches = text.matches(of: regex)
            for match in matches
            {
                let rangeStartIndex = match.range.lowerBound
                let rangeEndIndex = match.range.upperBound

                let start = text.distance(from: text.startIndex, to: rangeStartIndex)
                let length = text.distance(from: rangeStartIndex, to: rangeEndIndex)

                let nsrange = NSMakeRange(start,length)

                astr.addAttributes([.foregroundColor:NSColor.red,.font:font!], range: nsrange)
            }
            
            textField.textStorage?.setAttributedString(astr)
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

