// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom Overlap Region Color/CORCUnlit"
{
	Properties
	{
		 _MainTex("Sprite Texture", 2D) = "white" {}
		_Color("Albedo", Color) = (1, 1, 0, 1)
		_OverlapColor("Overlap Color", Color) = (0, 0, 0, 1)
	}
	SubShader
	{
		Tags
		{  
			"RenderType" = "Opaque"
			"IgnoreProjector" = "True" 
			"Queue" = "Geometry+10" 
			"PreviewType" = "Plane"
			"CanUseSpriteAtlas" = "True"
		}
		Cull Off
		LOD 100
		Pass
		{
			Stencil {
				Ref 0
				Comp Equal
				Pass IncrSat
				Fail IncrSat
			}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color : COLOR;
				float2 texcoord  : TEXCOORD0;
				float4 worldPosition : TEXCOORD1;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			half4 _Color;
			fixed4 _TextureSampleAdd;
			sampler2D _MainTex;
			float4 _MainTex_ST;

			v2f vert(appdata v)
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				o.worldPosition = v.vertex;
				o.vertex = UnityObjectToClipPos(o.worldPosition);

				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.color = v.color * _Color;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				half4 col = (tex2D(_MainTex, i.texcoord) + _TextureSampleAdd) * i.color;
				return col;
			}
			ENDCG
		}
		Pass
		{
			Stencil {
				Ref 2
				Comp Less
			}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
			};

			half4 _OverlapColor;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = _OverlapColor;
				return col;
			}
		ENDCG
		}
		
    }
	
}
