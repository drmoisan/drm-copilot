# Feature Audit: Bug #151 — GitHub Instructions Not Migrated to Claude (.claude/rules/)

---

**Audit Date:** 2026-04-17
**Reviewer:** GitHub Copilot (feature_code_review_agent)
**Feature Folder:** `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151`
**Work Mode:** `full-bug` — AC source: `spec.md`
**Base Branch:** `development` (merge-base `d742a7f8efef1ec95500edca6b2bd525bb78b819`)
**Head Branch:** `bug/github-instructions-not-migrated-to-claude-151` (working-tree state — uncommitted)
**AC Source:** `spec.md` (Work Mode: `full-bug`)

---

## Scope and Baseline

**Scope:** Bug #151 addresses a systematic gap in the Claude Code runtime configuration for this repository. Eight cross-cutting `.github/instructions/` policy files had no corresponding `.claude/rules/` mirrors, and four existing `.claude/rules/` language files were missing coverage thresholds.

**Baseline:** Development branch at merge-base `d742a7f8efef1ec95500edca6b2bd525bb78b819` (2026-04-17T11:18:37-05:00). The baseline state had no `general-code-change.md`, `general-unit-test.md`, `tonality.md`, `typescript-suppressions.md`, `python-suppressions.md`, or `self-explanatory-code-commenting.md` files in `.claude/rules/`. Coverage thresholds were absent from `typescript.md`, `csharp.md`, `powershell.md`, and the ≥80% repo-wide floor was absent from `python.md`.

**Change nature:** 14 Markdown files created or updated. No executable code changed. Changes exist in the working tree (uncommitted after `git reset --soft HEAD~1`).

**Files delivered:**
- New: `.claude/rules/general-code-change.md`, `general-unit-test.md`, `tonality.md`, `typescript-suppressions.md`, `python-suppressions.md`, `self-explanatory-code-commenting.md`
- Updated: `.claude/rules/typescript.md`, `python.md`, `csharp.md`, `powershell.md`
- Updated: `.claude/skills/feature-review-workflow/SKILL.md`, `.claude/agents/feature-review.md`
- Updated (out-of-spec, Info): `.github/agents/feature-review.agent.md`, `.github/skills/feature-review-workflow/SKILL.md`

---

## Acceptance Criteria Inventory

| ID | Criterion | Status |
|---|---|---|
| AC-1 | `general-code-change.md` created with `paths: "**"`, design principles + toolchain loop | PASS |
| AC-2 | `general-unit-test.md` created with `paths: "**"`, ≥80% repo-wide and ≥90% new code thresholds | PASS |
| AC-3 | `typescript.md` updated with ≥80% and ≥90% thresholds and `npm run test:unit:coverage` | PASS |
| AC-4 | `python.md` updated with repo-wide ≥80% coverage floor | PASS |
| AC-5 | `csharp.md` updated with ≥80% and ≥90% coverage thresholds | PASS |
| AC-6 | `powershell.md` updated with ≥80% and ≥90% coverage thresholds | PASS |
| AC-7 | `tonality.md` created with `paths: "**"`, professional tone + prohibition patterns | PASS |
| AC-8 | `typescript-suppressions.md` created with `paths: "**/*.ts"`, ESLint + @ts-expect-error pre-authorized patterns | PASS |
| AC-9 | `python-suppressions.md` created with `paths: "**/*.py"`, S603/ARG002/B008/BLE001/S110 patterns | PASS |
| AC-10 | `self-explanatory-code-commenting.md` created with `paths: "**/*.py"`, docstrings + loops/branches | PASS |
| AC-11 | `feature-review-workflow/SKILL.md` Step 5 coverage item + Step 8 coverage regression trigger | PASS |
| AC-12 | `feature-review.md` Coverage Verification section with evidence-based model | PASS |

---

## Acceptance Criteria Evaluation

Source: `spec.md`, section "Acceptance Criteria". Work Mode: `full-bug`. All 12 criteria evaluated.

### AC-1 — `general-code-change.md`: `paths: "**"`, design principles + toolchain loop

**Status: PASS**

File exists at `.claude/rules/general-code-change.md`. YAML frontmatter: `paths: "**"`. Content verified to include design principles (Simplicity, Reusability, Extensibility, Separation of Concerns), Classes/Functions/APIs section, Mandatory Toolchain Loop (Format → Lint → Type check → Test), 500-line file size limit, Error Handling and Logging, Naming conventions, and I/O Boundaries. Source: `.github/instructions/general-code-change.instructions.md`.

---

### AC-2 — `general-unit-test.md`: `paths: "**"`, ≥80% and ≥90% coverage thresholds

**Status: PASS**

File exists at `.claude/rules/general-unit-test.md`. YAML frontmatter: `paths: "**"`. Both coverage thresholds explicitly stated: "Repository-wide line coverage must remain >= 80%." and "Any new module, class, or method must target >= 90% coverage." Coverage regression prevention and test-file exclusion guidance also present. Source: `.github/instructions/general-unit-test.instructions.md`. This is the primary fix item for bug #151.

---

### AC-3 — `typescript.md`: ≥80% and ≥90% thresholds, `npm run test:unit:coverage`

**Status: PASS**

File `.claude/rules/typescript.md` updated. Four additions confirmed at lines 42-45:
1. "Repository-wide line coverage must remain >= 80%."
2. "Any new module, class, or method must reach >= 90% coverage."
3. "Coverage command: `npm run test:unit:coverage`"
4. "Coverage regression on changed lines is a blocking finding."

`npm run test:unit:coverage` script verified to pre-exist in root `package.json` at line 18 (`"test:unit:coverage": "node run-jest.cjs --coverage"`). No `package.json` change required.

---

### AC-4 — `python.md`: repo-wide ≥80% coverage floor

**Status: PASS**

File `.claude/rules/python.md` updated. Addition confirmed at line 39: "Repository-wide line coverage must remain >= 80%." The file previously contained a ≥90% new-logic statement (line 16). Both thresholds are now present.

---

### AC-5 — `csharp.md`: ≥80% and ≥90% coverage thresholds

**Status: PASS**

File `.claude/rules/csharp.md` updated. Three additions confirmed at lines 39-41: ≥80% repo-wide, ≥90% new code, and coverage regression as a blocking finding.

---

### AC-6 — `powershell.md`: ≥80% and ≥90% coverage thresholds

**Status: PASS**

File `.claude/rules/powershell.md` updated. Three additions confirmed at lines 46-48: ≥80% repo-wide, ≥90% new code, and coverage regression as a blocking finding.

---

### AC-7 — `tonality.md`: `paths: "**"`, professional tone + prohibition patterns

**Status: PASS**

File exists at `.claude/rules/tonality.md`. YAML frontmatter: `paths: "**"`. Content verified to include: Required Professional Tone, Humor and Joking (Prohibited), Hyperbole (Prohibited), Metaphors (Tightly Restricted), Evidence-First Wording, Difficult Messages guidance, and Final Rule. Source: `.github/instructions/tonality.instructions.md`.

---

### AC-8 — `typescript-suppressions.md`: `paths: "**/*.ts"`, pre-authorized ESLint + @ts-expect-error patterns

**Status: PASS**

File exists at `.claude/rules/typescript-suppressions.md`. YAML frontmatter: `paths: "**/*.ts"`. Pre-authorized patterns: `eslint-disable-next-line <rule> -- <reason>` (single rule, single line, required reason) and `// @ts-expect-error -- <reason>` (single line, required reason). Explicitly prohibited: file-level ESLint disables, `@ts-ignore`, `@ts-nocheck`. Authorization requirement and escalation path present. Source: `.github/instructions/typescript-suppressions.instructions.md`.

---

### AC-9 — `python-suppressions.md`: `paths: "**/*.py"`, S603/ARG002/B008/BLE001/S110 patterns

**Status: PASS**

File exists at `.claude/rules/python-suppressions.md`. YAML frontmatter: `paths: "**/*.py"`. All 5 required patterns verified:
- **S603** — subprocess via `shutil.which()` validation ✅
- **ARG002** — unused method argument in test mocks ✅
- **B008** — function call in default argument (Typer) ✅
- **BLE001** — blind except at CLI entry points only ✅
- **S110** — explicitly marked NOT AUTHORIZED with prohibited workarounds ✅

Additional patterns present (additive): TCH002/TCH003, S310, S314, S301, S108/S105. Source: `.github/instructions/python-suppressions.instructions.md`.

---

### AC-10 — `self-explanatory-code-commenting.md`: `paths: "**/*.py"`, docstrings + loops/branches

**Status: PASS**

File exists at `.claude/rules/self-explanatory-code-commenting.md`. YAML frontmatter: `paths: "**/*.py"`. Content verified: Core Principle, Mandatory class docstrings (purpose, responsibilities, usage, flow, invariants, side effects, attributes), Mandatory function/method docstrings (purpose, parameters, returns, raises, side effects), Loops and comprehensions (intent comment required), Branching (decision criteria, ordering rationale, business rationale), Multi-step block comments (meta-what + why), Anti-patterns and quality checklist. Source: `.github/instructions/self-explanatory-code-commenting.instructions.md`.

---

### AC-11 — `feature-review-workflow/SKILL.md`: Step 5 coverage item + Step 8 remediation trigger

**Status: PASS**

File `.claude/skills/feature-review-workflow/SKILL.md` updated. Verified:
- Step 5 coverage item (~line 99): "5. **Coverage:** Inspect pre-existing coverage artifacts (TypeScript: `coverage/lcov.info`; Python: `artifacts/python/lcov.info`). Report repo-wide coverage vs. ≥80% and new-code coverage vs. ≥90%. Mark UNVERIFIED if artifact missing."
- Step 8 remediation trigger (~line 135): "coverage regression below policy threshold (< 80% repo-wide or < 90% for new code)"

---

### AC-12 — `feature-review.md`: Coverage Verification section, evidence-based model

**Status: PASS**

File `.claude/agents/feature-review.md` updated. Verified:
- `## Coverage Verification` section header at ~line 63
- Evidence-based model stated: "The agent verifies coverage by inspecting pre-existing coverage artifacts produced during execution rather than rerunning coverage generation."
- TypeScript artifact: `coverage/lcov.info`; Python artifact: `artifacts/python/lcov.info`
- 5-step verification procedure present
- Explicit prohibition: "The agent does NOT rerun coverage generation"

---

## Summary

| ID | Criterion (abbreviated) | Status |
|---|---|---|
| AC-1 | `general-code-change.md` with `paths: "**"`, design principles, toolchain loop | PASS |
| AC-2 | `general-unit-test.md` with `paths: "**"`, ≥80% and ≥90% thresholds | PASS |
| AC-3 | `typescript.md` coverage thresholds and `npm run test:unit:coverage` | PASS |
| AC-4 | `python.md` ≥80% repo-wide floor | PASS |
| AC-5 | `csharp.md` ≥80% and ≥90% thresholds | PASS |
| AC-6 | `powershell.md` ≥80% and ≥90% thresholds | PASS |
| AC-7 | `tonality.md` with `paths: "**"`, professional tone + prohibitions | PASS |
| AC-8 | `typescript-suppressions.md` with `paths: "**/*.ts"`, ESLint + @ts-expect-error | PASS |
| AC-9 | `python-suppressions.md` with `paths: "**/*.py"`, S603/ARG002/B008/BLE001/S110 | PASS |
| AC-10 | `self-explanatory-code-commenting.md` with `paths: "**/*.py"`, docstrings + loops/branches | PASS |
| AC-11 | SKILL.md Step 5 coverage item + Step 8 coverage regression trigger | PASS |
| AC-12 | `feature-review.md` Coverage Verification section, evidence-based model | PASS |
| **Total** | 12 PASS / 0 PARTIAL / 0 FAIL / 0 UNVERIFIED | **PASS** |

**Remediation Required:** No

**Feature Readiness:** PASS — Go

No `remediation-inputs.<timestamp>.md` or `atomic_planner` delegation is needed.

---

## Acceptance Criteria Check-off

All 12 acceptance criteria in `spec.md` were pre-marked `[x]` by the executor. The reviewer verified each criterion against the working-tree file state. All 12 `[x]` marks are confirmed as accurate. No items remain unchecked. No reviewer check-offs were required.

---

## Out-of-Scope Observations

Two files were updated beyond the spec scope:

1. `.github/agents/feature-review.agent.md` — Updated with identical Coverage Verification section. Spec excluded `.github/agents/` from this issue. Change is additive, consistent with the `.claude/` mirror, and improves Copilot runtime alignment. No remediation needed.

2. `.github/skills/feature-review-workflow/SKILL.md` — Updated with identical coverage Step 5 and Step 8 entries. Spec scoped only the `.claude/` copy. Change is additive and consistent. No remediation needed.

Both observations are documented for traceability. Neither requires action.
