# Code Review: epic-orchestrate (#275)

---

**Review Date:** 2026-07-03
**Reviewer:** feature-review agent (Claude Sonnet 5)
**Feature Folder:** `docs/features/active/2026-07-02-epic-orchestrate-275/`
**Base Branch:** `main` (merge-base `3c5ff3289022abc3b7b16e2441c772e5f81fd9ff`)
**Head Branch:** `drm-copilot-wt-2026-07-02-19-03` @ `6d4bac761771558971174dce7b870ebb09bac72a`
**Review Type:** Re-audit — R4 of remediation cycle 2 (the second remediation cycle for this feature)
**Prior review (superseded, not assumed valid):** `code-review.2026-07-03T00-15.md` @ commit `44c827d` (its one residual Major finding is independently re-checked below, not trusted at face value).

---

## Executive Summary

This is an independent re-review of `epic-orchestrate` (#275) after remediation cycle 2, a narrowly-scoped, single-fix cycle addressing the sole residual finding from cycle 1: `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` was 513 lines, 13 over the mandatory 500-line cap. This review independently re-read the fix's diff, re-ran the affected and full test suites, and independently re-executed the complete four-stage toolchain for all three in-scope languages, rather than accepting the remediation's own evidence at face value.

**Remediation verification (independently confirmed):**

1. **Major — oversized `test_validate_orchestration_artifacts.py` — RESOLVED.** Now 381 lines (was 513). `git diff 44c827d 6d4bac7 -- tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` shows a pure deletion of the 8 relocated test functions, the 2 helper functions used exclusively by them, and the now-unused `json` import — no other line changed, no assertion text altered. The new sibling file, `test_validate_orchestration_artifacts_state_shape.py` (154 lines), imports the shared `build_valid_orchestrator_state` builder from its sibling rather than duplicating it, following the exact convention already established by `test_validate_orchestration_artifacts_dispatch.py` in cycle 1. All 8 relocated tests reproduced passing in isolation; the full `tests/scripts/dev_tools` suite reproduces at 1192 passed / 19 skipped / 0 failed, identical to the pre-fix baseline (net-zero change, as expected for a pure relocation).
2. **Major — `enforce-epic-worktree-removal-gate.ps1` unconditional activation — still NOT addressed (correctly out of this cycle's approved scope).** Confirmed unchanged. See refined risk assessment below.
3. **Minor — broken "Merge-Conflict Remediation" cross-reference — still NOT addressed (correctly out of this cycle's approved scope).** Confirmed unchanged via `grep`.
4. **New this pass (Minor) — `.claude/settings.local.json` hygiene debt.** Four `permissions.allow` entries were added in the cycle-1 commit (`44c827d`), three of which (`Bash(diff /tmp_root_baseline.psd1 /tmp_mirror_baseline.psd1)`, `Bash(echo "exit: $?")`, `Bash(rm -f /tmp_root_baseline.psd1 /tmp_mirror_baseline.psd1)`) reference ephemeral temp-file paths from an ad hoc verification step, not a documented or reusable permission. Not touched by cycle 2; noted here since it had not been previously flagged.

**Top risks remaining after this cycle:**
1. `enforce-epic-worktree-removal-gate.ps1`'s unconditional (non-epic-mode-scoped) activation — on closer inspection this pass, this hook is registered on the plain `"Bash"` `PreToolUse` matcher with no subagent-type gating (unlike the wave-barrier hook, which is registered on the `"Agent"` matcher and internally gates on subagent type), meaning its blast radius is any Bash-tool `git worktree remove` call in any session against this repository — broader than "no standalone-orchestration caller" alone conveys, though no currently-documented Claude-Code-driven workflow outside epic mode triggers it.
2. Dangling "Merge-Conflict Remediation" cross-reference in `orchestrate/SKILL.md` (documentation-only).
3. `.claude/settings.local.json` ephemeral-permission hygiene debt (functionally inert, cosmetic).

**PR readiness recommendation:** **Ready.** No Blocker- or Major-severity finding remains open that was not already explicitly, repeatedly deferred by the requester across two remediation cycles with a documented non-blocking rationale that this review independently re-confirms holds (refined for risk-description accuracy on item 1). This cycle's single fix is fully verified with no regression.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major (carried forward, non-blocking by explicit requester decision) | `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | Whole file (unconditional activation) + `.claude/settings.json` line 98 (`"Bash"` matcher registration) | The hook gates every `git worktree remove` Bash command fail-closed with no epic-mode precondition. This review additionally confirmed the *registration* itself (not only the hook's internal logic) has no subagent-type scoping: it is wired into the global `"Bash"` `PreToolUse` matcher, so it applies session-wide, not only when `epic-orchestrator` is active. | Either document explicitly why this hook is intentionally scoped globally, or add the same epic-mode precondition used by the wave-barrier hook (subagent-type/prompt-marker gate) for design consistency and to shrink the blast radius to epic-mode sessions only. | Two sibling hooks in the same feature use materially different activation-scoping strategies (global `Bash` matcher vs. subagent-gated `Agent` matcher) with no stated rationale for the difference. AC9's literal wording does not require epic-mode scoping and is satisfied as written; `git grep -n "worktree remove" .claude/` confirms only `epic-orchestrate/SKILL.md` documents this command today, so no currently-documented workflow is broken. | `.claude/settings.json` line 98 (registration); `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` lines 194-201 (no subagent/marker check in the decision function) vs. `enforce-epic-wave-barrier.ps1`'s `"Agent"`-matcher registration. Independently re-read this pass. |
| Minor (carried forward, non-blocking by explicit requester decision) | `.claude/skills/orchestrate/SKILL.md` | Line 162 (S9 step 6) | References a "Merge-Conflict Remediation" heading that does not exist in this file; the real procedure is `.claude/skills/epic-orchestrate/SKILL.md`'s "Merge-Conflict Handling (Fan-In)" section (confirmed present, line 120). | Correct the cross-reference to name the actual file and heading. | A dangling "below" reference in a procedural document agents follow at runtime is misleading, though the underlying procedure it should point to is present and correct. | `grep -n "Merge-Conflict Remediation" .claude/skills/orchestrate/SKILL.md` returns only the referencing line; `grep -n "Merge-Conflict Handling" .claude/skills/epic-orchestrate/SKILL.md` confirms the target section's actual name and location. Independently reproduced this pass. |
| Minor (new this pass) | `.claude/settings.local.json` | Whole file (`permissions.allow` array) | Three of four newly-added permission entries (`Bash(diff /tmp_root_baseline.psd1 /tmp_mirror_baseline.psd1)`, `Bash(echo "exit: $?")`, `Bash(rm -f /tmp_root_baseline.psd1 /tmp_mirror_baseline.psd1)`) reference specific, ephemeral temp-file paths from what appears to be an ad hoc mirror-verification step performed during the prior review cycle, not a reusable or AC-tied permission. Introduced in `44c827d` (cycle-1 audit commit), not touched by cycle 2. | Remove the three ephemeral entries in a future housekeeping pass; retain `Bash(git show *)` if still needed for evidence-gathering. | `.claude/settings.local.json` is tracked (not gitignored) and should not accumulate session-specific debug permissions tied to paths that no longer (and will never again) exist. | `git log -p -- .claude/settings.local.json` shows the four-entry addition landed in `44c827d`; the three temp-file entries reference paths not present anywhere else in the repository. |
| Info | `tests/scripts/dev_tools/test_validate_orchestration_artifacts_state_shape.py` | Whole file | Clean remediation: correct, verbatim relocation with no weakened assertions, a clear module docstring explaining the split's rationale and explicitly disambiguating itself from the pre-existing, unrelated `test_validate_orchestrator_state.py`, and reuse (not duplication) of the shared fixture builder via import from its sibling module. | None — noted as a positive pattern to continue. | N/A | Direct source read and isolated test run this pass (8/8 passed). |

No Blocker-severity findings remain in this pass (all prior Blockers resolved in cycle 1, independently re-confirmed as still resolved this pass by re-running the full toolchain).

---

## Implementation Audit (remediation-cycle-2 delta only; see `code-review.2026-07-03T00-15.md` for the full original-implementation and cycle-1 audit, independently re-confirmed as still accurate for all files unchanged since)

### Python implementation audit

- The cycle-2 fix is a pure test-file reorganization: no production code (`scripts/dev_tools/**`) was touched. `git diff 44c827d 6d4bac7 --stat` confirms only three files changed, all under `tests/scripts/dev_tools/`.
- `test_validate_orchestration_artifacts_state_shape.py`: fully typed (`from __future__ import annotations`, explicit `cast(...)` usage matching the pattern already used in the file it was split from); imports the shared builder rather than duplicating it, avoiding drift between the two files' notion of a "valid" checkpoint payload.
- `test_validate_orchestration_artifacts.py`: post-fix, retains its module docstring, all non-relocated fixtures (`build_valid_orchestrator_state`, `build_valid_policy_audit_text`, `build_read_text_stub`, `build_complete_large_orchestrator_state`) and all non-relocated `test_` functions, byte-for-byte unchanged except for the now-unused `json` import removal.

### PowerShell / TypeScript implementation audit

No PowerShell or TypeScript production or test file was touched by cycle 2 (`git diff --stat 44c827d 6d4bac7` confirms zero files under `.claude/hooks/`, `tests/scripts/claude-hooks/`, or `extensions/drm-copilot/`). Both languages' toolchains were independently re-executed in full this pass regardless, to confirm no incidental regression (see Toolchain Verification in `policy-audit.2026-07-03T00-45.md`); all stages pass with figures identical to cycle 1's measurement.

---

## Test Quality Audit

Independently re-executed rather than solely re-read from remediation evidence:

- `tests/scripts/dev_tools/test_validate_orchestration_artifacts_state_shape.py` — 8 tests, one behavior per test (receipt-completion gating, legacy list-based receipts, namespaced promotion receipts, non-object JSON root, non-container receipts, unknown promotion keys, missing result signal, non-list artifact paths), clear `test_...` names, all docstrings preserved verbatim from the pre-relocation file. All 8 independently reproduced passing in isolation.
- `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` (post-fix) — remaining tests independently reproduced passing as part of the full 1192-test suite run.
- Full-suite re-execution (this review's own session): 1192 Pytest passed + 19 skipped (0 failed), 467 Pester passed (0 failed), 1462 Jest passed (0 failed) — all independently reproduced, not read from prior evidence files alone.
- **Determinism:** No wall-clock reads, `Start-Sleep`/`setTimeout`, or unseeded randomness observed in the new sibling file.
- **Isolation:** The relocated tests remain single-function-scoped; no cross-test shared mutable state introduced by the move.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No credentials/tokens in any cycle-2 file. |
| No unsafe subprocess/command construction | ✅ PASS | Cycle 2 introduced no new subprocess or shell-out logic (pure test-file reorganization). |
| Input validation at boundaries | ✅ PASS | Unaffected by this cycle. |
| Error handling remains explicit | ✅ PASS | No exception-handling logic touched. |
| Configuration/path handling is safe | ✅ PASS | No configuration file touched by cycle 2. |

---

## Research Log

No new external research was required for this remediation cycle; the fix's scope (a single, mechanical test-file split) did not raise any new design question. The two carried-forward findings were re-examined against the current state of `.claude/settings.json` and the hook source files directly, rather than re-cited from the prior review without inspection.

---

## Verdict

Remediation cycle 2 resolved its single targeted finding (the residual 13-line file-size overage) cleanly, with independently-verified evidence that the extraction changed no test assertions, no production code, and no test/coverage count. No Blocker or newly-introduced Major finding was found in this pass. Two Major/Minor findings from prior cycles remain open by explicit, repeated requester decision (worktree-removal-gate scope, broken cross-reference); this review re-confirmed both are still accurately described as non-blocking, with a refinement to the worktree-removal-gate finding's risk description (session-wide registration, not merely a future-orchestration concern) that does not change its non-blocking disposition given AC9's literal satisfaction and the absence of any currently-documented triggering workflow outside epic mode. One new Minor, functionally-inert hygiene finding was observed (`settings.local.json` ephemeral permissions). **This feature is ready to proceed to PR creation; no further remediation cycle is required.**
