//
//  SongListView.swift
//  No Borders
//
//  Created by Jeremy Rodriguez on 12/3/17.
//  Copyright © 2017 Jeremy Rodriguez. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation

var player = AVAudioPlayer()

struct post {
    let mainImage : UIImage!
    let name : String!
   let previewURL : String!
}

class SongListView: UITableViewController,UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    
    var posts = [post]()
    //var searchURL = "https://api.spotify.com/v1/search?q=Shawn+Mendes&type=track,artist,album&offset=20"
    
    
    var searchURL = String()
    
    //https://open.spotify.com/track/5XQMr19TL7Mfksq9zihbOu
    //var searchURL = "https://open.spotify.com/search/results/shawn"
    
    
    typealias JSONStandard = [String : AnyObject]
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let keywords = searchBar.text
        let finalKeywords = keywords?.replacingOccurrences(of: " ", with: "+")
        
        searchURL = "https://api.spotify.com/v1/search?q=\(finalKeywords!)&type=track&offset=20"
        
        callAlamo(url: searchURL)
        
        self.view.endEditing(true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let keys = SPTAuth.defaultInstance().clientID //"<MY_APPLICATION_KEYS>"
        
        let url = NSURL(string: "https://accounts.spotify.com/api/token")
        
        let session = URLSession.shared
        
        let request = NSMutableURLRequest(url: url! as URL)
        
        request.httpMethod = "POST"
        
        request.setValue("Basic \(String(describing: keys))", forHTTPHeaderField: "Authorization")
        
        request.setValue("client_credentials", forHTTPHeaderField: "grant_type")
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            guard let _: Data = data, let _: URLResponse = response, error == nil else {
                
                print(error!)
                return
                
            }
            
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("Data: \(dataString!)")
            
            self.parseData1(JSONData: data!)
            
        }
        
        task.resume()
        
        
        // call
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //callAlamo(url: searchURL)
        // self.tableView.reloadData()
    }
    
    func callAlamo(url : String){
        
        let headers = ["Authorization: Bearer \(accessToken)"]
        
        var urlRequest = URLRequest(url:URL(string: url)!)
        urlRequest.httpMethod = HTTPMethod.get.rawValue
        
        accessToken = "BQAiuJ1ZYhPN62KE_g1BLrH22-pTK1E5s4Dkm3Jr57dCCuIaAKju3dYkbFNq9Hvyp2iSYkcJK2hhFDkpH1uzsCtPDqCyWFTEd5uPZVvVVEaUp3qvivT-38veiRGXGaS6BCaFCpJOz0One_aaZ1H3D8Kp6rfyUlpq36E"
        
        //"BQDJg3FXVBPzWtYjkL7ZpLLtTr7PtofFLiKMUxEFtSRbgQVcGy8_cruaQhk0HlB_55mwtrl9z74aj6TEt6dMCCk3IbUFFZtpSw-zvBk6FrjbhGcwOu9DbWGTNAUfiWb-uYvTufe2b87Z8hjFwFj2WYF2N7JrDbHIVMU"
        
        print("Token: \(accessToken)")
        
        //Accept: application/json
        
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        debugPrint("URL Request: \(urlRequest)")
        
        Alamofire.request(urlRequest).responseJSON(completionHandler: {
            response in
            print ("url call starts")
            debugPrint(response)
            print(response.data!.description)
            self.parseData(JSONData: response.data!)
            print ("url call ends")
        })
    }
    
    func parseData(JSONData : Data) {
        do {
            var readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! JSONStandard
            print(JSONData)
            
            if let tracks = readableJSON["tracks"] as? JSONStandard{
                
                if let items = tracks["items"] as? NSArray {
                    
                    //for item in items {
                    for i in 0..<items.count{
                        let item = items[i] as! JSONStandard
                        
                        let name = item["name"] as! String
                        
                        //Song Preview, song that works starts with the word Sunny!
                        let previewURL = item["preview_url"] as? String
                            
                        if let album = item["album"] as? JSONStandard{
                            
                            if let images = album["images"] as? [JSONStandard]{
                                let imageData = images[0]
                                let mainImageURL = URL(string: imageData["url"] as! String)
                                let mainImageData = NSData(contentsOf: mainImageURL!)
                                
                                let mainImage = UIImage(data: mainImageData! as Data)
//                                let name = album["name"] as! String
                                posts.append(post.init(mainImage: mainImage, name: name, previewURL: previewURL))
                                //spotifySong: spotifySong
                                self.tableView.reloadData()
                            
                            }
                        
                        }
                    }
                    
                }
            }
        }
        catch{
            print(error)
        }
    }
    
    var accessToken = "BQAiuJ1ZYhPN62KE_g1BLrH22-pTK1E5s4Dkm3Jr57dCCuIaAKju3dYkbFNq9Hvyp2iSYkcJK2hhFDkpH1uzsCtPDqCyWFTEd5uPZVvVVEaUp3qvivT-38veiRGXGaS6BCaFCpJOz0One_aaZ1H3D8Kp6rfyUlpq36E"
    
    func parseData1(JSONData : Data) {
        
        do {
            var readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! JSONStandard
            
            if let token = readableJSON["access_token"] as? String {
                
                accessToken = token
                
            }
            
            print("Access Token: \(accessToken)")
            
            //updateTokenInFirebase()
            
        }
        catch{
            print(error)
        }
        
        //
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        let mainImageView = cell?.viewWithTag(2) as! UIImageView

        mainImageView.image = posts[indexPath.row].mainImage
        
        
        let mainLabel = cell?.viewWithTag(1) as! UILabel

        mainLabel.text = posts[indexPath.row].name
        
        return cell!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = self.tableView.indexPathForSelectedRow?.row
        
        let vc = segue.destination as! AudioVC
        
        vc.image = posts[indexPath!].mainImage
        
        vc.mainSongTitle = posts[indexPath!].name
        
        vc.mainPreviewURL = posts[indexPath!].previewURL
    }
    
//        func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
//
//            // after a user authenticates a session, the SPTAudioStreamingController is then initialized and this method called
//
//            print("logged in")
//
//            self.player?.playSpotifyURI(, startingWith: 0, startingWithPosition: 0, callback: { (error) in
//
//                if (error != nil) {
//
//                    print("playing!")
//
//     }
//
//            })
//
//        }
    
}


