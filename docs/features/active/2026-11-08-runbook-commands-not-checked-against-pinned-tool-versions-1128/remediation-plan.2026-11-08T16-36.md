# Remediation Plan — Issue #1128, Cycle 2 (CI failure, proportionate)

- Inputs: `docs/features/active/2026-11-08-runbook-commands-not-checked-against-pinned-tool-versions-1128/remediation-inputs.2026-11-08T16-36.md` (finding CI-1).
- FEATURE: `docs/features/active/2026-11-08-runbook-commands-not-checked-against-pinned-tool-versions-1128`.
- SCRATCH is `<session scratchpad>/issue-1128/`; scratch files start with `issue-1128-`.
- Poetry commands run as `env -u VIRTUAL_ENV poetry -C <worktree> run ...`; `poetry install` is never run (execution-environment skill, Worktree Python Environment).
- Each task ends with a commit and a push of the item branch `bug/runbook-command-version-check`.
- No PowerShell file changes in this cycle, so no Pester run applies.

### Phase 0 — Fail-before reproduction

- [x] [P0-T1] [expect-fail] Run `check_quality_tiers` (module `scripts.dev_tools.check_quality_tiers`) against the unchanged `quality-tiers.yml` and record it in `FEATURE/evidence/regression-testing/qt008-fail-before.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode: 1`, and `Output Summary:`. Acceptance: `EXIT_CODE: 1` and the summary names the diagnostic `QT008` for `.claude/lib/runbook`. Commit and push the artifact.

### Phase 1 — Add the tier entry

- [ ] [P1-T1] Edit `quality-tiers.yml`: insert a project entry with path `.claude/lib/runbook`, `tier: T3`, and rationale `Runtime library shipped in the `.claude` bundle` (the text the sibling `.claude/lib/*` entries carry) between the `.claude/lib/requirements` and `.claude/lib/worktree-resolution` entries, keeping the same key order and indentation as those siblings. Acceptance: `check_quality_tiers` exits 0, and `git grep -n -F ".claude/lib/runbook" -- quality-tiers.yml` returns one match. Tests asserting the file: search `tests/` for `quality-tiers.yml` and `check_quality_tiers` (including `tests/scripts/dev_tools/test_check_quality_tiers.py` if present); each reads synthetic in-memory manifests or the real file's validity only, so each is unchanged because unaffected. Commit and push.

### Phase 2 — Final gate (every step of `.github/workflows/_quality-checks.yml`)

- [ ] [P2-T1] Run the static steps against the head, in the workflow's order, each as its own artifact in `FEATURE/evidence/qa-gates/` named `black-check.<timestamp>.md`, `ruff.<timestamp>.md`, `pyright.<timestamp>.md`, `codex-generator-check.<timestamp>.md`, and `check-quality-tiers.<timestamp>.md`, each with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Commands are the ones the workflow step runs: Black in check mode, Ruff check, Pyright, `scripts.dev_tools.generate_codex_agent_variants` with `--check`, and `scripts.dev_tools.check_quality_tiers`. Acceptance: all five record `EXIT_CODE: 0`; Black's summary states the unchanged-files line it printed, and no tracked file differs from the pre-run tree (`git status --porcelain` empty). If any step fails or changes a file, fix it, restart this task from the Black step, and write new artifacts. Commit and push.
- [ ] [P2-T2] Run one `pytest -n auto` with `--cov-branch`, `--cov-report=term-missing`, and `--cov-report=json:` to `SCRATCH`, with the workflow step's `--cov=` dotted-module targets, once, and record `FEATURE/evidence/qa-gates/pytest-final.<timestamp>.md` with the four fields, the pass and fail counts, repo-wide line and branch coverage from the JSON report, and a comparison with the Phase 0 baseline in the lexicographically greatest `pytest-baseline.*.md` under `FEATURE/evidence/baseline/`. Acceptance: `EXIT_CODE: 0`, zero failures, no new failing test against the baseline, no repo-wide coverage drop, thresholds still met (85% line, 75% branch). Commit and push.
- [ ] [P2-T3] Walk the policy-audit, code-review, and feature-audit templates under `docs/features/templates/policy_audit/` against the branch diff from the merge base of `origin/main` and `HEAD` and write `FEATURE/evidence/qa-gates/self-review.<timestamp>.md` with one PASS, FAIL, or N/A row per checklist item. Acceptance: no FAIL row (a FAIL is fixed and P2-T1 and P2-T2 are re-run first). Commit and push.

## Pre-Mortem

- Review checklists: P2-T3 walks the three policy templates against the diff before the plan completes.
- Coverage: P2-T2 compares the single gate run with the main plan's Phase 0 pytest baseline; the cycle adds only a YAML entry, so no production Python line changes.
- Mirror parity: not applicable; `quality-tiers.yml` is not mirrored or bundled, and no CI job, required context, tool route, or batch-budget fact changes, so no execution-environment brief update is needed.
- File size: `quality-tiers.yml` gains three lines and is not a code file; no source file is touched.
- Test isolation: one `pytest -n auto` run (P2-T2), re-run only after a fix; no Pester or Jest run applies.
- CI-only behavior: the failure was a CI-only step the earlier gates skipped; P2-T1 and P2-T2 run every `_quality-checks.yml` step locally, including `check_quality_tiers`, with one artifact per step.
- Evidence: fail-before in `evidence/regression-testing/`, per-step artifacts in `evidence/qa-gates/`, each with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`; stamps are write-time UTC.
