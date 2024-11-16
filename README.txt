** Installing Flutter **

Recommended Process: Install via VS Code
1) Launch VS Code 2) Install Flutter extension for VS Code via Extensions (Ctrl+Shift+X) 3) Open command prompt (Ctrl+Shift+P) and type ">flutter: new project" 4)As VS Code prompts to locate flutter sdk, click "Download SDK" (ignore template prompt). Consider installing under "C:\[INSERT USER\dev" 5)Once output panel displays that flutter is done initializing, type ">flutter: run doctor" in the command prompt to ensure everything was successful.
NOTE: Once installed, you don't have to use VS Code if you don't want to (I recommend Android Studio), it just makes it easier to install. Make sure to add SDK when installing.

Flutter Installation Documentation
https://docs.flutter.dev/get-started/install/windows/mobile

** Additional Flutter Configuration **

When making the following changes, make sure to run "flutter clean" upon changes.

Configuring Flutter for Android Studio
1) Go to Settings>Languages & Frameworks>Flutter 2)Insert the Flutter SDK file path

Allowing http get requests with chrome client
1) Open [Flutter SDK Path]\packages\flutter_tools\lib\src\web\chrome.dart 2)Find '--disable-extensions' 3) Insert '--disable-web-security' below that line



** Mac Setup for Building iOS IPA **

1) Install GitHub Desktop. Its recommended you move GitHub into the applications folder, but admin permission will be required to do so, and it can still run slowly through Downloads.
2) Install IDE of choice. Xcode does not have support for dart and/or flutter, so you will need to install an additional IDE. I recommend VS Code, as it requires very little additional setup, and others such as Android Studio don't work as well with Mac. It's also recommended to move this into the applications folder.
3) Install the Flutter SDK. Save the path, including the path to the bin.
4) Add Flutter to your PATH directory. Save the source cmnd to a text editor
4) Install Homebrew. There are ways to ignore this step, but this is the easiest method to access cocoapods. View info here: https://docs.brew.sh/Installation
5) Run "brew install cocoapods". Cocoapods is the application responsible for installing various flutter plugins we use from the internet.