# unauthorized-noqa-e501-in-blast-radius-parity-test (Spec)

- **Issue:** #512
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-29T15-16
- **Status:** Draft
- **Version:** 0.1

## Context
`tests/scripts/dev_tools/test_blast_radius_config_parity.py` carries a `# noqa: E501` that is not
authorized by `.claude/rules/python-suppressions.md`, and the plan task whose acceptance forbade a
new `noqa` was nonetheless checked off.

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- Python version: repository Poetry environment
- Command/flags used: `poetry run ruff check .`
- Data source or fixture: not applicable

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Medium rather than Low on two counts. A suppression outside the enumerated set weakens a lint gate
without a recorded decision, and a task checked against a half-satisfied acceptance condition is the
same class of defect that issue #500 corrected four separate times (AC9, AC10, AC4, and cycle 4's
own R1). The severity is not higher because the suppressed diagnostic is line length only, with no
behavioral effect.


## Repro & Evidence
Steps to Reproduce:
1. Open `tests/scripts/dev_tools/test_blast_radius_config_parity.py` and find the `def` line of
   `test_every_class_two_and_class_three_key_is_consumed_by_its_registered_assertion`. It ends with
   `# noqa: E501`.
2. Read `.claude/rules/python-suppressions.md`. A suppression must either match a pre-authorized
   pattern or carry explicit user approval. `E501` appears in neither the pre-authorized list nor
   the explicitly-not-authorized list, and no approval is recorded.
3. Observe that the rule's required explanatory comment for a suppression is absent.

Expected:
Either the line fits the 88-character limit without a suppression, or the suppression matches a
pre-authorized pattern, or an explicit user approval for this specific suppression is recorded.

Actual:
An unauthorized `E501` suppression is present in committed test code. Separately, task P5-T2 of
`docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/2026-08-22T17-20-remediation/remediation-plan.2026-08-22T18-05.md`
is checked `[x]` while its stated acceptance is "zero new `noqa` present", which the tree does not
satisfy. No deviation was recorded against that task.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: the `def` line measures 91 characters; the Ruff limit is 88.


## Scope & Non-Goals
- In scope:
  - In `tests/scripts/dev_tools/test_blast_radius_config_parity.py` only, rename
    `test_every_class_two_and_class_three_key_is_consumed_by_its_registered_assertion` (80 characters)
    to `test_every_class_two_and_three_key_is_consumed_by_its_registered_assertion` (74 characters).
  - Remove the `# noqa: E501` comment from that test's `def` line in the same edit.
- Out of scope / non-goals (each recorded as a follow-up that requires a user decision):
  - (a) Whether `E501` should be added to the pre-authorized list in
    `.claude/rules/python-suppressions.md`. Policy files must not be edited by agents.
  - (b) The three precedent `# noqa: E501` test defs:
    `tests/scripts/dev_tools/codex_native_converter/test_intermediate_state.py:86`,
    `tests/scripts/dev_tools/codex_native_converter/test_section_intent.py:76`, and
    `tests/scripts/dev_tools/test_potential_to_issue_content.py:65`.
  - (c) Historical documents under `docs/features/completed/` and `docs/features/potential/promoted/`
    that cite the old test name are not edited. This includes the #500 remediation plan, whose task
    P5-T2 was checked off against an acceptance condition the tree did not satisfy. The process
    finding is recorded in this spec (see Root Cause Analysis and Rollout & Follow-up) rather than by
    amending a completed plan.
  - Changes to the test body, docstring, or assertions.
  - Production code changes and configuration changes (`pyproject.toml` is unchanged).
- Explicitly excluded systems, integrations, or datasets: none are touched. The test is the
  meta-test that validates `CLASS_TWO_KEY_ASSERTIONS` and `CLASS_THREE_KEY_ASSERTIONS`; it is not a
  value in either registry, so the rename does not affect any registry lookup.

## Root Cause Analysis
Introduced by issue #500 remediation cycle 4 and recorded in that cycle's exit re-audit as finding
M4; see
`docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/2026-08-23T04-45-audit/code-review.2026-08-23T04-45.md`.

The suppression was not an arbitrary choice. The cycle-4 plan mandated the 80-character test name at
task P1-T2, and no formatting variant of that name fits: after Black wraps the return type, the
`def` line measures `len(name) + 11` characters, so 80 yields 91. Three other test files in this
repository carry an `E501` suppression for identically-shaped long test names, and the executor
followed that precedent rather than editing `pyproject.toml`, which the same plan forbade at P5-T10.
Precedent is not authorization under a rule that enumerates its authorized patterns exhaustively.

It was left in place deliberately rather than hot-fixed. The exit re-audit had already returned
`blocking_count` 0 against the committed tree, and renaming the function afterwards would have
shipped code that differed from the reviewed tree while leaving five citations of the old name in the
executed plan and two evidence artifacts.


## Proposed Fix

### Design summary (what changes where):
Rename one test function so its `def` line fits the 88-character limit without a suppression, and
delete the `# noqa: E501` comment. The rename drops the word `class_` before `three`, so
`..._two_and_class_three_key_...` becomes `..._two_and_three_key_...`.

Line-length arithmetic: the single-line form `def <name>() -> None:` measures `len(name) + 15`,
which is 89 for the 74-character name and exceeds 88. Black therefore keeps the wrapped return-type
form `def <name>() -> (\n    None\n):`, whose first line measures `len(name) + 11`, which is 85 for
the new name. Black decides the final formatting; the implementation must accept Black's output.

### Boundaries and invariants to preserve:
- Test body, docstring, and assertions are unchanged.
- The number of tests collected and passing in the file is unchanged from the pre-change run.
- The file stays at or under 500 lines (499 lines before the change; the rename adds no lines).
- The renamed test is not registered in `CLASS_TWO_KEY_ASSERTIONS` or `CLASS_THREE_KEY_ASSERTIONS`,
  so `unconsumed_class_keys(..., globals())` lookups are unaffected.
- No suppression comment is introduced anywhere as part of this change.

### Dependencies or blocked work:
None. Follow-up items (a) through (c) in Scope & Non-Goals are independent of this change and are
blocked on user decisions.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
- `tests/scripts/dev_tools/test_blast_radius_config_parity.py` (one function name and one comment).

#### Functions/classes/CLI commands impacted:
- `test_every_class_two_and_class_three_key_is_consumed_by_its_registered_assertion` becomes
  `test_every_class_two_and_three_key_is_consumed_by_its_registered_assertion`.
- Research found the old name in no code or PowerShell file other than its own definition; all other
  occurrences are in historical or active documentation.

#### Data flow and validation changes:
None.

#### Error handling and logging updates:
None.

#### Rollback/feature-flag considerations (if applicable):
Revert the single commit. No feature flag applies.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
Not applicable. The pytest node identifier of one test changes; no other interface changes.

#### Required configuration keys and defaults:
None. `pyproject.toml` is unchanged; the Black and Ruff line length remains 88.

#### Backward-compatibility expectations:
Any external selector that references the old pytest node identifier (for example `-k` expressions)
must use the new name. A repository search found no such reference in code or scripts.

#### Performance constraints (latency/throughput/memory):
None.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access): the repository Poetry environment provides Black, Ruff,
  Pyright, and pytest with coverage; the 88-character limit in `pyproject.toml` is unchanged.
- Constraints (budget, performance, compatibility): file size at or under 500 lines; policy files
  under `.claude/rules/` and `.github/` are not edited; no configuration changes.
- External dependencies (services, libraries, releases): none.

## Data / API / Config Impact
- User-facing or API changes: none.
- Data or migration considerations: none.
- Logging/telemetry updates (if any): none.
- Compatibility notes (CLI flags, config schemas, versioning): none; the only observable change is
  one pytest node identifier.

## Test Strategy
Seeded from issue:

- [x] Unit coverage areas: rename the test so the `def` line fits without a suppression. Any name of
      77 characters or fewer works, since the line measures `len(name) + 11`. A measured candidate is
      `test_every_class_two_and_three_key_is_consumed_by_its_registered_assertion` at 74 characters.
      Remove the `# noqa: E501` in the same edit and confirm `poetry run ruff check .` stays clean.
- [x] Integration scenario to retest: `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py`
      should still collect and pass 17 tests. Re-confirm the gate is non-vacuous by registering a key
      against an assertion that does not read it and observing exactly one failure.
- [x] Manual verification notes: decide the general question this raises, which is whether `E501`
      belongs in the pre-authorized list for long descriptive test names. Three existing precedents
      suggest the pattern recurs. If it is authorized, add it to
      `.claude/rules/python-suppressions.md` with its required explanatory-comment convention rather
      than leaving each instance to precedent.

Note on the seeded items above: the third item (the `E501` authorization decision) is not performed
by this change; it is recorded as follow-up (a) and requires a user decision.

- Regression tests to add or update: no new test is added. The regression guard is the existing
  Ruff E501 check, which fails on the file if a suppression-free over-length `def` line returns.
  Fail-before evidence: removing only the `# noqa: E501` comment (before the rename) makes
  `poetry run ruff check tests/scripts/dev_tools/test_blast_radius_config_parity.py` report E501 for
  that line; after the rename the same command exits 0.
- Unit tests (pytest) for the fixed behavior and boundaries: the existing tests in
  `tests/scripts/dev_tools/test_blast_radius_config_parity.py` are the behavior check. Record the
  collected and passed counts before the change and confirm they are identical after it.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values): the boundary is
  the 88-character limit. The new first line measures 85 characters. The non-vacuity re-check from the
  seeded integration item covers the negative scenario.
- Error handling and logging verification: not applicable.
- Coverage impact and targets for changed lines/modules: no change expected; line coverage remains
  at or above 85% and branch coverage at or above 75%, with no regression against the pre-change run.
- Toolchain commands to run (format → lint → type-check → test): `poetry run black`,
  `poetry run ruff check`, `poetry run pyright`, then `poetry run pytest` with coverage, repeated
  until a single pass is clean.
- Manual validation steps (if required): `grep` for `noqa: E501` in the file (expect no match) and for
  the old test name under `tests/` (expect no match).


## Acceptance Criteria
- [ ] `tests/scripts/dev_tools/test_blast_radius_config_parity.py` contains no `noqa` comment introduced by this change and no `# noqa: E501` string.
- [ ] `test_every_class_two_and_three_key_is_consumed_by_its_registered_assertion` (74 characters) is defined in `tests/scripts/dev_tools/test_blast_radius_config_parity.py`, and the old name `test_every_class_two_and_class_three_key_is_consumed_by_its_registered_assertion` appears nowhere under `tests/`.
- [ ] Fail-before evidence is recorded: with only the `# noqa: E501` comment removed and the old name in place, `poetry run ruff check tests/scripts/dev_tools/test_blast_radius_config_parity.py` reports E501 for that line.
- [ ] After the rename, `poetry run ruff check tests/scripts/dev_tools/test_blast_radius_config_parity.py` exits 0, and the renamed `def` line is accepted by `poetry run black --check` without a suppression.
- [ ] `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py` passes, and its collected and passed test counts equal the pre-change counts.
- [ ] The test body, docstring, and assertions of the renamed test are unchanged, and the file is at or under 500 lines.
- [ ] No file other than files in this feature folder and `tests/scripts/dev_tools/test_blast_radius_config_parity.py` is changed; in particular, nothing else under `tests/` or `scripts/`, no production code, no `pyproject.toml`, and no policy file under `.claude/rules/` or `.github/`.
- [ ] The full Python toolchain (black, ruff, pyright, pytest with coverage) passes in a single clean pass, with line and branch coverage not regressed against the pre-change run.
- [ ] Follow-ups (a), (b), and (c) from Scope & Non-Goals are recorded in this spec as out of scope pending a user decision, and the completed #500 plan and historical documents are unedited.

## Risks & Mitigations
- Technical or operational risks:
  - Black could format the renamed `def` differently than the arithmetic predicts. Mitigation: run
    Black and accept its output, then confirm Ruff exits 0.
  - An external `-k` selector or document could reference the old name. Mitigation: repository search
    found only documentation references, which are historical and intentionally left unedited.
  - Three other files retain `# noqa: E501` on test defs, so the unauthorized-suppression class is not
    eliminated repository-wide. Mitigation: recorded as follow-up (b) for a user decision.
- Mitigations and rollbacks: revert the single commit; the change is confined to one test file.

## Rollout & Follow-up
- Release/rollout steps: merge with the normal branch flow; no release action is required.
- Post-fix monitoring or clean-up tasks:
  - Follow-up (a): user decision on adding `E501` to the pre-authorized list in
    `.claude/rules/python-suppressions.md` with an explanatory-comment convention, or on rejecting it.
  - Follow-up (b): after decision (a), rename or otherwise resolve the three precedent test defs.
  - Follow-up (c): historical documents citing the old name remain unedited by design.
  - Process finding: task P5-T2 of the #500 remediation plan was checked `[x]` while its acceptance
    ("zero new `noqa` present") was not satisfied and no deviation was recorded. Under the
    acceptance-criteria-tracking rules, a task is checked only after verification against its
    stated acceptance; a known gap requires a recorded deviation. This finding is recorded here and
    the completed plan is not amended.
- Links: issue #512 (https://github.com/drmoisan/drm-copilot/issues/512); related: issue #500 and its
  audit `docs/features/completed/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/2026-08-23T04-45-audit/code-review.2026-08-23T04-45.md`;
  research `research/2026-09-29T19-20-noqa-e501-rename.research.md` in this feature folder.
