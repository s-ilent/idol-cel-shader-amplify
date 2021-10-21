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
		AlphaToMask Off
		Cull Back
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
				float2 uv_NormalMap17_g18 = i.ase_texcoord1.xy;
				float3 temp_output_21_0_g18 = ( UnpackNormal( tex2D( _NormalMap, uv_NormalMap17_g18 ) ) * float3( 1,-1,1 ) );
				float3 ase_worldTangent = i.ase_texcoord2.xyz;
				float3 ase_worldNormal = i.ase_texcoord3.xyz;
				float3 ase_worldBitangent = i.ase_texcoord4.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal24_g18 = temp_output_21_0_g18;
				float3 worldNormal24_g18 = float3(dot(tanToWorld0,tanNormal24_g18), dot(tanToWorld1,tanNormal24_g18), dot(tanToWorld2,tanNormal24_g18));
				float3 switchResult164_g18 = (((ase_vface>0)?(worldNormal24_g18):(( worldNormal24_g18 * float3( -1,-1,-1 ) ))));
				float3 worldNormal34_g18 = switchResult164_g18;
				float2 uv_ShadowTexture57_g18 = i.ase_texcoord1.xy;
				float4 tex2DNode57_g18 = tex2D( _ShadowTexture, uv_ShadowTexture57_g18 );
				float shadowDarkeningFresnel58_g18 = tex2DNode57_g18.a;
				float vertexColorMaskA59_g18 = i.ase_color.a;
				float fresnelNdotV94_g18 = dot( normalize( worldNormal34_g18 ), ase_worldViewDir );
				float fresnelNode94_g18 = ( 0.0 + ( shadowDarkeningFresnel58_g18 * vertexColorMaskA59_g18 * _RimLight ) * pow( max( 1.0 - fresnelNdotV94_g18 , 0.0001 ), _RimScale ) );
				float2 uv_MainTex31_g18 = i.ase_texcoord1.xy;
				float4 tex2DNode31_g18 = tex2D( _MainTex, uv_MainTex31_g18 );
				float2 texCoord3_g18 = i.ase_texcoord1.zw * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode7_g18 = tex2D( _CheekMaskTexture, texCoord3_g18 );
				float blushCheekNoseSwitch9_g18 = tex2DNode7_g18.a;
				float lerpResult15_g18 = lerp( _NoseRatio , _CheekRatio , blushCheekNoseSwitch9_g18);
				float blendCheek26_g18 = ( lerpResult15_g18 * tex2DNode7_g18.g );
				float4 lerpResult45_g18 = lerp( tex2DNode31_g18 , _CheekColor , blendCheek26_g18);
				float blendCheekObliqueLine39_g18 = ( lerpResult15_g18 * tex2DNode7_g18.b );
				float4 lerpResult54_g18 = lerp( lerpResult45_g18 , _CheekObliqueLineColor , blendCheekObliqueLine39_g18);
				float lerpResult28_g18 = lerp( _NoseHilightRatio , _CheekHilightRatio , blushCheekNoseSwitch9_g18);
				float blendCheekHilight47_g18 = ( lerpResult28_g18 * tex2DNode7_g18.r );
				float4 lerpResult63_g18 = lerp( lerpResult54_g18 , _CheekHilightColor , blendCheekHilight47_g18);
				#ifdef _USECHEEKMASK_ON
				float4 staticSwitch68_g18 = lerpResult63_g18;
				#else
				float4 staticSwitch68_g18 = tex2DNode31_g18;
				#endif
				float4 baseAlbedo82_g18 = staticSwitch68_g18;
				float4 rimContribution107_g18 = ( saturate( fresnelNode94_g18 ) * baseAlbedo82_g18 );
				float3 normal50_g18 = worldNormal34_g18;
				float3 viewDir50_g18 = ase_worldViewDir;
				float2 localgetMatcapUVs50_g18 = getMatcapUVs50_g18( normal50_g18 , viewDir50_g18 );
				float roughnessOrAlpha55_g18 = tex2DNode31_g18.a;
				float4 sphereMapContribution76_g18 = ( tex2D( _SphereMap, localgetMatcapUVs50_g18 ) * roughnessOrAlpha55_g18 );
				float4 lerpResult109_g18 = lerp( ( sphereMapContribution76_g18 + baseAlbedo82_g18 ) , ( baseAlbedo82_g18 + ( sphereMapContribution76_g18 * baseAlbedo82_g18 ) ) , _Metalness);
				float2 texCoord71_g18 = i.ase_texcoord1.zw * float2( 1,1 ) + float2( 0,0 );
				float3 worldSpaceLightDir = Unity_SafeNormalize(UnityWorldSpaceLightDir(WorldPosition));
				float3 normalizeResult4_g19 = normalize( ( ase_worldViewDir + worldSpaceLightDir ) );
				float dotResult72_g18 = dot( worldNormal34_g18 , normalizeResult4_g19 );
				float saferPower77_g18 = max( dotResult72_g18 , 0.0001 );
				float shadowHairHilightMask73_g18 = tex2DNode57_g18.g;
				#ifdef _USEHAIRHILIGHT_ON
				float4 staticSwitch100_g18 = ( tex2D( _HairTexture, texCoord71_g18 ) * saturate( pow( saferPower77_g18 , 5.0 ) ) * _HilightColor * shadowHairHilightMask73_g18 );
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
				float3 normalizeResult60_g18 = normalize( ( ( ase_lightColor.a * worldSpaceLightDir ) + ( indirectDir6_g18 * grayscale37_g18 ) ) );
				float3 mergedLightDir69_g18 = normalizeResult60_g18;
				float dotResult89_g18 = dot( worldNormal34_g18 , mergedLightDir69_g18 );
				#ifdef _USEHAIRHILIGHT_ON
				float staticSwitch78_g18 = 0.0;
				#else
				float staticSwitch78_g18 = tex2DNode57_g18.g;
				#endif
				float shadowBrightening93_g18 = staticSwitch78_g18;
				float diffuseShading116_g18 = saturate( ( ( shadowDarkening79_g18 * (0.0 + (dotResult89_g18 - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) ) + _ShadingShift + shadowBrightening93_g18 ) );
				float2 temp_cast_4 = (( 1.0 - diffuseShading116_g18 )).xx;
				float4 lerpResult127_g18 = lerp( ( diffuseColour118_g18 * float4( litIndirect119_g18 , 0.0 ) ) , temp_output_125_0_g18 , tex2D( _CelShadowTable, temp_cast_4 ));
				float4 lerpResult129_g18 = lerp( lerpResult127_g18 , temp_output_125_0_g18 , diffuseShading116_g18);
				UNITY_LIGHT_ATTENUATION(ase_atten, i, WorldPosition)
				#ifdef UNITY_PASS_FORWARDBASE
				float4 staticSwitch136_g18 = lerpResult129_g18;
				#else
				float4 staticSwitch136_g18 = ( lerpResult129_g18 * ase_atten );
				#endif
				
				
				finalColor = ( 0.8 * staticSwitch136_g18 );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18909
2015;1177;1818;922;1266.957;729.1008;1;True;False
Node;AmplifyShaderEditor.FunctionNode;188;-517.5914,-637.2628;Inherit;False;IdolCelLighting;0;;18;a1be52503abdf5b4bba14a8388d9c7c5;0;0;2;FLOAT;152;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;203;-241.4635,-612.8721;Float;False;True;-1;2;ASEMaterialInspector;100;1;Silent/IdolCelShader;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;FORWARD;2;False;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;2;Include;;False;;Native;Pragma;multi_compile_fwdbase;False;;Custom;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;203;0;188;0
ASEEND*/
//CHKSM=7396CBC466AE93B810F210CD20A1F97B0287CE19