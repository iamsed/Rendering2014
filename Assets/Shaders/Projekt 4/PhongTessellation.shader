Shader "Animacja/Tessellation/Phong Tessellation" {
        Properties {
            _EdgeLength ("Edge length", Range(2,50)) = 5
            _Phong ("Phong Strengh", Range(0,1)) = 0.5
            _MainTex ("Base (RGB)", 2D) = "white" {}
            _Color ("Color", color) = (1,1,1,0)
        }
        SubShader {
            Tags { "RenderType"="Opaque" }
            LOD 300
            
            CGPROGRAM
            #pragma surface surf Lambert vertex:dispNone tessellate:tessEdge tessphong:_Phong nolightmap
            
            float UnityCalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen)
			{
				// distance to edge center
				float dist = distance (0.5 * (wpos0+wpos1), _WorldSpaceCameraPos);
				// length of the edge
				float len = distance(wpos0, wpos1);
				// edgeLen is approximate desired size in pixels
				float f = max(len * _ScreenParams.y / (edgeLen * dist), 1.0);
				return f;
			}
            
            // Desired edge length based tessellation:
			// Approximate resulting edge length in pixels is "edgeLength".
			// Does not take viewing FOV into account, just flat out divides factor by distance.
			float4 UnityEdgeLengthBasedTess (float4 v0, float4 v1, float4 v2, float edgeLength)
			{
				float3 pos0 = mul(_Object2World,v0).xyz;
				float3 pos1 = mul(_Object2World,v1).xyz;
				float3 pos2 = mul(_Object2World,v2).xyz;
				float4 tess;
				tess.x = UnityCalcEdgeTessFactor (pos1, pos2, edgeLength);
				tess.y = UnityCalcEdgeTessFactor (pos2, pos0, edgeLength);
				tess.z = UnityCalcEdgeTessFactor (pos0, pos1, edgeLength);
				tess.w = (tess.x + tess.y + tess.z) / 3.0f;
				return tess;
			}

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
            };

            void dispNone (inout appdata v) { }

            float _Phong;
            float _EdgeLength;

            float4 tessEdge (appdata v0, appdata v1, appdata v2)
            {
                return UnityEdgeLengthBasedTess (v0.vertex, v1.vertex, v2.vertex, _EdgeLength);
            }

            struct Input {
                float2 uv_MainTex;
            };

            fixed4 _Color;
            sampler2D _MainTex;

            void surf (Input IN, inout SurfaceOutput o) {
                half4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
                o.Albedo = c.rgb;
                o.Alpha = c.a;
            }

            ENDCG
        }
        FallBack "Diffuse"
    }	