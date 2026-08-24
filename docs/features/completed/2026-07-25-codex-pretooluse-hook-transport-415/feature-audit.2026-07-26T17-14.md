# Feature Audit: Codex PreToolUse Hook Transport Repair (#415) — Cycle-2 Re-Audit (R4)

**Audit Date:** 2026-07-26
**Auditor:** feature-review agent
**Template source:** bundled asset `extensions/drm-copilot/resources/templates/policy_audit/feature-audit.yyyy-MM-ddTHH-mm.md` (the identical file the MCP selector `feature-audit-template` resolves; the MCP resolver tool was unavailable in this session).

## Scope and Baseline

- **Feature folder:** `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415` (single active folder whose suffix matches the issue number in the branch name).
- **Base branch:** `main` (resolved; supplied by caller and confirmed against `artifacts/pr_context.summary.txt`).
- **Merge-base:** `5f24e0f6bc85f03303826746409935bb9ab94e1b` — current `origin/main`; the branch was rebased after `main` advanced 21 commits (issues #421, #422, #423, #426), moving the merge-base from `fb483b84`.
- **Head:** `bug/codex-pretooluse-hook-transport-415` @ `d44a26ad85c0b542f51241e46a626f11585dc8ee` (confirmed via `git rev-parse HEAD`).
- **PR context artifacts:** `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt`, collected 2026-07-26 17:02 against exactly this base/head pair — current, no refresh required.
- **Work mode:** `full-bug` per the persisted `- Work Mode: full-bug` marker in `issue.md`. Acceptance-criteria source is therefore `spec.md` only (`## Acceptance Criteria`, 12 checkbox items). `user-story.md` is intentionally absent, which is correct for this mode.
- **Cycle context:** cycle-1 audit (2026-07-25T21-03) found 2 Blocking coverage-evidence findings; the cycle-1 re-audit (2026-07-26T13-42) was clean (0 Blocking). CI then failed `poshqc / PowerShell QC` against that head on the branch's own config-driven integration test (detached-HEAD null-method throw in `enforce-epic-child-worktree-binding.ps1`), triggering remediation cycle 2 (`remediation-inputs.2026-07-26T18-10.md`, `remediation-plan.2026-07-26T18-10.md`, 31/31 tasks checked). This re-audit re-verifies the full AC set at the cycle-2 head.

## Acceptance Criteria Inventory

Source: `spec.md`, section `## Acceptance Criteria` (lines 262-273). 12 items, all currently checked `[x]` (checked off during the cycle-1 review per the check-off protocol; `spec.md` was not touched in cycle 2 — reviewer-verified empty diff).

1. AC1 — Every registered handler exits 0 with empty stdout/stderr for a valid safe payload for every tool name its matcher admits (config-driven integration case).
2. AC2 — Forbidden payloads yield exit 0 and exactly the native deny envelope, no legacy `decision` key.
3. AC3 — Well-formed `apply_patch` with unmapped `tool_input` allows (exit 0, empty stdout) for every group handler.
4. AC4 — Malformed stdin yields exit 2 / empty stdout / nonempty stderr (scoped: empty+invalid JSON for all handlers; missing/null `tool_input` for the group); `enforce-completion-consistency` stderr names itself.
5. AC5 — Poisoned `CLAUDE_*` environment variables have no effect; static `$env:CLAUDE_` absence.
6. AC6 — Every pre-change hook registration still present with matchers unchanged.
7. AC7 — Allow/deny outcomes for previously reachable `apply_patch` payloads unchanged.
8. AC8 — Root `.codex/` and bundled copy byte-identical; bundle orphan deleted with #335 cross-reference.
9. AC9 — Shared transport module exists, entrypoint-free, ≤ 500 lines, mirrored, listed in parity lists and `core.json`.
10. AC10 — No `.claude/` paths in the change set.
11. AC11 — PoshQC loop (format → analyze → test) clean in a single pass with qa-gates evidence.
12. AC12 — Line coverage >= 85% and branch coverage >= 75% (branch where the toolchain measures it), evidenced under `evidence/qa-gates/`.

## Acceptance Criteria Evaluation

| AC | Verdict | Evidence (re-verified at HEAD `d44a26ad`) |
|---|---|---|
| AC1 | PASS | This is the criterion CI falsified against the prior head: on the detached `refs/pull/427/merge` checkout, `enforce-epic-child-worktree-binding.ps1` (registered under the wide matcher) exited 2 for a benign payload. Cycle 2 fixed the null-guard; this reviewer verified the fix three independent ways: (1) re-ran the config-driven integration matrix at HEAD on this checkout (green, within the 476/476 suite re-run); (2) re-ran the new deterministic mocked-seam cases that reproduce the exact CI condition (empty git output, exit 0) — 43/43; (3) created its own detached worktree at the committed HEAD and piped the CI-shaped benign payload into the fixed hook: exit 0, empty stdout, empty stderr. The integration test itself is byte-unchanged in cycle 2 and unskipped. Final CI confirmation against this head occurs at the orchestrator's S9 gate after push. |
| AC2 | PASS | Deny-path suites unchanged in cycle 2 and re-run green; cycle 2 adds the RD-1b deny case asserting the exact native envelope (`permissionDecision` = `deny`, reason matched verbatim) for a preparation-mode push with an empty branch. |
| AC3 | PASS | Unmapped-`apply_patch` cases unchanged in cycle 2; re-run green within the 476-test set. |
| AC4 | PASS | Malformed-stdin sweep unchanged and re-run green. Cycle 2 preserves the exit-2 contract boundary: transport errors remain exit 2 (git *failure* in the planning-only resolver, test-pinned), while a legitimate repository state (detached HEAD) no longer masquerades as one. |
| AC5 | PASS | Poisoned-environment spawns and the static `$env:CLAUDE_` absence check unchanged, re-run green. The cycle-2 hooks read only `CODEX_*` attestation variables (pre-existing), which the new tests save/clear/restore in `finally`. |
| AC6 | PASS | `.codex/config.toml` has zero diff at every range (working tree, vs merge-base, vs cycle-2 baseline); reviewer read the registration section directly: three `PreToolUse` matcher groups with 5 / 5 / 8 handler blocks, matchers unchanged. |
| AC7 | PASS | Decision functions in both cycle-2 hooks are byte-identical to `main` (reviewer-verified: the hooks were unchanged before cycle 2, and every cycle-2 hunk is confined to new helper functions and entrypoint call sites). Pre-existing deny-path and fail-closed cases pass without assertion changes; 0 removed test lines in cycle 2. The two deliberate entrypoint outcome changes on a detached HEAD (preparation push: exit 2 → policy deny; dormant push: exit 2 → allow) affect no previously *reachable* `apply_patch` or policy outcome — the affected paths previously terminated in a transport error, not a policy decision — and both are pinned by committed RD-1 tests. |
| AC8 | PASS | Reviewer performed a file-by-file hash comparison of root `.codex/` against the bundle: identical file sets, 0 content differences. Both runsettings copies byte-identical. All parity gates green in the 476-test re-run plus the 9-test pytest parity re-run. |
| AC9 | PASS | Unchanged from the clean cycle-1 re-audit; shared module still 474 lines, mirrored, listed. All branch-changed files ≤ 489 lines (reviewer-measured, including the three cycle-2 test files at 344/353/143 and the two hooks at 334/310). |
| AC10 | PASS | `git diff --name-status main...HEAD` contains zero `.claude/` paths; working tree clean; the cycle-2 scope-verification artifact additionally covers `.claude/state/` and `.claude/agent-memory/`. |
| AC11 | PASS | Cycle-2 final loop: format (0 files changed, SHA256-proven) → analyze (0 findings) → test (1702 pass / 0 fail / 9 skip, dual-path per RD-5) in a single uninterrupted pass, evidenced at `evidence/qa-gates/remediation2-final-poshqc-{format,analyze,test}.2026-07-26T15-17.md`; per-phase loop artifacts exist for every implementation phase. |
| AC12 | PASS | **Now satisfied with the cycle-2 changed surface also measured.** PowerShell: repo-wide 3148/3337 = 94.34% lines (41 files); cycle-2 changed files 95.62% and 93.33% raw; cycle-1 band 96.55%–100.00% held byte-identically — all independently reproduced by this reviewer from `artifacts/pester/powershell-coverage.xml`, with the +295/+279 growth reconciling exactly to the two newly measured files (zero coverage loss). Branch coverage is not measurable in this toolchain (no JaCoCo BRANCH counter, reviewer re-confirmed), matching the criterion's "where the toolchain measures it" qualifier; Python branches measure 81.84% ≥ 75% where measured (91.00% lines, re-summed from `artifacts/python/lcov.info`). Evidence: `per-file-coverage-final.2026-07-26T15-17.md`, `remediation2-coverage-comparison.2026-07-26T15-17.md`. |

Cycle-2 remediation findings:

| Finding | Verdict | Evidence |
|---|---|---|
| C1 (Blocking) — worktree-binding hook exits 2 on detached HEAD | RESOLVED | `Get-CodexChildGuardLiveBranch` guards git failure OR empty successful output; reviewer's independent detached-worktree probe at committed HEAD: exit 0, empty stdout/stderr; deterministic regression tests at the mocked seam; the config-driven integration test remains the permanent CI net. |
| A1 (Adjacent) — planning-only push path exits 2 on detached HEAD | RESOLVED per RD-1 | Git failure keeps exit-2 fail-closed (test-pinned); empty successful output resolves to `''` and the byte-unmodified decision layer governs: preparation deny (test-pinned envelope) / dormant allow (test-pinned + reviewer probe). Correctly scoped as a transport correction; no decision-function line changed. |
| S1 (Sweep) — other empty-git-output sites | CLEAN | Reviewer re-executed all sweep greps: identical hit inventory (8 distinct `& git` sites), SAFE verdicts spot-verified against source, advisory reasoning verified, zero new defects. |
| R-COV — cycle-2 hooks outside the coverage denominator | RESOLVED | Additive 2-entry extension to both runsettings copies; both hooks above 85% raw; no removals, thresholds, or denominator changes; cycle-1 per-file band unregressed. |

## Summary

- 12 of 12 acceptance criteria: **PASS** (none PARTIAL, FAIL, or UNVERIFIED).
- All four cycle-2 findings: **RESOLVED / CLEAN** with independently reproduced evidence, including the reviewer's own detached-worktree reproduction of the fixed behavior at the committed head.
- Blocking findings in this re-audit: **0**.
- All eight caller-listed constraints re-verified at HEAD (no `.claude/` changes; config.toml untouched with 5/5/8 handler blocks; no decision-function change beyond RD-1's scoped entrypoint outcomes; root/bundle and runsettings byte-identity; no temp files; ≤ 500 lines; coverage config additive-only with no weakened assertions or suppressions; integration test intact).
- All four executor-reported deviations adjudicated and accepted on their merits (policy-audit Section 8): the post-rebase baseline SHA is sound and did not narrow the scope assertion; the two-new-file test placement was within the plan's budget and structurally better; the SHA256 formatter proof is stronger than the `git status` alternative; the `Get-CodexChildGitScalar` advisory is genuinely out of scope.
- Remaining exit-gate element outside local control: a green `poshqc / PowerShell QC` run against this head SHA in CI (orchestrator S9 gate, after push). Local evidence indicates the failing condition is resolved.
- Recommendation: **Go for PR update and CI re-run.**

## Acceptance Criteria Check-off

All 12 items in `spec.md` `## Acceptance Criteria` were checked `[x]` during the cycle-1 review, consistent with the check-off protocol (evidence-before-check-off; every item PASS). Cycle 2 did not touch `spec.md` (reviewer-verified empty diff), and this re-audit re-verified each criterion at the cycle-2 head and confirms every check-off remains valid — including AC1, which CI temporarily falsified between the cycle-1 re-audit and this one and which is now re-established with three independent verification paths. No new check-offs were required and no criterion text was modified.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/spec.md`
- Total AC items: 12
- Checked off (delivered): 12
- Remaining (unchecked): 0
- Items remaining: none
