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
let session = ApproovSession(configString: "<enter-you-config-string-here>")
```

Additionally, the Approov SDK needs to be initialized before use. The `<enter-your-config-string-here>` is a custom string that configures your Approov account access. This will have been provided in your Approov onboarding email (it will be something like `#123456#K/XPlLtfcwnWkzv99Wj5VmAxo4CrU267J1KlQyoz8Qo=`).

## CHECKING IT WORKS
Initially you won't have set which API domains to protect, so the interceptor will not add anything. It will have called Approov though and made contact with the Approov cloud service. You will see logging from Approov saying `UNKNOWN_URL`.

Your Approov onboarding email should contain a link allowing you to access [Live Metrics Graphs](https://approov.io/docs/latest/approov-usage-documentation/#metrics-graphs). After you've run your app with Approov integration you should be able to see the results in the live metrics within a minute or so. At this stage you could even release your app to get details of your app population and the attributes of the devices they are running upon.

However, to actually protect your APIs there are some further steps you can learn about in [Next Steps](https://github.com/approov/quickstart-ios-swift-alamofire/blob/master/NEXT-STEPS.md).
