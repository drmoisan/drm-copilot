# Jest Per-File Coverage of orchestrator-state-remediation.ts (P0-T27)

Timestamp: 2026-10-01T21-13
Task: P0-T27
Input: `extensions/drm-copilot/coverage/lcov.info` written by P0-T26

Command: poetry run python -c "t=open('extensions/drm-copilot/coverage/lcov.info', encoding='utf-8').read(); b=[r for r in t.split('end_of_record') if any(l.startswith('SF:') and l.replace(chr(92), '/').endswith('/validate/orchestrator-state-remediation.ts') for l in r.splitlines())]; print(len(b)); print([l for l in b[0].splitlines() if l.startswith(('SF:','LF:','LH:','BRF:','BRH:'))])"
EXIT_CODE: 0
Output:

```
1
['SF:src\\lib\\validate\\orchestrator-state-remediation.ts', 'LF:136', 'LH:136', 'BRF:18', 'BRH:18']
```

## Output Summary:

- First printed line: `1` (exactly one LCOV record).
- Lines: LH/LF = 136/136 = 100.00%.
- Branches: BRH/BRF = 18/18 = 100.00%.
- ThresholdGap: false
