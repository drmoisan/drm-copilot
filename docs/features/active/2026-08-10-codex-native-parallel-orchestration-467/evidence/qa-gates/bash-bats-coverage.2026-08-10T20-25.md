# Final Bats and Bash Coverage Gate

Timestamp: `2026-08-11T16:44:30.0615493-04:00`

Logical command: `bash -lc "SHELL_QC_KCOV_OUT_DIR='docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/bash-kcov.2026-08-10T20-25' bash scripts/bash/shell-qc.sh test --coverage"`

Supported Windows execution: cached `kcov/kcov:latest` container with the repository mounted at `/work`, Bats `1.13.0` mounted at `/opt/bats`, `SHELL_QC_BATS_BIN=/opt/bats/bin/bats`, the canonical `SHELL_QC_KCOV_OUT_DIR`, and an ephemeral installation of `git` because host kcov is unavailable and the coverage image does not include Git.

EXIT_CODE: `0`

Output Summary: The clean P6-T15 run completed all Bats cases under kcov and wrote the merged report only to the plan-named canonical feature evidence directory.

## Bats result

- TAP plan: `1..250`.
- Passed: `250`.
- Failed: `0`.
- Skipped: `0`.
- Elapsed time: `107.118 seconds`.
- Bats warnings: `4`; each warning belongs to an intentional negative test that invokes a deliberately nonexistent shfmt, ShellCheck, Bats, or kcov binary and asserts exit `127`.

The first container attempt completed `248 / 250` cases and exposed only a harness dependency: two `cleanup_wt_git` fallback tests received exit `127` because the kcov image had no `git` command. No source file changed and no merged report was retained. The required P6-T13 through P6-T15 loop was then restarted; the final run used an actual ephemeral Git installation and passed `250 / 250`.

## Numeric Bash coverage

| Scope | Covered / total lines | Coverage |
| --- | ---: | ---: |
| Repository Bash files represented by kcov | `1,348 / 1,461` | `92.30%` |
| Nine approved portable Bash files | `727 / 780` | `93.21%` |

Portable-logic detail:

| Path | Covered / total lines | Coverage |
| --- | ---: | ---: |
| `.claude/lib/bash/compute-cohorts.sh` | `49 / 53` | `92.45%` |
| `.claude/lib/bash/compute-concurrency-batches.sh` | `36 / 44` | `81.82%` |
| `.claude/lib/bash/parallel-cohorts.sh` | `133 / 134` | `99.25%` |
| `.claude/lib/bash/parallel-common.sh` | `53 / 55` | `96.36%` |
| `.claude/lib/bash/parallel-items-validate.sh` | `115 / 115` | `100.00%` |
| `.claude/lib/bash/parallel-manifest-validate.sh` | `63 / 63` | `100.00%` |
| `.claude/lib/bash/parallel-yaml-emit.sh` | `134 / 153` | `87.58%` |
| `.claude/lib/bash/parallel-yaml-scan.sh` | `103 / 117` | `88.03%` |
| `.claude/lib/bash/validate-parallel-manifest.sh` | `41 / 46` | `89.13%` |

## Coverage artifact and policy checks

- Canonical coverage directory: `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/qa-gates/bash-kcov.2026-08-10T20-25`.
- Cobertura report: `kcov-merged/cobertura.xml`.
- Cobertura SHA-256: `BA131A797B956FFF241EEB05F020B238A5F23E380CF8031F7850393AFA0F4BE3`.
- Coverage files: `87`; total bytes: `2,596,226`.
- Residual `.kcov_runs` directories: `0`.
- Discovered shell files above `500` lines: `0`; maximum: `479` lines.
- New Bash suppression additions: `0`.
- `.claude/` baseline/current files: `150 / 150`; manifest mismatches: `0`; status paths: `0`.
- Canonical P0-T7/current `.claude/` manifest SHA-256: `34FE91AA14F9622BF4B9BF10E87BE787B95E992FFD69DFE09728937A779AA07C`.
- `.codex/state`: absent.
- `git diff --check`: exit `0`, no output.

`P6_T15_STATUS: COMPLETE`
