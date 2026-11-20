# Code Review: local-preflight-orchestrator-state-gate (#272) — Remediation Cycle 2 Exit Re-Review

**Review Date:** 2026-07-02
**Reviewer:** feature-review (Claude Sonnet 5)
**Feature Folder:** `docs/features/active/2026-07-02-local-preflight-orchestrator-state-gate-272/`
**Feature Folder Selection Rule:** Caller-supplied; matches the issue number (#272) in the branch name and is the only active feature folder with material scoping-doc changes on this branch.
**Base Branch:** `main` (`origin/main @ 3c5ff3289022abc3b7b16e2441c772e5f81fd9ff`; merge-base `b1b55c3ddbb38c6f49a0e5e9d2c757ca70ae13f7`)
**Head Branch:** `bug/local-preflight-orchestrator-state-gate-272 @ a6626628dd35e98ed906aab084695a16cdbb9e49`
**Review Type:** Post-remediation re-review (remediation cycle 2 exit), full branch-vs-base diff (123 files), not scoped to the remediation plan's own file subset.

---

## Executive Summary

This branch replaces a non-functional CI-based orchestrator-state gate with a local `pwsh` PreToolUse hook preflight, then (remediation cycle 1) corroborates PowerShell coverage evidence and corrects stale CI-enforcement doc claims, then (remediation cycle 2, the scope of this re-review) fixes a structural deadlock the original hook implementation introduced: the hook's default `$Invoker` originally called the orchestrator-state validator with `--require-complete`, a flag requiring `ci_gate`, `pr_gate`, and a `pr-author` delegation receipt — three values that can only exist *after* the very `gh pr create` call the hook is meant to gate. Remediation cycle 2 adds a new, additive, narrower `--require-pr-creation-ready` CLI flag/function that checks only that upstream steps 5-8 are not pending/blocked, `blocked_reason` is clear, and two override lists are empty, and rewires all three hook copies' default `$Invoker` (plus the orchestrator-side documentation) to use it instead, while leaving `--require-complete`'s existing full-lifecycle semantics completely untouched.

**What changed (remediation cycle 2 specifically):**
- New Python module `scripts/dev_tools/_orchestrator_state_pr_creation_readiness.py` (118 lines, 100% test coverage) holding the new pure validation function and two constants.
- `scripts/dev_tools/validate_orchestrator_state.py` gains an independent, sibling `require_pr_creation_ready` keyword parameter — verified by direct source read to never touch the `require_complete` code path.
- `scripts/dev_tools/validate_orchestration_artifacts.py` gains the `--require-pr-creation-ready` CLI flag.
- All three copies of `enforce-pr-author-skill.ps1` (root, `.claude`-customizations mirror, Codex mirror) have their default `$Invoker` command-line text switched from `--require-complete` to `--require-pr-creation-ready`, with matching `.DESCRIPTION` updates.
- Two new Python test files (11 tests total, 100% coverage of the new module) and a two-line Pester test-description/comment update.
- Doc updates across `orchestrate/SKILL.md`, `orchestrator.md`, `pr-author.md` (and mirrors) to reference the new flag and explicitly reserve `--require-complete` for the post-PR/CI completion context.
- The `remediation-handoff-atomic-planner` skill is amended to introduce the `audit/<ts>/`/`remediation/<ts>/` timestamped-folder convention this cycle's own artifacts (and this review's own artifacts) follow.

**Top 3 risks:**
1. The real, live `artifacts/orchestration/orchestrator-state.json` checkpoint still fails `--require-pr-creation-ready` today (exit 1), because of two missing metadata fields (`relativeFile`, `long-name`) and one invalid enum value (`step5_status: "complete"` instead of `"completed"`) — none of which are produced by, or fixable within, the code under review (see Findings Table, row 1). If the orchestrator invokes the hook against this exact checkpoint state before those fields are corrected, `gh pr create` will still be blocked, for a different reason than the original bug.
2. `spec.md`'s original Acceptance Criteria bullets #210/#211 still name `--require-complete` in their prose even though the hook now invokes `--require-pr-creation-ready`; the underlying behavior each bullet describes remains true and tested, but a future reader skimming only the checked AC boxes could be misled about which flag is actually wired in (see Findings Table, row 2).
3. `tests/scripts/dev_tools/test_validate_orchestrator_state.py` (735 lines) and `test_validate_orchestration_artifacts.py` (635 lines) both remain well over the repository's 500-line cap; this is a pre-existing condition this cycle correctly avoided extending (by routing new coverage to new sibling files), but the underlying file-size debt is unaddressed and will recur as a blocker for any future change that legitimately needs to add coverage to either file.

**PR readiness recommendation:** **Go** — the single Blocking finding that opened this remediation cycle is resolved at the code level, independently verified from source and by direct command execution against the real checkpoint. The two residual Minor items are data-quality/documentation-accuracy concerns outside the code under review's scope and do not gate mergeability.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `artifacts/orchestration/orchestrator-state.json` (not itself part of this PR's diff — a runtime checkpoint) | top-level `relativeFile`, `long-name`, `step5_status` | The real, live checkpoint fails `--require-pr-creation-ready` (exit 1) due to two missing metadata fields and one invalid enum value (`"complete"` vs. the valid `"completed"`), none of which are produced by or attributable to the reviewed code. | Correct `step5_status` to `"completed"` and populate `relativeFile`/`long-name` via the orchestrator's normal checkpoint-writing path before the next live `pr_author_preflight` invocation. No code change required in this PR. | If uncorrected, the very next legitimate `gh pr create` attempt on this branch would still be blocked by `ORCHESTRATOR_STATE_PREFLIGHT_FAILED`, for a reason unrelated to and outside the fix this PR delivers. | This review's own run: `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state artifacts/orchestration/orchestrator-state.json --require-pr-creation-ready` → exit 1, output `Checkpoint missing required key: relativeFile` / `Checkpoint missing required key: long-name` / `Checkpoint has invalid step5_status: complete`. Independently corroborated by `docs/features/active/2026-07-02-local-preflight-orchestrator-state-gate-272/evidence/other/remediation-cycle-2-summary.md` "Residual note". |
| Minor | `docs/features/active/2026-07-02-local-preflight-orchestrator-state-gate-272/spec.md` | Acceptance Criteria, lines 210-211 | Two already-checked (`[x]`) AC bullets still say "`--require-complete`" in their literal prose, even though the hook's default `$Invoker` now invokes `--require-pr-creation-ready`. The described block/allow *behavior* remains true and is still tested. | Leave the checked boxes as-is (per `acceptance-criteria-tracking`, do not rewrite existing checked criteria text); optionally have a future documentation pass append a one-line clarifying note next to each bullet pointing at the `## Addendum` section, which already documents the flag-name change. | A reader skimming only the checked AC list, without also reading the Addendum, could be misled about which flag is actually wired into the hook today. | Direct read of `spec.md` lines 207-219 and 244-251; direct read of `.claude/hooks/enforce-pr-author-skill.ps1` line 73 confirming the actual invoked flag is `--require-pr-creation-ready`. |
| Info | `tests/scripts/dev_tools/test_validate_orchestrator_state.py`, `test_validate_orchestration_artifacts.py` | whole files | Both files remain well over the repository's 500-line cap (735 and 635 lines respectively) — a pre-existing condition, not introduced or extended by this branch. | Track as a separate follow-up to split these files along the same sibling-module pattern already used for the additive branches (`_human_interaction`, `_remediation_loop`, `_routing_contract`, `_pr_creation_readiness`). | Continuing to grow either file (even by a single new test) will violate the 500-line cap; the pattern of routing new coverage to new sibling files (as this cycle correctly did) is a workaround, not a fix, and will not scale indefinitely. | `wc -l` this review session: 735 and 635 lines respectively; `git diff --name-status b1b55c3..HEAD` confirms neither file appears in this branch's diff. |
| Info | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-pr-author-skill.ps1` | whole file | Exactly 500 lines — zero headroom under the cap for any future edit without a file split. Carried forward unchanged from prior cycles; not a defect introduced by this cycle. | No action required now; flag for awareness before any future edit to this file. | Any future single-line addition to this file (without a compensating deletion) will violate the 500-line cap. | `wc -l` this review session: 500. |

No Blocker or Major findings.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- The new `require_pr_creation_ready` parameter is wired as a genuinely independent sibling conditional block (`if require_pr_creation_ready:` appended after, not nested inside, `if require_complete:`), which is the correct shape to guarantee the two flags cannot interact — confirmed by direct read of `validate_orchestrator_state.py` lines 454-482.
- The new module follows the exact established sibling-module pattern (`_orchestrator_state_human_interaction.py`, `_orchestrator_state_routing.py`) for keeping the primary module under the 500-line cap, including the `__all__`-declared re-export contract so existing/future callers can still resolve the three new symbols from either module.
- The message-prefix convention (`"Checkpoint PR-creation readiness validation failed: "`, distinct from `--require-complete`'s `"Checkpoint completion validation failed: "`) is a small, deliberate design choice that keeps failures from the two modes independently greppable — a good instance of designing for future debuggability, not just present correctness.
- `test_pr_creation_readiness_excludes_ci_pr_gate_and_pr_author_receipt` is a genuinely valuable negative-space test: it doesn't just assert the pass case returns `[]`, it asserts that *no* returned error string ever mentions `ci_gate`, `pr_gate`, or `pr-author`, which is exactly the property the whole remediation cycle exists to guarantee.

#### Typing and API notes

- `validate_orchestrator_state_pr_creation_readiness(state: dict[str, Any]) -> list[str]` is fully annotated; `Any` is confined to the checkpoint's already-established untyped-JSON representation (consistent with every other `validate_*` function in this module), not a new escape hatch.
- The public surface addition (`require_pr_creation_ready: bool = False` on `validate_orchestrator_state_text`) is additive and backward-compatible — verified by direct read that no existing call site's positional/keyword arguments needed to change.

#### Error handling and logging

- Consistent with the rest of the module: the function returns an error-string list rather than raising, and the CLI dispatcher (`_validate_from_args`) surfaces the list to stderr and a non-zero exit code, matching the existing `--require-complete` contract exactly.

### PowerShell implementation audit

#### What changed well

- The edit is a minimal, surgical three-line text substitution inside `Invoke-OrchestratorStatePreflight`'s default `$Invoker` scriptblock — confirmed via `git diff` scope inspection that no other function, branch, or the five receipt checks were touched.
- The `.DESCRIPTION` clarifying clause ("validating pre-PR-creation readiness (steps 5-8, blocked_reason) not full completion") is genuinely informative, not boilerplate — it tells a future reader *why* this flag is narrower without requiring them to read the Python source.
- All three hook copies (root, `.claude`-customizations mirror, Codex mirror) were kept in sync, with the Codex mirror's disclosed 2-line-vs-3-line clarifying-clause trim (to stay at exactly 500 lines) being a reasonable, explicitly-documented, non-functional-code-affecting compromise.

#### API and safety notes

- The `$Invoker` seam remains fully injectable (unchanged `[scriptblock] $Invoker = { ... }` parameter shape), so the flag-name change required no changes to the seam's calling contract — tests continue to mock at the same boundary.
- No new global/script-scoped mutable state was introduced.

#### Error handling and logging

- Unchanged: a non-zero `$LASTEXITCODE` (or non-empty error text) from the injected `$Invoker` still surfaces as `HasErrors = $true`/`ErrorText`, and the hook still fails closed (blocks) on any preflight error, exactly as before.

---

## Test Quality Audit

This branch's remediation-cycle-2 test additions are proportionate to the change: 11 new, tightly-scoped Python tests achieving 100% line/branch coverage of the new module, plus a 2-line Pester text update whose underlying assertion logic required no change (the pre-existing test already mocked `$Invoker`'s *behavior*, not its literal invoked command-line string).

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/test_validate_orchestrator_state_pr_creation_readiness.py` — 100% line/branch coverage of the new function; every one of the function's three independent rejection branches has a dedicated negative test, plus a dedicated positive test and a dedicated negative-space assertion test. Re-run this review session: 9/9 pass.
- `tests/scripts/dev_tools/test_validate_orchestration_artifacts_pr_creation_readiness.py` — CLI-level pass/fail exit-code tests via `monkeypatch`, no real subprocess or temp file. Re-run this review session: 2/2 pass.
- `tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1` / `enforce-pr-author-skill.Tests.ps1` — 385/385 pass across the full `tests/scripts/claude-hooks` scan (re-run this review session), with the hook's five receipt checks and now-narrower preflight both exercised via the pre-existing injectable mocks.
- `docs/features/active/2026-07-02-local-preflight-orchestrator-state-gate-272/evidence/regression-testing/pr-creation-readiness-real-checkpoint-pass.2026-07-02T22-05.md` — the remediation cycle's own real-checkpoint verification; independently reproduced this review session with an identical result (exit 1 for the disclosed, unrelated reason).

### Quality assessment prompts

- **Determinism:** No `sleep`/wall-clock reads in any touched test; the `$Invoker` seam is fully injectable, so no real `python` subprocess runs during the Pester suite.
- **Isolation:** Each new Python test mutates exactly one field of a shared local fixture builder and asserts on exactly one resulting error condition.
- **Speed:** Python: 79 relevant tests in 0.34s. PowerShell: 385 tests (full scan) in 14.31s.
- **Diagnostics:** New Python tests assert on substring matches against the actual returned error strings (e.g., `"step6_status is pending" in error`), so a failure's diagnostic output directly shows the mismatched error text, not just a boolean.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Direct read of all new/modified files; no credentials, tokens, or secrets present. |
| No unsafe subprocess or command construction | ✅ PASS | The `$Invoker` default scriptblock's invoked command-line arguments are all fixed string literals (`orchestrator-state`, `$Path`, `--require-pr-creation-ready`); `$Path` is the pre-existing, already-reviewed `$CheckpointPath` parameter, not attacker-controlled input from the command being gated. |
| Input validation at boundaries | ✅ PASS | `validate_orchestrator_state_pr_creation_readiness` uses defensive `.get()` lookups and `isinstance` checks throughout (e.g., the override-list check treats a present-but-non-list value as a violation rather than raising `TypeError`). |
| Error handling remains explicit | ✅ PASS | No new broad `except`/`catch` introduced; the function returns explicit error strings, and the hook's outer `try`/`catch` (unchanged) still surfaces unexpected exceptions via `Write-Error`/`exit 1`. |
| Configuration / path handling is safe | ✅ PASS | No new path-construction logic introduced; `$CheckpointPath` defaults to the pre-existing, already-reviewed `$script:OrchestratorStateCheckpointPath` constant. |

---

## Research Log

No external research was required for this review. All findings were derived from direct source inspection, direct execution of the repository's own toolchain commands against the real checkout and the real, live `artifacts/orchestration/orchestrator-state.json` checkpoint, and cross-referencing the feature folder's own `spec.md`, `remediation/2026-07-02T22-05/*.md`, and `evidence/**` artifacts (used as pointers to re-verify, not trusted as-is per the delegation's explicit instruction).

---

## Verdict

The code changes delivered in remediation cycle 2 correctly and minimally resolve the single Blocking finding that opened the cycle: the new `--require-pr-creation-ready` flag is independently verified (by source inspection, isolated unit tests, and direct execution against the real live checkpoint) to check only pre-PR-creation-appropriate conditions and never `ci_gate`/`pr_gate`/routing-contract receipts, while `--require-complete`'s existing behavior is unchanged and still correctly rejects a pre-PR-creation checkpoint. The two Minor findings recorded above are real, currently-reproducible, and worth tracking, but neither is a defect in the reviewed code, and neither should block this PR's merge — the first is an orchestrator-side checkpoint-data-hygiene follow-up outside this PR's Do-Not-Do-constrained scope, and the second is a documentation-prose staleness issue in an already-checked AC bullet whose underlying tested behavior remains correct. **Ready for normal PR flow.**
