# github-instructions-not-migrated-to-claude (Issue #151)

- Date captured: 2026-04-17
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/github-instructions-not-migrated-to-claude/ (Issue #151)
- Issue: #151
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/151
- Last Updated: 2026-04-17

- Work Mode: full-bug

## Summary

The migration of `.github/instructions/*.md` policy files into `.claude/rules/*.md` is incomplete and partially lossy. The migration created four consolidated `.claude/rules/*.md` files from the eight language-specific code-change and unit-test instruction files, but it did not create Claude-native rule mirrors for the cross-cutting instruction set, including `general-unit-test.instructions.md` — the canonical source for cross-language coverage requirements (≥80% repo-wide, ≥90% new code). It also dropped coverage requirements from `.claude/rules/typescript.md` and only partially carried them into `.claude/rules/python.md` (the 90% new-logic requirement is present, but the repo-wide 80% floor is absent). As a result, no Claude runtime file that the feature-review workflow actually reads enforces the full coverage policy, and feature-review audits can pass without verifying coverage metrics.

## Environment

- OS/version: All (repo configuration issue, not OS-specific)
- Python version: N/A
- Command/flags used: N/A — manifests during any Claude Code session that invokes the feature-review workflow
- Data source or fixture: `.github/instructions/` (16 files), `.claude/rules/` (4 files)

## Steps to Reproduce

1. Open a Claude Code session in this repository.
2. Execute a full-feature orchestration workflow through the execution and post-implementation review steps.
3. Observe that the feature-review agent does not run or verify a coverage check during the policy audit.
4. Confirm that `.claude/rules/` contains no `general-unit-test.md` or `general-code-change.md`.
5. Confirm that `.claude/rules/typescript.md` contains no mention of coverage thresholds.

## Expected Behavior

The feature-review agent enforces the same coverage requirements as the GitHub Copilot ecosystem:
- Repository-wide line coverage must remain ≥ 80%.
- Any new module, class, or method introduced in a change must reach ≥ 90% coverage.
- Coverage regression on changed lines is a blocking finding that triggers remediation.
These requirements are defined in `.github/instructions/general-unit-test.instructions.md` and should be replicated in the Claude ecosystem via `.claude/rules/`.

## Actual Behavior

The feature-review agent does not check coverage. No coverage gate exists in `.claude/skills/feature-review-workflow/SKILL.md`. No complete coverage requirement appears in `.claude/rules/typescript.md` or any other `.claude/rules/` file. `.claude/agents/feature-review.md` also does not allow a coverage command such as `npm run test:coverage`, so the reviewer cannot run coverage directly with the current tool policy and can only verify pre-existing evidence if some earlier execution step produced it. A feature implementation can therefore ship with zero new TypeScript test coverage and receive a PASS verdict from the Claude reviewer.

Observed during feature review of push-down-claude-dir (#149): the re-audit at `docs/features/active/2026-04-16-push-down-claude-dir-149/feature-audit.2026-04-17T00-30.md` noted `PV-1: Python toolchain (Black, Ruff, Pyright) was not run in a recorded evidence artifact` as non-blocking, but the TypeScript coverage gap was not flagged at all because no rule surface it to the reviewer.

## Logs / Screenshots

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

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

Coverage regressions introduced by any TypeScript change can pass full orchestration review undetected. The gap is systematic — it affects every TypeScript feature review, not just this one.

## Suspected Cause / Notes

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

## Proposed Fix / Validation Ideas

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

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch