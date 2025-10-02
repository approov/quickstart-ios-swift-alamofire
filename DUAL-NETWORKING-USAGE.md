# Using Both ApproovAFSession and ApproovURLSessionPackage Together

This guide demonstrates how to use **both** Approov networking layers in the same iOS application. The example implementation is in `shapes-app/ApproovShapes/ViewController.swift`.

## Overview

Approov provides two networking protection layers that can be used **simultaneously** in the same application:

1. **ApproovAFSession** - Alamofire-based networking wrapper
2. **ApproovURLSessionPackage** - Native URLSession-based wrapper

Both layers share the same underlying Approov SDK, so they **must be initialized with the same configuration string**.

## Why Use Both?

You might want to use both networking layers in the same app when:

- **Migrating from Alamofire to URLSession** (or vice versa) - gradually transition your networking code
- **Third-party dependencies** - some libraries use URLSession while you prefer Alamofire
- **Team preferences** - different parts of your codebase use different networking approaches
- **Performance optimization** - use URLSession for simple requests, Alamofire for complex ones
- **Testing and comparison** - evaluate both approaches before committing to one

## Initialization

Both services **MUST** be initialized with the **SAME** configuration string:

```swift
import ApproovAFSession
import ApproovURLSessionPackage

// In viewDidLoad() or app initialization:
let approovConfig = "<enter-your-config-string-here>"

do {
    // Initialize ApproovAFSession (Alamofire-based)
    try ApproovAFSession.ApproovService.initialize(config: approovConfig)
    
    // Initialize ApproovURLSessionPackage (URLSession-based)
    try ApproovURLSessionPackage.ApproovService.initialize(config: approovConfig)
    
} catch {
    print("Failed to initialize Approov services: \(error)")
}
```

### Important Notes:

- ✅ Use the **same config string** for both initializations
- ✅ Initialize **both services** even if you only plan to use one initially
- ✅ Both services share the same Approov SDK instance internally
- ⚠️ Initializing with different config strings will cause an error

## Creating Network Session Instances

After initialization, create instances of both networking layers:

```swift
// Create ApproovSession (Alamofire-based)
let approovAlamofireSession = ApproovSession()

// Create ApproovURLSession (URLSession-based)
let approovURLSession = ApproovURLSessionPackage.ApproovURLSession()
```

## Usage Examples

### Example 1: Alamofire-Style Request (ApproovAFSession)

```swift
// Simple GET request using ApproovSession
approovAlamofireSession.request("https://api.example.com/data")
    .responseData { response in
        switch response.result {
        case .success(let data):
            print("Success: \(data)")
        case .failure(let error):
            print("Error: \(error)")
        }
    }
    .resume()
```

### Example 2: URLSession-Style Request (ApproovURLSessionPackage)

```swift
// Simple GET request using ApproovURLSession
var request = URLRequest(url: URL(string: "https://api.example.com/data")!)
request.httpMethod = "GET"

let task = approovURLSession.dataTask(with: request) { data, response, error in
    if let error = error {
        print("Error: \(error)")
        return
    }
    
    if let data = data {
        print("Success: \(data)")
    }
}
task.resume()
```

### Example 3: Request with Headers (Alamofire)

```swift
// Request with custom headers using ApproovSession
var request = URLRequest(url: URL(string: "https://api.example.com/protected")!)
request.setValue("my-api-key", forHTTPHeaderField: "Api-Key")

approovAlamofireSession.request(request).responseData { response in
    // ApproovSession automatically adds:
    // - Approov-Token header
    // - Certificate pinning
    // - API key substitution (if secrets protection enabled)
    
    // Handle response...
}
```

### Example 4: Request with Headers (URLSession)

```swift
// Request with custom headers using ApproovURLSession
var request = URLRequest(url: URL(string: "https://api.example.com/protected")!)
request.httpMethod = "GET"
request.setValue("my-api-key", forHTTPHeaderField: "Api-Key")

let task = approovURLSession.dataTask(with: request) { data, response, error in
    // ApproovURLSession automatically adds:
    // - Approov-Token header
    // - Certificate pinning
    // - API key substitution (if secrets protection enabled)
    
    // Handle response...
}
task.resume()
```

## Configuring Approov Features

Since both networking layers share the same Approov SDK, you need to configure features for **both services**:

### Secrets Protection

```swift
// Enable secrets protection for BOTH services
ApproovAFSession.ApproovService.addSubstitutionHeader(header: "Api-Key", prefix: nil)
ApproovURLSessionPackage.ApproovService.addSubstitutionHeader(header: "Api-Key", prefix: nil)
```

### Token Binding

```swift
// Enable token binding for BOTH services
ApproovAFSession.ApproovService.setBindingHeader(header: "Authorization")
ApproovURLSessionPackage.ApproovService.setBindingHeader(header: "Authorization")
```

### Custom Approov Token Header

```swift
// Set custom token header for BOTH services
ApproovAFSession.ApproovService.setApproovHeader(header: "Authorization", prefix: "Bearer ")
ApproovURLSessionPackage.ApproovService.setApproovHeader(header: "Authorization", prefix: "Bearer ")
```

### Development Key

```swift
// Set development key for BOTH services (testing only)
ApproovAFSession.ApproovService.setDevKey(devKey: "your-dev-key")
ApproovURLSessionPackage.ApproovService.setDevKey(devKey: "your-dev-key")
```

### Installation Message Signing

```swift
// Enable message signing for BOTH services
ApproovAFSession.ApproovService.setApproovInterceptorExtensions(
    ApproovDefaultMessageSigning().setDefaultFactory(
        ApproovDefaultMessageSigning.generateDefaultSignatureParametersFactory()))

ApproovURLSessionPackage.ApproovService.setApproovInterceptorExtensions(
    ApproovDefaultMessageSigning().setDefaultFactory(
        ApproovDefaultMessageSigning.generateDefaultSignatureParametersFactory()))
```

## Complete Implementation Example

See `shapes-app/ApproovShapes/ViewController.swift` for a complete working example showing:

1. ✅ Initialization of both services with the same config
2. ✅ Creating instances of both networking layers
3. ✅ Making requests using ApproovAFSession (Alamofire)
4. ✅ Making requests using ApproovURLSessionPackage (URLSession)
5. ✅ Handling responses from both networking layers

The ViewController includes four example methods:

- `checkHello()` - ApproovAFSession example for simple endpoint
- `checkShape()` - ApproovAFSession example for protected endpoint with API key
- `checkHelloWithURLSession()` - ApproovURLSessionPackage example for simple endpoint
- `checkShapeWithURLSession()` - ApproovURLSessionPackage example for protected endpoint with API key

## Key Differences Between the Two Layers

| Feature | ApproovAFSession | ApproovURLSessionPackage |
|---------|------------------|--------------------------|
| **Based on** | Alamofire framework | Native URLSession |
| **API Style** | Fluent/chaining | Delegate/callback |
| **Dependencies** | Requires Alamofire | No external dependencies |
| **Use Case** | Complex networking, existing Alamofire code | Simple requests, native iOS code |
| **Session Type** | `ApproovSession` (extends `Session`) | `ApproovURLSession` (extends `URLSession`) |

## What Happens Behind the Scenes

Both networking layers provide the same Approov protection:

1. **Token Injection** - Automatically adds `Approov-Token` header to requests
2. **Certificate Pinning** - Validates server certificates against Approov's dynamic pins
3. **Secrets Protection** - Substitutes placeholder API keys with secure values from Approov cloud
4. **Token Binding** - Binds tokens to specific request data to prevent token theft
5. **Attestation** - Validates app authenticity before making network requests

## Best Practices

1. ✅ **Initialize both services at app startup** - Even if you only use one initially
2. ✅ **Use the same config string** - Critical for proper operation
3. ✅ **Configure features for both** - Apply settings to both services
4. ✅ **Choose the right layer for each request** - Use Alamofire for complex, URLSession for simple
5. ✅ **Handle errors consistently** - Both layers can throw Approov-specific errors
6. ✅ **Test with both layers** - Ensure your app works correctly with both networking approaches

## Troubleshooting

### Error: "Configuration mismatch"
- **Cause**: Initialized services with different config strings
- **Solution**: Use the exact same config string for both initializations

### Error: "Service not initialized"
- **Cause**: Attempting to use networking layer before initialization
- **Solution**: Call `initialize()` for both services before creating session instances

### Different behavior between layers
- **Cause**: Features configured for one service but not the other
- **Solution**: Apply all configuration calls to both services

## Migration Path

If you want to gradually migrate from one layer to another:

1. Initialize both services with the same config
2. Keep existing code using current networking layer
3. New features use the target networking layer
4. Gradually refactor old code to new layer
5. Eventually remove unused layer (optional)

## Additional Resources

- [ApproovAFSession Documentation](README.md)
- [API Protection Guide](API-PROTECTION.md)
- [Secrets Protection Guide](SECRETS-PROTECTION.md)
- [Alamofire Options](ALAMOFIRE-OPTIONS.md)
- [Reference Documentation](REFERENCE.md)

## Summary

Using both ApproovAFSession and ApproovURLSessionPackage together is:

- ✅ **Supported** - Both layers are designed to work together
- ✅ **Safe** - Share the same underlying Approov SDK
- ✅ **Flexible** - Use the best tool for each networking need
- ✅ **Simple** - Just initialize both with the same config string

The key requirement is to **initialize both services with the same configuration string** and **apply configuration changes to both services** to ensure consistent behavior as they both depend on the same Approov SDK.
