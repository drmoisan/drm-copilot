# parallel-items-fail-completion-on-promotion-receipts (Plan)

- **Issue:** #849
- **Branch:** bug/parallel-items-fail-completion-on-promotion-receipts-849
- **Parent (optional):** none
- **Owner:** drmoisan
- **Work Mode:** full-bug (acceptance criteria source: `spec.md` only, AC-1 through AC-18)
- **Baseline commit:** merge-base of HEAD and origin/main, recorded in P0-T2 as BASE_SHA
- **Last Updated:** 2026-10-09
- **Status:** Draft, pending executor preflight
- **Version:** 1.0

**Fail-closed evidence rule:** Each in-scope language (Python, TypeScript, PowerShell) has explicit baseline artifact tasks, final-QA artifact tasks, and a coverage-comparison task. If any required baseline, QA, or coverage-comparison artifact is missing, or a required numeric coverage value is absent, the audit verdict is BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Each evidence-producing task names its artifact path. A task is not checked off until its artifact exists with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` fields (plus `ExpectedExitCode:` for an expect-fail artifact).

## Run Constraints

- This plan is executed later by a parallel-orchestrator child. No force-push. Delete nothing: no task removes a tracked or untracked repository file, and no task reverts a file. Where a step would otherwise need a deletion or a revert, the task stops with the named `BLOCKED:` line instead.
- Commits are made by the orchestrator, not by `atomic-executor`, with explicit pathspecs only, drawn from `## Files Written`. No `git add -A`, `git add .`, or `git commit -a`.
- `scripts/dev_tools/validate_orchestrator_state.py` is not edited (shared with #798). `.claude/skills/parallel-add/SKILL.md` is out of scope (overlap with #843); the residual for `/parallel-add` admission is recorded as a follow-up note in P9-T6.
- `.claude/rules/orchestrator-state.md` is edited under explicit `spec.md` scope: it is the repo-owned contract document for the `issue_adoption` waiver, not a `.github/instructions` policy file. No other file under `.claude/rules/` or `.github/instructions/` is edited.
- Evidence file names carry the fixed artifact-set stamp `2026-10-09T01-33` (this plan cycle's identifier) so every written path is enumerable in advance for the run planner's blast-radius extraction. Each artifact's `Timestamp:` field records the actual execution time in `yyyy-MM-ddTHH-mm`. A loop restart overwrites the same artifact file.
- Gitignored outputs (`artifacts/pester/*`, the pytest LCOV file under `artifacts/`, `extensions/drm-copilot/node_modules`, `extensions/drm-copilot/coverage`) are produced by toolchain runs and are not repository files; they are not listed in `## Files Written`.
- No artifact records an absolute host path. The worktree root is written as the words "worktree root".

## Edit Text Blocks

The executor writes these literals verbatim. Each block is quoted here so that later assertions over these literals are exonerated by plan quotation.

**S1** (`.claude/skills/parallel-plan/SKILL.md`, `## Item Intake`): insert this bullet immediately after the `**Promotion.**` bullet (which ends with "`new_active_feature_folder`)."), as its own list item:

```text
- **Issue adoption.** Issue-number items are adopted, not promoted. The item's GitHub issue
  already exists, so its preparation child verifies the issue read-only and records a top-level
  `issue_adoption` object in its checkpoint instead of calling `potential_to_issue` or the
  promotion-entry tool. The delegation prompt carries that instruction as the issue-adoption line
  under `## Preparation Fan-Out`.
```

**S2** (`## Preparation Fan-Out`): replace the two-line sentence "Each delegation prompt includes this literal kickoff line, followed by the model-budget marker line:" with:

```text
Each delegation prompt includes this literal kickoff line, followed by the model-budget marker
line and, for an issue-number item only, the issue-adoption line:
```

**S3** (`## Preparation Fan-Out`): immediately after the blockquoted model-budget marker line (the line beginning "> `model_budget.fable_policy:"), append these two blockquote lines. The kickoff line itself is not edited.

```text
>
> `Issue adoption: this item's GitHub issue already exists. Verify it read-only (gh issue view), do not call potential_to_issue or the promotion-entry tool, and record a top-level issue_adoption object in the checkpoint per .claude/rules/orchestrator-state.md with origin filed_before_orchestration (or transferred when the issue was transferred), waiving potential_to_issue and the promotion-entry tool for the checkpoint's promotion-type. When a lifecycle record for the item exists under docs/features/potential/promoted/, cite it as potential_record.`
```

**S4** (`## Preparation Fan-Out`): insert this paragraph immediately after the `**Deliberate omissions.**` paragraph (which ends "must be preserved verbatim when the line is emitted."), separated by one blank line on each side:

```text
**Issue-adoption line.** The issue-adoption line is emitted only for an issue-number item, after
the model-budget marker line, and is omitted for a potential-entry item, whose child promotes it.
The line carries no mode marker, no digits, and no active feature-folder path, so hook target
resolution and mode classification are unchanged. The preparation checkpoint does not carry over
to execution, so the execution child records its own adoption (see
`.claude/skills/parallel-orchestrate/SKILL.md`, kickoff element 4).
```

**S5** (`## Preparation Fan-Out`, the `**Collected per child at termination:**` sentence): replace the words "the promotion receipt (the `issue_num` back-fill source)," with:

```text
the promotion receipt (the `issue_num` back-fill source for a potential-entry item) or, for an
issue-number item, the `issue_adoption` record from the child checkpoint,
```

**S6** (`.claude/skills/parallel-orchestrate/SKILL.md`, `## Parallel-Mode Kickoff Parameter`, element 4): append these lines to element 4, after its last sentence ("...on the item's own pushed feature branch."), indented three spaces as continuation lines of list item 4. No list item and no `##` heading is added.

```text
   The execution child starts a new checkpoint in its own worktree, and the preparation checkpoint
   does not carry over, so the prompt also instructs the child to verify the item's GitHub issue
   read-only (gh issue view), not to call `potential_to_issue` or the promotion-entry tool, and to
   record its own top-level `issue_adoption` object per `.claude/rules/orchestrator-state.md`,
   with origin `filed_before_orchestration` unless the issue was transferred, waiving
   `potential_to_issue` and the promotion-entry tool for the checkpoint's promotion-type. When a
   lifecycle record for the item exists under `docs/features/potential/promoted/`, the child cites
   it as `potential_record`.
```

**R1** (`.claude/rules/orchestrator-state.md`, `## Invariants (issue_adoption object)` table): replace the `potential_record` row with:

```text
| `potential_record` | When waiving a promotion-entry tool: required when `origin` is `epic_decomposition`, optional when `origin` is `transferred` or `filed_before_orchestration`, and validated whenever it is present (a path under `docs/features/potential/` ending in `.md`). |
```

**R2** (same section): replace rule 9 with:

```text
9. Only when the rule-8 shape check passed: each distinct waived promotion-entry tool (`new_potential_entry` or `new_potential_bug_entry`) requires a valid `potential_record`, except that rule 9 reports nothing when `origin` is `transferred` or `filed_before_orchestration` and the `potential_record` key is absent. A present `potential_record`, including `null`, is always validated.
```

**R3** (same section): insert this paragraph immediately after the paragraph that begins "The closed waivable set is", separated by one blank line on each side:

```text
A lifecycle record moved to `docs/features/potential/promoted/` satisfies the `potential_record` path rule, because the rule checks only the `docs/features/potential/` prefix and the `.md` suffix and does not check that the file exists.
```

**O1** (`.claude/skills/orchestrate/SKILL.md`, the paragraph beginning "When the GitHub issue already exists before orchestration starts"): replace the sentence "It may waive only `potential_to_issue` and, with a valid `potential_record` under `docs/features/potential/`, the checkpoint's promotion-entry tool (`new_potential_entry`, or `new_potential_bug_entry` for a bug-type checkpoint); `potential_to_issue` must always be listed." with:

```text
It may waive only `potential_to_issue` and the checkpoint's promotion-entry tool (`new_potential_entry`, or `new_potential_bug_entry` for a bug-type checkpoint); `potential_to_issue` must always be listed. For a promotion-entry waiver, `potential_record` (a markdown path under `docs/features/potential/`) is required when `origin` is `epic_decomposition`, optional when `origin` is `transferred` or `filed_before_orchestration`, and validated whenever it is present.
```

**L1** (`.claude/skills/feature-promotion-lifecycle/SKILL.md`, numbered step 2 of the adopted-issue list): replace step 2 with:

```text
2. Record a top-level `issue_adoption` object in the orchestrator checkpoint (`issue_num`, `issue_url`, `origin`, `verified_via`, `verified_at`, `evidence`, `waived_tools`, and, when a promotion-entry tool is waived, `potential_record`). For that waiver `potential_record` is required when `origin` is `epic_decomposition`, optional when `origin` is `transferred` or `filed_before_orchestration`, and validated whenever it is present. A valid record waives the `potential_to_issue` receipt requirement at completion.
```

Shared fragments pinned by the new contract test (each must appear, after whitespace collapse, in R1, O1, and L1): "required when `origin` is `epic_decomposition`", "optional when `origin` is `transferred` or `filed_before_orchestration`", and "validated whenever it is present". R3 fragment: "A lifecycle record moved to `docs/features/potential/promoted/` satisfies the `potential_record` path rule". S6 fragment: "the preparation checkpoint does not carry over". S1 fragment: "Issue-number items are adopted, not promoted." S3 line prefix: "> `Issue adoption:".

## Fixture Derivations

Each new corpus file is a copy of a named existing fixture with only the listed changes. Formatting matches the source file: two-space indentation, LF line endings, the source file's final-newline convention, and valid JSON (when a removed key was the last member of an object, the preceding member loses its trailing comma). Every other byte is unchanged.

- **D1** `valid-bug-preparation-filed-before-orchestration-without-record.json`, from the existing fixture valid-preparation-waives-potential-to-issue.json: `name` set to the new stem; `notes` set to "A filed_before_orchestration adoption on a bug preparation checkpoint waives potential_to_issue and the bug promotion-entry tool without a potential record."; `checkpoint.promotion-type` set to `bug`; the first `required_mcp_tools` entry changed from `new_potential_entry` to `new_potential_bug_entry`; the `mcp_call_receipts` entry whose `tool` is `new_potential_entry` removed; `issue_adoption.origin` set to `filed_before_orchestration`; `issue_adoption.waived_tools` set to `["potential_to_issue", "new_potential_bug_entry"]`; no `potential_record` key; `expected_errors` stays `[]`.
- **D2** `valid-bug-large-filed-before-orchestration-without-record.json`, from the existing fixture valid-bug-large-waives-bug-entry-tool-with-record.json: `name` set to the new stem; `notes` set to "A filed_before_orchestration adoption on a large bug checkpoint waives the bug promotion-entry tool without a potential record."; `issue_adoption.origin` set to `filed_before_orchestration`; the `potential_record` key removed; `expected_errors` stays `[]`.
- **D3** `valid-large-transferred-waives-feature-entry-tool-without-record.json`, from the existing fixture valid-large-waives-feature-entry-tool-with-record.json: `name` set to the new stem; `notes` set to "A transferred adoption on a large feature checkpoint waives the feature promotion-entry tool without a potential record."; the `potential_record` key removed (`origin` stays `transferred`); `expected_errors` stays `[]`.
- **D4** `epic-decomposition-waives-entry-tool-without-record.json`, from the existing fixture invalid-potential-record.json: `name` set to the new stem; `notes` set to "An epic_decomposition adoption that waives the feature promotion-entry tool still requires a potential record."; `issue_adoption.origin` set to `epic_decomposition`; the `potential_record` key removed; `expected_errors` unchanged (the same three strings, in the same order).
- **D5** `filed-before-orchestration-invalid-present-record.json`, from the existing fixture invalid-potential-record.json: `name` set to the new stem; `notes` set to "A filed_before_orchestration adoption with a present invalid potential record is still rejected."; `issue_adoption.origin` set to `filed_before_orchestration`; `potential_record` stays `notes/record.txt`; `expected_errors` unchanged.

Before the validator change, D1, D2, and D3 fail every parity reader (the resolver reports rule 9 and waives nothing, so two missing-receipt errors and one rule-9 error appear), and D4 and D5 pass. After the change all five pass.

## New Test Specifications

**Python** (added to `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py` under a new comment banner "# --- Issue #849: potential_record requirement by origin ---"). A module-level constant `PREPARATION_BUG_TOOLS = ("new_potential_bug_entry", "potential_to_issue", "new_active_feature_folder", "validate_orchestration_artifacts")` is defined in the test file. Seven tests, Arrange-Act-Assert, each with a docstring:

1. `test_filed_before_orchestration_waives_bug_entry_tool_without_record`: bug state, `LARGE_BUG_TOOLS`, origin `filed_before_orchestration`, waived `potential_to_issue` and `new_potential_bug_entry`, no record key. Errors `()`; `waived_tools` equals both tools.
2. `test_transferred_waives_feature_entry_tool_without_record`: feature state, `LARGE_TOOLS`, origin `transferred`, waived `potential_to_issue` and `new_potential_entry`, no record key. Errors `()`; both tools waived.
3. `test_filed_before_orchestration_waives_bug_entry_tool_on_preparation_route_without_record`: bug state, route `preparation`, `PREPARATION_BUG_TOOLS`, successful tools `{"new_active_feature_folder", "validate_orchestration_artifacts"}`, origin `filed_before_orchestration`, no record key. Errors `()`; both tools waived.
4. `test_epic_decomposition_without_record_still_reports_rule_nine`: feature, origin `epic_decomposition`, waived feature entry tool, no record key. Errors `(invalid_potential_record_error("new_potential_entry"),)`; waived empty.
5. `test_filed_before_orchestration_with_null_record_still_reports_rule_nine`: feature, origin `filed_before_orchestration`, `potential_record=None`. Same single rule-9 error; waived empty.
6. `test_transferred_with_invalid_record_still_reports_rule_nine`: feature, origin `transferred`, `potential_record="notes/record.txt"`. Same single rule-9 error; waived empty.
7. `test_invalid_origin_without_record_reports_origin_and_rule_nine`: feature, origin `imported`, waived feature entry tool, no record key. Errors `(E4, invalid_potential_record_error("new_potential_entry"))`; waived empty.

Tests 1-3 fail before the validator change; tests 4-7 pass before and after (unchanged behavior).

**TypeScript** (new file `extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption-origin.test.ts`): imports `resolveIssueAdoption` only; defines its own route tool lists, base adoption builder (issue 509, origin `transferred`, `gh_issue_view`, `2026-09-29T15:15:00Z`, evidence string, `waived_tools: ["potential_to_issue"]`), state builder, and rule-9 message builder; reads no file and uses no timer, clock, or randomness. One `describe("issue-adoption potential_record requirement by origin (issue #849)")` with seven `it` cases mirroring Python tests 1-7 in order, titled:
"waives the bug entry tool without a record when origin is filed_before_orchestration"; "waives the feature entry tool without a record when origin is transferred"; "waives the bug entry tool without a record on the preparation route"; "still reports rule 9 when origin is epic_decomposition and the record is absent"; "still reports rule 9 when origin is filed_before_orchestration and the record is null"; "still reports rule 9 when origin is transferred and the record path is invalid"; "reports the origin error and rule 9 when origin is invalid and the record is absent". Waived sets are compared after sorting.

**PowerShell** (appended to `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1`): one new `Describe 'Issue adoption potential record requirement by origin (issue 849)'` using the existing `Get-AdoptionRecord`, `Get-AdoptionState`, `Invoke-Adoption`, `Join-Text`, `Join-Sorted`, and `Get-E9` helpers and the existing `$script:E4` constant, with seven `It` blocks titled identically to the TypeScript cases, in the same order. The preparation case passes `-RouteId 'preparation'`, a bug preparation tool list, and successful tools `new_active_feature_folder` and `validate_orchestration_artifacts`. The null case passes `potential_record = $null` in `-Override`.

**Skill contract test** (new file `tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py`): module docstring; imports `read_repo_text`, `extract_section`, and `collapse_whitespace` from `tests.scripts.dev_tools.parallel_orchestrator_surface_test_support`; constant `HOOK_ISSUE_NUMBER_PATTERN = re.compile(r"issue(?:[_-]?num(?:ber)?|\s+number)\s*[:=]\s*#?(\d+)", re.IGNORECASE)`; constant `KICKOFF_LINE` holding the parallel-plan kickoff blockquote line copied verbatim from the baseline file (the line beginning "> `Preparation mode: true."), written as adjacent string literals inside parentheses so no source line exceeds the configured line length; helpers that return the S3 line (the single line in `## Preparation Fan-Out` starting with "> `Issue adoption:", raising `AssertionError` when the count is not exactly one) and the element-4 text of `## Parallel-Mode Kickoff Parameter` (the lines from the line starting "4. " up to the line starting "5. ", joined). Every text extraction runs inside a test body, never at collection time. Eleven test cases:

1. `test_parallel_plan_item_intake_declares_issue_number_items_adopted` (S1 fragment and `issue_adoption` present in `## Item Intake`).
2. `test_parallel_plan_fan_out_carries_issue_adoption_prompt_line` (S3 line exists once and contains `issue_adoption` and `potential_to_issue`).
3. `test_parallel_plan_issue_adoption_line_carries_no_mode_marker` (S3 line contains none of "Epic mode: true", "Parallel mode: true", "Preparation mode: true").
4. `test_parallel_plan_kickoff_line_is_unchanged` (`KICKOFF_LINE` is a line of `## Preparation Fan-Out`).
5. `test_parallel_orchestrate_element_four_carries_issue_adoption` (collapsed element-4 text contains `issue_adoption`, `potential_to_issue`, and the S6 fragment).
6. `test_parallel_orchestrate_kickoff_keeps_five_elements` (section contains "exactly these five elements" and no line starting "6. ").
7-8. `test_added_skill_text_does_not_match_hook_issue_number_pattern`, parametrized over the ids `parallel-plan-adoption-line` and `parallel-orchestrate-element-four` (the regex finds no match and the text contains no `docs/features/active/` token).
9. `test_rule_doc_states_origin_conditional_potential_record` (`## Invariants (issue_adoption object)` of `.claude/rules/orchestrator-state.md`, collapsed, contains the three shared fragments and the R3 fragment).
10-11. `test_skill_states_origin_conditional_potential_record`, parametrized over the ids `orchestrate` and `feature-promotion-lifecycle` (the collapsed full file text contains the three shared fragments).

Before the skill and rule-document edits, cases 1, 2, 3, 5, 7 (`parallel-plan-adoption-line`), 9, 10, and 11 fail, and cases 4, 6, and 8 (`parallel-orchestrate-element-four`, whose pre-edit text already contains no digit and no active-folder token) pass (8 failed, 3 passed). Case 8 is a guard that stays green; the fail-before signal for element 4 is case 5.

## PowerShell Measurement Sources

`atomic-executor` has no PowerShell host tool, and the worktree-isolation guard refuses Bash text that names a PowerShell host executable. The executor therefore runs only the MCP PoshQC tools, whose results carry a status and no counts, findings, or coverage. All PowerShell numbers come from JUnit and coverage XML copies that the orchestrator writes into the evidence tree at two planned handoffs, H0 (after P0-T17) and H1 (after P8-T3). At each handoff the executor stops after the trigger task and returns `HANDOFF: POWERSHELL SOURCE A (H0)` or `HANDOFF: POWERSHELL SOURCE A (H1)`; this is a planned stop, not a BLOCKED outcome.

**Source A (primary, orchestrator PowerShell tool).** `WORKTREE_ROOT` is the literal worktree root from the orchestrator's delegation prompt. The settings file `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` writes JUnit to `artifacts/pester/pester-junit.xml` and coverage to `artifacts/pester/powershell-coverage.xml`; `config/poshqc-coverage.json` includes the `.claude/lib` root.

Source A test command: `$root = 'WORKTREE_ROOT'; Import-Module (Join-Path $root 'scripts/powershell/PoshQC/PoshQC.psm1') -Force; Invoke-PoshQCTest -Root $root -ScanFolders @('tests/scripts/claude-lib/orchestrator-state','tests/scripts/claude-hooks','tests/scripts/claude-runtime')`

Source A analyzer command: `$root = 'WORKTREE_ROOT'; foreach ($p in @('.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1','extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1','tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1','tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Parity.Tests.ps1')) { '{0} {1}' -f $p, @(Invoke-ScriptAnalyzer -Path (Join-Path $root $p) -Settings (Join-Path $root 'scripts/powershell/PoshQC/settings/pssa.settings.psd1') -Severity Error,Warning,Information).Count }`

Freshness without deletion: the orchestrator records `SourceA-Start:` (UTC, `yyyy-MM-ddTHH:mm:ssZ`) immediately before the test command and, after it, the `LastWriteTimeUtc` of both `artifacts/pester` files. Both write times must be later than `SourceA-Start:`, and `SourceA-Start:` must be later than the UTC completion time recorded by the trigger task. Otherwise the copies are stale and the consuming task fails. No file under `artifacts/pester` is deleted.

**Source B (fallback, used only when the orchestrator has no PowerShell host tool or the tool refuses a Source A command; the refusal text is recorded verbatim in `run-record.md`).** The orchestrator commits pending in-scope changes with explicit pathspecs from `## Files Written`, pushes the branch without force, runs `gh workflow run _poshqc.yml --ref bug/parallel-items-fail-completion-on-promotion-receipts-849` and records the UTC time immediately after that command as `SourceB-Dispatched:` (`yyyy-MM-ddTHH:mm:ssZ`), waits for completion, reads `gh run list --workflow=_poshqc.yml --branch bug/parallel-items-fail-completion-on-promotion-receipts-849 --limit 1 --json databaseId,headSha,conclusion`, records the `Format PowerShell` and `Analyze PowerShell` step conclusions from `gh run view RUN_ID --json jobs` as `FormatStep:` and `AnalyzeStep:` lines, and downloads the `poshqc-test-results` artifact with `gh run download` to a directory outside the worktree (for example the session scratchpad), so that no downloaded file appears in `git status --porcelain`. The run's `headSha` must equal `git rev-parse HEAD`. `run-record.md` records `SourceB-RunId:`, `SourceB-HeadSha:` (the run's `headSha`), and `SourceB-LocalHead:` (the `git rev-parse HEAD` output taken immediately before dispatch). If the downloaded run has no `poshqc-test-results` artifact, record `FormatStep:` and `AnalyzeStep:` conclusions and `BLOCKED: SOURCE B NO TEST ARTIFACT` in `run-record.md`; the consuming task fails. Source B root counts are repository-wide, so only per-file and per-folder counts are compared, and an `AnalyzeStep: success` line stands for zero analyzer findings. The source used at H0 must be used at H1; otherwise the consuming task records `BLOCKED: MIXED POWERSHELL SOURCES`.

**Copy sanitization (every copied file, both handoffs).** In order: (1) every occurrence of the producing checkout root — the local worktree root for Source A, or for Source B the runner workspace prefix that precedes `tests/` or `.claude/` in the downloaded files (both separator forms, ASCII case-insensitive) — replaced by `WORKTREE_ROOT`, so testsuite and package names survive; (2) every remaining absolute path (an ASCII letter not preceded by a letter, followed by `:` and `\` or `/`, or the substring `/home/`, through the first whitespace, `"`, `'`, `<`, `>`, or `&`) replaced by `ABSOLUTE_PATH`; (3) every `<properties>...</properties>` block removed; (4) every `hostname` attribute value replaced by `HOST`. `run-record.md` records `sanitized: root, absolute-paths, properties, hostname`, the source used, `Timestamp:`, `SourceA-Start:` and the two write times (Source A), or `SourceB-Dispatched:`, `SourceB-RunId:`, `SourceB-HeadSha:`, and `SourceB-LocalHead:` (Source B), and per command `Command:` (with `WORKTREE_ROOT` as the placeholder), `EXIT_CODE:`, and `Output Summary:`.

**Reading rules.** Counts are read with the Read tool. JUnit has one `testsuite` element per test file, named by file path (either separator). Folder sums use the `testsuite` elements whose `name` contains `tests/scripts/claude-lib/orchestrator-state/`, `tests/scripts/claude-hooks/`, or `tests/scripts/claude-runtime/` (either separator). Line coverage is read from the `package` element whose `name` ends with `.claude/lib/orchestrator-state`, then the `sourcefile` named `OrchestratorStateIssueAdoption.psm1`, then its `counter` of type `LINE` (`missed`, `covered`), with `covered / (missed + covered)` and the arithmetic shown. Changed-line coverage uses that `sourcefile`'s `line` elements (`nr`, `ci`). Pester does not measure branch coverage, so no PowerShell branch figure exists.

### Phase 0 — Baseline Capture

- [x] [P0-T1] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/phase0-instructions-read.2026-10-09T01-33.md` after reading the policy files in this order: CLAUDE.md, then the rules general-code-change.md, general-unit-test.md, quality-tiers.md, python.md, python-suppressions.md, typescript.md, typescript-suppressions.md, powershell.md, tonality.md, and plan-acceptance-gates.md under .claude/rules, then the feature folder's issue.md, spec.md, and research/research.2026-10-09T05-40.md.
  - Acceptance: the artifact carries `Timestamp:`, `Policy Order:`, and a `Files Read:` list naming all 14 files in the order above.
- [x] [P0-T2] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/git-baseline.2026-10-09T01-33.md` recording the branch, HEAD, the origin/main tip, the baseline commit, and the pre-existing branch diff: run `git rev-parse --abbrev-ref HEAD`, `git rev-parse HEAD`, `git rev-parse origin/main`, `git merge-base HEAD origin/main`, `git diff --name-status --merge-base origin/main`, and `git status --porcelain`.
  - Acceptance: the branch is `bug/parallel-items-fail-completion-on-promotion-receipts-849`; `BASE_SHA` is recorded as the merge-base command's output; the name-status listing is recorded verbatim as `BASE_DIFF` (tracked paths already changed relative to `BASE_SHA` before this plan runs); the porcelain listing is recorded verbatim as `BASE_PORCELAIN`.
- [x] [P0-T3] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/corpus-count.2026-10-09T01-33.md` recording the baseline issue-adoption corpus count by two independent methods over the directory tests/fixtures/orchestrator_state_issue_adoption (non-recursive).
  - Acceptance: method 1 is a file-name enumeration of every file with suffix .json (Glob tool); method 2 is a content search for the regex `^  "name": ` (Grep tool, content mode) returning each fixture's top-level `name` value; both member sets are listed, compared after stripping `.json`, and are identical with 29 members each. Any other result records `BLOCKED: BASELINE CORPUS COUNT` and stops.
- [x] [P0-T4] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/file-line-counts.2026-10-09T01-33.md` from `wc -l scripts/dev_tools/_orchestrator_state_issue_adoption.py extensions/drm-copilot/src/lib/validate/orchestrator-state-issue-adoption.ts .claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1 tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption-parity.test.ts tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Parity.Tests.ps1`.
  - Acceptance: EXIT_CODE 0 and one count per file (nine files) recorded.
- [x] [P0-T5] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/py-black.2026-10-09T01-33.md` recording the Python formatter baseline in check mode: `poetry run black --check scripts/dev_tools/_orchestrator_state_issue_adoption.py tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py`.
  - Acceptance: EXIT_CODE 0 and the summary line "3 files would be left unchanged." recorded; check mode writes nothing.
- [x] [P0-T6] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/py-ruff.2026-10-09T01-33.md` recording `poetry run ruff check scripts/dev_tools/_orchestrator_state_issue_adoption.py tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py`.
  - Acceptance: EXIT_CODE 0 and the output "All checks passed!" recorded.
- [x] [P0-T7] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/py-pyright.2026-10-09T01-33.md` recording `poetry run pyright scripts/dev_tools/_orchestrator_state_issue_adoption.py tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py`.
  - Acceptance: EXIT_CODE 0 and the summary "0 errors, 0 warnings, 0 informations" recorded.
- [x] [P0-T8] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/py-adoption-coverage.2026-10-09T01-33.md` and `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/py-adoption-coverage.2026-10-09T01-33.json` recording the targeted Python coverage baseline: `poetry run pytest tests/scripts/dev_tools/test_orchestrator_state_issue_adoption.py tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py tests/scripts/dev_tools/test_validate_orchestrator_state_issue_adoption.py tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py --cov=scripts.dev_tools._orchestrator_state_issue_adoption --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/py-adoption-coverage.2026-10-09T01-33.json`.
  - Acceptance: EXIT_CODE 0; the pytest summary line, the passed count as `RB_PY_TARGETED_PASSED`, the verbatim `term-missing` row for `_orchestrator_state_issue_adoption.py`, and the JSON `summary` values for that file (key matched by suffix) as `RB_PY_LINE` (covered_lines / num_statements) and `RB_PY_BRANCH` (covered_branches / num_branches), with arithmetic shown, are recorded.
- [x] [P0-T9] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/py-full-suite.2026-10-09T01-33.md` and `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/py-full-coverage.2026-10-09T01-33.json` recording the full Python suite baseline: `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/py-full-coverage.2026-10-09T01-33.json`.
  - Acceptance: the EXIT_CODE, the summary line, the passed count as `RB_PY_FULL_PASSED`, the complete failed-node-ID set as `RB_PY_FULL_FAILED` (empty set recorded as `{}`), the verbatim `TOTAL` row, and the JSON `totals` line and branch percentages are recorded. A non-zero exit caused by pre-existing failures is recorded as baseline and does not stop the plan.
- [x] [P0-T10] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/py-skill-contracts.2026-10-09T01-33.md` recording `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py tests/scripts/dev_tools/test_parallel_kickoff_template_seam.py`.
  - Acceptance: the EXIT_CODE, the summary line, the passed count as `RB_PY_CONTRACT_PASSED`, and the failed-node-ID set as `RB_PY_CONTRACT_FAILED` are recorded. A non-empty failed set records `BLOCKED: BASELINE CONTRACT FAILURES` and stops, because AC-11, AC-12, and AC-15 require these suites to pass.
- [x] [P0-T11] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/ts-format.2026-10-09T01-33.md` recording the TypeScript formatter baseline: when the directory extensions/drm-copilot/node_modules is absent, first run `npm --prefix extensions/drm-copilot ci` (gitignored output); then `git status --porcelain`, `npm --prefix extensions/drm-copilot run format`, and `git status --porcelain`.
  - Acceptance: EXIT_CODE 0; every printed Prettier file line ends in "(unchanged)" (count recorded); the two porcelain listings are recorded verbatim and are identical. If any tracked file was rewritten, record `BLOCKED: BASELINE FORMAT DRIFT` with the rewritten paths and stop without reverting.
- [x] [P0-T12] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/ts-lint.2026-10-09T01-33.md` recording `npm --prefix extensions/drm-copilot run lint`.
  - Acceptance: EXIT_CODE 0 and no problem lines after the npm script banner.
- [x] [P0-T13] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/ts-typecheck.2026-10-09T01-33.md` recording `npm --prefix extensions/drm-copilot run typecheck`.
  - Acceptance: EXIT_CODE 0 and no diagnostic lines after the npm script banners.
- [x] [P0-T14] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/ts-validate-dir-tests.2026-10-09T01-33.md` recording `npm --prefix extensions/drm-copilot run test:unit -- test/lib/validate`.
  - Acceptance: EXIT_CODE 0; the `Test Suites:` and `Tests:` lines recorded verbatim; suites passed as `RB_TS_DIR_SUITES` and tests passed as `RB_TS_DIR_PASSED`.
- [x] [P0-T15] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/ts-coverage.2026-10-09T01-33.md` and `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/ts-coverage-output.2026-10-09T01-33.txt` recording the TypeScript coverage baseline: `npm --prefix extensions/drm-copilot run test:coverage -- --coverageReporters=text > docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/ts-coverage-output.2026-10-09T01-33.txt 2>&1`.
  - Acceptance: EXIT_CODE 0; from the output file, the `Tests:` line (passed as `RB_TS_TESTS_PASSED`), the `Statements`, `Branches`, and `Lines` summary lines, and the text-reporter row for `orchestrator-state-issue-adoption.ts` (% Lines as `RB_TS_LINE`, % Branch as `RB_TS_BRANCH`, Uncovered Line #s) are quoted verbatim. The output file contains no absolute host path; if one is present, replace each with `ABSOLUTE_PATH` before recording.
- [x] [P0-T16] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/ps-format.2026-10-09T01-33.md` recording the PowerShell formatter baseline: `git status --porcelain`, then the MCP tool `mcp__drm-copilot__run_poshqc_format` with `workspace_root` set to the worktree root, then `git status --porcelain`.
  - Acceptance: `EXIT_CODE: 0` for MCP status `success` (with an `MCP-Status:` line); the two porcelain listings are recorded verbatim and are identical, so every PowerShell file was left unchanged. If any tracked file was rewritten, record `BLOCKED: BASELINE FORMAT DRIFT` and stop without reverting.
- [x] [P0-T17] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/ps-analyze.2026-10-09T01-33.md` recording the MCP tool `mcp__drm-copilot__run_poshqc_analyze` run with `workspace_root` set to the worktree root, then stop for handoff H0.
  - Acceptance: `EXIT_CODE: 0` for status `success`, `EXIT_CODE: 1` for `failure`, with an `MCP-Status:` line; no count is asserted from the MCP result. The artifact records the task completion time as `H0-Trigger-Completed:` (UTC, from `date -u +%Y-%m-%dT%H:%M:%SZ`). The executor then returns `HANDOFF: POWERSHELL SOURCE A (H0)`.
- [ ] [P0-T18] Write the H0 copies `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/poshqc-local/run-record.md`, `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/poshqc-local/pester-junit.xml`, `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/poshqc-local/powershell-coverage.xml`, and `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/poshqc-local/analyzer-output.txt` (orchestrator-performed at handoff H0, per "PowerShell Measurement Sources").
  - Acceptance: the orchestrator runs the Source A analyzer command and the Source A test command (or Source B), applies copy sanitization, and writes `run-record.md` with every field listed there; for Source A, `SourceA-Start:` is later than `H0-Trigger-Completed:` and both pester output write times (JUnit and coverage) are later than `SourceA-Start:`; for Source B, `SourceB-Dispatched:` is later than `H0-Trigger-Completed:` and `SourceB-HeadSha:` equals `SourceB-LocalHead:`. `analyzer-output.txt` is written for Source A only; for Source B, `run-record.md` carries the `AnalyzeStep:` line instead. On resume after the handoff, `atomic-executor` verifies this acceptance against the files on disk (including the freshness and `sanitized:` lines in `run-record.md`) and checks the task off; it does not re-run the orchestrator commands.
- [ ] [P0-T19] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/ps-test-coverage.2026-10-09T01-33.md` recording the PowerShell test and coverage baseline read from the H0 copies under the reading rules.
  - Acceptance: records the source used; the per-file `tests` and `failures` for OrchestratorStateIssueAdoption.Tests.ps1 (passed as `RB_PS_UNIT_PASSED`) and OrchestratorStateIssueAdoption.Parity.Tests.ps1 (passed as `RB_PS_PARITY_PASSED`); the per-file `failures` for enforce-orchestration-preimplementation-gate.Tests.ps1; the failed-test set across the three scan folders as `RB_PS_FAILED`; the `LINE` counter of `OrchestratorStateIssueAdoption.psm1` with the percentage as `RB_PS_LINE`; and, for Source A, the four analyzer counts from `analyzer-output.txt` (or the `AnalyzeStep:` value for Source B). A copy that fails the freshness or sanitization record is rejected and the task fails.

### Phase 1 — Regression Fixtures, Corpus Floors, and Failing Tests

- [ ] [P1-T1] Create `tests/fixtures/orchestrator_state_issue_adoption/valid-bug-preparation-filed-before-orchestration-without-record.json` per derivation D1.
  - Acceptance: the file parses as JSON, `name` equals the file stem, the four required keys are present, and every difference from its source fixture is one of the D1 changes.
- [ ] [P1-T2] Create `tests/fixtures/orchestrator_state_issue_adoption/valid-bug-large-filed-before-orchestration-without-record.json` per derivation D2.
  - Acceptance: as P1-T1, with the D2 changes.
- [ ] [P1-T3] Create `tests/fixtures/orchestrator_state_issue_adoption/valid-large-transferred-waives-feature-entry-tool-without-record.json` per derivation D3.
  - Acceptance: as P1-T1, with the D3 changes.
- [ ] [P1-T4] Create `tests/fixtures/orchestrator_state_issue_adoption/epic-decomposition-waives-entry-tool-without-record.json` per derivation D4.
  - Acceptance: as P1-T1, with the D4 changes; `expected_errors` is byte-identical to the source fixture's array.
- [ ] [P1-T5] Create `tests/fixtures/orchestrator_state_issue_adoption/filed-before-orchestration-invalid-present-record.json` per derivation D5.
  - Acceptance: as P1-T1, with the D5 changes; `expected_errors` is byte-identical to the source fixture's array.
- [ ] [P1-T6] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/other/corpus-recount.2026-10-09T01-33.md` re-counting the corpus with the same two methods as P0-T3.
  - Acceptance: both member sets are listed and identical, each with 34 members (the 29 baseline members plus the five P1 stems). Any other count records `BLOCKED: CORPUS RECOUNT MISMATCH` and stops before P1-T7.
- [ ] [P1-T7] Update `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py` so `MINIMUM_CORPUS_COUNT` equals the P1-T6 count (34).
  - Acceptance: the only change to the file is the constant value 29 replaced by 34.
- [ ] [P1-T8] Update `extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption-parity.test.ts` so `MINIMUM_CORPUS_COUNT` equals the P1-T6 count (34).
  - Acceptance: the only change to the file is the constant value 29 replaced by 34.
- [ ] [P1-T9] Update `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Parity.Tests.ps1` so `$minimumFixtureCount` equals the P1-T6 count (34).
  - Acceptance: the only change to the file is the value 29 replaced by 34.
- [ ] [P1-T10] Add the seven Python tests and the `PREPARATION_BUG_TOOLS` constant to `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py` per "New Test Specifications", importing `E4`, `invalid_potential_record_error`, `LARGE_BUG_TOOLS`, `LARGE_TOOLS`, and the existing builders from the support module, and extending the module docstring with the issue #849 group.
  - Acceptance: the seven named test functions exist with Arrange-Act-Assert sections and docstrings; no existing test is changed; the file stays at or below 500 lines.
- [ ] [P1-T11] Create `extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption-origin.test.ts` per "New Test Specifications".
  - Acceptance: seven `it` cases with the listed titles under one `describe`; the file imports only `@jest/globals` and the resolver module; it is at or below 500 lines.
- [ ] [P1-T12] Add the new `Describe` block with seven `It` blocks to `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1` per "New Test Specifications".
  - Acceptance: the seven `It` titles match the TypeScript titles; no existing block is changed; the file stays at or below 500 lines.
- [ ] [P1-T13] Create `tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py` per "New Test Specifications".
  - Acceptance: eleven collected test cases with the listed names and parametrize ids; no text is read at collection time; the file is at or below 500 lines.

### Phase 2 — Fail-Before Regression Evidence

- [ ] [P2-T1] [expect-fail] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/regression-testing/py-parity-expect-fail.2026-10-09T01-33.md` recording `poetry run pytest tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py` before the validator change.
  - Acceptance: `ExpectedExitCode: 1` and observed `EXIT_CODE: 1`; summary "3 failed, 34 passed"; the failed node IDs are exactly the parametrized cases for the D1, D2, and D3 stems; the D1 failure output, quoted verbatim, lists the observed routing errors, including the token `when waiving new_potential_bug_entry` and both missing-receipt errors (AC-7 fail-before).
- [ ] [P2-T2] [expect-fail] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/regression-testing/py-waivers-expect-fail.2026-10-09T01-33.md` recording `poetry run pytest tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py` before the validator change.
  - Acceptance: `ExpectedExitCode: 1` and observed `EXIT_CODE: 1`; summary "3 failed, 12 passed"; the failed tests are exactly Python tests 1, 2, and 3 of "New Test Specifications".
- [ ] [P2-T3] [expect-fail] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/regression-testing/py-skill-contracts-expect-fail.2026-10-09T01-33.md` recording `poetry run pytest tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py` before any skill or rule-document edit.
  - Acceptance: `ExpectedExitCode: 1` and observed `EXIT_CODE: 1`; summary "8 failed, 3 passed"; the three passing cases are `test_parallel_plan_kickoff_line_is_unchanged`, `test_parallel_orchestrate_kickoff_keeps_five_elements`, and the `parallel-orchestrate-element-four` case of `test_added_skill_text_does_not_match_hook_issue_number_pattern` (AC-10 fail-before).
- [ ] [P2-T4] [expect-fail] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/regression-testing/ts-origin-expect-fail.2026-10-09T01-33.md` recording `npm --prefix extensions/drm-copilot run test:unit -- test/lib/validate/orchestrator-state-issue-adoption-origin.test.ts` before the validator change.
  - Acceptance: `ExpectedExitCode: 1` and a non-zero observed `EXIT_CODE`; the `Tests:` line reports 3 failed and 4 passed of 7; the failed titles are the first three titles in the TypeScript list.

### Phase 3 — Validator Fix in Three Runtimes

- [ ] [P3-T1] Fix rule 9 in `scripts/dev_tools/_orchestrator_state_issue_adoption.py`: add `RECORD_OPTIONAL_ORIGINS: frozenset[str] = frozenset({"transferred", "filed_before_orchestration"})` with a one-line comment; give `_potential_record_errors` keyword-only parameters `origin: object` and `record_present: bool` and return `[]` first when `not record_present and isinstance(origin, str) and origin in RECORD_OPTIONAL_ORIGINS`; update its docstring; pass `origin=adoption.get("origin")` and `record_present="potential_record" in adoption` at the call site in `resolve_issue_adoption`.
  - Acceptance: no error string, rule order, or fail-closed line changes; the rule-8 shape-check precondition is unchanged; the file stays at or below 500 lines.
- [ ] [P3-T2] Fix rule 9 in `extensions/drm-copilot/src/lib/validate/orchestrator-state-issue-adoption.ts`: add a non-exported `RECORD_OPTIONAL_ORIGINS: ReadonlySet<string>` holding `transferred` and `filed_before_orchestration`; give `potentialRecordErrors` parameters `origin: unknown` and `recordPresent: boolean` and return `[]` first when `!recordPresent && typeof origin === "string" && RECORD_OPTIONAL_ORIGINS.has(origin)`; pass `adoption["origin"]` and `Object.prototype.hasOwnProperty.call(adoption, "potential_record")` at the call in `resolveIssueAdoption`.
  - Acceptance: no error string or exported signature changes; no `any` is introduced; the file stays at or below 500 lines.
- [ ] [P3-T3] Fix rule 9 in `.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1`: add `$script:RECORD_OPTIONAL_ORIGINS = [string[]]@('transferred', 'filed_before_orchestration')`; add `[AllowNull()][object] $Origin` and mandatory `[bool] $RecordPresent` parameters (with `.PARAMETER` help) to `Get-AdoptionPotentialRecordError` and return an empty `[string[]]` first when `-not $RecordPresent -and ($Origin -is [string]) -and ($script:RECORD_OPTIONAL_ORIGINS -ccontains [string]$Origin)`; in `Get-OrchestratorStateIssueAdoptionResult`, read the `potential_record` member once with `Get-CheckpointObjectMember` and pass its `.Value`, its `.Present`, and the `origin` member's `.Value`.
  - Acceptance: `Export-ModuleMember` is unchanged; no error string changes; the file stays at or below 500 lines.
- [ ] [P3-T4] Replace `extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1` with a byte-identical copy of the P3-T3 module.
  - Acceptance: `cmp .claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1` exits 0 and prints nothing.

### Phase 4 — Skill and Rule-Document Edits with Bundled Mirrors

- [ ] [P4-T1] Edit `.claude/skills/parallel-plan/SKILL.md` to insert text block S1 in `## Item Intake`.
  - Acceptance: S1 appears once, directly after the Promotion bullet; no other line of the section changes.
- [ ] [P4-T2] Edit `.claude/skills/parallel-plan/SKILL.md` to apply text blocks S2, S3, and S4 in `## Preparation Fan-Out`.
  - Acceptance: the kickoff blockquote line and the model-budget blockquote line are byte-unchanged; S3 is the only blockquote line beginning "> `Issue adoption:"; S4 follows the Deliberate omissions paragraph.
- [ ] [P4-T3] Edit `.claude/skills/parallel-plan/SKILL.md` to apply text block S5 in the per-child collection sentence.
  - Acceptance: the rest of the sentence is unchanged.
- [ ] [P4-T4] Edit `.claude/skills/parallel-orchestrate/SKILL.md` to append text block S6 to kickoff element 4.
  - Acceptance: the section still states "exactly these five elements"; no list item 6 and no `##` heading is added; lines outside element 4 are unchanged.
- [ ] [P4-T5] Edit `.claude/rules/orchestrator-state.md` to apply text blocks R1, R2, and R3 in `## Invariants (issue_adoption object)`.
  - Acceptance: only the `potential_record` table row and rule 9 are replaced and the R3 paragraph is added; the required-keys area and every other section are unchanged.
- [ ] [P4-T6] Edit `.claude/skills/orchestrate/SKILL.md` to apply text block O1.
  - Acceptance: only the replaced sentence differs in the paragraph; the rest of the file is unchanged.
- [ ] [P4-T7] Edit `.claude/skills/feature-promotion-lifecycle/SKILL.md` to apply text block L1.
  - Acceptance: only step 2 of the adopted-issue list differs.
- [ ] [P4-T8] Replace `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md` with a byte-identical copy of the edited parallel-plan skill.
  - Acceptance: `cmp .claude/skills/parallel-plan/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md` exits 0.
- [ ] [P4-T9] Replace `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md` with a byte-identical copy of the edited parallel-orchestrate skill.
  - Acceptance: `cmp .claude/skills/parallel-orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md` exits 0.
- [ ] [P4-T10] Replace `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md` with a byte-identical copy of the edited rule document.
  - Acceptance: `cmp .claude/rules/orchestrator-state.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md` exits 0.
- [ ] [P4-T11] Replace `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md` with a byte-identical copy of the edited orchestrate skill.
  - Acceptance: `cmp .claude/skills/orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md` exits 0.
- [ ] [P4-T12] Replace `extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-promotion-lifecycle/SKILL.md` with a byte-identical copy of the edited lifecycle skill.
  - Acceptance: `cmp .claude/skills/feature-promotion-lifecycle/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-promotion-lifecycle/SKILL.md` exits 0.
- [ ] [P4-T13] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/other/mirror-identity.2026-10-09T01-33.md` recording the six `cmp` commands of P3-T4 and P4-T8 through P4-T12, re-run together after all edits.
  - Acceptance: six `Command:`/`EXIT_CODE: 0` pairs, each with an empty-output `Output Summary:` (AC-15 mirror identity).

### Phase 5 — Pass-After Verification

- [ ] [P5-T1] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/regression-testing/py-parity-pass-after.2026-10-09T01-33.md` recording `poetry run pytest tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py`.
  - Acceptance: EXIT_CODE 0 and summary "37 passed"; the D1 through D5 cases are listed as passed (AC-6, AC-7 pass-after in Python).
- [ ] [P5-T2] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/regression-testing/py-waivers-pass-after.2026-10-09T01-33.md` recording `poetry run pytest tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py`.
  - Acceptance: EXIT_CODE 0 and summary "15 passed" (AC-1, and the Python legs of AC-4 and AC-5).
- [ ] [P5-T3] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/regression-testing/py-skill-contracts-pass-after.2026-10-09T01-33.md` recording `poetry run pytest tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py`.
  - Acceptance: EXIT_CODE 0 and summary "11 passed" (AC-10, AC-11, AC-12, AC-13, AC-14 named-test legs).
- [ ] [P5-T4] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/regression-testing/ts-parity-origin-pass-after.2026-10-09T01-33.md` recording `npm --prefix extensions/drm-copilot run test:unit -- test/lib/validate/orchestrator-state-issue-adoption-parity.test.ts test/lib/validate/orchestrator-state-issue-adoption-origin.test.ts`.
  - Acceptance: EXIT_CODE 0; the `Test Suites:` line reports 2 passed and the `Tests:` line reports 44 passed of 44 (37 parity plus 7 origin) (AC-2, AC-6, AC-7 pass-after in TypeScript, TypeScript legs of AC-4 and AC-5).
- [ ] [P5-T5] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/other/fixture-immutability.2026-10-09T01-33.md` recording `git diff --name-status --merge-base origin/main -- tests/fixtures/orchestrator_state_issue_adoption`, `git status --porcelain -- tests/fixtures/orchestrator_state_issue_adoption`, and `git diff -U0 --merge-base origin/main -- scripts/dev_tools/_orchestrator_state_issue_adoption.py extensions/drm-copilot/src/lib/validate/orchestrator-state-issue-adoption.ts .claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1`.
  - Acceptance: the union of the name-status entries and the porcelain entries for the fixture directory is exactly the five P1 files, each as added (`A`) or untracked (`??`), with no `M`, `D`, or `R` entry; every removed (`-`) line of the module diff is quoted verbatim and none contains any of the tokens `Checkpoint issue_adoption`, `must name a markdown`, or `when waiving` (AC-8).
- [ ] [P5-T6] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/other/doc-observation.2026-10-09T01-33.md` quoting, with the Read tool, the post-edit `potential_record` table row, rule 9, and the R3 paragraph of the rule document, the O1 sentence of the orchestrate skill, and step 2 of the lifecycle skill, each with its line number.
  - Acceptance: each quoted passage matches its text block (R1, R2, R3, O1, L1); the P5-T3 pass of `test_rule_doc_states_origin_conditional_potential_record` and both `test_skill_states_origin_conditional_potential_record` cases is cited (AC-13, AC-14).

### Phase 6 — Python Final QA Loop

Loop rule: run P6-T1 through P6-T6 in order. If any task fails, or P6-T1 prints a "reformatted" line, correct the cause and restart at P6-T1, overwriting the artifacts. The loop is complete when one pass completes with every acceptance met.

- [ ] [P6-T1] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/py-black.2026-10-09T01-33.md` recording `poetry run black scripts/dev_tools/_orchestrator_state_issue_adoption.py tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py`.
  - Acceptance: EXIT_CODE 0, the summary line "4 files left unchanged." recorded, and no "reformatted" line printed.
- [ ] [P6-T2] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/py-ruff.2026-10-09T01-33.md` recording `poetry run ruff check scripts/dev_tools/_orchestrator_state_issue_adoption.py tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py`.
  - Acceptance: EXIT_CODE 0 and the output "All checks passed!" recorded.
- [ ] [P6-T3] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/py-pyright.2026-10-09T01-33.md` recording `poetry run pyright scripts/dev_tools/_orchestrator_state_issue_adoption.py tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py`.
  - Acceptance: EXIT_CODE 0 and the summary "0 errors, 0 warnings, 0 informations" recorded.
- [ ] [P6-T4] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/py-adoption-coverage.2026-10-09T01-33.md` and `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/py-adoption-coverage.2026-10-09T01-33.json` recording `poetry run pytest tests/scripts/dev_tools/test_orchestrator_state_issue_adoption.py tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py tests/scripts/dev_tools/test_validate_orchestrator_state_issue_adoption.py tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py --cov=scripts.dev_tools._orchestrator_state_issue_adoption --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/py-adoption-coverage.2026-10-09T01-33.json`.
  - Acceptance: EXIT_CODE 0; passed count equals `RB_PY_TARGETED_PASSED` + 12 with 0 failed; the verbatim `term-missing` row and the JSON line and branch percentages for the module are recorded, with line >= 85.0, branch >= 75.0, and neither below `RB_PY_LINE` / `RB_PY_BRANCH`.
- [ ] [P6-T5] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/py-full-suite.2026-10-09T01-33.md` and `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/py-full-coverage.2026-10-09T01-33.json` recording `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/py-full-coverage.2026-10-09T01-33.json`.
  - Acceptance: the failed-node-ID set equals `RB_PY_FULL_FAILED`; the passed count equals `RB_PY_FULL_PASSED` + 23 (7 waivers, 5 parity, 11 skill-contract cases); the verbatim `TOTAL` row and the JSON totals are recorded and neither total percentage is below its P0-T9 value.
- [ ] [P6-T6] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/py-skill-contracts.2026-10-09T01-33.md` recording `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py tests/scripts/dev_tools/test_parallel_kickoff_template_seam.py tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py`.
  - Acceptance: EXIT_CODE 0; passed count equals `RB_PY_CONTRACT_PASSED` + 11 with 0 failed; the pass of `test_bundled_claude_payload_contains_all_repo_runtime_contracts` is named (AC-11, AC-12, AC-15).

### Phase 7 — TypeScript Final QA Loop

Loop rule: run P7-T1 through P7-T5 in order. If any task fails or P7-T1 rewrites a file, correct the cause and restart at P7-T1, overwriting the artifacts.

- [ ] [P7-T1] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/ts-format.2026-10-09T01-33.md` recording `git status --porcelain`, `npm --prefix extensions/drm-copilot run format`, and `git status --porcelain`.
  - Acceptance: EXIT_CODE 0; every printed Prettier file line ends in "(unchanged)" (count recorded); the two porcelain listings are recorded verbatim and identical.
- [ ] [P7-T2] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/ts-lint.2026-10-09T01-33.md` recording `npm --prefix extensions/drm-copilot run lint`.
  - Acceptance: EXIT_CODE 0 and no problem lines after the npm script banner.
- [ ] [P7-T3] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/ts-typecheck.2026-10-09T01-33.md` recording `npm --prefix extensions/drm-copilot run typecheck`.
  - Acceptance: EXIT_CODE 0 and no diagnostic lines after the npm script banners.
- [ ] [P7-T4] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/ts-validate-dir-tests.2026-10-09T01-33.md` recording `npm --prefix extensions/drm-copilot run test:unit -- test/lib/validate`.
  - Acceptance: EXIT_CODE 0; suites passed equals `RB_TS_DIR_SUITES` + 1 and tests passed equals `RB_TS_DIR_PASSED` + 12, with 0 failed.
- [ ] [P7-T5] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/ts-coverage.2026-10-09T01-33.md` and `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/ts-coverage-output.2026-10-09T01-33.txt` recording `npm --prefix extensions/drm-copilot run test:coverage -- --coverageReporters=text > docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/ts-coverage-output.2026-10-09T01-33.txt 2>&1`.
  - Acceptance: EXIT_CODE 0 (every per-file `coverageThreshold` met); the `Tests:` line reports `RB_TS_TESTS_PASSED` + 12 passed with 0 failed; the summary lines and the `orchestrator-state-issue-adoption.ts` row are quoted verbatim, with % Lines >= 85 and % Branch >= 75 and neither below `RB_TS_LINE` / `RB_TS_BRANCH`. Absolute host paths, if present, are replaced with `ABSOLUTE_PATH`.

### Phase 8 — PowerShell Final QA Loop

Loop rule: run P8-T1 through P8-T5 in order. If P8-T1 rewrites a file inside `## Files Written` (the two porcelain listings differ, or any of the four P8-T1 digests changes), keep the rewrite, re-run P3-T4 (when the source module or its bundled mirror was rewritten) and P4-T13 so the bundled mirror stays byte-identical, re-run P6-T6, and restart at P8-T1; if it rewrites any other file, record `BLOCKED: OUT-OF-SCOPE FORMAT CHANGE` and stop without reverting. If P8-T2 or P8-T5 fails, correct the cause and restart at P8-T1; handoff H1 is repeated and its copies replace the earlier ones.

- [ ] [P8-T1] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/ps-format.2026-10-09T01-33.md` recording, in this order, `git status --porcelain`, `sha256sum .claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1 tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Parity.Tests.ps1`, the MCP tool `mcp__drm-copilot__run_poshqc_format` with `workspace_root` set to the worktree root, the same `sha256sum` command again, and `git status --porcelain`.
  - Acceptance: `EXIT_CODE: 0` for status `success` with an `MCP-Status:` line; the two porcelain listings are recorded verbatim and identical; the four digests are recorded verbatim before and after the format call and each file's digest is identical in both runs, so the four in-scope PowerShell files (already modified, and therefore invisible to a porcelain comparison) were left unchanged.
- [ ] [P8-T2] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/ps-analyze.2026-10-09T01-33.md` recording the MCP tool `mcp__drm-copilot__run_poshqc_analyze` with `workspace_root` set to the worktree root.
  - Acceptance: `EXIT_CODE: 0` for status `success` with an `MCP-Status:` line; no count is asserted from the MCP result (analyzer counts come from P8-T5).
- [ ] [P8-T3] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/ps-test-mcp.2026-10-09T01-33.md` recording the MCP tool `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the worktree root and `scan_folders` set to tests/scripts/claude-lib/orchestrator-state, tests/scripts/claude-hooks, and tests/scripts/claude-runtime, then stop for handoff H1.
  - Acceptance: the `MCP-Status:` value is recorded with `EXIT_CODE: 0` for `success` or `EXIT_CODE: 1` for `failure`; this call is route compliance only, no count or coverage figure is taken from it, and pass or fail for PowerShell is decided by P8-T5. The artifact records `H1-Trigger-Completed:` (UTC). The executor then returns `HANDOFF: POWERSHELL SOURCE A (H1)`.
- [ ] [P8-T4] Write the H1 copies `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/poshqc-local/run-record.md`, `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/poshqc-local/pester-junit.xml`, `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/poshqc-local/powershell-coverage.xml`, and `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/poshqc-local/analyzer-output.txt` (orchestrator-performed at handoff H1, same source as H0).
  - Acceptance: as P0-T18, with `H1-Trigger-Completed:` in place of `H0-Trigger-Completed:` in both the Source A and the Source B freshness clauses. On resume after the handoff, `atomic-executor` verifies this acceptance against the files on disk (including the freshness and `sanitized:` lines in `run-record.md`) and checks the task off; it does not re-run the orchestrator commands.
- [ ] [P8-T5] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/ps-test-coverage.2026-10-09T01-33.md` recording the PowerShell results read from the H1 copies under the reading rules.
  - Acceptance: OrchestratorStateIssueAdoption.Tests.ps1 reports `RB_PS_UNIT_PASSED` + 7 tests with 0 failures and its seven new `testcase` names present; OrchestratorStateIssueAdoption.Parity.Tests.ps1 reports `RB_PS_PARITY_PASSED` + 5 tests with 0 failures and a `testcase` naming `valid-bug-preparation-filed-before-orchestration-without-record` with no `failure` child; enforce-orchestration-preimplementation-gate.Tests.ps1 reports 0 failures; the failed-test set across the three folders equals `RB_PS_FAILED`; the `LINE` counter of `OrchestratorStateIssueAdoption.psm1` gives >= 85.0% and not below `RB_PS_LINE`; the four Source A analyzer counts are 0 (or `AnalyzeStep: success` for Source B) (AC-3, AC-6, AC-7, AC-12, AC-18, PowerShell legs of AC-4 and AC-5).

### Phase 9 — Coverage Deltas, Scope Gates, and Acceptance Check-Off

- [ ] [P9-T1] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/py-coverage-delta.2026-10-09T01-33.md` comparing Python coverage from P0-T8 and P6-T4 and computing changed-line coverage from `git diff -U0 --merge-base origin/main -- scripts/dev_tools/_orchestrator_state_issue_adoption.py` against the P6-T4 JSON `executed_lines` and `missing_lines` for the module.
  - Acceptance: baseline line and branch, post-change line and branch, and changed-line coverage (added line numbers from the `-U0` hunk headers that appear in the P6-T4 JSON `executed_lines` or `missing_lines` for the module; covered = those not in `missing_lines`; arithmetic shown) are recorded; post-change line >= 85.0, branch >= 75.0, neither below baseline, and changed-line coverage >= 85.0 (AC-16).
- [ ] [P9-T2] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/ts-coverage-delta.2026-10-09T01-33.md` comparing the `orchestrator-state-issue-adoption.ts` rows of P0-T15 and P7-T5 and checking the added line numbers from `git diff -U0 --merge-base origin/main -- extensions/drm-copilot/src/lib/validate/orchestrator-state-issue-adoption.ts` against the P7-T5 Uncovered Line #s.
  - Acceptance: baseline and post-change % Lines and % Branch recorded; post-change >= 85 / >= 75 and not below baseline; no added line number appears in the Uncovered Line #s column (AC-17).
- [ ] [P9-T3] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/ps-coverage-delta.2026-10-09T01-33.md` comparing `RB_PS_LINE` with the P8-T5 line coverage and computing changed-line coverage from `git diff -U0 --merge-base origin/main -- .claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1` against the H1 coverage `line` elements.
  - Acceptance: baseline and post-change line percentages recorded; post-change >= 85.0 and not below baseline; the added line numbers that appear as `line` elements are listed with their `ci` values and covered / instrumented >= 85.0; a statement that Pester measures no branch coverage is included (AC-18).
- [ ] [P9-T4] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/file-size-gate.2026-10-09T01-33.md` from `wc -l scripts/dev_tools/_orchestrator_state_issue_adoption.py extensions/drm-copilot/src/lib/validate/orchestrator-state-issue-adoption.ts .claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1 tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption-origin.test.ts extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption-parity.test.ts tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Parity.Tests.ps1`.
  - Acceptance: EXIT_CODE 0 and every one of the eleven counts is at or below 500.
- [ ] [P9-T5] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/diff-scope.2026-10-09T01-33.md` recording `git diff --name-status --merge-base origin/main` and `git status --porcelain`.
  - Acceptance: every listed path is in `## Files Written`, in `BASE_DIFF` or `BASE_PORCELAIN` from P0-T2, or under the feature folder; neither scripts/dev_tools/validate_orchestrator_state.py nor .claude/skills/parallel-add/SKILL.md appears in either listing.
- [ ] [P9-T6] Write `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/other/follow-up-parallel-add.2026-10-09T01-33.md` recording the out-of-scope residual: `/parallel-add` preparation children for issue-number items do not receive the issue-adoption instruction, overlap with #843 is the reason, and the execution child is covered by the parallel-orchestrate change.
  - Acceptance: the note carries `Timestamp:`, the residual statement, the reason, and a recommended follow-up item for the orchestrator to file; no file outside the feature folder is written.
- [ ] [P9-T7] Update `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/spec.md` to check AC-1.
  - Acceptance: checked only when the P5-T2 artifact shows "15 passed" and P6-T5 passed.
- [ ] [P9-T8] Update `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/spec.md` to check AC-2.
  - Acceptance: checked only when P5-T4 and P7-T4 passed.
- [ ] [P9-T9] Update `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/spec.md` to check AC-3.
  - Acceptance: checked only when P8-T5 records the seven new PowerShell test cases passing.
- [ ] [P9-T10] Update `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/spec.md` to check AC-4.
  - Acceptance: checked only when P5-T1, P5-T2, P5-T4, and P8-T5 passed, including the D4 parity case and the epic_decomposition unit tests.
- [ ] [P9-T11] Update `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/spec.md` to check AC-5.
  - Acceptance: checked only when P5-T1, P5-T2, P5-T4, and P8-T5 passed, including the D5 parity case and the null and invalid-record unit tests.
- [ ] [P9-T12] Update `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/spec.md` to check AC-6.
  - Acceptance: checked only when P1-T6 shows 34 identical members and P5-T1, P5-T4, and P8-T5 show every corpus case passing.
- [ ] [P9-T13] Update `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/spec.md` to check AC-7.
  - Acceptance: checked only when P2-T1 records the fail-before run and P5-T1, P5-T4, and P8-T5 record the pass-after runs.
- [ ] [P9-T14] Update `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/spec.md` to check AC-8.
  - Acceptance: checked only when P0-T2 recorded `BASE_SHA` (the merge-base of the branch and origin/main named in the restated AC-8) and P5-T5, whose diffs are taken against that merge-base, passed, and P5-T1, P5-T4, and P8-T5 show every corpus case passing (the byte-unchanged baseline fixtures' `expected_errors` cover every validator error string, so this is the error-string leg of AC-8).
- [ ] [P9-T15] Update `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/spec.md` to check AC-9.
  - Acceptance: checked only when P1-T6 passed and P1-T7, P1-T8, and P1-T9 set each floor to the P1-T6 count.
- [ ] [P9-T16] Update `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/spec.md` to check AC-10.
  - Acceptance: checked only when P2-T3 recorded the fail-before run and P5-T3 passed.
- [ ] [P9-T17] Update `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/spec.md` to check AC-11.
  - Acceptance: checked only when P5-T3 and P6-T6 passed.
- [ ] [P9-T18] Update `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/spec.md` to check AC-12.
  - Acceptance: checked only when P5-T3 and P6-T6 passed and P8-T5 shows 0 failures for enforce-orchestration-preimplementation-gate.Tests.ps1.
- [ ] [P9-T19] Update `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/spec.md` to check AC-13.
  - Acceptance: checked only when P5-T6 passed.
- [ ] [P9-T20] Update `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/spec.md` to check AC-14.
  - Acceptance: checked only when P5-T6 passed.
- [ ] [P9-T21] Update `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/spec.md` to check AC-15.
  - Acceptance: checked only when P4-T13 and P6-T6 passed.
- [ ] [P9-T22] Update `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/spec.md` to check AC-16.
  - Acceptance: checked only when P6-T1 through P6-T6 passed in one loop pass and P9-T1 passed. Leave AC-16 unchecked if `RB_PY_FULL_FAILED` is non-empty, and record each failing node ID as a gap in `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/diff-scope.2026-10-09T01-33.md`.
- [ ] [P9-T23] Update `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/spec.md` to check AC-17.
  - Acceptance: checked only when P7-T1 through P7-T5 passed in one loop pass and P9-T2 passed.
- [ ] [P9-T24] Update `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/spec.md` to check AC-18.
  - Acceptance: checked only when P8-T1 through P8-T5 passed in one loop pass and P9-T3 passed. Leave AC-18 unchecked if the P8-T5 failed-test set across the three scan folders is non-empty, and record each failing test name as a gap in `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/diff-scope.2026-10-09T01-33.md`.

## Files Written

Production and test files:

`scripts/dev_tools/_orchestrator_state_issue_adoption.py`
`extensions/drm-copilot/src/lib/validate/orchestrator-state-issue-adoption.ts`
`.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1`
`extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1`
`.claude/rules/orchestrator-state.md`
`extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`
`.claude/skills/parallel-plan/SKILL.md`
`extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md`
`.claude/skills/parallel-orchestrate/SKILL.md`
`extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md`
`.claude/skills/orchestrate/SKILL.md`
`extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`
`.claude/skills/feature-promotion-lifecycle/SKILL.md`
`extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-promotion-lifecycle/SKILL.md`
`tests/fixtures/orchestrator_state_issue_adoption/valid-bug-preparation-filed-before-orchestration-without-record.json`
`tests/fixtures/orchestrator_state_issue_adoption/valid-bug-large-filed-before-orchestration-without-record.json`
`tests/fixtures/orchestrator_state_issue_adoption/valid-large-transferred-waives-feature-entry-tool-without-record.json`
`tests/fixtures/orchestrator_state_issue_adoption/epic-decomposition-waives-entry-tool-without-record.json`
`tests/fixtures/orchestrator_state_issue_adoption/filed-before-orchestration-invalid-present-record.json`
`tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py`
`tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py`
`tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py`
`extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption-origin.test.ts`
`extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption-parity.test.ts`
`tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1`
`tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Parity.Tests.ps1`

Feature documents:

`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/spec.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/plan.2026-10-09T01-33.md`

Evidence files:

`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/phase0-instructions-read.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/git-baseline.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/corpus-count.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/file-line-counts.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/py-black.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/py-ruff.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/py-pyright.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/py-adoption-coverage.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/py-adoption-coverage.2026-10-09T01-33.json`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/py-full-suite.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/py-full-coverage.2026-10-09T01-33.json`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/py-skill-contracts.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/ts-format.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/ts-lint.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/ts-typecheck.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/ts-validate-dir-tests.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/ts-coverage.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/ts-coverage-output.2026-10-09T01-33.txt`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/ps-format.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/ps-analyze.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/poshqc-local/run-record.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/poshqc-local/pester-junit.xml`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/poshqc-local/powershell-coverage.xml`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/poshqc-local/analyzer-output.txt`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/baseline/ps-test-coverage.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/regression-testing/py-parity-expect-fail.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/regression-testing/py-waivers-expect-fail.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/regression-testing/py-skill-contracts-expect-fail.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/regression-testing/ts-origin-expect-fail.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/regression-testing/py-parity-pass-after.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/regression-testing/py-waivers-pass-after.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/regression-testing/py-skill-contracts-pass-after.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/regression-testing/ts-parity-origin-pass-after.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/other/corpus-recount.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/other/mirror-identity.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/other/fixture-immutability.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/other/doc-observation.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/other/follow-up-parallel-add.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/py-black.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/py-ruff.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/py-pyright.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/py-adoption-coverage.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/py-adoption-coverage.2026-10-09T01-33.json`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/py-full-suite.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/py-full-coverage.2026-10-09T01-33.json`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/py-skill-contracts.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/ts-format.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/ts-lint.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/ts-typecheck.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/ts-validate-dir-tests.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/ts-coverage.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/ts-coverage-output.2026-10-09T01-33.txt`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/ps-format.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/ps-analyze.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/ps-test-mcp.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/poshqc-local/run-record.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/poshqc-local/pester-junit.xml`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/poshqc-local/powershell-coverage.xml`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/poshqc-local/analyzer-output.txt`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/ps-test-coverage.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/py-coverage-delta.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/ts-coverage-delta.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/ps-coverage-delta.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/file-size-gate.2026-10-09T01-33.md`
`docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/diff-scope.2026-10-09T01-33.md`
