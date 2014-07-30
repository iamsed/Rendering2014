Shader "Animacja/CookTorrence" {
        Properties {
            _MainTex ("Texture", 2D) = "white" {}
            _Color ("Diffuse Color", Color) = (1,1,1,1)
            _Color2 ("Specular Color", Color) = (1,1,1,1)
            _Roughness ("Roughness", Range(0, 1.0)) = 0.3
            _DiffuseReflection ("DiffuseReflection", Range(0, 1.0)) = 0.2
            _FresnelReflectance ("FresnelReflectance", Range(0, 1.0)) = 0.8
        }
        SubShader {
        Tags { "RenderType" = "Opaque" }
	CGPROGRAM
       #pragma surface surf SimpleSpecular
       #pragma target 3.0
      
   		half3 _Color;
   		half3 _Color2;
   		float _Roughness;
   		float _DiffuseReflection;
   		float _FresnelReflectance;
   		
   		#include "UnityCG.cginc"

   		half4 LightingSimpleSpecular (SurfaceOutput s, half3 lightDir, half3 viewDir, half atten) 
   		{
   			 // set important material values
		    float roughnessValue = _Roughness; // 0 : smooth, 1: rough
		    float F0 = _FresnelReflectance; // fresnel reflectance at normal incidence
		    float k = _DiffuseReflection; // fraction of diffuse reflection (specular reflection = 1 - k)
		    half3 diffuseColor= _Color;
			half3 specularColor= _Color2;
		    
		    // interpolating normals will change the length of the normal, so renormalize the normal.
		    half3 norm = normalize(s.Normal);
		    
		    // do the lighting calculation for each fragment.
		    float NdotL = max(dot(norm, lightDir), 0.0);
		    
		    float spec = 0.0;
		    if(NdotL > 0.0)
		    {
		        half3 eyeDir = normalize(viewDir);
		
		        // calculate intermediary values
		        half3 halfVector = normalize(lightDir + eyeDir);
		        float NdotH = max(dot(norm, halfVector), 0.0); 
		        float NdotV = max(dot(norm, eyeDir), 0.0); // note: this could also be NdotL, which is the same value
		        float VdotH = max(dot(eyeDir, halfVector), 0.0);
		        float mSquared = roughnessValue * roughnessValue;
		        
		        // geometric attenuation
		        float NH2 = 2.0 * NdotH;
		        float g1 = (NH2 * NdotV) / VdotH;
		        float g2 = (NH2 * NdotL) / VdotH;
		        float geoAtt = min(1.0, min(g1, g2));
		     
		        // roughness (or: microfacet distribution function)
		        // beckmann distribution function
		        float r1 = 1.0 / ( 4.0 * mSquared * pow(NdotH, 4.0));
		        float r2 = (NdotH * NdotH - 1.0) / (mSquared * NdotH * NdotH);
		        float roughness = r1 * exp(r2);
		        
		        // fresnel
		        // Schlick approximation
		        float fresnel = pow(1.0 - VdotH, 5.0);
		        fresnel *= (1.0 - F0);
		        fresnel += F0;
		        
		        spec = (fresnel * geoAtt * roughness) / (NdotV * NdotL * 3.14);
		    }
		    
		    half3 finalValue = diffuseColor * NdotL * (k + spec * (1.0 - k));
			
			   		return half4(finalValue.xyz, 1);   		
   		
   		
//   		    half diff = max (0, dot (s.Normal, lightDir));
//			half3 N = s.Normal;
//			half3 L = lightDir;
//			half3 V = normalize(viewDir);
//			float dotLN = clamp( dot(N, L) , 0.0, 1.0); // przemiennosc iloczynu skalarnego
//			
//			half3 H = normalize(L + V); // oba znormalizowane wiec wychodzi srednia
//			float dotNH = dot(N, H);
//			float dotNV = dot(N, V);
//			float dotVH = dot(V, H);
//			
//			// G - czynnik geometryczny
//			float G1 = 2.0*dotNH*dotNV / dotVH;
//			float G2 = 2.0*dotNH*dotLN / dotVH;
//			float G3 = 1.0;
//			float G = min(max(G1, G2), G3);
//			
//			// D - rozklad powierzchni zorientowanych w kierunku H (ekstynkcja)
//			float c = 0.1; // matowosc male c2 - powierzchnia blyszczaca, duze (np. 0.8) c2 powierzchnia matowa
//			float c2 = c*c;
//			// alfa to kat pomiedzy H i N, ale my potrzebujemy cosinusa, how convenient
//			float mianownikD = dotNH*dotNH*(c2 - 1.0) + 1.0;
//			float D = c2 / mianownikD;
//			
//			// nie liczone cook-torrencowo D bo nie rozumiem co to 'm'
//			
//			
//			//D = 1.0;
//			//http://http.download.nvidia.com/developer/SDK/Individual_Samples/DEMOS/Direct3D9/src/HLSL_FresnelReflection/docs/FresnelReflection.pdf
//			float R0 = 1.51;
//			float cosAngle = 1.0 - clamp(dot(L, N),0.0,1.0); 
//			float F = cosAngle * cosAngle; 
//			F = F * F; 
//			F = F * cosAngle; 
//			F = clamp(F * (1.0 - clamp(R0,0.0,1.0)) + R0, 0.0 ,1.0);
//			
//			float pi = 3.1415926;
//			float PhongBlinn = (D * G * F) / ( dotNV * dotLN * pi);
//			PhongBlinn = clamp(PhongBlinn, 0.0, 1.0);
//			
//			half3 diffuseColor= _Color;
//			half3 specularColor= _Color2;
//			
//			half4 outputColor;
//			
//		
//   		    
//   		    outputColor.rgb = ( _LightColor0.rgb * diff * diffuseColor + _LightColor0.rgb * specularColor * PhongBlinn) * (atten * 2);
//   		
//   		    outputColor.a = s.Alpha;
//   		    
//	       
//   		    return outputColor;
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