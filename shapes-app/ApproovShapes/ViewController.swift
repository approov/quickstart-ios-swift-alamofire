// MIT License
//
// Copyright (c) 2016-present, Approov Ltd.
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
import ApproovAFSession
import ApproovURLSessionPackage

class ViewController: UIViewController {
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var statusTextView: UILabel!

    // APPROOV NETWORKING LAYERS:
    // We can use BOTH ApproovAFSession (Alamofire) and ApproovURLSessionPackage (URLSession) in the same app
    
    // 1. ApproovAFSession - Alamofire-based networking (extends Alamofire's Session class)
    var approovAlamofireSession: Session?
    
    // 2. ApproovURLSessionPackage - Pure URLSession-based networking (uses URLSession directly)
    var approovURLSession: URLSession?
    
    let urlHello = "https://shapes.approov.io/v1/hello"

    // *** COMMENT OUT IF USING APPROOV API PROTECTION
    static let currentShapesEndpoint = "v1"

    // *** UNCOMMENT IF USING APPROOV API PROTECTION
    //static let currentShapesEndpoint = "v3"

    // *** UNCOMMENT THE LINE BELOW FOR APPROOV USING INSTALLATION MESSAGE SIGNING
    //static let currentShapesEndpoint = "v5"

    let urlShapes = "https://shapes.approov.io/" + currentShapesEndpoint + "/shapes"

    // *** COMMENT IF USING APPROOV SECRETS PROTECTION
    let apiSecretKey = "yXClypapWNHIifHUWmBIyPFAm"

    // *** UNCOMMENT IF USING APPROOV SECRETS PROTECTION
    //let apiSecretKey = "shapes_api_key_placeholder"

    override func viewDidLoad() {
        super.viewDidLoad()

        // IMPORTANT: Both Approov services MUST be initialized with the SAME config string
        // This config string is provided in your Approov onboarding email
        let approovConfig = "<enter-your-config-string-here>"
        
        // ============================================================================
        // STEP 1: Initialize BOTH Approov services with the SAME configuration
        // ============================================================================
        
        do {
            // Initialize ApproovAFSession (Alamofire-based)
            // This service wraps Alamofire's networking and adds Approov protection
            try ApproovAFSession.ApproovService.initialize(config: approovConfig)
            NSLog("✅ ApproovAFSession initialized successfully")
            
            // Initialize ApproovURLSessionPackage (URLSession-based)
            // This service wraps URLSession directly and adds Approov protection
            try ApproovURLSessionPackage.ApproovService.initialize(config: approovConfig)
            NSLog("✅ ApproovURLSessionPackage initialized successfully")
            
        } catch {
            NSLog("❌ Failed to initialize Approov services: \(error)")
        }
        
        // ============================================================================
        // STEP 2: Create instances of both networking layers
        // ============================================================================
        
        // Create ApproovSession (extends Alamofire's Session)
        // Use this for Alamofire-style networking with Approov protection
        approovAlamofireSession = ApproovSession()
        NSLog("✅ ApproovSession (Alamofire) created")
        
        // Create ApproovURLSession (pure URLSession with Approov protection)
        // Use this for traditional URLSession-style networking with Approov protection
        approovURLSession = ApproovURLSessionPackage.ApproovURLSession(configuration: .default)
        NSLog("✅ ApproovURLSession (URLSession) created")
        
        // ============================================================================
        // STEP 3: (Optional) Configure Approov features for BOTH services
        // ============================================================================
        
        // *** UNCOMMENT IF USING APPROOV SECRETS PROTECTION ***
        // This applies to BOTH networking layers since they share the same Approov SDK instance
        //ApproovAFSession.ApproovService.addSubstitutionHeader(header: "Api-Key", prefix: nil)
        //ApproovURLSessionPackage.ApproovService.addSubstitutionHeader(header: "Api-Key", prefix: nil)
        
        // *** UNCOMMENT FOR INSTALLATION MESSAGE SIGNING ***
        //ApproovAFSession.ApproovService.setApproovInterceptorExtensions(
        //    ApproovDefaultMessageSigning().setDefaultFactory(
        //        ApproovDefaultMessageSigning.generateDefaultSignatureParametersFactory()))
        //ApproovURLSessionPackage.ApproovService.setApproovInterceptorExtensions(
        //    ApproovDefaultMessageSigning().setDefaultFactory(
        //        ApproovDefaultMessageSigning.generateDefaultSignatureParametersFactory()))
        
        NSLog("ℹ️ Both networking layers are ready to use!")
        NSLog("ℹ️ - Use approovAlamofireSession for Alamofire-style requests")
        NSLog("ℹ️ - Use approovURLSession for URLSession-style requests")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // ============================================================================
    // EXAMPLE 1: Using ApproovAFSession (Alamofire-based networking)
    // ============================================================================
    // This demonstrates using ApproovSession which extends Alamofire's Session class
    // Perfect for apps already using Alamofire or preferring its fluent API
    @IBAction func checkHello() {
        NSLog("🔵 Using ApproovAFSession (Alamofire) for /hello endpoint")
        
        DispatchQueue.main.async {
            self.statusImageView.image = UIImage(named: "approov")
            self.statusTextView.text = "Checking connectivity via Alamofire..."
        }
        
        // Use ApproovSession just like regular Alamofire Session
        // It automatically adds Approov-Token header and handles pinning
        let task = approovAlamofireSession!.request(urlHello).responseData{ response in
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
                        message = "\(code): OK (via Alamofire)"
                        image = UIImage(named: "hello")
                    }
                }
            }
            NSLog("✅ \(self.urlHello): \(message)")
            DispatchQueue.main.async {
                self.statusImageView.image = image
                self.statusTextView.text = message
            }
        }
        task.resume()
    }

    // ============================================================================
    // EXAMPLE 2: Using ApproovAFSession (Alamofire) for protected endpoint
    // ============================================================================
    // This shows how ApproovSession handles protected endpoints with API keys
    @IBAction func checkShape() {
        NSLog("🔵 Using ApproovAFSession (Alamofire) for /shapes endpoint")
        
        DispatchQueue.main.async {
            self.statusImageView.image = UIImage(named: "approov")
            self.statusTextView.text = "Checking app authenticity via Alamofire..."
        }
        
        // Create request with API key header
        var request = URLRequest(url: URL(string: urlShapes)!)
        request.setValue(apiSecretKey, forHTTPHeaderField: "Api-Key")
        
        // ApproovSession automatically:
        // 1. Adds Approov-Token header
        // 2. Handles certificate pinning
        // 3. Substitutes API key if secrets protection is enabled
        let task = approovAlamofireSession!.request(request).responseData { response in
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
                            message = "\(message) (via Alamofire)"
                        } catch {
                            message = "Invalid JSON from Shapes response"
                        }
                    }
                }
            }
            NSLog("✅ \(self.urlShapes): \(message)")
            DispatchQueue.main.async {
                self.statusImageView.image = image
                self.statusTextView.text = message
            }
        }
        task.resume()
    }
    
    // ============================================================================
    // EXAMPLE 3: Using ApproovURLSessionPackage (URLSession-based networking)
    // ============================================================================
    // This demonstrates using ApproovURLSession for pure URLSession-style networking
    // Perfect for apps that prefer URLSession or need lower-level control
    @IBAction func checkHelloWithURLSession() {
        NSLog("🟢 Using ApproovURLSessionPackage (URLSession) for /hello endpoint")
        
        DispatchQueue.main.async {
            self.statusImageView.image = UIImage(named: "approov")
            self.statusTextView.text = "Checking connectivity via URLSession..."
        }
        
        // Create URLRequest
        var request = URLRequest(url: URL(string: urlHello)!)
        request.httpMethod = "GET"
        
        // Use ApproovURLSession just like regular URLSession
        // It automatically adds Approov-Token header and handles pinning
        let task = approovURLSession!.dataTask(with: request) { data, response, error in
            var message = "unknown networking error"
            var image = UIImage(named: "confused")
            
            if let error = error {
                message = "response: \(error.localizedDescription)"
            } else if let httpResponse = response as? HTTPURLResponse {
                let code = httpResponse.statusCode
                let reason = HTTPURLResponse.localizedString(forStatusCode: code)
                message = "\(code): \(reason)"
                if code == 200 {
                    message = "\(code): OK (via URLSession)"
                    image = UIImage(named: "hello")
                }
            }
            
            NSLog("✅ \(self.urlHello): \(message)")
            DispatchQueue.main.async {
                self.statusImageView.image = image
                self.statusTextView.text = message
            }
        }
        task.resume()
    }
    
    // ============================================================================
    // EXAMPLE 4: Using ApproovURLSessionPackage for protected endpoint
    // ============================================================================
    // This shows how ApproovURLSession handles protected endpoints with API keys
    @IBAction func checkShapeWithURLSession() {
        NSLog("🟢 Using ApproovURLSessionPackage (URLSession) for /shapes endpoint")
        
        DispatchQueue.main.async {
            self.statusImageView.image = UIImage(named: "approov")
            self.statusTextView.text = "Checking app authenticity via URLSession..."
        }
        
        // Create URLRequest with API key header
        var request = URLRequest(url: URL(string: urlShapes)!)
        request.httpMethod = "GET"
        request.setValue(apiSecretKey, forHTTPHeaderField: "Api-Key")
        
        // ApproovURLSession automatically:
        // 1. Adds Approov-Token header
        // 2. Handles certificate pinning
        // 3. Substitutes API key if secrets protection is enabled
        let task = approovURLSession!.dataTask(with: request) { data, response, error in
            var message = "unknown networking error"
            var image = UIImage(named: "confused")
            
            if let error = error {
                message = "response: \(error.localizedDescription)"
            } else if let httpResponse = response as? HTTPURLResponse, let data = data {
                let code = httpResponse.statusCode
                let reason = HTTPURLResponse.localizedString(forStatusCode: code)
                message = "\(code): \(reason)"
                
                if code == 200 {
                    do {
                        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
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
                        message = "\(message) (via URLSession)"
                    } catch {
                        message = "Invalid JSON from Shapes response"
                    }
                }
            }
            
            NSLog("✅ \(self.urlShapes): \(message)")
            DispatchQueue.main.async {
                self.statusImageView.image = image
                self.statusTextView.text = message
            }
        }
        task.resume()
    }
}

