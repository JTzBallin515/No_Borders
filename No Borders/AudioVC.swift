//
//  AudioVC.swift
//  No Borders
//
//  Created by Jeremy Rodriguez on 12/4/17.
//  Copyright © 2017 Jeremy Rodriguez. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class AudioVC: UIViewController{
    
    var image = UIImage()
    var mainSongTitle = String()
    var mainPreviewURL = String()
    
    @IBOutlet weak var playpausebtn: UIButton!
    @IBOutlet weak var background: UIImageView!
    
    @IBOutlet weak var mainImageView: UIImageView!
    
    @IBOutlet weak var songTitle: UILabel!
    
    override func viewDidLoad() {
        
        songTitle.text = mainSongTitle
        
        background.image = image
        
        mainImageView.image = image
        
      downloadFileFromURL(url: URL(string : mainPreviewURL)!)
        
        playpausebtn.setTitle("Pause", for: .normal)
    }
    
    func downloadFileFromURL (url : URL){
        var downloadTask = URLSessionDownloadTask()
        downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: {
            customURL, response, error in

            self.play(url: customURL!)
        })

        downloadTask.resume()

    }

    func play(url: URL) {
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.play()
    }
        catch{
            print(error)
        }
}
    
    @IBAction func pauseplay(_ sender: Any) {
        if player.isPlaying {
            player.pause()
            playpausebtn.setTitle("Play", for: .normal)
        }
        else{
            player.play()
            playpausebtn.setTitle("Pause", for: .normal)
            
        }
    }
}
