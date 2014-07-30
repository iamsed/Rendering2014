Shader "Animacja/Tessellation/EdgeLengthBasedTessellation" {
        Properties {
            _EdgeLength ("Edge length", Range(2,50)) = 15
            _MainTex ("Base (RGB)", 2D) = "white" {}
            _DispTex ("Disp Texture", 2D) = "gray" {}
            _NormalMap ("Normalmap", 2D) = "bump" {}
            _Displacement ("Displacement", Range(0, 1.0)) = 0.3
            _Color ("Color", color) = (1,1,1,0)
            _SpecColor ("Spec color", color) = (0.5,0.5,0.5,0.5)
            
            _MaxDisplacement ("MaxDisplacement", Range(0, 100.0)) = 0.3
            
        }
        SubShader {
            Tags { "RenderType"="Opaque" }
            LOD 300
            
            CGPROGRAM
            #pragma surface surf BlinnPhong addshadow fullforwardshadows vertex:disp tessellate:tessEdge nolightmap
            #pragma target 5.0
            #include "UnityShaderVariables.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float4 tangent : TANGENT;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
            };

            float _EdgeLength;
            
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
			
			float UnityDistanceFromPlane (float3 pos, float4 plane)
			{
				float d = dot (float4(pos,1.0f), plane);
				return d;
			}
			
			bool UnityWorldViewFrustumCull (float3 wpos0, float3 wpos1, float3 wpos2, float cullEps)
			{    
				float4 planeTest;
				
				// left
				planeTest.x = (( UnityDistanceFromPlane(wpos0, unity_CameraWorldClipPlanes[0]) > -cullEps) ? 1.0f : 0.0f ) +
							  (( UnityDistanceFromPlane(wpos1, unity_CameraWorldClipPlanes[0]) > -cullEps) ? 1.0f : 0.0f ) +
							  (( UnityDistanceFromPlane(wpos2, unity_CameraWorldClipPlanes[0]) > -cullEps) ? 1.0f : 0.0f );
				// right
				planeTest.y = (( UnityDistanceFromPlane(wpos0, unity_CameraWorldClipPlanes[1]) > -cullEps) ? 1.0f : 0.0f ) +
							  (( UnityDistanceFromPlane(wpos1, unity_CameraWorldClipPlanes[1]) > -cullEps) ? 1.0f : 0.0f ) +
							  (( UnityDistanceFromPlane(wpos2, unity_CameraWorldClipPlanes[1]) > -cullEps) ? 1.0f : 0.0f );
				// top
				planeTest.z = (( UnityDistanceFromPlane(wpos0, unity_CameraWorldClipPlanes[2]) > -cullEps) ? 1.0f : 0.0f ) +
							  (( UnityDistanceFromPlane(wpos1, unity_CameraWorldClipPlanes[2]) > -cullEps) ? 1.0f : 0.0f ) +
							  (( UnityDistanceFromPlane(wpos2, unity_CameraWorldClipPlanes[2]) > -cullEps) ? 1.0f : 0.0f );
				// bottom
				planeTest.w = (( UnityDistanceFromPlane(wpos0, unity_CameraWorldClipPlanes[3]) > -cullEps) ? 1.0f : 0.0f ) +
							  (( UnityDistanceFromPlane(wpos1, unity_CameraWorldClipPlanes[3]) > -cullEps) ? 1.0f : 0.0f ) +
							  (( UnityDistanceFromPlane(wpos2, unity_CameraWorldClipPlanes[3]) > -cullEps) ? 1.0f : 0.0f );
					
				// has to pass all 4 plane tests to be visible
				return !all (planeTest);
			}
            
            // Same as UnityEdgeLengthBasedTess, but also does patch frustum culling:
			// patches outside of camera's view are culled before GPU tessellation. Saves some wasted work.
			float4 UnityEdgeLengthBasedTessCull (float4 v0, float4 v1, float4 v2, float edgeLength, float maxDisplacement)
			{
				float3 pos0 = mul(_Object2World,v0).xyz;
				float3 pos1 = mul(_Object2World,v1).xyz;
				float3 pos2 = mul(_Object2World,v2).xyz;
				float4 tess;
			
				if (UnityWorldViewFrustumCull(pos0, pos1, pos2, maxDisplacement))
				{
					tess = 0.0f;
				}
				else
				{
					tess.x = UnityCalcEdgeTessFactor (pos1, pos2, edgeLength);
					tess.y = UnityCalcEdgeTessFactor (pos2, pos0, edgeLength);
					tess.z = UnityCalcEdgeTessFactor (pos0, pos1, edgeLength);
					tess.w = (tess.x + tess.y + tess.z) / 3.0f;
				}
				return tess;
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
			
			
            float _MaxDisplacement;

            float4 tessEdge (appdata v0, appdata v1, appdata v2)
            {
                //return UnityEdgeLengthBasedTessCull(v0.vertex, v1.vertex, v2.vertex, _EdgeLength, _MaxDisplacement);
                return UnityEdgeLengthBasedTess(v0.vertex, v1.vertex, v2.vertex, _EdgeLength);
            }

            sampler2D _DispTex;
            float _Displacement;

            void disp (inout appdata v)
            {
                float d = tex2Dlod(_DispTex, float4(v.texcoord.xy,0,0)).r * _Displacement;
                v.vertex.xyz += v.normal * d;
            }

            struct Input {
                float2 uv_MainTex;
            };

            sampler2D _MainTex;
            sampler2D _NormalMap;
            fixed4 _Color;

            void surf (Input IN, inout SurfaceOutput o) {
                half4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
                o.Albedo = c.rgb;
                o.Specular = 0.2;
                o.Gloss = 1.0;
                o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv_MainTex));
            }
            ENDCG
        }
        FallBack "Diffuse"
    }