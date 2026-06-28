# Feature Audit: harden-claude-pretooluse-hook-schema (Issue #259)

**Audit Date:** 2026-06-27
**Feature Folder:** `docs/features/active/2026-06-27-harden-claude-pretooluse-hook-schema-259`
**Base Branch:** `main`
**Head Branch:** `feature/harden-claude-pretooluse-hook-schema-259`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (commit `fc22de3c4b3cd9b3b82bfd91c9944714121f6fbd`)
- **Head branch/commit:** `feature/harden-claude-pretooluse-hook-schema-259` (commit `a43fd9ae158529584644de4fb1af68d886474f92`)
- **Merge base:** `fc22de3c4b3cd9b3b82bfd91c9944714121f6fbd`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-06-27-harden-claude-pretooluse-hook-schema-259/evidence/**`
  - Additional evidence (generated this review): `evidence/coverage/absent-hooks-coverage.2026-06-27T22-18.xml`
- **Feature folder used:** `docs/features/active/2026-06-27-harden-claude-pretooluse-hook-schema-259`
- **Requirements source:** `spec.md` and `user-story.md` (work mode `full-feature`)
- **Work mode resolution note:** `issue.md` carries the explicit persisted marker `- Work Mode: full-feature`. Per the work-mode contract, the authoritative AC sources are `spec.md` (Definition of Done) and `user-story.md` (Acceptance Criteria).
- **Scope note:** The branch diff contains only PowerShell (`.ps1`, 40 files) and Markdown (`.md`, 42 files). The full feature-vs-base diff was audited; scope was not narrowed.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `user-story.md` — primary (Acceptance Criteria section)
- `spec.md` — primary (Definition of Done; identical criterion set)

The seven criteria are identical in both files. They are transcribed once below.

### Acceptance criteria

1. Every PreToolUse-registered hook emits the `hookSpecificOutput`/`permissionDecision=deny` shape for blocks and the `permissionDecision=allow` shape for allows; no PreToolUse hook emits a top-level `decision`/`reason` shape or uses `exit 1` to block.
2. `validate-bash` blocks via a pure detector plus a deny-decision builder that writes the `hookSpecificOutput` form, never `exit 1`.
3. A serialize-then-parse contract test asserts `permissionDecision=deny` and `hookEventName=PreToolUse` for every PreToolUse hook.
4. SubagentStop validator hardening (Parts 3.1–3.4) is ported without changing the SubagentStop block form.
5. The checkpoint-monotonic prerequisite gate (Part 4) and new PreToolUse gate hooks (Part 5) are present, registered, and tested on the correct schema.
6. Bundled mirror hooks match runtime hooks; bundle-parity contract tests pass.
7. PoshQC format clean, PSScriptAnalyzer 0 findings on changed files, all Pester hook tests pass, every touched `.ps1` <= 500 lines.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | All PreToolUse hooks emit `hookSpecificOutput`/`permissionDecision`; no top-level `decision` or deny `exit 1` | PASS | 0 matches for `decision\s*=\s*'(block\|allow)'` in `.claude/hooks/*.ps1`; 23 occurrences of `permissionDecision='deny'` across all 13 hooks; only `exit 1` in always-allow hooks is a doc comment | `rg "decision\s*=\s*'(block\|allow)'" .claude/hooks`; `rg "permissionDecision\s*=\s*'deny'" .claude/hooks` | Independently re-verified during this review |
| 2 | `validate-bash` uses pure detector + deny-builder writing `hookSpecificOutput`, never `exit 1` | PASS | `validate-bash.ps1` defines `Get-BlockedPatternMatch`, `Get-BashDenyDecision`, `Invoke-ValidateBashDecision`; deny path emits envelope + `exit 0`; dot-sourcing guard at line 165 | Read `.claude/hooks/validate-bash.ps1`; contract test `It 'validate-bash.ps1 emits a PreToolUse deny shape'` | Pure functions 100% line-covered |
| 3 | Serialize-then-parse contract test asserts `permissionDecision=deny` and `hookEventName=PreToolUse` for every hook | PASS | `PreToolUseSchema.Contract.Tests.ps1` has 13 `It` blocks, each asserting `hookEventName == 'PreToolUse'` and `permissionDecision == 'deny'` via `Assert-PreToolUseDenyShape`; 13 tests / 0 failures | `mcp__drm-copilot__run_poshqc_test` (contract test: 13 passed) | One DENY assertion per hook |
| 4 | SubagentStop validator hardening ported without changing the block form | PASS | None of `validate-executor-output`, `validate-feature-review-coverage`, `validate-orchestrator-output`, `validate-task-researcher-output` appear in the branch diff; 0 `permissionDecision`/`hookSpecificOutput` in those files; they retain top-level `decision:block` + `exit 1` | `git diff --name-only fc22de3..a43fd9a \| grep validate-` (none) | SubagentStop validators are unchanged; hardening was pre-existing per spec Implementation Strategy |
| 5 | Checkpoint-monotonic gate + new PreToolUse gate hooks present, registered, tested on correct schema | PASS | `enforce-checkpoint-monotonic.ps1`, `enforce-orchestration-preimplementation-gate.ps1`, `enforce-powershell-batch-budget.ps1`, `check-powershell-test-purity.ps1`, `validate-bash.ps1` registered in `.claude/settings.json`; contract + per-hook tests pass; checkpoint-monotonic deny tested when `S3_promotion`/`S4_atomic_planning` missing | `rg '<hook>\.ps1' .claude/settings.json`; contract test It blocks | All assert the `hookSpecificOutput` shape |
| 6 | Bundled mirror hooks match runtime; bundle-parity contract tests pass | PASS | All 13 changed runtime hooks byte-identical to their mirrors (`cmp` returned no divergence); pytest parity 7 passed | `cmp` per file (ALL_RUNTIME_MIRROR_BYTE_IDENTICAL); `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | Pre-existing `-ErrorAction Stop` divergence resolved in Phase 1 |
| 7 | PoshQC format clean, PSScriptAnalyzer 0 findings, all Pester pass, every touched `.ps1` <= 500 lines | PASS | Format EXIT 0; analyze 0 findings EXIT 0; Pester 832 tests / 0 failures; max file 473 lines | `mcp__drm-copilot__run_poshqc_format`; `..._analyze`; `..._test`; `line-count-proof` | Coverage: line >= 85% on every changed file; branch numeric UNVERIFIED (harness emits no BRANCH counter) — does not gate this criterion |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 7 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. Optional: perform the documented out-of-band live-harness denial check (not an automated test by design) to confirm the harness honors the new envelope in the runtime environment.
2. Optional: add the 8 enforce-* hooks to the standing `pester.runsettings.psd1` `CodeCoverage.Path` so future reviews obtain per-file coverage without a scoped re-run.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules, all seven criteria evaluated PASS. Each criterion below is mapped to its PASS status and supporting evidence, then confirmed checked off `[x]` in the authoritative source files.

| # | Acceptance criterion (from `issue.md` / `spec.md` / `user-story.md`) | Status | Supporting evidence |
|---|----------------------------------------------------------------------|--------|---------------------|
| 1 | Every PreToolUse-registered hook emits the `hookSpecificOutput`/`permissionDecision=deny` shape for blocks and the `permissionDecision=allow` shape for allows; no PreToolUse hook emits a top-level `decision`/`reason` shape or uses `exit 1` to block. | PASS | 0 matches for `decision\s*=\s*'(block\|allow)'` in `.claude/hooks/*.ps1`; 23 occurrences of `permissionDecision='deny'` across all 13 hooks; only `exit 1` in always-allow hooks is a doc comment. See Acceptance Criteria Evaluation row 1. |
| 2 | `validate-bash` blocks via a pure detector plus a deny-decision builder that writes the `hookSpecificOutput` form, never `exit 1`. | PASS | `validate-bash.ps1` defines `Get-BlockedPatternMatch`, `Get-BashDenyDecision`, `Invoke-ValidateBashDecision`; deny path emits envelope + `exit 0`; dot-sourcing guard at line 165; pure functions 100% line-covered. See row 2. |
| 3 | A serialize-then-parse contract test asserts `permissionDecision=deny` and `hookEventName=PreToolUse` for every PreToolUse hook. | PASS | `PreToolUseSchema.Contract.Tests.ps1` has 13 `It` blocks asserting `hookEventName == 'PreToolUse'` and `permissionDecision == 'deny'`; 13 tests / 0 failures. See row 3. |
| 4 | SubagentStop validator hardening (Parts 3.1–3.4) is ported without changing the SubagentStop block form. | PASS | SubagentStop validators do not appear in the branch diff; 0 `permissionDecision`/`hookSpecificOutput` in those files; they retain top-level `decision:block` + `exit 1`. See row 4. |
| 5 | The checkpoint-monotonic prerequisite gate (Part 4) and new PreToolUse gate hooks (Part 5) are present, registered, and tested on the correct schema. | PASS | `enforce-checkpoint-monotonic.ps1`, `enforce-orchestration-preimplementation-gate.ps1`, `enforce-powershell-batch-budget.ps1`, `check-powershell-test-purity.ps1`, `validate-bash.ps1` registered in `.claude/settings.json`; contract + per-hook tests pass on the `hookSpecificOutput` shape. See row 5. |
| 6 | Bundled mirror hooks match runtime hooks; bundle-parity contract tests pass. | PASS | All 13 changed runtime hooks byte-identical to their mirrors (`cmp` no divergence); pytest parity 7 passed. See row 6. |
| 7 | PoshQC format clean, PSScriptAnalyzer 0 findings on changed files, all Pester hook tests pass, every touched `.ps1` <= 500 lines. | PASS | Format EXIT 0; analyze 0 findings EXIT 0; Pester 832 tests / 0 failures; max file 473 lines; line coverage >= 85% on every changed file. See row 7. |

All seven criteria are PASS.

### AC Status Summary

- Source: `user-story.md` and `spec.md`
- Total AC items: 7 (per file)
- Checked off (delivered): 7
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `user-story.md` | 7 | 7 | 0 | Checkbox-backed; all pre-checked, confirmed correct |
| `spec.md` | 7 | 7 | 0 | Checkbox-backed (Definition of Done); all pre-checked, confirmed correct |

No source-file checkbox change was made because all seven items were already `[x]` and the evidence confirms each as PASS.
