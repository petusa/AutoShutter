//
//  ViewController.swift
//  AutoShutter
//
//  Created by Peter Nagy on 7/1/17.
//  Copyright © 2017 Mobile Dev Studio. All rights reserved.
//

import Cocoa
import AVFoundation

// tiny application to remotely push and hold the capture button for the Sony Remote Camera Controll app, for starting continous shooting
// without the presence of a camera man (who basically controls the Sony app and keeps the capture pressed while doing a continous shot)
class ViewController: NSViewController {
    
    
    var captureStarted: Bool = false
    
    @IBAction func buttonTapped(button: NSButton) {
        // clear customizations on trigger button
        button.layer?.backgroundColor = CGColor.clear
        //
        let remoteAppButtonPoint = identifyCaptureButtonPoint()
        if (!captureStarted) {
            captureStarted = true
            startWithTimer(button:button, seconds: 3, action: {
                self.pressMouseDown(point: remoteAppButtonPoint)
            })
        } else {
            releaseMouseUp(point: remoteAppButtonPoint)
            captureStarted = false
            button.title = "Start"
        }
    }

    
    // MARK: - find/identify Sony's Remote Camera Control app's capture button's position
    
    func identifyCaptureButtonPoint() -> CGPoint {
        // INFO
        // currenly I am using a naiva approach, when the Remote Camera Control app is positioned in
        // the top left corner of the window, on the current resolution of my display
        // this X and Y values are provided according to this setup
        let x  = 210 // CGFloat(args.integer(forKey: "x"))
        let y  = 210 // CGFloat(args.integer(forKey: "y"))
        let point = CGPoint(x: x, y: y)
        
        // TODO
        // find better way to find and identify Sony Remote Camera Control app, and it's UI components
        // maybe use Swindler library
        //        let ws = NSWorkspace.shared()
        //
        //        let apps = ws.runningApplications
        //        var remoteCameraControlApp:NSRunningApplication?
        //        for currentApp in apps
        //        {
        //            if(currentApp.activationPolicy == .regular){
        //                print(currentApp.localizedName!)
        //                if currentApp.localizedName!.compare("Remote Camera Control").rawValue == 0 {
        //                    remoteCameraControlApp = currentApp
        //                    break
        //                }
        //            }
        //        }
        //        if remoteCameraControlApp != nil {
        //            //remoteCameraControlApp?
        //                // .addObserver(<#T##observer: NSObject##NSObject#>, forKeyPath: <#T##String#>, options: <#T##NSKeyValueObservingOptions#>, context: <#T##UnsafeMutableRawPointer?#>)
        //            let windowList = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements, kCGNullWindowID);
        //
        //        }
        
        return point
    }
    
    
    // MARK: - timer/countdown decorator for button
    
    var isTimerRunning = false
    var timer = Timer() // This will be used to make sure only one timer is created at a time.
    func startWithTimer(button: NSButton, seconds: Int, action: @escaping () -> ()) {
        self.playSound(file: "263133__pan14__tone-beep", ext: "wav")
        button.title = String(seconds)
        button.layer?.backgroundColor = CGColor(red: 1, green: 0, blue: 0, alpha: 1)
        var remainingSeconds = seconds
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (t) in
            remainingSeconds = remainingSeconds-1
            if (remainingSeconds==0) { // timer elapsed
                t.invalidate()
                self.isTimerRunning = false
                self.playSound(file: "180821__empty-bell__beep", ext: "wav")
                button.title = "Stop"
                action()
                return
            }
            self.isTimerRunning = true
            self.playSound(file: "263133__pan14__tone-beep", ext: "wav")
            button.title = String(remainingSeconds)
        })
    }

    
    // MARK: - mouse trigger actions
    
    func pressMouseDown(point: CGPoint) { // click on button
        let mouseDown = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown,    mouseCursorPosition: point, mouseButton: .left)
        mouseDown?.post(tap: .cghidEventTap)
    }
    
    func releaseMouseUp(point: CGPoint) { // release button
        let mouseUp   = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: point, mouseButton: .left)
        mouseUp?.post(tap: .cghidEventTap)
    }
    
    let kDelayUSec : useconds_t = 500
    func dragMouse(from p0: CGPoint, to p1: CGPoint) {
        let mouseDown = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown,    mouseCursorPosition: p0, mouseButton: .left)
        let mouseDrag = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDragged, mouseCursorPosition: p1, mouseButton: .left)
        let mouseUp   = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: p1, mouseButton: .left)
        mouseDown?.post(tap: .cghidEventTap)
        mouseDrag?.post(tap: .cghidEventTap)
        usleep(kDelayUSec)
        mouseUp?.post(tap: .cghidEventTap)
    }
    
    
    // MARK: - playing sounds helper
    
    var player: AVAudioPlayer?
    func playSound(file:String, ext:String) -> Void {
        let url = Bundle.main.url(forResource: file, withExtension: ext)!
        do {
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            
            player.prepareToPlay()
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }

}
