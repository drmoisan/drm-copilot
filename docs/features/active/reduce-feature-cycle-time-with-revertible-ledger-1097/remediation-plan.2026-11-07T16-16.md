# reduce-feature-cycle-time-with-revertible-ledger - Remediation Plan (Stage F1, merge of main after PR #1108)

- **Issue:** #1097
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-07T16-16
- **Status:** Planned by `atomic-planner`; awaiting executor preflight
- **Version:** 1.0
- **Remediation-Mode:** proportionate
- **Inputs:** `remediation-inputs.2026-11-07T16-16.md` (primary)

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- PowerShell: [`.github/instructions/powershell-code-change.instructions.md`](../../../../.github/instructions/powershell-code-change.instructions.md), [`.github/instructions/powershell-unit-test.instructions.md`](../../../../.github/instructions/powershell-unit-test.instructions.md)

**All work must comply with these policies; do not duplicate their content here.**

## Scope

Blocking finding F1 only: merge `origin/main` (which carries PR #1108, issue #1106) into the branch as one merge commit, then rebase the ledger over it in their own commits. No acceptance-criterion text, baseline text, comparison text, `execution-environment` brief, Epic #1019 folder, or tag changes. The `Merge commit:` lines of the entries stay as they are. No forced push, no history rewrite.

## Conflicted Regions: What Each Side Changed and How Both Are Kept

Read from the item worktree files, the local `main` checkout that carries PR #1108, and the `0006` stored patch. The executor confirms each row against the diff from the merge base of `origin/main` and `HEAD` before editing; the list of conflicted paths comes from `git status` at merge time. Each source and its bundle copy receive the same resolution and end byte-identical.

| File | Region | PR #1108 changed | This branch (stage E2 restore) changed | Resolution keeps both |
| --- | --- | --- | --- | --- |
| `.claude/agents/csharp-typed-engineer.md` | frontmatter `description` | `xUnit` to `MSTest` in the toolchain phrase | tail now reads "zero-regression quality gates read from the single gate run and compared with the `Phase 0 baseline`" | MSTest in the toolchain phrase plus the E2 tail |
| same | `Plan and baseline` step | `xUnit` to `MSTest` in the test-strategy phrase | "Phase 0 baseline capture (static baselines and the `Phase 0 baseline` test-suite run)" | MSTest test-strategy phrase plus the E2 baseline clause |
| same | intro paragraph, steps 5 and 6, stop condition | intro only: `xUnit` to `MSTest` | steps 5 and 6 and the stop condition only | no overlap; both apply |
| `.claude/skills/csharp-qa-gate/SKILL.md` | frontmatter `description` | `xUnit` to `MSTest` | sentence rewritten to compare against the Phase A baseline and enforce zero-regression deltas | E2 sentence with MSTest as the toolchain name |
| same | requirements section | heading `Gate Requirements (Hard Gate)` and bullet `MSTest gate` | heading `Delta Requirements (Zero-Regression Hard Gate)` and bullet `xUnit delta` with the per-file and overall deltas | E2 heading and delta bullets, with the bullet named `MSTest delta` |
| same | `Required Inputs` and reporting block | none | baseline record and baseline line name `xUnit` | auto-merged text still says `xUnit`; the sweep in [P1-T1] renames it |
| `.claude/skills/invoke-csharp-engineer/SKILL.md` | frontmatter `description` and `Applies` list | `xUnit` to `MSTest` in both | description tail "zero-regression quality gates ... compared with the `Phase 0 baseline`" | MSTest plus the E2 tail |
| same | `Output Paths` and `Required Reporting Block` | none | baseline evidence wording; baseline and QA-result lines name `xUnit` | E2 lines kept; sweep renames `xUnit` to `MSTest` |
| `.codex/agents/powershell-di-unit-test-engineer.toml` | `description` key | `Pester v5` to `Pester v6`; tail "the parallel test gates" | tail "zero-regression gates on the parallel test gates against the `Phase 0 baseline`" | `Pester v6` plus the E2 tail |
| `.github/agents/Powershell DI Unit Test Engineer.agent.md` | frontmatter `description` | `Pester v5` to `Pester v6`; tail "the parallel test gates" | tail "zero-regression gates" | `Pester v6` plus "zero-regression gates" |
| same | frontmatter `argument-hint` (adjacent to `description`, so in the same conflict hunk) | none | "I will baseline" restored | E2 text; no overlap |
| same | bullet list of tests | `Pester v5` to `Pester v6` | none | #1108 text; no overlap |
| same | handoff prompts, delta and baseline bullets | none | E2 baseline and zero-regression wording | E2 text; no overlap |
| five bundle copies under `extensions/drm-copilot/resources/` | all of the above | same as source | same as source | re-copied from the resolved source |

Premise corrections, each read against the tree:

- **No `Current` block of `0001` or `0006` covers a conflicted file.** Their `Revert Block` sections name the three `atomic-plan-contract` sources, the brief `.claude/skills/execution-environment/SKILL.md`, and the policy-audit template. The conflicted files appear in the entries only in `## Files Changed` and in the stored patches. [P1-T2] and [P1-T3] therefore rebase the patches; the blocks are re-checked by replay and edited only if replay fails.
- **The `0001` stored patch also covers these files.** After the `0006` patch is reversed, the `0001` patch hunks over the five sources and their bundles carry `xUnit` and `Pester v5` context that #1108 renamed. [P1-T3] checks the chained reverse application (the `0006` patch, then the `0001` patch) in a scratch index and rebases the `0001` patch only for paths that fail.
- **Auto-merged lines can carry stale framework names.** A line only this branch restored can still read `xUnit` or `Pester v5` in a file #1108 renamed. The sweep derives its token pairs from #1108's own diff of that file and applies them only to lines this branch added; files #1108 did not change keep their text (for example the `.agents` copies, which #1108 left unchanged).

## Execution Terms

- `FEATURE` is `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097`.
- `SCRATCH` resolves to `<session scratchpad>/issue-1097/`. Launchers, helper scripts, scratch indexes, and coverage reports live there with names starting `issue-1097-`; artifacts record the token, never a host path.
- Tool routes come from the `execution-environment` skill and are not restated here.
- Commits: commit and push after each task with a conventional subject and the session attribution lines supplied at execution; a normal push only. [P1-T1] is one merge commit that holds only the conflict resolution, the sweep, and any generator output. [P1-T2] carries `reduction: 0006` in its subject. [P1-T3] carries `reduction: 0001` when entry `0001` changes. No tags.
- Testing rule (owner's standing instruction): tests run in parallel only. The Pester gate is one `Invoke-PoshQCParallelTest` run, the pytest gate is one `pytest -n auto` run, and Jest runs through its normal workers; each is re-run only after a fix. No single-process, seeded-shuffle, reversed-order, or comparison run. A task never runs an unqualified `poetry install` from the worktree; if the worktree cannot run a gate, stop and report.
- Hold: no baseline task, baseline evidence, or baseline comparison is reduced; Phase 0 runs no suite.
- Reading the Pester gate: `EXIT_CODE:` records the `ExitCode` property of the object `Invoke-PoshQCParallelTest` returns; merged `artifacts/pester/pester-junit.xml` is valid only when it is 0.
- Failure outside the branch: a failing test whose file and subject are both absent from the diff from the merge base of `origin/main` and `HEAD` taken after the merge. The artifact names it, `EXIT_CODE:` stays non-zero, the task stays unchecked, and the executor returns the facts. Any other failure is fixed and the loop restarts from [P2-T1].

## Implementation Plan (Atomic Tasks)

### Phase 0 — Baseline Capture

- [x] [P0-T1] Read the recorded stage E2 Phase 0 baseline artifacts under `FEATURE/evidence/baseline/` alone, with no suite run, and write `FEATURE/evidence/baseline/stage-f1-recorded-baseline.<timestamp>.md`.
  - Sources: the lexicographically greatest `stage-e2-powershell-test-baseline.*.md`, `stage-e2-python-test-baseline.*.md`, `stage-e2-typescript-test-baseline.*.md`, `stage-e2-powershell-static.*.md`, and `stage-e2-python-static.*.md`. `Command:` records that the artifact is a read of those files, and `EXIT_CODE:` is 0 when all five were read.
  - Output Summary: the Pester total and failed counts and repo-wide PowerShell line percentage with the per-file figures of the changed PowerShell files; the pytest passed and failed counts with the line and branch totals and per-file figures of the changed Python files; the Jest suite and test counts with the line and branch totals and per-file figures; and the static format and analyzer totals, each copied from its source. Where a source records no per-file figure, the artifact states so with `SearchScope:`, `SearchPatterns:`, and `SearchResult:` lines rather than inventing one; the branch's changed production files are PowerShell only (no Python or TypeScript production file is in the diff from the merge base).
  - Acceptance: the artifact exists and carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with numeric values. It edits no existing baseline artifact.

### Phase 1 — Remediation Edits

- [x] [P1-T1] Merge `origin/main` into the branch in one merge commit that resolves the ten conflicted files per the region table, and write `FEATURE/evidence/other/stage-f1-merge-resolution.<timestamp>.md`.
  - Merge: fetch `origin`, then `git merge origin/main` from the worktree; the commit message names PR #1108 and issue #1106. The commit holds no ledger edit. Conflicted files: `.claude/agents/csharp-typed-engineer.md`, `.claude/skills/csharp-qa-gate/SKILL.md`, `.claude/skills/invoke-csharp-engineer/SKILL.md`, `.codex/agents/powershell-di-unit-test-engineer.toml`, `.github/agents/Powershell DI Unit Test Engineer.agent.md`, and the five bundle copies under `extensions/drm-copilot/resources/`. Any further conflicted path found by `git status` is resolved the same way and recorded.
  - Resolve each region per the table: #1108's wording and the E2 restored baseline and comparison lines both stay.
  - Sweep: for each file #1108 changed that also holds lines this branch added (the added lines of the stored `0006` patch), derive the renamed token pairs from #1108's diff of that file and rename the stale tokens (`xUnit` to `MSTest`, `Pester v5` to `Pester v6`) in this branch's added lines only. The artifact lists each file, the pair, and the count.
  - Mirrors: re-copy each resolved source to its bundle copy, then run the Codex generator `scripts/dev_tools/generate_codex_agent_variants.py` in module form, then with `--check`. Generated output joins the merge commit.
  - Existing tests asserting the wording, found by searching `tests` for the five file names and the tokens `xUnit`, `MSTest`, `Pester v5`, `Pester v6`: those from #1108 (`test_csharp_typed_engineer_*`-style and policy-consistency suites) are unchanged because the resolved text keeps #1108's names; `parallel-gate-wording.Tests.ps1` and `test_codex_orchestration_contracts.py` assert the E2 wording, which the resolution keeps, and are unchanged; any test found that disagrees is named in the artifact with its disposition.
  - Acceptance: a search of the tree for the seven-character conflict markers returns no path beyond those that already carry them at the pre-merge `HEAD` (the `tests/fixtures/project_file_merge` fixtures and two archived documents), and no match in any conflicted path or bundle copy; `git hash-object` returns one value per source and bundle pair; the generator `--check` exits 0; the merge commit has two parents; and the artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P1-T2] Rebase entry `0006` over the merged tree in one commit with `reduction: 0006` in its subject, editing `docs/engineering/process-reductions/patches/0006-test-suite-baseline-restored.patch` and `docs/engineering/process-reductions/0006-test-suite-baseline-restored.md`, and write `FEATURE/evidence/other/stage-f1-patch-rebase-0006.<timestamp>.md`.
  - Patch: in a scratch index under `SCRATCH` (a `GIT_INDEX_FILE` set from a launcher script file, seeded with `git read-tree` of `HEAD`), build the pre-0006 tree for the entry's `## Files Changed` path set. Reverse-apply the old patch with `git apply -R --cached` for every path whose check passes; for each path whose check fails (the ten conflicted paths and any other path #1108 touched), build the pre-image by reverse-applying that path's old hunks by hand to the merged file, keeping #1108's wording, store it with `git hash-object -w` and `git update-index --cacheinfo`. Write the tree, then write the new patch as a git diff with the binary and no-renames options, from that tree to `HEAD`, over the path set.
  - Entry: edit `## Stored Patch` to say the patch diffs from the 0001-state text with #1108's wording to the current text and that the entry was rebased over #1108 (PR #1108, issue #1106); add the same sentence to `## Reason and Evidence`. Re-check every `Revert Block` by replay; a block whose `Current` no longer matches the merged text is edited so it replays to its `Prior` text, and the artifact names it (expected: none, by the premise correction). `Prior` text of unaffected blocks is untouched.
  - Asserting tests, found by searching `tests` for `0006-test-suite-baseline-restored`: `ProcessReductionLedger.Index.Tests.ps1` and the ledger suites read the entry structure only and are unchanged because the heading set is unchanged.
  - Acceptance: `git apply -R --check` of the new patch exits 0 against the working tree; `Test-ProcessReductionLedger` over `Read-ProcessReductionLedger` is valid; the entry text records the rebase over #1108; the artifact carries the four required fields.
- [ ] [P1-T3] Check the `0001` patch against the merged tree through the chained reverse application, rebase it only if the check fails, and write `FEATURE/evidence/other/stage-f1-patch-rebase-0001.<timestamp>.md`.
  - Check: in a fresh scratch index under `SCRATCH` seeded from `HEAD`, run `git apply -R --cached` of the committed `0006` patch, then `git apply -R --cached --check` of `docs/engineering/process-reductions/patches/0001-parallel-only-test-gates.patch`. The artifact records both exit codes.
  - Rebase (only for paths the check rejects): build the pre-0001 pre-image per path as in [P1-T2], regenerate the `0001` patch over the `## Files Changed` set of `docs/engineering/process-reductions/0001-parallel-only-test-gates.md`, add the sentence recording the rebase over #1108 to its `## Summary`, and commit with `reduction: 0001` in the subject. When the first check passes, entry `0001` and its patch are unchanged, no commit is made, and the artifact states that.
  - Asserting tests: the same ledger suites named in [P1-T2], unchanged for the same reason.
  - Acceptance: the chained `--check` exits 0 after the task; the `0001` `Revert Block` sections replay to their `Prior` text; the artifact carries the four required fields.

### Phase 2 — Final QA

- [x] [P2-T1] Run format and lint over the changed PowerShell, Python, and TypeScript files, the mirror and generator checks, and the ledger replay, and write `FEATURE/evidence/qa-gates/stage-f1-format-lint-ledger.<timestamp>.md`.
  - Changed files: every `.ps1`, `.psm1`, `.py`, and `.ts` path in the diff from the merge base of `origin/main` and `HEAD` (after the merge this is the branch's own change set), plus those paths in the working tree status.
  - PowerShell: `Invoke-PoshQCFormat` check-only with a no-op `-WriteFile`, then `Invoke-ScriptAnalyzer` directly with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`. Acceptance: an `Already formatted: ` line and no `Formatted: ` line per file, and findings number zero.
  - Python and TypeScript: Black check, Ruff check without fixing, and Pyright; Prettier check, ESLint, and `tsc` with the test project. Acceptance: Black reports each file unchanged and every other exit is 0.
  - Mirrors: the Codex generator `--check` exits 0; one `git hash-object` value per source and bundle pair for the five conflicted pairs and for every other bundle pair in the `0006` and `0001` path sets.
  - Ledger: `Test-ProcessReductionLedger` is valid; every `Revert Block` of every entry (`0001` to `0006`) applied with `Invoke-ProcessReductionRevert` gives its stated `Prior` text against the merged tree, after line-ending normalization, with a differing-path count of 0; `git apply -R --check` of the `0006` patch exits 0.
  - `EXIT_CODE:` is non-zero when any condition fails. A failure is repaired, committed, pushed, and this task restarts.
- [x] [P2-T2] Run the three test gates once each, compare them with the `stage-f1-recorded-baseline` artifact, and write `FEATURE/evidence/qa-gates/stage-f1-test-gates.<timestamp>.md`, leaving the coverage files on disk.
  - Pester: one `Invoke-PoshQCParallelTest` from the worktree root. Acceptance: the returned `ExitCode` is 0; the failed count in `artifacts/pester/pester-junit.xml` is zero; `parallel-gate-wording.Tests.ps1`, `planning-contract-wording.Tests.ps1`, and `ProcessReductionLedger.Tests.ps1` pass; repo-wide and per-changed-file line percentages from `artifacts/pester/powershell-coverage.xml` are at least 85% and show no drop from the baseline artifact wherever that artifact records the figure (the per-file figures are judged against the threshold where the recorded baseline carries none).
  - pytest: from the worktree root with `PYTHONPATH` set to the worktree's `packages/discovery-runtime/src`, one `poetry run pytest -n auto --cov --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1097-f1-coverage.json`. Acceptance: exit 0 with zero failed; the bundle-parity and Codex contract suites pass; line at least 85% and branch at least 75% per changed file and in total, read from the JSON, with no drop from the baseline.
  - Jest: in `extensions/drm-copilot`, one `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`, leaving `extensions/drm-copilot/coverage/lcov.info` and the pytest `artifacts/python/lcov.info` on disk. Acceptance: exit 0 with zero failed; line at least 85% and branch at least 75% in total and per changed file, with no drop from the baseline.
  - Comparison: no new failing test against the baseline, and no per-file or repo-wide coverage drop; new behavior is tested (this cycle adds none: the diff holds a merge, documentation, and a patch). Figures are read from this run alone and from files, not MCP output. A failure is classified under Execution Terms; a fix restarts from [P2-T1].
- [ ] [P2-T3] Walk the policy-audit, code-review, and feature-audit templates under `docs/features/templates/policy_audit/` against the branch diff from the merge base of `origin/main` and `HEAD`, and write `FEATURE/evidence/qa-gates/self-review.<timestamp>.md` with one PASS, FAIL, or N/A row per checklist item.
  - Scope rows: this cycle adds the merge commit, the rebased `0006` patch and entry, the `0001` patch and entry only if the chained check failed, and `FEATURE` artifacts; no acceptance-criterion text, baseline text, comparison text, Epic #1019 folder, `execution-environment` brief, or tag changes.
  - Acceptance: F1 has a row naming the proving artifacts (merge resolution, both patch rebases, format-lint-ledger, test gates); the history check row states the push was non-forced and no history was rewritten; no row is FAIL. A FAIL row is fixed, the loop re-runs from [P2-T1], and this artifact is rewritten.

## Pre-Mortem

- Review checklists: the likely finding is a lost side of a conflict. The region table names both sides per region, [P1-T1] records each resolution and the sweep, and [P2-T3] maps F1 to the artifacts. Re-review follows because the merge commit stales the reviewed head.
- Coverage: the diff holds a merge, documentation, and a patch; no production source is authored. [P2-T2] reads repo-wide and per-changed-file figures from the single run of each gate against 85% line and 75% branch and against the recorded stage E2 baseline. Pester measures no branch coverage.
- Mirror parity: [P1-T1] re-copies the five bundle pairs and runs the Codex generator, and [P2-T1] compares every pair by hash and runs `--check`. The cycle alters no fact the `execution-environment` brief states, so no brief-update task is needed; the brief copies are untouched.
- File size: the patch is a text fixture and Markdown is exempt; the edited agent and skill files change by wording only and no PowerShell, Python, or TypeScript file grows.
- Test isolation: the gates are one `Invoke-PoshQCParallelTest`, one `pytest -n auto`, and Jest through its normal workers, each re-run only after a fix. The scratch index and helper scripts live under `SCRATCH`; no test creates a file.
- CI-only behavior: the PR was conflicting and ran no checks, so the first CI run is on the merged head. Bundle and generator contract suites run in the pytest gate here; `.gitattributes` normalizes line endings, and the patch is generated on the worktree with LF endings so it applies on a Linux checkout.
- Evidence: artifacts live under `FEATURE/evidence/baseline/`, `other/`, and `qa-gates/` with write-time stamps and the four required fields, and record `SCRATCH`, never a host path. Phase 0 reads recorded artifacts, runs no suite, and no baseline, comparison, or `N/A - no pre-change run` text is reduced.

## Test Plan

- Merge: marker search, hash equality per bundle pair, and the Codex generator `--check` in [P1-T1].
- Ledger: patch reverse-application checks in [P1-T2] and [P1-T3], and the replay of every entry in [P2-T1].
- Gates: [P2-T2] with the single parallel run of each suite, compared with the stage E2 baseline.

## Open Questions / Notes

- The reviewed head is named in `remediation-inputs.2026-11-07T16-16.md`. The merge commit stales that review, so a re-review follows, and the `[E]` criterion is re-checked only after it.
- This plan was authored without a shell, so the region table is read from files and the stored patch rather than from `git diff`; [P1-T1] confirms it against the real diff and records any difference.
