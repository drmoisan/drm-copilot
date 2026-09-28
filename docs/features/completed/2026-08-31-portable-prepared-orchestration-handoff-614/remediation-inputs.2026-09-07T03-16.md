# Remediation Inputs — CI Failure at PR #638 Head fca8c045 (#614)

**Timestamp:** 2026-09-07T03-16
**Author:** orchestrator (Step S9 CI Green Gate, CI-failure handling)
**Canonical issue number:** 614
**Pull request:** https://github.com/drmoisan/drm-copilot/pull/638
**PR head SHA:** `fca8c0455dd7207b21096e70fe7ffbf8cfc56ca1` (branch `feature/portable-prepared-orchestration-handoff-614`, rebased onto `origin/main @ 0542c92a7c589cfe952a0dfd480223960fd1eb33`)
**PR Pipeline run:** https://github.com/drmoisan/drm-copilot/actions/runs/34090900558 (workflow `CI`, event `pull_request`, conclusion `failure`)
**Main-branch baseline:** the latest `CI` run on `main` at `0542c92a` (run 33828840631, 2026-09-04) concluded `success`, so every failure below is attributable to this branch.
**Remediation loop:** loop 2, pass 2 (CI-failure pass; the counter is shared with local-finding passes; cap 3)

## Blocking Status

**Blocking findings: 2** (synthetic, converted from failed required checks per the CI-failure handling contract of `.claude/skills/orchestrate/SKILL.md`).

| ID | Severity | Failing required check | Failing job |
|---|---|---|---|
| CI-614-001 | Blocking | `poshqc / PowerShell QC` | https://github.com/drmoisan/drm-copilot/actions/runs/34090900558/job/101643988172 |
| CI-614-002 | Blocking | `drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)` | https://github.com/drmoisan/drm-copilot/actions/runs/34090900558/job/101643988246 |

Related non-required job failing for the same cause as CI-614-002: `root-typescript-tests / Root TypeScript Tests (ubuntu-latest)` (https://github.com/drmoisan/drm-copilot/actions/runs/34090900558/job/101643988318). The `windows-latest` legs of both TypeScript jobs were cancelled by the matrix fail-fast and carry no independent signal; locally on Windows the same suites pass (executor evidence `evidence/qa-gates/typescript-unit-coverage.2026-09-06T23-30.md`, reviewer first-hand run in `policy-audit.2026-09-07T02-00.md`).

## Enumerated Fix List

### CI-614-001 — Pester test reads the gitignored live checkpoint (Blocking)

- **Failing test file:** `tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1`, the `It 'denies <Label> exactly without changing checkpoint bytes'` block at lines 270–290 (six parametrized cases: malformed MCP id, unrelated MCP server, unregistered MCP operation, approximate MCP operation, shell edit, production patch).
- **Origin:** added on this branch by commit `b01e5201` (`feat(orchestration): add portable handoff runtime authority`); the file grew by 93 lines relative to `origin/main`.
- **CI failure excerpt (identical for all six cases):**

  ```
  [-] Codex epic preparation, wave, merge, and worktree gates.preparation route.denies malformed MCP id exactly without changing checkpoint bytes
  DirectoryNotFoundException: Could not find a part of the path 'D:\a\drm-copilot\drm-copilot\artifacts\orchestration\orchestrator-state.json'.
  MethodInvocationException: Exception calling "ReadAllBytes" with "1" argument(s): ...
  at <ScriptBlock>, D:\a\drm-copilot\drm-copilot\tests\scripts\codex-hooks\epic-execution-gates.Tests.ps1:275
  Tests Passed: 3925, Failed: 6, Skipped: 9
  ```

- **Root cause:** line 274 builds `$checkpointPath = Join-Path $script:RepoRoot 'artifacts/orchestration/orchestrator-state.json'` and line 275 reads its bytes. `/artifacts` is gitignored (`.gitignore` line 6), so the file exists only on a developer machine that has run an orchestration; the CI checkout has no such file. This violates `.claude/rules/general-unit-test.md` ("Tests must not rely on mutable global state or external configuration that can change between runs") and the determinism requirement. The test passed locally only because this worktree carries a live checkpoint.
- **Expected behavior after remediation:** the six cases prove "the hook denies exactly and does not change checkpoint bytes" against a checkpoint the test controls. Acceptable designs, in order of preference: (1) point the hook process at a committed preparation-route fixture checkpoint that already exists under `tests/fixtures/` or `tests/scripts/codex-hooks/` (the same file's other `preparation route` cases already drive the hook with a preparation checkpoint; reuse that mechanism and its path), reading the before/after bytes from that fixture path; (2) if the hook only reads `<cwd>/artifacts/orchestration/orchestrator-state.json` (see `.codex/hooks/enforce-epic-planning-only.ps1` line 322, `Join-Path $repositoryRoot 'artifacts/orchestration/orchestrator-state.json'`), run the hook process with `WorkingDirectory` set to a committed fixture repository root that contains that relative path, as the sibling worktree cases at lines 397–405 do with `cwd`. Creating or writing a temporary file is prohibited (`general-unit-test.md`, "Creation and use of temporary files in tests is strictly prohibited"); the byte-identity assertion must read a committed fixture before and after.
- **Verification commands:**
  - `mcp__drm-copilot__run_poshqc_test` with `workspace_root` only (repository-wide); read `artifacts/pester/pester-junit.xml` root attributes: `failures="0"`, `errors="0"`, and the six case names present and passing.
  - Additionally prove the fix does not depend on the local checkpoint: temporarily rename `artifacts/orchestration/orchestrator-state.json` is NOT permitted (it is the live orchestration checkpoint). Instead, add a read-only assertion in the test's `BeforeAll` that the fixture path it uses is tracked (`git ls-files --error-unmatch <fixture>` exit 0), and record that command and exit code in evidence.
- **Policy basis:** `.claude/rules/general-unit-test.md` (Independence, Determinism, External Dependencies); `.claude/rules/powershell.md`.
- **Acceptance criteria affected:** none directly (spec AC7 and user-story US6 concern hook behavior, which is unchanged); this restores CI verifiability of that behavior.

### CI-614-002 — Materializer test scenarios use a Windows-only workspace root that fails canonical containment on Linux (Blocking)

- **Failing test files (amended 2026-09-07 after re-reading the full job log; both ubuntu-latest jobs report `Test Suites: 5 failed`, `Tests: 69 failed`):**
  1. `extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer.test.ts` (14 cases: `returns a deterministic dry-run projection without mutation` plus every `blocks <name> without mutation` case), driven by `extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer-test-support.ts`;
  2. `extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer-production.test.ts`;
  3. `extensions/drm-copilot/test/mcp-handlers/orchestration-handoff-handlers.test.ts`;
  4. `extensions/drm-copilot/test/mcp-server.test.ts` (shared fixture `extensions/drm-copilot/test/mcp-server-test-service.ts` line 46 supplies `workspaceRoot: "C:/workspace"`);
  5. `extensions/drm-copilot/test/repo-automation-orchestration-validation.test.ts` (lines 71 and 312 drive the real authority service, whose `path.isAbsolute` check at `orchestration-handoff-authority-service.ts` line 59 rejects a drive-letter root on POSIX).
  The authorized test scope for this finding therefore includes all five test files plus the two shared support modules (`orchestration-handoff-materializer-test-support.ts` and `mcp-server-test-service.ts`). `orchestration-handoff-authority-service.test.ts` carries seven drive-letter literals and passed on Linux; treat it as in scope only if a literal is shown to reach a production absolute-path check on a success path.
- **CI failure excerpt (ubuntu-latest, both the extension-tests job and the root-typescript-tests job):**

  ```
  FAIL test/lib/validate/orchestration-handoff-materializer.test.ts
    ● orchestration handoff materializer › returns a deterministic dry-run projection without mutation
      -   "destinationCheckpointPath": "artifacts/orchestration/orchestrator-state.json",
      +   "destinationCheckpointPath": null,
      -   "primaryFailureCode": null,
      +   "primaryFailureCode": "HANDOFF_PLAN_PATH_INVALID",
      -   "status": "validated",
      +   "status": "blocked",
    ● orchestration handoff materializer › blocks input read failure without mutation
      Expected: "HANDOFF_VALIDATOR_UNAVAILABLE"
      Received: "HANDOFF_PLAN_PATH_INVALID"
    (the remaining twelve `blocks ... without mutation` cases receive HANDOFF_PLAN_PATH_INVALID likewise)
  ```

- **Root cause (corrected by the planner's tree re-derivation):** the scenarios pass the drive-letter literal `"C:/workspace"` as the workspace root. The failing predicate is `path.isAbsolute`, which rejects `C:/workspace` on POSIX, reached through three production entry points: the syntactic boundary `orchestration-handoff-materializer-support.ts` line 36 (installed by `orchestration-handoff-materializer.ts` line 138 when no `pathBoundary` is injected, which is the materializer scenario's case), the Node boundary `orchestration-handoff-path-boundary.ts` line 110 (reached by the production test), and the MCP handlers `orchestration-handoff-handlers.ts` lines 107 and 154 (reached by the handlers, mcp-server, and orchestration-validation tests). On Windows the literal is absolute; on Linux it is relative, so every success path blocks with `HANDOFF_PLAN_PATH_INVALID` (or the handler throws) before any scenario-specific behavior can occur. `HANDOFF_PLAN_PATH_INVALID` precedes every other code in the scenario because it is decided first, not because of the precedence registry. The sibling `orchestration-handoff-materializer-path-boundary.test.ts` already builds its roots with `path.resolve("virtual-workspace-canonical")` and normalizes with `.replaceAll("\\", "/")` (lines 10, 41–42), which is why it passes on both platforms.
- **Expected behavior after remediation:** every scenario root and every fake-filesystem key is derived from `path.resolve(...)` of a relative virtual name (for example `path.resolve("virtual-workspace")`), normalized to forward slashes exactly as the path-boundary test does, so the registered keys equal what the production boundary computes on Windows and on POSIX. Apply the same derivation to every path the scenario registers relative to that root (source checkpoint, envelope, archive, candidate, destination) and to any assertion that compares an absolute path (for example `affectedPaths`). The envelope's `binding.workspaceRoot` and the request's `workspaceRoot` must agree with the derived root. Do not change production code for this finding; the production boundary is correct and the defect is in the scenario. Check `orchestration-handoff-materializer-production.test.ts` (7 occurrences of the literal) and `mcp-handlers/orchestration-handoff-handlers.test.ts` (1 occurrence) for the same pattern and apply the same derivation wherever a literal root is passed into the real path boundary; occurrences that only flow into mocked services and never reach `path.resolve` may stay.
- **Verification commands (Windows-local; Linux verification is CI, since WSL Ubuntu carries no Node runtime):**
  - `cd extensions/drm-copilot && node run-jest.cjs --runInBand --runTestsByPath test/lib/validate/orchestration-handoff-materializer.test.ts test/lib/validate/orchestration-handoff-materializer-production.test.ts test/lib/validate/orchestration-handoff-materializer-path-boundary.test.ts test/mcp-handlers/orchestration-handoff-handlers.test.ts` (exit 0).
  - Platform-neutrality proof without a Linux runtime: add or extend one test that constructs the scenario and asserts the registered root equals `path.resolve(<virtual name>)` normalized, and that no registered key contains a drive-letter literal; and grep proof `Select-String -Path extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer-test-support.ts, extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer.test.ts, extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer-production.test.ts -Pattern 'C:/workspace' -SimpleMatch` returns no match for paths that reach the boundary.
  - `cd extensions/drm-copilot && npm run test:coverage` (exit 0, no coverage regression against the P0 baseline captured in the plan).
- **Policy basis:** `.claude/rules/general-unit-test.md` (Determinism: same results in any environment); `.claude/rules/typescript.md`.
- **Acceptance criteria affected:** none directly; the scenarios verify spec AC10/AC11 behavior, which is unchanged.

## Do Not Do

- Do not change any `HANDOFF_*` failure-code assignment, the failure-precedence registry, the path boundary, or any production module to make a test pass; both findings are test defects.
- Do not create, write, rename, or delete files under `artifacts/` from tests; do not use temporary files or directories in tests.
- Do not modify the committed TaskMaster fixtures or their `.gitattributes` entries.
- Do not narrow the QA scope: the final QA phase runs the full toolchain for TypeScript and PowerShell (both have changed files in this pass) and Python as a no-regression surface, with coverage thresholds floor-phrased against the exact Phase 0 baseline values.
- Do not touch the deferred follow-ups F1, F2, R11–R15 from `remediation-inputs.2026-09-07T02-00.md`.
- Do not add a dependency.

## Handoff Note

Per `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`, `atomic-planner` authors the remediation plan at `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/remediation-plan.2026-09-07T03-16.md`; `atomic-executor` preflights and executes it; the orchestrator commits, pushes, and re-runs the S9 CI gate at the new head; `feature-review` re-audits before completion is asserted. The full failed-job log for run 34090900558 was captured by the orchestrator with `gh run view 34090900558 --log-failed` and its relevant excerpts are reproduced above; the run URL is the authoritative source.
