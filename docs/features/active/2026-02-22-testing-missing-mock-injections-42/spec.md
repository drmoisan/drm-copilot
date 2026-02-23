# testing-missing-mock-injections (Spec)

- **Issue:** #42
- **Parent (optional):** none
- **Owner:** Dan Moisan
- **Last Updated:** 2026-02-22T00-00
- **Status:** Drafted for implementation
- **Version:** 1.0
- **Work Mode:** full

## Context
- Summary of the bug and its impact (link to repro/playbook entry).
	Unit tests in `tests/scripts/dev_tools/test_new_active_feature_folder.py` call `create_active_folder(...)` without injecting `code_launcher`, so the default launcher path can invoke a real `code` subprocess. This violates unit-test hermeticity and can open/create files under `/workspace/...` (host-mapped to `C:\workspace\...` on Windows).
- Observed environment(s):
	Windows host environment with Poetry-managed Python runtime; repro executed with `poetry run pytest tests/scripts/dev_tools -q` and subprocess instrumentation writing to `artifacts/research/subprocess-invocations.log`.
- Customer impact and severity (who is affected, how often, how bad):
	High severity for contributors and CI reliability: affected test runs can trigger editor-launch side effects and create noisy, misleading filesystem churn outside test-owned boundaries. Deterministic whenever affected tests omit launcher injection and the launcher executable is available.
- First observed date and version(s) impacted:
	First captured 2026-02-22 in active-branch test runs; impacts current test suite state where 11 callsites omit `code_launcher`.

## Repro & Evidence
- Steps to reproduce (with data/flags/inputs):
	1. Run `poetry run pytest tests/scripts/dev_tools -q` using current test code where specific `create_active_folder(...)` calls do not pass `code_launcher`.
	2. Inspect `artifacts/research/subprocess-invocations.log` from the instrumented run.
	3. Observe `code` launcher invocations with `/workspace/docs/features/active/...` arguments such as `single-marker-40`, `full-compatible`, and `no-potential` artifacts.
- Expected vs actual behavior:
	Expected: tests are hermetic and do not launch external editor processes or touch host-mapped workspace paths.
	Actual: default launcher path executes `subprocess.run([code_cmd, ...], check=False)` for existing paths and triggers external editor-launch side effects.
- Logs/screenshots/error snippets:
	Evidence includes log lines like `run|...\code.CMD /workspace/docs/features/active/full-compatible/user-story.md ...` and `run|...\code.CMD /workspace/docs/features/active/no-potential/user-story.md ...` from `artifacts/research/subprocess-invocations.log`.
- Frequency / determinism (always, intermittent, data-dependent):
	Deterministic for affected callsites when launcher executable is discoverable (`shutil.which("code")` returns a path). No evidence of direct `git worktree` subprocess execution in the captured run (`GIT_WORKTREE_MATCHES=0`).

## Scope & Non-Goals
- In scope:
	- Update all identified missing test callsites in `tests/scripts/dev_tools/test_new_active_feature_folder.py` to inject `code_launcher=FakeCodeLauncher()`.
	- Add/extend a test guard in `tests/conftest.py` to fail fast on forbidden unmocked editor-launch subprocess attempts for isolated unit-test modules.
	- Preserve and verify launcher-specific behavior tests that explicitly mock subprocess interactions.
- Out of scope / non-goals:
	- Changing production/CLI default behavior of `create_active_folder(...)` launcher opening.
	- Refactoring slug logic, folder layout generation rules, issue-mode routing, or non-launcher feature behavior.
	- Introducing new runtime dependencies.
- Explicitly excluded systems, integrations, or datasets:
	- Git worktree flow changes (not evidenced as root cause here).
	- External APIs or services.
	- Non-dev-tools test modules unrelated to this launcher isolation bug.

## Root Cause Analysis
- Current hypothesis or confirmed root cause:
	Confirmed root cause: launcher dependency injection gap in tests. `create_active_folder(...)` defaults to `default_code_launcher(...)` whenever `code_launcher` is omitted.
- Signals/evidence supporting it:
	- AST/code scan found 11 `mod.create_active_folder(...)` callsites in `test_new_active_feature_folder.py` missing `code_launcher`.
	- Flow logic in `scripts/dev_tools/new_active_feature_folder_flow.py` invokes `code_launcher(existing)` after generating/open-target resolution.
	- Default launcher in `scripts/dev_tools/new_active_feature_folder_io.py` resolves `code` and runs subprocess.
	- Instrumented run captured `code` subprocess invocations to `/workspace/docs/features/active/...` paths.
- Affected components/modules (paths, services, pipelines):
	- `tests/scripts/dev_tools/test_new_active_feature_folder.py`
	- `tests/conftest.py` (guardrail fixture scope)
	- `scripts/dev_tools/new_active_feature_folder_flow.py` (behavioral context, no production behavior change planned)
	- `scripts/dev_tools/new_active_feature_folder_io.py` (launcher behavior remains under dedicated mocked tests)

## Proposed Fix

### Design summary (what changes where):
- Primary fix: inject `code_launcher=FakeCodeLauncher()` into each currently missing `create_active_folder(...)` callsite in `test_new_active_feature_folder.py`.
- Secondary hardening: add a scoped guard fixture in `tests/conftest.py` that fails if unit tests in targeted modules attempt unmocked `code` launcher subprocess calls.
- Explicit allowance: launcher behavior tests for `default_code_launcher(...)` continue to use subprocess mocking and remain valid.

### Boundaries and invariants to preserve:
- Preserve production behavior: default launcher usage in real CLI/runtime remains unchanged.
- Preserve existing assertions for generated markdown content, issue mode markers, fallback reasons, and backward-compatible full mode behavior.
- Preserve deterministic, isolated test behavior with no external side effects.

### Dependencies or blocked work:
- No external dependency additions required.
- No known blockers from current evidence.
- Research sufficiency: provided `issue.md` and `research.md` are sufficient to draft this spec without additional Task Researcher delegation.

### Implementation strategy (what changes, not sequencing):
	
#### Files/modules to change:
- `tests/scripts/dev_tools/test_new_active_feature_folder.py`
- `tests/conftest.py`

#### Functions/classes/CLI commands impacted:
- Test callsites in these functions/scenarios:
	- `test_create_active_folder_raises_on_invalid_feature_type`
	- `test_create_active_folder_raises_on_missing_template`
	- `test_create_active_folder_raises_when_exists_without_force`
	- `test_create_active_folder_minor_audit_materializes_issue_md_and_skips_full_docs`
	- `test_work_mode_marker_minor_issue_md`
	- `scenario_single_work_mode_marker_before_first_heading`
	- `test_minor_audit_preserves_issue_frontmatter_and_spacing`
	- `test_create_active_folder_minor_audit_falls_back_to_full_when_not_eligible`
	- `test_work_mode_marker_fallback_issue_md_full`
	- `test_create_active_folder_full_mode_remains_backward_compatible`
	- `test_create_active_folder_fallback_reason_output`
- Guard fixture logic in `tests/conftest.py` (scoped to relevant module path/marker).
- No CLI command surface change.

#### Data flow and validation changes:
- Test data flow: all affected tests explicitly route launcher interactions to `FakeCodeLauncher`, preventing fallback to subprocess-based launcher.
- Guard validation: detect forbidden subprocess invocations whose executable token resolves to VS Code launcher commands (`code`, `code.cmd`, or resolved launcher path forms) from scoped unit-test contexts.
- Optional path guard may validate that attempts to access `/workspace/` or `C:\workspace\` outside fake filesystem boundaries fail fast.

#### Error handling and logging updates:
- Guard fixture should raise clear assertion failures with command/path context when forbidden side effects are attempted.
- No production logging changes required.
- Existing evidence logging (`artifacts/research/subprocess-invocations.log`) remains a verification artifact, not a runtime dependency.

#### Rollback/feature-flag considerations (if applicable):
- If guard fixture creates false positives, rollback guard scope to narrower module targeting while retaining mandatory launcher injection in tests.
- No feature flags required (test-only remediation).

### Technical specifications (interfaces/contracts):
- `create_active_folder(...)` contract usage in tests must always pass explicit `code_launcher` unless a test intentionally validates launcher behavior with subprocess mocked.
- Guard fixture contract:
	- Applied automatically for selected test modules.
	- Fails test when forbidden launcher subprocess invocation is detected.
	- Supports allowlisting launcher-integration tests that explicitly mock subprocess.

#### Inputs/outputs and formats:
- Inputs:
	- Pytest invocation: `poetry run pytest tests/scripts/dev_tools/test_new_active_feature_folder.py -q` and `poetry run pytest tests/scripts/dev_tools -q`.
	- Test function args to `create_active_folder(...)` with `code_launcher=FakeCodeLauncher()`.
- Outputs:
	- Passing tests without external editor process execution.
	- Optional assertion failure output for intentionally negative guard test.
	- Evidence logs in `artifacts/research/subprocess-invocations.log` (text lines prefixed with `run|...`).

#### Required configuration keys and defaults:
- No new configuration keys, environment variables, or CLI flags introduced.
- Existing default behavior remains: `code_launcher` defaults to `default_code_launcher(...)` when omitted in production/runtime usage.

#### Backward-compatibility expectations:
- Backward compatibility is strict for runtime behavior and CLI output.
- Test compatibility preserved for launcher-specific tests through explicit mocking.
- Existing test expectations for markdown generation and mode-marker semantics remain unchanged.

#### Performance constraints (latency/throughput/memory):
- Test runtime impact should be negligible; guard fixture adds lightweight command/path checks only.
- No expected measurable impact to production runtime performance.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
	- Developers run tests via Poetry-managed environment.
	- `tests/scripts/dev_tools/test_new_active_feature_folder.py` continues to use fake filesystem and injectable collaborators.
	- Windows host path mapping (`/workspace` to `C:\workspace`) remains possible in local setups.
- Constraints (budget, performance, compatibility):
	- Keep remediation limited to test code and fixtures.
	- No runtime dependency additions.
	- Preserve compatibility with existing CI and local pytest flows.
- External dependencies (services, libraries, releases):
	- None beyond existing test tooling (Pytest, unittest.mock/monkeypatch).

## Data / API / Config Impact
- User-facing or API changes:
	- None. This is a test-isolation fix only.
- Data or migration considerations:
	- No schema/data migrations.
	- Operational cleanup task: remove residual external artifacts under `C:\workspace\docs\features\active\*` created by prior faulty runs.
- Logging/telemetry updates (if any):
	- No production telemetry changes.
	- Research evidence log remains optional validation artifact.
- Compatibility notes (CLI flags, config schemas, versioning):
	- No CLI/config schema changes.
	- No versioned API changes.

## Test Strategy
- Regression tests to add or update:
	- Update 11 affected test callsites to pass explicit fake launcher.
	- Add one negative regression test proving guard fixture fails on intentionally unmocked launcher invocation.
	- Keep/confirm dedicated `default_code_launcher(...)` tests rely on subprocess mocking.
- Unit tests (pytest) for the fixed behavior and boundaries:
	- Targeted run: `tests/scripts/dev_tools/test_new_active_feature_folder.py` confirms no external launcher execution.
	- Module run: `tests/scripts/dev_tools` confirms no regressions in neighboring dev-tool tests.
	- Guard behavior test validates failure path and assertion message quality.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values):
	- Existing invalid input tests (`invalid feature type`, `missing template`, `exists without force`) remain green with explicit launcher injection.
	- Guard false-positive boundary: launcher integration tests with mocked subprocess remain allowed and passing.
	- Path boundary checks for `/workspace/...` and `C:\workspace\...` patterns when guard is enabled.
- Error handling and logging verification:
	- Verify guard assertion includes forbidden command/path context.
	- Verify no new production logs are introduced.
- Coverage impact and targets for changed lines/modules:
	- Maintain or improve coverage for changed test lines and fixture logic.
	- Ensure changed lines in `tests/conftest.py` and `test_new_active_feature_folder.py` are exercised by targeted runs.
- Toolchain commands to run (format → lint → type-check → test):
	- `poetry run black .`
	- `poetry run ruff check`
	- `poetry run pyright`
	- `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`
	- Additional targeted checks:
		- `poetry run pytest tests/scripts/dev_tools/test_new_active_feature_folder.py -q`
		- `poetry run pytest tests/scripts/dev_tools -q`
- Manual validation steps (if required):
	- After test run, verify no newly created files under `C:\workspace\docs\features\active\*`.
	- Compare subprocess evidence log before/after remediation to confirm no leaked `code` invocation from targeted module.

## Acceptance Criteria
- [x] Running `poetry run pytest tests/scripts/dev_tools/test_new_active_feature_folder.py -q` completes without any real `code` process launch from that module.
- [x] `tests/scripts/dev_tools/test_new_active_feature_folder.py` includes explicit `code_launcher=FakeCodeLauncher()` for all previously identified missing callsites (11 total).
- [x] A regression guard test exists and proves fail-fast behavior when an intentionally unmocked launcher invocation is attempted.
- [x] Existing launcher-specific tests for `default_code_launcher(...)` still pass with subprocess mocked.
- [x] Existing behavior assertions for markdown generation, work-mode marker handling, and fallback messaging remain unchanged and passing.
- [x] No new external artifacts are created under `C:\workspace\docs\features\active\*` after executing targeted dev-tools test runs.
- [x] Full Python toolchain pass is completed and documented (`black`, `ruff`, `pyright`, `pytest --cov ...`).
- [x] Spec and issue references for this bug (`issue.md`, `research.md`, this `spec.md`) are aligned with the final implemented behavior.

## Resolution Status Notes

- Targeted module verification evidence: `docs/features/active/2026-02-22-testing-missing-mock-injections-42/evidence/regression-testing/pytest-target-green.2026-02-22T15-25.md`
- Final QA loop summary evidence: `docs/features/active/2026-02-22-testing-missing-mock-injections-42/evidence/qa-gates/qa-loop-summary.2026-02-22T15-25.md`

## Risks & Mitigations
- Technical or operational risks:
	- Guard fixture may be overly broad and block legitimate subprocess-mocked tests.
	- Future test additions may bypass launcher injection if reviewers miss pattern.
	- Command/path matching heuristics may miss edge-case executable forms.
- Mitigations and rollbacks:
	- Scope guard by module path/marker and allow explicit exceptions for launcher-behavior tests.
	- Keep explicit coding pattern in tests (`code_launcher=FakeCodeLauncher()`) as mandatory convention.
	- Roll back only guard strictness if needed; retain injection hardening as minimum safe baseline.

## Rollout & Follow-up
- Release/rollout steps:
	- Merge test-only remediation to `main` after full toolchain pass.
	- No production release gating required because runtime behavior is unchanged.
- Post-fix monitoring or clean-up tasks:
	- Monitor subsequent dev-tools test runs for guard failures indicating regression attempts.
	- Clean residual artifacts under `C:\workspace\docs\features\active\*` from pre-fix runs.
	- Retain or archive `artifacts/research/subprocess-invocations.log` as trace evidence for this bugfix.
- Links: issue, PRs, related docs
	- Issue: `https://github.com/drmoisan/drm-copilot/issues/42`
	- Related docs:
		- `docs/features/active/2026-02-22-testing-missing-mock-injections-42/issue.md`
		- `docs/features/active/2026-02-22-testing-missing-mock-injections-42/research.md`
		- `docs/features/active/2026-02-22-testing-missing-mock-injections-42/spec.md`
