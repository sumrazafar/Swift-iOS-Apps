//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Sumra Zafar on 5/8/16.
//  Copyright © 2016 Sumra Zafar. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var stopRecordingButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    
    var audioRecorder:AVAudioRecorder!
    
    var counter = 0
    var timer = NSTimer()
    
    // called every time interval from the timer
    func updateTimer(timer: NSTimer) {
        counter += 1
        recordingLabel.text = "Recording in progress..." + String(counter)
    }
    
    @IBAction func recordAudio(sender: AnyObject) {
        recordingLabel.text = "Recording in progress..." //less than one second
        timer.invalidate() // just in case this button is tapped multiple times
        // start the timer set interval update to 1 second
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateTimer:", userInfo: nil, repeats: true)
        stopRecordingButton.enabled = true
        recordButton.enabled = false
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        print(filePath)
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        
        try! audioRecorder = AVAudioRecorder(URL: filePath!, settings: [:])
        /* previous review suggested removing self call but when i do it doesnt redirects to next view */
        audioRecorder.delegate = self
        audioRecorder.meteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }

    @IBAction func stopRecording(sender: AnyObject) {
        print("Stop recording was pressed")
        timer.invalidate() //stop timer
        counter = 0 //reset the counter
        let duration = Double(round(100 * audioRecorder.currentTime)/100)
        print("Total recording duration:", String(duration), "seconds")
        stopRecordingButton.enabled = false
        recordButton.enabled = true
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
        recordingLabel.text = "Tap to Record"
    }
    
    override func viewWillAppear(animated: Bool) {
        stopRecordingButton.enabled = false
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if(flag){
            self.performSegueWithIdentifier("stopRecording", sender: audioRecorder.url)
        }else{
            print("Saving of recording failed")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "stopRecording") {
            let playSoundsVC = segue.destinationViewController as! PlaySoundsViewController
            let recordedAudioURL = sender as! NSURL
            playSoundsVC.recordedAudioURL = recordedAudioURL
        }
    }    
}

