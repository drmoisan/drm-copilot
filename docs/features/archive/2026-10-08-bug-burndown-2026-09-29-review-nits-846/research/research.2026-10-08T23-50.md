# Research: bug-burndown-2026-09-29 review nits (Issue #846)

- Timestamp: 2026-10-08T23-50 (taken from the orchestrator-supplied artifact name; this researcher session has no tool that reads the host clock)
- Mode: preparation-mode research, kind `bug`
- Branch: `bug/bug-burndown-2026-09-29-review-nits-846` (based on `origin/main` `e7d3779b`)
- Requirements source: `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/issue.md`
- Tools used: Read, Grep, Glob, WebFetch. No shell was available to this session, so no command in this document was executed by the researcher. Every "Expected output" below is derived from code reading or from prior recorded evidence and must be observed by the executor. Two git facts (commits `0c6abb95` and `65e331e6`) were verified by fetching the public GitHub `.patch` view of each commit.

## Scope Rules Applied

- Excluded: `extensions/drm-copilot/test/lib/validate/orchestration-handoff-authority-service.test.ts` (delivered by #844). It must not be edited.
- In scope: the split of `extensions/drm-copilot/test/subagent-tree-command.test.ts` (#647 CR-3, second half).
- #543 CR-11: only `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/other/python-batch-budget.2026-10-02T05-01.md` may be edited in that folder.
- Stale document or evidence findings: superseding note or text correction; nothing is deleted. Where a text correction replaces a value, the original value is retained in the corrected text.

## Summary of Findings

| Item | Finding | Still holds | Disposition |
|---|---|---|---|
| #734 CR-1 | test at `test_quality_tiers_contract.py:434` lacks `-> None` | Yes | Rename and annotate (moves to the new split file) |
| #734 CR-2 | `quality_tiers_contract.py` 124, 155, 199 uncovered | Yes (lines re-read) | Add 4 parse cases |
| #734 CR-3 | test file at 495 lines | Yes (495) | Split required, because CR-2 pushes it past 500 |
| #734 CR-4 | QT009 drops git stderr | Yes | Append collapsed stderr to the `OSError` message |
| #744 CR-1 | skill sentence lacks cross-reference | Yes, in all 6 copies | Text edit in 6 copies, plus a pin test |
| #744 PA-2 | two synthesis artifacts lack `Command:`/`EXIT_CODE:` | Yes | Explicit closure, no edit |
| #744 CR-5 | `Timestamp: 2026-10-02T01-44` one minute late | Yes (per review observation) | In-file correction with `Timestamp-Correction:` |
| #647 CR-3 | `subagent-tree-command.test.ts` at 500 lines | Yes (500) | Split into 2 test files plus 1 support module |
| #623 (1) | Protocol-stub test exists only for coverage arcs | Yes | `partial_also` in `pyproject.toml`; remove the eighth test |
| #623 (2) | plan P5-T3 / header stale | Yes | Text correction with annotation |
| #623 (3) | Python docstring/comment parity | Yes (line numbers moved) | Docstring line plus comment |
| #764 (1) | `git grep -nxF` invalid | Yes | Text correction (plan lines 39, 40, 66) |
| #764 (2) | evidence filename stamps vs `Timestamp:` | Yes (11 files) | Superseding note, no rename |
| #764 (3) | `issue.md:5` folder path stale | Yes | Text correction |
| #338 CR-1 | AC-3 names `io.test.ts` | Yes | Text correction of AC-3 |
| #338 A1 | no whole-repo Python figure | Yes | Close: CI enforces it; record #846 run |
| #338 CR-3 | issue text cites bundled mirrors | Yes (3 lines) | Text correction |
| #338 residual | no live Windows observation | Yes | Explicit closure (already `scope_change`) |
| #609 | four stale point-in-time files | Yes | Superseding status summary |
| #543 CR-11 | header 05-18 later than commit 05:14:57 | Yes (verified via GitHub patch) | In-file text correction |
| #527 | no CHANGELOG `[Unreleased]` entry | Yes (`[Unreleased]` is empty) | Add entry |
| #510 | `spec.md` stale | Yes | Text correction |
| #723 refinement | publish success as primary signal | Not needed (see analysis) | Explicit closure plus a pinning test |
| #723 N1 | runbook section lacks `npm view` | Yes | Add command |
| #723 N3 | `exit 1` assertion too loose | Yes | Tighten assertion |

## Item #734 (quality-tiers.yml)

Source review: `docs/features/active/2026-09-27-quality-tiers-yml-missing-and-unenforced-734/code-review.2026-10-02T03-55.md`.

### Current state (verified)

- `tests/scripts/dev_tools/test_quality_tiers_contract.py`: 495 lines; 28 `def test_` functions; 5 `@pytest.mark.parametrize` decorators (lines 127, 244, 298, 362, 385) carrying 24 parameter cases (16 `pytest.param(...)` entries plus 4 + 2 + 2 plain list items). Derived collected count: 23 non-parametrized + 24 cases = 47. The collected count is derived, not observed; the executor must record `--collect-only` before and after.
- Line 434: `def test_find_classification_errors_empty_project_set_reports_qt007_for_every_entry():` (no return annotation).
- `scripts/dev_tools/quality_tiers_contract.py`:
  - Line 124: `continue` in `_UniqueKeySafeLoader.construct_mapping` when a mapping key is not a `yaml.ScalarNode`.
  - Line 155: `return 0, [_qt003(f"'version' must be the integer {SCHEMA_VERSION}")]` when `type(version) is not int` (covers `bool` and strings).
  - Line 199: `return [], [_qt003("missing required top-level key 'projects'")]`.
- Existing parametrized case `missing-version` (line 130) covers line 152 only; no case covers 155 or 199, and no test supplies a non-scalar key.
- `scripts/dev_tools/check_quality_tiers.py` lines 90-94: `runner(..., capture_output=True, check=False)`; on non-zero exit it raises `OSError(f"git ls-files exited with code {result.returncode}")`. `result.stderr` is captured and never read. The `GitRunResult` Protocol (lines 46-57) declares only `returncode` and `stdout`.
- QT009 pins: `tests/scripts/dev_tools/test_check_quality_tiers.py` lines 189, 214, 239, 261 assert only the 5-character code prefix (`line[:5]`). No test pins the QT009 message text. `_assert_failure_output` (lines 93-101) requires every stderr line to start with `QTnnn: `.
- `FakeRunResult` (lines 65-70) is a frozen dataclass with `returncode` and `stdout` only. File is 388 lines.

### CR-2 forces CR-3

Minimum CR-2 additions: three `pytest.param` entries in the existing QT003 matrix (`version-bool`, `version-string`, `missing-projects`, about 6-9 lines) and one new QT002 test for a non-scalar key (about 14 lines). 495 + about 20 = about 515, which exceeds 500. Even the parametrize-only additions reach about 503. A split is therefore required in the same change.

### Remediation

CR-2 cases (expected behavior from code reading; executor observes):
- `version: true` plus a valid `projects` list: `type(True) is not int` holds, so QT003 only, manifest not `None` (line 155).
- `version: "1"` plus valid `projects`: QT003 only (line 155).
- `version: 1\n` with no `projects`: QT003 only, manifest with no entries (line 199).
- Non-scalar key, for example text `"? [a, b]\n: 1\nversion: 1\n"`: the loop reaches line 124 (`continue`); PyYAML's base `construct_mapping` then raises `ConstructorError` for the unhashable list key, which `parse_quality_tiers` maps to `(None, [QT002])`. Assert the code list `["QT002"]` and `manifest is None`. Asserting the substring `unhashable` is optional and should be adopted only after the executor observes the message.

CR-3 split (mirror layout under `tests/scripts/dev_tools/`, precedent `test_potential_to_issue_filesystem.py` and `potential_to_issue_test_support.py`):
- `tests/scripts/dev_tools/test_quality_tiers_contract.py` (kept): parsing, rendering, and discovery tests (current lines 1-318: 18 functions) plus the CR-2 cases. Estimated 340-350 lines.
- `tests/scripts/dev_tools/test_quality_tiers_contract_classification.py` (new): `SPEC_TIER_ASSIGNMENTS`, entry-error, classification, and committed-tree tests (current lines 321-495: 10 functions), with CR-1 applied. Estimated 190-200 lines.
- `tests/scripts/dev_tools/quality_tiers_contract_test_support.py` (new): public helpers `qt_codes(errors)` and `make_manifest(*entries)` replacing the private `_codes` and `_manifest`. A support module avoids duplicating `_codes` and avoids importing a private name across test modules, which Pyright strict reports. The file name does not match pytest's `test_*.py` / `*_test.py` collection patterns.
- Rejected: a three-way split (parsing / discovery / classification) adds a file without a size need; duplicating `_codes` in both files conflicts with the reuse rule.

CR-1: in the new classification file, rename to `test_find_classification_errors_empty_projects_reports_qt007() -> None:` (75 characters including `def ` and the annotation; within 88). The docstring keeps the behavior description.

CR-4 (minimal change, `scripts/dev_tools/check_quality_tiers.py`):
- Add a `stderr: bytes` read-only property to `GitRunResult`, in the same multi-line form as `stdout` (its `...` body line is already excluded by the `^\s*\.\.\.\s*$` coverage pattern).
- On non-zero exit: `detail = " ".join(result.stderr.decode("utf-8", errors="replace").split())`; message `f"git ls-files exited with code {result.returncode}: {detail}"` when `detail` is non-empty, otherwise the current message. Collapsing whitespace is required: git stderr is multi-line, and `_report` prints one `QTnnn:` line per error; an embedded newline would produce a stderr line without the QT prefix and fail `_assert_failure_output`. The same collapse idiom already exists at `quality_tiers_contract.py:233`.
- Update the module docstring line 19 only if wording changes; the QT009 meaning is unchanged.
- Tests (`tests/scripts/dev_tools/test_check_quality_tiers.py`): add `stderr: bytes = b""` to `FakeRunResult`; add one test asserting that a non-zero exit with `stderr=b"fatal: not a git repository\n"` yields one stderr line starting `QT009: ` and containing `fatal: not a git repository`; add one test asserting a multi-line stderr is reported on one line (exactly one stderr line); the existing non-zero test (line 192) covers the empty-stderr branch. Estimated +40 lines (about 430).

### Verification (executor observes)

- `poetry run pytest tests/scripts/dev_tools/test_quality_tiers_contract.py tests/scripts/dev_tools/test_quality_tiers_contract_classification.py tests/scripts/dev_tools/test_check_quality_tiers.py --cov=scripts.dev_tools.quality_tiers_contract --cov=scripts.dev_tools.check_quality_tiers --cov-branch --cov-report=term-missing`. Expected: exit 0, no failures; the `quality_tiers_contract.py` row lists none of 124, 155, 199 in `Missing`.
- `poetry run pytest --collect-only -q` on the two quality-tiers contract files, before and after. Expected: post count equals pre count (47 derived) plus the cases added for CR-2.
- `grep -c ""` (or equivalent) on every edited or new test file: each value at most 500.
- Smoke: `poetry run python -m scripts.dev_tools.check_quality_tiers` prints one line starting `quality-tiers: OK (` and exits 0.

## Item #744 (completion-gate and tooling friction)

Folder: `docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/`.

### CR-1: all copies and their pins

Copies (6), each containing both `### CI-Dependent Criteria` and the uncross-referenced sentence:

| Path | `### CI-Dependent Criteria` line | Sentence line |
|---|---|---|
| `.claude/skills/acceptance-criteria-tracking/SKILL.md` | 73 | 91 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/acceptance-criteria-tracking/SKILL.md` | 73 | 91 |
| `.agents/skills/acceptance-criteria-tracking/SKILL.md` | 71 | 89 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/acceptance-criteria-tracking/SKILL.md` | 71 | 89 |
| `.github/skills/acceptance-criteria-tracking/SKILL.md` | 71 | 89 |
| `extensions/drm-copilot/resources/customizations/.github/skills/acceptance-criteria-tracking/SKILL.md` | 71 | 89 |

Current text (identical in all 6): `Orchestrators do not directly check off AC items. Instead:`

Proposed replacement (identical in all 6):
`Orchestrators do not directly check off AC items. The one exception is a CI-dependent criterion, which the item's own orchestrator run checks off at S9 as described in `### CI-Dependent Criteria` above. For every other criterion, orchestrators instead:`

Tests that pin these copies (all must pass after the edit):
- `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py`: `test_acceptance_criteria_tracking_skill_defines_ci_dependent_rule` (section `## Check-Off Protocol`, the three source copies) and `test_edited_surface_matches_bundled_mirror` (byte equality, ids `claude-ac-tracking`, `agents-ac-tracking`, `github-ac-tracking`).
- `tests/scripts/dev_tools/test_minor_audit_acceptance_criteria_contracts.py`: `.github` copy text-equal to its `customizations` mirror; `.github` copy contains "explicit `## Acceptance Criteria` section" (unaffected).
- `tests/scripts/dev_tools/test_csharp_orchestration_contracts.py` line 110-125: asserts only that the `customizations` mirror exists (unaffected).
- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`: every `.claude/**` file equals its bundle copy.
- Pack manifests (`.../pack-manifests/core.json`) list the path only; no hashes. No change needed.

Recommended pin: add one parametrized test to `test_completion_gate_documentation_contracts.py` (402 lines; about +20) asserting that the `## Check-Off Protocol` section of each of the three source copies contains the fragment `The one exception is a CI-dependent criterion`. Mirrors are covered by the existing byte-equality test.

CHANGELOG: not required for CR-1 (documentation clarification). Optional.

### PA-2: synthesis artifacts

`evidence/qa-gates/acceptance-criteria-checkoff.2026-09-30T03-18.md` and `evidence/other/ac-status-summary-local.2026-09-30T03-18.md` are summaries of other evidence; no command produced them. Adding `Command:` / `EXIT_CODE:` rows would record a command that was not run. The PR-context parser (`scripts/dev_tools/pr_context/verification_evidence.py` lines 119-149) classifies a file lacking `Command` as `unparseable` and the collector drops it, which matches the policy-audit statement that they are omitted. Recommendation: no edit; record an explicit closure in the #846 closure-disposition evidence (see "Evidence Plan for #846").

### CR-5: `pester-doc-contracts.2026-09-30T03-18.md`

- Line 3 reads `Timestamp: 2026-10-02T01-44`.
- Commit `65e331e6` (author date `Fri, 2 Oct 2026 01:44:04 -0400`, verified via the GitHub patch view) created the file with that value. The reviewer observed a file write time of 01:43:48 (`code-review.2026-10-02T02-55.md:25`, `policy-audit.2026-10-02T02-55.md:278`). A fresh checkout cannot reproduce the original write time, so the correction must cite the review observation.
- Recommendation: in-file text correction, consistent with the 27 PA-1 corrections already in this folder and with the review's recommendation. Change line 3 to `Timestamp: 2026-10-02T01-43` and insert after it: `Timestamp-Correction: original value 2026-10-02T01-44 was later than the file's observed write time 01:43:48 recorded in code-review.2026-10-02T02-55.md (CR-5); corrected under #846.` A separate superseding note was considered and rejected because the parser reads the first `Timestamp:` occurrence in this file, which would remain inaccurate.
- Note for the planner: the issue's "Proposed Fix" wording suggests superseding summaries rather than editing for #744. This research recommends the in-file correction for CR-5 only, for the reason above; PA-2 is closed without edit.

## Item #647 CR-3 (in-scope half): `subagent-tree-command.test.ts`

### Current state (verified)

- 500 lines. Imports (1-11); constants `WORKSPACE_ROOT`, `CLAUDE_PROJECTS_ROOT`, `MATCHING_DIR` (15-23); mock functions and `jest.mock` blocks for `vscode`, `../src/command-runtime`, `../src/terminal-writer` (25-71); import of `registerSubagentTreeCommand` (73); `FakeTerminalWriter` (76-87); `FakeFileTimes` (95-103); `activateAndGetHandler` (106-124); `agentToolUseLine` (127-134); `addRootSession` (137-146).
- One `describe("drm-copilot showSubagentTree command")` (148-500) with `beforeEach`/`afterEach` and 14 `it` blocks at lines 162, 181, 197, 219, 239, 257, 278, 320, 349, 367, 388, 425, 445, 466.
- Grouping: discovery, selection, rendering, and error routing (162-386, 10 tests); quick-pick ordering and labels with injected `FileTimes` (388-499, 4 tests).

### Proposed split

- `extensions/drm-copilot/test/subagent-tree-command-test-support.ts` (new; precedent names `collect-commit-context-test-support.ts`, `extension-potential-to-issue-test-support.ts`): export the three constants, `FakeTerminalWriter`, `FakeFileTimes`, `agentToolUseLine`, `addRootSession`. It must use only `import type` for `TerminalWriter` and `FileTimes` and import `InMemoryFileSystem` from `./lib/subagent-tree/in-memory-file-system`. It must not import `vscode`, `../src/command-runtime`, or `../src/terminal-writer` at runtime. Estimated 70 lines.
- `extensions/drm-copilot/test/subagent-tree-command.test.ts` (kept, history preserved): the `jest.mock` blocks and mock functions, `activateAndGetHandler`, the `describe` with hooks, and the 10 tests at 162-386. Estimated 320 lines.
- `extensions/drm-copilot/test/subagent-tree-command.quick-pick.test.ts` (new; dotted naming precedent `promotion.move-verification.test.ts`): its own copy of the three `jest.mock` blocks (Jest module mocks are per test file and hoisted, so they cannot live in the support module), its own `activateAndGetHandler`, a `describe("drm-copilot showSubagentTree command quick pick")` with the same `beforeEach`/`afterEach`, and the 4 tests at 388-499. Estimated 210 lines.
- The `jest.mock` factories and `activateAndGetHandler` are duplicated in two files (about 60 lines). Moving `activateAndGetHandler` into the support module would require passing the module-scoped mocks and command map as arguments; this is acceptable but not required. Recommendation: keep the mock wiring per file, share everything else.

### Configuration impact (verified)

- `jest.config.cjs` `testMatch: ["**/test/**/*.test.ts"]` picks up the new test file; the support file does not match. `collectCoverageFrom` is `src/**/*.ts` only. The per-file threshold `./src/subagent-tree-command.ts` (85/75, line 204) is unchanged and must still pass.
- `tsconfig.jest.json` includes `test/**/*.ts`; `npm run typecheck` runs `typecheck:test` (`tsc -p tsconfig.jest.json --noEmit`), so the new files are type-checked.
- `run-jest.cjs` has no test allowlist. No config change is required.

### Verification (executor observes)

- Before and after, from `extensions/drm-copilot`: `npm run test:unit -- subagent-tree-command`. Expected before: `Test Suites: 1 passed, 1 total`, `Tests: 14 passed, 14 total`. Expected after: `Test Suites: 2 passed, 2 total`, `Tests: 14 passed, 14 total`.
- `npx jest --config jest.config.cjs --listTests` filtered for `subagent-tree-command`: before 1 path, after 2 paths.
- `grep -c -E "^\s+it\(" <file>` per file: 10 + 4 = 14.
- Line counts of the three files: each at most 500.
- `npm run test:coverage`: no `coverage threshold` line naming `src/subagent-tree-command.ts`.

## Item #623 (promotion receipt destination)

Folder: `docs/features/active/promotion-receipt-destination-unverified-623/`.

### (1) Repository-wide handling of one-line Protocol stubs

Verified facts:
- `pyproject.toml` lines 129-140: `[tool.coverage.report] exclude_lines` already contains `"^\\s*\\.\\.\\.\\s*$"`, which matches a `...` body on its own line but not Black's one-line form `def f(...) -> T: ...`.
- Coverage version is 7.13.2 (`poetry.lock` line 413-414). The coverage.py documentation (fetched) states: `exclude_lines`/`exclude_also` excluding a `def` line excludes the entire function; `partial_also` (added in 7.10.0) lists "patterns for branches to consider fully covered even if they don't exercise both destinations" and preserves the default `pragma: no branch` pattern.
- One-line Protocol stubs exist across `scripts/dev_tools` (62 lines matched `^\s+def .*: \.\.\.\s*$` in 14 modules, including `potential_to_issue_filesystem.py` 42-54, `potential_to_issue_adapters.py` 44-50, `new_potential_bug_entry.py` 181-187, `epic_planner_git_integrity.py`, `plan_gate_discrimination.py`). The #338 evidence (`evidence/qa-gates/python-pytest-coverage.2026-10-08T02-49.md`) independently shows `181->exit, 183->exit, 185->exit, 187->exit` as missing branches in `new_potential_bug_entry.py`.
- No `.coveragerc`, `setup.cfg`, `tox.ini`, or `--cov-config` use exists outside `docs/`; `pyproject.toml` is the single coverage configuration, also used by CI (`.github/workflows/_quality-checks.yml` lines 79-91).

Policy evaluation: the Coverage Exclusion Policy in `.claude/rules/general-unit-test.md` prohibits excluding production files from the denominator; its permitted/prohibited lists concern path `exclude` entries. A `partial_also` pattern removes no file and no line from the line denominator; it only stops reporting the def-line-to-exit arc of a declaration-only body as an unexercised branch. The same rule, and `.claude/rules/python.md` line 91, already allow Protocol-only modules to be omitted entirely, which is broader. The change is therefore permitted.

Recommendation: add to `[tool.coverage.report]` in `pyproject.toml`:
`partial_also = ["^\\s*(async\\s+)?def\\s.*:\\s*\\.\\.\\.\\s*(#.*)?$"]`
Rejected alternatives: `exclude_also` on the def line (drops an executed line from the denominator and excludes the whole function); per-line `# pragma: no branch` (scattered suppressions); one dedicated arc-covering test per module (copy-paste of a test that asserts a language property).

Dedicated test: remove `test_file_system_protocol_members_declare_no_behavior` (`tests/scripts/dev_tools/test_potential_to_issue_filesystem.py` lines 207-235). With the configuration change it asserts no product behavior; its removal returns the file to the seven tests the #623 plan specified. This is a test-code change, not a stale-document deletion, so the operator's "delete nothing" rule does not apply to it. Risk: a reviewer may read the removal as test weakening (`.claude/rules/python.md` "Prohibited Behaviors"); the before/after coverage evidence below addresses this. If the planner prefers zero test removals, keeping the test is acceptable and harmless; the configuration change is still recommended.

Verification sequence (executor observes; this ordering is also the regression evidence for the configuration change):
1. Baseline: `poetry run pytest "tests/scripts/dev_tools/test_potential_to_issue_filesystem.py" "--cov=scripts.dev_tools.potential_to_issue_filesystem" --cov-branch --cov-report=term-missing`. Expected (from the #623 review): 8 passed; module at 14/14 branches.
2. Remove the eighth test without the configuration change (`[expect-fail]`). Expected: 7 passed; `Missing` lists `42->exit` through `54->exit`; branch coverage about 50%, below 75%.
3. Add `partial_also`. Expected: 7 passed; no `->exit` entries in `Missing`; branch coverage at or above 75%.
4. Whole-repository before/after (also closes #338 A1): `poetry run pytest --cov --cov-branch --cov-report=term "--cov-report=json:artifacts/python/coverage.json"` then `poetry run python -m scripts.dev_tools.check_python_coverage_thresholds --report artifacts/python/coverage.json --min-line 85 --min-branch 75`. Expected: the threshold script prints nothing and exits 0 (it writes only failures to stderr); the post-change `TOTAL` branch figure is not lower than baseline.

### (2) Plan text (`plan.2026-09-29T19-06.md`)

- Line 7: `- **Status:** Draft (revision 1.2; preflight round 2 defects 1-3 and the P5-T3 advisory applied; pending validator and executor preflight round 3)`. Replace with a completed status, for example `- **Status:** Complete (revision 1.2; preflight cleared; all tasks checked; merged; P5-T3 deviation annotated under #846)`, and update line 6 `Last Updated`.
- Line 228 (P5-T3, one long line): contains "exactly seven tests" and acceptance `grep -c -E "^def test_" ... prints 7`. Line 230 (P5-T5) expects `7 passed`. Append to line 228: `Deviation (annotated under #846): an eighth test, test_file_system_protocol_members_declare_no_behavior, was added during execution to cover Protocol stub branch arcs (evidence/qa-gates/py-test-coverage-pass1-failed.2026-09-30T08-46.md); #846 replaced it with the repository-wide partial_also coverage setting and removed it, so the file again holds seven tests.` If the test is kept, the annotation states that the file holds eight tests and why.

### (3) Python documentation parity

Line numbers have moved since the review: the `PromotionOutcome` docstring is now `scripts/dev_tools/potential_to_issue.py` lines 76-97 and the post-move branch is lines 348-350 (file is 438-439 lines). TypeScript reference: `extensions/drm-copilot/src/lib/potential-to-issue/promotion.ts` line 88 and lines 440-442 (re-read, unchanged).
- Docstring line 94 `exit_code (int): Final process-style exit code.` becomes `exit_code (int): Final process-style exit code: 0 on success; the gh create exit code when issue creation fails; 1 when the promoted file is missing after the move.` (wrap for Black).
- Insert above line 348:
  `# Verify the move produced the destination before reporting success. A`
  `# missing destination is a non-zero outcome (not a raised error) so the`
  `# caller still receives every emitted line, including the created issue URL.`
- No bundled mirror of the Python module exists (Glob for `**/potential_to_issue*.py` returned only `scripts/dev_tools/` files and a test support module).
- Verification: `poetry run black --check`, `poetry run ruff check`, `poetry run pyright` on the file; `poetry run pytest "tests/scripts/dev_tools/test_potential_to_issue_move_verification.py"` exits 0. No coverage delta (no executable change).

## Item #764 (feature-review skill validator citation)

Folder: `docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/`.

1. `git grep -nxF`: verified in `plan.2026-09-30T05-00.md` lines 39, 40 (task acceptance) and 66 (AC mapping table). The git-grep documentation (fetched) lists no `-x`/`--line-regexp` option. Text correction: replace the command in lines 39 and 40 with the anchored form the executor actually ran (recorded at `evidence/regression-testing/edit-diff.2026-09-30T05-20.md` line 8): `git grep -n -e "^- When the rule fires and no qualifying green-run evidence is present, record a Blocking finding and route it through the standard remediation handoff\.$" -- <path>`, and append `(Corrected under #846: the original -nxF form is invalid because git grep has no -x option and exits 129.)`. Line 66: replace `P1-T1 exact-line \`git grep -nxF\`` with `P1-T1 anchored \`git grep -n -e "^...$"\` exact-line check`. Verification: `git grep -n -e "<pattern>" -- .claude/skills/feature-review-workflow/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-review-workflow/SKILL.md` prints one line per file, both at line 75, exit 0; `git grep -n -e "-nxF" -- <plan>` (use `-e`) prints no line from lines 39, 40, 66.
2. Filename stamps: 11 evidence files carry `2026-09-30T05-20` in the name while their `Timestamp:` fields read 09-47 to 09-58 (enumerated in "Numeric Derivation Evidence"). Recommendation: no rename (renames would break the plan's task references and the review citations). Add a superseding note `evidence/other/evidence-filename-timestamps.<YYYY-MM-DDTHH-mm>.md` in the #764 folder: `Timestamp:` (clock), `Supersedes:` none (clarifies), a table of the 11 files with filename stamp and recorded `Timestamp:`, and the statement that the filename stamp was the plan-assigned stamp and the `Timestamp:` field is the authoritative run time.
3. `issue.md` line 5: `- Status: Promoted -> docs/features/active/feature-review-skill-cites-nonexistent-validator/ (Issue #764)` becomes `- Status: Promoted -> docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/ (Issue #764)`.

Systemic observation (out of scope; follow-up candidate): every promoted `issue.md` checked carries the undated slug path, including this item's own `issue.md:5`. The text is produced by `scripts/dev_tools/potential_to_issue_content.py` line 209 (`f"Promoted -> docs/features/active/{feature_path}/ (Issue #{issue_number})"`) before the dated, issue-suffixed folder exists. Recommend a potential entry rather than a fix here.

## Item #338 (IDE launcher audit gaps)

Folder: `docs/features/active/2026-07-09-potential-entry-ide-launcher-audit-gaps-338/`.

- CR-1: `issue.md` line 44 (AC-3, checked) names `test/lib/new-active-feature-folder/io.test.ts` and a command that omits `io-launcher.test.ts`. Both files exist. The recorded run (`evidence/regression-testing/ac3-jest-new-tests.2026-10-08T02-45.md`) used `npm run test:unit -- test/lib/new-potential-bug-entry-launcher.test.ts test/lib/new-active-feature-folder/io.test.ts test/lib/new-active-feature-folder/io-launcher.test.ts -t launcher-gap` (27 passed of 61). Text correction: name `extensions/drm-copilot/test/lib/new-active-feature-folder/io-launcher.test.ts` as the location of the new default-helper tests (placed beside `io.test.ts` to respect the 500-line limit), add `test/lib/new-active-feature-folder/io-launcher.test.ts` to the command, and append `(AC text corrected under #846; verifying run: evidence/regression-testing/ac3-jest-new-tests.2026-10-08T02-45.md.)`. Keep the checkbox checked. Verification: run the corrected command from `extensions/drm-copilot`; expected exit 0 with 3 suites passed (derived).
- Advisory A1: CI already produces and gates the whole-repository Python figure: `.github/workflows/_quality-checks.yml` lines 79-91 run `poetry run pytest --cov --cov-branch ... --cov-report=json:artifacts/python/coverage.json` and `check_python_coverage_thresholds --min-line 85 --min-branch 75`. A local whole-repository run is feasible (the #744 evidence records 6376 tests locally). Recommendation: close A1 by recording the #846 whole-repository run from #623 step 4 and the PR's CI `Enforce Python coverage thresholds` step in the #846 closure-disposition evidence. No edit in the #338 folder.
- CR-3: `issue.md` refers to bundled copies at line 38 ("both the root and bundled copies of `_resolve_code_cli()`"), line 66 ("and their bundled mirrors"), and line 68 ("(root and bundled copies)"). Text correction: line 38 names the two Python modules only; line 66 lists the four launcher files that AC-4 names (`new_potential_bug_entry.py`, `new_active_feature_folder_io.py`, `new-potential-bug-entry.ts`, `io-launcher.ts`); line 68 drops "(root and bundled copies)". Add one note line under `## Actual Behavior`: `Correction (#846): no bundled mirror copies of the two Python modules exist (code-review.2026-10-08T07-05.md CR-3).` The GitHub issue body is not changed by this work (repository record only).
- Residual risk: already closed as `scope_change` under AC-5 with `evidence/other/ac1-ac2-scope-change-closure.2026-10-08T02-44.md`. A live observation needs a desktop session and cannot be automated. Recommendation: explicit closure entry in the #846 closure-disposition evidence citing the closure record; no new observation.

## Item #609 (bash lane assertion newline edges)

Folder: `docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/`.

Verified: `evidence/other/ac-status-summary.2026-09-29T18-45.md` records 6 of 17 checked and lists 11 open items (including AC-6 and AC-14); `evidence/other/ac-gaps.2026-09-29T18-45.md` lists the same 11 gaps; `spec.md` now has 17 checked criteria and 0 unchecked; the CI evidence `evidence/qa-gates/ci-per-file-coverage.2026-10-02T03-44.md` (AC-14 satisfied) and `evidence/regression-testing/bats-unit-before.2026-10-02T03-53.md` (AC-6 satisfied) postdate the stale files. The review says not to edit the old files.

Recommended superseding file: `evidence/other/ac-status-summary.<YYYY-MM-DDTHH-mm>.md` in the #609 folder (same stem with a newer stamp, so latest-by-timestamp readers select it). Outline:
- `Timestamp:` (host clock), `Command:` `git grep -c -e "^- \[x\] " -- docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/spec.md`, `EXIT_CODE:`, `Output Summary:` (the printed count).
- `Supersedes:` the four files `evidence/other/ac-gaps.2026-09-29T18-45.md`, `evidence/other/ac-status-summary.2026-09-29T18-45.md`, `evidence/qa-gates/coverage-comparison.2026-09-29T18-45.md`, `evidence/regression-testing/fail-before-exception.2026-09-29T18-45.md`.
- `### Acceptance Criteria Status` block: source `spec.md`; total, checked, remaining as observed by the command.
- Resolution table: AC-6 to `evidence/regression-testing/bats-unit-before.2026-10-02T03-53.md` (CI run 36961456506, fail-first) and CI run 36960736942 (pass-after); AC-14 to `evidence/qa-gates/ci-per-file-coverage.2026-10-02T03-44.md` (line-rate 0.989 head and baseline); the other nine formerly open criteria to `evidence/qa-gates/ci-shell-coverage.2026-10-02T03-40.md`.
- Statement that the four superseded files are retained unchanged as point-in-time records.
- Use `-e` for the hyphen-leading pattern.

## Item #543 CR-11

File: `docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/other/python-batch-budget.2026-10-02T05-01.md`.

- Current line 3: `Timestamp: 2026-10-02T05-18`.
- Current line 4: `Timestamp-Correction: original value 2026-10-02T05-01 was a reused reading rather than a clock reading for this artifact; the corrected value is the artifact's observed file write time (remediation-inputs.2026-10-02T07-08.md), an upper bound on the write time.`
- Verified via the GitHub patch view of `0c6abb95` (full SHA `0c6abb952153b38726ae65a5c0b438adc37e6e8b`): `Date: Fri, 2 Oct 2026 05:14:57 -0400`; the commit adds this file with `Timestamp: 2026-10-02T05-01` and a `## Reset log` header but no `### Reset 1` entry. The row was therefore written no later than 05:14:57, so 05-18 is not an upper bound. The patch `Date:` is the author date; the executor should confirm both dates with `git log -1 --format="%H %ad %cd" 0c6abb95`.
- Text correction (retains both prior values): line 3 becomes `Timestamp: 2026-10-02T05-14`; line 4 becomes `Timestamp-Correction: original value 2026-10-02T05-01 was a reused reading rather than a clock reading; a first correction to 2026-10-02T05-18 (observed file write time, remediation-inputs.2026-10-02T07-08.md) was later than commit 0c6abb95 (authored 2026-10-02 05:14:57 -04:00), which already contained this row; the value is now that commit time, an upper bound on the write time (corrected under #846, code-review.2026-10-07T09-34.md CR-11).`
- Lines 32-33 (`### Reset 1`) carry the same 05-18 value and the same upper-bound claim. That section was not in `0c6abb95`, and the review did not flag it. The executor should check it with `git log --format="%h %ad" -S"### Reset 1 (P2-T4)" -- <file>` and apply the same correction only if the first commit containing that section predates 05:18.

## Item #527 (PoshQC coverage denominator)

- `extensions/drm-copilot/CHANGELOG.md` line 8 `## [Unreleased]` has no content (line 9 blank, line 10 `## [0.0.1] - 2026-05-02`). It is the only `CHANGELOG.md` in the repository; there is no mirror. No test reads its content; `scripts/powershell/Publish-DrmCopilotExtension.ps1` only checks existence.
- Behavior source verified in `scripts/powershell/PoshQC/README.md` lines 68-75 and 86.
- Insert after line 8:

```
### Changed

- PoshQC code-coverage population (issue #527): `Invoke-PoshQCTest` derives the measured
  file set from the workspace. Declare coverage roots in `config/poshqc-coverage.json` at
  the workspace root (`{"version": 1, "roots": [...]}`). A `CodeCoverage.Path` list in the
  module's shipped `settings/pester.runsettings.psd1` is now ignored, and the ignore is
  logged. A caller-supplied settings file (`-SettingsPath`) with a non-empty
  `CodeCoverage.Path` is still honored. Without the configuration file, the population
  falls back to the effective test scan folders. Migration: move any coverage paths that
  were added to the shipped settings file into `config/poshqc-coverage.json`.
```

- Verification: `npx prettier --check CHANGELOG.md` is not part of the extension `format` script globs (`src/**/*.ts`, `test/**/*.ts`, `*.json`, `*.cjs`); no formatter applies. Visual check that the heading order is `[Unreleased]` > `### Changed` > `[0.0.1]`.

## Item #510 (claude resource parity)

`docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/spec.md` (re-read) against `.gitignore` (re-read: line 23 `.claude/worktrees`, line 69 `.claude/agent-memory`, line 70 `.claude/state/`):
- Line 6: `Last Updated: 2026-09-29T14-30`; update to the edit time.
- Line 7: `- **Status:** Draft`; all 13 criteria (lines 164-176) are checked. Replace with `- **Status:** Implemented (all 13 acceptance criteria checked; reviewed in code-review.2026-10-07T15-30.md)`.
- Line 45: "gitignored at `.gitignore` line 68" becomes "line 70".
- Line 61: "(`.gitignore` line 21)" becomes "line 23"; "`agent-memory` (line 67), `state` (line 68), and `worktrees` (line 21)" becomes "(line 69), (line 70), and (line 23)".
- Line 174: `.../evidence/coverage/coveragerc-helper.ini` becomes `.../evidence/other/coveragerc-helper.ini` (file verified to exist there).
- Verification: `git grep -n -e "line 68" -e "line 67" -e "line 21" -e "evidence/coverage/" -- <spec>` prints nothing (exit 1, expected).

## Item #723 (npm publish verify window)

Files (verified): `.github/workflows/publish-mcp-npm.yml` (136 lines; poll step 101-135; error message line 132; `exit 1` line 133); `tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1` (227 lines; 10 `It` blocks); `docs/engineering/missed-npm-publish.runbook.md` (section "Red verify step after a green publish step", lines 128-136). Review line references in the issue are off by one: N1 is at `code-review.2026-10-01T22-30.md` line 29 and N3 at line 31.

### Refinement: publish step's own success as the primary signal

Analysis: the verify step's `if: startsWith(github.ref, 'refs/tags/mcp-server-v')` contains no status-check function. The GitHub Actions expressions documentation (fetched) states: "A default status check of `success()` is applied unless you include one of these functions." The verify step therefore runs only when every earlier step, including "Publish to npm", succeeded; the message "The publish step succeeded before this check ran" is true by construction. `research/research.2026-09-29T21-40.md` line 123 records the same reasoning. Implementing the refinement would change a workflow file without adding information and would trigger the modified-workflow-needs-green-run rule.

Recommendation: close the refinement explicitly with this rationale (closure-disposition evidence in #846), and add one Pester test that pins the precondition, so a future change cannot silently falsify the message:
- the poll step's `if:` line contains none of `always()`, `failure()`, `cancelled()`;
- the publish step block contains no `continue-on-error`;
- the poll step index is greater than the publish step index (already asserted at line 119; reuse).
No `.github/workflows/**` file changes, so the modified-workflow rule does not apply. If the planner chooses to change the workflow instead, the rule applies; the workflow already has a `pull_request` trigger on its own path (lines 12-15), so a green branch-head run is obtainable.

### N3: tighten the `exit 1` assertion

Lines 125 and 224 (poll step) and 110 (equality step) use `Should -Match '(?m)^\s*exit 1\s*$'`. Replace with two assertions per step:
- `[regex]::Matches($text, '(?m)^\s*exit 1\s*$').Count | Should -Be 1`
- poll step: `$text | Should -Match '(?s)if \(-not \$resolved\) \{[^}]*::error::[^}]*\bexit 1\b[^}]*\}'`; equality step: `$text | Should -Match '(?s)if \(\$tagVersion -ne \$manifestVersion\) \{[^}]*::error::[^}]*\bexit 1\b[^}]*\}'`.
The error block bodies (lines 81-84 and 131-134) contain no `}` before the closing brace, so `[^}]*` is valid against the current text. Line 146 (generic rule over all pwsh steps) is left unchanged.

### N1: runbook

After line 134 insert (outer four-backtick fence shown only to delimit the inserted text):

````

```
npm view @danmoisan/drm-copilot-mcp@1.0.25 version
```

Substitute the version under investigation; this is the exact-version query described at the top of this runbook.
````

No test reads the runbook; anchors are unaffected.

### Verification (executor observes)

- `Invoke-Pester -Path tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 -Output Detailed`: expected `Tests Passed: 11, Failed: 0` (10 existing plus 1 new). The prior #723 run relied on CI because local `pwsh` invocation was denied (`evidence/qa-gates/final-pester-publish-mcp-npm-workflow.md`); if local execution is unavailable, the CI `poshqc / PowerShell QC` job on the PR head is the authoritative result.
- Fail-before: the tightened and new assertions strengthen invariants that already hold, and a failing run would require editing the workflow, which is out of scope. Record a fail-before exception dossier (`fail-before-exception.<ts>.md`) stating this instead of a failing run.
- Formatter and analyzer on the test file with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` (MCP `run_poshqc_format`, `run_poshqc_analyze`, or the equivalent cmdlets).
- `poetry run pytest tests/scripts/dev_tools/test_workflow_npm_token_guard.py` unaffected (no workflow change).

## Files the Implementation Will Write

Grouped by finding; repository-relative.

#734:
- tests/scripts/dev_tools/test_quality_tiers_contract.py
- tests/scripts/dev_tools/test_quality_tiers_contract_classification.py (new)
- tests/scripts/dev_tools/quality_tiers_contract_test_support.py (new)
- scripts/dev_tools/check_quality_tiers.py
- tests/scripts/dev_tools/test_check_quality_tiers.py

#744:
- .claude/skills/acceptance-criteria-tracking/SKILL.md
- .agents/skills/acceptance-criteria-tracking/SKILL.md
- .github/skills/acceptance-criteria-tracking/SKILL.md
- extensions/drm-copilot/resources/claude-customizations/.claude/skills/acceptance-criteria-tracking/SKILL.md
- extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/acceptance-criteria-tracking/SKILL.md
- extensions/drm-copilot/resources/customizations/.github/skills/acceptance-criteria-tracking/SKILL.md
- tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py
- docs/features/active/2026-09-27-orchestration-completion-gate-and-tooling-friction-744/evidence/regression-testing/pester-doc-contracts.2026-09-30T03-18.md

#647 (in-scope half):
- extensions/drm-copilot/test/subagent-tree-command.test.ts
- extensions/drm-copilot/test/subagent-tree-command.quick-pick.test.ts (new)
- extensions/drm-copilot/test/subagent-tree-command-test-support.ts (new)

#623:
- pyproject.toml
- tests/scripts/dev_tools/test_potential_to_issue_filesystem.py
- scripts/dev_tools/potential_to_issue.py
- docs/features/active/promotion-receipt-destination-unverified-623/plan.2026-09-29T19-06.md

#764:
- docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/plan.2026-09-30T05-00.md
- docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/issue.md
- docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/evidence/other/evidence-filename-timestamps.<YYYY-MM-DDTHH-mm>.md (new)

#338:
- docs/features/active/2026-07-09-potential-entry-ide-launcher-audit-gaps-338/issue.md

#609:
- docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/evidence/other/ac-status-summary.<YYYY-MM-DDTHH-mm>.md (new)

#543:
- docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/other/python-batch-budget.2026-10-02T05-01.md

#527:
- extensions/drm-copilot/CHANGELOG.md

#510:
- docs/features/active/2026-08-19-claude-resource-parity-enumerates-gitignored-state-510/spec.md

#723:
- tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1
- docs/engineering/missed-npm-publish.runbook.md

#846 own artifacts:
- docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md
- docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/plan.<timestamp>.md
- docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/baseline/*
- docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/regression-testing/*
- docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/qa-gates/*
- docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/other/closure-dispositions.<YYYY-MM-DDTHH-mm>.md (new; closes #744 PA-2, #338 A1, #338 residual risk, #723 refinement)

Not written: `extensions/drm-copilot/test/lib/validate/orchestration-handoff-authority-service.test.ts`; `jest.config.cjs`; `tsconfig.jest.json`; any `.github/workflows/**` file; `.gitignore`; any bundled mirror of a Python module (none exist).

## Evidence Plan for #846

All evidence goes to `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/evidence/<kind>/` with `Timestamp:` read from the host clock, `Command:`, `EXIT_CODE:`, `Output Summary:`.
- Baseline: Python targeted pytest coverage for `quality_tiers_contract`, `check_quality_tiers`, `potential_to_issue_filesystem`, `potential_to_issue` (dotted `--cov=`); whole-repository Python coverage JSON totals; Jest run for `subagent-tree-command` (14 tests) and `npm run test:coverage` summary; Pester run for the workflow test file (or CI reference); collected-test counts and line counts for the split files.
- Regression-testing: `[expect-fail]` run for #623 step 2; fail-before for #734 CR-2 is structural (new tests cover existing behavior and are expected to pass); record a `fail-before-exception.<ts>.md` dossier for the coverage-only and documentation-only items, and an observed failing run for CR-4 (the stderr-content test fails against the unchanged `check_quality_tiers.py`).
- QA gates: full Python, TypeScript, and PowerShell toolchain passes; coverage comparison baseline vs post-change per language; line-count gate; mirror byte-equality.
- Other: `closure-dispositions.<ts>.md`.

## Languages and Toolchain

Languages in scope: Python (production and tests), TypeScript (tests only), PowerShell (Pester test only), TOML (`pyproject.toml`), Markdown.

Python (repository root):
1. `poetry run black .` (check: `poetry run black --check .`)
2. `poetry run ruff check .`
3. `poetry run pyright`
4. Architecture: no Python architecture tool configured (prior plans record "not configured").
5. `poetry run pytest <files> "--cov=scripts.dev_tools.<module>" --cov-branch --cov-report=term-missing` (dotted module form; a `.py` path form measures nothing); whole repository: `poetry run pytest --cov --cov-branch --cov-report=term "--cov-report=json:artifacts/python/coverage.json"` followed by `poetry run python -m scripts.dev_tools.check_python_coverage_thresholds --report artifacts/python/coverage.json --min-line 85 --min-branch 75`.
6-7. Contract and integration: not applicable.

TypeScript (from `extensions/drm-copilot`):
1. `npm run format` (check: `npx prettier --check "src/**/*.ts" "test/**/*.ts"`)
2. `npm run lint`
3. `npm run typecheck` (includes `typecheck:test`)
4. Architecture: dependency-cruiser not configured in the extension (no config file found).
5. `npm run test:unit -- subagent-tree-command`, then `npm run test:coverage`.
6-7. Not applicable.

PowerShell (test file only): `mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, `mcp__drm-copilot__run_poshqc_test`, or `Invoke-Formatter` / `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` / `Invoke-Pester` through the PowerShell tool. Project memory records that PoshQC MCP results may carry no output and that the MCP test runner reads installed-extension settings; prefer direct cmdlets or the CI `poshqc` job for observed counts.

## Hooks and Execution Constraints

- `.claude/hooks/enforce-python-batch-budget.ps1`: in direct mode, at most 3 distinct production `.py` files per session; test files (`tests/**/*.py`, `test_*.py`) are not counted; the large/remediation/preparation route with a non-terminal checkpoint has no cap. This item needs 2 production Python files (`scripts/dev_tools/check_quality_tiers.py`, `scripts/dev_tools/potential_to_issue.py`); the new support module lives under `tests/` and is not counted.
- `.claude/hooks/enforce-powershell-batch-budget.ps1`: `.Tests.ps1` and `tests/**` files are not counted; no production PowerShell changes.
- `.claude/hooks/check-python-test-purity.ps1`: new Python tests must not use `tempfile`, `subprocess`, `time.sleep`, `.touch(`, network imports. The CR-4 tests use the injected `run` seam and need none of these.
- `.claude/hooks/check-powershell-test-purity.ps1`: the Pester file must not contain the literal `Start-Sleep` (the existing file assembles it as `'Start' + '-Sleep'`), `New-TemporaryFile`, or `$env:TEMP`.
- `.claude/hooks/enforce-promotion-mcp-only.ps1`: a Bash command whose unquoted text contains `potential_to_issue`, `new_potential_bug_entry`, `new_active_feature_folder`, or `new-potential-entry.ps1` is denied; quoted spans are masked. Double-quote test paths and `--cov=` arguments for #623 and any #338 command (precedent: #338 evidence notes this quoting).
- `.claude/hooks/enforce-evidence-locations.ps1`: evidence under `artifacts/baseline(s)/`, `artifacts/qa(-gates)/`, `artifacts/coverage/`, `artifacts/evidence/`, `artifacts/regression-testing/`, `artifacts/post-change/` is denied; `artifacts/python/` is permitted for coverage JSON.
- Project memory (not re-verified this session): the worktree isolation guard denies command text containing `bash`, `pwsh`, or `wsl`; `--force-with-lease` is caught by `validate-bash.ps1`; the preimplementation gate can block staging. Plan around these with the PowerShell tool for Pester and with the documented workarounds.
- Research artifact naming: the orchestrator-supplied file name `research.2026-10-08T23-50.md` does not match the `<timestamp>-<short-name>-research.md` pattern checked by `.claude/hooks/validate-task-researcher-output.ps1` (`Test-IsValidResearchFileName`). The file was written at the supplied path as instructed; the discrepancy is reported to the orchestrator.

## Testing Implications

- Python: CR-2 cases in the kept parse file; CR-1 rename in the classification file; CR-4 stderr-content and multi-line tests in `test_check_quality_tiers.py` (fail-before against unchanged production code for the content test); collected-count preservation across the split; #623 coverage before/after sequence.
- TypeScript: test-count preservation (14) across the split; per-file threshold for `src/subagent-tree-command.ts` unchanged.
- PowerShell: one new `It` pinning the publish-success precondition; tightened `exit 1` assertions in two existing `It` blocks and the equality-step `It`.
- Documentation-only items: verification by `git grep` checks and mirror byte-equality tests; fail-before exception dossiers.

## Numeric Derivation Evidence

### Claim 1: copies of the acceptance-criteria-tracking skill

- Numeric spec.md acceptance criterion: all 6 acceptance-criteria-tracking SKILL.md copies carry the CI-dependent cross-reference sentence.
- Complete Family: acceptance-criteria-tracking SKILL.md copies
- Exhaustive Search Scope: entire repository tree of this worktree, all files visible to Glob and Grep, with docs/** excluded from the content search only because feature documents quote the sentence
- Inclusion Rules: a file named SKILL.md inside a directory named acceptance-criteria-tracking, at any depth, including bundled resources under extensions/drm-copilot/resources/
- Exclusion Rules: Markdown under docs/ that quotes the sentence without being a skill file
- Primary Search Strategy or Query Expression: Glob path pattern **/acceptance-criteria-tracking/** across the whole worktree, enumerating acceptance-criteria-tracking SKILL.md copies by file path
- Primary Member Set: .claude/skills/acceptance-criteria-tracking/SKILL.md, .agents/skills/acceptance-criteria-tracking/SKILL.md, .github/skills/acceptance-criteria-tracking/SKILL.md, extensions/drm-copilot/resources/claude-customizations/.claude/skills/acceptance-criteria-tracking/SKILL.md, extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/acceptance-criteria-tracking/SKILL.md, extensions/drm-copilot/resources/customizations/.github/skills/acceptance-criteria-tracking/SKILL.md
- Primary Count: 6
- Cross-check Search Strategy or Query Expression: ripgrep content search for the literal text "Orchestrators do not directly check off AC items" across the whole worktree outside docs/**, enumerating acceptance-criteria-tracking SKILL.md copies by content
- Cross-check Member Set: .agents/skills/acceptance-criteria-tracking/SKILL.md, .github/skills/acceptance-criteria-tracking/SKILL.md, .claude/skills/acceptance-criteria-tracking/SKILL.md, extensions/drm-copilot/resources/customizations/.github/skills/acceptance-criteria-tracking/SKILL.md, extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/acceptance-criteria-tracking/SKILL.md, extensions/drm-copilot/resources/claude-customizations/.claude/skills/acceptance-criteria-tracking/SKILL.md
- Cross-check Count: 6
- Member-set Comparison: the normalized primary and cross-check member sets are equal (identical six paths in different order).

### Claim 2: test cases in the subagent-tree command suite

- Numeric spec.md acceptance criterion: the split preserves all 14 it blocks of the subagent-tree command suite.
- Complete Family: it blocks of extensions/drm-copilot/test/subagent-tree-command.test.ts
- Exhaustive Search Scope: the complete file extensions/drm-copilot/test/subagent-tree-command.test.ts (all 500 lines) in the repository tree; no other file holds tests for this command (Glob extensions/drm-copilot/test/subagent-tree* returned only this file)
- Inclusion Rules: every it( call inside the describe block
- Exclusion Rules: none (the file has no it.skip, it.each, or test( calls)
- Primary Search Strategy or Query Expression: ripgrep regex ^\s+it\( over it blocks of extensions/drm-copilot/test/subagent-tree-command.test.ts, reporting line numbers
- Primary Member Set: L162, L181, L197, L219, L239, L257, L278, L320, L349, L367, L388, L425, L445, L466
- Primary Count: 14
- Cross-check Search Strategy or Query Expression: full-file Read of it blocks of extensions/drm-copilot/test/subagent-tree-command.test.ts with manual enumeration of each test title and its starting line
- Cross-check Member Set: L162, L181, L197, L219, L239, L257, L278, L320, L349, L367, L388, L425, L445, L466
- Cross-check Count: 14
- Member-set Comparison: the two member sets are identical.

### Claim 3: test functions in the quality-tiers contract test file

- Numeric spec.md acceptance criterion: the split preserves all 28 test functions of the quality-tiers contract tests.
- Complete Family: def test_ functions of tests/scripts/dev_tools/test_quality_tiers_contract.py
- Exhaustive Search Scope: the complete file tests/scripts/dev_tools/test_quality_tiers_contract.py (all 495 lines) in the repository tree; the only other quality-tiers test file, tests/scripts/dev_tools/test_check_quality_tiers.py, tests the CLI and is not split
- Inclusion Rules: top-level functions whose name starts with test_
- Exclusion Rules: helper functions _codes and _manifest
- Primary Search Strategy or Query Expression: ripgrep regex ^def test_\w+ over def test_ functions of tests/scripts/dev_tools/test_quality_tiers_contract.py, reporting line numbers
- Primary Member Set: L48, L68, L82, L95, L114, L163, L174, L192, L206, L215, L224, L233, L253, L262, L271, L287, L299, L312, L350, L363, L373, L396, L406, L419, L434, L446, L460, L480
- Primary Count: 28
- Cross-check Search Strategy or Query Expression: full-file Read of def test_ functions of tests/scripts/dev_tools/test_quality_tiers_contract.py with manual enumeration of each definition line
- Cross-check Member Set: L48, L68, L82, L95, L114, L163, L174, L192, L206, L215, L224, L233, L253, L262, L271, L287, L299, L312, L350, L363, L373, L396, L406, L419, L434, L446, L460, L480
- Cross-check Count: 28
- Member-set Comparison: the two member sets are identical.

### Claim 4: #764 evidence files whose names carry the plan-assigned stamp

- Numeric spec.md acceptance criterion: the #764 superseding note lists all 11 evidence files named with 2026-09-30T05-20.
- Complete Family: #764 evidence files named with 2026-09-30T05-20
- Exhaustive Search Scope: the complete docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/ folder tree in the repository
- Inclusion Rules: files under evidence/ whose name contains 2026-09-30T05-20
- Exclusion Rules: evidence/baseline/phase0-instructions-read.md (no stamp in its name)
- Primary Search Strategy or Query Expression: Glob listing of the folder tree, filtering #764 evidence files named with 2026-09-30T05-20 by file name
- Primary Member Set: baseline-citation-grep, baseline-code-source-diff, baseline-pytest, baseline-rootfolders-diff, minor-audit-preconditions, final-citation-grep, final-pytest, final-rootfolders-diff, final-toolchain-applicability, edit-diff, targeted-parity-test
- Primary Count: 11
- Cross-check Search Strategy or Query Expression: ripgrep for Timestamp: lines inside the evidence tree, then keeping #764 evidence files named with 2026-09-30T05-20 from the matched file list (12 matches minus phase0-instructions-read)
- Cross-check Member Set: targeted-parity-test, edit-diff, final-toolchain-applicability, final-rootfolders-diff, final-citation-grep, final-pytest, baseline-citation-grep, baseline-code-source-diff, minor-audit-preconditions, baseline-rootfolders-diff, baseline-pytest
- Cross-check Count: 11
- Member-set Comparison: the two member sets are equal.

Not proposed as numeric acceptance criteria (derived only; the executor observes): the pytest collected count of 47 for the quality-tiers contract file, the `Tests Passed: 11` Pester figure, and the #609 `17` checked-criteria count (to be recorded by the superseding summary's own command).

## Automation Feasibility

No step requires human interaction. All edits are file edits; all verification is by local commands (pytest, Jest, Pester, git grep) or by CI on the PR head. The #338 live Windows observation is not performed; it is closed by documentation under the existing `scope_change` record, which needs no interaction. Synchronizing GitHub issue bodies (#338, #764) is not required and is not proposed. Pester execution may need the PowerShell tool or CI if `pwsh` command text is denied in the agent worktree; neither path needs a human.

## Rejected Alternatives (brief)

- #623: `exclude_also` on one-line stub `def` lines; per-line `# pragma: no branch`; per-module arc-covering tests.
- #734: three-way split; duplicating `_codes`.
- #647: one shared module containing the `jest.mock` wiring (not possible; mocks are per test file).
- #723: changing the workflow to read the publish step outcome (redundant with the default `success()` condition; triggers the modified-workflow rule).
- #609 and #764: editing or renaming the point-in-time files (breaks citations; reviews advise against it).
- #744 PA-2: adding `Command:`/`EXIT_CODE:` rows (would record commands that were not run).
