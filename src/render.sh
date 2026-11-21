#!/bin/bash
# Render klip gta6-clipper-01 dari VOD Twitch Kai Cenat 2932305259
# Sumber: win-gas-clean.mp4 di ../gta6-clipper-01-src/ (di luar repo: file sumber 143 MB,
# melebihi batas snapshot 100 MiB) = VOD 62602-62752 (1080p60, segmen HLS langsung dari usher)
#   gameplay: file 4-42s  = VOD ~62606-62644 (toko pom bensin, tembak, 6 bintang, kabur pakai SUV sheriff)
#   pitch:    file 105-115s = VOD ~62707-62717 (pelarian, digelapkan + teks pitch)
# Output: vertikal 9:16 1080x1920, blur-fill, 48 detik
set -e
cd "$(dirname "$0")"
SRC="../gta6-clipper-01-src/win-gas-clean.mp4"
FONT=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf
ffmpeg -y -v error -i "$SRC" -filter_complex "
[0:v]trim=start=4:end=42,setpts=PTS-STARTPTS[v1];
[0:v]trim=start=105:end=115,setpts=PTS-STARTPTS,eq=brightness=-0.45[v2];
[0:a]atrim=start=4:end=42,asetpts=PTS-STARTPTS[a1];
[0:a]atrim=start=105:end=115,asetpts=PTS-STARTPTS[a2];
[a1][a2]concat=n=2:v=0:a=1[aout];
[v1][v2]concat=n=2:v=1:a=0[game];
[game]split=2[bg][fg];
[bg]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,gblur=sigma=40[bg2];
[fg]scale=1080:607[fg2];
[bg2][fg2]overlay=(W-w)/2:(H-h)/2[base];
[base]drawbox=x=0:y=140:w=1080:h=120:color=black@0.55:t=fill:enable='between(t,0,3)'[b1];
[b1]drawtext=fontfile=$FONT:text='6 STARS IN GTA 6':fontsize=76:fontcolor=\#FFD400:borderw=3:bordercolor=black:x=(w-text_w)/2:y=160:enable='between(t,0,3)'[b2];
[b2]drawtext=fontfile=$FONT:text='Make clips like this with AI':fontsize=58:fontcolor=white:borderw=2:bordercolor=black:x=(w-text_w)/2:y=830:enable='between(t,38,48)'[b3];
[b3]drawtext=fontfile=$FONT:text='and earn money on make.fun':fontsize=58:fontcolor=white:borderw=2:bordercolor=black:x=(w-text_w)/2:y=905:enable='between(t,38,48)'[b4];
[b4]drawtext=fontfile=$FONT:text='make.fun/bounty/gta6-clipper-01':fontsize=44:fontcolor=\#FFD400:borderw=2:bordercolor=black:x=(w-text_w)/2:y=985:enable='between(t,38,48)'[out]
" -map "[out]" -map "[aout]" -c:v libx264 -preset medium -crf 21 -pix_fmt yuv420p -c:a aac -b:a 128k -movflags +faststart ../clip/gta6-clip.mp4
echo "RENDER DONE"
ffprobe -v error -show_entries format=duration,size -show_entries stream=codec_type,width,height,r_frame_rate -of default=noprint_wrappers=1 ../clip/gta6-clip.mp4
