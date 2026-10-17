# Jest Per-File Coverage Final (P9-T6)

Timestamp: 2026-10-01T22-47
Task: P9-T6
Loop iteration: 2
Input: `extensions/drm-copilot/coverage/lcov.info` written by P9-T5
Split: applied (P4-T4; deviation D4), so two records are expected.

Command: poetry run python -c "t=open('extensions/drm-copilot/coverage/lcov.info', encoding='utf-8').read(); b=[r for r in t.split('end_of_record') if any(l.startswith('SF:') and l.replace(chr(92), '/').endswith(('/validate/orchestrator-state-remediation.ts', '/validate/orchestrator-state-remediation-accounting.ts')) for l in r.splitlines())]; print(len(b)); [print([l for l in r.splitlines() if l.startswith(('SF:','LF:','LH:','BRF:','BRH:'))]) for r in b]"
EXIT_CODE: 0
Output:

```
2
['SF:src\\lib\\validate\\orchestrator-state-remediation-accounting.ts', 'LF:221', 'LH:217', 'BRF:45', 'BRH:43']
['SF:src\\lib\\validate\\orchestrator-state-remediation.ts', 'LF:283', 'LH:283', 'BRF:56', 'BRH:56']
```

## Output Summary:

- First printed line: `2` (permitted because P4-T4 recorded `Split: applied`).
- `orchestrator-state-remediation.ts`: LH/LF = 283/283 = 1.0000 (100.00%); BRH/BRF = 56/56 = 1.0000 (100.00%).
- `orchestrator-state-remediation-accounting.ts`: LH/LF = 217/221 = 0.9819 (98.19%); BRH/BRF = 43/45 = 0.9556 (95.56%).
- Every ratio meets 0.85 (lines) and 0.75 (branches). Result: PASS.
