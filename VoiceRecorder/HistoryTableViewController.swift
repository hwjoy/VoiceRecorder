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
    var fileArray: [String]?
    var audioPlay: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let statusHeight = UIApplication.shared.statusBarFrame.height
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: statusHeight))
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fileArray = FileManager.default.subpaths(atPath: audioFilesPath)
        
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    fileprivate func playAudio(_ filename: String) {
        let url = NSString(string: audioFilesPath).appendingPathComponent(filename)
        do {
            audioPlay = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: url))
            audioPlay?.delegate = self
            audioPlay?.play()
        } catch {
            print(error)
        }
    }
    
    // MARK: - AVAudioRecorderDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("[I] \(NSString(string: #file).lastPathComponent) \(#function) \(flag)")
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("[I] \(NSString(string: #file).lastPathComponent) \(#function) \(error?.localizedDescription ?? "")")
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let array = fileArray else {
            return 0
        }
        return array.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordCell", for: indexPath)
        cell.textLabel?.text = fileArray?[indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let array = fileArray else {
            return
        }
        playAudio(array[indexPath.row])
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
            if fileArray != nil {
                let filename = fileArray![indexPath.row]
                let url = NSString(string: audioFilesPath).appendingPathComponent(filename)
                try? FileManager.default.removeItem(atPath: url)
            }
            
            fileArray?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
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
