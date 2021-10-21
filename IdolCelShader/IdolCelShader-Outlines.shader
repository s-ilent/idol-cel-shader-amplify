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
		_OutlineDistanceAdjust("Outline Distance Adjust", Vector) = (0.1,-0.1,0.2,1)
		_OutlineWidth("Outline Width", Float) = 0.1
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
		Cull Front
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
			#define ASE_NEEDS_VERT_COLOR
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_SHADOWS 1
			#pragma shader_feature_local _USEHAIRHILIGHT_ON
			#pragma shader_feature_local _USECHEEKMASK_ON
			#pragma multi_compile_fwdbase


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
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
			
			uniform float _OutlineWidth;
			uniform float4 _OutlineDistanceAdjust;
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
			

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float outlineWidth207 = v.color.a;
				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float3 ase_worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(ase_worldPos);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float4 transform229 = mul(unity_WorldToObject,float4( ase_worldViewDir , 0.0 ));
				float outlineZPush208 = v.color.b;
				
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
				vertexValue = ( float4( ( _OutlineWidth * v.ase_normal * 0.01 * outlineWidth207 * (_OutlineDistanceAdjust.z + (saturate( (0.0 + (ase_screenPosNorm.z - _OutlineDistanceAdjust.x) * (1.0 - 0.0) / (_OutlineDistanceAdjust.y - _OutlineDistanceAdjust.x)) ) - 0.0) * (_OutlineDistanceAdjust.w - _OutlineDistanceAdjust.z) / (1.0 - 0.0)) ) , 0.0 ) + ( -transform229 * (outlineZPush208*2.0 + -1.0) * 0.04 * 0.1 ) ).xyz;
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
				float2 uv_NormalMap17_g20 = i.ase_texcoord1.xy;
				float3 temp_output_21_0_g20 = ( UnpackNormal( tex2D( _NormalMap, uv_NormalMap17_g20 ) ) * float3( 1,-1,1 ) );
				float3 ase_worldTangent = i.ase_texcoord2.xyz;
				float3 ase_worldNormal = i.ase_texcoord3.xyz;
				float3 ase_worldBitangent = i.ase_texcoord4.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal24_g20 = temp_output_21_0_g20;
				float3 worldNormal24_g20 = float3(dot(tanToWorld0,tanNormal24_g20), dot(tanToWorld1,tanNormal24_g20), dot(tanToWorld2,tanNormal24_g20));
				float3 switchResult164_g20 = (((ase_vface>0)?(worldNormal24_g20):(( worldNormal24_g20 * float3( -1,-1,-1 ) ))));
				float3 worldNormal34_g20 = switchResult164_g20;
				float2 uv_ShadowTexture57_g20 = i.ase_texcoord1.xy;
				float4 tex2DNode57_g20 = tex2D( _ShadowTexture, uv_ShadowTexture57_g20 );
				float shadowDarkeningFresnel58_g20 = tex2DNode57_g20.a;
				float vertexColorMaskA59_g20 = i.ase_color.a;
				float fresnelNdotV94_g20 = dot( normalize( worldNormal34_g20 ), ase_worldViewDir );
				float fresnelNode94_g20 = ( 0.0 + ( shadowDarkeningFresnel58_g20 * vertexColorMaskA59_g20 * _RimLight ) * pow( max( 1.0 - fresnelNdotV94_g20 , 0.0001 ), _RimScale ) );
				float2 uv_MainTex31_g20 = i.ase_texcoord1.xy;
				float4 tex2DNode31_g20 = tex2D( _MainTex, uv_MainTex31_g20 );
				float2 texCoord3_g20 = i.ase_texcoord1.zw * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode7_g20 = tex2D( _CheekMaskTexture, texCoord3_g20 );
				float blushCheekNoseSwitch9_g20 = tex2DNode7_g20.a;
				float lerpResult15_g20 = lerp( _NoseRatio , _CheekRatio , blushCheekNoseSwitch9_g20);
				float blendCheek26_g20 = ( lerpResult15_g20 * tex2DNode7_g20.g );
				float4 lerpResult45_g20 = lerp( tex2DNode31_g20 , _CheekColor , blendCheek26_g20);
				float blendCheekObliqueLine39_g20 = ( lerpResult15_g20 * tex2DNode7_g20.b );
				float4 lerpResult54_g20 = lerp( lerpResult45_g20 , _CheekObliqueLineColor , blendCheekObliqueLine39_g20);
				float lerpResult28_g20 = lerp( _NoseHilightRatio , _CheekHilightRatio , blushCheekNoseSwitch9_g20);
				float blendCheekHilight47_g20 = ( lerpResult28_g20 * tex2DNode7_g20.r );
				float4 lerpResult63_g20 = lerp( lerpResult54_g20 , _CheekHilightColor , blendCheekHilight47_g20);
				#ifdef _USECHEEKMASK_ON
				float4 staticSwitch68_g20 = lerpResult63_g20;
				#else
				float4 staticSwitch68_g20 = tex2DNode31_g20;
				#endif
				float4 baseAlbedo82_g20 = staticSwitch68_g20;
				float4 rimContribution107_g20 = ( saturate( fresnelNode94_g20 ) * baseAlbedo82_g20 );
				float3 normal50_g20 = worldNormal34_g20;
				float3 viewDir50_g20 = ase_worldViewDir;
				float2 localgetMatcapUVs50_g20 = getMatcapUVs50_g20( normal50_g20 , viewDir50_g20 );
				float roughnessOrAlpha55_g20 = tex2DNode31_g20.a;
				float4 sphereMapContribution76_g20 = ( tex2D( _SphereMap, localgetMatcapUVs50_g20 ) * roughnessOrAlpha55_g20 );
				float4 lerpResult109_g20 = lerp( ( sphereMapContribution76_g20 + baseAlbedo82_g20 ) , ( baseAlbedo82_g20 + ( sphereMapContribution76_g20 * baseAlbedo82_g20 ) ) , _Metalness);
				float2 texCoord71_g20 = i.ase_texcoord1.zw * float2( 1,1 ) + float2( 0,0 );
				float3 worldSpaceLightDir = Unity_SafeNormalize(UnityWorldSpaceLightDir(WorldPosition));
				float3 normalizeResult4_g21 = normalize( ( ase_worldViewDir + worldSpaceLightDir ) );
				float dotResult72_g20 = dot( worldNormal34_g20 , normalizeResult4_g21 );
				float saferPower77_g20 = max( dotResult72_g20 , 0.0001 );
				float shadowHairHilightMask73_g20 = tex2DNode57_g20.g;
				#ifdef _USEHAIRHILIGHT_ON
				float4 staticSwitch100_g20 = ( tex2D( _HairTexture, texCoord71_g20 ) * saturate( pow( saferPower77_g20 , 5.0 ) ) * _HilightColor * shadowHairHilightMask73_g20 );
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
				float3 normalizeResult60_g20 = normalize( ( ( ase_lightColor.a * worldSpaceLightDir ) + ( indirectDir6_g20 * grayscale37_g20 ) ) );
				float3 mergedLightDir69_g20 = normalizeResult60_g20;
				float dotResult89_g20 = dot( worldNormal34_g20 , mergedLightDir69_g20 );
				#ifdef _USEHAIRHILIGHT_ON
				float staticSwitch78_g20 = 0.0;
				#else
				float staticSwitch78_g20 = tex2DNode57_g20.g;
				#endif
				float shadowBrightening93_g20 = staticSwitch78_g20;
				float diffuseShading116_g20 = saturate( ( ( shadowDarkening79_g20 * (0.0 + (dotResult89_g20 - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) ) + _ShadingShift + shadowBrightening93_g20 ) );
				float2 temp_cast_4 = (( 1.0 - diffuseShading116_g20 )).xx;
				float4 lerpResult127_g20 = lerp( ( diffuseColour118_g20 * float4( litIndirect119_g20 , 0.0 ) ) , temp_output_125_0_g20 , tex2D( _CelShadowTable, temp_cast_4 ));
				float4 lerpResult129_g20 = lerp( lerpResult127_g20 , temp_output_125_0_g20 , diffuseShading116_g20);
				UNITY_LIGHT_ATTENUATION(ase_atten, i, WorldPosition)
				#ifdef UNITY_PASS_FORWARDBASE
				float4 staticSwitch136_g20 = lerpResult129_g20;
				#else
				float4 staticSwitch136_g20 = ( lerpResult129_g20 * ase_atten );
				#endif
				
				
				finalColor = ( 0.8 * staticSwitch136_g20 );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18909
2015;1177;1818;922;1841.532;871.0372;2.107179;True;False
Node;AmplifyShaderEditor.ScreenPosInputsNode;197;-1528.372,137.8301;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;204;-1529.927,319.6241;Inherit;False;Property;_OutlineDistanceAdjust;Outline Distance Adjust;24;0;Create;True;0;0;0;False;0;False;0.1,-0.1,0.2,1;0.1,-0.1,0.2,1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;189;-1328.172,40.82092;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;203;-1260.396,261.1858;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;208;-1160.927,52.62408;Inherit;False;outlineZPush;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;227;-1324.125,646.0742;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;205;-1084.927,260.6241;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;224;-1355.824,813.7051;Inherit;False;208;outlineZPush;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldToObjectTransfNode;229;-1169.876,643.9953;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalVertexDataNode;190;-930.172,-185.1791;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;193;-920.172,-29.17908;Inherit;False;Constant;_Float1;Float 1;1;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;207;-1157.927,132.6241;Inherit;False;outlineWidth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;206;-941.9268,257.6241;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;231;-981.5345,645.4365;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;225;-1138.824,816.7051;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;234;-1056.474,1034.859;Inherit;False;Constant;_Float2;Float 0;3;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;191;-906.172,-287.1791;Inherit;False;Property;_OutlineWidth;Outline Width;25;0;Create;True;0;0;0;False;0;False;0.1;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;233;-1064.474,947.8592;Inherit;False;Constant;_Float0;Float 0;3;0;Create;True;0;0;0;False;0;False;0.04;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;232;-813.5345,642.4365;Inherit;False;4;4;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;192;-725.172,-243.1791;Inherit;False;5;5;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;214;-526.1741,155.1539;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FunctionNode;199;-715.5914,-391.2628;Inherit;False;IdolCelLighting;0;;20;a1be52503abdf5b4bba14a8388d9c7c5;0;0;2;FLOAT;152;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;235;-241.4635,-612.8721;Float;False;True;-1;2;ASEMaterialInspector;100;1;Silent/IdolCelShader Outlines;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;FORWARD;2;False;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;True;True;1;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;2;Include;;False;;Native;Pragma;multi_compile_fwdbase;False;;Custom;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;203;0;197;3
WireConnection;203;1;204;1
WireConnection;203;2;204;2
WireConnection;208;0;189;3
WireConnection;205;0;203;0
WireConnection;229;0;227;0
WireConnection;207;0;189;4
WireConnection;206;0;205;0
WireConnection;206;3;204;3
WireConnection;206;4;204;4
WireConnection;231;0;229;0
WireConnection;225;0;224;0
WireConnection;232;0;231;0
WireConnection;232;1;225;0
WireConnection;232;2;233;0
WireConnection;232;3;234;0
WireConnection;192;0;191;0
WireConnection;192;1;190;0
WireConnection;192;2;193;0
WireConnection;192;3;207;0
WireConnection;192;4;206;0
WireConnection;214;0;192;0
WireConnection;214;1;232;0
WireConnection;235;0;199;0
WireConnection;235;1;214;0
ASEEND*/
//CHKSM=69CC35DAB151C4465A4331B66E8237FAA55B7110