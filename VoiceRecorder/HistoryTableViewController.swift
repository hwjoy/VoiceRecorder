//
//  HistoryTableViewController.swift
//  VoiceRecorder
//
//  Created by hwjoy on 10/04/2018.
//  Copyright © 2018 redant. All rights reserved.
//

import UIKit
import AVFoundation

class HistoryTableViewController: UITableViewController, AVAudioPlayerDelegate {

    lazy var audioFilesPath: String = {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    }()
    var fileArray: [(directory: String, subFile: [String])]?
    var audioPlay: AVAudioPlayer?
    var selectedIndex = -1
    var selectedDuration = 0.0
    var selectedCurrentTime = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let statusHeight = UIApplication.shared.statusBarFrame.height
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: statusHeight))
        let tabBarController = UITabBarController()
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: tabBarController.tabBar.frame.height))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fileArray = []
        let files = FileManager.default.enumerator(atPath: audioFilesPath)
        while let file = files?.nextObject() as? String {
            if (NSString(string: file).pathExtension == "") {
                fileArray?.append((file, []))
            } else {
                let fileDirectory = NSString(string: file).deletingLastPathComponent
                if let index = fileArray?.count, fileDirectory == fileArray?.last?.directory {
                    var subFile = fileArray?.last?.subFile
                    subFile?.append(file)
                    fileArray?[index - 1] = (fileDirectory, subFile!)
                }
            }
        }
        
        print("[I] AudioFilesPath = \(fileArray ?? [])")
        
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    fileprivate func playAudio(_ indexPath: IndexPath) -> TimeInterval {
        guard let _ = fileArray else {
            return 0
        }
        
        let filename = fileArray![indexPath.section].subFile[indexPath.row]
        let url = URL(fileURLWithPath: NSString(string: audioFilesPath).appendingPathComponent(filename))
        if audioPlay?.url == url {
            if audioPlay != nil && audioPlay!.isPlaying {
                audioPlay?.pause()
                selectedCurrentTime = audioPlay!.currentTime
            } else {
                audioPlay?.play()
            }
        } else {
            if audioPlay != nil {
                audioPlay!.stop()
            }
            do {
                audioPlay = try AVAudioPlayer(contentsOf: url)
                audioPlay?.delegate = self
                audioPlay?.play()
                selectedCurrentTime = 0
            } catch {
                print(error)
                
                selectedIndex = -1
                
                let alertController = UIAlertController(title: NSLocalizedString("File corrupted", comment: ""), message: NSLocalizedString("Delete the file?", comment: ""), preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: NSLocalizedString("Keep", comment: ""), style: .cancel, handler: { (_) in
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                })
                let okAction = UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive, handler: { (_) in
                    self.deleteFile(url, indexPath: indexPath)
                })
                alertController.addAction(cancelAction)
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
            }
        }
        
        guard let duration = audioPlay?.duration else { return 0 }
        return duration
    }
    
    fileprivate func deleteFile(_ indexPath: IndexPath) {
        guard let _ = fileArray else {
            return
        }
        
        let filename = fileArray![indexPath.section].subFile[indexPath.row]
        let url = URL(fileURLWithPath: NSString(string: audioFilesPath).appendingPathComponent(filename))
        deleteFile(url, indexPath: indexPath)
    }
    
    fileprivate func deleteFile(_ url: URL, indexPath: IndexPath) {
        try? FileManager.default.removeItem(at: url)
        
        guard let _ = fileArray else {
            return
        }
        
        fileArray![indexPath.section].subFile.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: - AVAudioRecorderDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("[I] \(NSString(string: #file).lastPathComponent) \(#function) \(flag)")
        
        selectedCurrentTime = 0
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("[I] \(NSString(string: #file).lastPathComponent) \(#function) \(error?.localizedDescription ?? "")")
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let array = fileArray else {
            return 0
        }
        return array.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let array = fileArray else {
            return 0
        }
        return array[section].subFile.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordCell", for: indexPath)
        cell.textLabel?.text = NSString(string: (fileArray?[indexPath.section].subFile[indexPath.row])!).lastPathComponent
        cell.textLabel?.backgroundColor = UIColor.clear
        cell.detailTextLabel?.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        if indexPath.row == selectedIndex {
            let time = Int(selectedDuration)
            cell.detailTextLabel?.text = String(format: "%02d:%02d", time / 60, time % 60)
        } else {
            cell.detailTextLabel?.text = " "
        }
        if indexPath.row == selectedIndex {
            let progressView = UIView(frame: CGRect(x: 0, y: 0, width: CGFloat(selectedCurrentTime / selectedDuration) * cell.bounds.width, height: cell.bounds.height))
            progressView.backgroundColor = UIColor(red: 0, green: 122.0 / 255, blue: 255.0 / 255, alpha: 0.6)
            if audioPlay != nil && audioPlay!.isPlaying {
                // Duration * 1.1: Prevent audio and video from being out of sync
                UIView.animate(withDuration: (selectedDuration - selectedCurrentTime) * 1.1, delay: 0, options: .curveLinear, animations: {
                    progressView.frame = cell.bounds
                }, completion: { (finished) in
                    
                })
            }
            let backgroundView = UIView(frame: cell.bounds)
            backgroundView.backgroundColor = UIColor.white
            backgroundView.addSubview(progressView)
            cell.backgroundView = backgroundView
        } else {
            cell.backgroundView = nil
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fileArray?[section].directory
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectedIndex = indexPath.row
        selectedDuration = playAudio(indexPath)
        tableView.reloadSections([indexPath.section], with: .none)
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            deleteFile(indexPath)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
