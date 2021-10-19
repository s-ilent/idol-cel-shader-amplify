// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Silent/IdolCelShader"
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
		[HideInInspector] _texcoord2( "", 2D ) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Off
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


		float2 getMatcapUVs50_g18( float3 normal, float3 viewDir )
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
			float2 uv_NormalMap17_g18 = i.uv_texcoord;
			float3 newWorldNormal24_g18 = (WorldNormalVector( i , ( UnpackNormal( tex2D( _NormalMap, uv_NormalMap17_g18 ) ) * float3( 1,-1,1 ) ) ));
			float3 worldNormal34_g18 = newWorldNormal24_g18;
			float2 uv_ShadowTexture57_g18 = i.uv_texcoord;
			float4 tex2DNode57_g18 = tex2D( _ShadowTexture, uv_ShadowTexture57_g18 );
			float shadowDarkeningFresnel58_g18 = tex2DNode57_g18.a;
			float vertexColorMaskA59_g18 = i.vertexColor.a;
			float fresnelNdotV94_g18 = dot( normalize( worldNormal34_g18 ), ase_worldViewDir );
			float fresnelNode94_g18 = ( 0.0 + ( shadowDarkeningFresnel58_g18 * vertexColorMaskA59_g18 ) * pow( max( 1.0 - fresnelNdotV94_g18 , 0.0001 ), _RimScale1 ) );
			float2 uv_MainTex31_g18 = i.uv_texcoord;
			float4 tex2DNode31_g18 = tex2D( _MainTex, uv_MainTex31_g18 );
			float4 tex2DNode7_g18 = tex2D( _CheekMaskTexture, i.uv2_texcoord2 );
			float blushCheekNoseSwitch9_g18 = tex2DNode7_g18.a;
			float lerpResult15_g18 = lerp( _NoseRatio1 , _CheekRatio1 , blushCheekNoseSwitch9_g18);
			float blendCheek26_g18 = ( lerpResult15_g18 * tex2DNode7_g18.g );
			float4 lerpResult45_g18 = lerp( tex2DNode31_g18 , _CheekColor1 , blendCheek26_g18);
			float blendCheekObliqueLine39_g18 = ( lerpResult15_g18 * tex2DNode7_g18.b );
			float4 lerpResult54_g18 = lerp( lerpResult45_g18 , _CheekObliqueLineColor1 , blendCheekObliqueLine39_g18);
			float lerpResult28_g18 = lerp( _NoseHilightRatio1 , _CheekHilightRatio1 , blushCheekNoseSwitch9_g18);
			float blendCheekHilight47_g18 = ( lerpResult28_g18 * tex2DNode7_g18.r );
			float4 lerpResult63_g18 = lerp( lerpResult54_g18 , _CheekHilightColor1 , blendCheekHilight47_g18);
			#ifdef _USECHEEKMASK_ON
				float4 staticSwitch68_g18 = lerpResult63_g18;
			#else
				float4 staticSwitch68_g18 = tex2DNode31_g18;
			#endif
			float4 baseAlbedo82_g18 = staticSwitch68_g18;
			float4 rimContribution107_g18 = ( fresnelNode94_g18 * baseAlbedo82_g18 );
			float3 normal50_g18 = worldNormal34_g18;
			float3 viewDir50_g18 = ase_worldViewDir;
			float2 localgetMatcapUVs50_g18 = getMatcapUVs50_g18( normal50_g18 , viewDir50_g18 );
			float roughnessOrAlpha55_g18 = tex2DNode31_g18.a;
			float4 sphereMapContribution76_g18 = ( tex2D( _SphereMap, localgetMatcapUVs50_g18 ) * roughnessOrAlpha55_g18 );
			float4 lerpResult109_g18 = lerp( ( sphereMapContribution76_g18 + baseAlbedo82_g18 ) , ( baseAlbedo82_g18 + ( sphereMapContribution76_g18 * baseAlbedo82_g18 ) ) , _Metalness1);
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 normalizeResult4_g19 = normalize( ( ase_worldViewDir + ase_worldlightDir ) );
			float dotResult72_g18 = dot( worldNormal34_g18 , normalizeResult4_g19 );
			float saferPower77_g18 = max( dotResult72_g18 , 0.0001 );
			float shadowHairHilightMask73_g18 = tex2DNode57_g18.g;
			#ifdef _USEHAIRHILIGHT_ON
				float4 staticSwitch100_g18 = ( tex2D( _HairTexture, i.uv2_texcoord2 ) * pow( saferPower77_g18 , 5.0 ) * _HilightColor1 * shadowHairHilightMask73_g18 );
			#else
				float4 staticSwitch100_g18 = float4( 0,0,0,0 );
			#endif
			float4 hairHilightContribution105_g18 = staticSwitch100_g18;
			float4 diffuseColour118_g18 = ( rimContribution107_g18 + lerpResult109_g18 + hairHilightContribution105_g18 );
			float3 normal115_g18 = float4(0,0,0,1).xyz;
			float3 localSimpleIndirectDiffuseLight115_g18 = SimpleIndirectDiffuseLight( normal115_g18 );
			float3 litIndirect119_g18 = localSimpleIndirectDiffuseLight115_g18;
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 localindirectDir4_g18 = indirectDir();
			float3 indirectDir6_g18 = localindirectDir4_g18;
			float3 normal14_g18 = indirectDir6_g18;
			float3 localSimpleIndirectDiffuseLight14_g18 = SimpleIndirectDiffuseLight( normal14_g18 );
			float4 litDirect18_g18 = ( ase_lightColor + float4( localSimpleIndirectDiffuseLight14_g18 , 0.0 ) );
			float4 temp_output_125_0_g18 = ( litDirect18_g18 * diffuseColour118_g18 );
			float shadowDarkening79_g18 = tex2DNode57_g18.r;
			float grayscale37_g18 = Luminance(litDirect18_g18.rgb);
			float3 normalizeResult60_g18 = normalize( ( ( ase_lightColor.a * ase_worldlightDir ) + ( indirectDir6_g18 * grayscale37_g18 ) ) );
			float3 mergedLightDir69_g18 = normalizeResult60_g18;
			float dotResult89_g18 = dot( newWorldNormal24_g18 , mergedLightDir69_g18 );
			#ifdef _USEHAIRHILIGHT_ON
				float staticSwitch78_g18 = 0.0;
			#else
				float staticSwitch78_g18 = tex2DNode57_g18.g;
			#endif
			float shadowBrightening93_g18 = staticSwitch78_g18;
			float diffuseShading116_g18 = saturate( ( ( shadowDarkening79_g18 * dotResult89_g18 ) + _ShadingShift1 + shadowBrightening93_g18 ) );
			float2 temp_cast_4 = (( 1.0 - diffuseShading116_g18 )).xx;
			float4 lerpResult127_g18 = lerp( ( diffuseColour118_g18 * float4( litIndirect119_g18 , 0.0 ) ) , temp_output_125_0_g18 , tex2D( _CelShadowTable, temp_cast_4 ));
			float4 lerpResult129_g18 = lerp( lerpResult127_g18 , temp_output_125_0_g18 , diffuseShading116_g18);
			#ifdef UNITY_PASS_FORWARDBASE
				float4 staticSwitch136_g18 = lerpResult129_g18;
			#else
				float4 staticSwitch136_g18 = ( lerpResult129_g18 * ase_lightAtten );
			#endif
			c.rgb = ( 0.8 * staticSwitch136_g18 ).rgb;
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
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows noshadow novertexlights nolightmap  nodynlightmap nodirlightmap 

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
1549;801;1818;946;1299.172;907.1791;1;True;False
Node;AmplifyShaderEditor.FunctionNode;188;-694.5914,-385.2628;Inherit;False;IdolCelLighting;0;;18;a1be52503abdf5b4bba14a8388d9c7c5;0;0;2;FLOAT;152;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-241.4635,-612.8721;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Silent/IdolCelShader;False;False;False;False;False;True;True;True;True;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;16;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;0;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;True;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;0;13;188;0
ASEEND*/
//CHKSM=2A60B8E572DB727C6D236C66570D424789E0A09B