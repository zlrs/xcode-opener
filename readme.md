# xcode-opener
* A CLI tool that opens XCode project from Terminal. 
* Auto detect .xcodeproj file or .xcworkspace file. 
* Quickly open a pod-based project after pod install. 

# Usage 
```
xc [<XCode_project_directory>]
```

# Prerequisite
Python 2.7+ or Python 3

# Installation
## macOS / Linux
```shell
cd this_project_s_root_dir
chmod +x ./xc
mv ./xc /usr/local/bin/
```

## Windows
Windows 下可以新建一个`.bat`文件，内容为`python ./xc`。将其和`xc`文件放在`PATH`之一的路径下即可。
