# Preflight fixes — remediation plan cycle 1 (issue 1161)

Timestamp: 2026-11-14T00-50
Plan: docs/features/active/2026-11-09-planner-worktree-removal-authorization-1161/remediation-plan.2026-11-14T00-34.md
Signal: PREFLIGHT: ALL CLEAR

## Fixes

1. [P1-T1] | literal-formatting defect (meaning unchanged) | The parenthetical for `recorded-at-byte-order-mark.json` held the literal byte-order-mark character (bytes EF BB BF) where the sibling entries hold JSON escape text (`\u001f`, `\u0085`). It is replaced with the six-character escape text `\ufeff`, which matches the sibling entries and the task's stated rule that fixtures are written with JSON `\u` escapes. The asserted fixture content is unchanged.

## Checks performed in the same pass

- Validators: the branch-current Python CLI (`validate_orchestration_artifacts` module, `plan` subcommand) exited 0 with `plan validation passed`; the MCP validator returned ok.
- Design check against `remediation-inputs.2026-11-14T00-34.md` (PA-1) and `spec.md` (`### Field shape (planner_worktrees[] entry)`, `### Validator error strings`, D11): each required change maps to a task (shared class: P1-T3, P1-T4; spec wording: P1-T5; three named fixtures plus the ASCII-control row: P1-T1; dispositions: plan section `## Existing Test Dispositions (recorded_at behavior)`; 100% line coverage: P2-T3, P2-T4; criterion 1 re-check: P2-T7). The failing tests for each rule are the parametrized corpus rows `test_validator_reproduces_the_corpus_errors[...]` and `reproduces the expected errors for ...`.
- Fail-before probe on unchanged code (a scratch script under SCRATCH): Python `str.strip()` treats U+001F and U+0085 as blank and U+FEFF as non-blank; ECMAScript `trim()` treats U+FEFF as blank and U+001F and U+0085 as non-blank; the six-character RB-1 class gives the same result in both runtimes for every probed value. This matches the three failing rows that P1-T2 names.
- Dispositions: a search of `tests/` and `extensions/drm-copilot/test/` for `recorded_at`, `recordedAt`, the corpus directory, and the error string found no test outside the plan's dispositions that reaches either changed function.
- Scope: `origin/main` equals the merge base; no bundled or Codex mirror exists for either validator.
