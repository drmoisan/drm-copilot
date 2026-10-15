# Feature Audit: pushed tier rule gated on adoption (#823)

**Audit Date:** 2026-10-03
**Feature Folder:** `docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823`
**Base Branch:** `origin/main`
**Head Branch:** `bug/pushed-tier-rule-not-gated-on-adoption-823`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review (review pass 1)

---

## Scope and Baseline

- **Base branch:** `origin/main` (commit `1920378812e61be21a5fc96f9ffbf474b4bbbee4` at review time, confirmed by `git fetch origin main`)
- **Head branch/commit:** `bug/pushed-tier-rule-not-gated-on-adoption-823` (commit `6a24fdb9631b6e33cadabb7fd2fff444b1b2da0f`)
- **Merge base:** `1920378812e61be21a5fc96f9ffbf474b4bbbee4` (committed 2026-10-02T06:38:32-05:00)
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-10-03 13:47:40 UTC, Head SHA `6a24fdb9`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `evidence/baseline/`, `evidence/regression-testing/`, `evidence/qa-gates/`, `evidence/other/` (AC index: `evidence/other/ac-checkoff.2026-10-03T09-45.md`)
  - Review re-runs: Black, Ruff, Pyright on the new module; pytest over the new module and six contract suites (159 passed); Pester `claude-architecture-doc.Tests.ps1` (6 passed); `check_quality_tiers` (OK); `validate_evidence_locations.py` (exit 0); `cmp` over eight mirror pairs; discrimination check of the test helpers against base text.
- **Feature folder used:** `docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823`
- **Requirements source:** `spec.md` `## Acceptance Criteria` (AC1-AC21).
- **Work mode resolution note:** explicit marker `- Work Mode: full-bug` in `issue.md` line 12; `spec.md` is the sole AC source.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823/spec.md` - only source (`## Acceptance Criteria`)

### Acceptance criteria

1. AC1: `quality-tiers.md` adoption gate before the first `## ` heading.
2. AC2: no unconditional classification or CI statement in `quality-tiers.md`; "in this repository" removed.
3. AC3: conditional "Module Rigor Tiers" section in `general-code-change.md`; legacy sentence absent.
4. AC4: root `CLAUDE.md` precedence in `general-unit-test.md` and `quality-tiers.md`, covering every restatement.
5. AC5: Test Categories adoption condition in `general-unit-test.md`; "not used in this repository" absent.
6. AC6: Codex skills carry the gate, conditional section, and `AGENTS.md`-then-`CLAUDE.md` precedence.
7. AC7: rewritten Codex sentences cite `.agents/skills/quality-tiers/SKILL.md`; the non-existent path is gone.
8. AC8: no TaskMaster, No-COM, SpamBayes, or Outlook in either `quality-tiers` file; harm-model definitions unchanged.
9. AC9: feature-review agent and skill replace "uniform tier rule" with the precedence and gate the tier finding on adoption.
10. AC10: feature-review Verification Procedure states no 80% or 90% threshold and refers to governing thresholds.
11. AC11: eight repo-local files byte-identical to mirrors; three parity suites pass.
12. AC12: three Claude rules keep `paths: ["**"]` and non-empty `description:`; frontmatter test passes.
13. AC13: pinned phrases retained; three documentation-contract suites pass.
14. AC14: regression module exists, scans all copies, implements assertions 1-6, no temp files, no external process.
15. AC15: negative-control test present; expect-fail run recorded before the edits.
16. AC16: `.github/copilot-instructions.md` and `.github/instructions/` unmodified.
17. AC17: no consuming repository named, no templating, no push-down code, pack manifest, or exclusion-manifest code modified.
18. AC18: `quality-tiers.yml`, `check_quality_tiers.py`, `quality_tiers_contract.py`, and the CI step unmodified; `check_quality_tiers` passes.
19. AC19: FU-734-4 marked superseded; FU-734-1 noted resolved for rewritten Codex sentences.
20. AC20: F1-F4 recorded in a potential item.
21. AC21: full toolchain passes in a single pass.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC1 adoption gate in preamble | PASS | `.claude/rules/quality-tiers.md` line after the H1 begins "Applicability: this rule applies only when `quality-tiers.yml` exists at the repository root ..." and states no tier classification requirement, no `tier-classification` CI stage, no tier-dependent gate, and "the absence of `quality-tiers.yml` is not a defect". `test_quality_tiers_preamble_states_adoption_gate` passes. | `git diff` of the file; pytest | A moved-gate mutant is detected by the preamble test (review check). |
| 2 | AC2 conditional classification and CI statements; repo phrase removed | PASS | Source-of-truth bullets now read "When `quality-tiers.yml` exists at the repository root, it maps every project to one tier" and "In a repository that runs a `tier-classification` CI stage, ... it fails CI for an unclassified project." Grep for "in this repository" in both `quality-tiers` files returned no match. | grep; pytest `test_copy_omits_unconditional_ci_sentence`, `test_quality_tiers_copy_drops_repo_scope_phrase` | |
| 3 | AC3 conditional Module Rigor Tiers section | PASS | Section reads "... apply only when `quality-tiers.yml` exists at the repository root; in that case every project must be classified in it. A repository without `quality-tiers.yml` has not adopted tiers ...". Legacy sentence absent from all 16 copies. | pytest `test_general_code_change_tier_section_is_conditional`, `test_copy_omits_legacy_classification_sentence` | |
| 4 | AC4 root `CLAUDE.md` precedence | PASS | Both files contain "Threshold precedence: when the repository's root `CLAUDE.md` states line or branch coverage thresholds, those thresholds govern. The 85% line and 75% branch figures are defaults that apply only when the root `CLAUDE.md` states none. This precedence applies to every restatement of these figures in other rule files, agents, and skills." | pytest `test_claude_copy_states_claude_md_precedence` | Per-metric fallback is not defined (code-review Minor, non-blocking). |
| 5 | AC5 Test Categories condition; phrase removed | PASS | Test Categories lead-in ends "those tier-dependent obligations apply only when `quality-tiers.yml` exists at the repository root". "not used in this repository" absent. | pytest `test_unit_test_categories_gate_tier_obligations`, `test_general_unit_test_copy_drops_repo_scope_phrase` | |
| 6 | AC6 Codex gate, section, and precedence | PASS | `.agents/skills/quality-tiers/SKILL.md` preamble gate; `.agents/skills/general-code-change/SKILL.md` conditional section; precedence "root `AGENTS.md` ... when `AGENTS.md` states none, thresholds stated in the repository's root `CLAUDE.md` govern" in `quality-tiers` and `general-unit-test` skills. | pytest `test_codex_copy_states_agents_md_precedence` and the preamble and section tests over Codex copies | |
| 7 | AC7 Codex citation corrected | PASS | Grep for `agents/skills/quality-tiers.md` over `.agents/skills/*/SKILL.md` returned no match; each of the three skills cites `.agents/skills/quality-tiers/SKILL.md`. | grep; pytest `test_codex_skill_copy_cites_existing_tier_skill` | |
| 8 | AC8 no product names; harm models unchanged | PASS | Grep for TaskMaster, No-COM, SpamBayes, Outlook over both files returned no match. The three harm-model sentences for T1-T3 are byte-equal to base in the diff; T4 line unchanged. | grep; pytest `test_quality_tiers_copy_names_no_consuming_product` | |
| 9 | AC9 feature-review precedence and adoption-gated finding | PASS | Both files drop "uniform tier rule", cite the root `CLAUDE.md` precedence, and add "report a missing or incomplete `quality-tiers.yml` only when the repository has adopted tiers, that is, when `quality-tiers.yml` exists at the repository root on the resolved base branch or the repository's CI runs a tier-classification check. Otherwise record tier classification as not applicable; it is not a finding." | grep; pytest `test_feature_review_copy_gates_tier_finding` | |
| 10 | AC10 Verification Procedure uses governing thresholds | PASS | The three bullets in `feature-review.md` Verification Procedure now refer to "the governing repo-wide / new-file / modified-file thresholds defined in Coverage Thresholds"; grep for `80%` and `90%` in `feature-review.md` returned no match. | grep; pytest `test_review_agent_copy_uses_governing_thresholds` | The workflow skill step 8 still states 80/90; it is outside AC10 and recorded as FU-823-5. |
| 11 | AC11 mirror byte identity; parity suites | PASS | `cmp -s` reported IDENTICAL for all eight pairs. Parity suites passed in this review's run (159 passed across seven files). | `cmp -s`; pytest | |
| 12 | AC12 frontmatter retained | PASS | `head -5` of each Claude rule shows `paths:` with `"**"` and a non-empty `description:`; `test_claude_rules_frontmatter.py` passes. | head; pytest | |
| 13 | AC13 pinned phrases retained | PASS | `test_orchestrator_state_remediation_docs.py` and `test_completion_gate_documentation_contracts.py` pass (this review); `claude-architecture-doc.Tests.ps1`: 6 passed, 0 failed (this review). | pytest; Invoke-Pester | |
| 14 | AC14 regression module scope and constraints | PASS | Module scans 16 copies (asserted by `test_every_scanned_copy_exists`), implements assertions 1-6, and performs only `Path.read_text`; no temp file, subprocess, or network call (code inspection). | Read of the module; pytest | |
| 15 | AC15 negative control and expect-fail run | PASS | `test_legacy_detection_flags_wrapped_legacy_sentences` asserts both legacy sentences are flagged in wrapped synthetic text. Expect-fail run recorded at `evidence/regression-testing/expect-fail-tier-rule-adoption-gate.2026-10-03T09-34.md` (52 failed, 28 passed) before commit `6a24fdb9`. | Read of evidence; review discrimination check against base text | |
| 16 | AC16 `.github/` unmodified | PASS | `git diff --name-only 19203788..HEAD -- .github` is empty. | git diff | |
| 17 | AC17 no repository named, no templating, no push-down code change | PASS | Grep of added lines for product names and template braces returned 0. `git diff --name-only` over `scripts`, `extensions/drm-copilot/src`, and the pack-manifest directories is empty. | git diff; grep | |
| 18 | AC18 tier enforcement untouched and passing | PASS | `git diff --name-only` over `quality-tiers.yml`, `scripts`, and `.github` is empty; `check_quality_tiers` reports `OK (24 entries, 24 discovered projects)`. | git diff; `poetry run python -m scripts.dev_tools.check_quality_tiers` | |
| 19 | AC19 FU-734 item updated | PASS | FU-734-1 gains "Status (2026-10-03): Resolved by #823 for the Codex sentences that #823 rewrote."; FU-734-4 gains "Superseded by #823 ... Do not promote this entry." | git diff of the potential item | |
| 20 | AC20 F1-F4 recorded | PASS | `docs/features/potential/2026-10-03-issue-823-tier-rule-adoption-follow-ups.md` records FU-823-1 to FU-823-4 (spec F1-F4) plus FU-823-5. | Read of the file | |
| 21 | AC21 full toolchain single pass | PASS | Executor evidence: Black, Ruff, Pyright, full pytest (6554 passed), Jest with coverage (3808 passed), contract set (159 passed), Codex variant check, `check_quality_tiers`, Pester doc contract, with a matching tree snapshot before and after (loop iteration 1). This review re-ran the Python stages on the changed file, the contract suites, Pester, and `check_quality_tiers`, all green. | Evidence files under `evidence/qa-gates/`; review re-runs | Only Markdown and one test file changed, so no TypeScript, PowerShell, or C# stage is affected by the diff. |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 21 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

Non-blocking observations from the policy audit and code review (no AC impact): workflow skill step 8 still states 80/90 thresholds (Minor, FU-823-5); precedence clause lacks a per-metric fallback (Minor); promoted-record Status path lacks the date prefix and issue suffix (Nit); the 80%/90% token check spans the whole agent file (Nit).

**Recommended follow-up verification steps:**

1. After the next extension release (FU-823-4), run a Claude push-down into a repository without `quality-tiers.yml` and confirm the pushed `quality-tiers.md` carries the adoption gate.
2. Optionally address the four non-blocking observations in a follow-up change.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

All twenty-one criteria were already checked by the executor (`evidence/other/ac-checkoff.2026-10-03T09-45.md`) and all evaluate PASS here, so `spec.md` was not modified by this review. No item was unchecked.

### AC Status Summary

- Source: `docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823/spec.md`
- Total AC items: 21
- Checked off (delivered): 21
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823/spec.md` | 21 | 21 | 0 | Checkbox-backed `## Acceptance Criteria` section; no change made by this review. |
