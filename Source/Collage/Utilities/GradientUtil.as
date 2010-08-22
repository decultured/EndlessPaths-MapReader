package Collage.Utilities
{
	import Collage.Utilities.Logger.*;
	import com.adobe.serialization.json.JSON;

	// alpha: elem.alpha,
	// color: elem.color,
	// ratio: elem.ratio

	public class GradientUtil
	{
		public static function FindColorValue(gradientArray:Array, value:Number, minVal:Number, maxVal:Number):Object
		{
			var result:Object = new Object();
			if (!gradientArray || !gradientArray.length) {
				result.color = 0x000000;
				result.alpha = 1.0;
			} else {
				result.color = gradientArray[0].color;
				result.alpha = gradientArray[0].alpha;
			}
			
			if (maxVal <= minVal || !gradientArray || gradientArray.length < 2)
				return result;
			
			var numColors:uint = gradientArray.length;
			var ratio:Number = (value - minVal) / (maxVal - minVal);

			var startRatio:Number = 0;
			var endRatio:Number = 1;
			var startIndex:int = -1;
			var endIndex:int = -1;

			var curRatio:Number = 0;
			for (var i:uint = 0; i < numColors; i++) {

				Logger.Log(JSON.encode(gradientArray[i]) + " Gradient Ratio: " + gradientArray[i].ratio + " color: " + gradientArray[i].color + " alpha: " + gradientArray[i].alpha);

				curRatio = gradientArray[i].ratio;
				
				if (curRatio == ratio) {
					result.color = gradientArray[i].color;
					result.alpha = gradientArray[i].alpha;
					return result;
				} else if (curRatio < ratio && curRatio >= startRatio) {
					startRatio = startRatio;
					startIndex = i;
				} else if (curRatio > ratio && curRatio <= endRatio) {
					endRatio = curRatio;
					endIndex = i;
				}
			}
			
			if (startIndex < 0 && endIndex < 0) {
				return result;
			} else if (startIndex < 0) {
				result.color = gradientArray[endIndex].color;
				result.alpha = gradientArray[endIndex].alpha;
				return result;
			} else if (endIndex < 0) {
				result.color = gradientArray[startIndex].color;
				result.alpha = gradientArray[startIndex].alpha;
				return result;
			} else {
				result.color = InterpolateColor(ratio, startRatio, endRatio, gradientArray[startIndex].color, gradientArray[endIndex].color);
				result.alpha = InterpolateAlpha(ratio, startRatio, endRatio, gradientArray[startIndex].alpha, gradientArray[endIndex].alpha);
				return result;
			}
			
			return result;
		}
		
		public static function InterpolateColor(value:Number, minVal:Number, maxVal:Number, minColor:Number, maxColor:Number):Number {
			if (maxVal - minVal <= 0 || value - minVal <= 0) return minColor;
			
			var percent:Number = (value - minVal) / (maxVal - minVal);
			
			var r1:Number = (minColor >> 16 ) & 0xff;
			var g1:Number = (minColor >> 8 ) & 0xff;
			var b1:Number = (minColor & 0xff);

			var r2:Number = (maxColor >> 16 ) & 0xff;
			var g2:Number = (maxColor >> 8 ) & 0xff;
			var b2:Number = (maxColor & 0xff);
			
			r1 = (r2 - r1) * percent + r1;
			g1 = (g2 - g1) * percent + g1;
			b1 = (b2 - b1) * percent + b1;
			return (r1 << 16 | g1 << 8 | b1);
		}
		
		public static function InterpolateAlpha(value:Number, minVal:Number, maxVal:Number, minAlpha:Number, maxAlpha:Number):Number {
			if (maxVal - minVal <= 0 || value - minVal <= 0) return minAlpha;
			var percent:Number = (value - minVal) / (maxVal - minVal);
			return (maxAlpha - minAlpha) * percent + minAlpha;
		}
	}
}