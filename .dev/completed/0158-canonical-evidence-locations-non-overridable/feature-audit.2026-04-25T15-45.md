# Feature Audit: canonical-evidence-locations-non-overridable (#158)

**Audit Date:** 2026-04-25T15-45
**Branch:** feature/canonical-evidence-locations-non-overridable-158
**Base Branch:** development (merge base: `79f83001617f3104d5d2f108cc41398e689bc81f`)
**Work Mode:** full-feature
**AC Sources:** `spec.md` (12 items + 6 test conditions) and `user-story.md` (12 items)

---

## Scope and Baseline

**Feature branch:** `feature/canonical-evidence-locations-non-overridable-158`
**Base branch:** `development` (merge base: `79f83001617f3104d5d2f108cc41398e689bc81f`)
**Work mode:** full-feature
**AC sources:** `spec.md` (12 items + 6 test conditions) and `user-story.md` (12 items)

**Baseline state:** Pre-change toolchain run (commit `79f83001617f3104d5d2f108cc41398e689bc81f`):
- Python: 993 passed, 1 failed (pre-existing), 14 skipped; Black/Ruff/Pyright all pass
- PowerShell: 325 pass, 0 fail, 7 skipped; PoshQC format/analyze pass
- No enforcement hook registered in `.claude/settings.json`
- No `validate_evidence_locations.py` present
- Skills and agents do not contain canonical-path authority pointers

**Post-change state (working tree):**
- Python: 999 passed, 1 failed (same pre-existing), 14 skipped
- PowerShell: 330 pass, 0 fail, 7 skipped
- Hook registered, validator present, all skill/agent files updated

---

## Acceptance Criteria Inventory

All AC items listed below are drawn from the authoritative sources. Items are indexed for traceability.

**From `user-story.md` (12 items):**
- AC-1: `evidence-and-timestamp-conventions/SKILL.md` Non-Overridable Authority section
- AC-2: QA-gate skills (3) contain canonical paths and authority pointer
- AC-3: Invoke-engineer skills (3) contain canonical paths and authority pointer
- AC-4: `orchestrate/SKILL.md` Evidence Location Authority section with allow-list
- AC-5: `atomic-plan-contract/SKILL.md` non-overridable clause
- AC-6: All 12 `.claude/agents/*.md` contain Evidence Location Invariant section
- AC-7: `feature-review.md` diff-scan FAIL-finding requirement
- AC-8: `enforce-evidence-locations.ps1` hook registered, blocks forbidden prefixes, emits block JSON
- AC-9: Hook self-test `enforce-evidence-locations.Tests.ps1` — 5 cases all pass
- AC-10: `validate_evidence_locations.py` validator exits non-zero on seeded violation
- AC-11: Demonstration run confirms forbidden write is blocked at tool layer
- AC-12: All four toolchain steps pass in a single clean run

**From `spec.md` — additional test conditions (6 items):**
- T-1: Hook self-test: blocked path outputs block decision with correct message
- T-2: Hook self-test: allowed orchestration path → allow decision
- T-3: Hook self-test: allowed research path → allow decision
- T-4: Hook self-test: canonical evidence path → allow decision
- T-5: Hook self-test: regular source-code path → allow decision
- T-6: Validator: clean tree exits 0; seeded violation exits 1 with canonical replacement

---

## Summary

Feature #158 adds non-overridable enforcement of canonical evidence paths across four layers: skill definitions, agent contract sections, a PreToolUse hook, and a standalone Python validator. All 12 AC items in `user-story.md` are evaluated below. AC #12 (full toolchain clean pass) is PARTIAL due to a pre-existing test failure that was already present at baseline; no new failures were introduced by this feature. All other AC items PASS.

**Overall verdict: PASS with one PARTIAL item (pre-existing baseline defect, not a regression).**

---

## Acceptance Criteria Evaluation

### From `user-story.md` (authoritative for full-feature work mode)

| # | Criterion | Status | Evidence |
|---|-----------|--------|----------|
| AC-1 | `evidence-and-timestamp-conventions/SKILL.md` contains `## Non-Overridable Authority` section listing 6 canonical sub-paths and stating that no delegation prompt, plan, or upstream agent may override them | ✅ PASS | `grep_search` for `Non-Overridable Authority` → 1 match at line 10 of the SKILL.md. Section lists all 6 sub-paths and contains the prohibition statement. |
| AC-2 | All QA-gate skills (`python-qa-gate`, `csharp-qa-gate`, `powershell-qa-gate`) reference `<FEATURE>/evidence/baseline/` and `<FEATURE>/evidence/qa-gates/` paths and include the canonical-authority pointer line | ✅ PASS | `grep_search` for `canonical per evidence-and-timestamp-conventions` → 3 matches across all 3 QA-gate skills. Paths verified in each file: `<FEATURE>/evidence/baseline/`, `<FEATURE>/evidence/qa-gates/`, pointer at final line. |
| AC-3 | All invoke-engineer skills (`invoke-python-engineer`, `invoke-csharp-engineer`, `invoke-powershell-engineer`) reference `<FEATURE>/evidence/baseline/` and `<FEATURE>/evidence/qa-gates/` paths and include the canonical-authority pointer line | ✅ PASS | `grep_search` for `canonical per evidence-and-timestamp-conventions` → 3 additional matches across all 3 invoke-engineer skills. Paths verified. |
| AC-4 | `orchestrate/SKILL.md` contains `## Evidence Location Authority` section with an explicit allow-list of permitted `artifacts/`-rooted sub-paths | ✅ PASS | `grep_search` for `Evidence Location Authority` → 1 match at line 38. Section contains explicit allow-list: `artifacts/orchestration/`, `artifacts/research/`, `artifacts/pr_context`, `artifacts/reviews/`, `artifacts/status/`, `artifacts/python/`, `artifacts/pester/`, `artifacts/csharp/`. |
| AC-5 | `atomic-plan-contract/SKILL.md` contains the non-overridable clause prohibiting plan tasks from accepting evidence path overrides | ✅ PASS | `grep_search` for `non-overridable` in `atomic-plan-contract/SKILL.md` → 2 matches (section heading `## Non-Overridable Evidence Path Clause` at line 92 and closing statement). Clause states plan tasks must use `<FEATURE>/evidence/<kind>/` and planner must reject and substitute any non-canonical path. |
| AC-6 | All 12 agent definition files under `.claude/agents/` contain `## Evidence Location Invariant` section with verbatim rejection-and-logging instruction | ✅ PASS | `grep_search` for `Evidence Location Invariant` → 12 matches across 12 distinct agent files: `atomic-executor.md`, `atomic-planner.md`, `csharp-typed-engineer.md`, `epic-review.md`, `feature-review.md`, `powershell-typed-engineer.md`, `prd-feature.md`, `python-typed-engineer.md`, `staged-review.md`, `status-updater.md`, `task-researcher.md`, `typescript-engineer.md`. |
| AC-7 | `feature-review.md` additionally contains the diff-scan FAIL-finding requirement for non-canonical evidence paths | ✅ PASS | `read_file` on `.claude/agents/feature-review.md` lines 110–140 confirmed: "The reviewer MUST scan the branch diff for files written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. Each such file is a FAIL-level finding. Record each occurrence under the heading `## Evidence Location Compliance` in `policy-audit.<timestamp>.md`..." |
| AC-8 | `enforce-evidence-locations.ps1` PreToolUse hook is registered for Write and Edit tool events in `.claude/settings.json`, blocks forbidden prefixes, allows exceptions, and emits the block decision JSON format to stdout | ✅ PASS | `.claude/settings.json` inspection confirms `{"type": "command", "command": "pwsh -NoProfile -File .claude/hooks/enforce-evidence-locations.ps1"}` in the `Write\|Edit` PreToolUse hooks array. Hook code verified: forbidden prefixes `artifacts/baselines/`, `artifacts/baseline/`, `artifacts/qa/`, `artifacts/qa-gates/`, `artifacts/coverage/`, `artifacts/evidence/`, `artifacts/regression-testing/`, `artifacts/post-change/` all blocked. Exceptions `artifacts/orchestration/`, `artifacts/research/` allowed. Output is `ConvertTo-Json -Compress` on a decision object. |
| AC-9 | Hook self-test `enforce-evidence-locations.Tests.ps1` passes all 5 cases: blocked path, allowed orchestration path, allowed research path, canonical evidence path, regular source-code path | ✅ PASS | `pester-junit.xml` (2026-04-25T15-32): 5 tests in `enforce-evidence-locations.Tests.ps1`, all pass. Cases verified: (1) `artifacts/baselines/foo.md` → `decision=block`, reason matches `EVIDENCE_LOCATION_BLOCKED`; (2) `artifacts/orchestration/foo.md` → `decision=allow`; (3) `artifacts/research/foo.md` → `decision=allow`; (4) `docs/features/active/.../evidence/baseline/foo.md` → `decision=allow`; (5) `src/hello.ts` → `decision=allow`. |
| AC-10 | `validate_evidence_locations.py` exists, walks the repository tree, exits non-zero on a seeded violation, prints the canonical replacement path, and is referenced from the feature-review policy-audit step | ✅ PASS | File exists at `scripts/dev_tools/validate_evidence_locations.py`. Pytest run exits 0 with 6 tests passing; `test_seeded_violation_exits_one` verifies a seeded `artifacts/baselines/seeded.md` path triggers a violation with the correct `evidence/baseline/` suggestion. `feature-review.md` line 125 references `validate_evidence_locations.py --root .` as a required step. |
| AC-11 | A demonstration run confirms that a deliberate Write to `artifacts/baselines/test.md` is blocked at the tool layer and the agent re-issues the write to the canonical path | ✅ PASS | Evidence artifact `evidence/other/hook-demonstration.md` documents the demonstration run. Hook output: `{"decision":"block","reason":"EVIDENCE_LOCATION_BLOCKED: 'artifacts/baselines/test.md' is not a canonical evidence location. Use <FEATURE>/evidence/baseline/ instead."}`. Agent re-issued to `docs/features/active/.../evidence/baseline/test.md`. |
| AC-12 | All four toolchain steps (format, lint, type-check, test) pass after the changes in a single clean pass | ⚠️ PARTIAL | Black ✅ (201 unchanged), Ruff ✅ (0 findings), Pyright ✅ (0 errors). Pytest ⚠️: exits 1; 999 tests pass, 1 fails. The single failure (`test_mirrored_orchestrator_agents_match_root_direct_command_contracts`) was also failing at baseline (993 passed, 1 failed) before this feature began. No new failures introduced. PoshQC: Format ✅, Analyze ✅ (0 findings), Pester ✅ (330 pass). |

### From `spec.md` — Test Conditions (lines 188–193)

| # | Criterion | Status | Evidence |
|---|-----------|--------|----------|
| T-1 | Hook self-test: blocked path outputs block decision with correct message | ✅ PASS | Pester test case 1 validated: `$result.decision | Should -Be 'block'`; `$result.reason | Should -Match 'EVIDENCE_LOCATION_BLOCKED'`. Note: spec.md line 188 says "exits 1" but hook correctly exits 0 with JSON decision (per Claude Code protocol). The test validates behavior, not exit code; behavior is correct. |
| T-2 | Hook self-test: allowed orchestration path outputs allow decision | ✅ PASS | Pester test case 2: `$result.decision | Should -Be 'allow'` ✅ |
| T-3 | Hook self-test: allowed research path outputs allow decision | ✅ PASS | Pester test case 3: `$result.decision | Should -Be 'allow'` ✅ |
| T-4 | Hook self-test: canonical evidence path outputs allow decision | ✅ PASS | Pester test case 4: `$result.decision | Should -Be 'allow'` ✅ |
| T-5 | Hook self-test: regular source-code path outputs allow decision | ✅ PASS | Pester test case 5: `$result.decision | Should -Be 'allow'` ✅ |
| T-6 | Validator: clean tree exits 0; seeded violation exits 1 with canonical replacement printed | ✅ PASS | Pytest tests 1 and 2: clean tree returns 0 violations (exit 0); seeded `artifacts/baselines/seeded.md` returns 1 violation with `evidence/baseline/` suggestion (exit 1). |

---

## Acceptance Criteria Check-off

The following items are confirmed PASS and are marked accordingly in `spec.md` and `user-story.md`:

**`user-story.md`:** AC-1 through AC-11 → marked `[x]`. AC-12 → remains `[ ]` (PARTIAL — pre-existing toolchain failure).

**`spec.md`:** Lines 174–183 → marked `[x]` for the 10 core AC items. Lines 184–185 (toolchain steps) → line 184 (Python) remains `[ ]` (PARTIAL); line 185 (PowerShell) → marked `[x]`. Lines 188–193 (test conditions) → all 6 marked `[x]`.

---

## PARTIAL Item Detail

### AC-12 / spec.md Line 184 — Python toolchain full clean pass

**Status:** PARTIAL

**Finding:** `poetry run pytest --cov` exits with code 1. One test fails: `test_mirrored_orchestrator_agents_match_root_direct_command_contracts`. This failure was present in the baseline evidence (EXIT_CODE: 1, 993 passed, 1 failed) before any of this feature's changes were made. The final QA evidence shows 999 passed, 1 failed — a net gain of 6 new passing tests with no new failures.

**Assessment:** The feature itself does not regress the test suite. The pre-existing failure is likely related to a contract-synchronization check between orchestrator agent files in `.github/agents/` and their mirrors. This failure is out of scope for feature #158.

**Disposition:** PARTIAL. The AC requires "all four toolchain steps pass." Pytest technically does not pass (exit 1). However, the failure predates the feature, and no new failures are attributable to this feature's changes. This PARTIAL does not block delivery of feature #158 but should be tracked as a separate defect.

---

## Coverage and Delivery Verification

| Deliverable | Expected | Actual | Status |
|-------------|----------|--------|--------|
| `evidence-and-timestamp-conventions/SKILL.md` — `## Non-Overridable Authority` | Section with 6 sub-paths | Present at line 10 | ✅ |
| 3 QA-gate skills — canonical paths + pointer | `<FEATURE>/evidence/baseline/`, `<FEATURE>/evidence/qa-gates/`, pointer line | All 3 confirmed | ✅ |
| 3 invoke-engineer skills — canonical paths + pointer | Same | All 3 confirmed | ✅ |
| `orchestrate/SKILL.md` — `## Evidence Location Authority` | Allow-list with 8 permitted sub-paths | Present at line 38, 8 items listed | ✅ |
| `atomic-plan-contract/SKILL.md` — non-overridable clause | Section heading + prohibition statement | Present at line 92 | ✅ |
| 12 `.claude/agents/*.md` — `## Evidence Location Invariant` | All 12 files | All 12 confirmed | ✅ |
| `feature-review.md` — diff-scan requirement + validator reference | FAIL-finding instruction + `validate_evidence_locations.py` reference | Both at line 125 | ✅ |
| `.claude/hooks/enforce-evidence-locations.ps1` | New file, hook logic, correct exit-code protocol | Present, 175 lines, exits 0 for allow and block | ✅ |
| `.claude/settings.json` hook registration | `Write\|Edit` PreToolUse array | Entry confirmed | ✅ |
| `tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1` | 5 test cases, all pass | 5 tests, all pass (pester-junit.xml) | ✅ |
| `scripts/dev_tools/validate_evidence_locations.py` | Validator script, exits non-zero on violation | Present, exit-0 clean, exit-1 seeded violation | ✅ |
| `tests/scripts/dev_tools/test_validate_evidence_locations.py` | Test coverage for validator | 6 tests, all pass | ✅ |
| Hook demonstration evidence | Confirmation run | `evidence/other/hook-demonstration.md` | ✅ |
| Python toolchain clean pass | All 4 steps | Black ✅, Ruff ✅, Pyright ✅, Pytest ⚠️ (pre-existing) | ⚠️ PARTIAL |
| PowerShell toolchain clean pass | Format, Analyze, Pester | All 3 pass | ✅ |

---

## Feature Verdict

**PASS with one PARTIAL item (AC-12 / pre-existing baseline defect).**

All feature-specific deliverables are present, correctly implemented, and tested. The enforcement stack is complete across four independent layers. The single PARTIAL item (pytest exit code 1) is attributable to a pre-existing test failure that was already documented in the baseline evidence before this feature's implementation began. No acceptance criterion that is specific to this feature's deliverables fails.

**Next steps:**
1. Track the pre-existing test failure (`test_mirrored_orchestrator_agents_match_root_direct_command_contracts`) as a separate defect.
2. Consider adding one additional Python test case (a second forbidden-prefix mapping) as noted in the code review (R-01) — not blocking.
3. Correct `spec.md` line 188 exit-code wording (R-03) — documentation fix only.
4. Commit the out-of-scope `.github/agents/orchestrator.agent.md` change separately (R-04).
5. Commit feature #158 changes with the evidence artifacts included.
