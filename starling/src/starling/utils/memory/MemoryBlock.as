package starling.utils.memory 
{
	/**
	 * ...
	 * @author Oldes
	 */
	public final class MemoryBlock 
	{
		private var mHead:uint;
		private var mTail:uint;
		public var level:String;
		public function MemoryBlock(head:uint, length:uint) 
		{
			mHead = head;
			mTail = head + length;
		}
		[Inline] public function get position():uint   { return mHead; }
		[Inline] public function get tail():uint   { return mTail; }
		[Inline] public function get length():uint { return mTail - mHead; }
		[Inline] public function release():void {
			mHead = mTail = 0;
		}
		public function toString(): String
		{
			return "[MemoryBlock position: " + mHead +", length: " + length + " "+ level + "]";
		}
	}

}