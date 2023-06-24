//
//  TimerView.swift
//  The Memory
//
//  Created by Andrei on 23/6/23.
//

import UIKit

class TimerView: UIView {
    
    var timerLabel = UILabel()
    var timer: Timer = Timer()
    var count: Int = 0
    
    var timerCounting: Bool = false
    
    init() {
        super.init(frame: .zero)
        timerLabel.text = "00 : 00 : 00"
        timerLabel.font = UIFont.boldSystemFont(ofSize: 18)
        
        addSubview(timerLabel)
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        timerLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        
    }
    
    func resetTimer() {
        self.count = 0
        self.timer.invalidate()
        self.timerLabel.text = self.makeTimeString(hours: 0, minutes: 0, seconds: 0)
        self.timerCounting = false
    }
    
    func startStopTimer() {
        
        if(timerCounting) {
            timerCounting = false
            timer.invalidate()
        } else {
            timerCounting = true
            timer = Timer.scheduledTimer(
                timeInterval: 1,
                target: self,
                selector: #selector(timerCounter),
                userInfo: nil,
                repeats: true)
        }
    }
    
    @objc func timerCounter() -> Void {
        
        count = count + 1
        let time = secondsToHoursMinutesSeconds(seconds: count)
        let timeString = makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
        timerLabel.text = timeString
        
    }
    
    func secondsToHoursMinutesSeconds(seconds: Int) -> (Int, Int, Int) {
        return (seconds / 3600, ((seconds % 3600) / 60), ((seconds % 3600) % 60))
    }
    
    func makeTimeString(hours: Int, minutes: Int, seconds: Int) -> String {
        var timeString = ""
        timeString += String(format: "%02d", hours)
        timeString += " : "
        timeString += String(format: "%02d", minutes)
        timeString += " : "
        timeString += String(format: "%02d", seconds)
        
        return timeString
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
