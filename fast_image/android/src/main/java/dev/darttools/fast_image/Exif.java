package dev.darttools.fast_image;

import androidx.exifinterface.media.ExifInterface;
import java.io.ByteArrayInputStream;
import java.io.IOException;

public class Exif {
    public static Integer getRotationDegrees(byte[] bytes){
        try {
            ExifInterface exif = new ExifInterface(new ByteArrayInputStream(bytes));
            return exif.getRotationDegrees();
        } catch (IOException e) {
            return 0;
        }
    }
}
