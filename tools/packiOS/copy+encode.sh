# !/usr/bin
# 复制和加密资源脚本
# 当前脚本的全路径

# FUNCTION: copy_encode_usage
# DESCRIPTION:  Display copy_encode_usage information.
function copy_encode_usage() {
    cat << EOT
Usage : 
  copy resource[images,scripts,audio], and encoding lua file from given options.
Example:
  1) Use options to copy and resource:
  不加密：./copy+encode.sh false
  加密：./copy+encode.sh true
Options:
  -h, --help       Display this message
  false （Default）不加密文件
  true   加密lua文件 
Exit status:
  0   if OK,
  !=0 if serious problems.
EOT
	exit 1
}   
# ----------  end of function copy_encode_usage  ----------

# 目前mac 还不支持 res src文件加密打包
# exit 1

# set option values
LuaIsEncode=false
case $1 in
	-h | --help ) copy_encode_usage; exit 1;;
	true | false ) LuaIsEncode=$1;;
	# * ) echo "internal error!" ; exit 1 ;;
esac
# 0 脚本目录路径
Basepath=$(cd `dirname $0`; pwd)
cd $Basepath
cd ../../

# 资源打包加密程序路径，增加可执行权限
PackExePath="${PWD}/tools/pack/mac/packageIos"
chmod +x $PackExePath

exit 1

# 需要删除的平台源路劲 
ImagesPath="${PWD}/ios/images/oversea/_PF"
ScriptsPath="${PWD}/ios/scripts/oversea/app/config"
IOSPath="${PWD}/ios"

# 建立软链接的脚本路径
LinkShPath=$PWD/Resource/link.sh
#1 建立老德州仓库 与 全球包仓库overseas 对应的软链接
sh $LinkShPath
echo -e "LinkShPath=$LinkShPath"

# 移动到make目录下
cd make
#2 复制资源
BeginTime=`date '+%s'` #开始时间
# 执行复制资源py脚本
python sync_res_common.py ios $LuaIsEncode
EndTime=`date '+%s'` #结束时间
SpendTime=`expr $EndTime - $BeginTime`
echo -e "\033[32mcopy resource finished ! spend time:$SpendTime \033[0m"

# 删除图片资源：
function removePlatformImages(){
  rm -rf $ImagesPath/_P_R_$1
}

# 删除scripts资源：
function removePlatformScripts(){
  rm -rf ${ScriptsPath}/platRes/_P_R_$1
  rm -rf ${ScriptsPath}/lan/string_$1.lua
  rm -rf ${ScriptsPath}/application/ios_fb_$1
}

#删除一些不需要的地区资源
function removePlatformSRes(){
  # local deleteLanguage=(ar de en fr id it pt ru sp tr tl pl zw zwen)
  local deleteLanguage=(pl)
  for lan in ${deleteLanguage[@]}
  do
    removePlatformImages $lan
    removePlatformScripts $lan
  done
  echo -e "\033[32mremove resource finished ! \033[0m"
}
removePlatformSRes

# 删除选择服务器弹窗
function removeSwitchLangPop(){
  rm -rf $IOSPath/images/switchLangPop
  rm -rf $IOSPath/scripts/switchLangPop
}
# 6.5.0之后又开始加入其它地区的
# removeSwitchLangPop
cd $Basepath
