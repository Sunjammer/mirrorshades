package mirrorshades.platform;

abstract Time(Void) {
    public static inline function now():UInt{
        return Std.int(haxe.Timer.stamp()*1000*1000);
    }
}