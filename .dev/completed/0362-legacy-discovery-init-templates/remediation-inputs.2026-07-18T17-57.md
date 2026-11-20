# Remediation Inputs — legacy-discovery-init-templates (#362) — R4 Re-Audit, Remediation Cycle 2

- Timestamp: 2026-07-18T17-57
- Feature branch: `feature/legacy-discovery-init-templates-362` (HEAD `48939e3e3f551dcf45465aa9be06560f86db65b5`)
- Base branch: `epic/legacy-discovery-and-parity-integration` (merge-base `85e7bea2bd2695114c9feffb2a4963da9f37c9ad`)
- Trigger: `poetry run pytest --cov --cov-branch --cov-report=term-missing` exits 1 at HEAD (1 failed test), which is a literal "toolchain checks fail" remediation trigger under `feature-review-workflow`. This document exists to satisfy that trigger with a complete, evidence-backed finding record — **not** because a cycle 3 within this feature's own remediation loop is the correct or possible remedy (see "Recommended Disposition" below).
- Related artifacts: `policy-audit.2026-07-18T17-57.md`, `code-review.2026-07-18T17-57.md`, `feature-audit.2026-07-18T17-57.md` (all produced by this same audit pass).

## Finding R1 — Bundled `.claude` payload missing four sibling-feature persona files (Blocking, attributed to sibling feature #365 / integration branch, not to this feature)

- **Severity:** Blocking, as a merge-readiness gate for `epic/legacy-discovery-and-parity-integration` overall. **Not attributable to and not remediable within `feature/legacy-discovery-init-templates-362`'s own scope.**
- **Failing test:** `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
- **Failure message:** `AssertionError: Repo file missing from bundle: .claude\agents\legacy-parity-analyst.md`
- **Independently confirmed full scope (not just the single file named in the test's own failure message):**
  ```
  MISSING COUNT: 4
   - .claude\agents\legacy-parity-analyst.md
   - .claude\agents\migration-coverage-reviewer.md
   - .claude\agents\requirements-reconciler.md
   - .claude\agents\runtime-characterization-analyst.md
  CONTENT-DIFF COUNT: 0
  ```
  Computed by reimplementing the test's own `list_scoped_files`/`_is_agent_memory_path` enumeration logic independently and diffing the full repo `.claude/**` tree against `extensions/drm-copilot/resources/claude-customizations/.claude/**` at HEAD. No other bundled-payload gap exists; every other file present in both trees is byte-identical.
- **Root cause (independently confirmed, not accepted from executor self-report alone):** sibling feature #365 (`feat(agents): add four domain-neutral agent personas for legacy-discovery`, commit `5335075c`) added the four files above to `.claude/agents/` on `epic/legacy-discovery-and-parity-integration`'s own tip without a corresponding push-down copy into the bundled payload.
- **Independent reproduction on the pure integration-branch tip, with zero involvement of this feature's commits:** a clean worktree at `C:\Users\DanMoisan\repos\drm-copilot-wt\2026-07-17T10-10`, checked out at `85e7bea2bd2695114c9feffb2a4963da9f37c9ad` (the exact integration-branch tip / this feature's merge-base), reproduces the identical failure: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -v` → `1 failed, 6 passed`, identical `AssertionError`. This branch's own commits do not add, modify, or reference any of the four files (confirmed via `git diff 85e7bea2 HEAD -- .claude/agents/` returning empty from this feature's side of the merge tree, and the files being absent from the pre-merge feature tip `7610bf25`).
- **Required fix (out of this feature's authorized scope):** copy the four files into `extensions/drm-copilot/resources/claude-customizations/.claude/agents/` so the bundled payload mirrors the repo `.claude/agents/` tree, then re-run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` to confirm the fix.
- **Why this is not a cycle-3 task for this feature:** this feature's plan (`plan.2026-07-17T14-05.md`, `remediation-plan.2026-07-18T13-00.md`, `remediation-plan.2026-07-18T15-35.md`) names only `scripts/dev_tools/discovery/**`, `docs/discovery/templates/**`, and `pyproject.toml` as in-scope paths. Editing `extensions/drm-copilot/resources/claude-customizations/.claude/agents/` is outside every one of this feature's plan documents and was never authorized. The defect belongs to sibling feature #365's own delivery, or to the integration branch's fan-in process for #365, and should be tracked and remediated there — most likely as a new issue against #365, or as a direct fix committed to the integration branch by whichever agent owns #365's fan-in.

## Finding R2 — `init_models.py` branch coverage below the uniform 75% new-file threshold (non-blocking)

- **Severity:** Non-blocking observation.
- **File:** `scripts/dev_tools/discovery/init_models.py`
- **Measurement:** 100% line coverage (32/32), 50% branch coverage (6/12), independently parsed from `artifacts/python/lcov.info` after an independent `poetry run pytest --cov --cov-branch --cov-report=term-missing` run at HEAD.
- **Root cause:** the six uncovered branches correspond one-to-one to the six abstract stub methods on the `FileSystem` `typing.Protocol` (`exists`, `is_dir`, `list_dir`, `ensure_dir`, `read_text`, `write_text`; lines 13-23), each with a `...` body that coverage.py registers as an unreachable synthetic "exit" branch. The concrete implementation of the same contract (`RealFileSystem`) is 100% line-covered.
- **Precedent:** this exact structural pattern (a `Protocol` mixed with its concrete implementation in one module) is present, uncorrected, in at least four other pre-existing files in this codebase (`new_active_feature_folder_models.py`, `copy_research_to_issue.py`, `new_potential_bug_entry.py`, `potential_to_issue.py`).
- **No automated gate trips on this:** `[tool.pytest.ini_options]`/`[tool.coverage.report]` in `pyproject.toml` configure no `--cov-fail-under`, so this finding did not cause any toolchain command to exit non-zero on its own.
- **Recommended (optional) remediation:** extract the `FileSystem` `Protocol` into its own type-only module, which would then legitimately report 0% executable coverage and qualify for the "Type-only / interface-only modules" carve-out in `general-unit-test.md`, isolating the concrete `RealFileSystem`/constants/functions in a fully-measured module. Not required before this feature's PR merges.

## Recommended Disposition

**Exit this feature's remediation loop and proceed to PR creation for #362.** Rationale:

1. R1 (the only Blocking finding) is independently confirmed to be a defect entirely attributable to sibling feature #365 / the integration branch's own tip, reproducible with zero involvement from this feature's commits, and outside every one of this feature's plan documents' authorized scope across both remediation cycles. Opening a cycle 3 within this feature's remediation loop cannot resolve R1, because the fix requires edits to files this feature's plan does not name.
2. R2 is a non-blocking, narrowly-scoped coverage-measurement artifact with no associated untested behavior, and does not independently justify a further remediation cycle.
3. This feature's own acceptance criteria (8 of 8 in each of `spec.md`/`user-story.md`) are independently re-verified PASS against the current merged tree; PR #380 is independently confirmed `MERGEABLE`; the `pyproject.toml` conflict resolution is independently confirmed complete and correct with no dropped or duplicated entries.

**Separately, outside this feature's remediation loop:** open a new issue or remediation cycle against sibling feature #365 (or the integration branch's fan-in process) to push the four missing `.claude/agents/*.md` persona files down into `extensions/drm-copilot/resources/claude-customizations/.claude/agents/`, so `test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes on the integration branch's own tip independent of this feature.
