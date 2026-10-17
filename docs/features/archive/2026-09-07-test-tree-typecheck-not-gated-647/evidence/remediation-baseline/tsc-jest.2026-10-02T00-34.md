# Baseline — Test-Tree Type Check (issue #647, remediation cycle 1)

Timestamp: 2026-10-02T00-34
Command: node extensions/drm-copilot/node_modules/typescript/bin/tsc -p extensions/drm-copilot/tsconfig.jest.json --noEmit > <SCRATCH>/tsc-jest-base.txt 2>&1; echo "TSC_EXIT=$?"; grep -c 'error TS' <SCRATCH>/tsc-jest-base.txt
EXIT_CODE: 0
Output Summary:
- TSC_EXIT=0
- `error TS` count: 0
- Result: pass (baseline expectation met).
