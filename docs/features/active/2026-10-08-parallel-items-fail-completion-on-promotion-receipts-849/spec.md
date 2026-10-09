# Spec: parallel-items-fail-completion-on-promotion-receipts (Issue #849)

- Issue: #849
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/849
- Branch: bug/parallel-items-fail-completion-on-promotion-receipts-849
- Work Mode: full-bug (acceptance criteria source: this file only)
- Research: `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/research/research.2026-10-09T05-40.md`
- Date: 2026-10-09

## Problem Statement

In parallel run bug-burndown-2026-09-29, child orchestrators for items whose GitHub issue existed before the run (#647, #734, #532, #338; the run notes also name #623 and #739 as the same class) failed the completion validator with `Checkpoint missing successful MCP receipt: new_potential_bug_entry.` and `Checkpoint missing successful MCP receipt: potential_to_issue.`. The `issue_adoption` waiver added by #509 (PR #809) exists in all three validator runtimes, but parallel-run children do not use it, and for an issue with no potential record the waiver cannot be satisfied for the promotion-entry tool. Coordinators currently classify this residual by hand on every item, which hides real receipt gaps in the same output.

## Root Cause

1. **Skill gap (primary).** `.claude/skills/parallel-plan/SKILL.md` (preparation fan-out) and `.claude/skills/parallel-orchestrate/SKILL.md` (execution kickoff) contain no instruction to record `issue_adoption`. The execution child starts a new checkpoint in a new worktree (`/artifacts` is gitignored and the preparation worktree is removed), so an adoption recorded at preparation would not reach execution even if one were recorded.
2. **Rule-9 gap (secondary).** Rule 9 of the adoption resolver requires a `potential_record` string that starts with `docs/features/potential/` and ends with `.md` whenever a promotion-entry tool (`new_potential_entry` / `new_potential_bug_entry`) is waived. The check ignores `origin`. An issue filed by hand or consolidated from other issues (for example #734) has no record, so the only way to pass is to cite a file that is not that issue's record.

## Scope

In scope:

- Relax rule 9 in the Python authority, the TypeScript port, and the PowerShell port so that the `potential_record` key may be absent when `origin` is `transferred` or `filed_before_orchestration`.
- Shared corpus cases under `tests/fixtures/orchestrator_state_issue_adoption/` covering the relaxed and unchanged behaviors, consumed by all three parity readers.
- Unit tests per runtime for the new branch.
- `issue_adoption` instructions in the `parallel-plan` preparation delegation and the `parallel-orchestrate` execution kickoff.
- One-sentence wording updates in `.claude/skills/orchestrate/SKILL.md`, `.claude/skills/feature-promotion-lifecycle/SKILL.md`, and `.claude/rules/orchestrator-state.md` (a repo-owned contract doc that documents the waiver; not a `.github/instructions` policy file).
- Byte-identical bundled mirrors under `extensions/drm-copilot/resources/claude-customizations/` for every edited `.claude/**` file.
- A Python skill-contract test that pins the new skill instructions.

## Out of Scope

- `.claude/skills/parallel-add/SKILL.md`. Admitted issue-number items keep the residual in their preparation child until a follow-up; their execution child is covered by the `parallel-orchestrate` change. Issue #843 edits adjacent lines in that file. Record a follow-up item for this residual.
- `scripts/dev_tools/validate_orchestrator_state.py` (overlaps #798, which edits required-keys documentation and invocation).
- Routing-contract callers (`_orchestrator_state_routing.py`, `orchestrator-state-routing.ts`, `OrchestratorStateRoutingContract.psm1`); the receipt loop already skips waived tools.
- `config/orchestration-routing.json`, `extensions/drm-copilot/jest.config.cjs`, `.claude/agents/*.md`, `.agents/**`, `.codex/**`, `.github/**`. Their existing text stays accurate under the relaxed rule.
- A file-existence check for `potential_record` (would add I/O to modules whose contract is pure).
- Planner-written adoption at intake (the planner has no write path into child checkpoints).

### Overlap Notes

- **#798:** edits `.claude/rules/orchestrator-state.md` in the required-keys area and `validate_orchestrator_state.py`. This change edits only the adoption table row and rule 9 text in the rule doc and does not touch `validate_orchestrator_state.py`. Expected conflict: none or trivial; whichever merges second rebases onto `main`.
- **#843:** edits `parallel-orchestrate/SKILL.md` around the model-band lines and `parallel-add/SKILL.md`. This change edits only kickoff element 4 in `parallel-orchestrate/SKILL.md` and does not edit `parallel-add`. Expected conflict: resolvable automatically.

## Design

### Validation rule (all runtimes)

- Add a constant naming the origins for which a record is optional: `transferred`, `filed_before_orchestration`.
- Rule 9 receives the adoption's `origin` and whether the `potential_record` key is present.
- When `origin` is in the optional set and the key is absent, rule 9 reports no errors.
- When the key is present (any value, including JSON `null`), it is validated exactly as today.
- When `origin` is `epic_decomposition` or invalid, rule 9 is unchanged.
- Error strings, rule order, the rule-8 shape-check precondition, and fail-closed behavior (any error empties `waived_tools`) are unchanged.

### Python

- `scripts/dev_tools/_orchestrator_state_issue_adoption.py`: add `RECORD_OPTIONAL_ORIGINS`; extend `_potential_record_errors` to accept origin and key presence (`"potential_record" in adoption`); update the call site in `resolve_issue_adoption`.
- Tests: new cases in `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py` (the main test file is near the 500-line limit); corpus floor in `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py` raised to the post-change corpus file count.

### TypeScript

- `extensions/drm-copilot/src/lib/validate/orchestrator-state-issue-adoption.ts`: equivalent constant; `potentialRecordErrors` takes origin and key presence (`Object.prototype.hasOwnProperty.call`); update the call in `resolveIssueAdoption`.
- Tests: new file `extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption-origin.test.ts` (the existing unit file is near the 500-line limit); corpus floor in `orchestrator-state-issue-adoption-parity.test.ts` raised to the post-change corpus file count.

### PowerShell

- `.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1`: equivalent constant; `Get-AdoptionPotentialRecordError` takes origin and key presence (`Get-CheckpointObjectMember(...).Present`); update the call in `Get-OrchestratorStateIssueAdoptionResult`. Exported surface unchanged. Mirror byte-identically under the bundled resources path.
- Tests: new cases in `OrchestratorStateIssueAdoption.Tests.ps1`; corpus floor in `OrchestratorStateIssueAdoption.Parity.Tests.ps1` raised to the post-change corpus file count.

### Shared corpus

New fixtures in `tests/fixtures/orchestrator_state_issue_adoption/`, each with `name` equal to the file stem, a one-sentence `notes`, a full `checkpoint`, and the complete ordered `expected_errors`:

- `valid-bug-preparation-filed-before-orchestration-without-record.json`: preparation route, `promotion-type: bug`, `origin: filed_before_orchestration`, waives `potential_to_issue` and `new_potential_bug_entry`, no `potential_record` key; `expected_errors: []`. This is the parallel-preparation regression case.
- `valid-bug-large-filed-before-orchestration-without-record.json`: large route, bug, no record key; `expected_errors: []`.
- `valid-large-transferred-waives-feature-entry-tool-without-record.json`: large route, feature, `origin: transferred`, no record key; `expected_errors: []`.
- `epic-decomposition-waives-entry-tool-without-record.json`: feature, `origin: epic_decomposition`, no record key; expected errors are the missing-receipt errors for `new_potential_entry` and `potential_to_issue` followed by the rule-9 error for `new_potential_entry`.
- `filed-before-orchestration-invalid-present-record.json`: `origin: filed_before_orchestration`, `potential_record: "notes/record.txt"`; expected errors match the shape of `invalid-potential-record.json`.

The corpus floor in each reader is set to the corpus file count re-counted after the fixtures are added (by both a file-name enumeration and a `"name"` content search that agree on the member set).

### Skills and rule doc

- `parallel-plan/SKILL.md`:
  - `## Item Intake`: add a bullet stating that issue-number items are adopted, not promoted.
  - `## Preparation Fan-Out`: add a third delegation-prompt line, emitted only for issue-number items after the model-budget marker, instructing the child to verify the issue read-only, not call `potential_to_issue` or the promotion-entry tool, and record a top-level `issue_adoption` object per `.claude/rules/orchestrator-state.md` waiving `potential_to_issue` and the promotion-entry tool for the checkpoint's `promotion-type`. The kickoff line itself is not edited.
  - Update the per-child collection sentence so the adoption record is an accepted alternative to the promotion receipt as the `issue_num` source.
- `parallel-orchestrate/SKILL.md`: extend kickoff element 4 with the same adoption instruction and a statement that the preparation checkpoint does not carry over. No new element and no new `##` heading.
- Prompt-text constraints (both skills): no `issue_num: <digits>`-style literal, no `docs/features/active/` token, and the added `parallel-plan` line contains neither `Epic mode: true` nor `Parallel mode: true`, so hook target resolution and mode classification are unchanged.
- Where a lifecycle record exists for the item under `docs/features/potential/promoted/`, the skill text asks the child to cite it as `potential_record`.
- `orchestrate/SKILL.md` and `feature-promotion-lifecycle/SKILL.md`: one-sentence update stating that `potential_record` is required for `epic_decomposition`, optional for `transferred` and `filed_before_orchestration`, and validated whenever supplied.
- `.claude/rules/orchestrator-state.md`: update the adoption table row and rule 9 to the origin-conditional requirement; add one sentence stating that a record under `docs/features/potential/promoted/` satisfies the path rule.

## Acceptance Criteria

- [ ] AC-1: Python `resolve_issue_adoption` returns no errors and returns the declared `waived_tools` when `origin` is `transferred` or `filed_before_orchestration`, a promotion-entry tool is waived, and the `potential_record` key is absent. Verified by new tests in `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py`.
- [ ] AC-2: TypeScript `resolveIssueAdoption` has the AC-1 behavior. Verified by `extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption-origin.test.ts`.
- [ ] AC-3: PowerShell `Get-OrchestratorStateIssueAdoptionResult` has the AC-1 behavior. Verified by new cases in `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1`.
- [ ] AC-4: In all three runtimes, `origin: epic_decomposition` with a waived promotion-entry tool and no `potential_record` key still produces the existing rule-9 error and an empty `waived_tools`. Verified by the per-runtime unit tests and by corpus fixture `epic-decomposition-waives-entry-tool-without-record.json`.
- [ ] AC-5: In all three runtimes, a present `potential_record` (including JSON `null` and an invalid path such as `notes/record.txt`) with `origin` `transferred` or `filed_before_orchestration` is validated as before and produces the existing rule-9 error. Verified by the per-runtime unit tests and by corpus fixture `filed-before-orchestration-invalid-present-record.json`.
- [ ] AC-6: Corpus fixtures `valid-bug-preparation-filed-before-orchestration-without-record.json`, `valid-bug-large-filed-before-orchestration-without-record.json`, `valid-large-transferred-waives-feature-entry-tool-without-record.json`, `epic-decomposition-waives-entry-tool-without-record.json`, and `filed-before-orchestration-invalid-present-record.json` exist under `tests/fixtures/orchestrator_state_issue_adoption/`, and the Python, TypeScript, and Pester parity suites pass on every corpus file.
- [ ] AC-7: Regression evidence: before the validator change, the parity case for `valid-bug-preparation-filed-before-orchestration-without-record.json` fails in at least the Python parity suite with the rule-9 error for `new_potential_bug_entry` (and the missing-receipt errors); after the change it passes in all three parity suites. The failing and passing runs are recorded under the feature `evidence/` folder.
- [ ] AC-8: Every corpus fixture present at the merge-base of the branch and origin/main recorded at Phase 0 as `BASE_SHA` is byte-unchanged (no diff under `tests/fixtures/orchestrator_state_issue_adoption/` other than added files), and no validator error string changes in any runtime.
- [ ] AC-9: Each parity reader's minimum corpus floor (Python `MINIMUM_CORPUS_COUNT`, TypeScript `MINIMUM_CORPUS_COUNT`, Pester `$minimumFixtureCount`) equals the corpus file count re-counted after the change, with the re-count recorded in evidence using a file-name enumeration and a `"name"` content search whose member sets are compared.
- [ ] AC-10: `.claude/skills/parallel-plan/SKILL.md` contains, in `## Item Intake`, a bullet stating that issue-number items are adopted, and, in `## Preparation Fan-Out`, a delegation-prompt line for issue-number items that names `issue_adoption` and `potential_to_issue`; the existing kickoff line is unchanged. Verified by `tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py`, which fails before the skill edit.
- [ ] AC-11: `.claude/skills/parallel-orchestrate/SKILL.md` kickoff element 4 instructs the execution child to record `issue_adoption` (naming `potential_to_issue`) and states that the preparation checkpoint does not carry over; no kickoff element or `##` heading is added. Verified by `tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py` and by `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` passing.
- [ ] AC-12: Neither added skill text matches the hook issue-number regex `issue(?:[_-]?num(?:ber)?|\s+number)\s*[:=]\s*#?(\d+)` or contains a `docs/features/active/` token, and the added `parallel-plan` line contains neither `Epic mode: true` nor `Parallel mode: true`. Verified by `tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py`; `tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py`, `tests/scripts/dev_tools/test_parallel_kickoff_template_seam.py`, and `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` pass unchanged.
- [ ] AC-13: `.claude/rules/orchestrator-state.md` describes `potential_record` as required for `epic_decomposition`, optional for `transferred` and `filed_before_orchestration`, and validated whenever present, and states that a record under `docs/features/potential/promoted/` satisfies the path rule. Verified by file observation.
- [ ] AC-14: `.claude/skills/orchestrate/SKILL.md` and `.claude/skills/feature-promotion-lifecycle/SKILL.md` state the same origin-conditional `potential_record` requirement as AC-13. Verified by file observation.
- [ ] AC-15: Every edited `.claude/**` file has a byte-identical copy under `extensions/drm-copilot/resources/claude-customizations/`, and `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes.
- [ ] AC-16: Python toolchain is clean: `black`, `ruff`, `pyright` report no errors; the targeted and full pytest suites pass; line coverage >= 85% and branch coverage >= 75% for `scripts.dev_tools._orchestrator_state_issue_adoption`, with no coverage regression on changed lines. Evidence recorded under the feature `evidence/` folder.
- [ ] AC-17: TypeScript toolchain is clean: `format`, `lint`, `typecheck`, and `test:unit` pass in `extensions/drm-copilot`; `test:coverage` passes its per-file thresholds with line coverage >= 85% and branch coverage >= 75% for `orchestrator-state-issue-adoption.ts`, with no coverage regression on changed lines. Evidence recorded under the feature `evidence/` folder.
- [ ] AC-18: PowerShell toolchain is clean: PoshQC format and analyze report no findings on changed files; Pester suites under `tests/scripts/claude-lib/orchestrator-state`, `tests/scripts/claude-hooks`, and `tests/scripts/claude-runtime` pass; line coverage >= 85% for `OrchestratorStateIssueAdoption.psm1` with no regression on changed lines, read from the JUnit and coverage XML files rather than the MCP summary. Evidence recorded under the feature `evidence/` folder.

## Assumptions

- **Work-mode downgrade.** The requested `minor-audit` mode was downgraded to `full-bug` because the change spans four or more production files across three runtimes (Python, TypeScript, PowerShell) and `issue.md` has no `## Acceptance Criteria` section. Under `full-bug`, this `spec.md` is the sole acceptance-criteria source and no `user-story.md` is produced.
- **No clarifying questions.** The operator directed that no questions be asked; open design points are resolved by the research Recommended Approach (Option A).
- **Adoption is recorded by each child.** Both the preparation child and the execution child record their own `issue_adoption`, because the execution child starts a fresh checkpoint in a new worktree and the preparation checkpoint (gitignored, in a removed worktree) does not carry over. Execution children use `origin: filed_before_orchestration` unless the issue was transferred.
- The relaxation applies only to `transferred` and `filed_before_orchestration`; `epic_decomposition` keeps the record requirement.
- A present `potential_record` key, including `null`, is validated as today, consistent with rule 1 rejecting a present `issue_adoption: null`.
- #798 and #843 scope was taken from the public issue pages during research; line ranges are as stated there.
- No new MCP tool, routing-matrix change, or schema file is required.

## Risks

- Waiver widening: a `transferred` or `filed_before_orchestration` adoption may waive the promotion-entry receipt with no record, removing one audit pointer. The waiver remains a declaration; the skill text asks for a record when one exists under `promoted/`.
- Three-runtime drift: mitigated by the shared corpus, which fails at least one parity suite on any divergence.
- Prompt-parsing hooks: mitigated by AC-12.
- Mirror omission: mitigated by AC-15.
- File-size limits: new tests are placed in files with headroom below 500 lines.

## Files To Change

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
