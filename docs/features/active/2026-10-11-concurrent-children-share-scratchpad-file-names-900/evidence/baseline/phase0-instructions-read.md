# Phase 0 Instructions Read

Timestamp: 2026-10-12T17-22

Policy Order:
1. `CLAUDE.md` (P0-T1)
2. `.claude/rules/general-code-change.md` (P0-T2)
3. `.claude/rules/general-unit-test.md` (P0-T3)
4. `.claude/rules/python.md` (P0-T4)
5. `.claude/rules/python-suppressions.md` (P0-T5)
6. `.claude/rules/powershell.md` (P0-T6)

Files read (P0-T1 through P0-T8), all read in full:
1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/python.md`
5. `.claude/rules/python-suppressions.md`
6. `.claude/rules/powershell.md`
7. `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/issue.md` (with a Glob of `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/*.md`)
8. `docs/features/active/2026-10-11-concurrent-children-share-scratchpad-file-names-900/research/scratch-file-naming.2026-10-11T10-45.md`

Notes recorded from the reads:
- general-code-change: 500-line file limit; seven-stage toolchain loop with restart on failure or auto-fix; temporary files in tests are prohibited.
- general-unit-test: line >= 85% and branch >= 75% defaults; no coverage regression on changed lines; tests live under `tests/` mirroring the source tree.
- python: `poetry run black`, `poetry run ruff check`, `poetry run pyright`, `poetry run pytest --cov --cov-branch --cov-report=term-missing`.
- python-suppressions: the new test module carries no `noqa` or `type: ignore` comment.
- powershell: Pester runs through `mcp__drm-copilot__run_poshqc_test`; no PowerShell file is edited by this plan.
- issue.md: `- Work Mode: minor-audit`; `## Acceptance Criteria` has 11 unchecked `- [ ]` items; the Glob listed only `issue.md` and the plan, so no `spec.md` and no `user-story.md` exist.
- research: `## Recommended Change Set` lists 8 edits and 1 new file, matching the plan's "Fixed names used below" list.
