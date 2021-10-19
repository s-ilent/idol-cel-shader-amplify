// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Silent/IdolCelShader Cutout"
{
	Properties
	{
		[NoScaleOffset]_MainTex("Albedo", 2D) = "white" {}
		[NoScaleOffset]_CelShadowTable("LUT", 2D) = "white" {}
		[NoScaleOffset]_ShadowTexture("ShadowTexture", 2D) = "white" {}
		[NoScaleOffset]_NormalMap("Normal Map", 2D) = "bump" {}
		[NoScaleOffset]_SphereMap("SphereMap", 2D) = "black" {}
		[ToggleUI]_UseTextureAlphaForOpacityMask1("UseTextureAlphaForOpacityMask", Float) = 0
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
		_Cutout("Cutout", Range( 0 , 1)) = 0.2
		[HideInInspector] _texcoord2( "", 2D ) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "AlphaTest+0" }
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
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
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

		uniform float _Cutout;
		uniform float _UseTextureAlphaForOpacityMask1;
		uniform sampler2D _MainTex;
		uniform sampler2D _ShadowTexture;
		uniform sampler2D _NormalMap;
		uniform float _RimScale1;
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


		float2 getMatcapUVs50_g22( float3 normal, float3 viewDir )
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
			float2 uv_MainTex31_g22 = i.uv_texcoord;
			float4 tex2DNode31_g22 = tex2D( _MainTex, uv_MainTex31_g22 );
			float roughnessOrAlpha55_g22 = tex2DNode31_g22.a;
			float2 uv_ShadowTexture57_g22 = i.uv_texcoord;
			float4 tex2DNode57_g22 = tex2D( _ShadowTexture, uv_ShadowTexture57_g22 );
			#ifdef _USEHAIRHILIGHT_ON
				float staticSwitch78_g22 = 0.0;
			#else
				float staticSwitch78_g22 = tex2DNode57_g22.g;
			#endif
			float shadowBrightening93_g22 = staticSwitch78_g22;
			float temp_output_190_152 = ( _UseTextureAlphaForOpacityMask1 >= 1.0 ? roughnessOrAlpha55_g22 : shadowBrightening93_g22 );
			float smoothstepResult198 = smoothstep( _Cutout , ( _Cutout + fwidth( temp_output_190_152 ) ) , temp_output_190_152);
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float2 uv_NormalMap17_g22 = i.uv_texcoord;
			float3 newWorldNormal24_g22 = (WorldNormalVector( i , ( UnpackNormal( tex2D( _NormalMap, uv_NormalMap17_g22 ) ) * float3( 1,-1,1 ) ) ));
			float3 worldNormal34_g22 = newWorldNormal24_g22;
			float shadowDarkeningFresnel58_g22 = tex2DNode57_g22.a;
			float vertexColorMaskA59_g22 = i.vertexColor.a;
			float fresnelNdotV94_g22 = dot( normalize( worldNormal34_g22 ), ase_worldViewDir );
			float fresnelNode94_g22 = ( 0.0 + ( shadowDarkeningFresnel58_g22 * vertexColorMaskA59_g22 ) * pow( max( 1.0 - fresnelNdotV94_g22 , 0.0001 ), _RimScale1 ) );
			float4 tex2DNode7_g22 = tex2D( _CheekMaskTexture, i.uv2_texcoord2 );
			float blushCheekNoseSwitch9_g22 = tex2DNode7_g22.a;
			float lerpResult15_g22 = lerp( _NoseRatio1 , _CheekRatio1 , blushCheekNoseSwitch9_g22);
			float blendCheek26_g22 = ( lerpResult15_g22 * tex2DNode7_g22.g );
			float4 lerpResult45_g22 = lerp( tex2DNode31_g22 , _CheekColor1 , blendCheek26_g22);
			float blendCheekObliqueLine39_g22 = ( lerpResult15_g22 * tex2DNode7_g22.b );
			float4 lerpResult54_g22 = lerp( lerpResult45_g22 , _CheekObliqueLineColor1 , blendCheekObliqueLine39_g22);
			float lerpResult28_g22 = lerp( _NoseHilightRatio1 , _CheekHilightRatio1 , blushCheekNoseSwitch9_g22);
			float blendCheekHilight47_g22 = ( lerpResult28_g22 * tex2DNode7_g22.r );
			float4 lerpResult63_g22 = lerp( lerpResult54_g22 , _CheekHilightColor1 , blendCheekHilight47_g22);
			#ifdef _USECHEEKMASK_ON
				float4 staticSwitch68_g22 = lerpResult63_g22;
			#else
				float4 staticSwitch68_g22 = tex2DNode31_g22;
			#endif
			float4 baseAlbedo82_g22 = staticSwitch68_g22;
			float4 rimContribution107_g22 = ( fresnelNode94_g22 * baseAlbedo82_g22 );
			float3 normal50_g22 = worldNormal34_g22;
			float3 viewDir50_g22 = ase_worldViewDir;
			float2 localgetMatcapUVs50_g22 = getMatcapUVs50_g22( normal50_g22 , viewDir50_g22 );
			float4 sphereMapContribution76_g22 = ( tex2D( _SphereMap, localgetMatcapUVs50_g22 ) * roughnessOrAlpha55_g22 );
			float4 lerpResult109_g22 = lerp( ( sphereMapContribution76_g22 + baseAlbedo82_g22 ) , ( baseAlbedo82_g22 + ( sphereMapContribution76_g22 * baseAlbedo82_g22 ) ) , _Metalness1);
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 normalizeResult4_g23 = normalize( ( ase_worldViewDir + ase_worldlightDir ) );
			float dotResult72_g22 = dot( worldNormal34_g22 , normalizeResult4_g23 );
			float saferPower77_g22 = max( dotResult72_g22 , 0.0001 );
			float shadowHairHilightMask73_g22 = tex2DNode57_g22.g;
			#ifdef _USEHAIRHILIGHT_ON
				float4 staticSwitch100_g22 = ( tex2D( _HairTexture, i.uv2_texcoord2 ) * pow( saferPower77_g22 , 5.0 ) * _HilightColor1 * shadowHairHilightMask73_g22 );
			#else
				float4 staticSwitch100_g22 = float4( 0,0,0,0 );
			#endif
			float4 hairHilightContribution105_g22 = staticSwitch100_g22;
			float4 diffuseColour118_g22 = ( rimContribution107_g22 + lerpResult109_g22 + hairHilightContribution105_g22 );
			float3 normal115_g22 = float4(0,0,0,1).xyz;
			float3 localSimpleIndirectDiffuseLight115_g22 = SimpleIndirectDiffuseLight( normal115_g22 );
			float3 litIndirect119_g22 = localSimpleIndirectDiffuseLight115_g22;
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 localindirectDir4_g22 = indirectDir();
			float3 indirectDir6_g22 = localindirectDir4_g22;
			float3 normal14_g22 = indirectDir6_g22;
			float3 localSimpleIndirectDiffuseLight14_g22 = SimpleIndirectDiffuseLight( normal14_g22 );
			float4 litDirect18_g22 = ( ase_lightColor + float4( localSimpleIndirectDiffuseLight14_g22 , 0.0 ) );
			float4 temp_output_125_0_g22 = ( litDirect18_g22 * diffuseColour118_g22 );
			float shadowDarkening79_g22 = tex2DNode57_g22.r;
			float grayscale37_g22 = Luminance(litDirect18_g22.rgb);
			float3 normalizeResult60_g22 = normalize( ( ( ase_lightColor.a * ase_worldlightDir ) + ( indirectDir6_g22 * grayscale37_g22 ) ) );
			float3 mergedLightDir69_g22 = normalizeResult60_g22;
			float dotResult89_g22 = dot( newWorldNormal24_g22 , mergedLightDir69_g22 );
			float diffuseShading116_g22 = saturate( ( ( shadowDarkening79_g22 * dotResult89_g22 ) + _ShadingShift1 + shadowBrightening93_g22 ) );
			float2 temp_cast_4 = (( 1.0 - diffuseShading116_g22 )).xx;
			float4 lerpResult127_g22 = lerp( ( diffuseColour118_g22 * float4( litIndirect119_g22 , 0.0 ) ) , temp_output_125_0_g22 , tex2D( _CelShadowTable, temp_cast_4 ));
			float4 lerpResult129_g22 = lerp( lerpResult127_g22 , temp_output_125_0_g22 , diffuseShading116_g22);
			#ifdef UNITY_PASS_FORWARDBASE
				float4 staticSwitch136_g22 = lerpResult129_g22;
			#else
				float4 staticSwitch136_g22 = ( lerpResult129_g22 * ase_lightAtten );
			#endif
			c.rgb = ( 0.8 * staticSwitch136_g22 ).rgb;
			c.a = smoothstepResult198;
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
			sampler3D _DitherMaskLOD;
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
				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT( UnityGI, gi );
				o.Alpha = LightingStandardCustomLighting( o, worldViewDir, gi ).a;
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
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
1549;801;1818;946;1571.172;922.1791;1;True;False
Node;AmplifyShaderEditor.FunctionNode;190;-1219.591,-405.2628;Inherit;False;IdolCelLighting;0;;22;a1be52503abdf5b4bba14a8388d9c7c5;0;0;2;FLOAT;152;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;201;-1107.172,-634.1791;Inherit;False;Property;_Cutout;Cutout;23;0;Create;True;0;0;0;False;0;False;0.2;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FWidthOpNode;203;-972.172,-497.1791;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;202;-788.172,-521.1791;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;198;-579.172,-545.1791;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.1;False;2;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-241.4635,-612.8721;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Silent/IdolCelShader Cutout;False;False;False;False;False;True;True;True;True;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Transparent;;AlphaTest;All;16;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;0;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;True;0;0;False;-1;-1;0;True;201;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;203;0;190;152
WireConnection;202;0;201;0
WireConnection;202;1;203;0
WireConnection;198;0;190;152
WireConnection;198;1;201;0
WireConnection;198;2;202;0
WireConnection;0;9;198;0
WireConnection;0;13;190;0
ASEEND*/
//CHKSM=FCBBEB5AC7C2C1BF7F11568E7D957E0BC55D2EAD