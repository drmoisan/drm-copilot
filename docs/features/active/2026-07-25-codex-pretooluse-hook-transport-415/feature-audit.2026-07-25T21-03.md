# Feature Audit: Codex PreToolUse Hook Transport Repair (#415)

**Audit Date:** 2026-07-25
**Feature Folder:** `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415`
**Base Branch:** `main`
**Head Branch:** `bug/codex-pretooluse-hook-transport-415`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review
**Template source:** bundled asset `extensions/drm-copilot/resources/templates/policy_audit/feature-audit.yyyy-MM-ddTHH-mm.md` (the identical file the MCP selector `feature-audit-template` resolves; the MCP tool itself was unavailable in this session).

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main`; supplied by the delegating workflow and confirmed locally)
- **Head branch/commit:** `bug/codex-pretooluse-hook-transport-415` (commit `ee98ca7fb69901f541ae10cf8f63f46262f3e6d5`)
- **Merge base:** `009808510363081d0db7684f7b555f2ded4b0b7c` (confirmed by `git merge-base HEAD origin/main`)
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (current for the head SHA)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt` and local `git diff 00980851..HEAD`
  - Feature evidence: `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/evidence/**` (27 artifacts across `baseline/`, `regression-testing/`, `qa-gates/`, `other/`)
  - Additional evidence: independent re-execution by this review — 5 Pester suites (59 tests), pytest parity (8 tests), Black, Ruff, Pyright, full-tree `.codex` parity `diff -r`, config matcher-group counts, line-count measurement, coverage-XML re-parse
- **Feature folder used:** `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415` (single-version feature; no `v*/` subfolders)
- **Requirements source:** `spec.md` (sole authoritative AC source)
- **Work mode resolution note:** explicit persisted marker `- Work Mode: full-bug` at `issue.md:12`; `spec.md:9` confirms it is the sole AC source and that `user-story.md` is intentionally absent (correct for `full-bug`).
- **Scope note:** Audit scope is the full branch diff against the merge base (59 files). The executor left all 12 spec AC checkboxes unticked per plan task `[P8-T10]` (check-off designated as a review-time action); each criterion below was verified independently by this review before check-off. Working tree is clean at the head commit; the pre-branch uncommitted `.codex/config.toml` ordering swap was discarded, and the untracked `.codex/state/` directory no longer exists.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/spec.md` — only source (`## Acceptance Criteria`, 12 checkbox items)

### Acceptance criteria

1. Every handler registered in `.codex/config.toml` exits 0 with empty stdout and empty stderr for a valid safe payload for EVERY tool name its matcher admits, verified by the config-driven process-level Pester integration case (registrations parsed from `.codex/config.toml`; output captured under `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/evidence/regression-testing/`).
2. For each handler with a deny policy, a representative forbidden payload yields exit 0 and exactly the native envelope `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"..."}}` on stdout, with no legacy `decision` key present, asserted by process-level Pester cases (batch-budget forbidden cases at unit level via injected state, per the existing suite pattern).
3. A well-formed `apply_patch` payload whose `tool_input` carries neither `file_path` nor apply-patch file markers yields exit 0 with empty stdout (allow) for every handler in the `^(apply_patch|Edit|Write)$` group, asserted by a process-level Pester case.
4. Malformed stdin yields exit 2, empty stdout, and nonempty stderr as follows: empty input and invalid JSON for EVERY registered handler; missing/null `tool_input` for every handler in the `^(apply_patch|Edit|Write)$` group (seven non-implicated registered handlers measurably exit 0 on missing/null `tool_input` today and must not be behaviorally changed). `enforce-completion-consistency.ps1`'s stderr names `enforce-completion-consistency` (not `enforce-checkpoint-monotonic`). Asserted by process-level Pester cases.
5. Poisoned `CLAUDE_TOOL_INPUT` / `CLAUDE_SESSION_ID` (and other `CLAUDE_*`) environment variables do not alter any handler's behavior; results depend only on stdin. Verified by the poisoned-environment process harness plus the static assertion that no hook reads `$env:CLAUDE_` (`legacy-codex-hook-contracts.Tests.ps1`).
6. Every hook registration present in `.codex/config.toml` before the change is still present after it, with matchers unchanged, verified by `git diff` of the registration blocks and the passing config-driven integration case.
7. Each handler's allow/deny policy outcome for previously reachable `apply_patch` payloads is unchanged (checkpoint fail-closed denies remain denies), verified by the existing deny-path and fail-closed Pester cases in `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` continuing to pass without policy-assertion changes.
8. Root `.codex/` and the bundled copy at `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/` are byte-identical, asserted by passing runs of `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1`, `tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1`, and `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`; the bundle-only `enforce-pr-author-skill.ps1` is deleted with an issue #335 cross-reference note recorded in the evidence tree.
9. The new shared transport module exists under `.codex/hooks/`, is entrypoint-free, is ≤ 500 lines (as are all changed hook files), is mirrored byte-for-byte into the bundle, and is listed in the Pester parity/static lists and `pack-manifests/core.json`, verified by the passing parity and manifest assertions in the Pester suites.
10. No file under `.claude/` (including any bundled `.claude` copy) is created, modified, or deleted, verified by `git diff --stat` showing no `.claude/` paths in the change set.
11. The PowerShell quality loop passes in order: `mcp__drm-copilot__run_poshqc_format` → `mcp__drm-copilot__run_poshqc_analyze` → `mcp__drm-copilot__run_poshqc_test`, all stages clean in a single pass, with results captured under `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/evidence/qa-gates/`.
12. Line coverage >= 85% and branch coverage >= 75% (branch coverage where the toolchain measures it), evidenced by the `run_poshqc_test` coverage output and the pytest parity run, captured under `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/evidence/qa-gates/`.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Every registered handler exits 0 for every admitted tool name (config-driven) | PASS | `codex-pretooluse-integration.Tests.ps1` derives 18 registrations / 17 handlers / 59 admitted combinations from `.codex/config.toml` and asserts exit 0 + empty stdout for each; a guard case prevents a vacuous parse. Re-run green by this review. Output captured at `evidence/regression-testing/pass-after.2026-07-25T20-46.md`. | `Invoke-Pester -Path tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` | 33 new-suite tests, 0 failures in the review re-run. |
| 2 | Forbidden payload → exit 0 + exact native deny envelope, no legacy `decision` key | PASS | 15 process-level deny cases (purity ×6, evidence-locations ×3, checkpoint ×6) assert the parsed envelope fields and `decision`-key absence; batch-budget forbidden cases remain unit-level via injected state per the existing pattern; preimplementation-gate denies asserted unit-level with `-CheckpointRaw '{}'`. Re-run green. | `Invoke-Pester -Path tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1` | Envelope shape verified against spec Technical Specifications item 4. |
| 3 | Unmapped well-formed `apply_patch` → exit 0, empty stdout, all 8 group handlers | PASS | Parameterized cases for `command:''` and `command:'noop'` across all 8 group handlers (16 spawns), re-run green; fail-before table shows 14 of these 16 previously exited 2. | `Invoke-Pester -Path tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1`; `evidence/regression-testing/fail-before.2026-07-25T19-30.md` | Second half of the defect (spec.md:57). |
| 4 | Malformed stdin → exit 2/empty stdout/nonempty stderr (scoped); self-naming stderr | PASS | Empty stdin + invalid JSON across all 17 registered handlers (34 spawns); missing/null `tool_input` across the 8 group handlers (16 spawns, scoped so the 7 non-implicated handlers stay behaviorally unchanged); dedicated case asserts `enforce-completion-consistency` names itself and not its neighbor. Re-run green. | `Invoke-Pester -Path tests/scripts/codex-hooks` | Includes the latent enforce-evidence-locations empty-stdin fix (previously silent-allow exit 0, now exit 2) — spec-conforming, with fail-before evidence. |
| 5 | Poisoned `CLAUDE_*` env has no effect; static no-`$env:CLAUDE_` assertion | PASS | Every spawn in all three suites bakes poisoned `CLAUDE_TOOL_INPUT`/`CLAUDE_SESSION_ID` into `ProcessStartInfo.Environment` (~130 spawns); static parity case asserts no `$env:CLAUDE_` across hooks and the shared module. Re-run green. | `Invoke-Pester -Path tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | Module docstring deliberately avoids the literal token so the static assertion measures code. |
| 6 | Registrations and matchers unchanged | PASS | `git diff 00980851..HEAD -- .codex/config.toml` is empty (verified by this review); matcher groups carry 5 / 5 / 8 handler blocks (independently counted from `config.toml` lines 119-232); config-driven integration case passes against the live registrations. | `git diff 00980851..HEAD -- .codex/config.toml`; `grep -n -E '^\[\[hooks|matcher =|command =' .codex/config.toml` | Hard Constraint 2 satisfied; the pre-branch uncommitted ordering swap was discarded, not committed. |
| 7 | Policy outcomes for previously reachable `apply_patch` payloads unchanged | PASS | Per-hunk diff inspection of all 8 hooks by this review: changes confined to docstrings, dot-source insertions, deleted transport functions, and entrypoints; every policy function byte-unchanged. Pre-existing deny-path/fail-closed cases in the legacy suite pass without assertion changes (only list additions and mapping-unit retargets with identical expected values). | `git diff 00980851..HEAD -- .codex/hooks/`; `Invoke-Pester -Path tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | Executor deviation 1 (checkpoint `Edit` deny per measured policy at `enforce-checkpoint-monotonic.ps1:230-239`) preserves policy; the deny is the existing policy newly reachable, per spec.md:203. |
| 8 | Root/bundle byte-identity; orphan deleted with #335 note | PASS | This review ran `diff -r .codex extensions/.../codex-and-agents-customizations/.codex` — clean across the full tree (stronger than per-file hash lists). All four named gates re-run green (12 + 10 + 4 Pester tests, 8 pytest tests). `enforce-pr-author-skill.ps1` is the single deletion in the diff; the #335 note exists at `evidence/regression-testing/issue-335-bundle-orphan-removal.2026-07-25T19-33.md`. | `diff -r .codex extensions/drm-copilot/resources/codex-and-agents-customizations/.codex`; `Invoke-Pester ...`; `poetry run pytest ...` | Hard Constraint 4 satisfied. |
| 9 | Shared module: exists, entrypoint-free, ≤ 500 lines, mirrored, listed | PASS | Module read in full by this review: functions and script constants only, no stdin read, no entrypoint. Line counts measured: module 474; all changed hooks ≤ 438. Parity hash covers it (bundle byte-identical); `$script:SharedModuleNames`/`$script:StaticCheckNames` additions in the legacy suite; `core.json` gains `.codex/hooks/codex-pretooluse-file-mapping.ps1` with a dedicated manifest assertion. | `pwsh -Command "(Get-Content -LiteralPath <file>).Count"`; suite re-runs | Extraction also reduced `enforce-checkpoint-monotonic.ps1` 420→339 lines. |
| 10 | No `.claude/` file created, modified, or deleted | PASS | `git diff --stat 00980851..HEAD -- .claude/ '**/.claude/**'` is empty (verified by this review); working tree clean. | `git diff --stat 00980851..HEAD -- .claude/ '**/.claude/**'` | Hard Constraint 1 satisfied, including bundled `.claude` copies. |
| 11 | PoshQC loop clean in a single pass, evidence under `qa-gates/` | PASS | Executor evidence: format exit 0 (no changes) → analyze exit 0 (0 findings) → test exit 0 (1391 tests, 0 failures), all recorded with `Timestamp:`/`Command:`/`EXIT_CODE:` under `evidence/qa-gates/` (`final-poshqc-format.2026-07-25T20-58.md`, `final-poshqc-analyze.2026-07-25T20-59.md`, `final-poshqc-test.2026-07-25T21-02.md`). This review corroborated the test stage by re-running the 5 affected suites (59 tests, 0 failures); the earlier Phase-7 analyzer finding was fixed at cause with a loop restart, and the final pass is clean. | Evidence inspection; `Invoke-Pester` re-runs | MCP PoshQC tools were not available to this review session; the executor's canonical qa-gates artifacts plus independent targeted re-runs are the verification basis. |
| 12 | Line coverage ≥ 85%; branch coverage ≥ 75% where the toolchain measures it | PASS | Post-change line coverage 90.15% (2151/2386) re-derived by this review directly from `artifacts/pester/powershell-coverage.xml`, above the 85% threshold; baseline 90.22% recorded at `evidence/baseline/phase0-poshqc-test.2026-07-25T19-16.md`; comparison at `evidence/qa-gates/coverage-comparison.2026-07-25T21-06.md`; pytest parity run green. Branch coverage is not emitted by this toolchain (all `mb`/`cb` attributes zero, no BRANCH counter — verified), so the criterion's own qualifier applies. | `pwsh` JaCoCo counter parse; `Select-String 'mb="[1-9]'` (no match) | PASS as written. Note: the policy audit independently records Blocking finding B1 — the changed production files are largely outside the measured set — as a policy-level gap; it does not negate this criterion's literal threshold, which is met on the measured set. |

---

## Summary

**Overall Feature Readiness:** PASS on acceptance criteria — with PR flow gated by the policy audit's two Blocking coverage-evidence findings (B1, B2), which are policy-level requirements outside the spec's AC text. See `policy-audit.2026-07-25T21-03.md` and `remediation-inputs.2026-07-25T21-03.md`.

**Criteria summary:**
- **PASS:** 12 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None at the acceptance-criteria level. (PR readiness is separately blocked by policy-audit findings B1 and B2 — coverage instrumentation for the changed PowerShell surface and the absent Python coverage artifact.)

**Recommended follow-up verification steps:**

1. Execute the remediation in `remediation-inputs.2026-07-25T21-03.md` (R1: expand `CodeCoverage.Path`; R2: capture Python coverage evidence), then re-run `mcp__drm-copilot__run_poshqc_test` and record per-file coverage for the 8 changed hooks and the new module.
2. Re-audit coverage sections only; all other sections of this audit are independently verified at head `ee98ca7f` and remain valid unless the remediation changes production files.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- All 12 criteria evaluated **PASS** above were checked off (`- [ ]` → `- [x]`) in the authoritative source file `spec.md` by this review, after individual verification. The executor had intentionally left them unticked per plan task `[P8-T10]`, which designates check-off as a review-time action.
- No criterion text was modified; only checkbox states changed.
- No new criteria were added.

### AC Status Summary

- Source: `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/spec.md`
- Total AC items: 12
- Checked off (delivered): 12
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 12 | 12 | 0 | Checkbox-backed; sole authoritative source for `full-bug` |
