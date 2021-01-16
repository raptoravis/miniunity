Shader "Custom/Toon"
{
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Bump ("Bump", 2D) = "bump" {}
		_Tooniness ("Tooniness", Range(0.1,20)) = 4
		_ColorMerge ("Color Merge", Range(0.1,20)) = 8
		_Ramp ("Ramp Texture", 2D) = "white" {}
		_Outline ("Outline", Range(0,1)) = 0.4
	}

	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
//#pragma surface surf Lambert finalcolor:final
//#pragma surface surf Lambert 
#pragma surface surf Toon

		sampler2D _MainTex;
		sampler2D _Bump;
		float _Tooniness;
		float _ColorMerge;
		sampler2D _Ramp;
		float _Outline;


		struct Input {
			float2 uv_MainTex;
			float2 uv_Bump;
			float3 viewDir;
		};

		void surf (Input IN, inout SurfaceOutput o) {
			half4 c = tex2D (_MainTex, IN.uv_MainTex);
			o.Normal = UnpackNormal( tex2D(_Bump, IN.uv_Bump));

			//o.Albedo = c.rgb;
			//o.Albedo = floor(c.rgb*_ColorMerge)/_ColorMerge;

			half edge = saturate(dot (o.Normal, normalize(IN.viewDir))); 
			edge = edge < _Outline ? edge/4 : 1;
			o.Albedo = (floor(c.rgb*_ColorMerge)/_ColorMerge) * edge;

			o.Alpha = c.a;
		}

		void final(Input IN, SurfaceOutput o, inout fixed4 color) {
			color = floor(color * _Tooniness)/_Tooniness;
		}

		half4 LightingToon(SurfaceOutput s, half3 lightDir, half atten){
			half4 c;
			half NdotL = dot(s.Normal, lightDir); 
			//NdotL = floor(NdotL * _Tooniness)/_Tooniness;
			NdotL = saturate(tex2D(_Ramp, float2(NdotL, 0.5)));
			c.rgb = s.Albedo * _LightColor0.rgb * NdotL * atten * 2;
			c.a = s.Alpha;
			return c;
		}

		ENDCG
	} 

    FallBack "Diffuse"
}
