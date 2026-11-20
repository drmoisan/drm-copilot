# fix-all-typescript-branch (Issue #205)

- Date captured: 2026-06-19
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/fix-all-typescript-branch/ (Issue #205)

- Issue: #205
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/205
- Last Updated: 2026-06-19
- Work Mode: minor-audit

## Problem / Why

The "QC: 0 Fix All" VS Code task and its underlying `scripts/dev_tools/fix_all` runtime run the
json, shell, python, and powershell quality toolchains in parallel, but do not run the TypeScript
toolchain. TypeScript sources are therefore excluded from the consolidated fix-all pass, requiring a
separate manual invocation of the TS format/lint/type-check/test steps.

## Proposed Behavior

Add a TypeScript toolchain branch to the `fix_all` runtime, executed in parallel with the existing
json, shell, python, and powershell branches. The branch runs Prettier (format) -> ESLint (lint) ->
TSC (type-check) -> Jest (test) via the existing npm scripts, with the Jest step switching to the
coverage variant when coverage is requested, mirroring the python branch. The status board includes a
`typescript` row. No change to `.vscode/tasks.json` is required because "QC: 0 Fix All" delegates to
the `scripts.dev_tools.fix_all` module.

## Acceptance Criteria

- [x] `fix_all` runtime registers a `typescript` branch in the parallel branch set.
- [x] The TypeScript branch runs Prettier -> ESLint -> TSC -> Jest in order via npm scripts.
- [x] The Jest step switches to the coverage command/name when coverage is requested.
- [x] The status board includes a `typescript` row alongside json, shell, python, powershell.
- [x] Unit tests cover each failing-step path and the coverage step-name switch.

## Constraints & Risks

- Must not change the behavior of the existing branches.
- Must reuse the established branch structure (linear, no auto-fix retry loop) used by the powershell branch.

## Test Conditions to Consider

- [ ] Unit coverage areas: Prettier/ESLint/TSC/Jest failure paths, coverage step-name switch
- [ ] Integration scenarios: full parallel fix-all run including the typescript branch
- [ ] CLI/API examples: `poetry run python -m scripts.dev_tools.fix_all`

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/fix-all-typescript-branch/` folder from the template