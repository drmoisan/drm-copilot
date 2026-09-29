# agent-payload-gates-resolve-session-root (Plan)

- **Issue:** #690
- **Parent (optional):** epic #678 defect class (worktree-scoped state resolution)
- **Owner:** drmoisan
- **Last Updated:** 2026-09-29T23-10
- **Status:** Draft (revision 1.2: executor preflight round 1 revisions applied; 1.1 changed D13 to a copy-drift halt; pending re-validation and preflight round 2)
- **Version:** 1.2
- **Work Mode:** full-bug (`spec.md` is the acceptance-criteria source; `user-story.md` is present and maps scenarios to spec sections)
- **Branch:** `bug/agent-payload-gates-resolve-session-root-690` (head `d6bb5c65` at planning time)
- **Research:** `research/2026-09-29T21-55-agent-payload-gates-session-root-research.md`

**Fail-closed evidence rule:** Include explicit baseline artifact tasks, final-QA artifact tasks, and coverage-comparison tasks for each in-scope language when policy requires coverage. If any required baseline artifact, QA artifact, or coverage-comparison artifact is missing, the audit verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Record the expected artifact path in each evidence-producing task. Do not mark evidence-backed work complete without the artifact.

## Scope Recap

The approved spec converts each session-root-relative checkpoint read listed in its Scope section to target-worktree resolution by portable identity:

1. Add `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` (epic, parallel, record, and operand resolvers) and export `ConvertTo-WorktreeItemResolvedResult` from `WorktreeItemResolution.psm1`. Nothing imports the new module in the commit that adds it.
2. Convert, one gate per phase, the preimplementation gate (single-feature, epic-mode, parallel-mode legs), the epic wave barrier, the parallel cohort barrier, the merge gate (child, epic, parallel branches), the two worktree-removal gates, and the parallel drift gate. Each gate denies `NoTarget` and `Ambiguous` behind its existing leading token with the accessor reason code, and denies a failed import of the new resolution modules.
3. Convert `Resolve-EpicScopeCheckpoint` to compose its checkpoint path from `Resolve-WorktreeEpicTarget`, and extend the #709/#737 isolation guard.
4. Extend the delegation identity contract text in the orchestrate, epic-orchestrate, parallel-orchestrate, and three invoke-engineer skills, no later than the preimplementation-gate phase.
5. Register and mirror every changed `.claude` file, and record three follow-up potential entries.

Out of scope (spec, Out of scope): `.claude/hooks/validate-orchestrator-output.ps1`; `.codex/**` and the Codex bundle (#736); `Find-EpicWaveBarrierFeatureFolderFromPrompt` (#565); the hook files `enforce-model-routing-receipt.ps1`, `enforce-pr-author-skill.ps1`, `enforce-pr-author-skill-helpers.ps1`, `enforce-pr-author-skill.epic-base-branch.ps1`, `enforce-prd-feature-before-planner.ps1`; the #769 batch-budget hooks; `CleanupWorktreeManifest.psm1`; `Invoke-OrchestratorStatePreflight`; hardening of pre-existing imports and dot-sources; `WorktreeResolution.psm1` and `enforce-orchestration-preimplementation-gate-helpers.ps1` (byte-unchanged); every Python file.

### Current-tree facts this plan relies on (re-derived 2026-09-29 by reading the files at `d6bb5c65`)

- `spec.md` `## Acceptance Criteria` holds 63 unchecked criteria, one `- [ ]` line each at spec lines 410-412, 416-425, 429-435, 439-441, 445-447, 451-455, 459-460, 464, 468-469, 473-475, 479-482, 486-490, 494-498, 502-504, 508-511, 515-517. The file also holds three unchecked Impact/Severity boxes (lines 41, 43, 44) and one checked box (`- [x] High`, line 42). The delegation prompt and `artifacts/orchestration/orchestrator-state.json` state 64 criteria; the tree holds 63, and this plan uses the tree-derived count (see Plan decision D1).
- `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` is 483 lines: dot-sources the epic-scope sibling at line 24; `$script:CheckpointPath` at line 31; `Get-CheckpointContent` at lines 257-266; `Get-OrchestrationModeDenyReason` at lines 298-313; the declared-path cross-check at lines 382-385; the epic-scope leg call at lines 389-394; the mode branch at lines 396-415 (`Get-EpicCheckpointContent` / `Get-ParallelCheckpointContent` called with no argument at line 401); the single-feature read at lines 417-419; the single-feature deny text at line 429. Gate-defined functions are declared after the line-24 dot-source, so a gate definition shadows a sibling definition of the same name.
- `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` is 127 lines: imports `EpicScopeResolution.psm1` and `EpicScopeReadiness.psm1` with `-Force -ErrorAction Stop` (lines 30-31); `Get-EpicCheckpointContent` (36-46) and `Get-ParallelCheckpointContent` (48-58) take no parameter; `Get-OrchestrationEpicScopeSelector` (60-86); `Get-OrchestrationEpicScopeDecision -Command -FilePath` (88-127) calls `Resolve-EpicScopeCheckpoint` at line 117.
- `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` holds the checkpoint-path map (lines 56-61) and the five-member implementation-agent allow-list (lines 68-74: `python-typed-engineer`, `powershell-typed-engineer`, `typescript-engineer`, `csharp-typed-engineer`, `atomic-executor`). It is not edited.
- `.claude/hooks/enforce-epic-wave-barrier.ps1` is 333 lines: `$script:EpicCheckpointPath` line 38; read seam `Get-EpicWaveBarrierCheckpointContent` (no parameter) lines 42-58; `Find-EpicWaveBarrierFeatureFolderFromPrompt` lines 60-107; scope filter lines 257-265; folder check 267-270; read at line 272.
- `.claude/hooks/enforce-parallel-cohort-barrier.ps1` is 283 lines: `$script:ParallelCheckpointPath` line 52; dot-sources `enforce-parallel-cohort-barrier-helpers.ps1` line 58; read seam lines 60-76; scope filter lines 207-215; read at line 222.
- `.claude/hooks/enforce-epic-merge-gate.ps1` is 483 lines: dot-sources the authorization sibling at line 61; three checkpoint-path variables lines 63-65; three read seams lines 67-119; `Get-EpicMergeGateCommandPrNumber` 146-190; `Test-ChildCheckpointAllowsEpicMerge` 192-219; branch reads at lines 403, 408, 413; standalone branch 418-427; final deny line 429.
- `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` is 468 lines: checkpoint-path variables lines 70-71; read seams lines 78-112; reads at lines 386 and 393; manifest branch 408-412; final deny line 414.
- `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` is 397 lines: path variables lines 42 and 49; read seams lines 55-93; reads at lines 288 and 313; manifest branch 338-341; final deny line 343.
- `.claude/hooks/enforce-parallel-drift-gate.ps1` is 394 lines: `$script:ParallelCheckpointPath` line 71; read seam lines 83-97; scope filter lines 296-303; folder check 305-308; read at line 310; the missing-checkpoint deny at line 320 names the path variable.
- `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1` is 392 lines: the private `ConvertTo-WorktreeItemResolvedResult` with its preceding comment lines 216-242; export list lines 384-392; `Get-WorktreeItemLiveRoot -SessionRoot [-Branch]` lines 179-214 returns its array as one object. The literal `ConvertTo-WorktreeItemResolvedResult` occurs on 5 lines (220, 273, 282, 302, 329).
- `.claude/lib/worktree-resolution/EpicScopeResolution.psm1` is 369 lines: `Resolve-EpicScopeCheckpoint` lines 273-360 composes its path from the session root at line 322 and reads once at line 323; exports lines 362-369.
- `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1`: `$script:BranchPattern` (line 61) matches `--head`, `--branch`, or `\bbranch:`; `New-WorktreeResolutionTargetResult` (lines 66-134) restricts `-Signal` to `''`, `FeatureFolderPath`, `FilePath`, `Branch`, `SessionRoot` and sets `ReasonCode` from the two accessors; `Join-WorktreeResolutionPath` lines 311-339 throws for a relative root. `WorktreeResolution.psm1` is 500 lines and exports `ConvertTo-WorktreeResolutionNormalizedPath`, `Find-WorktreeResolutionRoot`, and both reason-code accessors (lines 490-500).
- `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1` is 432 lines: helper functions in its top-level `BeforeAll` lines 28-188; the seven-suite guard list lines 191-199; discrimination rows 207-356; the seam-sufficiency block 359-432 pins `Get-EpicScopeCheckpointText -Times 1 -Exactly` at line 427 and `Get-EpicScopeWorktreeHeadBranch -Times 0` at line 429.
- `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1` carries the module list four times (lines 27-33, 37-43, 51-57, 81-87).
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` lists `.claude/hooks/enforce-epic-merge-gate-authorization.ps1` at line 30, `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` at line 32, and `.claude/lib/worktree-resolution/EpicScopeReadiness.psm1` at line 187.
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` lists `.claude/hooks/enforce-epic-merge-gate-authorization.ps1` at line 47, `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` at line 49, and `.claude/lib/worktree-resolution/EpicScopeReadiness.psm1` at line 320; its bundle copy is `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`.
- Existing suites call a read seam directly with no argument: `enforce-epic-wave-barrier.Tests.ps1` lines 179 and 185; `enforce-parallel-cohort-barrier.Tests.ps1` 446, 452; `enforce-epic-merge-gate.Tests.ps1` 235, 241, 294, 300, 305, 311; `enforce-epic-worktree-removal-gate.Tests.ps1` 176, 182, 419, 425; `enforce-parallel-worktree-removal-gate.Tests.ps1` 317, 323; `enforce-parallel-drift-gate.Tests.ps1` 326, 332; `enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1` 268, 283, 296, 310 (the last four with absolute synthetic paths at lines 253-254).
- Existing suites that assert a full deny text exactly: `enforce-epic-worktree-removal-gate.Tests.ps1` line 485 and `enforce-parallel-worktree-removal-gate.Tests.ps1` line 454.
- Existing suite sizes near the cap: `enforce-epic-worktree-removal-gate.Tests.ps1` 495 lines, `enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` 491, `enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` 489.
- `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` dot-sources the preimplementation gate inside one `It` and calls only `Get-OrchestrationPreimplementationGateBlockDecision` (lines 65-69); it reaches no resolution and is not edited.
- `tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1` dot-sources both removal gates, the merge gate, and the preimplementation gate (lines 47-51) and calls the epic removal and merge decisions (lines 88, 148). `tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1` dot-sources the epic removal gate (line 220) and the parallel removal gate (line 272) in two `BeforeAll` blocks.
- `.claude/skills/orchestrate/SKILL.md` `## Issue Number Consistency` is lines 255-265; line 263 names two gates. No file under `.claude/skills/orchestrate/`, `epic-orchestrate/`, `parallel-orchestrate/`, or `invoke-*-engineer/` contains `enforce-orchestration-preimplementation-gate.ps1` or `TARGET_WORKTREE_AMBIGUOUS`. `.claude/skills/epic-orchestrate/SKILL.md` kickoff paragraph ends at line 124; `.claude/skills/parallel-orchestrate/SKILL.md` `## Parallel-Mode Kickoff Parameter` ends at line 278 and forbids the epic-mode marker string (lines 269-273). The three invoke skills (`invoke-python-engineer`, `invoke-powershell-engineer`, `invoke-csharp-engineer`) each have `## Worker Routing` (lines 45, 44, 45).
- `artifacts/orchestration/orchestrator-state.json` (gitignored) records `issue-num` `690`, `route_id` `large`, `lifecycle_ready` `true`, and a note that `artifacts/orchestration/epic-orchestrator-state.json` at this worktree root belongs to the running #770 epic orchestrator and must not be modified. That epic checkpoint records `route_id` `epic` and `integration_branch` `epic/push-down-payload-correctness-integration` (lines 3 and 7).
- `.claude/state/current-session-id` exists (gitignored), so the push-down parity node is expected to fail locally only as KL-510 case (b).

### Plan decisions (resolutions of spec latitude, recorded for review)

- **D1 — Acceptance-criteria count.** The tree holds 63 criteria (derivation: the `- [ ]` lines of `spec.md` after line 406). This plan tracks AC-01 through AC-63 in spec order (Appendix I). No criterion is added or dropped.
- **D2 — Two additional module exports.** `WorktreeRunResolution.psm1` also exports `Get-WorktreeRunCheckpointPath -Kind epic|parallel|item -WorktreeRoot` (the single composition of an absolute checkpoint path) and `Resolve-WorktreeOperandTarget -Path -SessionRoot` (placement of a `file_path` or `git -C` operand by ascent). Hooks cannot see the nested sibling modules' exports, and both helpers keep identity and path logic out of the hooks.
- **D3 — New dot-sourced siblings for the two gates at the cap.** The merge-gate glue goes in a new sibling `.claude/hooks/enforce-epic-merge-gate-resolution.ps1` (estimate for the authorization file: 443 plus about 95 lines of glue, over 500). The epic worktree-removal gate (468 lines) gets a new sibling `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1`; inline glue is estimated at about 33 lines, reaching 501. Each sibling holds that gate's import guard, its relocated read seams (same names, now taking `-Path`), and its resolution seam. Both are registered in `core.json` and both runsettings copies and mirrored. `enforce-epic-merge-gate-authorization.ps1` is not edited.
- **D4 — Preimplementation glue location.** `Get-CheckpointContent`, `Get-OrchestrationModeDenyReason`, the import guard, the resolution seam `Resolve-OrchestrationGateTarget`, and the read helper `Read-OrchestrationGateCheckpoint` move into `enforce-orchestration-preimplementation-gate-epic-scope.ps1`; the gate file keeps only call sites.
- **D5 — Write order for a gate with a sibling.** The sibling is written first and the gate second, both from pre-checked staged copies, with no other repository write between them. For the preimplementation gate this is safe for the one intervening tool call: the old gate still shadows `Get-CheckpointContent` and `Get-OrchestrationModeDenyReason` with its own definitions, and `Get-OrchestrationEpicScopeDecision` keeps its name and parameters; only the old gate's epic- and parallel-mode `Agent` legs would call the re-signed seams, and the executor issues no `Agent` call between the two writes. The merge and removal gates run on Bash matchers and do not dot-source their new siblings until their own gate file is written.
- **D6 — `-CheckpointRaw` keeps its truthiness semantics.** The gate's existing comment (gate lines 325-330) requires `-CheckpointRaw` to keep its truthiness fall-through. A bound non-empty `-CheckpointRaw` bypasses resolution; a bound empty value falls through to resolution exactly as it fell through to the disk read. `-EpicCheckpointRaw` and `-ParallelCheckpointRaw` bypass resolution whenever bound (`ContainsKey`).
- **D7 — Import guard scope.** Each converted gate records a failed import of `WorktreeRunResolution.psm1` (and `WorktreeItemResolution.psm1` where imported) in a gate-specific script variable; the decision function checks it before any other logic. In the preimplementation sibling the guard also covers `EpicScopeResolution.psm1`, because after Phase 10 that module imports `WorktreeRunResolution.psm1` and an unguarded failure there would reopen the fail-open path for the same dependency. Every other pre-existing import stays as it is (follow-up entry E1).
- **D8 — Merge-gate unresolved reason.** When the command names a PR number and neither the epic nor the parallel branch resolves (both `NoTarget`, or either `Ambiguous`), and no allow condition holds, the deny reason is `EPIC_MERGE_GATE_BLOCKED: <code>: <detail>; ` followed by the unchanged standalone reason code and message. The ambiguity code wins when either branch is `Ambiguous`. When either branch resolves, the existing deny text is unchanged.
- **D9 — Removal-gate unresolved handling.** Either kind resolving `Ambiguous` denies at once with the gate token and `TARGET_WORKTREE_AMBIGUOUS`, before the manifest branch. Both kinds resolving `NoTarget` leaves both checkpoints `$null`, so the #635 manifest branch still decides; its non-authorizing outcome denies with the gate token, `TARGET_WORKTREE_NOT_DERIVABLE`, and the detail, followed by the unchanged deny text. Any other outcome leaves the final deny text byte-identical, so the exact-text rows at `enforce-epic-worktree-removal-gate.Tests.ps1:485` and `enforce-parallel-worktree-removal-gate.Tests.ps1:454` keep passing.
- **D10 — Default resolution mock in existing suites.** Every existing suite that dot-sources a converted gate and calls its decision function receives exactly one line (DT-LINE, Appendix C0) in the relevant `BeforeAll`, returning a `SessionRoot` target at `/synthetic-worktrees/default-session`. Gates read only the `Status`, `WorktreeRoot`, `ReasonCode`, and `Detail` fields of a target, so the four-field literal is sufficient. Existing read-seam unit rows that call a seam with no argument pass a test-local absolute synthetic path; their assertion lines are unchanged.
- **D11 — Isolation-guard helper extraction.** The guard's pure helper functions (current lines 31-187) move to a dot-sourced test helper `tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1`, following the `WorktreeResolutionFixture.Helpers.ps1` precedent, so the guard can grow the new seam checks within 500 lines.
- **D12 — Test seam choice.** No new committed fixture is added. Gate rows use a mocked resolution seam or the real resolver over mocked `Get-WorktreeItemLiveRoot` / `Get-WorktreeRunCheckpointText` (module scope `WorktreeRunResolution`) plus a mocked read seam that returns in-memory JSON. Synthetic roots use the `/synthetic-worktrees/<name>` form.
- **D13 — Live #770 epic copy-drift stop (revision 1.1).** A running #770 epic orchestrator keeps two copies of its epic checkpoint: one in the epic worktree `2026-09-29T14-15-epic-770` and one at this worktree's root. From 22:45Z on 2026-09-29 the orchestrator writes every `epic-orchestrator-state.json` update and every `artifacts/orchestration/epic-child-launches/**` update to both copies, epic worktree first, and keeps them byte-identical. After a gate is converted, the resolver prefers the worktree that has the integration branch checked out and therefore reads the epic-worktree copy; that is the intended behavior. The remaining risk is that the two copies differ at the moment a gate is converted. Before every gate phase (Phases 3-10) the executor runs the read-only copy-drift probe (A10 `-Mode drift`), which computes the SHA-256 of both copies. The phase proceeds when the session-root copy is absent, or when both copies exist and are identical, or when only the session-root copy exists. When both copies exist and their hashes differ, the probe re-probes once after 30 seconds, so a single in-between write by the #770 orchestrator does not halt the run; it halts with `EPIC-770-COPY-DRIFT` only when the re-probe still finds both copies present with different hashes. Both hashes (or `ABSENT`) are recorded in WLOG for every probe. The plan never writes, moves, or deletes either copy.
- **D14 — Final deny texts.** Each converted gate keeps every existing deny text for resolved targets. Deny texts that named a relative checkpoint literal keep it quoted and add the resolved worktree, in the form `'<relative literal>' in worktree '<root>'`.

## Execution Conventions

### Terms used in every task

- FEATURE means `docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690`.
- BRANCH means `bug/agent-payload-gates-resolve-session-root-690`.
- PLAN means `docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/plan.2026-09-29T22-17.md` (this file).
- CB means `extensions/drm-copilot/resources/claude-customizations`.
- WRR means `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1`; WIR means `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1`; ESR means `.claude/lib/worktree-resolution/EpicScopeResolution.psm1`.
- PRE means `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`; PRES means `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`.
- WAVE means `.claude/hooks/enforce-epic-wave-barrier.ps1`; COH means `.claude/hooks/enforce-parallel-cohort-barrier.ps1`.
- MRG means `.claude/hooks/enforce-epic-merge-gate.ps1`; MRGR means `.claude/hooks/enforce-epic-merge-gate-resolution.ps1` (new).
- EREM means `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`; EREMR means `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1` (new).
- PREM means `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`; DRIFT means `.claude/hooks/enforce-parallel-drift-gate.ps1`.
- RUNSET means `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`; RUNSETB means `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`.
- CORE means `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`.
- GUARD means `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1`; GUARDH means `tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1` (new).
- New test files (row counts fixed by Appendix C): T-SIG `tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Signal.Tests.ps1` (16), T-RUN `tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Tests.ps1` (22), T-REC `tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1` (27), T-ESR `tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.RunTarget.Tests.ps1` (4), G1A `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1` (15), G1B `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1` (10), G2 `tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1` (9), G3 `tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1` (7), G4 `tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1` (10), G5 `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1` (6), G6 `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1` (6), G7 `tests/scripts/claude-hooks/enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1` (6).
- WLOG means `FEATURE/evidence/qa-gates/gate-wiring-order.md`, the running write-order and suite-result log (Appendix J).
- TS means the execution time of the task in `yyyy-MM-ddTHH-mm` form.
- SCRATCH means the executor's session scratchpad directory, outside the repository and never committed. Artifacts record it as the literal token SCRATCH, never as a host path.
- BASE_SHA means the merge-base commit recorded by P0-T8.
- Every command-step evidence artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. An artifact whose expected exit code is not 0 also carries `ExpectedExitCode:`. PowerShell test-step artifacts that name coverage record numeric `LinePercent=` values in `Output Summary:`.
- KL-510 is the known local failure of issue #510 in node `test_bundled_claude_payload_contains_all_repo_runtime_contracts` of `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`: gitignored files under `.claude/state/` are reported missing from the bundle. A run of that node satisfies KL-510 in exactly two cases. Case (a): the node prints PASSED; the artifact carries `KL-510: PASSED`. Case (b): the node fails, its assertion message is the literal "Repo file missing from bundle:" followed by a path whose first two components are `.claude` and `state`, and no output line contains "Bundle content differs from repo for:"; the artifact carries `KL-510: STATE-ONLY`, quotes the assertion message, and carries `ExpectedExitCode: 1`. Any other outcome stops the task.
- DT-LINE is the one-line default resolution mock of Appendix C0.

### Evidence location

Every evidence artifact lives under `FEATURE/evidence/<kind>/` with kind one of `baseline`, `regression-testing`, `qa-gates`, or `other`. No artifact is written under `artifacts/`. Coverage XML and report files written by scratch scripts go to SCRATCH. The caller supplied no non-canonical evidence path, so no override record is needed.

### Shell route

- The worktree isolation hook refuses Bash-tool command text containing the words bash, pwsh, or wsl, heredocs, compound commands, cd-chains, or xargs. Every git, poetry, cp, and sh command in this plan is one plain command with literal arguments, and no commit message contains any of those three words.
- Every PowerShell script runs through scratch script A1: `sh SCRATCH/run-ps.sh SCRATCH/<script>.ps1 <args>`. Glob arguments are expanded by the shell before the script runs.
- Bundle mirrors are produced by `cp` from the primary file, never through Write or Edit, so they are byte-identical.

### Live-hook rules (spec Constraints and Risks)

The session executing this plan runs this worktree's hooks, and each converted hook takes effect on the next tool call.

- **LH-1 Live files.** A live file is any file under `.claude/hooks/` and the modules a hook imports: WIR and ESR (WRR becomes live in Phase 3). A live file is changed only through the Staged Write procedure SW; it is never changed with the Edit tool.
- **LH-2 Staged Write procedure (SW).** SW-1: write the complete new content to `SCRATCH/stage/<file name>`. SW-2: run CMD-PS-SCRIPT with script stage-check (A15) and `-Path SCRATCH/stage/<file name>`; the required output is the line `STAGE-CHECK ParseErrors=0 FormatChanged=False DiagnosticCount=0`; otherwise correct the staged copy and repeat SW-2. SW-3: Write the staged content to the repository path in one Write call carrying the whole file. SW-4: run CMD-PS-SCRIPT with script file-hashes (A5) over the staged copy and the repository path; the two `Hash=` values are equal. SW-5: append the WLOG entry. A corrective second Write of a live file follows SW again and its WLOG entry states the reason; no live file is ever changed by a partial Edit.
- **LH-3 Order.** Each gate phase stages every live file it changes, checks each staged copy, and only then performs the SW-3 writes back to back, sibling first. The gate's Pester suites run in the same phase, after the last SW-3 write and before any live file of another gate is written; bundle mirrors are not live files.
- **LH-4 Stop rule for hook denials.** If any hook denies a Write, Edit, Bash command, or Agent call in this plan, stop and report the verbatim denial text. Do not bypass the hook through another tool, do not edit any file under `artifacts/orchestration/`, and do not disable a hook.
- **LH-5 Protected state.** No task writes, moves, or deletes `artifacts/orchestration/orchestrator-state.json`, `artifacts/orchestration/epic-orchestrator-state.json`, anything under `artifacts/orchestration/epic-child-launches/`, any file under `.codex/`, the #769 batch-budget hooks, `.claude/hooks/validate-orchestrator-output.ps1`, WorktreeResolution.psm1, or the gate helpers file.
- **LH-6 Import order inside hooks.** A hook that imports both WRR and ESR imports WRR (and WIR) before ESR, so ESR's nested non-forced import reuses the same module instance that tests mock.

### Toolchain loop rule

Each implementation phase runs, after its writes: MCP-PS-FORMAT over the phase's folders, a read-only A6 check, a `git status --porcelain` check, MCP-PS-ANALYZE, an A7 count, and the phase's A2 suite runs (the per-phase loop). If any step fails or changes a tracked file, fix the cause and restart that phase's loop from its format task. Phase 12 is the final PowerShell QA loop (format, analyze, test with coverage; PowerShell has no type-check stage per `.claude/rules/powershell.md`). Phase 13 runs the Python parity harness; no Python source file is created or changed, which P13-T3 verifies, so black, ruff, pyright, and Python coverage gates have no in-scope file.

### Commit rule

Each phase ends with a commit-and-push task. CMD-GIT-ADD names paths explicitly (files, the FEATURE evidence directory, or the plan file); `git add -A` and `git add .` are not used. CMD-GIT-COMMIT uses a conventional message and appends the two required trailer lines. A phase interrupted before its commit task leaves only the previous phase's pushed, green state as the recoverable state. Every phase-ending CMD-GIT-ADD includes PLAN. A commit task's own check-off is written after its status check and is carried by the next commit.

### Command catalogue

Angle-bracket fields are filled from the task text. Commands run from the worktree root.

```text
CMD-GIT-BRANCH        git rev-parse --abbrev-ref HEAD
CMD-GIT-HEAD          git rev-parse HEAD
CMD-GIT-FETCH-MAIN    git fetch origin main
CMD-GIT-MERGE-BASE    git merge-base HEAD origin/main
CMD-GIT-STATUS        git status --porcelain
CMD-GIT-STATUS-PATH   git status --porcelain -- <pathspec>
CMD-GIT-COUNT         git grep -c -F -e '<literal>' -- <paths>
CMD-GIT-ADD           git add -- <exact paths listed in the task>
CMD-GIT-COMMIT        git commit -m "<message given in the task>" --trailer "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>" --trailer "Claude-Session: https://claude.ai/code/session_01Pij9yfzq7FBzpYvqjejUYn"
CMD-GIT-PUSH          git push -u origin bug/agent-payload-gates-resolve-session-root-690
CMD-CP                cp <primary> <mirror>

CMD-PY-TEST           poetry run pytest -v <test files listed in the task>
CMD-PY-PARITY         poetry run pytest -v tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py

CMD-PS-SCRIPT         sh SCRATCH/run-ps.sh SCRATCH/<script>.ps1 <args>
MCP-PS-FORMAT         mcp__drm-copilot__run_poshqc_format   (workspace_root = worktree root, scan_folders = folders listed in the task)
MCP-PS-ANALYZE        mcp__drm-copilot__run_poshqc_analyze  (same arguments)
MCP-PS-TEST           mcp__drm-copilot__run_poshqc_test     (workspace_root = worktree root)
```

CMD-GIT-COUNT literals are always wrapped in single quotes; the literal named in a task is the text between the quotes. `git grep` searches tracked files only, so a CMD-GIT-COUNT task never targets a file that is untracked at that point.

### Observed success outputs that acceptance conditions rely on

- The PoshQC MCP tools return a fixed summary string composed before the child process runs, with no exit code and no test output. Their only observable signal is whether the call returns or raises. Every count, percentage, and finding is read from scratch scripts A2, A3, A6, A7, and A15, never from an MCP result. Artifacts record the MCP call disposition as `EXIT_CODE: 0` when the call returned and non-zero when it raised.
- The scratch scripts print their result lines by construction (Appendix H): A2 prints `TotalCount=`, `PassedCount=`, `FailedCount=`, and one `FAILED:` line per failed test; A3 adds one `COVERAGE file=... LinePercent=` line and `HIT`/`MISSED` lines per coverage file; A6 prints `FORMAT-SUMMARY ChangedCount=`; A7 prints `PSSA-SUMMARY DiagnosticCount=`; A15 prints `STAGE-CHECK ParseErrors= FormatChanged= DiagnosticCount=`. The A2, A3, A6, and A7 formats were observed in the recorded runs of the #769 plan (`docs/features/active/2026-08-16-batch-budget-hook-lacks-orchestration-awareness-769/plan.2026-09-29T13-19.md` Appendix A and its executed Phase 9 tasks). A2 and A3 exit 0 whether or not tests fail; failures are read from their output.
- `git grep -c` prints one `path:count` line per file with a match and exits 1 with no output when nothing matches.
- `pytest -v` prints one PASSED or FAILED line per node and a final summary line.

### Search literal register

The searches in this plan use these fixed strings, quoted here so each is an explicit instruction and not an inferred phrase: "WorktreeRunResolution", "ConvertTo-WorktreeItemResolvedResult", "enforce-orchestration-preimplementation-gate.ps1", "csharp-typed-engineer", "TARGET_WORKTREE_AMBIGUOUS", "## Delegation Identity Lines", "Epic mode: true", "Parallel mode: true", "Mock Resolve-OrchestrationGateTarget", "Mock Resolve-EpicWaveBarrierTarget", "Mock Resolve-ParallelCohortBarrierTarget", "Mock Resolve-EpicMergeGateRunTarget", "Mock Resolve-EpicWorktreeGateRunTarget", "Mock Resolve-ParallelWorktreeGateRunTarget", "Mock Resolve-ParallelDriftGateTarget", "Mock Get-WorktreeRunCheckpointText", "Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeRunResolution", "Mock Resolve-WorktreeEpicTarget", "enforce-epic-merge-gate-resolution.ps1", "enforce-epic-worktree-removal-gate-resolution.ps1", "WorktreeRunResolution.psm1", "New-TemporaryFile", "GetTempFileName", "GetTempPath", "TestDrive", "Set-Content", "Out-File", "New-Item", "Remove-Item", "Copy-Item", "Move-Item", "- [x] ", "- [ ] ", "#690".

---

### Phase 0 — Policy Reads, Scratch Scripts, and Baselines

- [x] [P0-T1] Read `CLAUDE.md` and `.github/copilot-instructions.md` in full, in that order. Acceptance: both read; recorded in P0-T6.
- [x] [P0-T2] Read, in order, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `.github/instructions/python-code-change.instructions.md`, and `.github/instructions/python-unit-test.instructions.md`. Acceptance: all six read; recorded in P0-T6.
- [x] [P0-T3] Read, in order, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md`, and `.claude/rules/plan-acceptance-gates.md`. Acceptance: all five read; recorded in P0-T6.
- [x] [P0-T4] Read, in order, `.claude/rules/powershell.md`, `.claude/rules/python.md`, `.claude/rules/orchestrator-state.md`, and `.claude/rules/parallel-orchestration.md`. Acceptance: all four read; recorded in P0-T6.
- [x] [P0-T5] Read FEATURE/spec.md, FEATURE/user-story.md, FEATURE/issue.md, and FEATURE/research/2026-09-29T21-55-agent-payload-gates-session-root-research.md in full. Acceptance: all four read; recorded in P0-T6.
- [x] [P0-T6] Write the policy-read record FEATURE/evidence/baseline/phase0-instructions-read.TS.md. Acceptance: the artifact contains `Timestamp:`, `Policy Order:`, and the explicit list of the 21 files read in P0-T1 through P0-T5 in reading order.
- [x] [P0-T7] Create the 18 scratch scripts A1 through A18 of Appendix H verbatim under SCRATCH (staged copies later go under `SCRATCH/stage/`), then smoke-test with CMD-PS-SCRIPT, script line-counts (A4), argument `CLAUDE.md`. Write FEATURE/evidence/other/scratch-smoke.TS.md. Acceptance: exit 0 and one output line beginning `CLAUDE.md LineCount=`; the artifact lists the 18 script file names.
- [x] [P0-T8] Record branch state in FEATURE/evidence/baseline/branch-state.TS.md. Commands: CMD-GIT-BRANCH, CMD-GIT-FETCH-MAIN, CMD-GIT-HEAD, CMD-GIT-MERGE-BASE, CMD-GIT-STATUS. Acceptance: the branch is BRANCH; the merge-base is recorded as BASE_SHA (40 hexadecimal characters); CMD-GIT-STATUS prints only lines for the untracked plan file `FEATURE/plan.2026-09-29T22-17.md` and, when present, the untracked planner memory directory `.claude/agent-memory/atomic-planner/`. Any other line stops the plan.
- [x] [P0-T9] Verify checkpoint readiness read-only. Command: CMD-PS-SCRIPT with script checkpoint-probe (A9) and argument `artifacts/orchestration/orchestrator-state.json`. Write FEATURE/evidence/baseline/checkpoint-readiness.TS.md. Acceptance: output contains `ROUTE_ID=large`, `LIFECYCLE_READY=True`, and `ISSUE_NUM=690`. Otherwise stop and report; this plan does not write the checkpoint.
- [x] [P0-T10] Record the session-root epic checkpoint presence read-only. Command: CMD-PS-SCRIPT with script epic-coexistence-probe (A10) and `-Mode presence`. Write FEATURE/evidence/baseline/epic-coexistence.TS.md. Acceptance: exit 0 and a `SESSION_EPIC_PRESENT=` line; when it is `True`, `SESSION_EPIC_SHA256=` and `SESSION_EPIC_INTEGRATION_BRANCH=` lines are recorded. No stop at this point (D13 applies from Phase 3).
- [x] [P0-T11] Record pre-change line counts. Command: CMD-PS-SCRIPT with script line-counts (A4) over the 14 files of Appendix F group LC-BASE. Write FEATURE/evidence/baseline/line-counts.TS.md. Acceptance: exit 0 and 14 `LineCount=` lines; `.claude/lib/worktree-resolution/WorktreeResolution.psm1 LineCount=500`.
- [x] [P0-T12] Record hashes of the files that must stay byte-unchanged (Appendix F group BU). Command: CMD-PS-SCRIPT with script file-hashes (A5) over the BU files. Write FEATURE/evidence/baseline/byte-unchanged-hashes.TS.md. Acceptance: exit 0 and one `Hash=` line per BU file.
- [x] [P0-T13] Record mirror-pair hashes for the existing pairs of Appendix F group MP-EXIST. Command: CMD-PS-SCRIPT with script pair-hashes (A13) over those pairs. Write FEATURE/evidence/baseline/mirror-hashes.TS.md. Acceptance: `PAIR-SUMMARY pairs=22 unequal=0`. An unequal pair stops the plan, because a `cp` would discard a bundle-specific difference.
- [x] [P0-T14] PowerShell format baseline over the folders the MCP format calls scan. Command: CMD-PS-SCRIPT with script ps-format-check (A6) over `.claude/hooks/*.ps1 .claude/lib/worktree-resolution/*.psm1 tests/scripts/claude-hooks/*.ps1 tests/scripts/claude-lib/*.ps1 tests/scripts/claude-lib/worktree-resolution/*.ps1 scripts/powershell/PoshQC/settings/*.psd1`. Write FEATURE/evidence/baseline/powershell-format.TS.md. Acceptance: exit 0 and `FORMAT-SUMMARY ChangedCount=0`. A non-zero count stops the plan, because folder-scoped MCP format calls would otherwise rewrite files outside this item.
- [x] [P0-T15] PowerShell analyzer baseline for the existing production files this plan changes (Appendix F group PROD-EXIST). Command: CMD-PS-SCRIPT with script pssa-count (A7) over those files. Write FEATURE/evidence/baseline/powershell-analyze.TS.md. Acceptance: exit 0 and the `PSSA-SUMMARY DiagnosticCount=` value recorded.
- [x] [P0-T16] Pester baseline for suite set SET-LIB (Appendix G). Command: CMD-PS-SCRIPT with script pester-counts (A2) and `-Path` set to the SET-LIB list. Write FEATURE/evidence/baseline/pester-set-lib.TS.md. Acceptance: the artifact records `TotalCount=`, `PassedCount=`, `FailedCount=`, and every `FAILED:` line verbatim (the baseline failure set, possibly empty); the TotalCount is recorded as BASE_LIB.
- [x] [P0-T17] Pester baseline for SET-PRE. Command and artifact as P0-T16 with FEATURE/evidence/baseline/pester-set-pre.TS.md. Acceptance: as P0-T16; TotalCount recorded as BASE_PRE.
- [x] [P0-T18] Pester baseline for SET-WAVE, artifact FEATURE/evidence/baseline/pester-set-wave.TS.md. Acceptance: as P0-T16; recorded as BASE_WAVE.
- [x] [P0-T19] Pester baseline for SET-COHORT, artifact FEATURE/evidence/baseline/pester-set-cohort.TS.md. Acceptance: as P0-T16; recorded as BASE_COHORT.
- [x] [P0-T20] Pester baseline for SET-MERGE, artifact FEATURE/evidence/baseline/pester-set-merge.TS.md. Acceptance: as P0-T16; recorded as BASE_MERGE.
- [x] [P0-T21] Pester baseline for SET-EREM, artifact FEATURE/evidence/baseline/pester-set-erem.TS.md. Acceptance: as P0-T16; recorded as BASE_EREM.
- [x] [P0-T22] Pester baseline for SET-PREM, artifact FEATURE/evidence/baseline/pester-set-prem.TS.md. Acceptance: as P0-T16; recorded as BASE_PREM.
- [x] [P0-T23] Pester baseline for SET-DRIFT, artifact FEATURE/evidence/baseline/pester-set-drift.TS.md. Acceptance: as P0-T16; recorded as BASE_DRIFT.
- [x] [P0-T24] Pester baseline for SET-EPICSCOPE, artifact FEATURE/evidence/baseline/pester-set-epicscope.TS.md. Acceptance: as P0-T16; recorded as BASE_ESCOPE.
- [x] [P0-T25] Coverage baseline CG-LIB (Appendix G): CMD-PS-SCRIPT with script pester-coverage (A3) and the CG-LIB baseline arguments, `-CoverageOutputPath SCRATCH/cov-lib-base.xml -ReportPath SCRATCH/cov-lib-base.txt`. Write FEATURE/evidence/baseline/coverage-lib.TS.md. Acceptance: the artifact records `TotalCount=`, `FailedCount=`, every `FAILED:` line, and one `COVERAGE file=` line with a numeric `LinePercent=` for each coverage file (recorded as BASEPCT for that file).
- [x] [P0-T26] Coverage baseline CG-PRE, report SCRATCH/cov-pre-base.txt, artifact FEATURE/evidence/baseline/coverage-pre.TS.md. Acceptance: as P0-T25.
- [x] [P0-T27] Coverage baseline CG-WAVE, report SCRATCH/cov-wave-base.txt, artifact FEATURE/evidence/baseline/coverage-wave.TS.md. Acceptance: as P0-T25.
- [x] [P0-T28] Coverage baseline CG-COHORT, report SCRATCH/cov-cohort-base.txt, artifact FEATURE/evidence/baseline/coverage-cohort.TS.md. Acceptance: as P0-T25.
- [x] [P0-T29] Coverage baseline CG-MERGE, report SCRATCH/cov-merge-base.txt, artifact FEATURE/evidence/baseline/coverage-merge.TS.md. Acceptance: as P0-T25.
- [x] [P0-T30] Coverage baseline CG-EREM, report SCRATCH/cov-erem-base.txt, artifact FEATURE/evidence/baseline/coverage-erem.TS.md. Acceptance: as P0-T25.
- [x] [P0-T31] Coverage baseline CG-PREM, report SCRATCH/cov-prem-base.txt, artifact FEATURE/evidence/baseline/coverage-prem.TS.md. Acceptance: as P0-T25.
- [x] [P0-T32] Coverage baseline CG-DRIFT, report SCRATCH/cov-drift-base.txt, artifact FEATURE/evidence/baseline/coverage-drift.TS.md. Acceptance: as P0-T25.
- [x] [P0-T33] Pester folder baseline for `tests/scripts/claude-hooks`. Command: CMD-PS-SCRIPT with script pester-counts (A2) and `-Path tests/scripts/claude-hooks`. Write FEATURE/evidence/baseline/pester-claude-hooks.TS.md. Acceptance: counts and every `FAILED:` line recorded; TotalCount recorded as BASE_HOOKS.
- [x] [P0-T34] Pester folder baseline for `tests/scripts/claude-lib`, artifact FEATURE/evidence/baseline/pester-claude-lib.TS.md. Acceptance: as P0-T33; recorded as BASE_CLIB.
- [x] [P0-T35] Pester folder baseline for `tests/scripts/claude-runtime`, artifact FEATURE/evidence/baseline/pester-claude-runtime.TS.md. Acceptance: as P0-T33; recorded as BASE_RUNTIME.
- [x] [P0-T36] Pester folder baseline for `tests/scripts/codex-hooks`, artifact FEATURE/evidence/baseline/pester-codex-hooks.TS.md. Acceptance: as P0-T33; recorded as BASE_CODEX.
- [x] [P0-T37] Python parity baseline. Command: CMD-PY-PARITY. Write FEATURE/evidence/baseline/python-parity.TS.md. Acceptance: every node other than `test_bundled_claude_payload_contains_all_repo_runtime_contracts` is PASSED and that node satisfies KL-510.
- [x] [P0-T38] Python regression baseline for `tests/scripts/dev_tools`. Command: `poetry run pytest tests/scripts/dev_tools -q -rf`. Write FEATURE/evidence/baseline/python-dev-tools.TS.md. Acceptance: the summary line (passed, failed, skipped counts) and every `FAILED` line recorded verbatim. When the KL-510 node is the only FAILED line and satisfies case (b), the artifact carries `ExpectedExitCode: 1`.
- [x] [P0-T39] Commit and push Phase 0. Commands: CMD-GIT-ADD with `docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/plan.2026-09-29T22-17.md docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/evidence` plus `.claude/agent-memory/atomic-planner` when P0-T8 recorded it, CMD-GIT-COMMIT with message "docs(690): add implementation plan and baseline evidence", CMD-GIT-PUSH. Acceptance: CMD-GIT-STATUS prints nothing and the push exits 0.

### Phase 1 — Run-Resolution Module (No Hook Importer)

- [x] [P1-T1] Write WRR (`.claude/lib/worktree-resolution/WorktreeRunResolution.psm1`) per Appendix B1 in one Write call. Nothing imports it yet, so it is not live. Acceptance: CMD-PS-SCRIPT with script stage-check (A15) and `-Path .claude/lib/worktree-resolution/WorktreeRunResolution.psm1` prints `STAGE-CHECK ParseErrors=0 FormatChanged=False DiagnosticCount=0`; CMD-PS-SCRIPT with script line-counts (A4) over WRR prints a `LineCount=` value of at most 500.
- [x] [P1-T2] Change WIR (`.claude/lib/worktree-resolution/WorktreeItemResolution.psm1`) per Appendix B2 through SW (WIR is live: two hooks import it). Acceptance: SW-2 prints `STAGE-CHECK ParseErrors=0 FormatChanged=False DiagnosticCount=0`; SW-4 hashes are equal; CMD-GIT-COUNT with literal `ConvertTo-WorktreeItemResolvedResult` over WIR prints `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1:6` (5 lines at baseline plus the export line). WLOG is created with this first entry (Appendix J).
- [x] [P1-T3] Write T-SIG (`tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Signal.Tests.ps1`) per Appendix C1 (16 rows). Acceptance: the Write succeeds without a hook denial; A4 over T-SIG prints a `LineCount=` value of at most 500. The row count is verified by P1-T12.
- [x] [P1-T4] Write T-RUN (`tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Tests.ps1`) per Appendix C2 (22 rows). Acceptance: as P1-T3.
- [x] [P1-T5] Write T-REC (`tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1`) per Appendix C3 (27 rows). Acceptance: as P1-T3.
- [x] [P1-T6] Edit `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1`: append the entry `'.claude/lib/worktree-resolution/WorktreeRunResolution.psm1'` after the `EpicScopeReadiness.psm1` entry in each of its four lists (lines 32, 42, 56, 86). Acceptance: CMD-GIT-COUNT with literal `WorktreeRunResolution.psm1` over that file prints a count of 4.
- [x] [P1-T7] Edit CORE: insert the line `    ".claude/lib/worktree-resolution/WorktreeRunResolution.psm1",` immediately after line 187 (the `EpicScopeReadiness.psm1` entry). Acceptance: CMD-PS-SCRIPT with script json-parse (A12) over CORE prints `JSON-OK`; CMD-GIT-COUNT with literal `WorktreeRunResolution.psm1` over CORE prints a count of 1.
- [x] [P1-T8] Edit RUNSET: insert the two lines `            # Issue #690 added the run-target resolver; registered so it stays in the coverage denominator.` and `            '.claude/lib/worktree-resolution/WorktreeRunResolution.psm1'` immediately after line 320. Then CMD-CP from RUNSET to RUNSETB. Acceptance: CMD-PS-SCRIPT with script psd1-parse (A8) over RUNSET and RUNSETB prints two `PSD1-OK` lines; CMD-GIT-COUNT with literal `WorktreeRunResolution.psm1` over RUNSET and RUNSETB prints a count of 1 for each; CMD-PS-SCRIPT with script pair-hashes (A13) over the pair prints `PAIR-SUMMARY pairs=1 unequal=0`.
- [x] [P1-T9] Mirror WRR and WIR into CB. Commands: CMD-CP `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` and CMD-CP `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/WorktreeItemResolution.psm1`. Acceptance: A13 over the two pairs prints `PAIR-SUMMARY pairs=2 unequal=0`.
- [x] [P1-T10] Format. Commands: MCP-PS-FORMAT with scan_folders `.claude/lib/worktree-resolution`, `tests/scripts/claude-lib/worktree-resolution`, `scripts/powershell/PoshQC/settings`; CMD-GIT-STATUS; CMD-PS-SCRIPT with script ps-format-check (A6) over WRR, WIR, T-SIG, T-RUN, T-REC, and the manifest test. Write FEATURE/evidence/qa-gates/format-p1.TS.md. Acceptance: the MCP call returns without raising; CMD-GIT-STATUS names no path outside P1-FILES, the FEATURE evidence directory, and the plan file; A6 prints `FORMAT-SUMMARY ChangedCount=0`.
- [x] [P1-T11] Analyze. Commands: MCP-PS-ANALYZE with the P1-T10 scan_folders, then CMD-PS-SCRIPT with script pssa-count (A7) over the six P1-T10 files. Write FEATURE/evidence/qa-gates/analyze-p1.TS.md. Acceptance: the MCP call returns without raising and A7 prints `PSSA-SUMMARY DiagnosticCount=0`.
- [x] [P1-T12] Run the three new library suites. Command: CMD-PS-SCRIPT with script pester-counts (A2) and `-Path tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Signal.Tests.ps1,tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Tests.ps1,tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1`. Write FEATURE/evidence/regression-testing/lib-new-suites.TS.md. Acceptance: `TotalCount=65`, `PassedCount=65`, `FailedCount=0`.
- [x] [P1-T13] Run SET-LIB. Command: A2 over the SET-LIB list. Write FEATURE/evidence/qa-gates/pester-set-lib-p1.TS.md. Acceptance: `TotalCount=` equals BASE_LIB plus 68 (65 new rows plus 3 manifest rows), and every `FAILED:` line is a member of the P0-T16 baseline failure set.
- [x] [P1-T14] Early coverage check for WRR. Command: CMD-PS-SCRIPT with script pester-coverage (A3), `-TestPath tests/scripts/claude-lib/worktree-resolution -CoveragePath .claude/lib/worktree-resolution/WorktreeRunResolution.psm1 -CoverageOutputPath SCRATCH/cov-wrr-p1.xml -ReportPath SCRATCH/cov-wrr-p1.txt`. Write FEATURE/evidence/qa-gates/coverage-wrr-p1.TS.md. Acceptance: `FailedCount=0` and the `COVERAGE file=.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` line has `LinePercent=` of at least 85.
- [x] [P1-T15] Python parity. Command: CMD-PY-PARITY. Write FEATURE/evidence/regression-testing/python-parity-p1.TS.md. Acceptance: every node other than the KL-510 node is PASSED and that node satisfies KL-510.
- [x] [P1-T16] Confirm that no hook imports WRR and no hook file changed (AC-57). Commands: `git grep -n -F -e 'WorktreeRunResolution' -- .claude/hooks` and CMD-GIT-STATUS-PATH over `.claude/hooks`. Write FEATURE/evidence/qa-gates/no-hook-importer-p1.TS.md with `ExpectedExitCode: 1` for the search. Acceptance: the search exits 1 with no output and the status prints nothing.
- [x] [P1-T17] Probe the live topology read-only with the new module. Command: CMD-PS-SCRIPT with script epic-coexistence-probe (A10) and `-Mode resolve`. Write FEATURE/evidence/other/epic-coexistence-p1.TS.md. Acceptance: exit 0; the artifact records `SESSION_EPIC_PRESENT=` and, when present, `RESOLVED_STATUS=`, `RESOLVED_ROOT_LEAF=`, and `RESOLVED_REASON=`. This task only records; D13 is enforced from P3-T1.
- [x] [P1-T18] Line counts for the Phase 1 files. Command: A4 over WRR, WIR, T-SIG, T-RUN, T-REC, the manifest test. Write FEATURE/evidence/qa-gates/line-counts-p1.TS.md. Acceptance: every `LineCount=` value is at most 500.
- [x] [P1-T19] Commit and push Phase 1. Commands: CMD-GIT-ADD with the P1-FILES list of Appendix F plus `docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/evidence` and PLAN, CMD-GIT-COMMIT with message "feat(690): add the WorktreeRunResolution run-target resolver", CMD-GIT-PUSH. Acceptance: CMD-GIT-STATUS prints nothing and the push exits 0.

### Phase 2 — Identity Contract Text (Lands Before the Preimplementation Gate)

- [x] [P2-T1] Edit `.claude/skills/orchestrate/SKILL.md` per Appendix D1 (rewrite of the "Two gates" sentence on line 263 and one new paragraph after it). Acceptance: CMD-GIT-COUNT with literal `enforce-orchestration-preimplementation-gate.ps1` over that file prints a count of 2; CMD-GIT-COUNT with literal `csharp-typed-engineer` over that file prints a count of 1.
- [x] [P2-T2] Edit `.claude/skills/epic-orchestrate/SKILL.md` per Appendix D2 (one new paragraph after line 124). Acceptance: CMD-GIT-COUNT with literal `TARGET_WORKTREE_AMBIGUOUS` over that file prints a count of 1.
- [x] [P2-T3] Edit `.claude/skills/parallel-orchestrate/SKILL.md` per Appendix D3 (one new paragraph after line 278). Acceptance: CMD-GIT-COUNT with literal `TARGET_WORKTREE_AMBIGUOUS` over that file prints a count of 1; `git grep -n -F -e 'Epic mode: true' -- .claude/skills/parallel-orchestrate/SKILL.md` exits 1 with no output (the file's own marker prohibition, lines 269-273, still holds).
- [x] [P2-T4] Edit `.claude/skills/invoke-python-engineer/SKILL.md` per Appendix D4 with worker `python-typed-engineer` (a new section immediately before `## Worker Routing`). Acceptance: CMD-GIT-COUNT with literal `## Delegation Identity Lines` over that file prints a count of 1.
- [x] [P2-T5] Edit `.claude/skills/invoke-powershell-engineer/SKILL.md` per Appendix D4 with worker `powershell-typed-engineer`. Acceptance: as P2-T4 for that file.
- [x] [P2-T6] Edit `.claude/skills/invoke-csharp-engineer/SKILL.md` per Appendix D4 with worker `csharp-typed-engineer`. Acceptance: as P2-T4 for that file.
- [x] [P2-T7] Mirror the six skills into CB with six CMD-CP commands (primary `.claude/skills/<name>/SKILL.md`, mirror `extensions/drm-copilot/resources/claude-customizations/.claude/skills/<name>/SKILL.md`). Acceptance: A13 over the six pairs prints `PAIR-SUMMARY pairs=6 unequal=0`.
- [x] [P2-T8] Record the contract-text token counts of P2-T1 through P2-T6. Commands: the seven CMD-GIT-COUNT commands of those tasks (two for the orchestrate skill, one each for the other five) re-run in order. Write FEATURE/evidence/qa-gates/skill-contract-p2.TS.md. Acceptance: the artifact records each command and its `path:count` output, and every count equals the value its task requires.
- [x] [P2-T9] Negative marker check on the orchestrate skill. Command: `git grep -n -F -e 'Parallel mode: true' -- .claude/skills/orchestrate/SKILL.md`. Write FEATURE/evidence/qa-gates/skill-markers-p2.TS.md with `ExpectedExitCode: 1`. Acceptance: exit 1 with no output (research section 3 row 12 records that the orchestrate skill carries no parallel marker; the D1 text does not add one).
- [x] [P2-T10] Python parity. Command: CMD-PY-PARITY. Write FEATURE/evidence/regression-testing/python-parity-p2.TS.md. Acceptance: every node other than the KL-510 node is PASSED and that node satisfies KL-510.
- [ ] [P2-T11] Commit and push Phase 2. Commands: CMD-GIT-ADD with the six primary skill files, their six CB mirrors, the FEATURE evidence directory, and PLAN; CMD-GIT-COMMIT with message "docs(690): extend the delegation identity contract to implementation agents"; CMD-GIT-PUSH. Acceptance: CMD-GIT-STATUS prints nothing and the push exits 0.

### Phase 3 — Preimplementation Gate

- [ ] [P3-T1] D13 copy-drift gate (read-only). Command: CMD-PS-SCRIPT with script epic-coexistence-probe (A10) and `-Mode drift -EpicWorktreeRoot ../2026-09-29T14-15-epic-770`. Write FEATURE/evidence/qa-gates/epic-copy-drift-p3.TS.md and append one WLOG row carrying the `SESSION_EPIC_SHA256=` and `EPIC_WORKTREE_SHA256=` values (a hash or `ABSENT`) and the `FIRST_COPY_DRIFT=` and `COPY_DRIFT=` values (the script re-probes once after 30 seconds when the first probe finds drift; the recorded hashes are those of the last probe). Acceptance: output contains `COPY_DRIFT=False` (session-root copy absent, epic-worktree copy absent, or both present with equal hashes after at most one re-probe). Output containing `COPY_DRIFT=True` (both present, hashes still differ after the re-probe) stops the plan with the report line `EPIC-770-COPY-DRIFT` and both hashes; the plan writes neither copy.
- [ ] [P3-T2] AC-59 identity confirmation. Command: CMD-PS-SCRIPT with script identity-probe (A16) and arguments `-IssueNumber 690 -Branch bug/agent-payload-gates-resolve-session-root-690`. Write FEATURE/evidence/qa-gates/pending-delegation-identity.TS.md recording the probe output and the list of implementation delegations the executor has pending (expected: none issued by the executor itself; the orchestrator's re-delegations of this plan carry both lines). Acceptance: output contains `IDENTITY_STATUS=SessionRoot`; the artifact states the pending-delegation list explicitly.
- [ ] [P3-T3] Stage and check PRES and PRE (SW-1 and SW-2 for both, per Appendix B3 and B4). Acceptance: A15 prints `STAGE-CHECK ParseErrors=0 FormatChanged=False DiagnosticCount=0` for `SCRATCH/stage/enforce-orchestration-preimplementation-gate-epic-scope.ps1` and for `SCRATCH/stage/enforce-orchestration-preimplementation-gate.ps1`; A4 over the staged PRE prints a `LineCount=` value of at most 500.
- [ ] [P3-T4] SW-3 for PRES (sibling first, D5). Acceptance: the Write succeeds without a hook denial.
- [ ] [P3-T5] SW-3 for PRE, as the next repository write after P3-T4. Acceptance: the Write succeeds without a hook denial.
- [ ] [P3-T6] SW-4 for PRES and PRE, then append the two WLOG entries (SW-5). Acceptance: both hash pairs are equal; WLOG records PRES then PRE with their timestamps.
- [ ] [P3-T7] Write G1A per Appendix C5 (15 rows). This is the first repository Write evaluated by the converted gate's path leg. Acceptance: the Write succeeds without a hook denial (live evidence that a Write inside the session worktree resolves `SessionRoot` and is admitted); WLOG records it.
- [ ] [P3-T8] Write G1B per Appendix C6 (10 rows). Acceptance: the Write succeeds without a hook denial.
- [ ] [P3-T9] Add DT-LINE with seam `Resolve-OrchestrationGateTarget` as the last statement of the outermost `BeforeAll` of each of the eight suites of Appendix G group EXIST-PRE, and pass `-Path $script:EpicSeamPath` / `-Path $script:ParallelSeamPath` in the four act lines at `enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1` lines 268, 283, 296, 310 (assertion lines unchanged). Acceptance: CMD-GIT-COUNT with literal `Mock Resolve-OrchestrationGateTarget` over the eight EXIST-PRE files prints eight lines, each with count 1.
- [ ] [P3-T10] Mirror PRES and PRE into CB with two CMD-CP commands. Acceptance: A13 over the two pairs prints `PAIR-SUMMARY pairs=2 unequal=0`.
- [ ] [P3-T11] Format. Commands: MCP-PS-FORMAT with scan_folders `.claude/hooks` and `tests/scripts/claude-hooks`; CMD-GIT-STATUS; A6 over PRES, PRE, G1A, G1B, and the EXIST-PRE files. Write FEATURE/evidence/qa-gates/format-p3.TS.md. Acceptance: the MCP call returns without raising; CMD-GIT-STATUS names no path outside P3-FILES, the FEATURE evidence directory, and the plan file; A6 prints `FORMAT-SUMMARY ChangedCount=0`.
- [ ] [P3-T12] Analyze. Commands: MCP-PS-ANALYZE with the P3-T11 scan_folders; A7 over the P3-T11 files. Write FEATURE/evidence/qa-gates/analyze-p3.TS.md. Acceptance: the MCP call returns without raising and `PSSA-SUMMARY DiagnosticCount=0`.
- [ ] [P3-T13] Run G1A and G1B. Command: A2 with `-Path tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1,tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1`. Write FEATURE/evidence/regression-testing/pre-worktree-resolution.TS.md and append the result to WLOG. Acceptance: `TotalCount=25`, `PassedCount=25`, `FailedCount=0`.
- [ ] [P3-T14] Run SET-PRE. Command: A2 over the SET-PRE list. Write FEATURE/evidence/qa-gates/pester-set-pre-p3.TS.md and append the result to WLOG. Acceptance: `TotalCount=` equals BASE_PRE plus 25, and every `FAILED:` line is a member of the P0-T17 baseline failure set.
- [ ] [P3-T15] Confirm the modes and helpers files are byte-unchanged (AC-54, AC-56). Commands: `git diff --exit-code BASE_SHA -- .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` and CMD-GIT-STATUS-PATH over the same two files. Write FEATURE/evidence/qa-gates/pre-siblings-unchanged.TS.md. Acceptance: the diff exits 0 with no output and the status prints nothing.
- [ ] [P3-T16] Line counts for PRE, PRES, G1A, G1B, and the EXIST-PRE files. Command: A4. Write FEATURE/evidence/qa-gates/line-counts-p3.TS.md. Acceptance: every `LineCount=` value is at most 500.
- [ ] [P3-T17] Python parity. Command: CMD-PY-PARITY. Write FEATURE/evidence/regression-testing/python-parity-p3.TS.md. Acceptance: every node other than the KL-510 node is PASSED and that node satisfies KL-510.
- [ ] [P3-T18] Commit and push Phase 3. Commands: CMD-GIT-ADD with the P3-FILES list, the FEATURE evidence directory, and PLAN, CMD-GIT-COMMIT with message "fix(690): resolve the preimplementation gate checkpoint from the call target", CMD-GIT-PUSH. Acceptance: the `git add` and `git commit` commands are admitted by the converted gate (live evidence for the command leg with no `-C` selector); CMD-GIT-STATUS prints nothing and the push exits 0.

### Phase 4 — Epic Wave Barrier

- [ ] [P4-T1] D13 copy-drift gate (read-only). Command, WLOG row, and acceptance as P3-T1, artifact FEATURE/evidence/qa-gates/epic-copy-drift-p4.TS.md.
- [ ] [P4-T2] Stage and check WAVE per Appendix B5 (SW-1, SW-2). Acceptance: A15 prints `STAGE-CHECK ParseErrors=0 FormatChanged=False DiagnosticCount=0` for `SCRATCH/stage/enforce-epic-wave-barrier.ps1`.
- [ ] [P4-T3] SW-3 for WAVE. Acceptance: the Write succeeds without a hook denial.
- [ ] [P4-T4] SW-4 for WAVE and the WLOG entry. Acceptance: hashes equal; WLOG records WAVE.
- [ ] [P4-T5] Write G2 per Appendix C7 (9 rows). Acceptance: the Write succeeds without a hook denial.
- [ ] [P4-T6] Edit `tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1`: add DT-LINE with seam `Resolve-EpicWaveBarrierTarget` as the last statement of its `BeforeAll` (line 11 region); in the two read-seam rows (lines 177-186) define `$seamPath = '/synthetic-worktrees/wave-seam/artifacts/orchestration/epic-orchestrator-state.json'`, pass `-Path $seamPath` to `Get-EpicWaveBarrierCheckpointContent`, and compare the `Test-Path`/`Get-Content` ParameterFilters to `$seamPath`; the `Should` assertion lines are unchanged. Acceptance: CMD-GIT-COUNT with literal `Mock Resolve-EpicWaveBarrierTarget` over that file prints a count of 1.
- [ ] [P4-T7] Mirror WAVE into CB with CMD-CP. Acceptance: A13 over the pair prints `PAIR-SUMMARY pairs=1 unequal=0`.
- [ ] [P4-T8] Format: MCP-PS-FORMAT with scan_folders `.claude/hooks` and `tests/scripts/claude-hooks`; CMD-GIT-STATUS; A6 over WAVE, G2, and the edited suite. Write FEATURE/evidence/qa-gates/format-p4.TS.md. Acceptance: the MCP call returns without raising; CMD-GIT-STATUS names no path outside P4-FILES, the FEATURE evidence directory, and the plan file; `FORMAT-SUMMARY ChangedCount=0`.
- [ ] [P4-T9] Analyze: MCP-PS-ANALYZE with the P4-T8 scan_folders; A7 over the three P4-T8 files. Write FEATURE/evidence/qa-gates/analyze-p4.TS.md. Acceptance: the MCP call returns and `PSSA-SUMMARY DiagnosticCount=0`.
- [ ] [P4-T10] Run G2. Command: A2 with `-Path tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1`. Write FEATURE/evidence/regression-testing/wave-worktree-resolution.TS.md and append to WLOG. Acceptance: `TotalCount=9`, `PassedCount=9`, `FailedCount=0`.
- [ ] [P4-T11] Run SET-WAVE. Command: A2 over the SET-WAVE list. Write FEATURE/evidence/qa-gates/pester-set-wave-p4.TS.md and append to WLOG. Acceptance: `TotalCount=` equals BASE_WAVE plus 9 and every `FAILED:` line is a member of the P0-T18 baseline failure set.
- [ ] [P4-T12] AC-26 check. Command: CMD-PS-SCRIPT with script function-text-compare (A14), `-Path .claude/hooks/enforce-epic-wave-barrier.ps1 -FunctionName Find-EpicWaveBarrierFeatureFolderFromPrompt -BaseRef BASE_SHA` (BASE_SHA replaced by the recorded commit). Write FEATURE/evidence/qa-gates/wave-folder-function-unchanged.TS.md. Acceptance: output contains `FUNCTION-FOUND current=True base=True` and `FUNCTION-TEXT-EQUAL=True`.
- [ ] [P4-T13] Line counts for WAVE, G2, and the edited suite (A4). Write FEATURE/evidence/qa-gates/line-counts-p4.TS.md. Acceptance: every value is at most 500.
- [ ] [P4-T14] Python parity (CMD-PY-PARITY). Write FEATURE/evidence/regression-testing/python-parity-p4.TS.md. Acceptance: as P3-T17.
- [ ] [P4-T15] Commit and push Phase 4. Commands: CMD-GIT-ADD with the P4-FILES list, the FEATURE evidence directory, and PLAN, CMD-GIT-COMMIT with message "fix(690): resolve the epic wave barrier checkpoint from integration_branch", CMD-GIT-PUSH. Acceptance: CMD-GIT-STATUS prints nothing and the push exits 0.

### Phase 5 — Parallel Cohort Barrier

- [ ] [P5-T1] D13 copy-drift gate (read-only). Command, WLOG row, and acceptance as P3-T1, artifact FEATURE/evidence/qa-gates/epic-copy-drift-p5.TS.md.
- [ ] [P5-T2] Stage and check COH per Appendix B6 (SW-1, SW-2). Acceptance: A15 prints `STAGE-CHECK ParseErrors=0 FormatChanged=False DiagnosticCount=0` for `SCRATCH/stage/enforce-parallel-cohort-barrier.ps1`.
- [ ] [P5-T3] SW-3 for COH. Acceptance: the Write succeeds without a hook denial.
- [ ] [P5-T4] SW-4 for COH and the WLOG entry. Acceptance: hashes equal; WLOG records COH.
- [ ] [P5-T5] Write G3 per Appendix C8 (7 rows). Acceptance: the Write succeeds without a hook denial.
- [ ] [P5-T6] Edit `tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1` and `tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Payload.Tests.ps1`: add DT-LINE with seam `Resolve-ParallelCohortBarrierTarget` as the last statement of each suite's hook-loading `BeforeAll`; in the two read-seam rows of the first suite (lines 446 and 452) pass `-Path` a test-local absolute synthetic path and compare the ParameterFilters to it, leaving assertion lines unchanged. Acceptance: CMD-GIT-COUNT with literal `Mock Resolve-ParallelCohortBarrierTarget` over the two files prints two lines, each with count 1.
- [ ] [P5-T7] Mirror COH into CB with CMD-CP. Acceptance: A13 prints `PAIR-SUMMARY pairs=1 unequal=0`.
- [ ] [P5-T8] Format: MCP-PS-FORMAT (scan_folders `.claude/hooks`, `tests/scripts/claude-hooks`); CMD-GIT-STATUS; A6 over COH, G3, and the two edited suites. Write FEATURE/evidence/qa-gates/format-p5.TS.md. Acceptance: the MCP call returns; CMD-GIT-STATUS names no path outside P5-FILES, the FEATURE evidence directory, and the plan file; `FORMAT-SUMMARY ChangedCount=0`.
- [ ] [P5-T9] Analyze: MCP-PS-ANALYZE; A7 over the four P5-T8 files. Write FEATURE/evidence/qa-gates/analyze-p5.TS.md. Acceptance: the MCP call returns and `PSSA-SUMMARY DiagnosticCount=0`.
- [ ] [P5-T10] Run G3 (A2 with `-Path tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1`). Write FEATURE/evidence/regression-testing/cohort-worktree-resolution.TS.md and append to WLOG. Acceptance: `TotalCount=7`, `PassedCount=7`, `FailedCount=0`.
- [ ] [P5-T11] Run SET-COHORT (A2). Write FEATURE/evidence/qa-gates/pester-set-cohort-p5.TS.md and append to WLOG. Acceptance: `TotalCount=` equals BASE_COHORT plus 7 and every `FAILED:` line is a member of the P0-T19 baseline failure set.
- [ ] [P5-T12] Line counts for COH, G3, and the two edited suites (A4). Write FEATURE/evidence/qa-gates/line-counts-p5.TS.md. Acceptance: every value is at most 500.
- [ ] [P5-T13] Python parity (CMD-PY-PARITY). Write FEATURE/evidence/regression-testing/python-parity-p5.TS.md. Acceptance: as P3-T17.
- [ ] [P5-T14] Commit and push Phase 5. Commands: CMD-GIT-ADD with P5-FILES, the FEATURE evidence directory, and PLAN, CMD-GIT-COMMIT with message "fix(690): resolve the parallel cohort barrier checkpoint from parallel_slug", CMD-GIT-PUSH. Acceptance: CMD-GIT-STATUS prints nothing and the push exits 0.

### Phase 6 — Merge Gate

- [ ] [P6-T1] D13 copy-drift gate (read-only). Command, WLOG row, and acceptance as P3-T1, artifact FEATURE/evidence/qa-gates/epic-copy-drift-p6.TS.md.
- [ ] [P6-T2] Stage and check MRGR and MRG per Appendix B7 (SW-1, SW-2 for both). Acceptance: A15 prints the clean `STAGE-CHECK` line for `SCRATCH/stage/enforce-epic-merge-gate-resolution.ps1` and for `SCRATCH/stage/enforce-epic-merge-gate.ps1`.
- [ ] [P6-T3] SW-3 for MRGR (new sibling; the old gate does not dot-source it). Acceptance: the Write succeeds without a hook denial.
- [ ] [P6-T4] SW-3 for MRG, as the next repository write after P6-T3. Acceptance: the Write succeeds without a hook denial.
- [ ] [P6-T5] SW-4 for MRGR and MRG and the two WLOG entries. Acceptance: both hash pairs equal; WLOG records MRGR then MRG.
- [ ] [P6-T6] Write G4 per Appendix C9 (10 rows). Acceptance: the Write succeeds without a hook denial.
- [ ] [P6-T7] Add DT-LINE with seam `Resolve-EpicMergeGateRunTarget` as the last statement of the hook-loading `BeforeAll` of each EXIST-MERGE suite (Appendix G), and in the six read-seam rows of `enforce-epic-merge-gate.Tests.ps1` (lines 235, 241, 294, 300, 305, 311) pass `-Path` a test-local absolute synthetic path and compare the ParameterFilters to it, leaving assertion lines unchanged. Acceptance: CMD-GIT-COUNT with literal `Mock Resolve-EpicMergeGateRunTarget` over the four EXIST-MERGE files prints four lines, each with count 1.
- [ ] [P6-T8] Edit CORE: insert `    ".claude/hooks/enforce-epic-merge-gate-resolution.ps1",` immediately after the line `    ".claude/hooks/enforce-epic-merge-gate-authorization.ps1",`. Edit RUNSET: insert `            '.claude/hooks/enforce-epic-merge-gate-resolution.ps1'` immediately after the line `            '.claude/hooks/enforce-epic-merge-gate-authorization.ps1'`; then CMD-CP from RUNSET to RUNSETB. Acceptance: A12 over CORE prints `JSON-OK`; A8 over RUNSET and RUNSETB prints two `PSD1-OK` lines; CMD-GIT-COUNT with literal `enforce-epic-merge-gate-resolution.ps1` over CORE, RUNSET, and RUNSETB prints a count of 1 for each; A13 over the runsettings pair prints `PAIR-SUMMARY pairs=1 unequal=0`.
- [ ] [P6-T9] Mirror MRGR and MRG into CB with two CMD-CP commands. Acceptance: A13 over the two pairs prints `PAIR-SUMMARY pairs=2 unequal=0`.
- [ ] [P6-T10] Format: MCP-PS-FORMAT (scan_folders `.claude/hooks`, `tests/scripts/claude-hooks`, `scripts/powershell/PoshQC/settings`); CMD-GIT-STATUS; A6 over MRGR, MRG, G4, the EXIST-MERGE suites, and RUNSET. Write FEATURE/evidence/qa-gates/format-p6.TS.md. Acceptance: the MCP call returns; CMD-GIT-STATUS names no path outside P6-FILES, the FEATURE evidence directory, and the plan file (MRGR and its mirror appear as untracked `??` lines); `FORMAT-SUMMARY ChangedCount=0`.
- [ ] [P6-T11] Analyze: MCP-PS-ANALYZE; A7 over MRGR, MRG, G4, and the EXIST-MERGE suites. Write FEATURE/evidence/qa-gates/analyze-p6.TS.md. Acceptance: the MCP call returns and `PSSA-SUMMARY DiagnosticCount=0`.
- [ ] [P6-T12] Run G4 (A2 with `-Path tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1`). Write FEATURE/evidence/regression-testing/merge-worktree-resolution.TS.md and append to WLOG. Acceptance: `TotalCount=10`, `PassedCount=10`, `FailedCount=0`.
- [ ] [P6-T13] Run SET-MERGE (A2). Write FEATURE/evidence/qa-gates/pester-set-merge-p6.TS.md and append to WLOG. Acceptance: `TotalCount=` equals BASE_MERGE plus 10 and every `FAILED:` line is a member of the P0-T20 baseline failure set.
- [ ] [P6-T14] Confirm the authorization sibling is byte-unchanged. Commands: `git diff --exit-code BASE_SHA -- .claude/hooks/enforce-epic-merge-gate-authorization.ps1` and CMD-GIT-STATUS-PATH over that file. Write FEATURE/evidence/qa-gates/merge-authorization-unchanged.TS.md. Acceptance: the diff exits 0 with no output and the status prints nothing.
- [ ] [P6-T15] Line counts for MRG, MRGR, G4, and the EXIST-MERGE suites (A4). Write FEATURE/evidence/qa-gates/line-counts-p6.TS.md. Acceptance: every value is at most 500.
- [ ] [P6-T16] Python parity (CMD-PY-PARITY). Write FEATURE/evidence/regression-testing/python-parity-p6.TS.md. Acceptance: as P3-T17.
- [ ] [P6-T17] Commit and push Phase 6. Commands: CMD-GIT-ADD with P6-FILES, the FEATURE evidence directory, and PLAN, CMD-GIT-COMMIT with message "fix(690): resolve merge gate run checkpoints by pull request number", CMD-GIT-PUSH. Acceptance: CMD-GIT-STATUS prints nothing and the push exits 0.

### Phase 7 — Epic Worktree-Removal Gate

- [ ] [P7-T1] D13 copy-drift gate (read-only). Command, WLOG row, and acceptance as P3-T1, artifact FEATURE/evidence/qa-gates/epic-copy-drift-p7.TS.md.
- [ ] [P7-T2] Stage and check EREMR and EREM per Appendix B8 (SW-1, SW-2 for both). Acceptance: A15 prints the clean `STAGE-CHECK` line for both staged files.
- [ ] [P7-T3] SW-3 for EREMR. Acceptance: the Write succeeds without a hook denial.
- [ ] [P7-T4] SW-3 for EREM, as the next repository write after P7-T3. Acceptance: the Write succeeds without a hook denial.
- [ ] [P7-T5] SW-4 for EREMR and EREM and the two WLOG entries. Acceptance: both hash pairs equal; WLOG records EREMR then EREM.
- [ ] [P7-T6] Write G5 per Appendix C10 (6 rows). Acceptance: the Write succeeds without a hook denial.
- [ ] [P7-T7] Add DT-LINE with seam `Resolve-EpicWorktreeGateRunTarget` to each EXIST-EREM suite's relevant `BeforeAll` (for `CleanupWorktreeManifestGateMatrix.Tests.ps1`, the epic `Describe` `BeforeAll` at line 219), and in the four read-seam rows of `enforce-epic-worktree-removal-gate.Tests.ps1` (lines 176, 182, 419, 425) pass `-Path` an absolute synthetic path, writing the synthetic path literal inline in each act line and in each ParameterFilter (no new variable line), and leave the assertion lines unchanged. Acceptance: CMD-GIT-COUNT with literal `Mock Resolve-EpicWorktreeGateRunTarget` over the four EXIST-EREM files prints four lines, each with count 1; A4 over `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1` prints `LineCount=496`.
- [ ] [P7-T8] Edit CORE: insert `    ".claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1",` immediately after the line `    ".claude/hooks/enforce-epic-worktree-removal-gate.ps1",`. Edit RUNSET: insert `            '.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1'` immediately after the line `            '.claude/hooks/enforce-epic-worktree-removal-gate.ps1'`; then CMD-CP RUNSET to RUNSETB. Acceptance: A12 over CORE prints `JSON-OK`; A8 over both runsettings prints two `PSD1-OK` lines; CMD-GIT-COUNT with literal `enforce-epic-worktree-removal-gate-resolution.ps1` over CORE, RUNSET, and RUNSETB prints a count of 1 for each; A13 over the runsettings pair prints `PAIR-SUMMARY pairs=1 unequal=0`.
- [ ] [P7-T9] Mirror EREMR and EREM into CB (two CMD-CP). Acceptance: A13 over the two pairs prints `PAIR-SUMMARY pairs=2 unequal=0`.
- [ ] [P7-T10] Format: MCP-PS-FORMAT (scan_folders `.claude/hooks`, `tests/scripts/claude-hooks`, `scripts/powershell/PoshQC/settings`); CMD-GIT-STATUS; A6 over EREMR, EREM, G5, the EXIST-EREM suites, and RUNSET. Write FEATURE/evidence/qa-gates/format-p7.TS.md. Acceptance: the MCP call returns; CMD-GIT-STATUS names no path outside P7-FILES, the FEATURE evidence directory, and the plan file; `FORMAT-SUMMARY ChangedCount=0`.
- [ ] [P7-T11] Analyze: MCP-PS-ANALYZE; A7 over EREMR, EREM, G5, and the EXIST-EREM suites. Write FEATURE/evidence/qa-gates/analyze-p7.TS.md. Acceptance: the MCP call returns and `PSSA-SUMMARY DiagnosticCount=0`.
- [ ] [P7-T12] Run G5 (A2 with `-Path tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1`). Write FEATURE/evidence/regression-testing/erem-worktree-resolution.TS.md and append to WLOG. Acceptance: `TotalCount=6`, `PassedCount=6`, `FailedCount=0`.
- [ ] [P7-T13] Run SET-EREM (A2). Write FEATURE/evidence/qa-gates/pester-set-erem-p7.TS.md and append to WLOG. Acceptance: `TotalCount=` equals BASE_EREM plus 6 and every `FAILED:` line is a member of the P0-T21 baseline failure set.
- [ ] [P7-T14] Line counts for EREM, EREMR, G5, and the EXIST-EREM suites (A4). Write FEATURE/evidence/qa-gates/line-counts-p7.TS.md. Acceptance: every value is at most 500.
- [ ] [P7-T15] Python parity (CMD-PY-PARITY). Write FEATURE/evidence/regression-testing/python-parity-p7.TS.md. Acceptance: as P3-T17.
- [ ] [P7-T16] Commit and push Phase 7. Commands: CMD-GIT-ADD with P7-FILES, the FEATURE evidence directory, and PLAN, CMD-GIT-COMMIT with message "fix(690): resolve epic worktree-removal checkpoints by worktree path", CMD-GIT-PUSH. Acceptance: CMD-GIT-STATUS prints nothing and the push exits 0.

### Phase 8 — Parallel Worktree-Removal Gate

- [ ] [P8-T1] D13 copy-drift gate (read-only). Command, WLOG row, and acceptance as P3-T1, artifact FEATURE/evidence/qa-gates/epic-copy-drift-p8.TS.md.
- [ ] [P8-T2] Stage and check PREM per Appendix B9 (SW-1, SW-2). Acceptance: A15 prints the clean `STAGE-CHECK` line for `SCRATCH/stage/enforce-parallel-worktree-removal-gate.ps1`.
- [ ] [P8-T3] SW-3 for PREM. Acceptance: the Write succeeds without a hook denial.
- [ ] [P8-T4] SW-4 for PREM and the WLOG entry. Acceptance: hashes equal; WLOG records PREM.
- [ ] [P8-T5] Write G6 per Appendix C11 (6 rows). Acceptance: the Write succeeds without a hook denial.
- [ ] [P8-T6] Add DT-LINE with seam `Resolve-ParallelWorktreeGateRunTarget` to each EXIST-PREM suite's relevant `BeforeAll` (for `CleanupWorktreeManifestGateMatrix.Tests.ps1`, the parallel `Describe` `BeforeAll` at line 272 (271 at `d6bb5c65`, moved by P7-T7)), and in the two read-seam rows of `enforce-parallel-worktree-removal-gate.Tests.ps1` (lines 317, 323) pass `-Path` a test-local absolute synthetic path and compare the ParameterFilters to it, leaving assertion lines unchanged. Acceptance: CMD-GIT-COUNT with literal `Mock Resolve-ParallelWorktreeGateRunTarget` over the four EXIST-PREM files prints four lines, each with count 1.
- [ ] [P8-T7] Mirror PREM into CB (CMD-CP). Acceptance: A13 prints `PAIR-SUMMARY pairs=1 unequal=0`.
- [ ] [P8-T8] Format: MCP-PS-FORMAT (scan_folders `.claude/hooks`, `tests/scripts/claude-hooks`); CMD-GIT-STATUS; A6 over PREM, G6, and the EXIST-PREM suites. Write FEATURE/evidence/qa-gates/format-p8.TS.md. Acceptance: the MCP call returns; CMD-GIT-STATUS names no path outside P8-FILES, the FEATURE evidence directory, and the plan file; `FORMAT-SUMMARY ChangedCount=0`.
- [ ] [P8-T9] Analyze: MCP-PS-ANALYZE; A7 over the P8-T8 files. Write FEATURE/evidence/qa-gates/analyze-p8.TS.md. Acceptance: the MCP call returns and `PSSA-SUMMARY DiagnosticCount=0`.
- [ ] [P8-T10] Run G6 (A2 with `-Path tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1`). Write FEATURE/evidence/regression-testing/prem-worktree-resolution.TS.md and append to WLOG. Acceptance: `TotalCount=6`, `PassedCount=6`, `FailedCount=0`.
- [ ] [P8-T11] Run SET-PREM (A2). Write FEATURE/evidence/qa-gates/pester-set-prem-p8.TS.md and append to WLOG. Acceptance: `TotalCount=` equals BASE_PREM plus 6 and every `FAILED:` line is a member of the P0-T22 baseline failure set.
- [ ] [P8-T12] Line counts for PREM, G6, and the EXIST-PREM suites (A4). Write FEATURE/evidence/qa-gates/line-counts-p8.TS.md. Acceptance: every value is at most 500.
- [ ] [P8-T13] Python parity (CMD-PY-PARITY). Write FEATURE/evidence/regression-testing/python-parity-p8.TS.md. Acceptance: as P3-T17.
- [ ] [P8-T14] Commit and push Phase 8. Commands: CMD-GIT-ADD with P8-FILES, the FEATURE evidence directory, and PLAN, CMD-GIT-COMMIT with message "fix(690): resolve parallel worktree-removal checkpoints by worktree path", CMD-GIT-PUSH. Acceptance: CMD-GIT-STATUS prints nothing and the push exits 0.

### Phase 9 — Parallel Drift Gate

- [ ] [P9-T1] D13 copy-drift gate (read-only). Command, WLOG row, and acceptance as P3-T1, artifact FEATURE/evidence/qa-gates/epic-copy-drift-p9.TS.md.
- [ ] [P9-T2] Stage and check DRIFT per Appendix B10 (SW-1, SW-2). Acceptance: A15 prints the clean `STAGE-CHECK` line for `SCRATCH/stage/enforce-parallel-drift-gate.ps1`.
- [ ] [P9-T3] SW-3 for DRIFT. Acceptance: the Write succeeds without a hook denial.
- [ ] [P9-T4] SW-4 for DRIFT and the WLOG entry. Acceptance: hashes equal; WLOG records DRIFT.
- [ ] [P9-T5] Write G7 per Appendix C12 (6 rows). Acceptance: the Write succeeds without a hook denial.
- [ ] [P9-T6] Edit `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1`: add DT-LINE with seam `Resolve-ParallelDriftGateTarget` as the last statement of its hook-loading `BeforeAll`; in the two read-seam rows (lines 326, 332) pass `-Path` a test-local absolute synthetic path and compare the ParameterFilters to it, leaving assertion lines unchanged. Acceptance: CMD-GIT-COUNT with literal `Mock Resolve-ParallelDriftGateTarget` over that file prints a count of 1.
- [ ] [P9-T7] Mirror DRIFT into CB (CMD-CP). Acceptance: A13 prints `PAIR-SUMMARY pairs=1 unequal=0`.
- [ ] [P9-T8] Format: MCP-PS-FORMAT (scan_folders `.claude/hooks`, `tests/scripts/claude-hooks`); CMD-GIT-STATUS; A6 over DRIFT, G7, and the edited suite. Write FEATURE/evidence/qa-gates/format-p9.TS.md. Acceptance: the MCP call returns; CMD-GIT-STATUS names no path outside P9-FILES, the FEATURE evidence directory, and the plan file; `FORMAT-SUMMARY ChangedCount=0`.
- [ ] [P9-T9] Analyze: MCP-PS-ANALYZE; A7 over the three P9-T8 files. Write FEATURE/evidence/qa-gates/analyze-p9.TS.md. Acceptance: the MCP call returns and `PSSA-SUMMARY DiagnosticCount=0`.
- [ ] [P9-T10] Run G7 (A2 with `-Path tests/scripts/claude-hooks/enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1`). Write FEATURE/evidence/regression-testing/drift-worktree-resolution.TS.md and append to WLOG. Acceptance: `TotalCount=6`, `PassedCount=6`, `FailedCount=0`.
- [ ] [P9-T11] Run SET-DRIFT (A2). Write FEATURE/evidence/qa-gates/pester-set-drift-p9.TS.md and append to WLOG. Acceptance: `TotalCount=` equals BASE_DRIFT plus 6 and every `FAILED:` line is a member of the P0-T23 baseline failure set.
- [ ] [P9-T12] Line counts for DRIFT, G7, and the edited suite (A4). Write FEATURE/evidence/qa-gates/line-counts-p9.TS.md. Acceptance: every value is at most 500.
- [ ] [P9-T13] Python parity (CMD-PY-PARITY). Write FEATURE/evidence/regression-testing/python-parity-p9.TS.md. Acceptance: as P3-T17.
- [ ] [P9-T14] Commit and push Phase 9. Commands: CMD-GIT-ADD with P9-FILES, the FEATURE evidence directory, and PLAN, CMD-GIT-COMMIT with message "fix(690): resolve the parallel drift gate checkpoint from parallel_slug", CMD-GIT-PUSH. Acceptance: CMD-GIT-STATUS prints nothing and the push exits 0.

### Phase 10 — Epic-Scope Resolution and the Isolation Guard

- [ ] [P10-T1] D13 copy-drift gate (read-only). Command, WLOG row, and acceptance as P3-T1, artifact FEATURE/evidence/qa-gates/epic-copy-drift-p10.TS.md.
- [ ] [P10-T2] Stage and check ESR per Appendix B11 (SW-1, SW-2; ESR is live through PRES, the model-routing hook, and the pr-author helpers). Acceptance: A15 prints the clean `STAGE-CHECK` line for `SCRATCH/stage/EpicScopeResolution.psm1`.
- [ ] [P10-T3] SW-3 for ESR. Acceptance: the Write succeeds without a hook denial.
- [ ] [P10-T4] SW-4 for ESR and the WLOG entry. Acceptance: hashes equal; WLOG records ESR.
- [ ] [P10-T5] Write GUARDH per Appendix C14 (the relocated helper functions plus the WRR-pair checks). Acceptance: the Write succeeds without a hook denial; A4 over GUARDH prints a value of at most 500.
- [ ] [P10-T6] Write GUARD in full per Appendix C14 (dot-sources GUARDH; list of eight suites; discrimination rows; seam-sufficiency rows). Acceptance: the Write succeeds without a hook denial; A4 over GUARD prints a value of at most 500.
- [ ] [P10-T7] Write T-ESR per Appendix C4 (4 rows). Acceptance: the Write succeeds without a hook denial.
- [ ] [P10-T8] Edit `tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.Tests.ps1`: inside `Set-EpicScopeResolverMock` (line 30 onward) add the default `Mock Resolve-WorktreeEpicTarget -ModuleName EpicScopeResolution` of Appendix C0 (ESR-DEFAULT). Acceptance: CMD-GIT-COUNT with literal `Mock Resolve-WorktreeEpicTarget` over that file prints a count of 1.
- [ ] [P10-T9] Edit the seven guarded suites of Appendix G group GUARDED-7 (`tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1`, `tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1`, `tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1`): append, as the last statements of each outermost `BeforeAll`, an `Import-Module` of `WorktreeRunResolution.psm1` without `-Force` (using the suite's existing repository-root expression) and `Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }`; in the four GUARDED-PRE-4 suites also add, beside that text-read mock, `Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeRunResolution { , [string[]] @() }`. Acceptance: CMD-GIT-COUNT with literal `Mock Get-WorktreeRunCheckpointText` over the seven files prints seven lines, each with count 1; CMD-GIT-COUNT with literal `Mock Get-WorktreeItemLiveRoot -ModuleName WorktreeRunResolution` over the four GUARDED-PRE-4 files prints four lines, each with count 1; A4 over `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` prints `LineCount=493`.
- [ ] [P10-T10] Edit the four epic-scope suites of Appendix G group ESCOPE-4 (`enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1`, `enforce-model-routing-receipt.EpicScope.Tests.ps1`, `enforce-pr-author-skill.EpicScope.Tests.ps1`, `enforce-pr-author-skill.epic-base-branch.Tests.ps1`): in the `BeforeAll` that imports ESR, add the `Import-Module` of `WorktreeRunResolution.psm1` without `-Force`, the `$null` mock of `Get-WorktreeRunCheckpointText`, and ESR-DEFAULT. Acceptance: CMD-GIT-COUNT with literal `Mock Resolve-WorktreeEpicTarget` over the four files prints four lines, each with count 1.
- [ ] [P10-T11] Mirror ESR into CB (CMD-CP). Acceptance: A13 prints `PAIR-SUMMARY pairs=1 unequal=0`.
- [ ] [P10-T12] Format: MCP-PS-FORMAT (scan_folders `.claude/lib/worktree-resolution`, `tests/scripts/claude-hooks`, `tests/scripts/claude-lib/worktree-resolution`); CMD-GIT-STATUS; A6 over ESR, GUARD, GUARDH, T-ESR, and every edited suite of this phase. Write FEATURE/evidence/qa-gates/format-p10.TS.md. Acceptance: the MCP call returns; CMD-GIT-STATUS names no path outside P10-FILES, the FEATURE evidence directory, and the plan file; `FORMAT-SUMMARY ChangedCount=0`.
- [ ] [P10-T13] Analyze: MCP-PS-ANALYZE; A7 over the P10-T12 files. Write FEATURE/evidence/qa-gates/analyze-p10.TS.md. Acceptance: the MCP call returns and `PSSA-SUMMARY DiagnosticCount=0`.
- [ ] [P10-T14] Run T-ESR and GUARD. Command: A2 with `-Path tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.RunTarget.Tests.ps1,tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1`. Write FEATURE/evidence/regression-testing/epic-scope-run-target.TS.md and append to WLOG. Acceptance: `FailedCount=0` and `TotalCount=` equals 4 plus the GUARD row count of Appendix C14 (33); that is, `TotalCount=37`.
- [ ] [P10-T15] Run SET-EPICSCOPE (A2 over the Appendix G list, which now includes G1B and T-ESR). Write FEATURE/evidence/qa-gates/pester-set-epicscope-p10.TS.md and append to WLOG. Acceptance: `TotalCount=` equals BASE_ESCOPE plus 23 (G1B 10, T-ESR 4, GUARD 9) and every `FAILED:` line is a member of the P0-T24 baseline failure set.
- [ ] [P10-T16] Run SET-LIB (A2). Write FEATURE/evidence/qa-gates/pester-set-lib-p10.TS.md. Acceptance: `TotalCount=` equals BASE_LIB plus 72 and every `FAILED:` line is a member of the P0-T16 baseline failure set.
- [ ] [P10-T17] AC-23 hook files unchanged. Commands: `git diff --exit-code BASE_SHA -- .claude/hooks/enforce-model-routing-receipt.ps1 .claude/hooks/enforce-pr-author-skill.ps1 .claude/hooks/enforce-pr-author-skill-helpers.ps1 .claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` and CMD-GIT-STATUS-PATH over the same four files. Write FEATURE/evidence/qa-gates/epic-scope-callers-unchanged.TS.md. Acceptance: the diff exits 0 with no output and the status prints nothing.
- [ ] [P10-T18] Line counts for ESR, GUARD, GUARDH, T-ESR, and every edited suite of this phase (A4). Write FEATURE/evidence/qa-gates/line-counts-p10.TS.md. Acceptance: every value is at most 500.
- [ ] [P10-T19] Python parity (CMD-PY-PARITY). Write FEATURE/evidence/regression-testing/python-parity-p10.TS.md. Acceptance: as P3-T17.
- [ ] [P10-T20] Commit and push Phase 10. Commands: CMD-GIT-ADD with P10-FILES, the FEATURE evidence directory, and PLAN, CMD-GIT-COMMIT with message "fix(690): resolve the epic-scope checkpoint through the run resolver", CMD-GIT-PUSH. Acceptance: CMD-GIT-STATUS prints nothing and the push exits 0.

### Phase 11 — Follow-Up Potential Entries

- [ ] [P11-T1] Write `docs/features/potential/2026-09-29-hook-preexisting-imports-fail-open.md` per Appendix E1 (AC-36). Acceptance: the Write succeeds without a hook denial; content is verified after commit by P11-T4.
- [ ] [P11-T2] Write `docs/features/potential/2026-09-29-validate-orchestrator-output-session-relative-read.md` per Appendix E2 (AC-63). Acceptance: as P11-T1.
- [ ] [P11-T3] Write `docs/features/potential/2026-09-29-merge-gate-child-branch-without-pr-gate.md` per Appendix E3 (AC-63). Acceptance: as P11-T1.
- [ ] [P11-T4] Verify, commit, and push the three entries, in this order: CMD-GIT-ADD with the three entry paths; CMD-GIT-COUNT with literal `#690` over the three paths; write FEATURE/evidence/other/follow-up-entries.TS.md; CMD-GIT-ADD with the FEATURE evidence directory and PLAN; CMD-GIT-COMMIT with message "docs(690): record follow-up potential entries"; CMD-GIT-PUSH. Acceptance: the count prints three `path:count` lines; no `gh` command is run; CMD-GIT-STATUS prints nothing after the push and the push exits 0.

### Phase 12 — Final QA Loop: PowerShell (PoshQC and Pester)

If any Phase 12 step fails or changes a tracked file, fix the cause, re-mirror any changed `.claude` file, and restart from P12-T1.

- [ ] [P12-T1] Format. Commands: A5 over the Appendix F group FINAL-PS files (before); MCP-PS-FORMAT with scan_folders `.claude/hooks`, `.claude/lib/worktree-resolution`, `tests/scripts/claude-hooks`, `tests/scripts/claude-lib/worktree-resolution`, `scripts/powershell/PoshQC/settings` (no file directly under `tests/scripts/claude-lib` is created or edited, so that folder is not scanned); A5 over the same files (after); CMD-GIT-STATUS; A6 over the FINAL-PS files. Write FEATURE/evidence/qa-gates/powershell-format.TS.md. Acceptance: the MCP call returns without raising; before and after hashes are identical for every file; CMD-GIT-STATUS names no path outside the FEATURE evidence directory and the plan file; A6 prints `FORMAT-SUMMARY ChangedCount=0`.
- [ ] [P12-T2] Analyze. Commands: MCP-PS-ANALYZE with the P12-T1 scan_folders; A7 over the FINAL-PS files. Write FEATURE/evidence/qa-gates/powershell-analyze.TS.md. Acceptance: the MCP call returns and `PSSA-SUMMARY DiagnosticCount=0`.
- [ ] [P12-T3] Policy-mandated MCP test step. Command: MCP-PS-TEST. Write FEATURE/evidence/qa-gates/powershell-mcp-test.TS.md. Acceptance: the call returns without raising; the artifact records the disposition and states that counts and coverage come from P12-T4 through P12-T16, because the MCP result carries no test output.
- [ ] [P12-T4] Coverage CG-LIB final (A3, report SCRATCH/cov-lib-final.txt). Write FEATURE/evidence/qa-gates/coverage-lib.TS.md. Acceptance: `FailedCount=0`; `LinePercent=` for WRR is at least 85; `LinePercent=` for WIR and ESR are each at least their BASEPCT from P0-T25.
- [ ] [P12-T5] Coverage CG-PRE final (report SCRATCH/cov-pre-final.txt). Write FEATURE/evidence/qa-gates/coverage-pre.TS.md. Acceptance: `FailedCount=0`; `LinePercent=` for PRE and PRES each at least its P0-T26 BASEPCT.
- [ ] [P12-T6] Coverage CG-WAVE final (report SCRATCH/cov-wave-final.txt). Write FEATURE/evidence/qa-gates/coverage-wave.TS.md. Acceptance: `FailedCount=0`; `LinePercent=` for WAVE at least its P0-T27 BASEPCT.
- [ ] [P12-T7] Coverage CG-COHORT final (report SCRATCH/cov-cohort-final.txt). Write FEATURE/evidence/qa-gates/coverage-cohort.TS.md. Acceptance: `FailedCount=0`; COH at least its P0-T28 BASEPCT.
- [ ] [P12-T8] Coverage CG-MERGE final (report SCRATCH/cov-merge-final.txt). Write FEATURE/evidence/qa-gates/coverage-merge.TS.md. Acceptance: `FailedCount=0`; MRG at least its P0-T29 BASEPCT; MRGR at least 85.
- [ ] [P12-T9] Coverage CG-EREM final (report SCRATCH/cov-erem-final.txt). Write FEATURE/evidence/qa-gates/coverage-erem.TS.md. Acceptance: `FailedCount=0`; EREM at least its P0-T30 BASEPCT; EREMR at least 85.
- [ ] [P12-T10] Coverage CG-PREM final (report SCRATCH/cov-prem-final.txt). Write FEATURE/evidence/qa-gates/coverage-prem.TS.md. Acceptance: `FailedCount=0`; PREM at least its P0-T31 BASEPCT.
- [ ] [P12-T11] Coverage CG-DRIFT final (report SCRATCH/cov-drift-final.txt). Write FEATURE/evidence/qa-gates/coverage-drift.TS.md. Acceptance: `FailedCount=0`; DRIFT at least its P0-T32 BASEPCT.
- [ ] [P12-T12] Changed-line coverage against BASE_SHA for every changed or new production file. Commands: A11 once per coverage group with `-CoverageReportPath SCRATCH/cov-<group>-final.txt -BaseRef BASE_SHA -File <the group's production files>` (BASE_SHA replaced by the recorded commit). Write FEATURE/evidence/qa-gates/changed-line-coverage.TS.md. Acceptance: 13 `CHANGED-COVERAGE file=` lines (WRR, WIR, ESR, PRE, PRES, WAVE, COH, MRG, MRGR, EREM, EREMR, PREM, DRIFT; the runsettings files are data files with no Pester-measured lines), none `MISSING`. The 12 files other than WIR each have a numeric `ChangedPercent=` of at least 85. WIR is exempt from the numeric check: its line may read `ChangedAnalyzed=0 ... ChangedPercent=NA`, which the artifact records as "no executable changed line; the export is verified by T-REC X2 (P1-T12)".
- [ ] [P12-T13] Regression over `tests/scripts/claude-hooks` (A2). Write FEATURE/evidence/qa-gates/pester-claude-hooks.TS.md. Acceptance: `TotalCount=` equals BASE_HOOKS plus 78, and every `FAILED:` line is a member of the P0-T33 baseline failure set.
- [ ] [P12-T14] Regression over `tests/scripts/claude-lib` (A2). Write FEATURE/evidence/qa-gates/pester-claude-lib.TS.md. Acceptance: `TotalCount=` equals BASE_CLIB plus 72, and every `FAILED:` line is a member of the P0-T34 baseline failure set.
- [ ] [P12-T15] Regression over `tests/scripts/claude-runtime` (A2). Write FEATURE/evidence/qa-gates/pester-claude-runtime.TS.md. Acceptance: `TotalCount=` equals BASE_RUNTIME and every `FAILED:` line is a member of the P0-T35 baseline failure set (AC-53: the no-Python scan covers WRR, MRGR, and EREMR).
- [ ] [P12-T16] Regression over `tests/scripts/codex-hooks` (A2). Write FEATURE/evidence/qa-gates/pester-codex-hooks.TS.md. Acceptance: `TotalCount=` equals BASE_CODEX and every `FAILED:` line is a member of the P0-T36 baseline failure set.
- [ ] [P12-T17] File-size check over every production and test file created or edited by this plan (Appendix F group FINAL-PS; the six skill files are Markdown and exempt from the limit). Command: A4 over FINAL-PS. Write FEATURE/evidence/qa-gates/line-counts-final.TS.md. Acceptance: every `LineCount=` value is at most 500.
- [ ] [P12-T18] AC-50 temporary-file check on the new test files. Command: `git grep -n -F -e "New-TemporaryFile" -e "GetTempFileName" -e "GetTempPath" -e "TestDrive" -e "Set-Content" -e "Out-File" -e "New-Item" -e "Remove-Item" -e "Copy-Item" -e "Move-Item" -- tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Signal.Tests.ps1 tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Tests.ps1 tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1 tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.RunTarget.Tests.ps1 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1 tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 tests/scripts/claude-hooks/enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1 tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1`. Write FEATURE/evidence/qa-gates/ac50-no-temp-files-new.TS.md with `ExpectedExitCode: 1`. Acceptance: exit 1 and no output.
- [ ] [P12-T19] AC-50 added-lines check on the edited existing test files. Command: CMD-PS-SCRIPT with script added-lines-scan (A17), `-BaseRef BASE_SHA -Token New-TemporaryFile,GetTempFileName,GetTempPath,TestDrive,Set-Content,Out-File,New-Item,Remove-Item,Copy-Item,Move-Item -File <the Appendix G group EDITED-TESTS list, comma-separated>`. Write FEATURE/evidence/qa-gates/ac50-no-temp-files-edited.TS.md. Acceptance: output ends with `ADDED-TOKEN-SUMMARY count=0`.
- [ ] [P12-T20] Commit and push Phase 12. Commands: CMD-GIT-STATUS; CMD-GIT-ADD with the FEATURE evidence directory, PLAN, and every other path the status check listed; CMD-GIT-COMMIT with message "docs(690): record PowerShell final QA evidence"; CMD-GIT-PUSH. Acceptance: CMD-GIT-STATUS prints nothing after the commit and the push exits 0.

### Phase 13 — Python Parity, Scope Guards, and Coverage Comparison

- [ ] [P13-T1] Python parity. Command: CMD-PY-PARITY. Write FEATURE/evidence/qa-gates/python-parity.TS.md. Acceptance: every node other than the KL-510 node is PASSED and that node satisfies KL-510 (AC-44).
- [ ] [P13-T2] Python regression over `tests/scripts/dev_tools`. Command: `poetry run pytest tests/scripts/dev_tools -q -rf`. Write FEATURE/evidence/qa-gates/python-dev-tools.TS.md. Acceptance: every `FAILED` line is a member of the P0-T38 baseline failure set and the collected total equals the P0-T38 total. When the KL-510 node is the only FAILED line and satisfies case (b), the artifact carries `ExpectedExitCode: 1`.
- [ ] [P13-T3] No Python file changed. Commands: `git diff --name-only BASE_SHA -- "*.py"` and `git status --porcelain -- "*.py"`. Write FEATURE/evidence/qa-gates/python-scope.TS.md. Acceptance: both commands print nothing.
- [ ] [P13-T4] No `.codex` file changed (AC-62). Commands: `git diff --name-only BASE_SHA -- .codex` and `git status --porcelain -- .codex`. Write FEATURE/evidence/qa-gates/codex-scope.TS.md. Acceptance: both commands print nothing.
- [ ] [P13-T5] Byte-unchanged files (AC-54, AC-62). Commands: `git diff --exit-code BASE_SHA -- .claude/lib/worktree-resolution/WorktreeResolution.psm1 .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 .claude/hooks/validate-orchestrator-output.ps1 .claude/hooks/enforce-powershell-batch-budget.ps1 .claude/hooks/enforce-powershell-batch-budget-route.ps1` and CMD-PS-SCRIPT with script file-hashes (A5) over the Appendix F group BU. Write FEATURE/evidence/qa-gates/byte-unchanged.TS.md. Acceptance: the diff exits 0 with no output, and every A5 `Hash=` value equals its P0-T12 value.
- [ ] [P13-T6] AC-26 re-check (A14 as P4-T12). Write FEATURE/evidence/qa-gates/wave-folder-function-final.TS.md. Acceptance: `FUNCTION-TEXT-EQUAL=True`.
- [ ] [P13-T7] Final mirror check across Appendix F groups MP-EXIST and MP-NEW. Command: A13 over all 25 pairs. Write FEATURE/evidence/qa-gates/mirror-hashes-final.TS.md. Acceptance: `PAIR-SUMMARY pairs=25 unequal=0`.
- [ ] [P13-T8] Registration check (AC-45, AC-47). Commands: CMD-GIT-COUNT with literal `WorktreeRunResolution.psm1` over CORE, RUNSET, RUNSETB; CMD-GIT-COUNT with literal `enforce-epic-merge-gate-resolution.ps1` over the same three; CMD-GIT-COUNT with literal `enforce-epic-worktree-removal-gate-resolution.ps1` over the same three; A13 over the RUNSET/RUNSETB pair. Write FEATURE/evidence/qa-gates/registration.TS.md. Acceptance: each count prints three lines with count 1; A13 prints `PAIR-SUMMARY pairs=1 unequal=0`.
- [ ] [P13-T9] Commit manifest (AC-43, AC-57, AC-60). Command: CMD-PS-SCRIPT with script commit-manifest (A18) and `-BaseRef BASE_SHA` (BASE_SHA replaced by the recorded commit). Write FEATURE/evidence/qa-gates/commit-manifest.TS.md. Acceptance: the first `COMMIT` line is `d6bb5c65` (pre-plan documents), followed by the Phase 0-12 commits in order; the Phase 1 commit lists no path under `.claude/hooks/`; the Phase 2 commit precedes the Phase 3 commit; each gate commit (Phases 3-10) lists its primary hook or module file together with every sibling it writes and every CB mirror of those files (per the P3-FILES through P10-FILES lists of Appendix F).
- [ ] [P13-T10] Coverage comparison. Write FEATURE/evidence/qa-gates/coverage-comparison.TS.md from the P0-T25 through P0-T32 and P12-T4 through P12-T12 artifacts. Acceptance: the artifact carries, for PowerShell, `Baseline Coverage:` (each existing file's BASEPCT), `Post-Change Coverage:` (each P12 value, including WRR, MRGR, EREMR), `New/Changed-code Coverage:` (the 13 `ChangedPercent=` values; WIR may be `NA`, recorded as "no executable changed line; the export is verified by T-REC X2 (P1-T12)"), and `Disposition:`; every other value is numeric. `Disposition:` is `PASS` only when WRR, MRGR, and EREMR are each at least 85, each existing file is at least its BASEPCT, and each of the 12 non-WIR `ChangedPercent=` values is at least 85; otherwise `BLOCKED`. The artifact states that no Python or TypeScript file is changed.
- [ ] [P13-T11] Commit and push the final QA evidence. Commands: CMD-GIT-STATUS, then CMD-GIT-ADD with the FEATURE evidence directory plus every path CMD-GIT-STATUS listed (fixes made by Phase 12 restarts), CMD-GIT-COMMIT with message "docs(690): record final QA evidence", CMD-GIT-PUSH. Acceptance: CMD-GIT-STATUS prints nothing and the push exits 0.

### Phase 14 — Acceptance-Criteria Check-Off

Each check-off task edits one line of FEATURE/spec.md, changing its leading `- [ ] ` to `- [x] ` (the line numbers are those of Appendix I and do not move, because no earlier task edits spec.md), and records the check-off with the cited evidence in FEATURE/evidence/other/ac-checkoff.TS.md. A criterion whose cited evidence does not all pass stays unchecked and the plan outcome is remediation-required.

- [ ] [P14-T1] Check off AC-01 (spec line 410). Evidence: P3-T13 (G1A row R1).
- [ ] [P14-T2] Check off AC-02 (line 411). Evidence: P4-T10 (G2 row W1).
- [ ] [P14-T3] Check off AC-03 (line 412). Evidence: P3-T13 (G1A R2), P4-T10 (G2 W2).
- [ ] [P14-T4] Check off AC-04 (line 416). Evidence: P1-T12 (T-REC X1).
- [ ] [P14-T5] Check off AC-05 (line 417). Evidence: P1-T12 (T-REC C1 rows).
- [ ] [P14-T6] Check off AC-06 (line 418). Evidence: P1-T12 (T-SIG S1-S9).
- [ ] [P14-T7] Check off AC-07 (line 419). Evidence: P1-T12 (T-RUN E1-E6).
- [ ] [P14-T8] Check off AC-08 (line 420). Evidence: P1-T12 (T-RUN E7-E9).
- [ ] [P14-T9] Check off AC-09 (line 421). Evidence: P1-T12 (T-RUN E10-E15, R4-R7).
- [ ] [P14-T10] Check off AC-10 (line 422). Evidence: P1-T12 (T-RUN R1-R3).
- [ ] [P14-T11] Check off AC-11 (line 423). Evidence: P1-T12 (T-REC B1-B12).
- [ ] [P14-T12] Check off AC-12 (line 424). Evidence: P1-T12 (T-REC U1-U3).
- [ ] [P14-T13] Check off AC-13 (line 425). Evidence: P1-T2, P1-T12 (T-REC X2, C2).
- [ ] [P14-T14] Check off AC-14 (line 429). Evidence: P3-T13 (G1A R1-R3).
- [ ] [P14-T15] Check off AC-15 (line 430). Evidence: P3-T13 (G1A R4-R6).
- [ ] [P14-T16] Check off AC-16 (line 431). Evidence: P3-T13 (G1A R7-R10).
- [ ] [P14-T17] Check off AC-17 (line 432). Evidence: P3-T13 (G1B O1-O3).
- [ ] [P14-T18] Check off AC-18 (line 433). Evidence: P3-T13 (G1B O4-O5).
- [ ] [P14-T19] Check off AC-19 (line 434). Evidence: P3-T13 (G1B O10).
- [ ] [P14-T20] Check off AC-20 (line 435). Evidence: P3-T13 (G1A R13-R15), P3-T14.
- [ ] [P14-T21] Check off AC-21 (line 439). Evidence: P10-T14 (T-ESR N1).
- [ ] [P14-T22] Check off AC-22 (line 440). Evidence: P10-T14 (T-ESR N2, N3).
- [ ] [P14-T23] Check off AC-23 (line 441). Evidence: P10-T15, P10-T17.
- [ ] [P14-T24] Check off AC-24 (line 445). Evidence: P4-T10, P4-T11.
- [ ] [P14-T25] Check off AC-25 (line 446). Evidence: P5-T10, P5-T11.
- [ ] [P14-T26] Check off AC-26 (line 447). Evidence: P4-T12, P13-T6.
- [ ] [P14-T27] Check off AC-27 (line 451). Evidence: P6-T12 (G4 M1).
- [ ] [P14-T28] Check off AC-28 (line 452). Evidence: P6-T12 (G4 M2).
- [ ] [P14-T29] Check off AC-29 (line 453). Evidence: P6-T12 (G4 M3-M5).
- [ ] [P14-T30] Check off AC-30 (line 454). Evidence: P6-T12 (G4 M6).
- [ ] [P14-T31] Check off AC-31 (line 455). Evidence: P6-T12 (G4 M7-M9).
- [ ] [P14-T32] Check off AC-32 (line 459). Evidence: P7-T12, P7-T13.
- [ ] [P14-T33] Check off AC-33 (line 460). Evidence: P8-T10, P8-T11.
- [ ] [P14-T34] Check off AC-34 (line 464). Evidence: P9-T10, P9-T11.
- [ ] [P14-T35] Check off AC-35 (line 468). Evidence: import-failure rows G1B O7-O8, G2 W7, G3 C5, G4 M10, G5 V6, G6 Y6, G7 D6 (P3-T13, P4-T10, P5-T10, P6-T12, P7-T12, P8-T10, P9-T10).
- [ ] [P14-T36] Check off AC-36 (line 469). Evidence: P11-T4 (E1).
- [ ] [P14-T37] Check off AC-37 (line 473). Evidence: P3-T13 (G1B O5, O6).
- [ ] [P14-T38] Check off AC-38 (line 474). Evidence: P3-T13 (G1A R11), P4-T10 (G2 W5), P5-T10 (G3 C4).
- [ ] [P14-T39] Check off AC-39 (line 475). Evidence: P1-T12 (T-RUN E7), P3-T13 (G1A R12), P4-T10 (G2 W6).
- [ ] [P14-T40] Check off AC-40 (line 479). Evidence: P2-T8, P2-T9.
- [ ] [P14-T41] Check off AC-41 (line 480). Evidence: P2-T8 (epic-orchestrate and parallel-orchestrate counts), P2-T3 negative marker search.
- [ ] [P14-T42] Check off AC-42 (line 481). Evidence: P2-T8 (three invoke-skill counts).
- [ ] [P14-T43] Check off AC-43 (line 482). Evidence: P13-T9.
- [ ] [P14-T44] Check off AC-44 (line 486) only when the P13-T1 artifact records `KL-510: PASSED`. Evidence: P13-T1, P13-T7. When P13-T1 records `KL-510: STATE-ONLY`, leave AC-44 unchecked and record the gap in the ac-checkoff artifact; the pull request's CI run closes it.
- [ ] [P14-T45] Check off AC-45 (line 487). Evidence: P1-T7, P6-T8, P7-T8, P13-T8.
- [ ] [P14-T46] Check off AC-46 (line 488). Evidence: P1-T6, P1-T13.
- [ ] [P14-T47] Check off AC-47 (line 489). Evidence: P1-T8, P13-T8.
- [ ] [P14-T48] Check off AC-48 (line 490). Evidence: P10-T9, P10-T14, P10-T15.
- [ ] [P14-T49] Check off AC-49 (line 494). Evidence: G1A, G1B, G2-G7 rows listed in Appendix C per gate (P3-T13, P4-T10, P5-T10, P6-T12, P7-T12, P8-T10, P9-T10).
- [ ] [P14-T50] Check off AC-50 (line 495). Evidence: P12-T18, P12-T19.
- [ ] [P14-T51] Check off AC-51 (line 496). Evidence: P3-T9, P4-T6, P5-T6, P6-T7, P7-T7, P8-T6, P9-T6, P12-T13.
- [ ] [P14-T52] Check off AC-52 (line 497). Evidence: P12-T4, P12-T12, P13-T10 (`Disposition: PASS`).
- [ ] [P14-T53] Check off AC-53 (line 498). Evidence: P1-T13, P12-T14, P12-T15.
- [ ] [P14-T54] Check off AC-54 (line 502). Evidence: P3-T15, P13-T5.
- [ ] [P14-T55] Check off AC-55 (line 503). Evidence: P12-T17.
- [ ] [P14-T56] Check off AC-56 (line 504). Evidence: P3-T15, P3-T16.
- [ ] [P14-T57] Check off AC-57 (line 508). Evidence: P1-T16, P13-T9.
- [ ] [P14-T58] Check off AC-58 (line 509). Evidence: WLOG entries from P1-T2, P3-T6, P4-T4, P5-T4, P6-T5, P7-T5, P8-T4, P9-T4, P10-T4 and the suite results appended by P3-T13 through P10-T15.
- [ ] [P14-T59] Check off AC-59 (line 510). Evidence: P3-T2.
- [ ] [P14-T60] Check off AC-60 (line 511). Evidence: P13-T9.
- [ ] [P14-T61] Check off AC-61 (line 515). Evidence: P12-T1, P12-T2, P12-T4 through P12-T16.
- [ ] [P14-T62] Check off AC-62 (line 516). Evidence: P13-T3, P13-T4, P13-T5, P13-T6.
- [ ] [P14-T63] Check off AC-63 (line 517). Evidence: P11-T4 (E2, E3).
- [ ] [P14-T64] Check off the four early-draft items of FEATURE/issue.md `## Acceptance Criteria (early draft)` (lines 62-68), each superseded by spec criteria: item 1 by AC-01/AC-16, item 2 by AC-17, item 3 by AC-14 through AC-16, item 4 by AC-49/AC-51. Acceptance: the four lines begin `- [x] ` and the ac-checkoff artifact records the mapping.
- [ ] [P14-T65] Verify and commit the check-off. Commands: `git grep -c -F -e "- [x] " -- docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/spec.md docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/issue.md`, then `git grep -c -F -e "- [ ] " -- docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/spec.md docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/issue.md`; then CMD-GIT-ADD with FEATURE/spec.md, FEATURE/issue.md, the FEATURE evidence directory, and PLAN, CMD-GIT-COMMIT with message "docs(690): check off acceptance criteria", CMD-GIT-PUSH. Acceptance: when AC-44 is checked, the first search prints `spec.md:64` (63 criteria plus the pre-existing `- [x] High`) and the second prints `spec.md:3` (the three Impact/Severity boxes); when AC-44 is left unchecked by P14-T44, the first prints `spec.md:63` and the second prints `spec.md:4`. In both cases the first search prints `issue.md:5` (four criteria plus the pre-existing promotion box) and the second prints no `issue.md` line, each path printed in full; CMD-GIT-STATUS prints nothing after the push.

---

## Acceptance Criteria Traceability

| AC | Implementation tasks | Verifying tasks | Evidence |
| --- | --- | --- | --- |
| AC-01 | P3-T4, P3-T5 | P3-T13 (G1A R1) | regression-testing/pre-worktree-resolution |
| AC-02 | P4-T3 | P4-T10 (G2 W1) | regression-testing/wave-worktree-resolution |
| AC-03 | P3-T5, P4-T3 | P3-T13 (G1A R2), P4-T10 (G2 W2) | regression-testing/pre-worktree-resolution, wave-worktree-resolution |
| AC-04 | P1-T1 | P1-T12 (T-REC X1) | regression-testing/lib-new-suites |
| AC-05 | P1-T1 | P1-T12 (T-REC C1) | regression-testing/lib-new-suites |
| AC-06 | P1-T1 | P1-T12 (T-SIG S1-S9) | regression-testing/lib-new-suites |
| AC-07 | P1-T1 | P1-T12 (T-RUN E1-E6) | regression-testing/lib-new-suites |
| AC-08 | P1-T1 | P1-T12 (T-RUN E7-E9) | regression-testing/lib-new-suites |
| AC-09 | P1-T1 | P1-T12 (T-RUN E10-E15, R4-R7) | regression-testing/lib-new-suites |
| AC-10 | P1-T1 | P1-T12 (T-RUN R1-R3) | regression-testing/lib-new-suites |
| AC-11 | P1-T1 | P1-T12 (T-REC B1-B12) | regression-testing/lib-new-suites |
| AC-12 | P1-T1 | P1-T12 (T-REC U1-U3) | regression-testing/lib-new-suites |
| AC-13 | P1-T2 | P1-T12 (T-REC X2, C2) | regression-testing/lib-new-suites |
| AC-14 | P3-T4, P3-T5 | P3-T13 (G1A R1-R3) | regression-testing/pre-worktree-resolution |
| AC-15 | P3-T4, P3-T5 | P3-T13 (G1A R4-R6) | regression-testing/pre-worktree-resolution |
| AC-16 | P3-T4, P3-T5 | P3-T13 (G1A R7-R10) | regression-testing/pre-worktree-resolution |
| AC-17 | P3-T4, P3-T5 | P3-T13 (G1B O1-O3) | regression-testing/pre-worktree-resolution |
| AC-18 | P3-T4, P3-T5 | P3-T13 (G1B O4-O5) | regression-testing/pre-worktree-resolution |
| AC-19 | P3-T4, P3-T5 | P3-T13 (G1B O10) | regression-testing/pre-worktree-resolution |
| AC-20 | P3-T5, P3-T9 | P3-T13 (G1A R13-R15), P3-T14 | qa-gates/pester-set-pre-p3 |
| AC-21 | P10-T3 | P10-T14 (T-ESR N1) | regression-testing/epic-scope-run-target |
| AC-22 | P10-T3 | P10-T14 (T-ESR N2, N3) | regression-testing/epic-scope-run-target |
| AC-23 | P10-T10 | P10-T15, P10-T17 | qa-gates/pester-set-epicscope-p10, epic-scope-callers-unchanged |
| AC-24 | P4-T3 | P4-T10, P4-T11 | regression-testing/wave-worktree-resolution |
| AC-25 | P5-T3 | P5-T10, P5-T11 | regression-testing/cohort-worktree-resolution |
| AC-26 | P4-T3 | P4-T12, P13-T6 | qa-gates/wave-folder-function-unchanged |
| AC-27 | P6-T3, P6-T4 | P6-T12 (G4 M1) | regression-testing/merge-worktree-resolution |
| AC-28 | P6-T3, P6-T4 | P6-T12 (G4 M2) | regression-testing/merge-worktree-resolution |
| AC-29 | P6-T3, P6-T4 | P6-T12 (G4 M3-M5) | regression-testing/merge-worktree-resolution |
| AC-30 | P6-T4 | P6-T12 (G4 M6) | regression-testing/merge-worktree-resolution |
| AC-31 | P6-T3, P6-T4 | P6-T12 (G4 M7-M9) | regression-testing/merge-worktree-resolution |
| AC-32 | P7-T3, P7-T4 | P7-T12, P7-T13 | regression-testing/erem-worktree-resolution |
| AC-33 | P8-T3 | P8-T10, P8-T11 | regression-testing/prem-worktree-resolution |
| AC-34 | P9-T3 | P9-T10, P9-T11 | regression-testing/drift-worktree-resolution |
| AC-35 | P3-T4, P4-T3, P5-T3, P6-T3, P7-T3, P8-T3, P9-T3 | G1B O7-O8, G2 W7, G3 C5, G4 M10, G5 V6, G6 Y6, G7 D6 | regression-testing/*-worktree-resolution |
| AC-36 | P11-T1 | P11-T4 | other/follow-up-entries |
| AC-37 | P3-T5 | P3-T13 (G1B O5, O6) | regression-testing/pre-worktree-resolution |
| AC-38 | P3-T5, P4-T3, P5-T3 | G1A R11, G2 W5, G3 C4 | regression-testing/pre-, wave-, cohort-worktree-resolution |
| AC-39 | P1-T1, P3-T5, P4-T3 | T-RUN E7, G1A R12, G2 W6 | regression-testing/lib-new-suites, pre-worktree-resolution |
| AC-40 | P2-T1 | P2-T8, P2-T9 | qa-gates/skill-contract-p2, skill-markers-p2 |
| AC-41 | P2-T2, P2-T3 | P2-T8, P2-T3 | qa-gates/skill-contract-p2 |
| AC-42 | P2-T4, P2-T5, P2-T6 | P2-T8 | qa-gates/skill-contract-p2 |
| AC-43 | P2-T11 | P13-T9 | qa-gates/commit-manifest |
| AC-44 | P1-T9, P2-T7, P3-T10, P4-T7, P5-T7, P6-T9, P7-T9, P8-T7, P9-T7, P10-T11 | P13-T1, P13-T7 | qa-gates/mirror-hashes-final, python-parity |
| AC-45 | P1-T7, P6-T8, P7-T8 | P13-T8 | qa-gates/registration |
| AC-46 | P1-T6 | P1-T13 | qa-gates/pester-set-lib-p1 |
| AC-47 | P1-T8, P6-T8, P7-T8 | P13-T8 | qa-gates/registration |
| AC-48 | P10-T5, P10-T6, P10-T9 | P10-T14, P10-T15 | regression-testing/epic-scope-run-target |
| AC-49 | P3-T7, P3-T8, P4-T5, P5-T5, P6-T6, P7-T6, P8-T5, P9-T5 | P3-T13, P4-T10, P5-T10, P6-T12, P7-T12, P8-T10, P9-T10 | regression-testing/*-worktree-resolution |
| AC-50 | all new and edited test files | P12-T18, P12-T19 | qa-gates/ac50-no-temp-files-new, -edited |
| AC-51 | P3-T9, P4-T6, P5-T6, P6-T7, P7-T7, P8-T6, P9-T6 | P3-T14, P4-T11, P5-T11, P6-T13, P7-T13, P8-T11, P9-T11, P12-T13 | qa-gates/pester-claude-hooks |
| AC-52 | Phases 1-10 | P12-T4 through P12-T12, P13-T10 | qa-gates/coverage-comparison |
| AC-53 | P1-T1 | P1-T13, P12-T14, P12-T15 | qa-gates/pester-claude-lib, pester-claude-runtime |
| AC-54 | (no write to the two files) | P3-T15, P13-T5 | qa-gates/byte-unchanged |
| AC-55 | all phases | P12-T17 | qa-gates/line-counts-final |
| AC-56 | P3-T4, P3-T5 | P3-T15, P3-T16 | qa-gates/pre-siblings-unchanged |
| AC-57 | P1-T19 | P1-T16, P13-T9 | qa-gates/no-hook-importer-p1, commit-manifest |
| AC-58 | SW-5 entries | WLOG | qa-gates/gate-wiring-order |
| AC-59 | P3-T2 | P3-T2 | qa-gates/pending-delegation-identity |
| AC-60 | P3-T18 through P10-T20 | P13-T9 | qa-gates/commit-manifest |
| AC-61 | Phase 12 | P12-T1, P12-T2, P12-T4 through P12-T16 | qa-gates/powershell-format, powershell-analyze |
| AC-62 | (no write to the protected paths) | P13-T3, P13-T4, P13-T5, P13-T6 | qa-gates/codex-scope, byte-unchanged |
| AC-63 | P11-T2, P11-T3 | P11-T4 | other/follow-up-entries |

---

## Appendix A — Staged Write and Wiring Log (see LH-2 and Appendix J)

The staged write procedure is defined in LH-2. Staged copies live under `SCRATCH/stage/` and are never committed.

## Appendix B — Implementation Specifications

### B1 — WRR `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` (new, at most 500 lines)

Module shape (satisfies `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`): a comment-based help block whose `.NOTES` contains the line `CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.`; then `Set-StrictMode -Version Latest` immediately followed by `$ErrorActionPreference = 'Stop'`; then three column-0 imports, each ending `-ErrorAction Stop`, of `WorktreeResolution.psm1`, `WorktreeTargetResolution.psm1`, and `WorktreeItemResolution.psm1` from `$PSScriptRoot`. No interpreter invocation, no subprocess, no `$env:` read, no clock read, no `Get-Location` call, no network call.

Script constants: `$script:EpicCheckpointRelativePath = 'artifacts/orchestration/epic-orchestrator-state.json'`; `$script:ParallelCheckpointRelativePath = 'artifacts/orchestration/parallel-orchestrator-state.json'`; `$script:EpicRouteId = 'epic'`; `$script:ParallelRouteId = 'parallel'`; `$script:HandoffRemedy = 'artifacts/orchestration/handoff/'`; three case-sensitive patterns `(?<![A-Za-z0-9_])integration_branch:[ \t]*(?<value>\S+)`, `(?<![A-Za-z0-9_])epic_feature_folder:[ \t]*(?<value>\S+)`, `(?<![A-Za-z0-9_])parallel_slug:[ \t]*(?<value>\S+)`.

Exported functions (seven; D2):

1. `Find-WorktreeRunIdentitySignal -Text` (pure; `[AllowNull()][AllowEmptyString()]`). Returns `[pscustomobject]@{ IntegrationBranch; EpicSlug; ParallelSlug }`. For each pattern, collect every match value, remove one trailing `.` from a value, drop empty values; zero distinct values yields `$null`, one yields that value, more than one distinct value yields `$null` (a prompt that names two different runs identifies none).
2. `Get-WorktreeRunCheckpointText -Path` (`[AllowNull()][AllowEmptyString()]`): `$null` for a blank path, `$null` when `Test-Path -LiteralPath $Path -PathType Leaf` is false, otherwise `[System.IO.File]::ReadAllText($Path)`, returning `$null` if that read throws. The module's only filesystem read and the test seam.
3. `Get-WorktreeRunCheckpointPath -Kind epic|parallel|item -WorktreeRoot`: `item` returns `Get-WorktreeItemCheckpointPath -WorktreeRoot`; `epic` and `parallel` return `Join-WorktreeResolutionPath` with the matching relative constant. A relative root throws (from `Join-WorktreeResolutionPath`).
4. `Resolve-WorktreeEpicTarget -IntegrationBranch [-EpicSlug] -SessionRoot` (all strings; `SessionRoot` mandatory):
   - Blank branch: `NoTarget`, detail "the call carries no integration_branch: value, so the epic run it belongs to cannot be identified"; no enumeration.
   - Enumerate `Get-WorktreeItemLiveRoot -SessionRoot` (assign before wrapping). Keep each root whose `Get-WorktreeRunCheckpointText` of the epic path parses (private `ConvertFrom-WorktreeRunCheckpointText`: `$null` for blank, unparseable, or non-`PSCustomObject` text) to an object with `route_id -ceq 'epic'` and `integration_branch -ceq` the branch.
   - When `EpicSlug` is non-blank and any kept root records an `epic_feature_folder` that is `-cne` the slug: `Ambiguous` with `-Signal 'Branch' -SignalValue <branch>`, the kept roots as candidates, and a detail naming both slugs.
   - Zero kept: `NoTarget`, detail "no live worktree's epic checkpoint records integration_branch '<branch>'". One kept: `ConvertTo-WorktreeItemResolvedResult -WorktreeRoot <root> -SessionRoot -Branch <branch> -Detail`. Several kept: intersect (after `ConvertTo-WorktreeResolutionNormalizedPath`) with `Get-WorktreeItemLiveRoot -SessionRoot -Branch <branch>`; exactly one survivor resolves through `ConvertTo-WorktreeItemResolvedResult`; otherwise `Ambiguous` with the kept roots as candidates and a detail that states the count and ends "move the stale copy to artifacts/orchestration/handoff/".
5. `Resolve-WorktreeParallelTarget -ParallelSlug -SessionRoot`: blank slug `NoTarget` without enumeration; keep live roots whose parallel checkpoint parses with `route_id -ceq 'parallel'` and `parallel_slug -ceq` the slug; zero `NoTarget`; one resolves through `ConvertTo-WorktreeItemResolvedResult` (no `-Branch`); several `Ambiguous` with the handoff remedy in the detail.
6. `Resolve-WorktreeRunTargetByRecord -Kind epic|parallel -RecordField pr_number|worktree_path -Value -SessionRoot`: blank `Value`, or a `pr_number` value that is not all digits, is `NoTarget` without enumeration. Keep live roots whose checkpoint of that kind parses with the kind's `route_id` and records the value: epic `pr_number` in `epic_merge_pr.pr_number` or any `features[].pr_number`; epic `worktree_path` in any `features[].worktree_path`; parallel in `items[].pr_number` or `items[].worktree_path`. PR comparison parses both sides as `[long]`. Path comparison (private `Test-WorktreeRunPathEqual`) replaces `\` with `/`, trims trailing `/`, and compares with `OrdinalIgnoreCase` when either side begins with a drive letter and colon, otherwise `Ordinal`. Zero, one, several as in item 5 (`Ambiguous` detail names the record field and value).
7. `Resolve-WorktreeOperandTarget -Path -SessionRoot`: the session worktree is `Find-WorktreeResolutionRoot -Path SessionRoot`, or the normalized `SessionRoot` when that is `$null`. A blank operand returns `ConvertTo-WorktreeItemResolvedResult` for the session worktree. A relative operand is joined to `SessionRoot` with `Join-WorktreeResolutionPath`. The operand is placed by `Find-WorktreeResolutionRoot`; `$null` returns the session worktree result with a detail stating the operand lies in no worktree; otherwise `ConvertTo-WorktreeItemResolvedResult` for the found root.

Every result is built by `New-WorktreeResolutionTargetResult` or `ConvertTo-WorktreeItemResolvedResult`, so `ReasonCode` comes from the two accessors. `Export-ModuleMember -Function` lists exactly the seven functions above.

### B2 — WIR `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1` (changed through SW)

Replace the four comment lines 216-219 by a comment-based help block inside `ConvertTo-WorktreeItemResolvedResult` (`.SYNOPSIS` "Convert a resolved root and session path into a SessionRoot or OtherWorktree result.", `.DESCRIPTION` stating it is exported for issue #690 so the run resolver shares one labelling definition and that the ConvertTo verb is deliberate, and one `.PARAMETER` entry each for `WorktreeRoot`, `SessionRoot`, `Detail`, `Branch`). The help text does not contain the function name. Add the line `    ConvertTo-WorktreeItemResolvedResult, `` (with its trailing backtick continuation) to the export list after `Get-WorktreeItemLiveRoot, ``. No other line changes.

### B3 — PRES `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` (changed through SW; written before PRE)

- Header `.DESCRIPTION`/`.NOTES` updated to state the relocated functions (D4) and the import guard.
- Import guard, placed before the existing ESR import (LH-6): `$script:OrchestrationGateResolutionImportFailure = $null`, then for each of `WorktreeItemResolution.psm1`, `WorktreeRunResolution.psm1`, `EpicScopeResolution.psm1` (in that order, from `../lib/worktree-resolution/`) a `try { Import-Module <path> -Force -ErrorAction Stop } catch { if (-not $script:OrchestrationGateResolutionImportFailure) { $script:OrchestrationGateResolutionImportFailure = '<file name>' } }`. The unguarded ESR import line 30 is removed (the guard now imports ESR); the `EpicScopeReadiness.psm1` import at line 31 is unchanged.
- `Get-OrchestrationGateImportFailureDecision`: returns `$null` when the variable is empty; otherwise `Get-OrchestrationPreimplementationGateBlockDecision -Reason ("PREIMPLEMENTATION_GATE_BLOCKED: the worktree-resolution module '<name>' failed to import, so the checkpoint that governs this call cannot be located; the gate fails closed.")`.
- `Get-CheckpointContent -Path`, `Get-EpicCheckpointContent -Path`, `Get-ParallelCheckpointContent -Path`: each `[Parameter(Mandatory)][ValidatePattern('^([A-Za-z]:[\\/]|/)')][string] $Path`; `''` when `Test-Path -LiteralPath $Path` is false; otherwise `Get-Content -Raw -LiteralPath $Path`.
- `Get-OrchestrationModeDenyReason -Mode -Failure [-CheckpointPath]` (relocated from PRE lines 298-313): when `CheckpointPath` is non-empty it is named instead of `Get-OrchestrationDelegationCheckpointPath -Mode`; the wording is otherwise unchanged.
- `Resolve-OrchestrationGateTarget -Mode -Prompt -FilePath -Command` (resolution seam): `epic` resolves `Resolve-WorktreeEpicTarget -IntegrationBranch <signal.IntegrationBranch> -EpicSlug <signal.EpicSlug>`; `parallel` resolves `Resolve-WorktreeParallelTarget -ParallelSlug <signal.ParallelSlug>`; single-feature with `FilePath` resolves `Resolve-WorktreeOperandTarget -Path $FilePath`; single-feature with `Command` resolves `Resolve-WorktreeOperandTarget -Path (Get-OrchestrationEpicScopeSelector -Command $Command)` (a `$null` selector means the session root); single-feature with neither resolves `Resolve-WorktreeItemTarget -Text $Prompt`. Every call passes `-SessionRoot (Get-Location).Path`.
- `Read-OrchestrationGateCheckpoint -Mode -Prompt -FilePath -Command`: calls the seam; for `NoTarget`/`Ambiguous` returns `[pscustomobject]@{ Resolved = $false; Raw = ''; Path = $null; DenyReason = "PREIMPLEMENTATION_GATE_BLOCKED: <ReasonCode>: the target worktree of this <mode> call could not be resolved: <Detail>. Implementation operations require an identifiable target worktree whose checkpoint is ready." }`; otherwise composes `Get-WorktreeRunCheckpointPath -Kind (epic|parallel|item) -WorktreeRoot <target.WorktreeRoot>`, reads it through the mode's read seam, and returns `Resolved = $true` with `Raw` and `Path`. It reads only `Status`, `WorktreeRoot`, `ReasonCode`, and `Detail` from the target.
- `Get-OrchestrationEpicScopeSelector` and `Get-OrchestrationEpicScopeDecision` keep their names, parameters, and bodies.
- No `Test-Path` or `Get-Content` call in PRES receives a relative literal.

### B4 — PRE `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` (changed through SW; at most 500 lines, estimate about 472)

- Remove `$script:CheckpointPath` (lines 30-31), `Get-CheckpointContent` (257-266), and `Get-OrchestrationModeDenyReason` (298-313); both now come from PRES.
- `Invoke-OrchestrationPreimplementationGateDecision`: first statement `$importFailure = Get-OrchestrationGateImportFailureDecision; if ($null -ne $importFailure) { return $importFailure }`. Everything up to and including the epic-scope leg (lines 340-394) is unchanged.
- Mode branch: when the injected parameter is bound (`ContainsKey`), use it (no resolution); otherwise `$read = Read-OrchestrationGateCheckpoint -Mode $mode -Prompt $prompt`; unresolved returns the block decision with `$read.DenyReason`; resolved uses `$read.Raw` and passes `-CheckpointPath $read.Path` to `Get-OrchestrationModeDenyReason`.
- Single-feature read: `if (-not $CheckpointRaw)` (truthiness, D6) calls `Read-OrchestrationGateCheckpoint -Mode 'single-feature' -Prompt $prompt -FilePath $filePath -Command $command`; unresolved returns its deny; resolved sets `$CheckpointRaw = $read.Raw`. The deny text at line 429 is unchanged.
- The entry point, guard, and tail are unchanged.

### B5 — WAVE `.claude/hooks/enforce-epic-wave-barrier.ps1` (changed through SW)

- Import guard after the `HookPayload.psm1` import: `$script:EpicWaveBarrierResolutionImportFailure` recorded for `WorktreeRunResolution.psm1` (`-Force -ErrorAction Stop` inside `try`).
- Remove `$script:EpicCheckpointPath`; `Get-EpicWaveBarrierCheckpointContent -Path` (mandatory, absolute-path `ValidatePattern`), `$null` when absent.
- New seam `Resolve-EpicWaveBarrierTarget -Prompt`: `Resolve-WorktreeEpicTarget` keyed on `Find-WorktreeRunIdentitySignal`'s `IntegrationBranch` and `EpicSlug`, `-SessionRoot (Get-Location).Path`.
- Decision: import-failure deny first (`EPIC_WAVE_BARRIER_BLOCKED: the worktree-resolution module 'WorktreeRunResolution.psm1' failed to import, ...`); then the envelope and scope filter unchanged; then resolution; `NoTarget`/`Ambiguous` deny `EPIC_WAVE_BARRIER_BLOCKED: <ReasonCode>: <Detail>`; then the folder check and the read of `Get-WorktreeRunCheckpointPath -Kind epic -WorktreeRoot <root>`. The final deny text is unchanged.
- `Find-EpicWaveBarrierFeatureFolderFromPrompt` is copied byte-for-byte (P4-T12 checks it).
- `.NOTES` names the new module dependency.

### B6 — COH `.claude/hooks/enforce-parallel-cohort-barrier.ps1` (changed through SW)

As B5 with `$script:ParallelCohortBarrierResolutionImportFailure`, `Get-ParallelCohortBarrierCheckpointContent -Path`, seam `Resolve-ParallelCohortBarrierTarget -Prompt` (`Resolve-WorktreeParallelTarget` keyed on `ParallelSlug`), token `PARALLEL_COHORT_BARRIER_BLOCKED`, path kind `parallel`. The helpers dot-source is unchanged.

### B7 — MRGR (new) and MRG (changed), both through SW, MRGR first

MRGR `.claude/hooks/enforce-epic-merge-gate-resolution.ps1`: header (synopsis, issue #690, dot-sourced by MRG); import guard `$script:EpicMergeGateResolutionImportFailure` for `WorktreeRunResolution.psm1`; `Get-EpicMergeGateImportFailureDecision` (returns `$null` or the `EPIC_MERGE_GATE_BLOCKED` module deny, built with `Get-EpicMergeGateBlockDecision`); the three read seams relocated from MRG lines 67-119 with the same names, each taking `-Path` (mandatory, absolute `ValidatePattern`); `Get-EpicMergeGateSessionWorktreeRoot` returning `(Resolve-WorktreeOperandTarget -Path '' -SessionRoot (Get-Location).Path).WorktreeRoot`; seam `Resolve-EpicMergeGateRunTarget -Kind epic|parallel -PrNumber` calling `Resolve-WorktreeRunTargetByRecord -Kind -RecordField pr_number -Value ([string]$PrNumber) -SessionRoot (Get-Location).Path`; `Test-ChildCheckpointPrGateBinding -Checkpoint -CommandPrNumber` (`$true` when `CommandPrNumber` is `$null`, when the checkpoint is `$null`, or when it carries no `pr_gate` object or no `pr_gate.pr_number`; `$true` when both parse as integers and are equal; `$false` otherwise); `Get-EpicMergeGateUnresolvedReason -EpicTarget -ParallelTarget` (`$null` unless both targets are non-null and neither is resolved; then `<code>: <epic detail>; <parallel detail>`, with the ambiguity code when either is `Ambiguous`).

MRG: remove lines 63-119 (path variables and read seams); dot-source MRGR immediately after the authorization dot-source (line 61). Decision: import-failure check first; envelope and scope filter unchanged; `$commandPrNumber` unchanged; `$sessionRoot = Get-EpicMergeGateSessionWorktreeRoot`; child: read at `Get-WorktreeRunCheckpointPath -Kind item -WorktreeRoot $sessionRoot`, allow only when `Test-ChildCheckpointAllowsEpicMerge` and `Test-ChildCheckpointPrGateBinding` both hold; epic and parallel: when `$commandPrNumber` is `$null` read at the session root (no seam call), otherwise resolve each kind through the seam and read at the resolved root (`$null` checkpoint when unresolved); allow conditions and the standalone branch unchanged; the standalone deny becomes `'EPIC_MERGE_GATE_BLOCKED: ' + <unresolved reason + '; ' when present> + $standalone.ReasonCode + ': ' + $standalone.Message` (D8); the bare-command final deny (line 429) is unchanged.

### B8 — EREMR (new) and EREM (changed), both through SW, EREMR first

EREMR `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1`: import guard `$script:EpicWorktreeGateResolutionImportFailure`; `Get-EpicWorktreeGateImportFailureDecision`; the two read seams relocated from EREM lines 78-112 with the same names, each taking `-Path`; seam `Resolve-EpicWorktreeGateRunTarget -Kind epic|parallel -WorktreePath` calling `Resolve-WorktreeRunTargetByRecord -RecordField worktree_path -SessionRoot (Get-Location).Path`; `Read-EpicWorktreeGateRunCheckpoint -Kind -WorktreePath` returning `[pscustomobject]@{ Target; Checkpoint }` (checkpoint parsed with `ConvertFrom-EpicWorktreeGateJson`, `$null` when unresolved).

EREM: remove lines 70-71 and 78-112; dot-source EREMR after the command-parser dot-sources. Decision: import-failure check first; envelope and scope unchanged; read both kinds through `Read-EpicWorktreeGateRunCheckpoint`; either target `Ambiguous` denies `EPIC_WORKTREE_REMOVAL_BLOCKED: TARGET_WORKTREE_AMBIGUOUS: <detail>` before any allow or manifest evaluation; the epic and parallel allow conditions and the manifest branch use the two checkpoints exactly as today; the final deny is prefixed with `EPIC_WORKTREE_REMOVAL_BLOCKED: TARGET_WORKTREE_NOT_DERIVABLE: <epic detail>. ` only when both targets are `NoTarget`, and is otherwise byte-identical (D9).

### B9 — PREM `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` (changed through SW)

Inline equivalent of B8: import guard `$script:ParallelWorktreeGateResolutionImportFailure`; remove the two checkpoint-path variables (lines 42, 49); the two read seams take `-Path`; seam `Resolve-ParallelWorktreeGateRunTarget -Kind -WorktreePath`; decision as B8 with token `PARALLEL_WORKTREE_REMOVAL_BLOCKED` (parallel kind read first, epic kind second, manifest coverage over `items` only, exactly as today).

### B10 — DRIFT `.claude/hooks/enforce-parallel-drift-gate.ps1` (changed through SW)

As B6 with `$script:ParallelDriftGateResolutionImportFailure`, `Get-ParallelDriftGateCheckpointContent -Path`, seam `Resolve-ParallelDriftGateTarget -Prompt`, token `PARALLEL_DRIFT_GATE_BLOCKED`. Resolution runs after the subagent and marker filter (lines 296-303) and before the folder check. The missing-checkpoint deny keeps the phrase "is missing or unreadable" and names `'artifacts/orchestration/parallel-orchestrator-state.json' in worktree '<root>'` (D14). The finding-presence seam and helpers dot-source are unchanged.

### B11 — ESR `.claude/lib/worktree-resolution/EpicScopeResolution.psm1` (changed through SW)

- Add a column-0 `Import-Module (Join-Path $PSScriptRoot 'WorktreeRunResolution.psm1') -ErrorAction Stop` after the two existing imports.
- Rewrite the `.DESCRIPTION` paragraphs to state that the checkpoint is located by `Resolve-WorktreeEpicTarget` keyed on the matched branch, never composed from the session root.
- `Resolve-EpicScopeCheckpoint` order: (1) branch signal or `no-branch-signal`; (2) `$root = Find-WorktreeResolutionRoot -Path $SessionRoot` or `session-root-unresolved`; (3) the candidate branch: the text signal, or for `-MatchWorktreeHead` the HEAD of the effective root (selector root when given, else `$root`; `selector-unresolved` when the selector places nowhere); a `$null` candidate returns `branch-mismatch`; (4) `$target = Resolve-WorktreeEpicTarget -IntegrationBranch $candidate -SessionRoot $root`; `NoTarget` returns `IsEpicScope $false`, `CheckpointPath $null`, reason `epic-checkpoint-absent-or-unparseable`; `Ambiguous` returns `IsEpicScope $false`, reason `target-worktree-ambiguous`; (5) `$path = Join-WorktreeResolutionPath -WorktreeRoot $target.WorktreeRoot -RepoRelativePath (Get-EpicScopeCheckpointRelativePath)` and exactly one `Get-EpicScopeCheckpointText -Path $path` read; the existing absent, `route_id`, `integration_branch`, and `branch-mismatch` checks follow unchanged; (6) the merge probe of the effective root for `-MatchWorktreeHead` as today. It reads only `Status`, `WorktreeRoot`, `ReasonCode`, and `Detail` from the target.
- Exports unchanged.

## Appendix C — Test Specifications

Every new suite: `#Requires -Version 7.0` and the Pester 5 requirement; every `It` name (after `-ForEach` template expansion) is unique within its suite when compared case-insensitively, so that the name-based `FAILED:` comparison against baseline failure sets cannot conflate two rows; Arrange/Act/Assert comments; synthetic roots `/synthetic-worktrees/<name>`; no file creation, `TestDrive:`, clock read, subprocess, or network. Hook suites dot-source the hook first, then import library modules without `-Force`, then register mocks (research section 7 pattern). Where a row needs a target object it uses `New-WorktreeResolutionFixtureTarget` from `tests/scripts/claude-hooks/WorktreeResolutionFixture.Helpers.ps1` (imported `WorktreeTargetResolution.psm1` supplies the constructor). "Real resolver" rows mock `Get-WorktreeItemLiveRoot -ModuleName WorktreeRunResolution` (returning `, [string[]] @(...)`, filtered on `$Branch` where needed) and `Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution` (in-memory JSON keyed on `$Path`); the session root in those rows is `(Get-Location).Path` with backslashes replaced by `/`, returned by the live-root mock alongside the synthetic roots with no checkpoint text.

### C0 — Default mocks

DT-LINE (one line, `<Seam>` named per task):

```powershell
Mock <Seam> { [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = '/synthetic-worktrees/default-session'; ReasonCode = $null; Detail = 'default SessionRoot target (issue #690)' } }
```

ESR-DEFAULT (one line):

```powershell
Mock Resolve-WorktreeEpicTarget -ModuleName EpicScopeResolution { [pscustomobject]@{ Status = 'SessionRoot'; WorktreeRoot = $SessionRoot; ReasonCode = $null; Detail = 'default SessionRoot target (issue #690)' } }
```

### C1 — T-SIG (16 rows)

S1 `integration_branch: epic/repro-integration.` inside the full epic kickoff sentence returns `epic/repro-integration`; S2 `epic_feature_folder: repro.` returns `repro`; S3 `parallel_slug: wave-a.` returns `wave-a`; S4 a value followed by a space keeps its full token; S5 `Integration_Branch: x` returns `$null` (case-sensitive); S6 absent literals return three `$null` fields; S7 `xintegration_branch: y` returns `$null`; S8 two different `integration_branch:` values return `$null`; S9 `$null` and empty text return three `$null` fields (one row, both inputs). T1 blank path returns `$null`; T2 `/synthetic-worktrees/none/artifacts/orchestration/epic-orchestrator-state.json` returns `$null`; T3 the suite's own committed file (`$PSCommandPath`) returns text containing `Get-WorktreeRunCheckpointText`. P1 epic path; P2 parallel path; P3 item path; P4 relative root throws.

### C2 — T-RUN (22 rows)

E1 blank branch `NoTarget`, `ReasonCode` `TARGET_WORKTREE_NOT_DERIVABLE`, live-root mock invoked 0 times; E2 zero matches `NoTarget`; E3 one match at `/synthetic-worktrees/w-epic` resolves `OtherWorktree` there; E4 one match at the session root resolves `SessionRoot`; E5 slug disagreement `Ambiguous` (`TARGET_WORKTREE_AMBIGUOUS`); E6 slug agreement resolves; E7 tie-break reproducing the observed pair: matching checkpoints at `/synthetic-worktrees/2026-09-29T13-45` (the session root in this row) and `/synthetic-worktrees/2026-09-29T14-15-epic-770`, the `-Branch` enumeration returning only the second, resolves `OtherWorktree` at the second; E8 two matches and the branch enumeration returning neither: `Ambiguous`, `Detail` contains `artifacts/orchestration/handoff/`; E9 two matches both returned by the branch enumeration: `Ambiguous` with the same detail; E10-E15 (`-ForEach`, six rows) a single live root whose text is `$null`, `''`, `'{'`, `'[]'`, a `route_id` of `parallel`, or a different `integration_branch` yields `NoTarget`. R1 blank slug `NoTarget` without enumeration; R2 one match resolves; R3 two matches `Ambiguous`; R4-R7 (`-ForEach`, four rows) unparseable, array, `route_id` `epic`, different slug yield `NoTarget`.

### C3 — T-REC (27 rows)

B1 epic by `epic_merge_pr.pr_number`; B2 epic by `features[].pr_number`; B3 epic by `features[].worktree_path` recorded as `C:\wt\child\` against `C:/wt/child`; B4 parallel by `items[].pr_number`; B5 parallel by `items[].worktree_path`; B6 zero matches `NoTarget`; B7 two matches `Ambiguous`; B8 blank value `NoTarget` without enumeration; B9 `pr_number` value `12a` `NoTarget` without enumeration; B10 epic kind over a `route_id` `parallel` checkpoint `NoTarget`; B11 `C:/Wt/A` matches `c:\wt\a\`; B12 `/wt/A` does not match `/wt/a`. Q1 absolute operand inside another worktree resolves `OtherWorktree` (mock `Find-WorktreeResolutionRoot -ModuleName WorktreeRunResolution`); Q2 operand inside the session worktree resolves `SessionRoot`; Q3 operand in no worktree resolves `SessionRoot` at the session worktree; Q4 blank operand resolves `SessionRoot`; Q5 relative operand is joined to the session root before placement (asserted through the mock's `ParameterFilter`). C1 (`-ForEach`, four rows: epic `NoTarget`, parallel `Ambiguous`, record `OtherWorktree`, operand `SessionRoot`) every result carries `Status`, `WorktreeRoot`, `SessionRoot`, `Signal`, `SignalValue`, `Candidates`, `ReasonCode`, `Detail`, and `ReasonCode` equals `Get-WorktreeResolutionNoTargetReasonCode` / `Get-WorktreeResolutionAmbiguityReasonCode` / `$null` accordingly; C2 with `ConvertTo-WorktreeItemResolvedResult` mocked in module scope `WorktreeRunResolution` to return a `SessionRoot` stub, a resolving epic call returns that stub and the mock is invoked exactly once (`Should -Invoke -ModuleName WorktreeRunResolution -Times 1 -Exactly`), showing the labelling is delegated rather than reimplemented. U1 AST scan of WRR: every `Test-Path`, `Get-Content`, `Get-ChildItem`, `Get-Item` command and every `[System.IO.File]` member call lies inside `Get-WorktreeRunCheckpointText`; U2 no command named `Start-Process`, `Invoke-Expression`, `git`, `gh`, `pwsh`, `python`, `poetry`, and no `&` invocation of a string; U3 no `$env:` variable, no `Get-Date`, `Get-Location`, `Invoke-WebRequest`, `Invoke-RestMethod`, and no `[DateTime]::Now` or `System.Net` type. X1 WRR exports the seven functions of B1; X2 WIR exports `ConvertTo-WorktreeItemResolvedResult`.

### C4 — T-ESR (4 rows; module-scope mocks in `EpicScopeResolution` and `WorktreeRunResolution`)

N1 a head-matched command leg on the integration branch, with the matching epic checkpoint only at `/synthetic-worktrees/w-epic`, returns `IsEpicScope $true` and `CheckpointPath` `/synthetic-worktrees/w-epic/artifacts/orchestration/epic-orchestrator-state.json`; N2 no match returns `IsEpicScope $false`, reason `epic-checkpoint-absent-or-unparseable`; N3 two unresolvable matches return reason `target-worktree-ambiguous`; N4 a resolving call reads `Get-EpicScopeCheckpointText` exactly once with the resolved path.

### C5 — G1A (15 rows; seam `Resolve-OrchestrationGateTarget`)

R1 reproduction admitted (real resolver; ready epic checkpoint only at `/synthetic-worktrees/w-epic` in the ready-epic shape used by `enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`; prompt `Epic mode: true. epic_feature_folder: repro. integration_branch: epic/repro-integration. ...` plus the child folder and issue line): allow, and `Get-EpicCheckpointContent` invoked once with `-Path` `/synthetic-worktrees/w-epic/artifacts/orchestration/epic-orchestrator-state.json`; R2 reproduction denied (real resolver, no epic checkpoint anywhere): deny containing `PREIMPLEMENTATION_GATE_BLOCKED` and `TARGET_WORKTREE_NOT_DERIVABLE`, read seam 0 times; R3 epic `Ambiguous` (seam): deny with `TARGET_WORKTREE_AMBIGUOUS`; R4 parallel `OtherWorktree` at `/synthetic-worktrees/w-par` (seam): `Get-ParallelCheckpointContent` called with that root's path, allow with a ready parallel checkpoint; R5 parallel prompt without `parallel_slug:` (real resolver): deny `TARGET_WORKTREE_NOT_DERIVABLE`; R6 parallel `Ambiguous` (seam): deny; R7 `Agent(powershell-typed-engineer)` `OtherWorktree` at `/synthetic-worktrees/w-item` (seam): `Get-CheckpointContent` called with that root's path, allow with a ready checkpoint; R8 typed-engineer prompt with neither identity line (real resolver): deny `PREIMPLEMENTATION_GATE_BLOCKED:` and `TARGET_WORKTREE_NOT_DERIVABLE`, `Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution` invoked 0 times; R9 typed-engineer `Ambiguous` (seam): deny; R10 non-mode `Agent(orchestrator)` without identity lines (real resolver): deny `TARGET_WORKTREE_NOT_DERIVABLE`; R11 epic checkpoint only at the session root (real resolver): the decision equals the decision for the same text passed through `-EpicCheckpointRaw`; R12 stale matching copy at the session root and a second match at `/synthetic-worktrees/w-epic` that has the branch checked out (real resolver): the read targets `w-epic`; R13 bound non-empty `-CheckpointRaw`: seam 0 times; R14 bound `-EpicCheckpointRaw ''`: seam 0 times; R15 bound `-ParallelCheckpointRaw`: seam 0 times.

### C6 — G1B (10 rows; outermost `BeforeAll` follows the GUARD pattern: dot-source PRE, import ESR, `$null` mock of `Get-EpicScopeCheckpointText`, import WRR, `$null` mock of `Get-WorktreeRunCheckpointText`)

O1 Write to `/synthetic-worktrees/w-item/scripts/Sample.ps1` with the seam returning `OtherWorktree` there and a ready checkpoint: allow, read path under `w-item`; O2 same with a not-ready checkpoint: deny; O3 same with the read seam returning `''`: deny; O4 `git -C /synthetic-worktrees/w-item add scripts/Sample.ps1` (real operand resolution, `Find-WorktreeResolutionRoot -ModuleName WorktreeRunResolution` mocked): the read path is under `w-item`; O5 `git add scripts/Sample.ps1` (no selector): the read path is under the session worktree; O6 Write inside the session worktree: the decision equals the decision for the same checkpoint text passed through `-CheckpointRaw`; O7 `$script:OrchestrationGateResolutionImportFailure = 'WorktreeRunResolution.psm1'`: the decision denies naming the module, and `Invoke-OrchestrationPreimplementationGateEntryPoint -ToolInputRaw <payload>` returns 0 with a JSON line containing `deny` (the variable is restored in `finally`); O8 same for `WorktreeItemResolution.psm1`: deny naming it; O9 Write with the seam returning `Ambiguous`: deny with `PREIMPLEMENTATION_GATE_BLOCKED`, `TARGET_WORKTREE_AMBIGUOUS`, and the target `Detail`; O10 AST scan of PRE, PRES, the modes file, and the helpers file: no `Test-Path` or `Get-Content` command argument is a string constant beginning `artifacts/` or a `$script:*CheckpointPath` variable, and `Get-CheckpointContent`, `Get-EpicCheckpointContent`, `Get-ParallelCheckpointContent` each declare a mandatory `Path` parameter.

### C7 — G2 (9 rows; seam `Resolve-EpicWaveBarrierTarget`)

W1 reproduction admitted at the barrier (real resolver; dependencies merged at `w-epic`): allow, `Get-EpicWaveBarrierCheckpointContent` invoked once with the `w-epic` path; W2 reproduction denied (no epic checkpoint anywhere): deny containing `EPIC_WAVE_BARRIER_BLOCKED` and `TARGET_WORKTREE_NOT_DERIVABLE`, read seam 0 times; W3 seam `Ambiguous`: deny `TARGET_WORKTREE_AMBIGUOUS`; W4 seam `OtherWorktree` with a dependency not merged: the existing dependency deny text, read path under the target; W5 only match at the session root: decision equals the pre-change decision for the same checkpoint (seam returns `SessionRoot`, read seam returns the same JSON); W6 stale session-root copy and branch-checked-out second match (real resolver): read targets the second root; W7 import failure: deny naming `WorktreeRunResolution.psm1`, entry point returns 0 with a deny JSON line; W8 non-orchestrator subagent: allow, seam 0 times; W9 orchestrator prompt without the epic marker: allow, seam 0 times.

### C8 — G3 (7 rows; seam `Resolve-ParallelCohortBarrierTarget`)

C1 real resolver, one matching parallel checkpoint at `w-par`, barrier clear: allow, read path under `w-par`; C2 prompt without `parallel_slug:`: deny `PARALLEL_COHORT_BARRIER_BLOCKED` and `TARGET_WORKTREE_NOT_DERIVABLE`; C3 real resolver, two matches: deny `TARGET_WORKTREE_AMBIGUOUS`; C4 only match at the session root: decision equals the pre-change decision; C5 set `$script:ParallelCohortBarrierResolutionImportFailure` to `'WorktreeRunResolution.psm1'`: the decision denies naming the module, the entry point returns 0 with a JSON line containing `deny`, and the variable is restored in `finally`; C6 non-orchestrator: allow, seam 0 times; C7 no parallel marker: allow, seam 0 times.

### C9 — G4 (10 rows; seam `Resolve-EpicMergeGateRunTarget`)

M1 `gh pr merge --merge 812`, real record resolver, the ready epic checkpoint (`epic_merge_pr.pr_number` 812, `ci_gate.conclusion` `success`) only at `w-epic`: allow; M2 same for a parallel checkpoint (`items[].pr_number` 812, `merge_status` `ci_green`) only at `w-par`: allow; M3 child checkpoint `epic_mode` true, `step9_status` passed, `pr_gate.pr_number` 811, command PR 812, epic and parallel unresolved, no standalone record: deny; M4 same with `pr_gate.pr_number` 812: allow; M5 child checkpoint without `pr_gate`: allow as today; M6 bare `gh pr merge --merge`: the three read seams are called with session-worktree paths and the seam is invoked 0 times; M7 PR 812, both kinds `NoTarget`, no standalone record: deny containing `EPIC_MERGE_GATE_BLOCKED` and `TARGET_WORKTREE_NOT_DERIVABLE`; M8 epic `Ambiguous`, parallel `NoTarget`: deny containing `TARGET_WORKTREE_AMBIGUOUS`; M9 both `NoTarget` with a valid standalone record for 812 in the child checkpoint and a matching envelope `session_id` (record shape as in `enforce-epic-merge-gate.Authorization.Tests.ps1`): allow; M10 set `$script:EpicMergeGateResolutionImportFailure` to `'WorktreeRunResolution.psm1'`: the decision denies naming the module, the entry point returns 0 with a JSON line containing `deny`, and the variable is restored in `finally`.

### C10 — G5 (6 rows; seam `Resolve-EpicWorktreeGateRunTarget`)

V1 epic record (`features[].worktree_path`, `merge_status` merged) at `w-epic` only (real resolver): allow; V2 parallel record at `w-par` only: allow; V3 both `NoTarget`, manifest non-authorizing: deny containing `EPIC_WORKTREE_REMOVAL_BLOCKED` and `TARGET_WORKTREE_NOT_DERIVABLE`; V4 epic `Ambiguous`: deny `TARGET_WORKTREE_AMBIGUOUS`, `Test-CleanupWorktreeManifestAuthorizesRemoval` invoked 0 times; V5 both `NoTarget`, manifest authorizing: allow; V6 set `$script:EpicWorktreeGateResolutionImportFailure` to `'WorktreeRunResolution.psm1'`: the decision denies naming the module, the entry point returns 0 with a JSON line containing `deny`, and the variable is restored in `finally`.

### C11 — G6 (6 rows; seam `Resolve-ParallelWorktreeGateRunTarget`)

Y1-Y6 as V1-V6 with the token `PARALLEL_WORKTREE_REMOVAL_BLOCKED` (Y1 parallel record, Y2 epic record, Y3 both `NoTarget` non-authorizing manifest, Y4 parallel `Ambiguous` with manifest 0 times, Y5 both `NoTarget` authorizing manifest, Y6 set `$script:ParallelWorktreeGateResolutionImportFailure` to `'WorktreeRunResolution.psm1'`: the decision denies naming the module, the entry point returns 0 with a JSON line containing `deny`, and the variable is restored in `finally`).

### C12 — G7 (6 rows; seam `Resolve-ParallelDriftGateTarget`)

D1 real resolver, parallel checkpoint at `w-par` with no unresolved drift for the item: allow, read path under `w-par`; D2 prompt without `parallel_slug:`: deny `PARALLEL_DRIFT_GATE_BLOCKED` and `TARGET_WORKTREE_NOT_DERIVABLE`; D3 seam `Ambiguous`: deny; D4 non-`feature-review` subagent: allow, seam 0 times; D5 no marker: allow, seam 0 times; D6 set `$script:ParallelDriftGateResolutionImportFailure` to `'WorktreeRunResolution.psm1'`: the decision denies naming the module, the entry point returns 0 with a JSON line containing `deny`, and the variable is restored in `finally`.

### C14 — GUARD and GUARDH (GUARD 33 rows after the change)

GUARDH (`tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1`): the helper functions of GUARD lines 31-187 moved verbatim, with `Get-EpicStateIsolationFinding` extended to also require, inside the outermost `BeforeAll`, an `Import-Module` of `WorktreeRunResolution.psm1` without `-Force` placed after the hook dot-source, followed by a `Mock` of `Get-WorktreeRunCheckpointText` with `-ModuleName WorktreeRunResolution` whose body is exactly `$null`. New finding strings: "Mock of Get-WorktreeRunCheckpointText missing from outermost BeforeAll", "Mock lacks -ModuleName WorktreeRunResolution", "Import-Module of WorktreeRunResolution.psm1 missing from outermost BeforeAll", "Import-Module of WorktreeRunResolution.psm1 uses -Force". `Get-EpicStateIsolationSuiteFinding` takes the repository root as a parameter.

GUARD rows: the guard list of eight suites (the seven current plus G1B) — 8 rows; two compliant fixtures (each now carrying both pairs) — 2 rows; the six existing rejection fixtures (each now carrying the WRR pair so it fails only for its original reason) plus four new rejections for the four new finding strings — 10 rows; the missing-path row — 1 row; seam sufficiency over the four hostile shapes: control (lower seams hostile, `Get-WorktreeItemLiveRoot` and `Get-WorktreeRunCheckpointText` in `WorktreeRunResolution` returning the session root and hostile JSON; `IsEpicScope` true and one epic read) — 4 rows; treatment A (both `$null` mocks: reason `epic-checkpoint-absent-or-unparseable`, `Get-EpicScopeCheckpointText -Times 0 -Exactly`, head-branch reads `-Times ([int]$MatchWorktreeHead) -Exactly`, merge probe 0) — 4 rows; treatment B (only the `Get-EpicScopeCheckpointText` `$null` mock: `Get-EpicScopeCheckpointText -Times 1 -Exactly`, epic `GitFileText` read 0 times) — 4 rows. Total 33 (24 before the change, plus 9). The seam-sufficiency `BeforeAll` imports ESR with `-Force` and then WRR without `-Force`.

## Appendix D — Skill Text Edits

### D1 — `.claude/skills/orchestrate/SKILL.md`

On line 263 replace "Two gates, `enforce-model-routing-receipt.ps1` and `enforce-prd-feature-before-planner.ps1`, identify the item from these two lines" with "Three gates, `enforce-model-routing-receipt.ps1`, `enforce-prd-feature-before-planner.ps1`, and `enforce-orchestration-preimplementation-gate.ps1`, identify the item from these two lines". Then insert, after line 263, a blank line and this single-line paragraph:

```text
The same two lines are required on every delegation to an implementation agent (`python-typed-engineer`, `powershell-typed-engineer`, `typescript-engineer`, `csharp-typed-engineer`, and `atomic-executor`) and on every `Agent(orchestrator)` delegation that carries no epic-mode, parallel-mode, or preparation-mode kickoff marker. `enforce-orchestration-preimplementation-gate.ps1` resolves such a delegation's worktree from these lines and denies it with `TARGET_WORKTREE_NOT_DERIVABLE` when neither line is present, or with `TARGET_WORKTREE_AMBIGUOUS` when the lines disagree or match more than one live worktree.
```

### D2 — `.claude/skills/epic-orchestrate/SKILL.md` (after line 124, as one line after a blank line)

```text
The run gates `enforce-orchestration-preimplementation-gate.ps1` and `enforce-epic-wave-barrier.ps1` locate the epic checkpoint by the `integration_branch:` value of this line. They select the live worktree whose `artifacts/orchestration/epic-orchestrator-state.json` records `route_id` `epic` and that integration branch, prefer the worktree that has the branch checked out when more than one records it, and deny the delegation with `TARGET_WORKTREE_NOT_DERIVABLE` or `TARGET_WORKTREE_AMBIGUOUS` when none or more than one remains. A stale copy of the epic checkpoint is moved to `artifacts/orchestration/handoff/` rather than left at a worktree root. The child run's own delegations to implementation agents carry the canonical issue-number line and `branch:` label defined in `.claude/skills/orchestrate/SKILL.md` `## Issue Number Consistency`.
```

### D3 — `.claude/skills/parallel-orchestrate/SKILL.md` (after line 278, as one line after a blank line)

```text
The run gates `enforce-orchestration-preimplementation-gate.ps1`, `enforce-parallel-cohort-barrier.ps1`, and `enforce-parallel-drift-gate.ps1` locate the parallel checkpoint by the `parallel_slug:` value of the marker line. They select the single live worktree whose `artifacts/orchestration/parallel-orchestrator-state.json` records `route_id` `parallel` and that slug, and deny the delegation with `TARGET_WORKTREE_NOT_DERIVABLE` or `TARGET_WORKTREE_AMBIGUOUS` when none or more than one matches. The child run's own delegations to implementation agents carry the canonical issue-number line and `branch:` label defined in `.claude/skills/orchestrate/SKILL.md` `## Issue Number Consistency`.
```

### D4 — Each invoke skill (a new section immediately before `## Worker Routing`; `<worker>` per task)

```text
## Delegation Identity Lines

Every delegation prompt this skill sends to `<worker>` carries the canonical issue-number line (`Canonical issue number for this feature is <issue_num>. All artifact content, file paths, and cross-references must use this number.`) and a `branch: <name>` label naming the branch checked out in the item's worktree, written as the first `branch:` occurrence in the prompt. `enforce-orchestration-preimplementation-gate.ps1` resolves the item's worktree from these two lines and denies a delegation that carries neither with `TARGET_WORKTREE_NOT_DERIVABLE`.
```

## Appendix E — Follow-Up Potential Entries

Each entry uses the layout of `docs/features/potential/2026-09-29-csharp-budget-text-per-batch-cap.md` (title with "(Potential Bug)", Date captured, Author, `Status: Draft`, `Related: #690`, Summary, Scope, `## Acceptance Criteria (early draft)`, Constraints & Risks, Next Step).

- **E1** `docs/features/potential/2026-09-29-hook-preexisting-imports-fail-open.md`: pre-existing module imports and dot-sources in PreToolUse hooks (for example `HookPayload.psm1`, the `-helpers` and `-modes` dot-sources, `EpicScopeReadiness.psm1`) and every hook #690 does not convert (including `enforce-model-routing-receipt.ps1` and `enforce-pr-author-skill.ps1`, which import `EpicScopeResolution.psm1` and therefore `WorktreeRunResolution.psm1` unguarded) exit non-zero on a failed import, which PreToolUse treats as non-blocking. Early criteria: each such hook records the failure and denies; a test simulates it without renaming files.
- **E2** `docs/features/potential/2026-09-29-validate-orchestrator-output-session-relative-read.md`: `.claude/hooks/validate-orchestrator-output.ps1` (SubagentStop) reads `-CheckpointPath` relative to the session root (research section 3 row 18), so an epic run in the two-worktree topology can be blocked at epic-orchestrator termination. Early criteria: the hook resolves the run's checkpoint through `WorktreeRunResolution.psm1`.
- **E3** `docs/features/potential/2026-09-29-merge-gate-child-branch-without-pr-gate.md`: the merge gate's child branch binds the command PR number to `pr_gate.pr_number` only when the per-feature checkpoint records it; routes without `requires_pr_gate` (for example `small`) keep the unbound session-root decision (research section 9). Early criteria: the child branch binds the PR number for every route, or resolves the child checkpoint by record.

## Appendix F — File Groups and Mirror Pairs

- **LC-BASE** (P0-T11): WorktreeResolution.psm1, WIR, ESR, PRE, PRES, WAVE, COH, MRG, EREM, PREM, DRIFT, GUARD, `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`.
- **BU** (byte-unchanged): `.claude/lib/worktree-resolution/WorktreeResolution.psm1`, `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`, `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`, `.claude/hooks/enforce-epic-merge-gate-authorization.ps1`, `.claude/hooks/validate-orchestrator-output.ps1`, `.claude/hooks/enforce-powershell-batch-budget.ps1`, `.claude/hooks/enforce-powershell-batch-budget-route.ps1`, `.claude/hooks/enforce-model-routing-receipt.ps1`, `.claude/hooks/enforce-pr-author-skill.ps1`, `.claude/hooks/enforce-pr-author-skill-helpers.ps1`, `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1`.
- **PROD-EXIST**: WIR, ESR, PRE, PRES, WAVE, COH, MRG, EREM, PREM, DRIFT.
- **MP-EXIST** (22 pairs; primary then `CB/<primary>`): WIR, ESR, PRE, PRES, WAVE, COH, MRG, EREM, PREM, DRIFT, `.claude/lib/worktree-resolution/WorktreeResolution.psm1`, `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1`, `.claude/lib/worktree-resolution/EpicScopeReadiness.psm1`, `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`, `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`, `.claude/hooks/enforce-epic-merge-gate-authorization.ps1`, and the six skills of Phase 2 (`orchestrate`, `epic-orchestrate`, `parallel-orchestrate`, `invoke-python-engineer`, `invoke-powershell-engineer`, `invoke-csharp-engineer`).
- **MP-NEW** (3 pairs): WRR, MRGR, EREMR (primary then `CB/<primary>`).
- **P1-FILES**: WRR, WIR, T-SIG, T-RUN, T-REC, `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1`, CORE, RUNSET, RUNSETB, `CB/.claude/lib/worktree-resolution/WorktreeRunResolution.psm1`, `CB/.claude/lib/worktree-resolution/WorktreeItemResolution.psm1`.
- **P3-FILES**: PRES, PRE, their two CB mirrors, G1A, G1B, the eight EXIST-PRE suites. **P4-FILES**: WAVE, its mirror, G2, `enforce-epic-wave-barrier.Tests.ps1`. **P5-FILES**: COH, its mirror, G3, the two EXIST-COHORT suites. **P6-FILES**: MRGR, MRG, their two mirrors, G4, the four EXIST-MERGE suites, CORE, RUNSET, RUNSETB. **P7-FILES**: EREMR, EREM, their two mirrors, G5, the four EXIST-EREM suites, CORE, RUNSET, RUNSETB. **P8-FILES**: PREM, its mirror, G6, the four EXIST-PREM suites. **P9-FILES**: DRIFT, its mirror, G7, `enforce-parallel-drift-gate.Tests.ps1`. **P10-FILES**: ESR, its mirror, GUARD, GUARDH, T-ESR, `tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.Tests.ps1`, the GUARDED-7 suites, the ESCOPE-4 suites.
- **FINAL-PS**: WRR, WIR, ESR, PRE, PRES, WAVE, COH, MRG, MRGR, EREM, EREMR, PREM, DRIFT, RUNSET, every new test file (T-SIG, T-RUN, T-REC, T-ESR, G1A, G1B, G2-G7, GUARDH), and every edited existing test file (Appendix G group EDITED-TESTS).

## Appendix G — Suite Sets and Coverage Groups

All paths are under `tests/scripts/`. Lists are passed to A2/A3 comma-separated.

- **EXIST-PRE** (8): `claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1`, `.EpicScope.Tests.ps1`, `.TriggerScoping.Tests.ps1`, `.CommandExemption.Tests.ps1`, `.AttributionTrailer.Tests.ps1`, `claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1`, `-classifier.Tests.ps1`, `-mode-resolution.Tests.ps1`.
- **EXIST-COHORT** (2): `claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1`, `claude-hooks/enforce-parallel-cohort-barrier.Payload.Tests.ps1`.
- **EXIST-MERGE** (4): `claude-hooks/enforce-epic-merge-gate.Tests.ps1`, `.Authorization.Tests.ps1`, `.TriggerScoping.Tests.ps1`, `claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1`.
- **EXIST-EREM** (4): `claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1`, `.TriggerScoping.Tests.ps1`, `claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1`, `claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1`.
- **EXIST-PREM** (4): `claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1`, `.EpicAuthorization.Tests.ps1`, `.TriggerScoping.Tests.ps1`, `claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1`.
- **GUARDED-7**: `claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1`, `claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1`, `claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1`, `claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1`, `claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1`, `claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`, `claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1`. The last four are the preimplementation-gate members (GUARDED-PRE-4).
- **ESCOPE-4**: `claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1`, `claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1`, `claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1`, `claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1`.
- **EDITED-TESTS**: the union of EXIST-PRE, EXIST-COHORT, EXIST-MERGE, EXIST-EREM, EXIST-PREM, GUARDED-7, ESCOPE-4, `claude-hooks/enforce-epic-wave-barrier.Tests.ps1`, `claude-hooks/enforce-parallel-drift-gate.Tests.ps1`, GUARD, `claude-lib/worktree-resolution/EpicScopeResolution.Tests.ps1`, `claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1` (duplicates listed once).
- **SET-LIB**: `claude-lib/worktree-resolution` (folder), `claude-lib/ClaudeLibModuleConvention.Tests.ps1`, `claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`. Growth: +68 after Phase 1, +72 after Phase 10.
- **SET-PRE**: EXIST-PRE, `claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1`, `claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1`, GUARD, `claude-hooks/PreToolUseSchema.Contract.Tests.ps1`, `claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1`, and (from Phase 3) G1A and G1B. Growth: +25.
- **SET-WAVE**: `claude-hooks/enforce-epic-wave-barrier.Tests.ps1` and (from Phase 4) G2. Growth: +9.
- **SET-COHORT**: EXIST-COHORT and (from Phase 5) G3. Growth: +7.
- **SET-MERGE**: EXIST-MERGE, `claude-hooks/enforce-epic-merge-gate.AuthorizationFields.Tests.ps1`, and (from Phase 6) G4. Growth: +10.
- **SET-EREM**: EXIST-EREM and (from Phase 7) G5. Growth: +6.
- **SET-PREM**: EXIST-PREM and (from Phase 8) G6. Growth: +6.
- **SET-DRIFT**: `claude-hooks/enforce-parallel-drift-gate.Tests.ps1`, `claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1`, and (from Phase 9) G7. Growth: +6.
- **SET-EPICSCOPE**: `claude-lib/worktree-resolution/EpicScopeResolution.Tests.ps1`, GUARDED-7, ESCOPE-4 (the preimplementation EpicScope suite listed once), GUARD, and (from Phase 10) G1B and T-ESR. Growth at Phase 10: +23.
- Folder growth at Phase 12: `claude-hooks` +78 (G1A 15, G1B 10, G2 9, G3 7, G4 10, G5 6, G6 6, G7 6, GUARD 9); `claude-lib` +72 (T-SIG 16, T-RUN 22, T-REC 27, T-ESR 4, manifest 3); `claude-runtime` +0; `codex-hooks` +0.

Coverage groups (A3 `-TestPath` / `-CoveragePath`; baseline uses the suites that exist at Phase 0, final adds the new suites and new files):

- **CG-LIB**: tests `claude-lib/worktree-resolution`; coverage WIR, ESR (final adds WRR).
- **CG-PRE**: tests EXIST-PRE (final adds G1A, G1B); coverage PRE, PRES.
- **CG-WAVE**: tests `claude-hooks/enforce-epic-wave-barrier.Tests.ps1` (final adds G2); coverage WAVE.
- **CG-COHORT**: tests EXIST-COHORT (final adds G3); coverage COH.
- **CG-MERGE**: tests `claude-hooks/enforce-epic-merge-gate.Tests.ps1`, `.Authorization.Tests.ps1`, `.AuthorizationFields.Tests.ps1`, `.TriggerScoping.Tests.ps1` (final adds G4); coverage MRG (final adds MRGR).
- **CG-EREM**: tests `claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1`, `.TriggerScoping.Tests.ps1`, `claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1` (final adds G5); coverage EREM (final adds EREMR).
- **CG-PREM**: tests `claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1`, `.EpicAuthorization.Tests.ps1`, `.TriggerScoping.Tests.ps1`, `claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1` (final adds G6); coverage PREM.
- **CG-DRIFT**: tests `claude-hooks/enforce-parallel-drift-gate.Tests.ps1`, `claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1` (final adds G7); coverage DRIFT.

Changed-line coverage (P12-T12) covers the 13 production PowerShell files WRR, WIR, ESR, PRE, PRES, WAVE, COH, MRG, MRGR, EREM, EREMR, PREM, DRIFT. The runsettings files are data files and carry no Pester-measured lines. P12-T12's acceptance therefore reads: 13 `CHANGED-COVERAGE file=` lines, none `MISSING`, each with `ChangedPercent=` of at least 85.

## Appendix H — Scratch Scripts

Written verbatim under SCRATCH by P0-T7 and never committed. A1-A8, A11, A12, and A13 are carried unchanged from the #769 plan (`docs/features/active/2026-08-16-batch-budget-hook-lacks-orchestration-awareness-769/plan.2026-09-29T13-19.md` Appendix A); their text is reproduced here.

A1 run-ps.sh:

```sh
#!/bin/sh
set -eu
pwsh -NoProfile -NonInteractive -File "$@"
```

A2 pester-counts.ps1:

```powershell
param([Parameter(Mandatory)][string[]] $Path)
$Path = @($Path | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$configuration = New-PesterConfiguration
$configuration.Run.Path = $Path
$configuration.Run.PassThru = $true
$configuration.Output.Verbosity = 'Detailed'
$result = Invoke-Pester -Configuration $configuration
Write-Output "TotalCount=$($result.TotalCount)"
Write-Output "PassedCount=$($result.PassedCount)"
Write-Output "FailedCount=$($result.FailedCount)"
foreach ($failedTest in $result.Failed) { Write-Output "FAILED: $($failedTest.ExpandedPath)" }
```

A3 pester-coverage.ps1:

```powershell
param(
    [Parameter(Mandatory)][string[]] $TestPath,
    [Parameter(Mandatory)][string[]] $CoveragePath,
    [Parameter(Mandatory)][string] $CoverageOutputPath,
    [string] $ReportPath = ''
)
$TestPath = @($TestPath | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$CoveragePath = @($CoveragePath | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$configuration = New-PesterConfiguration
$configuration.Run.Path = $TestPath
$configuration.Run.PassThru = $true
$configuration.Output.Verbosity = 'Detailed'
$configuration.CodeCoverage.Enabled = $true
$configuration.CodeCoverage.Path = $CoveragePath
$configuration.CodeCoverage.OutputPath = $CoverageOutputPath
$result = Invoke-Pester -Configuration $configuration
$report = [System.Collections.Generic.List[string]]::new()
$report.Add("TotalCount=$($result.TotalCount)")
$report.Add("PassedCount=$($result.PassedCount)")
$report.Add("FailedCount=$($result.FailedCount)")
foreach ($failedTest in $result.Failed) { $report.Add("FAILED: $($failedTest.ExpandedPath)") }
$executed = @($result.CodeCoverage.CommandsExecuted)
$missed = @($result.CodeCoverage.CommandsMissed)
foreach ($file in $CoveragePath) {
    $fullPath = (Resolve-Path -LiteralPath $file).Path
    $hitLines = @($executed | Where-Object { $_.File -eq $fullPath } | ForEach-Object { $_.Line } | Sort-Object -Unique)
    $missLines = @($missed | Where-Object { $_.File -eq $fullPath } | ForEach-Object { $_.Line } | Sort-Object -Unique | Where-Object { $hitLines -notcontains $_ })
    $analyzed = @(@($hitLines) + @($missLines) | Sort-Object -Unique)
    $percent = if ($analyzed.Count -eq 0) { 'NA' } else { [math]::Round(100 * $hitLines.Count / $analyzed.Count, 2) }
    $report.Add("COVERAGE file=$file AnalyzedLines=$($analyzed.Count) CoveredLines=$($hitLines.Count) LinePercent=$percent")
    $report.Add("HIT file=$file Lines=$($hitLines -join ',')")
    $report.Add("MISSED file=$file Lines=$($missLines -join ',')")
}
$report | Write-Output
if ($ReportPath) { $report | Set-Content -LiteralPath $ReportPath -Encoding UTF8 }
```

A4 line-counts.ps1:

```powershell
param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $Path)
foreach ($file in $Path) { Write-Output "$file LineCount=$((Get-Content -LiteralPath $file).Count)" }
```

A5 file-hashes.ps1:

```powershell
param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $Path)
foreach ($file in $Path) { Write-Output "$file Hash=$((Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash)" }
```

A6 ps-format-check.ps1 (read-only):

```powershell
param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $Path)
$settings = 'scripts/powershell/PoshQC/settings/pssa.settings.psd1'
$changedCount = 0
foreach ($file in $Path) {
    $original = Get-Content -Raw -LiteralPath $file
    $formatted = Invoke-Formatter -ScriptDefinition $original -Settings $settings
    $changed = $formatted -cne $original
    if ($changed) { $changedCount++ }
    Write-Output "FORMAT file=$file Changed=$changed"
}
Write-Output "FORMAT-SUMMARY ChangedCount=$changedCount"
```

A7 pssa-count.ps1:

```powershell
param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $Path)
$settings = 'scripts/powershell/PoshQC/settings/pssa.settings.psd1'
$records = @(foreach ($file in $Path) { Invoke-ScriptAnalyzer -Path $file -Settings $settings })
foreach ($record in $records) { Write-Output "PSSA $($record.ScriptName):$($record.Line) $($record.RuleName) $($record.Severity)" }
Write-Output "PSSA-SUMMARY DiagnosticCount=$($records.Count)"
```

A8 psd1-parse.ps1:

```powershell
param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $Path)
$ErrorActionPreference = 'Stop'
foreach ($file in $Path) { $null = Import-PowerShellDataFile -LiteralPath $file; Write-Output "PSD1-OK file=$file" }
```

A9 checkpoint-probe.ps1 (read-only):

```powershell
param([Parameter(Mandatory)][string] $CheckpointPath)
$ErrorActionPreference = 'Stop'
$checkpoint = Get-Content -Raw -LiteralPath $CheckpointPath | ConvertFrom-Json
Write-Output "ROUTE_ID=$($checkpoint.route_id)"
Write-Output "LIFECYCLE_READY=$($checkpoint.lifecycle_ready)"
Write-Output "ISSUE_NUM=$($checkpoint.'issue-num')"
Write-Output "FEATURE_FOLDER=$($checkpoint.'feature-folder')"
```

A10 epic-coexistence-probe.ps1 (read-only; prints leaf names and hashes only; `-Mode drift` is the D13 copy-drift probe and takes the epic worktree root as a path relative to this worktree root):

```powershell
param(
    [ValidateSet('presence', 'resolve', 'drift')][string] $Mode = 'presence',
    [string] $EpicWorktreeRoot = ''
)
$ErrorActionPreference = 'Stop'
$epicPath = 'artifacts/orchestration/epic-orchestrator-state.json'
$present = Test-Path -LiteralPath $epicPath -PathType Leaf
Write-Output "SESSION_EPIC_PRESENT=$present"
if ($Mode -eq 'drift') {
    if ([string]::IsNullOrWhiteSpace($EpicWorktreeRoot)) { throw 'drift mode requires -EpicWorktreeRoot.' }
    $otherPath = Join-Path $EpicWorktreeRoot $epicPath
    $otherPresent = Test-Path -LiteralPath $otherPath -PathType Leaf
    $sessionHash = if ($present) { (Get-FileHash -LiteralPath $epicPath -Algorithm SHA256).Hash } else { 'ABSENT' }
    $otherHash = if ($otherPresent) { (Get-FileHash -LiteralPath $otherPath -Algorithm SHA256).Hash } else { 'ABSENT' }
    $drift = $present -and $otherPresent -and ($sessionHash -ne $otherHash)
    Write-Output "FIRST_COPY_DRIFT=$drift"
    if ($drift) {
        # One re-probe after 30 seconds, so a single in-between write by the #770 orchestrator does not halt the run.
        Start-Sleep -Seconds 30
        $present = Test-Path -LiteralPath $epicPath -PathType Leaf
        $otherPresent = Test-Path -LiteralPath $otherPath -PathType Leaf
        $sessionHash = if ($present) { (Get-FileHash -LiteralPath $epicPath -Algorithm SHA256).Hash } else { 'ABSENT' }
        $otherHash = if ($otherPresent) { (Get-FileHash -LiteralPath $otherPath -Algorithm SHA256).Hash } else { 'ABSENT' }
        $drift = $present -and $otherPresent -and ($sessionHash -ne $otherHash)
    }
    Write-Output "EPIC_WORKTREE_LEAF=$(Split-Path -Leaf $EpicWorktreeRoot)"
    Write-Output "EPIC_WORKTREE_PRESENT=$otherPresent"
    Write-Output "SESSION_EPIC_SHA256=$sessionHash"
    Write-Output "EPIC_WORKTREE_SHA256=$otherHash"
    Write-Output "COPY_DRIFT=$drift"
    return
}
if (-not $present) { return }
Write-Output "SESSION_EPIC_SHA256=$((Get-FileHash -LiteralPath $epicPath -Algorithm SHA256).Hash)"
$epic = Get-Content -Raw -LiteralPath $epicPath | ConvertFrom-Json
Write-Output "SESSION_EPIC_INTEGRATION_BRANCH=$($epic.integration_branch)"
if ($Mode -ne 'resolve') { return }
Import-Module (Join-Path (Get-Location).Path '.claude/lib/worktree-resolution/WorktreeRunResolution.psm1') -Force
$target = Resolve-WorktreeEpicTarget -IntegrationBranch ([string]$epic.integration_branch) -EpicSlug ([string]$epic.epic_feature_folder) -SessionRoot (Get-Location).Path
$leaf = if ($target.WorktreeRoot) { Split-Path -Leaf $target.WorktreeRoot } else { '' }
Write-Output "RESOLVED_STATUS=$($target.Status)"
Write-Output "RESOLVED_ROOT_LEAF=$leaf"
Write-Output "RESOLVED_REASON=$($target.ReasonCode)"
```

A11 changed-line-coverage.ps1 (reads an A3 report file; lines absent at the base ref count as changed):

```powershell
param(
    [Parameter(Mandatory)][string] $CoverageReportPath,
    [Parameter(Mandatory)][string] $BaseRef,
    [Parameter(Mandatory)][string[]] $File
)
$File = @($File | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$report = Get-Content -LiteralPath $CoverageReportPath
foreach ($target in $File) {
    $hitLine = $report | Where-Object { $_ -like "HIT file=$target Lines=*" } | Select-Object -First 1
    $missLine = $report | Where-Object { $_ -like "MISSED file=$target Lines=*" } | Select-Object -First 1
    if (-not $hitLine -or -not $missLine) { Write-Output "CHANGED-COVERAGE file=$target MISSING"; continue }
    $hit = @(($hitLine -replace '^.*Lines=', '') -split ',' | Where-Object { $_ } | ForEach-Object { [int]$_ })
    $miss = @(($missLine -replace '^.*Lines=', '') -split ',' | Where-Object { $_ } | ForEach-Object { [int]$_ })
    $changed = [System.Collections.Generic.HashSet[int]]::new()
    $null = git cat-file -e "${BaseRef}:$target" 2>$null
    if ($LASTEXITCODE -eq 0) {
        foreach ($diffLine in @(git diff -U0 $BaseRef -- $target)) {
            if ($diffLine -match '^@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@') {
                $start = [int]$Matches[1]
                $count = if ($Matches[2]) { [int]$Matches[2] } else { 1 }
                for ($offset = 0; $offset -lt $count; $offset++) { [void]$changed.Add($start + $offset) }
            }
        }
    } else {
        $lineCount = (Get-Content -LiteralPath $target).Count
        for ($lineNumber = 1; $lineNumber -le $lineCount; $lineNumber++) { [void]$changed.Add($lineNumber) }
    }
    $changedHit = @($hit | Where-Object { $changed.Contains($_) }).Count
    $changedMiss = @($miss | Where-Object { $changed.Contains($_) }).Count
    $analyzed = $changedHit + $changedMiss
    $percent = if ($analyzed -eq 0) { 'NA' } else { [math]::Round(100 * $changedHit / $analyzed, 2) }
    Write-Output "CHANGED-COVERAGE file=$target ChangedLines=$($changed.Count) ChangedAnalyzed=$analyzed ChangedCovered=$changedHit ChangedPercent=$percent"
}
```

A `ChangedPercent=NA` value fails the P12-T12 threshold and is reported, not waived.

A12 json-parse.ps1:

```powershell
param([Parameter(Mandatory)][string] $Path)
$ErrorActionPreference = 'Stop'
$null = Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json
Write-Output "JSON-OK file=$Path"
```

A13 pair-hashes.ps1 (arguments: primary, mirror, primary, mirror, ...):

```powershell
param([Parameter(Mandatory, ValueFromRemainingArguments = $true)][string[]] $Path)
if ($Path.Count % 2 -ne 0) { throw 'pair-hashes requires an even number of paths.' }
$unequal = 0
for ($index = 0; $index -lt $Path.Count; $index += 2) {
    $primary = $Path[$index]
    $mirror = $Path[$index + 1]
    $primaryHash = (Get-FileHash -LiteralPath $primary -Algorithm SHA256).Hash
    $mirrorHash = if (Test-Path -LiteralPath $mirror) { (Get-FileHash -LiteralPath $mirror -Algorithm SHA256).Hash } else { 'MISSING' }
    $equal = $primaryHash -eq $mirrorHash
    if (-not $equal) { $unequal++ }
    Write-Output "PAIR equal=$equal primary=$primary mirror=$mirror"
}
Write-Output "PAIR-SUMMARY pairs=$($Path.Count / 2) unequal=$unequal"
```

A14 function-text-compare.ps1:

```powershell
param([Parameter(Mandatory)][string] $Path, [Parameter(Mandatory)][string] $FunctionName, [Parameter(Mandatory)][string] $BaseRef)
$ErrorActionPreference = 'Stop'
function Get-FunctionText([string] $Source, [string] $Name) {
    $tokens = $null
    $errors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseInput($Source, [ref] $tokens, [ref] $errors)
    $found = $ast.Find({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq $Name }, $true)
    if ($null -eq $found) { return $null }
    return ($found.Extent.Text -replace "`r`n", "`n")
}
$current = Get-FunctionText -Source (Get-Content -Raw -LiteralPath $Path) -Name $FunctionName
$base = Get-FunctionText -Source ((@(git show "${BaseRef}:$Path")) -join "`n") -Name $FunctionName
Write-Output "FUNCTION-FOUND current=$($null -ne $current) base=$($null -ne $base)"
Write-Output "FUNCTION-TEXT-EQUAL=$($null -ne $current -and $current -ceq $base)"
```

A15 stage-check.ps1 (read-only):

```powershell
param([Parameter(Mandatory)][string] $Path)
$settings = 'scripts/powershell/PoshQC/settings/pssa.settings.psd1'
$tokens = $null
$errors = $null
$null = [System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path -LiteralPath $Path).Path, [ref] $tokens, [ref] $errors)
$original = Get-Content -Raw -LiteralPath $Path
$formatted = Invoke-Formatter -ScriptDefinition $original -Settings $settings
$records = @(Invoke-ScriptAnalyzer -Path $Path -Settings $settings)
foreach ($record in $records) { Write-Output "PSSA $($record.Line) $($record.RuleName) $($record.Severity)" }
Write-Output "STAGE-CHECK ParseErrors=$(@($errors).Count) FormatChanged=$($formatted -cne $original) DiagnosticCount=$($records.Count)"
```

A16 identity-probe.ps1 (read-only; prints leaf names only):

```powershell
param([Parameter(Mandatory)][string] $IssueNumber, [Parameter(Mandatory)][string] $Branch)
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path (Get-Location).Path '.claude/lib/worktree-resolution/WorktreeItemResolution.psm1') -Force
$text = "Canonical issue number for this feature is $IssueNumber. All artifact content, file paths, and cross-references must use this number.`nbranch: $Branch"
$target = Resolve-WorktreeItemTarget -Text $text -SessionRoot (Get-Location).Path
$leaf = if ($target.WorktreeRoot) { Split-Path -Leaf $target.WorktreeRoot } else { '' }
Write-Output "IDENTITY_STATUS=$($target.Status)"
Write-Output "IDENTITY_REASON=$($target.ReasonCode)"
Write-Output "IDENTITY_ROOT_LEAF=$leaf"
```

A17 added-lines-scan.ps1:

```powershell
param([Parameter(Mandatory)][string] $BaseRef, [Parameter(Mandatory)][string[]] $Token, [Parameter(Mandatory)][string[]] $File)
$Token = @($Token | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$File = @($File | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$count = 0
foreach ($target in $File) {
    $null = git cat-file -e "${BaseRef}:$target" 2>$null
    $added = if ($LASTEXITCODE -eq 0) {
        @(git diff -U0 $BaseRef -- $target | Where-Object { $_.StartsWith('+') -and -not $_.StartsWith('+++') })
    } else { @(Get-Content -LiteralPath $target) }
    foreach ($line in $added) {
        foreach ($item in $Token) {
            if ($line.Contains($item)) { $count++; Write-Output "ADDED-TOKEN file=$target token=$item" }
        }
    }
}
Write-Output "ADDED-TOKEN-SUMMARY count=$count files=$($File.Count)"
```

A18 commit-manifest.ps1:

```powershell
param([Parameter(Mandatory)][string] $BaseRef)
foreach ($line in @(git log --reverse --format='%H%x09%s' "$BaseRef..HEAD")) {
    $parts = $line -split "`t", 2
    $files = @(git show --name-only --format= $parts[0] | Where-Object { $_ })
    Write-Output "COMMIT subject=$($parts[1]) files=$($files -join ',')"
}
```

## Appendix I — Acceptance-Criteria Inventory (spec line per ID)

AC-01 410, AC-02 411, AC-03 412, AC-04 416, AC-05 417, AC-06 418, AC-07 419, AC-08 420, AC-09 421, AC-10 422, AC-11 423, AC-12 424, AC-13 425, AC-14 429, AC-15 430, AC-16 431, AC-17 432, AC-18 433, AC-19 434, AC-20 435, AC-21 439, AC-22 440, AC-23 441, AC-24 445, AC-25 446, AC-26 447, AC-27 451, AC-28 452, AC-29 453, AC-30 454, AC-31 455, AC-32 459, AC-33 460, AC-34 464, AC-35 468, AC-36 469, AC-37 473, AC-38 474, AC-39 475, AC-40 479, AC-41 480, AC-42 481, AC-43 482, AC-44 486, AC-45 487, AC-46 488, AC-47 489, AC-48 490, AC-49 494, AC-50 495, AC-51 496, AC-52 497, AC-53 498, AC-54 502, AC-55 503, AC-56 504, AC-57 508, AC-58 509, AC-59 510, AC-60 511, AC-61 515, AC-62 516, AC-63 517.

## Appendix J — Wiring Log (WLOG) Format

`FEATURE/evidence/qa-gates/gate-wiring-order.md` starts with `Timestamp:`, `Command: SW procedure (LH-2) and per-phase A2 runs`, `EXIT_CODE: 0`, and `Output Summary:` (updated at each append to state the latest entry). Each entry is one table row: sequence number, phase task, file written, SW-2 `STAGE-CHECK` line, SW-4 hash equality, timestamp, and the reason when it is a corrective re-Write. Suite-result entries record the task, the suite list name, `TotalCount=`, `PassedCount=`, `FailedCount=`. Copy-drift entries (P3-T1 through P10-T1, D13) record the task, `FIRST_COPY_DRIFT=`, `SESSION_EPIC_SHA256=`, `EPIC_WORKTREE_SHA256=` (each a hash or `ABSENT`), and `COPY_DRIFT=`; the P3-T1 entry is written before any Phase 3 file entry, and WLOG exists from P1-T2. Entries are appended with the Edit tool (the log is Markdown under FEATURE and is not a live file).
