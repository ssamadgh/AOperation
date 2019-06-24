
# AOperation


 A wrapper on Operation and OperationQueue classes which gives some more power to you in using them.


[![Swift 5](https://img.shields.io/badge/Swift-5-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![license MIT](https://img.shields.io/cocoapods/l/ModelAssistant.svg)](https://github.com/ssamadgh/ModelAssistant/blob/master/LICENSE)
[![Twitter](https://img.shields.io/badge/twitter-@ssamadgh-blue.svg?style=flat)](https://twitter.com/ssamadgh)



## Installation

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate ModelAssistant into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/ssamadgh/AOperationPod.git'
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do

    pod 'AOperation'
    
end

```


### Manually

If you prefer not to use any of the aforementioned dependency managers, you can integrate AOperation into your project manually.

#### Embedded Framework

- Open up Terminal, `cd` into your top-level project directory, and run the following command "if" your project is not initialized as a git repository:

  ```bash
  $ git init
  ```

- Add AOperation as a git [submodule](https://git-scm.com/docs/git-submodule) by running the following command:

  ```bash
  $ git submodule add https://github.com/ssamadgh/AOperation.git
  ```

- Open the new `AOperation ` folder, and drag the `AOperation.xcodeproj` into the Project Navigator of your application's Xcode project.

    > It should appear nested underneath your application's blue project icon. Whether it is above or below all the other Xcode groups does not matter.

- Select the `AOperation.xcodeproj` in the Project Navigator and verify the deployment target matches that of your application target.
- Next, select your application project in the Project Navigator (blue project icon) to navigate to the target configuration window and select the application target under the "Targets" heading in the sidebar.
- In the tab bar at the top of that window, open the "General" panel.
- Click on the `+` button under the "Embedded Binaries" section.
- You will see two different `AOperation.xcodeproj` folders each with a `AOperation.framework` nested inside a `Products` folder.

    > It does not matter which `Products` folder you choose from.

- Select the `AOperation.framework`.


- And that's it!

  > The `AOperation.framework` is automagically added as a target dependency, linked framework and embedded framework in a copy files build phase which is all you need to build on the simulator and a device.
  



## Credits

AOperation is owned and maintained by the [Seyed Samad Gholamzadeh](http://ssamadgh@gmail.com). You can follow me on Twitter at [@ssamadgh](https://twitter.com/ssamadgh) for project updates and releases.

## License

AOperation is released under the MIT license. [See LICENSE](https://github.com/ssamadgh/AOperation/blob/master/LICENSE) for details.
