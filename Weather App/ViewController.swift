//
//  ViewController.swift
//  Weather App
//
//  Created by admin on 28/01/2020.
//  Copyright © 2020 AM Kirsch. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController , UITextFieldDelegate{
    
     var imageView: UIImageView!

    @IBOutlet weak var city: UITextField!
    
    //@IBOutlet weak var weather: UILabel!
    
    
    @IBOutlet weak var weatherWKWebView: WKWebView!
    
    let baseUrl = "https://www.weather-forecast.com/locations/"
    
    var url = URL(string: "")
    
    // MARK: - Actions
    @IBAction func enter(_ sender: Any) {
        self.city.resignFirstResponder()
    
        if let name = city.text {
            if name.isEmpty || name == " "{
                print("city name is empty")
                return
            }
            let cityName = fixName(nameToFix: NSString(string: name))
            //  print (cityName)
            self.url = URL(string: self.baseUrl + (cityName as String))
            print ("URL: ", self.url! )
            
            let request = NSMutableURLRequest(url: self.url!)
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: self.completion(data:response:error:))
            task.resume()
        }
    }
    
    func completion(data: Data?, response: URLResponse?, error: Error?) {
        
        if let httpResponse = response as? HTTPURLResponse{
            if httpResponse.statusCode >= 400{
                print("error statusCode, ", httpResponse.statusCode)
                DispatchQueue.main.async {
                    self.city.text = ""
                    self.city.placeholder = "Error in city name, try again"
                }
                return
            }
        }
        
        if error != nil {
            print("error in task!: ", error)
        }else {
            if let unwrappedData = data {
                if let dataString = NSString(data: unwrappedData, encoding: String.Encoding.utf8.rawValue) {
                    print("HERE'S THE DATA: ", dataString)
                    
                    // testing this search
                    let str = String(dataString)
                    
                    let resultFront = str.range(of: "<td ",
                    options: NSString.CompareOptions.literal,
                    range: str.startIndex..<str.endIndex,
                    locale: nil)
                    print("index RESULT FRONT = " , resultFront!)
                    print("text RESULT FRONT = " , str[resultFront!])
                    
                    let resultEnd = str.range(of: "</td>",
                    options: NSString.CompareOptions.literal,
                    range: str.startIndex..<str.endIndex,
                    locale: nil)
                    print("index RESULT END = ", resultEnd!)
                    print("text RESULT END = ",str[resultEnd!])
                    
                    /// now print between both indexes
                    let midrange = resultFront!.lowerBound..<resultEnd!.upperBound
                    print(str[midrange])
                    
                    DispatchQueue.main.async {
                    self.weatherWKWebView.loadHTMLString(String(str[midrange]), baseURL: nil)
                     
                        self.weatherWKWebView.alpha = 0.80
                        
                    }


                }
            }
        }
    }
//    func hasSpace(nameToCheck:NSString) -> Bool{
//        if nameToCheck.contains(" ") {
//            return true
//        }
//        else {
//            return false
//        }
//    }
    func fixName(nameToFix: NSString) -> NSString{
        
        var name = nameToFix.replacingOccurrences(of: " ", with: "-")
        
        while  name.hasPrefix("-") {
            name = String( name.dropFirst() )
            print("removed '-' from name prefix")
        }
        while  name.hasSuffix("-") {
            name = String( name.dropLast() )
            print("removed '-' from name suffix")
        }

        while name.contains("--"){
            name = name.replacingOccurrences(of: "--", with: "-")
            print("removed -- from name")
        }
        
        print(name)
        return NSString(string: name)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) // closes keyboard when touch on screen
        
        // hide webkitview and clear textfield
            weatherWKWebView.alpha = 0.0
            city.text = ""

            
    }
    
    // what to do upon keyboard 'enter'
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.enter(city)
        return true
    }
     
    override func viewDidLoad() {
            super.viewDidLoad()
               assignbackground()
             
          }

    func assignbackground(){
          let background = UIImage(named: "wallpaper.jpg")
          imageView = UIImageView(frame: view.bounds)
          imageView.contentMode =  UIView.ContentMode.scaleAspectFill
          imageView.clipsToBounds = true
          imageView.image = background
          imageView.center = view.center
          view.addSubview(imageView)
          self.view.sendSubviewToBack(imageView)
     
      }


}

