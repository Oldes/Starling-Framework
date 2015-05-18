package starling.utils.memory 
{
	/**
	 * ...
	 * @author Oldes
	 */
	import flash.errors.MemoryError;
	import flash.utils.ByteArray;
	import flash.utils.Endian;;
	import starling.utils.memory.MemoryBlock;
	import flash.system.ApplicationDomain;

	public final class Memory 
	{
		private static var mInstance:Memory;
		private static var mMemory:ByteArray;
		public  static const mMemoryBlocks:Vector.<MemoryBlock> = new Vector.<MemoryBlock>;
		private static const mFreeAreaLengths:Vector.<uint> = new Vector.<uint>;
		private static const mFreeAreaPositions:Vector.<uint> = new Vector.<uint>;
		private static const DOMAIN_MEMORY_LENGTH:int = 59999232; //58593 * 1024
		
		/**
		 * The current application domain.
		 * @private
		 */
		private static const applicationDomain: ApplicationDomain = ApplicationDomain.currentDomain
		
		
		/** Returns an instance to the singleton Memory manager, creating one if needed. */
	/*	public static function get instance () :Memory {
			if (mInstance == null) {
				mInstance = new Memory(INITIAL_HEAP_SIZE, DEFAULT_DEBUG_OPTION);
			}
			return mInstance;
		}*/
		public function Memory (heapSize:uint=0) {
			mMemory = new ByteArray();
			if(heapSize == 0) heapSize = DOMAIN_MEMORY_LENGTH;
			mMemory.length = heapSize;
			mMemory.endian = Endian.LITTLE_ENDIAN;
			
			applicationDomain.domainMemory = mMemory;
			mFreeAreaLengths.length = 0;
			mFreeAreaPositions.length = 0;
			//first 1024 bytes are reserved
			mFreeAreaLengths[0] = heapSize - 1024; //length
			mFreeAreaPositions[0] = 1024;          //position
		}
		
		public static function allocate(requiredLength:uint):MemoryBlock {
			if (requiredLength == 0) requiredLength = 32;
			//trace("[MEMORY] ALLOCATE: " + requiredLength);
			var len:int = mFreeAreaLengths.length;
			var i:int = 0;
			while (i < len) {
				var blockLength:uint = mFreeAreaLengths[i];
				if (blockLength >= requiredLength) {
					var position:uint = mFreeAreaPositions[i];
					mFreeAreaLengths[i]   -= requiredLength;
					mFreeAreaPositions[i] += requiredLength;
					return new MemoryBlock(position, requiredLength);
				}
				i++;
			}
			throw new MemoryError();
		}
		
		public static function free(block:MemoryBlock):void {
			//trace("[MEMORY] FREE: " + block);
			//trace(mFreeAreaPositions);
			//trace(mFreeAreaLengths);
			//trace("----------------");
			var bPosition:uint = block.position;
			var bLength:uint = block.length;
			var tail:uint = bPosition + bLength;
			
			var len:int = mFreeAreaPositions.length;
			var i:int;
			while (i < len) {
				var position:uint = mFreeAreaPositions[i];
				if (tail == position) {
					if (i > 0 && mFreeAreaPositions[i-1]+mFreeAreaLengths[i-1]== bPosition) {
						mFreeAreaPositions[i] = mFreeAreaPositions[i-1];
						mFreeAreaLengths[i]  += mFreeAreaLengths[i - 1];
						mFreeAreaLengths.splice(i - 1, 1);
						mFreeAreaPositions.splice(i - 1, 1);
					} else {
						mFreeAreaPositions[i] = bPosition;
						mFreeAreaLengths[i]  += bLength;
					}
					block.position = block.length = 0;
					return;
				} else if (tail < position) {
					mFreeAreaPositions.splice(i, 0, bPosition);
					mFreeAreaLengths.splice(i, 0, bLength);
					block.position = block.length = 0;
					return;
				}
				i++;
			}
		}

		[Inline]
		public static function get position():uint {
			return mMemory.position;
		}
		[Inline]
		public static function set position(value:uint):void {
			mMemory.position = value;
		}
		[inline]
		public static function get heap():ByteArray {
			return mMemory;
		}
		
		public static function info():void {
			var free:uint;
			var len:int = mFreeAreaLengths.length;
			trace("Free blocks:   " + len);
			while (len-->0) {
				trace("     block: " + mFreeAreaPositions[len] + " / " + mFreeAreaLengths[len]);
				free += mFreeAreaLengths[len];
			}
			trace("Free bytes:    " + free);
			trace("Used bytes:    " + (applicationDomain.domainMemory.length - free))
		}
		
		
		[Inline]
		public static function readUTF(position:uint):String {
			//trace("readUTF");
			mMemory.position = position;
			return mMemory.readUTF();
		}
	}

}