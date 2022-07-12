package dev.darttools.fast_image;


import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;

import androidx.annotation.NonNull;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.lang.Math;
import java.util.ArrayList;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class ResizeImageHandler {
    public void handle(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        ArrayList<Object> args = (ArrayList<Object>) call.arguments;
        String filePath = (String) args.get(0);
        Integer width = (Integer) args.get(1);
        Integer height = (Integer) args.get(2);
        Integer quality = (Integer) args.get(3);
        String targetPath = (String) args.get(4);
        Integer rotate = (Integer) args.get(5);
        boolean autoCorrectionAngle = (boolean) args.get(6);

        Integer exifRotate = 0;
        if (autoCorrectionAngle) {

            byte[] bytes = new byte[0];
            try {
                bytes = ResizeImageHandler.readFileToBytes(filePath);
            } catch (IOException e) {
                e.printStackTrace();
                result.error("FastImageError", e.getMessage(), null);
                return;
            }
            exifRotate = Exif.getRotationDegrees(bytes);
        }

        if (exifRotate == 270 || exifRotate == 90) {
            Integer tmp = width;
            width = height;
            height = tmp;
        }

        Integer targetRotate = rotate + exifRotate;
        try {
            resize(filePath, targetPath, width, height, quality, targetRotate, 0);
            result.success(null);
        } catch (Exception e) {
            e.printStackTrace();
            result.error("FastImageError", e.getMessage(), null);
        }
    }

    private void resize(String path, String destinationPath, Integer width, Integer height, Integer quality, Integer rotate, int numberOfRetries) throws IOException, Exception {
        try {
            if(numberOfRetries == 5) throw new Exception("Failed to resize image after 5 retries");
            BitmapFactory.Options options = new BitmapFactory.Options();
            options.inJustDecodeBounds = false;
            options.inPreferredConfig = Bitmap.Config.RGB_565;
            options.inSampleSize = (int)Math.pow(2, numberOfRetries);
            if (android.os.Build.VERSION.SDK_INT < android.os.Build.VERSION_CODES.M) {

                options.inDither = true;
            }
            Bitmap bitmap = null;
            FileInputStream stream = null;
            try {
                stream = new FileInputStream(path);
                bitmap = BitmapFactory.decodeStream(stream, null, options);
                if(bitmap == null){
                    File file = new File(path);
                    long fileLength = file.length();
                    if(fileLength == 0) {
                        throw new Exception("File length is 0 when trying to decode bitmap.");
                    } else {
                        throw new Exception("File length is "+fileLength+" when trying to decode bitmap.");
                    }
                }
            } finally {
                if (stream != null) {
                    try {
                        stream.close();
                    } catch (IOException e) {
                        // do nothing here
                    }
                }
            }

            Integer w = bitmap.getWidth();
            Integer h = bitmap.getHeight();


            // System.out.println("src width = "+w);
            // System.out.println("src height = "+h);

            // System.out.println("input width = "+width);
            // System.out.println("input height = "+height);

            Integer intendedWidth = width;
            Integer intendedHeight = height;
            if (intendedWidth != null && intendedWidth > w) {
                intendedWidth = w;
                if (intendedHeight != null) {
                    intendedHeight = Math.round((height.floatValue() / width.floatValue()) * intendedWidth);
                }
            }
            if (intendedHeight != null && intendedHeight > h) {
                intendedHeight = h;
                if (intendedWidth != null) {
                    intendedWidth = Math.round((width.floatValue() / height.floatValue()) * intendedHeight);
                }
            }

            // System.out.println("intendedWidth = "+intendedWidth);
            // System.out.println("intendedHeight = "+intendedHeight);

            Integer newHeight = intendedHeight != null ? intendedHeight : Math.round((h.floatValue() / w.floatValue()) * intendedWidth);
            Integer newWidth = intendedWidth != null ? intendedWidth : Math.round((w.floatValue() / h.floatValue()) * newHeight);

            float scale = calcScale(bitmap.getWidth(), bitmap.getHeight(), newWidth, newHeight);

            float destW = w / scale;
            float destH = h / scale;

            // System.out.println("dst width = "+destW);
            // System.out.println("dst height = "+destH);

            if (newWidth.floatValue() / newHeight.floatValue() != w.floatValue() / h.floatValue()) {
                Integer targetX = Math.round(scale * (destW - newWidth) / 2);
                Integer targetY = Math.round(scale * (destH - newHeight) / 2);

                // System.out.println("targetX = "+targetX);
                // System.out.println("targetY = "+targetY);

                bitmap = Bitmap.createBitmap(bitmap, targetX, targetY, Math.round(scale * newWidth), Math.round(scale * newHeight));
            }

            byte[] array = compressBitmap(bitmap, newWidth, newHeight, quality, rotate);
            FileOutputStream fileOutputStream = new FileOutputStream(destinationPath);
            fileOutputStream.write(array);
            fileOutputStream.close();
        } catch (OutOfMemoryError error){//handling out of memory error and increase samples size
            System.gc();
            resize(path, destinationPath, width, height, quality, rotate, numberOfRetries + 1);
        }
    }

    private float calcScale(Integer width, Integer height, Integer minWidth, Integer minHeight) {

        float scaleW = width.floatValue() / minWidth.floatValue();
        float scaleH = height.floatValue() / minHeight.floatValue();

        // System.out.println("width scale = "+scaleW);
        // System.out.println("height scale = "+scaleH);

        return Math.max(1f, Math.min(scaleW, scaleH));
    }

    private byte[] compressBitmap(Bitmap bitmap, Integer minWidth, Integer minHeight, Integer quality, Integer rotate) throws IOException {
        Integer w = bitmap.getWidth();
        Integer h = bitmap.getHeight();

        // System.out.println("src width = "+w);
        // System.out.println("src height = "+h);

        float scale = calcScale(bitmap.getWidth(), bitmap.getHeight(), minWidth, minHeight);

        // System.out.println("scale = "+scale);

        Integer destW = Math.round(w.floatValue() / scale);
        Integer destH = Math.round(h.floatValue() / scale);

        // System.out.println("dst width = "+destW);
        // System.out.println("dst height = "+destH);

        bitmap = Bitmap.createScaledBitmap(bitmap, destW, destH, true);
        bitmap = rotateBitmap(bitmap, rotate);
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        bitmap.compress(Bitmap.CompressFormat.JPEG, quality, byteArrayOutputStream);
        byte[] result = byteArrayOutputStream.toByteArray();
        byteArrayOutputStream.close();
        return result;
    }

    private Bitmap rotateBitmap(Bitmap bitmap, Integer rotate) {
        if (rotate % 360 != 0) {
            Matrix matrix = new Matrix();
            matrix.setRotate(rotate.floatValue());
            return Bitmap.createBitmap(bitmap, 0, 0, bitmap.getWidth(), bitmap.getHeight(), matrix, false);
        } else {
            return bitmap;
        }
    }

    private static byte[] readFileToBytes(String filePath) throws IOException {

        File file = new File(filePath);
        byte[] bytes = new byte[(int) file.length()];

        try (FileInputStream fis = new FileInputStream(file)) {

            //read file into bytes[]
            fis.read(bytes);
            return bytes;

        }

    }
}
