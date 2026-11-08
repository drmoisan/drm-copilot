# Preflight Fixes - docs-page-quality-checker (1021), round 1

Timestamp: 2026-10-31T04-28
Plan: docs/features/active/2026-10-30-docs-page-quality-checker-1021/plan.2026-10-30T16-13.md

Single-pass preflight (preparation mode). Each entry below is a trivial in-place fix to task text or plan preamble. No task was added, removed, reordered, or checked.

## Fix 1 - Required References (preamble)

- Defect class: citation correction (stale reference set).
- Change: added the epic headings `### Generator contracts from the PowerShell preparation of 1024 (binding)` and `### Enforcement notes from the two preparations of 1034`, which were added to the epic after the plan was written, to the list of epic headings the plan honors.

## Fix 2 - Execution Context, read-only line (preamble)

- Defect class: internal inconsistency in prose; meaning unchanged.
- Change: the read-only exception now also names the 1020 suites updated for the dispositions recorded in [P0-T3], which [P1-T3], [P4-T3], and [P4-T5] edit.

## Fix 3 - [P0-T3]

- Defect class: validator-blind class (changed existing behavior without a complete asserting-test search).
- Change: the search list now also covers `Invoke-DocsInitCommand`, the `init` command name in `Invoke-DocsCommandCli` calls, and the in-memory write-log assertions of `init` tests, because [P4-T5] changes the planned writes and write log of 1020 `init` and those assertions do not necessarily name `planned_writes` or `Get-DocsInitTemplate`.

## Fix 4 - [P1-T4]

- Defect class: asserted literal corrected to the upstream contract value; asserted property unchanged.
- Change: the composed `audience` item pattern is asserted equal to the 1020 docs common `audience-id` pattern (the epic pattern plus the trailing guard that CR-1 permits), or to the local `$defs/audience-id` pattern when CR-1 is recorded as not accepted. The 1020 spec and plan store the pattern with the guard, so an equality assertion against the unguarded literal could not pass. For strings without a newline the two patterns accept the same set (1020 spec `### Docs common $defs`).

## Fix 5 - [P2-T3]

- Defect class: test-scope clarification; assertion unchanged.
- Change: the `Test-Json` mock is placed in the `DocsSchema` module scope, where `Test-DocsArtifactText` calls it. A mock in the `DocsPageFrontMatter` scope would not intercept that call.

## Fix 6 - [P3-T2]

- Defect class: module-visibility (epic `### Enforcement notes from the two preparations of 1034`).
- Change: when CR-8 is accepted and the 1020 matcher replaces `Test-DocsPagePathMatch`, `DocsPageDiataxis.psm1` also imports the 1020 module that exports the matcher (within the allowed import set), since a function is callable only from a module that imports its exporting module.

## Validator

- Command: poetry run python scripts/dev_tools/validate_orchestration_artifacts.py plan docs/features/active/2026-10-30-docs-page-quality-checker-1021/plan.2026-10-30T16-13.md
- Result before fixes: exit 0. Result after fixes: recorded in the preflight return.
