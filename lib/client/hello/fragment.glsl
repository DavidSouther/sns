// same name and type as VS
varying vec3 vNormal;

void main() {

  // calc the dot product and clamp
  // 0 -> 1 rather than -1 -> 1
  vec3 light = normalize(vec3(0.5, 0.2, 1.0));

  vec3 light2 = 0.2 *  - light;

  // calculate the dot product of
  // the light to the vertex normal
  float dProd = 0.0;
  dProd += max(0.0, dot(vNormal, light));
  dProd += max(0.0, dot(vNormal, light2));

  // feed into our frag colour
  gl_FragColor = vec4(dProd, // R
                      dProd, // G
                      dProd, // B
                      1.0);  // A
}
