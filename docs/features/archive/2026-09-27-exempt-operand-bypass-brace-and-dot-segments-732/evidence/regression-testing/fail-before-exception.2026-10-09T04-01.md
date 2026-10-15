# Fail-before exception dossier: targets unit and parity suites (issue #738, recorded under issue #732)

Timestamp: 2026-10-09T04-01
Task: [P3-T7]
Command: git cat-file -e 497cb504ad9a4e5435dc8946333ebc28baea50c4:.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
EXIT_CODE: 128
ExpectedExitCode: 128

Suites covered:

- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1`

WhyFailingRunImpossible: The unit under test, `enforce-orchestration-preimplementation-gate-targets.ps1`, does not exist before Phase 4 ([P4-T2] creates it), so no row of either suite can execute against a pre-change implementation; a run before Phase 4 would fail at dot-source time for every row rather than on any behavioral assertion.

## Alternative proof (absence of the unit at BASE_SHA)

```text
$ git cat-file -e 497cb504ad9a4e5435dc8946333ebc28baea50c4:.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
fatal: path '.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1' does not exist in '497cb504ad9a4e5435dc8946333ebc28baea50c4'
EXIT_CODE: 128
```

BASE_SHA `497cb504ad9a4e5435dc8946333ebc28baea50c4` is the integration-branch SHA recorded in `evidence/baseline/p0-fetch.md`. The non-zero exit code shows the file is absent from the base tree, so the behavior both suites assert is new behavior with no pre-change implementation.

Output Summary: Fail-before run impossible for the two section-5.7 suites; `git cat-file -e` on the targets file at BASE_SHA exits 128 (path does not exist).
