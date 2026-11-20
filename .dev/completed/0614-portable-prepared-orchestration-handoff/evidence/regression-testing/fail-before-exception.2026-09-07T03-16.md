# Fail-Before Exception Dossier — [P0-T7]

Timestamp: 2026-09-07T11-06
Task: [P0-T7]
Head: fca8c0455dd7207b21096e70fe7ffbf8cfc56ca1

Command: `Get-ChildItem docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/regression-testing` and a name search for `fail-before-exception.*.md` over that folder
EXIT_CODE: 0

## Negative-evidence record for the prior search

SearchScope: `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/regression-testing/`
SearchPatterns: `fail-before-exception.*.md`
SearchResult: none prior to this task. After this task the folder contains `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/regression-testing/fail-before-exception.2026-09-07T03-16.md`, which is this file. The feature is not versioned, so the feature-root evidence tree searched above is the only scope; no `v1/`, `v2/` sub-tree exists.

## WhyFailingRunImpossible

Two CI legs failed at head `fca8c0455dd7207b21096e70fe7ffbf8cfc56ca1`, and neither can be reproduced as a local failing run.

**Leg 1 — `poshqc / PowerShell QC`.** The six byte-identity cases in `tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1` read `artifacts/orchestration/orchestrator-state.json`, which `/artifacts` in `.gitignore` line 6 excludes from the repository. The failure therefore occurs only in a checkout where that file is absent. Reproducing it locally would require renaming or deleting the live orchestration checkpoint, which is the file the running orchestration reads and writes; removing it is prohibited. The failure mode is a `DirectoryNotFoundException` raised by the byte read, which is a checkout-state property rather than a property of the test logic.

**Leg 2 — both `ubuntu-latest` TypeScript jobs.** The five failing suites fail because `path.isAbsolute("C:/workspace")` returns `false` on POSIX, so the four production absolute-path predicates reject the Windows drive-letter literal. Reproducing this requires a POSIX Node runtime. The WSL Ubuntu installation on this machine carries no Node runtime, so no local POSIX Jest execution is available. CI is the verification path for this leg.

## Substitute red proofs executed locally by this plan

This plan executes three local proofs in place of the two unavailable failing runs. Each is a falsifiable observation taken before the corresponding fix.

1. **[P1-T2]** `[expect-fail]` — a new derivation test asserting the scenario workspace root is `path.resolve("virtual-workspace")` and that every registered fake-filesystem key sits under it. It is run before [P1-T3] substitutes the derived root, so it fails with the drive-letter literal as the received value. Expected exit code 1. Evidence: `ci-614-002-scenario-root-red.2026-09-07T03-16.md`.
2. **[P1-T6]** — the falsifiable pre-state literal inventory over the three files added to scope by the 2026-09-07 amendment, recording 86 matching lines that [P1-T13] drives to 0. Evidence: `ci-614-002-mcp-literal-red.2026-09-07T03-16.md`.
3. **[P1-T14]** `[expect-fail]` — the retargeted Pester file is run before [P1-T15] creates the fixture, so the outer `BeforeAll` guard throws and names the missing fixture path. Expected exit code 1. Evidence: `ci-614-001-fixture-red.2026-09-07T03-16.md`.

Output Summary: No failing local run is producible for either CI leg. Leg 1 requires deleting the live gitignored orchestration checkpoint, which is prohibited; leg 2 requires a POSIX Node runtime, which this machine does not provide. Three substitute red proofs are executed locally instead, at [P1-T2], [P1-T6], and [P1-T14], two of them tagged `[expect-fail]` with `ExpectedExitCode: 1`. A prior search of the canonical regression-testing folder for `fail-before-exception.*.md` returned none; this dossier is the first.
