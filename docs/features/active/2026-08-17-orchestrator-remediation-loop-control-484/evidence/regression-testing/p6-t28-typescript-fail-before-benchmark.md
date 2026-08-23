Timestamp: 2026-08-23T05-17
Command: `node -e "const fs=require('node:fs');const {performance}=require('node:perf_hooks');const {validateOrchestratorStateText:v}=require('./docs/features/active/2026-08-17-orchestrator-remediation-loop-control-484/evidence/qa-gates/typescript-benchmark-build/lib/validate/orchestrator-state-core.js');const s=fs.readFileSync('artifacts/orchestration/orchestrator-state.json','utf8');for(let i=0;i<100;i++)v(s);const a=[];for(let i=0;i<100;i++){const t=performance.now();v(s);a.push(performance.now()-t)}a.sort((x,y)=>x-y);console.log(JSON.stringify({samples:100,p50_ms:a[49],p95_ms:a[94]}))"`
ExpectedExitCode: 0
EXIT_CODE: 0
Output Summary: EXPECTED THRESHOLD FAIL. The unchanged benchmark completed 100 warm-ups and 100 timed samples. It reported p50 `0.2670999999999992 ms`, p95 `0.42540000000001044 ms`, and ratio `1.8359948208891` against baseline p95 `0.23170000000000357 ms`, above the required maximum ratio `1.10`.
Checkpoint SHA-256: `D8B6D3F8AE432D9CED93D1023EB08AB774107FCDDB1D7E14EEBE8C1B729D700B`
Checkpoint Bytes: `194016`
Topology Receipts: total `79`, unique resolver keys `12`
Model-Routing Receipts: total `79`, unique resolver keys `5`
Warm-ups: `100`
Timed Samples: `100`
Percentile Index: `94`
Baseline p95 ms: `0.23170000000000357`
Post p50 ms: `0.2670999999999992`
Post p95 ms: `0.42540000000001044`
Ratio: `1.8359948208891`
