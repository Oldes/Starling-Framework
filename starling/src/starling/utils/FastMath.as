/*
 * This file was part of Apparat.
 * Modified for usage without Apparat by Oldes (2013)
 * 
 * Copyright (C) 2010 Joa Ebert
 * http://www.joa-ebert.com/
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */
package starling.utils {

	import avm2.intrinsics.memory.sf32;
	import avm2.intrinsics.memory.lf32;
	import avm2.intrinsics.memory.li32;
	import avm2.intrinsics.memory.si32;
	
	/**
	 * The FastMath class defines fast functions to work with Numbers.
	 *
	 * FastMath functions are inlined by ASC2. Trigonometric functions
	 * are only approximations. However all approximations should have an error
	 * less than <code>0.008</code>.
	 *
	 * @author Joa Ebert
	 * 
	 * NOTE: you must have initialised ApplicationDomain correctly with at least 4 first bytes available!
	 */
	public final class FastMath {
		/**
		 * Computes and returns the sine of the specified angle in radians.
		 *
		 * To calculate a radian, see the overview of the Math class.
		 *
		 * This method is only a fast sine approximation.
		 *
		 * @param angleRadians A number that represents an angle measured in radians.
		 * @return A number from -1.0 to 1.0.
		 */
		[Inline]
		static public function sin(angleRadians: Number): Number {
			//
			// http://lab.polygonal.de/wp-content/articles/fast_trig/fastTrig.as
			//

			angleRadians += (6.28318531 * Number(angleRadians < -3.14159265)) - 6.28318531 * Number(angleRadians > 3.14159265);
			var sign:Number = (1.0 - (int(angleRadians > 0.0) << 1));
			angleRadians = (angleRadians * (1.27323954 + sign * 0.405284735 * angleRadians));
			sign = (1.0 - (int(angleRadians < 0.0) << 1));
			return angleRadians * (sign * 0.225 * (angleRadians - sign) + 1.0);
		}
		/*
		static private const PI:Number = Math.PI;
		static private const B:Number =  4 / PI;
		static private const C:Number = -4 / (PI*PI);
		[Inline]
		static public function sin2(angleRadians: Number): Number {
			angleRadians %= PI;
			return B * angleRadians + C * angleRadians * (angleRadians<0?-angleRadians:angleRadians);
		}
		*/
		
		/**
		 * Computes and returns the cosine of the specified angle in radians.
		 *
		 * To calculate a radian, see the overview of the Math class.
		 *
		 * This method is only a fast cosine approximation.
		 *
		 * @param angleRadians A number that represents an angle measured in radians.
		 * @return A number from -1.0 to 1.0.
		 */
		[Inline]
		static public function cos(angleRadians: Number): Number {
			//
			// http://lab.polygonal.de/wp-content/articles/fast_trig/fastTrig.as
			//

			angleRadians += (6.28318531 * Number(angleRadians < -3.14159265)) - 6.28318531 * Number(angleRadians > 3.14159265);
			angleRadians += 1.57079632;
			angleRadians -= 6.28318531 * Number(angleRadians > 3.14159265);

			var sign:Number = (1.0 - (int(angleRadians > 0.0) << 1));
			angleRadians = (angleRadians * (1.27323954 + sign * 0.405284735 * angleRadians));
			sign = (1.0 - (int(angleRadians < 0.0) << 1));
			return angleRadians * (sign * 0.225 * (angleRadians - sign) + 1.0);
		}

		/**
		 * Computes and returns the angle of the point <code>y/x</code> in radians, when measured counterclockwise
		 * from a circle's <em>x</em> axis (where 0,0 represents the center of the circle).
		 * The return value is between positive pi and negative pi.
		 *
		 * @author Eugene Zatepyakin
		 * @author Joa Ebert
		 * @author Patrick Le Clec'h
		 *
		 * @param y A number specifying the <em>y</em> coordinate of the point.
		 * @param x A number specifying the <em>x</em> coordinate of the point.
		 *
		 * @return A number.
		 */
		[Inline]
		static public function atan2(y:Number, x:Number):Number {
			var sign:Number = 1.0 - (int(y < 0.0) << 1)
			var absYandR:Number = y * sign + 2.220446049250313e-16
			var partSignX:Number = (int(x < 0.0) << 1) // [0.0/2.0]
			var signX:Number = 1.0 - partSignX // [1.0/-1.0]
			absYandR = (x - signX * absYandR) / (signX * x + absYandR)
			return ((partSignX + 1.0) * 0.7853981634 + (0.1821 * absYandR * absYandR - 0.9675) * absYandR) * sign
		}

		/**
		 * Computes and returns an absolute value.
		 *
		 * @param value The number whose absolute value is returned.
		 * @return The absolute value of the specified parameter.
		 */
		[Inline]
		static public function abs(value: Number): Number {
			return value * (1.0 - (int(value < 0.0) << 1));
		}

		/**
		 * Computes and returns the sign of the value.
		 *
		 * @param value The number whose sign value is returned.
		 * @return The -1.0 if value<0.0 or 1.0 if value >=0.0 .
		 */
		[Inline]
		static public function sign(value: Number): Number {
			return (1.0 - (int(value < 0.0) << 1));
		}

		/**
		 * Returns the smallest value of the given parameters.
		 *
		 * @param value0 A number.
		 * @param value1 A number.
		 * @return The smallest of the parameters <code>value0</code> and <code>value1</code>.
		 */
		[Inline]
		static public function min(value0: Number, value1: Number): Number {
			var tmp:Number=Number(value0 < value1);
			return value0 * tmp +(1.0 - tmp) * value1; //(value0 < value1) ? value0 : value1
		}

		/**
		 * Returns the largest value of the given parameters.
		 *
		 * @param value0 A number.
		 * @param value1 A number.
		 * @return The largest of the parameters <code>value0</code> and <code>value1</code>.
		 */
		[Inline]
		static public function max(value0: Number, value1: Number): Number {
			var tmp:Number=Number(value0 > value1);
			return value0 * tmp + (1.0 - tmp) * value1; //(value0 > value1) ? value0 : value1
		}

		/**
		 * Computes and returns the square root of the specified number.
		 *
		 * <p><b>Note:</b>Calling this function will overwrite the first
		 * four bytes of the ApplicationDomain.domainMemory ByteArray. It is
		 * required that such a ByteArray exists.</p>
		 *
		 * @param value A number or expression greater than or equal to 0.
		 * @see initMemory
		 * @return If the parameter val is greater than or equal to zero, a number; otherwise NaN (not a number).
		 * @throws TypeError If no <code>ApplicationDomain.domainMemory</code> has been set.
		 */
		[Inline]
		static public function sqrt(value: Number): Number {
			var originalValue: Number = value
			var halfValue: Number = value * 0.5
			var i: int = 0

			if(value == 0.0) {
				return 0.0
			} else if(value < 0.0) {
				return Number.NaN
			}

			sf32(value, 0)
			i = 0x5f3759df - (li32(0) >> 1)
			si32(i, 0)
			value = lf32(0)

			return originalValue * value * (1.5 - halfValue * value * value)
		}

		/**
		 * Computes and returns the reciprocal of the square root for the specified number.
		 *
		 * <p><b>Note:</b>Calling this function will overwrite the first
		 * four bytes of the ApplicationDomain.domainMemory ByteArray. It is
		 * required that such a ByteArray exists.</p>
		 *
		 * @param value A number or expression greater than or equal to 0.
		 * @return If the parameter val is greater than or equal to zero, a number; otherwise NaN (not a number).
		 * @throws TypeError If no <code>ApplicationDomain.domainMemory</code> has been set.
		 */
		[Inline]
		static public function rsqrt(value: Number): Number {
			var halfValue: Number = value * 0.5
			var i: int = 0

			if(value == 0.0) {
				return 0.0
			} else if(value < 0.0) {
				return Number.NaN
			}

			sf32(value, 0)
			i = 0x5f3759df - (li32(0) >> 1)
			si32(i, 0)
			value = lf32(0)

			return value * (1.5 - halfValue * value * value)
  		}

		/**
		 * Computes and returns the square root of the specified number.
		 *
		 * The address parameter should be a pointer to a <code>char[4]</code> in
		 * the Alchemy memory buffer.
		 *
		 * @param value A number or expression greater than or equal to 0.
		 * @param address The address in the Alchemy memory buffer.
		 * @return If the parameter val is greater than or equal to zero, a number; otherwise NaN (not a number).
		 * @throws TypeError If no <code>ApplicationDomain.domainMemory</code> has been set.
		 */
		[Inline]
		static public function sqrt2(value: Number, address: int): Number {
			var originalValue: Number = value
			var halfValue: Number = value * 0.5
			var i: int = 0

			if(value == 0.0) {
				return 0.0
			} else if(value < 0.0) {
				return Number.NaN
			}

			sf32(value, address)
			i = 0x5f3759df - (li32(address) >> 1)
			si32(i, address)
			value = lf32(address)

			return originalValue * value * (1.5 - halfValue * value * value)
		}

		/**
		 * Computes and returns the reciprocal of the square root for the specified number.
		 *
		 * The address parameter should be a pointer to a <code>char[4]</code> in
		 * the Alchemy memory buffer.
		 *
		 * @param value A number or expression greater than or equal to 0.
		 * @param address The address in the Alchemy memory buffer.
		 * @return If the parameter val is greater than or equal to zero, a number; otherwise NaN (not a number).
		 * @throws TypeError If no <code>ApplicationDomain.domainMemory</code> has been set.
		 */
		[Inline]
		static public function rsqrt2(value: Number, address: int): Number {
			var halfValue: Number = value * 0.5
			var i: int = 0

			if(value == 0.0) {
				return 0.0
			} else if(value < 0.0) {
				return Number.NaN
			}

			sf32(value, address)
			i = 0x5f3759df - (li32(address) >> 1)
			si32(i, address)
			value = lf32(address)

			return value * (1.5 - halfValue * value * value)
  		}

		/**
		 * Integer cast with respect to its sign.
		 *
		 * @param value A number.
		 * @return The number casted to an integer with respect to its sign.
		 */
		[Inline]
		static public function rint(value: Number): int {
			return int(value + 0.5 - Number(value < 0));
		}

		/**
		 * Test if a Number is not a Number.
		 *
		 * @param value A number.
		 * @return true if value is not a Number.
		 */
		[Inline]
		static public function isNaN(n:Number):Boolean {
			return n != n;
		}
	}
}
