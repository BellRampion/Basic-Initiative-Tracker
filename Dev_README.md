To change the icon: 

    - Add icon to assets folder
    - Go to pubspec.yaml and change the image_path under flutter_launcher_icons to the new icon name
    - Run `flutter pub run flutter_launcher_icons`
    - Run `dart run msix:create`
    
To build to Linux: 

	- `fluter build ilnux --release`
	- flutter_to_debian
