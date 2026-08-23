Timestamp: 2026-08-23T05-19
Command: `node -e "const fs=require('node:fs');const p=JSON.parse(fs.readFileSync('docs/features/active/2026-08-17-orchestrator-remediation-loop-control-484/evidence/regression-testing/p6-t28-typescript-fail-before.cpuprofile','utf8'));const c=new Map();for(const id of p.samples??[])c.set(id,(c.get(id)??0)+1);const nodes=new Map(p.nodes.map(n=>[n.id,n]));const rows=[...c].map(([id,samples])=>{const n=nodes.get(id);return {samples,functionName:n?.callFrame?.functionName??'',url:n?.callFrame?.url??'',line:(n?.callFrame?.lineNumber??-1)+1}}).filter(r=>r.url||r.functionName).sort((a,b)=>b.samples-a.samples).slice(0,30);console.log(JSON.stringify({total_samples:(p.samples??[]).length,top_frames:rows},null,2))"`
EXIT_CODE: 0
Command: `node -e "const fs=require('node:fs'),crypto=require('node:crypto');const b=fs.readFileSync('artifacts/orchestration/orchestrator-state.json');const d=JSON.parse(b);const t=d.codex_topology_receipts,m=d.codex_model_routing_receipts;const tk=r=>JSON.stringify([r.languages,r.production_file_count,r.test_file_count,r.execution_context,r.cross_cutting,r.root_persona]);const mk=r=>JSON.stringify([String(r.logical_agent),String(r.complexity_band),String(r.execution_context),String(r.orchestration_complexity_ceiling)]);const tc=new Map(),mc=new Map();for(const r of t)tc.set(tk(r),(tc.get(tk(r))??0)+1);for(const r of m)mc.set(mk(r),(mc.get(mk(r))??0)+1);console.log(JSON.stringify({checkpoint_sha256:crypto.createHash('sha256').update(b).digest('hex').toUpperCase(),checkpoint_bytes:b.length,topology_total:t.length,topology_unique:tc.size,topology_duplicate_keys:[...tc].filter(([,n])=>n>1).sort((a,b)=>b[1]-a[1]),model_total:m.length,model_unique:mc.size,model_duplicate_keys:[...mc].filter(([,n])=>n>1).sort((a,b)=>b[1]-a[1])},null,2))"`
EXIT_CODE: 0
Output Summary: The profile contains `67` total samples and directly attributes samples to the repeated validator/resolver path: `validateOrchestratorStateText` `31`, model-routing `validateReceipt` `3`, topology receipt-loop anonymous frames `3` and `2`, `resolveCodexTopology` `2`, `resolveCodexDeployment` `1`, topology `validateReceipt` `1`, and `validateCodexTopologyReceipts` `1`. The checkpoint shared by P4-T2 and P4-T3 has topology `79/12` and model routing `79/5`; both totals exceed their unique-key counts and both families contain duplicated exact resolver keys. The evidence locks the correction scope to per-invocation successful-result caching in `TS-PROD-A`.
Checkpoint SHA-256: `D8B6D3F8AE432D9CED93D1023EB08AB774107FCDDB1D7E14EEBE8C1B729D700B`
Checkpoint Bytes: `194016`
Topology Receipts: total `79`, unique `12`
Model-Routing Receipts: total `79`, unique `5`

Top sampled JavaScript frames, descending by sample count:

| Samples | Function | Location |
|---:|---|---|
| 31 | `validateOrchestratorStateText` | compiled `orchestrator-state-core.js:261` |
| 4 | `(garbage collector)` | V8 runtime |
| 3 | `validateReceipt` | compiled `orchestrator-state-codex-model-routing.js:225` |
| 3 | anonymous | compiled `orchestrator-state-codex-topology.js:143` |
| 2 | `wrapSafe` | `node:internal/modules/cjs/loader:1701` |
| 2 | `resolveCodexTopology` | compiled `codex-topology-resolver.js:120` |
| 2 | anonymous | compiled `orchestrator-state-core.js:171` |
| 2 | anonymous | compiled `orchestrator-state-codex-topology.js:98` |
| 1 | `(program)` | V8 runtime |
| 1 | anonymous | `node:internal/modules/esm/assert:1` |
| 1 | anonymous | `node:internal/modules/cjs/loader:704` |
| 1 | `normalizeString` | `node:path:92` |
| 1 | `normalizeString` | `node:path:92` |
| 1 | `normalizeString` | `node:path:92` |
| 1 | `wrapSafe` | `node:internal/modules/cjs/loader:1701` |
| 1 | anonymous | `node:internal/crypto/argon2:1` |
| 1 | anonymous | `node:internal/streams/readable:1` |
| 1 | `lstat` | native runtime |
| 1 | anonymous | `[eval]:1` |
| 1 | `resolveCodexDeployment` | compiled `orchestrator-state-codex-model-routing.js:171` |
| 1 | `validateReceipt` | compiled `orchestrator-state-codex-topology.js:94` |
| 1 | anonymous | compiled `orchestrator-state-codex-model-routing.js:229` |
| 1 | anonymous | compiled `orchestrator-state-codex-model-routing.js:184` |
| 1 | `validateCodexTopologyReceipts` | compiled `orchestrator-state-codex-topology.js:137` |
| 1 | `SafeWeakRef` | `node:internal/per_context/primordials:430` |
| 1 | `(idle)` | V8 runtime |

Duplicated topology resolver keys and multiplicities:

- `[["typescript"],11,14,"standalone",true,null]`: `36`
- `[["python"],11,14,"standalone",true,null]`: `10`
- `[["python"],3,3,"standalone",true,null]`: `9`
- `[["python"],2,0,"standalone",true,null]`: `5`
- `[["python","typescript"],2,3,"standalone",true,null]`: `5`
- `[["python"],7,10,"standalone",true,null]`: `3`
- `[["python"],2,2,"standalone",true,null]`: `3`
- `[["typescript"],2,2,"standalone",true,null]`: `3`
- `[["python"],5,8,"standalone",true,null]`: `2`

Duplicated model-routing resolver keys and multiplicities:

- `["atomic-executor","C4","standalone","C4"]`: `44`
- `["atomic-planner","C4","standalone","C4"]`: `25`
- `["orchestrator","C4","standalone","C4"]`: `4`
- `["task-researcher","C4","standalone","C4"]`: `3`
- `["prd-feature","C4","standalone","C4"]`: `3`

Scope Lock: Add only fresh, per-validation, successful-resolution caches keyed by the validated exact input tuples in `extensions/drm-copilot/src/lib/validate/orchestrator-state-codex-topology.ts` and `extensions/drm-copilot/src/lib/validate/orchestrator-state-codex-model-routing.ts`.
