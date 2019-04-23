#!/usr/bin/env python
# -*- coding: UTF-8 -*-

# CavanZhou
# usage
# 1:安装 PIL
	# 打开cmd
	# 进入python的安装目录中的Scripts目录：
	# 输入pip install pillow 失败就用 easy_install Pillow
# 2: 拷贝需要还原的拼图的lua文件和png文件 与脚本在同一个目录 
# 3:运行 此脚本
# -- TexturePacker xx --data main-hd.plist --format cocos2d --sheet main-hd.png
import os
import sys
import os.path
import shutil
from PIL import Image


def copy_rename_path(path):

	if not os.path.isdir(path):
		print "这不是一个文件夹，请输入文件夹的正确路径!"
		return
	else:
		fromFilePath = path 			# 源路径

		for root, dirs, files in os.walk(fromFilePath):

			for name in files:

				fileName, fileSuffix = os.path.splitext(name)
				if fileSuffix == '.lua':
					clipAndSaveImg(root + "/" + fileName)	
					creat_cocos_pin_img(root + fileName,fileName)	

			#遍历其他文件夹目录			
			for name1 in dirs:
				if '.git'==name1 or '.gitignore'==name1 or '.vscode'==name1 or '.vs'==name1:
					pass
				else:
					copy_rename_path(root + '/' + name1)	
			break									
	
def clipAndSaveImg(path):

	pngPath = path + ".png"
	luaPath = path + ".lua"

	lua_pin_info = read_file_as_str(luaPath)	
	dirInfo = parasLuaFile(lua_pin_info)

	if not dirInfo:
		pass
	img = Image.open(pngPath) #打开当前路径图像
	savePath = path + "PinFiles" 

	folder = os.path.exists(savePath)
	if not folder:  
		os.makedirs(savePath)

	for key in dirInfo:
		dir1 = dirInfo[key]
		x = dir1["x"]
		y = dir1["y"]
		w = dir1["width"]
		h = dir1["height"]
		box1 = (x, y, x+w, y+h)    #设置图像裁剪区域
		image1 = img.crop(box1)   #图像裁剪
		image1.save(savePath + "/" + key)  #存储当前区域
				
def read_file_as_str(file_path):
    # 判断路径文件存在
    if not os.path.isfile(file_path):
        raise TypeError(file_path + " does not exist")

    all_the_text = open(file_path).read()
    print type(all_the_text)
    return all_the_text

def creat_cocos_pin_img(file_path,fileName):
	plistName = fileName + ".plist"
	imgName = fileName + ".png"
	cmd = "TexturePacker " + fileName + "PinFiles" + " --data " + plistName + " --format cocos2d --sheet " + imgName + " --max-size 1024"
	os.system(cmd) 
	

def parasLuaFile(str):
	
	zkSplitStr = "zkSplitStr"
	strArr = str.split('return') #去掉return

	if len(strArr) < 1:
		pass

	newStr = strArr[0]
	newStr = newStr.replace("]", "") # 去掉]
	newStr = newStr.replace("[", "") # 去掉[
	newStr = newStr.replace("{", zkSplitStr,1) 
	newStr = newStr.replace("=path", ":\"path\"") # 
	newStr = newStr.replace("file:", "\"file\":") # 
	newStr = newStr.replace("x=", "\"x\"=") # 
	newStr = newStr.replace("y=", "\"y\"=") # 
	newStr = newStr.replace("width=", "\"width\"=") # 
	newStr = newStr.replace("height=", "\"height\"=") # 
	newStr = newStr.replace("utWidth=", "\"utWidth\"=") # 
	newStr = newStr.replace("utHeight=", "\"utHeight\"=") # 
	newStr = newStr.replace("=", ":")

	strArr = newStr.split(zkSplitStr) 
	
	if len(strArr) < 2:
		pass

	newStr = "{" + strArr[1]
	newStr = ''.join(newStr.split())
	dictFR = eval(newStr)
	return dictFR


def run():
	copy_rename_path('./')	
	print "zkzk __complete__!!!!"

if __name__ == "__main__":
    run()

