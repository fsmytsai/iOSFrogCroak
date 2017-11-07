//
//  AudioViewController.swift
//  FrogCroak
//
//  Created by 蔡旻袁 on 2017/10/23.
//  Copyright © 2017年 蔡旻袁. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation

class AudioViewController: UIViewController, AVAudioRecorderDelegate, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var iv_ResultFrogImage: UIImageView!
    
    @IBOutlet weak var l_Result: UILabel!
    @IBOutlet weak var bt_Record: UIButton!
    var audioRecorder:AVAudioRecorder?
    var isRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPopover" {
            let vc = segue.destination
            vc.preferredContentSize = CGSize(width: 175, height: 35)
            let controller = vc.popoverPresentationController
            if controller != nil {
                controller?.backgroundColor = UIColor.init(red: 0.2314, green: 0.3176, blue: 0.0784, alpha: 1)
                controller?.delegate = self
            }
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    @IBAction func record(_ sender: UIButton) {
        if isRecording && audioRecorder != nil {
            audioRecorder?.stop()
            bt_Record.setImage(UIImage(named: "recordbtn") , for: .normal)
            isRecording = false
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(AVAudioSessionCategoryPlayback)
                try audioSession.setActive(false)
            } catch _ {
            }
            
        } else {
            performSegue(withIdentifier: "showPopover", sender: nil)
            l_Result.text = "結果"
            iv_ResultFrogImage.image = nil
            let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let recordingName = "Frog.wav"
            let filePath = documentPath + "/" + recordingName
            let fileURL = URL(fileURLWithPath: filePath)
            
            let session = AVAudioSession.sharedInstance()
            
            do {
                try session.setCategory(AVAudioSessionCategoryPlayAndRecord)//7
            } catch _ {
            }
            
            let recordSettings:[String:Any] = [
                AVFormatIDKey : NSNumber(value: kAudioFormatLinearPCM),
                AVNumberOfChannelsKey : 2, //录音的声道数，立体声为双声道
                AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,//音频质量
                AVSampleRateKey : 44100.0,//录音器每秒采集的录音样本数
                AVLinearPCMBitDepthKey : NSNumber(value: 16),
                AVLinearPCMIsBigEndianKey : NSNumber(value: true),
                AVLinearPCMIsFloatKey : NSNumber(value: true)]
            
            do {
                audioRecorder = try AVAudioRecorder(url: fileURL, settings: recordSettings) //9
                
            } catch _ {
                audioRecorder = nil
            }
            audioRecorder?.delegate = self
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
            bt_Record.setImage(UIImage(named: "recordingbtn") , for: .normal)
            isRecording = true
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            //使用Alamofire上传
            Alamofire.upload(
                multipartFormData: {
                    multipartFormData in
                    multipartFormData.append(recorder.url, withName: "file[0]", fileName: "Frog.wav", mimeType: "audio/x-wav")
                },
                to: "https://frogcroak.azurewebsites.net/api/Frog/SoundRecognition",
                headers: ["content-type":"multipart/form-data"],
                encodingCompletion: {
                    encodingResult in
                    switch encodingResult {
                    case .success(let upload, _, _) :
                        upload.responseJSON {
                            response in
                            if let data = response.result.value {
                                DispatchQueue.main.async {
                                    if(response.response?.statusCode == 200){
                                        let FrogName = data as? String
                                        self.l_Result.text = FrogName
                                        if FrogName == "台北樹蛙" {
                                            self.iv_ResultFrogImage.image = UIImage(named: "tptreefrog")
                                        }
                                        else if FrogName == "面天樹蛙" {
                                            self.iv_ResultFrogImage.image = UIImage(named: "facefrog")
                                        }
                                        else if FrogName == "澤蛙" {
                                            self.iv_ResultFrogImage.image = UIImage(named: "waterfrog")
                                        }
                                        else if FrogName == "小雨蛙" {
                                            self.iv_ResultFrogImage.image = UIImage(named: "rainfrog")
                                        }
                                        else if FrogName == "艾氏樹蛙" {
                                            self.iv_ResultFrogImage.image = UIImage(named: "aistreefrog")
                                        }
                                        else if FrogName == "拉都希氏赤蛙" {
                                            self.iv_ResultFrogImage.image = UIImage(named: "ladofrog")
                                        }
                                        else if FrogName == "虎皮蛙" {
                                            self.iv_ResultFrogImage.image = UIImage(named: "lionskinfrog")
                                        }
                                        else if FrogName == "豎琴蛙" {
                                            self.iv_ResultFrogImage.image = UIImage(named: "harpfrog")
                                        }
                                        else if FrogName == "布氏樹蛙" {
                                            self.iv_ResultFrogImage.image = UIImage(named: "boostreefrog")
                                        }
                                        else if (FrogName == "貢德氏赤蛙") {
                                            self.iv_ResultFrogImage.image = UIImage(named: "gondesfrog")
                                        }
                                    } else{
                                        print("\(response.response?.statusCode ?? 0)")
                                    }
                                    
                                }
                            }

                        }
                        break
                    case .failure(let encodingError) :
                        print(encodingError)
                        break
                    }
            })
        }
    }
    
}
