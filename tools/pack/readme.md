## 一，简介
	此工具主要功能如下：
	1，把小图拼成大图，减少 draw call ，提高运行速度（注意，不包含拼图和 unpackImages.xml 里配置的 png 图片）
	2，加密 png 图片
	3，加密 plist，ccreator 文件并合并这些文件，提高运行速度
	4，加密 lua 文件并打包成一个文件


## 二，环境
   1，安装TexturePacker
   2，添加路径到环境变量 path 里去
   3，工具位于 tools\pack 目录下

## 三，打包
### win32
#### 打包图集 和 lua 代码
	
	package -projectPath ..\..\ -packImage -packLua

#### 只打包图集
	package -projectPath ..\..\ -packImage

#### 只打包lua代码
	package -projectPath ..\..\ -packLua

#### 只加密lua代码
	package -projectPath 指定目录 -encodeLua
	并且次目录下有src目录，lua代码需要放在这个目录下
	生成后会在该目录下的out目录里

### mac
    sudo ./packageIos -projectPath /Users/kv/Desktop/ipoke_cocos/IPoker_cocos -packImage -packLua

## 四，输出目录
   会输出在项目路径下的 out 目录下
## 五，使用
   将gradle.properties里USE_PACK_RES=true注释放开
   运行项目即可
