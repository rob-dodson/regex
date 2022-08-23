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
    @IBOutlet weak var shellText: NSTextField!
    
    var boldfont : NSFont!
    var font : NSFont!
    var donestaring : Bool = false
    
    func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        donestaring = false
        
        let fontManager = NSFontManager.shared
        boldfont = fontManager.font(withFamily: "Helvetica Neue", traits: NSFontTraitMask.boldFontMask, weight: 0, size:18.0)
        font = NSFont(name: "Helvetica Neue", size: 18.0)
        
        let text = "The first month of your subscription is free. Freedom"
        var astr = AttributedString(text)
       
        if let range1 = astr.range(of: text)
        {
            astr[range1].foregroundColor = NSColor.systemBrown
            astr[range1].font = NSFont.systemFont(ofSize: 18)
            textField.textStorage?.setAttributedString(NSAttributedString(astr))
        }
        
        regexTextField.stringValue = "(F)ree(dom)"
        
        donestaring = true
    }
    
    
    func applicationWillTerminate(_ aNotification: Notification)
    {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool
    {
        return true
    }
    
    
    @IBAction func shellAction(_ sender: Any)
    {
        runShell()
    }
    
    func runShell()
    {
        let process = Process()
        process.launchPath = "/bin/sh"
        var args = Array<String>()
        args.append("-c")
        args.append(shellText.stringValue)
        process.arguments = args
        
        let readpipe = Pipe()
        let readerrpipe = Pipe()
        process.standardOutput = readpipe
        process.standardError = readerrpipe
        
        var newText = ""
        
        do
        {
            try process.run()
            
            var moredata = true
            
            repeat
            {
                let data : Data = readerrpipe.fileHandleForReading.availableData
                if data.count > 0
                {
                    let text = String(data: data, encoding:.utf8) ?? "err"
                    newText = newText.appending(text)
                }
                else
                {
                    moredata = false
                }
            } while (moredata)
             
            repeat
            {
                let data : Data = readpipe.fileHandleForReading.availableData
                if data.count > 0
                {
                    let text = String(data: data, encoding:.utf8) ?? "err"
                    newText = newText.appending(text)
                }
                else
                {
                    moredata = false
                }
            } while (moredata)
                                    
            textField.string = newText
        }
        catch
        {
            Alert.showAlertInWindow(window: window, message: "Error in shell command:", info: "\(error)")
            {
            }
            cancel:
            {
            }
        }
    }
    

    @IBAction func regexAction(_ sender: Any)
    {
        if donestaring == false
        {
            return
        }
        do
        {
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
                

                if (match.output.count > 1)
                {
                    print("CAPS \(match.output.count)")
                    var skipfirst = true
                    for output in match.output
                    {
                        if skipfirst
                        {
                            skipfirst = false
                            continue
                        }
                        
                        if let crange = output.range
                        {
                            let rangeStartIndex = crange.lowerBound
                            let rangeEndIndex = crange.upperBound
                            
                            let start = text.distance(from: text.startIndex, to: rangeStartIndex)
                            let length = text.distance(from: rangeStartIndex, to: rangeEndIndex)
                            
                            print("cap \(output.substring) \(start) \(length)")
                            
                            let cnsrange = NSMakeRange(start,length)
                            
                            astr.addAttributes([.foregroundColor:NSColor.blue,.font:boldfont!], range: cnsrange)
                        }
                    }
                }
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

