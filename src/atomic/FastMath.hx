package atomic;
import atomic.FastMath.LUT;
import haxe.ds.Vector;

class FastMath
{

	public static inline function abs(num:Float):Float {
		return (num<0?-num:num);
	}
	public static inline function max(num1:Float, num2:Float):Float {
		return (num1>num2?num1:num2);
	}
	public static inline function roundTo(num:Float, round:Float):Float{
		return Math.round(num / round) * round;
	}
	public static inline function isNaN(val:Float): Bool {
		#if flash
		return val != val;
		#else
		return Math.isNaN(val);
		#end
	}
	
	static private var sqrtTable:LUT;
	static private var cosTable:LUT;
	static private var sinTable:LUT;
	
	static inline var PI:Float = 3.14159265359;
	static inline var PI2:Float = PI * 2;
	static inline var PIH:Float = PI / 2;
	
	public static function sqrt(num:Float):Float {
		if (sqrtTable == null) sqrtTable = new LUT(2, 100, Math.sqrt);
		return sqrtTable.val(num);
	}
	public static function sin(num:Float):Float {
		if (sinTable == null) sinTable = new LUT(3, PI2, Math.sin);
		return sinTable.val(loopRadians(num));
	}
	public static function cos(num:Float):Float {
		//if (cosTable == null) cosTable = new LUT(3, PI2, Math.cos);
		//return cosTable.val(loopRadians(num));
		
		return sin(num + PIH);
	}
	
	private static inline function loopRadians(num:Float):Float{
		while (num < 0) num += PI2;
		if (num > PI2) num %= PI2;
		return num;
	}
}

class LUT
{
	/** Table of function values*/
	public var table:Vector<Float>;

	/** 10^decimals of precision*/
	public var pow:Float;

	/**
	*   Make the look up table
	*   @param numDigits Number of digits places of precision
	*   @param max Maximum value to cache
	*   @param func Function to call to generate stored values.
	*               Must be valid on [0,max).
	* 
	*   @throws Error If func is null or invalid on [0,max)
	*/
	public function new(numDigits:Int, max:Float, func:Float->Float)
	{
		var pow:Float = Math.pow(10, numDigits);
		this.pow = pow;
		var round:Float = 1.0 / pow;
		var len:Int = Std.int(1 + max*pow);
		var table:Vector<Float> = this.table = new Vector<Float>(len);

		var val:Float = 0;
		for (i in 0 ... len)
		{
			table[i] = func(val);
			val += round;
		}
	}

	/**
	*   Look up the value of the given input
	*   @param val Input value to look up the value of
	*   @return The value of the given input
	*/
	public inline function val(val:Float): Float
	{
		return this.table[Std.int(val*this.pow)];
	}
}