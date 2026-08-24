# Feature Audit: Codex PreToolUse Hook Transport Repair (#415) — Cycle-1 Re-Audit (R4)

**Audit Date:** 2026-07-26
**Auditor:** feature-review agent
**Template source:** bundled asset `extensions/drm-copilot/resources/templates/policy_audit/feature-audit.yyyy-MM-ddTHH-mm.md` (the identical file the MCP selector `feature-audit-template` resolves; the MCP resolver tool was unavailable in this session).

## Scope and Baseline

- **Feature folder:** `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415` (single active folder whose suffix matches the issue number in the branch name).
- **Base branch:** `main` (resolved; supplied by caller and confirmed against `artifacts/pr_context.summary.txt`).
- **Merge-base:** `fb483b8468204e4385b5583c3b3ec4c0a987eede` (the branch was rebased onto current `main` after the cycle-1 audit; the prior merge-base was `00980851`).
- **Head:** `bug/codex-pretooluse-hook-transport-415` @ `fa198b008984c77f6ca1a4cfdbdcc801372c0a1f`.
- **PR context artifacts:** `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt`, collected 2026-07-26 13:33 against exactly this base/head pair — current, no refresh required.
- **Work mode:** `full-bug` per the persisted `- Work Mode: full-bug` marker in `issue.md`. Acceptance-criteria source is therefore `spec.md` only (`## Acceptance Criteria`, 12 checkbox items). `user-story.md` is intentionally absent, which is correct for this mode.
- **Cycle context:** cycle-1 audit (2026-07-25T21-03) evaluated all 12 ACs as PASS but gated PR flow on two Blocking coverage-evidence findings (B1, B2). This re-audit re-verifies the AC set at the rebased HEAD and evaluates the remediation outcome.

## Acceptance Criteria Inventory

Source: `spec.md`, section `## Acceptance Criteria` (lines 262-273). 12 items, all currently checked `[x]` (checked off during the cycle-1 review per the check-off protocol).

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

| AC | Verdict | Evidence (re-verified at HEAD `fa198b00`) |
|---|---|---|
| AC1 | PASS | Reviewer re-ran `codex-pretooluse-integration.Tests.ps1` at HEAD: the config-driven matrix (59 spawns across 18 registrations / 17 distinct handlers, derived from `.codex/config.toml` at run time) passes, with the non-vacuous-parse guard case. Suite total 433/433 green. |
| AC2 | PASS | 15 process-level deny cases in `codex-pretooluse-transport.Tests.ps1` assert the exact native envelope and absence of the legacy `decision` key; re-run green. Budget denies unit-level via injected state per spec. |
| AC3 | PASS | Parameterized unmapped-`apply_patch` cases (empty and marker-free command, 16 spawns across the 8 group handlers) re-run green; fail-before/pass-after pair on record (`evidence/regression-testing/fail-before.2026-07-25T19-30.md`, `pass-after.2026-07-25T20-46.md`). |
| AC4 | PASS | Empty-stdin + invalid-JSON sweep across all 17 handlers (34 spawns) and missing/null `tool_input` across the group (16 spawns) re-run green; self-naming stderr regression case asserts `enforce-completion-consistency` names itself and not its neighbour. |
| AC5 | PASS | Every spawn in the re-run bakes poisoned `CLAUDE_TOOL_INPUT`/`CLAUDE_SESSION_ID`; results are stdin-determined. Static check `contains no legacy Claude environment-variable dependency in hooks or shared modules` covers all hooks plus the shared module; re-run green. |
| AC6 | PASS | `.codex/config.toml` is absent from the branch diff (unchanged vs merge-base); reviewer read the registration section directly: three `PreToolUse` matcher groups with 5 / 5 / 8 handler blocks, matchers unchanged. Config-driven integration case passes against these registrations. |
| AC7 | PASS | Policy functions byte-untouched (diff-hunk inspection); pre-existing deny-path and fail-closed cases in `legacy-codex-hook-contracts.Tests.ps1` pass without assertion changes (re-run green). Removed test lines are restructuring only: one static check split into two strictly wider checks. |
| AC8 | PASS | Reviewer performed a file-by-file comparison of every `.codex/` blob at HEAD against the bundle in both directions: zero differences, zero bundle-only files (orphan deleted; #335 note at `evidence/regression-testing/issue-335-bundle-orphan-removal.2026-07-25T19-33.md`). All four parity gates green in the re-run (`legacy-codex-hook-contracts`, `codex-epic-runtime-contracts`, completion-consistency parity via full run, pytest parity 8/8 re-run). |
| AC9 | PASS | `.codex/hooks/codex-pretooluse-file-mapping.ps1`: 474 lines, entrypoint-free (constants + functions only, no stdin read), mirrored byte-identically, present in `$script:SharedModuleNames` static/parity lists, and listed in `pack-manifests/core.json` at sorted position with a dedicated manifest assertion. All changed files ≤ 489 lines (reviewer-measured). |
| AC10 | PASS | `git diff --name-status fb483b84..HEAD` contains zero `.claude/` paths (reviewer-verified); working tree clean. |
| AC11 | PASS | Final remediation loop: format (0 changed) → analyze (0 findings) → test (1668 tests, 0 failures) in a single uninterrupted pass, evidenced at `evidence/qa-gates/remediation-final-poshqc-{format,analyze,test}.2026-07-26T11-41.md`. |
| AC12 | PASS | **Now satisfied with the changed surface fully measured (the cycle-1 gap).** PowerShell: repo-wide 2869/3042 = 94.31% lines; changed surface 776/783 = 99.11%; per-file 96.55%–100.00% — all independently reproduced by this reviewer from `artifacts/pester/powershell-coverage.xml`. Branch coverage is not measurable in this toolchain (no JaCoCo BRANCH counter; reviewer-confirmed), matching the criterion's "where the toolchain measures it" qualifier. Python: 91.00% lines / 81.84% branches from `artifacts/python/lcov.info`, independently summed — the >= 75% branch threshold passes where measured. Evidence: `per-file-coverage-final.2026-07-26T11-41.md`, `coverage-comparison.2026-07-26T11-41.md`, `python-coverage.2026-07-26T11-41.md`. |

Cycle-1 remediation findings:

| Finding | Verdict | Evidence |
|---|---|---|
| R1 (B1) — changed PowerShell surface outside `CodeCoverage.Path` | RESOLVED | Additive 8-path extension to both runsettings copies (byte-identical); all 8 paths present in the coverage XML with per-file numbers above threshold; no removals, no threshold or denominator changes. Measurement verified CI-reproducible (`_poshqc.yml:38-42` + `PoshQC.psm1:3`). |
| R2 (B2) — Python coverage artifact absent | RESOLVED | `artifacts/python/lcov.info` present; 91.00% / 81.84%, no movement (test-only change), independently re-derived. |

## Summary

- 12 of 12 acceptance criteria: **PASS** (none PARTIAL, FAIL, or UNVERIFIED).
- Both cycle-1 Blocking findings: **RESOLVED** with independently reproduced numeric evidence.
- Blocking findings in this re-audit: **0**.
- All seven caller-listed constraints re-verified at HEAD (no `.claude/` changes; registrations 5/5/8 intact; policies preserved; root/bundle and runsettings byte-identity; no temp files; ≤ 500 lines; coverage configuration additive-only).
- Non-blocking follow-ups (3) are recorded with rationale in `evidence/other/remediation-followups.2026-07-26T11-41.md` and require no pre-PR action.
- Recommendation: **Go for PR creation.**

## Acceptance Criteria Check-off

All 12 items in `spec.md` `## Acceptance Criteria` were already checked `[x]` during the cycle-1 review, consistent with the check-off protocol (evidence-before-check-off; every item PASS). This re-audit re-verified each criterion at the rebased HEAD and confirms every check-off remains valid. No new check-offs were required and no criterion text was modified.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/spec.md`
- Total AC items: 12
- Checked off (delivered): 12
- Remaining (unchecked): 0
- Items remaining: none
