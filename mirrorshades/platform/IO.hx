package mirrorshades.platform;
import sys.io.File;
class IO{
    public static function dump(data:String, path:String){
        File.saveContent(path, data);
    }
}