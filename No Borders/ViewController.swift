//
//  ViewController.swift
//  No Borders
//
//  Created by Jeremy Rodriguez on 10/8/17.
//  Copyright © 2017 Jeremy Rodriguez. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SPTAudioStreamingPlaybackDelegate, SPTAudioStreamingDelegate {
    
    var auth = SPTAuth.defaultInstance()!
    
    var session:SPTSession!
    
    var player: SPTAudioStreamingController?
    
    var loginUrl: URL?
    
    func setup () {
        SPTAuth.defaultInstance().clientID = "b61aefba4ab34a7dbef18e3841f46a72"
        SPTAuth.defaultInstance().redirectURL = URL(string: "no-borders-app-login://callback")
        SPTAuth.defaultInstance().requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope, SPTAuthPlaylistModifyPublicScope, SPTAuthPlaylistModifyPrivateScope]
        loginUrl = SPTAuth.defaultInstance().spotifyWebAuthenticationURL()
    }
    
    @IBOutlet weak var loginBtnPressed: UIButton!
    
    @IBAction func loginBtnPressed(_ sender: Any)
    {
        if UIApplication.shared.openURL(loginUrl!) {
            
            if auth.canHandle(auth.redirectURL) {
                
                // To do - build in error handling
               
                
            }
            
        }
        

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        //let name:NSNotification.Name = NSNotification.Name("noBorders")
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.updateAfterFirstLogin), name: Notification.Name(rawValue: "loginSuccessfull"), object: nil)
        
        //NotificationCenter.default.addObserver(self, selector: #selector(ViewController.updateAfterFirstLogin), name: name , object: nil)
        
        //NotificationCenter.default.addObserver(self, selector: #selector(ViewController.updateAfterFirstLogin))
    }
    
    @objc func updateAfterFirstLogin () {
        
        // 5- Add session to User Defaults
        
        let userDefaults = UserDefaults.standard
        

        
        if let sessionObj:AnyObject = userDefaults.object(forKey: "SpotifySession") as AnyObject? {
            
            let sessionDataObj = sessionObj as! Data
            
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            
            self.session = firstTimeSession
            
            initializePlayer(authSession: session)
        }
        
        let sessionData = NSKeyedArchiver.archivedData(withRootObject: session!)
        
        userDefaults.set(sessionData, forKey: "SpotifySession")
        
        userDefaults.synchronize()
        
    }
    
    func initializePlayer(authSession:SPTSession){
        
        if self.player == nil {
            
            self.player = SPTAudioStreamingController.sharedInstance()
            
            self.player!.playbackDelegate = self as SPTAudioStreamingPlaybackDelegate
            
            self.player!.delegate = self as SPTAudioStreamingDelegate
            
            try! player!.start(withClientId: auth.clientID)
            
            // log to console
            print(auth.clientID)
            
            self.player!.login(withAccessToken: authSession.accessToken)
            
            // log to console
            print(authSession.accessToken)
            
            // TODO: remove if it doesn't work
            print("logged in")
            
            //redirect to songlist view controller
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SongList")
            self.present(vc!,animated: true, completion: nil)
            
            
            //https://open.spotify.com/track/5XQMr19TL7Mfksq9zihbOu
            //"spotify:track:5XQMr19TL7Mfksq9zihbOu"
            
//            self.player?.playSpotifyURI("https://open.spotify.com/track/5XQMr19TL7Mfksq9zihbOu", startingWith: 0, startingWithPosition: 0, callback: { (error) in
//
//                if (error != nil) {
//                    
//                    print("playing!")
//
//                }
//
//            })  //58s6EuEYJdlb0kO7awm3Vp
            
            //let vc = self.storyboard?.instantiateViewController(withIdentifier: "SongList")
            //self.present(vc!,animated: true, completion: nil)
            
        }
        
    }
    
//    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
//
//        // after a user authenticates a session, the SPTAudioStreamingController is then initialized and this method called
//
//        print("logged in")
//
//        self.player?.playSpotifyURI("spotify:track:5XQMr19TL7Mfksq9zihbOu", startingWith: 0, startingWithPosition: 0, callback: { (error) in
//
//            if (error != nil) {
//
//                print("playing!")
    
           // }
            
//        })
//
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    
        }
}
