//
//  VoicePlayerVC.swift
//  adimvi
//
//  Created by Aira on 23.11.2021.
//  Copyright © 2021 webdesky.com. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire

class VoicePlayerVC: UIViewController {
    
    var callback: (() -> Void)!
    
    var model: RoomMessageModel!
    
    @IBOutlet weak var bgUIMG: UIImageView!
    @IBOutlet weak var avatarUIMG: UIImageView!
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var playUIMG: UIImageView!
    @IBOutlet weak var seekBar: UISlider!
    @IBOutlet weak var durationLB: UILabel!
    @IBOutlet weak var gifUIMG: UIImageView!
    
    var audioPlayer: AVAudioPlayer?
    var audioTimer: Timer?
    var isPaused: Bool = false
    var countr = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        playUIMG.isUserInteractionEnabled = true
        playUIMG.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapPlayUB)))
        
        seekBar.value = 0.0
        bgUIMG.sd_setImage(with: URL(string: model.senderAvatar), placeholderImage: UIImage(named: "Splaceicon"))
        avatarUIMG.sd_setImage(with: URL(string: model.senderAvatar), placeholderImage: UIImage(named: "Splaceicon"))
        nameLB.text = model.userName
        durationLB.text = model.content.convertDuration()
        gifUIMG.setGifImage(UIImage(gifName: "gif_load.gif"))
        gifUIMG.isHidden = true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func didTapPlayUB() {
        let fileName = model.extra.components(separatedBy: "/").last
        let checkFileExistResult = checkFileExist(fileName: fileName!)
        if checkFileExistResult.0 {
            let url = URL(fileURLWithPath: checkFileExistResult.1)
            do {
                gifUIMG.isHidden = true
                playUIMG.isHidden = false
                if audioPlayer != nil && audioPlayer!.isPlaying {
                    audioPlayer?.pause()
                    audioTimer?.invalidate()
                    isPaused = true
                    playUIMG.image = UIImage(systemName: "play.fill")
                } else {
                    if !isPaused {
                        audioPlayer = try AVAudioPlayer(contentsOf: url)
                    }
                    isPaused = false
                    audioPlayer?.delegate = self
                    playUIMG.image = UIImage(systemName: "pause.fill")
                    audioPlayer?.play()
                    updateSeekbar()
                }
            } catch {
                print("could not load fil")
            }
        } else {
            gifUIMG.isHidden = false
            playUIMG.isHidden = true
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileURL = documentURL.appendingPathComponent(fileName!)
                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
            }
            Alamofire.download(model.extra, to: destination).response { response in
                print(response)
                if response.error == nil, let _ = response.destinationURL?.path{
                    self.didTapPlayUB()
                }
            }
        }
        
    }
    
    func updateSeekbar() {
        audioTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerAction(timer:)), userInfo: nil, repeats: true)
    }
    
    @objc func timerAction(timer: Timer) {
        countr += 1
        let timeInterval = countr * 1000
        let leftTime = Int(model.content)! - timeInterval
        guard let currentTime = audioPlayer?.currentTime, let duration = audioPlayer?.duration else {return}
        let percentCompleted = currentTime / duration
        durationLB.text = String(leftTime).convertDuration()
        seekBar.value = Float(percentCompleted)
    }

    @IBAction func didTapDismissUB(_ sender: Any) {
        isPaused = false
        countr = 0
        if audioPlayer != nil {
            if audioPlayer!.isPlaying {
                audioPlayer?.stop()
            }
            audioPlayer = nil
        }
        if audioTimer != nil {
            audioTimer?.invalidate()
        }
        callback()
    }
    
    func checkFileExist(fileName: String) -> (Bool, String) {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        let filePath = url.appendingPathComponent(fileName)
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath!.path) {
            return (true, filePath!.path)
        } else {
            return (false, "")
        }
    }
}

extension VoicePlayerVC: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        seekBar.value = 0.0
        durationLB.text = model.content.convertDuration()
        audioTimer?.invalidate()
        audioPlayer = nil
        isPaused = false
        countr = 0
        playUIMG.image = UIImage(systemName: "play.fill")
    }
}

extension String {
    func convertDuration() -> Self {
        let intDuration = Int(self)!
        let hrs = intDuration / 3600000
        let mins = (intDuration % 3600000) / 60000
        let secs = ((intDuration % 3600000) % 60000) / 1000
        if hrs > 0 {
            return String(format: "%02d:%02d:%02d", arguments: [hrs, mins, secs])
        } else {
            return String(format: "%02d:%02d", arguments: [mins, secs])
        }
    }
}
