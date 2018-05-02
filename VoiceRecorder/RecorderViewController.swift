//
//  RecorderViewController.swift
//  VoiceRecorder
//
//  Created by hwjoy on 10/04/2018.
//  Copyright © 2018 redant. All rights reserved.
//

import UIKit
import AVFoundation

public let AudioLevel:Float = 120.0

class RecorderViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    var audioRecorder: AVAudioRecorder?
    lazy var currentAudioFilePath: String = {
        let filename = dateFormatter.string(from: Date()) + ".m4a"
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        return NSString(string: documentDirectory).appendingPathComponent(filename)
    }()
    lazy var updateMetersTimer: Timer = {
        return Timer.scheduledTimer(withTimeInterval: WaveformView.SampleRate, repeats: true, block: { (timer) in
            self.audioRecorder?.updateMeters()
            if var powerChannel0 = self.audioRecorder?.averagePower(forChannel: 0) {
                powerChannel0 += 160
                self.performSelector(onMainThread: #selector(self.updateWaveform(_:)), with: [NSNumber(value: powerChannel0), UIColor.black.withAlphaComponent(0.8)], waitUntilDone: false)
            }
        })
    }()
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter
    }()
    
    var powerArray: Array<Float> = []
    var waveformView: WaveformView?
    var barPlotView: BarPlotView?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initButtons()
        initAudio()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if waveformView == nil {
            initViews()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Init
    
    fileprivate func initButtons() {
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
    
    fileprivate func initViews() {
        waveformView = WaveformView(frame: CGRect(x: 0, y: 0, width: containerView.frame.width, height: containerView.frame.height / 2 - 16))
        waveformView?.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        waveformView?.layer.cornerRadius = 8
        waveformView?.layer.masksToBounds = true
        containerView.addSubview(waveformView!)
        
        barPlotView = BarPlotView(frame: CGRect(x: 0, y: containerView.frame.height / 2, width: containerView.frame.width, height: containerView.frame.height / 2))
        barPlotView?.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        barPlotView?.layer.cornerRadius = 8
        barPlotView?.layer.masksToBounds = true
        containerView.addSubview(barPlotView!)
        
        barPlotView?.setBarData([])
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
    
    @objc func updateWaveform(_ params: [Any]) {
        print("[I] \(Date()) \(NSString(string: #file).lastPathComponent) \(#function) \(params)")
        
        guard params.count > 1 else {
            return
        }
        
        powerArray.append(params.first as! Float)
        waveformView?.dataSource = powerArray
        waveformView?.lineColor = params[1] as! UIColor
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
            updateMetersTimer.fireDate = Date.distantPast
        } catch {
            print(error)
        }
    }
    
    @objc func pauseButtonAction(_ sender: UIButton) {
        sender.isEnabled = false
        startButton.isEnabled = true
        
        if (audioRecorder?.isRecording)! {
            audioRecorder?.pause()
            updateMetersTimer.fireDate = Date.distantFuture
        }
    }
    
    @objc func stopButtonAction(_ sender: UIButton) {
        sender.isEnabled = false
        startButton.isEnabled = true
        pauseButton.isEnabled = false
        
        audioRecorder?.stop()
        updateMetersTimer.fireDate = Date.distantFuture
        powerArray.removeAll()
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
