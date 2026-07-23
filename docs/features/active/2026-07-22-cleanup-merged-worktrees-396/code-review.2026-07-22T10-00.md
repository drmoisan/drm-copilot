# Code Review: cleanup-merged-worktrees (#396) — Remediation Cycle 1 Re-review

---

**Review Date:** 2026-07-22
**Reviewer:** feature-review agent (Claude Code)
**Feature Folder:** `docs/features/active/2026-07-22-cleanup-merged-worktrees-396/`
**Base Branch:** `main` (merge base `b2351cbc3fb3916f516d77567a1c9e40457c8981`)
**Head Branch:** `drm-copilot-wt-2026-07-21T21-57` (`75aee760010d863a3a448766fe4b348440e58acb`)
**Review Type:** Remediation cycle 1 re-review (prior review: `code-review.2026-07-22T09-23.md`)

---

## Executive Summary

This re-review covers the full branch diff versus `main` (133 files, +3780/-0) with focus on the remediation cycle 1 delta (commits `8c1a0266`, `63eea73d`, `9876def8`, `75aee760`). The remediation resolved the single Blocking CI finding — the missing bundled-payload mirror for the new `cleanup-merged-worktrees` skill — by adding a byte-identical copy at `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md` and registering exactly one entry in `pack-manifests/core.json` at the correct alphabetical position within its manifest section. No production shell, Python, TypeScript, PowerShell, or C# code changed in the remediation delta; the fix is a two-file config/resource change plus documentation and evidence.

**What was verified in this cycle:**
- Mirror is byte-identical (`git diff --no-index` exit 0). Because the mirrored file is an exact copy of the already-reviewed skill, no new content review is required; the mirror inherits the prior review's findings (none against SKILL.md).
- `core.json` diff since the prior review head is exactly one inserted line; the manifest's pre-existing out-of-order section boundaries are unchanged (no ordering regression).
- The previously failing contract test `test_bundled_claude_payload_contains_all_repo_runtime_contracts` and the manifest-completeness test now pass: 9/9 locally (reviewer re-run, exit 0) and green in full CI run 29925971964 at `9876def8` (all 14 jobs, including the `quality-checks7` 3.10–3.13 matrix). The `9876def8..75aee760` delta is four `docs/features/**` files.
- The remediation plan's mechanism decision (direct copy rather than `push_down_claude_customizations`, which publishes outward, not into the bundle) is technically correct.

**Top risks (all carried forward, none new):**
1. CR-1 (Major, unchanged): dead `|| rc=$?` captures inside process substitutions in `cleanup_worktrees_lib.sh` — latent fail-open on anomalous git failure. Follow-up hardening recommended.
2. CR-2 (Minor, unchanged): stub-aware branch in `cherry_pick_candidates`.
3. New maintenance observation (Info, RR-1): the repo-to-bundle mirror for `.claude/**` files is a manual convention enforced only by the contract test — this feature's original CI failure is the recurring failure mode. Documented below; not a defect in this branch.

**PR readiness recommendation:** **Go** — zero Blockers; the cycle-1 Blocking finding is resolved and verified.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `scripts/bash/cleanup_worktrees_lib.sh` | lines 117, 270, 375 (CR-1, carried forward, unchanged) | Or-capture (`rc=$?`) assignments inside process substitutions execute in a subshell and never update the parent function's `rc`, leaving a narrow fail-open on anomalous `git cherry` / `git worktree list` / `git rev-list` termination. | File a follow-up hardening issue: capture output via command substitution with explicit exit-code propagation and add a fixture simulating a `git cherry` hard failure. | Unchanged since the prior review; the remediation delta did not touch this file. Risk remains bounded (report-default, apply re-verification, git's checked-out-branch refusal). | `git diff 69188347..HEAD` contains no shell files; full analysis in `code-review.2026-07-22T09-23.md`. |
| Minor | `scripts/bash/cleanup_worktrees_actions_lib.sh` | lines 96-102 (CR-2, carried forward, unchanged) | Stub-aware production logic re-emits `stub-git:` marker lines to stderr. | Move argv observation into the stub/test layer or document the marker as a supported diagnostic contract. | Unchanged since the prior review. | `code-review.2026-07-22T09-23.md`. |
| Minor | `scripts/bash/cleanup_worktrees_lib.sh` | call graph (CR-4, carried forward, unchanged) | Redundant subprocess work, O(branches x worktrees) git invocations. | Acceptable at current scale; hoist if runtime grows. | Unchanged since the prior review. | `code-review.2026-07-22T09-23.md`. |
| Nit | `scripts/bash/cleanup_worktrees_lib.sh` | whole file (CR-3, carried forward, unchanged) | 499 of 500 lines. | Plan a split on the next change to this file. | Unchanged since the prior review. | `wc -l` evidence in `evidence/qa-gates/file-size-caps.2026-07-22T09-01.md`. |
| Info | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md` | whole file (RR-2, new this cycle) | Bundled mirror is byte-identical to the reviewed repo skill; the bundle now carries a second copy that must be kept in sync on any future skill edit. | None required for this merge; the contract test enforces presence and the sync obligation is the established repo convention for all bundled `.claude/**` files. | The mirror inherits the prior review of the source file; divergence would be caught by `test_bundled_claude_payload_contains_all_repo_runtime_contracts` only for missing files, not for content drift — content drift is caught by the byte-comparison contract test in the same file. | `git diff --no-index` exit 0; `poetry run pytest` 9/9 pass. |
| Info | `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | line 58 (RR-3, new this cycle) | Single entry added at the correct alphabetical position within the skills block; pre-existing section-boundary ordering deviations in the manifest are untouched. | None required. | Minimal, correct, plan-conformant edit; JSON parses; exactly one occurrence. | JSON parse + occurrence/position check; `git diff 69188347..HEAD -- ...core.json` shows one added line. |
| Info | process | repo convention (RR-1, new this cycle) | The `.claude/**` to bundled-payload mirror is a manual step enforced only post-hoc by CI contract tests; this feature's original failure (skill created without its mirror) is the standard failure mode for new `.claude/**` files. | Consider a future enhancement: a pre-commit or PreToolUse check, or extending the skill-authoring workflow docs to include the mirror step. Out of scope for this branch. | Reduces repeat remediation cycles for future skill additions; precedent commit `bab8d604` shows the same pattern occurred before. | `remediation-inputs.2026-07-22T13-42.md`; remediation plan mechanism decision. |

No Blockers. The cycle-1 Blocking finding (missing bundle mirror) is resolved; findings CR-1 through CR-4 are carried forward unchanged from `code-review.2026-07-22T09-23.md` with CR-1 recommended as a follow-up hardening issue.

---

## Implementation Audit

### Remediation delta audit (cycle 1)

- **Correct mechanism:** the plan explicitly rejected `push_down_claude_customizations` (it publishes bundle content outward to a consumer workspace; it does not write into the bundle) in favor of a direct byte-identical copy. Verified correct by reading the plan's mechanism decision and confirming the tool's direction of data flow.
- **Byte-identity:** `git diff --no-index` between the repo skill and the bundled mirror exits 0 with empty output — no re-wrapping, encoding, or line-ending changes.
- **Manifest edit:** exactly one line added to `core.json`, positioned after `atomic-plan-contract` and before `commit-message` as planned. The file parses as valid JSON. The manifest's overall array is not globally sorted, but the three out-of-order adjacent pairs are identical in base and head — pre-existing section boundaries, not introduced by this change.
- **Scope discipline:** `git diff 69188347..HEAD --name-only` shows exactly the two bundled-payload files plus eight `docs/features/**` files. No contract test, anchor file, or unrelated path was modified — matching the plan's scope constraint.
- **Evidence quality:** fail-before evidence records the reproduced failure (named test, non-zero exit); pass-after evidence records exit 0, 9 passed, and the remediation commit SHA `8c1a0266`.

### Bash implementation audit

Unchanged since the prior review — no shell file in the remediation delta. Full audit: `code-review.2026-07-22T09-23.md`.

---

## Test Quality Audit

No test files changed in the remediation delta. The remediation is verified by pre-existing repo-wide contract tests rather than new tests, which is appropriate: the contract tests are exactly the gate that caught the defect, and they now exercise the new skill's bundled path on every CI run.

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` — reviewer re-ran: passes, including `test_bundled_claude_payload_contains_all_repo_runtime_contracts` (the previously failing test).
- `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` — reviewer re-ran: passes, including `test_bundled_claude_files_are_listed_in_some_pack_manifest`.
- `evidence/regression-testing/bundle-contracts.{fail-before,pass-after}.2026-07-22T13-42.md` — complete fail-before/pass-after pair with commands, exit codes, and commit SHA.
- Prior-cycle bats/QA artifacts — unchanged and still current (no shell delta).

### Quality assessment prompts

- **Determinism:** contract tests are pure filesystem/JSON comparisons; deterministic.
- **Regression protection:** the full-file rerun (not just the single failing test) confirms no other branch-added `.claude/**` file is missing from the bundle.
- **Gap (carried forward):** no fixture simulates a hard `git cherry` failure (CR-1 path remains untested).

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Remediation delta inspected: a mirrored markdown skill, one JSON manifest line, and docs/evidence. No credentials or tokens. |
| Bundle mirror integrity | PASS | Byte-identical copy verified; the mirrored skill's `allowed-tools` frontmatter is identical to the reviewed original (narrow wrapper + read-only/push git commands; no PR-creation shortcuts). |
| No prohibited PR shortcuts introduced | PASS | The mirror contains the same prohibition text as the original; no `gh pr create`/`gh pr edit` usage added anywhere in the delta. |
| Manifest correctness | PASS | Valid JSON, single occurrence, correct position, no other lines changed. |
| Prior-cycle checks | PASS | All security/correctness rows from `code-review.2026-07-22T09-23.md` remain valid (no code delta); the one PARTIAL row (explicit error handling, CR-1) is carried forward unchanged. |

---

## Research Log

No external research was required. Evidence sources: branch diff (`git diff b2351cbc..HEAD`, `git diff 69188347..HEAD`), remediation plan/inputs and evidence artifacts, local contract-test re-run (`poetry run pytest`, exit 0), byte-identity check (`git diff --no-index`), JSON manifest inspection, and gh CLI run metadata (runs 29924839016 failure at `69188347`; 29925971964 success at `9876def8`; 29926167798 in progress at head `75aee760`).

---

## Verdict

The remediation is complete, minimal, and correct: the bundled mirror is byte-identical, the manifest registration is exact, the previously failing required check is green in CI at branch-head content, and the reviewer reproduced the contract-test pass locally. No new code-quality findings at Major or higher; two Info observations document the mirror-maintenance convention and the correctly executed manifest edit. Carried-forward findings (CR-1 Major follow-up hardening, CR-2/CR-4 Minor, CR-3 Nit) are unchanged and do not gate the merge.

**Recommendation: Go.**
