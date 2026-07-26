# 2026-07-25-claude-rules-vitest-jest-divergence (Spec)

- **Issue:** #422
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-07-25
- **Status:** Draft
- **Version:** 1.0

## Context
The Claude-runtime and Codex/agents rule mirrors instruct agents to use Vitest for TypeScript unit tests, but the repository actually runs Jest. `.claude/rules/typescript.md` additionally names two commands that are wrong for this repository: `npm run test` (which is bound to `vscode-test`, the integration-test runner, not unit tests) and `npm run test:coverage` (which does not exist; the root script is `test:unit:coverage`).

The canonical policy source `.github/instructions/typescript-unit-test.instructions.md` correctly mandates Jest (`jest.spyOn`, `jest.mock`, `jest.resetAllMocks`, `jest.useFakeTimers()`) and names the approved command `npm run test:unit`. The divergence is in the mirrors, not the canon. Research adjudicated every occurrence in the owned file set as CORRECT-IN-MIRROR (the mirror text is wrong and must be corrected to match the canon or, where the canon is silent, to match the repository's actual Jest toolchain). See `docs/features/active/2026-07-25-claude-rules-vitest-jest-divergence-422/research/2026-07-25T22-15-claude-rules-vitest-jest-divergence-research.md`.

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- Python version: n/a (defect is in Markdown instruction mirrors)
- Command/flags used: `npm run test:unit` (resolves to `node run-jest.cjs`)
- Data source or fixture: repository at commit `fb483b84`

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

An agent that follows `.claude/rules/typescript.md` will author `vi.*`-based tests that cannot run under Jest, and `.claude/agents/atomic-executor.md` allowlists a `npx vitest` command that does not exist in this repository, so the executor's TypeScript toolchain stage is unrunnable as documented. The bundled extension copies propagate both defects downstream to every consumer repository.


## Repro & Evidence
Steps to Reproduce:
1. Read `.claude/rules/typescript.md` line 16: "**Testing — Vitest**: All TypeScript unit tests must use Vitest. Command: `npm run test`".
2. Read root `package.json`: `"test:unit": "node run-jest.cjs"`, `"test": "vscode-test"`, `"test:unit:coverage": "node run-jest.cjs --coverage"`. No `test:coverage` script and no Vitest dependency exist.
3. Read the canonical policy source `.github/instructions/typescript-unit-test.instructions.md`: it states "All TypeScript unit tests must use **Jest**", uses `jest.spyOn`, `jest.mock`, `jest.resetAllMocks`, `jest.useFakeTimers`, and names the approved command `npm run test:unit`.
4. Observe that the mirror contradicts both the canon and the repository's actual configuration.

Expected:
The `.claude/` and `.agents/` mirrors describe the test framework and commands the repository actually uses (Jest, `npm run test:unit`, `npm run test:unit:coverage`), consistent with the canonical `.github/instructions/` policy source.

Actual:
The mirrors instruct Jest-incompatible practice:

- `.claude/rules/typescript.md` — Vitest references at lines 16, 42, 47, 51, 73, plus the non-existent `npm run test:coverage` command and the wrong `npm run test` unit-test command.
- `.claude/rules/general-unit-test.md` — `vitest.config.ts` in the permitted coverage-exclude list (line 40) and a `vi.useFakeTimers()` determinism instruction (line 105).
- `.claude/rules/general-code-change.md` — Vitest named in the toolchain unit-test stage example list (line 39).
- `.claude/agents/atomic-executor.md` — `Bash(npx vitest *)` in the tool allowlist (line 18) and `npx vitest` in the TypeScript toolchain command list (line 79). This drives actual agent tool invocations, so the wrong framework here has runtime consequences beyond documentation.
- `.agents/skills/general-unit-test/SKILL.md` (lines 45, 110) and `.agents/skills/general-code-change/SKILL.md` (line 44) — the same divergences as their `.claude/rules/` counterparts.
- Bundled copies of all of the above under `extensions/drm-copilot/resources/claude-customizations/` and `extensions/drm-copilot/resources/codex-and-agents-customizations/` carry the identical defects and therefore ship them to every consumer repository through the extension.

Logs / Screenshots:
- [x] Attached minimal logs or snippet
- Snippet:

```
.claude/rules/typescript.md:16:4. **Testing - Vitest**: All TypeScript unit tests must use Vitest. Command: `npm run test`
.claude/rules/typescript.md:51:- Coverage command: `npm run test:coverage` (the script is wired in Prompt B1 alongside the Vitest dependency).
package.json: "test:unit": "node run-jest.cjs", "test": "vscode-test"
.github/instructions/typescript-unit-test.instructions.md:24:  - All TypeScript unit tests must use **Jest**.
.github/instructions/typescript-unit-test.instructions.md:110:- Approved command: `npm run test:unit`
```


## Scope & Non-Goals
- In scope:
  - Correcting six repo-root instruction files: `.claude/rules/typescript.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/general-code-change.md`, `.claude/agents/atomic-executor.md`, `.agents/skills/general-unit-test/SKILL.md`, `.agents/skills/general-code-change/SKILL.md`.
  - Applying byte-identical corrections to the six bundled counterparts: the first four under `extensions/drm-copilot/resources/claude-customizations/`, the last two under `extensions/drm-copilot/resources/codex-and-agents-customizations/`. Twelve files total. There is no repo-root-to-bundle regeneration script; both copies must be edited identically by hand. Parity is enforced by `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` (`.claude/**`) and `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts` (`.agents/**`).
  - Adding one new regression test module: `tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py` (see Test Strategy).
- Out of scope / non-goals:
  - Migrating the repository to Vitest. The fix makes the instructions describe the framework actually in use (Jest).
  - Any edit under `.github/instructions/` — this surface is canonical and protected by `CLAUDE.md`.
  - Any edit to root `package.json`, `jest.config.cjs`, `run-jest.cjs`, `tsconfig*.json`, or `.vscode-test.*`. A sibling orchestration owns those files. If the fix appears to require modifying them, that is a conflict to report, not to edit.
  - `extensions/drm-copilot/resources/customizations/.github/agents/expert-react-frontend-engineer.agent.md` and `extensions/drm-copilot/resources/customizations/.github/instructions/github-actions-ci-cd-best-practices.instructions.md` (and their `.github/` originals). Research verdict NOT-A-DEFECT: these are genuinely generic multi-ecosystem enumerations in which Vitest is a correct example. They live under the no-edit `.github/` surface and are outside the owned file set.
- Explicitly excluded systems, integrations, or datasets:
  - Historical artifacts under `docs/features/completed/**` and `docs/features/active/**` that mention the Vitest divergence are frozen records; do not edit.
  - Report-only adjacent finding (do not fix in this feature): `.claude/rules/typescript.md:57` names `.dependency-cruiser.cjs`, which does not exist anywhere in the repository. This is a separate accuracy defect, unrelated to the Vitest/Jest divergence, and is recorded here as an out-of-scope observation for separate filing.

## Root Cause Analysis
The rule mirrors appear to have been authored against a planned Vitest setup ("the script is wired in Prompt B1 alongside the Vitest dependency") that was never adopted; the repository standardized on Jest instead. The canonical `.github/instructions/` source was updated to Jest but the `.claude/` and `.agents/` mirrors were not.

Direction of authority is established by `CLAUDE.md`: `.github/instructions/` is the canonical policy source and must not be modified; `.claude/` files mirror or reference its content. Correcting the mirrors to match the canon is therefore the sanctioned fix direction.


## Proposed Fix

### Design summary (what changes where):
Twelve Markdown instruction files are corrected in six identical pairs (repo-root file plus bundled copy), replacing every Vitest framework reference with the Jest equivalent and correcting two wrong commands. One new pytest regression module locks the corrected state.

| Pair | Repo-root file | Corrections |
|---|---|---|
| 1 | `.claude/rules/typescript.md` (lines 16, 42, 47, 51, 73) | Line 16: "Testing — Jest", command `npm run test:unit` (`npm run test` maps to `vscode-test`, the integration runner). Line 42: mandate Jest. Line 47: `jest.spyOn`/`jest.mock`/`jest.resetAllMocks`. Line 51: `npm run test:unit:coverage` (no `test:coverage` script exists), and remove or replace the stale clause "(the script is wired in Prompt B1 alongside the Vitest dependency)" with accurate text. Line 73: Jest fake timers (`jest.useFakeTimers()`). |
| 2 | `.claude/rules/general-unit-test.md` (lines 40, 105) | Line 40: `vitest.config.ts` → `jest.config.cjs` in the permitted coverage-exclude list. Line 105: `vi.useFakeTimers()` for Vitest → `jest.useFakeTimers()` for Jest. |
| 3 | `.claude/rules/general-code-change.md` (line 39) | The `(e.g., Pytest, Vitest, MSTest, Pester)` unit-test-stage list enumerates this repository's actual per-language runners; the TypeScript slot must read Jest. |
| 4 | `.claude/agents/atomic-executor.md` (lines 18, 79) | Line 18: allowlist entry `Bash(npx vitest *)` → `Bash(npx jest *)`. Line 79: TypeScript toolchain command `npx vitest` → `npx jest`. Precedent: the hook-recognized command family in `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1:67` (`npx (prettier|eslint|tsc|jest)`) and the canonical `.github/agents/typescript-engineer.agent.md`. |
| 5 | `.agents/skills/general-unit-test/SKILL.md` (lines 45, 110) | Same corrections as pair 2, in lockstep. |
| 6 | `.agents/skills/general-code-change/SKILL.md` (line 44) | Same correction as pair 3, in lockstep. |

Bundled counterparts: pairs 1–4 under `extensions/drm-copilot/resources/claude-customizations/`, pairs 5–6 under `extensions/drm-copilot/resources/codex-and-agents-customizations/`, each edited byte-identically to its repo-root file.

### Boundaries and invariants to preserve:
- Byte-for-byte parity between each repo-root file and its bundled copy, as enforced by the two parity tests named in Scope.
- The `.github/` surface is read-only for this fix; all corrections flow canon-to-mirror.
- No behavior of the Jest toolchain itself changes; only the instructional text describing it changes.
- The `.claude` and `.agents` texts are corrected independently (no test binds them to each other); consistency between them is maintained by making the paired edits identical.

### Dependencies or blocked work:
- A sibling orchestration owns root `package.json`, `jest.config.cjs`, `run-jest.cjs`, `tsconfig*.json`, and `.vscode-test.*`. This fix reads those files (for command verification) but must not modify them. Any apparent need to modify them is a conflict to report.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
- `.claude/rules/typescript.md` and `extensions/drm-copilot/resources/claude-customizations/.claude/rules/typescript.md`
- `.claude/rules/general-unit-test.md` and `extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-unit-test.md`
- `.claude/rules/general-code-change.md` and `extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-code-change.md`
- `.claude/agents/atomic-executor.md` and `extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-executor.md`
- `.agents/skills/general-unit-test/SKILL.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-unit-test/SKILL.md`
- `.agents/skills/general-code-change/SKILL.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-code-change/SKILL.md`
- New: `tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py`

#### Functions/classes/CLI commands impacted:
- No production code functions or classes change. Documented command surface changes: `npm run test` → `npm run test:unit`; `npm run test:coverage` → `npm run test:unit:coverage`; `npx vitest` → `npx jest`; `vi.*` API names → `jest.*` equivalents; `vitest.config.ts` → `jest.config.cjs`.
- The atomic-executor Bash allowlist gains `Bash(npx jest *)` in place of `Bash(npx vitest *)`, which changes the executor's permitted tool invocations at runtime.

#### Data flow and validation changes:
- None. Markdown instruction content and one new test module only.

#### Error handling and logging updates:
- None.

#### Rollback/feature-flag considerations (if applicable):
- Not applicable. Reverting the commit restores the prior text; no flags or migrations are involved.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- The new regression test reads the six repo-root Markdown files with UTF-8 text reads and parses root `package.json` `scripts`. It writes nothing.

#### Required configuration keys and defaults:
- None added. The test depends on the existing root `package.json` `scripts` block (`test:unit`, `test:unit:coverage`).

#### Backward-compatibility expectations:
- The parity tests must continue to pass; the bundled extension ships the corrected text to consumer repositories on the next release. No schema or API compatibility surface is affected.

#### Performance constraints (latency/throughput/memory):
- None. The new test is a fast file-content assertion module.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
  - Root `package.json` continues to define `test:unit` and `test:unit:coverage` as the Jest unit-test entry points, and Jest (`jest ^30.4.2`) remains the installed root devDependency.
  - `npx jest` resolves via the root devDependency and auto-discovers `jest.config.cjs`. Research verified this by dependency and config inspection, not by execution; the executing agent should confirm with one invocation during implementation. Note: bare `npx jest` bypasses `run-jest.cjs`'s `--testPathPattern` → `--testPathPatterns` alias rewrite, so Jest 30 flag names must be used.
- Constraints (budget, performance, compatibility):
  - No edits to `.github/instructions/**`, root `package.json`, `jest.config.cjs`, `run-jest.cjs`, `tsconfig*.json`, or `.vscode-test.*`.
  - Repo-root and bundled copies must remain byte-identical.
- External dependencies (services, libraries, releases):
  - None. No new packages are introduced.

## Data / API / Config Impact
- User-facing or API changes: None. Instructional text and one Bash allowlist entry in an agent definition change.
- Data or migration considerations: None.
- Logging/telemetry updates (if any): None.
- Compatibility notes (CLI flags, config schemas, versioning): The corrected mirrors ship downstream via the bundled extension resources on the next extension release; consumer repositories receive the Jest-correct instructions through the existing push-down mechanism.

## Test Strategy
Seeded from issue:

- [x] Unit coverage areas: parity tests binding repo-root mirrors to their bundled `extensions/drm-copilot/resources/` copies; a regression test asserting no `vitest`/`vi.` framework reference survives in the TypeScript rule mirrors.
- [x] Integration scenario to retest: the bundled push-down resource contract tests (`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`).
- [x] Manual verification notes: confirm every command named in the corrected mirrors resolves to a script that exists in root `package.json`.

Explicit non-goal: do not migrate the repository to Vitest. The fix is to make the instructions describe the framework the repository actually uses.

- Regression tests to add or update:
  - New module `tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py` (pytest), asserting both of the following properties:
    1. Framework-token absence: for each of the six repo-root mirror files, the text contains no `vitest` token (case-insensitive) and no `vi.` API token (regex such as `\bvi\.[a-zA-Z]`). The bundled copies need no separate assertions; the existing parity tests transitively extend the repo-root guarantee to the bundles.
    2. Command resolution plus semantic anchors: every `npm run <script>` token named in `.claude/rules/typescript.md` resolves to a real script in root `package.json`; additionally, the Testing toolchain line must name `test:unit` and the coverage line must name `test:unit:coverage`. The semantic anchors are necessary because `npm run test` resolves to a real script (`vscode-test`) but is semantically wrong for unit tests, so a pure existence check would not catch it.
  - Structural precedent: `tests/scripts/dev_tools/test_codex_orchestration_contracts.py` (live-tree Markdown reads with required/forbidden substring assertions).
  - Fail-before evidence: run the new test against the pre-fix tree and record the failure output. Fail-before is achievable and is the expected path — the token-absence assertions fail today at the known lines, and the command assertions fail today on `npm run test:coverage` (unresolvable) and `npm run test` (wrong unit-test command).
- Unit tests (pytest) for the fixed behavior and boundaries: the new module above; no production Python code changes, so no additional unit tests are required.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values): the `\bvi\.[a-zA-Z]` regex must not false-positive on legitimate content in the six files (verified during research); the command extraction must tolerate backtick-wrapped `npm run <name>` tokens anywhere in `.claude/rules/typescript.md`.
- Error handling and logging verification: not applicable (no runtime code changes).
- Coverage impact and targets for changed lines/modules: no production source lines change; coverage thresholds (line >= 85%, branch >= 75%) are unaffected. The new test file is test code and excluded from coverage denominators per policy.
- Toolchain commands to run (format → lint → type-check → test): Python toolchain for the new test module per `.claude/rules/python.md` (format, lint, type-check), then `pytest tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py`, `pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, and `pytest tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`.
- Manual validation steps (if required): confirm every `npm run` command named in the corrected mirrors resolves in root `package.json`; optionally run one `npx jest` invocation to confirm resolution of the allowlisted command form.


## Acceptance Criteria
- [ ] `.claude/rules/typescript.md` (lines 16, 42, 47, 51, 73) is corrected to Jest — framework name, `jest.spyOn`/`jest.mock`/`jest.resetAllMocks`, and `jest.useFakeTimers()` — and its bundled copy at `extensions/drm-copilot/resources/claude-customizations/.claude/rules/typescript.md` is byte-identical.
- [ ] `.claude/rules/typescript.md` line 16 names `npm run test:unit` as the unit-test command (not `npm run test`, which maps to the `vscode-test` integration runner).
- [ ] `.claude/rules/typescript.md` line 51 names `npm run test:unit:coverage` (not the non-existent `npm run test:coverage`), and the stale clause "(the script is wired in Prompt B1 alongside the Vitest dependency)" is removed or replaced with accurate text.
- [ ] `.claude/rules/general-unit-test.md` (lines 40, 105) is corrected — `vitest.config.ts` → `jest.config.cjs` in the permitted coverage-exclude list; `vi.useFakeTimers()` → `jest.useFakeTimers()` — and its bundled copy at `extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-unit-test.md` is byte-identical.
- [ ] `.claude/rules/general-code-change.md` (line 39) names Jest in the TypeScript slot of the unit-test-stage runner list, and its bundled copy at `extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-code-change.md` is byte-identical.
- [ ] `.claude/agents/atomic-executor.md` line 18 allowlists `Bash(npx jest *)` in place of `Bash(npx vitest *)`, line 79 names `npx jest` in the TypeScript toolchain command list, and its bundled copy at `extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-executor.md` is byte-identical.
- [ ] `.agents/skills/general-unit-test/SKILL.md` (lines 45, 110) carries the same corrections as `.claude/rules/general-unit-test.md`, and its bundled copy at `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-unit-test/SKILL.md` is byte-identical.
- [ ] `.agents/skills/general-code-change/SKILL.md` (line 44) carries the same correction as `.claude/rules/general-code-change.md`, and its bundled copy at `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-code-change/SKILL.md` is byte-identical.
- [ ] Both parity tests pass: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` and `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts`.
- [ ] The new regression test `tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py` exists, asserts framework-token absence in all six repo-root mirrors and command resolution plus the `test:unit`/`test:unit:coverage` semantic anchors, and passes against the fixed tree.
- [ ] Fail-before evidence is recorded: the new regression test was run against the pre-fix tree and its failure output captured before the fix was applied.
- [ ] Non-goals respected: no file under `.github/instructions/**` was modified; root `package.json`, `jest.config.cjs`, `run-jest.cjs`, `tsconfig*.json`, and `.vscode-test.*` are unmodified; `expert-react-frontend-engineer.agent.md` and `github-actions-ci-cd-best-practices.instructions.md` (originals and vendored copies) are unmodified; no Vitest migration was performed.
- [ ] The adjacent `.dependency-cruiser.cjs` finding at `.claude/rules/typescript.md:57` was not folded into this fix and is recorded for separate filing.
- [ ] Full toolchain pass completed for the changed test module (format → lint → type-check → test).

## Risks & Mitigations
- Technical or operational risks:
  - A missed bundled-copy edit produces repo-root/bundle drift. Mitigation: the two parity tests fail deterministically on any drift and are named in the acceptance criteria.
  - `npx jest` behavior differs from the `run-jest.cjs` wrapper (no `--testPathPattern` alias rewrite, no `NODE_PATH` augmentation from `run-node-tool.cjs`). Mitigation: the corrected instruction text assumes Jest 30 flag names; the executing agent confirms one `npx jest` invocation during implementation. Fallback (recorded in research, not the primary design): allowlist `Bash(node run-jest.cjs *)` instead.
  - The regex-based framework-token assertion could false-positive on future legitimate content. Mitigation: the pattern `\bvi\.[a-zA-Z]` plus a case-insensitive `vitest` token check was verified against the current file contents; any future collision fails loudly and is trivially diagnosable.
- Mitigations and rollbacks:
  - Rollback is a single-commit revert; no data, config schema, or dependency changes are involved.

## Rollout & Follow-up
- Release/rollout steps: merge via the standard PR flow; the corrected bundled resources ship to consumer repositories with the next extension release through the existing push-down mechanism. No separate rollout action is required.
- Post-fix monitoring or clean-up tasks:
  - File a separate issue for the `.dependency-cruiser.cjs` reference at `.claude/rules/typescript.md:57` (file does not exist anywhere in the repository).
  - Planner-optional follow-up noted in research: `README.md:303` and `README.md:318` describe the TypeScript toolchain as Vitest; not in this feature's owned file set.
- Links: issue #422 (https://github.com/drmoisan/drm-copilot/issues/422), issue file `docs/features/active/2026-07-25-claude-rules-vitest-jest-divergence-422/issue.md`, research `docs/features/active/2026-07-25-claude-rules-vitest-jest-divergence-422/research/2026-07-25T22-15-claude-rules-vitest-jest-divergence-research.md`.
