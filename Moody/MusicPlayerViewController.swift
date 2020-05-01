//
//  MusicPlayerViewController.swift
//  Moody
//
//  Created by SWU Mac on 2020/04/30.
//  Copyright © 2020 SWU Mac. All rights reserved.
//

import UIKit
import AVFoundation

class MusicPlayerViewController: UIViewController, AVAudioPlayerDelegate {

    var songID: Int = 0
    
    var SongName: [Int: String] = [1: "Fireflies", 11: "Must Have Been The Wind", 12: "愛を伝えたいだとか", 20: "Take The A Train", 21: "Teenage Dream", 22: "お気に召すまま", 100: "Open Door", 102: "Kujira", 111: "Wish You Were Gay", 112: "たばこ", 121: "The Best Day"]
    
    //추천 음악이 존재하지 않는 경우에 재생 버튼과 재생시간 슬라이더를 조정할 수 없게 한다.
    var isMusicExist : Bool = false
    
    var player : AVAudioPlayer!
    var timer : Timer!

    
    
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var albumCover: UIImageView!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var playTimeLabel: UILabel!
    @IBOutlet weak var playSilder: UISlider!
    
    @IBOutlet weak var lyricsView: UIView!
    @IBOutlet weak var lyricsContent: UITextView!
    
    
    @IBAction func touchUpPlayPauseBtn( sender : UIButton){
        
        sender.isSelected = !sender.isSelected
        
        if isMusicExist {
            // sender가 선택되면 플레이어가 재생중인지 확인하고 처리
            if sender.isSelected {
                self.player?.play()
            } else {
                self.player?.pause()
            }
            
            // sender가 선택되면 타이머 처리를 할 것인지 확인
            if sender.isSelected{
                self.makeAndFireTimer()
            } else{
                self.invalidateTimer()
            }
        }
        
    }
    
    
    // 플레이어 초기화.
    func initializePlayer(){
        
        //노래가 있는지 확인하고 가져온다, songID를 이용해 노래를 찾는다
        if let songTitle = SongName[songID] {
            
            isMusicExist = true
            self.songTitleLabel.text = songTitle
            self.albumCover.image =  UIImage(named: songTitle + "Cover")
            
            guard let soundAsset : NSDataAsset = NSDataAsset(name : songTitle)
                else {
                print("음원을 asset에서 찾을 수 없음")
                return
            }
            do {
                try self.player = AVAudioPlayer(data : soundAsset.data)
                self.player.delegate = self
                
            } catch let error as NSError {
                print("초기화 실패");
                print("코드 : \(error.code), 메세지 : \(error.localizedDescription) ")
                
            }
            
            self.playSilder.maximumValue = Float(self.player.duration);
            self.playSilder.minimumValue = 0;
            self.playSilder.value = Float(self.player.currentTime);
                
        }
        else {
            print("노래가 등록되어 있지 않습니다.")
            }
        
        
        
    }
    
    
    // 레이블 업데이트.
    func updateTimeLabelText(time:TimeInterval){
        let minute : Int = Int(time/60);
        let second : Int = Int(time.truncatingRemainder(dividingBy: 60));
        let milisecond : Int = Int(time.truncatingRemainder(dividingBy: 1)*100);
                
        let timeText : String = String(format : "%02ld:%02ld:%02ld", minute, second, milisecond);
        self.playTimeLabel.text = timeText
        
    }
        
    // 타이머를 만들고 수행해줄 메소드
    func makeAndFireTimer(){
        self.timer = Timer.scheduledTimer(withTimeInterval : 0.01, repeats: true, block : { [unowned self] (timer : Timer) in
            if self.playSilder.isTracking { return }
            self.updateTimeLabelText(time:self.player.currentTime)
            self.playSilder.value = Float(self.player.currentTime)
        }
        )
        self.timer.fire();
        }

    
    // 플레이어 재생 관련 에러처리.
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        guard let error: Error = error else{
            print("플레이어 오류 발생");
            return
        }
        
        let message : String
        message = "플레이어 오류 발생 \(error.localizedDescription)"
        
        let alert : UIAlertController = UIAlertController(title:"알림", message : message, preferredStyle :UIAlertController.Style.alert)
        
        let okAction : UIAlertAction = UIAlertAction(title : "확인", style : UIAlertAction.Style.default) { ( action:UIAlertAction) -> Void in
            self.dismiss(animated: true, completion:nil)
        }
        
        alert.addAction(okAction)
        self.present(alert, animated:true, completion:nil)
    }
       
    // 음악 재생이 끝나면
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.playBtn.isSelected = false
        self.playSilder.value = 0
        self.updateTimeLabelText(time: 0)
        self.invalidateTimer()
    }
    
    // 타이머 해제
    func invalidateTimer(){
        self.timer.invalidate()
        self.timer = nil
    }
           
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isMusicExist = false
        self.initializePlayer()
        self.lyricsView.isHidden = true
        print(songID)
    }
    
    
    //음악이 존제하는 플레이어 화면에서 뒤로가기 버튼을 누를 떄 재생 상태이면 타이머 할당을 해제 해주어야 함
    override func willMove(toParent parent: UIViewController?)
    {
        if parent == nil
        {
            if playBtn.isSelected && isMusicExist {
                self.invalidateTimer()
            }
        }
    }

    // 슬라이더를 이용한 오디오 제어
    @IBAction func sliderValueControl(_ sender: UISlider) {
        
        if isMusicExist {
            self.updateTimeLabelText(time: TimeInterval(sender.value))
            if sender.isTracking{return}
            self.player.currentTime = TimeInterval(sender.value)
        }
       
    }
    
    
    //가사 뷰 처리
    @IBAction func showLyrics(_ sender: UIButton) {
        
        if let songTitle = SongName[songID] {
            if let txtFilePath = Bundle.main.path(forResource: songTitle, ofType: "txt"){
                do {
                    let contents = try String(contentsOfFile: txtFilePath)
                    lyricsContent.text = contents
                }
                catch {
                    print("가사불러오기 오류")
                }
            }
            else {
                print("가사를 찾을 수 없습니다")
            }
        }
        else {
            
        }
        
       
        self.lyricsView.isHidden = false
    }
    
    
    @IBAction func closeLyrics(_ sender: Any) {
        self.lyricsView.isHidden = true
    }
    
    
    
    }
    
