# typescript-toolchain (Issue #4)

- Date captured: 2026-02-02
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/typescript-toolchain/ (Issue #4)

- Issue: #4
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/4
- Last Updated: 2026-02-02
## Problem / Why

The repo has a strong, end-to-end Python quality toolchain (Black → Ruff → Pyright → Pytest) with multiple entry points: VS Code tasks, extension commands, and an automated “fix-all” pipeline (`scripts/dev_tools/fix_all.py`).

TypeScript has *partial* parity (npm scripts + VS Code tasks + extension commands exist), but it is not integrated into the “Run All Checks” and “Fix All” workflows that developers use as the primary quality gates. This creates two classes of contributions (Python is fully enforced, TypeScript is easier to accidentally skip), and it increases CI breakage + review churn when TS formatting/lint/typecheck drift.

## Proposed Behavior

Add first-class TypeScript/Node toolchain support with the same surfaces and expectations as Python.

Scope (what “parity with Python” means here):

- Single-shot commands exist for each step (format, lint, type-check, tests)
- A “run-all” entry point runs the full sequence (format → lint → type-check → tests)
- A “fix-all” entry point runs auto-fixable steps, retries where useful, then runs the remaining checks
- All of the above are available via:
	- npm scripts (CLI)
	- VS Code tasks (developer workflow)
	- the extension command palette mappings (via `TASK_COMMAND_MAP`)
	- the automated multi-language pipeline (`scripts/dev_tools/fix_all.py`) so it can run in parallel with JSON/shell/Python/PowerShell

Current TypeScript toolchain building blocks (already present):

- npm scripts in `package.json`:
	- `npm run format` (Prettier)
	- `npm run lint` (ESLint)
	- `npm run typecheck` (TSC noEmit + tests tsconfig)
	- `npm run test:unit` (Jest)
	- `npm run test:integration` / `npm run test` (VS Code extension tests)
- VS Code tasks in `.vscode/tasks.json`:
	- `TS: 1 Prettier: format`
	- `TS: 2 ESLint: lint`
	- `TS: 3 TSC: type-check`
	- `TS: 4 Jest: unit tests`
	- `npm: watch`
- Extension commands wired in `src/task-command-map.ts` and `package.json` contributes.commands:
	- `drm-copilot.tsPrettierFormat`, `drm-copilot.tsEslintLint`, `drm-copilot.tsTscTypeCheck`, `drm-copilot.tsJestUnitTests`

What’s missing (this feature’s concrete deliverables):

1) Integrate TypeScript into the repo-wide “Run All Checks” path

- Update the VS Code meta-task `QC: 5 Run All Checks` (currently JSON → Python → PowerShell) to include the TypeScript steps in sequence:
	- `TS: 1 Prettier: format`
	- `TS: 2 ESLint: lint`
	- `TS: 3 TSC: type-check`
	- `TS: 4 Jest: unit tests`

2) Add TypeScript as a first-class branch in `scripts/dev_tools/fix_all.py`

- Add a `typescript` branch alongside `json`, `shell`, `python`, `powershell`.
- The TypeScript branch should run the standard looped toolchain (mirroring the Python branch behavior):
	- format (auto-fix): `npm run format`
	- lint (ideally auto-fix + retry): introduce `npm run lint:fix` (ESLint `--fix`) and use it in fix-all; keep `npm run lint` for non-mutating verification
	- type-check: `npm run typecheck`
	- unit tests: `npm run test:unit`

3) Ensure developer documentation is complete and consistent

- Update `docs/developer-tooling.md` to explicitly include the TypeScript toolchain:
	- Individual commands
	- “Run All Checks (Sequential)” recipe includes the npm steps
	- “Fix All (Automated)” describes that the fix-all workflow includes TypeScript
- Reconcile documentation references that currently do not match the repo contents (e.g., `docs/developer-tooling.md` references a `scripts/dev-tools/fix-all.ps1` wrapper that is not present in the workspace).

4) Keep “single source of truth” alignment across surfaces

- Ensure the same labels/step names are used consistently across:
	- npm scripts (`package.json`)
	- VS Code task labels (`.vscode/tasks.json`)
	- extension command mappings (`src/task-command-map.ts`)
	- fix-all branch step names/status board (in `scripts/dev_tools/fix_all.py`)

## Acceptance Criteria (early draft)

- [ ] `QC: 5 Run All Checks` runs TypeScript checks in the same toolchain order as Python (format → lint → type-check → tests), using the existing TS tasks.
- [ ] `QC: 0 Fix All` (the `scripts.dev_tools.fix_all` entry point) includes a new TypeScript branch that executes the repo’s TypeScript toolchain.
- [ ] The TypeScript fix-all branch uses auto-fix commands where applicable (Prettier and ESLint `--fix`) and re-verifies after auto-fix before declaring success.
- [ ] The TypeScript branch is surfaced in the fix-all status output (interactive board and/or line-based status transitions) with a stable branch name (e.g., `typescript`).
- [ ] `docs/developer-tooling.md` documents the TypeScript toolchain commands and includes them in the “Run All Checks (Sequential)” and “Fix All (Automated)” sections.
- [ ] The documented developer workflow does not reference non-existent scripts; any stale references are corrected.
- [ ] VS Code command palette entries for TypeScript toolchain steps remain functional (task labels match `src/task-command-map.ts`).

## Constraints & Risks

- Node/npm availability: `npm` must be available on PATH (dev machines, CI runners, devcontainers). If the repo supports devcontainers, ensure Node is installed there.
- Windows compatibility: fix-all uses subprocess execution; ensure `npm` invocation and quoting work on Windows shells (PowerShell and CMD). Prefer `npm run <script>` over deep quoting or shell pipelines.
- Determinism: prefer `npm ci` in CI to avoid lockfile drift; local instructions should be explicit about install expectations.
- Toolchain ordering matters: TypeScript steps should mirror the repo’s “toolchain loop” concept (format → lint → type-check → test) so failures are actionable and consistent.
- Jest vs integration tests: VS Code extension tests (`npm test` / `vscode-test`) can be slower and more environment-sensitive than Jest. This feature should define whether fix-all and Run All Checks include integration tests or keep them as a separate, explicit step.
- Documentation drift risk: `docs/developer-tooling.md` currently mentions a PowerShell wrapper that isn’t present; ensure the final docs match the repo.

## Test Conditions to Consider

- [ ] Unit coverage: add/extend tests for the fix-all pipeline and/or QC runners to verify the TypeScript branch:
	- correct commands are executed in order
	- failures are reported on the correct branch
	- retry behavior (if implemented) does not loop indefinitely
- [ ] Integration scenarios:
	- `QC: 5 Run All Checks` includes TS tasks and still runs in sequence successfully
	- TypeScript formatting changes are applied by fix-all and then verified by lint/typecheck
	- Jest failures are surfaced clearly (branch output includes Jest failure summary)
- [ ] CLI examples:
	- `npm run format && npm run lint && npm run typecheck && npm run test:unit`
	- `poetry run python -m scripts.dev_tools.fix_all` includes a `typescript` branch and returns non-zero on TS failures

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/typescript-toolchain/` folder from the template
