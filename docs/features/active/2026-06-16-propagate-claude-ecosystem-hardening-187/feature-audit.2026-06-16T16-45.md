# Feature Audit: propagate-claude-ecosystem-hardening (#187)

**Audit Date:** 2026-06-16
**Feature Folder:** `docs/features/active/2026-06-16-propagate-claude-ecosystem-hardening-187`
**Base Branch:** `main`
**Head Branch:** `feature/propagate-claude-ecosystem-hardening-187`
**Work Mode:** `full-feature`
**Audit Type:** Post-remediation acceptance verification

---

## Scope and Baseline

- **Base branch:** `main` (commit `c903b1f9531a164a4470524171b17ef63759ee93`)
- **Head branch/commit:** `feature/propagate-claude-ecosystem-hardening-187` (commit `e1cf8f67c1a997a27496ecd0ae5ea55443b41a94`)
- **Merge base:** `c903b1f9531a164a4470524171b17ef63759ee93`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-06-16-propagate-claude-ecosystem-hardening-187/evidence/**`
  - Coverage artifacts: `artifacts/python/lcov.info`, repo-root `coverage.xml`
- **Feature folder used:** `docs/features/active/2026-06-16-propagate-claude-ecosystem-hardening-187`
- **Requirements source:** `spec.md` and `user-story.md` (full-feature work mode).
- **Work mode resolution note:** `issue.md` line 10 declares `- Work Mode: full-feature`, so `spec.md` and `user-story.md` are the authoritative AC sources.
- **Scope note:** Full branch-vs-base audit of all 64 changed paths. The `packages/mcp-server/resources/**` mirror is gitignored and does not appear in the tracked diff; on-disk byte-identical parity was verified per file.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `spec.md` — primary source (item-grouped criteria, items 1-7 + mirror/toolchain block)
- `user-story.md` — secondary source (nine roll-up criteria)

### Acceptance criteria

#### From spec.md

1. (Item 1) `Test-HumanInteractionShape` added to `validate-orchestrator-output.ps1` (canonical + both mirrors) and wired into `Invoke-OrchestratorOutputValidation`.
2. (Item 1) The function passes when `human_interaction` is absent; blocks missing `requirements`; blocks missing `response`; blocks out-of-enum `response`; blocks `response == halt`; blocks `response == exception` with empty/non-existent `runbook_path`.
3. (Item 1) Pester unit tests cover absent-key, missing-requirements, missing-response, invalid-enum, halt, and exception-without-runbook cases using the `$FileExistsCheck` seam.
4. (Item 2) `Test-AutomationFeasibilitySection` added to `validate-task-researcher-output.ps1` (canonical + both mirrors) and wired into `Invoke-TaskResearcherOutputValidation`.
5. (Item 2) Passes non-matching artifacts; for artifacts matching `autonomous-execution|human-interaction` requires an `## Automation Feasibility` heading.
6. (Item 2) Pester tests cover matching (present/absent) and non-matching artifacts using the `$ReadFileContent` seam.
7. (Item 3) `## Autonomous-Execution Mandate` section in `orchestrate/SKILL.md` (canonical + both mirrors), defining detection points, the three permitted responses, the exception-runbook requirement, and the three named enforcement points.
8. (Item 4) `skills/human-exception-runbook/SKILL.md` and `example.runbook.md` exist (canonical + both mirrors), defining canonical runbook path, five required sections, MCP-first/web-second rule.
9. (Item 5) `validate_orchestrator_state.py` enforces the `human_interaction` invariants using the existing error-string style; schema not copied verbatim.
10. (Item 5) pytest coverage includes the new invariants and a backward-compatibility case.
11. (Item 5) `rules/orchestrator-state.md` documents the invariants without regressing existing prose.
12. (Item 6) `general-unit-test.md` contains `## Coverage Exclusion Policy` and `## Test File Location` (canonical + both mirrors).
13. (Item 7) `remediation-handoff-atomic-planner/SKILL.md` matches the expanded SOURCE (Full Handoff Chain, Required Artifacts, Plan Shape, Preflight Sub-Loop, Exit Gate).
14. (Mirror) Every canonical `.claude/` file changed by items 1-7 is mirrored byte-identically to both bundled mirrors.
15. (Mirror) `settings.local.json` and `agent-memory/**` are NOT propagated from SOURCE.
16. (Toolchain) Bundle-sync contract tests pass.
17. (Toolchain) PowerShell toolchain passes.
18. (Toolchain) Python toolchain passes.

#### From user-story.md

U1. `Test-HumanInteractionShape` present and wired with the six Pester cases.
U2. `Test-AutomationFeasibilitySection` present with matching/non-matching Pester coverage.
U3. `## Autonomous-Execution Mandate` in `orchestrate/SKILL.md` (canonical + both mirrors).
U4. `human-exception-runbook/SKILL.md` and `example.runbook.md` exist (canonical + both mirrors).
U5. `validate_orchestrator_state.py` enforces the invariants with pytest coverage; `orchestrator-state.md` documents them.
U6. `general-unit-test.md` contains the two sections (canonical + both mirrors).
U7. `remediation-handoff-atomic-planner/SKILL.md` matches expanded source (canonical + both mirrors).
U8. Bundle-sync contract tests pass.
U9. Full toolchain (PowerShell, Python, contract tests) passes.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Item 1 added + wired | PASS | `validate-orchestrator-output.ps1` lines 60-146 define `Test-HumanInteractionShape`; lines 211-219 wire it into `Invoke-OrchestratorOutputValidation`. Mirror parity identical. | `grep -n "Test-HumanInteractionShape\|Invoke-OrchestratorOutputValidation"`; `cmp` per mirror | |
| 2 | Item 1 rejection order | PASS | Function implements absent-key pass, missing-requirements, missing/blank response, out-of-enum, halt, exception-empty/non-existent runbook in order. | diff inspection lines 88-145 | Uses `$FileExistsCheck` for the existence branch. |
| 3 | Item 1 Pester coverage | PASS | 7 new `It` blocks; Pester 36 pass. | `Invoke-Pester` | |
| 4 | Item 2 added + wired | PASS | `validate-task-researcher-output.ps1` line 86 defines `Test-AutomationFeasibilitySection`; line 192 wires it into `Invoke-TaskResearcherOutputValidation`. | `grep -n` | |
| 5 | Item 2 matching/non-matching | PASS | Function reads via `$ReadFileContent` (line 131) and requires `## Automation Feasibility` for matching artifacts. | diff inspection | |
| 6 | Item 2 Pester coverage | PASS | Matching present/absent + non-matching cases; included in 36 pass. | `Invoke-Pester` | |
| 7 | Item 3 mandate section | PASS | `orchestrate/SKILL.md` line 27 `## Autonomous-Execution Mandate`; lines 41-43 three responses; line 47 exception-runbook; lines 53-54 enforcement points. Mirror identical. | `grep -n`; `cmp` | |
| 8 | Item 4 runbook skill | PASS | `human-exception-runbook/SKILL.md` (canonical path line 18, five sections, MCP-first rule line 33) and `example.runbook.md` exist; mirror identical. | `ls`; `grep -n`; `cmp` | |
| 9 | Item 5 validator enforces, no verbatim schema | PASS | `validate_orchestrator_state.py` imports `_validate_human_interaction` and calls it under `HUMAN_INTERACTION_KEY in state_map`; helper docstring states no schema import; `grep` for schema ref returns none. | `grep -rn "orchestrator-state.schema.json" .claude/` (no match) | F2 resolved. |
| 10 | Item 5 pytest + backward-compat | PASS | 8 scenarios incl. absent-key backward-compat; 25 pass; helper 100% line/branch. | `poetry run pytest ... -q`; `artifacts/python/lcov.info` | |
| 11 | Item 5 orchestrator-state.md docs, no regression | PASS | `orchestrator-state.md` documents 3 `human_interaction` invariants (lines 27-38) alongside the 3 original remediation invariants (still present, count=3). | `grep -c` original invariants | |
| 12 | Item 6 general-unit-test sections | PASS | `general-unit-test.md` line 31 `## Coverage Exclusion Policy`, line 76 `## Test File Location`. Mirror identical. | `grep -n`; `cmp` | |
| 13 | Item 7 expanded handoff skill | PASS | `remediation-handoff-atomic-planner/SKILL.md` contains Full Handoff Chain (20), Required Artifacts (63), Plan Shape (80), Preflight Sub-Loop (92), Exit Gate (107). Mirror identical. | `grep -n`; `cmp` | |
| 14 | Mirror parity (both mirrors) | PASS | All 8 changed canonical `.claude` files byte-identical in `extensions/...` and `packages/mcp-server/...`. | per-file `cmp` all identical | packages mirror gitignored but on-disk identical. |
| 15 | settings.local.json / agent-memory not propagated | PASS | Neither path appears in the branch diff. | `git diff --name-only ... | grep -E "settings.local.json|agent-memory"` (none) | |
| 16 | Bundle-sync contract tests pass | PASS | 13 passed. | `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_customizations.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q` | |
| 17 | PowerShell toolchain passes | PASS | Format clean, analyze 0 findings, Pester 36 pass; hook line coverage 89.0% / 88.1%. | `run_poshqc_*`; `Invoke-Pester`; `coverage.xml` | |
| 18 | Python toolchain passes | PASS | Black clean, Ruff clean, Pyright clean, pytest 25 pass; validator 90.0% line / 78.1% branch, helper 100/100. | black/ruff/pyright/pytest | |
| U1-U9 | user-story roll-ups | PASS | Each maps directly to spec items 1-7 + toolchain above; all evidenced PASS. | as above | |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 18 spec criteria + 9 user-story criteria = 27 criteria
- **PARTIAL:** 0
- **UNVERIFIED:** 0
- **FAIL:** 0

**Prior remediation findings:**
- F1 (file-size limit): RESOLVED. `validate_orchestrator_state.py` 426 lines; new `_orchestrator_state_human_interaction.py` 127 lines; no diff file exceeds 500 lines.
- F2 (non-existent schema reference): RESOLVED. No `.claude` file references `orchestrator-state.schema.json`.

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. None required for merge. Optionally, consider an automated parity gate for the gitignored `packages/mcp-server/resources/**` mirror in a future change to prevent silent drift.

---

## Acceptance Criteria Check-Off

All acceptance criteria in `spec.md` (lines 33-64) and `user-story.md` (lines 51-59) were already marked `[x]` by the executor and are confirmed PASS by this audit. No checkbox state change is required; all delivered criteria are verified.

### AC Status Summary

- Source: `spec.md`, `user-story.md`
- Total AC items: spec 18 (item-grouped) / user-story 9
- Checked off (delivered): spec 18 / user-story 9
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 18 | 18 | 0 | Checkbox-backed; all `[x]` and verified PASS. |
| `user-story.md` | 9 | 9 | 0 | Checkbox-backed; all `[x]` and verified PASS. |

No source-file checkbox change was made because every criterion was already checked and is confirmed PASS.
