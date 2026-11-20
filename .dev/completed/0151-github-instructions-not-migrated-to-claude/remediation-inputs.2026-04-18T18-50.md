# Remediation Inputs: github-instructions-not-migrated-to-claude (#151)

**Generated:** 2026-04-18T18-50
**Source audit:** `policy-audit.2026-04-18T18-50.md`, `code-review.2026-04-18T18-50.md`, `feature-audit.2026-04-18T18-50.md`
**Scope:** Feature-vs-base remediation for branch `bug/github-instructions-not-migrated-to-claude-151` against `origin/development` @ `d742a7f8`.

## Trigger Summary

Remediation is triggered by:
- Coverage floor failure: PowerShell repo-wide coverage is 27.66%, below the 80% floor required by `.claude/rules/general-unit-test.md` and `.claude/rules/powershell.md`.
- Coverage artifact gap: the two new `.claude/hooks/*.ps1` files are not present in `artifacts/pester/powershell-coverage.xml`; per the `feature-review-workflow` SKILL, absent per-file coverage for a new file is a FAIL.
- File-size policy violation: `extensions/drm-copilot/src/repo-automation-service.ts` (545 lines at HEAD) and `extensions/drm-copilot/src/mcp-tools.ts` (568 lines at HEAD) exceed the 500-line production-file limit, and both grew on this branch from a pre-existing overage.
- Test file-size policy violation: `extensions/drm-copilot/test/repo-automation-service.test.ts` grew from 542 → 689 lines on this branch.
- Evidence gap: TypeScript toolchain (Prettier/ESLint/TSC/Jest) result artifacts and PowerShell toolchain (PSScriptAnalyzer/Invoke-Formatter) artifacts are not recorded for this review window; the Pester coverage artifact is stale (2026-04-17T22-28, pre-dates HEAD `b749258`).
- Python mirror coverage gap: `extensions/drm-copilot/resources/scripts/dev_tools/*.py` mirror copies are not present in `artifacts/python/lcov.info`; per-file coverage cannot be verified from existing evidence.

All 13 acceptance criteria from `spec.md` are PASS. This remediation does not reopen AC work; it addresses non-AC feature-vs-base findings that the SKILL Scope Invariant requires to be covered.

## Fix List (Authoritative)

### R-1 (Blocker): Add Pester tests for new PowerShell hook scripts and bring PowerShell coverage to policy

- **Files to add:** Pester test files, one per hook, following the naming convention `tests/pester/.claude/hooks/check-python-test-purity.tests.ps1` and `tests/pester/.claude/hooks/enforce-python-batch-budget.tests.ps1` (or the repo's established Pester test location — locate and confirm before writing).
- **Expected behavior for tests (check-python-test-purity):**
  - Positive: content without forbidden patterns is allowed (no block response).
  - Negative: content importing `tempfile`, `NamedTemporaryFile`, `TemporaryDirectory`, `mkstemp`, `mkdtemp`, or using `Path.touch` → block.
  - Negative: content importing `requests`, `httpx`, `urllib.request`, `socket`, or `http.client` → block.
  - Negative: content importing `subprocess`, `os.system`, or `os.popen` → block.
  - Negative: content using `time.sleep` → block.
  - Negative: content importing `psycopg2`, `pymysql`, or using `sqlite3.connect` against a real path → block.
  - Envelope: malformed JSON in `CLAUDE_TOOL_INPUT` → block with a specific diagnostic.
  - Envelope: empty `content` / `new_string` → no block.
- **Expected behavior for tests (enforce-python-batch-budget):**
  - Positive: small edit under the budget threshold is allowed.
  - Negative: write-or-edit that exceeds the budget threshold is blocked with a diagnostic containing the count.
  - Session state: counter increments across sequential allowed edits; reset occurs on new session file or missing session file.
  - Envelope: malformed JSON → block with a specific diagnostic.
- **Verification commands:**
  - `mcp__drmCopilotExtension__run_poshqc_test` against the Pester test path → artifact `artifacts/pester/powershell-coverage.xml` regenerated at HEAD.
  - The regenerated Pester XML must contain `<sourcefile>` entries for both new hook files, with line-coverage >= 90% each.
  - Repo-wide PowerShell line coverage in the regenerated XML must be >= 80%, OR a scoped-coverage decision must be applied (see R-2).

### R-2 (Blocker, optional alternative to scope R-1 upward): Scope PowerShell coverage measurement

If raising repo-wide PowerShell coverage to 80% is out of scope for this branch (many 0.00% files are bootstrap/one-shot scripts — `bootstrap-host.ps1`, `verify-host.ps1`, `publish-sideloaded-extension.ps1`, `run-*.ps1` wrappers), take the alternative:

- **Files to modify:** the Pester configuration file (`PesterConfig.ps1` or the equivalent invocation in `scripts/powershell/PoshQC/`) that defines which PowerShell files are measured for coverage.
- **Expected behavior:** exclude identified bootstrap/wrapper scripts from the measured path list, with an inline comment explaining why each exclusion is justified (non-testable runtime side effects, one-shot bootstrap, external CLI wrapper). Coverage artifact continues to include all testable files (`.claude/hooks/*.ps1`, `PoshQC.psm1`, `link-feature-docs.ps1`, etc.).
- **Verification commands:**
  - Regenerate Pester coverage artifact at HEAD.
  - Confirm repo-wide (scoped) coverage >= 80% AND both new hook files are at >= 90% line coverage.
  - Document the exclusion list in the PR description and in `.claude/rules/powershell.md` as a codified scoping decision.

Either R-1 or R-2 (combined with Pester tests for the two new hooks) resolves the coverage blocker.

### R-3 (High): Refactor `extensions/drm-copilot/src/mcp-tools.ts` below 500 lines

- **Expected behavior:** the file's public exports (`dispatchRepoAutomationTool`, etc.) remain stable; only internal organization changes.
- **Implementation strategy:** extract each per-tool case in `dispatchRepoAutomationTool` into a dedicated handler function in a new module `extensions/drm-copilot/src/mcp-handlers/*.ts` (one per tool, or grouped by concern). The dispatcher becomes a thin switch over handler references.
- **Acceptance:** `wc -l extensions/drm-copilot/src/mcp-tools.ts` returns <= 500. All existing TypeScript tests pass unchanged (they test the dispatcher's public surface).
- **Verification:** `npm run format:check && npm run lint && npm run type-check && npm run test:unit:coverage`.

### R-4 (High): Refactor `extensions/drm-copilot/src/repo-automation-service.ts` below 500 lines

- **Expected behavior:** the file's public interface `RepoAutomationService` remains stable; all callers continue to compile unchanged.
- **Implementation strategy:** extract argument-assembly helpers for each method that builds CLI args (`resolveExecuteHardLockPrompt`, `validateOrchestrationArtifacts`, etc.) into `extensions/drm-copilot/src/repo-automation-args.ts`. The service delegates argument construction to the helpers and remains a thin orchestrator over `executeScript`.
- **Acceptance:** `wc -l extensions/drm-copilot/src/repo-automation-service.ts` returns <= 500. All existing tests pass unchanged.
- **Verification:** same toolchain command as R-3.

### R-5 (High): Close the Python mirror-coverage verification gap

- **Expected behavior:** Coverage for the extension-bundled Python mirrors (`extensions/drm-copilot/resources/scripts/dev_tools/push_down_copilot_customizations_filesystem.py` and `resolve_hard_lock_prompt.py`) is verifiable from a persisted artifact.
- **Implementation strategy (choose one):**
  - Option A (preferred): extend `pyproject.toml` / `.coveragerc` to include `extensions/drm-copilot/resources/scripts/dev_tools/*.py` in the source paths measured by `pytest --cov`. Re-run `poetry run pytest --cov --cov-report=term --cov-report=lcov:artifacts/python/lcov.info` and confirm the mirror files now appear in `artifacts/python/lcov.info` at >= 80%.
  - Option B: document the sync-and-parity model explicitly. Add a note to `.github/instructions/self-explanatory-code-commenting.instructions.md` (or to the spec.md under a `Mirror-verification model` section) stating that the mirror is generated from the canonical copy at build time and is verified via the bundled-test suite `tests/extensions/drm_copilot/resources/templates/test_resolve_hard_lock_prompt*.py`. Require that bundle-parity tests assert byte-equivalence of mirror behavior.
- **Acceptance (Option A):** `artifacts/python/lcov.info` contains `SF:` entries for the extension-mirror copies at >= 80%. **Acceptance (Option B):** mirror-parity test(s) exist and fail if the mirror diverges from canonical in a way that affects runtime behavior.

### R-6 (Medium): Split `extensions/drm-copilot/test/repo-automation-service.test.ts`

- **Current state:** 689 lines at HEAD; was 542 at baseline.
- **Expected behavior:** the test file(s) together cover the same behaviors at the same quality; each split test file is <= 500 lines.
- **Implementation strategy:** group tests by target method — one file for hard-lock prompt resolution, one for orchestration validation, one for discovery dispatch. Use shared fixtures or a `test-helpers.ts` module if needed.
- **Verification:** `npm run test:unit:coverage` continues to pass at >= 80% repo-wide.

### R-7 (Medium): Regenerate stale and missing toolchain-evidence artifacts

- **Expected behavior:** `artifacts/evidence/post-change/<ts>/` contains a complete set of post-change toolchain result files for this feature review window.
- **Files to generate:**
  - `post-change-prettier.md` (`npm run format:check`)
  - `post-change-eslint.md` (`npm run lint`)
  - `post-change-tsc.md` (`npm run type-check`)
  - `post-change-jest.md` (`npm run test:unit:coverage`)
  - `post-change-psscriptanalyzer.md` (PSScriptAnalyzer over changed PS1 files)
  - `post-change-pester.md` (Pester run over `.claude/hooks/*.ps1` and related)
- **Verification:** each file records `Timestamp:`, `Command:`, and `EXIT_CODE:`. Coverage artifacts `coverage/lcov.info` and `artifacts/pester/powershell-coverage.xml` are regenerated at HEAD.

### R-8 (Medium): Tighten MCP dispatch invariant and surface-friendly error

- **File:** `extensions/drm-copilot/src/repo-automation-service.ts`, method `resolveExecuteHardLockPrompt`.
- **Change:** the thrown error when `quiet === true && output === undefined` currently uses the internal method name. Change the message to reference the MCP tool name (`resolve_execute_hard_lock_prompt: 'quiet' requires 'output' to be set.`) so external callers get an actionable diagnostic.
- **File:** `extensions/drm-copilot/src/mcp-tools.ts`, case `resolve_execute_hard_lock_prompt`.
- **Change:** extract the hard-coded `"artifacts/hard_lock_prompt.txt"` default to a named constant at module-top.
- **Verification:** TypeScript build and existing tests pass; new/updated test asserts the error message content and the constant usage.

## Do-Not-Do List

- Do not weaken the coverage thresholds in `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`, or the policy-reading order defined in `CLAUDE.md`.
- Do not narrow the scope of the feature-review back to "plan scope only" or similar formulations; the SKILL Scope Invariant forbids it.
- Do not modify `.github/instructions/*.md` policy files.
- Do not silently skip toolchain steps. If a check cannot be run, document the specific environmental cause and surface it in the remediation evidence artifact.
- Do not introduce new third-party dependencies to satisfy the Pester/lcov changes.
- Do not merge the PR until the coverage-floor and file-size items are remediated or explicitly deferred with a documented, reviewed technical-debt follow-up issue.
- Do not add temporary files or network-dependent tests in the Pester additions.
- Do not combine the remediation work with new feature work; this is a corrective plan only.

## Suggested Phase Skeleton (for atomic_planner)

(The atomic_planner is authoritative for the final plan shape; this is a suggestion.)

- **Phase 0 — Baseline capture:** record coverage state at HEAD, record file line counts, record existing-test inventory for new PS1 hooks.
- **Phase 1 — PowerShell coverage (R-1 and/or R-2):** write Pester tests for the two hook scripts, optionally adjust coverage-measurement scope, regenerate Pester coverage artifact, verify 80% repo-wide and 90% per-new-file.
- **Phase 2 — TypeScript file-size (R-3 and R-4):** extract helper modules, run full TS toolchain, confirm file sizes and coverage unchanged or improved.
- **Phase 3 — Python mirror coverage (R-5):** choose Option A or B, implement, regenerate lcov or land parity tests.
- **Phase 4 — Test-file split (R-6):** split `repo-automation-service.test.ts`.
- **Phase 5 — Evidence capture (R-7):** regenerate all toolchain evidence artifacts.
- **Phase 6 — MCP dispatch polish (R-8):** message and constant extraction.
- **Phase 7 — Final verification:** full toolchain loop (format → lint → type-check → test → coverage) for every affected language; re-run feature-review to confirm policy audit shows no FAIL items; update `status.md` if required.

## Context Package

- `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/spec.md` (AC authority; all 13 remain PASS)
- `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/policy-audit.2026-04-18T18-50.md` (authoritative audit)
- `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/code-review.2026-04-18T18-50.md` (findings detail)
- `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/feature-audit.2026-04-18T18-50.md` (AC status)
- `artifacts/pr_context.summary.txt` + `artifacts/pr_context.appendix.txt` (branch diff evidence)
- `artifacts/python/lcov.info`, `coverage/lcov.info`, `artifacts/pester/powershell-coverage.xml` (coverage artifacts at review time)

## Handoff

The next step in this remediation workflow is to delegate plan creation to the `atomic_planner` subagent via `remediation-handoff-atomic-planner`. The handoff target file is:

- `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/remediation-plan.2026-04-18T18-50.md`

The handoff prompt is recorded in `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/remediation-plan.2026-04-18T18-50.md` as a scaffold for the atomic_planner.
