# promotion-receipt-destination-unverified (Spec)

- **Issue:** #623
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-29
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-bug (acceptance criteria are tracked in this file only; no `user-story.md`)
- **Research:** `docs/features/active/promotion-receipt-destination-unverified-623/research/2026-09-29T19-15-promotion-destination-verification-research.md`

## Context
- Summary of the bug and its impact: the promotion-to-issue workflow moves a potential entry from `docs/features/potential/` into `docs/features/potential/promoted/` and reports the destination path. In at least one observed instance (consumer TaskMaster repository, TaskMaster issue #554) the success receipt named a `destination_path` under `promoted/` at which no file existed, while the source entry had already been removed. The potential document was lost and the receipt asserted it had been relocated. Neither the TypeScript workflow (`promotePotential`) nor the Python parity source (`promote_potential`) checks that the destination exists after the move.
- Scope note: GitHub issue #623 originally bundled three defects. Per the 2026-09-29 consolidation comment on #623, this spec covers item 2 only. Item 1 is tracked by #527 and item 3 by #405.
- Observed environment(s): Windows 11, consumer TaskMaster repository, invoked through the MCP tool `mcp__drm-copilot__potential_to_issue`. The extension version in use at the time is not recorded (unverified).
- Customer impact and severity: affects any caller of the promotion workflow (MCP tool, Poetry script `dev.potential-to-issue`, VS Code task "Dev: 2 Promote Potential to GitHub Issue"). When it occurs, the potential document is lost and a GitHub issue has already been created. Frequency in the current tree is unknown; the most likely original trigger (the #487 defect) has already been fixed. Severity: medium (data loss when it occurs, low observed frequency).
- First observed date and version(s) impacted: `issue.md` records TaskMaster #554 as 2026-09-02; the research WebFetch summary of the GitHub page reports 2026-08-14. The research marks the WebFetch value as unverified, so the first-observed date is unverified. The impacted extension version is unknown.

## Repro & Evidence
- Steps to reproduce (with data/flags/inputs):
  1. Create a potential entry under `docs/features/potential/`.
  2. Promote it through the promotion-to-issue tool.
  3. Inspect the receipt `destination_path` and check whether a file exists there.
  A natural reproduction in the current tree has not been achieved. The defect is reproduced deterministically in unit tests by injecting a filesystem fake whose `move` removes the source without writing the destination; with that fake, both `promotePotential` and `promote_potential` currently return exit code 0 with a `destination` set.
- Expected vs actual behavior:
  - Expected: after the move, the workflow verifies that the destination exists; if it does not, it reports a specific failure instead of success.
  - Actual (workflow layer, both languages): the workflow emits `Moved potential file to promoted folder: <dest>` and returns exit code 0 with `destination` set, without checking existence (`promotion.ts:439-442`; `potential_to_issue.py:551-554`).
  - Actual (MCP receipt layer, current tree): the #487 guard in `potential-to-issue-service-call.ts:215-226` already throws `potential_to_issue reported a path that does not exist: <destination>` before a receipt is built, so an MCP call cannot currently return `ok: true` for a destination that `fs.existsSync` reports absent at receipt time. That thrown message omits the emitted messages, including the created issue URL.
  - Actual (Python CLI): `main()` exits with the workflow exit code, so it reports success whether or not the destination exists.
- Logs/screenshots/error snippets: TaskMaster #554 receipt naming a non-existent `destination_path` under `docs/features/potential/promoted/`. No tool-call sequence or extension version accompanies the report.
- Frequency / determinism: intermittent in the original report. Deterministic in the unit-test reproduction described above.

## Scope & Non-Goals
- In scope:
  - A post-move existence check in `promotePotential` (`extensions/drm-copilot/src/lib/potential-to-issue/promotion.ts`).
  - The identical check in the Python parity source `promote_potential` (`scripts/dev_tools/potential_to_issue.py`), preserving the declared byte parity of emitted messages and decision branches.
  - Extraction of `FileSystem` and `RealFileSystem` from `scripts/dev_tools/potential_to_issue.py` into a new module `scripts/dev_tools/potential_to_issue_filesystem.py`, re-exported from `potential_to_issue.py`, so that the Python module's line count does not increase.
  - Regression tests in TypeScript and Python using injected fakes, and adjustment of the service-call test fake so the #487 receipt guard keeps branch coverage.
- Out of scope / non-goals:
  - Item 1 of #623 (PoshQC zero coverage, #527) and item 3 (bug-route tool-name mismatch, #405).
  - Any change to `new_active_feature_folder` or its flow.
  - Restoring or copying back the source file after a failed verification.
  - Reordering the move ahead of GitHub issue creation.
  - A `workspace_root` containment guard (research cause C3); candidate follow-up only.
  - Bringing `potential_to_issue.py` under 500 lines (tracked by #406).
  - Changes to the #487 receipt guard's behavior or message.
- Explicitly excluded systems, integrations, or datasets: bundled mirrors under `extensions/drm-copilot/resources/` (research found no tracked copy of the in-scope source files); `.claude/skills/feature-promotion-lifecycle/SKILL.md` and its mirror (unchanged); the gitignored `out/mcp-server.js` bundle.

## Root Cause Analysis
- Current hypothesis or confirmed root cause:
  - Most likely cause of the original TaskMaster report (research C1): the #487 lifecycle defect, in which `new_active_feature_folder` moved rather than copied the promoted record into `<active>/issue.md`. This produces the reported signature (source absent, promoted record absent, receipt naming the promoted path). The #487 fix and the receipt guard were completed on 2026-08-20. Attribution of the TaskMaster instance to C1 is supported but not proven, because the report carries no tool-call sequence or version.
  - Structural gap (confirmed by code reading): neither workflow layer verifies the destination after the move. The change in this spec is defense in depth at the move site, not a proven fix for the TaskMaster instance.
  - Other candidates evaluated by research: forward-slash paths on Windows (C2, not supported); mismatched `workspace_root` versus absolute `potential_path` (C3, code-consistent, not evidenced, and would not yield a non-existent `destination_path`); MSYS-form `workspace_root` (C4, not supported for the current tree; pre-#525 behavior unverified); `renameSync` returning without a destination (C5, not supported); external removal after the rename (C6, unverified, cannot be excluded, and only the window before the receipt can be covered).
- Signals/evidence supporting it: #487 controlled reproduction and QA artifacts (`docs/features/completed/2026-08-17-promotion-lifecycle-loses-promoted-record-487/`); code reading of `promotion.ts:430-442`, `potential_to_issue.py:548-554`, and `potential-to-issue-service-call.ts:215-226`.
- Affected components/modules:
  - `extensions/drm-copilot/src/lib/potential-to-issue/promotion.ts` (`promotePotential`)
  - `extensions/drm-copilot/src/lib/potential-to-issue/potential-to-issue-service-call.ts` (unchanged; consumes the non-zero outcome)
  - `scripts/dev_tools/potential_to_issue.py` (`promote_potential`, `FileSystem`, `RealFileSystem`, `main`)

## Proposed Fix

### Design summary (what changes where):
Research Approach A. Immediately after the move in each workflow, query the existing `exists` member of the injected filesystem for the destination path. If it reports absent, emit `Promoted file missing after move: <dest>` and return a non-zero outcome (exit code 1) with no destination. If it reports present, behavior is unchanged: emit the existing `Moved potential file to promoted folder: <dest>` line and return exit code 0 with the destination. A non-zero outcome is used instead of a thrown error so that the service-call layer's existing non-zero path (`potential-to-issue-service-call.ts:204-208`) reports `Command exited with code 1.` together with every emitted message, including the created issue URL.

### Boundaries and invariants to preserve:
- TypeScript and Python emit byte-identical message text and follow identical decision branches (declared in `promotion.ts:12-16`). In Python, `<dest>` renders with host separators, consistent with the existing "Moved" line.
- The "Moved" line is emitted only when the destination exists.
- The #487 receipt guard in `potential-to-issue-service-call.ts` remains in place with unchanged behavior and message, and keeps true-branch test coverage.
- `PotentialFileSystem` (TS) and `FileSystem` (Python) interfaces do not gain members.
- Existing imports of `FileSystem` and `RealFileSystem` from `scripts.dev_tools.potential_to_issue` continue to resolve to the same objects.
- A move that raises (for example cross-volume or permission errors) continues to propagate unchanged and leaves the source in place.

### Dependencies or blocked work:
- None blocking. #406 (oversized Python files) remains the owner of full file-size compliance for `potential_to_issue.py`.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
- `extensions/drm-copilot/src/lib/potential-to-issue/promotion.ts`: add the post-move `exists` branch after `filesystem.move(resolved, destPath)`.
- `scripts/dev_tools/potential_to_issue.py`: add the mirrored branch after `filesystem.move(resolved, dest_path)`; remove the `FileSystem` and `RealFileSystem` definitions and import them from the new module; remove the `Iterable` import if it becomes unused.
- New: `scripts/dev_tools/potential_to_issue_filesystem.py`: contains `FileSystem` (Protocol) and `RealFileSystem` moved verbatim, with required imports (`shutil`, `Path`, `Protocol`, `dataclass`, `Iterable`).
- Test files listed under Test Strategy.

#### Functions/classes/CLI commands impacted:
- `promotePotential` (TS), `promote_potential` and `main` (Python; `main` behavior changes only through the returned exit code).
- `potentialToIssueServiceCall` (TS; code unchanged, now receives exit code 1 in the missing-destination case).
- `FileSystem`, `RealFileSystem` (Python; relocated, re-exported, behavior unchanged).
- MCP tool `potential_to_issue`, Poetry script `dev.potential-to-issue`, VS Code task "Dev: 2 Promote Potential to GitHub Issue".

#### Data flow and validation changes:
- New validation step between the move and the "Moved" line: `filesystem.exists(destPath)` / `filesystem.exists(dest_path)`.
- On failure, `destination` is omitted (TS) / `None` (Python) in the outcome.

#### Error handling and logging updates:
- New emitted line: `Promoted file missing after move: <dest>`.
- MCP result on failure: `ok: false`, `summary` containing `Command exited with code 1.` followed by all emitted lines (including the `Created:` issue URL line and the missing-path line).
- Python CLI on failure: all lines printed, process exits with code 1.
- No source restoration is attempted: a successful rename has already removed the source.

#### Rollback/feature-flag considerations (if applicable):
- No feature flag. Rollback is a revert of the change set. The extraction is behavior-neutral and can remain if only the check is reverted.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- TS `PromotionOutcome` on missing destination: `{ exitCode: 1, messages: [..., "Promoted file missing after move: <destPath>"] }` with `destination` undefined.
- Python `PromotionOutcome` on missing destination: `PromotionOutcome(exit_code=1, messages=[..., f"Promoted file missing after move: {dest_path}"])` with `destination` `None`.
- Success outputs are unchanged in both languages.

#### Required configuration keys and defaults:
- None.

#### Backward-compatibility expectations:
- Success path outputs, messages, and receipts are unchanged.
- `from scripts.dev_tools.potential_to_issue import FileSystem, RealFileSystem` continues to work, and existing test subclasses of `mod.FileSystem` continue to work.
- Callers that relied on exit code 0 when the destination was absent now receive exit code 1; this is the intended change.

#### Performance constraints (latency/throughput/memory):
- One additional filesystem existence query per promotion. No measurable constraint applies.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access): the injected filesystem's `exists` reflects the post-move state; test fakes are Map/dict-backed. No live GitHub access is required for verification.
- Constraints (budget, performance, compatibility): 500-line limit for production and test files, with `potential_to_issue.py` already over the limit under #406 and required not to grow; `promotion.test.ts` is near 500 lines and must not receive the new cases; no temporary files in tests; TS/Python message parity.
- External dependencies (services, libraries, releases): none new. `quality-tiers.yml` is absent at the repository root, so the uniform gates apply.

## Data / API / Config Impact
- User-facing or API changes: new failure outcome and message for a missing destination on the MCP tool, Poetry script, and VS Code task.
- Data or migration considerations: none.
- Logging/telemetry updates (if any): the new emitted line only.
- Compatibility notes (CLI flags, config schemas, versioning): no CLI flag or schema changes. The Python CLI exit code changes from 0 to 1 only in the missing-destination case.

## Test Strategy
- Regression tests to add or update:
  - `extensions/drm-copilot/test/lib/potential-to-issue/promotion-test-support.ts`: add `DroppingMovePotentialFileSystem`, whose `move` removes the source without writing the destination.
  - New `extensions/drm-copilot/test/lib/potential-to-issue/promotion.move-verification.test.ts`:
    - `returns exit code 1 without a destination when the promoted file is missing after the move`: asserts `exitCode === 1`, `destination` undefined, last message `Promoted file missing after move: /workspace/docs/features/potential/promoted/sample.md`, messages include the `Created:` URL line, and no message starts with `Moved potential file to promoted folder:`.
    - `returns exit code 0 with the destination when the promoted file exists after the move`: positive control with `FakePotentialFileSystem`.
  - `extensions/drm-copilot/test/lib/potential-to-issue/potential-to-issue-service-call-test-support.ts`: add `LateBlockedPathPotentialFileSystem`, which reports the blocked path present on its first `exists` query for that path and absent on later queries.
  - `extensions/drm-copilot/test/lib/potential-to-issue/potential-to-issue-service-call.test.ts`:
    - Update `throws when the promoted destination is absent` to use `LateBlockedPathPotentialFileSystem`, so the workflow check passes and the #487 guard fires; its existing assertions (`toThrow("potential_to_issue")`, `toThrow(DESTINATION)`) remain.
    - Add `throws with the exit code, issue URL, and missing-path line when the workflow move check fails`, using `DroppingMovePotentialFileSystem`; asserts the thrown message contains `Command exited with code 1.`, `https://example.com/issues/123`, and `Promoted file missing after move:`.
  - New `tests/scripts/dev_tools/test_potential_to_issue_move_verification.py`:
    - `test_promote_potential_returns_exit_1_when_destination_missing_after_move`: dropping-move fake subclassing `mod.FileSystem`; asserts `exit_code == 1`, `destination is None`, last message `Promoted file missing after move: <dest>`, and no "Moved" message.
    - `test_promote_potential_returns_destination_when_move_succeeds`: positive control.
    - `test_filesystem_names_are_reexported`: asserts `potential_to_issue.FileSystem is potential_to_issue_filesystem.FileSystem` and the same for `RealFileSystem`.
  - New `tests/scripts/dev_tools/test_potential_to_issue_filesystem.py`: unit tests for each `RealFileSystem` method using pytest `monkeypatch` on `pathlib.Path` methods and `shutil.move` (no temporary files), so the new module meets the coverage threshold.
- Unit tests (pytest) for the fixed behavior and boundaries: as listed above.
- Edge cases and negative scenarios: destination absent after move (primary negative); destination present (positive control); move raises (existing behavior, covered by existing fakes that raise `FileNotFoundError` on a missing source); workflow check passes but receipt-time check fails (service-call guard retained).
- Error handling and logging verification: assert the exact message text in both languages and its presence in the service-call thrown message.
- Coverage impact and targets for changed lines/modules: line >= 85% and branch >= 75% for `promotion.ts`, `potential-to-issue-service-call.ts`, `potential_to_issue.py`, and `potential_to_issue_filesystem.py`, measured from the toolchain coverage output. Add a per-file `coverageThreshold` entry for `./src/lib/potential-to-issue/promotion.ts` in `extensions/drm-copilot/jest.config.cjs` only if measured coverage meets the thresholds.
- Fail-before evidence: run the new TS and Python negative tests against the unchanged production code and record the failing results under `<FEATURE>/evidence/regression-testing/`; record passing toolchain runs under `<FEATURE>/evidence/qa-gates/`.
- Toolchain commands to run:
  - TypeScript, from `extensions/drm-copilot/`: `npm run format`, `npm run lint`, `npm run typecheck`, architecture stage (no `.dependency-cruiser*` config exists; record absence), `npm run test:coverage`.
  - Python, from the repository root: `poetry run black .`, `poetry run ruff check .`, `poetry run pyright`, `poetry run pytest --cov --cov-branch --cov-report=term-missing`.
- Manual validation steps (if required): none required. A live promotion would create a real GitHub issue and is optional supplementary evidence only.

## Acceptance Criteria
- [ ] AC-1: `promotion.move-verification.test.ts` test `returns exit code 1 without a destination when the promoted file is missing after the move` passes: with `DroppingMovePotentialFileSystem`, `promotePotential` returns `exitCode` 1, `destination` undefined, last message `Promoted file missing after move: /workspace/docs/features/potential/promoted/sample.md`, messages include the `Created:` issue URL line, and no message starts with `Moved potential file to promoted folder:`.
- [ ] AC-2: The AC-1 test fails when run against the pre-change `promotion.ts`, and the failing run is recorded under `docs/features/active/promotion-receipt-destination-unverified-623/evidence/regression-testing/`.
- [ ] AC-3: TypeScript success path unchanged: `promotion.move-verification.test.ts` test `returns exit code 0 with the destination when the promoted file exists after the move` passes, and the existing `promotion.test.ts` success case, `promotion.matrix.test.ts`, and `promotion-lifecycle-sequence.test.ts` pass without modification.
- [ ] AC-4: `potential-to-issue-service-call.test.ts` test `throws with the exit code, issue URL, and missing-path line when the workflow move check fails` passes: the thrown message contains `Command exited with code 1.`, `https://example.com/issues/123`, and `Promoted file missing after move:`.
- [ ] AC-5: #487 receipt guard remains covered: `potential-to-issue-service-call.test.ts` test `throws when the promoted destination is absent` passes using `LateBlockedPathPotentialFileSystem` with its `toThrow("potential_to_issue")` and `toThrow(DESTINATION)` assertions intact, the positive case `returns the enriched record when the destination exists` passes unmodified, `git diff main -- extensions/drm-copilot/src/lib/potential-to-issue/potential-to-issue-service-call.ts` is empty, and coverage output shows the guard's true branch (lines 219-226) executed.
- [ ] AC-6: `tests/scripts/dev_tools/test_potential_to_issue_move_verification.py::test_promote_potential_returns_exit_1_when_destination_missing_after_move` passes: `exit_code == 1`, `destination is None`, last message `Promoted file missing after move: <dest>`, and no "Moved" message. The test fails against the pre-change `potential_to_issue.py`, and the failing run is recorded under the feature `evidence/regression-testing/` folder.
- [ ] AC-7: Python success path unchanged: `test_promote_potential_returns_destination_when_move_succeeds` passes, and the existing `test_potential_to_issue.py`, `test_potential_to_issue_branches.py`, and `test_potential_to_issue_missing_label_regression.py` pass without modification.
- [ ] AC-8: The new message text is identical in both languages: `Promoted file missing after move: ` appears in `promotion.ts` and `potential_to_issue.py` (verified by `git grep -n "Promoted file missing after move: "` returning a match in each file).
- [ ] AC-9: `FileSystem` and `RealFileSystem` are defined in `scripts/dev_tools/potential_to_issue_filesystem.py`, are no longer defined in `scripts/dev_tools/potential_to_issue.py`, and remain importable from `scripts.dev_tools.potential_to_issue` as the same objects (`test_filesystem_names_are_reexported` passes).
- [ ] AC-10: The line count of `scripts/dev_tools/potential_to_issue.py` on the branch is less than or equal to its line count at `git merge-base HEAD main`, compared with `(Get-Content scripts/dev_tools/potential_to_issue.py).Count` against `(git show "$(git merge-base HEAD main):scripts/dev_tools/potential_to_issue.py" | Measure-Object -Line).Lines`, with the result recorded in the feature evidence folder.
- [ ] AC-11: Every new or changed file other than `scripts/dev_tools/potential_to_issue.py` is at or below 500 lines, including `promotion.ts`, `potential_to_issue_filesystem.py`, and all new or modified test files.
- [ ] AC-12: `tests/scripts/dev_tools/test_potential_to_issue_filesystem.py` exercises every `RealFileSystem` method using `monkeypatch` only, and no test added or changed by this item creates a temporary file or directory.
- [ ] AC-13: Full TypeScript toolchain passes in a single pass from `extensions/drm-copilot/` (`npm run format`, `npm run lint`, `npm run typecheck`, architecture stage recorded, `npm run test:coverage`), with line coverage >= 85% and branch coverage >= 75% for `promotion.ts` and `potential-to-issue-service-call.ts`, recorded under the feature `evidence/qa-gates/` folder.
- [ ] AC-14: Full Python toolchain passes in a single pass from the repository root (`poetry run black .`, `poetry run ruff check .`, `poetry run pyright`, `poetry run pytest --cov --cov-branch --cov-report=term-missing`), with line coverage >= 85% and branch coverage >= 75% for `potential_to_issue.py` and `potential_to_issue_filesystem.py`, recorded under the feature `evidence/qa-gates/` folder.
- [ ] AC-15: No changes outside the declared scope: `git diff --name-only main` lists no file under `extensions/drm-copilot/src/lib/new-active-feature-folder/`, `extensions/drm-copilot/resources/`, or `.claude/skills/feature-promotion-lifecycle/`.

## Risks & Mitigations
- Technical or operational risks:
  - The GitHub issue is created before the move, so a missing-destination failure leaves a created issue with no promoted record. This residual is not addressed by this item.
  - The new workflow check makes the existing `BlockedPathPotentialFileSystem` scenario fail at the workflow layer first, which would leave the #487 guard's true branch untested and break the existing `toThrow("potential_to_issue")` assertion.
  - Extraction could break existing Python imports or subclassing of `mod.FileSystem`, or leave an unused `Iterable` import that fails ruff.
  - External removal after the receipt is built (research C6) cannot be detected by any check in this change.
  - The fix may not address the actual cause of the TaskMaster instance, which is most likely #487 and is unproven.
- Mitigations and rollbacks:
  - The non-zero outcome carries the created issue URL to the caller (AC-4), so the caller can act on the orphaned issue.
  - `LateBlockedPathPotentialFileSystem` keeps the guard's true branch covered (AC-5).
  - Re-export plus an identity test (AC-9) and unmodified existing Python tests (AC-7) guard the extraction; ruff runs in AC-14.
  - Rollback is a revert of the change set.

## Rollout & Follow-up
- Release/rollout steps: merge through the standard PR flow. The MCP bundle is rebuilt from source at extension build time; no tracked artifact requires regeneration. Consumers receive the TypeScript change after the extension is rebuilt and reinstalled.
- Post-fix monitoring or clean-up tasks:
  - Consider filing a potential entry for a `workspace_root` containment guard (research C3), which is not evidenced and not part of this fix.
  - Confirm and, if needed, correct the TaskMaster #554 date in `issue.md` (2026-09-02 recorded locally versus 2026-08-14 in an unverified WebFetch summary).
  - #406 continues to own reducing `potential_to_issue.py` below 500 lines.
- Links: issue https://github.com/drmoisan/drm-copilot/issues/623; related #487 (`docs/features/completed/2026-08-17-promotion-lifecycle-loses-promoted-record-487/`), #406, #527, #405; research record listed in the header.
