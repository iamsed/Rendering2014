Shader "Animacja/CookTorrence" {
        Properties {
            _MainTex ("Texture", 2D) = "white" {}
            _Color ("Diffuse Color", Color) = (1,1,1,1)
            _Color2 ("Specular Color", Color) = (1,1,1,1)
        }
        SubShader {
        Tags { "RenderType" = "Opaque" }
	CGPROGRAM
       #pragma surface surf SimpleSpecular
   		half3 _Color;
   		half3 _Color2;
   		
   		#include "UnityCG.cginc"

   		half4 LightingSimpleSpecular (SurfaceOutput s, half3 lightDir, half3 viewDir, half atten) 
   		{
   		
   		    half diff = max (0, dot (s.Normal, lightDir));
			half3 N = s.Normal;
			half3 L = lightDir;
			half3 V = normalize(viewDir);
			float dotLN = clamp( dot(N, L) , 0.0, 1.0); // przemiennosc iloczynu skalarnego
			
			half3 H = normalize(L + V); // oba znormalizowane wiec wychodzi srednia
			float dotNH = dot(N, H);
			float dotNV = dot(N, V);
			float dotVH = dot(V, H);
			
			// G - czynnik geometryczny
			float G1 = 2.0*dotNH*dotNV / dotVH;
			float G2 = 2.0*dotNH*dotLN / dotVH;
			float G3 = 1.0;
			float G = min(max(G1, G2), G3);
			
			// D - rozklad powierzchni zorientowanych w kierunku H (ekstynkcja)
			float c = 0.1; // matowosc male c2 - powierzchnia blyszczaca, duze (np. 0.8) c2 powierzchnia matowa
			float c2 = c*c;
			// alfa to kat pomiedzy H i N, ale my potrzebujemy cosinusa, how convenient
			float mianownikD = dotNH*dotNH*(c2 - 1.0) + 1.0;
			float D = c2 / mianownikD;
			
			// nie liczone cook-torrencowo D bo nie rozumiem co to 'm'
			
			
			//D = 1.0;
			//http://http.download.nvidia.com/developer/SDK/Individual_Samples/DEMOS/Direct3D9/src/HLSL_FresnelReflection/docs/FresnelReflection.pdf
			float R0 = 1.51;
			float cosAngle = 1.0 - clamp(dot(L, N),0.0,1.0); 
			float F = cosAngle * cosAngle; 
			F = F * F; 
			F = F * cosAngle; 
			F = clamp(F * (1.0 - clamp(R0,0.0,1.0)) + R0, 0.0 ,1.0);
			
			float pi = 3.1415926;
			float PhongBlinn = (D * G * F) / ( dotNV * dotLN * pi);
			PhongBlinn = clamp(PhongBlinn, 0.0, 1.0);
			
			half3 diffuseColor= _Color;
			half3 specularColor= _Color2;
			
			float d=0.5;
			
				half4 outputColor;
			
		
   		    
   		    outputColor.rgb = ( _LightColor0.rgb * diff * diffuseColor + _LightColor0.rgb * specularColor * PhongBlinn) * (atten * 2);
   		
   		    outputColor.a = s.Alpha;
   		    
	       
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