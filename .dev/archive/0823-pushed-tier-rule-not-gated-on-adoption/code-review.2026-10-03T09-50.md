# Code Review: pushed tier rule gated on adoption (#823)

**Review Date:** 2026-10-03
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823`
**Feature Folder Selection Rule:** the only active feature folder whose suffix matches the issue number in the branch name (`-823`).
**Base Branch:** `origin/main` (merge base `1920378812e61be21a5fc96f9ffbf474b4bbbee4`, confirmed current by `git fetch origin main`)
**Head Branch:** `bug/pushed-tier-rule-not-gated-on-adoption-823` at `6a24fdb9631b6e33cadabb7fd2fff444b1b2da0f`
**Review Type:** Initial review (review pass 1)

---

## Executive Summary

The branch edits eight pushed rule and skill files (five Claude, three Codex) and their eight byte-identical bundled mirrors, adds one pytest module (463 lines, 80 collected cases), and updates two potential-item documents. No production code, workflow, push-down code, manifest, or `.github/instructions/` file changed. Evidence reviewed: the full `origin/main...HEAD` diff, the PR context artifacts (head SHA matches), the feature-folder evidence, local re-runs of the Python toolchain, contract suites, Pester doc contract, `check_quality_tiers`, and the evidence-location validator, plus a read-only discrimination check of the new tests against the base-branch text.

The rewritten text matches spec Decisions D1-D7. The applicability paragraph sits before the first `## ` heading in both `quality-tiers` copies and explicitly keeps the coverage defaults independent of tier adoption, which avoids the misreading that a non-adopting repository has no coverage floor. The Codex anchor (`AGENTS.md`, then `CLAUDE.md`) is stated consistently in both Codex files. Because this repository has `quality-tiers.yml` and its root `CLAUDE.md` states no coverage thresholds (grep returned no match), the gated wording leaves this repository's behavior unchanged; `check_quality_tiers` still reports OK.

**What changed:**
- `quality-tiers.md` (Claude and Codex): adoption gate, conditional source-of-truth bullets, precedence statement, "in this repository" removed, neutral tier examples with harm-model sentences kept verbatim.
- `general-code-change.md` (Claude and Codex): conditional "Module Rigor Tiers" section; Codex citation corrected to `.agents/skills/quality-tiers/SKILL.md`.
- `general-unit-test.md` (Claude and Codex): precedence bullet; Test Categories adoption condition.
- `feature-review.md` and `feature-review-workflow/SKILL.md`: precedence citation and adoption-gated tier finding; Verification Procedure refers to governing thresholds.
- `test_push_down_tier_rule_adoption_gate.py`: whitespace-normalized content contract over 16 copies plus three helper self-tests.

**Top 3 risks:**
1. The workflow skill's step 8 remediation trigger still states 80/90 thresholds, so the skill now gives two different threshold sets (Minor; tracked as FU-823-5).
2. The precedence wording does not define per-metric fallback when a root `CLAUDE.md` states only one of line or branch thresholds (Minor).
3. Consumers receive the change only after an extension release (FU-823-4); the SubagentStop coverage hook still enforces 85/75 regardless of consumer thresholds (FU-823-1).

**PR readiness recommendation:** **Go** - no Blocker or Major finding.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.claude/skills/feature-review-workflow/SKILL.md` (and mirror) | line 149 | Step 8 lists "coverage regression below policy threshold (< 80% repo-wide per language, < 80% or regression for modified files, or < 90% for new files)" while step 5 of the same file now defers to the governing thresholds. Non-blocking; outside AC9 and AC10; already recorded as FU-823-5. | Replace the parenthetical with "below the governing thresholds defined in step 5" in the repository copy and mirror, and extend `test_review_agent_copy_uses_governing_thresholds` to cover the skill. | A reviewer reading step 8 alone applies thresholds that the rest of the document has retired. | `grep -n -E "80%" .claude/skills/feature-review-workflow/SKILL.md` returned line 149 only. |
| Minor | `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md` (and Codex equivalents, mirrors) | Coverage Requirements bullet 1; "Uniform across all tiers" paragraph | The precedence clause says root `CLAUDE.md` thresholds govern and the defaults apply "only when the root `CLAUDE.md` states none". A file that states a line threshold but no branch threshold leaves the branch figure undefined under a literal reading. Non-blocking. | Add "per metric": a stated line or branch threshold governs that metric, and the default applies to any metric the file does not state. Update the fragment constants in the regression module accordingly. | Removes an ambiguity that consumer agents would otherwise resolve inconsistently. | Diff hunks at `general-unit-test.md` +23 and `quality-tiers.md` +31. |
| Nit | `docs/features/potential/promoted/2026-10-03-pushed-tier-rule-not-gated-on-adoption.md` | line 5 | The Status line points to `docs/features/active/pushed-tier-rule-not-gated-on-adoption/`; the actual folder is `docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823/`. Non-blocking. | Correct the path, or confirm the promotion tooling writes this form and leave it. | Keeps lifecycle cross-references resolvable. | Read of the file; `ls docs/features/active/`. |
| Nit | `tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py` | lines 136, 385-398 | `RETIRED_REVIEW_THRESHOLDS = ("80%", "90%")` is matched as raw substrings across the whole agent file, so any later unrelated percentage such as an example figure would fail the test. Non-blocking. | Scope the check to the `### Verification Procedure` section using the existing `section` helper adapted for `### ` headings, or match the retired sentences. | Reduces false failures while keeping the regression pinned. | Code inspection. |
| Info | `tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py` | whole module | The tests discriminate. Evaluated against `git show 1920378812:<path>` for all 16 copies, every legacy construct present at base was detected (classification sentence in 4 copies, CI sentence in 4, missing gate in 4, product names in 4, missing Claude precedence in 4, 80/90 in 2), and a mutant that moves the gate paragraph below `## Tiers` is detected by the preamble test. | None required. | Confirms that the 100% pass after the edits reflects pinned behavior, not permissive matching. | Session scratchpad script; executor expect-fail evidence (52 failed, 28 passed). |
| Info | main checkout (not the branch) | `docs/features/potential/promoted/` | The main checkout at `C:/Users/DanMoisan/repos/drm-copilot` holds an untracked copy of the promoted record for this issue. Not part of the branch diff. | Remove the untracked copy from the main checkout after merge, as housekeeping. | Prevents a duplicate record when main is next updated. | Session git status of the main checkout. |

No Blocker or Major findings.

---

## Implementation Audit

### Rule-text implementation audit

#### What changed well

- The applicability paragraph enumerates each tier-dependent gate by name (escape-hatch limits, property-test density, mutation score, contract-bump rule, determinism retry rate, golden tests, E2E suite scope), matching the Tier-dependent table, so no gate is left implicitly in force.
- The source-of-truth bullets are rewritten as conditionals rather than deleted, so an adopting repository reads the same obligations as before.
- The feature-review adoption test has two triggers (file on the resolved base branch, or a CI tier-classification check), which handles a repository that runs the check before committing the file.
- The Verification Procedure in `feature-review.md` now evaluates line and branch for repo-wide, new-file, and modified-file cases, closing a gap where the prior text checked line coverage only.
- The Codex files cite `.agents/skills/quality-tiers/SKILL.md`; the broken `.agents/skills/quality-tiers.md` citation no longer appears in any Codex skill (grep returned no match).

#### API and safety notes

- No consuming repository is named in any added line (grep over added lines for TaskMaster, No-COM, SpamBayes, Outlook, and template braces returned 0).
- `paths: ["**"]` and non-empty `description:` remain on the three Claude rules; `test_claude_rules_frontmatter.py` passes.

#### Error handling and logging

- Not applicable; no executable production code changed.

### Python test implementation audit

- Helpers are pure and typed; `read_copy` is the only I/O and is read-only.
- `preamble` and `section` operate on lines, while fragment searches operate on whitespace-normalized text, so reflowed sentences are still found (proven by `test_legacy_detection_flags_wrapped_legacy_sentences`).
- `test_every_scanned_copy_exists` asserts both existence and the count of 16 distinct paths, which guards against a silently shrunken scan set.

---

## Test Quality Audit

The new module covers spec assertions 1-6 per copy and assertion 7 through a negative control. Fail-before evidence: `evidence/regression-testing/expect-fail-tier-rule-adoption-gate.2026-10-03T09-34.md` (52 failed, 28 passed, with the failing set enumerated). Pass-after: `evidence/regression-testing/pass-after-tier-rule-adoption-gate.2026-10-03T09-39.md` (80 passed), re-run by this review.

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py` - 17 test functions, 80 cases.
- `evidence/qa-gates/contract-set-pytest.2026-10-03T09-41.md` - 11 contract suites, 159 passed.
- `evidence/qa-gates/pytest-full-coverage.2026-10-03T09-41.md` - 6554 passed, 6 skipped.
- `evidence/qa-gates/coverage-comparison.2026-10-03T09-43.md` - Python and TypeScript totals equal to baseline.
- `evidence/qa-gates/scope-check.2026-10-03T09-44.md` - protected paths unchanged.

### Quality assessment prompts

- **Determinism:** committed inputs only.
- **Isolation:** one assertion family per test, parametrized by copy.
- **Speed:** sub-second.
- **Diagnostics:** every assertion names the copy and the offending fragments.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection; no credentials or tokens. |
| No unsafe subprocess or command construction | ✅ PASS | The test module starts no process. |
| Input validation at boundaries | ✅ PASS | Not applicable to rule text; the test asserts section presence before checking content. |
| Error handling remains explicit | ✅ PASS | No production error path changed. |
| Configuration / path handling is safe | ✅ PASS | Paths are repository-relative constants; no absolute host path is written to any artifact. |

---

## Research Log

No external research was required. Behavior was verified against the repository rules, `spec.md`, `research/research.2026-10-03.md`, and local command output.

---

## Verdict

The change is ready for normal PR flow. It delivers the scoped wording change on both surfaces, keeps all mirrors byte-identical, leaves this repository's tier enforcement intact, and pins the new wording with a test module that demonstrably fails on the old text. The two Minor findings and two Nits are non-blocking and suitable for a follow-up.
