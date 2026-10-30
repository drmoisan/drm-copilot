# Preflight Fixes (Round 2)

Timestamp: 2026-10-30T21-37
Plan: docs/features/active/2026-10-30-docs-surface-analyzers-python-config-1022/plan.2026-10-30T16-46.md

## Fix 1 — [P6-T7]

- Defect class: literal-formatting defect that does not change what is asserted (diff anchor state).
- Finding: the analyzer-contract and `pyproject.toml` numstat and full-diff commands compared `MERGE_BASE` with `HEAD`. The plan has no commit task before [P6-T7], so with uncommitted edits those commands print no row and the `1` added / `0` deleted assertion for each `pyproject.toml` could not be met.
- Change: both commands now compare the working tree with `MERGE_BASE` (`git diff --numstat MERGE_BASE -- ...` and `git diff MERGE_BASE -- PKG/analyzer_contract.py`), consistent with [P5-T1], so they report the edits in both the committed and the uncommitted state. The asserted counts are unchanged. The discovery-path check keeps its `MERGE_BASE HEAD` diff paired with `git status --porcelain`, which already covers both states.

## Fix 2 — [P0-T2]

- Defect class: ambiguous symbol reference whose intent is unambiguous.
- Finding: the registry-form inspection referred to "the `ANALYZER_REGISTRY` assignment". #1020 declares `ANALYZER_REGISTRY: tuple[AnalyzerRegistration, ...] = ()`, which parses as `ast.AnnAssign`, not `ast.Assign`; a helper that searches only `ast.Assign` nodes would report a `MISSING` failure on a correct #1020 delivery.
- Change: the task text now names the module-level binding as an `ast.AnnAssign` or an `ast.Assign`. The asserted `REGISTRY-FORM:` values and their conditions are unchanged.
