package starling.utils.memory 
{
	/**
	 * ...
	 * @author Oldes
	 */
	import flash.errors.MemoryError;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import starling.utils.memory.MemoryBlock;
	import flash.system.ApplicationDomain;
	import starling.utils.VectorUtil;

	public final class Memory 
	{
		private static var mInstance:Memory;
		private static var mMemory:ByteArray;
		public  static const mMemoryBlocks:Vector.<MemoryBlock> = new Vector.<MemoryBlock>;
		private static const mFreeAreaLengths:Vector.<uint> = new Vector.<uint>;
		private static const mFreeAreaPositions:Vector.<uint> = new Vector.<uint>;
		private static const DOMAIN_MEMORY_LENGTH:int = (86927 * 1024) - (Samorost3.sAchSounds ? 0: 22500000);
		
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
		public static function canAllocate(requiredLength:uint):Boolean {
			if (requiredLength == 0) requiredLength = 32;
			//trace("[MEMORY] ALLOCATE: " + requiredLength);
			var len:int = mFreeAreaLengths.length;
			var i:int = 0;
			while (i < len) {
				var blockLength:uint = mFreeAreaLengths[i];
				if (blockLength >= requiredLength) return true;
				i++;
			}
			return false;
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
			trace("[MEMORY] FAILED TO ALLOCATE: " + requiredLength);
			info();
			throw new MemoryError();
		}
		
		public static function allocateTail(requiredLength:uint):MemoryBlock {
			if (requiredLength == 0) requiredLength = 32;
			//trace("[MEMORY] ALLOCATE TAIL: " + requiredLength);
			var i:int = mFreeAreaLengths.length - 1;
			
			var blockLength:uint = mFreeAreaLengths[i];
			var position:uint = mFreeAreaPositions[i];
			if (blockLength >= requiredLength) {
				mFreeAreaLengths[i]   -= requiredLength;
				mFreeAreaPositions[i] += requiredLength;
				return new MemoryBlock(position, requiredLength);
			} else return allocate(requiredLength);
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
						mFreeAreaLengths[i]  += mFreeAreaLengths[i - 1] + bLength;
						mFreeAreaPositions.removeAt(i - 1);
						mFreeAreaLengths.removeAt(i - 1);
						//VectorUtil.removeUnsignedIntAt(mFreeAreaPositions, i - 1);
						//VectorUtil.removeUnsignedIntAt(mFreeAreaLengths, i - 1);
					} else {
						mFreeAreaPositions[i] = bPosition;
						mFreeAreaLengths[i]  += bLength;
					}
					block.release();
					return;
				} else if (tail < position) {
					mFreeAreaPositions.insertAt(i, bPosition);
					mFreeAreaLengths.insertAt(i, bLength);
					//VectorUtil.insertUnsignedIntAt(mFreeAreaPositions, i, bPosition);
					//VectorUtil.insertUnsignedIntAt(mFreeAreaLengths, i, bLength);
					block.release();
					return;
				}
				i++;
			}
		}
		public static function compactFree():void {
			CONFIG::LogEnabled { log("[MEMORY] Compacting free blocks if possible"); }
			var len:int = mFreeAreaPositions.length - 1;
			if (len == 0) return;
			//info();
			for (var i:int = 0; i < len; i++) {
				if (mFreeAreaPositions[i] + mFreeAreaLengths[i] == mFreeAreaPositions[i + 1]) {
					mFreeAreaPositions[i + 1] = mFreeAreaPositions[i];
					mFreeAreaLengths[i + 1] += mFreeAreaLengths[i];
					mFreeAreaLengths[i] = 0; //will be removed later
				}
			}
			//info();
			i = mFreeAreaPositions.length;
			while (i-->0) {
				if (mFreeAreaLengths[i] == 0) {
					mFreeAreaPositions.removeAt(i);
					mFreeAreaLengths.removeAt(i);
					//VectorUtil.removeUnsignedIntAt(mFreeAreaPositions, i);
					//VectorUtil.removeUnsignedIntAt(mFreeAreaLengths, i);
				}
			}
			CONFIG::LogEnabled { info(); }
			/*
			len = mFreeAreaPositions.length;
			if (len > 1) {
				var freePos:int = mFreeAreaPositions[0];
				var freeLen:int = mFreeAreaLengths[0];
				var n:int = mMemoryBlocks.length;
				trace("??? " + mMemoryBlocks.length);
				while (n-->0) {
					var block:MemoryBlock = mMemoryBlocks[n];
					//if(block.position > freePos && block.position 
					trace(mMemoryBlocks[n])
				}
				//for (i = 1; i < len; i++) {
					
				//	trace(">>> "+freePos+"       "+mFreeAreaPositions[i] + " / " + mFreeAreaLengths[i]);
				//}
			}*/
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
			log("[MEM] Free blocks:   " + len);
			while (len-->0) {
				log("[MEM]      block: " + mFreeAreaPositions[len] + " / " + mFreeAreaLengths[len]);
				free += mFreeAreaLengths[len];
			}
			log("[MEM] Free bytes:    " + free);
			log("[MEM] Used bytes:    " + (applicationDomain.domainMemory.length - free))
		}
		
		
		[Inline]
		public static function readUTF(position:uint):String {
			//trace("readUTF");
			mMemory.position = position;
			return mMemory.readUTF();
		}
	}

}