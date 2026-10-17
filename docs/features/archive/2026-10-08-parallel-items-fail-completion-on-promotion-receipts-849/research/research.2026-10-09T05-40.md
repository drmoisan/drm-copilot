# Research: parallel-items-fail-completion-on-promotion-receipts (Issue #849)

- Issue: #849
- Branch: bug/parallel-items-fail-completion-on-promotion-receipts-849
- Work mode: full-bug
- Researched: 2026-10-09T05-40
- Tree inspected: the agent worktree for this branch (HEAD descends from `a24a1ce3`)

## Summary

The `issue_adoption` waiver from #509 / PR #809 works as designed in all three runtimes, but two gaps keep parallel-run items from using it:

1. **Skill gap (primary cause).** Neither `.claude/skills/parallel-plan/SKILL.md` (preparation fan-out) nor `.claude/skills/parallel-orchestrate/SKILL.md` (execution kickoff) tells the child orchestrator to record `issue_adoption`. The execution child also starts with a new checkpoint in a new worktree. The preparation checkpoint is gitignored and does not carry over, so an adoption recorded during preparation would not reach execution anyway.
2. **Rule-9 gap (secondary cause).** Waiving the promotion-entry tool (`new_potential_entry` / `new_potential_bug_entry`) requires a `potential_record` string that starts with `docs/features/potential/` and ends with `.md`. The check is syntactic only. It accepts the `docs/features/potential/promoted/` subfolder and never checks that the file exists. An issue that was filed by hand or consolidated (for example #734) has no record, so the only way to pass is to name a file that is not that issue's record.

Recommendation: make `potential_record` optional only when `origin` is `transferred` or `filed_before_orchestration` and the key is absent. A value that is present must still be valid, and `epic_decomposition` keeps the current requirement. Make this change in all three runtimes, the rule doc, and the shared corpus. Add one `issue_adoption` instruction line to each parallel delegation prompt. `.claude/skills/orchestrate/SKILL.md` and `.claude/skills/feature-promotion-lifecycle/SKILL.md` each get a one-sentence wording update so they match the relaxed rule. Every `.claude/**` edit is mirrored byte-for-byte under `extensions/drm-copilot/resources/claude-customizations/`.

## Findings per Question

### Q1. Current behavior of the waiver

**Python authority:** `scripts/dev_tools/_orchestrator_state_issue_adoption.py`

- Constants:
  - `ORIGIN_VALUES` (lines 56-58): `transferred`, `filed_before_orchestration`, `epic_decomposition`.
  - `VERIFIED_VIA_VALUES` (lines 59-61).
  - `WAIVABLE_TOOLS` (lines 64-66): `potential_to_issue`, `new_potential_entry`, `new_potential_bug_entry`.
  - `PROMOTION_ENTRY_TOOLS` (lines 67-70).
  - `POTENTIAL_RECORD_PREFIX = "docs/features/potential/"` (line 71) and `POTENTIAL_RECORD_SUFFIX = ".md"` (line 72).
- Rule 1 (lines 294-299). An absent key returns no errors and no waivers. A present value that is not a dict (including `null`) returns only `ERROR_NOT_OBJECT`.
- Rules 2-3, `_issue_identity_errors` (lines 134-157). `issue_num` must be a decimal string with no leading zero. It must equal the checkpoint `issue-num` when that is a string. `issue_url` must end with `/issues/<issue_num>`.
- Rules 4-7, `_provenance_errors` (lines 160-181). Checks `origin`, `verified_via`, `verified_at` (presence only) and `evidence`.
- Rule 8, `_waived_tool_list` and `_waived_tool_errors` (lines 184-232).
  - The shape check needs a non-empty list of non-blank strings. A malformed list adds `ERROR_WAIVED_TOOLS_SHAPE` and skips rule 9 (lines 306-309).
  - Each entry gets the first error that applies, in this order: duplicate, not waivable, not required by the route, already has a successful receipt (lines 206-228).
  - The list must include `potential_to_issue` (lines 230-231).
- Rule 9, `_potential_record_errors` (lines 235-257). Runs only after the rule-8 shape check passed (lines 319-321).
  - When `potential_record` is a string that starts with the prefix and ends with `.md`, no error is reported.
  - Otherwise each distinct promotion-entry tool in the waived list gets one error. Rule 9 does not read `origin`.
- Fail-closed (lines 323-325): any error empties `waived_tools`.
- Promotion-type resolution happens before the resolver runs. `_resolve_promotion_entry_tools` in `scripts/dev_tools/_orchestrator_state_promotion_tools.py:46-95` replaces `new_potential_entry` with `new_potential_bug_entry` only when `promotion-type == "bug"` (line 87). The resolver receives the resolved list. On a bug checkpoint, waiving `new_potential_entry` therefore fails rule 8 as "not required by route" (corpus `bug-waives-feature-entry-tool.json`).

**Python callers**

- `scripts/dev_tools/_orchestrator_state_routing.py:189-265`, `validate_routing_contract`:
  - Line 216: resolves the tools.
  - Lines 249-254: calls `resolve_issue_adoption`.
  - Lines 255-259: the receipt loop skips waived tools.
  - Line 260: adoption errors are added after the receipt errors and before `local_execution_overrides` (line 262).
- `scripts/dev_tools/validate_orchestrator_state.py:406` calls `validate_routing_contract` only under `require_complete` (lines 388-407). This is the path the `validate_orchestration_artifacts` MCP tool uses.

**TypeScript port:** `extensions/drm-copilot/src/lib/validate/orchestrator-state-issue-adoption.ts`

- Same constants: lines 35-64, with the prefix and suffix at lines 62-63.
- `potentialRecordErrors`: lines 226-249.
- `resolveIssueAdoption`: lines 263-295. A malformed waived list returns early at lines 282-286.
- Caller: `orchestrator-state-routing.ts:4` (import) and lines 446-456 (receipt loop), inside `validateRoutingContract` (line 382). That function is invoked from `orchestrator-state-core.ts:432`.

**PowerShell port:** `.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1`

- Constants: lines 33-57.
- `Get-AdoptionPotentialRecordError`: lines 259-297.
- `Get-OrchestratorStateIssueAdoptionResult`: lines 299-372. This is the only exported function (line 375).
- Caller: `.claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1`, import at line 61 and receipt loop at lines 416-422.
- That module is reached through `OrchestratorStateCompletion.psm1:418`, which is imported by the SubagentStop hook `.claude/hooks/validate-orchestrator-output.ps1:259`.
- A byte-identical copy ships at `extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1`.

**Tests**

- Python:
  - `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption.py` (463 lines; fixed 96-case grid at lines 408-462 that always uses `VALID_RECORD`)
  - `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py` (178 lines)
  - `tests/scripts/dev_tools/test_validate_orchestrator_state_issue_adoption.py`
  - `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py`
  - Helpers: `tests/scripts/dev_tools/orchestrator_state_issue_adoption_test_support.py` (`VALID_RECORD` at lines 64-67, `build_adoption` at line 145, `run_resolver` at line 173)
- TypeScript:
  - `extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption.test.ts` (478 lines)
  - `extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption-parity.test.ts`
  - Per-file coverage thresholds in `extensions/drm-copilot/jest.config.cjs:96-101`
- PowerShell:
  - `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1` (381 lines)
  - `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Parity.Tests.ps1`
  - The pack-manifest membership test `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1:40` also references the module.

**Shared corpus:** `tests/fixtures/orchestrator_state_issue_adoption/`, 29 JSON files (see Numeric Derivation Evidence).

- File format (from the parity reader docstring, `test_orchestrator_state_issue_adoption_parity.py:12-15`):
  - `name`: equals the file stem.
  - `notes`: one sentence.
  - `checkpoint`: a full checkpoint object.
  - `expected_errors`: the complete ordered list returned by the routing contract.
- To add a case, commit one new JSON file. All three readers discover files by glob:
  - Python, line 148: `CORPUS_DIR.glob("*.json")`
  - TypeScript, line 141: `readdirSync`
  - Pester, lines 27-39: `Get-ChildItem -Filter '*.json'`
- Each reader also pins a floor of 29:
  - Python `MINIMUM_CORPUS_COUNT`, line 46
  - TypeScript `MINIMUM_CORPUS_COUNT`, line 42
  - Pester `$minimumFixtureCount`, line 46
- Each reader feeds the checkpoint through the public routing-contract entry point, so every case also exercises the receipt loop:
  - Python `validate_routing_contract` (line 216)
  - TypeScript `validateRoutingContract`
  - Pester `Get-OrchestratorStateRoutingContractError` (module from `.claude/lib/orchestrator-state`, line 49)
- Rule-9 coverage in the corpus today:
  - Only one failing case, `invalid-potential-record.json`: `origin` `transferred`, `potential_record` `notes/record.txt`, expected errors at lines 116-120.
  - Three passing cases use the `promoted/` path: `valid-large-waives-feature-entry-tool-with-record.json:113`, `valid-bug-large-waives-bug-entry-tool-with-record.json:113`, and `bug-waives-feature-entry-tool.json:118`.
  - No case waives a promotion-entry tool with the `potential_record` key absent.

### Q2. Rule-9 design options

**Verified fact on the `promoted/` subfolder.** Path validation is `startswith("docs/features/potential/") and endswith(".md")`:

- Python: lines 240-244
- TypeScript: lines 230-234
- PowerShell: lines 281-285

`docs/features/potential/promoted/<file>.md` is therefore accepted, and the corpus already pins that case (`valid-bug-large-waives-bug-entry-tool-with-record.json:113`). This run's own checkpoint (`artifacts/orchestration/orchestrator-state.json:43-52`) records:

- `origin: filed_before_orchestration`
- `waived_tools: ["potential_to_issue", "new_potential_bug_entry"]`
- `potential_record: docs/features/potential/promoted/2026-10-08-parallel-items-fail-completion-on-promotion-receipts.md`

That record satisfies rule 9 under the current code. No runtime checks that the file exists; the modules are I/O-free by contract (Python docstring lines 26-27, TypeScript lines 20-21, PowerShell lines 21-22).

**Option A: `potential_record` optional for `origin` in {`transferred`, `filed_before_orchestration`}.**

- Proposed semantics:
  - When `origin` is one of those two values and the `potential_record` key is absent, rule 9 reports nothing.
  - When the key is present (including JSON `null`), it must be valid, exactly as today.
  - When `origin` is `epic_decomposition` or invalid, rule 9 is unchanged.
- Runtime changes:
  - Each `_potential_record_errors` / `potentialRecordErrors` / `Get-AdoptionPotentialRecordError` takes the adoption's `origin` and whether the key is present. Python uses `"potential_record" in adoption`; TypeScript uses `hasOwnProperty`; PowerShell uses `Get-CheckpointObjectMember(...).Present`.
  - Each runtime gets one new constant for the origins that do not require a record.
  - No error strings change, so the existing corpus expectations stay byte-identical (`invalid-potential-record.json` still fails because its key is present but invalid).
- Rule doc `.claude/rules/orchestrator-state.md`:
  - Table row, line 246.
  - Rule 9 text, line 258.
  - Optionally a sentence after line 262 stating that the `promoted/` subfolder satisfies the path rule.
- Corpus: new cases (listed under Recommended Approach).

**Option B: keep rule 9 and document that the promoted lifecycle record satisfies it.**

- Change surface: documentation only.
- Does not meet the expected behavior in `issue.md:33` ("the waiver is satisfiable for an issue that has no potential record"). Because the check is syntactic, an author with no record is pushed to cite an unrelated or nonexistent file, which reduces the record's audit value.
- Rejected as a standalone fix. Its clarification sentence is folded into Option A.

**Option C (variants).**

- (C1) Add a file-existence check. Rejected: it introduces filesystem I/O into three modules whose contract is pure, and the TypeScript and PowerShell ports would need injected readers.
- (C2) Drop rule 9 entirely. Rejected: it removes the record requirement for `epic_decomposition`, where epic tooling normally creates a potential record, and widens the waiver more than the issue requires.
- (C3) Have `parallel-planner` write `issue_adoption` into child checkpoints at intake. Rejected: each child's checkpoint lives in that child's own worktree created by the `Agent` spawn, and the planner has no write path to it (see Q4).

### Q3. Skill surfaces

**`.claude/skills/parallel-plan/SKILL.md`**

- `## Item Intake`, "Promotion" bullet (lines 42-44). Add a sibling bullet: issue-number items are adopted, not promoted. Their child records `issue_adoption` instead of calling `potential_to_issue` or the promotion-entry tool.
- `## Preparation Fan-Out` delegation prompt (lines 104-109). Currently the kickoff line plus the model-budget marker line. Add a third prompt line, emitted only for issue-number items, that tells the child to record `issue_adoption`.
- Do not edit the kickoff line itself (line 107):
  - `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1:320` holds a verbatim copy of it.
  - `tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py:115-138` and `:302-315` isolate the blockquoted line that contains `Preparation mode: true.`.
- The hook exemption matches only the two markers (`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1:49-52`; `...-modes.ps1:42`), so an extra line does not change classification.
- Line 111 ("Properties of that line") and line 137 ("Collected per child at termination: ... the promotion receipt (the `issue_num` back-fill source)") need wording that also allows the adoption record.

**`.claude/skills/parallel-orchestrate/SKILL.md`**

- `## Parallel-Mode Kickoff Parameter` says the prompt "carries exactly these five elements" (line 242). Extend element 4 (lines 255-258, the resume-at-atomic-execution instruction) with the adoption instruction rather than adding a sixth element.
- Do not add a `##` heading: `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py:208-222` requires exactly sixteen `##` headings.
- No test pins the element count text (verified: "exactly these five elements" appears only in the skill and its mirror).

**Delegation-prompt target resolution constraints (both prompts)**

- `Find-OrchestrationDelegationIssueNumber` (`.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1:270-273`) takes the first match of `issue(?:[_-]?num(?:ber)?|\s+number)\s*[:=]\s*#?(\d+)`.
- `Find-OrchestrationDelegationTargetFolder` (lines 230-237) uses the longest `docs/features/active/...` token.
- The new instruction text must therefore contain no `issue_num: <digits>`-style literal and no `docs/features/active/` token. Placeholder text without digits is safe.

**`.claude/skills/orchestrate/SKILL.md` lines 442-444**

- Line 444 says the promotion-entry tool may be waived "with a valid `potential_record` under `docs/features/potential/`". Under Option A, update it to say the record is required only for `epic_decomposition` and optional otherwise; a record that is supplied must still be valid.
- No other change is required. The Preparation Mode section (lines 133-141) needs no change because the delegation prompts carry the instruction.

**`.claude/skills/feature-promotion-lifecycle/SKILL.md` line 48**

- Update "and `potential_record` when a promotion-entry tool is waived" to match the same rule.

**Agents**

- `.claude/agents/parallel-planner.md:93-99` and `.claude/agents/parallel-orchestrator.md:160-164, 171-173` defer to the skill-defined prompts and contain no adoption or promotion-receipt text that conflicts. No edit is required.
- `.claude/agents/orchestrator.md:78` describes Preparation mode only. No edit is required.

**Mirrors**

- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` (lines 89-110) requires every distributable `.claude/**` file to be byte-identical under `extensions/drm-copilot/resources/claude-customizations/`. Mirrors exist for all six edited `.claude/**` files (parallel-plan, parallel-orchestrate, orchestrate, feature-promotion-lifecycle skills, the rules file, and the PowerShell module).
- `.agents/skills/orchestrate/SKILL.md:298`, `.agents/skills/feature-promotion-lifecycle/SKILL.md:86`, `.agents/skills/orchestrator-workflow/SKILL.md:208,422`, and `.codex/agents/orchestrator*.toml:160` mention `issue_adoption` but not `potential_record`. They stay accurate under Option A, so no Codex, `.agents`, or `.github` mirror edit is required.
- `.github/skills/feature-promotion-lifecycle/SKILL.md` has no `issue_adoption` text.
- No `.agents/skills/parallel-plan` or `.agents/skills/parallel-orchestrate` file exists.

**Out of scope, recorded:** `.claude/skills/parallel-add/SKILL.md:53-56` reuses the preparation contract "UNCHANGED" and has no literal prompt. Issue #843 edits the adjacent lines 59-62. Admitted issue-number items keep the residual in their preparation child until a follow-up. Their execution child is covered by the parallel-orchestrate change.

### Q4. Does the execution child inherit the preparation checkpoint?

No. The execution child starts a new checkpoint. Evidence:

- `.gitignore:6` ignores `/artifacts`. The per-feature checkpoint `artifacts/orchestration/orchestrator-state.json` is never committed, so it does not travel with the pushed branch.
- `parallel-plan/SKILL.md:145-148`: per-item artifacts on the branch are the feature folder and plan, "pushed to `origin` before its worktree is removed". The preparation worktree, which holds the checkpoint, is removed.
- `parallel-orchestrate/SKILL.md:217-219`: each item's worktree "is created by that item's delegation spawn, `Agent(orchestrator, isolation: "worktree", ...)`". This is a new worktree.
- `parallel-orchestrate/SKILL.md:237`: "each item's checkpoint lives in that item's worktree".
- `parallel-orchestrate/SKILL.md:244-259`: the five prompt elements carry no portable prepared-state envelope. The handoff intake in `orchestrate/SKILL.md:38-78` is therefore not triggered.
- `orchestrate/SKILL.md:33-35`: with no checkpoint, the child "begin[s] the orchestration lifecycle from the start" and selects `small` or `large`. Both require `new_potential_entry` (bug: `new_potential_bug_entry`) and `potential_to_issue` (`config/orchestration-routing.json:26-32, 53-59`).

Consequences:

- An adoption recorded at preparation does not carry forward. The execution child must record its own.
- At execution time every item's issue already exists, because the manifest is fully resolved before kickoff (`parallel-plan/SKILL.md:51-52`). Execution children should always record adoption, with `origin: filed_before_orchestration` unless the issue was transferred.

### Q5. Overlapping issues

Neither issue could be read with `gh issue view` because no shell tool is available in this session. Both were read from the public issue pages with WebFetch.

- **#798** (open, "orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails"):
  - Documents the `last_updated` key in `.claude/rules/orchestrator-state.md`.
  - Notes that `last_updated` is in `REQUIRED_STATE_KEYS` in `scripts/dev_tools/validate_orchestrator_state.py` (cited near line 63).
  - Makes `scripts/dev_tools/validate_orchestration_artifacts.py` invocable by file path.
  - This fix does not need to edit `validate_orchestrator_state.py`. Its rule-doc edits are limited to lines 246, 258 and an optional sentence near 262, which is not the required-keys area. Expected conflict: none or trivial.
- **#843** (open, "parallel-model-routing-admitted-item-source-and-absent-band-test"):
  - Edits `parallel-orchestrate/SKILL.md` lines 265-271 and 312-319 (band source for admitted items).
  - Edits `parallel-add/SKILL.md` lines 59-62.
  - Adds tests to `test_validate_parallel_planner_state_routing.py` and `parallel-planner-state-routing.test.ts`.
  - This fix edits parallel-orchestrate lines 255-258 only. Lines 259-264 stay unchanged between the two hunks, so the conflict should be resolvable automatically. Avoid editing parallel-add.

### Q6. Toolchain commands

Python (run from the worktree root):

- `poetry run black .`
- `poetry run ruff check .`
- `poetry run pyright`
- Targeted tests:
  - `poetry run pytest tests/scripts/dev_tools/test_orchestrator_state_issue_adoption.py tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py tests/scripts/dev_tools/test_validate_orchestrator_state_issue_adoption.py tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py`
- Module coverage (dotted form):
  - `poetry run pytest tests/scripts/dev_tools/test_orchestrator_state_issue_adoption.py tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py tests/scripts/dev_tools/test_validate_orchestrator_state_issue_adoption.py tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py --cov=scripts.dev_tools._orchestrator_state_issue_adoption --cov-branch --cov-report=term-missing --cov-report=json:<FEATURE>/evidence/<kind>/py-adoption-coverage.json`
- Full suite:
  - `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=json:<FEATURE>/evidence/<kind>/py-full-coverage.json`
- These forms match the #509 evidence (`docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/qa-gates/rem1-py-adoption-coverage.2026-10-01T16-42.md:6`).
- Skill and mirror contract tests:
  - `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py tests/scripts/dev_tools/test_parallel_kickoff_template_seam.py`

TypeScript (scripts in `extensions/drm-copilot/package.json:207-213`):

- `npm --prefix extensions/drm-copilot run format`
- `npm --prefix extensions/drm-copilot run lint`
- `npm --prefix extensions/drm-copilot run typecheck`
- `npm --prefix extensions/drm-copilot run test:unit -- test/lib/validate`
- Coverage: `npm --prefix extensions/drm-copilot run test:coverage -- --coverageReporters=text`. Per-file thresholds are enforced from `jest.config.cjs:96-101`.

PowerShell:

- `mcp__drm-copilot__run_poshqc_format`
- `mcp__drm-copilot__run_poshqc_analyze`
- `mcp__drm-copilot__run_poshqc_test`, with `scan_folders` including `tests/scripts/claude-lib/orchestrator-state`, `tests/scripts/claude-hooks`, and `tests/scripts/claude-runtime`.
  - Settings: `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`.
  - Coverage output: `artifacts/pester/powershell-coverage.xml` (line 22). The coverage population is derived from `config/poshqc-coverage.json` (lines 23-24).
- The MCP test summary does not carry per-test output. Any count or coverage figure the plan asserts must be read from the JUnit or coverage XML files, not from the MCP summary.

### Q7. Files a fix would write

See `## Files To Change`.

## Recommended Approach

1. **Rule 9 relaxation (Option A) in all three runtimes.**
   - Add the constant `RECORD_OPTIONAL_ORIGINS = {"transferred", "filed_before_orchestration"}`.
   - In rule 9, report nothing when the adoption's `origin` is in that set and the `potential_record` key is absent.
   - A present key (any value, including `null`) is validated exactly as today. `epic_decomposition` and invalid origins keep the current requirement.
   - Error strings, rule order, and fail-closed behavior are unchanged.
   - Each runtime update is about 10-15 lines. Python is 326 lines, TypeScript 296, PowerShell 376, all within the 500-line limit.
2. **Rule doc update** in `.claude/rules/orchestrator-state.md` (and its mirror):
   - Table row at line 246 and rule 9 at line 258: describe the origin-conditional requirement.
   - Add one sentence stating that a lifecycle record moved to `docs/features/potential/promoted/` satisfies the path rule.
3. **Corpus additions.** Five new files in `tests/fixtures/orchestrator_state_issue_adoption/`:
   - `valid-bug-preparation-filed-before-orchestration-without-record.json`: preparation route, `promotion-type: bug`, waives `potential_to_issue` and `new_potential_bug_entry` with no record key. `expected_errors: []`. This is the direct parallel-preparation scenario and the expect-fail regression.
   - `valid-bug-large-filed-before-orchestration-without-record.json`: large route, bug. `expected_errors: []`.
   - `valid-large-transferred-waives-feature-entry-tool-without-record.json`: large route, feature. `expected_errors: []`.
   - `epic-decomposition-waives-entry-tool-without-record.json`: feature, `origin: epic_decomposition`, no record. Expected errors in order:
     1. `Checkpoint missing successful MCP receipt: new_potential_entry.`
     2. `Checkpoint missing successful MCP receipt: potential_to_issue.`
     3. The rule-9 error for `new_potential_entry`.
   - `filed-before-orchestration-invalid-present-record.json`: `origin: filed_before_orchestration`, `potential_record: "notes/record.txt"`. Expected errors are the same three-error shape as `invalid-potential-record.json`.
   - Raise the three corpus floors (Python line 46, TypeScript line 42, Pester line 46) from 29 to 34.
4. **Unit tests per runtime** for the new branch: absent and allowed origin; absent and `epic_decomposition`; present-null with an allowed origin.
   - Python: add to `test_orchestrator_state_issue_adoption_waivers.py` (178 lines). The main test file is already at 463 lines.
   - TypeScript: add a new file `extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption-origin.test.ts`. The existing file is at 478 lines.
   - PowerShell: add to `OrchestratorStateIssueAdoption.Tests.ps1` (381 lines).
   - The existing 96-case grids are unaffected because they always pass `VALID_RECORD`.
5. **Skill instructions.**
   - `parallel-plan/SKILL.md`:
     - Add an intake bullet: issue-number items are adopted.
     - Add a conditional third prompt line for issue-number items, emitted after the model-budget marker. Suggested text: "Issue adoption: this item's GitHub issue already exists. Verify it read-only (gh issue view), do not call potential_to_issue or the promotion-entry tool, and record a top-level issue_adoption object in the checkpoint per .claude/rules/orchestrator-state.md, waiving potential_to_issue and the promotion-entry tool for the checkpoint's promotion-type."
     - Update the per-child collection sentence at line 137.
   - `parallel-orchestrate/SKILL.md`: extend element 4 with the same instruction and a statement that the preparation checkpoint does not carry over.
   - Both texts must avoid digit-bearing `issue_num:` literals and `docs/features/active/` tokens (Q3 constraints).
   - Update the `potential_record` wording in `orchestrate/SKILL.md:444` and `feature-promotion-lifecycle/SKILL.md:48`.
6. **Skill regression test.** Add a new Python contract test, `tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py`, asserting:
   - Each skill's prompt section carries `issue_adoption` and `potential_to_issue`.
   - The added parallel-plan line contains neither `Epic mode: true` nor `Parallel mode: true`.
   - Neither added text matches the hook's keyed issue-number regex with digits.
   Section extraction reuses the helpers in `tests/scripts/dev_tools/parallel_orchestrator_surface_test_support.py`. This test fails before the skill edits.
7. **Mirror** every `.claude/**` edit byte-identically under `extensions/drm-copilot/resources/claude-customizations/`.

Rationale: Option A is the only option that makes the waiver work for issues with no record (`issue.md:33`) without adding I/O. It keeps every existing error string and corpus expectation unchanged and leaves `epic_decomposition` as strict as before. The skill change addresses the primary cause; without it, the relaxed rule would never be exercised by parallel children.

Rejected alternatives (summary): Option B (documentation only; does not cover issues with no record); C1 (existence check; adds I/O to pure modules); C2 (drop rule 9; widens the waiver more than the issue requires); C3 (planner-written adoption; the planner cannot write child checkpoints); a sixth kickoff element or a new `##` heading (breaks `test_parallel_orchestrator_surface_contracts.py:216`).

## Files To Change

scripts/dev_tools/_orchestrator_state_issue_adoption.py
extensions/drm-copilot/src/lib/validate/orchestrator-state-issue-adoption.ts
.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1
.claude/rules/orchestrator-state.md
extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md
.claude/skills/parallel-plan/SKILL.md
extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md
.claude/skills/parallel-orchestrate/SKILL.md
extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md
.claude/skills/orchestrate/SKILL.md
extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md
.claude/skills/feature-promotion-lifecycle/SKILL.md
extensions/drm-copilot/resources/claude-customizations/.claude/skills/feature-promotion-lifecycle/SKILL.md
tests/fixtures/orchestrator_state_issue_adoption/valid-bug-preparation-filed-before-orchestration-without-record.json
tests/fixtures/orchestrator_state_issue_adoption/valid-bug-large-filed-before-orchestration-without-record.json
tests/fixtures/orchestrator_state_issue_adoption/valid-large-transferred-waives-feature-entry-tool-without-record.json
tests/fixtures/orchestrator_state_issue_adoption/epic-decomposition-waives-entry-tool-without-record.json
tests/fixtures/orchestrator_state_issue_adoption/filed-before-orchestration-invalid-present-record.json
tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py
tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py
tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py
extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption-origin.test.ts
extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption-parity.test.ts
tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1
tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Parity.Tests.ps1

Files deliberately not changed: `scripts/dev_tools/validate_orchestrator_state.py` (overlap with #798), `scripts/dev_tools/_orchestrator_state_routing.py`, `extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts`, `.claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1` (the receipt loop already honors waivers), `.claude/skills/parallel-add/SKILL.md` (overlap with #843), `.claude/agents/*.md`, `.agents/**`, `.codex/**`, `.github/**`, `config/orchestration-routing.json`, `extensions/drm-copilot/jest.config.cjs`.

## Numeric Derivation Evidence

### Claim N1: the issue-adoption corpus currently holds 29 cases (baseline for raising the floor to 34)

- **Complete Family:** every corpus case consumed by the three parity readers, which is every `*.json` file directly under `tests/fixtures/orchestrator_state_issue_adoption/`.
- **Exhaustive Search Scope:** the whole directory `tests/fixtures/orchestrator_state_issue_adoption/` (non-recursive, matching the readers' globs).
- **Inclusion Rules:** a file with suffix `.json` in that directory.
- **Exclusion Rules:** none. The directory holds no non-JSON files, and no reader filters by content.
- **Primary Search Strategy or Query Expression:** Glob `tests/fixtures/orchestrator_state_issue_adoption/*` (file-name enumeration).
- **Primary Member Set:** absent-key-large-missing-receipt, adoption-error-precedes-local-execution-overrides, blank-evidence, blank-verified-at, bug-waives-feature-entry-tool, case-variant-tool-name, declared-list-omits-potential-to-issue, duplicate-waived-tool, empty-waived-tools, integer-issue-num, invalid-potential-record, issue-num-mismatch, issue-url-mismatch, leading-zero-issue-num, multiple-field-errors-in-rule-order, non-list-waived-tools, non-object-adoption-string, null-adoption, remediation-route-adoption, unknown-origin, unknown-verified-via, valid-bug-large-waives-bug-entry-tool-with-record, valid-large-waives-feature-entry-tool-with-record, valid-large-waives-potential-to-issue, valid-preparation-waives-potential-to-issue, waived-tools-omits-potential-to-issue, waives-new-active-feature-folder, waives-tool-with-successful-receipt, waives-validate-orchestration-artifacts.
- **Primary Count:** 29.
- **Cross-check Search Strategy or Query Expression:** content Grep for the regex `^  "name": ` over the same directory (each fixture's top-level `name` value, which the readers require to equal the file stem).
- **Cross-check Member Set:** the 29 `name` values returned, which are identical strings to the primary member set (for example `"name": "waives-validate-orchestration-artifacts"` through `"name": "invalid-potential-record"`).
- **Cross-check Count:** 29.
- **Member-set Comparison:** after normalizing each primary file name by stripping `.json`, the two sets are identical: 29 = 29, no member missing from either side, no duplicates. The count also matches the floor of 29 in all three readers (Python line 46, TypeScript line 42, Pester line 46).

### Claim N2: proposed corpus size after the fix is 34

- **Complete Family:** the N1 set plus the five new fixtures enumerated under Recommended Approach step 3.
- **Exhaustive Search Scope:** same directory as N1.
- **Inclusion Rules:** the 29 N1 members plus the five named new files.
- **Exclusion Rules:** none.
- **Primary Search Strategy or Query Expression:** arithmetic over enumerated members (29 baseline + 5 named additions).
- **Primary Member Set:** N1 members plus valid-bug-preparation-filed-before-orchestration-without-record, valid-bug-large-filed-before-orchestration-without-record, valid-large-transferred-waives-feature-entry-tool-without-record, epic-decomposition-waives-entry-tool-without-record, filed-before-orchestration-invalid-present-record.
- **Primary Count:** 34.
- **Cross-check Search Strategy or Query Expression:** after implementation, repeat both N1 strategies (Glob and `^  "name": ` Grep). This is a planned post-change cross-check, not one already performed.
- **Cross-check Member Set:** not yet available; the files do not exist.
- **Cross-check Count:** not yet available.
- **Member-set Comparison:** pending. The number 34 must not be written into an approved acceptance criterion until the post-change Glob and Grep both return 34 identical members. Until then, word the criterion as "each reader's floor equals the post-change corpus file count".

## Risks

- **Waiver widening.** Option A lets a `transferred` or `filed_before_orchestration` adoption waive the promotion-entry receipt with no record. The waiver is a declaration, not a proof (rule doc line 231), so this does not change the security posture. It does remove one audit pointer. Mitigation: the skill text should still ask for a `potential_record` when a `promoted/` file exists for the item.
- **Three-runtime drift.** All three runtimes must change together. The shared corpus is the binding check: any drift fails at least one parity suite.
- **Prompt-parsing hooks.** Added prompt text could change hook target resolution if it contains `issue_num: <digits>` or a `docs/features/active/` token (`enforce-orchestration-preimplementation-gate-modes.ps1:230,270`). The proposed skill contract test pins this.
- **Mirror omission.** Missing one of the six mirror copies fails `test_bundled_claude_payload_contains_all_repo_runtime_contracts`.
- **Merge conflicts.**
  - #843 edits nearby lines in `parallel-orchestrate/SKILL.md` (265-271).
  - #798 edits `.claude/rules/orchestrator-state.md` in a different section.
  - Whichever merges second needs to rebase onto `main`.
- **Admission path residual.** `/parallel-add` preparation children for issue-number items are not covered by this change. Record a follow-up.
- **File-size limits.** The Python main test file (463 lines) and the TypeScript unit test file (478 lines) are close to the 500-line limit. Place new tests as recommended.

## Assumptions

- The intended scope of relaxation is `transferred` and `filed_before_orchestration` only, as `issue.md:68` proposes. `epic_decomposition` keeps the requirement.
- A present `potential_record` key, including `null`, is validated as today. This matches how a present `issue_adoption: null` is already rejected (rule 1).
- Execution children should use `origin: filed_before_orchestration` for issues their own preparation child promoted. The issue existed before the execution orchestration began.
- #798 and #843 content is taken from the public issue pages via WebFetch (no `gh` access in this session); line ranges are as stated in those issues.
- No new MCP tool, routing-matrix change, or schema file is required.

## Automation Feasibility

All work is file edits, fixture authoring, and toolchain runs: Poetry/pytest, npm/Jest, and the PoshQC MCP tools. None of it requires human UI interaction. Evidence artifacts go to `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/<kind>/`.
