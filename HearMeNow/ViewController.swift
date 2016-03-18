//
//  ViewController.swift
//  HearMeNow
//
//  Created by Ryan Ingram on 30/10/2014.
//  Copyright (c) 2014 Ryan Ingram. All rights reserved.
//  This is the View Controller

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {

    var hasRecording = false
    var soundPlayer : AVAudioPlayer?
    var soundRecorder : AVAudioRecorder?
    var session : AVAudioSession?
    var soundPath : String?
    
    let recordSettings = [AVSampleRateKey : NSNumber(float: Float(44100.0)),
    AVFormatIDKey : NSNumber(int: Int32(kAudioFormatMPEG4AAC)),
    AVNumberOfChannelsKey : NSNumber(int: 1),
    AVEncoderAudioQualityKey : NSNumber(int: Int32(AVAudioQuality.Medium.rawValue))]
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBAction func recordPressed(sender: AnyObject) {
        if(soundRecorder?.recording == true)
        {
            soundRecorder?.stop()
            recordButton.setTitle("Record", forState: UIControlState.Normal)
            hasRecording = true
        }
        else
        {
            session?.requestRecordPermission(){
                granted in
                if(granted == true)
                {
                    self.soundRecorder?.record()
                    self.recordButton.setTitle("Stop", forState: UIControlState.Normal)
                }
                else
                {
                    print("Unable to record")
                }
            }
        }
    }
    @IBAction func playPressed(sender: AnyObject) {
        if(soundPlayer?.playing == true)
        {
            soundPlayer?.pause()
            playButton.setTitle("Play", forState: UIControlState.Normal)
        }
        else if (hasRecording == true)
        {
            let url = NSURL(fileURLWithPath: soundPath!)
            var error : NSError?
            
            do {
                soundPlayer = try AVAudioPlayer(contentsOfURL: url)
            } catch let error1 as NSError {
                error = error1
                soundPlayer = nil
            }
            
            if(error == nil)
            {
                soundPlayer?.delegate = self
                soundPlayer?.enableRate = true
                soundPlayer?.rate = 0.5
                soundPlayer?.play()
            }
            else
            {
                print("Error initializing player \(error)")
            }
            playButton.setTitle("Pause", forState: UIControlState.Normal)
            hasRecording = false
        }
        else if (soundPlayer != nil)
        {
            soundPlayer?.play()
            playButton.setTitle("Pause", forState: UIControlState.Normal)
        }
    }

    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        recordButton.setTitle("Record", forState: UIControlState.Normal)
    }

    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        playButton.setTitle("Play", forState: UIControlState.Normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        soundPath = "\(NSTemporaryDirectory())hearmenow.wav"
        
        let url = NSURL(fileURLWithPath: soundPath!)
        
        session = AVAudioSession.sharedInstance()
        do {
            try session?.setActive(true)
        } catch _ {
        }
        
        var error : NSError?
        
        do {
            try session?.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch var error1 as NSError {
            error = error1
        }
        
        do {
            soundRecorder = try AVAudioRecorder(URL: url, settings: recordSettings )
            //soundRecorder = try AVAudioRecorder(URL: url, settings: nil)
        } catch var error1 as NSError {
            error = error1
            soundRecorder = nil
        }
        
        if(error != nil)
        {
            print("Error initializing the recorder: \(error)")
        }
        
        soundRecorder?.delegate = self
        soundRecorder?.prepareToRecord()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

