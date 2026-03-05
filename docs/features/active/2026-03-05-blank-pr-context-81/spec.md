# 2026-03-05-blank-pr-context (Spec)

- **Issue:** #81
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-03-05T10-42
- **Status:** Draft
- **Version:** 0.1

## Context
When the extension exposes internal tooling to a destination workspace, PR-context collection from `scripts/dev_tools/pr_context` creates the output artifact but leaves it empty (or effectively empty), while `collect_commit_context.py` succeeds under the same workflow.

Environment:
- OS/version: Windows (workspace host)
- Python version: `>=3.10,<4.0` (repo constraint in `pyproject.toml`)
- Command/flags used: Extension-side execution flow that exposes and runs tooling in a destination workspace
- Data source or fixture: Destination workspace Git repository context (branch, base comparison, changed files/diffs)

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Use the `drm-copilot` extension to expose internal tooling to a destination workspace.
2. Run `collect_commit_context.py` (control) and then run PR-context collection from `scripts/dev_tools/pr_context` in the same destination workspace flow.
3. Inspect generated artifacts in the destination workspace.

Expected:
PR-context artifacts should be populated with expected branch/base comparison and diff context when generated in destination workspaces, just like commit-context artifacts are populated.

Actual:
The destination artifact path is created correctly, but PR-context content is empty (or effectively empty for downstream use). This indicates collection/rendering references are not resolving correctly under extension-side execution.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet:
	- Commit context artifact is populated using `collect_commit_context.py` in destination workspace.
	- PR-context artifact from `scripts/dev_tools/pr_context` is created but lacks expected context payload.


## Scope & Non-Goals
- In scope:
	- Fix extension-side PR-context generation so destination artifacts contain substantive PR context (not placeholder text).
	- Keep existing branch-selection UX and command wiring in `extensions/scaffold-extension/src/extension.ts`, while changing payload generation behavior in the bundled PR collector script.
	- Preserve canonical artifact paths and expected contracts:
		- `artifacts/pr_context.summary.txt`
		- `artifacts/pr_context.appendix.txt`
	- Add deterministic regression coverage that fails on placeholder-only output and passes on meaningful PR-context output.
- Out of scope / non-goals:
	- Reworking branch selection semantics, default-branch detection policy, or command contribution metadata.
	- Adding new commands, new artifact formats, or additional destination artifact files.
	- Changing `collect_commit_context.py` behavior (control path already behaves correctly).
	- Adding telemetry systems beyond existing extension output/logging patterns.
- Explicitly excluded systems, integrations, or datasets:
	- No changes to external GitHub API integrations.
	- No changes to non-extension PR-context call paths outside the extension-bundled execution flow.
	- No dataset/schema migrations.

## Root Cause Analysis
Likely path/reference resolution mismatch when PR-context package runs from extension-exposed location in destination workspace. Candidate areas to inspect:
- `scripts/dev_tools/pr_context/collector.py`
- `scripts/dev_tools/pr_context/render.py`
- `scripts/dev_tools/pr_context/render_pr_helpers.py`

Confirmed root cause from research:
- Extension command `scaffoldExtension.collectPrContext` currently executes bundled script `extensions/scaffold-extension/resources/templates/collect_pr_context.py`.
- That bundled script writes a placeholder summary body (heading + base branch line) instead of invoking canonical PR-context collection logic.
- Because output files are created at the correct destination path but payload generation is minimal, artifacts appear "blank" for downstream use even though file creation succeeds.

Signals/evidence supporting root cause:
- `collect_commit_context.py` bundled counterpart is fully implemented and produces useful artifacts in the same destination flow.
- Extension wiring, branch discovery, and command invocation are already exercised by tests; artifact content depth is not currently asserted strongly enough.
- Canonical collector entrypoint (`scripts/dev_tools/pr_context/collector.py::collect_and_write`) already exists and is richer than the placeholder bundled implementation.


## Proposed Fix

### Design summary (what changes where):
- Replace placeholder content generation in `extensions/scaffold-extension/resources/templates/collect_pr_context.py` with canonical-collector-equivalent collection/render flow.
- Keep extension command orchestration in `extensions/scaffold-extension/src/extension.ts` stable (workspace resolution, branch pick, Python invocation, output paths).
- Tighten extension tests so output quality (meaningful context sections/content) is required, not just file existence.

### Boundaries and invariants to preserve:
- Preserve extension execution boundary: execute bundled resources from extension install location; do not materialize scripts in destination workspace root.
- Preserve existing CLI argument surface consumed by extension invocation:
	- `--base`
	- `--out`
	- `--appendix-out`
- Preserve destination `cwd` semantics (Git resolution remains against destination workspace).
- Preserve deterministic cancel/error behavior for branch-selection and runtime failures.

### Dependencies or blocked work:
- Dependencies:
	- Git executable available in destination workspace environment.
	- Python runtime discovery path already used by extension commands.
- Blockers:
	- None identified from supplied issue + research.

### Implementation strategy (what changes, not sequencing):
	- Update bundled PR collector script internals to generate meaningful summary/appendix data instead of placeholder text.
	- Reuse canonical logic patterns from `scripts/dev_tools/pr_context/collector.py` and rendering helpers where feasible for parity.
	- Add regression assertions in extension tests to detect placeholder-only output regressions.
	- Keep process spawning and command registration contracts unchanged unless needed for argument/contract parity.
	
#### Files/modules to change:
- `extensions/scaffold-extension/resources/templates/collect_pr_context.py`
	- Primary fix target; replace placeholder writer path with full PR-context collection flow.
- `extensions/scaffold-extension/test/extension.collect-pr-context.test.ts`
	- Update/add assertions for summary + appendix content quality and failure-path diagnostics.
- `extensions/scaffold-extension/test/extension.integration.test.ts`
	- Update/add integration assertions to ensure destination artifacts are not effectively blank.
- Optional (only if needed for parity bug discovered during implementation):
	- `extensions/scaffold-extension/src/extension.ts`
	- `scripts/dev_tools/pr_context/collector.py` or render helper modules for shared contract adjustments.

#### Functions/classes/CLI commands impacted:
- `extensions/scaffold-extension/src/extension.ts`
	- Command: `scaffoldExtension.collectPrContext` (behavior contract preserved; payload quality improved through collector output).
- `extensions/scaffold-extension/resources/templates/collect_pr_context.py`
	- `main(...)` and internal collection/render helpers (exact function names to be finalized in implementation PR).
- Canonical reference contract:
	- `scripts/dev_tools/pr_context/collector.py::collect_and_write(...)`
	- `scripts/dev_tools/pr_context/collector.py::build_pr_context(...)`

#### Data flow and validation changes:
- Before fix:
	- Branch selection succeeds.
	- Bundled script writes placeholder markdown to `--out` and minimal/no useful appendix context.
- After fix:
	- Branch selection output (`--base`) feeds substantive PR-context data collection (git base/head/range, changed files, rendered sections).
	- `--out` receives summary content suitable for downstream consumption.
	- `--appendix-out` receives supporting detailed context payload.
- Validation expectations:
	- Output files must contain more than heading + base metadata.
	- Rendering must include contextual sections equivalent to canonical PR-context artifact intent.

#### Error handling and logging updates:
- Preserve existing extension-level logging and error propagation semantics.
- Ensure bundled collector surfaces actionable stderr/stdout on Git/runtime failures rather than silently producing near-empty outputs.
- Ensure deterministic non-zero exits for unrecoverable collector failures so extension can notify user appropriately.

#### Rollback/feature-flag considerations (if applicable):
- No feature flag planned (bug fix to existing behavior).
- Rollback path: revert bundled collector script changes to previous placeholder behavior if emergency stabilization is needed (not expected to be necessary).

### Technical specifications (interfaces/contracts):
- Artifact contract remains:
	- `artifacts/pr_context.summary.txt` for concise PR context summary.
	- `artifacts/pr_context.appendix.txt` for detailed supplemental context.
- Invocation contract remains extension-driven and destination-root scoped:
	- `python <bundled_collect_pr_context.py> --base <branch> --out <summary_path> --appendix-out <appendix_path>`
	- process `cwd` = destination workspace root.
- Content contract strengthens from "file exists" to "file has meaningful PR context sections and data."

#### Inputs/outputs and formats:
- Inputs:
	- CLI args: `--base`, `--out`, `--appendix-out`.
	- Destination git repository state (branches, merge-base ancestry, changed files/diffs).
- Outputs:
	- UTF-8 markdown/text artifacts at configured output paths.
	- Non-zero process exit and error text when collection cannot proceed.
- Format expectations:
	- Summary contains multi-line contextual body (not single-line placeholder).
	- Appendix contains additional detailed context for deeper review/debugging.

#### Required configuration keys and defaults:
- No new config keys introduced.
- Existing defaults remain:
	- Output paths provided by extension command.
	- Base branch selected in command flow and passed explicitly via `--base`.

#### Backward-compatibility expectations:
- No command ID changes (`scaffoldExtension.collectPrContext` unchanged).
- No CLI flag removals/renames for bundled collector invocation.
- Existing downstream consumers of `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` continue to read same paths.
- Behavior change is additive in quality (artifact richness), not a breaking path contract.

#### Performance constraints (latency/throughput/memory):
- Maintain current interactive command expectations (single invocation should complete within typical local Git command timing; no long-lived background processes).
- Avoid expensive full-repo scans beyond existing PR-context collector needs.
- Memory footprint should remain bounded to command-lifecycle data structures and subprocess output.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
	- Destination workspace is a valid git repository with an accessible selected base branch.
	- Python and Git are discoverable in the destination execution environment.
	- Extension command has filesystem write permission to destination `artifacts/` directory.
- Constraints (budget, performance, compatibility):
	- Keep fix minimal and targeted to bug scope (no broad refactors).
	- Preserve cross-platform behavior (Windows/macOS/Linux) of extension invocation path.
	- Maintain compatibility with repo Python constraint (`>=3.10,<4.0`) and existing extension runtime strategy.
- External dependencies (services, libraries, releases):
	- Local Git CLI behavior for branch/ref/diff resolution.
	- VS Code extension host APIs already used by command flow.
	- No new third-party package dependencies proposed.

## Data / API / Config Impact
- User-facing or API changes:
	- User-visible behavior improves: PR-context artifacts generated from extension flow are meaningfully populated.
	- No new user-facing commands or flags.
- Data or migration considerations:
	- No schema migrations.
	- Existing artifact filenames/locations preserved; only payload richness changes.
- Logging/telemetry updates (if any):
	- Continue using existing `Scaffold Utils` output channel diagnostics.
	- Add/retain failure diagnostics for runtime and collector exit failures relevant to blank output symptom triage.
- Compatibility notes (CLI flags, config schemas, versioning):
	- `--base`, `--out`, `--appendix-out` remain the extension-to-collector interface.
	- No config schema changes.
	- Backward compatible for consumers reading existing artifact paths.

## Test Strategy
Seeded from issue:

- [x] Unit coverage areas
	- Add regression tests for destination-workspace execution path to ensure PR-context artifacts are non-empty when git context exists.
- [x] Integration scenario to retest
	- End-to-end extension exposure workflow: compare commit-context vs PR-context artifact generation in destination workspace.
- [x] Manual verification notes
	- Re-run destination-workspace PR-context generation and confirm output includes expected context body.

- Regression tests to add or update:
- `extensions/scaffold-extension/test/extension.collect-pr-context.test.ts`
	- Add/adjust test(s) asserting generated summary/appendix contain non-placeholder substantive content.
	- Add/adjust failure-path assertions so collector errors are surfaced and do not silently pass with effectively blank artifacts.
- `extensions/scaffold-extension/test/extension.integration.test.ts`
	- Extend end-to-end command-flow assertions to validate artifact content quality in destination workspace, not only file creation.
- Unit tests (pytest) for the fixed behavior and boundaries:
- Python-side targeted tests for bundled collector behavior if repository test layout includes coverage for extension resource scripts.
- If no direct Python test harness exists for extension resources, enforce behavior through extension unit/integration tests and document parity checks against canonical collector contracts.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values):
- Invalid/missing `--base` should fail with actionable error (non-zero exit) rather than writing placeholder output.
- Destination repo with no changed files should still produce coherent, non-empty structured context indicating zero-diff state.
- Git command failure scenarios should emit diagnostics and fail deterministically.
- Existing cancel flow (no branch selected) must continue producing no artifact mutation.
- Error handling and logging verification:
- Verify `Scaffold Utils` output includes command failure context (runtime resolution failure, collector non-zero exit, key stderr hints).
- Verify no false-success notification when collector cannot generate meaningful context.
- Coverage impact and targets for changed lines/modules:
- Maintain repository coverage policy baselines and add regression coverage focused on changed extension PR-context flow.
- Changed lines in bundled PR collector and related extension tests should be covered by deterministic automated tests.
- Toolchain commands to run (format → lint → type-check → test):
- TypeScript/extension scope:
	- `npm run lint`
	- `npm run test`
- Python scope for touched Python files:
	- `poetry run black .`
	- `poetry run ruff check`
	- `poetry run pyright`
	- `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`
- Manual validation steps (if required):
- In extension host, run `Scaffold Utils: Collect PR Context` against a destination repository with known changes and verify both output artifacts contain meaningful multi-line context.
- Repeat in the same destination workspace where `collect_commit_context.py` succeeds to confirm parity of usefulness.

### 2026-03-05 Execution Status (Post-Fix)

- Passing regression tests (exact names):
	- `scaffold-extension collectPrContext command behavior > fails_when_summary_is_placeholder_only`
	- File run result: `extensions/scaffold-extension/test/extension.collect-pr-context.test.ts` => 7 passed, 0 failed.
- Integration assertions updated:
	- `extensions/scaffold-extension/test/extension.integration.test.ts` now asserts summary and appendix artifact line counts are greater than `1`.

Final command outcomes:
- `cd extensions/scaffold-extension && npm run format` => pass (`evidence/qa-gates/ts-format.2026-03-05T10-42.md`)
- `cd extensions/scaffold-extension && npm run lint` => pass (`evidence/qa-gates/ts-lint.2026-03-05T10-42.md`)
- `cd extensions/scaffold-extension && npm run typecheck` => pass (`evidence/qa-gates/ts-typecheck.2026-03-05T10-42.md`)
- `cd extensions/scaffold-extension && npm run test` => pass, 3 suites / 36 tests (`evidence/qa-gates/ts-test.2026-03-05T10-42.md`)
- `poetry run black .` => pass (`evidence/qa-gates/py-format.2026-03-05T10-42.md`)
- `poetry run ruff check` => pass after one E501 fix + loop restart (`evidence/qa-gates/py-lint.2026-03-05T10-42.md`)
- `poetry run pyright` => pass (`evidence/qa-gates/py-typecheck.2026-03-05T10-42.md`)
- `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` => pass, 801 tests, total coverage 81% (`evidence/qa-gates/py-test-cov.2026-03-05T10-42.md`)


## Acceptance Criteria
- [ ] Repro steps now produce the expected behavior in all documented environments.
- [ ] Regression test(s) added and passing (list file path and test name).
- [ ] Edge cases and invalid inputs are handled with correct errors or fallbacks.
- [ ] No unintended behavior changes outside the defined scope.
- [ ] Required logs/telemetry updated and validated (if applicable).
- [ ] Performance constraints met or explicitly waived with rationale.
- [ ] Full toolchain pass completed (format → lint → type-check → test).
- [ ] Docs/config references updated to match the new behavior.

## Risks & Mitigations
- Technical or operational risks:
	- Parity drift risk between bundled collector behavior and canonical collector behavior over time.
	- Cross-platform command/path handling risk (especially Windows quoting/path separators) affecting artifact generation.
	- Regression risk where tests pass on artifact existence while content quality degrades.
- Mitigations and rollbacks:
	- Add explicit content-quality assertions in extension test suites.
	- Keep invocation args/path contracts explicit and covered by tests.
	- If regression appears post-merge, rollback by reverting bundled collector change set and reopening targeted follow-up issue.

## Rollout & Follow-up
- Release/rollout steps:
	- Include fix in next extension release containing updated bundled resources.
	- Run extension unit/integration tests in CI before release publish.
	- Validate in manual destination-workspace smoke test for Windows host (issue repro environment).
- Post-fix monitoring or clean-up tasks:
	- Watch for follow-up issues reporting low-information PR-context artifacts after upgrade.
	- Consider future deduplication to share more code between canonical and bundled collectors to reduce drift.
- Links: issue, PRs, related docs
	- Issue: `docs/features/active/2026-03-05-blank-pr-context-81/issue.md`
	- Research: `artifacts/research/20260305-blank-pr-context-81-research.md`
	- Related command entrypoint: `extensions/scaffold-extension/src/extension.ts`
	- Related collector references: `scripts/dev_tools/pr_context/collector.py`, `extensions/scaffold-extension/resources/templates/collect_pr_context.py`
