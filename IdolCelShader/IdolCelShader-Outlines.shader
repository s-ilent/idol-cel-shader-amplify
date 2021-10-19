// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Silent/IdolCelShader Outlines"
{
	Properties
	{
		[NoScaleOffset]_MainTex("Albedo", 2D) = "white" {}
		[NoScaleOffset]_CelShadowTable("LUT", 2D) = "white" {}
		[NoScaleOffset]_ShadowTexture("ShadowTexture", 2D) = "white" {}
		[NoScaleOffset]_NormalMap("Normal Map", 2D) = "bump" {}
		[NoScaleOffset]_SphereMap("SphereMap", 2D) = "black" {}
		_Metalness1("Metalness", Range( 0 , 1)) = 0
		_RimScale1("Rim Scale", Float) = 7.5
		[Header(Face Specific Features)][Toggle(_USECHEEKMASK_ON)] _UseCheekMask("Use Cheek Mask", Float) = 0
		[NoScaleOffset]_CheekMaskTexture("CheekMaskTexture", 2D) = "black" {}
		_CheekHilightColor1("CheekHilightColor", Color) = (0.973446,0.3467039,0.2622509,1)
		_CheekColor1("CheekColor", Color) = (1,0.708376,0.637597,1)
		_CheekObliqueLineColor1("CheekObliqueLineColor", Color) = (1,0.4178849,0.3324519,1)
		_CheekHilightRatio1("CheekHilightRatio", Range( 0 , 1)) = 0
		_NoseHilightRatio1("NoseHilightRatio", Range( 0 , 1)) = 0
		_CheekRatio1("CheekRatio", Range( 0 , 1)) = 0.6
		_NoseRatio1("NoseRatio", Range( 0 , 1)) = 0
		[Header(Hair Hilight)][Toggle(_USEHAIRHILIGHT_ON)] _UseHairHilight("Use Hair Hilight", Float) = 0
		[NoScaleOffset]_HairTexture("Hair Hilight Texture", 2D) = "black" {}
		_HilightColor1("HilightColor", Color) = (1,0.519674,0.429741,1)
		[Header(Other Junk)]_ShadingShift1("Shading Shift", Range( -1 , 1)) = 0
		_OutlineDistanceAdjust("Outline Distance Adjust", Vector) = (0.1,-0.1,0.2,1)
		_OutlineWidth("Outline Width", Float) = 0.1
		[HideInInspector] _texcoord2( "", 2D ) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Front
		AlphaToMask On
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma shader_feature_local _USEHAIRHILIGHT_ON
		#pragma shader_feature_local _USECHEEKMASK_ON
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
			float4 vertexColor : COLOR;
			float2 uv2_texcoord2;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float _OutlineWidth;
		uniform float4 _OutlineDistanceAdjust;
		uniform sampler2D _NormalMap;
		uniform sampler2D _ShadowTexture;
		uniform float _RimScale1;
		uniform sampler2D _MainTex;
		uniform float4 _CheekColor1;
		uniform float _NoseRatio1;
		uniform float _CheekRatio1;
		uniform sampler2D _CheekMaskTexture;
		uniform float4 _CheekObliqueLineColor1;
		uniform float4 _CheekHilightColor1;
		uniform float _NoseHilightRatio1;
		uniform float _CheekHilightRatio1;
		uniform sampler2D _SphereMap;
		uniform float _Metalness1;
		uniform sampler2D _HairTexture;
		uniform float4 _HilightColor1;
		uniform sampler2D _CelShadowTable;
		uniform float _ShadingShift1;


		float2 getMatcapUVs50_g20( float3 normal, float3 viewDir )
		{
			half3 worldUp = float3(0, 1, 0);
			half3 worldViewUp = normalize(worldUp - viewDir * dot(viewDir, worldUp));
			half3 worldViewRight = normalize(cross(viewDir, worldViewUp));
			return half2(dot(worldViewRight, normal), dot(worldViewUp, normal)) * 0.5 + 0.5;
		}


		float3 SimpleIndirectDiffuseLight( float3 normal )
		{
			return SHEvalLinearL0L1(float4(normal, 1.0));
		}


		float3 indirectDir(  )
		{
			return normalize(0.001 + unity_SHAr.xyz + unity_SHAg.xyz + unity_SHAb.xyz);
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertexNormal = v.normal.xyz;
			float4 ase_screenPos = ComputeScreenPos( UnityObjectToClipPos( v.vertex ) );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			v.vertex.xyz += ( _OutlineWidth * ase_vertexNormal * 0.01 * v.color.a * (_OutlineDistanceAdjust.z + (saturate( (0.0 + (ase_screenPosNorm.z - _OutlineDistanceAdjust.x) * (1.0 - 0.0) / (_OutlineDistanceAdjust.y - _OutlineDistanceAdjust.x)) ) - 0.0) * (_OutlineDistanceAdjust.w - _OutlineDistanceAdjust.z) / (1.0 - 0.0)) );
			v.vertex.w = 1;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float2 uv_NormalMap17_g20 = i.uv_texcoord;
			float3 newWorldNormal24_g20 = (WorldNormalVector( i , ( UnpackNormal( tex2D( _NormalMap, uv_NormalMap17_g20 ) ) * float3( 1,-1,1 ) ) ));
			float3 worldNormal34_g20 = newWorldNormal24_g20;
			float2 uv_ShadowTexture57_g20 = i.uv_texcoord;
			float4 tex2DNode57_g20 = tex2D( _ShadowTexture, uv_ShadowTexture57_g20 );
			float shadowDarkeningFresnel58_g20 = tex2DNode57_g20.a;
			float vertexColorMaskA59_g20 = i.vertexColor.a;
			float fresnelNdotV94_g20 = dot( normalize( worldNormal34_g20 ), ase_worldViewDir );
			float fresnelNode94_g20 = ( 0.0 + ( shadowDarkeningFresnel58_g20 * vertexColorMaskA59_g20 ) * pow( max( 1.0 - fresnelNdotV94_g20 , 0.0001 ), _RimScale1 ) );
			float2 uv_MainTex31_g20 = i.uv_texcoord;
			float4 tex2DNode31_g20 = tex2D( _MainTex, uv_MainTex31_g20 );
			float4 tex2DNode7_g20 = tex2D( _CheekMaskTexture, i.uv2_texcoord2 );
			float blushCheekNoseSwitch9_g20 = tex2DNode7_g20.a;
			float lerpResult15_g20 = lerp( _NoseRatio1 , _CheekRatio1 , blushCheekNoseSwitch9_g20);
			float blendCheek26_g20 = ( lerpResult15_g20 * tex2DNode7_g20.g );
			float4 lerpResult45_g20 = lerp( tex2DNode31_g20 , _CheekColor1 , blendCheek26_g20);
			float blendCheekObliqueLine39_g20 = ( lerpResult15_g20 * tex2DNode7_g20.b );
			float4 lerpResult54_g20 = lerp( lerpResult45_g20 , _CheekObliqueLineColor1 , blendCheekObliqueLine39_g20);
			float lerpResult28_g20 = lerp( _NoseHilightRatio1 , _CheekHilightRatio1 , blushCheekNoseSwitch9_g20);
			float blendCheekHilight47_g20 = ( lerpResult28_g20 * tex2DNode7_g20.r );
			float4 lerpResult63_g20 = lerp( lerpResult54_g20 , _CheekHilightColor1 , blendCheekHilight47_g20);
			#ifdef _USECHEEKMASK_ON
				float4 staticSwitch68_g20 = lerpResult63_g20;
			#else
				float4 staticSwitch68_g20 = tex2DNode31_g20;
			#endif
			float4 baseAlbedo82_g20 = staticSwitch68_g20;
			float4 rimContribution107_g20 = ( fresnelNode94_g20 * baseAlbedo82_g20 );
			float3 normal50_g20 = worldNormal34_g20;
			float3 viewDir50_g20 = ase_worldViewDir;
			float2 localgetMatcapUVs50_g20 = getMatcapUVs50_g20( normal50_g20 , viewDir50_g20 );
			float roughnessOrAlpha55_g20 = tex2DNode31_g20.a;
			float4 sphereMapContribution76_g20 = ( tex2D( _SphereMap, localgetMatcapUVs50_g20 ) * roughnessOrAlpha55_g20 );
			float4 lerpResult109_g20 = lerp( ( sphereMapContribution76_g20 + baseAlbedo82_g20 ) , ( baseAlbedo82_g20 + ( sphereMapContribution76_g20 * baseAlbedo82_g20 ) ) , _Metalness1);
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 normalizeResult4_g21 = normalize( ( ase_worldViewDir + ase_worldlightDir ) );
			float dotResult72_g20 = dot( worldNormal34_g20 , normalizeResult4_g21 );
			float saferPower77_g20 = max( dotResult72_g20 , 0.0001 );
			float shadowHairHilightMask73_g20 = tex2DNode57_g20.g;
			#ifdef _USEHAIRHILIGHT_ON
				float4 staticSwitch100_g20 = ( tex2D( _HairTexture, i.uv2_texcoord2 ) * pow( saferPower77_g20 , 5.0 ) * _HilightColor1 * shadowHairHilightMask73_g20 );
			#else
				float4 staticSwitch100_g20 = float4( 0,0,0,0 );
			#endif
			float4 hairHilightContribution105_g20 = staticSwitch100_g20;
			float4 diffuseColour118_g20 = ( rimContribution107_g20 + lerpResult109_g20 + hairHilightContribution105_g20 );
			float3 normal115_g20 = float4(0,0,0,1).xyz;
			float3 localSimpleIndirectDiffuseLight115_g20 = SimpleIndirectDiffuseLight( normal115_g20 );
			float3 litIndirect119_g20 = localSimpleIndirectDiffuseLight115_g20;
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 localindirectDir4_g20 = indirectDir();
			float3 indirectDir6_g20 = localindirectDir4_g20;
			float3 normal14_g20 = indirectDir6_g20;
			float3 localSimpleIndirectDiffuseLight14_g20 = SimpleIndirectDiffuseLight( normal14_g20 );
			float4 litDirect18_g20 = ( ase_lightColor + float4( localSimpleIndirectDiffuseLight14_g20 , 0.0 ) );
			float4 temp_output_125_0_g20 = ( litDirect18_g20 * diffuseColour118_g20 );
			float shadowDarkening79_g20 = tex2DNode57_g20.r;
			float grayscale37_g20 = Luminance(litDirect18_g20.rgb);
			float3 normalizeResult60_g20 = normalize( ( ( ase_lightColor.a * ase_worldlightDir ) + ( indirectDir6_g20 * grayscale37_g20 ) ) );
			float3 mergedLightDir69_g20 = normalizeResult60_g20;
			float dotResult89_g20 = dot( newWorldNormal24_g20 , mergedLightDir69_g20 );
			#ifdef _USEHAIRHILIGHT_ON
				float staticSwitch78_g20 = 0.0;
			#else
				float staticSwitch78_g20 = tex2DNode57_g20.g;
			#endif
			float shadowBrightening93_g20 = staticSwitch78_g20;
			float diffuseShading116_g20 = saturate( ( ( shadowDarkening79_g20 * dotResult89_g20 ) + _ShadingShift1 + shadowBrightening93_g20 ) );
			float2 temp_cast_4 = (( 1.0 - diffuseShading116_g20 )).xx;
			float4 lerpResult127_g20 = lerp( ( diffuseColour118_g20 * float4( litIndirect119_g20 , 0.0 ) ) , temp_output_125_0_g20 , tex2D( _CelShadowTable, temp_cast_4 ));
			float4 lerpResult129_g20 = lerp( lerpResult127_g20 , temp_output_125_0_g20 , diffuseShading116_g20);
			#ifdef UNITY_PASS_FORWARDBASE
				float4 staticSwitch136_g20 = lerpResult129_g20;
			#else
				float4 staticSwitch136_g20 = ( lerpResult129_g20 * ase_lightAtten );
			#endif
			c.rgb = ( 0.8 * staticSwitch136_g20 ).rgb;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows noshadow novertexlights nolightmap  nodynlightmap nodirlightmap vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			AlphaToMask Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float4 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				half4 color : COLOR0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.customPack1.zw = customInputData.uv2_texcoord2;
				o.customPack1.zw = v.texcoord1;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.color = v.color;
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				surfIN.uv2_texcoord2 = IN.customPack1.zw;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				surfIN.vertexColor = IN.color;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18909
1904;1195;1818;946;1626.927;145.3759;1;True;False
Node;AmplifyShaderEditor.ScreenPosInputsNode;197;-1528.372,137.8301;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;204;-1529.927,319.6241;Inherit;False;Property;_OutlineDistanceAdjust;Outline Distance Adjust;23;0;Create;True;0;0;0;False;0;False;0.1,-0.1,0.2,1;0.1,-0.1,0.2,1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;203;-1260.396,261.1858;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;205;-1084.927,260.6241;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;190;-930.172,-185.1791;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;193;-920.172,-29.17908;Inherit;False;Constant;_Float1;Float 1;1;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;189;-926.172,47.82092;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;191;-906.172,-287.1791;Inherit;False;Property;_OutlineWidth;Outline Width;24;0;Create;True;0;0;0;False;0;False;0.1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;206;-941.9268,257.6241;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;192;-725.172,-243.1791;Inherit;False;5;5;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;199;-715.5914,-391.2628;Inherit;False;IdolCelLighting;0;;20;a1be52503abdf5b4bba14a8388d9c7c5;0;0;2;FLOAT;152;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-241.4635,-612.8721;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Silent/IdolCelShader Outlines;False;False;False;False;False;True;True;True;True;False;False;False;False;False;False;False;False;False;False;False;False;Front;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;16;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;0;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;True;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;203;0;197;3
WireConnection;203;1;204;1
WireConnection;203;2;204;2
WireConnection;205;0;203;0
WireConnection;206;0;205;0
WireConnection;206;3;204;3
WireConnection;206;4;204;4
WireConnection;192;0;191;0
WireConnection;192;1;190;0
WireConnection;192;2;193;0
WireConnection;192;3;189;4
WireConnection;192;4;206;0
WireConnection;0;13;199;0
WireConnection;0;11;192;0
ASEEND*/
//CHKSM=21EAB42F6CEA6D7B4FEC53D2EA350454C6DB70F2