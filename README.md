# HLSL_Avatar_Seeds
To use this Avatar Pandora like asset, just copy the folder AvatarSeed into a content directory of your unreal engine 5.3 project.

The level is just the Electronic Dreams project of Epic Games PCG tech demo.

Ensure your project setting with substrate material enabled, because I adjusted the color and emissive amount in the new mechanism.
Of course, you can go with it disabled, just recalibrate the emission value as you like, the HLSL code does not depend on it.

<img width="773" alt="enable_subtrate" src="https://github.com/baiyanghor/HLSL_Avatar_Seeds/assets/22685081/1c2abc7d-12d4-43e1-9473-93181ecc3638">


The core HLSL code is copied out as in file avatar_seed_hlsl_v001.02.hlsl, you can copy it into your custom node in the material editor, then connect your input refers to network like unreal_content\AvatarSeed\Materials\M_AvatarSeed.uasset
