// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Dirty Wall" {
  Properties{
    _Color("Color", Color) = (1,1,1,1)
    _MainTex("Albedo (RGB)", 2D) = "white" {}
    _BumpMap("Normal", 2D) = "bump" {}
    _BlueNoise("Blue Noise", 2D) = "blue noise" {}
    _Glossiness("Smoothness", Range(0,1)) = 0.5
    _Metallic("Metallic", Range(0,1)) = 0.0
    _Seed("Seed", Range(0, 50000)) = 123
    _MeshSize("Mesh Size", Vector) = (1,1,1)
  }
    SubShader{
      Tags { "RenderType" = "Opaque" }
      LOD 200
      CGPROGRAM

      #include "UnityCG.cginc" 

      #pragma surface surf Standard vertex:vert addshadow
      #pragma target 3.0

      sampler2D _MainTex;
      sampler2D _BumpMap;
      sampler2D _BlueNoise;

      struct Input {
        float2 uv_MainTex;
        float2 uv_BumpMap;

        float2 customBumpMap;
      };

      half _Glossiness;
      half _Metallic;
      fixed4 _Color;
      float _Seed;
      half3 _MeshSize;

      float hash(float n) {
        return frac(sin(n)*43758.5453);
      }

      float noise(float3 x) {
        float3 p = floor(x);
        float3 f = frac(x);

        f = f * f*(3.0 - 2.0*f);
        float n = p.x + p.y*57.0 + 113.0*p.z;

        return lerp(lerp(lerp(hash(n + 0.0), hash(n + 1.0),f.x),
               lerp(hash(n + 57.0), hash(n + 58.0),f.x),f.y),
               lerp(lerp(hash(n + 113.0), hash(n + 114.0),f.x),
               lerp(hash(n + 170.0), hash(n + 171.0),f.x),f.y),f.z);
      }

      struct v2f {
        float4 pos : SV_POSITION;
        float2 uv : TEXCOORD0;
        float2 normalUv : TEXCOORD1;
        fixed4 color : COLOR;
      };

      void vert(inout appdata_full v, out Input o) {
        UNITY_INITIALIZE_OUTPUT(Input, o);
        o.customBumpMap = v.texcoord;
        float4 worldPosition = mul(unity_ObjectToWorld, v.vertex);
        float sinX = sin(worldPosition.x) * 1;
        float cosY = cos(worldPosition.y) * 1;
        float2x2 rotationMatrix = float2x2(sinX, -cosY, cosY, sinX);
        v.texcoord.xy = mul(v.texcoord.xy, rotationMatrix) * 0.5;
      }

      void surf (Input IN, inout SurfaceOutputStandard o) {
        fixed4 blueNoise = tex2D(_BlueNoise, IN.uv_MainTex);

        float x = IN.uv_MainTex.x * blueNoise.xzy;
        float y = IN.uv_MainTex.y * blueNoise.xyz;
        float2 mainTex = float2(x, y);
        fixed4 c = tex2D (_MainTex, mainTex);

        o.Albedo = _Color * c.rgb;

        o.Normal = UnpackNormal(tex2D(_BumpMap, IN.customBumpMap));
        o.Metallic = _Metallic;
        o.Smoothness = _Glossiness;
        o.Alpha = c.a;
      }


      ENDCG
    }
    FallBack "Diffuse"
}
