 Shader "Animacja/Bump Mapping/Ward Bump" {
    Properties {
      _MainTex ("Texture", 2D) = "white" {}
      _BumpMap ("Bumpmap", 2D) = "bump" {}
      _Color ("Diffuse Color", Color) = (1,1,1,1)
      _Color2 ("Specular Color", Color) = (1,1,1,1)
    }
    SubShader {
      Tags { "RenderType" = "Opaque" }
      CGPROGRAM
      #pragma surface surf Ward
      
      	half3 _Color;
   		half3 _Color2;
   		
   		#include "UnityCG.cginc"

   		half4 LightingWard (SurfaceOutput surface, half3 lightDir, half3 viewDir, half atten) 
   		{
   		
   		    half3 surfaceNormal = normalize(surface.Normal);
			half3 camLightDir = normalize(lightDir);
			half3 viewDirection = normalize(viewDir);
		
		
			half3 halfAngle = normalize(camLightDir + viewDirection);
			
			float dotLN = clamp(dot(surfaceNormal, camLightDir), 0.0, 1.0);	
			float blinnTerm = dot(surfaceNormal, halfAngle);
		
			blinnTerm = clamp(blinnTerm, 0.0, 1.0);
			blinnTerm = dotLN != 0.0 ? blinnTerm : 0.0;
			blinnTerm = pow(blinnTerm, 10.0);
		
		
			half3 diffuseColor= _Color;
			half3 specularColor= _Color2;
		
			float d=0.5;
			float s_weight=0.5;
			
			//float dotLSL = max(0, dot(camLightDir,normalize(spotLightDir.xyz)));
			half4 outputColor;
			//if (dotLSL > cos(spotLightAngle))
				outputColor = ( half4(d * diffuseColor * dotLN, 1.0) + half4(s_weight * specularColor * blinnTerm, 1.0) ); //*dotLSL;
			//else 
			//	outputColor = vec4(s_weight*half3(0.0,0.0,0.0) * blinnTerm,1.0) +vec4(d*half3(0.0,0.0,0.0) * dotLN,1.0);
				
			return outputColor;
   		}
      
      struct Input {
        float2 uv_MainTex;
        float2 uv_BumpMap;
      };
      sampler2D _MainTex;
      sampler2D _BumpMap;
      void surf (Input IN, inout SurfaceOutput o) {
        o.Albedo = tex2D (_MainTex, IN.uv_MainTex).rgb;
        o.Normal = UnpackNormal (tex2D (_BumpMap, IN.uv_BumpMap));
      }
      ENDCG
    } 
    Fallback "Diffuse"
  }