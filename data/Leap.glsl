#version 330

#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform float fingers_x[5];
uniform float fingers_y[5];
uniform sampler2D texture;
uniform sampler2D feedback;

uniform float hand;

uniform vec2 resolution;
uniform float time;

varying vec4 vertColor;
varying vec3 vertNormal;
varying vec3 vertLightDir;


void main() {
  
  vec2 uv = gl_FragCoord.xy/resolution;
  vec2 coord = gl_FragCoord.xy/resolution;
  vec2 st = gl_FragCoord.xy/resolution;
  
  //Flip the y texture coordinate;
  
  coord.y = 1.0 - coord.y;
  
  //Standard scaling processing
  
  float scl = resolution.x/resolution.y;
  uv.x *= scl;
  vec2 pos = uv - vec2(0.5 * scl, 0.5);
  
   
   float d = 1.0;
   float color = 0.0;
   vec2 mean = vec2(0.0);
   
   for (int i = 0; i < 5; i++){
   vec2 p = vec2(fingers_x[i], fingers_y[i])/resolution;
   p.x *= scl;
   p = p - vec2(0.5 * scl, 0.5);
   float a = length(p - pos);
   d = min(d, a * 0.1);
   color += d;
   mean += p;
   }
   mean = mean/5.0;
   mean += vec2(0.5);
   
   

  float theta = color * 5.0;
  vec2 disp = vec2(cos(theta * 3.14), sin(theta * 3.14)) * 0.02 * hand * theta ;
  
  
  coord += disp + vec2(cos(texture2D(texture, st).x * 3.14), sin(texture2D(texture, st).y) * 3.14) * hand * 0.09;  

  vec4 text = texture2D(texture, fract(coord));
   
   st -= vec2(0.5);
   st *= 0.4;
   st += vec2(0.5);
  
  gl_FragColor =  text * (1 - hand * 0.3) + 0.35 * texture2D(feedback, st)  * hand;
}