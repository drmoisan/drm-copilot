# parallel-add-children-not-told-to-record-issue-adoption (Plan)

- **Issue:** #885
- **Branch:** bug/parallel-add-children-not-told-to-record-issue-adoption-885
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-11T08-30
- **Status:** Draft (awaiting preflight)
- **Version:** 1.0
- **Work Mode:** minor-audit (persisted marker `- Work Mode: minor-audit` in `docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/issue.md`)
- **Requirements source:** `docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/issue.md`, section `## Acceptance Criteria` only (AC-1 through AC-8). `spec.md` and `user-story.md` are intentionally absent and must stay absent.
- **Research (context only):** `docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/research/research.2026-10-11T08-05.md`
- **Directive:** MINIMAL-AUDIT PLAN REQUIRED

**Fail-closed evidence rule:** Include explicit baseline artifact tasks, final-QA artifact tasks, and coverage-comparison tasks for each in-scope language when policy requires coverage. If any required baseline artifact, QA artifact, or coverage-comparison artifact is missing, the audit verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Record the expected artifact path or location in each evidence-producing task. Do not mark evidence-backed work complete without the artifact.

## Conventions for This Plan

- Feature folder: `docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885`. Every evidence path is written out in full and resolves under that folder's `evidence/<kind>/` (kinds used: `baseline`, `regression-testing`, `other`, `qa-gates`).
- `<ts>` in an evidence filename is the ISO-8601 timestamp `yyyy-MM-ddTHH-mm` read from the clock when the task runs, per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.
- Every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. An artifact whose expected exit code is non-zero also carries `ExpectedExitCode: <int>`.
- Files this plan writes outside the feature folder, and no others:
  - `.claude/skills/parallel-add/SKILL.md` (one insertion inside step 2)
  - `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md` (identical insertion; byte-identical result)
  - `tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py` (constants, helpers, one registry entry, four new tests)
- Files this plan writes inside the feature folder: `issue.md` (AC check-offs only), this plan file (checkbox state only), and the evidence files named individually in the tasks below.
- Coverage statement: the change touches no production Python and no production TypeScript. The one Python file edited is test code under `tests/`. Line and branch coverage of every production module is therefore unchanged by construction, and P2-T8 proves that no production path is among the changed paths. No coverage-mode run is planned, because a `--cov` run over this change has no module whose measured lines the change can alter; no coverage percentage is asserted anywhere in this plan.
- No manifest change: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` lists the mirrored path by name only (line 122) and carries no content hash.
- No `.agents/`, `.codex/`, or `.github/` counterpart of `parallel-add` exists, and none is created.
- Hard boundaries for the executor: do not edit `.claude/skills/parallel-add/SKILL.md` outside step 2; do not change the markers `2. **Prepare the item.**` or `3. **Compute conflict edges`; do not edit steps 3 through 7 or `## Constraints` (concurrent issue #890 edits steps 3 through 6); do not edit anything under `.claude/rules/` or `.github/instructions/`; do not call `sh`, `bash`, or `pwsh` wrapper scripts; do not create temporary files or scratch files; do not delete any file; do not force-push; do not create any GitHub issue.
- Python toolchain only: `poetry run black`, `poetry run ruff check`, `poetry run pyright`, `poetry run pytest`. PowerShell, bats, and TypeScript toolchains are not in scope; no file of those languages is changed.
- Observed success-case literals used as acceptance markers (each observed in a recorded run of the same tool on a Python test file in this repository):
  - Black check mode prints `1 file would be left unchanged.` for one file (`docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/remediation-baseline/black-check-baseline.2026-09-30T11-59.md`, line 4).
  - Black write mode on a clean file prints `All done!` followed by `<n> files left unchanged.` (`docs/features/active/2026-07-24-potential-to-issue-python-files-oversized-406/evidence/qa-gates/black.md`, line 4, recorded with `n` = 8); for one file the count line reads `1 file left unchanged.`. When Black rewrites a file it prints `1 file reformatted.` instead, which is the signal that restarts the Phase 2 loop.
  - `ruff check` prints `All checks passed!` (`docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/remediation-baseline/ruff-file-baseline.2026-09-30T11-59.md`, line 4). The project Ruff configuration (`pyproject.toml` lines 88-91) sets `show-fixes` and no `fix = true`, and the plan passes no `--fix` flag, so `ruff check` here does not rewrite files.
  - Pyright prints `0 errors, 0 warnings, 0 informations` (same folder, `pyright-file-baseline.2026-09-30T11-59.md`, line 4).
  - Pytest with `-v` prints one `PASSED` or `FAILED` line per node and a final result line of the form `<n> passed in <t>s` (or `<k> failed, <n> passed in <t>s`).
  - The orchestrator observed on origin/main `2ef8d361e` (2026-10-11): `git hash-object` of both `parallel-add/SKILL.md` copies returns `39dfca6d036d1425d892a67978ab1bc995828d83`, and `poetry run pytest tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q -p no:cacheprovider --no-cov` returned `36 passed`.
- Pytest invocations in this plan pass `-p no:cacheprovider --no-cov` so that no cache directory or coverage data file is written; the project `addopts` value (`-ra --cov-report=lcov:artifacts/python/lcov.info`) is unchanged and no `--cov` source is active.
- Every document edit is located by a text anchor, never by a line number. Line numbers in this plan are citations for the reader only, against the tree observed at authoring time.

## Exact Text to Insert (copy verbatim; line breaks inside a line group may differ only as stated; no blank line may be introduced)

Insertion S, appended to step 2 of `## Procedure` in `.claude/skills/parallel-add/SKILL.md` and in its bundled mirror. It goes directly after the existing last line of step 2, which reads (anchor, unique in each file): `   the item's model from that band at spawn time per `parallel-orchestrate` `## Model Selection`.` The nine inserted lines are indented three spaces as list-item continuation, and the blank line that precedes `3. **Compute conflict edges` stays in place:

```text
   For an issue-number item, the preparation delegation prompt carries the issue-adoption line used
   by `/parallel-plan` `## Preparation Fan-Out`, quoted verbatim: `Issue adoption: this item's GitHub
   issue already exists. Verify it read-only (gh issue view), do not call potential_to_issue or the
   promotion-entry tool, and record a top-level issue_adoption object in the checkpoint per
   .claude/rules/orchestrator-state.md with origin filed_before_orchestration (or transferred when
   the issue was transferred), waiving potential_to_issue and the promotion-entry tool for the
   checkpoint's promotion-type. When a lifecycle record for the item exists under
   docs/features/potential/promoted/, cite it as potential_record.` The line is omitted for a
   potential-entry item, whose child promotes it.
```

Authoring constraints verified against Insertion S at authoring time (the executor must not alter the text in a way that breaks them): the text contains no digit; contains none of the three mode markers `Epic mode: true`, `Parallel mode: true`, `Preparation mode: true`; contains no `docs/features/active/` path; and contains no sequence matching the hook issue-number pattern `issue(?:[_-]?num(?:ber)?|\s+number)\s*[:=]\s*#?(\d+)` (every occurrence of `issue-number` is followed by ` item`, and every `Issue adoption:` or `issue_adoption` has `adoption` rather than `num` after `issue`). After whitespace collapse, the text between the backticks that open at `Issue adoption:` and close after `potential_record.` is equal to the `/parallel-plan` line `.claude/skills/parallel-plan/SKILL.md` line 116 with its leading `> ` and the enclosing backticks removed.

Test-file insertions (P1-T2 through P1-T4). Black may re-wrap code lines, and Ruff E501 may require re-wrapping a docstring or comment line; no identifier, literal value, or assertion changes.

Constant insertion A, directly after the existing line `ORCHESTRATOR_STATE_RULE = Path(".claude/rules/orchestrator-state.md")`:

```python
PARALLEL_ADD_SKILL = Path(".claude/skills/parallel-add/SKILL.md")
```

Constant insertion B, directly after the existing line `INVARIANTS_HEADING = "## Invariants (issue_adoption object)"`:

```python
PROCEDURE_HEADING = "## Procedure"
STEP_TWO_START = "2. **Prepare the item.**"
STEP_THREE_START = "3. **Compute conflict edges"
```

Constant insertion C, directly before the existing comment line `# The issue-number shape the preimplementation-gate hook resolves from a prompt.`, followed by one blank line:

```python
# The quoted issue-adoption line in parallel-add step 2, matched on collapsed text.
ADOPTION_SPAN = re.compile(r"`(Issue adoption:[^`]*)`")
CONDITION_FRAGMENT = "an issue-number item, the preparation delegation prompt"
OMISSION_FRAGMENT = "omitted for a potential-entry item, whose child promotes it"
STEP_TWO_ADOPTION_FRAGMENTS: tuple[str, ...] = (
    "Verify it read-only (gh issue view)",
    "do not call potential_to_issue or the promotion-entry tool",
    "record a top-level issue_adoption object",
)
```

Helper insertion D, directly after the end of the existing function `_element_four_text` and before the existing line `ADDED_TEXT_SOURCES: dict[str, Callable[[], str]] = {`, with two blank lines between top-level definitions:

```python
def _parallel_add_step_two_text() -> str:
    """Return step 2 of the parallel-add ``## Procedure`` list, joined.

    Raises:
        AssertionError: If the step 2 or step 3 line cannot be located.
    """

    section = extract_section(read_repo_text(PARALLEL_ADD_SKILL), PROCEDURE_HEADING)
    lines = section.splitlines()
    starts = [
        index for index, line in enumerate(lines) if line.startswith(STEP_TWO_START)
    ]
    ends = [
        index for index, line in enumerate(lines) if line.startswith(STEP_THREE_START)
    ]
    if len(starts) != 1 or len(ends) != 1 or ends[0] <= starts[0]:
        raise AssertionError(
            f"parallel-add step 2 boundaries not found: starts={starts}, ends={ends}"
        )
    return "\n".join(lines[starts[0] : ends[0]])


def _step_two_adoption_text() -> str:
    """Return the quoted issue-adoption line from parallel-add step 2, collapsed.

    Raises:
        AssertionError: If step 2 does not hold exactly one quoted adoption span.
    """

    collapsed = collapse_whitespace(_parallel_add_step_two_text())
    spans = ADOPTION_SPAN.findall(collapsed)
    if len(spans) != 1:
        raise AssertionError(
            "expected exactly one quoted adoption span in parallel-add step 2, "
            f"found {len(spans)}"
        )
    return spans[0]


def _step_two_text_requiring_adoption() -> str:
    """Return step 2 text, failing when the adoption span is absent.

    A text-exclusion check over step 2 as it stood before the adoption sentence
    was added would pass without examining any added text, so presence is first.
    """

    _step_two_adoption_text()
    return _parallel_add_step_two_text()
```

Registry insertion E: in the existing `ADDED_TEXT_SOURCES` dictionary, add as the first entry, above `"parallel-plan-adoption-line": _adoption_line,`:

```python
    "parallel-add-step-two": _step_two_text_requiring_adoption,
```

Test insertion F, appended at the end of the file after `test_skill_states_origin_conditional_potential_record`, with two blank lines between tests:

```python
def test_parallel_add_step_two_carries_issue_adoption_instruction() -> None:
    """Step 2 tells the preparation child to adopt the issue read-only."""

    # Arrange
    adoption = _step_two_adoption_text()

    # Act / Assert
    for fragment in STEP_TWO_ADOPTION_FRAGMENTS:
        assert fragment in adoption, f"step 2 adoption text lacks: {fragment}"


def test_parallel_add_step_two_adoption_line_equals_parallel_plan_line() -> None:
    """Step 2 quotes the parallel-plan adoption line after whitespace collapse."""

    # Arrange
    plan_line = collapse_whitespace(_adoption_line())

    # Act
    expected = plan_line.removeprefix("> `").removesuffix("`")
    actual = _step_two_adoption_text()

    # Assert
    assert actual == expected, f"parallel-add adoption text drifted: {actual}"


def test_parallel_add_step_two_adoption_is_issue_number_only() -> None:
    """Step 2 conditions the line on issue-number items and omits it otherwise."""

    # Arrange
    collapsed = collapse_whitespace(_parallel_add_step_two_text())
    span = ADOPTION_SPAN.search(collapsed)

    # Act
    condition_at = collapsed.find(CONDITION_FRAGMENT)
    omission_at = collapsed.find(OMISSION_FRAGMENT)

    # Assert
    assert span is not None, "parallel-add step 2 lacks the quoted adoption span"
    assert 0 <= condition_at < span.start(), "condition does not precede the line"
    assert span.end() < omission_at, "omission does not follow the line"


def test_parallel_add_step_two_adoption_carries_no_mode_marker() -> None:
    """Step 2 carries no epic, parallel, or preparation mode marker."""

    # Arrange
    text = _step_two_text_requiring_adoption()

    # Act
    present = [marker for marker in MODE_MARKERS if marker in text]

    # Assert
    assert present == [], f"parallel-add step 2 carries mode markers: {present}"
```

New test node IDs (all prefixed `tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py::`), five in total:

1. `test_parallel_add_step_two_carries_issue_adoption_instruction`
2. `test_parallel_add_step_two_adoption_line_equals_parallel_plan_line`
3. `test_parallel_add_step_two_adoption_is_issue_number_only`
4. `test_parallel_add_step_two_adoption_carries_no_mode_marker`
5. `test_added_skill_text_does_not_match_hook_issue_number_pattern[parallel-add-step-two]` (the existing parametrized test, extended by registry insertion E; it also asserts that the step 2 text does not contain `docs/features/active/`)

The existing test file has 11 collected nodes (the 9 test functions of which two are parametrized twice), so the edited file collects 16. Before the skill edit, all five new nodes fail with an `AssertionError` (the step 2 text holds no quoted adoption span) and the 11 existing nodes pass; after the skill edit all 16 pass.

## AC-to-Task Traceability

| AC | Implementation tasks | Verification tasks | Evidence (under the feature folder) | Check-off task |
| --- | --- | --- | --- | --- |
| AC-1 | P1-T7, P1-T8 | P1-T11 (nodes 1, 2) | `evidence/regression-testing/pass-after-adoption-contracts.<ts>.md` | P1-T13 |
| AC-2 | P1-T7, P1-T8 | P1-T11 (node 3) | same as AC-1 | P1-T14 |
| AC-3 | P1-T7, P1-T8 | P1-T11 (nodes 4, 5) | same as AC-1 | P1-T15 |
| AC-4 | P1-T7 | P1-T10, P1-T12 | `evidence/other/step-two-diff-scope.<ts>.md`, `evidence/regression-testing/pass-after-suite.<ts>.md` | P1-T16 |
| AC-5 | P1-T8 | P1-T9, P1-T12 | `evidence/other/mirror-hash-identity.<ts>.md`, `evidence/regression-testing/pass-after-suite.<ts>.md` | P1-T17 |
| AC-6 | P1-T2, P1-T3, P1-T4 | P1-T5, P1-T6, P1-T11 | `evidence/regression-testing/fail-before-adoption-contracts.<ts>.md`, `evidence/regression-testing/pass-after-adoption-contracts.<ts>.md` | P1-T18 |
| AC-7 | P1-T2 through P1-T4 | P1-T12, P2-T1 through P2-T5 | `evidence/regression-testing/pass-after-suite.<ts>.md`, `evidence/qa-gates/final-black.<ts>.md`, `evidence/qa-gates/final-ruff.<ts>.md`, `evidence/qa-gates/final-pyright.<ts>.md`, `evidence/qa-gates/final-pytest-suite.<ts>.md` | P2-T10 |
| AC-8 | all edits | P2-T8 | `evidence/qa-gates/final-scope-boundary.<ts>.md` | P2-T11 |

### Phase 0 — Baseline Capture

- [x] [P0-T1] Read `CLAUDE.md` (policy order step 1). Acceptance: listed in position 1 in `docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/evidence/baseline/phase0-instructions-read.md` (written by P0-T6).
- [x] [P0-T2] Read `.claude/rules/general-code-change.md` (policy order step 2). Acceptance: listed in position 2 in the P0-T6 artifact.
- [x] [P0-T3] Read `.claude/rules/general-unit-test.md` (policy order step 3). Acceptance: listed in position 3 in the P0-T6 artifact.
- [x] [P0-T4] Read `.claude/rules/python.md` (policy order step 4, Python). Acceptance: listed in position 4 in the P0-T6 artifact.
- [x] [P0-T5] Read `.claude/rules/python-suppressions.md` (policy order step 4, Python). Acceptance: listed in position 5 in the P0-T6 artifact.
- [x] [P0-T6] Write `docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/evidence/baseline/phase0-instructions-read.md` containing `Timestamp:`, `Policy Order: CLAUDE.md -> general-code-change -> general-unit-test -> python -> python-suppressions`, and an explicit numbered list of the five repository-relative paths read in P0-T1 through P0-T5. Acceptance: the file exists and carries all three fields.
- [x] [P0-T7] Write `docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/evidence/baseline/baseline-feature-folder-listing.<ts>.md` recording `git ls-files --cached --others --exclude-standard -- docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885` with the four fields; `Output Summary:` holds every printed path. Acceptance: `EXIT_CODE: 0`; the output lists `issue.md`, `plan.2026-10-11T07-58.md`, and `research/research.2026-10-11T08-05.md` of the feature folder; the output contains neither `spec.md` nor `user-story.md`. A listed `spec.md` or `user-story.md` is reported to the caller and Phase 1 does not begin, because minor-audit mode fails closed when either exists.
- [x] [P0-T8] Write `docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/evidence/baseline/baseline-git-branch.<ts>.md` recording `git rev-parse --abbrev-ref HEAD` with the four fields. Acceptance: `EXIT_CODE: 0` and the output is `bug/parallel-add-children-not-told-to-record-issue-adoption-885`. A different branch name is reported to the caller and Phase 1 does not begin.
- [x] [P0-T9] Write `docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/evidence/baseline/baseline-git-head.<ts>.md` recording `git rev-parse HEAD` with the four fields and `BaselineHeadSha: <40-character hash>`. Acceptance: `EXIT_CODE: 0` and the output is a 40-character hexadecimal hash.
- [x] [P0-T10] Write `docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/evidence/baseline/baseline-parallel-add-hash.<ts>.md` recording `git hash-object .claude/skills/parallel-add/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md` with the four fields and `BaselineParallelAddHash: <hash>` copied from the first output line. Acceptance: `EXIT_CODE: 0`; the command prints two lines and they are equal; the expected value of both is `39dfca6d036d1425d892a67978ab1bc995828d83` (orchestrator-observed on origin/main `2ef8d361e`). A value that differs from the expected one but is equal across both lines is recorded verbatim and reported to the caller without stopping; two unequal lines are reported to the caller and Phase 1 does not begin.
- [x] [P0-T11] Write `docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/evidence/baseline/baseline-black-check.<ts>.md` recording the check-mode (non-writing) run `poetry run black --check tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py 2>&1` with the four fields; `Output Summary:` holds the final summary line verbatim. Acceptance: the artifact exists with all four fields populated from the observed run; on a clean tree the line is `1 file would be left unchanged.`. The baseline records state and does not require exit 0.
- [x] [P0-T12] Write `docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/evidence/baseline/baseline-ruff-check.<ts>.md` recording `poetry run ruff check --no-fix tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py` with the four fields; `Output Summary:` records `All checks passed!` when printed, otherwise the finding-count line. Acceptance: the artifact exists with all four fields.
- [x] [P0-T13] Write `docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/evidence/baseline/baseline-pyright.<ts>.md` recording `poetry run pyright tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py` with the four fields; `Output Summary:` holds the final `<n> errors, <n> warnings, <n> informations` line verbatim. Acceptance: the artifact exists with all four fields and the verbatim summary line.
- [x] [P0-T14] Write `docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/evidence/baseline/baseline-pytest-adoption-file.<ts>.md` recording `poetry run pytest tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py -v -p no:cacheprovider --no-cov` with the four fields; `Output Summary:` lists every node line and the result line, plus `BaselineAdoptionPassCount: <n>`. Acceptance: `EXIT_CODE: 0` with no failed count; the expected passed count is `11` (the 11 nodes enumerated from the test file at authoring time); any other result is recorded verbatim and reported to the caller before Phase 1 begins.
- [x] [P0-T15] Write `docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/evidence/baseline/baseline-pytest-suite.<ts>.md` recording `poetry run pytest tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q -p no:cacheprovider --no-cov` with the four fields; `Output Summary:` holds the verbatim result line, `BaselineSuitePassCount: <n>`, and `BaselineSuiteFailingNodes:` (every `FAILED` and `ERROR` line of the `-ra` short summary, or `none`). Record `ExpectedExitCode:` equal to the observed exit code. Acceptance: the artifact exists and `BaselineSuitePassCount:` holds an integer. A non-empty `BaselineSuiteFailingNodes:` is reported to the caller before Phase 1 begins, because AC-7 requires this suite to pass.
- [x] [P0-T16] Write `docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/evidence/baseline/baseline-test-line-count.<ts>.md` recording the single-line probe `poetry run python -c "import pathlib; print(len(pathlib.Path('tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py').read_text(encoding='utf-8').splitlines()))"` with the four fields and `BaselineTestLineCount: <n>`. Acceptance: `EXIT_CODE: 0` and the output is a single integer; the expected value is `268` (the line count read at authoring time).
- [x] [P0-T17] Stage the Phase 0 files: `git add docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/evidence/baseline docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/plan.2026-10-11T07-58.md docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/issue.md docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/research/research.2026-10-11T08-05.md`, after setting `[x]` on P0-T1 through P0-T16 in this plan. Acceptance: `git status --porcelain --untracked-files=all -- docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885` prints no line beginning with `??` or ` M` (every change in the folder is staged).
- [x] [P0-T18] Commit the staged Phase 0 files: `git commit -m "docs(885): record Phase 0 baseline evidence and plan"`. Acceptance: the command exits 0 and `git status --porcelain --untracked-files=all -- docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885` prints nothing.
- [x] [P0-T19] Push the branch: `git push origin bug/parallel-add-children-not-told-to-record-issue-adoption-885` (no force flag). Acceptance: the command exits 0, and `git ls-remote origin refs/heads/bug/parallel-add-children-not-told-to-record-issue-adoption-885` prints a line whose hash equals the output of `git rev-parse HEAD`. After the push, set `[x]` on P0-T17 through P0-T19; that plan change is committed with the Phase 1 boundary commit.

### Phase 1 — Constrained Implementation (delegated small-path implementation via atomic-executor)

Constraints for every Phase 1 task:

- The Markdown edit inserts the exact text of Insertion S and changes no other byte of either skill file; the mirror edit is the same insertion at the same anchor, made after the source edit.
- Test-file edits insert the exact code quoted in `## Exact Text to Insert`; no existing assertion, test, constant, helper, or import is modified, renamed, or removed; the only change to an existing statement is the added first entry of `ADDED_TEXT_SOURCES`.
- Each new test follows Arrange-Act-Assert and carries a one-line docstring.
- No suppression comment is added in any file.
- No file outside the three scope files, `issue.md`, this plan, and the named evidence artifacts is written.

- [x] [P1-T1] Write `docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/evidence/other/phase1-handoff.<ts>.md` recording the delegation, by `atomic-executor`, of P1-T2 through P1-T5 (test-file edits) to `python-typed-engineer` and of P1-T7 and P1-T8 (Markdown edits) and the remaining Phase 1 tasks to `atomic-executor` itself, with `Timestamp:`, `Delegates:`, `Scope: P1-T2..P1-T21`, and the Phase 1 constraints list copied from this plan. When the executing session has no delegation tool, record `DelegationAvailable: false` and perform all tasks in `atomic-executor`. Acceptance: the file exists with those items; Phase 1 is complete only when every task P1-T2 through P1-T21 meets its acceptance condition.
- [x] [P1-T2] Edit `tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py`: add constant insertions A, B, and C exactly as quoted in `## Exact Text to Insert`, each at its stated anchor. Acceptance: `poetry run python -c "import tests.scripts.dev_tools.test_parallel_issue_adoption_skill_contracts as m; print(m.PARALLEL_ADD_SKILL.as_posix(), m.PROCEDURE_HEADING, m.ADOPTION_SPAN.pattern)"` exits 0 and prints a line beginning `.claude/skills/parallel-add/SKILL.md ## Procedure` (the `as_posix()` call keeps the printed separators forward slashes on Windows).
- [x] [P1-T3] Edit `tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py`: add helper insertion D and registry insertion E exactly as quoted in `## Exact Text to Insert`. This task creates the three helper definitions `_parallel_add_step_two_text`, `_step_two_adoption_text`, and `_step_two_text_requiring_adoption` and the registry key `parallel-add-step-two`. Acceptance: `poetry run python -c "import tests.scripts.dev_tools.test_parallel_issue_adoption_skill_contracts as m; print(sorted(m.ADDED_TEXT_SOURCES))"` exits 0 and prints `['parallel-add-step-two', 'parallel-orchestrate-element-four', 'parallel-plan-adoption-line']`.
- [x] [P1-T4] Edit `tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py`: append test insertion F (the four tests) exactly as quoted in `## Exact Text to Insert`. Acceptance: the four function names `test_parallel_add_step_two_carries_issue_adoption_instruction`, `test_parallel_add_step_two_adoption_line_equals_parallel_plan_line`, `test_parallel_add_step_two_adoption_is_issue_number_only`, and `test_parallel_add_step_two_adoption_carries_no_mode_marker` are collected in P1-T5.
- [x] [P1-T5] Collect the edited test file: `poetry run pytest tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py --collect-only -q -p no:cacheprovider --no-cov`. Acceptance: exit code 0; the count line reads `16 tests collected`; the output lists the four function names of P1-T4 and the node `tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py::test_added_skill_text_does_not_match_hook_issue_number_pattern[parallel-add-step-two]`.
- [x] [P1-T6] [expect-fail] Write `docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/evidence/regression-testing/fail-before-adoption-contracts.<ts>.md` recording `poetry run pytest tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py -v -p no:cacheprovider --no-cov`, run BEFORE P1-T7 edits any skill file, with the four fields and `ExpectedExitCode: 1`; `Output Summary:` lists every node line and the result line. Acceptance: `EXIT_CODE: 1`; the result line reads `5 failed, 11 passed`; the five new node IDs listed in `## Exact Text to Insert` are listed `FAILED`; the 11 pre-existing nodes are listed `PASSED`. A different result stops Phase 1 and is reported to the caller.
- [x] [P1-T7] Edit `.claude/skills/parallel-add/SKILL.md`: insert Insertion S exactly as quoted in `## Exact Text to Insert`, directly after the existing step-2 line that ends `per `parallel-orchestrate` `## Model Selection`.`. Acceptance: verified by P1-T10 (a single nine-line insertion inside step 2, no removed line).
- [x] [P1-T8] Edit `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md`: insert Insertion S at the same anchor, so the file text equals the edited source. Acceptance: verified by P1-T9 (equal `git hash-object` values).
- [x] [P1-T9] Write `docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/evidence/other/mirror-hash-identity.<ts>.md` recording `git hash-object .claude/skills/parallel-add/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md` with the four fields. Acceptance: `EXIT_CODE: 0`; the two printed hashes are equal; the hash differs from `BaselineParallelAddHash` recorded by P0-T10.
- [x] [P1-T10] Write `docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/evidence/other/step-two-diff-scope.<ts>.md` recording `git diff -U0 HEAD -- .claude/skills/parallel-add/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md` (anchored to `HEAD`, which is the Phase 0 commit, before any skill edit is committed) with the four fields; `Output Summary:` holds both files' hunk header lines verbatim. Acceptance: `EXIT_CODE: 0`; each of the two files shows exactly one hunk whose header has the form `@@ -N,0 +M,9 @@` with `M` equal to `N` plus 1; each hunk body is nine lines each beginning `+` and no line beginning `-` other than the `---` file header; the `+` body of the first file equals the `+` body of the second file; the inserted lines read as Insertion S. This establishes that nothing in `2. **Prepare the item.**` or `3. **Compute conflict edges` or any line from step 3 onward changed.
- [x] [P1-T11] Write `docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/evidence/regression-testing/pass-after-adoption-contracts.<ts>.md` recording `poetry run pytest tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py -v -p no:cacheprovider --no-cov` with the four fields; `Output Summary:` lists every node line and the result line. Acceptance: `EXIT_CODE: 0`; the result line reads `16 passed`; the five new node IDs listed in `## Exact Text to Insert` are listed `PASSED`.
- [x] [P1-T12] Write `docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/evidence/regression-testing/pass-after-suite.<ts>.md` recording the P0-T15 command with `-q` replaced by `-v`: `poetry run pytest tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -v -p no:cacheprovider --no-cov`, with the four fields, every node line, the result line, and `PostSuiteFailingNodes:` (every `FAILED` and `ERROR` line, or `none`). Acceptance: `EXIT_CODE: 0`; `PostSuiteFailingNodes: none`; the passed count equals `BaselineSuitePassCount` (P0-T15) plus 5; these nodes are listed `PASSED`: `tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py::test_parallel_add_requires_complexity_assessment`, `tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py::test_parallel_add_step_two_defers_model_to_parallel_orchestrate`, and `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`.
- [x] [P1-T13] Edit `docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/issue.md`: change the literal `- [ ] AC-1:` to `- [x] AC-1:`, only if P1-T11 met its acceptance condition (nodes 1 and 2 of the new-test list `PASSED`). Acceptance: `grep -c -F "[x] AC-1:" docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/issue.md` prints `1`.
- [x] [P1-T14] Edit `docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/issue.md`: change the literal `- [ ] AC-2:` to `- [x] AC-2:`, only if P1-T11 met its acceptance condition (node 3 `PASSED`). Acceptance: `grep -c -F "[x] AC-2:" docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/issue.md` prints `1`.
- [x] [P1-T15] Edit `docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/issue.md`: change the literal `- [ ] AC-3:` to `- [x] AC-3:`, only if P1-T11 met its acceptance condition (nodes 4 and 5 `PASSED`). Acceptance: `grep -c -F "[x] AC-3:" docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/issue.md` prints `1`.
- [x] [P1-T16] Edit `docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/issue.md`: change the literal `- [ ] AC-4:` to `- [x] AC-4:`, only if P1-T10 and P1-T12 met their acceptance conditions (the two existing complexity-routing nodes that slice step 2 between the two markers are `PASSED`). Acceptance: `grep -c -F "[x] AC-4:" docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/issue.md` prints `1`.
- [x] [P1-T17] Edit `docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/issue.md`: change the literal `- [ ] AC-5:` to `- [x] AC-5:`, only if P1-T9 and P1-T12 met their acceptance conditions (equal hashes; the bundle-parity node `PASSED`). Acceptance: `grep -c -F "[x] AC-5:" docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/issue.md` prints `1`.
- [x] [P1-T18] Edit `docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/issue.md`: change the literal `- [ ] AC-6:` to `- [x] AC-6:`, only if P1-T6 (five new nodes `FAILED` before the skill edit) and P1-T11 (the same five nodes `PASSED` after it) met their acceptance conditions. Acceptance: `grep -c -F "[x] AC-6:" docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/issue.md` prints `1`.
- [x] [P1-T19] Stage the Phase 1 files: `git add .claude/skills/parallel-add/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/issue.md docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/plan.2026-10-11T07-58.md docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/evidence/other docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/evidence/regression-testing`, after setting `[x]` on P1-T1 through P1-T18 in this plan. Acceptance: `git status --porcelain --untracked-files=all` prints no line beginning `??` or ` M`; every printed line begins with `A ` or `M `.
- [x] [P1-T20] Commit the staged Phase 1 files: `git commit -m "fix(885): tell parallel-add preparation children to record issue adoption"`. Acceptance: the command exits 0 and `git status --porcelain --untracked-files=all` prints nothing.
- [x] [P1-T21] Push the branch: `git push origin bug/parallel-add-children-not-told-to-record-issue-adoption-885` (no force flag). Acceptance: the command exits 0, and `git ls-remote origin refs/heads/bug/parallel-add-children-not-told-to-record-issue-adoption-885` prints a line whose hash equals the output of `git rev-parse HEAD`. After the push, set `[x]` on P1-T19 through P1-T21; that plan change is committed with the Phase 2 boundary commit.

### Phase 2 — Final QC Loop and Acceptance Check-Off

Loop rule: run P2-T1 through P2-T8 in order. If any of them does not meet its acceptance condition, or P2-T1 reformats a file, fix the cause and restart from P2-T1, writing a new timestamped artifact for each rerun command. The loop is complete only when P2-T1 through P2-T8 meet their acceptance conditions in a single pass; P2-T9 records that pass. No task in this phase may be recorded as `SKIPPED`; every command task below is unconditional. The Python test-suite failures that this phase tolerates are none: any failing node restarts the loop, because the baseline in P0-T15 required an empty failing-node list.

- [x] [P2-T1] Write `docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/evidence/qa-gates/final-black.<ts>.md`: first record `PrePassStatus:` as the output of `git status --porcelain -- tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py`, then run the write-mode formatter `poetry run black tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py 2>&1`, record the four fields with the summary lines verbatim, and then record `PostPassStatus:` as the output of the same `git status --porcelain` command. Acceptance: `EXIT_CODE: 0`; the output contains `All done!` and the line `1 file left unchanged.`; the output does not contain `reformatted`; `PrePassStatus:` and `PostPassStatus:` are identical (a before-and-after tree observation, because Black exits 0 whether or not it rewrote the file). A run that prints `1 file reformatted.` restarts the loop.
- [x] [P2-T2] Write `docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/evidence/qa-gates/final-ruff.<ts>.md` recording `poetry run ruff check tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py` (no `--fix` flag; the project configuration does not enable fixing) with the four fields and `PostPassStatus:` as the output of `git status --porcelain -- tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py` after the run. Acceptance: `EXIT_CODE: 0`; the output contains `All checks passed!`; `PostPassStatus:` equals the `PostPassStatus:` of P2-T1.
- [x] [P2-T3] Write `docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/evidence/qa-gates/final-pyright.<ts>.md` recording `poetry run pyright tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py` with the four fields and the summary line verbatim. Acceptance: `EXIT_CODE: 0` and the summary line is `0 errors, 0 warnings, 0 informations`.
- [x] [P2-T4] Write `docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/evidence/qa-gates/final-pytest-adoption-file.<ts>.md` recording `poetry run pytest tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py -v -p no:cacheprovider --no-cov` with the four fields, every node line, and the result line. Acceptance: `EXIT_CODE: 0`; the result line reads `16 passed`; the five new node IDs listed in `## Exact Text to Insert` are listed `PASSED`.
- [x] [P2-T5] Write `docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/evidence/qa-gates/final-pytest-suite.<ts>.md` recording the P1-T12 command rerun unchanged, with the four fields, the result line, and `FinalSuiteFailingNodes:` (every `FAILED` and `ERROR` line, or `none`). Acceptance: `EXIT_CODE: 0`; `FinalSuiteFailingNodes: none`; the passed count equals `BaselineSuitePassCount` (P0-T15) plus 5.
- [x] [P2-T6] Write `docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/evidence/qa-gates/final-mirror-hash.<ts>.md` recording `git hash-object .claude/skills/parallel-add/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md` with the four fields. Acceptance: `EXIT_CODE: 0`; the two printed hashes are equal to each other and to the hash recorded by P1-T9.
- [x] [P2-T7] Write `docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/evidence/qa-gates/final-test-line-count.<ts>.md` recording the P0-T16 probe command rerun unchanged, with the four fields, `BaselineTestLineCount:` copied from P0-T16, and `FinalTestLineCount: <n>`. Acceptance: `EXIT_CODE: 0`; `FinalTestLineCount` is greater than `BaselineTestLineCount` and less than `500` (the file-size limit of `.claude/rules/general-code-change.md`; the expected value is about 386, which is 268 plus roughly 118 inserted lines, and only the bounds above are asserted).
- [x] [P2-T8] Write `docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/evidence/qa-gates/final-scope-boundary.<ts>.md` recording, in this order, `git status --porcelain --untracked-files=all`, then `git fetch origin main`, then `git diff --name-only origin/main...HEAD`, with the four fields for each command (the second and third recorded as `ExitCode2:` and `ExitCode3:`). Acceptance: every path listed by the `git diff --name-only` span, and every path listed by the `git status --porcelain` span, is one of: the three files named under "Files this plan writes outside the feature folder" in `## Conventions for This Plan`, or a path beginning with `docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/`; no listed path begins with `.claude/rules/`, `.github/`, `.agents/`, `.codex/`, `scripts/`, `src/`, `extensions/drm-copilot/src/`, or `extensions/drm-copilot/resources/claude-customizations/pack-manifests/`; the only listed path under `.claude/` is `.claude/skills/parallel-add/SKILL.md`. This also proves that no production Python or TypeScript path changed, which is the basis of the coverage statement.
- [x] [P2-T9] Write `docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/evidence/qa-gates/final-loop-single-pass.<ts>.md` listing the artifact paths of the last P2-T1 through P2-T8 run and the `PostPassStatus:` values of the last P2-T1 and P2-T2 artifacts. Acceptance: every listed artifact records its acceptance literal, and the two `PostPassStatus:` values are identical; if they differ, the loop restarts.
- [x] [P2-T10] Edit `docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/issue.md`: change the literal `- [ ] AC-7:` to `- [x] AC-7:`, only if P1-T12, P2-T1 through P2-T5, and P2-T9 met their acceptance conditions (the issue-adoption, complexity-routing, planner-surface, and bundle-parity tests pass; Black, Ruff, and Pyright are clean for the edited test file). Acceptance: `grep -c -F "[x] AC-7:" docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/issue.md` prints `1`.
- [x] [P2-T11] Edit `docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/issue.md`: change the literal `- [ ] AC-8:` to `- [x] AC-8:`, only if P2-T8 met its acceptance condition (no path under `.claude/rules/` or `.github/instructions/` is changed). Acceptance: `grep -c -F "[x] AC-8:" docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/issue.md` prints `1`.
- [x] [P2-T12] Write `docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/evidence/other/reduced-audit-handoff.<ts>.md` (reduced-audit handoff note) containing `Timestamp:`; `AuditMode: minor-audit`; `AuditAgent: feature-review`; `RequirementsSource:` naming `issue.md` `## Acceptance Criteria` (AC-1 through AC-8); `AcStatus:` listing each AC as checked or unchecked as recorded in `issue.md`; `Phase0Artifacts:`, `RegressionArtifacts:`, and `QcArtifacts:` listing every artifact path written by Phase 0, Phase 1, and Phase 2; `ReducedArtifactChecks:` stating that the audit verifies the Phase 0 instructions-read artifact, one baseline artifact and one final artifact per command, the fail-before artifact of P1-T6 and the pass-after artifact of P1-T11, and the equal hashes of P2-T6; `CoverageStatement:` stating that no production Python or TypeScript changed (P2-T8), so no coverage-mode run was planned and no coverage value is asserted; and `OutOfScope:` stating that pull-request authoring and CI are handled after this run. Acceptance: the file exists and carries every named field.
- [x] [P2-T13] Stage the Phase 2 files: `git add docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/issue.md docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/plan.2026-10-11T07-58.md docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/evidence/qa-gates docs/features/active/2026-10-11-parallel-add-children-not-told-to-record-issue-adoption-885/evidence/other tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py`, after setting `[x]` on every Phase 2 task whose acceptance condition is met and whose artifact exists with complete fields (P2-T1 through P2-T12, and P2-T13 itself). The test file is staged so that a Black reformat in P2-T1 is captured; when Black changed nothing it stages no change. Acceptance: `git status --porcelain --untracked-files=all` prints no line beginning `??` or ` M`.
- [x] [P2-T14] Commit the staged Phase 2 files: `git commit -m "docs(885): record final QC evidence and acceptance check-off"`. Acceptance: the command exits 0 and `git status --porcelain --untracked-files=all` prints nothing.
- [x] [P2-T15] Push the branch: `git push origin bug/parallel-add-children-not-told-to-record-issue-adoption-885` (no force flag). Acceptance: the command exits 0, and `git ls-remote origin refs/heads/bug/parallel-add-children-not-told-to-record-issue-adoption-885` prints a line whose hash equals the output of `git rev-parse HEAD`. After the push, set `[x]` on P2-T14 and P2-T15 as a worktree-only plan change and report it in the handoff; it is carried by the orchestrator's next checkpoint commit and is not committed by this plan.
