# 2026-08-30-bash-lane-assertion-newline-edges-divergence (Spec)

- **Issue:** #609
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-29T18-40
- **Status:** Draft
- **Version:** 0.2

## Context
- Summary of the bug and its impact: the bash lane-assertion `--edges` parser (`pla_parse_edges`) discards every token after the first embedded newline. The Python authority (`scripts/dev_tools/parallel_lane_assertion.py`) tokenizes the same value with `str.split()`, which splits on newlines and other whitespace. The two lanes therefore report different derived conflict component counts for the same input. The difference is not declared as a divergence class in the completed #599 spec and is not covered by any test. This is finding R-1 of `docs/features/completed/2026-08-29-remove-remaining-python-invocations-599/remediation-inputs.2026-08-30T17-17.md`.
- Observed environment(s): Windows 11 Pro 10.0.26200; bash lane run under the repository shell toolchain; Python authority run in the repository Poetry environment.
- Customer impact and severity: severity High per the issue, bounded in practice. The diagnostic is advisory-only, always exits 0, feeds nothing, and never influences scheduling. Both documented invocation forms (`.claude/skills/parallel-plan/SKILL.md` and `.claude/agents/parallel-planner.md`) pass single-line, space-separated strings, so no documented use is affected. The defect is a parity and test-coverage gap.
- First observed date and version(s) impacted: identified 2026-08-30 during review of #599 (branch `feature/remove-remaining-python-invocations-599-r2`); present since the bash lane was introduced. It is not a regression.

## Repro & Evidence
- Steps to reproduce:
  1. Run the bash lane (`.claude/lib/bash/report-lane-assertion.sh`) against `tests/fixtures/parallel_manifest_payload/parallel.md` with `--edges` set to the two-line value `999:998` newline `101:202`.
  2. Run the Python authority (`scripts/dev_tools/parallel_lane_assertion.py`) against the same manifest with the same `--edges` value.
  3. Compare the reported derived conflict component counts.
- Expected vs actual behavior:
  - Expected: both lanes tokenize the value identically and print the same header line.
  - Actual (recorded in the issue):
    ```
    --edges 999:998\n101:202
      bash   -> Lane assertion: 2 derived conflict component(s); 0 disagreement(s).
      python -> Lane assertion: 1 derived conflict component(s); 0 disagreement(s).
    ```
    Bash keeps only `999:998`, which names undeclared vertices and is skipped. The items `101` and `202` stay separate. Python keeps `101:202`, which merges them.
- Logs/screenshots/error snippets: see the reproduction output above. Execution was not performed during research (shell tools are denied in agent worktrees); the mechanism is derived from the code and documented bash `read` semantics, and the output values come from the issue.
- Frequency / determinism: deterministic and input-dependent. It occurs whenever the `--edges` value contains a newline, and, by the same mechanism class, a carriage return, vertical tab, or form feed.

## Scope & Non-Goals
- In scope:
  - Canonical file `.claude/lib/bash/parallel-lane-assertion.sh`: change the `--edges` tokenization in `pla_parse_edges` (about line 86) and its comment.
  - Byte-identical bundled mirror `extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/parallel-lane-assertion.sh`.
  - Regression tests in `tests/shell/parallel_lane_assertion.bats`: newline, tab, CR and CRLF cases, plus a single-line control.
  - New parity fixture `tests/fixtures/parallel_lane_assertion/edges_newline_separated.json`, with `expected_stdout` derived by running the Python authority, picked up automatically by `tests/shell/parallel_lane_assertion_parity.bats` and `tests/scripts/dev_tools/test_parallel_lane_assertion_bash_parity.py`.
  - Optional: a CRLF parity fixture `tests/fixtures/parallel_lane_assertion/edges_crlf_separated.json`, with `expected_stdout` derived the same way.
- Out of scope / non-goals (recorded as follow-ups, not requirements):
  - Follow-up 1: newline truncation in `.claude/lib/bash/compute-cohorts.sh` via `pcoh_split_words` in `.claude/lib/bash/parallel-cohorts.sh`. It is a separate helper with its own Python authority and parity suite (`tests/shell/parallel_cohorts_parity.bats`).
  - Follow-up 2: Python-only whitespace characters (`\x1c` to `\x1f`, `\x85`, `\xa0`, other Unicode spaces) in `--edges`.
  - No edit to the completed #599 spec under `docs/features/completed/`. After this fix its statement that both implementations split on whitespace is accurate for the covered characters, so no edit is required.
  - No edit to the divergence-class restatements in the header of `tests/shell/parallel_lane_assertion_parity.bats` or the module docstring of `tests/scripts/dev_tools/test_parallel_lane_assertion_bash_parity.py`. Their sentence that both implementations split the `--edges` value on whitespace and converge becomes true as written for the covered characters, so no wording update is needed.
- Explicitly excluded systems, integrations, or datasets: `.claude/lib/bash/report-lane-assertion.sh`, `pack-manifests/core.json` (registration is unchanged by an in-place edit), the Python authority, and any output-format change.

## Root Cause Analysis
- Current hypothesis or confirmed root cause: `pla_parse_edges` (`.claude/lib/bash/parallel-lane-assertion.sh:73-98`) tokenizes with `read -ra tokens <<<"$text"` at line 86. `read` without `-d` treats newline as the record delimiter and consumes one record only. The default IFS splits that first record on space and tab, but content after the first embedded newline is never read. The default IFS also does not contain CR, VT, or FF, so `202` followed by CR is one non-integer token and the edge is dropped by the integer-lexis check (`^-?(0|[1-9][0-9]*)$`, line 70). Python's `edge_text.split()` (`scripts/dev_tools/parallel_lane_assertion.py:425`) splits on all of these.
- Signals/evidence supporting it: the reproduction in the issue matches the derived mechanism (bash array is `("999:998")`; `999:998` is skipped in `pla_derive_components`, lines 225-226). Research static reading found no test that contains a newline, tab, or CR in any corpus record or unit case. Line 86 is the only `read -ra` that takes operator-supplied text; the other uses read internally built space-joined lists.
- Affected components/modules (paths, services, pipelines): `.claude/lib/bash/parallel-lane-assertion.sh` (`pla_parse_edges`) and its bundled mirror. The entry point `report-lane-assertion.sh` passes the raw value through unchanged and needs no change.

## Proposed Fix

### Design summary (what changes where):
Option A from research: normalize newline, CR, VT, and FF to spaces before the `read -ra`, so the bash lane tokenizes on the same ASCII whitespace as the Python authority for those characters. The change is a single parameter expansion, for example `read -ra tokens <<<"${text//[$'\n\r\v\f']/ }"`, plus a short comment update. Option B (declare a sixth divergence class) is rejected: it would edit a closed spec, leave a porting defect in a diagnostic whose purpose is byte-identical output with the authority, and nothing justifies dropping newline-separated edges.

### Boundaries and invariants to preserve:
- The diagnostic remains advisory-only and always exits 0.
- Output format is unchanged.
- The `read -ra` idiom stays, so a token containing a glob character is never subjected to pathname expansion.
- No `read` exit-status effect under `set -euo pipefail`; parameter expansion adds no failing command.
- The bundled mirror remains byte-identical to the canonical file.
- Existing divergence classes (integer lexis, and the others in the #599 spec) are unchanged.

### Dependencies or blocked work:
None. Bats cannot be executed inside the agent worktree; CI (`.github/workflows/_shell-coverage.yml`) or an operator-run shell is the bats authority.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
- `.claude/lib/bash/parallel-lane-assertion.sh` (about lines 84-86)
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/parallel-lane-assertion.sh` (byte-identical copy)
- `tests/shell/parallel_lane_assertion.bats`
- `tests/fixtures/parallel_lane_assertion/edges_newline_separated.json` (new)
- `tests/fixtures/parallel_lane_assertion/edges_crlf_separated.json` (optional, new)

#### Functions/classes/CLI commands impacted:
`pla_parse_edges` only. The `--edges` flag of `report-lane-assertion.sh` and of the Python authority keep their current interface.

#### Data flow and validation changes:
Operator text is normalized (newline, CR, VT, FF to space) before splitting. Downstream validation (`x:y` shape, integer lexis, undeclared-vertex skipping) is unchanged.

#### Error handling and logging updates:
None. No new error paths and no new output.

#### Rollback/feature-flag considerations (if applicable):
None. Revert the single statement and its mirror copy.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
Input: `--edges` string. After the fix, the ASCII separators space, tab, newline, CR, VT, and FF all separate edge tokens. Output: the existing `Lane assertion: N derived conflict component(s); M disagreement(s).` report, unchanged in format.

#### Required configuration keys and defaults:
None.

#### Backward-compatibility expectations:
Single-line, space-separated inputs (all documented invocations) behave identically. Inputs that contained newline, CR, VT, or FF now yield the same result as the Python authority instead of a truncated or dropped edge set.

#### Performance constraints (latency/throughput/memory):
No measurable change; one parameter expansion over a short operator string.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access): the fixture manifest declares `issue_num` 101 and 202 (`tests/fixtures/parallel_manifest_payload/parallel.md`); the parity harnesses read the `edges` value from JSON via `$(...)`, which preserves interior newlines.
- Constraints (budget, performance, compatibility): `parallel-lane-assertion.sh` is currently 495 lines and must stay at or under 500 lines, so the edit adds at most four lines net. The mirror must stay byte-identical (guards: `tests/shell/parallel_bash_manifest_membership.bats` and the push-down resource contract test `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`). Toolchain: `shell-qc` (format, check, test with coverage) plus the pytest parity test.
- External dependencies (services, libraries, releases): none new. Mirroring is manual; there is no copy automation.

## Data / API / Config Impact
- User-facing or API changes: none to the interface; newline, CR, VT, and FF in `--edges` are now honored as separators.
- Data or migration considerations: none.
- Logging/telemetry updates (if any): none.
- Compatibility notes (CLI flags, config schemas, versioning): no flag, schema, or version change. Bundled payload content changes only through the mirrored file.

## Test Strategy
- Regression tests to add or update:
  - `tests/shell/parallel_lane_assertion.bats`: new cases using `PAYLOAD_MANIFEST` and `ENTRY_POINT` asserting the header line for an edges value separated by newline, by tab, by CR, and by CRLF, each compared against a single-line `101:202` control (same manifest, same header).
  - `tests/fixtures/parallel_lane_assertion/edges_newline_separated.json`: manifest `manifests/two-items-no-assertion.md`, edges `999:998` newline `101:202`. The `expected_stdout` is generated by running `scripts/dev_tools/parallel_lane_assertion.py`, not hand written. Both parity suites iterate it automatically. The corpus record count floor in the bash parity suite is a minimum, so adding a record does not break it.
  - Optional `edges_crlf_separated.json` with the same derivation rule.
- Unit tests (pytest) for the fixed behavior and boundaries: `tests/scripts/dev_tools/test_parallel_lane_assertion_bash_parity.py` covers the new fixture in the Python lane; the Python authority is unchanged and `tests/scripts/dev_tools/test_parallel_lane_assertion.py` stays green.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values): trailing newline, mixed separators, CRLF-terminated final token (verifies CR does not corrupt the last integer), and an all-undeclared-vertices value (skipped edges, no failure). Empty and whitespace-only edges are already covered by `edges_empty` and `edges_whitespace_only`.
- Error handling and logging verification: verify exit status remains 0 for each new case and that stdout format is unchanged.
- Coverage impact and targets for changed lines/modules: line coverage of `parallel-lane-assertion.sh` must not regress and the repository floor of 85% line coverage applies (kcov; PowerShell and bash have no branch-coverage gate).
- Toolchain commands to run (format, lint, type-check, test):
  - `bash scripts/bash/shell-qc.sh format`
  - `bash scripts/bash/shell-qc.sh check`
  - `bash scripts/bash/shell-qc.sh test --coverage`
  - `poetry run pytest tests/scripts/dev_tools/test_parallel_lane_assertion_bash_parity.py tests/scripts/dev_tools/test_parallel_lane_assertion.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`
  - Single file: `bats tests/shell/parallel_lane_assertion.bats`
- Manual validation steps (if required): none. Fail-before evidence is obtained by running the new regression tests against the unmodified library.

## Acceptance Criteria
- [x] The issue's reproduction (`--edges` of `999:998` newline `101:202` against `tests/fixtures/parallel_manifest_payload/parallel.md`) produces an identical `Lane assertion:` header line from the bash entry point and from `scripts/dev_tools/parallel_lane_assertion.py`; verified by the new bats case in `tests/shell/parallel_lane_assertion.bats` and by the `edges_newline_separated` parity record.
- [x] `pla_parse_edges` in `.claude/lib/bash/parallel-lane-assertion.sh` normalizes newline, CR, VT, and FF to spaces before the `read -ra tokens` call; verified by `grep -n 'read -ra tokens' .claude/lib/bash/parallel-lane-assertion.sh` showing the normalized expansion.
- [x] A bats regression test in `tests/shell/parallel_lane_assertion.bats` asserts that a newline-separated `--edges` value yields the same header as the single-line `101:202` control.
- [x] A bats regression test in `tests/shell/parallel_lane_assertion.bats` asserts that a tab-separated `--edges` value yields the same header as the single-line control.
- [x] A bats regression test in `tests/shell/parallel_lane_assertion.bats` asserts that a CR-separated value and a CRLF-separated value each yield the same header as the single-line control, and that a CRLF-terminated final token is not dropped.
- [ ] The new bats regression tests fail when run against the unmodified library and pass after the fix; evidence recorded under `docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/evidence/`.
- [x] `tests/fixtures/parallel_lane_assertion/edges_newline_separated.json` exists, follows the schema of `edges_endpoint_interior_whitespace.json`, and its `expected_stdout` equals the output of the Python authority for the same manifest and edges (regeneration by running `scripts/dev_tools/parallel_lane_assertion.py` yields no diff).
- [x] `bats tests/shell/parallel_lane_assertion_parity.bats` passes, including the new fixture record.
- [x] `poetry run pytest tests/scripts/dev_tools/test_parallel_lane_assertion_bash_parity.py` passes, including the new fixture record.
- [x] If the optional `edges_crlf_separated.json` fixture is added, its `expected_stdout` is derived from the Python authority and both parity suites pass with it; if it is not added, the CRLF regression test in `tests/shell/parallel_lane_assertion.bats` remains the CRLF coverage.
- [x] The bundled mirror `extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/parallel-lane-assertion.sh` is byte-identical to the canonical file; verified by `cmp .claude/lib/bash/parallel-lane-assertion.sh extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/parallel-lane-assertion.sh` returning exit 0, by `bats tests/shell/parallel_bash_manifest_membership.bats`, and by `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`.
- [x] Existing suites remain green: `bats tests/shell/parallel_lane_assertion.bats` (all pre-existing cases), `tests/scripts/dev_tools/test_parallel_lane_assertion.py`, and the two parity suites.
- [x] The diagnostic still always exits 0 and its output format is unchanged; verified by the new cases asserting exit status 0 and by unchanged `expected_stdout` for all pre-existing fixtures.
- [x] Line coverage of `.claude/lib/bash/parallel-lane-assertion.sh` does not regress relative to the pre-change baseline and remains at or above 85%; verified by `bash scripts/bash/shell-qc.sh test --coverage`.
- [x] `.claude/lib/bash/parallel-lane-assertion.sh` remains at or under 500 lines; verified by `wc -l` on the canonical file.
- [x] No edits are made to `.claude/lib/bash/parallel-cohorts.sh`, `.claude/lib/bash/compute-cohorts.sh`, `.claude/lib/bash/report-lane-assertion.sh`, the completed #599 spec, or the divergence-class headers of the two parity test files; verified by `git diff --name-only` against the branch base.
- [x] `bash scripts/bash/shell-qc.sh format` and `bash scripts/bash/shell-qc.sh check` pass with zero findings on the changed shell files.

## Risks & Mitigations
- Technical or operational risks: characters still divergent after the fix (`\x1c` to `\x1f`, `\x85`, `\xa0`, other Unicode spaces) may be mistaken for a fully closed divergence. The 500-line limit leaves only a few lines of headroom in the library.
- Mitigations and rollbacks: record the residual Python-only whitespace and the `pcoh_split_words` newline behavior as follow-ups. Keep the library edit to at most four added lines. Rollback is a revert of one statement and its mirror copy. Manual mirroring risk is covered by the two byte-equality guards.

## Rollout & Follow-up
- Release/rollout steps: ship with the next extension payload that includes the mirrored library file; no flag or migration.
- Post-fix monitoring or clean-up tasks:
  - Follow-up: `compute-cohorts.sh` / `pcoh_split_words` newline truncation (`.claude/lib/bash/parallel-cohorts.sh`).
  - Follow-up: residual Python-only whitespace in `--edges`, to be either fixed or declared as a divergence class.
- Links: issue #609 (https://github.com/drmoisan/drm-copilot/issues/609); parent finding R-1 in `docs/features/completed/2026-08-29-remove-remaining-python-invocations-599/remediation-inputs.2026-08-30T17-17.md`; research `docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/research/research.2026-09-29T18-35.md`.
