import os, inspect, sys, zipfile

#应用场景：Resource目录下的改动立即在android手机上看到效果，无需重新安装apk(只支持未提交的改动)
absPath = os.getcwd() + os.sep
key = ["\\src/","\\res/"]
isRoot = os.system("adb root")
isRemount = os.popen("adb remount").readlines()[0].find("succeed") != -1
config = {
	"zw" : "com.coalaa.itexaspro.cn",
	"tl" : "air.com.coalaa.itexasth",
	"id" : "air.com.coalaa.itexasid",
	"vn" : "air.com.coalaa.itexasvn",
    "ar" : "air.com.coalaa.itexasar",
	"fr" : "air.com.coalaa.itexasfr",
}
print("isRemount:", isRemount)

param = "zw"
if len(sys.argv) >= 2:
	param = sys.argv[1]

srcFiles = []

def pushFile(srcFile, desFile):
	cmd = "adb push " + srcFile + " " + desFile
	os.system(cmd.replace("\n", ""))
	#print(cmd)

def zipToSDCard(srcFiles):
	zf = zipfile.ZipFile("update.zip", "w", zipfile.zlib.DEFLATED)
	for srcFile in srcFiles:
		uri = "update/" + srcFile[INDEX + 4:]
		zf.write(srcFile, uri)
	zf.close()
	
	srcFile = os.getcwd() + os.sep + "update.zip"
	desFile = "/sdcard/." + config[param] + "/assets/update.zip"
	pushFile(srcFile, desFile)
	
	if os.path.exists(srcFile):
		os.remove(srcFile)

files = os.popen("git diff HEAD --name-status").readlines()
for v in files:
	arr = v.split()
	status = arr[0]
	if status == "D":
		continue
	
	srcFile = absPath + arr[1]
	index = srcFile.find(key[0])
	if  index != -1:
		INDEX = index
		srcFiles.append(srcFile)
	else:
		index = srcFile.find(key[1])
		if index != -1:
			INDEX = index
			srcFiles.append(srcFile)

if isRemount:
	for srcFile in srcFiles:
		fileName = srcFile[INDEX:].replace("\\", "/")
		desFile = "/data/data/" + config[param] + "/files/assets" + fileName
		pushFile(srcFile, desFile)
		#print(desFile)
else:
	zipToSDCard(srcFiles)