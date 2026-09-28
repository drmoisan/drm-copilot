# Preflight Round 1 — atomic-executor report (issue #643)

- Timestamp: 2026-09-07T13:38Z
- Plan: `docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/plan.2026-09-07T08-13.md`
- Plan commit reviewed: `db930463` (pre-rebase); the branch was rebased after this report onto `origin/main` `c3ffb080`; branch head is now `c16d2ae6` and the merge base with `origin/main` is `c3ffb080`.
- Signal: `PREFLIGHT: REVISIONS REQUIRED`
- Convergence: `CONVERGENCE: NO FURTHER ROUNDS EXPECTED` (every defect has a mechanical delta; no design change)
- Validator: `validate_plan_text_with_warnings` with a live repository seam reported 0 Blocking and 0 Warning findings (G1-G9 clean). The defects below are in the classes the validator cannot reach: unobservable or vacuous acceptance output, and task ordering.

## Verification summary (what checked out)

Confirmed correct against the tree: the AC inventory (spec.md 39 + 7 + 5 = 51 at lines 190-228, 240-246, 249-253; user-story.md 11 at lines 52-62), the work-mode marker, all check-off arithmetic (3, 5, 12, 19, 34, 38, 42, 51 and 1, 2, 8, 11), all Phase 1-5 PowerShell/Python line anchors, all TypeScript anchors, and the rule-file anchors (347/354/369-370). Every named test node ID exists. C5's surface-contract claims are exact (`len(prescribed) == 3`, nine agent headings, `MERGE_CONFLICT_FRAGMENTS`, six header fields). C4's #510 exemption reproduces on this tree. C3's observed outputs are corroborated by the cited precedent artifact. `_entries_overlap("Proj/**","Proj/*.csproj")` is `True` and the detail renders `Proj/** ~ Proj/*.csproj`.

## Blocking defects

### B1 — [P0-T15] The `git diff origin/main` scope assertion was already false

Post-rebase state: the branch is rebased onto `origin/main` (`c3ffb080`), so `git diff c3ffb080 --name-only` lists exactly six paths today: the four feature documents (`issue.md`, `plan.2026-09-07T08-13.md`, `spec.md`, `user-story.md`), the research artifact, and `docs/features/potential/promoted/2026-09-07-mergeable-project-file-overlaps.md`. Delta: anchor every scope diff to the merge-base commit `c3ffb080` (a fixed ancestor; stable even if `origin/main` advances again), add `--untracked-files=all` to the porcelain companion, and enumerate the six-path expected set plus a note that `c3ffb080` is the merge base.

### B2 — [P8-T15] The allowed-path enumeration omits paths that are in the change set

Add `docs/features/potential/promoted/2026-09-07-mergeable-project-file-overlaps.md` and `extensions/drm-copilot/jest.config.cjs` (see B8) to the allowed list; anchor the diff to `c3ffb080` and add `--untracked-files=all`.

### B3 — [P1-T12, P2-T8, P3-T13, P4-T12, P5-T22, P6-T9, P7-T8, P8-T17, P8-T18] The check-off assertions are unsatisfiable

`spec.md` and `user-story.md` are added files relative to the merge base (`--numstat` shows `253 0` and `70 0`). The removed count is structurally `0`, so "equal added and removed counts" and a `- [ ]` to `- [x]` diff pair can never hold. Delta: replace with direct checkbox counts. For each task with its scheduled N (3, 5, 12, 19, 34, 38, 42, 51 for spec.md; 1, 2, 8, 11 for user-story.md):

> Acceptance: `grep -c -F "- [x] " docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/spec.md` prints `N`, `grep -c -F "- [ ] " docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/spec.md` prints `51 - N`, and `git diff c3ffb080 --numstat -- docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/spec.md` reports a removed count of `0` and an added count of `253`.

The literals `- [x] ` and `- [ ] ` must be quoted verbatim in the plan outside the command span. `grep -c -F "- [x] " spec.md` prints `0` today.

### B4 — [P2-T4] The asserted pass count is one short

`poetry run pytest tests/scripts/dev_tools/test_parallel_drift_detection_conflicts.py --collect-only -q` reports `15 tests collected` today. After adding one test the count is 16. Delta: `prints \`16 passed\``.

### B5 — [P5-T3] `git grep` skips untracked files

The plan commits nothing during execution, so `.claude/lib/project-file-merge/Resolve-MergeableConflict.ps1` is untracked when the acceptance runs and `git grep` never sees it. Delta:

> Acceptance: `grep -c -F "InvocationName -ne '.'" .claude/lib/project-file-merge/Resolve-MergeableConflict.ps1` prints `1`; `grep -c -E "git add|git commit|'add'|'commit'" .claude/lib/project-file-merge/Resolve-MergeableConflict.ps1` prints `0`; and `wc -l .claude/lib/project-file-merge/Resolve-MergeableConflict.ps1` reports at most 260.

### B6 — [P5-T2, P5-T19] The no-XML search is vacuous for the same reason

Delta in both tasks: `grep -r -c -E "System\.Xml|\[xml\]" .claude/lib/project-file-merge` prints `0` for every file it lists.

### B7 — [P6-T6] Both acceptance greps are already zero before the change

Both target sentences wrap across lines today (`parallel-orchestrator.md` 225-226; `parallel-orchestrate/SKILL.md` 446-447), so "prints nothing" holds before and after. Delta: assert the new single-line tokens and require the replacement text to keep them unwrapped:

> - [ ] [P6-T6] Narrow the two "add no field" sentences. In `.claude/agents/parallel-orchestrator.md`, inside `## Checkpoint Persistence`, replace the wrapped sentence `You consume that schema and add no field to it.` so the replacement carries the fragment `add no field to it that the rule file does not declare` on a single unwrapped line, followed by `` `mergeable_conflicts_resolved` is the one declared optional item field. `` In `.claude/skills/parallel-orchestrate/SKILL.md`, inside `## Parallel-Level Checkpoint`, replace the wrapped sentence `Consume that schema; add no field to it and extend no enum in it.` so the replacement carries the fragment `add no field to it that` on a single unwrapped line and names `` `.claude/rules/parallel-orchestration.md` `` as the declaring file and `mergeable_conflicts_resolved` as the one declared optional item field. Copy both files to their mirrors. Acceptance: `git grep -c -F "add no field to it that the rule file does not declare" -- .claude/agents/parallel-orchestrator.md` reports a count of 1 for that path; `git grep -c -F "add no field to it that" -- .claude/skills/parallel-orchestrate/SKILL.md` reports a count of 1; `git grep -c -F "mergeable_conflicts_resolved" -- .claude/agents/parallel-orchestrator.md .claude/skills/parallel-orchestrate/SKILL.md` reports a count of 1 for each file; and both mirror SHA-256 hashes equal their source hashes.

All four literals are new to the tree and must be quoted verbatim in constraint C6. Note: these two files are tracked, so `git grep` is valid here; for untracked new files use plain `grep`.

### B8 — No task gates the new TypeScript production file for coverage

`extensions/drm-copilot/jest.config.cjs` carries a `coverageThreshold` map with no `global` key (its own comment for issue #596 records that a new production file without its own entry is ungated). P4-T1 creates `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-manifests.ts` and no task adds its entry. Delta: insert after P4-T2 and renumber the remainder of Phase 4:

> - [ ] [P4-T3] Add a `coverageThreshold` entry for `"./src/lib/push-down/claude-blast-radius-derive-manifests.ts"` with `lines: 85` and `branches: 75` to `extensions/drm-copilot/jest.config.cjs`, immediately after the existing `"./src/lib/push-down/claude-blast-radius-derive-core.ts"` entry, preceded by a comment naming issue #643 and stating that the map carries no `global` key so a new production file without its own entry is ungated. Acceptance: `git grep -c -F "claude-blast-radius-derive-manifests.ts" -- extensions/drm-copilot/jest.config.cjs` reports a count of 1 for that path, and `wc -l extensions/drm-copilot/jest.config.cjs` reports at most 300.

### B9 — [P6-T2, P5-T17, P5-T6] Three acceptance commands are not executable as written

Backticks inside a double-quoted Bash string open command substitution, and `$t` is expanded by Bash before `pwsh` sees it. Delta: single-quote every pattern containing a backtick and single-quote the whole `-Command` payload.

> P6-T2: `git grep -c -F '`version`, `over_breadth_fraction`, `mandate_reads`, and `mergeable_paths`' -- .claude/rules/parallel-orchestration.md` reports a count of 1; `git grep -c -F 'and `mandate_reads` are byte-equal' -- .claude/rules/parallel-orchestration.md` reports no match (exit 1).
> P5-T17: `git grep -c -E 'section `## Mergeable' -- .claude/skills/parallel-orchestrate/SKILL.md` reports no match (exit 1).
> P5-T6: `pwsh -NoProfile -Command 'Set-Variable t ([System.IO.File]::ReadAllText("tests/fixtures/project_file_merge/crlf-compile.conflicted.csproj")); ([regex]::Matches($t, "\r\n")).Count -eq ([regex]::Matches($t, "\n")).Count'` prints `True`.

Verified baselines: the `and `mandate_reads` are byte-equal` fragment currently matches line 369; the four-name fragment currently matches nothing.

## Task-ordering defects

### O1 — [P6-T2, P6-T3] cite line numbers that P6-T1 invalidates

P6-T1 inserts a subsection before line 263 of `.claude/rules/parallel-orchestration.md`, shifting 354 and 369-370. Delta: content anchors. P6-T2: "the sentence beginning `Only \`version\`, \`over_breadth_fraction\`, and \`mandate_reads\` are byte-equal`". P6-T3: "immediately after the paragraph ending `helper raises on an absent key. Nothing schedules on it.`".

### O2 — [P6-T6] cites line numbers that P5-T15/T16/T17 invalidate; `:447-448` is wrong today (sentence spans 446-447)

The B7 replacement uses section-plus-sentence anchors and carries no line numbers.

### O3 — [P3-T2] lists five in-file edits in an order that invalidates its own later anchors

Delta: add "Apply the five edits in descending line order (464-465, then 426-428, then 344-404, then 84-86, then the insertion after line 60), so no edit invalidates a later anchor." Add the same sentence to P4-T2 (same shape).

## Citation defects

- C-1 — [P4-T7] helper span: `observe` is at `blast-radius-derive-core.test.ts:61-71`, `deriveModules` at 74-81; change the citation to `:54-81`.
- C-2 — [P7-T1] bats: line 43 sets `FIXTURE_DIR`; the glob is at line 70; the floor `MINIMUM_FIXTURE_COUNT=20` is at 47.
- C-3 — [P1-T7] `"config_mergeable_paths"` sorts before `"conflicts"`; say "immediately before `"conflicts"`".
- C-4 — [C2 table] state `wc -l` values: BlastRadius.psm1 495; claude-blast-radius-derive-core.ts 468; blast-radius-derive-core.test.ts 482; blast-radius-derive.test.ts 472; _blast_radius_validation.py 464; claude-config-carriage.test.ts 461; test_validate_parallel_orchestrator_state.py 486; BlastRadius.Conflict.Tests.ps1 435; parallel-orchestrator-state-core.test.ts 417; BlastRadius.TruthTable.Tests.ps1 325; BlastRadius.KeyPartition.Tests.ps1 268; _blast_radius_conflicts.py 241; test_blast_radius_config_parity.py 499; BlastRadiusConfig.psm1 473; test_parallel_drift_detection_conflicts.py 420; BlastRadiusConfig.Tests.ps1 500.
- C-5 — [plan header] state: merge base `c3ffb080` with `origin/main` (branch rebased); branch head `c16d2ae6` at revision time.

## Advisory findings (address in the same revision)

- A1 — add `--untracked-files=all` to every `git status --porcelain` in P0-T15, P7-T7, P8-T1, P8-T15, because an untracked directory collapses to one entry.
- A2 — [P2-T6] "`Cover` at or above 90% and an empty `Missing` column" only co-hold at 100%; state 100%, or drop the empty-column requirement.
- A3 — [P5-T20] add `tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py` to the P5-T20 command; it binds the skill's prescribed commands to the agent's grants and both change in Phase 5.
- A4 — name the working-directory mechanism for the twelve `extensions/drm-copilot` tasks: `npm --prefix extensions/drm-copilot run <script>` (the Bash cwd resets and cd-chained commands are denied).
- A5 — `git grep -c` prints `<path>:<count>`; reword "prints `N`" as "reports a count of N for that path".
- A6 — [P4-T2] state explicitly that the existing local `classifyProjectDirectories` at `claude-blast-radius-derive-core.ts:282` is removed before the re-export.
- A7 — [P4-T5] record that it keeps `claude-config-carriage.test.ts:110` (`expect(fixture).toEqual(committed)`) green after P1-T2 changed the committed bundled copy.
- A8 — [P5-T13] replace "the P3-T4 Python probe adapted" with the concrete one-liner.
