# 2026-04-17-github-instructions-not-migrated-to-claude (Plan)

- **Issue:** #151
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-04-17T16-30
- **Status:** Approved
- **Version:** 1.0
- **Plan path:** `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/plan.2026-04-17T16-13.md`

---

## Context

Fix the incomplete migration of `.github/instructions/*.md` policy files to `.claude/rules/*.md`. The fix creates six new rule files, updates four existing ones, and adds coverage enforcement to the feature-review-workflow skill and feature-review agent. All changes are additive markdown edits; no executable code changes are required.

**PREFLIGHT: ALL CLEAR**

Source documents:
- `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/issue.md`
- `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/spec.md`
- `artifacts/research/20260417-github-instructions-not-migrated-to-claude-151-research.md`

---

## Phase 0 — Baseline Capture

- [x] [P0-T1] Read and record the current `.claude/rules/` directory listing (expected: 4 files — `csharp.md`, `powershell.md`, `python.md`, `typescript.md`). Confirm none of the 6 files to be created already exist. Record as baseline evidence in `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/phase0-instructions-read.md`.
- [x] [P0-T2] Record the spec file path, the AC list (AC-1 through AC-12), and the plan-path in the baseline evidence file. Confirm the spec status is not "Delivered" before proceeding.
- [x] [P0-T3] Read `.github/skills/feature-review-workflow/SKILL.md` Step 5 and Step 8 sections and record their current content verbatim in the baseline evidence file. These are the specific insertion points for Phase 3.
- [x] [P0-T4] Read `.claude/agents/feature-review.md` and record the current `tools:` allowlist and agent body in the baseline evidence file to inform the Phase 3 update.

---

## Phase 1 — Create New `.claude/rules/` Files

### [P1-T1] Create `.claude/rules/general-code-change.md`

**Acceptance criteria:** File exists at `.claude/rules/general-code-change.md`. Frontmatter has `paths: "**"` and a description stating it covers `general-code-change.instructions.md`. File contains at minimum: design principles (simplicity, reusability, extensibility, separation of concerns), the mandatory toolchain loop order (format → lint → type-check → test with restart-from-step-1 rule), the 500-line file size limit, and the error-handling rule (fail fast, no silent broad-catch).

- [x] [P1-T1] Create `.claude/rules/general-code-change.md` with the required frontmatter and a condensed summary of `general-code-change.instructions.md`.

### [P1-T2] Create `.claude/rules/general-unit-test.md`

**Acceptance criteria:** File exists at `.claude/rules/general-unit-test.md`. Frontmatter has `paths: "**"` and a description stating it covers `general-unit-test.instructions.md`. File contains the following verbatim thresholds: "Repository-wide line coverage must remain >= 80%." and "Any new module, class, or method must target >= 90% coverage." File also contains the five core test principles (independence, isolation, fast execution, determinism, readability), the Arrange–Act–Assert pattern, the prohibition on temporary file creation in tests, and the scenario completeness requirements (positive, negative, edge, error, concurrency, state transitions).

- [x] [P1-T2] Create `.claude/rules/general-unit-test.md` with the required frontmatter and a condensed summary of `general-unit-test.instructions.md`.

### [P1-T3] Create `.claude/rules/tonality.md`

**Acceptance criteria:** File exists at `.claude/rules/tonality.md`. Frontmatter has `paths: "**"` and a description. File contains: required professional tone definition, prohibition on humor/jokes/banter/sarcasm/puns, prohibition on hyperbole/inflated language, restriction on metaphor to utilitarian-only, evidence-first wording rule, and the final rule (when tone is uncertain, choose the more restrained phrasing).

- [x] [P1-T3] Create `.claude/rules/tonality.md` with the required frontmatter and a condensed summary of `tonality.instructions.md`.

### [P1-T4] Create `.claude/rules/typescript-suppressions.md`

**Acceptance criteria:** File exists at `.claude/rules/typescript-suppressions.md`. Frontmatter has `paths: "**/*.ts"` and a description. File contains the authorization requirement (must match pre-authorized pattern or have explicit user approval). File documents the two pre-authorized patterns: (1) `// eslint-disable-next-line <rule-name> -- <reason>` for single-rule single-line ESLint suppression, (2) `// @ts-expect-error -- <reason>` for TypeScript suppressions. File explicitly lists as prohibited: `/* eslint-disable */` (file-level), `// @ts-ignore`, `// @ts-nocheck`. File states the escalation path (five+ refactor attempts before requesting approval).

- [x] [P1-T4] Create `.claude/rules/typescript-suppressions.md` with the required frontmatter and content.

### [P1-T5] Create `.claude/rules/python-suppressions.md`

**Acceptance criteria:** File exists at `.claude/rules/python-suppressions.md`. Frontmatter has `paths: "**/*.py"` and a description. File contains the authorization requirement. File lists at minimum these pre-authorized `# noqa` patterns with their required comment format: S603, ARG002, B008, TCH002/TCH003, S310, S314, BLE001, S301. File lists the S110 as explicitly not authorized with the documented workaround. File states the escalation path.

- [x] [P1-T5] Create `.claude/rules/python-suppressions.md` with the required frontmatter and content.

### [P1-T6] Create `.claude/rules/self-explanatory-code-commenting.md`

**Acceptance criteria:** File exists at `.claude/rules/self-explanatory-code-commenting.md`. Frontmatter has `paths: "**/*.py"` and a description. File contains: the mandatory class docstring requirement (purpose, responsibilities, usage, invariants, side effects), the mandatory function/method docstring requirement (purpose, parameters, returns, raises, side effects), the rule that every `for`/`while` loop and non-trivial comprehension must have an intent comment above it, the rule that branching (if/elif/else, match/case) must have decision-logic comments, the rule to use meta-what comments for multi-step blocks, and the prohibition on numbered notes (NOTE 1:, NOTE 2:).

- [x] [P1-T6] Create `.claude/rules/self-explanatory-code-commenting.md` with the required frontmatter and content.

---

## Phase 2 — Update Existing `.claude/rules/` Files

### [P2-T1] Update `.claude/rules/typescript.md`

**Acceptance criteria:** The Testing Standards section of `.claude/rules/typescript.md` contains all three of the following new items: (1) `- Repository-wide line coverage must remain >= 80%.`, (2) `- Any new module, class, or method must reach >= 90% coverage.`, (3) `- Coverage command: \`npm run test:unit:coverage\`` and a statement that coverage regression on changed lines is a blocking finding. Existing content is unchanged.

- [x] [P2-T1] Add coverage threshold lines and coverage command to the Testing Standards section of `.claude/rules/typescript.md`.

### [P2-T2] Update `.claude/rules/python.md`

**Acceptance criteria:** The Testing Standards section of `.claude/rules/python.md` contains the line `- Repository-wide line coverage must remain >= 80%.` in addition to the existing `>= 90%` new-code requirement. The existing `poetry run pytest --cov` command line is preserved.

- [x] [P2-T2] Add the repo-wide ≥80% coverage floor to the Testing Standards section of `.claude/rules/python.md`.

### [P2-T3] Update `.claude/rules/csharp.md`

**Acceptance criteria:** The Testing Standards section of `.claude/rules/csharp.md` contains: `- Repository-wide line coverage must remain >= 80%.`, `- Any new module, class, or method must reach >= 90% coverage.`, and a statement that coverage regression on changed lines is a blocking finding. Existing content is unchanged.

- [x] [P2-T3] Add coverage threshold lines to the Testing Standards section of `.claude/rules/csharp.md`.

### [P2-T4] Update `.claude/rules/powershell.md`

**Acceptance criteria:** The Testing Standards section of `.claude/rules/powershell.md` contains: `- Repository-wide line coverage must remain >= 80%.`, `- Any new module, class, or method must reach >= 90% coverage.`, and a statement that coverage regression on changed lines is a blocking finding. Existing content is unchanged.

- [x] [P2-T4] Add coverage threshold lines to the Testing Standards section of `.claude/rules/powershell.md`.

---

## Phase 3 — Update Skill and Agent Coverage Enforcement

### [P3-T1] Update `.github/skills/feature-review-workflow/SKILL.md` (canonical source)

**Acceptance criteria:** Step 5 "Run required checks" in `.github/skills/feature-review-workflow/SKILL.md` includes a numbered coverage check item that states: run `npm run test:unit:coverage` (TypeScript) or `poetry run pytest --cov` (Python) and record coverage; flag as FAIL if repo-wide coverage is below 80% or any new module/class/method is below 90%. Step 8 "Trigger remediation when required" includes "coverage regression below policy threshold (< 80% repo-wide or < 90% for new code)" as a remediation-required condition.

- [x] [P3-T1] Update `.github/skills/feature-review-workflow/SKILL.md` per the acceptance criteria above. The canonical note at the top must be preserved unchanged. The update must use the exact replacement text with consistent formatting to the existing numbered list.

### [P3-T2] Update `.claude/skills/feature-review-workflow/SKILL.md` (runtime mirror)

**Acceptance criteria:** `.claude/skills/feature-review-workflow/SKILL.md` reflects the same Step 5 and Step 8 changes as the canonical source. The mirror header note (`> Canonical authored source:`) is preserved unchanged.

- [x] [P3-T2] Apply the same Step 5 and Step 8 changes to `.claude/skills/feature-review-workflow/SKILL.md`. These changes must be identical to P3-T1.

### [P3-T3] Update `.claude/agents/feature-review.md`

**Acceptance criteria:** `.claude/agents/feature-review.md` contains a "Coverage Verification" section or has updated "Constraints" that state: the agent verifies coverage by inspecting pre-existing coverage artifacts (e.g., `coverage/lcov.info` for TypeScript, `artifacts/python/lcov.info` for Python) rather than rerunning coverage generation. If no artifact exists, the agent marks the coverage section as UNVERIFIED with the reason "no coverage artifact found." The agent does NOT require a new `Bash(npm run test:unit:coverage)` in its tool allowlist — evidence verification is the model.

- [x] [P3-T3] Update `.claude/agents/feature-review.md` to add coverage verification instructions per the acceptance criteria.

### [P3-T4] Update `.github/agents/feature-review.agent.md` (canonical agent source) if file exists

**Acceptance criteria:** If `.github/agents/feature-review.agent.md` exists, it contains the same coverage-verification instruction update as `.claude/agents/feature-review.md`.

- [x] [P3-T4] Check whether `.github/agents/feature-review.agent.md` exists. If it does, apply the same coverage verification instruction update. If it does not exist, mark this task SKIPPED and record the reason.

---

## Phase 4 — Verification

- [x] [P4-T1] List `.claude/rules/` directory and confirm all 10 expected files exist: `general-code-change.md`, `general-unit-test.md`, `tonality.md`, `typescript-suppressions.md`, `python-suppressions.md`, `self-explanatory-code-commenting.md`, `typescript.md`, `python.md`, `csharp.md`, `powershell.md`.
- [x] [P4-T2] For each of the 6 new files, verify the `paths:` frontmatter value matches the spec: `**` for general, tonality; `**/*.py` for python-suppressions and commenting; `**/*.ts` for typescript-suppressions.
- [x] [P4-T3] Grep `.claude/rules/typescript.md` for "80%" and confirm the repo-wide coverage threshold is present.
- [x] [P4-T4] Grep `.claude/rules/python.md` for "80%" and confirm the repo-wide coverage floor is present.
- [x] [P4-T5] Grep `.claude/rules/csharp.md` for "80%" and confirm the repo-wide coverage threshold is present.
- [x] [P4-T6] Grep `.claude/rules/powershell.md` for "80%" and confirm the repo-wide coverage threshold is present.
- [x] [P4-T7] Read `.claude/skills/feature-review-workflow/SKILL.md` Step 5 and confirm a coverage check item is present.
- [x] [P4-T8] Read `.claude/skills/feature-review-workflow/SKILL.md` Step 8 and confirm "coverage regression" appears as a remediation trigger.
- [x] [P4-T9] Check off AC-1 through AC-12 in `spec.md` for each criterion verified in P4-T1 through P4-T8.
- [x] [P4-T10] Update `spec.md` status field from "Draft" to "Delivered" and set Last Updated to today's date.

