/*
 * Copyright 2014 http://Bither.net
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package net.bither.util;

import android.graphics.Bitmap;
import android.graphics.Bitmap.Config;
import android.graphics.Canvas;
import android.graphics.Rect;
import android.os.Build;
import android.util.Log;

import java.io.File;

public class NativeUtil {
	private static int DEFAULT_QUALITY = 100;

	/**
	 *
	 * @param bitmap
	 * @param optimize
	 * @param compressScale 原始图片宽高缩小的比例
	 */
	public static void compressImageFile(Bitmap bitmap, String outPath,
                                         boolean optimize, int compressScale) {
		if(compressScale <= 1) {
			compressBitmap(bitmap, outPath, DEFAULT_QUALITY, optimize);
		} else {
			compressBitmap(bitmap, outPath, DEFAULT_QUALITY, optimize,compressScale);
		}
	}

	public static void compressBitmap(Bitmap bit, String outPath, int quality, boolean optimize) {
		int compressScale =1;
		int w = bit.getWidth();
		int h = bit.getHeight();
		// 现在主流手机比较多是800*480分辨率，所以高和宽我们设置为
		float hh = 480f;// 这里设置高度为480f
		float ww = 800f;// 这里设置宽度为800f
		if (w / ww >= 1 || h / hh >= 1) {
			if (w / ww > h / hh) {
				compressScale = (int) (w / ww);
				if(w%ww !=0 ) {
					compressScale ++;
				}
			} else {
				compressScale = (int) (h / hh);
				if(h%hh !=0 ) {
					compressScale ++;
				}
			}
		}
				compressBitmap(bit, outPath, quality,  optimize,compressScale);

	}


	/**
	 * 获取图片大小
	 * @param bitmap
	 * @return
	 */
	public static long getBitmapsize(Bitmap bitmap){

		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB_MR1) {
			return bitmap.getByteCount();
		}
		// Pre HC-MR1
		return bitmap.getRowBytes() * bitmap.getHeight();

	}

	/**
	 * 压缩
	 * @param bit
	 * @param quality
	 * @param optimize
	 * @param compressScale
	 */
	public static void compressBitmap(Bitmap bit, String outPath, int quality,
                                      boolean optimize, int compressScale) {
		Log.d("native", "compress of native" + compressScale);

//		if (bit.getConfig() != Config.ARGB_8888) {
			Bitmap result = null;
			File file = new File(outPath);
			if(file.exists()) {
				file.delete();
			}

			result = Bitmap.createBitmap(bit.getWidth() / compressScale,
					bit.getHeight() / compressScale, Config.ARGB_8888);// 缩小3倍
			Canvas canvas = new Canvas(result);
			Rect rect = new Rect(0, 0, bit.getWidth(), bit.getHeight());// original
			rect = new Rect(0, 0, bit.getWidth() / compressScale,
					bit.getHeight() / compressScale);// 缩小3倍
			canvas.drawBitmap(bit, null, rect, null);
			saveBitmap(result, quality, outPath, optimize);
			result.recycle();
//		} else {
//			saveBitmap(bit, quality, fileName, optimize);
//		}

	}

	private static void saveBitmap(Bitmap bit, int quality, String fileName,
                                   boolean optimize) {
		Log.v("compress", compressBitmap(bit, bit.getWidth(), bit.getHeight(), quality,
				fileName.getBytes(), optimize));
	}

	/**
	 *
	 * @param bit 需要压缩的bitmap
	 * @param w
	 * @param h
	 * @param quality   压缩质量
	 * @param fileNameBytes 压缩后图片保存的路径
	 * @param optimize
	 * @return
	 */
	private static native String compressBitmap(Bitmap bit, int w, int h,
                                                int quality, byte[] fileNameBytes, boolean optimize);

	static {
		System.loadLibrary("jpegbither");
		System.loadLibrary("bitherjni");
	}

}
