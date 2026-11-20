# AC-F3 — Substantively Delivered, Atomicity Clause Deviated

Timestamp: 2026-08-18T13-05
Command: `git log --oneline -1 -- <path>` per file; `git show 40db8ecc:tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1`
EXIT_CODE: 0

## AC-F3 as written

> The committed-truth-table and location-bucket Describe blocks in `BlastRadius.Parity.Tests.ps1`
> (lines 302-436 pre-change), and any behavior-matrix case naming a removed module, are amended
> **in the same commit as the config change** and pass under Pester.

## What was delivered (verified)

- The `Committed blast-radius truth table shape` Describe is no longer in
  `BlastRadius.Parity.Tests.ps1` (grep count 0) — relocated per Design Determination 6.
- `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` exists and carries the
  amended content, including a negative pin asserting that none of the five removed modules
  (`python-dev-tools`, `vscode-extension`, `claude-runtime`, `copilot-surface`, `agents-surface`)
  appear in `$script:CommittedConfig['modules'].Keys`, with the removal rationale recorded inline.
- Comparison is ordinal (`-ccontains`), matching the case-sensitive semantics of the Python reference.
- Passes under Pester: `poshqc / PowerShell QC` is green in CI at head `7083734f`.

## Deviation (not met as written)

The amendment did NOT land in the same commit as the config change:

| Artifact | Landing commit |
| --- | --- |
| `config/blast-radius.json` (module map reduced to seven) | `40db8ecc` |
| `BlastRadius.TruthTable.Tests.ps1` (amended truth table) | `b0277bdb` |

`BlastRadius.TruthTable.Tests.ps1` was ABSENT at `40db8ecc` (verified by `git show`). The old
Describe in `BlastRadius.Parity.Tests.ps1` was therefore still asserting the twelve-module map
against a seven-module config at that commit, so the PowerShell suite was red at `40db8ecc` and
green again from `b0277bdb` onward.

## Disposition

The clause exists to prevent exactly that red intermediate state, and it was violated. The impact is
confined to one intermediate commit on the feature branch: CI gates the PR head SHA, which is green
across all 11 required checks, and the branch merges as a unit.

The only remedies are to accept the deviation or to rewrite already-pushed history to reorder two
commits. Rewriting pushed history to satisfy a sequencing clause on an otherwise-green PR is
disproportionate to the harm, so the deviation is RECORDED here rather than silently checked off or
silently corrected. AC-F3 is marked delivered on the strength of the substantive requirement, with
this artifact as the qualifying record.
