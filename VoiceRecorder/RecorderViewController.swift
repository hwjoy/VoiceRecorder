//
//  RecorderViewController.swift
//  VoiceRecorder
//
//  Created by hwjoy on 10/04/2018.
//  Copyright © 2018 redant. All rights reserved.
//

import UIKit
import AVFoundation

class RecorderViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    var audioRecorder: AVAudioRecorder?
    lazy var currentAudioFilePath: String = {
        let filename = Date().description + ".m4a"
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        return NSString(string: documentDirectory).appendingPathComponent(filename)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initViews()
        initAudio()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    fileprivate func initViews() {
        startButton.setTitle(NSLocalizedString("Start", comment: ""), for: .normal)
        pauseButton.setTitle(NSLocalizedString("Pause", comment: ""), for: .normal)
        stopButton.setTitle(NSLocalizedString("Stop", comment: ""), for: .normal)
        startButton.isEnabled = false
        pauseButton.isEnabled = false
        stopButton.isEnabled = false
        startButton.addTarget(self, action: #selector(startButtonAction(_:)), for: .touchUpInside)
        pauseButton.addTarget(self, action: #selector(pauseButtonAction(_:)), for: .touchUpInside)
        stopButton.addTarget(self, action: #selector(stopButtonAction(_:)), for: .touchUpInside)
    }
    
    fileprivate func initAudio() {
        let audioSession = AVAudioSession.sharedInstance()
        audioSession.requestRecordPermission { (granted) in
            if granted {
                self.performSelector(onMainThread: #selector(self.setupAudio(_:)), with: audioSession, waitUntilDone: true)
            } else {
                
            }
        }
    }
    
    @objc func setupAudio(_ audioSession: AVAudioSession) {
        self.startButton.isEnabled = true
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.setActive(true)
        } catch {
            print(error)
        }
    }
    
    @objc func startButtonAction(_ sender: UIButton) {
        sender.isEnabled = false
        pauseButton.isEnabled = true
        stopButton.isEnabled = true
        
        do {
            let recorderSettings = [
                AVFormatIDKey : kAudioFormatMPEG4AAC,   //编码格式
                AVSampleRateKey : 44100.0,  //声音采样率
                AVNumberOfChannelsKey : 2,  //采集音轨
                AVEncoderAudioQualityKey : AVAudioQuality.medium.rawValue] as [String : Any]
            try self.audioRecorder = AVAudioRecorder(url: URL(fileURLWithPath: currentAudioFilePath), settings: recorderSettings)
            self.audioRecorder?.delegate = self
            self.audioRecorder?.isMeteringEnabled = true
            
            if (self.audioRecorder?.isRecording)! {
                return
            }
            self.audioRecorder?.record()
        } catch {
            print(error)
        }
    }
    
    @objc func pauseButtonAction(_ sender: UIButton) {
        sender.isEnabled = false
        startButton.isEnabled = true
        
        if (self.audioRecorder?.isRecording)! {
            self.audioRecorder?.pause()
        }
    }
    
    @objc func stopButtonAction(_ sender: UIButton) {
        sender.isEnabled = false
        startButton.isEnabled = true
        pauseButton.isEnabled = false
        
        if (self.audioRecorder?.isRecording)! {
            self.audioRecorder?.stop()
        }
    }

    // MARK: - AVAudioRecorderDelegate
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("[I] \(NSString(string: #file).lastPathComponent) \(#function) \(flag)")
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("[I] \(NSString(string: #file).lastPathComponent) \(#function) \(error?.localizedDescription ?? "")")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
