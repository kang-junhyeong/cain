#!/bin/sh
# 시연 영상 1편 합성: 시나리오 1(재학증명서) → 시나리오 2(AI 상담)
# 왼쪽 폰 화면(모서리 둥글게) + 오른쪽 장면별 자막, 시나리오별 시작 카드, 마지막 타이틀 1회
# 먼저 node gen_frames.js 로 frames/ 를 만든 뒤 실행
set -e
FF="/c/Users/USER/AppData/Local/Microsoft/WinGet/Packages/Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe/ffmpeg-9.0.2-full_build/bin/ffmpeg.exe"
cd "$(dirname "$0")"
F=frames
SRC=..
OUT=../submission
mkdir -p "$OUT"

# 상태바(위 88px)·내비게이션 바(아래 136px) 잘라내고 폰 화면 크기(476x960)로
PHONE="fps=30,crop=1080:2176:0:88,scale=476:960,setsar=1"
CARD="fps=30,format=yuv420p,setsar=1"

# 시나리오 1 (65.mp4) 장면 경계(원본 초): 1.5 | 4.77 | 9.22 | 15.49 | 18.38 | 21.16 | 23.46 | 25.73 (+1초 정지)
# 시나리오 2 (67.mp4) 구간(원본 초 → 배속): 0-1.4 x1 | 1.4-4.3 x2 | 4.3-9.3 x2 | 9.3-12.8 x1 | 12.8-32.4 x4 | 32.4-38.11 x1 (+2초 정지)
"$FF" -y -v error \
  -i "$SRC/65.mp4" \
  -i "$SRC/67.mp4" \
  -loop 1 -i corners.png \
  -loop 1 -t 2.5  -i $F/v1_intro.png \
  -loop 1 -t 3.27 -i $F/v1_s0.png \
  -loop 1 -t 4.45 -i $F/v1_s1.png \
  -loop 1 -t 6.27 -i $F/v1_s2.png \
  -loop 1 -t 2.89 -i $F/v1_s3.png \
  -loop 1 -t 2.78 -i $F/v1_s4.png \
  -loop 1 -t 2.30 -i $F/v1_s5.png \
  -loop 1 -t 3.27 -i $F/v1_s6.png \
  -loop 1 -t 2.5  -i $F/v2_intro.png \
  -loop 1 -t 2.85 -i $F/v2_s0.png \
  -loop 1 -t 2.5  -i $F/v2_s1.png \
  -loop 1 -t 3.5  -i $F/v2_s2.png \
  -loop 1 -t 4.9  -i $F/v2_s3.png \
  -loop 1 -t 7.71 -i $F/v2_s4.png \
  -loop 1 -t 3.5  -i $F/v2_outro.png \
  -f lavfi -t 60 -i anullsrc=r=48000:cl=stereo \
  -filter_complex "\
[2:v]format=rgba,split=2[c1][c2];\
[0:v]trim=start=1.5:end=25.73,setpts=PTS-STARTPTS,$PHONE,tpad=stop_mode=clone:stop_duration=1[ph1];\
[4:v]$CARD[a0];[5:v]$CARD[a1];[6:v]$CARD[a2];[7:v]$CARD[a3];[8:v]$CARD[a4];[9:v]$CARD[a5];[10:v]$CARD[a6];\
[a0][a1][a2][a3][a4][a5][a6]concat=n=7:v=1:a=0[bg1];\
[bg1][ph1]overlay=346:56:shortest=1[x1];[x1][c1]overlay=346:56:shortest=1,fade=t=in:st=0:d=0.3[body1];\
[1:v]$PHONE,split=6[a][b][c][d][e][f];\
[a]trim=0:1.4,setpts=PTS-STARTPTS[p1];\
[b]trim=1.4:4.3,setpts=(PTS-STARTPTS)/2[p2];\
[c]trim=4.3:9.3,setpts=(PTS-STARTPTS)/2[p3];\
[d]trim=9.3:12.8,setpts=PTS-STARTPTS[p4];\
[e]trim=12.8:32.4,setpts=(PTS-STARTPTS)/4[p5];\
[f]trim=32.4:38.11,setpts=PTS-STARTPTS,tpad=stop_mode=clone:stop_duration=2[p6];\
[p1][p2][p3][p4][p5][p6]concat=n=6:v=1:a=0,fps=30[ph2];\
[12:v]$CARD[b0];[13:v]$CARD[b1];[14:v]$CARD[b2];[15:v]$CARD[b3];[16:v]$CARD[b4];\
[b0][b1][b2][b3][b4]concat=n=5:v=1:a=0[bg2];\
[bg2][ph2]overlay=346:56:shortest=1[x2];[x2][c2]overlay=346:56:shortest=1,fade=t=in:st=0:d=0.3[body2];\
[3:v]$CARD,fade=t=in:st=0:d=0.4,fade=t=out:st=2.1:d=0.4[in1];\
[11:v]$CARD,fade=t=in:st=0:d=0.4,fade=t=out:st=2.1:d=0.4[in2];\
[17:v]$CARD,fade=t=in:st=0:d=0.4,fade=t=out:st=3.1:d=0.4[out];\
[in1][body1][in2][body2][out]concat=n=5:v=1:a=0,format=yuv420p[v]" \
  -map "[v]" -map 18:a -shortest -c:v libx264 -preset slow -crf 20 -r 30 -c:a aac -b:a 64k -movflags +faststart \
  "$OUT/Cain_시연영상.mp4"

ls -la "$OUT"
