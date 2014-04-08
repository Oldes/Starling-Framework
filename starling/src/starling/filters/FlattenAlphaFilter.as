package starling.filters
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
 
	import starling.textures.Texture;
 
	public class FlattenAlphaFilter extends FragmentFilter
	{
		private var _constants:Vector.<Number> = new <Number>[1, 1, 1, 0];
		private var _program:Program3D;
		private var _alpha:Number;
 
		public function FlattenAlphaFilter(alpha:Number = 1)
		{
			_alpha = alpha;
		}
 
		override protected function createPrograms():void
		{
			_program = assembleAgal(
			"tex ft0, v0, fs0 <2d, clamp, linear, mipnone>" + "\n" +
			"mul ft0, ft0, fc0" + "\n" +
			"mov oc, ft0"
			);
		}
 
		override protected function activate(pass:int, context:Context3D, texture:Texture):void
		{
			_constants[3] = _alpha;
 
		//	context.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _constants, 1);
			context.setProgram(_program);
		}
 
		override protected function deactivate(pass:int, context:Context3D, texture:Texture):void
		{
			context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
		}
 
		override public function dispose():void
		{
			if (_program)
				_program.dispose();
			super.dispose();
		}
 
		public function get alpha():Number
		{
			return _alpha;
		}
 
		public function set alpha(value:Number):void
		{
			_alpha = value;
		}
	}
}