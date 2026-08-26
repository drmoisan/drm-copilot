# preimplementation-gate-blocks-epic-execution (Atomic Plan)

- **Issue:** #554
- **Work Mode:** `full-bug`
- **Owner:** drmoisan
- **Last Updated:** 2026-08-26T08-40 (revision 2, applying the preflight delta set R1 through R13)
- **Status:** Ready for preflight
- **Version:** 1.1
- **Plan path (canonical, updated in place):** `docs/features/active/preimplementation-gate-blocks-epic-execution-554/plan.2026-08-26T08-40.md`

## Requirements Source

`docs/features/active/preimplementation-gate-blocks-epic-execution-554/spec.md` is the **sole**
authoritative acceptance-criteria source for this feature (work mode `full-bug`). `issue.md` carries
the issue body and the precedence note and is a pointer, not a second source. `user-story.md` is
deliberately absent and its absence is justified in the spec; its absence is **not** a blocker and
this plan does not require it.

Every design decision cited below as D1 through D8 is settled in the spec. This plan implements those
decisions and does not re-open them.

## Path Conventions Used in This Document

- `${feature-folder}` denotes `docs/features/active/preimplementation-gate-blocks-epic-execution-554`.
- All evidence artifacts resolve to `${feature-folder}/evidence/<kind>/` per the non-overridable
  evidence-path clause in `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. No artifact
  is written under `artifacts/baselines/`, `artifacts/baseline/`, `artifacts/qa/`,
  `artifacts/qa-gates/`, `artifacts/coverage/`, or `artifacts/evidence/`.
- `<timestamp>` in an artifact filename is the ISO-8601 `yyyy-MM-ddTHH-mm` value at the moment the
  artifact is written.
- Inside an acceptance command, concrete repository-relative paths are written literally. The
  `${feature-folder}` spelling is used in prose only.

## Change Budget and Batch Sequencing (decision D6)

`.claude/rules/powershell.md` caps direct-mode overall scope at **2 production PowerShell files** and
caps any batch at **3 production files and 3 test files**. The spec fixes the logical production
count at **3 units** — the `.claude` main gate hook, the `.codex` main gate hook, and the new modes
sibling — realized as 8 physical `.ps1` files once the two bundled mirror trees are counted.

**Explicit treatment statement, required by decision D6 and by a spec acceptance criterion:** each
file under `extensions/drm-copilot/resources/` written by this change is treated as a **mechanical
byte-copy** of an already-reviewed source file, not as an independent production edit. No logic is
authored in any `extensions/drm-copilot/resources/` file. The four mirrored `.ps1` files are produced
by copying their reviewed self-hosted source and are then proved byte-identical by SHA-256; the
bundled `pester.runsettings.psd1` is a text-parity copy pinned by a Python test; the two
`pack-manifests/core.json` files are registration manifests, not production PowerShell. That
treatment is what keeps the logical production count at 3 rather than 8, and it is stated here rather
than assumed because an unstated assumption is indistinguishable from a budget breach at review time.

Batch sequencing, each batch at or under the per-batch cap:

- **Batch A (Phase 2)** — production: the new modes sibling, 1 logical unit realized as the two
  self-hosted files `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` and
  `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`. Test files: 1
  (`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`).
- **Batch B (Phase 3)** — production: 2 logical units, the `.claude` main gate hook and the `.codex`
  main gate hook. Test files: 2 (the Claude mode-resolution suite and the new Codex mode-resolution
  suite).
- **Batch C (Phase 4)** — production: 0 new logic. Four mechanical byte-copies into
  `extensions/drm-copilot/resources/`, plus two coverage-settings files and two pack manifests, all
  under the treatment stated above. Six of those files are `.ps1` or `.psd1` and therefore count
  against the per-batch budget, so Batch C is split by a second counter reset placed at the head of
  P4-T4: P4-T1 through P4-T3 form the first three-file group, and P4-T4 through P4-T6 form the
  second. The two `pack-manifests/core.json` files are JSON and are not counted by the hook.

**Batch-budget counter reset (operational, required).** `.claude/hooks/enforce-powershell-batch-budget.ps1`
is registered on the `Write|Edit` PreToolUse matcher and counts every `.ps1`, `.psm1`, and `.psd1`
write against a session-scoped cap of 3 production and 3 test files. It classifies a file as a test
only when its path matches a `tests/` prefix or a `.Tests.ps1` suffix, so both
`pester.runsettings.psd1` copies count as PRODUCTION. Cumulative production writes across this plan
are the 8 physical `.ps1` files plus those two `.psd1` copies, so 10 counted writes in total against
a cap of 3. The counter is therefore reset at each batch boundary by deleting every file matching
`.claude/state/powershell-batch-budget.*.json`. That deletion is the mechanism the hook's own block
reason prescribes. The path is gitignored, never appears in a diff, and is unrelated to the issue
#510 condition recorded below; do not conflate the two.

## Declared Blast Radius (binding)

The `## DECLARED BLAST RADIUS` section of `spec.md` is exhaustive. This plan writes only paths listed
there. In particular:

- **No file under `.claude/rules/`, `.claude/skills/`, `.github/instructions/`, or
  `.github/copilot-instructions.md` is written.** Those are canonical policy sources this repository
  forbids modifying. If any task appears to require such an edit, execution stops and reports blocked.
- **The four `-helpers.ps1` copies are not touched.** Leaving them byte-untouched is the proof that
  the issue #539 staging exemption is behaviourally unchanged (decision D1).
- **No existing test file is edited.** Six pre-existing suites must pass unmodified: the spec's four
  named suites, plus `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1`, plus
  `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`. The last of these dot-sources
  `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` and pins
  `Test-ImplementationDelegation` to true for `atomic-executor` and false for `task-researcher`, so
  it is the suite most directly exposed to the Codex classifier replacement in P3-T9 and P3-T10.
  `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` is at 461 of
  500 lines and must not grow; all new Claude-side cases go in the new sibling suite.

## Toolchain

PowerShell toolchain order is **format, then analyze, then test**. Type checking is **not applicable**
to PowerShell. Restart from format if any stage fails or changes files, and repeat until all three
stages complete without error or file change in a single pass. Every production `.ps1` written by this
change must stay at or under **500 lines**.

## Known Operational Conditions (carried into execution)

- **MCP PoshQC test runner reads installed-extension settings.** Newly added `CodeCoverage.Path`
  entries are ignored by `mcp__drm-copilot__run_poshqc_test`. Verifying that the new entries take
  effect requires the self-hosted invocation instead: import the module at
  `scripts/powershell/PoshQC/PoshQC.psd1` and call `Invoke-PoshQCTest` with the repository settings
  path. Task P4-T11 performs that verification.
- **Known pre-existing local failure, not a regression and not to be fixed here.**
  `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
  fails locally because it enumerates gitignored `.claude/state/*.json` counters that regenerate
  within minutes. This is open issue #510; CI is unaffected. Do not misread a local failure of that
  test as a regression introduced by this change, and do not delete the state file as a fix.
- **Mirror byte-identity is verified by SHA-256, not by inspection.** The repository's Python parity
  tests compare `read_text()` results under universal-newline translation and therefore cannot observe
  a line-ending or trailing-byte difference. `Get-FileHash` is the only check in this repository that
  observes it.
- **Baseline facts measured before planning, recorded as context only.** All four mirror pairs were
  byte-identical at the branch point; the two main gate hooks hash
  `bf3fe18d0de06f871e80a3962fc69bf1551e4015f4351e98979f087ebe911ca9` on the Claude surface and
  `db69f084eea38ef30f273b95c07a994a17e1f4b6b4963eb39388f4021533f350` on the Codex surface; all four
  `-helpers.ps1` copies share the single hash
  `45c339fd4b4b1702230518b6fcdeb863a08bcb7a7540f46c5f7851c730765c0b`; the two
  `pester.runsettings.psd1` copies share the hash
  `ca1894a4111d28aa716c2167a05a2d96af519ab78ab1bb25907ebc934dcc7b9a`. Phase 0 still captures its own
  baseline artifacts from real command output; these values are context, not a substitute.

---

### Phase 0 — Baseline Capture and Policy Compliance Reads

- [x] [P0-T1] Read the repository policy files in the order defined by the policy-compliance-order skill — `CLAUDE.md`, then `.claude/rules/general-code-change.md`, then `.claude/rules/general-unit-test.md`, then `.claude/rules/powershell.md`, then `.claude/rules/quality-tiers.md`, then `.claude/rules/plan-acceptance-gates.md` — and write `${feature-folder}/evidence/baseline/phase0-instructions-read.<timestamp>.md` carrying `Timestamp:`, `Policy Order:`, and the explicit list of the six files read.
  - Acceptance: the artifact exists, contains all three required field labels, and names all six policy files in the stated order.
- [x] [P0-T2] Read `docs/features/active/preimplementation-gate-blocks-epic-execution-554/spec.md` in full, `docs/features/active/preimplementation-gate-blocks-epic-execution-554/issue.md`, and `docs/features/active/preimplementation-gate-blocks-epic-execution-554/research/2026-08-26T09-30-preimplementation-gate-epic-execution-554-research.md`, then write `${feature-folder}/evidence/baseline/phase0-requirements-sources.<timestamp>.md` carrying `Timestamp:` and recording that `spec.md` is the sole acceptance-criteria source, that `user-story.md` is deliberately absent, and the count of acceptance-criteria items found in the spec's `## Acceptance Criteria` section.
  - Acceptance: the artifact records the acceptance-criteria item count as the integer 35 and states that `user-story.md` is deliberately absent and is not a blocker.
- [x] [P0-T3] Record the merge base of the working branch against `main` by running `git merge-base origin/main HEAD` and write `${feature-folder}/evidence/baseline/phase0-merge-base.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` carrying the resolved commit SHA.
  - Acceptance: `EXIT_CODE:` is 0 and `Output Summary:` contains a 40-character hexadecimal commit SHA. The SHA is recorded as branch-point context only; the Phase 5 diff tasks use the equivalent `origin/main...HEAD` three-dot form and do not substitute the recorded SHA.
- [x] [P0-T4] Capture the PowerShell formatting baseline by invoking the MCP tool `mcp__drm-copilot__run_poshqc_format` and write `${feature-folder}/evidence/baseline/phase0-poshqc-format.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` stating the number of files reformatted.
  - Acceptance: the artifact exists with all four field labels and `Output Summary:` states a numeric reformatted-file count.
- [x] [P0-T5] Capture the PSScriptAnalyzer baseline by invoking the MCP tool `mcp__drm-copilot__run_poshqc_analyze` and write `${feature-folder}/evidence/baseline/phase0-poshqc-analyze.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` stating the numeric finding count by severity.
  - Acceptance: the artifact exists with all four field labels and `Output Summary:` states a numeric total finding count.
- [x] [P0-T6] Capture the coverage-bearing Pester baseline using the self-hosted invocation, importing `scripts/powershell/PoshQC/PoshQC.psd1` and then running `Invoke-PoshQCTest -Root . -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, and write `${feature-folder}/evidence/baseline/phase0-poshqc-test-coverage.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording the numeric passed count, the numeric failed count, and the numeric line-coverage headline percentage.
  - Acceptance: `Output Summary:` records a numeric line-coverage percentage; a placeholder such as UNVERIFIED or NOT DETERMINED is not acceptable and leaves this task unchecked.
- [x] [P0-T7] Capture the SHA-256 baseline of the eight hook files in scope — the four main-gate copies and the four `-helpers.ps1` copies — using `Get-FileHash -Algorithm SHA256` on each path, and write `${feature-folder}/evidence/baseline/phase0-hook-hashes.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` listing all eight paths with their hashes.
  - Acceptance: the artifact lists exactly eight path-and-hash rows and records, per surface, whether each self-hosted file and its bundled mirror agree.
- [x] [P0-T8] Capture the line-count baseline of the two main gate hooks and the existing Claude gate suite by counting lines in `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, and `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1`, and write `${feature-folder}/evidence/baseline/phase0-line-counts.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` carrying the three integer counts and the remaining headroom against the 500-line cap.
  - Acceptance: the artifact records three integer line counts and three integer headroom values.
- [x] [P0-T9] Capture the Python parity and pack-manifest baseline by running `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py` and write `${feature-folder}/evidence/baseline/phase0-python-parity.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` carrying the numeric passed and failed counts and naming any failing test node.
  - Acceptance: the artifact records numeric passed and failed counts, and explicitly annotates any failure of the bundled-Claude-payload whole-tree test as the pre-existing issue #510 condition rather than a regression.
- [x] [P0-T10] Capture the pre-change `.codex/config.toml` PreToolUse matcher baseline by recording the exact tool matchers present, and write `${feature-folder}/evidence/baseline/phase0-codex-matchers.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` listing every PreToolUse tool matcher literal found.
  - Acceptance: `Output Summary:` lists exactly three PreToolUse tool matchers and states that none of them admits an Agent or Task tool name.

### Phase 1 — Fail-Before Regression Evidence for the Fault-1 Wording-Independence Case

- [x] [P1-T1] Create the new Pester suite file `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` containing a header that records why the cases live in a new sibling rather than in the existing suite, a `BeforeAll` block that dot-sources `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` through a `$PSScriptRoot`-relative `Resolve-Path`, and literal-string fixture factories for delegation tool inputs and checkpoint content, with no temporary file, no filesystem write, no wall-clock read, and no network access.
  - Acceptance: the file exists, defines its fixtures as literal strings only, and the suite is discoverable by Pester without error.
- [x] [P1-T2] [expect-fail] Add matrix case 6b to that suite as a single `It` block asserting that a delegation whose `subagent_type` is `orchestrator`, whose prompt carries no mode markers and is phrased with the words "atomic execution" while containing neither of the two legacy free-text tokens, and whose injected single-feature checkpoint is unready, yields a **deny** decision.
  - Acceptance: the `It` block exists, names the case explicitly as the Fault-1 allow-to-deny behaviour change, and executes against the unmodified hook.
- [x] [P1-T3] [expect-fail] Run only the new suite against the unmodified hook and write the fail-before artifact `${feature-folder}/evidence/regression-testing/fail-before-case-6b.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode:` set to the non-zero value the run produces, and `Output Summary:` recording that the 6b case failed because the pre-fix classifier returns allow.
  - Acceptance: the artifact records a non-zero `EXIT_CODE:` together with a matching `ExpectedExitCode:`, and `Output Summary:` states that the observed pre-fix decision was allow while the asserted decision is deny.

### Phase 2 — Batch A: the Pure Modes Sibling (both self-hosted surfaces)

- [x] [P2-T1] Create `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` with a comment-based header declaring its normative contract as the issue #554 mode dispatch and readiness predicates, declaring the file pure with no disk, process, network, or environment access, and declaring that every readiness predicate accepts an already-parsed checkpoint object or `$null`.
  - Acceptance: the file exists, its header states the purity constraint, and the file contains no call to `Get-Content`, `Test-Path`, `Invoke-WebRequest`, or `Start-Process`.
- [x] [P2-T2] Add the three script-scope constant tables to that file: the fixed mode table mapping the recognized marker literals to mode names, the canonical checkpoint-path map, and the implementation-agent allow-list containing exactly `python-typed-engineer`, `powershell-typed-engineer`, `typescript-engineer`, `csharp-typed-engineer`, and `atomic-executor`.
  - Acceptance: the epic marker literal is `Epic mode: true` with no trailing period, the parallel marker literal is `Parallel mode: true` with no trailing period, the preparation markers retain their trailing periods, the canonical epic path is `artifacts/orchestration/epic-orchestrator-state.json`, the canonical parallel path is `artifacts/orchestration/parallel-orchestrator-state.json`, the default path is `artifacts/orchestration/orchestrator-state.json`, and the allow-list has exactly five members.
- [x] [P2-T3] Add `Resolve-OrchestrationDelegationMode` accepting a prompt string and returning one of the four mode names, evaluating preparation first, then epic, then parallel, then defaulting to the single-feature mode, reading nothing but the supplied string.
  - Acceptance: the function is null-tolerant and empty-string tolerant, returns the default mode for an empty prompt, and never reads a checkpoint path out of the prompt.
- [x] [P2-T4] Add `Get-OrchestrationDelegationCheckpointPath` accepting a mode name and returning the canonical path from the fixed table, returning an empty string for the preparation mode.
  - Acceptance: the function resolves each of the four mode names to the value declared in P2-T2 and derives no value from any prompt text.
- [x] [P2-T5] Add `Find-OrchestrationDelegationTargetFolder` accepting a prompt string and returning the target feature-folder basename using the wave-barrier technique — scan for forward- or backslash-separated `docs/features/active/` path tokens, longest unique match wins, a match ending in the Markdown extension resolves to its parent directory, and the basename is returned — returning `$null` when no token resolves.
  - Acceptance: the function returns `$null` for a prompt with no such token, and returns the basename for a prompt whose only token is a path ending in a Markdown file.
- [x] [P2-T6] Add `Find-OrchestrationDelegationIssueNumber` accepting a prompt string and returning the resolvable issue number as a string, or `$null` when none resolves, so `issue_num` can serve as the alternative target resolution required by decision D3.
  - Acceptance: the function returns `$null` for a prompt carrying no issue number and returns the numeric string for a prompt carrying one.
- [x] [P2-T7] Add `Test-OrchestrationDelegationDeclaredCheckpointPath` accepting a prompt string and a mode name and returning true only when the prompt declares no checkpoint path for that mode, or declares one that equals the mode's canonical path; the declared value is a cross-check operand only and is never used to select a source.
  - Acceptance: an absent declared value returns true, a declared value equal to the canonical path returns true, and a declared value differing from the canonical path returns false.
- [x] [P2-T8] Add `Get-EpicOrchestrationReadinessFailure` accepting an already-parsed checkpoint object or `$null`, a target folder basename, and an issue number, and returning an empty string when every conjunct holds or the name of the first failed predicate otherwise, enforcing in order: `route_id` exactly `epic`; non-empty `epic_feature_folder`; non-empty `epic_manifest_path` under `docs/features/epics/`; non-empty `integration_branch`; present and non-empty `features`; the resolved target present as a record in `features`; and that record's `merge_status` neither `merged` nor `worktree_removed`.
  - Acceptance: a `$null` checkpoint returns a non-empty failure name, an absent `merge_status` is treated as `not_started` and does not fail the last conjunct, and a `merge_status` of `merge_conflict` or `blocked_conflict_loop_limit` does not fail the last conjunct.
- [x] [P2-T9] Add `Test-EpicOrchestrationReady` as a boolean wrapper over `Get-EpicOrchestrationReadinessFailure`, returning false whenever the failure name is non-empty.
  - Acceptance: the wrapper returns false for a `$null` checkpoint and true only for a checkpoint satisfying all seven conjuncts of P2-T8.
- [x] [P2-T10] Add `Get-ParallelOrchestrationReadinessFailure` and `Test-ParallelOrchestrationReady` mirroring P2-T8 and P2-T9 against the parallel checkpoint, enforcing: `route_id` exactly `parallel`; non-empty `parallel_slug`; non-empty `parallel_manifest_path`; present and non-empty `items`; the resolved target present as a record in `items`; and that record's `merge_status` neither `merged` nor `worktree_removed`.
  - Acceptance: the predicate consumes the parallel item-state and merge-status member sets without adding any member, and a `merge_status` of `blocked_drift` or `blocked_ci_loop_limit` does not fail the last conjunct.
- [x] [P2-T11] Create `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` as a copy of the reviewed `.claude` modes file, adjusting only the header's surface reference, and confirm the file introduces no dependency on `HookPayload.psm1` or on any Claude-surface field reader.
  - Acceptance: the Codex modes file defines the same function names as the Claude modes file and contains no `Import-Module` statement.
- [x] [P2-T12] First add to the suite's `BeforeAll` a `$PSScriptRoot`-relative `Resolve-Path` dot-source of `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`, so the predicate-level cases resolve the modes functions during Batch A, before the main gate hook dot-sources that sibling in P3-T1. Then add predicate-level Pester cases for mode resolution to `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`, covering the four mode names, the preparation-first precedence, the empty-prompt default, and the canonical-path cross-check in its absent, matching, and mismatching forms.
  - Acceptance: every added case uses literal string fixtures only, and all added cases pass when the suite is run; and the suite resolves `Resolve-OrchestrationDelegationMode` when run at the end of Batch A, with no Batch B edit applied.
- [x] [P2-T13] Add predicate-level Pester cases for the epic readiness predicate to the same suite, covering each of the seven conjuncts failing individually, the fully ready case, the absent `merge_status` case, the terminal-merged deny case, and the failure-status allow case required by decision D8.
  - Acceptance: at least one case exists per conjunct, and every added case passes when the suite is run.
- [x] [P2-T14] Add predicate-level Pester cases for the parallel readiness predicate to the same suite, covering each of the six conjuncts failing individually, the fully ready case, the terminal-merged deny case, and the blocked-status allow case.
  - Acceptance: at least one case exists per conjunct, and every added case passes when the suite is run.
- [x] [P2-T15] Verify that both new modes files are at or under the 500-line cap by counting the lines in `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` and `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`, and record the two counts in `${feature-folder}/evidence/qa-gates/batch-a-line-counts.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - Acceptance: both recorded counts are integers at or below 500.
- [x] [P2-T16] Run the PowerShell toolchain over Batch A in order — the MCP tools `mcp__drm-copilot__run_poshqc_format` then `mcp__drm-copilot__run_poshqc_analyze` — restarting from format if formatting changes a file, and record the result in `${feature-folder}/evidence/qa-gates/batch-a-format-analyze.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - Acceptance: `Output Summary:` records zero analyzer findings for the two new modes files in the final pass.
- [x] [P2-T17] Run the test stage of the Batch A toolchain over the new suite only, with `Invoke-Pester -Path tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`, and record the result in `${feature-folder}/evidence/qa-gates/batch-a-test.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `ExpectedExitCode:` set to the non-zero value the run produces, and `Output Summary:` carrying the numeric passed, failed, and skipped counts together with the name of each failing case. The `[expect-fail]` matrix case 6b added in P1-T2 is still expected to fail here, because the structural classifier that changes its outcome is not applied until P3-T2; that single failure is the only failure permitted at this task. Restart the Batch A toolchain at P2-T16 if any other case fails or if this stage changes a file.
  - Acceptance: `Output Summary:` records a numeric passed count greater than 0, `EXIT_CODE:` equals the declared `ExpectedExitCode:`, and the only failing case named is the `[expect-fail]` matrix case 6b from P1-T2.
- [x] [P2-T18] Reset the PowerShell per-batch budget counter before Batch B begins by deleting every file matching `.claude/state/powershell-batch-budget.*.json`, and record the reset in `${feature-folder}/evidence/qa-gates/batch-a-budget-reset.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` naming the files deleted or stating that no counter file existed.
  - Acceptance: `Output Summary:` records the counter contents observed before deletion and confirms no `powershell-batch-budget` counter file remains under `.claude/state/` afterwards.

### Phase 3 — Batch B: the Two Main Gate Hooks and the Decision-Level Tests

- [x] [P3-T1] Add to `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` a dot-source line for the new modes sibling, placed alongside the existing dot-source of the `-helpers.ps1` sibling, without altering the existing dot-source line.
  - Acceptance: the file dot-sources both siblings, the existing helpers dot-source line is unchanged, and dot-sourcing the hook in a test resolves every modes-sibling function.
- [x] [P3-T2] Replace `Test-ImplementationDelegation` in `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` with the structural classifier defined in the spec: field-scoped reads of `subagent_type` and `prompt` via `Get-ClaudeHookToolInputString`; an allow-listed `subagent_type` classifies as implementation against the single-feature source; a `subagent_type` other than `orchestrator` is not implementation; an `orchestrator` whose resolved mode is preparation is not implementation; every other `orchestrator` is implementation against the mode's table path. The whole-payload `ConvertTo-Json` scan is removed.
  - Acceptance: the function retains its `[AllowNull()]` parameter and returns false for a `$null` tool input; the file no longer contains a `ConvertTo-Json` call inside this function; and marker text placed in a non-`prompt` field cannot change the classification in either direction.
- [x] [P3-T3] Add the two per-mode read seams `Get-EpicCheckpointContent` and `Get-ParallelCheckpointContent` to `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, each mirroring the shape of the existing `Get-CheckpointContent` and each reading only its mode's canonical path constant.
  - Acceptance: each seam returns an empty string when its file is absent, and neither seam derives its path from any prompt text.
- [x] [P3-T4] Add the two optional parameters `-EpicCheckpointRaw` and `-ParallelCheckpointRaw` to `Invoke-OrchestrationPreimplementationGateDecision` in the Claude hook, each carrying `[AllowNull()]` and `[AllowEmptyString()]`, and each overriding the corresponding read seam whenever the caller BINDS it — decided with `$PSBoundParameters.ContainsKey('EpicCheckpointRaw')` and `$PSBoundParameters.ContainsKey('ParallelCheckpointRaw')`, never with a truthiness test — so that an explicitly supplied empty string suppresses the seam instead of falling through to disk. The existing `-ToolInputRaw` and `-CheckpointRaw` parameters are unchanged in name, position, attributes, and truthiness-based fall-through behaviour.
  - Acceptance: an invocation supplying only `-ToolInputRaw` and `-CheckpointRaw` behaves exactly as before; an invocation supplying `-EpicCheckpointRaw` bound to the empty string returns a deny without reading any file from disk; and an invocation supplying only `-EpicCheckpointRaw` while leaving `-CheckpointRaw` unset proves the epic source was the one consulted.
- [x] [P3-T5] Add the mode-aware dispatch and mode-specific deny-reason construction to `Invoke-OrchestrationPreimplementationGateDecision` in the Claude hook, so the resolved mode selects the readiness source, the readiness predicate, and a reason that names the checkpoint actually consulted and the failed predicate, preserving the `PREIMPLEMENTATION_GATE_BLOCKED:` prefix, and so that a failed canonical-path cross-check denies.
  - Acceptance: an epic-mode deny reason contains the literal `epic-orchestrator-state.json`, a parallel-mode deny reason contains the literal `parallel-orchestrator-state.json`, and every deny reason retains the `PREIMPLEMENTATION_GATE_BLOCKED:` prefix.
- [x] [P3-T6] Preserve the default single-feature deny wording in the Claude hook so it continues to contain both substrings `route metadata` and `lifecycle readiness`, which an existing unmodified test asserts.
  - Acceptance: the pre-existing `It` block in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` that asserts both substrings passes without any edit to that file.
- [x] [P3-T7] Verify that `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` remains at or under 500 lines after the Batch B edits by counting its lines and recording the count in `${feature-folder}/evidence/qa-gates/batch-b-claude-line-count.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - Acceptance: the recorded count is an integer at or below 500.
- [x] [P3-T8] Apply the P3-T1 dot-source change to `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, placing the modes-sibling dot-source alongside the existing helpers dot-source and the existing `codex-pretooluse-file-mapping.ps1` dot-source.
  - Acceptance: the Codex hook dot-sources the Codex modes sibling and both pre-existing dot-source lines are unchanged.
- [x] [P3-T9] Apply the P3-T2 structural-classifier replacement to `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, adapting the field reads to the hook's local `Get-StringProperty` and introducing no predicate whose outcome depends on untrimmed leading or trailing whitespace in a field value.
  - Acceptance: every marker test in the Codex classifier is a containment test over the prompt, so the Codex reader's trimming behaviour cannot change any decision this change introduces.
- [x] [P3-T10] Apply the P3-T3, P3-T4, and P3-T5 changes to `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` — the two read seams, the two optional parameters, and the mode-aware dispatch and reason construction — leaving the Codex-specific empty-input allow branch, malformed-JSON throw, and dispatch tail unchanged.
  - Acceptance: the Codex decision function still accepts the mapped flat `tool_input` JSON on its `-ToolInputRaw` parameter, still returns allow on empty input, and still throws on malformed JSON.
- [x] [P3-T11] Verify that `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` remains at or under 500 lines after the Batch B edits by counting its lines and recording the count in `${feature-folder}/evidence/qa-gates/batch-b-codex-line-count.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - Acceptance: the recorded count is an integer at or below 500.
- [x] [P3-T12] Add matrix cases 1 through 4 to the Claude mode-resolution suite: an epic-mode delegation with a ready epic checkpoint injected through `-EpicCheckpointRaw` yields allow; the same with empty injected epic-checkpoint content yields deny whose reason names the epic checkpoint file; the same whose injected checkpoint's `features` array lacks the target record yields deny naming the failed predicate; and the same declaring a non-canonical `epic_checkpoint_path` in its prompt yields deny.
  - Acceptance: all four cases pass, and the case-2 assertion checks the deny reason for the literal `epic-orchestrator-state.json`; and case 2 binds `-EpicCheckpointRaw` to the empty string explicitly, so the assertion never reads the on-disk epic checkpoint.
- [x] [P3-T13] Add matrix case 5 to the Claude mode-resolution suite: an epic-mode marker placed in a non-`prompt` field, with a clean prompt, resolves to the default single-feature mode rather than epic mode.
  - Acceptance: the case passes and asserts the decision was evaluated against the single-feature source rather than the epic source.
- [x] [P3-T14] Add matrix cases 6a, 7, and 8 to the Claude mode-resolution suite: an allow-listed implementation `subagent_type` with a prompt containing none of the seven legacy tokens and an unready single-feature checkpoint yields deny; a delegation carrying both preparation markers yields allow; and a standalone orchestrator yields allow against a ready single-feature checkpoint and deny against an unready one.
  - Acceptance: all four assertions pass, and case 8 is expressed as two separate `It` blocks.
- [x] [P3-T15] Add the epic target-unresolvable case and the merge-status hardening cases to the Claude mode-resolution suite: an epic-mode delegation whose prompt carries no resolvable target token and no issue number yields deny; an epic-mode delegation whose target record carries a terminal-merged merge status yields deny; and a companion epic-mode delegation whose target record carries a failure merge status yields allow.
  - Acceptance: all three cases pass and none of them extends any checkpoint enum member set.
- [x] [P3-T16] Add the parallel decision-level cases to the Claude mode-resolution suite: a parallel-mode delegation with a ready parallel checkpoint injected through `-ParallelCheckpointRaw` yields allow; one whose injected checkpoint's `items` array lacks the target record yields deny naming the parallel checkpoint file; and one declaring a non-canonical `parallel_checkpoint_path` in its prompt yields deny.
  - Acceptance: all three cases pass, and the negative case asserts the deny reason contains the literal `parallel-orchestrator-state.json`.
- [x] [P3-T17] Add the deny-by-default cases to the Claude mode-resolution suite: an unparseable payload yields deny, a payload with no tool-input key yields deny, and an epic-mode delegation with `-EpicCheckpointRaw` bound to the empty string yields deny without any filesystem read.
  - Acceptance: all three cases pass, and no new permissive path is introduced by any of them.
- [x] [P3-T18] Create `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` that dot-sources the Codex gate hook and its modes sibling through `$PSScriptRoot`-relative `Resolve-Path` and asserts, with the same constructed literal inputs used on the Claude side, that `Resolve-OrchestrationDelegationMode` and both readiness predicates return the same outcomes; no `Agent` envelope is fabricated on this surface.
  - Acceptance: the suite passes, and it contains no case that constructs an `Agent` tool payload for the Codex decision function.
- [x] [P3-T19] Add to the Codex mode-resolution suite one case that reads `.codex/config.toml` through a `$PSScriptRoot`-relative `Resolve-Path` and asserts that no PreToolUse matcher admits an Agent or Task tool name, with a comment cross-referencing issue #555.
  - Acceptance: the case passes and its comment names issue #555 as the owner of the transport gap.
- [ ] [P3-T20] Run all four pre-existing suites, `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1`, and `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` — the last of which dot-sources the Codex gate hook and pins `Test-ImplementationDelegation` to true for `atomic-executor` and false for `task-researcher` — without editing any of them and record the result in `${feature-folder}/evidence/qa-gates/pre-existing-suites.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` carrying per-suite passed and failed counts.
  - Acceptance: `EXIT_CODE:` is 0, every per-suite failed count is 0, and none of the six files appears in the branch diff.
- [x] [P3-T21] Run the PowerShell toolchain over Batch B in order — `mcp__drm-copilot__run_poshqc_format` then `mcp__drm-copilot__run_poshqc_analyze` — restarting from format if formatting changes a file, and record the result in `${feature-folder}/evidence/qa-gates/batch-b-format-analyze.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - Acceptance: `Output Summary:` records zero analyzer findings for the two main gate hooks in the final pass.
- [x] [P3-T22] Run the test stage of the Batch B toolchain over both new suites, with `Invoke-Pester -Path tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1,tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`, and record the result in `${feature-folder}/evidence/qa-gates/batch-b-test.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` carrying the numeric passed and failed counts per suite. Restart the Batch B toolchain at P3-T21 if this stage fails or changes a file.
  - Acceptance: `Output Summary:` records a failed count of the integer 0 for each of the two suites and a numeric passed count greater than 0 for each.
- [x] [P3-T23] Reset the PowerShell per-batch budget counter before Batch C begins by deleting every file matching `.claude/state/powershell-batch-budget.*.json`, and record the reset in `${feature-folder}/evidence/qa-gates/batch-b-budget-reset.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` naming the files deleted or stating that no counter file existed.
  - Acceptance: `Output Summary:` records the counter contents observed before deletion and confirms no `powershell-batch-budget` counter file remains under `.claude/state/` afterwards.

### Phase 4 — Batch C: Mechanical Mirror Copies, Coverage Registration, and Pack Manifests

- [ ] [P4-T1] Copy the reviewed `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` to `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` as a mechanical byte-copy, authoring no logic in the destination.
  - Acceptance: `Get-FileHash -Algorithm SHA256` reports the same hash for both paths.
- [ ] [P4-T2] Copy the reviewed `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` to `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` as a mechanical byte-copy.
  - Acceptance: `Get-FileHash -Algorithm SHA256` reports the same hash for both paths.
- [ ] [P4-T3] Copy the reviewed `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` to `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` as a mechanical byte-copy.
  - Acceptance: `Get-FileHash -Algorithm SHA256` reports the same hash for both paths.
- [ ] [P4-T4] Before copying, reset the PowerShell per-batch budget counter a second time by deleting every file matching `.claude/state/powershell-batch-budget.*.json`, so that this copy and the two `pester.runsettings.psd1` edits in P4-T5 and P4-T6 form a three-file production batch. Then copy the reviewed `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` to `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` as a mechanical byte-copy.
  - Acceptance: `Get-FileHash -Algorithm SHA256` reports the same hash for both paths.
- [ ] [P4-T5] Append the two new production hook paths to the `CodeCoverage.Path` allow-list in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, placing each beside the existing entry for its surface and adding a registering comment that names issue #554.
  - Acceptance: the file lists both `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` and `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`, and the list remains an explicit per-file allow-list with no directory wildcard introduced.
- [ ] [P4-T6] Apply the identical text edit to `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` so the two settings files remain at exact text parity.
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py` exits 0, and `Get-FileHash -Algorithm SHA256` reports the same hash for both settings files.
- [ ] [P4-T7] Add `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` to `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, adjacent to the two existing preimplementation-gate entries.
  - Acceptance: the manifest lists the new modes hook and remains valid JSON.
- [ ] [P4-T8] Add `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` to `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`, adjacent to the existing `-helpers.ps1` entry, without adding any entry to the pre-existing-unrelated-hook exception set.
  - Acceptance: the manifest lists the new modes hook, remains valid JSON, and the exception set in `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py` is unchanged.
- [ ] [P4-T9] Run `poetry run pytest tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` and record the result in `${feature-folder}/evidence/qa-gates/pack-manifest-and-payload-parity.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` carrying numeric passed and failed counts.
  - Acceptance: the pack-manifest completeness test and the codex payload contract test both pass, and any failure of the bundled-Claude-payload whole-tree test is annotated as the pre-existing issue #510 condition with the baseline artifact from P0-T9 cited as proof it predates this change; and the Claude pack-manifest completeness test passes, proving the bundled modes hook was registered by P4-T7.
- [ ] [P4-T10] Compute the SHA-256 of each of the four mirrored production pairs with `Get-FileHash -Algorithm SHA256` and write `${feature-folder}/evidence/qa-gates/mirror-pair-hashes.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording all four pair hashes and a per-pair MATCH or DIFFER verdict.
  - Acceptance: the artifact records exactly four pairs and all four verdicts are MATCH.
- [ ] [P4-T11] Verify the new `CodeCoverage.Path` entries take effect by importing `scripts/powershell/PoshQC/PoshQC.psd1` and running `Invoke-PoshQCTest -Root . -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, then confirming both new production hook files appear as measured files in the resulting Pester coverage report; record the result in `${feature-folder}/evidence/qa-gates/coverage-registration-selfhosted.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. The MCP PoshQC test runner must not be used for this verification because it reads settings from the installed extension and would ignore the new entries.
  - Acceptance: `Output Summary:` names both new modes files as measured files and records a numeric per-file covered-line count for each.
- [ ] [P4-T12] Run the PowerShell toolchain over Batch C in order — `mcp__drm-copilot__run_poshqc_format` then `mcp__drm-copilot__run_poshqc_analyze` — and, if formatting changes any mirrored file, re-copy from the self-hosted source and re-verify the pair hash before proceeding; record the result in `${feature-folder}/evidence/qa-gates/batch-c-format-analyze.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Before any re-copy, reset the PowerShell per-batch budget counter by deleting every file matching `.claude/state/powershell-batch-budget.*.json`, as authorized by the change-budget section.
  - Acceptance: the final pass records zero analyzer findings and all four mirror pairs still verify as MATCH.

### Phase 5 — Scope, Blast-Radius, and Follow-Up Verification

- [ ] [P5-T1] Verify the four `-helpers.ps1` copies are byte-identical to their state at the branch point by confirming none of them appears in `git diff --name-only origin/main...HEAD`, and record the result in `${feature-folder}/evidence/qa-gates/helpers-untouched.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - Acceptance: none of the four helpers paths appears in the diff output, and each still hashes to `45c339fd4b4b1702230518b6fcdeb863a08bcb7a7540f46c5f7851c730765c0b`.
- [ ] [P5-T2] Verify the branch diff contains no path beginning with `.claude/rules/`, `.claude/skills/`, or `.github/` by piping `git diff --name-only origin/main...HEAD` into `Select-String -Pattern '^\.claude/rules/|^\.claude/skills/|^\.github/'` and recording the result in `${feature-folder}/evidence/qa-gates/policy-paths-untouched.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - Acceptance: the recorded match count is the integer 0.
- [ ] [P5-T3] Verify every file in the branch diff appears in the `## DECLARED BLAST RADIUS` section of `docs/features/active/preimplementation-gate-blocks-epic-execution-554/spec.md`, treating the `research/` entry and the five `evidence/` entries as directory prefixes, and record the comparison in `${feature-folder}/evidence/qa-gates/blast-radius-conformance.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` listing every diff path with a DECLARED or UNDECLARED verdict.
  - Acceptance: the count of UNDECLARED paths is the integer 0.
- [ ] [P5-T4] Verify no existing test file was edited by confirming that none of the six pre-existing suite paths — the three Claude preimplementation-gate suites, the Codex command-exemption suite, `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1`, and `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` — appears in `git diff --name-only origin/main...HEAD`, and record the result in `${feature-folder}/evidence/qa-gates/existing-suites-unmodified.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - Acceptance: none of the six paths appears in the diff output.
- [ ] [P5-T5] Verify this plan document records the decision D6 batch sequencing and the mechanical-copy treatment by running `Select-String -SimpleMatch 'mechanical byte-copy' -LiteralPath docs/features/active/preimplementation-gate-blocks-epic-execution-554/plan.2026-08-26T08-40.md` and recording the result in `${feature-folder}/evidence/qa-gates/plan-budget-statement.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. The asserted literal is written verbatim here as `mechanical byte-copy` so the assertion targets text this plan itself states.
  - Acceptance: the recorded match count is an integer greater than 0 and the artifact quotes the matched line.
- [ ] [P5-T6] Re-run the Fault-1 case 6b assertion after the fix and write the pass-after artifact `${feature-folder}/evidence/regression-testing/pass-after-case-6b.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording that the case now yields deny, and cross-referencing the fail-before artifact from P1-T3.
  - Acceptance: `EXIT_CODE:` is 0, the case passes, and the artifact names the fail-before artifact path it supersedes.
- [ ] [P5-T7] Draft the follow-up issue for the epic kickoff contract gap described in decision D3 — the epic child kickoff prompt carries no contractually guaranteed `docs/features/active/` basename token and no issue-number key — and write the draft to `${feature-folder}/evidence/other/followup-epic-kickoff-contract-gap.<timestamp>.md` with a title, a body, the rationale, and an explicit statement that no `.claude/skills/` file is modified by this feature.
  - Acceptance: the draft exists, names the gap, and states that closing it is out of scope for issue #554.
- [ ] [P5-T8] Record that filing the follow-up issue is a maintainer action outside this branch by writing `${feature-folder}/evidence/other/followup-issue-filing-deferred.<timestamp>.md` with `Timestamp:`, a `POSTING BLOCKED` header, and both reasons the spec's final acceptance criterion states: `gh issue create` is denied by a PreToolUse hook in this repository, and the sanctioned MCP promotion-lifecycle path writes files under `docs/features/potential/`, which is deliberately not in the declared blast radius. Do not run `gh issue create`, and do not invoke the MCP promotion-lifecycle path from this branch.
  - Acceptance: the artifact carries the `POSTING BLOCKED` header and both stated reasons, and `git diff --name-only origin/main...HEAD` contains no path beginning with `docs/features/potential/`.
- [ ] [P5-T9] Record the known pre-existing local failure condition in `${feature-folder}/evidence/other/known-preexisting-failure-510.<timestamp>.md`, naming the test node, citing open issue #510, and stating that CI is unaffected and that deleting the gitignored state file is not a durable fix and must not be attempted.
  - Acceptance: the artifact names issue #510 and states the non-regression conclusion with the P0-T9 baseline artifact cited as its evidence.

### Phase 6 — Final PowerShell QC Loop

- [ ] [P6-T1] Run the formatting stage by invoking the MCP tool `mcp__drm-copilot__run_poshqc_format` across the repository and write `${feature-folder}/evidence/qa-gates/final-poshqc-format.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` stating the numeric reformatted-file count.
  - Acceptance: `EXIT_CODE:` is 0 and the reformatted-file count in the final pass is the integer 0; a non-zero count restarts the loop at this task.
- [ ] [P6-T2] Run the linting stage by invoking the MCP tool `mcp__drm-copilot__run_poshqc_analyze` across the repository and write `${feature-folder}/evidence/qa-gates/final-poshqc-analyze.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` stating the numeric finding count by severity.
  - Acceptance: `EXIT_CODE:` is 0 and the total finding count is the integer 0; any finding restarts the loop at P6-T1.
- [ ] [P6-T3] Record that the type-checking stage is not applicable to PowerShell by writing `${feature-folder}/evidence/qa-gates/final-typecheck-not-applicable.<timestamp>.md` with `Timestamp:`, `Command:` set to the literal text stating no type checker runs for PowerShell, `EXIT_CODE:` 0, and `Output Summary:` citing the PowerShell rule file's step 3.
  - Acceptance: the artifact exists with all four field labels and cites `.claude/rules/powershell.md` as the authority for skipping type checking.
- [ ] [P6-T4] Run the coverage-bearing test stage using the self-hosted invocation, importing `scripts/powershell/PoshQC/PoshQC.psd1` and running `Invoke-PoshQCTest -Root . -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, and write `${feature-folder}/evidence/qa-gates/final-poshqc-test-coverage.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording the numeric passed count, the numeric failed count, and the numeric post-change line-coverage headline percentage.
  - Acceptance: `EXIT_CODE:` is 0, the failed count is the integer 0, and `Output Summary:` records a numeric post-change line-coverage percentage at or above 85; a placeholder value leaves this task unchecked; if a failure is recorded, this task stays unchecked unless the identical test node is present as a failure in the P0-T6 baseline artifact and is annotated in `Output Summary:` as pre-existing and out of scope for issue #554.
- [ ] [P6-T5] Run the Python verification suites that gate this change by running `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` and write `${feature-folder}/evidence/qa-gates/final-python-verification.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` carrying numeric passed and failed counts.
  - Acceptance: every test passes except a failure of the bundled-Claude-payload whole-tree test attributable to issue #510, which must be annotated against the P0-T9 baseline; any other failure restarts the loop at P6-T1.
- [ ] [P6-T6] Compute and record the coverage delta by writing `${feature-folder}/evidence/qa-gates/coverage-delta.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` reporting the baseline line-coverage percentage from P0-T6, the post-change line-coverage percentage from P6-T4, and the changed-line coverage for the two modified gate hooks and the two new modes files.
  - Acceptance: all three values are numeric, the post-change percentage is at or above 85, and no changed line in either modified hook is reported as uncovered; Pester measures no branch coverage, so no branch-coverage value is reported and none is required.
- [ ] [P6-T7] Verify that the full PowerShell toolchain completed format, analyze, and test in a single pass with no stage failing and no stage changing a file, and record the confirmation in `${feature-folder}/evidence/qa-gates/final-single-pass-confirmation.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` naming the three artifacts from P6-T1, P6-T2, and P6-T4 and their timestamps.
  - Acceptance: the three cited artifact timestamps are monotonically ordered within one loop iteration and each cited artifact records `EXIT_CODE:` 0.
- [ ] [P6-T8] Re-verify every production `.ps1` file written by this change is at or under 500 lines by counting the lines in the four self-hosted files and their four mirrors, and write `${feature-folder}/evidence/qa-gates/final-line-counts.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` carrying all eight integer counts.
  - Acceptance: all eight recorded counts are integers at or below 500.
- [ ] [P6-T9] Re-verify the four mirrored production pairs after the final format pass by recomputing `Get-FileHash -Algorithm SHA256` for each pair and writing `${feature-folder}/evidence/qa-gates/final-mirror-pair-hashes.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording all four pair hashes and a per-pair MATCH or DIFFER verdict. Before any re-copy, reset the PowerShell per-batch budget counter by deleting every file matching `.claude/state/powershell-batch-budget.*.json`, as authorized by the change-budget section.
  - Acceptance: the artifact records exactly four pairs and all four verdicts are MATCH; a DIFFER verdict restarts the loop at P6-T1 after re-copying from the self-hosted source.

---

## Traceability to the Spec Acceptance Criteria

- Amendment criteria 1 through 4 are carried by P3-T2 through P3-T6, P3-T20, P5-T1, and P5-T6.
- Matrix cases 1 through 5 are carried by P3-T12 and P3-T13.
- Matrix cases 6a, 6b, 7, and 8 are carried by P1-T2, P3-T14, and P5-T6.
- Parallel readiness, the parallel cross-check, the epic target-unresolvable case, and the decision D8
  merge-status hardening are carried by P2-T10, P2-T14, P3-T15, and P3-T16.
- Codex logic parity and the recorded transport gap are carried by P3-T18 and P3-T19.
- Unmodified pre-existing suites, the untouched helpers files, and the mirror pair hashes are carried
  by P3-T20, P5-T1, P5-T4, P4-T10, and P6-T9. Six pre-existing suites are in the verification set, not
  five: the spec's four, plus `PreToolUseSchema.Contract.Tests.ps1`, plus
  `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`.
- Coverage registration, the self-hosted coverage verification, and the coverage threshold are carried
  by P4-T5, P4-T6, P4-T11, P6-T4, and P6-T6.
- Pack-manifest registration is carried by P4-T7, P4-T8, P4-T9, and P6-T5; both pack-manifest
  completeness tests — the Codex one and the Claude one — are in the argument list of P4-T9 and P6-T5.
- Per-batch test evidence is carried by P2-T17 and P3-T22; the batch-budget counter resets that make
  the batch sequence executable are carried by P2-T18, P3-T23, and the P4-T4 preamble.
- The blast-radius and policy-path constraints are carried by P5-T2 and P5-T3.
- Deny-by-default preservation is carried by P3-T17.
- The plan's own batch-sequencing statement is carried by P5-T5 and by the change-budget section above.
- The 500-line cap is carried by P2-T15, P3-T7, P3-T11, and P6-T8.
- The decision D3 follow-up record is carried by P5-T7, and the deferral of the GitHub filing itself
  to a maintainer action outside this branch is carried by P5-T8.

## Execution Notes

- Final-QC command tasks in Phase 6 are unconditional. `EXIT_CODE: SKIPPED` is not a passing outcome
  for any of them.
- A task whose evidence artifact is absent, or whose artifact is missing a required field label, stays
  unchecked regardless of the underlying work.
- If any task appears to require writing a file outside the spec's declared blast radius, stop and
  report blocked rather than widening the radius.
