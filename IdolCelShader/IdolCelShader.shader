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
		[Header(Hair Hilight)][Toggle(_USEHAIRHILIGHT_ON)] _UseHairHilight("Use Hair Hilight", Float) = 0
		[NoScaleOffset]_HairTexture("Hair Hilight Texture", 2D) = "black" {}
		_HilightColor("HilightColor", Color) = (1,0.519674,0.429741,1)
		[Header(Other Junk)]_ShadingShift("Shading Shift", Range( -1 , 1)) = 0
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Int) = 2
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
		Cull [_CullMode]
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
			#include "UnityStandardBRDF.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
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
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float2 uv_NormalMap17_g22 = i.ase_texcoord1.xy;
				float3 temp_output_21_0_g22 = ( UnpackNormal( tex2D( _NormalMap, uv_NormalMap17_g22 ) ) * float3( 1,-1,1 ) );
				float3 ase_worldTangent = i.ase_texcoord2.xyz;
				float3 ase_worldNormal = i.ase_texcoord3.xyz;
				float3 ase_worldBitangent = i.ase_texcoord4.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal24_g22 = temp_output_21_0_g22;
				float3 worldNormal24_g22 = normalize( float3(dot(tanToWorld0,tanNormal24_g22), dot(tanToWorld1,tanNormal24_g22), dot(tanToWorld2,tanNormal24_g22)) );
				float3 worldNormal34_g22 = worldNormal24_g22;
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = Unity_SafeNormalize( ase_worldViewDir );
				float dotResult168_g22 = dot( worldNormal34_g22 , ase_worldViewDir );
				float2 uv_ShadowTexture57_g22 = i.ase_texcoord1.xy;
				float4 tex2DNode57_g22 = tex2D( _ShadowTexture, uv_ShadowTexture57_g22 );
				float shadowDarkeningFresnel58_g22 = tex2DNode57_g22.a;
				float vertexColorMaskA59_g22 = i.ase_color.a;
				float2 uv_MainTex31_g22 = i.ase_texcoord1.xy;
				float4 tex2DNode31_g22 = tex2D( _MainTex, uv_MainTex31_g22 );
				float2 texCoord3_g22 = i.ase_texcoord1.zw * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode7_g22 = tex2D( _CheekMaskTexture, texCoord3_g22 );
				float blushCheekNoseSwitch9_g22 = tex2DNode7_g22.a;
				float lerpResult15_g22 = lerp( _NoseRatio , _CheekRatio , blushCheekNoseSwitch9_g22);
				float blendCheek26_g22 = ( lerpResult15_g22 * tex2DNode7_g22.g );
				float4 lerpResult45_g22 = lerp( tex2DNode31_g22 , _CheekColor , blendCheek26_g22);
				float blendCheekObliqueLine39_g22 = ( lerpResult15_g22 * tex2DNode7_g22.b );
				float4 lerpResult54_g22 = lerp( lerpResult45_g22 , _CheekObliqueLineColor , blendCheekObliqueLine39_g22);
				float lerpResult28_g22 = lerp( _NoseHilightRatio , _CheekHilightRatio , blushCheekNoseSwitch9_g22);
				float blendCheekHilight47_g22 = ( lerpResult28_g22 * tex2DNode7_g22.r );
				float4 lerpResult63_g22 = lerp( lerpResult54_g22 , _CheekHilightColor , blendCheekHilight47_g22);
				#ifdef _USECHEEKMASK_ON
				float4 staticSwitch68_g22 = lerpResult63_g22;
				#else
				float4 staticSwitch68_g22 = tex2DNode31_g22;
				#endif
				float4 baseAlbedo82_g22 = staticSwitch68_g22;
				float4 rimContribution107_g22 = ( saturate( ( pow( ( 1.0 - max( dotResult168_g22 , 0.0001 ) ) , _RimScale ) * ( shadowDarkeningFresnel58_g22 * vertexColorMaskA59_g22 * _RimLight ) ) ) * baseAlbedo82_g22 );
				float3 normal50_g22 = worldNormal34_g22;
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 viewDir50_g22 = ase_worldViewDir;
				float2 localgetMatcapUVs50_g22 = getMatcapUVs50_g22( normal50_g22 , viewDir50_g22 );
				float roughnessOrAlpha55_g22 = tex2DNode31_g22.a;
				float4 sphereMapContribution76_g22 = ( tex2D( _SphereMap, localgetMatcapUVs50_g22 ) * roughnessOrAlpha55_g22 );
				float4 lerpResult109_g22 = lerp( ( sphereMapContribution76_g22 + baseAlbedo82_g22 ) , ( baseAlbedo82_g22 + ( sphereMapContribution76_g22 * baseAlbedo82_g22 ) ) , _Metalness);
				float2 texCoord71_g22 = i.ase_texcoord1.zw * float2( 1,1 ) + float2( 0,0 );
				float3 worldSpaceLightDir = Unity_SafeNormalize(UnityWorldSpaceLightDir(WorldPosition));
				float3 normalizeResult180_g22 = normalize( ( ase_worldViewDir + worldSpaceLightDir ) );
				float3 HalfVector181_g22 = normalizeResult180_g22;
				float dotResult72_g22 = dot( worldNormal34_g22 , HalfVector181_g22 );
				float saferPower77_g22 = max( dotResult72_g22 , 0.0001 );
				float shadowHairHilightMask73_g22 = tex2DNode57_g22.g;
				#ifdef _USEHAIRHILIGHT_ON
				float4 staticSwitch100_g22 = ( tex2D( _HairTexture, texCoord71_g22 ) * saturate( pow( saferPower77_g22 , 5.0 ) ) * _HilightColor * shadowHairHilightMask73_g22 );
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
				float4 temp_output_176_0_g22 = ase_lightColor;
				float3 lightColor184_g22 = (temp_output_176_0_g22).xyz;
				float3 localindirectDir4_g22 = indirectDir();
				float3 indirectDir6_g22 = localindirectDir4_g22;
				float3 normal14_g22 = indirectDir6_g22;
				float3 localSimpleIndirectDiffuseLight14_g22 = SimpleIndirectDiffuseLight( normal14_g22 );
				float3 litDirect18_g22 = ( lightColor184_g22 + localSimpleIndirectDiffuseLight14_g22 );
				float4 temp_output_125_0_g22 = ( float4( litDirect18_g22 , 0.0 ) * diffuseColour118_g22 );
				float shadowDarkening79_g22 = tex2DNode57_g22.r;
				float lightIntensity185_g22 = (temp_output_176_0_g22).w;
				float3 lightDirectionWS191_g22 = worldSpaceLightDir;
				float grayscale37_g22 = Luminance(litDirect18_g22);
				float3 normalizeResult60_g22 = normalize( ( ( lightIntensity185_g22 * lightDirectionWS191_g22 ) + ( indirectDir6_g22 * grayscale37_g22 ) ) );
				float3 mergedLightDir69_g22 = normalizeResult60_g22;
				float dotResult89_g22 = dot( worldNormal34_g22 , mergedLightDir69_g22 );
				#ifdef _USEHAIRHILIGHT_ON
				float staticSwitch78_g22 = 0.0;
				#else
				float staticSwitch78_g22 = tex2DNode57_g22.g;
				#endif
				float shadowBrightening93_g22 = staticSwitch78_g22;
				float diffuseShading116_g22 = saturate( ( ( shadowDarkening79_g22 * (0.0 + (dotResult89_g22 - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) ) + _ShadingShift + shadowBrightening93_g22 ) );
				float2 temp_cast_4 = (( 1.0 - diffuseShading116_g22 )).xx;
				float4 lerpResult127_g22 = lerp( ( diffuseColour118_g22 * float4( litIndirect119_g22 , 0.0 ) ) , temp_output_125_0_g22 , tex2D( _CelShadowTable, temp_cast_4 ));
				float4 lerpResult129_g22 = lerp( lerpResult127_g22 , temp_output_125_0_g22 , diffuseShading116_g22);
				UNITY_LIGHT_ATTENUATION(ase_atten, i, WorldPosition)
				float3 temp_cast_6 = (ase_atten).xxx;
				float3 lightAttenuation194_g22 = temp_cast_6;
				float emissionMask198_g22 = tex2DNode57_g22.g;
				float4 emissionContribution205_g22 = ( _EmissionIntensity * baseAlbedo82_g22 * emissionMask198_g22 );
				#ifdef UNITY_PASS_FORWARDBASE
				float4 staticSwitch136_g22 = ( lerpResult129_g22 + emissionContribution205_g22 );
				#else
				float4 staticSwitch136_g22 = ( lerpResult129_g22 * float4( lightAttenuation194_g22 , 0.0 ) );
				#endif
				
				
				finalColor = ( 0.8 * staticSwitch136_g22 );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	Fallback "Hidden/IdolCelShader/VRCShadowWorkaround"
}
/*ASEBEGIN
Version=18909
1403;863;1818;904;1257.957;1038.101;1;True;False
Node;AmplifyShaderEditor.IntNode;206;-200.957,-709.1008;Inherit;False;Property;_CullMode;Cull Mode;25;1;[Enum];Create;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;2;2;False;0;1;INT;0
Node;AmplifyShaderEditor.FunctionNode;205;-517.5914,-637.2628;Inherit;False;IdolCelLighting;0;;22;a1be52503abdf5b4bba14a8388d9c7c5;0;3;176;FLOAT4;0,0,0,0;False;189;FLOAT3;0,0,0;False;195;FLOAT3;0,0,0;False;2;FLOAT;152;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;203;-241.4635,-612.8721;Float;False;True;-1;2;ASEMaterialInspector;100;1;Silent/IdolCelShader;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;FORWARD;2;False;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;True;True;0;True;206;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;2;Include;;False;;Native;Pragma;multi_compile_fwdbase;False;;Custom;Hidden/IdolCelShader/VRCShadowWorkaround;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;203;0;205;0
ASEEND*/
//CHKSM=7891615C49623A17BD87E66A3EB9F5A04E06135F