# P7-T27 AC-27 pending CI

Timestamp: 2026-10-03T10-16

AC-27 ("The repository's full toolchain passes on the PR head, including the Windows PoshQC job and the Linux hook-suite Pester job in `.github/workflows/_poshqc.yml`") is CI-dependent. Its checkbox in spec.md is left unchecked and is recorded here as pending-CI.

Jobs it depends on, both defined in `.github/workflows/_poshqc.yml`:

- `poshqc / PowerShell QC` (`windows-latest`, every suite with coverage; lines 8-52)
- `poshqc / PowerShell hook suites (Linux)` (`ubuntu-latest`, `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks`, coverage disabled; lines 54-90)

The rest of the repository CI on the PR head also applies. AC-27 is checked off at orchestration step S9 by the item's own orchestrator run, after those jobs pass and `ci_gate.conclusion` records `success`.

Local evidence available ahead of CI: the full Windows Pester run with coverage passed (`evidence/qa-gates/poshqc-test.2026-10-03T10-04.md`, tests=6626 failures=0), and the local Windows run of the hook-suite selection passed (`evidence/regression-testing/hook-suites-full.2026-10-03T09-57.md`, 3509 passed). The Linux job has not been observed locally.
