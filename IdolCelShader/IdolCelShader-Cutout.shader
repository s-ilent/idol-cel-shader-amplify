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
		[Header(Face Specific Features)][Toggle(_USECHEEKMASK_ON)] _UseCheekMask("Use Cheek Mask", Float) = 0
		[NoScaleOffset]_CheekMaskTexture("CheekMaskTexture", 2D) = "black" {}
		_CheekHilightColor("CheekHilightColor", Color) = (0.973446,0.3467039,0.2622509,1)
		_CheekColor("CheekColor", Color) = (1,0.708376,0.637597,1)
		_CheekObliqueLineColor("CheekObliqueLineColor", Color) = (1,0.4178849,0.3324519,1)
		_CheekHilightRatio("CheekHilightRatio", Range( 0 , 1)) = 0
		_NoseHilightRatio("NoseHilightRatio", Range( 0 , 1)) = 0
		_CheekRatio("CheekRatio", Range( 0 , 1)) = 0.6
		_NoseRatio("NoseRatio", Range( 0 , 1)) = 0
		[Header(Hair Hilight)][Toggle(_USEHAIRHILIGHT_ON)] _UseHairHilight("Use Hair Hilight", Float) = 0
		[NoScaleOffset]_HairTexture("Hair Hilight Texture", 2D) = "black" {}
		_HilightColor("HilightColor", Color) = (1,0.519674,0.429741,1)
		[Header(Other Junk)]_ShadingShift("Shading Shift", Range( -1 , 1)) = 0
		[ToggleUI]_UseTextureAlphaForOpacityMask("Use Texture Alpha For Opacity Mask", Float) = 0
		[ToggleUI]_DisableTransparency("Disable Transparency", Float) = 0
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
		Cull Off
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		
		
		
		Pass
		{
			Name "FORWARD"
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			#include "UnityStandardBRDF.cginc"
			#include "UnityShaderVariables.cginc"
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_SHADOWS 1
			#pragma shader_feature_local _USEHAIRHILIGHT_ON
			#pragma shader_feature_local _USECHEEKMASK_ON
			#pragma multi_compile_fwdbase


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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			//This is a late directive
			
			uniform sampler2D _NormalMap;
			uniform sampler2D _ShadowTexture;
			uniform float _RimLight;
			uniform float _RimScale;
			uniform sampler2D _MainTex;
			uniform float4 _CheekColor;
			uniform float _NoseRatio;
			uniform float _CheekRatio;
			uniform sampler2D _CheekMaskTexture;
			uniform float4 _CheekObliqueLineColor;
			uniform float4 _CheekHilightColor;
			uniform float _NoseHilightRatio;
			uniform float _CheekHilightRatio;
			uniform sampler2D _SphereMap;
			uniform float _Metalness;
			uniform sampler2D _HairTexture;
			uniform float4 _HilightColor;
			uniform sampler2D _CelShadowTable;
			uniform float _ShadingShift;
			uniform float _DisableTransparency;
			uniform float _Cutout;
			uniform float _UseTextureAlphaForOpacityMask;
			float2 getMatcapUVs50_g36( float3 normal, float3 viewDir )
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
			
			fixed4 frag (v2f i , half ase_vface : VFACE) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float2 uv_NormalMap17_g36 = i.ase_texcoord1.xy;
				float3 temp_output_21_0_g36 = ( UnpackNormal( tex2D( _NormalMap, uv_NormalMap17_g36 ) ) * float3( 1,-1,1 ) );
				float3 ase_worldTangent = i.ase_texcoord2.xyz;
				float3 ase_worldNormal = i.ase_texcoord3.xyz;
				float3 ase_worldBitangent = i.ase_texcoord4.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal24_g36 = temp_output_21_0_g36;
				float3 worldNormal24_g36 = float3(dot(tanToWorld0,tanNormal24_g36), dot(tanToWorld1,tanNormal24_g36), dot(tanToWorld2,tanNormal24_g36));
				float3 switchResult164_g36 = (((ase_vface>0)?(worldNormal24_g36):(( worldNormal24_g36 * float3( -1,-1,-1 ) ))));
				float3 worldNormal34_g36 = switchResult164_g36;
				float2 uv_ShadowTexture57_g36 = i.ase_texcoord1.xy;
				float4 tex2DNode57_g36 = tex2D( _ShadowTexture, uv_ShadowTexture57_g36 );
				float shadowDarkeningFresnel58_g36 = tex2DNode57_g36.a;
				float vertexColorMaskA59_g36 = i.ase_color.a;
				float fresnelNdotV94_g36 = dot( normalize( worldNormal34_g36 ), ase_worldViewDir );
				float fresnelNode94_g36 = ( 0.0 + ( shadowDarkeningFresnel58_g36 * vertexColorMaskA59_g36 * _RimLight ) * pow( max( 1.0 - fresnelNdotV94_g36 , 0.0001 ), _RimScale ) );
				float2 uv_MainTex31_g36 = i.ase_texcoord1.xy;
				float4 tex2DNode31_g36 = tex2D( _MainTex, uv_MainTex31_g36 );
				float2 texCoord3_g36 = i.ase_texcoord1.zw * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode7_g36 = tex2D( _CheekMaskTexture, texCoord3_g36 );
				float blushCheekNoseSwitch9_g36 = tex2DNode7_g36.a;
				float lerpResult15_g36 = lerp( _NoseRatio , _CheekRatio , blushCheekNoseSwitch9_g36);
				float blendCheek26_g36 = ( lerpResult15_g36 * tex2DNode7_g36.g );
				float4 lerpResult45_g36 = lerp( tex2DNode31_g36 , _CheekColor , blendCheek26_g36);
				float blendCheekObliqueLine39_g36 = ( lerpResult15_g36 * tex2DNode7_g36.b );
				float4 lerpResult54_g36 = lerp( lerpResult45_g36 , _CheekObliqueLineColor , blendCheekObliqueLine39_g36);
				float lerpResult28_g36 = lerp( _NoseHilightRatio , _CheekHilightRatio , blushCheekNoseSwitch9_g36);
				float blendCheekHilight47_g36 = ( lerpResult28_g36 * tex2DNode7_g36.r );
				float4 lerpResult63_g36 = lerp( lerpResult54_g36 , _CheekHilightColor , blendCheekHilight47_g36);
				#ifdef _USECHEEKMASK_ON
				float4 staticSwitch68_g36 = lerpResult63_g36;
				#else
				float4 staticSwitch68_g36 = tex2DNode31_g36;
				#endif
				float4 baseAlbedo82_g36 = staticSwitch68_g36;
				float4 rimContribution107_g36 = ( saturate( fresnelNode94_g36 ) * baseAlbedo82_g36 );
				float3 normal50_g36 = worldNormal34_g36;
				float3 viewDir50_g36 = ase_worldViewDir;
				float2 localgetMatcapUVs50_g36 = getMatcapUVs50_g36( normal50_g36 , viewDir50_g36 );
				float roughnessOrAlpha55_g36 = tex2DNode31_g36.a;
				float4 sphereMapContribution76_g36 = ( tex2D( _SphereMap, localgetMatcapUVs50_g36 ) * roughnessOrAlpha55_g36 );
				float4 lerpResult109_g36 = lerp( ( sphereMapContribution76_g36 + baseAlbedo82_g36 ) , ( baseAlbedo82_g36 + ( sphereMapContribution76_g36 * baseAlbedo82_g36 ) ) , _Metalness);
				float2 texCoord71_g36 = i.ase_texcoord1.zw * float2( 1,1 ) + float2( 0,0 );
				float3 worldSpaceLightDir = Unity_SafeNormalize(UnityWorldSpaceLightDir(WorldPosition));
				float3 normalizeResult4_g37 = normalize( ( ase_worldViewDir + worldSpaceLightDir ) );
				float dotResult72_g36 = dot( worldNormal34_g36 , normalizeResult4_g37 );
				float saferPower77_g36 = max( dotResult72_g36 , 0.0001 );
				float shadowHairHilightMask73_g36 = tex2DNode57_g36.g;
				#ifdef _USEHAIRHILIGHT_ON
				float4 staticSwitch100_g36 = ( tex2D( _HairTexture, texCoord71_g36 ) * saturate( pow( saferPower77_g36 , 5.0 ) ) * _HilightColor * shadowHairHilightMask73_g36 );
				#else
				float4 staticSwitch100_g36 = float4( 0,0,0,0 );
				#endif
				float4 hairHilightContribution105_g36 = staticSwitch100_g36;
				float4 diffuseColour118_g36 = ( rimContribution107_g36 + lerpResult109_g36 + hairHilightContribution105_g36 );
				float3 normal115_g36 = float4(0,0,0,1).xyz;
				float3 localSimpleIndirectDiffuseLight115_g36 = SimpleIndirectDiffuseLight( normal115_g36 );
				float3 litIndirect119_g36 = localSimpleIndirectDiffuseLight115_g36;
				#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
				float4 ase_lightColor = 0;
				#else //aselc
				float4 ase_lightColor = _LightColor0;
				#endif //aselc
				float3 localindirectDir4_g36 = indirectDir();
				float3 indirectDir6_g36 = localindirectDir4_g36;
				float3 normal14_g36 = indirectDir6_g36;
				float3 localSimpleIndirectDiffuseLight14_g36 = SimpleIndirectDiffuseLight( normal14_g36 );
				float4 litDirect18_g36 = ( ase_lightColor + float4( localSimpleIndirectDiffuseLight14_g36 , 0.0 ) );
				float4 temp_output_125_0_g36 = ( litDirect18_g36 * diffuseColour118_g36 );
				float shadowDarkening79_g36 = tex2DNode57_g36.r;
				float grayscale37_g36 = Luminance(litDirect18_g36.rgb);
				float3 normalizeResult60_g36 = normalize( ( ( ase_lightColor.a * worldSpaceLightDir ) + ( indirectDir6_g36 * grayscale37_g36 ) ) );
				float3 mergedLightDir69_g36 = normalizeResult60_g36;
				float dotResult89_g36 = dot( worldNormal34_g36 , mergedLightDir69_g36 );
				#ifdef _USEHAIRHILIGHT_ON
				float staticSwitch78_g36 = 0.0;
				#else
				float staticSwitch78_g36 = tex2DNode57_g36.g;
				#endif
				float shadowBrightening93_g36 = staticSwitch78_g36;
				float diffuseShading116_g36 = saturate( ( ( shadowDarkening79_g36 * (0.0 + (dotResult89_g36 - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) ) + _ShadingShift + shadowBrightening93_g36 ) );
				float2 temp_cast_4 = (( 1.0 - diffuseShading116_g36 )).xx;
				float4 lerpResult127_g36 = lerp( ( diffuseColour118_g36 * float4( litIndirect119_g36 , 0.0 ) ) , temp_output_125_0_g36 , tex2D( _CelShadowTable, temp_cast_4 ));
				float4 lerpResult129_g36 = lerp( lerpResult127_g36 , temp_output_125_0_g36 , diffuseShading116_g36);
				UNITY_LIGHT_ATTENUATION(ase_atten, i, WorldPosition)
				#ifdef UNITY_PASS_FORWARDBASE
				float4 staticSwitch136_g36 = lerpResult129_g36;
				#else
				float4 staticSwitch136_g36 = ( lerpResult129_g36 * ase_atten );
				#endif
				float temp_output_217_152 = ( _UseTextureAlphaForOpacityMask >= 1.0 ? roughnessOrAlpha55_g36 : shadowHairHilightMask73_g36 );
				float smoothstepResult198 = smoothstep( _Cutout , ( _Cutout + fwidth( temp_output_217_152 ) ) , temp_output_217_152);
				float4 appendResult205 = (float4(( 0.8 * staticSwitch136_g36 ).rgb , ( _DisableTransparency >= 1.0 ? 1.0 : smoothstepResult198 )));
				
				
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
2015;1177;1818;922;1486.398;804.5034;1;True;False
Node;AmplifyShaderEditor.FunctionNode;217;-1220.591,-431.2628;Inherit;False;IdolCelLighting;0;;36;a1be52503abdf5b4bba14a8388d9c7c5;0;0;2;FLOAT;152;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;201;-1107.172,-634.1791;Inherit;False;Property;_Cutout;Cutout;25;0;Create;True;0;0;0;False;0;False;0.2;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FWidthOpNode;203;-974.172,-502.1791;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;202;-789.172,-516.1791;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;198;-579.172,-545.1791;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.1;False;2;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;209;-598.172,-660.1791;Inherit;False;Property;_DisableTransparency;Disable Transparency;24;0;Create;True;0;0;0;False;1;ToggleUI;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;207;-580.172,-743.1791;Inherit;False;Constant;_1;1;3;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;210;-284.172,-548.1791;Inherit;False;3;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;205;-77.172,-402.1791;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;204;155.5365,-395.8721;Float;False;True;-1;2;ASEMaterialInspector;100;1;Silent/IdolCelShader Cutout;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;FORWARD;2;False;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;True;2;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;2;Include;;False;;Native;Pragma;multi_compile_fwdbase;False;;Custom;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;203;0;217;152
WireConnection;202;0;201;0
WireConnection;202;1;203;0
WireConnection;198;0;217;152
WireConnection;198;1;201;0
WireConnection;198;2;202;0
WireConnection;210;0;209;0
WireConnection;210;1;207;0
WireConnection;210;2;207;0
WireConnection;210;3;198;0
WireConnection;205;0;217;0
WireConnection;205;3;210;0
WireConnection;204;0;205;0
ASEEND*/
//CHKSM=E17EAF1047CDFBF6AA34DA00844D18D7A23F080A