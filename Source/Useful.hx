class Useful {
    public static function lerp(a:Float, b:Float, p:Float) {
        return a + (b - a) * p;
    }

    public static function lerpXY(x1:Float, y1:Float, x2:Float, y2:Float, p:Float) {
        return {x:lerp(x1, x2, p), y:lerp(y1, y2, p)};
    }
}