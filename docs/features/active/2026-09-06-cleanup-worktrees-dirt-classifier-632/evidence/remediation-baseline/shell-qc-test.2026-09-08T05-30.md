# Baseline — full bats stage

Timestamp: 2026-09-08T05-40

Task: [P0-T5] of `remediation-plan.2026-09-08T05-00.md`

## Commands

Binary resolution:

```
npx --yes bats --version
```

Stage invocation, with the placeholder resolved to the concrete path:

```
env SHELL_QC_BATS_BIN=C:/Users/DanMoisan/AppData/Local/npm-cache/_npx/cd2c4d46c11457b7/node_modules/bats/bin/bats bash scripts/bash/shell-qc.sh test
```

`run_test` in `scripts/bash/shell_qc_lib.sh` honours the `SHELL_QC_BATS_BIN` seam
documented at `.claude/rules/shell.md:42-44`.

EXIT_CODE: 0

ResolvedBatsPath: `C:/Users/DanMoisan/AppData/Local/npm-cache/_npx/cd2c4d46c11457b7/node_modules/bats/bin/bats`
ResolvedBatsVersion: `Bats 1.13.0`

## TAP figures

TAP plan line: `1..390`
Lines beginning `ok`: 390
Lines beginning `not ok`: 0

BaselineLocalTestTotal: 390

Output Summary: The full local bats stage passed with exit code 0. The TAP plan line is
`1..390`, 390 lines begin `ok`, and 0 lines begin `not ok`; the `ok` count equals the plan
line's upper bound. The stage did not print `bats not installed; skipping shell tests.`, so
this is a real run rather than the skip path.

The observed local total of 390 equals the figure the CI run at `ad6bc946` reported. The CI
figure is recorded for comparison only and is not asserted, because the local stage and the
CI stage can enumerate different suites; here they agree, so there is no difference to
record.

The run emitted four `BW01` bats warnings from
`tests/shell/test_shell_qc_commands.bats`, each reporting that a deliberately-nonexistent
tool path under a `SHELL_QC_<TOOL>_BIN` override exited 127. These are the intended inputs
of the missing-tool tests; they are advisory bats warnings, not test failures, and every
affected test reports `ok`.

`BaselineLocalTestTotal: 390` is the value P8-T3 measures its delta against.
