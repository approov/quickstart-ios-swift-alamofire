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

// *** UNCOMMENT IF USING APPROOV
//import ApproovSession

class ViewController: UIViewController {
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var statusTextView: UILabel!
    
    var session: Session?
    let urlHello = "https://shapes.approov.io/v1/hello"
    
    // *** COMMENT OUT IF USING APPROOV API PROTECTION
    static let currentShapesEndpoint = "v1"
    
    // *** UNCOMMENT IF USING APPROOV API PROTECTION
    //static let currentShapesEndpoint = "v3"
    
    let urlShapes = "https://shapes.approov.io/" + currentShapesEndpoint + "/shapes"
    
    // *** COMMENT IF USING APPROOV SECRETS PROTECTION
    let apiSecretKey = "yXClypapWNHIifHUWmBIyPFAm"
    
    // *** UNCOMMENT IF USING APPROOV SECRETS PROTECTION
    //let apiSecretKey = "shapes_api_key_placeholder"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // *** COMMENT OUT IF USING APPROOV
        session = Session()
        
        // *** UNCOMMENT TO USE APPROOV
        //session = ApproovSession()
        //try! ApproovService.initialize(config: "<enter-you-config-string-here>")
        
        // *** UNCOMMENT IF USING APPROOV SECRETS PROTECTION
        //ApproovService.addSubstitutionHeader(header: "Api-Key", prefix: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // check unprotected hello endpoint
    @IBAction func checkHello() {
        DispatchQueue.main.async {
            self.statusImageView.image = UIImage(named: "approov")
            self.statusTextView.text = "Checking connectivity..."
        }
        let task = session!.request(urlHello).responseData{ response in
            var message = "unknown networking error"
            var image = UIImage(named: "confused")
            if response.error != nil {
                message = "response: \(response.error!.localizedDescription)"
            } else {
                if let httpResponse = response.response {
                    let code = httpResponse.statusCode
                    let reason = HTTPURLResponse.localizedString(forStatusCode: code)
                    message = "\(code): \(reason)"
                    if code == 200 {
                        message = "\(code): OK"
                        image = UIImage(named: "hello")
                    }
                }
            }
            NSLog("\(self.urlHello): \(message)")
            DispatchQueue.main.async {
                self.statusImageView.image = image
                self.statusTextView.text = message
            }
        }
        task.resume()
    }
    
    // check shapes endpoint
    @IBAction func checkShape() {
        DispatchQueue.main.async {
            self.statusImageView.image = UIImage(named: "approov")
            self.statusTextView.text = "Checking app authenticity..."
        }
        var request = URLRequest(url: URL(string: urlShapes)!)
        request.setValue(apiSecretKey, forHTTPHeaderField: "Api-Key")
        let task = session!.request(request).responseData { response in
            var message = "unknown networking error"
            var image = UIImage(named: "confused")
            if response.error != nil {
                message = "response: \(response.error!.localizedDescription)"
            } else {
                if let httpResponse = response.response {
                    let code = httpResponse.statusCode
                    let reason = HTTPURLResponse.localizedString(forStatusCode: code)
                    message = "\(code): \(reason)"
                    if code == 200 {
                        do {
                            let jsonObject = try JSONSerialization.jsonObject(with: response.data!, options: [])
                            let jsonDict = jsonObject as? [String: Any]
                            message = (jsonDict!["status"] as? String)!
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
                                    message = "\(code): unknown shape '\(shape)'"
                            }
                        } catch {
                            message = "Invalid JSON from Shapes response"
                        }
                    }
                }
            }
            NSLog("\(self.urlShapes): \(message)")
            DispatchQueue.main.async {
                self.statusImageView.image = image
                self.statusTextView.text = message
            }
        }
        task.resume()
    }
}
