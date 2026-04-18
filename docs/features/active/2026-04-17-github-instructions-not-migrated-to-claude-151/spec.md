# 2026-04-17-github-instructions-not-migrated-to-claude (Spec)

- **Issue:** #151
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-04-17
- **Status:** In Progress
- **Version:** 0.1

## Context
The migration of `.github/instructions/*.md` policy files into `.claude/rules/*.md` is incomplete and partially lossy. The migration created four consolidated `.claude/rules/*.md` files from the eight language-specific code-change and unit-test instruction files, but it did not create Claude-native rule mirrors for the cross-cutting instruction set, including `general-unit-test.instructions.md` — the canonical source for cross-language coverage requirements (≥80% repo-wide, ≥90% new code). It also dropped coverage requirements from `.claude/rules/typescript.md` and only partially carried them into `.claude/rules/python.md` (the 90% new-logic requirement is present, but the repo-wide 80% floor is absent). As a result, no Claude runtime file that the feature-review workflow actually reads enforces the full coverage policy, and feature-review audits can pass without verifying coverage metrics.

Environment:
- OS/version: All (repo configuration issue, not OS-specific)
- Python version: N/A
- Command/flags used: N/A — manifests during any Claude Code session that invokes the feature-review workflow
- Data source or fixture: `.github/instructions/` (16 files), `.claude/rules/` (4 files)

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

Coverage regressions introduced by any TypeScript change can pass full orchestration review undetected. The gap is systematic — it affects every TypeScript feature review, not just this one.


## Repro & Evidence
Steps to Reproduce:
1. Open a Claude Code session in this repository.
2. Execute a full-feature orchestration workflow through the execution and post-implementation review steps.
3. Observe that the feature-review agent does not run or verify a coverage check during the policy audit.
4. Confirm that `.claude/rules/` contains no `general-unit-test.md` or `general-code-change.md`.
5. Confirm that `.claude/rules/typescript.md` contains no mention of coverage thresholds.

Expected:
The feature-review agent enforces the same coverage requirements as the GitHub Copilot ecosystem:
- Repository-wide line coverage must remain ≥ 80%.
- Any new module, class, or method introduced in a change must reach ≥ 90% coverage.
- Coverage regression on changed lines is a blocking finding that triggers remediation.
These requirements are defined in `.github/instructions/general-unit-test.instructions.md` and should be replicated in the Claude ecosystem via `.claude/rules/`.

Actual:
The feature-review agent does not check coverage. No coverage gate exists in `.claude/skills/feature-review-workflow/SKILL.md`. No complete coverage requirement appears in `.claude/rules/typescript.md` or any other `.claude/rules/` file. `.claude/agents/feature-review.md` also does not allow a coverage command such as `npm run test:coverage`, so the reviewer cannot run coverage directly with the current tool policy and can only verify pre-existing evidence if some earlier execution step produced it. A feature implementation can therefore ship with zero new TypeScript test coverage and receive a PASS verdict from the Claude reviewer.

Observed during feature review of push-down-claude-dir (#149): the re-audit at `docs/features/active/2026-04-16-push-down-claude-dir-149/feature-audit.2026-04-17T00-30.md` noted `PV-1: Python toolchain (Black, Ruff, Pyright) was not run in a recorded evidence artifact` as non-blocking, but the TypeScript coverage gap was not flagged at all because no rule surface it to the reviewer.

Logs / Screenshots:
- [x] Observed gap documented in re-audit artifact: `docs/features/active/2026-04-16-push-down-claude-dir-149/policy-audit.2026-04-17T00-30.md`

- Snippet — `.claude/rules/typescript.md` Testing Standards (current, incomplete):
  ```
  - Use **Jest** as the test framework.
  - Name test files `*.test.ts`.
  - Unit tests must not require the VS Code extension host.
  - Follow Arrange–Act–Assert structure.
  - Each test targets one behavior.
  [no coverage threshold or coverage command]
  ```

- Contrast with `.claude/rules/python.md` Testing Standards (partially migrated):
  ```
  - Command: `poetry run pytest --cov --cov-report=term-missing`
  - New logic must have test coverage >= 90%.
  [repo-wide >=80% floor is still absent]
  ```


## Scope & Non-Goals
- In scope:
  - **DONE** — Create `.claude/rules/general-code-change.md` — cross-language design principles and toolchain loop
  - **DONE** — Create `.claude/rules/general-unit-test.md` — cross-language coverage floors and test principles
  - **DONE** — Create `.claude/rules/tonality.md` — communication tone policy
  - **DONE** — Create `.claude/rules/typescript-suppressions.md` — TypeScript ESLint/TSC suppression authorization
  - **DONE** — Create `.claude/rules/python-suppressions.md` — Python Ruff/Pyright suppression authorization
  - **DONE** — Create `.claude/rules/self-explanatory-code-commenting.md` — code commenting standards
  - **DONE** — Update `.claude/rules/typescript.md` — add coverage thresholds and `test:unit:coverage` command
  - **DONE** — Update `.claude/rules/python.md` — add repo-wide ≥80% coverage floor
  - **DONE** — Update `.claude/rules/csharp.md` — add coverage thresholds
  - **DONE** — Update `.claude/rules/powershell.md` — add coverage thresholds
  - **DONE** — Update `.claude/skills/feature-review-workflow/SKILL.md` — add coverage as required check (Step 5) and as a remediation trigger (Step 8)
  - **DONE** — Update `.claude/agents/feature-review.md` — add evidence-based coverage verification instructions
  - **DONE** — Update `.github/agents/feature-review.agent.md` — add evidence-based coverage verification instructions
  - **DONE** — Update `package.json` (root) — add `test:unit:coverage` npm script
  - **REMAINING** — Synchronize `extensions/drm-copilot/resources/customizations/.github/agents/feature-review.agent.md` with the root `.github/agents/feature-review.agent.md` — the bundled mirror has 41 lines vs root 112 lines; the Coverage Verification section, Constraints, Operating rules, and Phase A/B execution plan are absent from the bundled file

- Out of scope / non-goals:
  - Do not modify any `.github/instructions/*.md` files; these remain the authoritative source
  - Do not mirror `github-actions-ci-cd-best-practices.instructions.md` as a full verbatim copy; a condensed summary only
  - Do not add `github-actions.md` in this issue — the GitHub Actions rules gap is lower priority and should be tracked in a separate issue
  - Do not change `CLAUDE.md` (root standing instructions)
  - Do not add coverage reporting to the test runner itself (Jest `coverageThreshold` config) unless the engineer determines it is necessary for correctness; agent-level coverage verification is the primary mechanism here

- Explicitly excluded systems, integrations, or datasets:
  - The `.claude/worktrees/` directory does not need to be updated
  - Agent files under `.github/agents/` are not in scope; only `.claude/agents/` mirrors are updated

## Root Cause Analysis
The migration of `.github/instructions/*.md` into `.claude/rules/*.md` produced four consolidated language rule files:

| `.claude/rules/` file | Source(s) it claims to cover |
|---|---|
| `typescript.md` | `typescript-code-change.instructions.md` + `typescript-unit-test.instructions.md` |
| `python.md` | `python-code-change.instructions.md` + `python-unit-test.instructions.md` |
| `csharp.md` | `csharp-code-change.instructions.md` + `csharp-unit-test.instructions.md` |
| `powershell.md` | `powershell-code-change.instructions.md` + `powershell-unit-test.instructions.md` |

That means the language-specific code-change and unit-test instruction pairs were folded into four rule files, but the cross-cutting and suppression instruction set still has no standalone Claude-native mirror.

**No standalone `.claude/rules/` mirror exists for these 8 instruction files:**

| `.github/instructions/` file | Policy content |
|---|---|
| `general-code-change.instructions.md` | Cross-language design principles, toolchain loop, no-shortcuts policy |
| `general-unit-test.instructions.md` | Cross-language coverage floors, independence, isolation, scenario completeness |
| `tonality.instructions.md` | Full tone and communication policy |
| `self-explanatory-code-commenting.instructions.md` | Code commenting standards |
| `typescript-suppressions.instructions.md` | TypeScript ESLint/TSC suppression authorization |
| `python-suppressions.instructions.md` | Python Ruff/Pyright suppression authorization |
| `github-actions.instructions.md` | GitHub Actions workflow rules |
| `github-actions-ci-cd-best-practices.instructions.md` | CI/CD best practices |

**Migrated but with content gaps:**

| `.claude/rules/` file | Missing content |
|---|---|
| `typescript.md` | Coverage command and coverage thresholds are absent. The file lists `npm run test:unit`, but it does not mention `npm run test:coverage`, the ≥80% repo-wide floor, or the ≥90% new-code floor. |
| `python.md` | Includes `pytest --cov` and the ≥90% new-logic statement, but it still omits the ≥80% repo-wide floor from `general-unit-test.instructions.md`. |

The direct runtime effect is that no Claude review-scope file actually enforces coverage:

- `.claude/skills/feature-review-workflow/SKILL.md` Step 5 ("Run required checks") lists only format, lint, type-check, and tests.
- `.claude/skills/feature-review-workflow/SKILL.md` Step 8 does not list coverage regression as a remediation trigger.
- `.claude/agents/feature-review.md` permits only `git diff` and `git log` Bash commands, so the reviewer cannot run `npm run test:coverage` even if the workflow text were updated.

There is also an architectural coupling worth noting: several `.claude` runtime mirrors still carry headers such as "Canonical authored source: `.github/...`" and "Update the `.github` source first." That mirror model is compatible with repository sync workflows, but it is inconsistent with the stated goal that the Claude ecosystem should remain functionally complete even if the GitHub-specific runtime layer is absent.

The planning layer is only partially implicated. `.claude/skills/atomic-plan-contract/SKILL.md` already contains a generic "Coverage Evidence Contract" that requires explicit baseline and final-QC coverage tasks when repository policy requires coverage. The missing piece is that the Claude rule surface does not currently state that TypeScript review/execution requires coverage, so the generic contract is not activated deterministically for TypeScript work.


## Proposed Fix

### Design summary (what changes where):

The fix has three logical layers:

1. **Rule surface additions/updates (`.claude/rules/`)**: Create six new Claude rule files that mirror the eight unmigrated instruction files (pairing `general-code-change` + `general-unit-test` into one file, and `typescript-suppressions` + `python-suppressions` as separate language-scoped files). Update four existing rule files to add the missing coverage thresholds.

2. **Workflow enforcement (`.claude/skills/feature-review-workflow/SKILL.md`)**: Add coverage as a required check in Step 5 and add coverage regression as a remediation trigger in Step 8. This ensures the review workflow acts on the new coverage requirements in the rule surface.

3. **Agent tool policy (`.claude/agents/feature-review.md`)**: Determine the coverage execution model. The preferred model is evidence verification — the reviewer checks pre-existing coverage artifacts produced by the executor — rather than running coverage directly. This avoids requiring the `npm run test:unit:coverage` command in the reviewer's tool allowlist.

### Boundaries and invariants to preserve:

- All `.github/instructions/*.md` files remain unchanged.
- Existing content in each `.claude/rules/*.md` file must be preserved; only additive changes are made.
- The YAML frontmatter `paths:` field in each rule file is the activation scope; it must be correct for each rule to apply to the right files.
- The feature-review agent must remain read-only regarding source code; coverage evidence is verified from artifacts, not recomputed live.

### Dependencies or blocked work:

- None. This fix is self-contained and does not require external service changes or third-party library additions.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

- **Create (6 new `.claude/rules/` files)**:
  - `general-code-change.md` — condensed summary of `general-code-change.instructions.md`, paths `**`
  - `general-unit-test.md` — condensed summary of `general-unit-test.instructions.md`, paths `**`; carries the ≥80%/≥90% coverage floors
  - `tonality.md` — condensed summary of `tonality.instructions.md`, paths `**`
  - `typescript-suppressions.md` — pre-authorized patterns from `typescript-suppressions.instructions.md`, paths `**/*.ts`
  - `python-suppressions.md` — condensed pre-authorized patterns from `python-suppressions.instructions.md`, paths `**/*.py`
  - `self-explanatory-code-commenting.md` — condensed summary of `self-explanatory-code-commenting.instructions.md`, paths `**/*.py`

- **Update (4 existing `.claude/rules/` files)**:
  - `typescript.md` — add coverage thresholds (≥80% repo, ≥90% new code) and `npm run test:unit:coverage` command to Testing Standards
  - `python.md` — add ≥80% repo-wide coverage floor to Testing Standards
  - `csharp.md` — add coverage thresholds to Testing Standards
  - `powershell.md` — add coverage thresholds to Testing Standards

- **Update (1 skill file)**:
  - `.claude/skills/feature-review-workflow/SKILL.md` — add coverage verification step and remediation trigger

- **Update (1 agent file)**:
  - `.claude/agents/feature-review.md` — add evidence-based coverage verification instructions

#### Functions/classes/CLI commands impacted:

- `npm run test:unit:coverage` — must exist in `package.json` for coverage evidence production by the executor
- Verify script exists in `package.json` before adding to agent instructions

#### Data flow and validation changes:

- No data flow changes. These are documentation/configuration files that describe required behavior.

#### Error handling and logging updates:

- Not applicable; no executable code changes.

#### Rollback/feature-flag considerations (if applicable):

- All changes are additive markdown additions. Rollback is a `git revert`. No feature flags are required.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

- All files are UTF-8 Markdown.
- Rule files use YAML frontmatter with `paths:` and `description:` fields.
- Rule file content is a condensed summary, not a verbatim copy, of the source instruction file.

#### Required configuration keys and defaults:

- `paths:` in each rule file frontmatter: see the scope table above.

#### Backward-compatibility expectations:

- Existing `.claude/rules/*.md` content is additive only; no content is removed.
- Existing `.claude/skills/` and `.claude/agents/` content that is not related to coverage is unchanged.

#### Performance constraints (latency/throughput/memory):

- Not applicable; these are static documentation files.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access): Claude Code loads `.claude/rules/*.md` files based on the `paths:` frontmatter and makes them available to all agents in a session.
- Constraints (budget, performance, compatibility): Each rule file must follow the condensed-summary format used by existing rule files (not verbatim copies of source instruction files).
- External dependencies (services, libraries, releases): None.

## Data / API / Config Impact
- User-facing or API changes: None; these are internal Claude runtime configuration files.
- Data or migration considerations: None.
- Logging/telemetry updates (if any): None.
- Compatibility notes (CLI flags, config schemas, versioning): None.

## Test Strategy
Seeded from issue:

**Rule file additions/updates (`.claude/rules/`):**

- [x] Create `.claude/rules/general-code-change.md` — migrate `general-code-change.instructions.md` with `paths: ["**"]`
- [x] Create `.claude/rules/general-unit-test.md` — migrate `general-unit-test.instructions.md` with `paths: ["**"]`; this file carries the ≥80%/≥90% coverage floors and is the primary fix
- [x] Update `.claude/rules/typescript.md` — add `npm run test:coverage` plus the ≥80% repo-wide and ≥90% new-code coverage floors
- [x] Update `.claude/rules/python.md` — add the missing ≥80% repo-wide coverage floor so Python fully reflects `general-unit-test.instructions.md`
- [x] Create `.claude/rules/tonality.md` — migrate `tonality.instructions.md` with `paths: ["**"]`
- [x] Create `.claude/rules/typescript-suppressions.md` — migrate `typescript-suppressions.instructions.md` scoped to `**/*.ts`
- [x] Create `.claude/rules/python-suppressions.md` — migrate `python-suppressions.instructions.md` scoped to `**/*.py`
- [x] Create `.claude/rules/self-explanatory-code-commenting.md` — migrate `self-explanatory-code-commenting.instructions.md` with `paths: ["**"]`

**Skill update (`.claude/skills/feature-review-workflow/SKILL.md`):**

- [x] Add coverage as Step 5 item 5: run `npm run test:coverage` (TypeScript) or `poetry run pytest --cov` (Python); record pre-change baseline and post-change values; fail if repo-wide coverage drops below 80% or any new module is below 90%
- [x] Add coverage regression to Step 8 remediation triggers

**Agent/runtime decision (`.claude/agents/feature-review.md` and plan generation):**

- [x] If the reviewer should run coverage directly, add a coverage-command allowlist entry such as `Bash(npm run test:coverage *)`
- [x] If the reviewer should remain evidence-only, keep the restricted tool policy and ensure TypeScript plans emitted by the Claude planner include explicit coverage tasks and artifacts, using the existing coverage-evidence contract in `.claude/skills/atomic-plan-contract/SKILL.md`

**Extension tooling (`extensions/drm-copilot/package.json`):**

- [x] Add `test:coverage` npm script (`node run-jest.cjs --coverage`) so reviewers have a deterministic command to run and reference
- [x] Optionally add `coverageThreshold` to Jest config to make the toolchain itself fail on regression rather than relying solely on agent judgment

**Validation:**

- [x] After fix: run a test feature review and confirm coverage is checked, reported, and triggers remediation when below threshold
- [x] Confirm `.claude/rules/typescript.md` and `general-unit-test.md` are loaded and visible in a new Claude Code session context
- [x] Confirm `feature-review-workflow` Step 5 now includes coverage in the ordered check list
- [x] Confirm the chosen execution model is internally consistent: either the reviewer can run coverage directly via its tool policy, or the reviewer explicitly verifies coverage artifacts that the executor is required to produce

- Regression tests to add or update: Not applicable; no executable logic changes. Validation is manual inspection of file content.
- Unit tests (pytest) for the fixed behavior and boundaries: Not applicable.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values): Ensure `paths:` frontmatter values are correctly scoped — a `paths: **` must not accidentally break narrower language-scoped rules.
- Error handling and logging verification: Not applicable.
- Coverage impact and targets for changed lines/modules: Not applicable; `.md` files are not measured by coverage tooling.
- Toolchain commands to run (format → lint → type-check → test): None required for markdown-only changes. No Black/Ruff/Pyright/Pytest or Prettier/ESLint/TSC/Jest runs are triggered by markdown file changes.
- Manual validation steps (if required): Manually open a Claude Code session and confirm the new rule files are visible in the loaded context when working on a `.ts` or `.py` file. Confirm coverage thresholds appear in the TypeScript and Python rule text.


## Acceptance Criteria
- [ ] AC-1: `.claude/rules/general-code-change.md` exists with `paths: **`, summarizes the cross-language design principles and the mandatory toolchain loop order (format → lint → type-check → test).
- [ ] AC-2: `.claude/rules/general-unit-test.md` exists with `paths: **`, and explicitly states: repository-wide line coverage ≥ 80% and any new module/class/method ≥ 90%.
- [ ] AC-3: `.claude/rules/typescript.md` Testing Standards section includes: coverage thresholds (≥80% repo-wide, ≥90% new code) and the coverage command (`npm run test:unit:coverage`).
- [ ] AC-4: `.claude/rules/python.md` Testing Standards section includes the repo-wide ≥80% coverage floor (in addition to the existing ≥90% new-code statement).
- [ ] AC-5: `.claude/rules/csharp.md` Testing Standards section includes coverage thresholds (≥80% repo, ≥90% new code).
- [ ] AC-6: `.claude/rules/powershell.md` Testing Standards section includes coverage thresholds (≥80% repo, ≥90% new code).
- [ ] AC-7: `.claude/rules/tonality.md` exists with `paths: **`, summarizes the professional tone requirements and the prohibitions on humor, hyperbole, and decorative metaphor.
- [ ] AC-8: `.claude/rules/typescript-suppressions.md` exists with `paths: **/*.ts`, lists the pre-authorized `eslint-disable-next-line` and `@ts-expect-error` patterns with their required comment format.
- [ ] AC-9: `.claude/rules/python-suppressions.md` exists with `paths: **/*.py`, lists at minimum the S603, ARG002, B008, BLE001, and S110 suppression patterns with their pre-authorized comment formats.
- [ ] AC-10: `.claude/rules/self-explanatory-code-commenting.md` exists with `paths: **/*.py`, summarizes mandatory docstring requirements for classes and functions, and the rule that loops and branches must have intent comments.
- [ ] AC-11: `.claude/skills/feature-review-workflow/SKILL.md` Step 5 check list includes a coverage verification step; Step 8 lists coverage regression as a remediation trigger.
- [ ] AC-12: `.claude/agents/feature-review.md` includes instructions for how the reviewer handles coverage — either by verifying existing coverage artifacts or (if the tool policy is expanded) by running the coverage command directly.
- [ ] AC-13: `extensions/drm-copilot/resources/customizations/.github/agents/feature-review.agent.md` is byte-identical to `.github/agents/feature-review.agent.md`.

## Risks & Mitigations
- Technical or operational risks: Rule file `paths:` scope errors could cause a rule intended for all files to silently fail to load for certain file types, or a rule intended for only `.ts` files to bleed into other contexts. Risk is low because Claude Code's path activation is straightforward.
- Mitigations and rollbacks: All changes are additive markdown additions. A `git revert` of this commit set fully restores the prior state. No database migrations or service restarts are required.

## Rollout & Follow-up
- Release/rollout steps: Merge to main. Claude Code sessions will immediately load the updated rule files at next session start.
- Post-fix monitoring or clean-up tasks: Run the next feature review after this fix is merged and confirm coverage is verified in the policy audit.
- Links: Issue #151: https://github.com/drmoisan/drm-copilot/issues/151
