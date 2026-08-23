Timestamp: 2026-08-23T09-31
Command: `node -e "const fs=require('node:fs');const {performance}=require('node:perf_hooks');const {validateOrchestratorStateText:v}=require('./docs/features/active/2026-08-17-orchestrator-remediation-loop-control-484/evidence/qa-gates/typescript-benchmark-build/lib/validate/orchestrator-state-core.js');const s=fs.readFileSync('artifacts/orchestration/orchestrator-state.json','utf8');for(let i=0;i<100;i++)v(s);const a=[];for(let i=0;i<100;i++){const t=performance.now();v(s);a.push(performance.now()-t)}a.sort((x,y)=>x-y);console.log(JSON.stringify({samples:100,p50_ms:a[49],p95_ms:a[94]}))"`
EXIT_CODE: 0
Output Summary: SEMANTIC THRESHOLD FAIL. The unchanged exact original P6-T28 benchmark completed with `100` warm-ups and `100` timed samples using sorted p95 index `[94]`, but measured p50 `0.2960000000000065 ms`, p95 `0.4871000000000123 ms`, and ratio `2.1022874406560415`, exceeding the required `1.10`. The single permitted immediate unchanged confirmation run reproduced the threshold failure with p50 `0.2843000000000018 ms`, p95 `0.4176999999999964 ms`, and ratio `1.802762192490246`. The plan-governed remediation-required stop applies; P4-T30 remains unchecked and P4-T31 was not started.
Baseline p95: `0.23170000000000357 ms`
Warm-ups: `100`
Timed samples: `100`
Sorted p95 index: `[94]`
Threshold: `1.10`
Post p50: `0.2960000000000065 ms`
Post p95: `0.4871000000000123 ms`
Post ratio: `2.1022874406560415`
Confirmation Command: `node -e "const fs=require('node:fs');const {performance}=require('node:perf_hooks');const {validateOrchestratorStateText:v}=require('./docs/features/active/2026-08-17-orchestrator-remediation-loop-control-484/evidence/qa-gates/typescript-benchmark-build/lib/validate/orchestrator-state-core.js');const s=fs.readFileSync('artifacts/orchestration/orchestrator-state.json','utf8');for(let i=0;i<100;i++)v(s);const a=[];for(let i=0;i<100;i++){const t=performance.now();v(s);a.push(performance.now()-t)}a.sort((x,y)=>x-y);console.log(JSON.stringify({samples:100,p50_ms:a[49],p95_ms:a[94]}))"`
Confirmation EXIT_CODE: 0
Confirmation p50: `0.2843000000000018 ms`
Confirmation p95: `0.4176999999999964 ms`
Confirmation ratio: `1.802762192490246`
Checkpoint: `artifacts/orchestration/orchestrator-state.json`; bytes `261424`; SHA-256 `2c55942e5079c157af8a2058d1bb096d89d954dc233a4f64111f4c2e400b473b`
Compiled Core: `docs/features/active/2026-08-17-orchestrator-remediation-loop-control-484/evidence/qa-gates/typescript-benchmark-build/lib/validate/orchestrator-state-core.js`; bytes `16194`; SHA-256 `89936caca555f17a6cb3d5a61cca4b5721db8112288c4cfb94e6241bb0cf0e13`
Topology Receipts: total `110`; unique `13`; structurally invalid `0`
Model-Routing Receipts: total `110`; unique `5`; structurally invalid `0`
Receipt Conditions: Both totals exceed the P4-T4 floors (`79/12` topology and `79/5` model routing), and `total > unique` remains true for both families.
Process Startup Exclusion: Preserved; timing starts and ends only around each in-process validator call.
