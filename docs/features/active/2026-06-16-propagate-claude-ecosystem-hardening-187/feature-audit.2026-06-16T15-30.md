# Feature Audit: propagate-claude-ecosystem-hardening (#187)

**Audit Date:** 2026-06-16
**Feature Folder:** `docs/features/active/2026-06-16-propagate-claude-ecosystem-hardening-187`
**Base Branch:** `main`
**Head Branch:** `feature/propagate-claude-ecosystem-hardening-187` @ `24353b0bf4527092832cdfaea81c37b0367614c5`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (commit `c903b1f9531a164a4470524171b17ef63759ee93`)
- **Head branch/commit:** `feature/propagate-claude-ecosystem-hardening-187` (commit `24353b0bf4527092832cdfaea81c37b0367614c5`)
- **Merge base:** `c903b1f9531a164a4470524171b17ef63759ee93`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-06-16-propagate-claude-ecosystem-hardening-187/evidence/**`
  - Direct diff: `git diff c903b1f..24353b0b`
- **Feature folder used:** `docs/features/active/2026-06-16-propagate-claude-ecosystem-hardening-187`
- **Requirements source:** `spec.md` and `user-story.md` (full-feature mode)
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-feature`, so `spec.md` and `user-story.md` are the authoritative AC sources.
- **Scope note:** Full branch-diff audit against the merge-base. The `packages/mcp-server/resources/claude-customizations/` mirror is git-ignored and therefore absent from the diff; byte-identity was verified directly in the working tree with `cmp`.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `spec.md` — primary (full Acceptance Criteria with per-item detail)
- `user-story.md` — secondary (condensed Acceptance Criteria)

### From spec.md

Item 1 — `Test-HumanInteractionShape`:
1. Added to `validate-orchestrator-output.ps1` (canonical + both mirrors) and wired into `Invoke-OrchestratorOutputValidation`.
2. Passes when `human_interaction` absent; blocks missing `requirements`, missing `response`, out-of-enum `response`, `halt`, and `exception` with empty/nonexistent `runbook_path`.
3. Pester tests cover absent-key, missing-requirements, missing-response, invalid-enum, halt, exception-without-runbook via injectable `$FileExistsCheck`.

Item 2 — `Test-AutomationFeasibilitySection`:
4. Added to `validate-task-researcher-output.ps1` (canonical + both mirrors) and wired into `Invoke-TaskResearcherOutputValidation`.
5. Passes non-matching artifacts; for `autonomous-execution|human-interaction` matches requires an `## Automation Feasibility` heading.
6. Pester tests cover matching (present/absent) and non-matching, via injectable `$ReadFileContent`.

Item 3 — Autonomous-Execution Mandate:
7. `## Autonomous-Execution Mandate` present in `orchestrate/SKILL.md` (canonical + both mirrors), with detection points, three responses, exception-runbook requirement, three named enforcement points.

Item 4 — Human-Exception Runbook skill:
8. `human-exception-runbook/SKILL.md` and `example.runbook.md` exist (canonical + both mirrors), defining canonical path, five sections, MCP-first/web-second rule.

Item 5 — `human_interaction` validator invariants:
9. `validate_orchestrator_state.py` enforces the invariants without verbatim schema copy.
10. pytest coverage includes the invariants and a backward-compat case.
11. `rules/orchestrator-state.md` documents the invariants without regressing existing prose.

Item 6 — `general-unit-test.md` sections:
12. `## Coverage Exclusion Policy` and `## Test File Location` present (canonical + both mirrors).

Item 7 — Remediation handoff skill:
13. `remediation-handoff-atomic-planner/SKILL.md` matches expanded source (Full Handoff Chain, Required Artifacts entry/exit timestamps, Plan Shape, Preflight Sub-Loop, Exit Gate).

Mirror parity and toolchain:
14. Every changed `.claude/` file mirrored byte-identically to both mirrors.
15. `settings.local.json` and `agent-memory/**` NOT propagated.
16. Bundle-sync contract tests pass.
17. PowerShell toolchain passes.
18. Python toolchain passes.

### From user-story.md

(Condensed; maps 1:1 onto the spec items above.)

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | `Test-HumanInteractionShape` added + wired | PASS | Function at `.claude/hooks/validate-orchestrator-output.ps1:60`; wired at lines 210-217 | `grep -n Test-HumanInteractionShape .claude/hooks/validate-orchestrator-output.ps1` | byte-identical in both mirrors |
| 2 | Six rejection branches + absent-key pass | PASS | Branches at lines 95-140 (absent, missing-requirements, blank-response, out-of-enum, halt, exception+runbook) | code inspection | matches SOURCE error strings |
| 3 | Pester coverage incl. `$FileExistsCheck` seam | PASS | 7 new `It` blocks; 36 tests pass | scoped `Invoke-Pester` -> 36 pass | injected seam, no temp files |
| 4 | `Test-AutomationFeasibilitySection` added + wired | PASS | Function at `.claude/hooks/validate-task-researcher-output.ps1:86`; detection pattern line 121 | `grep -n Test-AutomationFeasibilitySection ...` | byte-identical in both mirrors |
| 5 | Non-matching pass; matching requires heading | PASS | Pattern `autonomous-execution|human-interaction`; requires `## Automation Feasibility` | code inspection | filename + content detection |
| 6 | Pester coverage incl. `$ReadFileContent` seam | PASS | 9 new `It` blocks (matching present/absent, non-matching, empty content) | scoped `Invoke-Pester` | injected seam |
| 7 | `## Autonomous-Execution Mandate` in `orchestrate/SKILL.md` | PASS | Section at line 27; three responses (lines 41-43); enforcement points (lines 53-54+) | `grep -n "## Autonomous-Execution Mandate" ...` | mirrors present |
| 8 | `human-exception-runbook/SKILL.md` + `example.runbook.md` | PASS | SKILL canonical path line 18; five sections in example (Cue, Prerequisites, Step-by-step, Verification, Source and Citation); MCP-first rule line 33 | `grep -n "^## " example.runbook.md` | mirrors present |
| 9 | Python validator enforces invariants, no verbatim schema | PASS | `_validate_human_interaction` lines 111-186; no schema import; `.claude/schemas/...` file absent | `poetry run pytest ... ; ls .claude/schemas/...` | foreign-schema policy honored |
| 10 | pytest coverage incl. backward-compat | PASS | 8 tests incl. `test_no_human_interaction_is_backward_compatible`; module 88.43% line | `poetry run pytest --cov=scripts.dev_tools.validate_orchestrator_state` | 25 pass total |
| 11 | `rules/orchestrator-state.md` documents invariants, no regression | PASS | Added "Human-Interaction Scope" + "Invariants (human_interaction block)"; existing 3 remediation invariants + foreign-schema warning preserved | `git diff c903b1f..24353b0b -- .claude/rules/orchestrator-state.md` | additive only |
| 12 | `general-unit-test.md` Coverage Exclusion + Test File Location | PASS | Sections at lines 31 and 76 | `grep -n "## Coverage Exclusion Policy\|## Test File Location" ...` | mirrors present |
| 13 | `remediation-handoff-atomic-planner/SKILL.md` expanded | PASS | Full Handoff Chain (line 20), Required Artifacts entry/exit (line 63), Plan Shape, Preflight Sub-Loop, Exit Gate present | `grep -n "Full Handoff Chain\|Required Artifacts\|Preflight Sub-Loop\|Exit Gate" ...` | mirrors present |
| 14 | Every `.claude/` change byte-identical to both mirrors | PASS | All 8 files: `cmp` MATCH for extensions and mcp-server mirrors | `cmp .claude/... extensions/.../.claude/...` and `... packages/mcp-server/.../.claude/...` | mcp-server git-ignored but byte-identical in working tree |
| 15 | `settings.local.json` / `agent-memory/**` NOT propagated | PASS | Branch diff contains neither path | `git diff --name-only c903b1f..24353b0b | grep -E "settings.local.json|agent-memory/"` -> empty | Non-Goal honored |
| 16 | Bundle-sync contract tests pass | PASS | 4 passed | `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | extensions mirror parity |
| 17 | PowerShell toolchain passes | PASS | Format clean (repo settings), 0 analyzer findings, 36 Pester pass | `Invoke-Formatter` / `Invoke-ScriptAnalyzer` / `Invoke-Pester` | see policy-audit Section 7 |
| 18 | Python toolchain passes | PASS | Black clean, Ruff clean, Pyright 0 errors, 25 pytest pass | `poetry run black/ruff/pyright/pytest` | see policy-audit Section 7 |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

All 18 acceptance criteria across `spec.md` and `user-story.md` are met (PASS). The feature is functionally complete: both new PowerShell gates and the Python validator invariants are present, wired, tested, backward-compatible, and mirrored byte-identically into both bundled mirrors; the documentation/skill items are present; non-goals are honored; and all toolchain and contract checks pass.

Readiness is downgraded to NEEDS REVISION not because of an unmet acceptance criterion, but because of a separate `general-code-change.md` policy violation surfaced during the audit: `scripts/dev_tools/validate_orchestrator_state.py` is 505 lines, exceeding the 500-line hard limit. This must be remediated before merge. See `policy-audit.2026-06-16T15-30.md` Section 8 and `code-review.2026-06-16T15-30.md` Findings Table (Major).

**Criteria summary:**
- **PASS:** 18 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS (merge readiness, not AC):**
1. `validate_orchestrator_state.py` exceeds the 500-line hard limit (505 lines). Split into a sibling module.
2. `orchestrate/SKILL.md` and the orchestrator-hook docstring reference a non-existent `.claude/schemas/orchestrator-state.schema.json`. Reword or add a compliant repo-local schema.

**Recommended follow-up verification steps:**
1. After splitting the Python module, re-run `poetry run black/ruff/pyright/pytest` and confirm `wc -l` < 500.
2. Re-verify mirror parity (`cmp`) for any `.claude/` file touched during remediation.

---

## Acceptance Criteria Check-Off

Both authoritative source files already represent all acceptance criteria as `- [x]` (delivered). All 18 criteria evaluate as PASS in this audit, so the existing checked state is correct; no checkbox transitions are required. The source files were not modified by this review.

### AC Status Summary

- Source: `spec.md` and `user-story.md`
- Total AC items: 18 (spec.md detailed) / 9 (user-story.md condensed)
- Checked off (delivered): all (already `[x]` in both files)
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 18 | 18 | 0 | Checkbox-backed; all already `[x]`, all PASS |
| `user-story.md` | 9 | 9 | 0 | Checkbox-backed; all already `[x]`, all PASS |

Note: No source-file checkbox change was made because every criterion was already checked and all evaluate PASS.
