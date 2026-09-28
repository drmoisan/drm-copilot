# FR-614-005 Focused Green — P2-T7

Timestamp: 2026-09-06T00-00
Task: [P2-T7]
Finding: FR-614-005
Working directory for Jest steps: `extensions/drm-copilot`
Working directory for Pytest step: repository root

## Gitignored runtime-state precondition

`.claude/state/` is gitignored at `.gitignore:68` and is not repository content.
`git check-ignore -v .claude/state/current-session-id` reports
`.gitignore:68:.claude/state/	.claude/state/current-session-id`. The regenerated
runtime session file was removed immediately before each command below. Each
step records its own before-and-after `.claude` porcelain observation.

## Step 1 — public contract

Timestamp: 2026-09-06T00-00
Command: `node run-jest.cjs --runInBand --runTestsByPath test/mcp-repo-automation-tool-definitions.test.ts test/mcp-handlers/orchestration-handoff-handlers.test.ts test/repo-automation-orchestration-validation.test.ts test/mcp-server.test.ts`
EXIT_CODE: 0
Before `git status --porcelain=v1 --untracked-files=all -- .claude`:
```
 M .claude/skills/orchestrate/SKILL.md
```
After `git status --porcelain=v1 --untracked-files=all -- .claude`:
```
 M .claude/skills/orchestrate/SKILL.md
```
Output Summary: 4 suites passed, 92 tests passed, 0 failed. All three public
tools require and forward the ten independent expected-context fields; omitted
and malformed values are rejected before service invocation.

## Step 2 — authority and checkout boundary

Timestamp: 2026-09-06T00-00
Command: `node run-jest.cjs --runInBand --runTestsByPath test/lib/validate/orchestration-handoff-authority-service.test.ts test/lib/validate/orchestration-handoff-checkout-context.test.ts`
EXIT_CODE: 0
Before `git status --porcelain=v1 --untracked-files=all -- .claude`:
```
 M .claude/skills/orchestrate/SKILL.md
```
After `git status --porcelain=v1 --untracked-files=all -- .claude`:
```
 M .claude/skills/orchestrate/SKILL.md
```
Output Summary: 2 suites passed, 52 tests passed, 0 failed. Each single-field
case returns its specified primary code — `HANDOFF_REPOSITORY_MISMATCH`,
`HANDOFF_WORKSPACE_MISMATCH`, `HANDOFF_ISSUE_FEATURE_MISMATCH`,
`HANDOFF_BRANCH_LINEAGE_MISMATCH`, `HANDOFF_PLAN_PATH_INVALID`, and
`HANDOFF_PLAN_HASH_MISMATCH` — for both a mutated envelope and a contradicting
checkout observation. The multiply-invalid case returns
`HANDOFF_REPOSITORY_MISMATCH` in registry order. An unavailable observation
fails closed with `HANDOFF_VALIDATOR_UNAVAILABLE`. Spy inspection confirms
`writeTextFile` and `ensureDir` were not called and that `observe` received
`expectedWorkspaceRoot`.

## Step 3 — materializer dry-run and materialize matrices

Timestamp: 2026-09-06T00-00
Command: `node run-jest.cjs --runInBand --runTestsByPath test/lib/validate/orchestration-handoff-materializer.test.ts test/lib/validate/orchestration-handoff-materializer-production.test.ts`
EXIT_CODE: 0
Before `git status --porcelain=v1 --untracked-files=all -- .claude`:
```
 M .claude/skills/orchestrate/SKILL.md
```
After `git status --porcelain=v1 --untracked-files=all -- .claude`:
```
 M .claude/skills/orchestrate/SKILL.md
```
Output Summary: 2 suites passed, 51 tests passed, 0 failed. The twelve-case
FR-614-005 matrix (six codes across `dry_run` and `materialize`) blocks every
combination with a null destination checkpoint path and hash. Spy inspection
confirms zero `readPorcelainStatus`, `routing.resolve`, `createDirectory`,
`writeFile`, `replaceFile`, `removeFile`, and `nowIso8601` calls for every
blocked case. Both authorities receive the entire independent context.

## Step 4 — consumer publication parity

Timestamp: 2026-09-06T00-00
Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`
EXIT_CODE: 0
Before `git status --porcelain=v1 --untracked-files=all -- .claude`:
```
 M .claude/skills/orchestrate/SKILL.md
```
After `git status --porcelain=v1 --untracked-files=all -- .claude`:
```
 M .claude/skills/orchestrate/SKILL.md
```
Output Summary: 23 passed, 0 failed. Source and bundled guidance both name the
three context-bound operations and all ten independent expected-context keys.
Source-to-resource normalized content is exact for all three published skills.

## Boundary observations

For every step the before and after `.claude` porcelain observations are
identical to each other, so no test run changed any tracked path under
`.claude`. The only path either observation lists is
`.claude/skills/orchestrate/SKILL.md`, the published orchestrate skill that
P2-T6 is authorized to change.

`git status --porcelain=v1 --untracked-files=all` after the four steps lists
only authorized production, test, publication, evidence, requirement, and
review paths. No pack manifest, dependency, policy, checkpoint, or unrelated
path changed, and no unexpected mutation was introduced.
