# root-vscode-test-entrypoint-unrunnable (Spec)

- **Issue:** #421
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-07-26T02-00
- **Status:** Ready for Planning
- **Version:** 1.0

## Context
The repository-root npm scripts `test` and `test:integration` are both defined as `vscode-test`, but no `.vscode-test.*` configuration file exists anywhere in the repository. `npm test` and `npm run test:integration` therefore fail for every developer at the repository root, and no CI job exercises the path, so the breakage is undetected.

Environment:
- OS/version: Windows 11 Pro 10.0.26200 (condition is environment-independent; also reproduces on CI runners)
- Node/npm: repository-standard toolchain
- Command/flags used: `npm test` and `npm run test:integration` from the repository root
- Data source or fixture: repository root `package.json` at `origin/main` (`fb483b84`)

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

`npm test` is the conventional entry point a developer or external tool reaches for first. It is unconditionally broken at the repository root, but no production behavior is affected and no CI gate is currently red.

A verified additional finding shapes this fix: no CI job runs the root TypeScript toolchain at all. Verified by grep of `.github/workflows/` for `jest`, `run-jest`, `test:unit`, and `npm test` (zero matches); `_quality-checks.yml` is Python-only and `_build-check.yml` is Poetry/bash-only. The root jest suite (`tests/unit/hello-typescript.test.ts`) is presently unexercised by CI. The fix therefore also wires a CI job that runs the root TypeScript toolchain, which is what makes the repaired entry point durable and is the authoritative verification path for this defect (see Test Strategy).


## Repro & Evidence
Steps to Reproduce:
1. Check out `origin/main` at commit `fb483b84`.
2. Run `npm ci` at the repository root.
3. Run `npm test` (or `npm run test:integration`) from the repository root.

Expected:
`npm test` at the repository root ends in a defined, passing state — either by running a real test suite or by being an honest entry point that does not claim to run a harness that does not exist.

Actual:
The command exits 1 before any test runner starts:

```
> drm-copilot@1.0.0 test:integration
> vscode-test

Error: Could not find a .vscode-test file in this directory or any parent. You can specify one with the --config option.
```

`@vscode/test-cli` fails in `loadDefaultConfigFile` because no configuration file exists.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: see Actual Behavior. Prior verification is recorded at `docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/baseline/test-integration-root-baseline.2026-07-25T17-12.md` and `.../evidence/qa-gates/final-test-integration-root.2026-07-25T22-04.md`.


## Scope & Non-Goals
- In scope:
  - Root `package.json` **scripts block only**:
    - Repoint `test` at the real root jest suite: `"test": "node run-jest.cjs"` (the same command as the existing `test:unit`).
    - Remove `test:integration`.
    - Remove `compile:integration-tests`.
    - Trim `pretest` to `npm run compile && npm run lint` so it no longer calls the removed script.
    - Remove the vestigial `".vscode-test.mjs"` entry from the `format` and `format:check` glob lists.
  - A new regression-guard test asserting that no root npm script invokes `vscode-test` and that the dead config files (`.vscode-test.mjs`, `.vscode-test.js`, `.vscode-test.cjs`, `.vscode-test.json`, `tsconfig.vscode-test.json`) are absent. Modeled on the prior-art guard at `2f67b888:tests/unit/vscode-test-removal.test.ts`. It must be auto-discovered by the existing root jest `testMatch` (`tests/unit/**/*.test.ts`) so that no jest configuration change is needed.
  - A CI job wiring the root TypeScript toolchain (including root `npm test`) into `.github/workflows/`, following the repository's reusable-workflow convention: a callable `_<name>.yml` declaring both `on: workflow_call:` and `on: workflow_dispatch:`, referenced from `ci.yml` via `uses:`. See `.github/workflows/README.md` and the `## GitHub Actions Reusable Workflows` section of `.claude/skills/orchestrate/SKILL.md`.
- Out of scope / non-goals:
  - **devDependency removal and lockfile regeneration.** The research artifact recommended removing `@vscode/test-cli`, `@vscode/test-electron`, and `@types/mocha` from devDependencies and regenerating `package-lock.json`. These are deliberately excluded: this workstream owns the root `package.json` scripts block only, and a sibling orchestration owns dependency/lockfile work; touching them would collide. The unused devDependencies are recorded as a follow-up (see Rollout & Follow-up), not part of this fix.
  - Root extension-manifest vestiges (`publisher`, `displayName`, `engines.vscode`, `vscode:prepublish`, `@types/vscode`) — outside the scripts block; same collision constraint; follow-up material.
  - The `.gitignore` `.vscode-test/` entry — inert; not part of the scripts block.
  - Any VS Code extension-host integration harness, at the root or in `extensions/drm-copilot/`. If host-level testing is ever wanted, it is a new feature with its own issue (see Scope Decision, option (b)).
- Explicitly excluded systems, integrations, or datasets — MUST NOT be modified under any circumstances:
  - `run-jest.cjs`
  - `jest.config.cjs`
  - `.claude/rules/**`
  - `.agents/skills/**`
  - `extensions/drm-copilot/resources/claude-customizations/**`

## Root Cause Analysis
Verified conditions at `fb483b84`:

- Root `package.json` declares `"test:integration": "vscode-test"` and `"test": "vscode-test"`.
- No `.vscode-test.mjs`, `.vscode-test.js`, `.vscode-test.cjs`, or `.vscode-test.json` exists anywhere in the repository. `vscode-test` requires such a config file.
- No `tsconfig.vscode-test.json` exists. Only `tsconfig.json`, `tsconfig.jest.json`, and `tsconfig.tests.json` are present at the root.
- There are no root integration-test sources: no `*integration*` directory under `tests/`, and no `*.integration.*` files at the root.
- No file under `.github/workflows/**` references `test:integration` or `vscode-test`, so no CI job exercises this path.

Two neighbouring scripts silently paper over the gap:

- `compile:integration-tests` exits 0 with a "Skipping" message when `tsconfig.vscode-test.json` is absent.
- `format` / `format:check` include `.vscode-test.mjs` in their glob lists under `--no-error-on-unmatched-pattern`.

Provenance (verified by the orchestrator with `git log`, superseding the research artifact where they differ):

- Root `package.json` was created at commit `ac9bd4e8` ("chore(typescript): scaffold strict tsconfig and Jest (ts-jest) harness") already containing the dead `test`/`test:integration`/`compile:integration-tests` scripts. They were dead on arrival on main's lineage — this is scaffold debris, not a regression.
- **Correction to the research artifact:** the research states the `.vscode-test.*` and `tsconfig.vscode-test.json` files "never existed", based on GitHub API queries (the researcher had no shell access). Orchestrator re-verification with `git log --all` found they DID exist on an abandoned pre-rewrite lineage and were deliberately deleted there by commit `2f67b888` ("(fix(tests)): drop vscode-test harness and make npm test container-safe", Refs #12). The corrected statement is: **they never existed on main's current lineage.** This correction strengthens rather than weakens the scope decision, because `2f67b888` is prior art implementing exactly the selected option (a): it repointed `test`/`test:integration` at the jest suite, deleted `compile:integration-tests`, trimmed `pretest`, dropped the `.vscode-test.mjs` format globs, and added a `tests/unit/vscode-test-removal.test.ts` regression guard.
- The repository root is not a VS Code extension: root `package.json` has no `main` and no `activationEvents`, and the root has exactly one TypeScript source file (`src/hello-typescript.ts`) plus one root test (`tests/unit/hello-typescript.test.ts`).

This defect was identified and recorded for separate filing during issue #414; see `docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/other/preexisting-defects-for-filing.2026-07-25T22-28.md` (Condition 2).

## Scope Decision

The issue posed two candidate directions. The decision is recorded in `artifacts/orchestration/orchestrator-state.json` (`scope_decision`, decided 2026-07-26T01:55:00Z) and rendered here. This spec does not re-open the decision.

### Selected: option (a) — remove the dead entry points

Remove the dead root `vscode-test` entry points, repoint root `test` at the real jest suite, add a regression-guard test, and wire a CI job that actually runs the root TypeScript toolchain so the entry point cannot silently rot again.

Decisive evidence (all verified by the orchestrator with `git log`, not solely from the research artifact):

1. Root `package.json` was created at `ac9bd4e8` already containing the dead `test`/`test:integration`/`compile:integration-tests` scripts. They were dead on arrival on main's lineage.
2. `.vscode-test.*` and `tsconfig.vscode-test.json` have no history on main's current lineage (`git log --all` shows them only on the abandoned pre-rewrite lineage; see the correction in Root Cause Analysis).
3. The repository root is not a VS Code extension: no `main`, no `activationEvents`, exactly one TypeScript source file.
4. Option (b) has no target. `extensions/drm-copilot/test/extension.integration.test.ts` and `extension.collect-commit-context.integration.test.ts` use `jest.mock("vscode", ..., { virtual: true })` — they are jest tests against a mocked host, already executed in CI on ubuntu-latest and windows-latest by `.github/workflows/_drm-copilot-extension-tests.yml`. They would not run under a `@vscode/test-cli` mocha harness without a rewrite. A root harness would host nothing.
5. Prior art on the abandoned lineage (commit `2f67b888`) implemented exactly option (a), including a `tests/unit/vscode-test-removal.test.ts` regression guard, validating the approach.
6. Option (b) would additionally require a runtime VS Code download plus `xvfb-run` on Linux runners, duplicating the existing extension test job for no added coverage.

### Rejected: option (b) — wire a real vscode-test harness at the root

Rejected for the reasons in items 3, 4, and 6 above: there is no extension at the root to host, no test sources that could run under the harness without a rewrite, and the harness would add a network-downloading, display-server-dependent Electron launch that covers nothing the existing mocked jest suite does not already cover. If genuine extension-host integration testing is ever wanted, the correct location is `extensions/drm-copilot/` with its own config, tsconfig, CI job, and new mocha-based sources — a separately-scoped feature, not a repair of the root scripts.

### Strongest counterargument, and why it does not prevail

Removing `test:integration` deletes a conventional entry-point name that an external tool or contributor might expect. It does not prevail because no workflow, script, or docs page invokes root `test:integration`, and aliasing it to the unit suite — as the abandoned prior art did — would be actively dishonest naming: it would claim to run integration tests while running unit tests.

## Proposed Fix

### Design summary (what changes where):
1. **`package.json` (scripts block only):** `"test": "node run-jest.cjs"`; delete `"test:integration"`; delete `"compile:integration-tests"`; `"pretest": "npm run compile && npm run lint"`; remove `".vscode-test.mjs"` from the `format` and `format:check` glob lists. No other key in `package.json` changes (no devDependencies, no manifest fields, no lockfile).
2. **New regression-guard test** at `tests/unit/vscode-test-removal.test.ts` (name follows the `2f67b888` prior art), asserting (a) no root npm script value invokes `vscode-test` and (b) none of `.vscode-test.mjs`, `.vscode-test.js`, `.vscode-test.cjs`, `.vscode-test.json`, `tsconfig.vscode-test.json` exists at the repository root. Auto-discovered by the existing root jest `testMatch` (`tests/unit/**/*.test.ts`); no jest configuration change.
3. **New reusable CI workflow** (suggested name `_root-typescript-tests.yml`) under `.github/workflows/`, declaring both `on: workflow_call:` and `on: workflow_dispatch:`, running the root TypeScript toolchain: `npm ci` at the root, then root `npm test` (which via `pretest` runs `compile` and `lint`, then the root jest suite). Modeled on `_drm-copilot-extension-tests.yml` (checkout, setup-node with npm cache keyed on the root `package-lock.json`, install, test). Wired into `ci.yml` as a new job via `uses: ./.github/workflows/_root-typescript-tests.yml`, consistent with the seven existing reusable-workflow jobs.

### Boundaries and invariants to preserve:
- Only the `scripts` block of root `package.json` is edited. `devDependencies`, `dependencies`, `overrides`, and all manifest fields are untouched. `package-lock.json` is untouched.
- Forbidden files (must not change): `run-jest.cjs`, `jest.config.cjs`, `.claude/rules/**`, `.agents/skills/**`, `extensions/drm-copilot/resources/claude-customizations/**`.
- The existing root jest `testMatch` must pick up the guard test without configuration edits.
- Load-bearing `.vscode-test` references identified in research section 8 (PoshQC excludes and their tests, the extension folder-picker exclude, `extensions/drm-copilot/.vscodeignore`, historical `docs/**` records) are not touched.
- Existing CI jobs and their check-run names are not renamed; the new workflow is additive.

### Dependencies or blocked work:
- A sibling orchestration owns root dependency/lockfile work against the same base commit (`fb483b84`); this workstream must not touch `devDependencies` or `package-lock.json` (see `file_ownership_constraints` in the orchestrator state).
- Per the feature-review policy rule `modified-workflow-needs-green-run` and `.claude/rules/ci-workflows.md`, the new workflow requires a green run against the branch head before merge.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
- `package.json` — scripts block edits listed above.
- `tests/unit/vscode-test-removal.test.ts` — new regression-guard test.
- `.github/workflows/_root-typescript-tests.yml` — new reusable workflow (`workflow_call` + `workflow_dispatch`).
- `.github/workflows/ci.yml` — add one job referencing the new reusable workflow via `uses:`.
- `.github/workflows/README.md` — add the new workflow to the per-stage dispatch table (documentation consistency).

#### Functions/classes/CLI commands impacted:
- Root `npm test` — changes from an unconditional exit-1 to running the root jest suite (with `pretest` = compile + lint).
- Root `npm run test:integration` — removed; invoking it will produce npm's standard "missing script" error, which is the honest state (there is no root integration suite).
- Root `npm run compile:integration-tests` — removed (it unconditionally self-skipped).
- Root `npm run format` / `format:check` — behavior unchanged in effect; the `.vscode-test.mjs` glob was inert under `--no-error-on-unmatched-pattern`.

#### Data flow and validation changes:
- None. No production code path changes; only npm script definitions, one test file, and CI wiring.

#### Error handling and logging updates:
- None beyond the entry-point behavior change described above. The new workflow uses plain steps with default failure propagation; it contains no deliberately-failing nested commands, so the `$LASTEXITCODE` reset pattern in `.claude/rules/ci-workflows.md` is not triggered.

#### Rollback/feature-flag considerations (if applicable):
- Rollback is a single revert commit; the change is additive/removal-only text edits with no data or schema impact.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- Root npm script contract after the change: `test` == `test:unit` == `node run-jest.cjs`; `test:unit:coverage` unchanged; `test:integration` and `compile:integration-tests` absent.
- New workflow contract: callable via `workflow_call` from `ci.yml` and independently dispatchable via `workflow_dispatch` (`gh workflow run _root-typescript-tests.yml --ref <branch>`).

#### Required configuration keys and defaults:
- None. No new configuration is introduced.

#### Backward-compatibility expectations:
- `test:integration` removal is a deliberate, documented breaking change to the root script surface. Verified safe: no workflow, script, hook, task, or docs page invokes root `test:integration` (grep-verified in research RQ3/RQ7).
- Adding a job to `ci.yml` does not rename any existing check-run. If the new check is to become a required status check, follow the rename/required-check procedure in `.github/workflows/README.md` as an operational follow-up.

#### Performance constraints (latency/throughput/memory):
- The new CI job is a hermetic jest run (no network beyond `npm ci`, no Electron download, no display server). Expected runtime is comparable to the existing extension-tests job, which runs the same jest suite superset.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
  - CI runners check out to a path with no dot-directory component, so the pre-existing jest `<rootDir>` glob-escape artifact (#414 Condition 3) does not reproduce on CI. This is the default behavior of `actions/checkout`.
  - `run-jest.cjs` and `jest.config.cjs` already define a working root jest suite (root `tests/unit/**` plus `extensions/drm-copilot/test/**`); no runner or config work is needed.
- Constraints (budget, performance, compatibility):
  - File ownership: root `package.json` scripts block only; `devDependencies`/`package-lock.json` belong to a sibling orchestration.
  - Forbidden files listed in Scope & Non-Goals must not change.
  - No jest configuration change is permitted; the guard test must be discovered by the existing `testMatch`.
- External dependencies (services, libraries, releases):
  - None added. The now-unused `@vscode/test-cli`, `@vscode/test-electron`, and `@types/mocha` devDependencies remain in place (follow-up; see Rollout & Follow-up).

## Data / API / Config Impact
- User-facing or API changes: root npm script surface changes as specified (`test` repointed; `test:integration` and `compile:integration-tests` removed).
- Data or migration considerations: none.
- Logging/telemetry updates (if any): none.
- Compatibility notes (CLI flags, config schemas, versioning): no config schema changes; new workflow file follows the established `_<name>.yml` reusable pattern; `ci.yml` gains one additive job.

## Test Strategy

### Verification constraint (read before evaluating acceptance criteria)

Root `npm test` **cannot** be verified as passing inside this working worktree. The worktree path contains a dot-directory (`.claude`), which triggers the pre-existing jest `<rootDir>` glob-escape artifact (issue #414, Condition 3). Verified directly in this worktree: `npm run test:unit` prints `No tests found, exiting with code 1` and the reported `testMatch` is the malformed `C:/Users/DanMoisan/repos/drm-copilot\.claude/worktrees/.../tests/unit/**/*.test.ts`. `jest.config.cjs` and `run-jest.cjs` are off-limits in this workstream, so this artifact cannot be fixed here.

Consequently:
- The **authoritative verification path** for the passing state of root `npm test` is the new CI workflow, whose checkout path contains no dot-directory.
- **Local verification** is satisfied by a path-independent invocation (for example, running jest with an explicit rootDir-free `--testMatch` per the documented #414 Condition 3 workaround, or running from a checkout path without a dot-directory component).
- No acceptance criterion below requires `npm test` to pass in the local worktree. This is not a coverage dodge: the local failure mode is a pre-existing, separately-filed defect unrelated to this fix, and the same command is fully exercised on CI by the new workflow.

### Regression tests to add or update:
- New: `tests/unit/vscode-test-removal.test.ts` (modeled on `2f67b888:tests/unit/vscode-test-removal.test.ts`). Arrange: read and parse the committed root `package.json` (reading a versioned repository file; no temporary files). Assert: (1) no script value contains `vscode-test`; (2) `.vscode-test.mjs`, `.vscode-test.js`, `.vscode-test.cjs`, `.vscode-test.json`, and `tsconfig.vscode-test.json` do not exist at the repository root. Deterministic, order-independent, filesystem-read-only, Arrange–Act–Assert.

### Unit tests for the fixed behavior and boundaries:
- The guard test above is the unit-tier coverage for this defect class ("a declared npm script whose entry point cannot exist"). The existing `tests/unit/hello-typescript.test.ts` continues to pass unchanged and is now CI-executed for the first time.

### Edge cases and negative scenarios:
- Guard test must fail if any script is later re-pointed at `vscode-test` or if any dead config file is reintroduced (negative-path assertions are the guard's purpose).
- `npm run test:integration` after the change: npm reports a missing script (defined, honest failure) rather than a broken harness.

### Error handling and logging verification:
- Not applicable beyond the entry-point behavior; no production error paths change.

### Coverage impact and targets for changed lines/modules:
- **Zero coverage is lost, with proof.** Both removed scripts exit 1 inside `@vscode/test-cli`'s `loadDefaultConfigFile` before any runner starts (verbatim stack trace in `docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/baseline/test-integration-root-baseline.2026-07-25T17-12.md`), so they have never executed a single test; no `.vscode-test.*` config exists on main's lineage at any commit; and no CI workflow invokes them (grep-verified).
- **Coverage strictly increases:** the root jest suite goes from zero CI execution (no workflow currently runs `jest`, `run-jest`, `test:unit`, or root `npm test`) to being run by the new job on every `ci.yml` trigger.
- Edited files (`package.json`, workflow YAML) are not coverage-measured; the guard test adds executed test code only. No production file's coverage denominator changes.

### Toolchain commands to run (format → lint → type-check → test):
- Full seven-stage toolchain at the repository root per `.claude/rules/general-code-change.md`: `npm run format:check` (1), `npm run lint` (2), `npm run typecheck` (3), architecture-boundary tests (4 — no root TypeScript architecture gate is configured; record as not-applicable with rationale), root jest suite (5 — via the path-independent invocation locally and root `npm test` on CI), contract/schema checks (6 — not applicable at the root; record with rationale), integration tests (7 — not applicable at the root after this change; the extension integration-style jest tests run under stage 5 and in `_drm-copilot-extension-tests.yml`). Restart from stage 1 on any failure or auto-fix.
- Store toolchain and CI evidence under `docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/evidence/qa-gates/` and baseline captures under `.../evidence/baseline/` per the evidence-location convention.

### Manual validation steps (if required):
- After the branch is pushed: dispatch or observe the new workflow against the branch head and confirm a green run whose log shows root `npm test` executing the jest suite, including `tests/unit/vscode-test-removal.test.ts`.


## Acceptance Criteria

- [ ] AC1 — Scripts block corrected: the root `package.json` `scripts` block defines `"test": "node run-jest.cjs"`, defines `"pretest": "npm run compile && npm run lint"`, and no longer contains `test:integration` or `compile:integration-tests`; the `format` and `format:check` glob lists no longer contain `".vscode-test.mjs"`. Evidence: the committed `package.json` diff, which touches the `scripts` block only.
- [ ] AC2 — No root npm script references `vscode-test`: a search of the root `package.json` `scripts` values for the string `vscode-test` returns zero matches. Evidence: grep output recorded in `evidence/qa-gates/`, plus the regression guard in AC3.
- [ ] AC3 — Regression guard present: `tests/unit/vscode-test-removal.test.ts` exists, asserts that no root npm script value invokes `vscode-test` and that `.vscode-test.mjs`/`.vscode-test.js`/`.vscode-test.cjs`/`.vscode-test.json`/`tsconfig.vscode-test.json` are absent from the repository root, and requires no change to `jest.config.cjs` or `run-jest.cjs` to be discovered (its path matches the existing `tests/unit/**/*.test.ts` `testMatch`).
- [ ] AC4 — Regression guard executed: the guard test is listed as an executed, passing suite in the root jest run output — locally via the path-independent invocation, and on CI in the new workflow's run log. Evidence: run logs stored in `evidence/qa-gates/`.
- [ ] AC5 — CI wiring follows convention: a new reusable workflow `_<name>.yml` exists under `.github/workflows/` declaring both `on: workflow_call:` and `on: workflow_dispatch:`, runs `npm ci` and root `npm test` at the repository root, and is referenced from `ci.yml` via `uses:`; `.github/workflows/README.md` lists it in the per-stage dispatch table.
- [ ] AC6 — Root `npm test` ends in a defined, passing state, verified on CI: a green run of the new workflow against the branch head shows root `npm test` completing successfully (pretest compile + lint, then the full root jest suite). This run also satisfies the `modified-workflow-needs-green-run` policy for the workflow diff. Evidence: workflow run URL and log excerpt stored in `evidence/qa-gates/`. (Per the Test Strategy verification constraint, a local-worktree `npm test` pass is explicitly NOT required — the worktree's dot-directory path triggers the pre-existing #414 Condition 3 jest artifact, which is out of scope and unfixable here.)
- [ ] AC7 — Local path-independent verification recorded: the root jest suite (including the guard test) passes locally via a rootDir-free invocation (documented #414 Condition 3 workaround) or from a checkout path without a dot-directory component. Evidence: command and output stored in `evidence/qa-gates/`.
- [ ] AC8 — No silent coverage reduction, with proof: evidence records that (a) the removed scripts executed zero tests (baseline stack trace showing exit inside `loadDefaultConfigFile`), (b) no CI workflow previously ran the root TypeScript toolchain, and (c) the new workflow now runs the root jest suite on every `ci.yml` trigger — i.e., coverage strictly increases. All previously executing suites (root jest via `test:unit`, extension jest CI job, pytest, PoshQC/Pester, shell coverage) are unchanged. Evidence: baseline reference plus new-run log in `evidence/baseline/` and `evidence/qa-gates/`.
- [ ] AC9 — Boundaries respected: the change set contains no modifications to `run-jest.cjs`, `jest.config.cjs`, `.claude/rules/**`, `.agents/skills/**`, or `extensions/drm-copilot/resources/claude-customizations/**`, and no changes to `devDependencies` or `package-lock.json`. Evidence: `git diff --name-only` inventory recorded in `evidence/qa-gates/`.
- [ ] AC10 — Full seven-stage toolchain passes at the repository root in a single pass (format:check, lint, typecheck, architecture [n/a with rationale], unit tests via the path-independent invocation, contract checks [n/a with rationale], integration tests [n/a with rationale]), with the loop restarted from stage 1 after any failure or auto-fix. Evidence: stage-by-stage results in `evidence/qa-gates/`.
- [ ] AC11 — Scope decision documented: this spec's Scope Decision section records the selected option (a), the decisive evidence including the orchestrator's `git log --all` correction to the research artifact and the `2f67b888` prior art, the rejected option (b) with reasons, the strongest counterargument and why it does not prevail, and the deliberate exclusion of devDependency/lockfile changes as a follow-up.

## Risks & Mitigations
- Technical or operational risks:
  - The new CI job could surface a latent failure in the root jest suite on an OS not previously exercised. Mitigation: the same suite superset already runs green on ubuntu-latest and windows-latest in `_drm-copilot-extension-tests.yml`; the branch-head green run (AC6) catches any residual difference before merge.
  - A contributor or external tool could depend on root `test:integration` existing. Mitigation: grep-verified that nothing in the repository invokes it; removal is documented here and in the issue; npm's missing-script error is explicit.
  - Adding a `ci.yml` job may interact with branch-protection required checks. Mitigation: the job is additive (no renames); if it is to be made required, follow the documented procedure in `.github/workflows/README.md` post-merge.
  - Local verification in dot-directory worktrees remains broken (#414 Condition 3). Mitigation: documented path-independent invocation (AC7) and CI as the authoritative gate (AC6); the underlying defect is separately filed.
- Mitigations and rollbacks: single-revert rollback; no data, schema, or dependency changes.

## Rollout & Follow-up
- Release/rollout steps: standard PR merge to `main` after green branch-head run of the new workflow and full toolchain pass; no release artifact changes.
- Post-fix monitoring or clean-up tasks (follow-ups, not part of this fix):
  - Remove the now-unused root devDependencies `@vscode/test-cli`, `@vscode/test-electron`, and `@types/mocha` and regenerate `package-lock.json` — owned by the sibling dependency/lockfile orchestration; excluded here to avoid collision.
  - Optional cleanup of root extension-manifest vestiges (`publisher`, `displayName`, `engines.vscode`, `vscode:prepublish`, `@types/vscode`) and the `.gitignore` `.vscode-test/` entry — same ownership constraint.
  - If the new CI check should become a required status check, execute the required-status-check procedure in `.github/workflows/README.md`.
- Links: issue [#421](https://github.com/drmoisan/drm-copilot/issues/421); research `docs/features/active/2026-07-25-root-vscode-test-entrypoint-unrunnable-421/research/2026-07-25T23-45-root-vscode-test-entrypoint-scope-research.md`; scope decision `artifacts/orchestration/orchestrator-state.json` (`scope_decision`); prior #414 evidence `docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/other/preexisting-defects-for-filing.2026-07-25T22-28.md`.
