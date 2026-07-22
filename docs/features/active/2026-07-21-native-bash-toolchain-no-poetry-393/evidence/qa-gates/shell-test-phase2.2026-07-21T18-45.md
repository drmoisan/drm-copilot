# QA Gate — Shell Toolchain Gate, Phase 2 (P2-T8) (Issue #393)

Timestamp: 2026-07-21T18-45

## Commands
1. Command: bash scripts/bash/shell-qc.sh format — EXIT_CODE: NOT-EXECUTED (delegated)
2. Command: bash scripts/bash/shell-qc.sh check  — EXIT_CODE: NOT-EXECUTED (delegated)
3. Command: bash scripts/bash/shell-qc.sh test   — EXIT_CODE: NOT-EXECUTED (delegated)

Note: shfmt/shellcheck are not run by the executor (not on the Bash allowlist) and bats/kcov
are not installed on this Windows host. Per the orchestrator's constraints, the bats suites
are written correctly and completely; shfmt/shellcheck verification is delegated to the
orchestrator and bats/kcov execution is deferred to the CI green run (AC9, P5-T9).

## Bats suites written (AC8)
- tests/shell/test_shell_qc_discovery.bats (84 lines): 11 named tests covering .sh suffix,
  extensionless bash shebang, env form, env -S flags form, uppercase shebang, sh shebang,
  node_modules prune, non-shell (txt, ps1) ignored, and sorted/de-duplicated output.
- tests/shell/test_shell_qc_commands.bats (165 lines): 19 named tests covering check
  no-scripts skip + exit 0; check 127 + five-line block for missing shfmt and missing
  shellcheck; max-exit semantics (shfmt-only, shellcheck-only, both); single `shfmt -d` over
  the full list + per-file shellcheck (5 calls asserted from stub argv); format `-w`; the two
  byte-identical fix_all skip markers ("No shell test directories found; skipping." and
  "bats not installed; skipping shell tests."); bats-missing coverage exit 127; kcov-missing
  exit 127 + block; kcov argv shape (--cobertura-only, include/exclude patterns, test dir,
  stub bats path) and `kcov --merge`; coverage summary "Bash coverage (lines): 75.0%" via a
  direct library call on the cov.xml fixture; --help and help exit 0; unknown subcommand and
  unknown test flag exit 2.

## Fixtures/stubs added (no temp files at runtime)
- tests/fixtures/shell_qc/scripts/{env_s_bash, sh_shebang, uppercase_bash}
- tests/fixtures/shell_qc/scripts/node_modules/skip_me.sh (force-tracked via `git add -f`)
- tests/fixtures/shell_qc/cov/cov.xml (line-rate="0.75")
- tests/fixtures/shell_qc/stub-bin/{shfmt, shellcheck, bats, kcov} (recording stubs;
  runtime-executable via `chmod +x` in the commands suite setup())

Output Summary: Both bats suites written (< 500 lines each) with every plan-listed scenario as
a named test; byte-identical skip markers asserted; no temp files. Execution delegated/deferred
to orchestrator and CI.
