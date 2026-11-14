# Preflight Fixes: Issue 1097, Stage A

Timestamp: 2026-11-07T03-10
Plan: docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/plan.2026-11-06T21-23.md

Each entry is a task-text or preamble edit. No task was added, removed, or reordered.

## Fixes

1. [P3-T2] | stale anchor | The coverage read named the class-level `LINE` counter and the `sourcefilename` attribute. `Merge-PoshQCCoverageReport` removes every `class` element from the merged report (pinned by `CM08-MERGE-OMITS-CLASS-AND-METHOD-FIGURES`), so that read has no source after a parallel run. The task now reads the `LINE` counter of the `sourcefile` element named `ProcessReductionLedger.psm1`, which the merge recomputes. The 85% module threshold is unchanged.
2. `## Pre-Mortem`, `Coverage` bullet | stale anchor | The same counter reference was changed to the `sourcefile` level.
3. `## Pre-Mortem`, `Evidence` bullet | stale anchor | "absolute class names" was changed to "absolute package names", because the merged report keeps package elements and holds no class element.
4. [P1-T1] | spec wording omission | `spec.md` `## Behavior` joins the generator `--check` to the Codex-variant step. The six labels and every test are unchanged; the README text now states that the `Regenerate Codex variants` step includes the generator `--check`.
5. `## Pre-Mortem`, `File size` bullet | scope wording | The conditional split file was not reflected in the later references to the test file. The bullet now states that the split file joins [P3-T1], the [P3-T2] suite count, and the [P3-T4] scope row.
