# Jest Per-File Coverage Baseline for orchestrator-state-core.ts (P0-T19)

Timestamp: 2026-09-30T14-28
Command: poetry run python -c "t=open('extensions/drm-copilot/coverage/lcov.info', encoding='utf-8').read(); b=[r for r in t.split('end_of_record') if any(l.startswith('SF:') and l.replace(chr(92), '/').endswith('/validate/orchestrator-state-core.ts') for l in r.splitlines())]; print(len(b)); print([l for l in b[0].splitlines() if l.startswith(('SF:','LF:','LH:','BRF:','BRH:'))])"
EXIT_CODE: 0
Output Summary: First printed line `1`. Second line: `['SF:src\\lib\\validate\\orchestrator-state-core.ts', 'LF:467', 'LH:462', 'BRF:78', 'BRH:75']`.
- `SF:` value ends with `orchestrator-state-core.ts` directly after a path separator (not the `epic-` or `parallel-` variant).
- LF=467, LH=462, BRF=78, BRH=75
- Line percent (LH/LF): 462/467 = 98.93%
- Branch percent (BRH/BRF): 75/78 = 96.15%
