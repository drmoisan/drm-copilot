# Code Review: legacy-discovery-init-templates (#362) — R4 Re-Review, Remediation Cycle 2

**Template source note:** MCP template resolution is unavailable in this session; the canonical repository template `docs/features/templates/policy_audit/code-review.yyyy-MM-ddTHH-mm.md` was used as the authoritative structure source.

**Review Date:** 2026-07-18
**Reviewer:** feature-review agent (independent verification, not accepted from executor self-report)
**Feature Folder:** `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/`
**Feature Folder Selection Rule:** Only active feature folder whose suffix (`-362`) matches the branch name's issue number.
**Base Branch:** `epic/legacy-discovery-and-parity-integration` (merge-base `85e7bea2bd2695114c9feffb2a4963da9f37c9ad`)
**Head Branch:** `feature/legacy-discovery-init-templates-362` (HEAD `48939e3e3f551dcf45465aa9be06560f86db65b5`)
**Review Type:** Post-remediation re-review (R4, remediation cycle 2 — merge-conflict resolution with the integration branch)

---

## Executive Summary

This cycle-2 re-review covers a merge commit (`afab4468`) that resolves a `pyproject.toml` conflict between this feature branch and the current tip of `epic/legacy-discovery-and-parity-integration`, plus two follow-on documentation commits. The feature's own production code (`scripts/dev_tools/discovery/init_cli.py`, `init_flow.py`, `init_models.py`, and a one-line docstring change to `__init__.py`) is unchanged in content by the merge — it is byte-identical to the code reviewed in the cycle-1 re-review (`code-review.2026-07-18T12-56.md`). The review scope for this cycle is therefore narrower in substance than cycle 1: verify the merge resolution itself, verify the full toolchain still passes at the new HEAD, and independently diagnose a test failure the executor attributes to an unrelated upstream defect.

**What changed:** One merge commit resolving an 8-line adjacent-insertion conflict in `[tool.poetry.scripts]` (both branches added a new `dev.discovery.*` console-script alias at the same insertion point), plus two documentation commits recording the cycle-2 evidence trail. No production Python file's content changed as part of this cycle.

**Top 3 risks:**
1. The merge inherits every sibling feature already fanned into the integration branch (#361, #364, #365, #375, #376, #377, #379), which is expected and correct, but also inherits any defects those sibling features carry — as materialized by the test failure discussed below.
2. `scripts/dev_tools/discovery/init_models.py`'s branch coverage (50%, 6/12) falls below the uniform 75% new-file threshold, though the shortfall is fully attributable to `Protocol` stub artifacts rather than untested behavior (see Findings Table).
3. `spec.md`'s `## Definition of Done` checklist remains entirely unchecked, which could mislead a future reader into thinking toolchain/docs work was not performed, even though it was.

**PR readiness recommendation:** **Conditional Go** — the merge resolution itself is correct and complete, and this feature's own code has no new defects. The one test failure at HEAD is independently confirmed to be a pre-existing defect in sibling feature #365 / the integration branch, reproducible with zero involvement from this feature's commits, and outside this feature's authorized remediation scope. Recommend proceeding to PR creation for this feature while separately tracking the bundled-payload push-down gap against feature #365 or the integration branch.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major (attributed to sibling feature #365, not this feature) | `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | `test_bundled_claude_payload_contains_all_repo_runtime_contracts` | Test fails at HEAD: four `.claude/agents/*.md` persona files (`legacy-parity-analyst.md`, `migration-coverage-reviewer.md`, `requirements-reconciler.md`, `runtime-characterization-analyst.md`) added by sibling feature #365 on the integration-branch tip are missing from the bundled `extensions/drm-copilot/resources/claude-customizations/.claude/agents/` payload. | Track and remediate against feature #365 or the integration branch (push the four files down into the bundled payload). Do not attempt to fix within this feature's plan — it does not name and was never authorized to touch that path. | The failure is reproducible on a clean checkout of the pure integration-branch tip (`85e7bea2`) with none of this feature's commits present, confirming it predates and is independent of this feature. | Independent re-run: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -v` in the worktree at `C:\Users\DanMoisan\repos\drm-copilot-wt\2026-07-17T10-10` (HEAD `85e7bea2`, clean tree) → `1 failed, 6 passed`, identical `AssertionError`. |
| Minor | `scripts/dev_tools/discovery/init_models.py` | Lines 13-23 (`FileSystem` `Protocol` stub methods) | Branch coverage for this new file is 50% (6/12), below the uniform 75% new-file threshold. All six uncovered branches are coverage.py's synthetic "exit" branch for a `...`-bodied `Protocol` stub method, which can never be executed by any caller. | Optional cleanup: extract the `FileSystem` `Protocol` into its own type-only module so it can be measured (and exempted) separately from the concrete `RealFileSystem`/constants/functions in this file, per the "Type-only / interface-only modules" carve-out in `general-unit-test.md`. Not required before merge. | The concrete implementation of the same contract (`RealFileSystem`) is 100% line-covered; no real behavior is untested. The identical structural pattern (Protocol + concrete implementation in one module) is present, uncorrected, in at least four pre-existing files in this codebase. | `artifacts/python/lcov.info` (this review's independent regeneration): `init_models.py` LF 32 LH 32 (100% line), BRF 12 BRH 6 (50% branch). |
| Info | `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/spec.md` | `## Definition of Done` (lines 403-413) | All six Definition-of-Done checkboxes remain `- [ ]` even though the underlying work (tests added, docs updated, toolchain run) has been completed and evidenced elsewhere in the feature folder. | Optional: check off the Definition of Done items to match the feature folder's actual evidence trail. Not an acceptance-criteria gap (this section is not an AC source under `full-feature` work mode). | Documentation completeness only; does not affect merge readiness. | Direct read of `spec.md` lines 403-413. |
| Info | `pyproject.toml` | `[tool.poetry.scripts]` lines 59-70 | Merge conflict resolution correctly preserves all 12 unique `dev.discovery.*` entries (this feature's own `dev.discovery.init` plus the 11 entries fanned in from sibling features via the integration branch), with no duplicates and no drops. | No action needed; recorded as positive confirmation. | Direct textual comparison across three refs (pre-merge feature tip, integration tip, merged HEAD) shows exact set-union preservation. | `git show 7610bf25:pyproject.toml`, `git show 85e7bea2:pyproject.toml`, `git show 48939e3e:pyproject.toml` — each `grep -n "dev.discovery"`. |

No Blocker findings attributable to this feature's own commits.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- The merge resolution is purely additive and mechanically correct: both sides' `dev.discovery.*` script entries are preserved, alphabetically re-sorted by the merge tool/editor, with no key collisions.
- This feature's own production code (`init_cli.py`, `init_flow.py`, `init_models.py`) is unchanged in content from the cycle-1 re-reviewed version: thin CLI wiring separated from pure orchestration (`init_flow.py` contains no `argparse`/`print` calls, per its own module docstring, independently confirmed by reading the file), which continues to satisfy the separation-of-concerns principle in `general-code-change.md`.
- `create_discovery_workspace` validates the full template set and the target path before writing any file (`validate_template_set` then `validate_target_path`, both before any `fs.ensure_dir`/`fs.write_text` call), correctly implementing the fail-fast acceptance criterion.

#### Typing and API notes

- `from __future__ import annotations` and a `Protocol`-based `FileSystem` contract are used consistently; `pyright` strict mode reports 0 errors against these files (independently re-run).
- No new public Python API surface was added or changed by this cycle's merge commit itself; the public surface (`init_cli.main`, `init_flow.create_discovery_workspace`, the `FileSystem` protocol) is unchanged from cycle 1.

#### Error handling and logging

- `init_flow.py` raises specific, named exceptions (`FileNotFoundError`, `NotADirectoryError`, `FileExistsError`) with messages naming the offending path; `init_cli.py` catches exactly those four exception types (plus `ValueError`), prints to `stderr`, and exits via `SystemExit(1)` — no broad `except Exception` catch-all, consistent with the fail-fast/explicit-error-handling policy.

### JSON/YAML template review

- The seven `docs/discovery/templates/artifacts/*.template.json` files and `docs/discovery/templates/domain-profile/domain-profile.yaml` are unchanged by this cycle's merge; domain-neutrality and schema-conformance are independently re-verified as still passing (`test_domain_neutrality.py`, `test_generated_artifacts_conform_to_real_schemas`, both part of the 1782-passing set).

---

## Test Quality Audit

This review independently re-ran the full test suite and the failing test in isolation, and independently reproduced the failing test's exact scope and root cause on a separate worktree checked out at the pure integration-branch tip, rather than accepting the executor's self-reported diagnosis.

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/discovery/test_init_flow.py`, `test_init_cli.py`, `test_init_models.py`, `test_package_exports.py`, `test_domain_neutrality.py` — unchanged from cycle 1; re-verified passing at HEAD `48939e3e` as part of the 1782-passing set.
- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` — the sole failing test; independently confirmed to fail identically on a clean checkout of the integration-branch tip (`85e7bea2`), with none of this feature's commits present, ruling out any contribution from this feature.
- `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/qa-gates/r2c1-pytest.2026-07-18T17-25.md` (executor's self-reported evidence) — independently reproduced by this review, not merely re-read; figures matched exactly (1782 passed, 1 failed, 88.53% line / 79.34% branch).
- `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/qa-gates/r2c1-pr-mergeable-check.2026-07-18T17-25.md` — independently reproduced via `gh pr view 380 --json mergeable` → `{"mergeable":"MERGEABLE"}`.

### Quality assessment prompts

- **Determinism:** No real filesystem I/O, no network, no wall-clock dependency in the discovery test modules; the `FakeFileSystem` test double is fully in-memory. The failing upstream test is deterministic in its failure (reproduced twice, identically, in two separate worktrees).
- **Isolation:** Each discovery test targets one function or one CLI-level scenario; the failing upstream test targets a single contract assertion (bundled-payload parity) unrelated to this feature's own module set.
- **Speed:** Full 1783-test suite completes in 8.09s (independently timed).
- **Diagnostics:** The failing test's own assertion message names only the first missing file it encounters (`legacy-parity-analyst.md`); this review independently reimplemented the test's enumeration logic outside the test itself to compute the full missing-file set (4 files, 0 content-diffs), which the test's own failure message does not surface.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No credentials, tokens, or connection strings in any file changed by this feature or this cycle's merge commit. |
| No unsafe subprocess or command construction | ✅ PASS | `init_cli.py`/`init_flow.py` contain no `subprocess` or shell-invocation calls. |
| Input validation at boundaries | ✅ PASS | `validate_template_set`/`validate_target_path` validate the target path and template root before any write. |
| Error handling remains explicit | ✅ PASS | Specific exception types raised and caught; no silent swallowing. |
| Configuration / path handling is safe | ✅ PASS | All paths are constructed via `pathlib.Path` joins against caller-supplied or `Path(__file__).resolve()`-derived roots; no string-concatenation path building. |
| Merge conflict resolution correctness (`pyproject.toml`) | ✅ PASS | Independently verified set-union preservation across three refs; `poetry check` exits 0 with only pre-existing, unrelated deprecation warnings; no residual conflict markers. |

---

## Research Log

No external research was required. All findings were derived from direct repository inspection (`git show`, `git diff`, `git log`), independent toolchain re-execution (`black`, `ruff`, `pyright`, `pytest --cov`), independent re-implementation of the failing test's enumeration logic, and reproduction in a second worktree checked out at the integration-branch tip.

---

## Verdict

This feature's own production code and tests are unchanged in substance by the cycle-2 merge and remain fully compliant with the general and Python-specific code-change and unit-test policies, matching the cycle-1 re-review's conclusions. The merge commit itself correctly and completely resolves the `pyproject.toml` conflict with no dropped or duplicated entries, and PR #380 is independently confirmed `MERGEABLE`. The single failing test at HEAD is independently confirmed, through an out-of-branch reproduction, to be a pre-existing defect on the integration branch's own tip introduced by sibling feature #365, not by this feature — it is not a regression this feature caused and not a defect this feature's plan is authorized to fix. The `init_models.py` branch-coverage shortfall is a non-blocking measurement artifact of a `Protocol` stub pattern already pervasive in this codebase. This change is ready for normal PR flow; the bundled-payload push-down gap should be opened as a separate issue/remediation cycle against feature #365 or the integration branch.
