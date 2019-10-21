BuildInfoOverlay
================

Available arguments:
```bash
-text
-textColor
-textSize
-textPosition
-textAligment
-textXPadding
-textYPadding
-sourcePath
-resultPath
-resultHeight
-resultWidth
```

Example
================

Run script
Schell /bin/sh

```bash
cd ${SRCROOT}/PrebuildScripts/
./PreBuldConfigure.sh "${SRCROOT}" "${CONFIGURATION}" "DEV"
```

PreBuldConfigure.sh

```bash
srcroot=$1
configuration=$2
environment=$3

echo "🔜 App icons configuration..."

version=${environment}
textColor="#d0021b"
textAligment="right"

infoPlist="${srcroot}/SupportingFiles/Info.plist"
appVersion=`/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "${infoPlist}"`
build=`/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "${infoPlist}"`
buildNumber="($build)"

basePath="${srcroot}/SupportingFiles/Resources/Images.xcassets/AppIcon.appiconset/"
resourcesBasePath="${srcroot}/PrebuildScripts/BuildInfoOverlay/"
sourceImagePath="${resourcesBasePath}/source.png"
tempImagePath="${basePath}/temp.png"

cd "${resourcesBasePath}"

#draw version text
./BuildInfoOverlay -sourcePath $sourceImagePath -resultPath $tempImagePath -text "$version" -textColor $textColor -textPosition 'bottom' -textAligment 'center' -textSize 14 -textYPadding 2

#draw appVersion and build number
./BuildInfoOverlay -sourcePath $tempImagePath -resultPath $tempImagePath -text "$appVersion $buildNumber" -textColor $textColor -textPosition 'top' -textAligment 'center' -textYPadding 2 -textSize 14

#drawing icons
#notifications
./BuildInfoOverlay -sourcePath $tempImagePath -resultPath $basePath'icon_notifications@2x.png' -resultWidth 40 -resultHeight 40
./BuildInfoOverlay -sourcePath $tempImagePath -resultPath $basePath'icon_notifications@3x.png' -resultWidth 60 -resultHeight 60

#settings
./BuildInfoOverlay -sourcePath $tempImagePath -resultPath $basePath'icon_settings@2x.png' -resultWidth 58 -resultHeight 58
./BuildInfoOverlay -sourcePath $tempImagePath -resultPath $basePath'icon_settings@3x.png' -resultWidth 87 -resultHeight 87

#spotlite
./BuildInfoOverlay -sourcePath $tempImagePath -resultPath $basePath'icon_spotlight@2x.png' -resultWidth 80 -resultHeight 80
./BuildInfoOverlay -sourcePath $tempImagePath -resultPath $basePath'icon_spotlight@3x.png' -resultWidth 120 -resultHeight 120

#iPhone App Icons
./BuildInfoOverlay -sourcePath $tempImagePath -resultPath $basePath'icon_iphone@2x.png' -resultWidth 120 -resultHeight 120
./BuildInfoOverlay -sourcePath $tempImagePath -resultPath $basePath'icon_iphone@3x.png' -resultWidth 180 -resultHeight 180

#AppStore Icons
./BuildInfoOverlay -sourcePath $tempImagePath -resultPath $basePath'icon_AppStore_iOS.png' -resultWidth 1024 -resultHeight 1024


rm $tempImagePath
echo "✅ App icons ready"
```
