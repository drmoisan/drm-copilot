# Jest Per-File Coverage Final QA (P9-T6)

Timestamp: 2026-09-30T15-44
Command: poetry run python -c "t=open('extensions/drm-copilot/coverage/lcov.info', encoding='utf-8').read(); b=[r for r in t.split('end_of_record') if any(l.startswith('SF:') and l.replace(chr(92), '/').endswith(('/validate/orchestrator-state-core.ts', '/validate/orchestrator-state-blocked-reason.ts')) for l in r.splitlines())]; print(len(b)); [print([l for l in r.splitlines() if l.startswith(('SF:','LF:','LH:','BRF:','BRH:'))]) for r in b]"
EXIT_CODE: 0
Output Summary: First printed line `2`; exactly two records follow. The lcov file was written by the P9-T5 run of this iteration (modification time 15:44 UTC).
- `['SF:src\\lib\\validate\\orchestrator-state-blocked-reason.ts', 'LF:74', 'LH:74', 'BRF:10', 'BRH:10']`
  - Line (LH/LF): 74/74 = 100.00% (>= 85: PASS); Branch (BRH/BRF): 10/10 = 100.00% (>= 75: PASS)
- `['SF:src\\lib\\validate\\orchestrator-state-core.ts', 'LF:458', 'LH:453', 'BRF:80', 'BRH:77']`
  - Line (LH/LF): 453/458 = 98.91% (>= 85: PASS); Branch (BRH/BRF): 77/80 = 96.25% (>= 75: PASS)
- Both `SF:` values, with `\` normalized to `/`, end with the selected suffixes; the `epic-` and `parallel-` core records are not selected.
- Loop iteration 2 (restart after remediation cycle 1; supersedes the iteration 1 artifact).
