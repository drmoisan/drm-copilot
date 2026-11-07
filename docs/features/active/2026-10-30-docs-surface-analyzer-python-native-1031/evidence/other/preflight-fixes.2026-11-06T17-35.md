# Preflight Fixes - remediation cycle 1, revision preflight R2 (issue #1031)

Timestamp: 2026-11-06T17-35
Plan: docs/features/active/2026-10-30-docs-surface-analyzer-python-native-1031/remediation-plan.2026-11-05T23-18.md
Signal: PREFLIGHT: REVISIONS REQUIRED (one substantive defect, [P6-T4], is returned; these three fixes are trivial)

## Fix 1 - `## Execution Context`, commit tasks

- Defect class: literal defect in a commit file set (task-ordering observation; the condition is unchanged).
- Observation: each commit task names a file set that omits this plan file, while its condition requires `git status --porcelain` to print nothing. The plan file holds check-offs at every commit task, and it holds the uncommitted revision plus this record at [P0-T10].
- Change: one preamble bullet states that every commit task also stages this plan file and any uncommitted preflight record, and where a commit task's own check-off travels.

## Fix 2 - [P6-T14], `Invoke-PoshQCParallelTest` scope

- Defect class: tool-shape correction; the assertion of 0 failed over `TESTS` is unchanged.
- Observation: `Invoke-PoshQCParallelTest` in `scripts/powershell/PoshQC/PoshQC.Parallel.psm1` has `-Root` and `-WorkerCount` plus seams and no path parameter, on `HEAD` and on the trial merge tree, so a run "over `TESTS`" cannot be requested. `Invoke-PoshQCParallelMerge` writes no merged artifact when a shard exits non-zero; each shard writes `pester-junit.xml` under `artifacts/pester/parallel/shard-<n>/`.
- Change: the task states the run covers the whole configured scan set; the condition reads 0 failed for test files under `TESTS` from the merged or per-shard JUnit files, and failures outside `TESTS` are listed by name as in [P6-T8].

## Fix 3 - [P6-T19], cycle start

- Defect class: executor-selected evidence made mechanical; the scan and its condition are unchanged.
- Observation: "the cycle start" had no derivation. A case-insensitive search of the whole feature folder for both forbidden tokens returned no match, so the choice does not affect the result today.
- Change: the cycle start is the first parent of the commit that added this plan file.

## Checked and not changed

- Trial merge: `git merge-tree --write-tree HEAD origin/epic/documentation-estate-tooling-integration` is clean, 173 integration commits, with the one overlapping path `pack-manifests/core.json` merging without conflict. The integration branch does not yet carry the tokenizer fix: the fix branch holds only a documentation commit at this time, so the `## Sequencing` precondition is open.
- [P6-T3]: `[tool.pyright] include` holds `tests` and `.claude/lib/docs/python` and no mirror path, and `exclude` is explicit, so baseline plus 12 and the path-scoped 18 hold.
- `_helper_trees`: `PYLIB.rglob("*.py")` counts `PYLIB` only; the chain 12, 13, 14, 15, 16, 18 matches the tasks. No `PYTESTS` file reads the mirror.
- [P4-T2]: `python.json` is unchanged by the integration branch and `source.py` is its last element, so 7 added and 1 deleted and the ordinal positions hold.
- [P6-T9]: none of the five files changes on the integration branch. Against the existing coverage file, no missed line falls on a changed line in any of the five.
- [P6-T18]: every path of the current branch diff matches a classification row; no `DocsPythonTokens` path, and no path under `.claude/hooks/`, `.claude/skills/`, `.claude/agents/` or `extensions/drm-copilot/src/`.
- [P0-T9] search on the trial merge tree: the set of files with a counted match equals the set on `HEAD`.
- Spec text: `PYTHON_NATIVE_UNAVAILABLE` (information, `docs-inventory`, null path), `DOCS_PYTHON_NATIVE_UNAVAILABLE` under `native`, the 1031 anchor and four rows, `DOCS_PROCESS_START_FAILED`, the `parent` key set and the file-set check match `.claude/lib/docs`. S4, S13, U4 and U13 are the expected lines and are checked. All named traceability tests exist.
- [P5-T1] and [P6-T20]: the three stale tokens occur only in sections being edited; no `- [` line lies in an edited section outside the four criteria; the amendments reach `HEAD` at [P5-T3], before [P6-T20].
- Host: Pester 6.2.0 is installed, which the merged `Invoke-PoshQCTest` requires. The new suites have not been run under Pester 6.2.0 on this branch; [P0-T6] is the first measurement.
