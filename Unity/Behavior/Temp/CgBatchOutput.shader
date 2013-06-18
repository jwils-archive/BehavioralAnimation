// Upgrade NOTE: replaced 'PositionFog()' with multiply of UNITY_MATRIX_MVP by position
// Upgrade NOTE: replaced 'V2F_POS_FOG' with 'float4 pos : SV_POSITION'

Shader "FX/Water (simple)" {
Properties {
	_horizonColor ("Horizon color", COLOR)  = ( .172 , .463 , .435 , 0)
	_WaveScale ("Wave scale", Range (0.02,0.15)) = .07
	_ColorControl ("Reflective color (RGB) fresnel (A) ", 2D) = "" { }
	_ColorControlCube ("Reflective color cube (RGB) fresnel (A) ", Cube) = "" { TexGen CubeReflect }
	_BumpMap ("Waves Bumpmap (RGB) ", 2D) = "" { }
	WaveSpeed ("Wave speed (map1 x,y; map2 x,y)", Vector) = (19,9,-16,-7)
	_MainTex ("Fallback texture", 2D) = "" { }
}

#LINE 57

	
// -----------------------------------------------------------
// Fragment program

Subshader {
	Tags { "RenderType"="Opaque" }
	Pass {

Program "vp" {
// Vertex combos: 1
//   opengl - ALU: 17 to 17
//   d3d9 - ALU: 17 to 17
//   d3d11 - ALU: 7 to 7, TEX: 0 to 0, FLOW: 1 to 1
//   d3d11_9x - ALU: 7 to 7, TEX: 0 to 0, FLOW: 1 to 1
SubProgram "opengl " {
Keywords { }
Bind "vertex" Vertex
Vector 9 [_WorldSpaceCameraPos]
Matrix 5 [_World2Object]
Vector 10 [unity_Scale]
Float 11 [_WaveScale]
Vector 12 [_WaveOffset]
"!!ARBvp1.0
# 17 ALU
PARAM c[13] = { { 0.40000001, 0.44999999, 1 },
		state.matrix.mvp,
		program.local[5..12] };
TEMP R0;
TEMP R1;
MOV R1.w, c[0].z;
MOV R1.xyz, c[9];
DP4 R0.z, R1, c[7];
DP4 R0.x, R1, c[5];
DP4 R0.y, R1, c[6];
MAD R1.xyz, R0, c[10].w, -vertex.position;
DP3 R0.z, R1, R1;
RSQ R1.w, R0.z;
MUL R0.xy, vertex.position.xzzw, c[11].x;
ADD R0, R0.xyxy, c[12];
MUL result.texcoord[2].xyz, R1.w, R1.xzyw;
MUL result.texcoord[0].xy, R0, c[0];
MOV result.texcoord[1].xy, R0.wzzw;
DP4 result.position.w, vertex.position, c[4];
DP4 result.position.z, vertex.position, c[3];
DP4 result.position.y, vertex.position, c[2];
DP4 result.position.x, vertex.position, c[1];
END
# 17 instructions, 2 R-regs
"
}

SubProgram "d3d9 " {
Keywords { }
Bind "vertex" Vertex
Matrix 0 [glstate_matrix_mvp]
Vector 8 [_WorldSpaceCameraPos]
Matrix 4 [_World2Object]
Vector 9 [unity_Scale]
Float 10 [_WaveScale]
Vector 11 [_WaveOffset]
"vs_2_0
; 17 ALU
def c12, 0.40000001, 0.44999999, 1.00000000, 0
dcl_position0 v0
mov r1.w, c12.z
mov r1.xyz, c8
dp4 r0.z, r1, c6
dp4 r0.x, r1, c4
dp4 r0.y, r1, c5
mad r1.xyz, r0, c9.w, -v0
dp3 r0.z, r1, r1
rsq r1.w, r0.z
mul r0.xy, v0.xzzw, c10.x
add r0, r0.xyxy, c11
mul oT2.xyz, r1.w, r1.xzyw
mul oT0.xy, r0, c12
mov oT1.xy, r0.wzzw
dp4 oPos.w, v0, c3
dp4 oPos.z, v0, c2
dp4 oPos.y, v0, c1
dp4 oPos.x, v0, c0
"
}

SubProgram "d3d11 " {
Keywords { }
Bind "vertex" Vertex
ConstBuffer "$Globals" 80 // 80 used size, 5 vars
Float 48 [_WaveScale]
Vector 64 [_WaveOffset] 4
ConstBuffer "UnityPerCamera" 128 // 76 used size, 8 vars
Vector 64 [_WorldSpaceCameraPos] 3
ConstBuffer "UnityPerDraw" 336 // 336 used size, 6 vars
Matrix 0 [glstate_matrix_mvp] 4
Matrix 256 [_World2Object] 4
Vector 320 [unity_Scale] 4
BindCB "$Globals" 0
BindCB "UnityPerCamera" 1
BindCB "UnityPerDraw" 2
// 16 instructions, 1 temp regs, 0 temp arrays:
// ALU 7 float, 0 int, 0 uint
// TEX 0 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 1 static, 0 dynamic
"vs_4_0
eefiecedofjlhpdomddkckicfnbflflikkbjlfnlabaaaaaakeadaaaaadaaaaaa
cmaaaaaahmaaaaaaaeabaaaaejfdeheoeiaaaaaaacaaaaaaaiaaaaaadiaaaaaa
aaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaapapaaaaebaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaabaaaaaaahaaaaaafaepfdejfeejepeoaaeoepfcenebemaaepfdeheo
iaaaaaaaaeaaaaaaaiaaaaaagiaaaaaaaaaaaaaaabaaaaaaadaaaaaaaaaaaaaa
apaaaaaaheaaaaaaaaaaaaaaaaaaaaaaadaaaaaaabaaaaaaadamaaaaheaaaaaa
abaaaaaaaaaaaaaaadaaaaaaacaaaaaaadamaaaaheaaaaaaacaaaaaaaaaaaaaa
adaaaaaaadaaaaaaahaiaaaafdfgfpfaepfdejfeejepeoaafeeffiedepepfcee
aaklklklfdeieefcjiacaaaaeaaaabaakgaaaaaafjaaaaaeegiocaaaaaaaaaaa
afaaaaaafjaaaaaeegiocaaaabaaaaaaafaaaaaafjaaaaaeegiocaaaacaaaaaa
bfaaaaaafpaaaaadpcbabaaaaaaaaaaaghaaaaaepccabaaaaaaaaaaaabaaaaaa
gfaaaaaddccabaaaabaaaaaagfaaaaaddccabaaaacaaaaaagfaaaaadhccabaaa
adaaaaaagiaaaaacabaaaaaadiaaaaaipcaabaaaaaaaaaaafgbfbaaaaaaaaaaa
egiocaaaacaaaaaaabaaaaaadcaaaaakpcaabaaaaaaaaaaaegiocaaaacaaaaaa
aaaaaaaaagbabaaaaaaaaaaaegaobaaaaaaaaaaadcaaaaakpcaabaaaaaaaaaaa
egiocaaaacaaaaaaacaaaaaakgbkbaaaaaaaaaaaegaobaaaaaaaaaaadcaaaaak
pccabaaaaaaaaaaaegiocaaaacaaaaaaadaaaaaapgbpbaaaaaaaaaaaegaobaaa
aaaaaaaadcaaaaalpcaabaaaaaaaaaaaigbibaaaaaaaaaaaagiacaaaaaaaaaaa
adaaaaaaegiocaaaaaaaaaaaaeaaaaaadiaaaaakdccabaaaabaaaaaaegaabaaa
aaaaaaaaaceaaaaamnmmmmdoggggogdoaaaaaaaaaaaaaaaadgaaaaafdccabaaa
acaaaaaalgapbaaaaaaaaaaadiaaaaajhcaabaaaaaaaaaaafgifcaaaabaaaaaa
aeaaaaaaigibcaaaacaaaaaabbaaaaaadcaaaaalhcaabaaaaaaaaaaaigibcaaa
acaaaaaabaaaaaaaagiacaaaabaaaaaaaeaaaaaaegacbaaaaaaaaaaadcaaaaal
hcaabaaaaaaaaaaaigibcaaaacaaaaaabcaaaaaakgikcaaaabaaaaaaaeaaaaaa
egacbaaaaaaaaaaaaaaaaaaihcaabaaaaaaaaaaaegacbaaaaaaaaaaaigibcaaa
acaaaaaabdaaaaaadcaaaaalhcaabaaaaaaaaaaaegacbaaaaaaaaaaapgipcaaa
acaaaaaabeaaaaaaigbbbaiaebaaaaaaaaaaaaaabaaaaaahicaabaaaaaaaaaaa
egacbaaaaaaaaaaaegacbaaaaaaaaaaaeeaaaaaficaabaaaaaaaaaaadkaabaaa
aaaaaaaadiaaaaahhccabaaaadaaaaaapgapbaaaaaaaaaaaegacbaaaaaaaaaaa
doaaaaab"
}

SubProgram "gles " {
Keywords { }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec3 xlv_TEXCOORD2;
varying highp vec2 xlv_TEXCOORD0_1;
varying highp vec2 xlv_TEXCOORD0;
uniform highp vec4 _WaveOffset;
uniform highp float _WaveScale;
uniform highp vec4 unity_Scale;
uniform highp mat4 _World2Object;

uniform highp vec3 _WorldSpaceCameraPos;
attribute vec4 _glesVertex;
void main ()
{
  highp vec4 temp_1;
  temp_1 = ((_glesVertex.xzxz * _WaveScale) + _WaveOffset);
  highp vec4 tmpvar_2;
  tmpvar_2.w = 1.0;
  tmpvar_2.xyz = _WorldSpaceCameraPos;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = (temp_1.xy * vec2(0.4, 0.45));
  xlv_TEXCOORD0_1 = temp_1.wz;
  xlv_TEXCOORD2 = normalize((((_World2Object * tmpvar_2).xyz * unity_Scale.w) - _glesVertex.xyz)).xzy;
}



#endif
#ifdef FRAGMENT

varying highp vec3 xlv_TEXCOORD2;
varying highp vec2 xlv_TEXCOORD0_1;
varying highp vec2 xlv_TEXCOORD0;
uniform sampler2D _ColorControl;
uniform sampler2D _BumpMap;
uniform highp vec4 _horizonColor;
void main ()
{
  mediump vec4 col_1;
  mediump vec4 water_2;
  mediump float fresnel_3;
  mediump vec3 bump2_4;
  mediump vec3 bump1_5;
  lowp vec3 tmpvar_6;
  tmpvar_6 = texture2D (_BumpMap, xlv_TEXCOORD0).xyz;
  bump1_5 = tmpvar_6;
  lowp vec3 tmpvar_7;
  tmpvar_7 = texture2D (_BumpMap, xlv_TEXCOORD0_1).xyz;
  bump2_4 = tmpvar_7;
  mediump vec3 tmpvar_8;
  tmpvar_8 = ((bump1_5 + bump2_4) - 1.0);
  highp float tmpvar_9;
  tmpvar_9 = dot (xlv_TEXCOORD2, tmpvar_8);
  fresnel_3 = tmpvar_9;
  lowp vec4 tmpvar_10;
  tmpvar_10 = texture2D (_ColorControl, vec2(fresnel_3));
  water_2 = tmpvar_10;
  highp vec3 tmpvar_11;
  tmpvar_11 = mix (water_2.xyz, _horizonColor.xyz, water_2.www);
  col_1.xyz = tmpvar_11;
  highp float tmpvar_12;
  tmpvar_12 = _horizonColor.w;
  col_1.w = tmpvar_12;
  gl_FragData[0] = col_1;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { }
"!!GLES
#define SHADER_API_GLES 1
#define tex2D texture2D


#ifdef VERTEX
#define gl_ModelViewProjectionMatrix glstate_matrix_mvp
uniform mat4 glstate_matrix_mvp;

varying highp vec3 xlv_TEXCOORD2;
varying highp vec2 xlv_TEXCOORD0_1;
varying highp vec2 xlv_TEXCOORD0;
uniform highp vec4 _WaveOffset;
uniform highp float _WaveScale;
uniform highp vec4 unity_Scale;
uniform highp mat4 _World2Object;

uniform highp vec3 _WorldSpaceCameraPos;
attribute vec4 _glesVertex;
void main ()
{
  highp vec4 temp_1;
  temp_1 = ((_glesVertex.xzxz * _WaveScale) + _WaveOffset);
  highp vec4 tmpvar_2;
  tmpvar_2.w = 1.0;
  tmpvar_2.xyz = _WorldSpaceCameraPos;
  gl_Position = (gl_ModelViewProjectionMatrix * _glesVertex);
  xlv_TEXCOORD0 = (temp_1.xy * vec2(0.4, 0.45));
  xlv_TEXCOORD0_1 = temp_1.wz;
  xlv_TEXCOORD2 = normalize((((_World2Object * tmpvar_2).xyz * unity_Scale.w) - _glesVertex.xyz)).xzy;
}



#endif
#ifdef FRAGMENT

varying highp vec3 xlv_TEXCOORD2;
varying highp vec2 xlv_TEXCOORD0_1;
varying highp vec2 xlv_TEXCOORD0;
uniform sampler2D _ColorControl;
uniform sampler2D _BumpMap;
uniform highp vec4 _horizonColor;
void main ()
{
  mediump vec4 col_1;
  mediump vec4 water_2;
  mediump float fresnel_3;
  mediump vec3 bump2_4;
  mediump vec3 bump1_5;
  lowp vec3 tmpvar_6;
  tmpvar_6 = texture2D (_BumpMap, xlv_TEXCOORD0).xyz;
  bump1_5 = tmpvar_6;
  lowp vec3 tmpvar_7;
  tmpvar_7 = texture2D (_BumpMap, xlv_TEXCOORD0_1).xyz;
  bump2_4 = tmpvar_7;
  mediump vec3 tmpvar_8;
  tmpvar_8 = ((bump1_5 + bump2_4) - 1.0);
  highp float tmpvar_9;
  tmpvar_9 = dot (xlv_TEXCOORD2, tmpvar_8);
  fresnel_3 = tmpvar_9;
  lowp vec4 tmpvar_10;
  tmpvar_10 = texture2D (_ColorControl, vec2(fresnel_3));
  water_2 = tmpvar_10;
  highp vec3 tmpvar_11;
  tmpvar_11 = mix (water_2.xyz, _horizonColor.xyz, water_2.www);
  col_1.xyz = tmpvar_11;
  highp float tmpvar_12;
  tmpvar_12 = _horizonColor.w;
  col_1.w = tmpvar_12;
  gl_FragData[0] = col_1;
}



#endif"
}

SubProgram "flash " {
Keywords { }
Bind "vertex" Vertex
Matrix 0 [glstate_matrix_mvp]
Vector 8 [_WorldSpaceCameraPos]
Matrix 4 [_World2Object]
Vector 9 [unity_Scale]
Float 10 [_WaveScale]
Vector 11 [_WaveOffset]
"agal_vs
c12 0.4 0.45 1.0 0.0
[bc]
aaaaaaaaabaaaiacamaaaakkabaaaaaaaaaaaaaaaaaaaaaa mov r1.w, c12.z
aaaaaaaaabaaahacaiaaaaoeabaaaaaaaaaaaaaaaaaaaaaa mov r1.xyz, c8
bdaaaaaaaaaaaeacabaaaaoeacaaaaaaagaaaaoeabaaaaaa dp4 r0.z, r1, c6
bdaaaaaaaaaaabacabaaaaoeacaaaaaaaeaaaaoeabaaaaaa dp4 r0.x, r1, c4
bdaaaaaaaaaaacacabaaaaoeacaaaaaaafaaaaoeabaaaaaa dp4 r0.y, r1, c5
adaaaaaaacaaahacaaaaaakeacaaaaaaajaaaappabaaaaaa mul r2.xyz, r0.xyzz, c9.w
acaaaaaaabaaahacacaaaakeacaaaaaaaaaaaaoeaaaaaaaa sub r1.xyz, r2.xyzz, a0
bcaaaaaaaaaaaeacabaaaakeacaaaaaaabaaaakeacaaaaaa dp3 r0.z, r1.xyzz, r1.xyzz
akaaaaaaabaaaiacaaaaaakkacaaaaaaaaaaaaaaaaaaaaaa rsq r1.w, r0.z
adaaaaaaaaaaadacaaaaaaoiaaaaaaaaakaaaaaaabaaaaaa mul r0.xy, a0.xzzw, c10.x
abaaaaaaaaaaapacaaaaaaeeacaaaaaaalaaaaoeabaaaaaa add r0, r0.xyxy, c11
adaaaaaaacaaahaeabaaaappacaaaaaaabaaaafiacaaaaaa mul v2.xyz, r1.w, r1.xzyy
adaaaaaaaaaaadaeaaaaaafeacaaaaaaamaaaaoeabaaaaaa mul v0.xy, r0.xyyy, c12
aaaaaaaaabaaadaeaaaaaaklacaaaaaaaaaaaaaaaaaaaaaa mov v1.xy, r0.wzzz
bdaaaaaaaaaaaiadaaaaaaoeaaaaaaaaadaaaaoeabaaaaaa dp4 o0.w, a0, c3
bdaaaaaaaaaaaeadaaaaaaoeaaaaaaaaacaaaaoeabaaaaaa dp4 o0.z, a0, c2
bdaaaaaaaaaaacadaaaaaaoeaaaaaaaaabaaaaoeabaaaaaa dp4 o0.y, a0, c1
bdaaaaaaaaaaabadaaaaaaoeaaaaaaaaaaaaaaoeabaaaaaa dp4 o0.x, a0, c0
aaaaaaaaaaaaamaeaaaaaaoeabaaaaaaaaaaaaaaaaaaaaaa mov v0.zw, c0
aaaaaaaaabaaamaeaaaaaaoeabaaaaaaaaaaaaaaaaaaaaaa mov v1.zw, c0
aaaaaaaaacaaaiaeaaaaaaoeabaaaaaaaaaaaaaaaaaaaaaa mov v2.w, c0
"
}

SubProgram "d3d11_9x " {
Keywords { }
Bind "vertex" Vertex
ConstBuffer "$Globals" 80 // 80 used size, 5 vars
Float 48 [_WaveScale]
Vector 64 [_WaveOffset] 4
ConstBuffer "UnityPerCamera" 128 // 76 used size, 8 vars
Vector 64 [_WorldSpaceCameraPos] 3
ConstBuffer "UnityPerDraw" 336 // 336 used size, 6 vars
Matrix 0 [glstate_matrix_mvp] 4
Matrix 256 [_World2Object] 4
Vector 320 [unity_Scale] 4
BindCB "$Globals" 0
BindCB "UnityPerCamera" 1
BindCB "UnityPerDraw" 2
// 16 instructions, 1 temp regs, 0 temp arrays:
// ALU 7 float, 0 int, 0 uint
// TEX 0 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 1 static, 0 dynamic
"vs_4_0_level_9_3
eefiecedgldpfiapnohekbgnkophfcmemajfkimoabaaaaaahaafaaaaaeaaaaaa
daaaaaaapiabaaaajiaeaaaaoiaeaaaaebgpgodjmaabaaaamaabaaaaaaacpopp
giabaaaafiaaaaaaaeaaceaaaaaafeaaaaaafeaaaaaaceaaabaafeaaaaaaadaa
acaaabaaaaaaaaaaabaaaeaaabaaadaaaaaaaaaaacaaaaaaaeaaaeaaaaaaaaaa
acaabaaaafaaaiaaaaaaaaaaaaaaaaaaabacpoppfbaaaaafanaaapkamnmmmmdo
ggggogdoaaaaaaaaaaaaaaaabpaaaaacafaaaaiaaaaaapjaabaaaaacaaaaabia
abaaaakaaeaaaaaeaaaaapiaaaaaiijaaaaaaaiaacaaoekaafaaaaadaaaaadoa
aaaaoeiaanaaoekaabaaaaacabaaadoaaaaaoliaabaaaaacaaaaahiaadaaoeka
afaaaaadabaaahiaaaaaffiaajaanikaaeaaaaaeaaaaaliaaiaagikaaaaaaaia
abaakeiaaeaaaaaeaaaaahiaakaanikaaaaakkiaaaaapeiaacaaaaadaaaaahia
aaaaoeiaalaanikaaeaaaaaeaaaaahiaaaaaoeiaamaappkaaaaanijbaiaaaaad
aaaaaiiaaaaaoeiaaaaaoeiaahaaaaacaaaaaiiaaaaappiaafaaaaadacaaahoa
aaaappiaaaaaoeiaafaaaaadaaaaapiaaaaaffjaafaaoekaaeaaaaaeaaaaapia
aeaaoekaaaaaaajaaaaaoeiaaeaaaaaeaaaaapiaagaaoekaaaaakkjaaaaaoeia
aeaaaaaeaaaaapiaahaaoekaaaaappjaaaaaoeiaaeaaaaaeaaaaadmaaaaappia
aaaaoekaaaaaoeiaabaaaaacaaaaammaaaaaoeiappppaaaafdeieefcjiacaaaa
eaaaabaakgaaaaaafjaaaaaeegiocaaaaaaaaaaaafaaaaaafjaaaaaeegiocaaa
abaaaaaaafaaaaaafjaaaaaeegiocaaaacaaaaaabfaaaaaafpaaaaadpcbabaaa
aaaaaaaaghaaaaaepccabaaaaaaaaaaaabaaaaaagfaaaaaddccabaaaabaaaaaa
gfaaaaaddccabaaaacaaaaaagfaaaaadhccabaaaadaaaaaagiaaaaacabaaaaaa
diaaaaaipcaabaaaaaaaaaaafgbfbaaaaaaaaaaaegiocaaaacaaaaaaabaaaaaa
dcaaaaakpcaabaaaaaaaaaaaegiocaaaacaaaaaaaaaaaaaaagbabaaaaaaaaaaa
egaobaaaaaaaaaaadcaaaaakpcaabaaaaaaaaaaaegiocaaaacaaaaaaacaaaaaa
kgbkbaaaaaaaaaaaegaobaaaaaaaaaaadcaaaaakpccabaaaaaaaaaaaegiocaaa
acaaaaaaadaaaaaapgbpbaaaaaaaaaaaegaobaaaaaaaaaaadcaaaaalpcaabaaa
aaaaaaaaigbibaaaaaaaaaaaagiacaaaaaaaaaaaadaaaaaaegiocaaaaaaaaaaa
aeaaaaaadiaaaaakdccabaaaabaaaaaaegaabaaaaaaaaaaaaceaaaaamnmmmmdo
ggggogdoaaaaaaaaaaaaaaaadgaaaaafdccabaaaacaaaaaalgapbaaaaaaaaaaa
diaaaaajhcaabaaaaaaaaaaafgifcaaaabaaaaaaaeaaaaaaigibcaaaacaaaaaa
bbaaaaaadcaaaaalhcaabaaaaaaaaaaaigibcaaaacaaaaaabaaaaaaaagiacaaa
abaaaaaaaeaaaaaaegacbaaaaaaaaaaadcaaaaalhcaabaaaaaaaaaaaigibcaaa
acaaaaaabcaaaaaakgikcaaaabaaaaaaaeaaaaaaegacbaaaaaaaaaaaaaaaaaai
hcaabaaaaaaaaaaaegacbaaaaaaaaaaaigibcaaaacaaaaaabdaaaaaadcaaaaal
hcaabaaaaaaaaaaaegacbaaaaaaaaaaapgipcaaaacaaaaaabeaaaaaaigbbbaia
ebaaaaaaaaaaaaaabaaaaaahicaabaaaaaaaaaaaegacbaaaaaaaaaaaegacbaaa
aaaaaaaaeeaaaaaficaabaaaaaaaaaaadkaabaaaaaaaaaaadiaaaaahhccabaaa
adaaaaaapgapbaaaaaaaaaaaegacbaaaaaaaaaaadoaaaaabejfdeheoeiaaaaaa
acaaaaaaaiaaaaaadiaaaaaaaaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaapapaaaa
ebaaaaaaaaaaaaaaaaaaaaaaadaaaaaaabaaaaaaahaaaaaafaepfdejfeejepeo
aaeoepfcenebemaaepfdeheoiaaaaaaaaeaaaaaaaiaaaaaagiaaaaaaaaaaaaaa
abaaaaaaadaaaaaaaaaaaaaaapaaaaaaheaaaaaaaaaaaaaaaaaaaaaaadaaaaaa
abaaaaaaadamaaaaheaaaaaaabaaaaaaaaaaaaaaadaaaaaaacaaaaaaadamaaaa
heaaaaaaacaaaaaaaaaaaaaaadaaaaaaadaaaaaaahaiaaaafdfgfpfaepfdejfe
ejepeoaafeeffiedepepfceeaaklklkl"
}

}
Program "fp" {
// Fragment combos: 1
//   opengl - ALU: 9 to 9, TEX: 3 to 3
//   d3d9 - ALU: 8 to 8, TEX: 3 to 3
//   d3d11 - ALU: 4 to 4, TEX: 3 to 3, FLOW: 1 to 1
//   d3d11_9x - ALU: 4 to 4, TEX: 3 to 3, FLOW: 1 to 1
SubProgram "opengl " {
Keywords { }
Vector 0 [_horizonColor]
SetTexture 0 [_BumpMap] 2D
SetTexture 1 [_ColorControl] 2D
"!!ARBfp1.0
OPTION ARB_precision_hint_fastest;
OPTION ARB_fog_exp2;
# 9 ALU, 3 TEX
PARAM c[2] = { program.local[0],
		{ 1 } };
TEMP R0;
TEMP R1;
TEX R1.xyz, fragment.texcoord[1], texture[0], 2D;
TEX R0.xyz, fragment.texcoord[0], texture[0], 2D;
ADD R0.xyz, R0, R1;
ADD R0.xyz, R0, -c[1].x;
DP3 R0.x, fragment.texcoord[2], R0;
MOV result.color.w, c[0];
TEX R0, R0.x, texture[1], 2D;
ADD R1.xyz, -R0, c[0];
MAD result.color.xyz, R0.w, R1, R0;
END
# 9 instructions, 2 R-regs
"
}

SubProgram "d3d9 " {
Keywords { }
Vector 0 [_horizonColor]
SetTexture 0 [_BumpMap] 2D
SetTexture 1 [_ColorControl] 2D
"ps_2_0
; 8 ALU, 3 TEX
dcl_2d s0
dcl_2d s1
def c1, -1.00000000, 0, 0, 0
dcl t0.xy
dcl t1.xy
dcl t2.xyz
texld r0, t1, s0
texld r1, t0, s0
add_pp r0.xyz, r1, r0
add_pp r0.xyz, r0, c1.x
dp3 r0.x, t2, r0
mov r0.xy, r0.x
texld r0, r0, s1
add_pp r1.xyz, -r0, c0
mad_pp r0.xyz, r0.w, r1, r0
mov_pp r0.w, c0
mov_pp oC0, r0
"
}

SubProgram "d3d11 " {
Keywords { }
ConstBuffer "$Globals" 80 // 32 used size, 5 vars
Vector 16 [_horizonColor] 4
BindCB "$Globals" 0
SetTexture 0 [_BumpMap] 2D 0
SetTexture 1 [_ColorControl] 2D 1
// 10 instructions, 2 temp regs, 0 temp arrays:
// ALU 4 float, 0 int, 0 uint
// TEX 3 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 1 static, 0 dynamic
"ps_4_0
eefiecedlcilcilmcdfmfbkkiielgeahghkoooigabaaaaaakiacaaaaadaaaaaa
cmaaaaaaleaaaaaaoiaaaaaaejfdeheoiaaaaaaaaeaaaaaaaiaaaaaagiaaaaaa
aaaaaaaaabaaaaaaadaaaaaaaaaaaaaaapaaaaaaheaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaabaaaaaaadadaaaaheaaaaaaabaaaaaaaaaaaaaaadaaaaaaacaaaaaa
adadaaaaheaaaaaaacaaaaaaaaaaaaaaadaaaaaaadaaaaaaahahaaaafdfgfpfa
epfdejfeejepeoaafeeffiedepepfceeaaklklklepfdeheocmaaaaaaabaaaaaa
aiaaaaaacaaaaaaaaaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaapaaaaaafdfgfpfe
gbhcghgfheaaklklfdeieefcliabaaaaeaaaaaaagoaaaaaafjaaaaaeegiocaaa
aaaaaaaaacaaaaaafkaaaaadaagabaaaaaaaaaaafkaaaaadaagabaaaabaaaaaa
fibiaaaeaahabaaaaaaaaaaaffffaaaafibiaaaeaahabaaaabaaaaaaffffaaaa
gcbaaaaddcbabaaaabaaaaaagcbaaaaddcbabaaaacaaaaaagcbaaaadhcbabaaa
adaaaaaagfaaaaadpccabaaaaaaaaaaagiaaaaacacaaaaaaefaaaaajpcaabaaa
aaaaaaaaegbabaaaabaaaaaaeghobaaaaaaaaaaaaagabaaaaaaaaaaaefaaaaaj
pcaabaaaabaaaaaaegbabaaaacaaaaaaeghobaaaaaaaaaaaaagabaaaaaaaaaaa
aaaaaaahhcaabaaaaaaaaaaaegacbaaaaaaaaaaaegacbaaaabaaaaaaaaaaaaak
hcaabaaaaaaaaaaaegacbaaaaaaaaaaaaceaaaaaaaaaialpaaaaialpaaaaialp
aaaaaaaabaaaaaahbcaabaaaaaaaaaaaegbcbaaaadaaaaaaegacbaaaaaaaaaaa
efaaaaajpcaabaaaaaaaaaaaagaabaaaaaaaaaaaeghobaaaabaaaaaaaagabaaa
abaaaaaaaaaaaaajhcaabaaaabaaaaaaegacbaiaebaaaaaaaaaaaaaaegiccaaa
aaaaaaaaabaaaaaadcaaaaajhccabaaaaaaaaaaapgapbaaaaaaaaaaaegacbaaa
abaaaaaaegacbaaaaaaaaaaadgaaaaagiccabaaaaaaaaaaadkiacaaaaaaaaaaa
abaaaaaadoaaaaab"
}

SubProgram "gles " {
Keywords { }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { }
"!!GLES"
}

SubProgram "flash " {
Keywords { }
Vector 0 [_horizonColor]
SetTexture 0 [_BumpMap] 2D
SetTexture 1 [_ColorControl] 2D
"agal_ps
c1 -1.0 0.0 0.0 0.0
[bc]
ciaaaaaaaaaaapacabaaaaoeaeaaaaaaaaaaaaaaafaababb tex r0, v1, s0 <2d wrap linear point>
ciaaaaaaabaaapacaaaaaaoeaeaaaaaaaaaaaaaaafaababb tex r1, v0, s0 <2d wrap linear point>
abaaaaaaaaaaahacabaaaakeacaaaaaaaaaaaakeacaaaaaa add r0.xyz, r1.xyzz, r0.xyzz
abaaaaaaaaaaahacaaaaaakeacaaaaaaabaaaaaaabaaaaaa add r0.xyz, r0.xyzz, c1.x
bcaaaaaaaaaaabacacaaaaoeaeaaaaaaaaaaaakeacaaaaaa dp3 r0.x, v2, r0.xyzz
aaaaaaaaaaaaadacaaaaaaaaacaaaaaaaaaaaaaaaaaaaaaa mov r0.xy, r0.x
ciaaaaaaaaaaapacaaaaaafeacaaaaaaabaaaaaaafaababb tex r0, r0.xyyy, s1 <2d wrap linear point>
bfaaaaaaabaaahacaaaaaakeacaaaaaaaaaaaaaaaaaaaaaa neg r1.xyz, r0.xyzz
abaaaaaaabaaahacabaaaakeacaaaaaaaaaaaaoeabaaaaaa add r1.xyz, r1.xyzz, c0
adaaaaaaabaaahacaaaaaappacaaaaaaabaaaakeacaaaaaa mul r1.xyz, r0.w, r1.xyzz
abaaaaaaaaaaahacabaaaakeacaaaaaaaaaaaakeacaaaaaa add r0.xyz, r1.xyzz, r0.xyzz
aaaaaaaaaaaaaiacaaaaaaoeabaaaaaaaaaaaaaaaaaaaaaa mov r0.w, c0
aaaaaaaaaaaaapadaaaaaaoeacaaaaaaaaaaaaaaaaaaaaaa mov o0, r0
"
}

SubProgram "d3d11_9x " {
Keywords { }
ConstBuffer "$Globals" 80 // 32 used size, 5 vars
Vector 16 [_horizonColor] 4
BindCB "$Globals" 0
SetTexture 0 [_BumpMap] 2D 0
SetTexture 1 [_ColorControl] 2D 1
// 10 instructions, 2 temp regs, 0 temp arrays:
// ALU 4 float, 0 int, 0 uint
// TEX 3 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 1 static, 0 dynamic
"ps_4_0_level_9_3
eefiecedidkfapncgfaobhhgfafljpkmnkminblcabaaaaaaneadaaaaaeaaaaaa
daaaaaaafiabaaaabiadaaaakaadaaaaebgpgodjcaabaaaacaabaaaaaaacpppp
oiaaaaaadiaaaaaaabaacmaaaaaadiaaaaaadiaaacaaceaaaaaadiaaaaaaaaaa
abababaaaaaaabaaabaaaaaaaaaaaaaaabacppppfbaaaaafabaaapkaaaaaialp
aaaaaaaaaaaaaaaaaaaaaaaabpaaaaacaaaaaaiaaaaaadlabpaaaaacaaaaaaia
abaaadlabpaaaaacaaaaaaiaacaaahlabpaaaaacaaaaaajaaaaiapkabpaaaaac
aaaaaajaabaiapkaecaaaaadaaaacpiaabaaoelaaaaioekaecaaaaadabaacpia
aaaaoelaaaaioekaacaaaaadaaaachiaaaaaoeiaabaaoeiaacaaaaadaaaachia
aaaaoeiaabaaaakaaiaaaaadaaaacdiaacaaoelaaaaaoeiaecaaaaadaaaacpia
aaaaoeiaabaioekabcaaaaaeabaachiaaaaappiaaaaaoekaaaaaoeiaabaaaaac
abaaciiaaaaappkaabaaaaacaaaicpiaabaaoeiappppaaaafdeieefcliabaaaa
eaaaaaaagoaaaaaafjaaaaaeegiocaaaaaaaaaaaacaaaaaafkaaaaadaagabaaa
aaaaaaaafkaaaaadaagabaaaabaaaaaafibiaaaeaahabaaaaaaaaaaaffffaaaa
fibiaaaeaahabaaaabaaaaaaffffaaaagcbaaaaddcbabaaaabaaaaaagcbaaaad
dcbabaaaacaaaaaagcbaaaadhcbabaaaadaaaaaagfaaaaadpccabaaaaaaaaaaa
giaaaaacacaaaaaaefaaaaajpcaabaaaaaaaaaaaegbabaaaabaaaaaaeghobaaa
aaaaaaaaaagabaaaaaaaaaaaefaaaaajpcaabaaaabaaaaaaegbabaaaacaaaaaa
eghobaaaaaaaaaaaaagabaaaaaaaaaaaaaaaaaahhcaabaaaaaaaaaaaegacbaaa
aaaaaaaaegacbaaaabaaaaaaaaaaaaakhcaabaaaaaaaaaaaegacbaaaaaaaaaaa
aceaaaaaaaaaialpaaaaialpaaaaialpaaaaaaaabaaaaaahbcaabaaaaaaaaaaa
egbcbaaaadaaaaaaegacbaaaaaaaaaaaefaaaaajpcaabaaaaaaaaaaaagaabaaa
aaaaaaaaeghobaaaabaaaaaaaagabaaaabaaaaaaaaaaaaajhcaabaaaabaaaaaa
egacbaiaebaaaaaaaaaaaaaaegiccaaaaaaaaaaaabaaaaaadcaaaaajhccabaaa
aaaaaaaapgapbaaaaaaaaaaaegacbaaaabaaaaaaegacbaaaaaaaaaaadgaaaaag
iccabaaaaaaaaaaadkiacaaaaaaaaaaaabaaaaaadoaaaaabejfdeheoiaaaaaaa
aeaaaaaaaiaaaaaagiaaaaaaaaaaaaaaabaaaaaaadaaaaaaaaaaaaaaapaaaaaa
heaaaaaaaaaaaaaaaaaaaaaaadaaaaaaabaaaaaaadadaaaaheaaaaaaabaaaaaa
aaaaaaaaadaaaaaaacaaaaaaadadaaaaheaaaaaaacaaaaaaaaaaaaaaadaaaaaa
adaaaaaaahahaaaafdfgfpfaepfdejfeejepeoaafeeffiedepepfceeaaklklkl
epfdeheocmaaaaaaabaaaaaaaiaaaaaacaaaaaaaaaaaaaaaaaaaaaaaadaaaaaa
aaaaaaaaapaaaaaafdfgfpfegbhcghgfheaaklkl"
}

}

#LINE 89

	}
}

// -----------------------------------------------------------
// Radeon 9000

#warning Upgrade NOTE: SubShader commented out because of manual shader assembly
/*Subshader {
	Tags { "RenderType"="Opaque" }
	Pass {
CGPROGRAM
// Upgrade NOTE: excluded shader from OpenGL ES 2.0 because it does not contain a surface program or both vertex and fragment programs.
#pragma exclude_renderers gles
#pragma vertex vert
// just define 'vert' as a vertex shader, the code is included
// from the section on top
ENDCG

		Program "" {
			SubProgram {
				Local 0, [_horizonColor]

"!!ATIfs1.0
StartConstants;
	CONSTANT c0 = program.local[0];
EndConstants;

StartPrelimPass;
	SampleMap r0, t0.str;
	SampleMap r1, t1.str;
	PassTexCoord r2, t2.str;
	
	ADD r1, r0.bias, r1.bias;	# bump = bump1 + bump2 - 1
	DOT3 r2, r1, r2;			# fresnel: dot (bump, viewer-pos)
EndPass;

StartOutputPass;
 	SampleMap r2, r2.str;

	LERP r0.rgb, r2.a, c0, r2;	# fade in reflection
	MOV r0.a, c0.a;
EndPass;
" 
}
}
		SetTexture [_BumpMap] {}
		SetTexture [_BumpMap] {}
		SetTexture [_ColorControl] {}
	}
}*/

// -----------------------------------------------------------
//  Old cards

// three texture, cubemaps
Subshader {
	Tags { "RenderType"="Opaque" }
	Pass {
		Color (0.5,0.5,0.5,0.5)
		SetTexture [_MainTex] {
			Matrix [_WaveMatrix]
			combine texture * primary
		}
		SetTexture [_MainTex] {
			Matrix [_WaveMatrix2]
			combine texture * primary + previous
		}
		SetTexture [_ColorControlCube] {
			combine texture +- previous, primary
			Matrix [_Reflection]
		}
	}
}

// dual texture, cubemaps
Subshader {
	Tags { "RenderType"="Opaque" }
	Pass {
		Color (0.5,0.5,0.5,0.5)
		SetTexture [_MainTex] {
			Matrix [_WaveMatrix]
			combine texture
		}
		SetTexture [_ColorControlCube] {
			combine texture +- previous, primary
			Matrix [_Reflection]
		}
	}
}

// single texture
Subshader {
	Tags { "RenderType"="Opaque" }
	Pass {
		Color (0.5,0.5,0.5,0)
		SetTexture [_MainTex] {
			Matrix [_WaveMatrix]
			combine texture, primary
		}
	}
}

}
