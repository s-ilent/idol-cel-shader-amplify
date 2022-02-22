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
		_Metalness("Metalness", Range( 0 , 1)) = 0
		[ToggleUI]_RimLight("Rim Light", Float) = 1
		_RimScale("Rim Scale", Float) = 7.5
		_EmissionIntensity("Emission Intensity (for clothes)", Range( 0 , 20)) = 0
		[Header(Face Specific Features)][Toggle(_USECHEEKMASK_ON)] _UseCheekMask("Use Cheek Mask", Float) = 0
		[NoScaleOffset]_CheekMaskTexture("CheekMaskTexture", 2D) = "black" {}
		_CheekHilightColor("CheekHilightColor", Color) = (0.973446,0.3467039,0.2622509,1)
		_CheekColor("CheekColor", Color) = (1,0.708376,0.637597,1)
		_CheekObliqueLineColor("CheekObliqueLineColor", Color) = (1,0.4178849,0.3324519,1)
		_CheekHilightRatio("CheekHilightRatio", Range( 0 , 1)) = 0
		_NoseHilightRatio("NoseHilightRatio", Range( 0 , 1)) = 0
		_CheekRatio("CheekRatio", Range( 0 , 1)) = 0.6
		_NoseRatio("NoseRatio", Range( 0 , 1)) = 0
		_CheekObliqueLineRatio("CheekObliqueLineRatio", Range( 0 , 1)) = 0
		[Header(Hair Hilight)][Toggle(_USEHAIRHILIGHT_ON)] _UseHairHilight("Use Hair Hilight", Float) = 0
		[NoScaleOffset]_HairTexture("Hair Hilight Texture", 2D) = "black" {}
		_HilightColor("HilightColor", Color) = (1,0.519674,0.429741,1)
		[Header(Other Junk)]_ShadingShift("Shading Shift", Range( -1 , 1)) = 0
		[ToggleUI]_UseTextureAlphaForOpacityMask("Use Texture Alpha For Opacity Mask", Float) = 0
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Int) = 2
		[ToggleUI]_DisableTransparency("Disable Transparency", Float) = 0
		[ToggleUI]_SoftTransparency("Soft Transparency", Float) = 0
		_Cutout("Cutout", Range( 0 , 1)) = 0.2
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend Off
		AlphaToMask On
		Cull [_CullMode]
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		
		
		
		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="ForwardBase" "PassFlags"="OnlyDirectional" "RenderMode"="Cutout" }
			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityStandardBRDF.cginc"
			#include "Lighting.cginc"
			#include "UnityShaderVariables.cginc"
			#include "AutoLight.cginc"
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_SHADOWS 1
			#pragma shader_feature_local _USEHAIRHILIGHT_ON
			#pragma shader_feature_local _USECHEEKMASK_ON


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_color : COLOR;
				UNITY_SHADOW_COORDS(5)
				float4 ase_texcoord6 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			//This is a late directive
			
			uniform int _CullMode;
			uniform sampler2D _NormalMap;
			uniform float _RimScale;
			uniform sampler2D _ShadowTexture;
			uniform float _RimLight;
			uniform sampler2D _MainTex;
			uniform float4 _CheekColor;
			uniform float _NoseRatio;
			uniform float _CheekRatio;
			uniform sampler2D _CheekMaskTexture;
			uniform float4 _CheekObliqueLineColor;
			uniform float _CheekObliqueLineRatio;
			uniform float4 _CheekHilightColor;
			uniform float _NoseHilightRatio;
			uniform float _CheekHilightRatio;
			uniform sampler2D _SphereMap;
			uniform float _Metalness;
			uniform sampler2D _HairTexture;
			uniform float4 _HilightColor;
			uniform sampler2D _CelShadowTable;
			uniform float _ShadingShift;
			uniform float _EmissionIntensity;
			uniform float _DisableTransparency;
			uniform float _SoftTransparency;
			uniform float _UseTextureAlphaForOpacityMask;
			uniform float _Cutout;
			float R2Noise( float2 pixel )
			{
				    const float a1 = 0.75487766624669276;
				    const float a2 = 0.569840290998;
				    return frac(a1 * float(pixel.x) + a2 * float(pixel.y));
			}
			
			float2 getMatcapUVs50_g52( float3 normal, float3 viewDir )
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
			
			float RemapTriangular243( float z )
			{
				return z >= 0.5 ? 2.-2.*z : 2.*z;
			}
			

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldTangent = UnityObjectToWorldDir(v.ase_tangent);
				o.ase_texcoord2.xyz = ase_worldTangent;
				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord3.xyz = ase_worldNormal;
				float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord4.xyz = ase_worldBitangent;
				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord6 = screenPos;
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				o.ase_color = v.color;
				o.ase_texcoord1.zw = v.ase_texcoord1.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.w = 0;
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.w = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float2 uv_NormalMap17_g52 = i.ase_texcoord1.xy;
				float3 temp_output_21_0_g52 = ( UnpackNormal( tex2D( _NormalMap, uv_NormalMap17_g52 ) ) * float3( 1,-1,1 ) );
				float3 ase_worldTangent = i.ase_texcoord2.xyz;
				float3 ase_worldNormal = i.ase_texcoord3.xyz;
				float3 ase_worldBitangent = i.ase_texcoord4.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal24_g52 = temp_output_21_0_g52;
				float3 worldNormal24_g52 = normalize( float3(dot(tanToWorld0,tanNormal24_g52), dot(tanToWorld1,tanNormal24_g52), dot(tanToWorld2,tanNormal24_g52)) );
				float3 worldNormal34_g52 = worldNormal24_g52;
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = Unity_SafeNormalize( ase_worldViewDir );
				float dotResult168_g52 = dot( worldNormal34_g52 , ase_worldViewDir );
				float2 uv_ShadowTexture57_g52 = i.ase_texcoord1.xy;
				float4 tex2DNode57_g52 = tex2D( _ShadowTexture, uv_ShadowTexture57_g52 );
				float shadowDarkeningFresnel58_g52 = tex2DNode57_g52.a;
				float vertexColorMaskA59_g52 = i.ase_color.a;
				float2 uv_MainTex31_g52 = i.ase_texcoord1.xy;
				float4 tex2DNode31_g52 = tex2D( _MainTex, uv_MainTex31_g52 );
				float2 texCoord3_g52 = i.ase_texcoord1.zw * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode7_g52 = tex2D( _CheekMaskTexture, texCoord3_g52 );
				float blushCheekNoseSwitch9_g52 = tex2DNode7_g52.a;
				float lerpResult15_g52 = lerp( _NoseRatio , _CheekRatio , blushCheekNoseSwitch9_g52);
				float blendCheek26_g52 = ( lerpResult15_g52 * tex2DNode7_g52.g );
				float4 lerpResult45_g52 = lerp( tex2DNode31_g52 , _CheekColor , blendCheek26_g52);
				float blendCheekObliqueLine39_g52 = ( ( lerpResult15_g52 * tex2DNode7_g52.b ) * _CheekObliqueLineRatio );
				float4 lerpResult54_g52 = lerp( lerpResult45_g52 , _CheekObliqueLineColor , blendCheekObliqueLine39_g52);
				float lerpResult28_g52 = lerp( _NoseHilightRatio , _CheekHilightRatio , blushCheekNoseSwitch9_g52);
				float blendCheekHilight47_g52 = ( lerpResult28_g52 * tex2DNode7_g52.r );
				float4 lerpResult63_g52 = lerp( lerpResult54_g52 , _CheekHilightColor , blendCheekHilight47_g52);
				#ifdef _USECHEEKMASK_ON
				float4 staticSwitch68_g52 = lerpResult63_g52;
				#else
				float4 staticSwitch68_g52 = tex2DNode31_g52;
				#endif
				float4 baseAlbedo82_g52 = staticSwitch68_g52;
				float4 rimContribution107_g52 = ( saturate( ( pow( ( 1.0 - max( dotResult168_g52 , 0.0001 ) ) , _RimScale ) * ( shadowDarkeningFresnel58_g52 * vertexColorMaskA59_g52 * _RimLight ) ) ) * baseAlbedo82_g52 );
				float3 normal50_g52 = worldNormal34_g52;
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 viewDir50_g52 = ase_worldViewDir;
				float2 localgetMatcapUVs50_g52 = getMatcapUVs50_g52( normal50_g52 , viewDir50_g52 );
				float roughnessOrAlpha55_g52 = tex2DNode31_g52.a;
				float4 sphereMapContribution76_g52 = ( tex2D( _SphereMap, localgetMatcapUVs50_g52 ) * roughnessOrAlpha55_g52 );
				float4 lerpResult109_g52 = lerp( ( sphereMapContribution76_g52 + baseAlbedo82_g52 ) , ( baseAlbedo82_g52 + ( sphereMapContribution76_g52 * baseAlbedo82_g52 ) ) , _Metalness);
				float2 texCoord71_g52 = i.ase_texcoord1.zw * float2( 1,1 ) + float2( 0,0 );
				float shadowHairHilightMask73_g52 = tex2DNode57_g52.g;
				#ifdef _USEHAIRHILIGHT_ON
				float4 staticSwitch100_g52 = ( tex2D( _HairTexture, texCoord71_g52 ) * shadowHairHilightMask73_g52 * _HilightColor );
				#else
				float4 staticSwitch100_g52 = float4( 0,0,0,0 );
				#endif
				float4 hairHilightContribution105_g52 = staticSwitch100_g52;
				float4 diffuseColour118_g52 = ( rimContribution107_g52 + lerpResult109_g52 + hairHilightContribution105_g52 );
				float3 normal115_g52 = float4(0,0,0,1).xyz;
				float3 localSimpleIndirectDiffuseLight115_g52 = SimpleIndirectDiffuseLight( normal115_g52 );
				float3 litIndirect119_g52 = localSimpleIndirectDiffuseLight115_g52;
				#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
				float4 ase_lightColor = 0;
				#else //aselc
				float4 ase_lightColor = _LightColor0;
				#endif //aselc
				float4 temp_output_176_0_g52 = ase_lightColor;
				float3 lightColor184_g52 = (temp_output_176_0_g52).xyz;
				float3 localindirectDir4_g52 = indirectDir();
				float3 indirectDir6_g52 = localindirectDir4_g52;
				float3 normal14_g52 = indirectDir6_g52;
				float3 localSimpleIndirectDiffuseLight14_g52 = SimpleIndirectDiffuseLight( normal14_g52 );
				float3 litDirect18_g52 = ( lightColor184_g52 + localSimpleIndirectDiffuseLight14_g52 );
				float4 temp_output_125_0_g52 = ( float4( litDirect18_g52 , 0.0 ) * diffuseColour118_g52 );
				float shadowDarkening79_g52 = tex2DNode57_g52.r;
				float lightIntensity185_g52 = (temp_output_176_0_g52).w;
				float3 worldSpaceLightDir = Unity_SafeNormalize(UnityWorldSpaceLightDir(WorldPosition));
				float3 lightDirectionWS191_g52 = worldSpaceLightDir;
				float grayscale37_g52 = Luminance(litDirect18_g52);
				float3 normalizeResult60_g52 = normalize( ( ( lightIntensity185_g52 * lightDirectionWS191_g52 ) + ( indirectDir6_g52 * grayscale37_g52 ) ) );
				float3 mergedLightDir69_g52 = normalizeResult60_g52;
				float dotResult89_g52 = dot( worldNormal34_g52 , mergedLightDir69_g52 );
				#ifdef _USEHAIRHILIGHT_ON
				float staticSwitch78_g52 = 0.0;
				#else
				float staticSwitch78_g52 = tex2DNode57_g52.g;
				#endif
				float shadowBrightening93_g52 = staticSwitch78_g52;
				float diffuseShading116_g52 = saturate( ( ( shadowDarkening79_g52 * (0.0 + (dotResult89_g52 - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) ) + _ShadingShift + shadowBrightening93_g52 ) );
				float2 temp_cast_4 = (( 1.0 - diffuseShading116_g52 )).xx;
				float4 lerpResult127_g52 = lerp( ( diffuseColour118_g52 * float4( litIndirect119_g52 , 0.0 ) ) , temp_output_125_0_g52 , tex2D( _CelShadowTable, temp_cast_4 ));
				float4 lerpResult129_g52 = lerp( lerpResult127_g52 , temp_output_125_0_g52 , diffuseShading116_g52);
				UNITY_LIGHT_ATTENUATION(ase_atten, i, WorldPosition)
				float3 temp_cast_6 = (ase_atten).xxx;
				float3 lightAttenuation194_g52 = temp_cast_6;
				float emissionMask198_g52 = tex2DNode57_g52.g;
				float4 emissionContribution205_g52 = ( _EmissionIntensity * baseAlbedo82_g52 * emissionMask198_g52 );
				#ifdef UNITY_PASS_FORWARDBASE
				float4 staticSwitch136_g52 = ( lerpResult129_g52 + emissionContribution205_g52 );
				#else
				float4 staticSwitch136_g52 = ( lerpResult129_g52 * float4( lightAttenuation194_g52 , 0.0 ) );
				#endif
				float temp_output_255_152 = ( _UseTextureAlphaForOpacityMask >= 1.0 ? roughnessOrAlpha55_g52 : shadowHairHilightMask73_g52 );
				float4 screenPos = i.ase_texcoord6;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 appendResult252 = (float2(_SinTime.x , _SinTime.y));
				float2 pixel236 = ( ( ase_screenPosNorm * _ScreenParams ) + float4( ( appendResult252 % float2( 4,4 ) ), 0.0 , 0.0 ) ).xy;
				float localR2Noise236 = R2Noise( pixel236 );
				float z243 = localR2Noise236;
				float localRemapTriangular243 = RemapTriangular243( z243 );
				float smoothstepResult198 = smoothstep( _Cutout , ( _Cutout + fwidth( temp_output_255_152 ) ) , temp_output_255_152);
				float4 appendResult205 = (float4(( 0.8 * staticSwitch136_g52 ).rgb , ( _DisableTransparency >= 1.0 ? 1.0 : ( _SoftTransparency >= 1.0 ? ( temp_output_255_152 + ( localRemapTriangular243 * 0.015625 ) ) : smoothstepResult198 ) )));
				
				
				finalColor = appendResult205;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18909
1721;915;1818;904;2340.65;983.783;1.712635;True;False
Node;AmplifyShaderEditor.SinTimeNode;249;-1492.344,139.4255;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;252;-1319.344,179.4255;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;240;-1493.315,-209.9753;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenParams;241;-1497.315,-34.97534;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleRemainderNode;250;-1145.344,136.4255;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;4,4;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;242;-1255.315,-109.9753;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;251;-977.3445,34.42548;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FunctionNode;255;-1341.591,-426.2628;Inherit;False;IdolCelLighting;0;;52;a1be52503abdf5b4bba14a8388d9c7c5;0;3;176;FLOAT4;0,0,0,0;False;189;FLOAT3;0,0,0;False;195;FLOAT3;0,0,0;False;2;FLOAT;152;COLOR;0
Node;AmplifyShaderEditor.CustomExpressionNode;236;-818.8545,-206.5149;Inherit;False;    const float a1 = 0.75487766624669276@$    const float a2 = 0.569840290998@$    return frac(a1 * float(pixel.x) + a2 * float(pixel.y))@$;1;Create;1;True;pixel;FLOAT2;0,0;In;;Inherit;False;R2 Noise;False;True;0;;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FWidthOpNode;203;-974.172,-502.1791;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;246;-652.3154,-108.9753;Inherit;False;Constant;_164;1/64;4;0;Create;True;0;0;0;False;0;False;0.015625;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;201;-1107.172,-634.1791;Inherit;False;Property;_Cutout;Cutout;29;0;Create;True;0;0;0;False;0;False;0.2;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;243;-651.3154,-204.9753;Inherit;False;return z >= 0.5 ? 2.-2.*z : 2.*z@;1;Create;1;True;z;FLOAT;0;In;;Inherit;False;Remap Triangular;True;False;0;;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;245;-485.3154,-192.9753;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;202;-789.172,-516.1791;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;207;-521.172,-927.1791;Inherit;False;Constant;_1;1;3;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;248;-563.3445,-752.5745;Inherit;False;Property;_SoftTransparency;Soft Transparency;28;0;Create;True;0;0;0;False;1;ToggleUI;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;244;-334.3154,-269.9753;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;198;-579.172,-545.1791;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.1;False;2;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;209;-577.172,-833.1791;Inherit;False;Property;_DisableTransparency;Disable Transparency;27;0;Create;True;0;0;0;False;1;ToggleUI;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;247;-339.3445,-554.5745;Inherit;False;3;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;210;-104.172,-562.1791;Inherit;False;3;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;235;397.716,-476.7176;Inherit;False;Property;_CullMode;Cull Mode;26;1;[Enum];Create;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;2;2;False;0;1;INT;0
Node;AmplifyShaderEditor.DynamicAppendNode;205;113.828,-405.1791;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;232;347.5365,-403.8721;Float;False;True;-1;2;ASEMaterialInspector;100;1;Silent/IdolCelShader Cutout;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;False;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;True;0;True;235;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;LightMode=ForwardBase;PassFlags=OnlyDirectional;RenderMode=Cutout;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;252;0;249;1
WireConnection;252;1;249;2
WireConnection;250;0;252;0
WireConnection;242;0;240;0
WireConnection;242;1;241;0
WireConnection;251;0;242;0
WireConnection;251;1;250;0
WireConnection;236;0;251;0
WireConnection;203;0;255;152
WireConnection;243;0;236;0
WireConnection;245;0;243;0
WireConnection;245;1;246;0
WireConnection;202;0;201;0
WireConnection;202;1;203;0
WireConnection;244;0;255;152
WireConnection;244;1;245;0
WireConnection;198;0;255;152
WireConnection;198;1;201;0
WireConnection;198;2;202;0
WireConnection;247;0;248;0
WireConnection;247;1;207;0
WireConnection;247;2;244;0
WireConnection;247;3;198;0
WireConnection;210;0;209;0
WireConnection;210;1;207;0
WireConnection;210;2;207;0
WireConnection;210;3;247;0
WireConnection;205;0;255;0
WireConnection;205;3;210;0
WireConnection;232;0;205;0
ASEEND*/
//CHKSM=4BC7A748534316B4A4BC53829F1C78D72D4D53DB