# Coverage status (remediation cycle 1)

Timestamp: 2026-10-16T16-31
Task: [P5-T9]
Command: record of P0-T9 and P0-T11 values
EXIT_CODE: 0
Output Summary:
PYTHON: NOT-APPLICABLE (P0-T11: `## Files Written` names no Python file; PY-CONTRACT is the Python regression gate, 786 passed in P5-T4)
POWERSHELL: PENDING-ORCH (ORCH-R3; D-COV and D-CHANGED on R_final_2, job poshqc / PowerShell QC)

Baseline values (P0-T9, R_final 38899600487):
- CODEX_HELPER_LINE=75.47 (changed-line 75.47)
- CLAUDE_HELPER_LINE=94.34
- PARSER_LINE=91.67

No PowerShell PASS verdict is recorded by the executor; post-change coverage comes only from CI artifacts read by the orchestrator.
