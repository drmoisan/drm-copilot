<!-- markdownlint-disable-file -->

# Task Research Notes: outside-workspace-test-side-effects

## Research Executed

### File Analysis

- `tests/scripts/dev_tools/test_new_active_feature_folder.py`
  - Contains scenarios whose output paths exactly match reported artifacts (`single-marker-40`, `full-compatible`, `no-potential`, etc.).
  - 11 test calls invoke `mod.create_active_folder(...)` **without** `code_launcher=...`.
- `scripts/dev_tools/new_active_feature_folder_flow.py`
  - `create_active_folder(...)` calls `code_launcher(existing)` after generating files.
  - Even when `fs=FakeFileSystem()`, launcher invocation still occurs if file paths are considered existing by fake FS.
- `scripts/dev_tools/new_active_feature_folder_io.py`
  - `default_code_launcher(...)` resolves `code` via `shutil.which("code")` and executes subprocess.
- `scripts/dev_tools/new_active_feature_folder_models.py`
  - Confirms `RealFileSystem` does real disk writes when used.

### Code Search Results

- `single-marker-40|single-marker`
  - Matched in `tests/scripts/dev_tools/test_new_active_feature_folder.py` where `feature_name="single-marker"` and `- Issue: #40` generate `single-marker-40`.
- AST scan: `mod.create_active_folder(...)` calls missing `code_launcher`
  - 11 matches in `test_new_active_feature_folder.py` at lines:
    - 721, 734, 866, 1028, 1064, 1101, 1153, 1201, 1239, 1260, 1277.
  - Enclosing test functions:
    - 721 → `test_create_active_folder_raises_on_invalid_feature_type`
    - 734 → `test_create_active_folder_raises_on_missing_template`
    - 866 → `test_create_active_folder_raises_when_exists_without_force`
    - 1028 → `test_create_active_folder_minor_audit_materializes_issue_md_and_skips_full_docs`
    - 1064 → `test_work_mode_marker_minor_issue_md`
    - 1101 → `scenario_single_work_mode_marker_before_first_heading`
    - 1153 → `test_minor_audit_preserves_issue_frontmatter_and_spacing`
    - 1201 → `test_create_active_folder_minor_audit_falls_back_to_full_when_not_eligible`
    - 1239 → `test_work_mode_marker_fallback_issue_md_full`
    - 1260 → `test_create_active_folder_full_mode_remains_backward_compatible`
    - 1277 → `test_create_active_folder_fallback_reason_output`
- Instrumented subprocess capture (`artifacts/research/sitecustomize.py`) during `tests/scripts/dev_tools`
  - Captured `code` invocations with `/workspace/docs/features/active/...` file arguments including:
    - `/workspace/docs/features/active/single-marker-40/issue.md`
    - `/workspace/docs/features/active/full-compatible/user-story.md`
    - `/workspace/docs/features/active/full-compatible/spec.md`
    - `/workspace/docs/features/active/full-compatible/plan.2026-02-22T12-41.md`
    - `/workspace/docs/features/active/no-potential/user-story.md`
  - Captured zero `git worktree` command attempts.

### External Research

- #githubRepo:"drmoisan/drm-copilot new_active_feature_folder launcher side effects"
  - Repository-local analysis and instrumented runs provided sufficient evidence; no external repository mining required.
- #fetch:https://example.invalid/not-used
  - No external webpage fetch required for this investigation.

### Project Conventions

- Standards referenced: repo unit-test isolation policy (no external side effects from tests).
- Instructions followed: researcher-mode constraint (changes only under `artifacts/research/`).

## Key Discoveries

### Project Structure

The user-reported files (`C:\workspace\docs\features\active\no-potential\user-story.md`, `...\full-compatible\spec.md`, `...\plan.*.md`) map directly to scenario names and issue suffixes in `test_new_active_feature_folder.py`.

### Implementation Patterns

The side effect is caused by **launcher injection gap**, not by fake filesystem omission:

- `fs=FakeFileSystem()` prevents direct disk writes from the tested create function.
- But missing `code_launcher` injection allows default launcher subprocess execution.
- Default launcher receives `/workspace/...` paths from tests and can open/create files in user environments.

### Complete Examples

```python
# new_active_feature_folder_flow.py
existing = [path for path in files_to_open if filesystem.exists(path)]
if existing:
    opened = code_launcher(existing)  # default is default_code_launcher

# new_active_feature_folder_io.py
def default_code_launcher(files: Iterable[Path]) -> bool:
    code_cmd = shutil.which("code")
    if not code_cmd:
        return False
    subprocess.run([code_cmd, *[f.as_posix() for f in files]], check=False)
    return True
```

### API and Schema Documentation

Relevant contract for `create_active_folder(...)`:

- Optional `fs` (defaults to real filesystem)
- Optional `code_launcher` (defaults to subprocess-based launcher)

### Configuration Examples

```text
Instrumented command examples captured from tests:
run|...\code.CMD /workspace/docs/features/active/full-compatible/user-story.md ...
run|...\code.CMD /workspace/docs/features/active/no-potential/user-story.md ...
```

### Technical Requirements

- Instrumented run executed:
  - `poetry run pytest tests/scripts/dev_tools -q` with startup subprocess logging enabled.
- Summary from logs:
  - `TOTAL=197` subprocess calls
  - `GIT_WORKTREE_MATCHES=0`
  - Multiple `code` invocations targeting `/workspace/docs/features/active/...`

**Mandatory unachievable objective callout**:
- **Repository-local evidence cannot prove direct `git worktree add` execution by tests in this run (no such subprocess commands were observed).**

## Recommended Approach

Treat this as an **active test isolation bug** caused by default launcher execution:

1. Update `test_new_active_feature_folder.py` so every `create_active_folder(...)` call injects `code_launcher=FakeCodeLauncher()`.
2. Keep dedicated launcher unit tests isolated with mocked subprocess behavior.
3. Add a guard fixture that fails tests on forbidden external path writes or external launcher calls.

Rejected alternatives (brief, non-exhaustive):
- “Stale artifacts only” explanation: rejected by captured launcher subprocess evidence.
- Assuming tests directly issue `git worktree` commands: rejected by instrumentation (`GIT_WORKTREE_MATCHES=0`).

## Implementation Guidance

### Spec Scope Definition (copy into spec “Problem Statement”)

- **Defect class**: unit-test isolation violation.
- **Root cause**: selected tests call `create_active_folder(...)` without `code_launcher=...`, so default `default_code_launcher(...)` may execute `subprocess.run([code, ...])`.
- **Impact**:
  - Editor-launch side effects during tests.
  - Potential creation/opening of files under host-mapped `/workspace/...` paths on Windows (`C:\workspace\...`).
  - False signals that resemble worktree churn (path overlap), though no direct `git worktree` subprocess evidence was captured.

### Functional Requirements (spec “Requirements” section)

1. **FR-1: Deterministic launcher isolation in unit tests**
   - Every `create_active_folder(...)` test in `test_new_active_feature_folder.py` must pass an explicit fake launcher except tests that directly validate launcher behavior.
2. **FR-2: Guardrail against external side effects**
   - Test suite must fail fast if any forbidden editor-launch or external `/workspace` path side effect is attempted from unit tests.
3. **FR-3: Preserve production behavior**
   - Runtime/default behavior of `create_active_folder(...)` for CLI usage must remain unchanged (still opens files when launcher exists).
4. **FR-4: Keep launcher-specific behavior testable**
   - Existing tests for `default_code_launcher(...)` continue to use subprocess mocking and remain the only place where launcher behavior is directly asserted.

### Non-Goals (spec “Out of Scope”)

- Changing product CLI behavior for end users.
- Refactoring folder generation semantics, slug logic, or minor-audit routing.
- Introducing new runtime dependencies.

### Design Decisions (spec “Technical Design”)

#### D1 — Injection hardening in tests (primary fix)

- **Change**: add `code_launcher=FakeCodeLauncher()` to all currently missing callsites in `test_new_active_feature_folder.py`.
- **Rationale**: existing test architecture already uses dependency injection (`fs`, `issue_fetcher`, `now_provider`); launcher should follow same isolation boundary.
- **Target callsites/functions**:
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

#### D2 — Suite-level side-effect guard (secondary hardening)

- **Change**: add a `tests/conftest.py` fixture that monkeypatches launcher subprocess edges for scoped test groups.
- **Guard policy**:
  - Fail on `subprocess.run` commands containing `code` when originating from isolated unit-test modules that should not invoke real launchers.
  - Optionally fail on writes/opens resolving to absolute `C:\workspace\` or `/workspace/` outside test-controlled fake FS boundaries.
- **Rationale**: prevents future regression when new tests are added without launcher injection.

#### D3 — Explicit exception for launcher integration tests

- **Change**: mark launcher-behavior tests as allowed to mock subprocess (`default_code_launcher` unit tests).
- **Rationale**: preserve coverage of launcher code path while blocking accidental real invocations.

### Spec-Ready Acceptance Criteria

1. **AC-1 (Isolation):** Running `poetry run pytest tests/scripts/dev_tools/test_new_active_feature_folder.py -q` does not trigger any real `code` process launch.
2. **AC-2 (Regression guard):** New side-effect guard fixture fails on intentionally injected unmocked launcher call (prove fail-before).
3. **AC-3 (Compatibility):** Existing launcher unit tests still pass with subprocess mocked.
4. **AC-4 (No behavior drift):** Existing expectations for generated docs and work-mode markers remain unchanged.
5. **AC-5 (Evidence):** Post-fix evidence demonstrates no external `/workspace` artifact creation from the target test module.

### Test Plan Matrix (spec “Verification Strategy”)

- **T1 — Targeted unit regression**
  - File: `tests/scripts/dev_tools/test_new_active_feature_folder.py`
  - Goal: ensure no launcher side effects after injection hardening.
- **T2 — Guard fixture negative test**
  - Add a controlled test that intentionally attempts unmocked launcher invocation and asserts guard failure.
- **T3 — Launcher behavior tests**
  - Validate `default_code_launcher` tests still use `mock.patch("subprocess.run")` and pass.
- **T4 — Suite smoke**
  - Run `tests/scripts/dev_tools -q` and verify no side-effect guard failures.

### Implementation Sequence (spec “Execution Plan”)

1. Patch 11 missing callsites in `test_new_active_feature_folder.py` with `code_launcher=FakeCodeLauncher()`.
2. Add side-effect guard fixture in `tests/conftest.py` (scoped to relevant test paths).
3. Add one explicit negative regression test for guard behavior.
4. Run targeted tests, then broader dev-tools tests.
5. Capture evidence artifact showing no launcher subprocess leakage.

### Risk Register (spec “Risks & Mitigations”)

- **Risk R1**: guard fixture is too broad and blocks legitimate subprocess mocks.
  - **Mitigation**: scope by module path/marker; allow mocked launcher tests explicitly.
- **Risk R2**: hidden dependency on default launcher behavior in existing tests.
  - **Mitigation**: keep injection as test-local change; do not alter production defaults.
- **Risk R3**: false positives from path-string heuristics.
  - **Mitigation**: match command executable tokenization rather than substring-only checks when possible.

### Rollback Plan (spec “Rollback”)

- If guard fixture causes instability, temporarily disable guard by marker and retain D1 injection hardening (minimum safe fix).
- Re-enable guard incrementally per module after narrowing allowlist.

### Operational Cleanup Guidance

- Remove residual external artifacts manually under `C:\workspace\docs\features\active\*` produced by earlier test runs.
- Preserve `artifacts/research/subprocess-invocations.log` as investigation evidence until remediation merges.

### Success Criteria

- No unmocked `code` subprocess invocation from `test_new_active_feature_folder.py`.
- Dev-tools unit tests remain green.
- Guard fixture blocks future accidental launcher regressions.
- No new external `C:\workspace` test artifacts after remediation run.