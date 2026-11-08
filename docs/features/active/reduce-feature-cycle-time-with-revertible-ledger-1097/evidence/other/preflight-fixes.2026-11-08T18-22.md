# Preflight Fixes - Stage I Remediation Cycle 1 (F1)

Timestamp: 2026-11-08T18-22
Plan: docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/remediation-plan.2026-11-08T18-06.md
Command: single-pass preflight; branch-current validator `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan>` (VIRTUAL_ENV set to the shared environment) before and after the fixes; trial merge with `git merge-tree --write-tree` of HEAD and origin/main and a scratch prototype of the pre-0010 derivation (sh scripts under SCRATCH, no worktree change)
EXIT_CODE: 0
Output Summary:
  Validator: plan validation passed before and after the fixes.
  Trial merge: content conflicts in exactly the seven files F1 names, one hunk each.
  0010 patch index lines carry abbreviated (9-character) blob ids; every pre-image id resolves with `git cat-file -e`.
  Branch diff from the merge base over the 0010 paths has the same `+`/`-` line multiset as the stored 0010 patch.
  Prototype of the pre-0010 derivation: `git merge-file` exits 0 on 7 of the 14 paths that both 0010 and main change (each result equals the origin/main blob) and conflicts on 7 (both epic-run skills and their bundle copies, the epic agent and its bundle copy, the pin file); for all 14 the 0010 pre-image equals the merge-base blob.
  Five trivial fixes made in task text and preamble; no task added, removed, or reordered; no acceptance meaning changed.

## Fixes

1. `### Design Decision` (pre-0010 merged state) and [P3-T1] - unsatisfiable procedure clause. [P3-T1] said a `git merge-file` conflict outside the pin file "is returned as a finding", but the derivation conflicts on six further paths. Because each such path's 0010 pre-image equals its merge-base blob, the branch changed it only through 0010 and its pre-0010 text is its origin/main blob; the Design Decision already defines the pin file's pre-0010 text the same way (main's paragraphs and main's digests, which equal the SHA-256 of main's surfaces). Added that rule to both places; a conflicted path whose pre-image differs from its merge-base blob is still returned as a finding. The [P3-T1] acceptance is unchanged.
2. [P1-T1] conflict-marker acceptance - unsatisfiable search scope. A repository-wide `git grep` for `^<<<<<<< ` and `^>>>>>>> ` matches tracked merge-conflict fixtures under `tests/fixtures/project_file_merge/` and two archived feature documents on both HEAD and origin/main. Scoped the search to the seven conflicted paths, which is the set the merge can leave markers in.
3. [P1-T1] line-presence acceptance - self-contradiction. The check required every `+` line of the 0010 pin-file section in the merged file, while the same task takes main's digest values until [P2-T3]. Excluded the two stage I digest `+` lines of the pin file.
4. [P3-T3] gate (e) - unsatisfiable tree-id equality. The [P3-T1] tree is built before [P3-T2] edits the 0010 entry and patch, so a whole-tree id comparison after [P3-T2] cannot match. Restated as equality of the two trees on every path of the patch (`git diff --quiet` over those paths exits 0).
5. [P5-T1] format acceptance - asserted value not printed. `Invoke-PoshQCFormat` prints `Already formatted: <path>` for a clean file and `Formatted: <path>` only for a rewritten file (`PoshQC.Analyzer.psm1`), so `Formatted: 0` is never printed. Restated as `Already formatted:` for every file and no `Formatted:` line (files needing format: 0).
