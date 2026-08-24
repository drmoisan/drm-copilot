# QA Gate — Shell Self-Hosting Check (P1-T7) (Issue #393)

Timestamp: 2026-07-21T18-45

## Command 1
Command: bash scripts/bash/shell-qc.sh format
EXIT_CODE: NOT-EXECUTED (delegated; see note)

## Command 2
Command: bash scripts/bash/shell-qc.sh check
EXIT_CODE: NOT-EXECUTED (delegated; see note)

Note: Per the orchestrator's toolchain-execution constraints, shfmt and shellcheck are not
run by the executor (not on the executor Bash allowlist; the local WSL/host tool set is not
guaranteed). The two new files were written to be shfmt-clean and shellcheck-clean by
construction:
- Tab indentation (shfmt default; verified 0 leading-space code lines via `grep -Pn '^ '`),
  matching the existing `scripts/bash/coverage_lib.sh`.
- `set -euo pipefail` in the wrapper; every external tool (shfmt, shellcheck, bats, kcov) is
  invoked only with a captured `|| rc=$?` so an intended non-zero never aborts under set -e.
- All expansions quoted; `command -v` / the SHELL_QC_<TOOL>_BIN seam used for tool resolution.
- A `# shellcheck source=scripts/bash/shell_qc_lib.sh` directive precedes the dynamic
  `source`, resolving SC1090/SC1091.
- `i=$((i + 1))` used instead of `((i++))` to avoid the set -e post-increment pitfall.

Status: written; shfmt/shellcheck verification delegated to orchestrator; the CI green run
(AC9, P5-T9) is the canonical check. If the orchestrator's `format` pass rewrites either file,
the toolchain loop restarts from format per the plan's loop rule.

Output Summary: Both new files (`scripts/bash/shell-qc.sh`, `scripts/bash/shell_qc_lib.sh`)
are discovered by the wrapper's own `tools/`+`scripts/` discovery and are subject to the
self-hosting check. Constructed shfmt-/shellcheck-clean; execution deferred.
