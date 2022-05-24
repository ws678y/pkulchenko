local function fn (description) 
	local description2,returns,args = description:match("(.+)%-%s*(%b())%s*(%b())")
	if not description2 then
		return {type="function",description=description,
			returns="(?)"} 
	end
	return {type="function",description=description2,
		returns=returns:gsub("^%s+",""):gsub("%s+$",""), args = args} 
end

local function val (description)
	return {type="value",description = description}
end
-- docs
local api = {
}
	
local keyw =
		[[int uint uchar ushort half float bool double size_t ptrdiff_t intptr_t uintptr_t void
		long ulong char short unsigned 
		half2 half4 half8 half16
		float2 float4 float8 float16
		double2 double4 double8 double16
		char2 char4 char8 char16
		uchar2 uchar4 uchar8 uchar16
		short2 short4 short8 short16
		ushort2 ushort4 ushort8 ushort16
		int2 int4 int8 int16
		uint2 uint4 uint8 uint16
		long2 long4 long8 long16
		ulong2 ulong4 ulong8 ulong16
		image2d_t image3d_t sampler_t event_t cl_image_format
		
		struct typedef void const
		return switch case for do while if else break continue volatile
		CLK_A CLK_R CLK_RG CLK_RGB CLK_RGBA CLK_ARGB CLK_BGRA CLK_INTENSITY CLK_LUMINANCE
		
		MAXFLOAT HUGE_VALF INFINITY NAN
		CLK_LOCAL_MEM_FENCE CLK_GLOBAL_MEM_FENCE 
		CLK_SNORM_INT8
		CLK_SNORM_INT16
		CLK_UNORM_INT8
		CLK_UNORM_INT16
		CLK_UNORM_SHORT_565
		CLK_UNORM_SHORT_555
		CLK_UNORM_SHORT_101010
		CLK_SIGNED_INT8
		CLK_SIGNED_INT16
		CLK_SIGNED_INT32
		CLK_UNSIGNED_INT8
		CLK_UNSIGNED_INT16
		CLK_UNSIGNED_INT32
		CLK_HALF_FLOAT
		CLK_FLOAT
		__FILE__ __LINE__ __OPENCL_VERSION__ __ENDIAN_LITTLE__ 
		__ROUNDING_MODE__ __IMAGE_SUPPORT__ __FAST_RELAXED_MATH__
		
		__kernel kernel __attribute__ __read_only __write_only read_only write_only
		__constant constant __local local __global global __private private
		vec_type_hint work_group_size_hint reqd_work_group_size
		aligned packed endian host device
		
		async_work_group_copy wait_group_events prefetch 
		clamp min max degrees radians sign smoothstep step mix
		mem_fence read_mem_fence write_mem_fence
		cross prod distance dot length normalize fast_distance fast_length fast_normalize
		read_image write_image get_image_width get_image_height get_image_depth
		get_image_channel_data_type get_image_channel_order
		get_image_dim
		abs abs_diff add_sat clz hadd mad24 mad_hi mad_sat
		mul24 mul_hi rhadd rotate sub_sat upsample
		
		isequal isnotequal isgreater isgreaterequal isless islessequal islessgreater
		isfinite isinf isnan isnormal isordered isunordered signbit any all bitselect select
		
		acos acosh acospi asin asinh asinpi atan atan2 atanh atanpi atan2pi
		cbrt ceil copysign cos half_cos native_cos cosh cospi half_divide native_divide
		erf erfc exp half_exp native_exp exp2 half_exp2 native_exp2 exp10 half_exp10 native_exp10
		expm1 fabs fdim floor fma fmax fmin fmod fract frexp hypot ilogb
		ldexp lgamma lgamma_r log half_log native_log log2 half_log2 native_log2
		log10 half_log10 native_log10 log1p logb mad modf nan nextafter
		pow pown powr half_powr native_powr half_recip native_recip
		remainder remquo rint round rootn rsqrt half_rsqrt native_rsqrt
		sin half_sin native_sin sincos sinh sinpi sqrt half_sqrt native_sqrt
		tan half_tan native_tan tanh tanpi tgamma trunc
		
		barrier 
		vload2 vload4 vload8 vload16
		vload_half vload_half2 vload_half4 vload_half8 vload_half16 vloada_half4 vloada_half8 vloada_half16
		vstore2 vstore4 vstore8 vstore16
		vstore_half vstore_half2 vstore_half4 vstore_half8 vstore_half16 vstorea_half4 vstorea_half8 vstorea_half16
		get_global_id get_global_size get_group_id get_local_id get_local_size get_num_groups get_work_dim 
]]

-- keywords - shouldn't be left out
for w in keyw:gmatch("([a-zA-Z_0-9]+)") do
	api[w] = {type="keyword"}
end

return api