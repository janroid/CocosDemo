# !/bin/sh
# 打印使用教程
# 可使用 ./autoPack.sh -h 或者 ./autoPack.sh --help 来查看使用教程
function autopack_usage() {
	cat << EOT
Usage : 
  iOS自动打包脚本，导出ipa文件.
Example:
  1) 先移动到该脚本目录下，然后执行:
  ./autopack.sh [Server Options] [IPA Options] [Version Code] [Description]
  2)或者全路径执行脚本：
  sh xx/xx/xx/autopack.sh [Server Options] [IPA Options] [Version Code] [Description]
Help:
  -h, --help       Display this message
Server Options: 
  demo   (Default)内网环境
  release  外网环境		
IPA Options: 
  adhoc (Default) 使用临时发布证书打包
  inhouse  使用企业证书打包
  appstore 使用上传到appstore的证书打包		
Version Code:
  [1-9].[0-9].[0-9]		传了版本号，会自动修改info.plist文件中的那个版本号，并使用起来
  Null (Default) 不传默认使用info.plist文件中的那个版本号
Description:(options)
  描述信息
Exit status:
  0   if OK,
  !=0 if serious problems.
EOT
	exit 1
}

# 设置是否开启服务器demo， 第一个参数为true/yes 就开启服务器demo，该函数由于用到了外部全局变量，所以调用时机需要掌握好
function set_demo_mode(){
	echo ======== $1
	if [[ $1 == true || $1 == yes ]]; then
		$PlistBuddy -c 'Set :IS_DEMO true' ${InfoPlistPath}
	else
		$PlistBuddy -c 'Set :IS_DEMO false' ${InfoPlistPath}
	fi

	# 本想把下面几句添加到 Xcode build Pre-actions、Run Pre-actions、Archive Pre-actions,但是会导致每次用脚本打包或者Xcode 打包都运行，
	# InfoPlistPath="${PROJECT_DIR}/Resource/poker_Global/Info.plist"
	# PlistBuddy="/usr/libexec/PlistBuddy"
	# Debug_mode=$($PlistBuddy -c "print IS_DEMO" ${InfoPlistPath})
	# if [[ $Debug_mode = true ]]; then
    # 	$PlistBuddy -c 'Set :IS_DEMO false' ${InfoPlistPath}
	# fi
}
#处理输入参数
ServerType="demo"
VersionCode=""
IPAType="adhoc"
Description=""
ExportOptionsPlistName="AdHocExportOptions.plist"
for param in $*; do
	case $param in
		appstore)
			ExportOptionsPlistName="AppStoreExportOptions.plist"
			IPAType=$param
		;;
		adhoc)
			ExportOptionsPlistName="AdHocExportOptions.plist"
			IPAType=$param
		;;
		inhouse)
			ExportOptionsPlistName="EnterpriseExportOptions.plist"
			IPAType=$param
		;;
		demo | release)
			ServerType=$param
		;;
		[1-9].[0-9].[0-9])
		# *.*.*)
			VersionCode=$param
		;;
		-h | --help)
			autopack_usage;
			exit 1
		;;
		*)
			Description=$param
		;;
	esac
done

#配置脚本运行目录
function configRunDir()
{
	PlistBuddy=/usr/libexec/PlistBuddy
	Basepath=$(cd `dirname $0`; pwd)
	cd $Basepath
	# 移动目录到cocos根目录
	cd ../../
	cocosDir=$PWD
	cd $Basepath
}
configRunDir

#配置区域信息
function configAreaInfo()
{
	target="iPoker"
	projectPath=$cocosDir/frameworks/runtime-src/proj.ios_mac/${target}.xcodeproj
	InfoPlistPath=$cocosDir/frameworks/runtime-src/proj.ios_mac/ios/Resource/Info.plist

	#option
	startPath=$PWD;

	# 默认地区
	areaBrief="zh"
	areaName="繁体"
	bundle="com.coalaa.itexashk"
	remoteAdress="http://mtv.oa.com/webData/apps/ipoker"
	version=$VersionCode
	displayName=$($PlistBuddy -c "print CFBundleDisplayName" ${InfoPlistPath})

	#各地区区域和名称简称
	BundleIDs=("com.coalaa.itexashk" "com.coalaa.itexasvn" "com.coalaa.itexasth" "com.coalaa.itexasid" "com.funplus.pokerar" "com.funplus.pokerfr")
	AreaBriefs=("zh" "vn" "th" "id" "ar" "fr")
	AreaNames=("繁体" "越南" "泰语" "印尼" "阿语" "法语")
	for((i=0; i<${#BundleIDs[@]}; i++)) 
	do
		if [[ ${bundle} = ${BundleIDs[i]} ]]; then
			areaBrief=${AreaBriefs[i]}
			areaName=${AreaNames[i]}
			break
		fi
	done


	# 调整版本号
	if [[ $VersionCode = "" ]]; then
		version=$($PlistBuddy -c "print CFBundleShortVersionString" ${InfoPlistPath})
	else
		$PlistBuddy -c "Set :CFBundleShortVersionString $VersionCode" ${InfoPlistPath}
		$PlistBuddy -c "Set :CFBundleVersion $VersionCode" ${InfoPlistPath}
	fi
}
configAreaInfo

# 配置server
function configServer()
{
	# 调整服务器内外网
	if [[ $IPAType = "adhoc" ]]; then
		if [[ $ServerType = "demo" ]]; then
			color="#0000FF"
		else 
			color="#00FF00"
		fi
	elif [[ $IPAType = "appstore" ]]; then
		color="#FF0000"
		ServerType="release"
	fi

	if [[ $ServerType = "release" ]]; then
		set_demo_mode false
	else 
		set_demo_mode true
	fi
}
configServer

# 配置IPA信息
function configIPAInfo()
{
	# iPoker/v5.0.0_zh_demo_adHoc
	ipaDirectory="v${version}_${areaBrief}_${ServerType}_${IPAType}"
	ipafolder=$target/$ipaDirectory

	dateName=`date +%Y-%m-%d-%H.%M`
	archiveName="${target}_$dateName.xcarchive"
	archiveFilePreFolder=`date +%Y-%m-%d`
	archTemPath="$HOME/Library/Developer/Xcode/Archives/$archiveFilePreFolder/";
	archTemFile="$HOME/Library/Developer/Xcode/Archives/$archiveFilePreFolder/$archiveName"
	ipaPath="$PWD/$ipafolder"

	optionsPlist="$PWD/OptionsPlist/${ExportOptionsPlistName}"

	echo -e "packageParam:\033[32m
	 project: $projectPath
	 target: $target
	 server: $ServerType
	 verison: $version
	 bundle: $bundle
	 证书类型: $IPAType
	 remoteAdress: $remoteAdress
	 archTemPath: $archTemPath
	 archTemFile: $archTemFile
	 ipaPath : $ipaPath 
	 optionsPlist: $optionsPlist\033[0m"

	rm -r $ipaPath/
	mkdir -p $ipafolder
	LogPath=$ipaPath/log.txt
	#删除上一次打包的log记录
	if [ -e $LogPath ]; then
		rm -rf  $LogPath
	fi
	cd $projectPath

	SendDesc=""
	Configuration="Release"

	if [[ $IPAType = "appstore" ]]; then
		SendDesc="AppStore包(仅用于上架商店)"
	elif [[ $IPAType = "inhouse" ]]; then
		SendDesc="企业包(无设备限制)"
		Configuration="Inhouse"
	else
		SendDesc="测试包(仅用于测试机)"
	fi
}
configIPAInfo

# core:打包
function dopackage()
{
	echo "`date +%Y/%m/%d-%H:%M:%S` cleaning $target 项目 ..."
	echo ======== `date +%Y/%m/%d-%H:%M:%S` =========== >> $LogPath
	# 清理项目
	# xcodebuild clean -configuration $Configuration \
	# 				 -target $target \
	# 				 -project $projectPath \			
	# 				 >> $LogPath

	echo "`date +%Y/%m/%d-%H:%M:%S` archive $target 项目 ..."
	# 压缩打包项目
	xcodebuild archive -project $projectPath \
					   -scheme $target \
					   -configuration $Configuration \
					   -destination generic/platform=iOS \
					   -archivePath $archTemFile \
					   >> $LogPath

	# 压缩archive文件失败，则打开提示日志
	if [ ! -e ${archTemFile} ]; then
		set_demo_mode false
		echo "** error: archive failed **"
		open  $LogPath
		exit 1
	fi
				   
	echo "`date +%Y/%m/%d-%H:%M:%S` exportArchive $target 项目 ..."
	# 导出ipa文件
	xcodebuild -exportArchive -archivePath $archTemFile \
							  -exportPath $ipaPath \
							  -exportOptionsPlist $optionsPlist \
							  >> $LogPath

	set_demo_mode false
	# 导出ipa失败，则打开提示日志
	if [ ! -e ${ipaPath}/${target}.ipa ]; then
		echo "** error: export ipa failed  please see $LogPath  **"
		open  $LogPath
		exit 1
	fi
}
# dopackage

# 生成MTV需要的配置文件
function createMTVCfgFile()
{
#上传到mtv的plist文件
	cat << EOF > $startPath/$ipafolder/$target.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>items</key>
	<array>
		<dict>
			<key>assets</key>
			<array>
				<dict>
					<key>kind</key>
					<string>software-package</string>
					<key>url</key>
					<string>http://mtv.oa.com/webData/apps/ipoker/${ipaDirectory}/${target}.ipa</string>
				</dict>
				<dict>
					<key>kind</key>
					<string>display-image</string>
					<key>needs-shine</key>
					<true/>
					<key>url</key>
					<string>http://mtv.oa.com/webData/apps/ipoker/${ipaDirectory}/${target}.png</string>
				</dict>
			</array>
			<key>metadata</key>
			<dict>
				<key>bundle-identifier</key>
				<string>${bundle}</string>
				<key>kind</key>
				<string>software</string>
				<key>title</key>
				<string>${displayName}</string>
			</dict>
		</dict>
	</array>
</dict>
</plist>
EOF

	#上传到mtv的txt文件
	send=`date '+%Y%m%d_%H%M'`;

	cat << EOF > $startPath/$ipafolder/$target.txt
<font color=blue>${areaName}_${version}_${ServerType}</font>
</br>
<font color=gray>${send}</font>
</br>
<font color=${color}>${SendDesc}</font>
</br>
<font color=$color>$Description</font>
EOF

	#上传到mtv的js文件
	cat << EOF > $startPath/$ipafolder/${target}.js
{"name":"<font color=${color}> 我爱德州 ${areaName} ${version} $IPAType </font>",
"version":"${version}",
"date":"${send}",
"type":"${ServerType}",
"desc":"<font color=#FF9801> 1.${SendDesc};\n2.bundleID:${bundle};\n$Description</font>"
}
EOF
}
createMTVCfgFile

# 打印打包结果
function printPackResult()
{
	echo -e "\033[32m****  `date +%Y/%m/%d-%H:%M:%S` exportArchive ipa ${ipaPath}/${target}.ipa finished  ****\033[0m"
	cd $startPath
	open $ipaPath
}
printPackResult

