FRAG

DCL IN[0], COLOR, LINEAR
DCL OUT[0], COLOR

DCL TEMP[0]

IMM FLT32 { 1.0, 0.0, 0.0, 0.0 }
IMM FLT32 { 1.5, 0.0, 0.0, 0.0 }

ADD TEMP[0], IN[0], IMM[0]
RCP TEMP[0].x, TEMP[0].xxxx
SUB OUT[0], TEMP[0], IMM[1]

END
