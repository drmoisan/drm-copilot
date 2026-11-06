# execution-env-test-worktree-filter (Plan)

- **Issue:** #1019
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-06T12-41
- **Status:** Draft
- **Version:** 0.1
- **Work Mode:** minor-audit

**Fail-closed evidence rule:** If any required baseline artifact or final-QA artifact is missing, the audit verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Each evidence-producing task records its artifact path. Do not mark evidence-backed work complete without the artifact.

**Requirements source:** `docs/features/active/2026-11-06-execution-env-test-worktree-filter-1019/issue.md`, section `## Acceptance Criteria` only (AC1 to AC4). `<FEATURE>` below means `docs/features/active/2026-11-06-execution-env-test-worktree-filter-1019`.

**Environment constraints:** Tool routes and launchers follow the `execution-environment` skill. `poetry env info -p` resolves to the shared main-checkout `.venv`; `poetry install` is never run. `poetry run` of the listed tools is permitted. `SCRATCH` is `<session scratchpad>/issue-1019/`.

**Coverage contract:** Not applicable. No production file changes and no coverage task exists; the change edits one line of one existing test.

## Pre-Mortem

- Review checklists: the self-review task in Phase 2 walks the policy-audit, code-review, and feature-audit templates against the branch diff from the merge base of `origin/main` and `HEAD`; a FAIL row is fixed before the QA loop is re-run.
- Coverage: not applicable. No production file changes and no coverage task exists; the diff touches one test line.
- Mirror parity: not applicable. No fact in the execution-environment brief changes and no mirrored or bundled file is edited, so no brief-update task is needed.
- File size: not applicable. The edit is one line inside an existing test file and does not change the file's size tier.
- Test isolation: the changed module is run in reversed order in one Python process in [P2-T5] and recorded under `<FEATURE>/evidence/regression-testing/`. No Jest or Pester suite is touched, so no shuffled Jest run and no Pester file-order run applies.
- CI-only behavior: the fixed test now depends only on repository-relative parts, so it behaves the same in a CI checkout and in a checkout under a `worktrees` directory. No gitignored `artifacts/` state, drive-letter fixture, or depth-one checkout dependency is introduced.
- Evidence: every command task writes one artifact with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, named `<name>.<timestamp>.md` with the write-time UTC stamp, under `<FEATURE>/evidence/<kind>/`.

### Phase 0 — Baseline Capture

- [ ] [P0-T1] Read the policy files in the order of `policy-compliance-order` (`CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`) and write `<FEATURE>/evidence/baseline/phase0-instructions-read.<timestamp>.md` with `Timestamp:`, `Policy Order:`, and the list of files read. Acceptance: the artifact exists with all three fields.
- [ ] [P0-T2] Run Black in check mode on `tests/scripts/dev_tools/test_discovery_documentation_contracts.py` through `poetry run black --check` and write `<FEATURE>/evidence/baseline/baseline-black.<timestamp>.md`. Acceptance: the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`, and the summary states the unchanged-files line Black prints on a clean run.
- [ ] [P0-T3] Run `poetry run ruff check` on the same file and write `<FEATURE>/evidence/baseline/baseline-ruff.<timestamp>.md`. Acceptance: the artifact carries the four fields and the summary states the `All checks passed!` line Ruff prints on a clean run (no `--fix` is passed, so Ruff rewrites nothing).
- [ ] [P0-T4] Run `poetry run pyright` on the same file and write `<FEATURE>/evidence/baseline/baseline-pyright.<timestamp>.md`. Acceptance: the artifact carries the four fields and the summary states the error count Pyright prints.
- [ ] [P0-T5] Write `<FEATURE>/evidence/baseline/baseline-pytest.<timestamp>.md` for the node `tests/scripts/dev_tools/test_discovery_documentation_contracts.py::test_execution_environment_fact_is_unchanged_across_copies`. The artifact consumes the committed `<FEATURE>/evidence/regression-testing/fail-before.2026-11-06T17-42.md` (EXIT_CODE 1, `assert 0 == 6`) instead of re-running the node, and records its `Command:`, `EXIT_CODE:`, and `Output Summary:` values. Acceptance: the artifact carries the four fields, `EXIT_CODE: 1`, and names the source artifact. This satisfies the fail-before requirement of AC3.

### Phase 1 — Implementation

- [ ] [P1-T1] In `tests/scripts/dev_tools/test_discovery_documentation_contracts.py`, change the exclusion line inside `test_execution_environment_fact_is_unchanged_across_copies` so the set `{"node_modules", ".git", "packages", "worktrees"}` is intersected with `set(path.relative_to(REPO_ROOT).parts)` instead of `set(path.parts)`. The assertion `len(copies) == 6`, its message, the byte-equality loop, and the four excluded names stay unchanged; no production file, new Python file, or other test is edited. No other test asserts this test's behavior, because the change is internal to one test function. Before: an ancestor of the repository root named `worktrees` matched the exclusion and removed all six copies (`0 == 6`). After: only components below `REPO_ROOT` are examined, so a checkout under a `worktrees` directory finds six copies, while a nested agent worktree at `.claude/worktrees/<name>/...` has `worktrees` as a relative part and stays excluded. Acceptance: the node `tests/scripts/dev_tools/test_discovery_documentation_contracts.py::test_execution_environment_fact_is_unchanged_across_copies` passes when run from this checkout, which sits under a `worktrees` directory, and the diff from the merge base of `origin/main` and `HEAD` for that file is confined to the exclusion condition of that generator expression (one changed line, or a few lines if Black wraps the longer condition).

### Phase 2 — Final QC

- [ ] [P2-T1] Run `poetry run black --check` on `tests/scripts/dev_tools/test_discovery_documentation_contracts.py` and write `<FEATURE>/evidence/qa-gates/qc-black.<timestamp>.md`. Acceptance: the four fields are present, `EXIT_CODE: 0`, and the summary records the unchanged-files line Black prints on a clean run.
- [ ] [P2-T2] Run `poetry run ruff check` on the same file and write `<FEATURE>/evidence/qa-gates/qc-ruff.<timestamp>.md`. Acceptance: the four fields are present, `EXIT_CODE: 0`, and the summary records the `All checks passed!` line Ruff prints on a clean run (no `--fix` is passed, so Ruff rewrites nothing).
- [ ] [P2-T3] Run `poetry run pyright` on the same file and write `<FEATURE>/evidence/qa-gates/qc-pyright.<timestamp>.md`. Acceptance: the four fields are present, `EXIT_CODE: 0`, and the summary records the error count Pyright prints.
- [ ] [P2-T4] Run `poetry run pytest` on the whole file `tests/scripts/dev_tools/test_discovery_documentation_contracts.py` and write `<FEATURE>/evidence/qa-gates/qc-pytest.<timestamp>.md`. Acceptance: the four fields are present, `EXIT_CODE: 0`, and the summary records the passed count with no failures, including the named node.
- [ ] [P2-T5] Run the same test module in reversed order in one process (a Python helper file under `SCRATCH` that reverses the collected items, run with `poetry run python`) and write `<FEATURE>/evidence/regression-testing/reversed-order.<timestamp>.md`. Acceptance: the four fields are present, `EXIT_CODE: 0`, and the summary records the passed count and the reversed order.
- [ ] [P2-T6] If any of [P2-T1] to [P2-T5] fails or rewrites a file, fix the cause and restart from [P2-T1]; the QC artifacts must come from one clean pass. Acceptance: the artifacts of [P2-T1] to [P2-T5] all record `EXIT_CODE: 0` from the same pass.
- [ ] [P2-T7] After verification, check off AC1 in `<FEATURE>/issue.md` (exclusion evaluated against `path.relative_to(REPO_ROOT).parts`; verified by reading the changed condition and the diff, which is confined to it). Acceptance: the AC1 checkbox is `[x]`.
- [ ] [P2-T8] Check off AC2 in `<FEATURE>/issue.md` (assertion, count of 6, and excluded names unchanged; nested worktree stays excluded; verified by reading the diff). Acceptance: the AC2 checkbox is `[x]`.
- [ ] [P2-T9] Check off AC3 in `<FEATURE>/issue.md` (fails before per `fail-before.2026-11-06T17-42.md`, passes after per the Pytest artifact of [P2-T4]). Acceptance: the AC3 checkbox is `[x]`.
- [ ] [P2-T10] Check off AC4 in `<FEATURE>/issue.md` (Black, Ruff, Pyright, Pytest pass per the artifacts of [P2-T1] to [P2-T4]). Acceptance: the AC4 checkbox is `[x]`.
- [ ] [P2-T11] Walk the policy-audit, code-review, and feature-audit templates under `docs/features/templates/policy_audit/` against the branch diff from the merge base of `origin/main` and `HEAD`, and write `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md` with one PASS, FAIL, or N/A row per checklist item. Acceptance: the artifact exists and has no FAIL row; a FAIL row is fixed and the QA loop re-run before the artifact is rewritten.
