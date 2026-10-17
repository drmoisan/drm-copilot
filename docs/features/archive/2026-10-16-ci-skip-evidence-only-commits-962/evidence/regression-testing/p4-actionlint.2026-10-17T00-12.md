# actionlint, rule 17 RI-4 re-run of P4-T15

Timestamp: 2026-10-17T00-12
Command: sh SCRATCH/tools/run-cr.sh cr-actionlint -PathList ".github/workflows/ci.yml,.github/workflows/_quality-checks.yml,.github/workflows/_security-scan.yml,.github/workflows/_build-check.yml,.github/workflows/_shell-coverage.yml,.github/workflows/_drm-copilot-extension-tests.yml,.github/workflows/_poshqc.yml"
EXIT_CODE: 0
Output Summary: On the re-integrated head (ci.yml now also declares merge_group), actionlint 1.7.11 wrapper exit 0, direct exit 0, ACTIONLINT-FINDINGS: 0. EXIT_CODE_COMPUTED: 0.

## Output

```
RUN-CR: cr-actionlint
Running actionlint...
ACTIONLINT-WRAPPER-EXIT: 0
ACTIONLINT-VERSION: 1.7.11
ACTIONLINT-DIRECT-EXIT: 0
ACTIONLINT-FINDINGS: 0
EXIT_CODE_COMPUTED: 0
```
