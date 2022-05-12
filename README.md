# Approov Quickstart: iOS Swift Alamofire
 
This quickstart is written specifically for native iOS apps that are written in Swift and using [Alamofire](https://github.com/Alamofire/Alamofire) for making the API calls that you wish to protect with Approov. If this is not your situation then check if there is a more relevant quickstart guide available.
 
This quickstart provides the basic steps for integrating Approov into your app. A more detailed step-by-step guide using a [Shapes App Example](https://github.com/approov/quickstart-ios-swift-alamofire/blob/master/SHAPES-EXAMPLE.md) is also available.
 
To follow this guide you should have received an onboarding email for a trial or paid Approov account.
 
## ADDING APPROOV SERVICE DEPENDENCY
The Approov integration is available via the [`Swift Package Manager`](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app). This allows inclusion into the project by simply specifying a dependency in the `Add Package Dependency` Xcode option:
 
![Add Package Dependency](readme-images/add-package-repository.png)
 
This package is actually an open source wrapper layer that allows you to easily use Approov with `Alamofire`. This has a further dependency to the closed source [Approov SDK](https://github.com/approov/approov-ios-sdk).
 
## USING APPROOV SERVICE
The `ApproovSession` class extends the [Session](https://alamofire.github.io/Alamofire/Classes/Session.html) class defined by Alamofire and handles connections by providing pinning and including an additional ApproovSDK attestation call. The simplest way to use the `ApproovSession` class is to find and replace all the `Session` instances with `ApproovSession`.
 
```swift
try! ApproovService.initialize("<enter-your-config-string-here>")
let session = ApproovSession()
```
 
Additionally, the Approov SDK wrapper class, `ApproovService` needs to be initialized before using the `ApproovSession` object. The `<enter-your-config-string-here>` is a custom string that configures your Approov account access. This will have been provided in your Approov onboarding email (it will be something like `#123456#K/XPlLtfcwnWkzv99Wj5VmAxo4CrU267J1KlQyoz8Qo=`).
 
For API domains that are configured to be protected with an Approov token, this adds the `Approov-Token` header and pins the connection. This may also substitute header values when using secrets protection.

Please note on the above code, the `ApproovService` is instantiated and might throw a `configurationError`exception if the configuration string provided as parameter is different than the already used one to initialize previously. If the underlying Appproov SDK can not be initialized because of a permanent issue, an `initializationFailure` is returned which should be considered permanent. Failure to initialise the `ApproovService` should cancel any network requests since lack of initialization is generally considered fatal.
 
 
## ERROR MESSAGES
The `ApproovService` provides specific type errors when using some functions to provide additional information about the type of error:
 
* `permanentError` might be due to a feature not enabled using the command line
* `rejectionError` an attestation has been rejected, the `ARC` and `rejectionReasons` may contain specific device information that would help troubleshooting
* `networkingError` generally can be retried since it can be temporary network issue
* `pinningError` is a certificate error
* `configurationError` a configuration feature is disabled or wrongly configured (i.e. attempting to initialize with different config)
* `initializationFailure` the ApproovService failed to be initialized
 
## CHECKING IT WORKS
Initially you won't have set which API domains to protect, so the interceptor will not add anything. It will have called Approov though and made contact with the Approov cloud service. You will see logging from Approov saying `UNKNOWN_URL`.
 
Your Approov onboarding email should contain a link allowing you to access [Live Metrics Graphs](https://approov.io/docs/latest/approov-usage-documentation/#metrics-graphs). After you've run your app with Approov integration you should be able to see the results in the live metrics within a minute or so. At this stage you could even release your app to get details of your app population and the attributes of the devices they are running upon.
 
## NEXT STEPS
To actually protect your APIs there are some further steps. Approov provides two different options for protection:
 
* [API PROTECTION](https://github.com/approov/quickstart-ios-swift-alamofire/blob/master/API-PROTECTION.md): You should use this if you control the backend API(s) being protected and are able to modify them to ensure that a valid Approov token is being passed by the app. An [Approov Token](https://approov.io/docs/latest/approov-usage-documentation/#approov-tokens) is short lived cryptographically signed JWT proving the authenticity of the call.
 
* [SECRETS PROTECTION](https://github.com/approov/quickstart-ios-swift-alamofire/blob/master/SECRETS-PROTECTION.md): If you do not control the backend API(s) being protected, and are therefore unable to modify it to check Approov tokens, you can use this approach instead. It allows app secrets, and API keys, to be protected so that they no longer need to be included in the built code and are only made available to passing apps at runtime.
 
Note that it is possible to use both approaches side-by-side in the same app, in case your app uses a mixture of 1st and 3rd party APIs.

## BITCODE SUPPORT

[Bitcode](https://approov.io/docs/latest/approov-usage-documentation/#bitcode-mode-management) is supported by Approov but requires command line option to be specified when registering apps.

```
approov registration -add YourApp.ipa -bitcode
```

In order to use a bitcode enabled Approov service, you can still use the swift package repository at `https://github.com/approov/approov-service-alamofire.git` but append the `-bitcode` suffix to the required SDK version, i.e you could use `3.0.0-bitcode` as a version in the Swift PM window.


## ALAMOFIRE FEATURES

Additional optional features regarding `Alamofire` are desribed [here](https://github.com/approov/quickstart-ios-swift-alamofire/blob/master/ALAMOFIRE-OPTIONS.md)