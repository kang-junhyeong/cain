// 영상용 배경·자막 프레임(1920x1080 PNG)을 HTML로 만들고 Edge로 캡처한다.
// 실행: node gen_frames.js
const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');

const EDGE = fs.existsSync('C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe')
  ? 'C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe'
  : 'C:/Program Files/Microsoft/Edge/Application/msedge.exe';
const OUT = path.join(__dirname, 'frames');
fs.mkdirSync(OUT, { recursive: true });

const css = `
* { margin:0; padding:0; box-sizing:border-box; }
html,body { width:1920px; height:1080px; overflow:hidden; }
body { font-family:'Noto Sans KR','Malgun Gothic',sans-serif; color:#fff; word-break:keep-all;
  background: radial-gradient(circle at 80% 20%, #1E88E5 0%, #1565C0 40%, #0D47A1 100%); }
.bezel { position:absolute; left:330px; top:40px; width:508px; height:992px; border-radius:58px; background:#0B1220;
  box-shadow: 0 30px 80px rgba(0,0,0,.35); }
.screen { position:absolute; left:346px; top:56px; width:476px; height:960px; background:#000; }
.brand { position:absolute; left:960px; top:84px; font-size:44px; font-weight:900; letter-spacing:-1px; }
.brand small { font-size:22px; font-weight:500; opacity:.75; margin-left:16px; letter-spacing:0; }
.text { position:absolute; left:960px; top:330px; width:860px; }
.label { display:inline-block; font-size:28px; font-weight:800; color:#0D47A1; background:#FFB74D; padding:8px 26px; border-radius:40px; }
.title { font-size:72px; font-weight:800; line-height:1.25; margin-top:30px; letter-spacing:-1.5px; }
.sub { font-size:34px; font-weight:400; line-height:1.5; margin-top:26px; opacity:.88; }
.dots { position:absolute; left:960px; bottom:96px; display:flex; gap:14px; }
.dots i { width:14px; height:14px; border-radius:50%; background:rgba(255,255,255,.3); }
.dots i.on { background:#FFB74D; width:44px; border-radius:8px; }
/* 카드 */
.card { position:absolute; inset:0; display:flex; flex-direction:column; justify-content:center; padding-left:180px; }
.card .eyebrow { font-size:34px; font-weight:800; color:#FFB74D; }
.card .big { font-size:96px; font-weight:900; line-height:1.2; margin-top:20px; letter-spacing:-2px; }
.card .csub { font-size:40px; font-weight:400; margin-top:30px; opacity:.9; }
.card .logo { font-size:160px; font-weight:900; letter-spacing:-4px; line-height:1; }
.card .note { position:absolute; left:180px; bottom:80px; font-size:24px; opacity:.7; }
`;

function sceneHtml(s, idx, total, scenario) {
  const dots = Array.from({ length: total }, (_, i) => `<i class="${i === idx ? 'on' : ''}"></i>`).join('');
  return `<div class="bezel"></div><div class="screen"></div>
<div class="brand">Cain<small>${scenario}</small></div>
<div class="text"><span class="label">${s.label}</span><div class="title">${s.title}</div><div class="sub">${s.sub}</div></div>
<div class="dots">${dots}</div>`;
}

const videos = {
  v1: {
    scenario: '시나리오 1 · 재학증명서 발급',
    intro: `<div class="card"><div class="eyebrow">SCENARIO 1</div><div class="big">재학증명서,<br>혼자서 발급하기</div><div class="csub">출발부터 수령까지 Cain이 한 단계씩 안내합니다</div></div>`,
    scenes: [
      { label: '서비스 선택', title: '필요한 서비스를 고르면', sub: '장소 · 운영시간 · 준비물을 한 화면에서 확인' },
      { label: '방문 전 준비', title: '출발 전에 미리 챙기고', sub: '준비물 체크리스트와 전체 절차 미리 보기' },
      { label: '1단계', title: '학생회관까지<br>도보 경로로', sub: '현재 위치에서 경로와 소요 시간을 지도에 표시' },
      { label: '2단계', title: '건물 안에서는<br>층별 배치도로', sub: '2층 배치도 위 현위치 → 무인발급기 경로' },
      { label: '3단계', title: '발급기 화면 그대로<br>따라 하기', sub: '무엇을 눌러야 하는지 실제 화면으로 안내' },
      { label: '4단계', title: '출력구에서<br>수령까지', sub: '내용과 직인 확인까지 놓치지 않게' },
      { label: '완료', title: '길을 묻지 않고<br>끝까지', sub: '처음 온 학생도 혼자서 발급 완료' },
    ],
    outroNote: '',
  },
  v2: {
    scenario: '시나리오 2 · AI 상담',
    intro: `<div class="card"><div class="eyebrow">SCENARIO 2</div><div class="big">학생증을<br>잃어버렸을 때</div><div class="csub">학교를 아는 AI 도우미에게 물어보세요</div></div>`,
    scenes: [
      { label: 'AI 도우미', title: '궁금하면<br>바로 물어보세요', sub: '교내 생활 · 시설 · 서비스 무엇이든' },
      { label: '질문', title: '상황을<br>그대로 말하면', sub: '"학생증 잃어버렸어"' },
      { label: '되묻기', title: '답이 달라지는 지점은<br>먼저 확인하고', sub: '결제 기능 여부에 따라 절차가 달라지기 때문' },
      { label: '이어서 질문', title: '대화를<br>이어서 묻고', sub: '어디서, 무엇을 챙겨서?' },
      { label: '맞춤 안내', title: '필요한 정보만<br>한눈에', sub: '위치 · 준비물 · 비용 · 기간 + 공식 안내 출처' },
    ],
    outroNote: '※ 시연 버전 — AI 상담은 정해진 대화 시나리오로 동작하며, 부서·연락처·비용은 예시 정보입니다.',
  },
};

function render(name, body) {
  const htmlPath = path.join(OUT, `${name}.html`);
  fs.writeFileSync(htmlPath, `<!doctype html><html lang="ko"><head><meta charset="utf-8"><style>${css}</style></head><body>${body}</body></html>`);
  const png = path.join(OUT, `${name}.png`);
  execFileSync(EDGE, ['--headless=new', '--disable-gpu', '--hide-scrollbars', '--window-size=1920,1080',
    `--screenshot=${png}`, 'file:///' + htmlPath.replace(/\\/g, '/')], { stdio: 'ignore' });
  fs.unlinkSync(htmlPath);
}

for (const [key, v] of Object.entries(videos)) {
  render(`${key}_intro`, v.intro);
  v.scenes.forEach((s, i) => render(`${key}_s${i}`, sceneHtml(s, i, v.scenes.length, v.scenario)));
  render(`${key}_outro`, `<div class="card"><div class="logo">Cain</div><div class="csub" style="font-size:52px;font-weight:700;opacity:1;margin-top:40px">처음 온 캠퍼스, 길을 묻지 않아도 되도록</div><div class="csub">AI 다국어 캠퍼스 생활 안내 앱 · 한국기술교육대학교</div>${v.outroNote ? `<div class="note">${v.outroNote}</div>` : ''}</div>`);
}
console.log(fs.readdirSync(OUT).join('\n'));
