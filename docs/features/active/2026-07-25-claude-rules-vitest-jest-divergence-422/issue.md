# claude-rules-vitest-jest-divergence (Issue #422)

- Date captured: 2026-07-25
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/claude-rules-vitest-jest-divergence/ (Issue #422)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #422
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/422
- Last Updated: 2026-07-26
- Work Mode: full-bug

## Summary

The Claude-runtime and Codex/agents rule mirrors instruct agents to use Vitest for TypeScript unit tests, but the repository actually runs Jest. `.claude/rules/typescript.md` additionally names two commands that are wrong for this repository: `npm run test` (which is bound to `vscode-test`, the integration-test runner, not unit tests) and `npm run test:coverage` (which does not exist; the root script is `test:unit:coverage`).

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: n/a (defect is in Markdown instruction mirrors)
- Command/flags used: `npm run test:unit` (resolves to `node run-jest.cjs`)
- Data source or fixture: repository at commit `fb483b84`

## Steps to Reproduce

1. Read `.claude/rules/typescript.md` line 16: "**Testing — Vitest**: All TypeScript unit tests must use Vitest. Command: `npm run test`".
2. Read root `package.json`: `"test:unit": "node run-jest.cjs"`, `"test": "vscode-test"`, `"test:unit:coverage": "node run-jest.cjs --coverage"`. No `test:coverage` script and no Vitest dependency exist.
3. Read the canonical policy source `.github/instructions/typescript-unit-test.instructions.md`: it states "All TypeScript unit tests must use **Jest**", uses `jest.spyOn`, `jest.mock`, `jest.resetAllMocks`, `jest.useFakeTimers`, and names the approved command `npm run test:unit`.
4. Observe that the mirror contradicts both the canon and the repository's actual configuration.

## Expected Behavior

The `.claude/` and `.agents/` mirrors describe the test framework and commands the repository actually uses (Jest, `npm run test:unit`, `npm run test:unit:coverage`), consistent with the canonical `.github/instructions/` policy source.

## Actual Behavior

The mirrors instruct Jest-incompatible practice:

- `.claude/rules/typescript.md` — 4 Vitest references (lines 16, 42, 47, 51, 73), plus the non-existent `npm run test:coverage` command and the wrong `npm run test` unit-test command.
- `.claude/rules/general-unit-test.md` — `vitest.config.ts` in the permitted coverage-exclude list and a `vi.useFakeTimers()` determinism instruction.
- `.claude/rules/general-code-change.md` — Vitest named in the toolchain unit-test stage example list.
- `.claude/agents/atomic-executor.md` — `Bash(npx vitest *)` in the tool allowlist and `npx vitest` in the TypeScript toolchain command list. This drives actual agent tool invocations, so the wrong framework here has runtime consequences beyond documentation.
- `.agents/skills/general-unit-test/SKILL.md` and `.agents/skills/general-code-change/SKILL.md` — the same divergences as their `.claude/rules/` counterparts.
- Bundled copies of all of the above under `extensions/drm-copilot/resources/claude-customizations/` and `extensions/drm-copilot/resources/codex-and-agents-customizations/` carry the identical defects and therefore ship them to every consumer repository through the extension.

## Logs / Screenshots

- [x] Attached minimal logs or snippet
- Snippet:

```
.claude/rules/typescript.md:16:4. **Testing - Vitest**: All TypeScript unit tests must use Vitest. Command: `npm run test`
.claude/rules/typescript.md:51:- Coverage command: `npm run test:coverage` (the script is wired in Prompt B1 alongside the Vitest dependency).
package.json: "test:unit": "node run-jest.cjs", "test": "vscode-test"
.github/instructions/typescript-unit-test.instructions.md:24:  - All TypeScript unit tests must use **Jest**.
.github/instructions/typescript-unit-test.instructions.md:110:- Approved command: `npm run test:unit`
```

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

An agent that follows `.claude/rules/typescript.md` will author `vi.*`-based tests that cannot run under Jest, and `.claude/agents/atomic-executor.md` allowlists a `npx vitest` command that does not exist in this repository, so the executor's TypeScript toolchain stage is unrunnable as documented. The bundled extension copies propagate both defects downstream.

## Suspected Cause / Notes

The rule mirrors appear to have been authored against a planned Vitest setup ("the script is wired in Prompt B1 alongside the Vitest dependency") that was never adopted; the repository standardized on Jest instead. The canonical `.github/instructions/` source was updated to Jest but the `.claude/` and `.agents/` mirrors were not.

Direction of authority is established by `CLAUDE.md`: `.github/instructions/` is the canonical policy source and must not be modified; `.claude/` files mirror or reference its content. Correcting the mirrors to match the canon is therefore the sanctioned fix direction.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: parity tests binding repo-root mirrors to their bundled `extensions/drm-copilot/resources/` copies; a regression test asserting no `vitest`/`vi.` framework reference survives in the TypeScript rule mirrors.
- [x] Integration scenario to retest: the bundled push-down resource contract tests (`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`).
- [x] Manual verification notes: confirm every command named in the corrected mirrors resolves to a script that exists in root `package.json`.

Explicit non-goal: do not migrate the repository to Vitest. The fix is to make the instructions describe the framework the repository actually uses.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch
