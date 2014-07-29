Shader "Animacja/Strauss" {
        Properties {
            _MainTex ("Texture", 2D) = "white" {}
            _Color ("Diffuse Color", Color) = (1,1,1,1)
            _Color2 ("Specular Color", Color) = (1,1,1,1)
        }
        SubShader {
        Tags { "RenderType" = "Opaque" }
	CGPROGRAM
       #pragma surface surf Strauss
   		half3 _Color;
   		half3 _Color2;
   		
   		#include "UnityCG.cginc"

   		half4 LightingStrauss (SurfaceOutput surface, half3 lightDir, half3 viewDir, half atten) 
   		{
   		
   		    float s = 0.5;
			float m = 0.1;
			float t = 0.0;
			float n = 0.5;
			
			half3 surfaceNormal = normalize(surface.Normal);
			half3 camLightDir = normalize(lightDir); // normalize(worldLightPos.xyz - interpPosition);
			half3 viewDirection = normalize(viewDir); //normalize(-interpPosition);
			
			
			half3 reflectDir =  reflect(-camLightDir, surfaceNormal);
			float dotLN = clamp(dot(surfaceNormal, camLightDir), 0.0, 1.0);	
			float dotRV  = max(0,dot(viewDirection,reflectDir));
			
			float fd = (1.0 - pow(s, 3)) * (1.0 - t) * dotLN * (1.0 - (m*s));
			
			float kb = 0.1;
			float kf = 1.12;
			float kg = 1.01; //wartosci by strauss
			
			float x = cos(max(dot(surfaceNormal, camLightDir), 0.0) / (3.14159/2.0));
			float F = ( 1.0/pow(x - kf,2.0) - 1.0/pow(kf, 2.0)) / (1.0/pow(1-kf,2.0) - 1.0/pow(kf,2.0));
			
			x = cos(max(dot(surfaceNormal, viewDirection), 0.0) / (3.14159/2.0));
			float G = ( 1.0/pow(x - kg,2.0) - 1.0/pow(kg, 2.0)) / (1.0/pow(1-kg,2.0) - 1.0/pow(kg,2.0));
			
			float rn = (1.0 - t) - fd;
			float b = F * G * G;
			
			float fs = pow(dotRV, 3.0/(1.0 - s)) * min(1, rn + (rn + kb)*b) * (1 + m*(1-F));
			
			
			
			
			half3 diffuseColor= _Color;
			half3 specularColor= _Color2;
		
		
		//float dotLSL = max(0, dot(camLightDir,normalize(spotLightDir.xyz)));
		
		//if (dotLSL > cos(spotLightAngle))
			half4 outputColor = half4(diffuseColor * fd, 1.0) + half4(specularColor * fs, 1.0);//*dotLSL;
		//else 
		//	outputColor = vec4(sc*half3(0.0,0.0,0.0) * fs,1.0) +vec4(dc*half3(0.0,0.0,0.0) * fd,1.0);
	
			return outputColor;
   		}
   		
   		struct Input {
   		    float2 uv_MainTex;
   		};
   		
   		sampler2D _MainTex;
   		
   		void surf (Input IN, inout SurfaceOutput o) {
   		
   			
   		
   		    o.Albedo = tex2D (_MainTex, IN.uv_MainTex).rgb;
   		}
    ENDCG
        }
        Fallback "Diffuse"
    }