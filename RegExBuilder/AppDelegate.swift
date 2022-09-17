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
    @IBOutlet weak var regexComboBox: NSComboBox!
    
    var boldfont : NSFont!
    var font : NSFont!
    var donestaring : Bool = false
    var fontName : String!
    var fontSize = 18.0
    var fontColor = NSColor.systemBrown
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        donestaring = false
        fontName = "Helvetica Neue"
        
        let fontManager = NSFontManager.shared
        boldfont = fontManager.font(withFamily: fontName, traits: NSFontTraitMask.boldFontMask, weight: 0, size:fontSize)
        font = NSFont(name: fontName, size: fontSize)
        
        let text = "The first month of your subscription is free.\nFreedom's just another word."
        var astr = AttributedString(text)
       
        if let range1 = astr.range(of: text)
        {
            astr[range1].foregroundColor = fontColor
            astr[range1].font = NSFont.systemFont(ofSize: fontSize)
            textField.textStorage?.setAttributedString(NSAttributedString(astr))
        }
        
        regexTextField.stringValue = "([Ff])ree(dom)*"
        
        
        let lines:[String] = ["All characters - .*",
                              "All digits - \\d*",
                              "First word (multiline) - (?m)^\\w+",
                              "All three letter words - \\b\\w{3}\\b",
                              "All upper case characters - [A-Z]+",
                              "Capture first word - (?m)^(\\w+)",
                              "Upper case characters - [:upper:]*",
                              "Capitalized words - [A-Z]\\w+",
                              "Lines ending with word ending with e - (?m)\\w+e$",
        ]
        
        for line in lines
        {
            regexComboBox.addItem(withObjectValue:line)
        }
        
        donestaring = true
    }
    
    
    @IBAction func comboAction(_ sender: Any)
    {
        let parts = regexComboBox.stringValue.split(separator: #/ \- /#)
        var re = parts[1]
            
        regexTextField.stringValue = String(re)
        regexAction(self)
    }
    
    
    func applicationWillTerminate(_ aNotification: Notification)
    {
    }

    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool
    {
        return false
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
        
       
        do
        {
            var newText = String()
            var errText = String()
            
            try process.run()
            
            newText = readPipe(pipe: readpipe)
            errText = readPipe(pipe: readerrpipe)
            
           
            if errText.count == 0
            {
                textField.string = newText
            }
            else
            {
                textField.string = "Error: \(errText)"
            }
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
    
    
    @IBAction func regExHelpAction(_ sender: Any)
    {
        guard let url = URL.init(string:"https://www.pcre.org/current/doc/html/pcre2syntax.html") else { return }
        NSWorkspace.shared.open(url)
        
        guard let url = URL.init(string:"https://github.com/apple/swift-evolution/blob/main/proposals/0355-regex-syntax-run-time-construction.md") else { return }
        NSWorkspace.shared.open(url)
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
                let nsrange = rangeToNSRange(range: match.range, inText: text)
                astr.addAttributes([.foregroundColor:NSColor.red,.font:font!], range: nsrange)
                

                if (match.output.count > 1)
                {
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
                            let cnsrange = rangeToNSRange(range: crange, inText: text)
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
   
    
    func rangeToNSRange(range:Range<String.Index>, inText text:String) -> NSRange
    {
        let rangeStartIndex = range.lowerBound
        let rangeEndIndex = range.upperBound

        let start = text.distance(from: text.startIndex, to: rangeStartIndex)
        let length = text.distance(from: rangeStartIndex, to: rangeEndIndex)

        return NSMakeRange(start,length)
    }

    
    func readPipe(pipe:Pipe) -> String
    {
        var newText = String()
        
        var moredata = true
        repeat
        {
            let data : Data = pipe.fileHandleForReading.availableData
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
                    
        return newText
    }
    
}

