# Research: github-instructions-not-migrated-to-claude (Issue #151)

- Date: 2026-04-17
- Researcher: Task Researcher
- Issue: docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/issue.md

## Summary

Issue #151 identified that the migration of `.github/instructions/*.md` policy files into `.claude/rules/*.md` was incomplete: six cross-cutting instruction files had no Claude-native mirrors, and two existing rule files were missing coverage thresholds. A prior agent session completed the majority of the fix without documentation. All 10 target `.claude/rules/` files now exist with correct content and frontmatter, both feature-review-workflow SKILL.md files include coverage enforcement, both agent files include Coverage Verification sections, and the root `package.json` has the `test:unit:coverage` script. The sole remaining gap is the bundled extension mirror `extensions/drm-copilot/resources/customizations/.github/agents/feature-review.agent.md`, which has 41 lines and is missing all content added to the root agent file (Coverage Verification, Constraints, Operating rules, and Phase A/B execution plan — 71 lines omitted).

---

## Source Instruction File Inventory

| File | Key content | Migrated? | Notes |
|---|---|---|---|
| `general-code-change.instructions.md` | Design principles (simplicity, reusability, extensibility, separation of concerns), mandatory toolchain loop (format → lint → type-check → test, restart-from-step-1), 500-line file size limit, error handling, naming conventions | ✅ Yes | `.claude/rules/general-code-change.md` created |
| `general-unit-test.instructions.md` | Coverage floors (≥80% repo-wide, ≥90% new code), five core test principles, Arrange–Act–Assert, scenario completeness (positive/negative/edge/error), temporary file prohibition | ✅ Yes | `.claude/rules/general-unit-test.md` created |
| `tonality.instructions.md` | Professional tone, no humor/joking/banter/sarcasm, no hyperbole, metaphor restriction (utilitarian only), evidence-first wording, final rule (choose more restrained phrasing) | ✅ Yes | `.claude/rules/tonality.md` created |
| `self-explanatory-code-commenting.instructions.md` | Mandatory class and function docstrings, intent comments on loops/comprehensions, decision-logic comments on branching, meta-what comments for multi-step blocks, no numbered notes | ✅ Yes | `.claude/rules/self-explanatory-code-commenting.md` created |
| `typescript-suppressions.instructions.md` | Authorization requirement, pre-authorized patterns: `// eslint-disable-next-line <rule> -- <reason>` and `// @ts-expect-error -- <reason>`, prohibited: `/* eslint-disable */`, `// @ts-ignore`, `// @ts-nocheck`, escalation path (5+ attempts) | ✅ Yes | `.claude/rules/typescript-suppressions.md` created |
| `python-suppressions.instructions.md` | Authorization requirement, pre-authorized `# noqa` patterns (S603, ARG002, B008, TCH002/TCH003, S310, S314, BLE001, S301, S108/S105), pre-authorized `# type: ignore` (import-untyped), explicitly not authorized (S110, TID252, S607, D401, F401, UP017), escalation path | ✅ Yes | `.claude/rules/python-suppressions.md` created |

---

## Current State of `.claude/rules/`

### 1. `.claude/rules/general-code-change.md`

- **Exists:** Yes
- **Frontmatter `paths`:** `"**"` — correct
- **Content complete:** Yes
- **Verification evidence:** File contains design principles section, mandatory toolchain loop with four steps and restart rule, 500-line limit, error handling (fail fast, no silent broad-catch), naming conventions.
- **Gaps:** None identified.

### 2. `.claude/rules/general-unit-test.md`

- **Exists:** Yes
- **Frontmatter `paths`:** `"**"` — correct
- **Content complete:** Yes
- **Verification evidence:** Contains "Repository-wide line coverage must remain >= 80%." and "Any new module, class, or method must target >= 90% coverage." Five core principles, Arrange–Act–Assert, scenario completeness list, external dependency prohibition, temporary file prohibition.
- **Gaps:** None identified.

### 3. `.claude/rules/tonality.md`

- **Exists:** Yes
- **Frontmatter `paths`:** `"**"` — correct
- **Content complete:** Yes
- **Verification evidence:** Contains required professional tone definition, humor/joking prohibition, hyperbole prohibition, metaphor restriction, evidence-first wording, difficult messages guidance, final rule.
- **Gaps:** None identified.

### 4. `.claude/rules/typescript-suppressions.md`

- **Exists:** Yes
- **Frontmatter `paths`:** `"**/*.ts"` — correct
- **Content complete:** Yes
- **Verification evidence:** Contains authorization requirement, escalation path (5+ attempts), both pre-authorized patterns with required comment format (`-- <reason>` suffix), prohibited pattern table with four entries, policy enforcement checklist.
- **Gaps:** None identified.

### 5. `.claude/rules/python-suppressions.md`

- **Exists:** Yes
- **Frontmatter `paths`:** `"**/*.py"` — correct
- **Content complete:** Yes
- **Verification evidence:** Contains authorization requirement, pre-authorized `# noqa` patterns (S603, ARG002, B008, TCH002/TCH003, S310, S314, BLE001, S301, S108/S105), pre-authorized `# type: ignore` (import-untyped), not-authorized section (S110, TID252, S607, D401, F401, UP017), policy enforcement checklist.
- **Gaps:** None identified.

### 6. `.claude/rules/self-explanatory-code-commenting.md`

- **Exists:** Yes
- **Frontmatter `paths`:** `"**/*.py"` — correct
- **Content complete:** Substantially yes
- **Verification evidence:** Contains mandatory class docstring requirements, mandatory function/method docstring requirements, loop/comprehension intent comment rule, branching decision-logic comment rule, multi-step block meta-what comment rule.
- **Gaps:** The prohibition on numbered notes (`NOTE 1:`, `NOTE 2:`) is present in the source instruction file but is not explicitly stated in the `.claude/rules/` file. This is a minor content gap.

### 7. `.claude/rules/typescript.md`

- **Exists:** Yes (pre-existing, updated by prior agent)
- **Frontmatter `paths`:** `"**/*.ts"` — correct
- **Coverage thresholds present:** Yes
- **Verification evidence:** Testing Standards section contains: "Repository-wide line coverage must remain >= 80%.", "Any new module, class, or method must reach >= 90% coverage.", "Coverage command: `npm run test:unit:coverage`", "Coverage regression on changed lines is a blocking finding."
- **Gaps:** None identified relative to issue #151 requirements.

### 8. `.claude/rules/python.md`

- **Exists:** Yes (pre-existing, updated by prior agent)
- **Frontmatter `paths`:** `"**/*.py"` — correct
- **Coverage thresholds present:** Yes — both ≥80% and ≥90% floors present
- **Verification evidence:** Testing Standards section contains: "Repository-wide line coverage must remain >= 80%.", "Coverage regression on changed lines is a blocking finding." The ≥90% new-logic statement is in the Toolchain section ("New logic must have test coverage >= 90%"). The `poetry run pytest --cov` command is present.
- **Gaps:** None identified relative to issue #151 requirements.

### 9. `.claude/rules/csharp.md`

- **Exists:** Yes (pre-existing, updated by prior agent)
- **Frontmatter `paths`:** `"**/*.cs"`, `"**/*.csproj"` — correct
- **Coverage thresholds present:** Yes
- **Verification evidence:** Testing Standards section contains: "Repository-wide line coverage must remain >= 80%.", "Any new module, class, or method must reach >= 90% coverage.", "Coverage regression on changed lines is a blocking finding."
- **Gaps:** None identified relative to issue #151 requirements.

### 10. `.claude/rules/powershell.md`

- **Exists:** Yes (pre-existing, updated by prior agent)
- **Frontmatter `paths`:** `"**/*.ps1"`, `"**/*.psm1"`, `"**/*.psd1"` — correct
- **Coverage thresholds present:** Yes
- **Verification evidence:** Testing Standards section contains: "Repository-wide line coverage must remain >= 80%.", "Any new module, class, or method must reach >= 90% coverage.", "Coverage regression on changed lines is a blocking finding."
- **Ancillary gap (outside issue #151 scope):** Toolchain section uses `mcp__drmCopilotExtension__run_poshqc_format`, `mcp__drmCopilotExtension__run_poshqc_analyze`, and `mcp__drmCopilotExtension__run_poshqc_test`. Per repo memory, the canonical test function name is `mcp_drmcopilotext_run_poshqc_test`. This stale naming is a separate defect not covered by issue #151.

---

## Skill and Agent Update Status

### `.github/skills/feature-review-workflow/SKILL.md`

- **Status:** Complete
- **Step 5 coverage check present:** Yes — item 5 in the ordered check list states: run `npm run test:unit:coverage` (TypeScript) or `poetry run pytest --cov` (Python); record coverage; flag as FAIL if repo-wide coverage is below 80% or any new module/class/method is below 90%; if coverage artifacts already exist from the executor run, inspect them instead of re-running.
- **Step 8 coverage regression trigger present:** Yes — "coverage regression below policy threshold (< 80% repo-wide or < 90% for new code)" is listed as a remediation-required condition.

### `.claude/skills/feature-review-workflow/SKILL.md`

- **Status:** Complete — content is identical to `.github/skills/feature-review-workflow/SKILL.md`
- **Step 5 coverage check present:** Yes — same as above
- **Step 8 coverage regression trigger present:** Yes — same as above

### `.claude/agents/feature-review.md`

- **Status:** Complete
- **Coverage Verification section present:** Yes — dedicated `## Coverage Verification` section states: agent verifies by inspecting pre-existing coverage artifacts (`coverage/lcov.info` for TypeScript, `artifacts/python/lcov.info` for Python); if artifact exists, parse and report; flag FAIL if repo-wide < 80% or new module < 90%; if no artifact found, mark UNVERIFIED; agent does NOT rerun coverage generation.
- **Tool allowlist:** `Bash(git diff *)` and `Bash(git log *)` only — consistent with evidence-verification model.

### `.github/agents/feature-review.agent.md`

- **Status:** Complete — file has been updated (112 lines)
- **Coverage Verification section present:** Yes — same Coverage Verification section as `.claude/agents/feature-review.md`, plus Constraints, Operating rules, and Phase A/B execution plan.
- **Note:** The spec's Scope & Non-Goals stated "Agent files under `.github/agents/` are not in scope," but plan task P3-T4 explicitly included this file and the update was applied.

### `package.json` — `test:unit:coverage` script

- **Status:** Present in root `package.json` (line 18): `"test:unit:coverage": "node run-jest.cjs --coverage"`
- **Note:** The spec referenced `extensions/drm-copilot/package.json` as the target, but the script was added to the root `package.json`. `extensions/drm-copilot/package.json` has `test:unit` but not `test:unit:coverage`. Since the TypeScript test runner (`run-jest.cjs`, `jest.config.cjs`) and coverage output (`coverage/`) reside at the repo root, the root `package.json` is the appropriate location. The `.claude/rules/typescript.md` coverage command (`npm run test:unit:coverage`) runs correctly from the root.

---

## Bundled Extension Mirror Status

### `extensions/drm-copilot/resources/customizations/.github/agents/feature-review.agent.md`

- **Line count:** 41 lines
- **Root file line count:** 112 lines (`.github/agents/feature-review.agent.md`)
- **Status:** **OUT OF DATE — DOES NOT MATCH ROOT**
- **Missing content (71 lines):**
  - `# Constraints (feature review)` — 5 constraint rules including "Do not ask the user questions" and "Do not claim completion unless required review artifacts pass their validators"
  - `# Coverage Verification` — complete coverage-verification procedure specifying artifact paths (`coverage/lcov.info`, `artifacts/python/lcov.info`), 5-step verification procedure, 80%/90% thresholds, UNVERIFIED handling, and statement that agent does not rerun coverage generation
  - `# Operating rules (non-negotiable)` — 3 rules: baseline-diff truth, no silent fixes, work-mode marker contract with all three markers and fail-closed behavior
  - `# Execution plan (phased, deterministic)` — Phase A (collect baseline context, 5 steps) and Phase B (determine active feature folder)
- **Impact:** The repo memory states bundled customization mirrors must match root files exactly, and tests enforce exact equality for agent mirrors. This gap means any push-down workflow deploys a stale, incomplete agent definition that omits coverage verification and all operating rules. Mirror-contract tests may fail on this file.
- **Required action:** Overwrite the bundled mirror with the full content of `.github/agents/feature-review.agent.md`.

---

## Remaining Gaps

1. **`extensions/drm-copilot/resources/customizations/.github/agents/feature-review.agent.md` is not synchronized with the root.** The bundled mirror has 41 lines; the root has 112 lines. The mirror is missing the Coverage Verification section, Constraints, Operating rules, and Phase A/B execution plan. This is the only substantive remaining gap from the issue #151 fix scope. Fix: overwrite bundled mirror with root file content and verify files are identical.

2. **Minor: `.claude/rules/self-explanatory-code-commenting.md` does not explicitly state the prohibition on numbered notes** (`NOTE 1:`, `NOTE 2:`). The source instruction file includes this under a dedicated section. The `.claude/rules/` file omits it. This is a low-priority content gap that does not affect coverage enforcement or the primary bug fix.

3. **Ancillary (outside issue #151 scope): `.claude/rules/powershell.md` uses stale MCP function names** (`mcp__drmCopilotExtension__*` instead of canonical `mcp_drmcopilotext_*`). This is a separate defect predating issue #151 and should be tracked independently.

---

## Recommended Fix Scope

Based on verified remaining gaps, the following work remains to close issue #151:

### Required

1. **Synchronize the bundled extension mirror.** Overwrite `extensions/drm-copilot/resources/customizations/.github/agents/feature-review.agent.md` with the complete content of `.github/agents/feature-review.agent.md`. Verify byte-identical content after the update. This restores Coverage Verification, Constraints, Operating rules, and Phase A/B execution plan to the push-down payload.

### Optional (can be included in issue #151 or deferred)

2. **Add numbered-notes prohibition to `.claude/rules/self-explanatory-code-commenting.md`.** Add an explicit statement that numbered notes (`NOTE 1:`, `NOTE 2:`) are prohibited; use `TODO:`, `WARNING:`, `PERF:`, or `SECURITY:` tags instead. This aligns the rule file fully with the source instruction file.

### Out of scope for issue #151 (track separately)

3. **Fix stale MCP function names in `.claude/rules/powershell.md`.** Update `mcp__drmCopilotExtension__run_poshqc_*` references to canonical `mcp_drmcopilotext_*`. This is a separate defect not introduced by issue #151.
