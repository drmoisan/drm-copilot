Timestamp: 2026-08-23T05-18
Command: `node --cpu-prof --cpu-prof-dir=docs/features/active/2026-08-17-orchestrator-remediation-loop-control-484/evidence/regression-testing --cpu-prof-name=p6-t28-typescript-fail-before.cpuprofile -e "const fs=require('node:fs');const {performance}=require('node:perf_hooks');const {validateOrchestratorStateText:v}=require('./docs/features/active/2026-08-17-orchestrator-remediation-loop-control-484/evidence/qa-gates/typescript-benchmark-build/lib/validate/orchestrator-state-core.js');const s=fs.readFileSync('artifacts/orchestration/orchestrator-state.json','utf8');for(let i=0;i<100;i++)v(s);const a=[];for(let i=0;i<100;i++){const t=performance.now();v(s);a.push(performance.now()-t)}a.sort((x,y)=>x-y);console.log(JSON.stringify({samples:100,p50_ms:a[49],p95_ms:a[94]}))"`
EXIT_CODE: 0
Output Summary: Node produced a CPU profile for the unchanged P6-T28 body using 100 warm-ups and 100 timed samples. The profiled run reported p50 `0.2797999999999945 ms` and p95 `0.4819999999999993 ms`. P4-T2 and P4-T3 used the same checkpoint and compiled-core identities.
Checkpoint SHA-256: `D8B6D3F8AE432D9CED93D1023EB08AB774107FCDDB1D7E14EEBE8C1B729D700B`
Checkpoint Bytes: `194016`
Topology Receipts: total `79`, unique resolver keys `12`
Model-Routing Receipts: total `79`, unique resolver keys `5`
Compiled Core SHA-256: `89936CACA555F17A6CB3D5A61CCA4B5721DB8112288C4CFB94E6241BB0CF0E13`
Compiled Core Bytes: `16194`
Profile Path: `docs/features/active/2026-08-17-orchestrator-remediation-loop-control-484/evidence/regression-testing/p6-t28-typescript-fail-before.cpuprofile`
Profile SHA-256: `35E990ECE0CCDDB1CB16E17A32971FDFEB53F40EB2F96D9EE7B17197700EE147`
Profile Bytes: `31135`
Warm-ups: `100`
Timed Samples: `100`
