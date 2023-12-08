// Parameters
// @worldPos
// @viewDir
// @pivot
// @forkWidth
// @forkCount
// @frequency
// @amplitude
// @capHeight
// @time
// @latency
// @fallingAngle
// @stemLength
// @beanSize
// @stemWidth
// @forkLength
// @thinner
// @seedColor


const float PI = 3.1415926;
const float FAR = 1000000;
struct Shapes
{
    float far_away;
    
    float width_profile(float x, float falling_range,float start, float thinner_speed)
    {
        return start - start * thinner_speed * (x / falling_range);
    }


    float seed_dot(float3 p, float3 center)
    {
        return length(p - center);
    }

    float3 stem(float3 p,
                float3 fix_tip,
                float stem_length,
                float wave_frequency, 
                float wave_amplitude,
                float wave_offset)
    {
        float x = fix_tip.x;
        float y_0 = 0.37 * wave_amplitude * sin(wave_frequency * (fix_tip.z) + wave_offset);
        float y = 0.37 * wave_amplitude * sin(wave_frequency * (p.z) + wave_offset);
        float the_z = p.z;
        if(p.z > fix_tip.z || p.z < fix_tip.z - stem_length)
        {
            the_z = far_away; 
        }
        return float3(x, y - y_0, the_z);
    }

    float wave_fun(float x, 
                   float cap_height, 
                   float wave_offset, 
                   float wave_frequency, 
                   float wave_amplitude,
                   float falling_angle)
    {
        //float y_offset = wave_amplitude * sin(-wave_offset);
        float y = wave_amplitude * sin(wave_frequency * x - wave_offset);
        return y - x * atan(radians(falling_angle)) + cap_height;
    }

    float3 treeSeed(float3 p,
                  float angle_offset_x,
                  float cap_height, 
                  float wave_offset, 
                  float wave_frequency, 
                  float wave_amplitude,
                  float wave_falling_angle,
                  float stem_length,
                  float fork_length
                  )
    {
        float r = length(p.xy);
        float z = wave_fun(r,
                           cap_height, 
                           wave_offset, 
                           wave_frequency, 
                           wave_amplitude,
                           wave_falling_angle);

        float z_0 = wave_fun(0,
                    cap_height, 
                    wave_offset, 
                    wave_frequency, 
                    wave_amplitude,
                    wave_falling_angle);
        
        float wave_x = far_away;
        float wave_y = far_away;
        if(r < fork_length)
        {
            wave_x = r * cos(angle_offset_x);
            wave_y = r * sin(angle_offset_x);               
        }

        // Cap shape
        float3 capProfile = float3(wave_x, wave_y, z);
        // Stem shape
        float3 stemProfile = stem(p,
                                  float3(0, 0, z_0),
                                  stem_length,
                                  wave_frequency,
                                  wave_amplitude,
                                  wave_offset);

        float3 stemProfile_bean = stem(float3(p.xy, z_0 - stem_length),
                            float3(0, 0, z_0),
                            stem_length,
                            wave_frequency,
                            wave_amplitude,
                            wave_offset);
        return float3(
                      length(p - capProfile),
                      length(p - stemProfile),
                      seed_dot(p, float3(stemProfile_bean.xy, z_0 - stem_length))
                      );
    }

    float4 composite()
    {
        return float4(0, 0, 0, 0);
    }

};

Shapes sdf;
sdf.far_away = FAR;

float3 rayOrigin = 0;
float3 rayStep = 0;
float angle_xy = 0;
float out_offset = time / latency;
for (int j = 0; j < forkCount; j++)
{
    rayOrigin = 1 - (viewDir - worldPos);
    rayStep = viewDir * -1;
    angle_xy = j * (2 * PI / forkCount);
    
    for (int i = 0; i < 64; i++)
    {
        
        float3 dist = sdf.treeSeed(rayOrigin,
                                angle_xy,
                                capHeight,
                                out_offset,
                                frequency,
                                amplitude,
                                fallingAngle,
                                stemLength,
                                forkLength
                                );
        if (dist.x < forkWidth 
            || dist.y <  sdf.width_profile(rayOrigin.z - capHeight, stemLength, stemWidth, thinner) 
            || dist.z < beanSize)
        {
            return seedColor;
        }
        opacityMask = 1;
        rayOrigin += rayStep;
    }
}

opacityMask = 0;

return float3(0, 0, 0);
