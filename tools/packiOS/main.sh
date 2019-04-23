# !/bin/sh

# 使用方法 cd 到当前目录
function main_usage(){
	cat << EOT
Usage : 
  iOS 资源复制，ipa打包脚本合集.
Example:
  1) 先移动到该脚本目录下，然后执行:
  ./main.sh [Encode Options] [Server Options] [IPA Options] [Version Code] [Description]
  2)或者全路径执行脚本：
  sh xx/xx/xx/main.sh [Encode Options] [Server Options] [IPA Options] [Version Code] [Description]
Help:
  -h, --help       Display this message
Encode Options:
  false （Default）不加密lua
  true 加密lua
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
# 0 参数设置 、过滤
ServerType="Debug"
VersionCode=""
IPAType="AdHoc"
Description=""
LuaIsEncode=false
for param in $*; do
	case $param in
		AdHoc | AppStore)
			IPAType=$param
		;;
		Debug | Release)
			ServerType=$param
		;;
		[1-9].[0-9].[0-9])
		# *.*.*)
			VersionCode=$param
		;;
		true | false)
			LuaIsEncode=$param
		;;
		-h | --help)
			main_usage;
			exit 1
		;;
		*)
			Description=$param
		;;
	esac
done
# 1.需要进行强制调整
if [[ $IPAType = "AppStore" ]]; then
	LuaIsEncode=true
	ServerType="Release"
fi
# 2.当前打包脚本路径
Basepath=$(cd `dirname $0`; pwd)
cd $Basepath

CopyEncodeShPath=$Basepath/copy+encode.sh
AutoPackShPath=$Basepath/autoPack.sh
# 3.进行资源复制，以及加密操作
sh $CopyEncodeShPath $LuaIsEncode

# 4.执行打包脚本
sh $AutoPackShPath $ServerType $VersionCode $IPAType $Description

cd $Basepath