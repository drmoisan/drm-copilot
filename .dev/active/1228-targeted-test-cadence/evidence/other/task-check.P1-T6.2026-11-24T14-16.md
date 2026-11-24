# Task Check - [P1-T6] - Issue #1228, remediation cycle 2

Timestamp: 2026-11-24T14-16
Plan: remediation-plan.2026-11-24T10-50.md
Kind: task check (not a gate; no coverage measured; not coverage evidence)
Command: Edit-tool edits of `.dev/active/1228-targeted-test-cadence/spec.md`; `grep -c "^- \[x\] AC-"` and `grep -c "^- \[ \] AC-"` of the spec; `grep -o "^| D[0-9]*"` of the spec; `git diff -U0 -- .dev/active/1228-targeted-test-cadence/spec.md` filtered to checkbox lines; `git grep -l "targeted-test-cadence/spec.md" -- tests`
EXIT_CODE: 0
Output Summary:
- Changed file: `.dev/active/1228-targeted-test-cadence/spec.md` (Markdown in the feature folder).
- Edits: `## Overview` now names the feature-review coverage hook, its Codex twin, and the launcher's run-scope record (D11) as the only non-wording changes; D3 states that the hook grades a local report as repository-wide only when no covering `selection` record exists, with the rationale that the earlier text accounted for the freshness hook but not the metrics check (finding F3, remediation cycle 2, autonomous mode); D11 records RD1 and RD2 (mechanism, rejected alternatives, fail-safe direction, CI unchanged); `## Data & State` names the record as the one new runtime file; the `## Out of Scope` hooks line excludes validators and every hook other than the two coverage hooks and their freshness twin; `## Implementation Strategy` gains the D11 bullet; unchecked `AC-20` and `AC-21` are added; `Version` 0.2 to 0.3 and `Last Updated` 2026-11-24.
- Consistency edits in the same file and decision (recorded here): the `New classes, functions, or commands: none.` bullet of `## Implementation Strategy` now reads `only the D11 functions above.`, and the first sentence of `## API / CLI Surface` now names the D11 run-scope record as the one new file format, because both sentences were otherwise contradicted by D11.
- Acceptance: 19 checked `AC-` items (AC-01 to AC-19, text and state unchanged; the diff adds no `-` checkbox line) and 2 unchecked (`AC-20`, `AC-21`); the `## Design Decisions` table holds D1 to D11.
- Static: none applies (Markdown).
- Selection and rule: contract tests that read the changed path; `git grep -l "targeted-test-cadence/spec.md" -- tests` returns no file, so the selection is empty and no suite runs ("no selected tests"). `ProcessReductionChain.Ledger.Tests.ps1` does not read the feature folder (excluded from the ledger set by the entry's derivation).
- Result: PASS.
