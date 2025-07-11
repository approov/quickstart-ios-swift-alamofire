# Shapes Example

This quickstart is written specifically for native iOS apps that are written in Swift and using Alamofire for making the API calls that you wish to protect with Approov. This quickstart provides a step-by-step example of integrating Approov into an app using a simple `Shapes` example that shows a geometric shape based on a request to an API backend that can be protected with Approov.

## WHAT YOU WILL NEED
* Access to a trial or paid Approov account
* The `approov` command line tool [installed](https://approov.io/docs/latest/approov-installation/) with access to your account
* [Xcode](https://developer.apple.com/xcode/) installed (version 16.1 is used in this guide)
* An Apple mobile device or simulator with iOS 12 or higher
* The contents of this repo

## ALAMOFIRE FRAMEWORK
 
We include [Alamofire](https://github.com/Alamofire/Alamofire) as a `swift package manager` dependency in our project.
 
## RUN THE SHAPES APP WITHOUT APPROOV

Open the `ApproovShapes.xcodeproj` project in the `shapes-app` folder using `File->Open` in Xcode. Ensure the `ApproovShapes` project is selected at the top of Xcode's project explorer panel.

Select your code signing certificate in the `Signing & Capabilities` tab and run the application on your preferred device.

![Codesign App](readme-images/codesign-app.png)

Once the application is running you will see two buttons:

<p>
   <img src="readme-images/app-startup.png" width="256" title="Shapes App Startup">
</p>

Click on the `Hello` button and you should see this:

<p>
   <img src="readme-images/hello-okay.png" width="256" title="Hello Okay">
</p>

This checks the connectivity by connecting to the endpoint `https://shapes.approov.io/v1/hello`. Now press the `Shape` button and you will see this (or another shape):

<p>
   <img src="readme-images/shape.png" width="256" title="Shape">
</p>

This contacts `https://shapes.approov.io/v1/shapes` to get the name of a random shape. This endpoint is protected with an API key that is built into the code, and therefore can be easily extracted from the app.

The subsequent steps of this guide show you how to provide better protection, either using an Approov token or by migrating the API key to become an Approov managed secret.

## ADD THE APPROOV SERVICE ALAMOFIRE

The Approov integration is available via the [`Swift Package Manager`](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app). This allows inclusion into the project by simply specifying a dependency in the `File -> Add Packages...` Xcode option if the project is selected:

![Add Package Dependency](readme-images/add-package-repository.png)

Enter the repository `https://github.com/approov/approov-service-alamofire.git` into the search box. You will then have to select the relevant version you wish to use. To do so, select the `Exact Version` option and the latest version available should be selected for you.

Once you click `Add Package` the last screen will confirm the package product and target selection. The `approov-service-alamofire` and Approov SDK are now included as a dependency in your project. The `approov-service-alamofire` is actually an open source wrapper layer that allows you to easily use the Approov SDK itself with Alamofire.  This has a further dependency to the closed source [Approov SDK](https://github.com/approov/approov-ios-sdk).

## ENSURE THE SHAPES API IS ADDED

In order for Approov tokens to be generated for the shapes endpoint `https://shapes.approov.io/v3/shapes` it is necessary to inform Approov about it:

```
approov api -add shapes.approov.io
```

Tokens for this domain will be automatically signed with the specific secret for this domain, rather than the normal one for your account.

## MODIFY THE APP TO USE APPROOV

Before using Approov you need to import the Alamofire Service. In the `ViewController.swift` source file uncomment the line to import the service module:

```swift
// *** UNCOMMENT IF USING APPROOV
import ApproovSession
```

Find the function definition for `viewDidLoad()` in the `ViewController.swift` source file. Uncomment the code below (and remember to comment the previous version):

```swift
// *** COMMENT OUT IF USING APPROOV
//session = Session()

// *** UNCOMMENT TO USE APPROOV
session = ApproovSession()
try! ApproovService.initialize(config: "<enter-you-config-string-here>")
```

Replace `<enter-you-config-string-here>"` with the actual configuration string for your account. You will have received this in your Approov onboarding email (it will be something like `#12456#K/XPlLtfcwnWkzv99Wj5VmAxo4CrU267J1KlQyoz8Qo=`). The `ApproovSession` class adds the `Approov-Token` header and also applies pinning for the connections to ensure that no Man-in-the-Middle can eavesdrop on any communication being made.

Lastly, make sure we are using the Approov protected endpoint for the shapes server, `https://shapes.approov.io/v3/shapes/`. Uncomment the line below (commenting out the previous definition):

```swift
// *** COMMENT OUT IF USING APPROOV API PROTECTION
//static let currentShapesEndpoint = "v1"

// *** UNCOMMENT IF USING APPROOV API PROTECTION
static let currentShapesEndpoint = "v3"
```

## ADD YOUR SIGNING CERTIFICATE TO APPROOV

You should add the signing certificate used to sign apps. These are available in your Apple development account portal. Go to the initial screen showing program resources:

![Apple Program Resources](readme-images/program-resources.png)

Click on `Certificates` and you will be presented with the full list of development and distribution certificates for the account. Click on the certificate being used to sign applications from your particular Xcode installation and you will be presented with the following dialog:

![Download Certificate](readme-images/download-cert.png)

Now click on the `Download` button and a file with a `.cer` extension is downloaded, e.g. `development.cer`. Add it to Approov with:

```
approov appsigncert -add development.cer -autoReg
```

This ensures that any app signed with the certificate will be recognized by Approov.

If it is not possible to download the correct certificate from the portal then it is also possible to [add app signing certificates from the app](https://approov.io/docs/latest/approov-usage-documentation/#adding-apple-app-signing-certificates-from-app).

> **IMPORTANT:** Apps built to run on the iOS simulator are not code signed and thus auto-registration does not work for them. In this case you can consider [forcing a device ID to pass](https://approov.io/docs/latest/approov-usage-documentation/#forcing-a-device-id-to-pass) to get a valid attestation.

## RUNNING THE SHAPES APP WITH APPROOV

Run the app (without any debugger attached) and press the `Shape` button. You should now see this (or another shape):

<p>
   <img src="readme-images/shape-approoved.png" width="256" title="Shape Approoved">
</p>

This means that the app is getting a validly signed Approov token to present to the shapes endpoint.

## WHAT IF I DON'T GET SHAPES

If you still don't get a valid shape then there are some things you can try. Remember this may be because the device you are using has some characteristics that cause rejection for the currently set [Security Policy](https://approov.io/docs/latest/approov-usage-documentation/#security-policies) on your account:

* Ensure that the version of the app you are running is signed with the correct certificate.
* Look at the console output from the device using the [Console](https://support.apple.com/en-gb/guide/console/welcome/mac) app from MacOS. This provides console output for a connected simulator or physical device. Select the device and search for `ApproovService` to obtain specific logging related to Approov. This will show lines including the loggable form of any tokens obtained by the app. You can easily [check](https://approov.io/docs/latest/approov-usage-documentation/#loggable-tokens) the validity and find out any reason for a failure.
* Use `approov metrics` to see [Live Metrics](https://approov.io/docs/latest/approov-usage-documentation/#metrics-graphs) of the cause of failure.
* You can use a debugger or simulator and get valid Approov tokens on a specific device by ensuring you are [forcing a device ID to pass](https://approov.io/docs/latest/approov-usage-documentation/#forcing-a-device-id-to-pass). As a shortcut, you can use the `latest` as discussed so that the `device ID` doesn't need to be extracted from the logs or an Approov token.
* Also, you can use a debugger and get valid Approov tokens on any device if you [mark the signing certificate as being for development](https://approov.io/docs/latest/approov-usage-documentation/#development-app-signing-certificates).
* Inspect any exceptions for additional information.

## SHAPES APP WITH INSTALLATION MESSAGE SIGNING

 This section shows how to add message signing as an additional layer of protection in addition to an Approov token.

1. Make sure we are using the `https://shapes.approov.io/v5/shapes/` endpoint of the shapes server. The v5 endpoint performs a message signature check in addition to the Approov token check. Find the following line in the `ViewController.swift`  source file and uncomment it to point to `v5` (commenting the previous definitions):

```swift
//*** UNCOMMENT THE LINE BELOW FOR APPROOV USING INSTALLATION MESSAGE SIGNING
let currentShapesEndpoint = "v5"
```

 2. Uncomment the message signing setup code in `ViewController.swift`. This adds an interceptor extension to the ApproovService which adds the message signature to the request automatically.

```swift
//*** UNCOMMENT THE LINES BELOW FOR APPROOV USING INSTALLATION MESSAGE SIGNING
ApproovService.setApproovInterceptorExtensions(
    ApproovDefaultMessageSigning().setDefaultFactory(
        ApproovDefaultMessageSigning.generateDefaultSignatureParametersFactory()))
```

 3. Configure Approov to add the public message signing key to the approov token. This key is used by the v5 endpoint to perform its message signature check.

 ```shell
 approov policy -setInstallPubKey on
 ```

 4. Build and run the app again and press the `Shape` button. You should see this (or another shape):

 <p>
    <img src="readme-images/shape-approoved.png" width="256" title="Shape Approoved">
 </p>

 This indicates that in addition to the app obtaining a validly signed Approov token, the message also has a valid signature.

## SHAPES APP WITH SECRETS PROTECTION

This section provides an illustration of an alternative option for Approov protection if you are not able to modify the backend to add an Approov Token check. We are going to be using `https://shapes.approov.io/v1/shapes/` that simply checks for an API key. Change back the code so it points to `https://shapes.approov.io/v1/shapes/`.

```swift
static let currentShapesEndpoint = "v1"
```

The `apiSecretKey` variable also needs to be changed as follows, removing the actual API key out of the code. Uncomment the line containing `"shapes_api_key_placeholder"` (commenting the previous definition):

```swift
// *** COMMENT IF USING APPROOV SECRETS PROTECTION
//let apiSecretKey = "yXClypapWNHIifHUWmBIyPFAm"

// *** UNCOMMENT IF USING APPROOV SECRETS PROTECTION
let apiSecretKey = "shapes_api_key_placeholder"
```

You must inform Approov that it should map `shapes_api_key_placeholder` to `yXClypapWNHIifHUWmBIyPFAm` (the actual API key) in requests as follows:

```
approov secstrings -addKey shapes_api_key_placeholder -predefinedValue yXClypapWNHIifHUWmBIyPFAm
```

> Note that this command requires an [admin role](https://approov.io/docs/latest/approov-usage-documentation/#account-access-roles).

Next we need to inform Approov that it needs to substitute the placeholder value for the real API key on the `Api-Key` header. Find the line below and uncomment it:

```swift
// *** UNCOMMENT IF USING APPROOV SECRETS PROTECTION
ApproovService.addSubstitutionHeader(header: "Api-Key", prefix: nil)
```

This processes the headers and replaces in the actual API key as required.

Build and run the app and press the `Shape` button. You should now see this (or another shape):

<p>
   <img src="readme-images/shape.png" width="256" title="Shape">
</p>

This means that the app is able to access the API key, even though it is no longer embedded in the app code, and provide it to the shapes request.
