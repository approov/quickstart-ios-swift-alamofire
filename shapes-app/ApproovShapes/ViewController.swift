// MIT License
//
// Copyright (c) 2016-present, Critical Blue Ltd.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files
// (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge,
// publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR
// ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH
// THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import UIKit
import Alamofire


class ViewController: UIViewController {
    
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var statusTextView: UILabel!
    
    var session:Session?
    let httpPrefix = "https://"
    let urlNameCheck = "shapes.approov.io/v1/hello"
    static let currentShapesEndpoint = "v1"    // Current shapes endpoint
    let urlNameVerify = "shapes.approov.io/" + currentShapesEndpoint + "/shapes"
    //*** CHANGE THE LINE BELOW FOR APPROOV USING SECRETS PROTECTION TO `shapes_api_key_placeholder`
    let apiSecretKey = "yXClypapWNHIifHUWmBIyPFAm"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // check unprotected hello endpoint

    @IBAction func checkHello() {
        // Display busy screen
        DispatchQueue.main.async {
            self.statusImageView.image = UIImage(named: "approov")
            self.statusTextView.text = "Checking connectivity..."
        }
        // Create the session if not creeated
        initializeSession()
        let task = session!.request(httpPrefix + urlNameCheck).responseData{ response in
            let message: String
            let image: UIImage?
            
            // analyze response
            if response.error != nil {
                // other networking failure
                message = "Unknown networking error"
                image = UIImage(named: "confused")
            } else {
                if let httpResponse = response.response {
                    let code = httpResponse.statusCode
                    if code == 200 {
                        // successful http response
                        message = "\(code): OK"
                        image = UIImage(named: "hello")
                    } else {
                        // unexpected http response
                        let reason = HTTPURLResponse.localizedString(forStatusCode: code)
                        message = "\(code): \(reason)"
                        image = UIImage(named: "confused")
                    }
                } else {
                    // not an http response
                    message = "Networking error: \(response.error!.localizedDescription)"
                    image = UIImage(named: "confused")
                }
            }
            
            NSLog("\(self.httpPrefix + self.urlNameCheck): \(message)")
            
            // Display the image on screen using the main queue
            DispatchQueue.main.async {
                self.statusImageView.image = image
                self.statusTextView.text = message
            }
        }
        
        task.resume()
    }
    
    // check Approov-protected shapes endpoint

    @IBAction func checkShape() {
        // Display busy screen
        DispatchQueue.main.async {
            self.statusImageView.image = UIImage(named: "approov")
            self.statusTextView.text = "Checking app authenticity..."
        }
        // Create the session
        initializeSession()
        var request = URLRequest(url: URL(string: httpPrefix + urlNameVerify)!)
        request.setValue(apiSecretKey, forHTTPHeaderField: "Api-Key")
        let task = session!.request(request).responseData { response in
            var message: String
            let image: UIImage?
            
            // analyze response
            if response.error != nil {
                // other networking failure
                message = "Networking error: \(response.error!.localizedDescription)"
                image = UIImage(named: "confused")
            } else {
                if let httpResponse = response.response {
                let code = httpResponse.statusCode
                if code == 200 {
                    // successful http response
                    message = "\(code): Approoved!"
                    // unmarshal the JSON response
                    do {
                        let jsonObject = try JSONSerialization.jsonObject(with: response.data!, options: [])
                        let jsonDict = jsonObject as? [String: Any]
                        let shape = (jsonDict!["shape"] as? String)!.lowercased()
                        switch shape {
                        case "circle":
                            image = UIImage(named: "circle")
                        case "rectangle":
                            image = UIImage(named: "rectangle")
                        case "square":
                            image = UIImage(named: "square")
                        case "triangle":
                            image = UIImage(named: "triangle")
                        default:
                            message = "\(code): Approoved: unknown shape '\(shape)'"
                            image = UIImage(named: "confused")
                        }
                    } catch {
                        message = "\(code): Invalid JSON from Shapes response"
                        image = UIImage(named: "confused")
                    }
                } else {
                    // unexpected http response
                    let reason = HTTPURLResponse.localizedString(forStatusCode: code)
                    message = "\(code): \(reason)"
                    image = UIImage(named: "confused")
                }
            } else {
                // not an http response
                message = "Not an HTTP response"
                image = UIImage(named: "confused")
            }
        
            NSLog("\(self.httpPrefix + self.urlNameVerify): \(message)")

            // Display the image on screen using the main queue
            DispatchQueue.main.async {
                self.statusImageView.image = image
                self.statusTextView.text = message
            }
        }
    }
    
    task.resume()

    }
    
    // Create the session only if it does not exist yet
    func initializeSession(){
        if (session == nil) {
            // *** COMMENT OUT IF USING APPROOV APPROOV
            session = Session()
            // *** UNCOMMENT TO USE APPROOV
            //session = ApproovSession()
            //try! ApproovService.initialize(config: "<enter-you-config-string-here>")
            
            // *** UNCOMMENT THE LINE BELOW FOR APPROOV USING SECRETS PROTECTION ***
            //ApproovService.addSubstitutionHeader(header: "Api-Key", prefix: nil)
        }
    }
}

