#!/bin/sh
# 시연 영상 2개 합성: 왼쪽 폰 화면 + 오른쪽 장면별 자막, 앞뒤 타이틀 카드
set -e
FF="/c/Users/USER/AppData/Local/Microsoft/WinGet/Packages/Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe/ffmpeg-9.0.2-full_build/bin/ffmpeg.exe"
cd "$(dirname "$0")"
F=frames
SRC=..
OUT=../submission
mkdir -p "$OUT"

# 공통: 상태바(위 88px)·내비게이션 바(아래 136px) 잘라내고 폰 화면 크기로
PHONE="fps=30,crop=1080:2176:0:88,scale=476:960,setsar=1"
CARD="fps=30,format=yuv420p,setsar=1"

# ── 영상 1: 재학증명서 (65.mp4) ──
# 장면 경계(원본 초): 1.5 | 4.77 | 9.22 | 15.49 | 18.38 | 21.16 | 23.46 | 25.73 (+마지막 1초 정지)
"$FF" -y -v error \
  -i "$SRC/65.mp4" \
  -loop 1 -t 2.5 -i $F/v1_intro.png \
  -loop 1 -t 3.27 -i $F/v1_s0.png \
  -loop 1 -t 4.45 -i $F/v1_s1.png \
  -loop 1 -t 6.27 -i $F/v1_s2.png \
  -loop 1 -t 2.89 -i $F/v1_s3.png \
  -loop 1 -t 2.78 -i $F/v1_s4.png \
  -loop 1 -t 2.30 -i $F/v1_s5.png \
  -loop 1 -t 3.27 -i $F/v1_s6.png \
  -loop 1 -t 3 -i $F/v1_outro.png \
  -f lavfi -t 31 -i anullsrc=r=48000:cl=stereo \
  -filter_complex "\
[0:v]trim=start=1.5:end=25.73,setpts=PTS-STARTPTS,$PHONE,tpad=stop_mode=clone:stop_duration=1[ph];\
[2:v]$CARD[b0];[3:v]$CARD[b1];[4:v]$CARD[b2];[5:v]$CARD[b3];[6:v]$CARD[b4];[7:v]$CARD[b5];[8:v]$CARD[b6];\
[b0][b1][b2][b3][b4][b5][b6]concat=n=7:v=1:a=0[bg];\
[bg][ph]overlay=346:56:shortest=1,fade=t=in:st=0:d=0.3[body];\
[1:v]$CARD,fade=t=in:st=0:d=0.4,fade=t=out:st=2.1:d=0.4[in];\
[9:v]$CARD,fade=t=in:st=0:d=0.4,fade=t=out:st=2.6:d=0.4[out];\
[in][body][out]concat=n=3:v=1:a=0,format=yuv420p[v]" \
  -map "[v]" -map 10:a -shortest -c:v libx264 -preset slow -crf 20 -r 30 -c:a aac -b:a 64k -movflags +faststart \
  "$OUT/Cain_시연영상1_재학증명서.mp4"

# ── 영상 2: AI 상담 (67.mp4) ──
# 구간(원본 초 → 배속): 0-1.4 x1 | 1.4-4.3 x2 | 4.3-9.3 x2 | 9.3-12.8 x1 | 12.8-32.4 x4 | 32.4-38.11 x1 (+2초 정지)
"$FF" -y -v error \
  -i "$SRC/67.mp4" \
  -loop 1 -t 2.5 -i $F/v2_intro.png \
  -loop 1 -t 2.85 -i $F/v2_s0.png \
  -loop 1 -t 2.5 -i $F/v2_s1.png \
  -loop 1 -t 3.5 -i $F/v2_s2.png \
  -loop 1 -t 4.9 -i $F/v2_s3.png \
  -loop 1 -t 7.71 -i $F/v2_s4.png \
  -loop 1 -t 3.5 -i $F/v2_outro.png \
  -f lavfi -t 29 -i anullsrc=r=48000:cl=stereo \
  -filter_complex "\
[0:v]$PHONE,split=6[a][b][c][d][e][f];\
[a]trim=0:1.4,setpts=PTS-STARTPTS[p1];\
[b]trim=1.4:4.3,setpts=(PTS-STARTPTS)/2[p2];\
[c]trim=4.3:9.3,setpts=(PTS-STARTPTS)/2[p3];\
[d]trim=9.3:12.8,setpts=PTS-STARTPTS[p4];\
[e]trim=12.8:32.4,setpts=(PTS-STARTPTS)/4[p5];\
[f]trim=32.4:38.11,setpts=PTS-STARTPTS,tpad=stop_mode=clone:stop_duration=2[p6];\
[p1][p2][p3][p4][p5][p6]concat=n=6:v=1:a=0,fps=30[ph];\
[2:v]$CARD[b0];[3:v]$CARD[b1];[4:v]$CARD[b2];[5:v]$CARD[b3];[6:v]$CARD[b4];\
[b0][b1][b2][b3][b4]concat=n=5:v=1:a=0[bg];\
[bg][ph]overlay=346:56:shortest=1,fade=t=in:st=0:d=0.3[body];\
[1:v]$CARD,fade=t=in:st=0:d=0.4,fade=t=out:st=2.1:d=0.4[in];\
[7:v]$CARD,fade=t=in:st=0:d=0.4,fade=t=out:st=3.1:d=0.4[out];\
[in][body][out]concat=n=3:v=1:a=0,format=yuv420p[v]" \
  -map "[v]" -map 8:a -shortest -c:v libx264 -preset slow -crf 20 -r 30 -c:a aac -b:a 64k -movflags +faststart \
  "$OUT/Cain_시연영상2_AI상담.mp4"

ls -la "$OUT"
