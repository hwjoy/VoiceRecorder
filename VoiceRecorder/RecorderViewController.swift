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

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    var audioRecorder: AVAudioRecorder?
    lazy var currentAudioFilePath: String = {
        let filename = Date().description + ".m4a"
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        return NSString(string: documentDirectory).appendingPathComponent(filename)
    }()
    lazy var updateMetersTimer: Timer = {
        return Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
            self.audioRecorder?.updateMeters()
            if var powerChannel0 = self.audioRecorder?.averagePower(forChannel: 0) {
                powerChannel0 += 160
                self.performSelector(onMainThread: #selector(self.updateWaveform(_:lineColor:)), with: [powerChannel0, UIColor.black], waitUntilDone: false)
            }
            if var powerChannel1 = self.audioRecorder?.averagePower(forChannel: 1) {
                powerChannel1 += 160
                self.performSelector(onMainThread: #selector(self.updateWaveform(_:lineColor:)), with: [powerChannel1, UIColor.purple], waitUntilDone: false)
            }
        })
    }()
    
    var powerArray: Array<Float> = []
    var waveformView: WaveformView?

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

    // MARK: - Init
    
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
        
        waveformView = WaveformView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height / 2))
        waveformView?.backgroundColor = UIColor.clear
        view.addSubview(waveformView!)
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
        startButton.isEnabled = true
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.setActive(true)
        } catch {
            print(error)
        }
    }
    
    // MARK: - Display Waveform
    
    @objc func updateWaveform(_ value: Float, lineColor: UIColor) {
        print("[I] \(NSString(string: #file).lastPathComponent) \(#function) \(value) \(lineColor)")
        
        powerArray.append(value)
        waveformView?.dataSource = powerArray
        waveformView?.lineColor = UIColor.black
        waveformView?.setNeedsDisplay()
    }
    
    // MARK: - User Action
    
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
            try audioRecorder = AVAudioRecorder(url: URL(fileURLWithPath: currentAudioFilePath), settings: recorderSettings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            
            if (audioRecorder?.isRecording)! {
                return
            }
            audioRecorder?.record()
            updateMetersTimer.fire()
        } catch {
            print(error)
        }
    }
    
    @objc func pauseButtonAction(_ sender: UIButton) {
        sender.isEnabled = false
        startButton.isEnabled = true
        
        if (audioRecorder?.isRecording)! {
            audioRecorder?.pause()
            updateMetersTimer.invalidate()
        }
    }
    
    @objc func stopButtonAction(_ sender: UIButton) {
        sender.isEnabled = false
        startButton.isEnabled = true
        pauseButton.isEnabled = false
        
        if (audioRecorder?.isRecording)! {
            audioRecorder?.stop()
            updateMetersTimer.invalidate()
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
