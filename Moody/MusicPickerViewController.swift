//
//  MusicPickerViewController.swift
//  Moody
//
//  Created by SWU Mac on 2020/04/30.
//  Copyright © 2020 SWU Mac. All rights reserved.
//

import UIKit

class MusicPickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource  {

    
    
    @IBOutlet var musicPicker: UIPickerView!
    
    let speedArray: Array<String> = ["빠르고", "느리고"]
    let moodArray: [String] = ["평온한", "우울한", "신나는"]
    let genreArray: [String] = ["재즈 / R & B", "pop", "J-pop"]
    
    var selectedMood: String = ""
    var songIdentification: Int = 0
    
    

    
    @IBAction func getMusic() {
    let speed: String = speedArray[self.musicPicker.selectedRow(inComponent: 0)]
    let mood: String = moodArray[self.musicPicker.selectedRow(inComponent: 1)]
    let genre: String = genreArray[self.musicPicker.selectedRow(inComponent: 2)]
        
        selectedMood =  speed + " " + mood + " " + genre
        
        songIdentification = self.musicPicker.selectedRow(inComponent: 0) * 100 + self.musicPicker.selectedRow(inComponent: 1) * 10 + self.musicPicker.selectedRow(inComponent: 2)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "toMusicPlayer" {
    let destVC = segue.destination as! MusicPlayerViewController
    
    destVC.title = selectedMood
    destVC.songID = songIdentification
    } }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        switch component {
        case 0:
            return speedArray.count
        case 1:
            return moodArray.count
        case 2:
        return genreArray.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if component == 0 {
            return speedArray[row]
        }
        else if component == 1 {
            return moodArray[row]
        }
        else {
            return genreArray[row]
        }
        
    }
    
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
