# Owner-Directive Pass-Down - Remediation Plan, Cycle 2 (CI Failure)

- **Issue:** 1157
- **Branch:** feature/owner-directive-pass-down-1157
- **Requirements source:** `docs/features/active/owner-directive-pass-down-1157/remediation-inputs.2026-11-13T16-30.md` (findings C1, C2, C3; `Remediation-Mode: design`)
- **Context:** owner directive OD-17; the cycle 1 plan `remediation-plan.2026-11-13T14-04.md` and its evidence in the same folder
- **Status:** initial authoring; ready for preflight

## Required References

- Policy reading order: the `policy-compliance-order` skill; TypeScript rules in `.claude/rules/typescript.md`.
- Tool routes, the sibling-worktree command forms (`npm --prefix <abs>`), command-text restrictions, and CI shape: the `execution-environment` skill (`## Command-Text Restrictions`, `## CI Shape and Required Checks`). This plan does not restate them.
- Test cadence: `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill. After every task the executor writes `<FEATURE>/evidence/other/task-check.P<N>-T<M>.<timestamp>.md`; task checks are not gates.
- `<FEATURE>` is `docs/features/active/owner-directive-pass-down-1157`. `<worktree root>` is the item worktree root; artifacts record it as that token, never as a host path. SCRATCH means `<session scratchpad>/issue-1157/`; artifacts record the token `SCRATCH`.
- The merge base is the output of `git merge-base origin/main HEAD` in the item worktree, derived at run time.
- The three manifests are `.` (root), `extensions/drm-copilot`, and `packages/mcp-server`, each addressed as `npm --prefix <worktree root>/<manifest>`.

## CI Command Mirrored

- `.github/workflows/_npm-audit-gate.yml`, job `npm-audit`, runs per manifest the step `Install from lockfile (verifies lockfile/manifest sync)` (`npm ci`) and then the step `Audit dependencies` (`npm audit --audit-level="$AUDIT_LEVEL"`, with `audit-level` defaulting to `moderate`). No `--omit` or `--production` flag is passed, so development dependencies are audited. The local verification is therefore `npm ci` followed by `npm audit --audit-level=moderate` in each manifest, with no other flag.
- `.github/workflows/_root-typescript-tests.yml` step `Run root TypeScript toolchain and jest suite` runs `npm test` at the root (its `pretest` runs `compile` and `lint`); root `jest.config.cjs` `testMatch` covers `tests/unit` and `extensions/drm-copilot/test`, so the root suite also collects the extension tests; that CI job installs only the root dependencies (`npm ci` at the root) before `npm test`.
- `.github/workflows/_drm-copilot-extension-tests.yml` runs the extension `typecheck` and `test` scripts.
- `packages/mcp-server/package.json` defines no test script (`scripts` holds `build` and `prepack` only), so the MCP server package has no test suite; its `build` script is the dependency smoke check.

## Premise and Scope Notes

- **Override ranges already admit the fix.** The root, extension, and MCP server `package.json` `overrides` declare `hono` `^4.12.27` and `@hono/node-server` `^2.0.5`; the fixed releases (above `4.13.15` and above `2.1.5`) fall inside those ranges, so a lockfile-only resolution is expected and no `package.json` edit is planned. If `npm audit fix` itself rewrites a `package.json`, that change is kept and recorded; no range is edited by hand.
- **Fallback inside the declared ranges.** If `npm audit fix` leaves a moderate `hono` or `@hono/node-server` advisory in a manifest, the task runs `npm update hono @hono/node-server` in that manifest, which changes only the lockfile within the declared ranges. If a moderate-or-higher advisory still remains, the task stops and records it as a blocking finding with its advisory identifier; `--force` is never used and no range is changed.
- **Below-gate findings.** The low findings (the jest chain, and `deepmerge` in the extension, whose only fix is `npm audit fix --force`) are below the `moderate` gate. They are recorded in P1-T4 with the reason they are not forced; per OD-8 they are related, so they are recorded here rather than filed, and no separate issue is created.
- **Language scope.** The change set is three JSON lockfiles (and a `package.json` only if `npm audit fix` rewrites it). No PowerShell, Python, or TypeScript source changes. The gates therefore run the TypeScript and Node toolchain of the root and extension manifests. Pester and pytest suites resolve no installed Node package version; their branch-head results are the cycle 1 gates `evidence/qa-gates/pester-final.2026-11-13T15-48.md` and `evidence/qa-gates/pytest-final.2026-11-13T15-55.md`, and CI re-runs them on the pushed head.

## Changed Behavior and Asserting Tests

Search of `tests/` and `extensions/drm-copilot/test/` for `hono`, `@hono/`, and `package-lock` found no test that reads the content of a tracked lockfile or pins a resolved dependency version.

| Test or contract | What it asserts | Disposition |
|---|---|---|
| `tests/scripts/claude-lib/runbook/RunbookCommandVersion.Tests.ps1` (`reads top-level node_modules entries from package-lock.json and ignores nested paths`) | parsing of in-memory lockfile text | unchanged: reads no tracked lockfile |
| `tests/scripts/claude-hooks/validate-human-exception-runbook-output.Tests.ps1` (`merges pinned versions from several lockfile formats at the item root`) | an in-memory file map under a synthetic item root | unchanged: reads no tracked lockfile |
| `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1` (`bumps both manifests and opens a PR against main`) | the release script stages both lockfile paths | unchanged: asserts path names, not content |
| `tests/scripts/claude-lib/blast-radius/BlastRadiusConfig.Tests.ps1` (`returns exactly the separator-free entries in ordinal sort order`) and the blast-radius fixtures and Python parity tests | `package-lock.json` as a shared-surface name | unchanged: name only |
| `extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts` | `package-lock.json` excluded from push-down carriage | unchanged: name only |
| `tests/discovery_runtime/analyzer/test_dependency_node.py` and siblings | the `package-lock` parser format on synthetic input | unchanged: synthetic input |
| `.github/workflows/_npm-audit-gate.yml` job `npm-audit` | `npm ci` sync and `npm audit --audit-level=moderate` per manifest | the contract this plan satisfies (P1-T5, P2-T5) |

## Implementation Plan (Atomic Tasks)

### Phase 0 — Remediation Baseline

- [ ] [P0-T1] Install each manifest from its lockfile and record the toolchain: `node --version` and `npm --version`; `npm ci` through `npm --prefix <worktree root>/<manifest>` for the root, `extensions/drm-copilot`, and `packages/mcp-server`, in that order; the MCP server `build` script; and the lockfile difference between the merge base and `origin/main` for the three lockfile paths.
  - Acceptance: `<FEATURE>/evidence/remediation-baseline/npm-install.<timestamp>.md` records `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` for each command, with `npm ci` exit 0 for all three manifests and the build exit 0; `git status --porcelain` printed after the installs lists no lockfile and no `package.json`; the `origin/main` lockfile difference is recorded as empty, or, when non-empty, the task stops and reports it to the orchestrator before P1-T1, because `main` then already carries a lockfile change.
- [ ] [P0-T2] Record the audit fail-before per manifest: `npm audit --audit-level=moderate` against `package-lock.json`, `extensions/drm-copilot/package-lock.json`, and `packages/mcp-server/package-lock.json`, with no other flag, before any lockfile change.
  - Acceptance: three artifacts `<FEATURE>/evidence/remediation-baseline/npm-audit-baseline-root.<timestamp>.md`, `npm-audit-baseline-extension.<timestamp>.md`, and `npm-audit-baseline-mcp-server.<timestamp>.md`, each with `Timestamp:`, `Command:`, `EXIT_CODE:` (non-zero), `ExpectedExitCode: 1`, and `Output Summary:` giving the vulnerability count per severity, the moderate advisories for `hono` and `@hono/node-server` as printed, and every finding the output marks as fixable only with `--force`.
- [ ] [P0-T3] Record the TypeScript static baseline of `package.json` and `extensions/drm-copilot/package.json`: the root `format:check`, `lint`, and `typecheck` scripts; Prettier in check mode over the globs of the extension `format` script; and the extension `lint` and `typecheck` scripts.
  - Acceptance: `<FEATURE>/evidence/remediation-baseline/typescript-static.<timestamp>.md` records each step's command, exit code, and finding count; each Prettier check run that passes prints `All matched files use Prettier code style!`, and the artifact records that line or the count of files reported.
- [ ] [P0-T4] Run the root Jest baseline: one `test:unit:coverage` run of `package.json` under `jest.config.cjs` (test files under `tests/unit/` and `extensions/drm-copilot/test/`), through its normal parallel workers.
  - Acceptance: `<FEATURE>/evidence/remediation-baseline/jest-root-baseline.<timestamp>.md` records `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with the test-suite and test pass and fail counts and the repo-wide coverage headline figures the run prints.
- [ ] [P0-T5] Run the extension Jest baseline: one `test:coverage` run of `extensions/drm-copilot` through its normal parallel workers, with the per-file `coverageThreshold` map of `extensions/drm-copilot/jest.config.cjs` in force.
  - Acceptance: `<FEATURE>/evidence/remediation-baseline/jest-extension-baseline.<timestamp>.md` records the four fields, the pass and fail counts, and the statements, branches, functions, and lines percentages of the `text-summary` reporter.

### Phase 1 — Non-Breaking Lockfile Updates

- [ ] [P1-T1] (C1) Run `npm audit fix` without `--force` in the root manifest through `npm --prefix <worktree root>`, apply the in-range fallback of `## Premise and Scope Notes` only if a moderate `hono` or `@hono/node-server` advisory remains, then run `npm audit --audit-level=moderate` there.
  - Acceptance: `<FEATURE>/evidence/other/npm-audit-fix-root.<timestamp>.md` records each command and exit code, the resolved `hono` and `@hono/node-server` versions from `npm ls hono @hono/node-server`, and the audit exit 0; `git status --porcelain` lists `package-lock.json` as modified and lists the root `package.json` only if `npm audit fix` rewrote it, which the artifact then states; the task check records an empty test selection (no test reads this path) and the audit result.
- [ ] [P1-T2] (C2) Apply P1-T1 to `extensions/drm-copilot`, writing `<FEATURE>/evidence/other/npm-audit-fix-extension.<timestamp>.md`.
  - Acceptance: the artifact records the same fields as P1-T1 with the audit exit 0 for `extensions/drm-copilot`; `git status --porcelain` lists `extensions/drm-copilot/package-lock.json` as modified and `extensions/drm-copilot/package.json` only if `npm audit fix` rewrote it; the remaining `deepmerge` finding is recorded with its severity and is not forced.
- [ ] [P1-T3] (C3) Apply P1-T1 to `packages/mcp-server`, writing `<FEATURE>/evidence/other/npm-audit-fix-mcp-server.<timestamp>.md`.
  - Acceptance: the artifact records the same fields as P1-T1 with the audit exit 0 for `packages/mcp-server`; `git status --porcelain` lists `packages/mcp-server/package-lock.json` as modified and `packages/mcp-server/package.json` only if `npm audit fix` rewrote it.
- [ ] [P1-T4] Record every finding that remains after P1-T1 to P1-T3 in `package-lock.json`, `extensions/drm-copilot/package-lock.json`, or `packages/mcp-server/package-lock.json`, read from one `npm audit` run per manifest (no level flag), with its package, severity, advisory identifier, and the fix the output offers.
  - Acceptance: `<FEATURE>/evidence/other/npm-audit-residual.<timestamp>.md` lists each residual finding with the reason it is not fixed (fix only through `--force` or a major version change), states zero moderate, high, or critical residual findings in each of the three manifests, and states that no `--force` run occurred.
- [ ] [P1-T5] Verify the updated `package-lock.json`, `extensions/drm-copilot/package-lock.json`, and `packages/mcp-server/package-lock.json` the way CI installs them: `npm ci` in each manifest, then the `build` script of `packages/mcp-server/package.json`.
  - Acceptance: `<FEATURE>/evidence/other/npm-ci-sync.<timestamp>.md` records `npm ci` exit 0 for each manifest and the build exit 0; `git status --porcelain` after the run lists no path outside `<FEATURE>/` beyond those listed at the end of P1-T3 (new evidence files under `<FEATURE>/evidence/` are expected).
- [ ] [P1-T6] [phase-gate] Run stages 1 to 6 of the toolchain loop for the changed dependency trees per `## Test Cadence (Mandatory)`, writing `docs/features/active/owner-directive-pass-down-1157/evidence/qa-gates/phase-gate.P1.<timestamp>.md`: the root `format:check`, `lint`, and `typecheck` scripts; Prettier in check mode over the extension `format` globs; the extension `lint` and `typecheck` scripts; one root `test:unit` run and one extension `test` run, each through Jest's normal parallel workers and run one after the other; stage 4 (no architecture-boundary tool is configured) and stage 6 (no contract check reads a lockfile) recorded as not applicable with that reason. Restart from stage 1 after any failure or auto-fix.
  - Acceptance: the artifact records each stage's command, exit code, and finding or failure count from one clean pass; both Jest runs report 0 failed tests and 0 failed suites; every Prettier check prints `All matched files use Prettier code style!`.

### Phase 2 — Final QA

- [ ] [P2-T1] Run the TypeScript final-QC static steps for `package.json` and `extensions/drm-copilot/package.json`: the root `format:check`, `lint`, and `typecheck` scripts, Prettier in check mode over the extension `format` globs, and the extension `lint` and `typecheck` scripts.
  - Acceptance: `<FEATURE>/evidence/qa-gates/typescript-static.<timestamp>.md` records each step's command, exit code 0, and finding count 0; each Prettier check prints `All matched files use Prettier code style!`; finding counts are no higher than the P0-T3 counts.
- [ ] [P2-T2] Run the final root Jest gate: one `test:unit:coverage` run of `package.json` under `jest.config.cjs` (test files under `tests/unit/` and `extensions/drm-copilot/test/`), through its normal parallel workers.
  - Acceptance: `<FEATURE>/evidence/qa-gates/jest-root-final.<timestamp>.md` records the four fields, exit code 0, the pass and fail (0) counts, and the coverage headline figures.
- [ ] [P2-T3] Run the final extension Jest gate: one `test:coverage` run of `extensions/drm-copilot` through its normal parallel workers, with the per-file `coverageThreshold` map in force.
  - Acceptance: `<FEATURE>/evidence/qa-gates/jest-extension-final.<timestamp>.md` records the four fields, exit code 0 (so every per-file threshold holds), the pass and fail (0) counts, and the four `text-summary` percentages.
- [ ] [P2-T4] Compare the P2-T2 and P2-T3 results with the P0-T4 and P0-T5 baselines (`<FEATURE>/evidence/remediation-baseline/jest-root-baseline.<timestamp>.md` and `jest-extension-baseline.<timestamp>.md`): pass counts not lower, fail counts 0, and each coverage headline figure not lower than its baseline and at or above 85% lines and 75% branches for the extension.
  - Acceptance: `<FEATURE>/evidence/qa-gates/coverage-comparison.<timestamp>.md` records baseline, post-change, and threshold as numbers for each figure, states that no production source file changed (so no per-file comparison applies), and records PASS only when every comparison holds; otherwise the outcome is remediation-required.
- [ ] [P2-T5] Run the final audit gate exactly as `.github/workflows/_npm-audit-gate.yml` does: `npm ci` then `npm audit --audit-level=moderate` for `package-lock.json`, `extensions/drm-copilot/package-lock.json`, and `packages/mcp-server/package-lock.json`, with no other flag.
  - Acceptance: `<FEATURE>/evidence/qa-gates/npm-audit-final.<timestamp>.md` records `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` for each of the six commands, all with exit code 0, and the per-severity counts of each audit.
- [ ] [P2-T6] Record the scope check of this cycle against the cycle-start commit, which is the commit that added this plan file (`git log --diff-filter=A --format=%H -- docs/features/active/owner-directive-pass-down-1157/remediation-plan.2026-11-13T16-30.md`), because the merge-base diff also holds the cycle 1 and feature changes: `git diff --name-status <cycle-start commit>` and `git status --porcelain`; for each changed lockfile, a comparison against its merge-base version (read with `git show`) by a `.cjs` script under `SCRATCH` (no new Python) reporting `lockfileVersion`, the `packages` root entry (key empty string), and the changed `packages` keys.
  - Acceptance: `<FEATURE>/evidence/other/scope-check.<timestamp>.md` records both listings and the script output, and marks PASS for each check: the changed paths outside `<FEATURE>/` are only the three lockfiles, plus a `package.json` that P1-T1 to P1-T3 recorded as rewritten by `npm audit fix`; no `.py`, `.ps1`, `.ts`, workflow, or customization file changed in this cycle; each lockfile keeps its `lockfileVersion` and an unchanged `packages` root entry, and every changed key is a `node_modules/` entry; no `package.json` dependency or override range is wider than at the merge base.
- [ ] [P2-T7] Walk the policy-audit, code-review, and feature-audit templates under `docs/features/templates/policy_audit/` against the branch diff from the merge base, including findings C1 to C3 of the inputs, and write a new self-review file; fix any FAIL row and re-run P2-T1 to P2-T6 before writing a new self-review file.
  - Acceptance: `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md` exists, is newer than `self-review.2026-11-13T15-59.md`, which is not edited, and carries one PASS, FAIL, or N/A row per checklist item with zero FAIL rows, including rows for C1, C2, and C3 citing the P2-T5 artifact.

## Pre-Mortem

- Review checklists: P2-T7 walks all three templates against the merge-base diff, including C1 to C3, and the plan cannot complete with a FAIL row; the inputs' requirement that the PR head be re-reviewed after this cycle stays with the orchestrator.
- Coverage: no production source file changes, so per-file figures cannot move through this change; a dependency update can still change test behavior, so P0-T4 and P0-T5 record the baselines, P2-T2 and P2-T3 re-run both Jest suites with coverage, the extension run enforces its per-file `coverageThreshold` map, and P2-T4 compares every figure.
- Mirror parity: no `.claude`, `.agents`, `.github`, or bundled file changes, so no bundle copy is needed; the plan alters no fact the execution-environment brief states (the toolchain baseline names Node.js and npm versions, not package versions, and no job or check changes), so no brief-update task is needed.
- File size: lockfiles are generated JSON outside the source-file tiers, and no source or test file changes.
- Test isolation: Jest runs through its normal parallel workers, one suite at a time (OD-5), re-run only after a fix; Pester and pytest are not run because no PowerShell or Python input changes (see `## Premise and Scope Notes`); no test creates a file; no integration or golden suite runs locally.
- CI-only behavior: CI runs `npm ci` and the audit on `ubuntu-latest` with Node.js 26.13.0; P0-T1 records the local Node.js and npm versions, and a different local npm major can rewrite lockfile metadata, which P2-T6 detects through the unchanged `lockfileVersion` and root entry; the advisory database can change between the local run and CI, so P2-T5 runs immediately before the push and any new advisory is a new finding, not a pass.
- Evidence: every artifact is a new file under `<FEATURE>/evidence/<kind>/` named with a clock-read UTC stamp; no existing evidence, including `self-review.2026-11-13T15-59.md`, is edited, back-dated, or deleted; artifacts record `<worktree root>` and `SCRATCH` tokens, never an absolute path.

## Test Plan

- Unit: the root Jest suite (which also collects `extensions/drm-copilot/test`) and the extension Jest suite, in P1-T6 and in P2-T2 and P2-T3.
- Dependency gate: `npm ci` and `npm audit --audit-level=moderate` per manifest in P0-T2 (fail-before), P1-T1 to P1-T3, P1-T5, and P2-T5.
- Integration: none local; CI runs integration and golden suites.
- MCP server: no test script is defined; its `build` script is run in P0-T1 and P1-T5.

## Open Questions / Notes

- No spec acceptance criterion or public interface changes; this cycle covers C1 to C3 only.
- Items #1164 and #1163 take the fix by merging `main` after #1171 merges (OD-17); this plan changes nothing on their branches.
