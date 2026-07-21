# Orchestrator Shell-QC Verification — Issue #393

- Date (UTC): 2026-07-21T23:20
- Verifier: orchestrator (main session)
- Reason: The `atomic-executor` Bash allowlist (`poetry run`/`npx`/`pwsh`/`git`) cannot
  invoke the native bash toolchain, and `feature-review` has only `git diff`/`git log`.
  The orchestrator (main session) is the sole actor able to run `shfmt`/`shellcheck`.
  `bats` and `kcov` are not installed on this Windows host and WSL has no bash-capable
  distribution, so `bats`/`kcov` verification is deferred to the CI green run (AC9).

## Host tooling

- shfmt: present, v3.12.0
- shellcheck: present, v0.11.0
- bats: absent
- kcov: absent
- WSL: present but no bash-capable distribution (`execvpe(bash) failed`)

## Verification results (dogfooded via the new wrapper)

| Check | Command | Result |
|---|---|---|
| Help / installability smoke | `bash scripts/bash/shell-qc.sh --help` | exit 0; usage printed |
| Format + lint | `bash scripts/bash/shell-qc.sh check` | exit 0 (shfmt diff clean + shellcheck clean across all 4 discovered scripts) |
| Discovery | (via `check`) | Discovered `scripts/bash/{coverage_demo.sh,coverage_lib.sh,shell-qc.sh,shell_qc_lib.sh}` |
| bats-missing skip path | `bash scripts/bash/shell-qc.sh test` | exit 0; printed byte-identical marker `bats not installed; skipping shell tests.` |
| File-size limit (<= 500) | `wc -l` | shell-qc.sh 103, shell_qc_lib.sh 354, test_shell_qc_commands.bats 165, test_shell_qc_discovery.bats 84 |
| Line endings | `.gitattributes` `* text=auto eol=lf` + LF-only working files | No CRLF; safe on Linux CI |

## Orchestrator correction applied

- `scripts/bash/shell-qc.sh`: the initial `check` run reported `SC1091` (info) on the
  runtime `source` of `shell_qc_lib.sh`; shellcheck exits non-zero on any finding. Added a
  justified `# shellcheck disable=SC1091` (with a `# shellcheck source=` directive and an
  inline rationale) per `.claude/rules/shell.md` (suppressions permitted when justified
  inline). Re-ran `check` -> exit 0.

## Deferred to CI (AC9 green run)

- AC2 (kcov coverage `cov.xml` + `Bash coverage (lines): NN.N%` summary), AC3 (bats
  discovery suite pass), AC8 (bats command suite pass). These execute in
  `.github/workflows/_shell-coverage.yml` (bats + kcov on `ubuntu-latest`) and are verified
  by the S9 CI green gate.
