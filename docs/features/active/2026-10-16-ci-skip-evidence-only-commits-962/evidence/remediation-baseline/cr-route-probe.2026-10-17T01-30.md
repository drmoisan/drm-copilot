# Command route probe — remediation cycle 1 (P0-T3)

Timestamp: 2026-10-17T01-30
Command: sh SCRATCH/tools/run-cr.sh cr-probe
EXIT_CODE: 0
Output Summary: The launcher and all seven recipes match section 5 of the reference plan (byte comparison after CR removal; run-cr.sh has LF endings). No file was rewritten. Probe passed: Pester 5.9.0, cwd is the repo root, EXIT_CODE_COMPUTED: 0.

CR-ROUTE: sh-launcher

## Files read (none rewritten)

Compared with `plan.2026-10-16T10-27.md` section 5 fenced blocks by `SCRATCH/verify/rem1-cmp-tools.sh`:

```text
SAME: run-cr.sh
SAME: cr-probe.txt
SAME: cr-pester-list.txt
SAME: cr-format.txt
SAME: cr-pssa.txt
SAME: cr-hermetic.txt
SAME: cr-readme.txt
SAME: cr-actionlint.txt
RUN-CR-CRLF: no
CMP-EXIT: 0
```

## Probe output

```text
RUN-CR: cr-probe
PROBE-PWSH: 7.6.6
PROBE-PESTER: 5.9.0
PROBE-PSSA: 1.25.0
PROBE-CWD-IS-REPO-ROOT: True
EXIT_CODE_COMPUTED: 0
```
