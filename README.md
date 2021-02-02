# Approov Quickstart: iOS Swift Alamofire

This quickstart is written specifically for native iOS apps that are written in Swift and using Alamofire for making the API calls that you wish to protect with Approov. If this is not your situation then check if there is a more relevant quickstart guide available.

## WHAT YOU WILL NEED
* Access to a trial or paid Approov account
* The `approov` command line tool [installed](https://approov.io/docs/latest/approov-installation/) with access to your account
* [Xcode](https://developer.apple.com/xcode/) version 12 installed (version 12.3 is used in this guide)
* The contents of the folder containing this README
* An Apple mobile device with iOS 10 or higher
* [Cocoapods](https://cocoapods.org) package manager installed (version 1.10.1 is used in this guide)

## WHAT YOU WILL LEARN
* How to integrate Approov into a real app in a step by step fashion
* How to register your app to get valid tokens from Approov
* A solid understanding of how to integrate Approov into your own Swift app that uses Alamofire
* Some pointers to other Approov features

## OBTAINING ALAMOFIRE FRAMEWORK

We include [Alamofire](https://github.com/Alamofire/Alamofire) as a cocoapod package dependency and in order to satisfy the dependency,
using the command line, locate the `shapes-app` folder and set it as a working directory. Execute the command `pod install`:
```
$ pod install
Analyzing dependencies
Downloading dependencies
Installing Alamofire (5.1.0)
Generating Pods project
Integrating client project
Pod installation complete! There is 1 dependency from the Podfile and 1 total pod installed.
```
This downloads the Alamofire framework and updates the directory structure. Please, do not use the project file `ApproovShapes.xcodeproj`. Instead always
use the workspace file `ApproovShapes.xcworkspace`.

## RUNNING THE SHAPES APP WITHOUT APPROOV

Open the `ApproovShapes.xcworkspace` project in the `shapes-app` folder using `File->Open` in Xcode. Ensure the `ApproovShapes` project is selected at the top of Xcode's project explorer panel.

Select your codesigning certificate in the `Signing & Capabilities` tab and run the application on your prefered device. Note that if you have difficulties codesigning the application, change the `Bundle Identifier` in the General tab to contain a unique prefix.

![Codesign App](readme-images/codesign-app.png)

Once the application is running you will see two buttons:

<p>
    <img src="readme-images/app-startup.png" width="256" title="Shapes App Startup">
</p>

Click on the `Hello` button and you should see this:

<p>
    <img src="readme-images/hello-okay.png" width="256" title="Hello Okay">
</p>

This checks the connectivity by connecting to the endpoint `https://shapes.approov.io/v1/hello`. Now press the `Shape` button and you will see this:

<p>
    <img src="readme-images/shapes-bad.png" width="256" title="Shapes Bad">
</p>

This contacts `https://shapes.approov.io/v2/shapes` to get the name of a random shape. It gets the status code 400 (`Bad Request`) because this endpoint is protected with an Approov token. Next, you will add Approov into the app so that it can generate valid Approov tokens and get shapes.

## ADD THE APPROOV SDK

Get the latest Approov SDK (if you are using Windows then substitute `approov` with `approov.exe` in all cases in this quickstart)
```
$ approov sdk -getLibrary Approov.xcframework
$ iOS SDK library 2.6.0(5851) written to Approov.xcframework
```
In Xcode select `File` and then `Add Files to "ApproovShapes"...` and select the Approov.xcframework folder from the previous command:

![Add Files to ApproovShapes](readme-images/add-files-to-approovshapes.png)

Make sure the `Copy items if needed` option and the target `ApproovShapes` are selected. Once the Approov framework appears in the project structure we have to ensure it is signed and embedded in the ApproovShapes binary. To do so, select the target `ApproovShapes` and in the `General` tab scroll to the `Frameworks, Libraries and Embedded Content` section where the `Approov.framework` entry must have `Embed & Sign` selected in the `Embed` column:

![Embed & Sign](readme-images/embed-and-sign.png)

The Approov SDK is now included as a dependency in your project.

## ADD THE APPROOV FRAMEWORK CODE

The `shapes-app` folder's subfolder `framework` contains an `ApproovInterceptor.swift` file. This provides a wrapper around the Approov SDK itself to make it easier to use with Alamofire's `RequestInterceptor` protocol. In Xcode select `File` and then `Add Files to "ApproovShapes"...` and select the `ApproovInterceptor.swift` file.
Your project structure should now look like this:

![Final Project View](readme-images/final-project-view.png)

## ENSURE THE SHAPES API IS ADDED

In order for Approov tokens to be generated for `https://shapes.approov.io/v2/shapes` it is necessary to inform Approov about it. If you are using a demo account this is unnecessary as it is already set up. For a trial account do:
```
$ approov api -add shapes.approov.io
```
Tokens for this domain will be automatically signed with the specific secret for this domain, rather than the normal one for your account.

## SETUP YOUR APPROOV CONFIGURATION

The Approov SDK needs a configuration string to identify the account associated with the app. Obtain it using:
```
$ approov sdk -getConfig approov-initial.config
```
We need to add the text file to our project and ensure it gets copied to the root directory of our app upon installation. In Xcode select `File`, then `Add Files to "ApproovShapes"...` and select the `approov-initial.config` file. Make sure the `Copy items if needed` option and the target `ApproovShapes` are selected. Your final project structure should look like this:

![Initial Config String](readme-images/initial-config.png)

 Verify that the `Copy Bundle Resources` phase of the `Build Phases` tab includes the `approov-initial.config` in its list, otherwise it will not get copied during installation.
 Providing the configuration file as part of the application is not strictly necessary, the configuration string can be read from a network resource for example, and then provided to the ApproovInterceptor constructor during initialization.

## MODIFY THE APP TO USE APPROOV

Find the function definition for `initializeSession()` in the `ViewController.swift` source file:
```swift
// Create the session only if it does not exist yet
func initializeSession(){
    if (session == nil) {
        session = Session()
    }
}
```
Replace the above code with the one using Approov:
```swift
func initializeSession(){
    if (session == nil) {
        session = ApproovSession()
    }
}
```

The `ApproovSession` class adds the `Approov-Token` header and also applies pinning for the connections to ensure that no Man-in-the-Middle can eavesdrop on any communication being made. The `prefetchToken` option allows the ApproovSDK to asynchronously begin token fetching and allows potentially an attestation token to be available immediately when needed, thus speeding up the costly initial network connection.

## REGISTER YOUR APP WITH APPROOV

In order for Approov to recognize the app as being valid it needs to be registered with the service. This requires building an `.ipa` file using the `Archive` option of Xcode (this option will not be avaialable if using the simulator). Make sure `Any iOS Device` is selected as build destination. This ensures an `embedded.mobileprovision` is included in the application package which is a requirement for the `approov` command line tool. 

![Target Device](readme-images/target-device.png)

We can now build the application by selecting `Product` and then `Archive`. Select the apropriate code signing options and eventually a destination to save the `.ipa` file.

Copy the ApproovShapes.ipa file to a convenient working directory. Register the app with Approov:

```
$ approov registration -add ApproovShapes.ipa
registering app ApproovShapes
lhB30o4UMuzjDsdNicQ6QiM6cEcC4Y5k/SF72fID/Es=com.yourcompany-name.ApproovShapes-1.0[1]-5851  SDK:iOS-universal(2.6.0)
registration successful
```

## RUNNING THE SHAPES APP WITH APPROOV

Install the `ApproovShapes.ipa` that you just registered on the device. You will need to remove the old app from the device first. Please note that you need to run the applicaiton with Approov SDK on a real device and not a simulator.
If using Mac OS Catalina, simply drag the `ipa` file to the device. Alternatively you can select `Window`, then `Devices and Simulators` and after selecting your device click on the small `+` sign to locate the `ipa` archive you would like to install.

![Install IPA Xcode](readme-images/install-ipa.png)

Launch the app and press the `Shape` button. You should now see this (or another shape):

<p>
    <img src="readme-images/shapes-good.jpeg" width="256" title="Shapes Good">
</p>

This means that the app is getting a validly signed Approov token to present to the shapes endpoint.

## WHAT IF I DON'T GET SHAPES

If you still don't get a valid shape then there are some things you can try. Remember this may be because the device you are using has some characteristics that cause rejection for the currently set [Security Policy](https://approov.io/docs/latest/approov-usage-documentation/#security-policies) on your account:

* Ensure that the version of the app you are running is exactly the one you registered with Approov.
* If you run the app from a debugger then valid tokens are not issued.
* Look at the [`syslog`](https://developer.apple.com/documentation/os/logging) output from the device. Information about any Approov token fetched or an error is printed, e.g. `Approov: Approov token for host: https://approov.io : {"anno":["debug","allow-debug"],"did":"/Ja+kMUIrmd0wc+qECR0rQ==","exp":1589484841,"ip":"2a01:4b00:f42d:2200:e16f:f767:bc0a:a73c","sip":"YM8iTv"}`. You can easily [check](https://approov.io/docs/latest/approov-usage-documentation/#loggable-tokens) the validity.

If you have a trial (as opposed to demo) account you have some additional options:
* Consider using an [Annotation Policy](https://approov.io/docs/latest/approov-usage-documentation/#annotation-policies) during development to directly see why the device is not being issued with a valid token.
* Use `approov metrics` to see [Live Metrics](https://approov.io/docs/latest/approov-usage-documentation/#live-metrics) of the cause of failure.
* You can use a debugger and get valid Approov tokens on a specific device by [whitelisting](https://approov.io/docs/latest/approov-usage-documentation/#adding-a-device-security-policy).

## CHANGING YOUR OWN APP TO USE APPROOV

### Configuration

This quick start guide has taken you through the steps of adding Approov to the shapes demonstration app. If you have an app using Swift you can follow exactly the same steps to add Approov. Take a note of the dependency discussion [here](https://approov.io/docs/latest/approov-usage-documentation/#importing-the-approov-sdk-into-ios-xcode).

### API Domains
Remember you need to [add](https://approov.io/docs/latest/approov-usage-documentation/#adding-api-domains) all of the API domains that you wish to send Approov tokens for. You can still use the Approov `swift` client for other domains, but no `Approov-Token` will be sent. 

### Preferences
An Approov app automatically downloads any new configurations of APIs and their pins that are available. These are stored in the [`UserDefaults`](https://developer.apple.com/documentation/foundation/userdefaults) for the app in a preference key `approov-dynamic`. You can store the preferences differently by modifying or overriding the methods `storeDynamicConfig` and `readDynamicApproovConfig` in `ApproovInterceptor.swift`.

### Changing Your API Backend
The Shapes example app uses the API endpoint `https://shapes.approov.io/v2/shapes` hosted on Approov's servers. If you want to integrate Approov into your own app you will need to [integrate](https://approov.io/docs/latest/approov-usage-documentation/#backend-integration) an Approov token check. Since the Approov token is simply a standard [JWT](https://en.wikipedia.org/wiki/JSON_Web_Token) this is usually straightforward. [Backend integration](https://approov.io/docs/latest/approov-integration-examples/backend-api/) examples provide a detailed walk-through for particular languages. Note that the default header name of `Approov-Token` can be modified by changing the variable `approovTokenPrefix`, i.e. in integrations that need to be prefixed with `Bearer`, like the `Authorization` header. It is also possible to change the `Approov-Token` header completely by overriding the contents of `kApproovTokenHeader` variable.

### Token Prefetching
If you wish to reduce the latency associated with fetching the first Approov token, then constructing an `ApproovSession` object should be done setting `prefetchToken` parameter as `true`. This initiates the process of fetching an Approov token as a background task, so that a cached token is available immediately when subsequently needed, or at least the fetch time is reduced. Note that if this feature is being used with [Token Binding](https://approov.io/docs/latest/approov-usage-documentation/#token-binding) then the binding must be set prior to the prefetch, as changes to the binding invalidate any cached Approov token.

### Token Binding
The Approov SDK allows any string value to be bound to a particular token by computing its SHA256 hash and placing its base64 encoded value inside the `pay` claim of the JWT token. The property `ApproovInterceptor.bindHeader` takes the name of the header holding the value to be bound. This only needs to be called once but the header needs to be present on all API requests using Approov. It is also crucial to set the `ApproovInterceptor.bindHeader` property before any token fetch occurs, like token prefetching being enabled in the `ApproovSession` constructor, since setting the value to be bound invalidates any (pre)fetched token.

### Network Retry Options
The `ApproovInterceptor` class implements Alamofire's Interceptor protocol which includes an option to invoke a retry attempt in case the original request failed. We do not implement the retry option in `ApproovInterceptor`, but if you require implementing one, you should mimic the contents of the `adapt()` function and perhaps add some logic regarding retry attempts. See an example [here](https://github.com/Alamofire/Alamofire/blob/master/Documentation/AdvancedUsage.md#adapting-and-retrying-requests-with-requestinterceptor).

### Network Delegate
Unfortunately we do not support network delegates in Alamofire. If you wish to use a network delegate and do not mind using apple's URLSession interface, we can offer an `ApproovURLSession` integration that does support network delegates.

### ApproovTrustManager
The `ApproovSession` object handles internally the creation of a default `AproovTrustManager`, if one is not provided during initialization. The `AproovTrustManager` then sets the mapping between hosts and evaluators internally. If you wish to use different evaluators for hosts not protected by Approov, you can initialize the `ApproovTrustManager` like so:

```swift
        let evaluators: [String: ServerTrustEvaluating] = [
            "some.other.host.com": RevocationTrustEvaluator(),
            "another.host": PinnedCertificatesTrustEvaluator()
        ]

        let manager = ApproovTrustManager(evaluators: evaluators)
        session = ApproovSession(serverTrustManager: manager)
```

Please note that you do not have to specify the hosts that need to be protected by Approov, they are automatically set for you once a configuration has been fetched from the Approov servers. You can manage (adding and removing) Approov protected domains using the approov [admin tools](https://approov.io/docs/latest/approov-cli-tool-reference/).
By default, the `ApproovTrustManager` verifies all the hosts protected by Approov and any optional hosts provided a mapping to an evaluator has been provided as in the above code snippet. This means that any request to an additional host not known to the Approov SDK nor the `ApproovTrustManager`, lets say `https://approov.io`, will not be evaluated by Alamofire and it will not be protected by Approov. As long as the certificate presented by that host is valid, the connection will most likely go through. If you wish to change this behaviour, you may modify how the `ApproovTrustManager` is initialized in the above code:

```swift
        let evaluators: [String: ServerTrustEvaluating] = [
            "some.other.host.com": RevocationTrustEvaluator(),
            "another.host": PinnedCertificatesTrustEvaluator()
        ]

        let manager = ApproovTrustManager(allHostsMustBeEvaluated: true, evaluators: evaluators)
        session = ApproovSession(serverTrustManager: manager)
```

The `allHostsMustBeEvaluated: true` parameter will evaluate `some.other.host.com` and `another.host` according to the evaluators specified above. The Approov SDK will verify the public key pinning of all the hosts specified using the [admin tools](https://approov.io/docs/latest/approov-cli-tool-reference/) but any connections to additional hosts will be rejected.

### Redirection
If any of the hosts you are protecting with Approov redirects requests to a different host, depending on the `allHostsMustBeEvaluated` option used and described above, you might need to protect both hosts with Approov and/or an evaluator as in the code example above, otherwise the original request might get evaluated and after a redirect is triggered, the target host connection is rejected.

### Alamofire Request
If your code makes use of the default Alamofire Session, like so:

```swift
    AF.request("https://httpbin.org/get").response { response in
        debugPrint(response)
    }
```

all you will need to do to use Approov is to replace the default Session object with the ApproovSession:

```swift
    let approovSession = ApproovSession()
    approovSession!.request("https://httpbin.org/get").responseData{ response in
            debugPrint(response)
    }
```

## NEXT STEPS

This quick start guide has shown you how to integrate Approov with your existing app. Now you might want to explore some other Approov features:

* Managing your app [registrations](https://approov.io/docs/latest/approov-usage-documentation/#managing-registrations)
* Manage the [pins](https://approov.io/docs/latest/approov-usage-documentation/#public-key-pinning-configuration) on the API domains to ensure that no Man-in-the-Middle attacks on your app's communication are possible.
* Update your [Security Policy](https://approov.io/docs/latest/approov-usage-documentation/#security-policies) that determines the conditions under which an app will be given a valid Approov token.
* Learn how to [Manage Devices](https://approov.io/docs/latest/approov-usage-documentation/#managing-devices) that allows you to change the policies on specific devices.
* Understand how to provide access for other [Users](https://approov.io/docs/latest/approov-usage-documentation/#user-management) of your Approov account.
* Use the [Metrics Graphs](https://approov.io/docs/latest/approov-usage-documentation/#metrics-graphs) to see live and accumulated metrics of devices using your account and any reasons for devices being rejected and not being provided with valid Approov tokens. You can also see your billing usage which is based on the total number of unique devices using your account each month.
* Use [Service Monitoring](https://approov.io/docs/latest/approov-usage-documentation/#service-monitoring) emails to receive monthly (or, optionally, daily) summaries of your Approov usage.
* Consider using [Token Binding](https://approov.io/docs/latest/approov-usage-documentation/#token-binding).
* Learn about [automated approov CLI usage](https://approov.io/docs/latest/approov-usage-documentation/#automated-approov-cli-usage).
* Investigate other advanced features, such as [Offline Security Mode](https://approov.io/docs/latest/approov-usage-documentation/#offline-security-mode) and [DeviceCheck Integration](https://approov.io/docs/latest/approov-usage-documentation/#apple-devicecheck-integration).
