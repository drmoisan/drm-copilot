# 2026-04-25-canonical-evidence-locations-non-overridable - Plan

- **Issue:** #158
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-04-25T14-37
- **Status:** Draft
- **Version:** 0.1

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- Python Coding Standards: [`.github/instructions/python-code-change.instructions.md`](../../../../.github/instructions/python-code-change.instructions.md)
- Python Unit Test Policy: [`.github/instructions/python-unit-test.instructions.md`](../../../../.github/instructions/python-unit-test.instructions.md)
- PowerShell Coding Standards: [`.github/instructions/powershell-code-change.instructions.md`](../../../../.github/instructions/powershell-code-change.instructions.md)
- PowerShell Unit Test Policy: [`.github/instructions/powershell-unit-test.instructions.md`](../../../../.github/instructions/powershell-unit-test.instructions.md)

**All work must comply with these policies; do not duplicate their content here.**

## Feature Folder

`FEATURE = docs/features/active/2026-04-25-canonical-evidence-locations-non-overridable-158`

## Implementation Plan (Atomic Tasks)

### Phase 0 — Policy Compliance & Baseline Capture

- [x] [P0-T1] Read all required policy files in order (`.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`, `.github/instructions/python-suppressions.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`) and save the policy-read evidence artifact to `FEATURE/evidence/baseline/phase0-policy-read.md`
  - Acceptance: `FEATURE/evidence/baseline/phase0-policy-read.md` exists and contains the fields `Timestamp:`, `Policy Order:`, and an explicit list of all files read.

- [x] [P0-T2] Capture Python Black baseline by running `poetry run black --check .` and saving the result to `FEATURE/evidence/baseline/python-black-baseline.md`
  - Acceptance: artifact exists; contains `Timestamp:`, `Command: poetry run black --check .`, `EXIT_CODE:`, `Output Summary:`.

- [x] [P0-T3] Capture Python Ruff baseline by running `poetry run ruff check .` and saving to `FEATURE/evidence/baseline/python-ruff-baseline.md`
  - Acceptance: artifact exists; contains `Timestamp:`, `Command: poetry run ruff check .`, `EXIT_CODE:`, `Output Summary:`.

- [x] [P0-T4] Capture Python Pyright baseline by running `poetry run pyright` and saving to `FEATURE/evidence/baseline/python-pyright-baseline.md`
  - Acceptance: artifact exists; contains `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE:`, `Output Summary:`.

- [x] [P0-T5] Capture Python pytest baseline with coverage by running `poetry run pytest --cov --cov-report=term-missing` and saving to `FEATURE/evidence/baseline/python-pytest-baseline.md`
  - Acceptance: artifact exists; contains `Timestamp:`, `Command: poetry run pytest --cov --cov-report=term-missing`, `EXIT_CODE:`, `Output Summary:` including a numeric coverage headline percentage (e.g., `TOTAL ... 82%`).

- [x] [P0-T6] Capture PowerShell PoshQC format baseline via MCP tool `mcp__drmCopilotExtension__run_poshqc_format` and save to `FEATURE/evidence/baseline/powershell-format-baseline.md`
  - Acceptance: artifact exists; contains `Timestamp:`, `Command: mcp__drmCopilotExtension__run_poshqc_format`, `EXIT_CODE:`, `Output Summary:`.

- [x] [P0-T7] Capture PowerShell PoshQC analyze baseline via MCP tool `mcp__drmCopilotExtension__run_poshqc_analyze` and save to `FEATURE/evidence/baseline/powershell-analyze-baseline.md`
  - Acceptance: artifact exists; contains `Timestamp:`, `Command: mcp__drmCopilotExtension__run_poshqc_analyze`, `EXIT_CODE:`, `Output Summary:`.

- [x] [P0-T8] Capture PowerShell PoshQC Pester test baseline via MCP tool `mcp_drmcopilotext_run_poshqc_test` and save to `FEATURE/evidence/baseline/powershell-test-baseline.md`
  - Acceptance: artifact exists; contains `Timestamp:`, `Command: mcp_drmcopilotext_run_poshqc_test`, `EXIT_CODE:`, `Output Summary:`.

### Phase 1 — Part A: Skill File Reconciliation (9 files)

- [x] [P1-T1] Update `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` by inserting a `## Non-Overridable Authority` section that names all 6 canonical evidence sub-paths (`baseline/`, `regression-testing/`, `qa-gates/`, `issue-updates/`, `other/`, `remediation-baseline/`) and declares explicitly that no delegation prompt, plan, or upstream agent may override the `<FEATURE>/evidence/<kind>/` location
  - Acceptance: `Select-String "## Non-Overridable Authority" .claude/skills/evidence-and-timestamp-conventions/SKILL.md` returns exactly one match.

- [x] [P1-T2] Update `.claude/skills/python-qa-gate/SKILL.md` by replacing all occurrences of `artifacts/evidence/baseline/<timestamp>/` with `<FEATURE>/evidence/baseline/` and `artifacts/evidence/post-change/<timestamp>/` with `<FEATURE>/evidence/qa-gates/`, then appending the canonical-authority pointer line `This location is canonical per evidence-and-timestamp-conventions and is not overridable.` to each corrected section
  - Acceptance: `Select-String "artifacts/evidence/" .claude/skills/python-qa-gate/SKILL.md` returns zero matches; `Select-String "canonical per evidence-and-timestamp-conventions" .claude/skills/python-qa-gate/SKILL.md` returns at least one match.

- [x] [P1-T3] Update `.claude/skills/csharp-qa-gate/SKILL.md` with the same path replacements and canonical-authority pointer line as P1-T2
  - Acceptance: `Select-String "artifacts/evidence/" .claude/skills/csharp-qa-gate/SKILL.md` returns zero matches; canonical-authority pointer line present.

- [x] [P1-T4] Update `.claude/skills/powershell-qa-gate/SKILL.md` with the same path replacements and canonical-authority pointer line as P1-T2
  - Acceptance: `Select-String "artifacts/evidence/" .claude/skills/powershell-qa-gate/SKILL.md` returns zero matches; canonical-authority pointer line present.

- [x] [P1-T5] Update `.claude/skills/invoke-python-engineer/SKILL.md` Output Paths section by replacing `artifacts/evidence/baseline/<timestamp>/` with `<FEATURE>/evidence/baseline/` and `artifacts/evidence/post-change/<timestamp>/` with `<FEATURE>/evidence/qa-gates/`; append canonical-authority pointer line to the corrected section
  - Acceptance: `Select-String "artifacts/evidence/" .claude/skills/invoke-python-engineer/SKILL.md` returns zero matches; canonical-authority pointer line present.

- [x] [P1-T6] Update `.claude/skills/invoke-csharp-engineer/SKILL.md` Output Paths section with the same replacements and canonical-authority pointer line as P1-T5
  - Acceptance: `Select-String "artifacts/evidence/" .claude/skills/invoke-csharp-engineer/SKILL.md` returns zero matches; canonical-authority pointer line present.

- [x] [P1-T7] Update `.claude/skills/invoke-powershell-engineer/SKILL.md` Output Paths section with the same replacements and canonical-authority pointer line as P1-T5
  - Acceptance: `Select-String "artifacts/evidence/" .claude/skills/invoke-powershell-engineer/SKILL.md` returns zero matches; canonical-authority pointer line present.

- [x] [P1-T8] Update `.claude/skills/orchestrate/SKILL.md` by inserting a `## Evidence Location Authority` section after the `## Delegation Model` section; the section must contain the explicit allow-list of permitted `artifacts/`-rooted sub-paths (`artifacts/orchestration/`, `artifacts/research/`, `artifacts/pr_context`, `artifacts/reviews/`, `artifacts/status/`, `artifacts/python/`, `artifacts/pester/`, `artifacts/csharp/`) and state that all other `artifacts/` sub-paths are forbidden for evidence output
  - Acceptance: `Select-String "## Evidence Location Authority" .claude/skills/orchestrate/SKILL.md` returns exactly one match; `Select-String "artifacts/orchestration/" .claude/skills/orchestrate/SKILL.md` returns at least one match within the new section.

- [x] [P1-T9] Update `.claude/skills/atomic-plan-contract/SKILL.md` by inserting a non-overridable evidence-path clause stating that no plan task may specify a non-canonical evidence path and that if a delegation prompt supplies a non-canonical path the planner must reject it and substitute the canonical `<FEATURE>/evidence/<kind>/` path before the plan is approved
  - Acceptance: `Select-String "non-canonical evidence path" .claude/skills/atomic-plan-contract/SKILL.md` returns at least one match.

### Phase 2 — Part B: Agent Evidence Location Invariants (12 files)

Each agent file receives a `## Evidence Location Invariant` section containing: if a delegation prompt, plan, or caller instruction specifies a non-canonical evidence path (e.g., `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`), the agent ignores that instruction, writes to the canonical `<FEATURE>/evidence/<kind>/` path, and records the override as `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <supplied path> replaced with <canonical path>`.

- [x] [P2-T1] Add `## Evidence Location Invariant` section to `.claude/agents/atomic-planner.md`
  - Acceptance: `Select-String "## Evidence Location Invariant" .claude/agents/atomic-planner.md` returns exactly one match.

- [x] [P2-T2] Add `## Evidence Location Invariant` section to `.claude/agents/atomic-executor.md`
  - Acceptance: `Select-String "## Evidence Location Invariant" .claude/agents/atomic-executor.md` returns exactly one match.

- [x] [P2-T3] Add `## Evidence Location Invariant` section to `.claude/agents/python-typed-engineer.md`
  - Acceptance: `Select-String "## Evidence Location Invariant" .claude/agents/python-typed-engineer.md` returns exactly one match.

- [x] [P2-T4] Add `## Evidence Location Invariant` section to `.claude/agents/csharp-typed-engineer.md`
  - Acceptance: `Select-String "## Evidence Location Invariant" .claude/agents/csharp-typed-engineer.md` returns exactly one match.

- [x] [P2-T5] Add `## Evidence Location Invariant` section to `.claude/agents/powershell-typed-engineer.md`
  - Acceptance: `Select-String "## Evidence Location Invariant" .claude/agents/powershell-typed-engineer.md` returns exactly one match.

- [x] [P2-T6] Add `## Evidence Location Invariant` section to `.claude/agents/typescript-engineer.md`
  - Acceptance: `Select-String "## Evidence Location Invariant" .claude/agents/typescript-engineer.md` returns exactly one match.

- [x] [P2-T7] Add `## Evidence Location Invariant` section to `.claude/agents/task-researcher.md`
  - Acceptance: `Select-String "## Evidence Location Invariant" .claude/agents/task-researcher.md` returns exactly one match.

- [x] [P2-T8] Add `## Evidence Location Invariant` section to `.claude/agents/prd-feature.md`
  - Acceptance: `Select-String "## Evidence Location Invariant" .claude/agents/prd-feature.md` returns exactly one match.

- [x] [P2-T9] Add `## Evidence Location Invariant` section to `.claude/agents/staged-review.md`
  - Acceptance: `Select-String "## Evidence Location Invariant" .claude/agents/staged-review.md` returns exactly one match.

- [x] [P2-T10] Add `## Evidence Location Invariant` section to `.claude/agents/epic-review.md`
  - Acceptance: `Select-String "## Evidence Location Invariant" .claude/agents/epic-review.md` returns exactly one match.

- [x] [P2-T11] Add `## Evidence Location Invariant` section to `.claude/agents/status-updater.md`
  - Acceptance: `Select-String "## Evidence Location Invariant" .claude/agents/status-updater.md` returns exactly one match.

- [x] [P2-T12] Add `## Evidence Location Invariant` section AND the diff-scan FAIL-finding instruction to `.claude/agents/feature-review.md`; the diff-scan instruction must state that during the policy-audit phase the agent scans the branch diff for any files written under forbidden `artifacts/` sub-paths and records a FAIL finding under the heading `## Evidence Location Compliance` in the policy-audit artifact if any are found, listing each file path and its canonical replacement
  - Acceptance: `Select-String "## Evidence Location Invariant" .claude/agents/feature-review.md` returns exactly one match; `Select-String "Evidence Location Compliance" .claude/agents/feature-review.md` returns at least one match.

### Phase 3 — Part C: PreToolUse Hook + Settings Update (PowerShell)

- [x] [P3-T1] Create `.claude/hooks/enforce-evidence-locations.ps1` following the `check-python-test-purity.ps1` structural pattern: `[CmdletBinding()]` param block, pure helper functions `Test-EvidenceLocationForbidden`, `Get-EvidenceLocationBlockDecision`, `Invoke-EvidenceLocationDecision`, and an entrypoint block that reads `$env:CLAUDE_TOOL_INPUT`, parses the `file_path` field, returns `{"decision":"block","reason":"EVIDENCE_LOCATION_BLOCKED: <path> is not a canonical evidence location. Use <FEATURE>/evidence/<kind>/ instead."}` to stdout for forbidden paths or `{"decision":"allow"}` for allowed paths, exits 0 for both decisions, and exits 1 on hard failure (malformed or missing JSON input)
  - Forbidden prefixes: `artifacts/baselines/`, `artifacts/baseline/`, `artifacts/qa/`, `artifacts/qa-gates/`, `artifacts/coverage/`, `artifacts/evidence/`, `artifacts/regression-testing/`, `artifacts/post-change/`
  - Allowed `artifacts/` prefixes: `artifacts/orchestration/`, `artifacts/research/`, `artifacts/pr_context`, `artifacts/reviews/`, `artifacts/status/`, `artifacts/python/`, `artifacts/pester/`, `artifacts/csharp/`
  - Acceptance: `.claude/hooks/enforce-evidence-locations.ps1` exists; `Select-String "\[CmdletBinding\(\)\]" .claude/hooks/enforce-evidence-locations.ps1` returns a match; `Select-String "Test-EvidenceLocationForbidden" .claude/hooks/enforce-evidence-locations.ps1` returns a match; `Select-String "Get-EvidenceLocationBlockDecision" .claude/hooks/enforce-evidence-locations.ps1` returns a match.

- [x] [P3-T2] Create `tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1` with a `Describe 'enforce-evidence-locations.ps1'` block containing test case 1: dot-source the hook, set `$env:CLAUDE_TOOL_INPUT = '{"file_path":"artifacts/baselines/foo.md"}'`, invoke the hook entrypoint, parse stdout JSON, assert `decision -eq "block"` and `reason` contains `EVIDENCE_LOCATION_BLOCKED`
  - Acceptance: test file exists; `Select-String "artifacts/baselines/foo.md" tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1` returns a match.

- [x] [P3-T3] Add test case 2 to `tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1`: set `$env:CLAUDE_TOOL_INPUT = '{"file_path":"artifacts/orchestration/orchestrator-state.json"}'`, invoke hook, assert `decision -eq "allow"`
  - Acceptance: `Select-String "artifacts/orchestration/orchestrator-state.json" tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1` returns a match.

- [x] [P3-T4] Add test case 3 to `tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1`: set `$env:CLAUDE_TOOL_INPUT = '{"file_path":"artifacts/research/notes.md"}'`, invoke hook, assert `decision -eq "allow"`
  - Acceptance: `Select-String "artifacts/research/notes.md" tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1` returns a match.

- [x] [P3-T5] Add test case 4 to `tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1`: set `$env:CLAUDE_TOOL_INPUT = '{"file_path":"docs/features/active/my-feature/evidence/baseline/baseline.md"}'`, invoke hook, assert `decision -eq "allow"`
  - Acceptance: `Select-String "evidence/baseline/baseline.md" tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1` returns a match.

- [x] [P3-T6] Add test case 5 to `tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1`: set `$env:CLAUDE_TOOL_INPUT = '{"file_path":"src/hello-typescript.ts"}'`, invoke hook, assert `decision -eq "allow"`
  - Acceptance: `Select-String "hello-typescript.ts" tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1` returns a match.

- [x] [P3-T7] Update `.claude/settings.json` to append `{"type":"command","command":"pwsh -NoProfile -File .claude/hooks/enforce-evidence-locations.ps1"}` to the `PreToolUse` `Write|Edit` hooks array
  - Acceptance: `Select-String "enforce-evidence-locations.ps1" .claude/settings.json` returns exactly one match; `Get-Content .claude/settings.json | ConvertFrom-Json` completes without error (valid JSON).

- [x] [P3-T8] Run PoshQC format via MCP tool `mcp__drmCopilotExtension__run_poshqc_format` scoped to `.claude/hooks/` and `tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1`; apply any formatting changes; save result to `FEATURE/evidence/other/powershell-hook-format.md`
  - Acceptance: artifact exists with `Timestamp:`, `Command: mcp__drmCopilotExtension__run_poshqc_format`, `EXIT_CODE: 0`, `Output Summary:`; if format changed any file, the change was applied.

- [x] [P3-T9] Run PoshQC analyze via MCP tool `mcp__drmCopilotExtension__run_poshqc_analyze` scoped to `.claude/hooks/enforce-evidence-locations.ps1` and the test file; fix all reported findings; save result to `FEATURE/evidence/other/powershell-hook-analyze.md`
  - Acceptance: artifact exists with `EXIT_CODE: 0`; `Output Summary:` states zero findings or lists findings that were resolved.

- [x] [P3-T10] Run PoshQC Pester tests via MCP tool `mcp_drmcopilotext_run_poshqc_test`; verify all 5 `It` blocks in `enforce-evidence-locations.Tests.ps1` pass; save result to `FEATURE/evidence/other/powershell-hook-test.md`
  - Acceptance: artifact exists with `EXIT_CODE: 0`; `Output Summary:` states all 5 new test cases passed.

### Phase 4 — Part D: Python Validator + pytest

- [x] [P4-T1] Create `scripts/dev_tools/validate_evidence_locations.py` following the `validate_orchestration_artifacts.py` pattern with: an `argparse` CLI accepting `--root <path>` (optional, defaulting to `Path(__file__).resolve().parents[2]`); a fully type-annotated pure generator `find_forbidden_paths(root: Path) -> Iterator[tuple[Path, str]]` that walks the tree and yields `(forbidden_path, canonical_suggestion)` for every file under a forbidden prefix (`artifacts/baselines/`, `artifacts/baseline/`, `artifacts/qa/`, `artifacts/qa-gates/`, `artifacts/coverage/`, `artifacts/evidence/`, `artifacts/regression-testing/`, `artifacts/post-change/`); and a `main()` function that collects results, prints `VIOLATION: <path> — use <canonical_suggestion> instead` per violation, and exits with code 1 if any violations are found or code 0 if clean; uses Python standard library only
  - Acceptance: `scripts/dev_tools/validate_evidence_locations.py` exists; `Select-String "def find_forbidden_paths" scripts/dev_tools/validate_evidence_locations.py` returns one match; `Select-String "def main" scripts/dev_tools/validate_evidence_locations.py` returns one match.

- [x] [P4-T2] Create `tests/scripts/dev_tools/test_validate_evidence_locations.py` with pytest test case `test_clean_tree_exits_zero`: call `find_forbidden_paths` on a directory path that contains no files under any forbidden prefix (e.g., the `docs/` directory or a hand-built `pathlib.Path` structure in memory via `monkeypatch`); assert the generator yields no results; assert no `tempfile` or `TemporaryDirectory` usage
  - Preconditions: P4-T1 complete (module importable).
  - Acceptance: `Select-String "test_clean_tree_exits_zero" tests/scripts/dev_tools/test_validate_evidence_locations.py` returns one match; `Select-String "tempfile\|TemporaryDirectory" tests/scripts/dev_tools/test_validate_evidence_locations.py` returns zero matches.

- [x] [P4-T3] Add pytest test case `test_seeded_violation_exits_one` to `tests/scripts/dev_tools/test_validate_evidence_locations.py`: use `monkeypatch` or a controlled `Path` mock to present a tree containing the path `artifacts/baselines/seeded.md`; call `find_forbidden_paths` on that root; assert exactly one result is yielded with the canonical suggestion containing `evidence/baseline/`; assert no `tempfile` usage
  - Preconditions: P4-T2 complete (test file exists).
  - Acceptance: `Select-String "test_seeded_violation_exits_one" tests/scripts/dev_tools/test_validate_evidence_locations.py` returns one match; `Select-String "artifacts/baselines/seeded.md" tests/scripts/dev_tools/test_validate_evidence_locations.py` returns at least one match.

- [x] [P4-T4] Update `.claude/agents/feature-review.md` to add a reference to `validate_evidence_locations.py` as a required policy-audit step; the instruction must state that the feature-review agent invokes `poetry run python scripts/dev_tools/validate_evidence_locations.py` and records its exit code and output in the policy-audit artifact
  - Preconditions: P4-T1 complete (script exists).
  - Acceptance: `Select-String "validate_evidence_locations" .claude/agents/feature-review.md` returns at least one match.

- [x] [P4-T5] Run Python Black formatter `poetry run black scripts/dev_tools/validate_evidence_locations.py tests/scripts/dev_tools/test_validate_evidence_locations.py`; apply any formatting changes
  - Acceptance: `poetry run black --check scripts/dev_tools/validate_evidence_locations.py tests/scripts/dev_tools/test_validate_evidence_locations.py` exits with code 0.

- [x] [P4-T6] Run Ruff linter `poetry run ruff check scripts/dev_tools/validate_evidence_locations.py tests/scripts/dev_tools/test_validate_evidence_locations.py`; fix all reported errors
  - Acceptance: `poetry run ruff check scripts/dev_tools/validate_evidence_locations.py tests/scripts/dev_tools/test_validate_evidence_locations.py` exits with code 0.

- [x] [P4-T7] Run Pyright type checker `poetry run pyright scripts/dev_tools/validate_evidence_locations.py` and fix all reported type errors
  - Acceptance: `poetry run pyright scripts/dev_tools/validate_evidence_locations.py` exits with code 0; zero Pyright errors reported.

- [x] [P4-T8] Run pytest `poetry run pytest tests/scripts/dev_tools/test_validate_evidence_locations.py -v` and verify both test cases pass
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_validate_evidence_locations.py -v` exits with code 0; output contains `2 passed`.

### Phase 5 — Final QA: Both Toolchains + Hook Demonstration

- [x] [P5-T1] Run PoshQC format (full project) via MCP tool `mcp__drmCopilotExtension__run_poshqc_format`; apply any formatting changes; save result to `FEATURE/evidence/qa-gates/powershell-format-final.md`
  - Acceptance: artifact exists with `Timestamp:`, `Command: mcp__drmCopilotExtension__run_poshqc_format`, `EXIT_CODE: 0`, `Output Summary:`.

- [x] [P5-T2] Run PoshQC analyze (full project) via MCP tool `mcp__drmCopilotExtension__run_poshqc_analyze`; fix any new findings; save result to `FEATURE/evidence/qa-gates/powershell-analyze-final.md`
  - Acceptance: artifact exists with `EXIT_CODE: 0`; `Output Summary:` confirms zero unfixed findings.

- [x] [P5-T3] Run PoshQC Pester tests (full project) via MCP tool `mcp_drmcopilotext_run_poshqc_test`; save result to `FEATURE/evidence/qa-gates/powershell-test-final.md`
  - Acceptance: artifact exists with `EXIT_CODE: 0`; `Output Summary:` reports all Pester tests passed, including the 5 new cases in `enforce-evidence-locations.Tests.ps1`.

- [x] [P5-T4] Run Python Black (full project) `poetry run black --check .`; if any files need formatting, apply with `poetry run black .` and re-run check; save result to `FEATURE/evidence/qa-gates/python-black-final.md`
  - Acceptance: artifact exists; final `poetry run black --check .` exits with code 0; `EXIT_CODE: 0` recorded in artifact.

- [x] [P5-T5] Run Python Ruff (full project) `poetry run ruff check .`; fix all errors; save result to `FEATURE/evidence/qa-gates/python-ruff-final.md`
  - Acceptance: artifact exists; `poetry run ruff check .` exits with code 0; `EXIT_CODE: 0` recorded.

- [x] [P5-T6] Run Python Pyright (full project) `poetry run pyright`; fix all type errors; save result to `FEATURE/evidence/qa-gates/python-pyright-final.md`
  - Acceptance: artifact exists; `poetry run pyright` exits with code 0; `EXIT_CODE: 0` recorded.

- [x] [P5-T7] Run Python pytest with coverage (full project) `poetry run pytest --cov --cov-report=term-missing`; save result to `FEATURE/evidence/qa-gates/python-pytest-final.md`
  - Acceptance: artifact exists; `poetry run pytest --cov` exits with code 0; `Output Summary:` includes the numeric final coverage percentage; `EXIT_CODE: 0` recorded.

- [x] [P5-T8] Verify coverage delta by comparing the numeric baseline coverage from `FEATURE/evidence/baseline/python-pytest-baseline.md` against the numeric final coverage from `FEATURE/evidence/qa-gates/python-pytest-final.md`; document the comparison in `FEATURE/evidence/qa-gates/python-coverage-delta.md`
  - Acceptance: `FEATURE/evidence/qa-gates/python-coverage-delta.md` exists and contains `Baseline Coverage:`, `Final Coverage:`, and `New Code Coverage (validate_evidence_locations.py):` fields with numeric percentage values; final coverage is ≥ baseline coverage (no regression); new-code coverage for `validate_evidence_locations.py` is ≥ 90%.

- [x] [P5-T9] Demonstrate hook blocking: invoke `.claude/hooks/enforce-evidence-locations.ps1` directly via `pwsh -NoProfile -Command` with `$env:CLAUDE_TOOL_INPUT` set to `'{"file_path":"artifacts/baselines/test.md"}'`; capture stdout JSON; save output and command to `FEATURE/evidence/qa-gates/hook-block-demonstration.md`
  - Acceptance: `FEATURE/evidence/qa-gates/hook-block-demonstration.md` exists; the recorded stdout JSON contains `"decision":"block"` and `"reason"` containing `EVIDENCE_LOCATION_BLOCKED: artifacts/baselines/test.md`; `EXIT_CODE: 0` recorded in the artifact.

## Coverage Evidence Summary

| Language   | Baseline Artifact                                          | Final Artifact                                               | Delta Artifact                                           |
|------------|------------------------------------------------------------|--------------------------------------------------------------|----------------------------------------------------------|
| Python     | `FEATURE/evidence/baseline/python-pytest-baseline.md`      | `FEATURE/evidence/qa-gates/python-pytest-final.md`           | `FEATURE/evidence/qa-gates/python-coverage-delta.md`     |
| PowerShell | `FEATURE/evidence/baseline/powershell-test-baseline.md`    | `FEATURE/evidence/qa-gates/powershell-test-final.md`         | N/A (no mandatory numeric threshold for PowerShell)      |

## Acceptance Criteria Traceability

| AC (from issue.md)                                                                                         | Delivering Tasks        |
|------------------------------------------------------------------------------------------------------------|-------------------------|
| `evidence-and-timestamp-conventions/SKILL.md` contains `## Non-Overridable Authority`                     | P1-T1                   |
| All QA-gate skills name canonical paths + carry pointer line                                               | P1-T2, P1-T3, P1-T4     |
| All invoke-engineer skills name canonical paths + carry pointer line                                       | P1-T5, P1-T6, P1-T7     |
| `orchestrate/SKILL.md` contains `## Evidence Location Authority` with allow-list                           | P1-T8                   |
| `atomic-plan-contract/SKILL.md` contains non-overridable plan-task clause                                 | P1-T9                   |
| All 12 agent files contain `## Evidence Location Invariant`                                               | P2-T1 – P2-T12          |
| `feature-review.md` contains diff-scan FAIL-finding requirement                                           | P2-T12                  |
| PreToolUse hook registered, runs on Write/Edit, blocks forbidden patterns, allows exceptions               | P3-T1, P3-T7            |
| Hook self-test passes all 5 cases                                                                          | P3-T2 – P3-T6, P3-T10  |
| Standalone validator exists, exits non-zero on seeded violation, referenced in feature-review              | P4-T1, P4-T2, P4-T3, P4-T4 |
| Demonstration: `artifacts/baselines/test.md` write is blocked at tool layer                               | P5-T9                   |
| All four toolchain steps pass after changes                                                                | P5-T1 – P5-T8           |

## Open Questions / Notes

- ...
