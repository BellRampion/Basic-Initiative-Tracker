To change the icon: 

    - Add icon to assets folder
    - Go to pubspec.yaml and change the image_path under flutter_launcher_icons to the new icon name
    - Run `flutter pub run flutter_launcher_icons`
    - Run `dart run msix:create`
    
To build to Linux: 

	- `flutter build linux --release`
	- flutter_to_debian

To build to Windows

	- `flutter build windows --release`
	- Add the cert to root file for Basic Initiative Tracker
	- Add cert password to pubspec.yaml
	- ` dart run msix:create`