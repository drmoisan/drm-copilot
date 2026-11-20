<!-- markdownlint-disable-file -->

# Task Research Notes: Refresh epic-orchestrate frozen-surface digest (Issue #615)

## Research Executed

### File Analysis

- `.claude/skills/epic-orchestrate/SKILL.md`
  - The checked-in runtime skill contains a four-line wording change in the checkpoint-validation paragraph compared with its parent at merge commit `1432ff89`; its current byte SHA-256 is `42cd106c1dc6982cfe4fb15fb3439bdde4eb1bbbc6a1a2db26a8739587ab4ca7`.
- `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`
  - `PINNED_FROZEN_SURFACE_HASHES` pins both frozen runtime files. The epic-orchestrate entry remains at the former digest `d8d3425b5cc70bccfa1d1ab19266f9c90a0134d98a510aedcea636d24d5d078b`; the epic-orchestrator agent pin remains `5318b458a8ccfdf5270677a3b90ba130367a0857dea0acbcf4db1a8e68a97dec`.
- `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py`
  - The failing parametrized test computes the file digest from repository bytes and requires exact equality with each pinned expectation. This is a contract test, not a runtime behavior test.
- `docs/features/active/2026-08-31-refresh-epic-orchestrate-frozen-surface-digest-615/issue.md` and `spec.md`
  - Both identify full-bug workflow issue #615. The supplied implementation scope is zero runtime files and one Python test-support file.

### Code Search Results

- `PINNED_FROZEN_SURFACE_HASHES`
  - One stale entry targets `.claude/skills/epic-orchestrate/SKILL.md`; no second stale entry was found.
- `git diff 1432ff89^ 1432ff89 -- .claude/skills/epic-orchestrate/SKILL.md`
  - The merge introduced four insertions and four deletions in the pinned file. The change replaces the old Python-module validation wording with the MCP validation call and its `require_complete` argument.
- `git log --all -- tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`
  - Prior digest updates are recorded as explicit re-baselines, including issue #559; the expectation was retained as a live guard rather than removed.

### External Research

- #githubRepo:"drmoisan/drm-copilot CI run 33379396439"
  - The GitHub CLI run metadata identifies head SHA `1432ff895c57113702db70deb2dbb092cefe0296`. The failed job was `quality-checks7 / Code Quality & Tests (3.11)`; documentation validation, build, security, npm audit, TypeScript, shell coverage, and PowerShell jobs reported success. The 3.11 log reports 4,244 passed and 5 skipped, with only the frozen digest assertion failing.
- #fetch:https://docs.github.com/en/actions/how-tos/monitor-workflows/view-workflow-run-history?tool=webui
  - GitHub documents viewing workflow-run and job logs, including `gh run view --job JOB_ID --log`, which was used to inspect the failed job.
- #fetch:https://docs.python.org/3.11/library/hashlib.html
  - Python documents `hashlib.sha256()` and `.hexdigest()` as the standard way to produce a hexadecimal SHA-256 digest, matching the repository test’s byte-digest mechanism.

### Project Conventions

- Standards referenced: `.agents/skills/research-issue/SKILL.md`, `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`, `.agents/skills/general-code-change/SKILL.md`, `.agents/skills/general-unit-test/SKILL.md`, `.agents/skills/python/SKILL.md`, `.github/instructions/github-actions-ci-cd-best-practices.instructions.md`.
- Instructions followed: research-only scope; verified findings from repository and authoritative external sources; canonical feature research location; issue number 615 retained in all artifact references; no source, configuration, formatter, test, commit, push, PR, or merge mutation performed.

## Key Discoveries

### Project Structure

The frozen-surface contract is split between immutable runtime documents under `.claude/` and pinned expectation data under `tests/scripts/dev_tools/`. The test-support module is the only supplied implementation target. The runtime skill is already the intended post-merge content and must remain unchanged; `.claude/`/mirror parity is not implicated by the failure.

### Implementation Patterns

The repository re-baselines a digest only when the frozen document has an intentional, reviewed change. The contract test continues to compare raw file bytes, so the replacement must be computed from the exact PR-head bytes and written only to the matching tuple entry. Removing the assertion or changing unrelated pins would weaken the frozen-surface control.

### Complete Examples

```python
(
    ".claude/skills/epic-orchestrate/SKILL.md",
    "42cd106c1dc6982cfe4fb15fb3439bdde4eb1bbbc6a1a2db26a8739587ab4ca7",
)
```

This is the minimal expected replacement supported by the independently computed local digest and the CI-reported actual digest.

### API and Schema Documentation

The test contract accepts a tuple of `(relative_path, expected_digest)` and computes an exact SHA-256 digest over the target file. There is no API, schema, or user-facing behavior change.

### Configuration Examples

```text
Expected digest before merge: d8d3425b5cc70bccfa1d1ab19266f9c90a0134d98a510aedcea636d24d5d078b
Observed digest at merge head: 42cd106c1dc6982cfe4fb15fb3439bdde4eb1bbbc6a1a2db26a8739587ab4ca7
```

### Technical Requirements

- Change only the `.claude/skills/epic-orchestrate/SKILL.md` tuple value in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`.
- Preserve the second frozen-file pin, all section and fragment expectations, and the runtime skill and mirror bytes.
- Validate the changed test-support file with the repository’s Python formatting, linting, type-checking, and pytest gates in the implementation phase.
- Re-run CI against the resulting branch/PR head and confirm the required checks pass for that exact SHA.

## Recommended Approach

Update the single stale digest tuple to `42cd106c1dc6982cfe4fb15fb3439bdde4eb1bbbc6a1a2db26a8739587ab4ca7`, preserving the assertion and every other expectation. This is supported by the CI failure’s exact expected/actual values, the local byte hash, the four-line merge diff, and the historical re-baselining pattern.

Rejected alternatives: reverting the runtime skill would discard the merged MCP wording change; removing the digest assertion would weaken regression protection; changing both pins or regenerating unrelated expectations lacks evidence.

## Implementation Guidance

- **Objectives**: Reconcile the frozen expectation with the intentionally changed post-merge runtime skill for issue #615.
- **Key Tasks**: Edit one string in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`; run the required Python toolchain; run the focused frozen-surface contract; commit through the bug workflow; observe CI on the exact head.
- **Dependencies**: The exact PR-head runtime bytes and the repository Python test environment.
- **Success Criteria**: The focused digest test passes; no other expectations change; required Python gates and CI pass for the current commit; runtime skill and mirror remain unmodified.
