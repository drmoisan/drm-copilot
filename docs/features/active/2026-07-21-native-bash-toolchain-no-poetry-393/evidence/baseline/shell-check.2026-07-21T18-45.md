# Baseline — Existing shell-qc check (parity reference) (Issue #393)

Timestamp: 2026-07-21T18-45
Command: poetry run shell-qc check
EXIT_CODE: NOT-EXECUTED (see note)

Note: The old Poetry entry point is not executed by the executor (Python/Poetry surface being
removed; not on the executor Bash allowlist). shfmt/shellcheck are also not run by the
executor per the orchestrator's constraints (verification delegated to the orchestrator /
CI). Parity captured from `scripts/dev_tools/shell_qc.py::run_check` (lines 167-193).

Behavior contract (to be reproduced by `run_check` in the bash library):
1. Discover scripts; if none: print "No shell scripts found; skipping." and return 0.
2. Preflight shfmt (missing -> 5-line block, exit 127), then shellcheck (missing -> block, 127).
3. `shfmt -d <all files>` once over the full file list.
4. `shellcheck <file>` once per file; track max shellcheck exit.
5. Final exit = max(shfmt_exit, max_shellcheck_exit).

Output Summary: Findings/exit determined at runtime by the discovered file set and tool
versions. The two new bash files (`scripts/bash/shell-qc.sh`, `scripts/bash/shell_qc_lib.sh`)
enter the discovered set and must be shfmt-clean and shellcheck-clean (self-hosting gate,
P1-T7). Local shfmt/shellcheck verification is delegated to the orchestrator; the CI green
run (AC9, P5-T9) is the canonical check.
