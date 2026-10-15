# Code Review: concurrent-children-share-scratchpad-file-names (Issue #900)

- Timestamp: 2026-10-12T17-38
- Branch: bug/concurrent-children-share-scratchpad-file-names-900 (head eb365f9f4)
- Base: origin/main
- Work Mode: minor-audit
- Files reviewed: the four persona and skill sources, their four bundled copies, and `tests/scripts/dev_tools/test_scratch_location_contracts.py`. Feature-folder documents and evidence were read for consistency only.

## Executive Summary

Verdict: no blocking findings. Blocking count: 0.

The persona and skill edits are insertion-only prose with the same six-bullet shape in the executor sources and a five-bullet shape in the planner sources. They state the pinned rule, the scope, the literal-token requirement, and the same-issue extension point. The executor text adds directory creation and the pre-rule-plan reinterpretation. Placement matches the issue: before `## Preflight Validation` in the Claude planner, after `## Toolchain Commands` and ahead of `## Evidence Location Invariant` in the Claude executor. The bundled copies are byte-identical to their sources (`cmp` on all four pairs).

The new contract module is typed, small (275 lines), deterministic, and structured as Arrange-Act-Assert. At head it passes (15 passed), and Black, Ruff, and Pyright report no errors. Three low-severity or informational observations follow; none requires remediation before merge.

Typed-Python review (one new Python file): all function signatures carry parameter and return annotations; there is no `Any`, no `cast`, and no suppression comment; `from __future__ import annotations` is present; helpers are pure functions over `Path.read_text`; module constants are upper case. No change is requested.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Low (advisory) | tests/scripts/dev_tools/test_scratch_location_contracts.py | `FORBIDDEN_SCRATCH_PATHS` (lines 93-100) and `test_normative_surfaces_name_no_bare_fixed_scratch_path` (lines 258-275) | The bare-path guard is a denylist of six literals (five historical `SCRATCH/<name>` helper names plus `<scratchpad>/`). A new fixed shared name outside that list would pass the guard. The guard also passed in the red run (14 failed, 1 passed), which is expected because it protects an absence, but it means the guard has no recorded failing demonstration. | No change for this PR. When the deferred plan-validator check is built, move the general "no bare scratchpad root" detection there and keep this list as a regression pin. Optionally record a one-time negative demonstration of the guard in a later change. | AC-6 asks for a check against "a bare fixed scratchpad path such as" the listed names, so the enumerated form satisfies the criterion. Under the new rule any `SCRATCH/<name>` is valid, so a general detector cannot be written as a simple string match. | Test lines 93-100 and 258-275; `evidence/regression-testing/scratch-contract-red.2026-10-11T10-38.md` (1 passed in red); issue.md AC-6 |
| Info | .claude/agents/atomic-planner.md; .claude/agents/atomic-executor.md; .agents/skills/atomic-planner/SKILL.md; .agents/skills/atomic-executor/SKILL.md | New `## Scratch Location` sections | The rule has no preflight enforcement. A plan that defines `SCRATCH` as the bare scratchpad root still passes plan preflight; only the executor's mechanical reinterpretation and the contract test protect against collisions. This is the deferred plan-validator follow-up, not a defect in this change. | Track the plan-validator check (G-rule rejecting bare `SCRATCH`) as a follow-up. It needs an edit to `.claude/rules/plan-acceptance-gates.md` and operator approval, so it is out of scope here. | The issue records the deferral under Dependencies / Risks. The executor text already tells the executor to treat a bare-scratchpad definition as the per-issue directory, which closes the practical gap for pre-rule plans. | issue.md Dependencies / Risks, "Plan-validator check out of scope (deferred)"; executor persona bullet 4 |
| Info | .codex/agents/atomic-planner.toml; .codex/agents/atomic-executor.toml | Not changed | Codex agents that load only the TOML persona bodies will not see the rule. The `.agents/skills/` edits cover the Codex skill surface. | Track the TOML update as a follow-up with the generator-churn cost assessed first. | Deliberately left out by the issue; no parity test requires it. Not a finding against this change. | issue.md Dependencies / Risks, "Codex TOML personas not updated" |

## Detailed Review Notes

### Persona and skill text

- The rule phrase `` `SCRATCH` resolves to `<session scratchpad>/issue-<issue-num>/` `` appears once in each of the four sections and is the pinned phrase in the test, so wording drift fails the test.
- The planner text says "Every plan that uses scratch files defines `SCRATCH` this way", which keeps plans from relying on the executor reinterpretation for new work.
- The executor text calls the pre-rule reinterpretation "a mechanical micro-action, not replanning". That wording matches the executor's existing prohibition on inventing phases or tasks and avoids creating a replan trigger.
- The extension point `issue-<issue-num>-<yyyy-MM-ddTHH-mm>` is stated conditionally ("can execute at once"), consistent with the issue's statement that same-issue concurrency is not an expected topology.
- Forbidden shapes (backticked `npm run` token, `issue number: <digits>`, `docs/features/active/` path) are absent from the new text and asserted absent by the test. Placeholders such as `<issue-num>` are not digits, so they do not trigger the issue-number pattern.
- The Claude executor section is placed before `## Preflight Validation` and the later `## Evidence Location Invariant`, which keeps the insertion away from the end of the file as the #903 merge-risk note requested.

### Contract test

- Separation of concerns: pure text helpers (`scratch_section`, `neighbouring_headings`, `section_start`, `normative_surface_paths`) are reused by every test; file reads occur only in `read_repo_lines` and the scan test.
- `section_start` uses exact-line membership for `## Scratch Location`, so a heading inside a code fence with trailing text would not match; none exists in the four sources.
- `scratch_section` stops at the next `## ` heading, so the body assertions cannot be satisfied by text from a neighbouring section.
- Parametrization with named `pytest.param` ids produces readable failure identifiers. Assertion messages name the file and the absent phrases.
- The test reads only the four repository-root sources. The bundled copies are covered by the two push-down parity modules, which the docstring states and which pass at head.
- No temporary files, no wall-clock use, no ordering dependence.

### Evidence and process

- The red-run precondition, red run, and green run are recorded as separate artifacts, satisfying the verification order in the issue.
- The coverage comparison states that changed-line coverage is not applicable (Markdown prose and an omitted test module), which agrees with `pyproject.toml` `omit` entries.
- Evidence files are under `<FEATURE>/evidence/{baseline,regression-testing,qa-gates}/`; `validate_evidence_locations.py --root .` exits 0.

## Remediation Triggers

None. No blocker, no FAIL, no blocking PARTIAL, and no failing toolchain check.
