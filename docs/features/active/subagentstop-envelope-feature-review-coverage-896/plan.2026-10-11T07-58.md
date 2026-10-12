# subagentstop-envelope-feature-review-coverage (Plan)

- **Issue:** #896 (Refs #884 Codex half only; Refs #897 feature-review coverage validator only)
- **Parent (optional):** epic `subagentstop-envelope` (epic issue #904), child E4, integration branch `epic/subagentstop-envelope-integration`
- **Owner:** drmoisan
- **Last Updated:** 2026-10-12T03-00
- **Status:** Draft v1.8 (revision 2026-10-12: P4-T4 rule3 exemplar representation rule revised after the P4-T4 BLOCKED record `EXEMPLAR-UNREPRESENTABLE`; v1.7 applied the preflight round-3 plan-file staging delta to v1.6; v1.6 applied four preflight round-2 deltas to v1.5; v1.5 applied eight executor-preflight deltas to the v1.4 amendment; v1.4 inserted the corpus false-positive gate as Phase 4 and renumbered former Phases 4-11 to 5-12; v1.3 was PREFLIGHT: ALL CLEAR after 4 rounds; awaiting validator run and executor preflight of v1.8)
- **Version:** 1.8
- **Work Mode:** full-bug (from `issue.md` metadata; `spec.md` is the sole acceptance-criteria source; `user-story.md` is absent by design)
- **Branch:** the value P0-T2 records in `Branch:` (the upstream of the checked-out branch with the leading `origin/` removed), which must match `^bug/subagentstop-envelope-feature-review-coverage(-exec)?-896$` (written `<BRANCH>` below; every push is `git push origin HEAD:<BRANCH>`, and every fetch and remote rev-parse uses `<BRANCH>`). The checked-out local branch may be an alias of a different name (for example `exec-896-local` tracking `origin/bug/subagentstop-envelope-feature-review-coverage-exec-896`, because another worktree holds the canonical local branch name); P0-T2 records it separately as `LocalBranch:`, and the `HEAD:<BRANCH>` refspec pushes the alias to the remote `<BRANCH>`.
- **Integration ref:** `origin/epic/subagentstop-envelope-integration` (written `<INT>` below; every `git diff` in this plan carries a ref operand)
- **Feature folder:** `docs/features/active/subagentstop-envelope-feature-review-coverage-896/` (written `<FEATURE>` below)
- **Requirements:** `<FEATURE>/spec.md` v1.1 (AC-1 through AC-31), `<FEATURE>/issue.md`, `<FEATURE>/research/research.2026-10-11T08-10.md`
- **Upstream dependency:** E1 (#897, preparation branch `bug/subagentstop-envelope-core-897`, execution branch possibly `bug/subagentstop-envelope-core-exec-897`, folder `docs/features/active/subagentstop-envelope-core-897/`). Epic children have entered the integration branch through PRs from `-exec-` branches and through direct merges (E1's preparation documents entered by direct merge `cf3108b04`), so P0-T3 identifies the E1 merge by head-branch pattern or by the first-parent merge that introduced the helper, not by one fixed branch name. As of the v1.5 revision, the execution worktree's HEAD contains the E1 merge `039e53339` (reached through `f11f1814b`): `.claude/hooks/subagentstop-envelope.ps1` (functions `Get-SubagentStopEnvelopeAnomalyReason` line 20, `Read-SubagentStopEnvelope` line 54, `Exit-SubagentStopBlock` line 171), its mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`, `tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1`, the P1 manifest entry `.claude/hooks/subagentstop-envelope.ps1` (line 68), and the E1 feature folder `docs/features/active/subagentstop-envelope-core-897/` (including `spec.md`) are present. H1 is unchanged by that merge (477 lines; no `subagentstop` token). Phase 0 still reads E1's helper and spec from the integration ref (P0-T4 through P0-T7), so the AC-1 check does not depend on the local copy. This plan is written against the E1 contract recorded in spec Proposed Fix item 1 (reconciled at E1 head `cc3285559`). Phase 0 compares E1's merged spec with that recorded contract item by item and stops on any divergence (AC-1).

**Fail-closed evidence rule:** Include explicit baseline artifact tasks, final-QA artifact tasks, and coverage-comparison tasks for each in-scope language when policy requires coverage. If any required baseline artifact, QA artifact, or coverage-comparison artifact is missing, the audit verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Record the expected artifact path or location in each evidence-producing task. Do not mark evidence-backed work complete without the artifact.

## Scope Summary

In scope (spec Scope & Non-Goals): the Claude feature-review hook transport (E1 helper, `-InputText`, exit 2 on every block path, E1 consumer rules 1-6 including the re-entry policy), CR-4, CR-6, CR-8, CR-9, the Codex hook floor source (byte-identical thresholds copy, root `CLAUDE.md` line floor, CR-4 within Codex semantics), the feature-review-workflow skill copies and `.codex/agents/feature-review.toml`, their bundled mirrors, both `core.json` pack manifests, `$script:SharedModuleNames` in `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, and `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`.

Not edited by any task (AC-22, AC-27, spec Scope & Non-Goals): the E2 validators (`validate-orchestrator-output.ps1`, `validate-orchestrator-output-resolution.ps1`, `validate-executor-output.ps1`, `validate-planner-output.ps1`, `validate-required-artifact-output.ps1`) and E3 validators (`validate-discovery-artifact-gate.ps1`, `validate-pr-author-output.ps1`, `validate-prd-feature-output.ps1`, `validate-task-researcher-output.ps1`) and their mirrors; `.claude/settings.json`; `.claude/hooks/subagentstop-envelope.ps1` and its mirror; `.claude/lib/bash/compute-concurrency-batches.sh` and every other bash file; `.codex/config.toml` and its bundle copy; everything under `.github/instructions/` and `.claude/rules/`; the #824 folder `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/`; the guard-test helpers under `tests/scripts/claude-runtime/` (run, not edited). No Python is added to any hook.

### Files named by this plan

| ID | Repository-relative path | Change |
|---|---|---|
| H1 | `.claude/hooks/validate-feature-review-coverage.ps1` | edit: entry and decision only; transport; re-entry policy; CR-4 decision; help; Phase 4 same-folder-and-timestamp corpus rule fix inside the decision function, when any |
| H2 | `.claude/hooks/validate-feature-review-coverage-metrics.ps1` | new: artifact reader, CR-4 reader, coverage parsers |
| H3 | `.claude/hooks/validate-feature-review-coverage-rules.ps1` | new: artifact-path rules, language set, coverage-row rule (adds `Repairable`, `-LineSource`, `-BranchSource`); Phase 4 corpus rule fixes inside existing functions, when any |
| H4 | `.claude/hooks/feature-review-coverage-thresholds.ps1` | edit: CR-9 second alternative and help |
| H5 | `.codex/hooks/validate-feature-review-coverage.ps1` | edit: floor source, `-LineFloor`, help |
| H6 | `.codex/hooks/feature-review-coverage-thresholds.ps1` | new: byte copy of H4 |
| M1-M6 | the six mirrors of H1-H6 under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` (H1-H4) and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/` (H5, H6) | byte copies |
| S1 | `.agents/skills/feature-review-workflow/SKILL.md` | edit: lines 111-114 and 148 |
| S2 | `.github/skills/feature-review-workflow/SKILL.md` | edit: line 126 |
| S3 | `.codex/agents/feature-review.toml` | edit: lines 121-123 and 133-135 |
| SM1-SM3 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md`, `extensions/drm-copilot/resources/customizations/.github/skills/feature-review-workflow/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-review.toml` | byte copies of S1-S3 |
| P1 | `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | edit: two entries |
| P2 | `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` | edit: one entry |
| T1 | `tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1` | edit: transport conversion, static tests E4-ST1, ST2, ST3, ST4, ST6; `E4-CORPUS` rule-fix tests (Phase 4, only when a rule fix is made) |
| T2 | `tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1` | edit: E4-TR1, TR2, TR3, TR3b, TR4, TR4a, TR4c, TR6, TR10a-d; transport conversion |
| T3 | `tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1` | edit: CR-6 and transport conversion |
| T4 | `tests/scripts/claude-hooks/validate-feature-review-coverage.ThresholdsGuard.Tests.ps1` | edit: TG1 stdin, TG3 `-InputText`, E4-TG4 |
| T5 | `tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1` | edit: E4-TR5 rows, E4-ST5 |
| T6 | `tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1` | edit: E4-TR7, TR8, TR9, ST7; floor row |
| T7 | `tests/scripts/codex-hooks/feature-review-coverage-thresholds.Tests.ps1` | new: E4-PX2 and resolver rows on the Codex copy |
| T8 | `tests/scripts/codex-hooks/feature-review-coverage-floor-parity.Tests.ps1` | new: E4-PX1 |
| T9 | `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | edit: line 30 only (no added line; file stays at 497 lines) |
| T10 | `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` | edit: `STEP_EIGHT_COPIES`, `EXPECTED_LISTED_COPY_COUNT`, new parametrized test |
| T11 | `tests/scripts/claude-hooks/validate-feature-review-coverage.E4.Helpers.ps1` | new: E4 test-support harness and fixtures dot-sourced by T2's E4 Context (not a `*.Tests.ps1` file; outside the `config/poshqc-coverage.json` coverage roots, so no production exclude entry is involved) |

`.claude/skills/feature-review-workflow/SKILL.md` and its mirror are read-only: they already contain `CLAUDE.md`, `85%`, `75%`, `governing thresholds`, and no `80%`/`90%`.

## Planned File Split (CR-8)

| File | Functions | Expected lines (target <= 300; hard cap < 500) |
|---|---|---|
| H1 `.claude/hooks/validate-feature-review-coverage.ps1` | comment-based help; guard bootstrap; guarded dot-sources of `feature-review-coverage-thresholds.ps1`, `validate-feature-review-coverage-metrics.ps1`, `validate-feature-review-coverage-rules.ps1`, `subagentstop-envelope.ps1`; `Invoke-FeatureReviewCoverageValidation -InputText` (dependency check, envelope read, validation in try/catch, re-entry policy); entry point | about 210-235 |
| H2 `.claude/hooks/validate-feature-review-coverage-metrics.ps1` | `Get-ArtifactFileContent`, `Get-FeatureReviewClaudeMdText` (new, CR-4), `Get-LcovRepoCoverage`, `Get-LcovBranchCoverage`, `Get-JacocoBranchCoverage`, `Get-LanguageBranchCoverage`, `Get-JacocoRepoCoverage`, `Get-LanguageRepoCoverage` | about 165-180 |
| H3 `.claude/hooks/validate-feature-review-coverage-rules.ps1` | `Get-ReviewArtifactPathFromOutput`, `Get-ReviewArtifactInfo`, `Get-ChangedLanguageSet`, `Test-LanguageCoverageRow` (adds `-LineSource`, `-BranchSource`, and a `Repairable` result key) | about 175-190 |
| H4 `.claude/hooks/feature-review-coverage-thresholds.ps1` | `Get-FeatureReviewCoverageThreshold` (CR-9 alternative; help lists accepted forms) | about 85-95 |
| H5 `.codex/hooks/validate-feature-review-coverage.ps1` | unchanged function set; `Test-LanguageCoverageRow -LineFloor`; entry reads root `CLAUDE.md` | about 315-325 (baseline 304; above the 300 design target, recorded by AC-10; below the 500 cap) |
| H6 `.codex/hooks/feature-review-coverage-thresholds.ps1` | byte copy of H4 | same as H4 |

The function lists of H1, H2, H3 are exactly those of spec Proposed Fix item 3 (plus the CR-4 reader the spec names for H2); no other function is added, because E4-ST4 (AC-9) compares each file's function set with the assigned list.

## Evidence Location

All evidence is written under `<FEATURE>/evidence/<kind>/` with kinds `baseline`, `regression-testing`, `qa-gates`, `other`, and `issue-updates` only. No path under `artifacts/` is an evidence location. `<ts>` in an artifact name is the executor's write time in `yyyy-MM-ddTHH-mm` form. Every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; an artifact whose expected exit code is non-zero also carries `ExpectedExitCode: 1`. Artifacts record repository-relative paths only; replace any absolute worktree prefix a tool prints with `<repo>`.

## Plan Interpretations (PI)

- PI-1 (AC-26 check mapping). AC-26 is verified by four recorded checks, each matched to the AC-26 clause it covers: clauses (a) and (c) are recorded in `<FEATURE>/evidence/qa-gates/constraints.<ts>.md`; clause (b) in `<FEATURE>/evidence/qa-gates/constraints-no-python.<ts>.md`; the temporary-file clause in `<FEATURE>/evidence/qa-gates/constraints-temp-files.<ts>.md` (separate files because `ExpectedExitCode:` is per file and those two steps can carry `ExpectedExitCode: 1`); the constraints artifact names both separate files. Clause (a): P12-T4 runs the two AC-26 (a) commands verbatim, `git diff --name-status origin/epic/subagentstop-envelope-integration -- .claude/hooks/ .codex/hooks/` and `git status --porcelain -- .claude/hooks/ .codex/hooks/`. Clause (b): P12-T5 runs `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` on the branch head. Clause (c): P12-T6 runs CR-PY-TOKEN, which issues `git grep -i -c python origin/epic/subagentstop-envelope-integration -- <family paths>` and `git grep -i -c python HEAD -- <family paths>` for the two hook families (`.claude/hooks/`: H1, H2, H3, H4; `.codex/hooks/`: H5, H6) and compares the summed counts per family. The temporary-file clause: P12-T7. The token `python` occurs as data in the base files: `.claude/hooks/validate-feature-review-coverage.ps1` lines 23, 142, 224, 261, 281 (the `Python` language label, the `'python'`/`'pytest'` audit labels, and the `artifacts/python/lcov.info` coverage path) and `.codex/hooks/validate-feature-review-coverage.ps1` lines 13, 29, 77, 135, 152; `.claude/hooks/feature-review-coverage-thresholds.ps1` contains none. `git grep -c` counts matching lines, so the expected base count is 5 for each family. P12-T13 restates this mapping in the AC-26 check-off.
- PI-2 (regression-test ordering). Each regression test carries the Pester tags `E4-Regression` and its own ID tag (`E4-TR1`, `E4-TR4`, `E4-TR5`, `E4-TR7`). Every gate that runs a file containing a regression test before the phase that fixes it excludes that test by tag (Phase 2: `E4-Regression`; Phase 3: `E4-TR1`, `E4-TR4`; Phase 4 (amendment 2026-10-11): `E4-TR1`, `E4-TR4`; Phase 5: `E4-TR4`). From Phase 6 onward no exclusion is used. The tags remain in the files.
- PI-3 (E4-TR4 failure on the base). On the base, `Invoke-FeatureReviewCoverageValidation` has no `-InputText` parameter, so E4-TR4 fails at parameter binding before reaching the `CLAUDE.md` read. The fail-first artifact records that failure message verbatim and cites research Q4 (`research.2026-10-11T08-10.md` lines 152-165) for the behavioral defect (the unwrapped read at base line 444 propagates and ends as exit 1). E4-TR1, the E4-TR5 positive rows, and E4-TR7 fail on the base for behavioral reasons (exit 1 through `Write-Error`; default 85 instead of the stated figure; 80.5% accepted against the 80% floor).
- PI-4 (message prefix). The five decision messages that begin `feature-review hook:` (base lines 355, 362, 370, 433, 457) are re-prefixed `validate-feature-review-coverage:` so that every `Message` begins with the prefix the spec requires and the dependency-failure tables pin (`hook-dependency-failure.Claude.Tests.ps1:97`, `hook-dependency-failure.SpecialCases.Tests.ps1:54`). No test asserts the old prefix.
- PI-5 (E1 contract fields). Tasks that need an E1-defined value read it from the named field of the AC-1 artifact `<FEATURE>/evidence/other/upstream-merge-check.<ts>.md` (written by P0-T2 through P0-T9): `ValidityProperty:`, `AnomalyProperty:`, `AssistantTextProperty:`, `StopHookActiveProperty:`, `AnomalyReasonFunction:`, `AnomalyReasonCall:`, `ConsumerPolicy:`, `ReportAndHaltPhrase:`, `AnomalyNames:`, `RequiredEnvelopeFields:`. `Verdict: PROCEED` requires the four property fields to read exactly `IsValid`, `Anomaly`, `AssistantText`, `StopHookActive`, so the code and tests below use those names literally. `<AnomalyReasonCall>` below is replaced by the recorded `AnomalyReasonCall:` value, and `<ReportAndHalt>` by the recorded `ReportAndHaltPhrase:` value when it is not `NONE DEFINED`, otherwise by the spec clause `The subagent cannot repair this condition; report it in the final response and stop.` No task chooses these values.
- PI-6 (line anchors). Line numbers in this plan were verified against the authoring tree. P0-T10 records whether the E1 merge touched any file this plan edits; if it did not, the line numbers hold; if it did, the executor locates each edit by the quoted content and records the shifted line numbers in the task's artifact.
- PI-7 (AC-28 format and analyze). AC-28 names PoshQC format (no changes) and PoshQC analyze (0 errors). The `mcp__drm-copilot__run_poshqc_*` tools return a summary that carries no tool output, so no count can be read from them. This plan evaluates AC-28 format with CR-FORMAT-APPLY and AC-28 analyze with CR-PSSA. Both apply the PoshQC settings file `scripts/powershell/PoshQC/settings/pssa.settings.psd1` (the path `scripts/powershell/PoshQC/PoshQC.psm1:2` loads), and CR-FORMAT-APPLY performs the comparison and write of `Invoke-PoshQCFormat` (`scripts/powershell/PoshQC/PoshQC.Analyzer.psm1:56-66`). The file population is LIST-PROD plus LIST-TEST, the PowerShell files this feature changes or adds, not the whole repository. The AC-28 full Pester suite is the full-population PoshQC run (CR-POSHQC-FULL). P12-T15 restates this interpretation in the AC-28 check-off.

## Plan Amendment 2026-10-11 (corpus false-positive gate)

Operator rule (applies to this epic child). Before the Claude feature-review coverage validator (H1, split by Phase 2 into H1, H2, H3, with rules changed by Phase 3) switches to blocking with exit 2 (Phase 5: E1 transport and `Exit-SubagentStopBlock`), it is run against the existing feature-review artifacts on current `origin/main` and must produce zero false positives. Where it rejects an established convention, the rule is fixed and each rule change is recorded with its rationale in the feature folder. The corpus is re-run with the changed validator before the switch, and the work is committed and pushed before any Phase 5 task runs.

Rationale. After the switch, every rejection blocks the feature-review subagent at termination with exit 2. A rule that rejects an established artifact convention would block reviews that follow that convention. The feature-review artifacts already merged on `origin/main` are the available record of the conventions in use, so they are the test population.

Constraint. Phase 4 below implements the rule. No Phase 5 task starts until P4-T10 meets its acceptance (`HEAD` equals `origin/<BRANCH>` with a clean status). The amendment adds no spec acceptance criterion; the AC inventory and the AC-1 through AC-31 mappings are unchanged except for the task renumbering below.

Renumbering. The plan validator (`scripts/dev_tools/validate_orchestration_artifacts.py`, `PLAN_PHASE_RE` line 48 and `PLAN_TASK_RE` lines 49-51) accepts only a decimal phase number in `### Phase N — <Title>` and in `[P#-T#]`, so a `3A` heading and `P3A-T#` task IDs fail it. The corpus gate is therefore Phase 4 and the former Phases 4-11 are Phases 5-12. Every task ID, phase reference, and `phaseN-` evidence name in this plan was renumbered by the same mapping: 4→5, 5→6, 6→7, 7→8, 8→9, 9→10, 10→11, 11→12 (for example the former P4-T13 is P5-T13, the former P10-T7 is P11-T7, and the former `phase4-transport-pester` artifact is `phase5-transport-pester`). Task substance is unchanged.

Revision 2026-10-11 (v1.5; executor-preflight deltas on the v1.4 amendment). Eight deltas were applied and nothing else was re-planned:
1. P0-T2 records `LocalBranch:` (`git rev-parse --abbrev-ref HEAD`) and derives `Branch:` from the upstream (`git rev-parse --abbrev-ref --symbolic-full-name "@{u}"`, leading `origin/` removed), keeping the pattern check on `Branch:`, because the execution worktree checks out the alias `exec-896-local`. Every push in the plan, including the P4-T4 BLOCKED path and P4-T10, is now `git push origin HEAD:<BRANCH>`; fetches and `git rev-parse origin/<BRANCH>` are unchanged.
2. The header (Upstream dependency), self-review R10 and item 27, item 19, and P2-T4 now state that HEAD contains the E1 merge `039e53339` (via `f11f1814b`); the P1 `core.json` anchors were re-derived (lines 71 and 72; E1 entry at 68).
3. D6 S1 is stated with the CR-CORPUS regexes, and a Phase 4 S1 fix must use the same two regexes.
4. P4-T4 (b): the rule3 `Accept` row asserts the original reason fragment is absent; the rule2 `Accept` row advertises the recorded partner for the fixed stem and a same-folder, same-timestamp path for the other stem; CR-CORPUS appends ` [partner: <path>]` to each rule2 reason.
5. P4-T4 (b): rule3 here-strings use trimmed lines, and `Exemplar:` for rule3 is the first qualifying candidate (ASCII-only, no purity-hook denied token, no P12-T7 literal, no line starting `'@`, at most 40 lines), else BLOCKED with `EXEMPLAR-UNREPRESENTABLE`.
6. P4-T4 and the re-entry bound: `k` is the total number of `## FIX-` sections after the latest P4-T4 pass; `FIX-CLASSES:` and `E4-CORPUS-ROWS:` are rewritten on each re-entry; BLOCKED after a third failed P4-T7 run records `ReentryExhausted: yes`.
7. The CR-CORPUS introduction names its two working-tree reads (the H1 dot-source and, in final mode, `$InitialArtifact`) separately from the corpus reads at `<CORPUS-SHA>`.
8. P4-T2 appends a `CorpusCommand:` line recording the route and the substituted `$Mode`, `$CorpusSha`, and `$InitialArtifact`.

Revision 2026-10-11 (v1.6; preflight round-2 deltas on v1.5). Four deltas were applied and nothing else was re-planned:
1. CR-CORPUS rule2 passes `$stem` as the `Add-CorpusReject` language field, so the rule2 final-mode TP key is `rule2|<policy-audit path>|<stem>` and the two partner rejections of one policy audit no longer collapse into one key; the CR-CORPUS Output-lines text now reads `<language for rule3, partner stem for rule2, - for rule1>`; self-review V8 states the key.
2. P4-T4 (b) Reject S1: every match of `(?i)\bbranch\b` in each line meeting the D6 S1 condition is replaced with `line`, so no transformed line matches `(?i)\bbranch\b` (the former first-match replacement could leave a second `branch` token and keep the line sanctioned).
3. P4-T4 (b) rule2 Accept: each row carries its advertised paths as `Paths`, the `It` body sets `$script:E4CorpusPaths`, and the in-`It` `Get-ArtifactFileContent` mock answers existence from that list; the return shape was verified against `Get-ArtifactFileContent` (H1 base lines 60 and 72) and the T1 same-timestamp test (lines 39-54) and needed no adjustment.
4. P4-T6 caps T1 at 400 lines (derivation in the task: 99 lines of headroom below the 500-line cap for about 88 planned later T1 lines from P5-T6, P5-T11, P6-T6, and P7-T12); a T1 above the ceiling records `BlockedReason: T1-LINE-BUDGET` and follows the P4-T4 BLOCKED procedure, whose trigger list now names that reason.

Revision 2026-10-11 (v1.7; preflight round-3 delta on v1.6). One delta was applied, with one sibling correction found by the self-review; nothing else was re-planned:
1. The plan file `<FEATURE>/plan.2026-10-11T07-58.md` is tracked and receives the executor's check-offs, but no `git add` staged it, so every clean-status acceptance failed. The Execution Notes now carry the plan-file staging rule. The plan path was appended to the `git add` command of P0-T8 (STOP path), P0-T9 (conflict path), P0-T25, P1-T7, P2-T9, P3-T12, P4-T4 (BLOCKED procedure), P4-T10, P5-T21, P6-T13, P7-T19, P8-T4, P9-T16, P10-T7, P11-T11, and P12-T17 (16 commands; each task was re-read and contains a `git add`). The unscoped status checks of P0-T8, P0-T9, P0-T25, P1-T7, P2-T9, P3-T12, P4-T1, P4-T10, P5-T21, P6-T13, P7-T19, P8-T4, P9-T16, P10-T7, P11-T11, P12-T8, and P12-T17 accept the single plan-file status line (17 checks; each task was re-read and contains an unscoped `git status --porcelain` check). The task lists in the delta needed no adjustment. P0-T10 now states that the plan-file status line is left out of `AnchorDrift:`. The P4-T4 BLOCKED `git restore` paths (`.claude/hooks`, `tests/scripts/claude-hooks`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks`) do not include `docs/`, so the restore leaves the plan file and its check-offs in place.
2. Sibling correction (P12-T8). P12-T8 runs after P11-T11 and before P12-T17, so the artifacts written by P12-T1 through P12-T7 are untracked when it runs and the P12-T3 append to the tracked P1-T5 artifact is uncommitted; its status output contains those `??` and ` M` lines in addition to the plan-file line. The P12-T8 status check therefore also accepts ` M ` and `?? ` lines under `<FEATURE>/evidence/`; P12-T17 commits them. No other listed status check runs while uncommitted evidence exists: P4-T1 runs its status command before it creates its artifact, and every commit task checks status after its own commit.

Revision 2026-10-12 (v1.8; P4-T4 exemplar representation rule). Execution stopped at P4-T4 with `BlockedReason: EXEMPLAR-UNREPRESENTABLE` (`<FEATURE>/evidence/other/corpus-rule-changes.2026-10-12T00-18.md`, against `CorpusSha: 2ef8d361e978ca8b7733a545d76a87e8418005ce`): FIX-3 (`rule3|Python|NARROWING|sanctioned`) and FIX-4 (`rule3|TypeScript|NARROWING|sanctioned`) had no candidate whose full line set was ASCII-only and at most 40 lines. Only the rule3 exemplar rule and the text it forces were changed; P0-T1 through P4-T3 and their check-offs are unchanged, and nothing else was re-planned:
1. P4-T4 (b) now selects every rule3 exemplar through the new read-only CR-EXEMPLAR. It tries the full line set of each candidate first (`ExemplarForm: FULL`, the v1.5 definition). When no full line set qualifies, it tries a mechanically derived reduced line set of each candidate (`ExemplarForm: REDUCED`). The reduced set keeps the lines `Test-LanguageCoverageRow` evaluates for the form key's reason class, plus the `^##\s` heading that opens each kept line's section, and replaces each non-ASCII UTF-16 code unit through a fixed table, with `?` for any unit not in the table. The existing purity, P12-T7, `'@`, and 40-line checks then apply unchanged.
2. Representativeness guard. A candidate is selected only when its line set, passed to the HEAD version of `Test-LanguageCoverageRow` (loaded from `git show HEAD:.claude/hooks/validate-feature-review-coverage-rules.ps1`, which holds no Phase 4 fix until P4-T10 commits), returns the form key's original reason fragment. CR-EXEMPLAR prints `EXEMPLAR-GUARD: ... | REPRODUCED | <fragment> | <reason>`, and the FIX section records `ExemplarGuard: REPRODUCED | <fragment>`. The guard applies to FULL and REDUCED candidates alike, and a candidate that fails it is passed over for the next one. When no candidate qualifies and reproduces, the result is `EXEMPLAR-UNREPRESENTABLE`.
3. Restart after a BLOCKED P4-T4. The restart creates a new rule-changes artifact with `RestartOf:` naming the BLOCKED one, which stays in place unedited. It re-derives `k` from P4-T2 and re-applies every fix from FIX-1, because the BLOCKED procedure restored H1, H3, T1, and the Claude bundle hooks to HEAD. A restart is not a P4-T7 re-entry. The Phase 4 introduction defines "the rule-changes artifact" for P4-T4 through P4-T9 as the file created by the latest first pass or restart. A new artifact is used instead of an appended section because the BLOCKED artifact already holds `CorpusGate: BLOCKED` and four `Status: PENDING` sections. Appending to it would make the P4-T9 acceptance (exactly one `CorpusGate:` line, reading PASS) and the P4-T4 acceptance (every `## FIX-` section `APPLIED`) unsatisfiable.
4. The success-output observation rule names CR-EXEMPLAR's in-task observation run. P4-T4 (b) states that the Python label lines in a T1 rule3 here-string do not breach C3, because C3 and the Hermeticity rule govern H1-H6 production lines. C1-C8 are otherwise unchanged: CR-EXEMPLAR adds no function to H1, H2, or H3, keeps every reason fragment, and adds no production line. The P4-T6 T1 ceiling of 400 is unchanged.
5. Body locations of items 1-4: the Phase 4 introduction (restart paragraph and the "rule-changes artifact" definition); the P4-T4 field list (`RestartOf:` on a restart; `ExemplarForm:` and `ExemplarGuard:` for rule3); the P4-T4 (b) rule3 bullet (the CR-EXEMPLAR run, its `ExemplarCommand:` line and `### CR-EXEMPLAR output` block in the FIX section, the here-string built from the `EXEMPLAR-LINE:` values, and the C3 statement); the P4-T4 BLOCKED procedure (the trigger names CR-EXEMPLAR's `NONE` result, and P4-T4 resumes only through the restart); one P4-T4 acceptance bullet for the rule3 fields; and the P4-T9 artifact reference. The new section is `### CR-EXEMPLAR` under the Command Reference. Its script was re-checked against the current tree in this revision and needed no change.
6. Preflight round-1 delta (2026-10-12). The P4-T4 (b) rule3 bullet now states, after the here-string construction sentence, that each rule3 `j` carries its here-string exactly once in T1: it is assigned in the `It` body as `$auditText`, the two `-ForEach` rows are `@{ Kind = 'Accept' }` and `@{ Kind = 'Reject' }` (plus any `It` name template keys), and the `It` body applies the `Reject` transformation to `$auditText` when `$Kind -eq 'Reject'`. The line-budget sentence was adjusted in the sibling check: the supplied wording said a per-row repetition "would exceed the P4-T6 ceiling of 400", but 156 + 93 + 93 = 342, so the sentence now states the 342-line subtotal and the 58 lines it leaves for the remaining E4-CORPUS text. T1 156 lines at HEAD was re-derived from the tree; the 87-line and 93-line exemplar totals come from the executor's 2026-10-12 CR-EXEMPLAR dry run and are not recorded in a feature artifact. No other task or check-off changed.

Design decisions (fixed here; the executor does not choose them):

- D1 Corpus. After `git fetch origin main` (the one fetch in this plan that does not target `<BRANCH>`), `CorpusSha` is the output of `git rev-parse origin/main`, recorded by P4-T1. The raw corpus is every path printed by `git -c core.quotePath=false ls-tree -r --name-only <CorpusSha> -- docs` whose last segment matches `(policy-audit|code-review|feature-audit)` (case-insensitive) and ends `.md`. Paths under `docs/features/templates/` are excluded as templates (the three `docs/features/templates/policy_audit/<stem>.yyyy-MM-ddTHH-mm.md` files). Paths whose last segment does not match `^(policy-audit|code-review|feature-audit)(\..*)?\.md$` (case-sensitive) are excluded as non-artifacts. The remainder are the review artifacts. Both exclusion counts are printed. The initial and the final run use the same `CorpusSha`, so a third party re-running CR-CORPUS with that SHA obtains the same set.
- D2 Active-prefix rule. Feature folders move from `docs/features/active/` to other lifecycle folders (for example `completed/` and `archive/`) after review, so the `docs/features/active/` prefix in `Get-ReviewArtifactInfo` is a location convention that held at review time. Each artifact path is evaluated as its active-equivalent path: the segment directly under `docs/features/` (any segment other than `templates`) is replaced by `active`. The rest of the path (feature folder, any subfolder, stem, timestamp) is evaluated unchanged.
- D3 Triple grouping. For each review artifact that `Get-ReviewArtifactInfo` accepts, `(Folder, Stem, Timestamp)` is indexed. For each accepted policy audit `(F, T)`, the code-review and feature-audit partners are the artifacts of that stem in folder `F` with timestamp `T`. When none exists, the partner is the one in `F` with the smallest absolute timestamp difference that is at most 120 minutes; ties go to the earlier timestamp. A policy audit with both partners is a triple. Otherwise it is an incomplete group, which is counted and excluded from the same-folder-and-timestamp rule, because whether an artifact exists is not a convention-sensitive rule. Each triple runs through the real decision function (`Invoke-FeatureReviewCoverageValidation`) with all three active-equivalent paths advertised and file existence answered from the corpus. Only the same-folder-and-timestamp reasons are collected from that run.
- D4 Changed-language set. The coverage-row rule is evaluated for every policy-audit artifact, independently of D3. The issue number is the trailing `-(\d+)$` of the feature folder segment. The candidate PRs are the merged PRs (`gh pr list --repo drmoisan/drm-copilot --state merged --limit 5000 --json number,headRefName`) whose `headRefName` matches `-<issue>(-r\d+)?$`. Of these, the reviewed PR is the one whose full file list (`gh api --paginate repos/drmoisan/drm-copilot/pulls/<number>/files --jq '.[].filename'`) contains the policy audit's active-equivalent path, which is the PR that added the review artifact. When exactly one such PR exists, its file list goes to `Get-ChangedLanguageSet` in the `- <path> (+0/-0)` summary form, and the result is the language set. Otherwise the policy audit is `UNDERIVABLE` (no issue number, or zero or several matching PRs). It is then excluded from the coverage-row denominator, and the count is printed. A policy audit whose set is empty is counted as `NO-CHANGED-LANGUAGE`. The initial run records each set in a `CORPUS-LANG:` line, and the final run reuses those lines, so both runs evaluate the same input.
- D5 Live coverage. Historical live coverage is unavailable, so `Test-LanguageCoverageRow` is called with `-RepoWidePct $null -BranchPct $null` and only the four text rules apply (mention, coverage-scoped row, narrowing, PASS/FAIL verdict).
- D6 Classification. CR-CORPUS classifies each rejection mechanically in this order. The vocabulary it uses (language labels, coverage terms, narrowing phrases) is a fixed copy of the base H1 values (lines 279-284, 299, 307), so the classification does not depend on the validator version under test.
  1. Sanction table. The rejection is FALSE-POSITIVE when it matches an entry below.
     - S1: a PowerShell narrowing line that matches the regex `(?i)\bbranch\b` and does not match the regex `(?i)\bline\s+coverage\b` (the two regexes CR-CORPUS `Get-Rule3Class` applies). Any Phase 4 S1 fix in `Test-LanguageCoverageRow` uses these same two regexes to identify the sanctioned line, so the validator and the classifier agree on which lines S1 covers. Sanctioned by `.claude/rules/general-unit-test.md:25`, `.claude/rules/quality-tiers.md:38`, and `.claude/skills/feature-review-workflow/SKILL.md:111` (Pester measures no branch coverage, and a missing PowerShell branch figure is not a FAIL).
     - S2: a narrowing line inside a `## Rejected Scope Narrowing` section. `.claude/skills/feature-review-workflow/SKILL.md:180` requires caller narrowing text to be recorded there verbatim.
     - S3: an artifact at `docs/features/active/<slug>/audit/<yyyy-MM-ddTHH-mm>/<stem>.md`. `.claude/skills/remediation-handoff-atomic-planner/SKILL.md:69-82` names the review artifacts this way.
     A narrowing rejection is FALSE-POSITIVE only when every narrowing line that names the language is covered by S1 or S2.
  2. Policy prohibition. The rejection is TRUE-POSITIVE in each of these cases:
     - a narrowing rejection with at least one narrowing line not covered by S1 or S2 (`feature-review-workflow/SKILL.md:180-181`: `N/A`, `UNVERIFIED`, and "informational only" are not acceptable for a changed language);
     - a no-mention rejection;
     - a no-coverage-row or no-verdict rejection where no line outside an S2 section names the language with a coverage term or a percentage and a `PASS` or `FAIL` token and no narrowing phrase (`SKILL.md:106` and `:181`: an explicit PASS or FAIL coverage verdict is required for each changed language);
     - a path rejection whose path carries no `yyyy-MM-ddTHH-mm` timestamp (`.claude/skills/evidence-and-timestamp-conventions/SKILL.md:46`; `feature-review-workflow/SKILL.md:164-172`).
  3. Established convention. Every other rejection has a form key (path shape with digits replaced by `9`, stem by `<stem>`, and feature folder by `<F>`; or `rule2|<stem>|<delta bucket>`; or `rule3|<language>|<reason class>`). It is FALSE-POSITIVE when the rejections in this step that share its form key span at least N = 3 distinct feature folders, and TRUE-POSITIVE otherwise.
  N = 3 is chosen for these reasons. One folder is an individual deviation. Two folders can be a single review and its re-review, or one session repeating its own choice. Three distinct feature folders show the same form across separate reviews, which is the operator rule's meaning of "established". Step 2 runs before step 3, so a form that contradicts a governing source is never accepted on frequency alone. The governing sources are the current `origin/main` versions of the files cited in steps 1 and 2.
- D7 Rule-fix constraints (Phase 4 edits).
  - C1: change only the existing functions `Get-ReviewArtifactInfo` and `Test-LanguageCoverageRow` in H3 and the same-folder-and-timestamp comparison in `Invoke-FeatureReviewCoverageValidation` in H1. Add or remove no function in H1, H2, or H3, so the E4-ST4 lists (P2-T6, P6-T6) and the Planned File Split stay valid. A fix that needs a new function stops with BLOCKED.
  - C2: keep the six failure returns of `Test-LanguageCoverageRow` and these reason fragments: `does not mention`, `no coverage-scoped row`, `narrows scope`, `neither a PASS nor a FAIL`, `line coverage floor`, `branch coverage floor`. Keep `must share the same feature folder and timestamp`. P5-T2 classifies those returns, and CR-CORPUS classifies by those fragments.
  - C3: no new line contains the token `python` in any letter case (Hermeticity).
  - C4: if removing a false positive would require editing any file under `.claude/rules/` or `.github/instructions/`, root `CLAUDE.md` (including its coverage wording), or any skill file, stop with BLOCKED, record the reason, and do not edit that file.
  - C5: do not edit H5 (the operator rule covers the Claude validator). The rule-changes artifact records `CodexParity:` for each fix, stating whether H5's `Test-LanguageCoverageRow` contains the same rule. This is informational only.
  - C6: every file stays below 500 lines.
  - C7: a fix accepts its false-positive form key and nothing else. The final run's `CORPUS-TP-DROPPED: 0` enforces this.
  - C8: a fix keeps every existing test outcome and every T11 fixture outcome that a later phase asserts.
- D8 Out-of-corpus observation. The optional `remediation-inputs-path` comparison (H1 base lines 417-429) is not in the corpus, which is limited to the three stems. P4-T4 records in the rule-changes artifact whether `.claude/skills/remediation-handoff-atomic-planner/SKILL.md:71-84` (`remediation/<entry-ts>/remediation-inputs.md`, with an entry timestamp that differs from the audit timestamp) conflicts with that comparison. It records this as `OutOfCorpusObservation:` for the orchestrator and makes no change.

## Decision Function Shape (H1; AC-4, AC-5, AC-30, AC-31)

Phase 5 writes `Invoke-FeatureReviewCoverageValidation` in this shape; Phase 6 replaces the marked `CLAUDE.md` read. `<AnomalyReasonCall>` and `<ReportAndHalt>` follow PI-5.

```powershell
function Invoke-FeatureReviewCoverageValidation {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [AllowNull()] [AllowEmptyString()] [string] $InputText
    )
    $dependencyDecision = Get-HookDependencyFailureDecision -HookEvent SubagentStop -ReasonPrefix 'validate-feature-review-coverage:'
    if ($null -ne $dependencyDecision) { return $dependencyDecision }

    $envelope = if ($PSBoundParameters.ContainsKey('InputText')) { Read-SubagentStopEnvelope -InputText $InputText } else { Read-SubagentStopEnvelope }
    if (-not $envelope.IsValid) {
        return @{ Ok = $false; Message = ('validate-feature-review-coverage: payload anomaly - ' + (<AnomalyReasonCall>)) }
    }

    try {
        $finding = & {
            # Base lines 365-459, with these changes: $agentOutput = [string]$envelope.AssistantText;
            # each block return becomes @{ Message = <text>; HasRepairable = <bool>; HasNonRepairable = <bool> };
            # each allow return becomes "return $null"; messages begin 'validate-feature-review-coverage:' (PI-4).
        }
    }
    catch {
        $finding = @{ Message = ('validate-feature-review-coverage: validator error: ' + ([string]$_.Exception.Message -split "`r?`n")[0] + '; the gate fails closed.'); HasRepairable = $false; HasNonRepairable = $true }
    }

    if ($null -eq $finding) { return @{ Ok = $true; Message = $null } }
    if ($envelope.StopHookActive -and -not $finding.HasRepairable) { return @{ Ok = $true; Message = $null } }
    $message = if ($finding.HasNonRepairable) { "$($finding.Message) <ReportAndHalt>" } else { $finding.Message }
    return @{ Ok = $false; Message = $message }
}
```

Classification inside the script block (spec Proposed Fix item 2a):

- Repairable (`HasRepairable = $true`, `HasNonRepairable = $false`): empty `AssistantText` (`validate-feature-review-coverage: agent output is empty; feature-review must report required artifact paths before termination.`); the collected artifact-path errors (`validate-feature-review-coverage: required review artifact validation failed:` followed by the existing error list).
- Coverage rows: the message is `validate-feature-review-coverage: coverage validation failed against branch diff:` followed by every collected reason; `HasRepairable` is true when any failing row result has `Repairable = $true`, and `HasNonRepairable` is true when any has `Repairable = $false`.
- Non-repairable: root `CLAUDE.md` unreadable (Phase 6: `validate-feature-review-coverage: root CLAUDE.md exists but could not be read (<first exception line>); coverage floors cannot be resolved, so the gate fails closed.`); validator error (the catch above).

`Test-LanguageCoverageRow` in H3 returns `Repairable = $true` on its five repairable failure returns (base lines 293-296, 301-304, 311-314, 319-322, 328-331) and `Repairable = $false` on the branch-floor return (base lines 336-339).

The entry point (base lines 464-477) becomes, with base lines 464-469 unchanged and in place:

```powershell
try { $result = Invoke-FeatureReviewCoverageValidation }
catch { Exit-SubagentStopBlock -Message ('validate-feature-review-coverage: validator error: ' + ([string]$_.Exception.Message -split "`r?`n")[0] + '; the gate fails closed. <ReportAndHalt>') }
if (-not $result.Ok) { Exit-SubagentStopBlock -Message $result.Message }
exit 0
```

The first two statements of the function are the S6 statements (`tests/scripts/claude-runtime/HookGuardShape.Helpers.ps1:113-116`); they are not reshaped, and the dependency-failure return keeps the guard's `ExitCode`/`Reason` shape (`.claude/hooks/hook-dependency-guard.ps1:104-105`). The entry tail at base lines 467-469 stays inline (S1, `HookGuardShape.Helpers.ps1:40-55`) and does not call `Exit-SubagentStopBlock`.

## Hermeticity and Authoring Constraints (every new or edited file)

- No temporary files: no `New-TemporaryFile`, no `TestDrive:`, no write under the temp directory, no `GetTempFileName`. Stdin is supplied through `[System.Console]::SetIn([System.IO.StringReader]::new(...))` and stderr through `[System.Console]::SetError([System.IO.StringWriter]::new())`, both restored in `finally`. File content is supplied through mocks of `Get-ArtifactFileContent`, `Test-Path`, `Get-Content`, and `Get-ChildItem`. Static tests read committed repository files only.
- No child process: the hook entry point is driven in-process through the `&` route, as `tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1:26-43` does.
- `.claude/hooks/check-powershell-test-purity.ps1` denies a write under `tests/` that contains certain tokens (for example the process-start cmdlet, the sleep cmdlet, the temporary-file cmdlet, or the temp environment variable). No test in this plan needs them; do not write them, including in comments.
- No mock is built with `[scriptblock]::Create`; mock bodies are literal script blocks.
- No new or edited line in H1-H6 contains the token `python` in any letter case, other than the base lines that move unchanged into H2 and H3 (CR-PY-TOKEN, AC-26 (c)).
- No file under `.codex/hooks/` dot-sources a `.claude/` path; no hook adds a Python invocation.
- Every test and production file stays below 500 lines.

## Execution Notes

- Command route rule: every PowerShell-syntax command in any task (for example `Test-Path`, `Copy-Item`, `ConvertFrom-Json`, `[System.Management.Automation.Language.Parser]::ParseFile`, `Get-Command`, `(Get-Content <path>).Count`) runs only as a CR body through the CR route below; no task runs a PowerShell cmdlet outside a CR. `git`, `gh`, `poetry`, and `sh` commands are shell-neutral and run directly.
- `.claude/hooks/enforce-powershell-batch-budget.ps1` denies the fourth distinct production PowerShell file outside the orchestrated large path. This plan edits six production PowerShell files (H1-H6) plus their mirrors and runs under the epic orchestrator's large path. If the hook denies a write, stop with BLOCKED and report the denial text; do not bypass or edit the hook.
- Never force-push. Every push is `git push origin HEAD:<BRANCH>`, where `<BRANCH>` is the `Branch:` value recorded by P0-T2 (the upstream name, not the possibly aliased `LocalBranch:`); the explicit `HEAD:` refspec makes the push target independent of the local branch name; every branch fetch is `git fetch origin <BRANCH>` and every remote-head comparison is `git rev-parse origin/<BRANCH>`.
- The `mcp__drm-copilot__run_poshqc_*` tools return a summary that does not carry tool output, so no task asserts a count, percentage, or finding from them (PI-7). Every count and percentage in this plan is read from a CR output below.
- Pre-existing failure rule (PEF): a gate marked `(PEF)` meets its `TOTAL:` acceptance when every `FAILED:` line names a test (the `ExpandedPath` before ` :: `) that P0-T12 lists as `PRE-EXISTING:` and whose name contains none of `validate-feature-review-coverage`, `feature-review-coverage-thresholds`, `E4-`, `TG1:`, `TG2:`, `TG3:`, `F824-`, `T824-`. When every `FAILED:` line meets this rule and at least one exists and the `TOTAL:` line reads `FailedBlocks=0 | FailedContainers=0`, that gate's `EXIT_CODE_COMPUTED: 0` and process-exit-0 acceptance is replaced by `EXIT_CODE_COMPUTED: 1` and process exit code 1, and the gate artifact records `ExpectedExitCode: 1` and lists each such line under `PRE-EXISTING-STILL-FAILING:`. The rule applies to `TOTAL:` lines only; `SUITE:` and `NAMED:` acceptances are exact, except the `NAMED: N1:*` acceptance, which follows the N1 rule under GUARD-PATTERNS. Any `PRE-EXISTING-STILL-FAILING:` entry leaves AC-28 unchecked (P12-T15). The full-run analogue for P11-T7 is stated in that task.
- Plan-file staging rule. Check-offs are written to `<FEATURE>/plan.2026-10-11T07-58.md`, which is tracked. Append that path to the `git add` command of P0-T8 (STOP path), P0-T9 (conflict path), P0-T25, P1-T7, P2-T9, P3-T12, P4-T4 (BLOCKED procedure), P4-T10, P5-T21, P6-T13, P7-T19, P8-T4, P9-T16, P10-T7, P11-T11, and P12-T17. Every check on unscoped `git status --porcelain` output in P0-T8, P0-T9, P0-T25, P1-T7, P2-T9, P3-T12, P4-T1, P4-T10, P5-T21, P6-T13, P7-T19, P8-T4, P9-T16, P10-T7, P11-T11, P12-T8, and P12-T17 passes when the output is empty or is exactly the single line ` M docs/features/active/subagentstop-envelope-feature-review-coverage-896/plan.2026-10-11T07-58.md`. P0-T10 leaves that line out of `AnchorDrift:`. The before-and-after status comparisons in P0-T15, P0-T23, and P11-T1, and the path-scoped status commands in P7-T14, P9-T11, and P12-T4, are unchanged. P12-T8 alone additionally accepts lines that begin ` M docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/` or `?? docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/`, because the P12-T1 through P12-T7 artifacts and the P12-T3 append to the P1-T5 artifact are committed only by P12-T17 (v1.7 sibling correction).
- Commit messages end with the session's standard attribution trailer lines.

## Command Reference (CR)

Every CR body runs from the worktree root. Every CR body except CR-POSHQC-FULL ends with `exit $code`, where `$code` is the value printed on the `EXIT_CODE_COMPUTED:` line, so the process exit code equals the computed value. The artifact `EXIT_CODE:` field records the process exit code of the CR run.

Routes. Primary route: the PowerShell tool runs the body and reports the process exit code. Scratchpad route: write the body to a `.ps1` file in the session scratchpad directory (outside the repository, not under any `tests` segment, not named `*.Tests.ps1`), write a scratchpad `.sh` file whose single command line runs the PowerShell host with `-NoProfile -File` on it, and run `sh <that .sh>` from the worktree root. The scratchpad route is used when the agent-worktree isolation guard denies the text, when no PowerShell tool is available, and always for CR-POSHQC-FULL (its `Run.Exit = $true` ends the host process). On either route, stop with BLOCKED if the process exit code disagrees with `EXIT_CODE_COMPUTED:`. The artifact `Command:` field records the route and the list substituted for each list placeholder.

Success-output observation rule: Phase 0 runs every CR at least once (P0-T11 through P0-T23), except CR-CORPUS (amendment 2026-10-11), whose observation runs are P4-T2 and P4-T3 as stated under CR-CORPUS, and CR-EXEMPLAR (v1.8), whose observation run is its first P4-T4 run as stated under CR-EXEMPLAR. Before a later task asserts over a CR's output, the Phase 0 artifact must show the success-case literal named under that CR. If a named literal is absent from a successful run, record the observed output and stop with BLOCKED; do not substitute a different literal.

### Lists

- LIST-PROD: `.claude/hooks/validate-feature-review-coverage.ps1`, `.claude/hooks/validate-feature-review-coverage-metrics.ps1`, `.claude/hooks/validate-feature-review-coverage-rules.ps1`, `.claude/hooks/feature-review-coverage-thresholds.ps1`, `.codex/hooks/validate-feature-review-coverage.ps1`, `.codex/hooks/feature-review-coverage-thresholds.ps1`.
- LIST-PROD-BASE: `.claude/hooks/validate-feature-review-coverage.ps1`, `.claude/hooks/feature-review-coverage-thresholds.ps1`, `.codex/hooks/validate-feature-review-coverage.ps1`.
- LIST-TEST: T1 through T9 and T11 paths from the table above (T11 is test support; it is formatted, analyzed, and size-checked with the tests but is not a Pester run path).
- LIST-TEST-BASE: T1 through T6 and T9 paths (T7 and T8 do not exist on the base).
- LIST-RUNTIME-SUITES: `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`, `tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1`.
- LIST-CLAUDE-SUITES: T1, T2, T3, T4, T5, `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1`, `tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1`, and LIST-RUNTIME-SUITES.
- LIST-CODEX-SUITES: T6, T7, T8, T9, `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1`, `tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1`.
- LIST-AUX: `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`.
- LIST-MIRROR-PAIRS (source then mirror): H1-H4 with `extensions/drm-copilot/resources/claude-customizations/<same path>`; H5, H6, S1, S3 with `extensions/drm-copilot/resources/codex-and-agents-customizations/<same path>`; S2 with `extensions/drm-copilot/resources/customizations/<same path>`.
- GUARD-PATTERNS (Pester `ExpandedName` patterns for this hook's guard-completeness and no-stdout rows; the row names come from `hook-dependency-guard-completeness.Tests.ps1:117-139` with `Hook` set to the root-relative path, and from `hook-imported-modules-no-stdout.Tests.ps1:67`): `S1:*.claude/hooks/validate-feature-review-coverage.ps1*`, `S2:*.claude/hooks/validate-feature-review-coverage.ps1*`, `S6:*.claude/hooks/validate-feature-review-coverage.ps1*`, `N1:*`. Each `S` pattern matches one `repository` row and one `mirror` row (expected `Passed=2`); `N1:*` matches the `repository` and `mirror` rows (expected `Passed=2`). N1 rule: N1 scans the import closure of every registered hook, so a finding in another hook's module fails it. P0-T12 records `N1-BASELINE: PASSING` when its `NAMED: N1:*` line reads `Passed=2 | Failed=0`, otherwise `N1-BASELINE: FAILING`. When `N1-BASELINE: FAILING` is recorded, every later `NAMED: N1:* | Passed=2 | Failed=0` acceptance is replaced by: no `FAILED:` line whose name contains `N1: ` (the `ExpandedPath` is the `Describe` name, a dot, then the `It` name) has a message (the text after ` :: `) naming `validate-feature-review-coverage`, `feature-review-coverage-thresholds`, or `subagentstop-envelope`, and no N1 `FAILED:` message contains ` more)` (Pester lists at most ten findings in the message; a shortened message does not meet the N1 rule); the gate artifact copies each N1 `FAILED:` line verbatim.
- PYTEST-SPEC: `poetry run pytest tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_codex_core_manifest_closure.py` (the spec Test Strategy command, verbatim).

### CR-PESTER-LIST (direct Pester over an explicit list, with tag filters)

Adapted from the executed recipe in `docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/plan.2026-10-08T13-54.md:120-150`; the two filter lines and the final `exit` are the only additions.

```powershell
$Paths = @( <LIST> )
$IncludeTags = @( <TAGS-IN> )    # may be empty
$ExcludeTags = @( <TAGS-OUT> )   # may be empty
$NamePatterns = @( <PATTERNS> )  # wildcard patterns matched against ExpandedName; may be empty
$root = (Get-Location).Path
Import-Module Pester -MinimumVersion 5.0.0 -ErrorAction Stop
$configuration = New-PesterConfiguration
$configuration.Run.Path = $Paths
$configuration.Run.PassThru = $true
$configuration.Output.Verbosity = 'Normal'
if ($IncludeTags.Count -gt 0) { $configuration.Filter.Tag = $IncludeTags }
if ($ExcludeTags.Count -gt 0) { $configuration.Filter.ExcludeTag = $ExcludeTags }
$result = Invoke-Pester -Configuration $configuration
function Get-RelativeName([string] $File) { return $File.Substring($root.Length + 1).Replace([string][char]92, '/') }
foreach ($container in $result.Containers) { "CONTAINER: $(Get-RelativeName ([string]$container.Item)) | Result=$($container.Result)" }
foreach ($group in ($result.Tests | Group-Object { Get-RelativeName ([string]$_.ScriptBlock.File) } | Sort-Object Name)) {
    $passed = @($group.Group | Where-Object Result -EQ 'Passed').Count
    $failed = @($group.Group | Where-Object Result -EQ 'Failed').Count
    $skipped = @($group.Group | Where-Object Result -EQ 'Skipped').Count
    $notRun = @($group.Group | Where-Object Result -EQ 'NotRun').Count
    "SUITE: $($group.Name) | Passed=$passed | Failed=$failed | Skipped=$skipped | NotRun=$notRun"
}
foreach ($pattern in $NamePatterns) {
    $hits = @($result.Tests | Where-Object { $_.ExpandedName -like $pattern })
    "NAMED: $pattern | Passed=$(@($hits | Where-Object Result -EQ 'Passed').Count) | Failed=$(@($hits | Where-Object Result -EQ 'Failed').Count) | NotRun=$(@($hits | Where-Object Result -EQ 'NotRun').Count) | Total=$($hits.Count)"
}
foreach ($test in $result.Failed) { "FAILED: $($test.ExpandedPath) :: $((($test.ErrorRecord | Select-Object -First 1).Exception.Message) -replace '\s+', ' ')" }
"TOTAL: Passed=$($result.PassedCount) | Failed=$($result.FailedCount) | Skipped=$($result.SkippedCount) | NotRun=$($result.NotRunCount) | FailedBlocks=$($result.FailedBlocksCount) | FailedContainers=$($result.FailedContainersCount)"
$code = if ($result.FailedCount -eq 0 -and $result.FailedBlocksCount -eq 0 -and $result.FailedContainersCount -eq 0) { 0 } else { 1 }
"EXIT_CODE_COMPUTED: $code"
exit $code
```

Success-case literals: one `CONTAINER:` line per file with `Result=Passed`, one `SUITE:` line per file, one `NAMED:` line per pattern, a `TOTAL:` line with `Failed=0`, `EXIT_CODE_COMPUTED: 0`.

### CR-POSHQC-FULL (full-population PoshQC run; research Q8, `research.2026-10-11T08-10.md:274-278`)

```powershell
Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force
Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1
```

Observed success-case output (`docs/features/active/epic-852-main-sync/evidence/qa-gates/final-pester-coverage.md:11-12`, a recorded scratchpad-route run): one line beginning `Tests Passed:` with `Failed: 0,` and one line beginning `Covered` of the form `Covered <x>% / 0%. <n> analyzed Commands in <m> Files.`. This command prints no per-file figure; per-file line coverage is read from `artifacts/pester/powershell-coverage.xml` (`pester.runsettings.psd1:22`) by CR-COV-FILES, run immediately afterwards with no other Pester run in between. The run also writes `artifacts/pester/pester-junit.xml` (`pester.runsettings.psd1:15`), read by CR-JUNIT.

### CR-JUNIT (totals of the full run)

```powershell
[xml] $junit = Get-Content -Raw -LiteralPath 'artifacts/pester/pester-junit.xml'
$tests = 0; $failures = 0; $errors = 0
foreach ($suite in @($junit.SelectNodes('//testsuite'))) { $tests += [int]$suite.tests; $failures += [int]$suite.failures; $errors += [int]$suite.errors }
"JUNIT: tests=$tests | failures=$failures | errors=$errors"
foreach ($case in @($junit.SelectNodes('//testcase[failure or error]'))) { "JUNIT-FAILED: $($case.name)" }
$code = [int](($failures + $errors) -gt 0)
"EXIT_CODE_COMPUTED: $code"
exit $code
```

Success-case literals: `JUNIT: tests=<n> | failures=0 | errors=0`, `EXIT_CODE_COMPUTED: 0` (same summation as the executed script at `docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/evidence/other/observation-scripts.2026-10-08T17-32.md:320-325`).

### CR-COV-FILES (per-file line coverage from the CoverageGutters XML)

Package/sourcefile resolution copied from the executed script at `docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/evidence/other/observation-scripts.2026-10-08T17-32.md:327-347` (handles rooted and relative package names).

```powershell
$Files = @( <LIST> )
$root = (Get-Location).Path
[xml] $cov = Get-Content -Raw -LiteralPath 'artifacts/pester/powershell-coverage.xml'
$index = @{}
foreach ($pkg in @($cov.SelectNodes('//package'))) {
    $dir = [string]$pkg.name
    $relDir = if ([System.IO.Path]::IsPathRooted($dir)) { [System.IO.Path]::GetRelativePath($root, $dir) } else { $dir }
    $relDir = $relDir.Replace([string][char]92, '/').TrimEnd('/')
    foreach ($sf in @($pkg.SelectNodes('sourcefile'))) {
        $counter = $sf.SelectSingleNode("counter[@type='LINE']")
        if ($null -ne $counter) { $index["$relDir/$($sf.name)"] = $counter }
    }
}
$below = @()
foreach ($rel in $Files) {
    if (-not $index.ContainsKey($rel)) { "COVERAGE: $rel | ABSENT"; $below += $rel; continue }
    $c = [int]$index[$rel].covered; $m = [int]$index[$rel].missed
    $pct = if (($c + $m) -gt 0) { [math]::Round(100.0 * $c / ($c + $m), 2) } else { 0 }
    'COVERAGE: {0} | covered={1} | missed={2} | pct={3:F2}' -f $rel, $c, $m, $pct
    if ($pct -lt 85.0) { $below += $rel }
}
if ($below.Count -eq 0) { 'COVERAGE-BELOW-85: NONE' } else { "COVERAGE-BELOW-85: $($below -join ', ')" }
$code = [int]($below.Count -gt 0)
"EXIT_CODE_COMPUTED: $code"
exit $code
```

Success-case literals: one `COVERAGE:` line per file with numeric `covered=`, `missed=`, `pct=` values, `COVERAGE-BELOW-85: NONE`, `EXIT_CODE_COMPUTED: 0`.

### CR-COV-CHANGED (changed-line coverage against the merge base)

Line-map construction copied from the executed script at `docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/evidence/other/observation-scripts.2026-10-08T17-32.md:359-370`. The three-dot form compares committed content, so the final-QC use runs after the Phase 11 commit.

```powershell
$Files = @( <LIST> )
$root = (Get-Location).Path
[xml] $cov = Get-Content -Raw -LiteralPath 'artifacts/pester/powershell-coverage.xml'
$lineIndex = @{}
foreach ($pkg in @($cov.SelectNodes('//package'))) {
    $dir = [string]$pkg.name
    $relDir = if ([System.IO.Path]::IsPathRooted($dir)) { [System.IO.Path]::GetRelativePath($root, $dir) } else { $dir }
    $relDir = $relDir.Replace([string][char]92, '/').TrimEnd('/')
    foreach ($sf in @($pkg.SelectNodes('sourcefile'))) {
        $map = @{}
        foreach ($ln in @($sf.SelectNodes('line'))) { $map[[int]$ln.nr] = [int]$ln.ci }
        $lineIndex["$relDir/$($sf.name)"] = $map
    }
}
$below = @()
foreach ($rel in $Files) {
    $changed = [System.Collections.Generic.List[int]]::new()
    foreach ($hunk in @(git diff -U0 'origin/epic/subagentstop-envelope-integration...HEAD' -- $rel | Select-String -Pattern '^@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@')) {
        $start = [int]$hunk.Matches[0].Groups[1].Value
        $count = if ($hunk.Matches[0].Groups[2].Success) { [int]$hunk.Matches[0].Groups[2].Value } else { 1 }
        for ($n = $start; $n -lt $start + $count; $n++) { $changed.Add($n) }
    }
    $map = $lineIndex[$rel]
    if ($null -eq $map) { "CHANGED-COVERAGE: $rel | ABSENT"; $below += $rel; continue }
    $exec = @($changed | Where-Object { $map.ContainsKey($_) })
    $hit = @($exec | Where-Object { $map[$_] -gt 0 })
    $pct = if ($exec.Count -gt 0) { [math]::Round(100.0 * $hit.Count / $exec.Count, 2) } else { 100 }
    'CHANGED-COVERAGE: {0} | changed={1} | executable={2} | covered={3} | pct={4:F2}' -f $rel, $changed.Count, $exec.Count, $hit.Count, $pct
    if ($pct -lt 85.0) { $below += $rel }
}
if ($below.Count -eq 0) { 'CHANGED-BELOW-85: NONE' } else { "CHANGED-BELOW-85: $($below -join ', ')" }
$code = [int]($below.Count -gt 0)
"EXIT_CODE_COMPUTED: $code"
exit $code
```

Success-case literals: one `CHANGED-COVERAGE:` line per file with numeric values, `CHANGED-BELOW-85: NONE`, `EXIT_CODE_COMPUTED: 0`.

### CR-FORMAT-CHECK (read-only; mirrors the comparison in `Invoke-PoshQCFormat`, `scripts/powershell/PoshQC/PoshQC.Analyzer.psm1:56-66`)

Copied from the executed recipe at `docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/plan.2026-10-08T13-54.md:191-208`.

```powershell
$Paths = @( <LIST> )
Import-Module PSScriptAnalyzer -ErrorAction Stop
$settings = (Resolve-Path 'scripts/powershell/PoshQC/settings/pssa.settings.psd1').Path
$drift = 0
foreach ($path in $Paths) {
    $normalized = (Get-Content -Raw -LiteralPath $path) -replace "`r?`n", "`n"
    $formatted = Invoke-Formatter -ScriptDefinition $normalized -Settings $settings
    if ($formatted -ne $normalized) { $drift++; "FORMAT-DRIFT: $path" } else { "FORMAT-CLEAN: $path" }
}
"FORMAT-DRIFT-COUNT: $drift"
$code = [int]($drift -gt 0)
"EXIT_CODE_COMPUTED: $code"
exit $code
```

Success-case literals: one `FORMAT-CLEAN:` line per file, `FORMAT-DRIFT-COUNT: 0`, `EXIT_CODE_COMPUTED: 0`. Writes no file.

### CR-FORMAT-APPLY (write mode over an explicit list; same write as `Invoke-PoshQCFormat`)

```powershell
$Paths = @( <LIST> )
Import-Module PSScriptAnalyzer -ErrorAction Stop
$settings = (Resolve-Path 'scripts/powershell/PoshQC/settings/pssa.settings.psd1').Path
$applied = 0
foreach ($path in $Paths) {
    $normalized = (Get-Content -Raw -LiteralPath $path) -replace "`r?`n", "`n"
    $formatted = Invoke-Formatter -ScriptDefinition $normalized -Settings $settings
    if ($formatted -ne $normalized) { Set-Content -LiteralPath $path -Value $formatted -Encoding UTF8 -NoNewline; $applied++; "FORMAT-APPLIED: $path" } else { "FORMAT-UNCHANGED: $path" }
}
"FORMAT-APPLIED-COUNT: $applied"
$code = 0
"EXIT_CODE_COMPUTED: $code"
exit $code
```

Success-case literals for a clean pass: one `FORMAT-UNCHANGED:` line per file and `FORMAT-APPLIED-COUNT: 0`. A non-zero `FORMAT-APPLIED-COUNT` means the tree changed and the QC loop restarts.

### CR-PSSA (PSScriptAnalyzer with repository settings)

Copied from the executed recipe at `docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/plan.2026-10-08T13-54.md:210-228`.

```powershell
$Paths = @( <LIST> )
Import-Module PSScriptAnalyzer -ErrorAction Stop
$settings = (Resolve-Path 'scripts/powershell/PoshQC/settings/pssa.settings.psd1').Path
$total = 0
foreach ($path in $Paths) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { "PSSA: $path | MISSING"; $total++; continue }
    $findings = @(Invoke-ScriptAnalyzer -Path $path -Settings $settings -Severity Error, Warning, Information)
    $total += $findings.Count
    "PSSA: $($path) | findings=$($findings.Count)"
    foreach ($finding in $findings) { "PSSA-FINDING: $($path):$($finding.Line) $($finding.RuleName) $($finding.Severity)" }
}
"PSSA-TOTAL: $total"
$code = [int]($total -gt 0)
"EXIT_CODE_COMPUTED: $code"
exit $code
```

Success-case literals: one `PSSA:` line per file with `findings=0`, `PSSA-TOTAL: 0`, `EXIT_CODE_COMPUTED: 0`. The `Test-Path` line is the only addition to the copied recipe; a missing file prints `PSSA: <path> | MISSING` and counts toward `PSSA-TOTAL:`.

### CR-LINES (line counts against the 300-line target and the 500-line cap)

```powershell
$Files = @( <LIST> )
$over = 0
foreach ($rel in $Files) {
    if (-not (Test-Path -LiteralPath $rel -PathType Leaf)) { "LINES: $rel | MISSING"; $over++; continue }
    $count = (Get-Content -LiteralPath $rel).Count
    $band = if ($count -ge 500) { 'OVER-CAP' } elseif ($count -gt 300) { 'OVER-TARGET' } else { 'WITHIN-TARGET' }
    if ($count -ge 500) { $over++ }
    "LINES: $rel | count=$count | $band"
}
"LINES-OVER-CAP: $over"
$code = [int]($over -gt 0)
"EXIT_CODE_COMPUTED: $code"
exit $code
```

Success-case literals: one `LINES:` line per file with a numeric `count=`, `LINES-OVER-CAP: 0`, `EXIT_CODE_COMPUTED: 0`. The count is `(Get-Content <path>).Count`, the measure AC-10 names.

### CR-SHA (source and mirror SHA256; read-only)

```powershell
$Pairs = @( <PAIRS> )   # each entry: @{ Source = '<path>'; Mirror = '<path>' }
$differ = 0
foreach ($pair in $Pairs) {
    $s = (Get-FileHash -Algorithm SHA256 -LiteralPath $pair.Source).Hash
    $m = (Get-FileHash -Algorithm SHA256 -LiteralPath $pair.Mirror).Hash
    $state = if ($null -eq $s -or $null -eq $m) { 'MISSING' } elseif ($s -eq $m) { 'MATCH' } else { 'DIFFER' }
    if ($state -ne 'MATCH') { $differ++ }
    "SHA: $($pair.Source) | $s | $($pair.Mirror) | $m | $state"
}
"SHA-DIFFER-COUNT: $differ"
$code = [int]($differ -gt 0)
"EXIT_CODE_COMPUTED: $code"
exit $code
```

Success-case literals: one `SHA:` line per pair ending `MATCH`, `SHA-DIFFER-COUNT: 0`, `EXIT_CODE_COMPUTED: 0`. A missing source or mirror yields a null hash, a line ending `MISSING`, and a non-zero `SHA-DIFFER-COUNT:`.

### CR-MIRROR (copy each source to its mirror, then hash both; write mode)

```powershell
$Pairs = @( <PAIRS> )   # each entry: @{ Source = '<path>'; Mirror = '<path>' }
$differ = 0
foreach ($pair in $Pairs) {
    Copy-Item -LiteralPath $pair.Source -Destination $pair.Mirror -Force
    $s = (Get-FileHash -Algorithm SHA256 -LiteralPath $pair.Source).Hash
    $m = (Get-FileHash -Algorithm SHA256 -LiteralPath $pair.Mirror).Hash
    $state = if ($null -eq $s -or $null -eq $m) { 'MISSING' } elseif ($s -eq $m) { 'MATCH' } else { 'DIFFER' }
    if ($state -ne 'MATCH') { $differ++ }
    "COPIED: $($pair.Source) | $s | $($pair.Mirror) | $m | $state"
}
"COPY-DIFFER-COUNT: $differ"
$code = [int]($differ -gt 0)
"EXIT_CODE_COMPUTED: $code"
exit $code
```

Success-case literals: one `COPIED:` line per pair ending `MATCH`, `COPY-DIFFER-COUNT: 0`, `EXIT_CODE_COMPUTED: 0`. The `MATCH` hash pair is the observation beyond the exit code for this write-mode command. A missing source (copy fails, null source hash) yields a line ending `MISSING` and a non-zero `COPY-DIFFER-COUNT:`.

### CR-PARSE (parse check, function names, and `It` counts)

```powershell
$Files = @( <LIST> )
$ItPatterns = @( <IT-PATTERNS> )   # wildcard patterns matched against each It block's literal name; may be empty
$bad = 0
foreach ($rel in $Files) {
    $tokens = $null; $parseErrors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path -LiteralPath $rel).Path, [ref]$tokens, [ref]$parseErrors)
    $errorCount = @($parseErrors).Count
    $bad += $errorCount
    $functions = @($ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true) | ForEach-Object Name | Sort-Object)
    "PARSE: $rel | errors=$errorCount | functions=$($functions -join ',')"
    $itNames = @($ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.CommandAst] -and $n.GetCommandName() -eq 'It' }, $true) | ForEach-Object {
            $first = @($_.CommandElements | Select-Object -Skip 1 | Where-Object { $_ -is [System.Management.Automation.Language.StringConstantExpressionAst] }) | Select-Object -First 1
            [string]$first.Value
        })
    foreach ($pattern in $ItPatterns) { "IT-COUNT: $rel | $pattern | $(@($itNames | Where-Object { $_ -like $pattern }).Count)" }
}
"PARSE-ERROR-COUNT: $bad"
$code = [int]($bad -gt 0)
"EXIT_CODE_COMPUTED: $code"
exit $code
```

Success-case literals: one `PARSE:` line per file with `errors=0` and a `functions=` list, one `IT-COUNT:` line per file and pattern with a numeric count, `PARSE-ERROR-COUNT: 0`, `EXIT_CODE_COMPUTED: 0`. An `It` declared with `-ForEach` counts once; its expanded rows are counted by CR-PESTER-LIST `NAMED:` lines.

### CR-TEXT (file existence and literal presence or absence)

```powershell
$Checks = @( <CHECKS> )   # each entry: @{ Path = '<path>'; Present = @('<literal>'); Absent = @('<literal>'); Normalize = $false }
$bad = 0
foreach ($check in $Checks) {
    $exists = Test-Path -LiteralPath $check.Path -PathType Leaf
    "TEXT-FILE: $($check.Path) | exists=$exists"
    if (-not $exists) { $bad++; continue }
    $raw = Get-Content -Raw -LiteralPath $check.Path
    $text = if ($check.Normalize) { $raw -replace '\s+', ' ' } else { $raw }
    foreach ($token in @($check.Present | Where-Object { $_ })) { $hit = $text.Contains($token); if (-not $hit) { $bad++ }; "TEXT-PRESENT: $($check.Path) | $token | $hit" }
    foreach ($token in @($check.Absent | Where-Object { $_ })) { $hit = $text.Contains($token); if ($hit) { $bad++ }; "TEXT-ABSENT: $($check.Path) | $token | $(-not $hit)" }
}
"TEXT-CHECK-FAILURES: $bad"
$code = [int]($bad -gt 0)
"EXIT_CODE_COMPUTED: $code"
exit $code
```

Success-case literals: one `TEXT-FILE:` line per check with `exists=True`, one `TEXT-PRESENT:` or `TEXT-ABSENT:` line per literal ending `True`, `TEXT-CHECK-FAILURES: 0`, `EXIT_CODE_COMPUTED: 0`. The comparison is ordinal and case-sensitive.

### CR-JSON (pack-manifest parse and entry presence)

```powershell
$ErrorActionPreference = 'Stop'
$Path = '<MANIFEST>'
$Expect = @( <ENTRIES> )
$manifest = Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json
"JSON-PARSE: ok | paths=$(@($manifest.paths).Count)"
$missing = 0
foreach ($entry in $Expect) { $has = @($manifest.paths) -contains $entry; if (-not $has) { $missing++ }; "JSON-HAS: $entry | $has" }
"JSON-MISSING-COUNT: $missing"
$code = [int]($missing -gt 0)
"EXIT_CODE_COMPUTED: $code"
exit $code
```

Success-case literals: `JSON-PARSE: ok` with a numeric `paths=`, one `JSON-HAS:` line per entry ending `True`, `JSON-MISSING-COUNT: 0`, `EXIT_CODE_COMPUTED: 0`. With `$ErrorActionPreference = 'Stop'`, a missing manifest or a parse failure ends the process with a non-zero exit before `JSON-PARSE:` is printed.

### CR-PY-TOKEN (AC-26 (c); PI-1)

```powershell
$Mode = '<baseline|final>'
$Ref = 'origin/epic/subagentstop-envelope-integration'
$Families = [ordered]@{
    'claude-hooks' = @('.claude/hooks/validate-feature-review-coverage.ps1', '.claude/hooks/validate-feature-review-coverage-metrics.ps1', '.claude/hooks/validate-feature-review-coverage-rules.ps1', '.claude/hooks/feature-review-coverage-thresholds.ps1')
    'codex-hooks'  = @('.codex/hooks/validate-feature-review-coverage.ps1', '.codex/hooks/feature-review-coverage-thresholds.ps1')
}
function Get-PyTokenSum([string[]] $Lines) { $sum = 0; foreach ($line in $Lines) { if ($line -match ':(\d+)$') { $sum += [int]$Matches[1] } }; return $sum }
$worse = 0
foreach ($name in $Families.Keys) {
    $paths = $Families[$name]
    $baseLines = @(git grep -i -c python $Ref -- $paths)
    foreach ($line in $baseLines) { "GREP-BASE: $line" }
    $baseCount = Get-PyTokenSum $baseLines
    if ($Mode -eq 'baseline') { "PY-TOKEN: $name | base=$baseCount"; continue }
    $headLines = @(git grep -i -c python HEAD -- $paths)
    foreach ($line in $headLines) { "GREP-HEAD: $line" }
    $headCount = Get-PyTokenSum $headLines
    $state = if ($headCount -le $baseCount) { 'NOT-INCREASED' } else { 'INCREASED' }
    if ($headCount -gt $baseCount) { $worse++ }
    "PY-TOKEN: $name | base=$baseCount | head=$headCount | $state"
}
"PY-TOKEN-INCREASED-COUNT: $worse"
$code = [int]($worse -gt 0)
"EXIT_CODE_COMPUTED: $code"
exit $code
```

`git grep -c` prints one `<rev>:<path>:<count>` line per file with at least one matching line and exits 1 when no file matches; the body sums the trailing counts and ignores the grep exit code. Success-case literals: baseline mode prints two `PY-TOKEN:` lines with numeric `base=`; final mode prints two lines ending `NOT-INCREASED`, `PY-TOKEN-INCREASED-COUNT: 0`, `EXIT_CODE_COMPUTED: 0`.

### CR-CORPUS (amendment 2026-10-11; corpus false-positive gate; D1-D6)

Always run through the scratchpad route. It reads corpus files only through `git ls-tree` and `git show` at `<CORPUS-SHA>` and reads PR file lists through `gh`. It also reads two working-tree inputs that are not corpus files: it dot-sources the working-tree H1, which dot-sources H2, H3, and H4, so it evaluates the validator as it stands when the run starts; and in final mode it reads `$InitialArtifact` (the P4-T1 artifact) with `Get-Content`. It writes no repository file, and the scratchpad files are the route's own `.ps1` and `.sh` files. It then replaces `Get-ArtifactFileContent` in its own scope with a corpus-existence lookup, so the decision function reads no file.

```powershell
$Mode = '<initial|final>'
$CorpusSha = '<CORPUS-SHA>'                 # 40-hex; the P4-T1 CorpusSha value in both modes
$InitialArtifact = '<INITIAL-ARTIFACT>'     # final mode: repository-relative path of the P4-T1 artifact; initial mode: ''
$Repo = 'drmoisan/drm-copilot'
$EstablishedFolders = 3
$root = (Get-Location).Path
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
. (Join-Path $root '.claude/hooks/validate-feature-review-coverage.ps1')
$ErrorActionPreference = 'Stop'
$script:CorpusExists = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
function Get-ArtifactFileContent { param([string] $Path) if ($script:CorpusExists.Contains(($Path -replace '\\', '/'))) { return @{ Exists = $true; Text = ''; Lines = @() } }; return @{ Exists = $false; Text = $null; Lines = @() } }
$TsRe = '\d{4}-\d{2}-\d{2}T\d{2}-\d{2}'
$LabelMap = @{ 'TypeScript' = @('TypeScript', 'typescript'); 'Python' = @('Python', 'python', 'pytest'); 'PowerShell' = @('PowerShell', 'powershell', 'pester'); 'CSharp' = @('C#', 'CSharp', 'csharp', '.NET', 'dotnet') }
$NarrowRe = '(?i)(informational only|context only|out of plan scope|out of scope|not applicable|\bN/A\b|\bUNVERIFIED\b)'
$CovRe = '(?i)(coverage|lcov|line[s]?\s+hit|pester)'
$VerdictCovRe = '(?i)(coverage|lcov|line[s]?\s+hit|pester|\d+(?:\.\d+)?\s*%)'
function Get-LabelRe([string] $Language) { return '(?i)(' + (($LabelMap[$Language] | ForEach-Object { [regex]::Escape($_) }) -join '|') + ')' }
function Get-TopFolder([string] $Active) { $p = $Active -split '/'; if ($Active.StartsWith('docs/features/active/') -and $p.Count -ge 5) { return $p[3] }; return 'other:' + (($p | Select-Object -SkipLast 1) -join '/') }
function Get-SectionLineSet([string[]] $Lines) {
    $set = [System.Collections.Generic.HashSet[int]]::new(); $inside = $false
    for ($i = 0; $i -lt $Lines.Count; $i++) { if ($Lines[$i] -match '^##\s') { $inside = $Lines[$i] -match '^##\s+Rejected Scope Narrowing\b'; continue }; if ($inside) { [void]$set.Add($i) } }
    return , $set
}
function Get-Rule1Class([string] $Active) {
    $key = 'rule1|' + (($Active -replace '^docs/features/active/[^/]+/', 'docs/features/active/<F>/') -replace '(policy-audit|code-review|feature-audit)', '<stem>' -replace '\d', '9')
    if ($Active -match ('^docs/features/active/[^/]+/audit/' + $TsRe + '/(policy-audit|code-review|feature-audit)\.md$')) { return @{ Class = 'FALSE-POSITIVE'; Basis = 'SANCTIONED-S3'; Key = $key } }
    if ($Active -notmatch $TsRe) { return @{ Class = 'TRUE-POSITIVE'; Basis = 'POLICY-PROHIBITS'; Key = $key } }
    return @{ Class = 'COUNT'; Basis = 'FORM'; Key = $key }
}
function Get-Rule3Class([string[]] $Lines, [string] $Language, [string] $ReasonClass) {
    $labelRe = Get-LabelRe $Language; $section = Get-SectionLineSet $Lines
    if ($ReasonClass -eq 'NARROWING') {
        $open = @(for ($i = 0; $i -lt $Lines.Count; $i++) {
                $l = $Lines[$i]
                if ($l -notmatch $labelRe -or $l -notmatch $CovRe -or $l -notmatch $NarrowRe) { continue }
                if ($section.Contains($i)) { continue }
                if ($Language -eq 'PowerShell' -and $l -match '(?i)\bbranch\b' -and $l -notmatch '(?i)\bline\s+coverage\b') { continue }
                $l
            })
        if ($open.Count -eq 0) { return @{ Class = 'FALSE-POSITIVE'; Basis = 'SANCTIONED-S1-S2'; Key = "rule3|$Language|NARROWING|sanctioned" } }
        return @{ Class = 'TRUE-POSITIVE'; Basis = 'POLICY-PROHIBITS'; Key = "rule3|$Language|NARROWING|" + [regex]::Match($open[0], $NarrowRe).Value.ToLowerInvariant() }
    }
    if ($ReasonClass -eq 'NO-MENTION') { return @{ Class = 'TRUE-POSITIVE'; Basis = 'POLICY-PROHIBITS'; Key = "rule3|$Language|NO-MENTION" } }
    $present = $false
    for ($i = 0; $i -lt $Lines.Count; $i++) { $l = $Lines[$i]; if ($section.Contains($i)) { continue }; if ($l -match $labelRe -and $l -match $VerdictCovRe -and $l -cmatch '\b(PASS|FAIL)\b' -and $l -notmatch $NarrowRe) { $present = $true; break } }
    if (-not $present) { return @{ Class = 'TRUE-POSITIVE'; Basis = 'POLICY-PROHIBITS'; Key = "rule3|$Language|$ReasonClass" } }
    return @{ Class = 'COUNT'; Basis = 'VERDICT-PRESENT'; Key = "rule3|$Language|$ReasonClass" }
}
$rejects = [System.Collections.Generic.List[object]]::new()
$unexpected = [System.Collections.Generic.List[string]]::new()
function Add-CorpusReject([string] $Top, [string] $Rule, [string] $Artifact, [string] $Language, [hashtable] $Class, [string] $Reason) {
    $rejects.Add([pscustomobject]@{ Top = $Top; Rule = $Rule; Artifact = $Artifact; Language = $Language; Class = $Class.Class; Basis = $Class.Basis; Key = $Class.Key; Reason = (($Reason -replace '\s+', ' ').Trim()) })
}
"CORPUS-SHA: $CorpusSha"

# D1: corpus derivation.
$listing = @(git -c core.quotePath=false ls-tree -r --name-only $CorpusSha -- docs)
if ($LASTEXITCODE -ne 0) { throw "git ls-tree failed for $CorpusSha" }
$raw = @($listing | Where-Object { (($_ -split '/')[-1] -match '(policy-audit|code-review|feature-audit)') -and $_.EndsWith('.md') })
$templates = 0; $nonArtifacts = 0
$artifacts = [System.Collections.Generic.List[object]]::new()
foreach ($path in $raw) {
    if ($path.StartsWith('docs/features/templates/')) { $templates++; continue }
    $m = [regex]::Match(($path -split '/')[-1], '^(?<Stem>policy-audit|code-review|feature-audit)(?:\..*)?\.md$')
    if (-not $m.Success) { $nonArtifacts++; continue }
    $active = $path -replace '^docs/features/(?!templates/)[^/]+/', 'docs/features/active/'
    [void]$script:CorpusExists.Add($active)
    $artifacts.Add([pscustomobject]@{ Path = $path; Active = $active; Stem = $m.Groups['Stem'].Value; Top = (Get-TopFolder $active) })
}

# Rule 1 (D2): Get-ReviewArtifactInfo on the active-equivalent path.
$info = @{}
foreach ($a in $artifacts) {
    $i = Get-ReviewArtifactInfo -Path $a.Active -Stem $a.Stem
    if ($null -eq $i) { Add-CorpusReject $a.Top 'rule1' $a.Path '-' (Get-Rule1Class $a.Active) "$($a.Active) is rejected by Get-ReviewArtifactInfo for stem $($a.Stem)"; continue }
    $info[$a.Path] = $i
}

# Rule 2 (D3): same folder and timestamp, through the decision function.
$byFolderStem = @{}
foreach ($a in $artifacts) {
    if (-not $info.ContainsKey($a.Path)) { continue }
    $k = "$($info[$a.Path].Folder)|$($a.Stem)"
    if (-not $byFolderStem.ContainsKey($k)) { $byFolderStem[$k] = [System.Collections.Generic.List[object]]::new() }
    $byFolderStem[$k].Add($info[$a.Path])
}
function Get-Minute([string] $Ts) { $d = [datetime]::MinValue; if ([datetime]::TryParseExact($Ts, "yyyy-MM-dd'T'HH-mm", [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::None, [ref]$d)) { return $d }; return $null }
$triples = 0; $incomplete = 0
foreach ($a in @($artifacts | Where-Object { $_.Stem -eq 'policy-audit' -and $info.ContainsKey($_.Path) } | Sort-Object Path)) {
    $p = $info[$a.Path]; $t0 = Get-Minute $p.Timestamp; $partner = @{}; $delta = @{}
    foreach ($stem in @('code-review', 'feature-audit')) {
        $cands = if ($byFolderStem.ContainsKey("$($p.Folder)|$stem")) { @($byFolderStem["$($p.Folder)|$stem"]) } else { @() }
        $same = @($cands | Where-Object { $_.Timestamp -eq $p.Timestamp })
        if ($same.Count -gt 0) { $partner[$stem] = $same[0]; $delta[$stem] = 0; continue }
        $best = $null; $bestD = [int]::MaxValue
        foreach ($c in @($cands | Sort-Object { $_.Timestamp })) {
            $tc = Get-Minute $c.Timestamp
            if ($null -eq $t0 -or $null -eq $tc) { continue }
            $d = [int][math]::Abs(($tc - $t0).TotalMinutes)
            if ($d -le 120 -and $d -lt $bestD) { $best = $c; $bestD = $d }
        }
        if ($null -ne $best) { $partner[$stem] = $best; $delta[$stem] = $bestD }
    }
    if ($partner.Count -ne 2) { $incomplete++; continue }
    $triples++
    $out = "policy-audit-path: $($p.Path)`ncode-review-path: $($partner['code-review'].Path)`nfeature-audit-path: $($partner['feature-audit'].Path)"
    $decision = Invoke-FeatureReviewCoverageValidation -RawPayload (@{ output = $out } | ConvertTo-Json -Compress)
    if ($decision.Ok) { continue }
    foreach ($line in @((([string]$decision.Message) -split "`r?`n") | Select-Object -Skip 1)) {
        $text = ($line -replace '^\s*-\s*', '').Trim()
        if ($text -match '^(code-review|feature-audit) artifact must share the same feature folder and timestamp') {
            $stem = $Matches[1]; $d = $delta[$stem]
            $bucket = if ($d -le 2) { 'delta-1-2' } elseif ($d -le 10) { 'delta-3-10' } else { 'delta-11-120' }
            Add-CorpusReject $a.Top 'rule2' $a.Path $stem @{ Class = 'COUNT'; Basis = 'FORM'; Key = "rule2|$stem|$bucket" } "$text [partner: $($partner[$stem].Path)]"
        }
        else { $unexpected.Add("rule2 | $($a.Path) | $text") }
    }
}

# Rule 3 (D4, D5): changed-language set, then the coverage-row text rules.
$langOf = @{}
$initialText = @()
if ($Mode -eq 'initial') {
    $prs = @(gh pr list --repo $Repo --state merged --limit 5000 --json number,headRefName | ConvertFrom-Json)
    if ($LASTEXITCODE -ne 0) { throw 'gh pr list failed' }
    $filesOf = @{}
    foreach ($a in @($artifacts | Where-Object Stem -EQ 'policy-audit' | Sort-Object Path)) {
        $prLabel = '-'
        if ($a.Top -notmatch '-(\d+)$') { $value = 'UNDERIVABLE:NO-ISSUE-NUMBER' }
        else {
            $issue = $Matches[1]; $hits = @()
            foreach ($pr in @($prs | Where-Object { $_.headRefName -match ('-' + $issue + '(?:-r\d+)?$') })) {
                if (-not $filesOf.ContainsKey($pr.number)) {
                    $f = @(gh api --paginate "repos/$Repo/pulls/$($pr.number)/files" --jq '.[].filename')
                    if ($LASTEXITCODE -ne 0) { throw "gh api files failed for PR $($pr.number)" }
                    $filesOf[$pr.number] = $f
                }
                if ($filesOf[$pr.number] -contains $a.Active) { $hits += $pr }
            }
            if ($hits.Count -ne 1) { $value = "UNDERIVABLE:PR-MATCHES-$($hits.Count)" }
            else {
                $prLabel = [string]$hits[0].number
                $set = Get-ChangedLanguageSet -Lines @($filesOf[$hits[0].number] | ForEach-Object { "- $_ (+0/-0)" })
                $value = if ($set.Count -eq 0) { 'NONE' } else { @($set.Keys) -join ',' }
            }
        }
        $langOf[$a.Path] = $value
        "CORPUS-LANG: $($a.Path) | PR=$prLabel | $value"
    }
}
else {
    $initialText = @(Get-Content -LiteralPath $InitialArtifact)
    $shaLine = @($initialText | Where-Object { $_ -match '^CORPUS-SHA: ' }) | Select-Object -First 1
    if ($shaLine -ne "CORPUS-SHA: $CorpusSha") { throw "CorpusSha $CorpusSha does not match the initial artifact line '$shaLine'" }
    foreach ($l in $initialText) {
        if ($l -match '^CORPUS-LANG: (?<P>.+?) \| PR=(?<N>\S+) \| (?<V>.+)$') { $langOf[$Matches['P']] = $Matches['V']; "CORPUS-LANG: $($Matches['P']) | PR=$($Matches['N']) | $($Matches['V'])" }
    }
}
$r3Eval = 0; $r3Under = 0; $r3None = 0
foreach ($a in @($artifacts | Where-Object Stem -EQ 'policy-audit' | Sort-Object Path)) {
    $v = $langOf[$a.Path]
    if ($null -eq $v -or $v.StartsWith('UNDERIVABLE')) { $r3Under++; continue }
    if ($v -eq 'NONE') { $r3None++; continue }
    $r3Eval++
    $text = (@(git show "$($CorpusSha):$($a.Path)") -join "`n")
    if ($LASTEXITCODE -ne 0) { throw "git show failed for $($a.Path)" }
    $lines = $text -split "`r?`n"
    foreach ($lang in ($v -split ',')) {
        $r = Test-LanguageCoverageRow -AuditText $text -Language $lang -RepoWidePct $null -BranchPct $null
        if ($r.Ok) { continue }
        $rc = if ($r.Reason -match 'does not mention') { 'NO-MENTION' } elseif ($r.Reason -match 'no coverage-scoped row') { 'NO-COVERAGE-ROW' } elseif ($r.Reason -match 'narrows scope') { 'NARROWING' } elseif ($r.Reason -match 'neither a PASS nor a FAIL') { 'NO-VERDICT' } else { $null }
        if ($null -eq $rc) { $unexpected.Add("rule3 | $($a.Path) | $lang | $($r.Reason)"); continue }
        Add-CorpusReject $a.Top 'rule3' $a.Path $lang (Get-Rule3Class $lines $lang $rc) $r.Reason
    }
}

# D6 step 3: established-convention count over the COUNT-class rejections only.
$foldersByKey = @{}
foreach ($x in @($rejects | Where-Object Class -EQ 'COUNT')) { if (-not $foldersByKey.ContainsKey($x.Key)) { $foldersByKey[$x.Key] = [System.Collections.Generic.HashSet[string]]::new() }; [void]$foldersByKey[$x.Key].Add($x.Top) }
foreach ($x in $rejects) { if ($x.Class -eq 'COUNT') { if ($foldersByKey[$x.Key].Count -ge $EstablishedFolders) { $x.Class = 'FALSE-POSITIVE'; $x.Basis = 'ESTABLISHED' } else { $x.Class = 'TRUE-POSITIVE'; $x.Basis = 'ISOLATED' } } }

$sorted = @($rejects | Sort-Object Top, Rule, Artifact, Language, Key)
foreach ($x in $sorted) { "CORPUS-REJECT: $($x.Top) | $($x.Rule) | $($x.Class) | $($x.Artifact) ; $($x.Language) ; $($x.Basis) ; $($x.Key) ; $($x.Reason)" }
foreach ($g in @($sorted | Group-Object Key | Sort-Object Name)) { "CORPUS-FORM: $($g.Name) | folders=$(@($g.Group.Top | Sort-Object -Unique).Count) | rejections=$($g.Count) | classes=$((@($g.Group.Class | Sort-Object -Unique)) -join ',')" }
foreach ($u in $unexpected) { "CORPUS-UNEXPECTED-ITEM: $u" }
$dropped = 0; $added = 0; $addedUnexplained = 0
if ($Mode -eq 'final') {
    $initTp = [System.Collections.Generic.HashSet[string]]::new(); $initFpTops = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($l in $initialText) {
        if ($l -match '^CORPUS-REJECT: (?<T>.+?) \| (?<R>rule\d) \| (?<C>TRUE-POSITIVE|FALSE-POSITIVE) \| (?<A>.+?) ; (?<L>.+?) ; ') {
            if ($Matches['C'] -eq 'TRUE-POSITIVE') { [void]$initTp.Add("$($Matches['R'])|$($Matches['A'])|$($Matches['L'])") } else { [void]$initFpTops.Add($Matches['T']) }
        }
    }
    $nowTp = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($x in @($sorted | Where-Object Class -EQ 'TRUE-POSITIVE')) { [void]$nowTp.Add("$($x.Rule)|$($x.Artifact)|$($x.Language)") }
    foreach ($id in @($initTp | Sort-Object)) { if (-not $nowTp.Contains($id)) { $dropped++; "CORPUS-TP-DROPPED-ITEM: $id" } }
    $seen = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($x in @($sorted | Where-Object Class -EQ 'TRUE-POSITIVE')) {
        $id = "$($x.Rule)|$($x.Artifact)|$($x.Language)"
        if ($initTp.Contains($id) -or -not $seen.Add($id)) { continue }
        $added++
        if ($initFpTops.Contains($x.Top)) { "CORPUS-TP-ADDED-ITEM: $id | EXPLAINED" } else { $addedUnexplained++; "CORPUS-TP-ADDED-ITEM: $id | UNEXPLAINED" }
    }
    "CORPUS-TP-DROPPED: $dropped"
    "CORPUS-TP-ADDED: $added"
    "CORPUS-TP-ADDED-UNEXPLAINED: $addedUnexplained"
}
$tp = @($rejects | Where-Object Class -EQ 'TRUE-POSITIVE').Count
$fp = @($rejects | Where-Object Class -EQ 'FALSE-POSITIVE').Count
"CORPUS-RAW: $($raw.Count)"
"CORPUS-EXCLUDED-TEMPLATE: $templates"
"CORPUS-EXCLUDED-NON-ARTIFACT: $nonArtifacts"
"CORPUS-ARTIFACTS: $($artifacts.Count)"
"CORPUS-TRIPLES: $triples"
"CORPUS-INCOMPLETE-GROUPS: $incomplete"
"CORPUS-RULE3-EVALUATED: $r3Eval"
"CORPUS-RULE3-UNDERIVABLE: $r3Under"
"CORPUS-RULE3-NO-CHANGED-LANGUAGE: $r3None"
"CORPUS-REJECTED: $($rejects.Count)"
"CORPUS-TRUE-POSITIVE: $tp"
"CORPUS-FALSE-POSITIVE: $fp"
"CORPUS-UNEXPECTED: $($unexpected.Count)"
$code = if ($unexpected.Count -gt 0) { 1 } elseif ($Mode -eq 'final' -and ($fp -gt 0 -or $dropped -gt 0 -or $addedUnexplained -gt 0)) { 1 } else { 0 }
"EXIT_CODE_COMPUTED: $code"
exit $code
```

Output lines. Both modes print, in this order:
- `CORPUS-SHA:`;
- one `CORPUS-LANG: <policy-audit path> | PR=<number or -> | <languages, NONE, or UNDERIVABLE:<reason>>` line per policy-audit artifact;
- one `CORPUS-REJECT: <folder> | <rule> | <classification> | <artifact path> ; <language for rule3, partner stem for rule2, - for rule1> ; <basis> ; <form key> ; <validator reason>` line per rejection (for a rule2 rejection the reason ends ` [partner: <active-equivalent path of the recorded partner for that stem>]`, which P4-T4 reads);
- one `CORPUS-FORM:` line per form key;
- any `CORPUS-UNEXPECTED-ITEM:` lines;
- in final mode only, the `CORPUS-TP-*` lines;
- the thirteen summary lines from `CORPUS-RAW:` through `CORPUS-UNEXPECTED:`;
- `EXIT_CODE_COMPUTED:`.

Initial mode computes exit code 1 only when `CORPUS-UNEXPECTED:` is non-zero; a non-zero false-positive count in initial mode is a finding, not a run failure. Final mode also computes 1 when `CORPUS-FALSE-POSITIVE:`, `CORPUS-TP-DROPPED:`, or `CORPUS-TP-ADDED-UNEXPLAINED:` is non-zero.

Success-output observation for CR-CORPUS. No Phase 0 run exists, because the validator CR-CORPUS evaluates is the post-Phase-3 validator. CR-CORPUS's success-case output is observed by P4-T2 for the initial-mode literals and by P4-T3 for the final-mode literals. Both print every summary line unconditionally with a numeric value. If any literal named in those tasks is absent from a run that exits 0, record the observed output and stop with BLOCKED.

### CR-EXEMPLAR (v1.8; rule3 exemplar selection and representativeness guard; read-only)

Always run through the scratchpad route, once per rule3 `## FIX-<j>` section, before step (a) of that `j`. It reads corpus files only through `git show <CORPUS-SHA>:<path>`. It reads the candidate list from `$InitialArtifact` (the P4-T1 artifact) with `Get-Content`. It reads the denied-token patterns by parsing `.claude/hooks/check-powershell-test-purity.ps1` (the `Pattern` values of the `$forbiddenPatterns` hashtables), so they are applied by reference and not copied. It loads `Test-LanguageCoverageRow` from `git show HEAD:.claude/hooks/validate-feature-review-coverage-rules.ps1`, not from the working tree. HEAD holds no Phase 4 rule fix until P4-T10 commits, so the guard observes the unchanged rule even after earlier `j` values have edited the working-tree H3. It writes no repository file.

```powershell
$CorpusSha = '<CORPUS-SHA>'                 # the P4-T1 CorpusSha value
$InitialArtifact = '<INITIAL-ARTIFACT>'     # repository-relative path of the P4-T1 artifact
$FormKey = '<FORM-KEY>'                     # the FormKey of the rule3 FIX section
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = 'Stop'
$LabelMap = @{ 'TypeScript' = @('TypeScript', 'typescript'); 'Python' = @('Python', 'python', 'pytest'); 'PowerShell' = @('PowerShell', 'powershell', 'pester'); 'CSharp' = @('C#', 'CSharp', 'csharp', '.NET', 'dotnet') }
$CovRe = '(?i)(coverage|lcov|line[s]?\s+hit|pester)'
$Fragments = @{ 'NARROWING' = 'narrows scope'; 'NO-COVERAGE-ROW' = 'no coverage-scoped row'; 'NO-VERDICT' = 'neither a PASS nor a FAIL' }
$TempLiterals = @('New-TemporaryFile', 'GetTempFileName', 'TestDrive', '$env:TEMP')
$Ascii = @{ 0x2010 = '-'; 0x2011 = '-'; 0x2012 = '-'; 0x2013 = '-'; 0x2014 = '-'; 0x2212 = '-'; 0x2018 = "'"; 0x2019 = "'"; 0x201C = '"'; 0x201D = '"'; 0x2026 = '...'; 0x00A0 = ' '; 0x2190 = '<-'; 0x2192 = '->'; 0x2264 = '<='; 0x2265 = '>='; 0x00D7 = 'x' }
$parts = $FormKey -split '\|'
if ($parts.Count -lt 3 -or $parts[0] -ne 'rule3' -or -not $LabelMap.ContainsKey($parts[1]) -or -not $Fragments.ContainsKey($parts[2])) { throw "not a rule3 form key: $FormKey" }
$Language = $parts[1]; $ReasonClass = $parts[2]; $Fragment = $Fragments[$ReasonClass]
$LabelRe = '(?i)(' + (($LabelMap[$Language] | ForEach-Object { [regex]::Escape($_) }) -join '|') + ')'
$tk = $null; $pe = $null
$purityAst = [System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path -LiteralPath '.claude/hooks/check-powershell-test-purity.ps1').Path, [ref]$tk, [ref]$pe)
$assign = $purityAst.Find({ param($n) $n -is [System.Management.Automation.Language.AssignmentStatementAst] -and $n.Left.Extent.Text -eq '$forbiddenPatterns' }, $true)
$Purity = @($assign.Right.FindAll({ param($n) $n -is [System.Management.Automation.Language.HashtableAst] }, $true) | ForEach-Object { foreach ($kv in $_.KeyValuePairs) { if ($kv.Item1.Extent.Text -eq 'Pattern') { $kv.Item2.GetPureExpression().SafeGetValue() } } })
if ($Purity.Count -eq 0) { throw 'no purity patterns read' }
"PURITY-PATTERNS: $($Purity.Count)"
$h3Text = (@(git show 'HEAD:.claude/hooks/validate-feature-review-coverage-rules.ps1') -join "`n")
if ($LASTEXITCODE -ne 0) { throw 'git show HEAD rules file failed' }
. ([scriptblock]::Create($h3Text))
$cands = [System.Collections.Generic.List[string]]::new()
foreach ($l in @(Get-Content -LiteralPath $InitialArtifact)) {
    if ($l -match '^CORPUS-REJECT: .+? \| rule3 \| (?:TRUE-POSITIVE|FALSE-POSITIVE) \| (?<A>.+?) ; (?<L>.+?) ; (?<B>.+?) ; (?<K>.+?) ; ' -and $Matches['K'] -eq $FormKey -and -not $cands.Contains($Matches['A'])) { $cands.Add($Matches['A']) }
}
"EXEMPLAR-CANDIDATES: $FormKey | $($cands.Count)"
function Get-FullSet([string[]] $Lines) { foreach ($x in $Lines) { if ($x -match $LabelRe -or $x -match '^##\s') { $x.TrimEnd() } } }
function Get-ReducedSet([string[]] $Lines) {
    $keep = [System.Collections.Generic.SortedSet[int]]::new(); $heading = -1
    for ($i = 0; $i -lt $Lines.Count; $i++) {
        if ($Lines[$i] -match '^##\s') { $heading = $i }
        $hit = $Lines[$i] -match $LabelRe -and ($ReasonClass -eq 'NO-COVERAGE-ROW' -or $Lines[$i] -match $CovRe)
        if ($hit) { [void]$keep.Add($i); if ($heading -ge 0) { [void]$keep.Add($heading) } }
    }
    foreach ($i in $keep) {
        $sb = [System.Text.StringBuilder]::new()
        foreach ($ch in $Lines[$i].ToCharArray()) { $c = [int]$ch; if ($c -lt 128) { [void]$sb.Append($ch) } elseif ($Ascii.ContainsKey($c)) { [void]$sb.Append($Ascii[$c]) } else { [void]$sb.Append('?') } }
        $sb.ToString().TrimEnd()
    }
}
function Get-QualifyFailures([string[]] $Set) {
    $fails = @()
    if (@($Set | Where-Object { $_ -match '[^\x00-\x7F]' }).Count -gt 0) { $fails += 'non-ascii' }
    foreach ($p in $Purity) { if (@($Set | Where-Object { $_ -match $p }).Count -gt 0) { $fails += 'purity'; break } }
    foreach ($t in $TempLiterals) { if (@($Set | Where-Object { $_.Contains($t) }).Count -gt 0) { $fails += 'temp-literal'; break } }
    if (@($Set | Where-Object { $_.StartsWith("'@") }).Count -gt 0) { $fails += 'here-string-terminator' }
    if (@($Set).Count -gt 40) { $fails += "lines=$(@($Set).Count)" }
    return $fails
}
$texts = @{}
foreach ($a in $cands) {
    $t = @(git show "$($CorpusSha):$a")
    if ($LASTEXITCODE -ne 0) { throw "git show failed for $a" }
    $texts[$a] = (($t -join "`n") -split "`r?`n")
}
$selected = $null
foreach ($form in @('FULL', 'REDUCED')) {
    foreach ($a in $cands) {
        $set = @(if ($form -eq 'FULL') { Get-FullSet $texts[$a] } else { Get-ReducedSet $texts[$a] })
        $fails = @(Get-QualifyFailures $set)
        $reason = ''
        if ($fails.Count -eq 0) { $r = Test-LanguageCoverageRow -AuditText ($set -join "`n") -Language $Language -RepoWidePct $null -BranchPct $null; if (-not $r.Ok) { $reason = [string]$r.Reason } }
        $guard = if ($fails.Count -gt 0) { 'NOT-EVALUATED' } elseif ($reason.Contains($Fragment)) { 'REPRODUCED' } else { 'NOT-REPRODUCED' }
        $state = if ($fails.Count -gt 0) { $fails -join ',' } else { 'QUALIFIES' }
        "EXEMPLAR-CANDIDATE: $FormKey | $form | $a | lines=$($set.Count) | $state | guard=$guard"
        if ($guard -eq 'NOT-REPRODUCED') { "EXEMPLAR-GUARD: $FormKey | $form | $a | HEAD Test-LanguageCoverageRow | NOT-REPRODUCED | $Fragment | $(($reason -replace '\s+', ' ').Trim())" }
        if ($guard -eq 'REPRODUCED') {
            "EXEMPLAR-GUARD: $FormKey | $form | $a | HEAD Test-LanguageCoverageRow | REPRODUCED | $Fragment | $(($reason -replace '\s+', ' ').Trim())"
            $selected = @{ Form = $form; Path = $a; Set = $set }
            break
        }
    }
    if ($null -ne $selected) { break }
}
if ($null -eq $selected) { "EXEMPLAR: $FormKey | NONE"; $code = 1 }
else {
    "EXEMPLAR: $FormKey | ExemplarForm=$($selected.Form) | $($selected.Path) | lines=$($selected.Set.Count)"
    foreach ($line in $selected.Set) { "EXEMPLAR-LINE: $line" }
    $code = 0
}
"EXIT_CODE_COMPUTED: $code"
exit $code
```

Derivations, stated once so that a third party re-running CR-EXEMPLAR with the same `$CorpusSha`, `$InitialArtifact`, and `$FormKey` obtains the same selection:
- Candidates: the distinct artifact paths of the `$InitialArtifact` `CORPUS-REJECT:` lines whose rule is `rule3` and whose form-key field equals `$FormKey`, in file order (the P4-T2 output order).
- FULL line set (the v1.5 definition): the lines of `git show <CorpusSha>:<candidate>` that match the language label pattern (`$LabelRe`, the CR-CORPUS `Get-LabelRe` value) or `^##\s`, in file order, trailing whitespace trimmed. No character is replaced.
- REDUCED line set. Key lines are selected by reason class. For `NARROWING` and `NO-VERDICT`, a key line matches `$LabelRe` and `$CovRe`, which are the `$coverageLines` filter of `Test-LanguageCoverageRow`, H3 lines 120 and 129. For `NO-COVERAGE-ROW`, a key line matches `$LabelRe`, the `$languageLines` filter of H3 line 120. Each key line's section heading is also kept: the nearest line at or before it that matches `^##\s`. Lines are emitted in file order without duplicates. In each emitted line, every UTF-16 code unit at or above 128 is replaced through the fixed `$Ascii` table below, and trailing whitespace is trimmed after the replacement:
  - U+2010, U+2011, U+2012, U+2013, U+2014, U+2212 become `-`;
  - U+2018, U+2019 become `'`, and U+201C, U+201D become `"`;
  - U+2026 becomes `...`, and U+00A0 becomes a space;
  - U+2190 becomes `<-`, U+2192 becomes `->`, U+2264 becomes `<=`, U+2265 becomes `>=`, and U+00D7 becomes `x`;
  - any other unit becomes `?`, so a surrogate pair becomes `??`.
- Why REDUCED stays representative. Every key line is kept with its own section heading, so it falls in the same section in the reduced set as in the artifact. The reduced set therefore keeps every line that the function's narrowing and verdict checks read, and keeps each line's membership in a `## Rejected Scope Narrowing` section, which is the S2 condition. The replacement table maps no character to a narrowing phrase, a label, or a coverage term, so it cannot create a match. A substitution that removed a match would show up as a failed guard, not as a passing exemplar.
- Qualification (both forms, after replacement): no non-ASCII character; no line matches any purity pattern; no line contains any of the four P12-T7 literals; no line starts with `'@`; at most 40 lines.
- Guard (both forms): `Test-LanguageCoverageRow -AuditText <set joined by LF> -Language <language> -RepoWidePct $null -BranchPct $null`, loaded from HEAD, returns `Ok` false with a `Reason` containing the form key's original fragment (`narrows scope` for `NARROWING`, `no coverage-scoped row` for `NO-COVERAGE-ROW`, `neither a PASS nor a FAIL` for `NO-VERDICT`).
- Selection: the first candidate in candidate order whose FULL set qualifies and reproduces. When there is none, the first candidate in candidate order whose REDUCED set qualifies and reproduces. When there is none, `EXEMPLAR: <form key> | NONE` and exit 1.

Success-case literals: `PURITY-PATTERNS:` with a value greater than 0 (17 in the current tree; lines 103-119 of the hook file); `EXEMPLAR-CANDIDATES:` with a value greater than 0; one `EXEMPLAR-CANDIDATE:` line per evaluated candidate and form; exactly one `EXEMPLAR-GUARD:` line ending `| REPRODUCED | <fragment> | <reason>`; exactly one `EXEMPLAR: <form key> | ExemplarForm=<FULL or REDUCED> | <path> | lines=<n>` line; `<n>` `EXEMPLAR-LINE:` lines; `EXIT_CODE_COMPUTED: 0`. Success-output observation: no Phase 0 run exists, because CR-EXEMPLAR reads the P4-T1 artifact and the post-Phase-3 HEAD rules file. Its first P4-T4 run is the observation run. In the restart after the 2026-10-12 BLOCKED record, that is FIX-2 (`rule3|PowerShell|NARROWING|sanctioned`), whose FULL candidate `docs/features/completed/2026-06-16-propagate-claude-ecosystem-hardening-187/policy-audit.2026-06-16T16-45.md` was recorded as qualifying (37 lines) in the BLOCKED artifact. If a run that exits 0 lacks any literal named here, record the observed output and stop with BLOCKED.

## Guarded Dot-Source Literals

Each line below is added verbatim (one statement per line) and asserted by the static tests and by guard-completeness rule S2 (`HookGuardShape.Helpers.ps1:101-105`):

- H1, after the existing thresholds line 47: `try { . (Join-Path $PSScriptRoot 'validate-feature-review-coverage-metrics.ps1') } catch { Add-HookDependencyFailure -Name 'validate-feature-review-coverage-metrics.ps1' -ErrorRecord $_ }`
- H1, next line: `try { . (Join-Path $PSScriptRoot 'validate-feature-review-coverage-rules.ps1') } catch { Add-HookDependencyFailure -Name 'validate-feature-review-coverage-rules.ps1' -ErrorRecord $_ }`
- H1, next line (Phase 5): `try { . (Join-Path $PSScriptRoot 'subagentstop-envelope.ps1') } catch { Add-HookDependencyFailure -Name 'subagentstop-envelope.ps1' -ErrorRecord $_ }`
- H5, after the guard bootstrap at line 43: `try { . (Join-Path $PSScriptRoot 'feature-review-coverage-thresholds.ps1') } catch { Add-HookDependencyFailure -Name 'feature-review-coverage-thresholds.ps1' -ErrorRecord $_ }`

The thresholds dot-source stays the first edge after the guard bootstrap in H1, because `hook-dependency-failure.SpecialCases.Tests.ps1:27-33` selects the first non-guard edge by line.

## Help-Text Tokens (asserted by E4-ST3)

Both the H1 comment-based help and the H5 comment-based help contain the sentences "an absent root CLAUDE.md uses the defaults" and "an unreadable root CLAUDE.md fails closed" (each may wrap; E4-ST3 compares whitespace-normalized text). The H1 help keeps the phrase "falls back independently".

### Phase 0 — Policy Reads, Upstream-Merge Check, and Baseline Capture

- [x] [P0-T1] Read, in this order, `CLAUDE.md`, `.github/copilot-instructions.md`, `.github/instructions/tonality.instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`, `.claude/rules/python.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md`, `.claude/rules/plan-acceptance-gates.md`, `.claude/skills/atomic-plan-contract/SKILL.md`, `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`, `.claude/skills/acceptance-criteria-tracking/SKILL.md`; write `<FEATURE>/evidence/baseline/phase0-instructions-read.<ts>.md` with `Timestamp:`, `Policy Order:`, and the list of the 19 files read. Acceptance: the artifact lists all 19 paths in this order.
- [x] [P0-T2] UPSTREAM-MERGE CHECK, step 1 (first gating task; AC-1). Run `git fetch origin epic/subagentstop-envelope-integration` and `git rev-parse origin/epic/subagentstop-envelope-integration`; create `<FEATURE>/evidence/other/upstream-merge-check.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Base: <40-hex SHA>`, `StartHead:` from `git rev-parse HEAD`, `LocalBranch:` from `git rev-parse --abbrev-ref HEAD`, and `Branch:` from `git rev-parse --abbrev-ref --symbolic-full-name "@{u}"` with the leading `origin/` removed (the local branch can be an alias such as `exec-896-local` whose upstream is `origin/bug/subagentstop-envelope-feature-review-coverage-exec-896`; when the upstream command exits non-zero or its output does not begin with `origin/`, record `Branch: NO-ORIGIN-UPSTREAM`). Acceptance: `Base:` holds a 40-character hexadecimal SHA, `LocalBranch:` is present with the command output, and `Branch:` matches `^bug/subagentstop-envelope-feature-review-coverage(-exec)?-896$`; any other `Branch:` value is a failing field for P0-T8. `LocalBranch:` is informational and is not pattern-checked. The recorded `Branch:` value is `<BRANCH>` for every later push (`git push origin HEAD:<BRANCH>`), fetch, and remote rev-parse in this plan.
- [x] [P0-T3] UPSTREAM-MERGE CHECK, step 2 (E1 merged). The lookup does not filter on a head-branch name, because epic children have merged from `-exec-` branches (for example PR #881 and PR #863), E1's preparation documents entered by direct merge `cf3108b04`, and #897 is shared with E3. Run `gh pr list --repo drmoisan/drm-copilot --state merged --base epic/subagentstop-envelope-integration --limit 300 --json number,headRefName,mergeCommit,mergedAt` and append its output and exit code to the P0-T2 artifact. Candidates are the listed PRs whose `headRefName` matches `^bug/subagentstop-envelope-core(-exec)?-897$`; append them as `E1Candidates:` (number, `headRefName`, `mergeCommit.oid`, `mergedAt` per candidate, or `NONE`). PR route: when at least one candidate exists, select the candidate with the greatest `mergedAt`, run `git merge-base --is-ancestor <its mergeCommit.oid> origin/epic/subagentstop-envelope-integration`, and append `E1MergeCommit: <that oid>`, `E1MergeRoute: pr`, and the ancestry exit code. Direct-merge route: when `E1Candidates: NONE`, run `git log --first-parent --merges --reverse --format=%H ac525c4ef..origin/epic/subagentstop-envelope-integration` (oldest first, limited to merges after the epic start commit `ac525c4ef`), then run `git cat-file -e <sha>:.claude/hooks/subagentstop-envelope.ps1` for each printed SHA in printed order, stopping at the first that exits 0; append each SHA tried with its exit code, then `E1MergeCommit: <that sha>` and `E1MergeRoute: direct-merge`, then run `git merge-base --is-ancestor <that sha> origin/epic/subagentstop-envelope-integration` and append its exit code; when no SHA exits 0, append `E1MergeCommit: NONE` and `E1MergeRoute: NONE`. Append `E1Merged: yes|no`. Acceptance: `E1Merged: yes` only when exactly one commit is recorded in `E1MergeCommit:` and its ancestry check exits 0; otherwise `E1Merged: no`.
- [x] [P0-T4] UPSTREAM-MERGE CHECK, step 3 (helper at base). Run `git cat-file -e origin/epic/subagentstop-envelope-integration:.claude/hooks/subagentstop-envelope.ps1`, `git cat-file -e origin/epic/subagentstop-envelope-integration:extensions/drm-copilot/resources/claude-customizations/.claude/hooks/subagentstop-envelope.ps1`, and `git grep -n -F -e "function Read-SubagentStopEnvelope" -e "function Get-SubagentStopEnvelopeAnomalyReason" -e "function Exit-SubagentStopBlock" origin/epic/subagentstop-envelope-integration -- .claude/hooks/subagentstop-envelope.ps1`; append the outputs to the P0-T2 artifact with `HelperPresent: yes|no`, `HelperMirrorPresent: yes|no`, `HelperFunctions: <count>`. The three searched literals are "function Read-SubagentStopEnvelope", "function Get-SubagentStopEnvelopeAnomalyReason", and "function Exit-SubagentStopBlock". Acceptance: both `cat-file` commands exit 0 and the grep prints exactly three lines, one per literal; otherwise the corresponding field is `no` or the count is not 3.
- [x] [P0-T5] UPSTREAM-MERGE CHECK, step 4 (stdin and stderr mechanisms). Run `git grep -n -F -e "Console]::In" origin/epic/subagentstop-envelope-integration -- .claude/hooks/subagentstop-envelope.ps1` and `git grep -n -F -e "Console]::Error" origin/epic/subagentstop-envelope-integration -- .claude/hooks/subagentstop-envelope.ps1`; append both outputs to the P0-T2 artifact with `StdinRedirectable: yes|no` and `StderrRedirectable: yes|no`. The searched literals are "Console]::In" and "Console]::Error" (each matches both the `[Console]` and the `[System.Console]` spelling). Acceptance: each field is `yes` only when its grep prints at least one line, because the E4 harness supplies stdin through `[System.Console]::SetIn` and reads stderr through `[System.Console]::SetError`.
- [x] [P0-T6] UPSTREAM-MERGE CHECK, step 5 (E1 merged spec, item-by-item comparison). Locate E1's spec with `git ls-tree -r --name-only origin/epic/subagentstop-envelope-integration -- docs/features` filtered to paths ending `subagentstop-envelope-core-897/spec.md`, read it with `git show origin/epic/subagentstop-envelope-integration:<that path>`, and append to the P0-T2 artifact: `E1SpecPath:`; a comparison table with one row per item of the contract recorded in `<FEATURE>/spec.md` Proposed Fix item 1, each marked `match` or `diverges` and cited to an E1 spec line: I1 `Read-SubagentStopEnvelope [-InputText <string>]` signature with `-InputText` optional; I2 never throws; I3 returned properties `IsValid`, `Anomaly`, `Envelope`, `AssistantText`, `StopHookActive`, `AgentType`, `HookEventName`; I4 reads stdin when `-InputText` is not supplied; I5 `Get-SubagentStopEnvelopeAnomalyReason` returns the clause for the `Anomaly` of an invalid envelope; I6 `Exit-SubagentStopBlock -Message <text>` writes to stderr and exits 2; I7 through I12 consumer rules 1 through 6 as worded in Proposed Fix item 1; I13 standard report-and-halt phrase. I13 is `match` when E1's spec defines no standard phrase, or defines one that contains `cannot repair this condition`; otherwise `diverges`. Then append the recorded fields: `ValidityProperty:`, `AnomalyProperty:`, `AssistantTextProperty:`, `StopHookActiveProperty:` (each the property name E1's spec gives); `AnomalyReasonFunction:` (its parameter list as E1's spec states it); `AnomalyReasonCall:` (derived mechanically: when the function's single parameter, as E1's spec states it, takes the anomaly code, `Get-SubagentStopEnvelopeAnomalyReason -<ParameterName> $envelope.Anomaly`; when it takes the result object, `Get-SubagentStopEnvelopeAnomalyReason -<ParameterName> $envelope`; any other signature is recorded `UNDERIVABLE`); `ConsumerPolicy:` (rules 1 through 6 quoted from E1's spec); `ReportAndHaltPhrase:` (the phrase E1's spec defines, or `NONE DEFINED`); `AnomalyNames:` (every anomaly value E1's spec defines); `RequiredEnvelopeFields:` (the envelope fields E1's spec requires for `IsValid = $true`). Acceptance: the table has 13 rows each marked `match` or `diverges` with an E1 spec line cited, and every recorded field is present with a value (`UNDEFINED` when E1's spec does not define it).
- [x] [P0-T7] UPSTREAM-MERGE CHECK, step 6 (spec drift since reconciliation). Run `git cat-file -t cc3285559`; when it prints `commit`, run `git diff cc3285559 origin/epic/subagentstop-envelope-integration -- docs/features/active/subagentstop-envelope-core-897/spec.md` and append its output under `E1SpecDiffFromReconciledHead:`; otherwise append `E1SpecDiffFromReconciledHead: cc3285559 unreachable` with the `cat-file` output. Acceptance: the field is present with either the diff output (possibly empty) or the unreachable statement.
- [x] [P0-T8] UPSTREAM-MERGE CHECK, verdict. Append `Verdict: PROCEED` to the P0-T2 artifact only when all hold: `Branch:` matches the P0-T2 pattern; `E1Merged: yes`; `HelperPresent: yes`; `HelperMirrorPresent: yes`; `HelperFunctions: 3`; `StdinRedirectable: yes`; `StderrRedirectable: yes`; all 13 comparison rows `match`; `ValidityProperty: IsValid`, `AnomalyProperty: Anomaly`, `AssistantTextProperty: AssistantText`, `StopHookActiveProperty: StopHookActive`; `AnomalyReasonCall:` is not `UNDERIVABLE` or `UNDEFINED`; `AnomalyNames:` includes `EmptyPayload` and `UnparseableJson`; every `RequiredEnvelopeFields:` entry is one of `session_id`, `hook_event_name`, `agent_type`, `stop_hook_active`, `last_assistant_message` (the fields every E4 test envelope carries); `ReportAndHaltPhrase:` is `NONE DEFINED` or contains `cannot repair this condition` (AC-30 asserts that text). Otherwise append `Verdict: STOP` followed by `FailingFields:` naming each failing field. When `Branch:` is among the failing fields, halt with BLOCKED without committing or pushing (the checked-out branch does not track this feature's remote branch). Otherwise run `git add <FEATURE>/evidence <FEATURE>/plan.2026-10-11T07-58.md`, `git commit -m "docs(896): record upstream-merge check STOP"`, `git push origin HEAD:<BRANCH>`, and halt execution with BLOCKED; no production or test file is changed. Acceptance: the artifact contains exactly one `Verdict:` line; on STOP with a passing `Branch:`, `git status --porcelain` prints nothing after the push and, after `git fetch origin <BRANCH>`, `git rev-parse HEAD` equals `git rev-parse origin/<BRANCH>`; on STOP with a failing `Branch:`, no commit is created (`git rev-parse HEAD` equals the P0-T2 `StartHead:` value).
- [x] [P0-T9] Merge the integration ref (only after `Verdict: PROCEED`). Run `git merge --no-edit origin/epic/subagentstop-envelope-integration`. On a clean merge run `git merge-base --is-ancestor origin/epic/subagentstop-envelope-integration HEAD`, then CR-TEXT with `<CHECKS>` = `@{ Path = '.claude/hooks/subagentstop-envelope.ps1'; Present = @('function Read-SubagentStopEnvelope', 'function Get-SubagentStopEnvelopeAnomalyReason', 'function Exit-SubagentStopBlock') }`, and append the outputs to the P0-T2 artifact with `MergeOutcome: CLEAN` and `MergedHead: <sha>`. On a merge conflict run `git merge --abort`, append `MergeOutcome: CONFLICT` with the conflicting paths (no second `Verdict:` line), run `git add <FEATURE>/evidence <FEATURE>/plan.2026-10-11T07-58.md`, `git commit -m "docs(896): record upstream merge conflict"`, `git push origin HEAD:<BRANCH>`, and halt with BLOCKED. Acceptance: on `MergeOutcome: CLEAN`, the ancestry check exits 0 and CR-TEXT prints `TEXT-CHECK-FAILURES: 0`; on `MergeOutcome: CONFLICT`, `git status --porcelain` prints nothing after the push and, after `git fetch origin <BRANCH>`, `git rev-parse HEAD` equals `git rev-parse origin/<BRANCH>`.
- [x] [P0-T10] Record whether the E1 merge changed any file this plan edits: run `git diff --name-only ac525c4ef origin/epic/subagentstop-envelope-integration -- .claude/hooks/validate-feature-review-coverage.ps1 .claude/hooks/feature-review-coverage-thresholds.ps1 .codex/hooks/validate-feature-review-coverage.ps1 tests/scripts/claude-hooks tests/scripts/codex-hooks tests/scripts/claude-runtime tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py .agents/skills/feature-review-workflow .github/skills/feature-review-workflow .codex/agents/feature-review.toml extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` together with `git status --porcelain`; append to the P0-T2 artifact as `AnchorDrift: NONE` or the listed paths (PI-6), leaving the plan-file status line out of `AnchorDrift:` (plan-file staging rule). Acceptance: the field is present and matches the diff output.
- [x] [P0-T11] Baseline line counts: run CR-LINES with `<LIST>` = LIST-PROD-BASE plus LIST-TEST-BASE plus `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`; write `<FEATURE>/evidence/baseline/file-size.<ts>.md`. Acceptance: one `LINES:` line per file with numeric `count=`, `LINES-OVER-CAP: 0`, and `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` at `count=497`.
- [x] [P0-T12] Baseline targeted Pester: run CR-PESTER-LIST with `<LIST>` = LIST-CLAUDE-SUITES, T6, T9, `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1`, `tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1`, LIST-AUX; `<TAGS-IN>` empty; `<TAGS-OUT>` = `E4-Regression` (no test carries it yet; the run observes the filter code path); `<PATTERNS>` = `T824-*`, `F824-*`, `TG*`, and the four GUARD-PATTERNS; write `<FEATURE>/evidence/baseline/pester-targeted.<ts>.md` with every `SUITE:` and `NAMED:` line copied. Acceptance: the artifact records the `TOTAL:` line and `EXIT_CODE_COMPUTED:`; the `S1`, `S2`, and `S6` GUARD-PATTERN lines each show `Passed=2 | Failed=0` (the base hook already satisfies S1, S2, and S6); the `NAMED: N1:*` line shows `Passed=2 | Failed=0` and the artifact records `N1-BASELINE: PASSING`, or, when it does not, the artifact records `N1-BASELINE: FAILING` with each N1 `FAILED:` line verbatim (the N1 rule under GUARD-PATTERNS then governs later N1 acceptances); every `FAILED:` line is listed as `PRE-EXISTING:` for the PEF rule and for comparison in P11-T6.
- [x] [P0-T13] Baseline full-population run: run CR-POSHQC-FULL through the scratchpad route, then CR-JUNIT; write `<FEATURE>/evidence/baseline/pester-full-run.<ts>.md` with the `Tests Passed:` line, the `Covered` line, and the `JUNIT:` line verbatim. Acceptance: all three literals are present; each `JUNIT-FAILED:` line is listed as `PRE-EXISTING:`.
- [x] [P0-T14] Baseline per-file coverage (AC-25 baseline half), immediately after P0-T13 with no Pester run in between: run CR-COV-FILES with `<LIST>` = LIST-PROD-BASE; write `<FEATURE>/evidence/baseline/pester-coverage.<ts>.md` with `Output Summary:` stating the three numeric `pct=` values; then run CR-COV-CHANGED with the same list (observation run; the branch has no change yet) and append its output. Acceptance: three `COVERAGE:` lines with numeric `covered=`, `missed=`, `pct=` values and no `ABSENT` line; three `CHANGED-COVERAGE:` lines with `changed=0` and `CHANGED-BELOW-85: NONE`.
- [x] [P0-T15] Baseline format check: run CR-FORMAT-CHECK with `<LIST>` = LIST-PROD-BASE plus LIST-TEST-BASE; write `<FEATURE>/evidence/baseline/format-check.<ts>.md`; then run CR-FORMAT-APPLY with `<LIST>` = exactly the files that CR-FORMAT-CHECK reported `FORMAT-CLEAN:` (observation run) and record `git status --porcelain` before and after it. Acceptance: one check line per file and a numeric `FORMAT-DRIFT-COUNT:` (any `FORMAT-DRIFT:` file is recorded as pre-existing drift); the apply run prints one `FORMAT-UNCHANGED:` line per listed file and `FORMAT-APPLIED-COUNT: 0`, and the two status outputs are identical.
- [x] [P0-T16] Baseline PSScriptAnalyzer: run CR-PSSA with `<LIST>` = LIST-PROD-BASE plus LIST-TEST-BASE; write `<FEATURE>/evidence/baseline/pssa.<ts>.md`. Acceptance: one `PSSA:` line per file and a numeric `PSSA-TOTAL:`.
- [x] [P0-T17] Baseline Python contract tests: run PYTEST-SPEC; write `<FEATURE>/evidence/baseline/pytest-contracts.<ts>.md` with the final pytest summary line. Acceptance: the summary line carries numeric `passed` and `failed` counts (a missing `failed` word means 0 failed).
- [x] [P0-T18] Baseline auxiliary Python contract test: run `poetry run pytest tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py`; write `<FEATURE>/evidence/baseline/pytest-ci-gate-contracts.<ts>.md`. Acceptance: the summary line is recorded with numeric counts.
- [x] [P0-T19] Baseline Black check (read-only): run `poetry run black --check tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`; write `<FEATURE>/evidence/baseline/python-black-check.<ts>.md`. Acceptance: the artifact records the output line containing `would be left unchanged` or `would reformat`.
- [x] [P0-T20] Baseline Ruff: run `poetry run ruff check tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`; write `<FEATURE>/evidence/baseline/python-ruff.<ts>.md`. Acceptance: the artifact records `All checks passed!` or the listed findings.
- [x] [P0-T21] Baseline Pyright: run `poetry run pyright tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`; write `<FEATURE>/evidence/baseline/python-pyright.<ts>.md`. Acceptance: the artifact records the summary line with numeric error, warning, and information counts.
- [x] [P0-T22] Baseline Python-token counts (AC-26 (c)): run CR-PY-TOKEN with `$Mode = 'baseline'`, then with `$Mode = 'final'` (observation run; HEAD equals the merged base); write `<FEATURE>/evidence/baseline/python-token-count.<ts>.md`. Acceptance: the baseline run prints two `PY-TOKEN:` lines with numeric `base=` (expected `claude-hooks | base=5` and `codex-hooks | base=5` when P0-T10 recorded `AnchorDrift: NONE`; otherwise the observed values are recorded); the final-mode run prints two lines ending `NOT-INCREASED` and `PY-TOKEN-INCREASED-COUNT: 0`.
- [x] [P0-T23] CR observation run (success-output observation rule). Run, in order: CR-PARSE with `<LIST>` = LIST-PROD-BASE plus T5 and `<IT-PATTERNS>` = `T824-*`; CR-TEXT with `<CHECKS>` = `@{ Path = '.claude/hooks/validate-feature-review-coverage.ps1'; Present = @("ReasonPrefix 'validate-feature-review-coverage:'"); Absent = @('subagentstop-envelope.ps1') }`; CR-JSON with `<MANIFEST>` = P1 and `<ENTRIES>` = `.claude/hooks/validate-feature-review-coverage.ps1`; CR-SHA with `<PAIRS>` = the H4 pair; then, only when that CR-SHA line ends `MATCH`, CR-MIRROR with the same pair, recording `git status --porcelain` before and after; write `<FEATURE>/evidence/baseline/cr-observation.<ts>.md`. Acceptance: CR-PARSE prints `PARSE-ERROR-COUNT: 0` and `IT-COUNT: tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1 | T824-* | 1`; CR-TEXT prints `TEXT-CHECK-FAILURES: 0`; CR-JSON prints `JSON-MISSING-COUNT: 0`; CR-SHA prints `SHA-DIFFER-COUNT: 0`; CR-MIRROR prints `COPY-DIFFER-COUNT: 0`; the two status outputs are identical.
- [x] [P0-T24] Check off AC-1 in `<FEATURE>/spec.md` (change `- [ ] AC-1:` to `- [x] AC-1:`) only if the P0-T2 artifact contains exactly one `Verdict:` line and it reads `Verdict: PROCEED`, and it records `MergeOutcome: CLEAN`. Acceptance: exactly that one checkbox changed.
- [x] [P0-T25] Commit and push Phase 0: `git add <FEATURE>/evidence <FEATURE>/spec.md <FEATURE>/plan.2026-10-11T07-58.md`, `git commit -m "docs(896): record upstream-merge check and baselines"`, `git push origin HEAD:<BRANCH>`. Acceptance: `git status --porcelain` prints nothing, and after `git fetch origin <BRANCH>` the output of `git rev-parse HEAD` equals that of `git rev-parse origin/<BRANCH>`.

### Phase 1 — Regression Tests First (expect-fail)

- [x] [P1-T1] [expect-fail] Create T11 `tests/scripts/claude-hooks/validate-feature-review-coverage.E4.Helpers.ps1` (test support, so that T2 stays below the 500-line cap; T2 is 296 lines on the base) with a comment-based header (synopsis "E4 (issue #896) harness and fixtures for validate-feature-review-coverage.Coverage.Tests.ps1"; it is dot-sourced from that file's E4 Context `BeforeAll`; it writes no file) and no top-level statement other than the function definitions and `$script:` assignments listed here. T11 defines: `Invoke-ClaudeReviewEntry` (parameter `[AllowEmptyString()][string] $Stdin`; saves `[System.Console]::In` and `[System.Console]::Error`, sets a `StringReader` and a `StringWriter`, sets `$global:LASTEXITCODE = 0`, runs `& $script:HookFile`, returns `ExitCode`, `Stdout`, `Stderr`, and restores both streams in `finally`); `ConvertTo-ClaudeEnvelope` (parameters `[AllowEmptyString()][string] $AssistantText` and `[bool] $StopHookActive = $false`; returns `[ordered]@{ session_id = 'e4-896'; hook_event_name = 'SubagentStop'; agent_type = 'feature-review'; stop_hook_active = $StopHookActive; last_assistant_message = $AssistantText } | ConvertTo-Json -Compress`); the paths `docs/features/active/foo/policy-audit.2026-05-04T08-00.md`, `docs/features/active/foo/code-review.2026-05-04T08-00.md`, `docs/features/active/foo/feature-audit.2026-05-04T08-00.md` and the three-token text `$script:E4Tokens` (the lines `policy-audit-path: <policy path>`, `code-review-path: <code path>`, `feature-audit-path: <feature path>` joined by newlines); `$script:E4Fixtures`, a hashtable of eight entries, each `@{ Text = <assistant text>; Map = <path-to-lines hashtable> }`, where the review map holds the three artifact paths (policy-audit lines as stated, code-review `code`, feature-audit `feature`): `MissingToken` (text: the code-review and feature-audit token lines only; review map with policy-audit `Python coverage PASS`), `AbsentArtifact` (`$script:E4Tokens`; empty map), `NoCoverageRow` (`$script:E4Tokens`; review map with policy-audit `Python style PASS`, plus `artifacts/pr_context.summary.txt` = `- src/foo.py (+1/-0)`), `LineBelowFloor` (policy-audit `Python coverage PASS`, the `.py` summary, `artifacts/python/lcov.info` = `LF:100`, `LH:80`, `BRF:100`, `BRH:80`), `BranchBelowFloor` (as `LineBelowFloor` with `LF:100`, `LH:90`, `BRF:100`, `BRH:70`), `UnreadableClaudeMd` (policy-audit `Python coverage PASS`, the `.py` summary, `CLAUDE.md` = the string `THROW`), `ValidatorError` (policy-audit `PowerShell coverage PASS`, summary `- scripts/foo.ps1 (+1/-0)`, `artifacts/pester/powershell-coverage.xml` = `<report`), `Mixed` (policy-audit lines `Python coverage PASS` and `TypeScript coverage PASS`, summary lines `- src/a.py (+1/-0)` and `- src/b.ts (+1/-0)`, `artifacts/python/lcov.info` = `LF:100`, `LH:80`, `BRF:100`, `BRH:80`, `coverage/lcov.info` = `LF:100`, `LH:90`, `BRF:100`, `BRH:70`); and `Use-E4Fixture -Name` (sets `$script:E4ArtifactMap` to the fixture's `Map` and returns its `Text`). `Invoke-ClaudeReviewEntry` reads the hook path from `$script:HookFile`, which T2's top-level `BeforeAll` (line 14) sets. In T2 `tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1`, add `Context 'E4 (issue #896)'` inside the `Describe`. Its `BeforeAll` holds the single statement `. (Join-Path $PSScriptRoot 'validate-feature-review-coverage.E4.Helpers.ps1')` (the dot-source form of `enforce-completion-consistency.Tests.ps1:11`). Its `BeforeEach` (in T2, not in T11) sets `$script:E4ArtifactMap = @{}` and declares one literal mock: `Mock Get-ArtifactFileContent { param([string] $Path) $entry = $script:E4ArtifactMap[$Path]; if ($null -eq $entry) { return @{ Exists = $false; Text = $null; Lines = @() } }; if ($entry -is [string] -and $entry -eq 'THROW') { throw 'simulated read failure: access denied' }; return Get-ArtifactFileResult -Lines @($entry) }`. Add `It 'E4-TR1: the entry point exits 2 for an envelope without review-artifact tokens' -Tag 'E4-Regression', 'E4-TR1'` that calls `Invoke-ClaudeReviewEntry -Stdin (ConvertTo-ClaudeEnvelope -AssistantText 'Review complete.')` and asserts `ExitCode` is 2 and `Stderr.StartsWith('validate-feature-review-coverage:', [System.StringComparison]::Ordinal)` is true. Acceptance: CR-PARSE with `<LIST>` = T2, T11 and `<IT-PATTERNS>` = `E4-TR1:*` prints `PARSE-ERROR-COUNT: 0`, `IT-COUNT: tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | E4-TR1:* | 1`, and a `PARSE:` line for T11 with `errors=0 | functions=ConvertTo-ClaudeEnvelope,Invoke-ClaudeReviewEntry,Use-E4Fixture`; CR-LINES with `<LIST>` = T2, T11 prints `LINES-OVER-CAP: 0`; CR-TEXT with `<CHECKS>` = `@{ Path = <T2>; Present = @("validate-feature-review-coverage.E4.Helpers.ps1')", 'Mock Get-ArtifactFileContent { param([string] $Path) $entry = $script:E4ArtifactMap[$Path]') }` prints `TEXT-CHECK-FAILURES: 0`.
- [x] [P1-T2] [expect-fail] In the same Context of T2, add `It 'E4-TR4: an unreadable root CLAUDE.md blocks with a structured message and exit 2' -Tag 'E4-Regression', 'E4-TR4'`: `$text = Use-E4Fixture -Name 'UnreadableClaudeMd'`; assert `(Invoke-FeatureReviewCoverageValidation -InputText (ConvertTo-ClaudeEnvelope -AssistantText $text))` has `Ok` false and a `Message` containing `root CLAUDE.md` and `could not be read`; then assert `(Invoke-ClaudeReviewEntry -Stdin (ConvertTo-ClaudeEnvelope -AssistantText $text)).ExitCode` is 2. Acceptance: CR-PARSE with `<LIST>` = T2 and `<IT-PATTERNS>` = `E4-TR4:*` prints `PARSE-ERROR-COUNT: 0` and an `IT-COUNT:` of 1.
- [x] [P1-T3] [expect-fail] In T5 `tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1`, add `It 'E4-TR5-P<Id> resolves <Label>' -Tag 'E4-Regression', 'E4-TR5' -ForEach` with six rows (Line, Branch, LineSource, BranchSource): P1 `line coverage: 70% minimum` (70, 75, claude-md, default); P2 `line coverage 80% at least` (80, 75, claude-md, default); P3 `line coverage of 80% or more` (80, 75, claude-md, default); P4 `branch coverage: 60% or higher` (85, 60, default, claude-md); P5 `line coverage 81% or above` (81, 75, claude-md, default); P6 `branch coverage 62% or greater` (85, 62, default, claude-md); and a separate `It 'E4-TR5-N<Id> keeps the defaults for <Label>' -ForEach` (no regression tag) with three rows: N1 `Line coverage was 62% last release`, N2 `Line and branch coverage: 70% minimum`, N3 `line coverage: 150% minimum`, each expecting 85, 75, default, default. Use the Arrange/Act/Assert body shape of lines 39-50. Acceptance: CR-PARSE with `<LIST>` = T5 and `<IT-PATTERNS>` = `E4-TR5-P*`, `E4-TR5-N*` prints `PARSE-ERROR-COUNT: 0` and an `IT-COUNT:` of 1 for each pattern (row counts are checked by P1-T5 and P1-T6).
- [x] [P1-T4] [expect-fail] In T6 `tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1`, inside `Context 'entry point'`, add `It 'E4-TR7: with no CLAUDE.md figure an 80.5% line row fails against the 85% floor' -Tag 'E4-Regression', 'E4-TR7'` with these mocks: `Mock Test-Path { param($Path) -not ([string]$Path).EndsWith('.xml') }`; `Mock Get-ChildItem { [pscustomobject]@{ FullName = '/synthetic-root/repo/docs/features/active/f/policy-audit.2026-10-10T00-00.md'; LastWriteTime = [datetime]'2026-10-10' } }` (the synthetic audit object of line 183); `Mock Get-Content { param($Path) $p = [string]$Path; if ($p.EndsWith('pr_context.summary.txt')) { @('- src/a.py (+1/-0)') } elseif ($p.EndsWith('lcov.info')) { @('LF:1000', 'LH:805') } elseif ($p.EndsWith('CLAUDE.md')) { 'Project notes without coverage figures.' } else { 'Python coverage PASS' } }`; call `Invoke-CodexReviewEntry -Stdin $script:ReviewStop`; assert `ExitCode` 0, `Stdout` non-empty, `($result.Stdout | ConvertFrom-Json).decision` equals `block`, and the reason contains `below the 85% line coverage floor`. Acceptance: CR-PARSE with `<LIST>` = T6 and `<IT-PATTERNS>` = `E4-TR7:*` prints `PARSE-ERROR-COUNT: 0` and an `IT-COUNT:` of 1.
- [x] [P1-T5] [expect-fail] Run CR-PESTER-LIST with `<LIST>` = T2, T5, T6; `<TAGS-IN>` = `E4-Regression`; `<TAGS-OUT>` empty; `<PATTERNS>` = `E4-TR1:*`, `E4-TR4:*`, `E4-TR5-P*`, `E4-TR7:*`; write `<FEATURE>/evidence/regression-testing/fail-first.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE: 1`, `ExpectedExitCode: 1`, `Output Summary:`, every `NAMED:` and `FAILED:` line verbatim, a `Base:` line copied from the P0-T2 artifact, and the PI-3 note for E4-TR4. Acceptance: `NAMED: E4-TR1:* | Passed=0 | Failed=1`, `NAMED: E4-TR4:* | Passed=0 | Failed=1`, `NAMED: E4-TR5-P* | Passed=0 | Failed=6`, `NAMED: E4-TR7:* | Passed=0 | Failed=1`, `EXIT_CODE_COMPUTED: 1`, and process exit code 1.
- [x] [P1-T6] Confirm the untagged rows of the three edited files still pass: run CR-PESTER-LIST with `<LIST>` = T2, T5, T6; `<TAGS-IN>` empty; `<TAGS-OUT>` = `E4-Regression`; `<PATTERNS>` = `E4-TR5-N*`, `T824-*`; write `<FEATURE>/evidence/regression-testing/phase1-untagged-rows.<ts>.md`. Acceptance: `NAMED: E4-TR5-N* | Passed=3 | Failed=0`, `NAMED: T824-* | Passed=11 | Failed=0`, `TOTAL:` with `Failed=0`, `EXIT_CODE_COMPUTED: 0`.
- [x] [P1-T7] Commit and push Phase 1: `git add tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 tests/scripts/claude-hooks/validate-feature-review-coverage.E4.Helpers.ps1 tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1 tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 <FEATURE>/evidence <FEATURE>/plan.2026-10-11T07-58.md`, `git commit -m "test(896): add expect-fail regression tests E4-TR1, TR4, TR5, TR7"`, `git push origin HEAD:<BRANCH>`. Acceptance: `git status --porcelain` prints nothing and, after `git fetch origin <BRANCH>`, `git rev-parse HEAD` equals `git rev-parse origin/<BRANCH>`.

### Phase 2 — CR-8 Three-File Split (behavior-preserving move)

- [x] [P2-T1] Create H2 `.claude/hooks/validate-feature-review-coverage-metrics.ps1` with a comment-based file header (synopsis; "Dot-sourced by validate-feature-review-coverage.ps1"; PowerShell 7+; no `python` token) and move, unchanged, `Get-ArtifactFileContent` (H1 lines 51-73), `Get-LcovRepoCoverage` (150-169), `Get-LcovBranchCoverage` (171-194), `Get-JacocoBranchCoverage` (196-216), `Get-LanguageBranchCoverage` (218-229), `Get-JacocoRepoCoverage` (231-251), `Get-LanguageRepoCoverage` (253-266). The file has no `param()` block, no output-stream write, and no top-level statement other than function definitions. Acceptance: CR-PARSE with `<LIST>` = H2 prints `errors=0` and `functions=Get-ArtifactFileContent,Get-JacocoBranchCoverage,Get-JacocoRepoCoverage,Get-LanguageBranchCoverage,Get-LanguageRepoCoverage,Get-LcovBranchCoverage,Get-LcovRepoCoverage`.
- [x] [P2-T2] Create H3 `.claude/hooks/validate-feature-review-coverage-rules.ps1` with the same header form and move, unchanged, `Get-ReviewArtifactPathFromOutput` (H1 lines 75-104), `Get-ReviewArtifactInfo` (106-129), `Get-ChangedLanguageSet` (131-148), `Test-LanguageCoverageRow` (268-343). Acceptance: CR-PARSE with `<LIST>` = H3 prints `errors=0` and `functions=Get-ChangedLanguageSet,Get-ReviewArtifactInfo,Get-ReviewArtifactPathFromOutput,Test-LanguageCoverageRow`.
- [x] [P2-T3] Edit H1 `.claude/hooks/validate-feature-review-coverage.ps1`: delete the eleven moved function bodies and add the metrics and rules guarded dot-source lines quoted under Guarded Dot-Source Literals immediately after line 47. Acceptance: CR-PARSE with `<LIST>` = H1 prints `errors=0` and `functions=Invoke-FeatureReviewCoverageValidation`, and CR-TEXT with `<CHECKS>` = `@{ Path = <H1>; Present = @(<the two quoted lines>) }` prints `TEXT-CHECK-FAILURES: 0`.
- [x] [P2-T4] Edit P1 `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`: insert `".claude/hooks/validate-feature-review-coverage-metrics.ps1",` and `".claude/hooks/validate-feature-review-coverage-rules.ps1",` between the entries at lines 71 (`".claude/hooks/validate-executor-output.ps1",`) and 72 (`".claude/hooks/validate-feature-review-coverage.ps1",`), as re-derived in the v1.5 revision against the tree that contains the E1 merge (the E1 entry `".claude/hooks/subagentstop-envelope.ps1",` is at line 68 and is not edited; `".claude/hooks/feature-review-coverage-thresholds.ps1",` is at line 59). The insertion point is located by the two quoted entries; the line numbers locate them in the current tree. Acceptance: CR-JSON with `<MANIFEST>` = P1 and `<ENTRIES>` = the two new strings prints `JSON-MISSING-COUNT: 0`.
- [x] [P2-T5] Mirror H1, H2, H3: run CR-MIRROR with `<PAIRS>` = the H1, H2, H3 pairs of LIST-MIRROR-PAIRS; write `<FEATURE>/evidence/other/phase2-mirror.<ts>.md`. Acceptance: three `COPIED:` lines ending `MATCH` and `COPY-DIFFER-COUNT: 0`.
- [x] [P2-T6] In T1 `tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1`, add `It 'E4-ST4: <File> defines exactly its assigned functions' -ForEach` with three rows: H1 (`Invoke-FeatureReviewCoverageValidation`), H2 (the seven P2-T1 names), H3 (the four P2-T2 names); each row parses the file with `[System.Management.Automation.Language.Parser]::ParseFile` and asserts the sorted `FunctionDefinitionAst` name set equals the sorted assigned list. Acceptance: CR-PARSE with `<LIST>` = T1 and `<IT-PATTERNS>` = `E4-ST4*` prints `PARSE-ERROR-COUNT: 0` and an `IT-COUNT:` of 1.
- [x] [P2-T7] Gate: run CR-PESTER-LIST with `<LIST>` = LIST-CLAUDE-SUITES; `<TAGS-IN>` empty; `<TAGS-OUT>` = `E4-Regression`; `<PATTERNS>` = `E4-ST4*`, `TG1:*`, `TG2:*`, `TG3:*`, `F824-*`, `B1:*validate-feature-review-coverage*`, and the four GUARD-PATTERNS; write `<FEATURE>/evidence/qa-gates/phase2-split-pester.<ts>.md`. Acceptance: `NAMED: E4-ST4* | Passed=3 | Failed=0`, `NAMED: TG1:* | Passed=2 | Failed=0`, `NAMED: TG2:* | Passed=2 | Failed=0`, `NAMED: TG3:* | Passed=2 | Failed=0`, `NAMED: B1:*validate-feature-review-coverage* | Passed=3 | Failed=0` (thresholds, metrics, rules edges), each `S1`, `S2`, `S6` GUARD-PATTERN line `Passed=2 | Failed=0`, `NAMED: N1:* | Passed=2 | Failed=0` (N1 rule), `TOTAL:` with `Failed=0` and `EXIT_CODE_COMPUTED: 0`, or, when every `FAILED:` line meets the PEF, `EXIT_CODE_COMPUTED: 1`, process exit code 1, and an artifact recording `ExpectedExitCode: 1` and `PRE-EXISTING-STILL-FAILING:` (PEF).
- [x] [P2-T8] Run CR-LINES with `<LIST>` = H1, H2, H3; write `<FEATURE>/evidence/qa-gates/phase2-file-size.<ts>.md`. Acceptance: three `LINES:` lines with `count=` below 500 and `LINES-OVER-CAP: 0`.
- [x] [P2-T9] Commit and push Phase 2: `git add .claude/hooks/validate-feature-review-coverage.ps1 .claude/hooks/validate-feature-review-coverage-metrics.ps1 .claude/hooks/validate-feature-review-coverage-rules.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 <FEATURE>/evidence <FEATURE>/plan.2026-10-11T07-58.md`, `git commit -m "refactor(896): split feature-review coverage hook into entry, metrics, and rules files"`, `git push origin HEAD:<BRANCH>`. Acceptance: `git status --porcelain` prints nothing and after `git fetch origin <BRANCH>`, `git rev-parse HEAD` equals `git rev-parse origin/<BRANCH>`.

### Phase 3 — CR-9 Resolver Form and Floor-Source Messages

- [x] [P3-T1] Edit H4 `.claude/hooks/feature-review-coverage-thresholds.ps1` line 57: replace the pattern with one that keeps the combined-metric lookbehind and adds the trailing-floor alternative from spec Proposed Fix item 5, in the form `'(?im)(?<!\b(?:line|branch)\s*(?:and|or|&|/)\s*)\b' + $metric + '\s+coverage\b[^\r\n%]*?(?:(?:>=|' + [char]0x2265 + '|\bat\s+least\b|\bminimum(?:\s+of)?\b|\bno\s+less\s+than\b)\s*:?\s*(?<![\d.])(?<pct>\d{1,3}(?:\.\d+)?)\s*%|(?<![\d.])(?<pct>\d{1,3}(?:\.\d+)?)\s*%\s*(?:minimum|at\s+least|or\s+(?:more|higher|above|greater))\b)'`; keep the 0..100 range check and first-valid-match loop (lines 58-66) unchanged. Acceptance: CR-PARSE with `<LIST>` = H4 prints `errors=0`, and CR-TEXT with `<CHECKS>` = `@{ Path = <H4>; Present = @('or\s+(?:more|higher|above|greater)') }` prints `TEXT-CHECK-FAILURES: 0`.
- [x] [P3-T2] Edit the `Get-FeatureReviewCoverageThreshold` help (H4 lines 22-36) to list the accepted forms: comparator before the figure (`>=`, the U+2265 sign, `at least`, `minimum`, `minimum of`, `no less than`) and trailing floor phrase after the figure (`minimum`, `at least`, `or more`, `or higher`, `or above`, `or greater`), each on the same line as `<metric> coverage`; keep the combined-metric limitation paragraph. Acceptance: CR-TEXT with `<CHECKS>` = `@{ Path = <H4>; Normalize = $true; Present = @('>=', 'U+2265', 'at least', 'minimum of', 'no less than', 'or more', 'or higher', 'or above', 'or greater') }` prints `TEXT-CHECK-FAILURES: 0`.
- [x] [P3-T3] Edit `Test-LanguageCoverageRow` in H3: add parameters `[string] $LineSource = 'default'` and `[string] $BranchSource = 'default'`; compute the label `(root CLAUDE.md)` when the source is `claude-md` and `(default)` otherwise; append the label after `line coverage floor` and after `branch coverage floor` in the two floor messages (base H1 lines 330 and 338), producing for example `below the 70% line coverage floor (root CLAUDE.md)`. Acceptance: CR-PARSE with `<LIST>` = H3 prints `errors=0`, and CR-TEXT with `<CHECKS>` = `@{ Path = <H3>; Present = @('[string] $LineSource', '[string] $BranchSource', '(root CLAUDE.md)') }` prints `TEXT-CHECK-FAILURES: 0`.
- [x] [P3-T4] Edit `Invoke-FeatureReviewCoverageValidation` in H1: pass `-LineSource $thresholds.LineSource -BranchSource $thresholds.BranchSource` in the `Test-LanguageCoverageRow` call (base line 450). Acceptance: CR-PARSE with `<LIST>` = H1 prints `errors=0`, and CR-TEXT with `<CHECKS>` = `@{ Path = <H1>; Present = @('-LineSource $thresholds.LineSource') }` prints `TEXT-CHECK-FAILURES: 0`.
- [x] [P3-T5] In T2, inside `Context 'Test-LanguageCoverageRow'`, add `It 'E4-TR6: <Metric> floor message names <Expected>' -ForEach` with four rows: line/claude-md (`-RepoWidePct 60 -LineFloor 70 -LineSource 'claude-md'`, expects `70% line coverage floor (root CLAUDE.md)`), line/default (`-RepoWidePct 60`, expects `85% line coverage floor (default)`), branch/claude-md (`-RepoWidePct 90 -BranchPct 50 -BranchFloor 60 -BranchSource 'claude-md'`, expects `60% branch coverage floor (root CLAUDE.md)`), branch/default (`-RepoWidePct 90 -BranchPct 50`, expects `75% branch coverage floor (default)`); audit text `Python coverage PASS`; assert `.Reason.Contains($Expected)`. Acceptance: CR-PARSE with `<LIST>` = T2 and `<IT-PATTERNS>` = `E4-TR6*` prints `PARSE-ERROR-COUNT: 0` and an `IT-COUNT:` of 1.
- [x] [P3-T6] In T5, add `It 'E4-ST5: the resolver help names every accepted comparator form'` that parses H4, takes the `Get-FeatureReviewCoverageThreshold` `FunctionDefinitionAst`, reads `GetHelpContent().Description`, collapses whitespace runs to one space, and asserts it contains each P3-T2 token. Acceptance: CR-PARSE with `<LIST>` = T5 and `<IT-PATTERNS>` = `E4-ST5:*` prints `PARSE-ERROR-COUNT: 0` and an `IT-COUNT:` of 1.
- [x] [P3-T7] Mirror H1, H3, H4: run CR-MIRROR with `<PAIRS>` = the H1, H3, H4 pairs of LIST-MIRROR-PAIRS; write `<FEATURE>/evidence/other/phase3-mirror.<ts>.md`. Acceptance: three `COPIED:` lines ending `MATCH` and `COPY-DIFFER-COUNT: 0`.
- [x] [P3-T8] Gate (CR-9 regression now passing): run CR-PESTER-LIST with `<LIST>` = T5; no tag filters; `<PATTERNS>` = `E4-TR5-P*`, `E4-TR5-N*`, `T824-*`, `E4-ST5:*`; write `<FEATURE>/evidence/qa-gates/phase3-resolver-pester.<ts>.md`. Acceptance: `NAMED: E4-TR5-P* | Passed=6 | Failed=0`, `NAMED: E4-TR5-N* | Passed=3 | Failed=0`, `NAMED: T824-* | Passed=11 | Failed=0`, `NAMED: E4-ST5:* | Passed=1 | Failed=0`, `EXIT_CODE_COMPUTED: 0`.
- [x] [P3-T9] Gate: run CR-PESTER-LIST with `<LIST>` = LIST-CLAUDE-SUITES; `<TAGS-OUT>` = `E4-TR1`, `E4-TR4`; `<PATTERNS>` = `E4-TR6*`, `E4-ST4*`, `TG*`, `F824-*`; write `<FEATURE>/evidence/qa-gates/phase3-claude-pester.<ts>.md`. Acceptance: `NAMED: E4-TR6* | Passed=4 | Failed=0`, `NAMED: E4-ST4* | Passed=3 | Failed=0`, `TOTAL:` with `Failed=0` and `EXIT_CODE_COMPUTED: 0`, or, when every `FAILED:` line meets the PEF, `EXIT_CODE_COMPUTED: 1`, process exit code 1, and an artifact recording `ExpectedExitCode: 1` and `PRE-EXISTING-STILL-FAILING:` (PEF).
- [x] [P3-T10] Check off AC-11 in `<FEATURE>/spec.md` (P1-T5 recorded the base failures of the positive rows; P3-T8 shows all rows passing). Acceptance: only the AC-11 checkbox changed.
- [x] [P3-T11] Check off AC-12 in `<FEATURE>/spec.md` (P3-T8 `E4-ST5`, P3-T9 `E4-TR6`). Acceptance: only the AC-12 checkbox changed.
- [x] [P3-T12] Commit and push Phase 3: `git add .claude/hooks/feature-review-coverage-thresholds.ps1 .claude/hooks/validate-feature-review-coverage.ps1 .claude/hooks/validate-feature-review-coverage-rules.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks tests/scripts/claude-hooks <FEATURE>/evidence <FEATURE>/spec.md <FEATURE>/plan.2026-10-11T07-58.md`, `git commit -m "fix(896): accept trailing-floor coverage statements and name the floor source (CR-9)"`, `git push origin HEAD:<BRANCH>`. Acceptance: `git status --porcelain` prints nothing and after `git fetch origin <BRANCH>`, `git rev-parse HEAD` equals `git rev-parse origin/<BRANCH>`.

### Phase 4 — Corpus False-Positive Gate (amendment 2026-10-11)

This phase implements the Plan Amendment 2026-10-11 operator rule under design decisions D1-D8. It runs after P3-T12. No Phase 5 task starts until P4-T10 meets its acceptance. Gates in this phase exclude `E4-TR1` and `E4-TR4` by tag (PI-2). CR-CORPUS calls `Invoke-FeatureReviewCoverageValidation -RawPayload`, the parameter that exists until P5-T3, so CR-CORPUS is run only in this phase. Re-entry bound: when P4-T7 does not meet its acceptance, the executor returns to P4-T4 once per failed P4-T7 run, at most twice. P4-T4 appends `## FIX-<j>` sections (continuing the numbering) for the remaining false-positive form keys or revises the fix whose form key dropped a true positive; it then rewrites `FIX-CLASSES:` and `E4-CORPUS-ROWS:` with the new `k` (the total number of `## FIX-` sections after that P4-T4 pass), and P4-T5, P4-T6, and P4-T7 are repeated. After a third P4-T7 run that does not meet its acceptance, the executor follows the BLOCKED procedure of P4-T4 and records `ReentryExhausted: yes` as the reason.

Restart after a BLOCKED P4-T4 (v1.8). When P4-T4 stopped with BLOCKED and the plan was revised, the executor restarts P4-T4 from the committed state. P4-T1, P4-T2, and P4-T3 are not re-run: their artifacts and `CorpusSha:` are reused. The restart creates a new `<FEATURE>/evidence/other/corpus-rule-changes.<ts>.md` whose fields include `RestartOf: <repository-relative path of the BLOCKED rule-changes artifact>`. The BLOCKED artifact stays in place unedited. The restart re-derives `k` from the P4-T2 `CORPUS-FORM:` lines, as on a first pass. It applies every fix from FIX-1, because the BLOCKED procedure restored H1, H3, T1, and the Claude bundle hooks to HEAD. A restart is a first pass and not a P4-T7 re-entry, so it does not count toward the re-entry bound. In P4-T4 through P4-T9, "the rule-changes artifact" is the `corpus-rule-changes.<ts>.md` file created by the latest P4-T4 first pass or restart. A BLOCKED artifact from an earlier pass is not that file.

- [x] [P4-T1] Precondition and corpus reference. Run `git fetch origin <BRANCH>`, `git rev-parse HEAD`, `git rev-parse origin/<BRANCH>`, `git status --porcelain`, `git fetch origin main`, and `git rev-parse origin/main`. Create `<FEATURE>/evidence/other/corpus-run.initial.<ts>.md` with `Timestamp:`, `Command:` (the six commands), `EXIT_CODE:` (0 when all six exit 0), `StartHead:` (the `git rev-parse HEAD` output), `CorpusRef: origin/main`, and `CorpusSha:` (the `git rev-parse origin/main` output). Acceptance: the two `rev-parse` outputs for `HEAD` and `origin/<BRANCH>` are equal, which shows that P3-T12 pushed; `git status --porcelain` printed nothing; `CorpusSha:` holds a 40-character hexadecimal SHA. When `HEAD` differs from `origin/<BRANCH>` or the status is not empty, stop with BLOCKED.
- [x] [P4-T2] Initial corpus run (D1-D6). Run CR-CORPUS through the scratchpad route with `$Mode = 'initial'`, `$CorpusSha` = the P4-T1 `CorpusSha:` value, and `$InitialArtifact = ''`. Append to `<FEATURE>/evidence/other/corpus-run.initial.<ts>.md` (the P4-T1 file) a `CorpusCommand:` line recording the route (`scratchpad`) and the substituted values `$Mode = 'initial'`, `$CorpusSha = '<the 40-hex value>'`, and `$InitialArtifact = ''`, then the full output verbatim under `## CR-CORPUS initial run`, followed by `CORPUS_RUN_EXIT_CODE:` (the process exit code) and `Output Summary:` (the thirteen summary lines). The P4-T1 `Command:` field keeps its six precondition commands. This run is the CR-CORPUS initial-mode success-output observation. Acceptance:
  - each of `CORPUS-SHA:`, `CORPUS-RAW:`, `CORPUS-EXCLUDED-TEMPLATE:`, `CORPUS-EXCLUDED-NON-ARTIFACT:`, `CORPUS-ARTIFACTS:`, `CORPUS-TRIPLES:`, `CORPUS-INCOMPLETE-GROUPS:`, `CORPUS-RULE3-EVALUATED:`, `CORPUS-RULE3-UNDERIVABLE:`, `CORPUS-RULE3-NO-CHANGED-LANGUAGE:`, `CORPUS-REJECTED:`, `CORPUS-TRUE-POSITIVE:`, `CORPUS-FALSE-POSITIVE:`, and `CORPUS-UNEXPECTED:` appears exactly once with a numeric value (the SHA for `CORPUS-SHA:`);
  - `CORPUS-SHA:` equals `CorpusSha:`;
  - `CORPUS-RAW:` equals the sum of `CORPUS-EXCLUDED-TEMPLATE:`, `CORPUS-EXCLUDED-NON-ARTIFACT:`, and `CORPUS-ARTIFACTS:`;
  - `CORPUS-REJECTED:` equals both the sum of `CORPUS-TRUE-POSITIVE:` and `CORPUS-FALSE-POSITIVE:` and the number of `CORPUS-REJECT:` lines;
  - the number of `CORPUS-LANG:` lines equals the sum of `CORPUS-RULE3-EVALUATED:`, `CORPUS-RULE3-UNDERIVABLE:`, and `CORPUS-RULE3-NO-CHANGED-LANGUAGE:`;
  - `CORPUS-RULE3-EVALUATED:` is greater than 0;
  - `CORPUS-UNEXPECTED: 0`, `EXIT_CODE_COMPUTED: 0`, and process exit code 0;
  - exactly one `CorpusCommand:` line is present, and its `$CorpusSha` value equals `CorpusSha:`.

  When `CORPUS-RULE3-EVALUATED: 0` is printed, or a `CORPUS-UNEXPECTED-ITEM:` line is printed, stop with BLOCKED and record the lines; the gate would otherwise be vacuous for the coverage-row rule or would contain an unclassified rejection.
- [x] [P4-T3] Final-mode observation run (validator unchanged). Run CR-CORPUS through the scratchpad route with `$Mode = 'final'`, the same `$CorpusSha`, and `$InitialArtifact` = the P4-T1 artifact path. Write `<FEATURE>/evidence/other/corpus-run.observation.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:` (the process exit code), `ExpectedExitCode: 1` only when the P4-T2 `CORPUS-FALSE-POSITIVE:` value is non-zero, `Output Summary:`, and the full output. This run is the CR-CORPUS final-mode success-output observation. Acceptance: the output prints `CORPUS-TP-DROPPED: 0`, `CORPUS-TP-ADDED: 0`, and `CORPUS-TP-ADDED-UNEXPLAINED: 0`. Its `CORPUS-RAW:`, `CORPUS-ARTIFACTS:`, `CORPUS-REJECTED:`, `CORPUS-TRUE-POSITIVE:`, and `CORPUS-FALSE-POSITIVE:` values equal the P4-T2 values. `EXIT_CODE_COMPUTED:` is 0 when the P4-T2 false-positive count is 0, and 1 otherwise.
- [x] [P4-T4] Rule-change record and bounded rule-fix loop (D6, D7). Create `<FEATURE>/evidence/other/corpus-rule-changes.<ts>.md` with these fields:
  - `Timestamp:`, `CorpusSha:`, and `InitialArtifact:` (the P4-T1 path), and on a restart `RestartOf:` (Phase 4 introduction);
  - `FIX-CLASSES: <k>`, where `k` is the total number of `## FIX-` sections in this artifact after the latest P4-T4 pass. On the first pass that equals the number of P4-T2 `CORPUS-FORM:` lines whose `classes=` value contains `FALSE-POSITIVE`; on each re-entry (phase re-entry bound) the executor rewrites this line, and the `E4-CORPUS-ROWS:` line, with the new total;
  - `OutOfCorpusObservation:` (D8);
  - one `## FIX-<j>` section per such form key, in the `CORPUS-FORM:` line order, with `FormKey:`, `Rule:` (`rule1`, `rule2`, or `rule3`), `Basis:` (`SANCTIONED-S1-S2`, `SANCTIONED-S3`, or `ESTABLISHED` with its `folders=` value), `Governing:` (the D6 sanction citation, or `none (established by count)`), `Rejections:`, `Exemplar:` (for rule1 and rule2, the artifact path of the first `CORPUS-REJECT:` line, in output order, that carries this form key; for rule3, the exemplar CR-EXEMPLAR selects under (b)), for rule3 only `ExemplarForm:` (`FULL` or `REDUCED`) and `ExemplarGuard: REPRODUCED | <fragment>`, `TargetFile:` (H3 for rule1 and rule3, H1 for rule2), `TargetFunction:` (`Get-ReviewArtifactInfo` for rule1, `Invoke-FeatureReviewCoverageValidation` for rule2, `Test-LanguageCoverageRow` for rule3), `Change:` (one sentence), `Rationale:`, `PolicyEditRequired: no`, `NewFunctionRequired: no`, `CodexParity:` (C5), `Tests:`, `Rows:`, and `Status: PENDING`.

  When `k` is 0, write `RULE-CHANGES: NONE` and `E4-CORPUS-ROWS: 0`, make no production or test change, and the task is complete.

  Otherwise, for each `j` from 1 to `k` in order:
  - (a) Edit `TargetFunction` in `TargetFile` under constraints C1-C8. An S1 fix in `Test-LanguageCoverageRow` identifies the sanctioned PowerShell line with the two D6 S1 regexes, `(?i)\bbranch\b` present and `(?i)\bline\s+coverage\b` absent, and no other test.
  - (b) In T1 `tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1`, inside `Context 'E4-CORPUS (issue #896 corpus gate)'` (created once, as the last Context of the `Describe`), add `It 'E4-CORPUS-<j>: <Rule> form <j> is accepted and its true-positive counterpart is rejected' -Tag 'E4-CORPUS' -ForEach` with exactly two rows.
    - rule3 exemplar and here-string (v1.8). Before step (a) of each rule3 `j`, run CR-EXEMPLAR with `$CorpusSha` = the P4-T1 `CorpusSha:` value, `$InitialArtifact` = the P4-T1 artifact path, and `$FormKey` = the section's `FormKey:`. Append to the `## FIX-<j>` section an `ExemplarCommand:` line recording the route (`scratchpad`) and the three substituted values, then the full output verbatim in a fenced block under `### CR-EXEMPLAR output`. CR-EXEMPLAR tries every candidate's FULL line set first, then every candidate's REDUCED line set, as defined there. Qualification checks: ASCII only; no match of any `$forbiddenPatterns` pattern of `.claude/hooks/check-powershell-test-purity.ps1` (lines 102-120 in the current tree, read by reference); none of the four P12-T7 literals; no line starting `'@`; at most 40 lines. A candidate is selected only when the representativeness guard reproduces the form key's original reason fragment through the HEAD `Test-LanguageCoverageRow`. When it prints `EXEMPLAR: <form key> | ExemplarForm=<form> | <path> | lines=<n>`, set `Exemplar: <path>`, `ExemplarForm: <form>`, and `ExemplarGuard: REPRODUCED | <fragment>`, where `<fragment>` is the fragment field of its `EXEMPLAR-GUARD: ... | REPRODUCED | ...` line. The here-string is a single-quoted here-string: `@'` on its own line, then the `EXEMPLAR-LINE:` values in output order with the `EXEMPLAR-LINE: ` prefix removed, then `'@` on its own line. Each rule3 `j` carries its here-string exactly once in T1. It is assigned inside the `It` body (`$auditText = @'` … `'@`). The two `-ForEach` rows are `@{ Kind = 'Accept' }` and `@{ Kind = 'Reject' }`, plus any keys the `It` name template uses. The `It` body applies the `Reject` transformation to `$auditText` when `$Kind -eq 'Reject'`. No row repeats the here-string. Line budget: T1 is 156 lines at HEAD. The three rule3 exemplars selected by the 2026-10-12 CR-EXEMPLAR dry run total 87 lines (93 with delimiters). Repeating them in each row would add a further 93 lines (156 + 93 + 93 = 342 lines before any `Context`, `It` declaration, row table, or rule1 or rule2 row), leaving 58 lines under the P4-T6 ceiling of 400 for that remaining E4-CORPUS text and risking a `T1-LINE-BUDGET` block. When it prints `EXEMPLAR: <form key> | NONE` (exit 1), set `BlockedReason: EXEMPLAR-UNREPRESENTABLE` in the section and follow the BLOCKED procedure. A rule3 here-string for the Python language carries Python label lines, for example lines containing `Python` or `pytest`. These lines are corpus data in T1, a test file. They do not breach C3, because C3 and the Hermeticity rule govern the H1-H6 production lines.
    - The `Accept` row is built from the exemplar.
      - rule3: call `Test-LanguageCoverageRow -AuditText <here-string> -Language <language>` and assert that `[string]$result.Reason` does not match the original reason fragment of the form key: `narrows scope` for a `|NARROWING|` key, `no coverage-scoped row` for a `|NO-COVERAGE-ROW` key, `neither a PASS nor a FAIL` for a `|NO-VERDICT` key. A different failure return of the same function, or `Ok` true, meets the assertion, because the here-string carries only the selected lines.
      - rule1: the exemplar's active-equivalent path and stem. Assert that `Get-ReviewArtifactInfo` returns a non-null result whose `Timestamp` matches `^\d{4}-\d{2}-\d{2}T\d{2}-\d{2}$`.
      - rule2: the form key `rule2|<stem>|<bucket>` fixes one stem. Advertise, through `Invoke-FeatureReviewCoverageValidation -RawPayload` with the `Mock -CommandName Get-ArtifactFileContent` pattern of the existing T1 same-timestamp test (the mock reports all three paths as existing), these three paths: the exemplar policy audit's active-equivalent path; for the fixed stem, the recorded partner path read from the exemplar's `CORPUS-REJECT:` reason suffix ` [partner: <path>]`; for the other stem, `docs/features/active/<policy audit Folder>/<other stem>.<policy audit Timestamp>.md`. Assert `Ok` is true. Each row carries its three advertised paths as `Paths`; the `It` body assigns `$script:E4CorpusPaths = $Paths` before the call, and the mock returns `@{ Exists = $true; Text = 'ok'; Lines = @('ok') }` when `$script:E4CorpusPaths -contains $Path` and `@{ Exists = $false; Text = $null; Lines = @() }` otherwise (including `artifacts/pr_context.summary.txt`). The mock is a literal script block declared in the `It` body as `Mock -CommandName Get-ArtifactFileContent -MockWith { param([string]$Path) ... }`, the form of the T1 same-timestamp test (lines 39-54). This return shape is the one `Get-ArtifactFileContent` produces (H1 base lines 60 and 72: `Exists`, `Text`, `Lines`), and the absent `artifacts/pr_context.summary.txt` makes the decision function return `Ok` true at the changed-language check (H1 base lines 437-441) before any `CLAUDE.md` read, so the `Accept` row observes only the artifact-path and same-folder-and-timestamp rules. The `Reject` row's `Paths` holds its own three advertised paths (the policy audit path and the two shifted partner paths), so every advertised file exists and the only rejection is the same-folder-and-timestamp one.
    - The `Reject` row applies one transformation to the `Accept` input.
      - S1: in each line of the Accept here-string that meets the D6 S1 condition, replace every match of `(?i)\bbranch\b` with `line`, so that no transformed line matches `(?i)\bbranch\b`.
      - S2: remove the `## Rejected Scope Narrowing` heading line.
      - Both S1 and S2 (`Basis: SANCTIONED-S1-S2`): apply both.
      - Established rule3: remove every word-bounded `PASS` and `FAIL` token.
      - rule1 (S3 or established): replace every `yyyy-MM-ddTHH-mm` timestamp in the path with `undated`.
      - rule2: move each partner timestamp one day later.
    - The `Reject` row asserts the original rejection class: `Ok` false with `Reason` containing `narrows scope` for S1 and S2; `Ok` false with `Reason` matching `no coverage-scoped row|neither a PASS nor a FAIL` for established rule3; a null result for rule1; `Ok` false with `Message` containing `must share the same feature folder and timestamp` for rule2.
  - (c) Set the section's `Tests: E4-CORPUS-<j>`, `Rows: 2`, and `Status: APPLIED`.

  After the loop, write `E4-CORPUS-ROWS: <2k>`, with `k` as defined for `FIX-CLASSES:` (on a re-entry pass, rewrite the existing line rather than appending a second one).

  BLOCKED procedure. It applies when a fix would require a policy edit (C4) or a new function (C1), when CR-EXEMPLAR prints `EXEMPLAR: <form key> | NONE` for a rule3 section (`BlockedReason: EXEMPLAR-UNREPRESENTABLE`), or when a third P4-T7 run does not meet its acceptance (record `ReentryExhausted: yes` in the artifact as the reason), or when P4-T6 reports T1 above its ceiling (`BlockedReason: T1-LINE-BUDGET`). For C4 or C1, set `PolicyEditRequired: yes` or `NewFunctionRequired: yes` with the reason. In every case, edit no policy file and leave the production and test files unchanged. Run `git restore --source=HEAD -- .claude/hooks tests/scripts/claude-hooks extensions/drm-copilot/resources/claude-customizations/.claude/hooks`. Then run `git add <FEATURE>/evidence <FEATURE>/plan.2026-10-11T07-58.md`, `git commit -m "docs(896): record corpus gate BLOCKED"`, and `git push origin HEAD:<BRANCH>`, and stop with BLOCKED. After a plan revision, P4-T4 resumes only through the restart defined in the Phase 4 introduction.

  Acceptance:
  - CR-PARSE with `<LIST>` = H1, H3, T1 and `<IT-PATTERNS>` = `E4-CORPUS-*` prints `PARSE-ERROR-COUNT: 0`, `functions=Invoke-FeatureReviewCoverageValidation` for H1, `functions=Get-ChangedLanguageSet,Get-ReviewArtifactInfo,Get-ReviewArtifactPathFromOutput,Test-LanguageCoverageRow` for H3, and `IT-COUNT: tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 | E4-CORPUS-* | <k>`, where `<k>` is the total number of `## FIX-` sections after the latest P4-T4 pass (the current `FIX-CLASSES:` value).
  - Every `## FIX-` section reads `Status: APPLIED`.
  - Every `## FIX-` section whose `Rule:` is `rule3` carries `ExemplarForm: FULL` or `ExemplarForm: REDUCED`, an `ExemplarGuard: REPRODUCED | <fragment>` line whose fragment is the form key's original reason fragment, and a `### CR-EXEMPLAR output` block containing `EXIT_CODE_COMPUTED: 0`.
  - CR-TEXT with `<CHECKS>` = `@{ Path = '.claude/hooks/validate-feature-review-coverage-rules.ps1'; Present = @('does not mention', 'no coverage-scoped row', 'narrows scope', 'neither a PASS nor a FAIL', 'line coverage floor', 'branch coverage floor') }, @{ Path = '.claude/hooks/validate-feature-review-coverage.ps1'; Present = @('must share the same feature folder and timestamp') }` prints `TEXT-CHECK-FAILURES: 0`.
- [x] [P4-T5] Mirror H1 and H3, then hash. Run CR-MIRROR with `<PAIRS>` = the H1 and H3 pairs of LIST-MIRROR-PAIRS, then CR-SHA with `<PAIRS>` = the H1, H2, H3 pairs. Write `<FEATURE>/evidence/other/phase4-mirror.<ts>.md`. Acceptance: two `COPIED:` lines ending `MATCH`, `COPY-DIFFER-COUNT: 0`, three `SHA:` lines ending `MATCH`, and `SHA-DIFFER-COUNT: 0`.
- [x] [P4-T6] File sizes after the rule fixes. Run CR-LINES with `<LIST>` = H1, H3, T1 (`.claude/hooks/validate-feature-review-coverage.ps1`, `.claude/hooks/validate-feature-review-coverage-rules.ps1`, `tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1`). Write `<FEATURE>/evidence/qa-gates/phase4-file-size.<ts>.md`. Acceptance: three `LINES:` lines with numeric `count=` and `LINES-OVER-CAP: 0`, and the T1 `count=` is at most 400. Derivation of the ceiling: CR-LINES reports `OVER-CAP` at 500, so T1 must end at most at 499 lines; the T1 additions planned after Phase 4 are estimated at about 88 lines (P5-T6 envelope conversion of the four base tests and of any `E4-CORPUS` rule2 rows, at most about 10 lines, because each `@{ output = ... }` payload is replaced by an envelope literal of the same line structure; P5-T11 `E4-ST1` six-row and two-row `It` blocks, `E4-ST2`, and `E4-ST6`, about 63 lines; P6-T6 the H2 row of `E4-ST4` gaining one name, at most 1 line; P7-T12 the two-row `E4-ST3` `It`, about 14 lines); 499 - 400 = 99 lines of headroom covers that estimate with 11 lines of margin. When T1 exceeds that ceiling, record `BlockedReason: T1-LINE-BUDGET` in the rule-changes artifact and follow the P4-T4 BLOCKED procedure.
- [x] [P4-T7] Final corpus run with the changed validator. Run CR-CORPUS through the scratchpad route with `$Mode = 'final'`, `$CorpusSha` = the P4-T1 value, and `$InitialArtifact` = the P4-T1 artifact path. Write `<FEATURE>/evidence/qa-gates/corpus-run.final.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (the summary lines and the three `CORPUS-TP-*` count lines), and the full output. Acceptance:
  - `CORPUS-SHA:` equals the P4-T1 `CorpusSha:`;
  - `CORPUS-RAW:`, `CORPUS-ARTIFACTS:`, and `CORPUS-RULE3-EVALUATED:` equal the P4-T2 values;
  - `CORPUS-FALSE-POSITIVE: 0`, `CORPUS-TP-DROPPED: 0`, `CORPUS-TP-ADDED-UNEXPLAINED: 0`, and `CORPUS-UNEXPECTED: 0`;
  - `EXIT_CODE_COMPUTED: 0` and process exit code 0.

  Each `CORPUS-TP-ADDED-ITEM:` line, which can only read `EXPLAINED` here, is listed in the rule-changes artifact under `## Newly visible true positives`. When this acceptance is not met, apply the phase re-entry bound.
- [x] [P4-T8] Claude suites gate with the corpus tests (as P3-T9, same exclusions). Run CR-PESTER-LIST with `<LIST>` = LIST-CLAUDE-SUITES, `<TAGS-OUT>` = `E4-TR1`, `E4-TR4`, and `<PATTERNS>` = `E4-CORPUS-*`, `E4-TR6*`, `E4-ST4*`, `E4-TR5-P*`, `TG*`, `F824-*`, and the four GUARD-PATTERNS. Write `<FEATURE>/evidence/qa-gates/phase4-corpus-pester.<ts>.md`. Acceptance:
  - `NAMED: E4-CORPUS-* | Passed=<E4-CORPUS-ROWS> | Failed=0`, using the `E4-CORPUS-ROWS:` value of the rule-changes artifact (with `Total=0` when it is 0);
  - `NAMED: E4-TR6* | Passed=4 | Failed=0`, `NAMED: E4-ST4* | Passed=3 | Failed=0`, `NAMED: E4-TR5-P* | Passed=6 | Failed=0`;
  - each `S1`, `S2`, `S6` GUARD-PATTERN line `Passed=2 | Failed=0`, and `NAMED: N1:* | Passed=2 | Failed=0` (N1 rule);
  - either `TOTAL:` with `Failed=0` and `EXIT_CODE_COMPUTED: 0`, or, when every `FAILED:` line meets the PEF, `EXIT_CODE_COMPUTED: 1`, process exit code 1, and an artifact recording `ExpectedExitCode: 1` and `PRE-EXISTING-STILL-FAILING:` (PEF).
- [x] [P4-T9] Record the gate verdict. Append to the rule-changes artifact (Phase 4 introduction; the `<FEATURE>/evidence/other/corpus-rule-changes.<ts>.md` file of the latest P4-T4 first pass or restart) the lines `InitialFalsePositives: <P4-T2 value>`, `FinalFalsePositives: <P4-T7 value>`, `FinalArtifact: <P4-T7 path>`, `SuitesGateArtifact: <P4-T8 path>`, and `CorpusGate: PASS`. Write `CorpusGate: PASS` only when P4-T5, P4-T6, P4-T7, and P4-T8 met their acceptance. Acceptance: the artifact contains exactly one `CorpusGate:` line and it reads `CorpusGate: PASS`.
- [x] [P4-T10] Commit and push Phase 4 before the blocking switch. Run `git add .claude/hooks/validate-feature-review-coverage.ps1 .claude/hooks/validate-feature-review-coverage-rules.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 <FEATURE>/evidence <FEATURE>/plan.2026-10-11T07-58.md`, then `git commit -m "fix(896): corpus false-positive gate before the blocking switch"`, then `git push origin HEAD:<BRANCH>`. Acceptance: `git status --porcelain` prints nothing, and after `git fetch origin <BRANCH>`, `git rev-parse HEAD` equals `git rev-parse origin/<BRANCH>`.

### Phase 5 — Claude Hook Transport, Consumer Policy, and Dependency Handling

Amendment 2026-10-11 pointer. Phase 4 may have changed `Get-ReviewArtifactInfo` or `Test-LanguageCoverageRow` in H3, or the same-folder-and-timestamp comparison in H1. Each change is recorded in `<FEATURE>/evidence/other/corpus-rule-changes.<ts>.md`. Base line numbers cited from here on locate content as of the base (PI-6), and each task here keeps the Phase 4 version of a changed region:
- P5-T2 adds `Repairable` to the same six failure returns, which Phase 4 constraint C2 kept.
- P5-T3 moves the current validation body, including any Phase 4 change, into the script block.
- P5-T6 also converts every `E4-CORPUS` row that calls `Invoke-FeatureReviewCoverageValidation -RawPayload` to `-InputText` with the T1 envelope shape it states, so its `RawPayload` absence check holds.

- [x] [P5-T1] Edit H1: add the `subagentstop-envelope.ps1` guarded dot-source line quoted under Guarded Dot-Source Literals immediately after the rules line (E1 consumer rule 4; AC-31). Acceptance: CR-TEXT with `<CHECKS>` = `@{ Path = <H1>; Present = @(<the quoted subagentstop-envelope.ps1 line>) }` prints `TEXT-CHECK-FAILURES: 0`.
- [x] [P5-T2] Edit `Test-LanguageCoverageRow` in H3: add `Repairable = $true` to the five repairable failure returns (base lines 293-296, 301-304, 311-314, 319-322, 328-331) and `Repairable = $false` to the branch-floor return (base lines 336-339), as stated under Decision Function Shape; the success return is unchanged. Acceptance: CR-PARSE with `<LIST>` = H3 prints `errors=0`, and CR-TEXT with `<CHECKS>` = `@{ Path = <H3>; Present = @('Repairable = $true', 'Repairable = $false') }` prints `TEXT-CHECK-FAILURES: 0`.
- [x] [P5-T3] Rewrite `Invoke-FeatureReviewCoverageValidation` in H1 to the Decision Function Shape: replace `[string] $RawPayload` with `[AllowNull()] [AllowEmptyString()] [string] $InputText`; keep the first two statements verbatim (base lines 351-352); read the envelope with `Read-SubagentStopEnvelope -InputText $InputText` when the parameter is bound and `Read-SubagentStopEnvelope` otherwise; return the payload-anomaly result for an invalid envelope (E1 consumer rule 1); move the base validation (lines 365-459) into the script block inside `try`, replacing the JSON parse and `output` property blocks (base lines 354-368) with `$agentOutput = [string]$envelope.AssistantText`, converting returns to the finding shape, and re-prefixing messages (PI-4); add the `catch` and the re-entry tail (E1 consumer rule 2). Leave the `CLAUDE.md` read (`Get-ArtifactFileContent -Path 'CLAUDE.md'`, base line 444) in place for Phase 6. Acceptance: CR-PARSE with `<LIST>` = H1 prints `errors=0`, and CR-TEXT with `<CHECKS>` = `@{ Path = <H1>; Present = @("`$dependencyDecision = Get-HookDependencyFailureDecision -HookEvent SubagentStop -ReasonPrefix 'validate-feature-review-coverage:'", 'if ($null -ne $dependencyDecision) { return $dependencyDecision }', 'Read-SubagentStopEnvelope -InputText $InputText', 'payload anomaly - ', 'validator error: ', 'HasRepairable'); Absent = @('[string] $RawPayload', 'ConvertFrom-Json', 'feature-review hook:') }` prints `TEXT-CHECK-FAILURES: 0`.
- [x] [P5-T4] Edit the H1 entry point (base lines 471-477): replace the `CLAUDE_HOOK_INPUT` call and the `Write-Error`/`exit 1` block with the four entry statements under Decision Function Shape (E1 consumer rules 5 and 6); base lines 464-469 stay unchanged and in place. Acceptance: CR-PARSE with `<LIST>` = H1 prints `errors=0`, and CR-TEXT with `<CHECKS>` = `@{ Path = <H1>; Present = @("if (`$script:HookDependencyGuardLoadFailed) { [Console]::Error.WriteLine('validate-feature-review-coverage: hook-dependency-guard.ps1 failed to load; the gate fails closed.'); exit 2 }", 'if ($null -ne $dependencyDecision) { [Console]::Error.WriteLine($dependencyDecision.Reason); exit $dependencyDecision.ExitCode }', 'Exit-SubagentStopBlock -Message $result.Message'); Absent = @('Write-Error', 'exit 1', '$env:CLAUDE_HOOK_INPUT', 'RawPayload') }` prints `TEXT-CHECK-FAILURES: 0`.
- [x] [P5-T5] Edit the H1 comment-based help `.NOTES` (base lines 40-42): state that the hook reads the SubagentStop envelope from stdin through `Read-SubagentStopEnvelope`, exits 0 to allow, and blocks through `Exit-SubagentStopBlock` (stderr reason, exit 2) on every block path including payload anomalies and validator errors; that dependency failures block through the inline guard tail; and that a non-repairable condition blocks once and does not block again when `stop_hook_active` is true. Keep the precedence text with "falls back independently" (base lines 29-35). Acceptance: CR-TEXT with `<CHECKS>` = `@{ Path = <H1>; Present = @('Exit-SubagentStopBlock', 'falls back independently'); Absent = @('CLAUDE_HOOK_INPUT') }` prints `TEXT-CHECK-FAILURES: 0`.
- [x] [P5-T6] Convert T1 `tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1` lines 26-135: in each of the four tests, replace the `@{ output = <text> } | ConvertTo-Json -Compress` payload with `[ordered]@{ session_id = 't1-896'; hook_event_name = 'SubagentStop'; agent_type = 'feature-review'; stop_hook_active = $false; last_assistant_message = <text> } | ConvertTo-Json -Compress` and call `Invoke-FeatureReviewCoverageValidation -InputText $raw`; assertions are unchanged. Acceptance: CR-PARSE with `<LIST>` = T1 prints `errors=0`, and CR-TEXT with `<CHECKS>` = `@{ Path = <T1>; Present = @('-InputText $raw', 'last_assistant_message'); Absent = @('RawPayload', 'CLAUDE_HOOK_INPUT', 'output = ') }` prints `TEXT-CHECK-FAILURES: 0`.
- [x] [P5-T7] Convert T2 `Context 'Invoke-FeatureReviewCoverageValidation'` (lines 200-280): replace `ConvertTo-ReviewPayload` with `ConvertTo-ReviewEnvelope -Output` (returns the T1 envelope shape with `last_assistant_message = $Output`); change the empty-payload test to `-InputText ''` and the malformed-payload test to `-InputText '{not json'`, each asserting `Ok` false and `Message` like `validate-feature-review-coverage: payload anomaly - *`; change the empty-output test to `-InputText (ConvertTo-ReviewEnvelope -Output '')`, asserting `Ok` false and `Message.StartsWith('validate-feature-review-coverage:', [System.StringComparison]::Ordinal)`; every other call passes `-InputText (ConvertTo-ReviewEnvelope -Output <former output>)` with its assertions unchanged. Delete `Context 'entry point'` (lines 282-295), which asserts the base `Write-Error` exit-1 path (comment at line 292). Acceptance: CR-PARSE with `<LIST>` = T2 prints `errors=0`, and CR-TEXT with `<CHECKS>` = `@{ Path = <T2>; Present = @('ConvertTo-ReviewEnvelope'); Absent = @('RawPayload', 'CLAUDE_HOOK_INPUT', 'blocks through Write-Error') }` prints `TEXT-CHECK-FAILURES: 0`.
- [x] [P5-T8] In T2 `Context 'E4 (issue #896)'`, add: `It 'E4-TR2: a valid envelope whose advertised artifact does not exist blocks'` (`$text = Use-E4Fixture -Name 'AbsentArtifact'`; assert the decision with `-InputText (ConvertTo-ClaudeEnvelope -AssistantText $text)` returns `Ok` false and a `Message` containing `no file exists at that location`; assert `Invoke-ClaudeReviewEntry` with the same envelope returns `ExitCode` 2 and stderr containing `no file exists at that location`); `It 'E4-TR3: an unhandled exception in the decision blocks with a validator error and exit 2'` (`Use-E4Fixture -Name 'ValidatorError'`; entry with `stop_hook_active` false; assert `ExitCode` 2 and stderr containing `validator error`); `It 'E4-TR3b: the <Anomaly> anomaly blocks with the E1 anomaly clause' -ForEach @(@{ Anomaly = 'EmptyPayload'; Stdin = '' }, @{ Anomaly = 'UnparseableJson'; Stdin = '{bad' })` (arrange `$envelope = Read-SubagentStopEnvelope -InputText $Stdin`, assert `[string]$envelope.Anomaly` equals `$Anomaly`, and set `$expected = 'validate-feature-review-coverage: payload anomaly - ' + (<AnomalyReasonCall>)`; assert `Invoke-ClaudeReviewEntry -Stdin $Stdin` returns `ExitCode` 2 and `Stderr.StartsWith($expected, [System.StringComparison]::Ordinal)`; assert `Invoke-FeatureReviewCoverageValidation -InputText $Stdin` returns `Ok` false and `Message` equal to `$expected`). Acceptance: CR-PARSE with `<LIST>` = T2 and `<IT-PATTERNS>` = `E4-TR2:*`, `E4-TR3:*`, `E4-TR3b:*` prints `PARSE-ERROR-COUNT: 0` and an `IT-COUNT:` of 1 for each pattern.
- [x] [P5-T9] Convert T3 `tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1` with the CR-6 helper (spec Proposed Fix item 6): in the `Describe` `BeforeAll`, change `ConvertTo-FeatureReviewPayload` (lines 39-52) to return `[ordered]@{ session_id = 'f824'; hook_event_name = 'SubagentStop'; agent_type = 'feature-review'; stop_hook_active = $false; last_assistant_message = ($outputLines -join "`n") } | ConvertTo-Json -Compress`, and define `Get-ArtifactFileResult -Lines` (as in T2 lines 25-29) and `Set-ReviewArtifactMap -Override <hashtable>` (builds `$map` from the three default artifacts, policy audit `Python coverage PASS`, code review `code`, feature audit `feature`, merged with the overrides; values are multi-line strings). Because the `Set` verb triggers PSScriptAnalyzer rule `PSUseShouldProcessForStateChangingFunctions` (which would block `PSSA-TOTAL: 0`; `.claude/rules/powershell.md:30`), `Set-ReviewArtifactMap` declares `[CmdletBinding(SupportsShouldProcess)]` and performs its only state change as `if ($PSCmdlet.ShouldProcess('ReviewArtifactMap', 'Set')) { $script:ReviewArtifactMap = $map }`. In each of the two F824 Contexts (lines 55-127, 129-256) add a `BeforeEach` with one literal mock: `Mock Get-ArtifactFileContent { param([string] $Path) if ($script:ReviewArtifactMap.ContainsKey($Path)) { Get-ArtifactFileResult -Lines @($script:ReviewArtifactMap[$Path] -split "`n") } else { @{ Exists = $false; Text = $null; Lines = @() } } }`. Rewrite F824-1..F824-8 so each calls `Set-ReviewArtifactMap -Override @{ ... }` with exactly its differing entries (policy-audit text, `artifacts/pr_context.summary.txt`, coverage report, `CLAUDE.md`) and then `Invoke-FeatureReviewCoverageValidation -InputText (ConvertTo-FeatureReviewPayload)`, with each test's original assertions unchanged. Move F824-9 (lines 242-255) into its own `Context` whose `BeforeEach` holds `Mock Get-ArtifactFileContent -MockWith $script:RealGetArtifactFileContent`. In the validation-paths Context (lines 258-288), give each row an `InputText` value and call `-InputText $InputText`: V1 `''` with pattern `payload anomaly`; V2 `'{not json'` with pattern `payload anomaly`; V3 the envelope with an empty `last_assistant_message` (literal JSON `{"session_id":"f824","hook_event_name":"SubagentStop","agent_type":"feature-review","stop_hook_active":false,"last_assistant_message":""}`) with pattern `^validate-feature-review-coverage:`; V4-V8 the same literal JSON shape whose `last_assistant_message` carries the former `output` text (with `\n` escapes), patterns unchanged. Acceptance: CR-PARSE with `<LIST>` = T3 prints `errors=0`, and CR-TEXT with `<CHECKS>` = `@{ Path = <T3>; Present = @('Set-ReviewArtifactMap', 'last_assistant_message', 'SupportsShouldProcess'); Absent = @('RawPayload', 'CLAUDE_HOOK_INPUT', '[scriptblock]::Create') }` prints `TEXT-CHECK-FAILURES: 0`.
- [x] [P5-T10] Convert T4 `tests/scripts/claude-hooks/validate-feature-review-coverage.ThresholdsGuard.Tests.ps1` and add E4-TG4: in `Invoke-ThresholdsGuardHookProcess` (lines 32-50) remove the environment-variable save, set, and restore and instead save `[System.Console]::In`, set it to a `StringReader` over `{"session_id":"tg-896","hook_event_name":"SubagentStop","agent_type":"feature-review","stop_hook_active":false,"last_assistant_message":""}`, and restore it in `finally`; update the comment at line 33 accordingly. In TG3 (lines 101-120) change only the call at line 113 to `Invoke-FeatureReviewCoverageValidation -InputText ''`; its name and its `ExitCode`/`Reason` assertions (lines 118-119) are unchanged (AC-5, AC-31). Add `It 'E4-TG4: <Copy> exits 2 naming subagentstop-envelope.ps1 when the E1 helper dot-source fails' -ForEach` over the same two rows as TG1: `Mock Join-Path { throw 'simulated load failure: subagentstop-envelope.ps1' } -ParameterFilter { $ChildPath -eq 'subagentstop-envelope.ps1' }`, `Initialize-ThresholdsGuardDependencyState`, run `Invoke-ThresholdsGuardHookProcess`, and assert `ExitCode` 2, stderr starting `validate-feature-review-coverage:` (ordinal), and stderr containing `subagentstop-envelope.ps1`. Acceptance: CR-PARSE with `<LIST>` = T4 and `<IT-PATTERNS>` = `E4-TG4:*` prints `PARSE-ERROR-COUNT: 0` and an `IT-COUNT:` of 1, and CR-TEXT with `<CHECKS>` = `@{ Path = <T4>; Present = @("-InputText ''", '$decision.ExitCode | Should -Be 2'); Absent = @('RawPayload', 'CLAUDE_HOOK_INPUT') }` prints `TEXT-CHECK-FAILURES: 0`.
- [x] [P5-T11] In T1, add: `It 'E4-ST1: <File> has no legacy transport or exit-1 block path' -ForEach` over H1, H2, H3 and their three mirrors (six rows; each asserts the file text does not contain `CLAUDE_HOOK_INPUT`, the AST holds no `CommandAst` named `Write-Error`, and no `ExitStatementAst` whose pipeline text is `1`); `It 'E4-ST1: <File> dot-sources the E1 helper through the guarded pattern' -ForEach` over H1 and its mirror (two rows; each asserts the file contains the quoted `subagentstop-envelope.ps1` guarded line); `It 'E4-ST2: Invoke-FeatureReviewCoverageValidation takes InputText and passes it to the E1 reader'` (asserts `(Get-Command Invoke-FeatureReviewCoverageValidation).Parameters.Keys` contains `InputText` and contains neither `RawPayload` nor `AssistantText`, and that the H1 text contains `Read-SubagentStopEnvelope -InputText $InputText`); `It 'E4-ST6: the Issue824 suite declares no Get-ArtifactFileContent mock inside an It block'` (parses T3; for every `CommandAst` named `It`, finds no descendant `CommandAst` named `Mock` whose elements include `Get-ArtifactFileContent`; asserts the `Describe`-level `BeforeAll` script block defines functions `Get-ArtifactFileResult` and `Set-ReviewArtifactMap`; asserts the file text does not contain `[scriptblock]::Create`). Acceptance: CR-PARSE with `<LIST>` = T1 and `<IT-PATTERNS>` = `E4-ST1:*`, `E4-ST2:*`, `E4-ST6:*` prints `PARSE-ERROR-COUNT: 0` and `IT-COUNT:` values 2, 1, 1.
- [x] [P5-T12] Mirror H1 and H3: run CR-MIRROR with `<PAIRS>` = the H1 and H3 pairs, then CR-SHA with `<PAIRS>` = the H1, H2, H3 pairs; write `<FEATURE>/evidence/other/phase5-mirror.<ts>.md`. Acceptance: `COPY-DIFFER-COUNT: 0` and `SHA-DIFFER-COUNT: 0`.
- [x] [P5-T13] Gate: run CR-PESTER-LIST with `<LIST>` = LIST-CLAUDE-SUITES; `<TAGS-OUT>` = `E4-TR4`; `<PATTERNS>` = `E4-TR1:*`, `E4-TR2:*`, `E4-TR3:*`, `E4-TR3b*`, `E4-ST1*`, `E4-ST2:*`, `E4-ST6:*`, `TG1:*`, `TG2:*`, `TG3:*`, `E4-TG4*`, `F824-*`, `B1:*validate-feature-review-coverage*`, `B3:*validate-feature-review-coverage*`, and the four GUARD-PATTERNS; write `<FEATURE>/evidence/qa-gates/phase5-transport-pester.<ts>.md`. Acceptance: `NAMED: E4-TR1:* | Passed=1 | Failed=0`, `NAMED: E4-TR2:* | Passed=1 | Failed=0`, `NAMED: E4-TR3:* | Passed=1 | Failed=0`, `NAMED: E4-TR3b* | Passed=2 | Failed=0`, `NAMED: E4-ST1* | Passed=8 | Failed=0`, `NAMED: E4-ST2:* | Passed=1 | Failed=0`, `NAMED: E4-ST6:* | Passed=1 | Failed=0`, `NAMED: F824-* | Passed=17 | Failed=0`, `NAMED: TG1:* | Passed=2 | Failed=0`, `NAMED: TG2:* | Passed=2 | Failed=0`, `NAMED: TG3:* | Passed=2 | Failed=0`, `NAMED: E4-TG4* | Passed=2 | Failed=0`, `NAMED: B1:*validate-feature-review-coverage* | Passed=4 | Failed=0`, `NAMED: B3:*validate-feature-review-coverage* | Passed=1 | Failed=0`, each `S1`, `S2`, `S6` GUARD-PATTERN line `Passed=2 | Failed=0`, `NAMED: N1:* | Passed=2 | Failed=0` (N1 rule), `TOTAL:` with `Failed=0` and `EXIT_CODE_COMPUTED: 0`, or, when every `FAILED:` line meets the PEF, `EXIT_CODE_COMPUTED: 1`, process exit code 1, and an artifact recording `ExpectedExitCode: 1` and `PRE-EXISTING-STILL-FAILING:` (PEF).
- [x] [P5-T14] AC-6 search: run `git grep -n -e CLAUDE_HOOK_INPUT -e "-RawPayload" -- tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1 tests/scripts/claude-hooks/validate-feature-review-coverage.ThresholdsGuard.Tests.ps1`; write `<FEATURE>/evidence/qa-gates/claude-suites-transport-grep.<ts>.md` with `ExpectedExitCode: 1`. The searched literals are "CLAUDE_HOOK_INPUT" and "-RawPayload"; all four files are tracked. Acceptance: no output and `EXIT_CODE: 1`.
- [x] [P5-T15] Check off AC-2 in `<FEATURE>/spec.md` (P5-T13 `E4-ST1` over repository copies and mirrors). Acceptance: only the AC-2 checkbox changed.
- [x] [P5-T16] Check off AC-3 in `<FEATURE>/spec.md` (P1-T5 base failure; P5-T13 `E4-TR1` passing). Acceptance: only the AC-3 checkbox changed.
- [x] [P5-T17] Check off AC-4 in `<FEATURE>/spec.md` (P5-T13 `E4-TR2`, `E4-TR3`, both `E4-TR3b` rows; P5-T7 removed the line-292 exit-1 test). Acceptance: only the AC-4 checkbox changed.
- [x] [P5-T18] Check off AC-5 in `<FEATURE>/spec.md` (P5-T13 `E4-ST2`, and `TG1`-`TG3` for both copies with TG3 still asserting `ExitCode = 2` and the `Reason`). Acceptance: only the AC-5 checkbox changed.
- [x] [P5-T19] Check off AC-13 in `<FEATURE>/spec.md` (P5-T13 `E4-ST6` and `F824-*` passing). Acceptance: only the AC-13 checkbox changed.
- [x] [P5-T20] Check off AC-31 in `<FEATURE>/spec.md` (P5-T13: the S2 and S6 GUARD-PATTERN rows of `hook-dependency-guard-completeness.Tests.ps1` and both `E4-TG4` rows passing; P5-T4 CR-TEXT shows the inline tail unchanged) only if no `PRE-EXISTING-STILL-FAILING:` entry in the P5-T13 artifact names a test in `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`, that is, its P5-T13 `SUITE:` line reads `Failed=0`; otherwise leave it unchecked and record the reason in `<FEATURE>/evidence/qa-gates/phase5-transport-pester.<ts>.md`. Acceptance: only the AC-31 checkbox changed, or it stays unchecked with the reason recorded.
- [x] [P5-T21] Commit and push Phase 5: `git add .claude/hooks/validate-feature-review-coverage.ps1 .claude/hooks/validate-feature-review-coverage-rules.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks tests/scripts/claude-hooks <FEATURE>/evidence <FEATURE>/spec.md <FEATURE>/plan.2026-10-11T07-58.md`, `git commit -m "fix(896): read the SubagentStop envelope through the E1 helper and block with exit 2"`, `git push origin HEAD:<BRANCH>`. Acceptance: `git status --porcelain` prints nothing and after `git fetch origin <BRANCH>`, `git rev-parse HEAD` equals `git rev-parse origin/<BRANCH>`.

AC-6 is checked off in P6-T11, after P6-T9 runs all four Claude hook suites with no tag exclusion.

### Phase 6 — CR-4 (Unreadable Root CLAUDE.md) and Re-entry Policy Tests

- [x] [P6-T1] Add `Get-FeatureReviewClaudeMdText` to H2 (`[CmdletBinding()]`, `[OutputType([hashtable])]`, no parameters): `try { $file = Get-ArtifactFileContent -Path 'CLAUDE.md'; return @{ Text = $file.Text; ReadError = $null } } catch { return @{ Text = $null; ReadError = ([string]$_.Exception.Message -split "`r?`n")[0] } }`, with comment-based help stating that an absent file yields `Text = $null` and `ReadError = $null`. Acceptance: CR-PARSE with `<LIST>` = H2 prints `errors=0` and a `functions=` list that includes `Get-FeatureReviewClaudeMdText`.
- [x] [P6-T2] Edit the H1 decision script block: replace `Get-ArtifactFileContent -Path 'CLAUDE.md'` with `$claudeMd = Get-FeatureReviewClaudeMdText`; when `$claudeMd.ReadError` is not null return the non-repairable finding `@{ Message = "validate-feature-review-coverage: root CLAUDE.md exists but could not be read ($($claudeMd.ReadError)); coverage floors cannot be resolved, so the gate fails closed."; HasRepairable = $false; HasNonRepairable = $true }`; otherwise pass `$claudeMd.Text` to `Get-FeatureReviewCoverageThreshold`. Acceptance: CR-PARSE with `<LIST>` = H1 prints `errors=0`, and CR-TEXT with `<CHECKS>` = `@{ Path = <H1>; Present = @('Get-FeatureReviewClaudeMdText', 'could not be read'); Absent = @("Get-ArtifactFileContent -Path 'CLAUDE.md'") }` prints `TEXT-CHECK-FAILURES: 0`.
- [x] [P6-T3] Edit the H1 comment-based help to add the two Help-Text Tokens sentences ("an absent root CLAUDE.md uses the defaults"; "an unreadable root CLAUDE.md fails closed") next to the precedence text. Acceptance: CR-TEXT with `<CHECKS>` = `@{ Path = <H1>; Normalize = $true; Present = @('an absent root CLAUDE.md uses the defaults', 'an unreadable root CLAUDE.md fails closed', 'falls back independently') }` prints `TEXT-CHECK-FAILURES: 0`.
- [x] [P6-T4] In T2 `Context 'E4 (issue #896)'`, add `It 'E4-TR4a: an absent root CLAUDE.md applies the default <Metric> floor' -ForEach @(@{ Metric = 'line'; Fixture = 'LineBelowFloor'; Expected = '85% line coverage floor (default)' }, @{ Metric = 'branch'; Fixture = 'BranchBelowFloor'; Expected = '75% branch coverage floor (default)' })` (each row: `$text = Use-E4Fixture -Name $Fixture`; the fixture has policy audit `Python coverage PASS` and no `CLAUDE.md` entry, so the file is absent; the line row's report is `LF:100`, `LH:80`, `BRF:100`, `BRH:80` and the branch row's is `LF:100`, `LH:90`, `BRF:100`, `BRH:70`; call the decision with `-InputText (ConvertTo-ClaudeEnvelope -AssistantText $text)`; assert `Ok` false and `Message.Contains($Expected)`), and `It 'E4-TR4c: the CLAUDE.md reader reports a read error without throwing'` (`Mock Get-ArtifactFileContent -MockWith $script:RealGetArtifactFileContent`, `Mock Test-Path { $true }`, `Mock Get-Content { throw 'simulated read failure: access denied' }`; assert `Get-FeatureReviewClaudeMdText` returns `Text` null and `ReadError` containing `access denied`). Acceptance: CR-PARSE with `<LIST>` = T2 and `<IT-PATTERNS>` = `E4-TR4a:*`, `E4-TR4c:*` prints `PARSE-ERROR-COUNT: 0` and an `IT-COUNT:` of 1 for each pattern.
- [x] [P6-T5] In T2 `Context 'E4 (issue #896)'`, add the AC-30 tests: `It 'E4-TR10a: <Fixture> is repairable with stop_hook_active <Active>' -ForEach` with eight rows (`MissingToken`, `AbsentArtifact`, `NoCoverageRow`, `LineBelowFloor`, each with `Active = $false` and `Active = $true`), asserting the decision result for `-InputText (ConvertTo-ClaudeEnvelope -AssistantText (Use-E4Fixture -Name $Fixture) -StopHookActive $Active)` has `Ok` false and a `Message` that does not contain `cannot repair this condition`; `It 'E4-TR10b: <Fixture> is not repairable with stop_hook_active <Active>' -ForEach` with six rows (`UnreadableClaudeMd`, `BranchBelowFloor`, `ValidatorError`, each with `Active = $false` and `Active = $true`), asserting `Ok` false and a `Message` containing `cannot repair this condition` when `Active` is false, and `Ok` true when `Active` is true; `It 'E4-TR10c: a repairable and a non-repairable coverage condition still block with stop_hook_active true'` (`Mixed`, `-StopHookActive $true`; assert `Ok` false); `It 'E4-TR10d: an unreadable root CLAUDE.md through the entry point exits <ExitCode> with stop_hook_active <Active>' -ForEach @(@{ Active = $false; ExitCode = 2 }, @{ Active = $true; ExitCode = 0 })` (`Invoke-ClaudeReviewEntry -Stdin (ConvertTo-ClaudeEnvelope -AssistantText (Use-E4Fixture -Name 'UnreadableClaudeMd') -StopHookActive $Active)`; assert `ExitCode`). Acceptance: CR-PARSE with `<LIST>` = T2 and `<IT-PATTERNS>` = `E4-TR10a:*`, `E4-TR10b:*`, `E4-TR10c:*`, `E4-TR10d:*` prints `PARSE-ERROR-COUNT: 0` and an `IT-COUNT:` of 1 for each pattern.
- [x] [P6-T6] In T1, update the H2 row of `E4-ST4` to the eight names (the seven P2-T1 names plus `Get-FeatureReviewClaudeMdText`). Acceptance: CR-TEXT with `<CHECKS>` = `@{ Path = <T1>; Present = @('Get-FeatureReviewClaudeMdText') }` prints `TEXT-CHECK-FAILURES: 0`.
- [x] [P6-T7] Mirror H1 and H2: run CR-MIRROR with `<PAIRS>` = the H1 and H2 pairs, then CR-SHA with `<PAIRS>` = the H1, H2, H3 pairs; write `<FEATURE>/evidence/other/phase6-mirror.<ts>.md`. Acceptance: `COPY-DIFFER-COUNT: 0` and `SHA-DIFFER-COUNT: 0`.
- [x] [P6-T8] Run CR-LINES with `<LIST>` = H1, H2, H3, T2, T11; write `<FEATURE>/evidence/qa-gates/phase6-file-size.<ts>.md`. Acceptance: five `LINES:` lines with numeric `count=` and `LINES-OVER-CAP: 0` (T2 below 500 lines after all E4 `It` blocks, with the harness and fixtures held in T11).
- [x] [P6-T9] Gate (no tag exclusion): run CR-PESTER-LIST with `<LIST>` = LIST-CLAUDE-SUITES; `<PATTERNS>` = `E4-TR1:*`, `E4-TR4:*`, `E4-TR4a:*`, `E4-TR4c:*`, `E4-TR10a*`, `E4-TR10b*`, `E4-TR10c*`, `E4-TR10d*`, `E4-ST4*`, `E4-ST1*`, `TG*`, `E4-TG4*`, `F824-*`, `E4-TR5-P*`, and the four GUARD-PATTERNS; write `<FEATURE>/evidence/qa-gates/phase6-cr4-pester.<ts>.md`. Acceptance: `NAMED: E4-TR1:* | Passed=1 | Failed=0`, `NAMED: E4-TR4:* | Passed=1 | Failed=0`, `NAMED: E4-TR4a:* | Passed=2 | Failed=0`, `NAMED: E4-TR4c:* | Passed=1 | Failed=0`, `NAMED: E4-TR10a* | Passed=8 | Failed=0`, `NAMED: E4-TR10b* | Passed=6 | Failed=0`, `NAMED: E4-TR10c* | Passed=1 | Failed=0`, `NAMED: E4-TR10d* | Passed=2 | Failed=0`, `NAMED: E4-ST4* | Passed=3 | Failed=0`, `NAMED: E4-TR5-P* | Passed=6 | Failed=0`, each `S1`, `S2`, `S6` GUARD-PATTERN line `Passed=2 | Failed=0`, `NAMED: N1:* | Passed=2 | Failed=0` (N1 rule), `TOTAL:` with `Failed=0` and `EXIT_CODE_COMPUTED: 0`, or, when every `FAILED:` line meets the PEF, `EXIT_CODE_COMPUTED: 1`, process exit code 1, and an artifact recording `ExpectedExitCode: 1` and `PRE-EXISTING-STILL-FAILING:` (PEF).
- [x] [P6-T10] Check off AC-7 in `<FEATURE>/spec.md` (P6-T9 both `E4-TR4a` rows and `E4-TR4`; P1-T5 base failure of `E4-TR4`). Acceptance: only the AC-7 checkbox changed.
- [x] [P6-T11] Check off AC-6 in `<FEATURE>/spec.md` (P5-T14 empty search; P6-T9 all four Claude hook suites passing with no exclusion). Acceptance: only the AC-6 checkbox changed.
- [x] [P6-T12] Check off AC-30 in `<FEATURE>/spec.md` (P6-T9 `E4-TR10a` through `E4-TR10d`). Acceptance: only the AC-30 checkbox changed.
- [x] [P6-T13] Commit and push Phase 6: `git add .claude/hooks/validate-feature-review-coverage.ps1 .claude/hooks/validate-feature-review-coverage-metrics.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks tests/scripts/claude-hooks <FEATURE>/evidence <FEATURE>/spec.md <FEATURE>/plan.2026-10-11T07-58.md`, `git commit -m "fix(896): fail closed on an unreadable root CLAUDE.md (CR-4) and pin the re-entry policy"`, `git push origin HEAD:<BRANCH>`. Acceptance: `git status --porcelain` prints nothing and after `git fetch origin <BRANCH>`, `git rev-parse HEAD` equals `git rev-parse origin/<BRANCH>`.

### Phase 7 — Codex Hook Floor Source (#884 Codex half)

- [x] [P7-T1] Create H6 `.codex/hooks/feature-review-coverage-thresholds.ps1` as a byte copy of H4: run CR-MIRROR with `<PAIRS>` = `@{ Source = '.claude/hooks/feature-review-coverage-thresholds.ps1'; Mirror = '.codex/hooks/feature-review-coverage-thresholds.ps1' }`; write `<FEATURE>/evidence/other/phase7-thresholds-copy.<ts>.md`. Acceptance: one `COPIED:` line ending `MATCH` and `COPY-DIFFER-COUNT: 0`.
- [x] [P7-T2] Edit H5 `.codex/hooks/validate-feature-review-coverage.ps1`: add the H5 guarded dot-source line quoted under Guarded Dot-Source Literals immediately after line 43. Acceptance: CR-TEXT with `<CHECKS>` = `@{ Path = <H5>; Present = @(<the quoted H5 line>) }` prints `TEXT-CHECK-FAILURES: 0`.
- [x] [P7-T3] Edit `Test-LanguageCoverageRow` in H5 (lines 142-207): add `[double] $LineFloor = 85.0`; replace `-lt 80.0` (line 196) with `-lt $LineFloor`; replace the line-201 message with `("{0} repo-wide coverage is {1}% (below the {2}% line coverage floor) but the policy-audit contains no FAIL verdict on a coverage row for {0}." -f $Language, $RepoWidePct, $LineFloor)`. Acceptance: CR-PARSE with `<LIST>` = H5 prints `errors=0`, and CR-TEXT with `<CHECKS>` = `@{ Path = <H5>; Present = @('[double] $LineFloor = 85.0', '-lt $LineFloor'); Absent = @('80.0') }` prints `TEXT-CHECK-FAILURES: 0`.
- [x] [P7-T4] Edit the H5 entry (lines 264-290): after the `$changedLanguages.Count -eq 0` exit (lines 267-269), add `$claudeMdPath = Join-Path $repoRoot 'CLAUDE.md'`, `$claudeMdText = $null`, `if (Test-Path -Path $claudeMdPath) { try { $claudeMdText = Get-Content -Path $claudeMdPath -Raw -ErrorAction Stop } catch { throw "root CLAUDE.md exists but could not be read ($(([string]$_.Exception.Message -split "`r?`n")[0])); coverage floors cannot be resolved, so the gate fails closed." } }`, and `$thresholds = Get-FeatureReviewCoverageThreshold -ClaudeMdText $claudeMdText`; pass `-LineFloor $thresholds.Line` in the line-275 call; replace the line-284 footer text `below 80%` with `below the governing line coverage floor ($($thresholds.Line)%)`. Use `-Path` (not `-LiteralPath`) and no `-PathType` argument, matching the existing Codex reads (for example line 69) and the existing mocks' `param($Path)` binding. Keep the stdin read, `stop_hook_active` handling, continuation output, and catch (lines 237-262, 286-304) unchanged. Acceptance: CR-PARSE with `<LIST>` = H5 prints `errors=0`, and CR-TEXT with `<CHECKS>` = `@{ Path = <H5>; Present = @('Get-FeatureReviewCoverageThreshold -ClaudeMdText $claudeMdText', '-LineFloor $thresholds.Line'); Absent = @('80%') }` prints `TEXT-CHECK-FAILURES: 0`.
- [x] [P7-T5] Edit the H5 comment-based help (lines 22-25): replace the 80-percent text with the governing-floor statement (root `CLAUDE.md` line threshold when stated, otherwise the 85 percent default; the Codex hook enforces the line floor only) including the two Help-Text Tokens sentences; add no `python` token. Acceptance: CR-TEXT with `<CHECKS>` = `@{ Path = <H5>; Normalize = $true; Present = @('an absent root CLAUDE.md uses the defaults', 'an unreadable root CLAUDE.md fails closed'); Absent = @('80.0', '80%', '80 percent') }` prints `TEXT-CHECK-FAILURES: 0`.
- [x] [P7-T6] In T6, change the `low coverage without FAIL` row (line 135) pattern from `below the 80% floor` to `below the 85% line coverage floor`. Acceptance: CR-TEXT with `<CHECKS>` = `@{ Path = <T6>; Present = @('below the 85% line coverage floor'); Absent = @('80% floor') }` prints `TEXT-CHECK-FAILURES: 0`.
- [x] [P7-T7] In T6 `Context 'entry point'`, add `It 'E4-TR8: a CLAUDE.md line floor of 70 lets a 72% row pass'` (the P1-T4 `Test-Path` and `Get-ChildItem` mocks, and the P1-T4 `Get-Content` mock with `@('LF:100', 'LH:72')` for paths ending `lcov.info` and `Line coverage >= 70%` for paths ending `CLAUDE.md`; assert `ExitCode` 0 and empty `Stdout`) and `It 'E4-TR9: an unreadable CLAUDE.md <Case>' -ForEach` with two rows that both use the P1-T4 `Test-Path`, `Get-ChildItem`, and `Get-Content` mocks except that `Get-Content` throws `simulated read failure: access denied` for paths ending `CLAUDE.md` (literal: `Mock Get-Content { param($Path) $p = [string]$Path; if ($p.EndsWith('CLAUDE.md')) { throw 'simulated read failure: access denied' } elseif ($p.EndsWith('pr_context.summary.txt')) { @('- src/a.py (+1/-0)') } elseif ($p.EndsWith('lcov.info')) { @('LF:1000', 'LH:805') } else { 'Python coverage PASS' } }`): `stop_hook_active false exits 2` (stdin `$script:ReviewStop`; assert `ExitCode` 2 and `Stderr` containing `root CLAUDE.md` and `could not be read`) and `stop_hook_active true emits continue false` (stdin `$script:ReviewStopActive`; assert `ExitCode` 0, `Stdout` containing `"continue":false`, and `($result.Stdout | ConvertFrom-Json).continue` false). Add `It 'E4-ST7: the Codex hook reads the floor from its own thresholds copy'` that reads H5 and asserts: the text contains the H5 guarded line; no dot-source `CommandAst` (invocation operator `Dot`) has an extent containing `.claude`; the text contains neither `subagentstop-envelope.ps1` nor `Exit-SubagentStopBlock`; the text contains none of `80.0`, `80%`, `80 percent`. Acceptance: CR-PARSE with `<LIST>` = T6 and `<IT-PATTERNS>` = `E4-TR8:*`, `E4-TR9:*`, `E4-ST7:*` prints `PARSE-ERROR-COUNT: 0` and an `IT-COUNT:` of 1 for each pattern.
- [x] [P7-T8] Create T7 `tests/scripts/codex-hooks/feature-review-coverage-thresholds.Tests.ps1` (Pester 5; `#Requires -Version 7.0`; header help stating the determinism rules): `It 'E4-PX2: the four thresholds copies are byte-identical'` asserting equal `Get-FileHash -Algorithm SHA256` values for `.claude/hooks/feature-review-coverage-thresholds.ps1`, `.codex/hooks/feature-review-coverage-thresholds.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/feature-review-coverage-thresholds.ps1`, and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/feature-review-coverage-thresholds.ps1` (located from `$PSScriptRoot` with `Join-Path`); and `It 'E4-PX2-<Id> the Codex copy resolves <Label>' -ForEach` carrying the eleven T824 rows of T5 lines 28-38 and the nine E4-TR5 rows of P1-T3, run against the `.codex/hooks/` copy dot-sourced in `BeforeAll`. Acceptance: CR-PARSE with `<LIST>` = T7 and `<IT-PATTERNS>` = `E4-PX2:*`, `E4-PX2-*` prints `PARSE-ERROR-COUNT: 0` and an `IT-COUNT:` of 1 for each pattern (the twenty rows are counted by P7-T13).
- [x] [P7-T9] Edit T9 `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` line 30: append `, 'feature-review-coverage-thresholds.ps1'` inside the `$script:SharedModuleNames` array on the same line. Acceptance: CR-LINES with `<LIST>` = T9 prints `count=497`, and CR-TEXT with `<CHECKS>` = `@{ Path = <T9>; Present = @("'hook-dependency-guard.ps1', 'feature-review-coverage-thresholds.ps1')") }` prints `TEXT-CHECK-FAILURES: 0`.
- [x] [P7-T10] Edit P2 `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`: insert `".codex/hooks/feature-review-coverage-thresholds.ps1",` after line 46 (`.codex/hooks/feature-folder-resolution.ps1`). Acceptance: CR-JSON with `<MANIFEST>` = P2 and `<ENTRIES>` = `.codex/hooks/feature-review-coverage-thresholds.ps1` prints `JSON-MISSING-COUNT: 0`.
- [x] [P7-T11] Mirror H5 and H6 to `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`: run CR-MIRROR with `<PAIRS>` = the H5 and H6 pairs, then CR-SHA with `<PAIRS>` = the H4, H5, H6 pairs and the `.claude`-to-`.codex` thresholds pair; write `<FEATURE>/evidence/other/phase7-mirror.<ts>.md`. Acceptance: `COPY-DIFFER-COUNT: 0`, four `SHA:` lines ending `MATCH`, and `SHA-DIFFER-COUNT: 0`.
- [x] [P7-T12] In T1, add `It 'E4-ST3: <File> help states the absent and unreadable CLAUDE.md rules' -ForEach` over H1 and H5: each row reads the file's first comment block (the script-level help), collapses whitespace runs to one space, and asserts it contains "an absent root CLAUDE.md uses the defaults" and "an unreadable root CLAUDE.md fails closed"; the H1 row also asserts "falls back independently". Acceptance: CR-PARSE with `<LIST>` = T1 and `<IT-PATTERNS>` = `E4-ST3*` prints `PARSE-ERROR-COUNT: 0` and an `IT-COUNT:` of 1.
- [x] [P7-T13] Gate: run CR-PESTER-LIST with `<LIST>` = T6, T7, T9, `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1`, `tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1`, T1, and LIST-RUNTIME-SUITES; no tag filters; `<PATTERNS>` = `E4-TR7:*`, `E4-TR8:*`, `E4-TR9:*`, `E4-ST7:*`, `E4-PX2*`, `E4-ST3*`, `uses one SubagentStop continuation*`, `S2:*.codex/hooks/validate-feature-review-coverage.ps1*`, `N1:*`; write `<FEATURE>/evidence/qa-gates/phase7-codex-pester.<ts>.md`. Acceptance: `NAMED: E4-TR7:* | Passed=1 | Failed=0`, `NAMED: E4-TR8:* | Passed=1 | Failed=0`, `NAMED: E4-TR9:* | Passed=2 | Failed=0`, `NAMED: E4-ST7:* | Passed=1 | Failed=0`, `NAMED: E4-PX2* | Passed=21 | Failed=0`, `NAMED: E4-ST3* | Passed=2 | Failed=0`, the continuation pattern `Passed=1 | Failed=0`, `NAMED: S2:*.codex/hooks/validate-feature-review-coverage.ps1* | Passed=2 | Failed=0`, `NAMED: N1:* | Passed=2 | Failed=0` (N1 rule), `TOTAL:` with `Failed=0` and `EXIT_CODE_COMPUTED: 0`, or, when every `FAILED:` line meets the PEF, `EXIT_CODE_COMPUTED: 1`, process exit code 1, and an artifact recording `ExpectedExitCode: 1` and `PRE-EXISTING-STILL-FAILING:` (PEF).
- [x] [P7-T14] AC-17 configuration check: run `git diff --name-only origin/epic/subagentstop-envelope-integration...HEAD -- .codex/config.toml extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml` and `git status --porcelain -- .codex/config.toml extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml`; write `<FEATURE>/evidence/qa-gates/codex-config-unchanged.<ts>.md`. Acceptance: both commands print nothing.
- [x] [P7-T15] Check off AC-14 in `<FEATURE>/spec.md` (P7-T13 `E4-PX2`). Acceptance: only the AC-14 checkbox changed.
- [x] [P7-T16] Check off AC-15 in `<FEATURE>/spec.md` (P7-T13 `E4-ST7`). Acceptance: only the AC-15 checkbox changed.
- [x] [P7-T17] Check off AC-16 in `<FEATURE>/spec.md` (P1-T5 base failure of `E4-TR7`; P7-T13 `E4-TR7`, `E4-TR8`, both `E4-TR9` rows). Acceptance: only the AC-16 checkbox changed.
- [x] [P7-T18] Check off AC-17 in `<FEATURE>/spec.md` (P7-T13 legacy, dependency-failure, and probe suites passing; P7-T14 empty diff) only if no `PRE-EXISTING-STILL-FAILING:` entry in the P7-T13 artifact names a test in T9, `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1`, or `tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1`, that is, the P7-T13 `SUITE:` line of each of those three files reads `Failed=0`; otherwise leave it unchecked and record the reason in `<FEATURE>/evidence/qa-gates/phase7-codex-pester.<ts>.md`. Acceptance: only the AC-17 checkbox changed, or it stays unchecked with the reason recorded.
- [x] [P7-T19] Commit and push Phase 7: `git add .codex/hooks/validate-feature-review-coverage.ps1 .codex/hooks/feature-review-coverage-thresholds.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json tests/scripts/codex-hooks tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 <FEATURE>/evidence <FEATURE>/spec.md <FEATURE>/plan.2026-10-11T07-58.md`, `git commit -m "fix(896): read the Codex feature-review line floor from root CLAUDE.md (Refs #884)"`, `git push origin HEAD:<BRANCH>`. Acceptance: `git status --porcelain` prints nothing and after `git fetch origin <BRANCH>`, `git rev-parse HEAD` equals `git rev-parse origin/<BRANCH>`.

### Phase 8 — Claude and Codex Floor Parity

- [x] [P8-T1] Create T8 `tests/scripts/codex-hooks/feature-review-coverage-floor-parity.Tests.ps1` (Pester 5; header help): define `Get-FloorFromReason` (returns the number captured by `below the (?<floor>\d+(?:\.\d+)?)% line coverage floor`); define `Get-ClaudeFloorReason -ClaudeMdText` as `& { param($HookPath, $Text) . $HookPath; $t = Get-FeatureReviewCoverageThreshold -ClaudeMdText $Text; (Test-LanguageCoverageRow -AuditText 'Python coverage PASS' -Language 'Python' -RepoWidePct 60 -LineFloor $t.Line -LineSource $t.LineSource).Reason } <H1 path> $ClaudeMdText` and `Get-CodexFloorReason -ClaudeMdText` with the same shape over the H5 path and `-LineFloor $t.Line` (so each hook loads in its own child scope); add `It 'E4-PX1: <Label> reports line floor <Floor> on both surfaces' -ForEach` with rows `no figure` (`Project notes without coverage figures.`, 85), `comparator form` (`Line coverage >= 70%`, 70), `trailing form` (`line coverage: 92% minimum`, 92), each asserting the Claude floor equals the Codex floor equals the row's `Floor`. Acceptance: CR-PARSE with `<LIST>` = T8 and `<IT-PATTERNS>` = `E4-PX1:*` prints `PARSE-ERROR-COUNT: 0` and an `IT-COUNT:` of 1.
- [x] [P8-T2] Gate: run CR-PESTER-LIST with `<LIST>` = T8; `<PATTERNS>` = `E4-PX1*`; write `<FEATURE>/evidence/qa-gates/phase8-parity-pester.<ts>.md`. Acceptance: `NAMED: E4-PX1* | Passed=3 | Failed=0`, `EXIT_CODE_COMPUTED: 0`.
- [x] [P8-T3] Check off AC-19 in `<FEATURE>/spec.md`. Acceptance: only the AC-19 checkbox changed.
- [x] [P8-T4] Commit and push Phase 8: `git add tests/scripts/codex-hooks/feature-review-coverage-floor-parity.Tests.ps1 <FEATURE>/evidence <FEATURE>/spec.md <FEATURE>/plan.2026-10-11T07-58.md`, `git commit -m "test(896): pin Claude and Codex feature-review floor parity"`, `git push origin HEAD:<BRANCH>`. Acceptance: `git status --porcelain` prints nothing and after `git fetch origin <BRANCH>`, `git rev-parse HEAD` equals `git rev-parse origin/<BRANCH>`.

### Phase 9 — Skill and Agent Texts

- [x] [P9-T1] Edit S1 `.agents/skills/feature-review-workflow/SKILL.md` lines 111-114: replace the four threshold lines with "Coverage thresholds: when the repository's root `CLAUDE.md` states a line or branch coverage threshold, that threshold governs; otherwise the defaults govern (line 85%, branch 75% for branch-capable languages). Each metric falls back independently. New files and modified files must meet the governing line threshold (and the branch threshold where measured); modified files must also show no regression on changed lines. Repo-wide coverage per language must meet the governing thresholds. Flag as FAIL otherwise." (research Q9, `research.2026-10-11T08-10.md:312`), keeping the list indentation of line 111. Acceptance: CR-TEXT with `<CHECKS>` = `@{ Path = <S1>; Present = @('CLAUDE.md', '85%', '75%') }` prints `TEXT-CHECK-FAILURES: 0`.
- [x] [P9-T2] Edit S1 line 148: replace it with "coverage below the governing thresholds defined in step 5 (repo-wide per language, modified files including any regression on changed lines, or new files)", keeping its indentation. Acceptance: CR-TEXT with `<CHECKS>` = `@{ Path = <S1>; Present = @('governing thresholds'); Absent = @('80%', '90%') }` prints `TEXT-CHECK-FAILURES: 0`.
- [x] [P9-T3] Edit S2 `.github/skills/feature-review-workflow/SKILL.md` line 126: replace it with "coverage below the governing thresholds (the root `CLAUDE.md` thresholds when stated, otherwise the defaults: line 85%, branch 75% for branch-capable languages; repo-wide per language, modified files including any regression on changed lines, or new files)", keeping its indentation. Acceptance: CR-TEXT with `<CHECKS>` = `@{ Path = <S2>; Present = @('CLAUDE.md', '85%', '75%', 'governing thresholds'); Absent = @('80%', '90%') }` prints `TEXT-CHECK-FAILURES: 0`.
- [x] [P9-T4] Edit S3 `.codex/agents/feature-review.toml` lines 121-123: replace the three bullets with the P9-T1 statement adapted to bullets (root `CLAUDE.md` governs when it states a threshold; otherwise line 85% and branch 75% for branch-capable languages; each metric falls back independently; new and modified files meet the governing line threshold; modified files show no regression on changed lines; repo-wide coverage meets the governing thresholds). Acceptance: CR-TEXT with `<CHECKS>` = `@{ Path = <S3>; Present = @('CLAUDE.md', '85%', '75%') }` prints `TEXT-CHECK-FAILURES: 0`.
- [x] [P9-T5] Edit S3 lines 133-135: replace each fixed figure with "below the governing line threshold" wording (repo-wide; each new file; each modified file, including regression from baseline). Acceptance: CR-TEXT with `<CHECKS>` = `@{ Path = <S3>; Present = @('governing line threshold'); Absent = @('80%', '90%') }` prints `TEXT-CHECK-FAILURES: 0`.
- [x] [P9-T6] Mirror S1, S2, S3: run CR-MIRROR with `<PAIRS>` = the S1, S2, S3 pairs of LIST-MIRROR-PAIRS; write `<FEATURE>/evidence/other/phase9-mirror.<ts>.md`. Acceptance: three `COPIED:` lines ending `MATCH` and `COPY-DIFFER-COUNT: 0`.
- [x] [P9-T7] Edit T10 `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`: extend `STEP_EIGHT_COPIES` (lines 70-73) with `".agents/skills/feature-review-workflow/SKILL.md"`, `CODEX_BUNDLE + ".agents/skills/feature-review-workflow/SKILL.md"`, `".github/skills/feature-review-workflow/SKILL.md"`, `GITHUB_BUNDLE + ".github/skills/feature-review-workflow/SKILL.md"`; set `EXPECTED_LISTED_COPY_COUNT` (line 94) to `40`; add `FEATURE_REVIEW_TEXT_COPIES` (the six `feature-review-workflow/SKILL.md` copies and both `.codex/agents/feature-review.toml` copies), `CLAUDE_MD_FLOOR_SOURCE = "CLAUDE.md"`, `DEFAULT_FLOOR_FIGURES = ("85%", "75%")`, and a fully annotated `@pytest.mark.parametrize("relative_path", FEATURE_REVIEW_TEXT_COPIES)` test `test_feature_review_texts_name_claude_md_floor_source(relative_path: str) -> None` with a docstring and Arrange/Act/Assert sections asserting the file contains neither `80%` nor `90%`, contains `CLAUDE.md`, and contains `85%` and `75%`. Do not add the new tuple to the `listed` tuple of `test_every_follow_up_copy_exists`. Acceptance: `poetry run python -m py_compile tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` exits 0 and CR-LINES with `<LIST>` = T10 prints `LINES-OVER-CAP: 0`.
- [x] [P9-T8] Gate: run `poetry run pytest "tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py::test_feature_review_texts_name_claude_md_floor_source"`; write `<FEATURE>/evidence/qa-gates/phase9-texts-pytest.<ts>.md`. Acceptance: the summary line reads `8 passed` with no failure.
- [x] [P9-T9] Gate: run `poetry run pytest "tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py::test_review_workflow_step_eight_uses_governing_thresholds" "tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py::test_every_follow_up_copy_exists"`; write `<FEATURE>/evidence/qa-gates/phase9-step-eight-pytest.<ts>.md`. Acceptance: the summary line reads `7 passed` with no failure (six step-8 copies plus the existence test).
- [x] [P9-T10] Gate: run `poetry run pytest tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py`; write `<FEATURE>/evidence/qa-gates/phase9-module-pytest.<ts>.md`. Acceptance: the summary line has a numeric `passed` count and no `failed` count.
- [x] [P9-T11] AC-22 check: run `git diff --name-only origin/epic/subagentstop-envelope-integration...HEAD -- .github/instructions .claude/rules` and `git status --porcelain -- .github/instructions .claude/rules`; write `<FEATURE>/evidence/qa-gates/policy-files-unchanged.<ts>.md`. Acceptance: both commands print nothing.
- [x] [P9-T12] Check off AC-20 in `<FEATURE>/spec.md` (P9-T8). Acceptance: only the AC-20 checkbox changed.
- [x] [P9-T13] Check off AC-21 in `<FEATURE>/spec.md` (P9-T9). Acceptance: only the AC-21 checkbox changed.
- [x] [P9-T14] Check off AC-22 in `<FEATURE>/spec.md` (P9-T11). Acceptance: only the AC-22 checkbox changed.
- [x] [P9-T15] Check off AC-8 in `<FEATURE>/spec.md` (P7-T13 `E4-ST3`; P9-T10 `test_push_down_issue_824_follow_ups.py` passing; spec Proposed Fix item 4 records the supersession of the #824 spec line 122). Acceptance: only the AC-8 checkbox changed.
- [x] [P9-T16] Commit and push Phase 9: `git add .agents/skills/feature-review-workflow/SKILL.md .github/skills/feature-review-workflow/SKILL.md .codex/agents/feature-review.toml extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/feature-review-workflow/SKILL.md extensions/drm-copilot/resources/customizations/.github/skills/feature-review-workflow/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/feature-review.toml tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py <FEATURE>/evidence <FEATURE>/spec.md <FEATURE>/plan.2026-10-11T07-58.md`, `git commit -m "docs(896): name root CLAUDE.md as the feature-review floor source in skill and agent texts"`, `git push origin HEAD:<BRANCH>`. Acceptance: `git status --porcelain` prints nothing and after `git fetch origin <BRANCH>`, `git rev-parse HEAD` equals `git rev-parse origin/<BRANCH>`.

### Phase 10 — Mirror and Manifest Verification

- [x] [P10-T1] Run CR-SHA with `<PAIRS>` = all nine LIST-MIRROR-PAIRS entries; write `<FEATURE>/evidence/other/mirror-log.<ts>.md` (AC-23) with every `SHA:` line verbatim, including the `.github/skills/feature-review-workflow/SKILL.md` pair, which has no automated parity test. Acceptance: nine `SHA:` lines ending `MATCH` and `SHA-DIFFER-COUNT: 0`.
- [x] [P10-T2] Run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`; write `<FEATURE>/evidence/qa-gates/mirror-parity-pytest.<ts>.md`. Acceptance: numeric `passed` count and no `failed` count.
- [x] [P10-T3] Run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_codex_core_manifest_closure.py`; write `<FEATURE>/evidence/qa-gates/manifest-pytest.<ts>.md`. Acceptance: numeric `passed` count and no `failed` count.
- [x] [P10-T4] Check off AC-9 in `<FEATURE>/spec.md` (P6-T9 `E4-ST4`; P10-T3 Claude manifest completeness). Acceptance: only the AC-9 checkbox changed.
- [x] [P10-T5] Check off AC-18 in `<FEATURE>/spec.md` (P10-T3 Codex manifest completeness; P7-T13 legacy contracts passing; P7-T9 `count=497`) only if no `PRE-EXISTING-STILL-FAILING:` entry in the P7-T13 artifact names a test in T9, that is, the P7-T13 `SUITE:` line for `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` reads `Failed=0`; otherwise leave it unchecked and record the reason in `<FEATURE>/evidence/qa-gates/manifest-pytest.<ts>.md`. Acceptance: only the AC-18 checkbox changed, or it stays unchecked with the reason recorded.
- [x] [P10-T6] Check off AC-23 in `<FEATURE>/spec.md` (P10-T1, P10-T2). Acceptance: only the AC-23 checkbox changed.
- [x] [P10-T7] Commit and push Phase 10: `git add <FEATURE>/evidence <FEATURE>/spec.md <FEATURE>/plan.2026-10-11T07-58.md`, `git commit -m "docs(896): record mirror and manifest verification"`, `git push origin HEAD:<BRANCH>`. Acceptance: `git status --porcelain` prints nothing and after `git fetch origin <BRANCH>`, `git rev-parse HEAD` equals `git rev-parse origin/<BRANCH>`.

### Phase 11 — Final QC Loop (PowerShell and Python)

Loop rule: run P11-T1 through P11-T9 in order. If any step fails, or P11-T1 reports a non-zero `FORMAT-APPLIED-COUNT`, or P11-T3 reports `reformatted`, fix the cause, re-run CR-MIRROR for any changed mirrored file, and restart from P11-T1. Number each pass in the artifact names (`pass<k>`). A step that passes only under the PEF does not restart the loop. The loop is complete only when one pass runs P11-T1 through P11-T9 with every step meeting its acceptance (directly or under the PEF) and no file change.

- [x] [P11-T1] PowerShell format (write mode; PI-7): run CR-FORMAT-APPLY with `<LIST>` = LIST-PROD plus LIST-TEST; write `<FEATURE>/evidence/qa-gates/final-format.pass<k>.<ts>.md`. Acceptance for a clean pass: one `FORMAT-UNCHANGED:` line per file and `FORMAT-APPLIED-COUNT: 0`; also record `git status --porcelain` before and after, which must be identical.
- [x] [P11-T2] PowerShell lint (PI-7): run CR-PSSA with `<LIST>` = LIST-PROD plus LIST-TEST; write `<FEATURE>/evidence/qa-gates/final-pssa.pass<k>.<ts>.md`. Acceptance: one `PSSA:` line per file with `findings=0`, `PSSA-TOTAL: 0`, `EXIT_CODE_COMPUTED: 0`.
- [x] [P11-T3] Python format (write mode): run `poetry run black tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`; write `<FEATURE>/evidence/qa-gates/final-python-black.pass<k>.<ts>.md`. Acceptance for a clean pass: the output contains `1 file left unchanged` and does not contain `reformatted`.
- [x] [P11-T4] Python lint: run `poetry run ruff check tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`; write `<FEATURE>/evidence/qa-gates/final-python-ruff.pass<k>.<ts>.md`. Acceptance: the output contains `All checks passed!` and `EXIT_CODE: 0`.
- [x] [P11-T5] Python type check: run `poetry run pyright tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`; write `<FEATURE>/evidence/qa-gates/final-python-pyright.pass<k>.<ts>.md`. Acceptance: the summary line reports `0 errors` and `EXIT_CODE: 0`.
- [x] [P11-T6] Targeted Pester over every in-scope suite: run CR-PESTER-LIST with `<LIST>` = LIST-CLAUDE-SUITES plus LIST-CODEX-SUITES plus LIST-AUX; no tag filters; `<PATTERNS>` = `E4-TR*`, `E4-ST*`, `E4-PX*`, `E4-TG*`, `TG*`, `F824-*`, `T824-*`, and the four GUARD-PATTERNS; write `<FEATURE>/evidence/qa-gates/final-pester-targeted.pass<k>.<ts>.md` and compare each `SUITE:` line with P0-T12. Acceptance: each `S1`, `S2`, `S6` GUARD-PATTERN line `Passed=2 | Failed=0`; every suite present in P0-T12 present here; and either `TOTAL:` with `Failed=0` and `EXIT_CODE_COMPUTED: 0`, or, when every `FAILED:` line meets the PEF, `EXIT_CODE_COMPUTED: 1`, process exit code 1, and an artifact recording `ExpectedExitCode: 1` and `PRE-EXISTING-STILL-FAILING:` (PEF).
- [x] [P11-T7] Full-population Pester with coverage: run CR-POSHQC-FULL through the scratchpad route, then CR-JUNIT; write `<FEATURE>/evidence/qa-gates/final-pester-full-run.pass<k>.<ts>.md` with the `Tests Passed:`, `Covered`, and `JUNIT:` lines verbatim. The artifact `EXIT_CODE:` records the CR-JUNIT process exit code. Acceptance: the `Tests Passed:` and `Covered` lines are present, and either (a) the `Tests Passed:` line contains `Failed: 0,`, `JUNIT:` shows `failures=0 | errors=0`, and `EXIT_CODE_COMPUTED: 0`, or (b) every `JUNIT-FAILED:` name is listed `PRE-EXISTING:` in the P0-T13 artifact and contains none of the PEF tokens (`validate-feature-review-coverage`, `feature-review-coverage-thresholds`, `E4-`, `TG1:`, `TG2:`, `TG3:`, `F824-`, `T824-`), `EXIT_CODE_COMPUTED: 1`, and the artifact records `ExpectedExitCode: 1` and lists each such name under `PRE-EXISTING-STILL-FAILING:`. This run includes `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1` and `tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1` through the `tests/scripts` run path (`pester.runsettings.psd1:3`). A pre-existing failure under (b) is recorded, not fixed, and leaves AC-28 unchecked (P12-T15).
- [x] [P11-T8] Per-file coverage (AC-25 final half), immediately after P11-T7 with no Pester run in between: run CR-COV-FILES with `<LIST>` = LIST-PROD; write `<FEATURE>/evidence/qa-gates/final-pester-coverage.<ts>.md`. Acceptance: six `COVERAGE:` lines with numeric values, each `pct=` at least 85.00, `COVERAGE-BELOW-85: NONE`, `EXIT_CODE_COMPUTED: 0`.
- [x] [P11-T9] Python contract tests: run PYTEST-SPEC, then `poetry run pytest tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py`; write `<FEATURE>/evidence/qa-gates/final-pytest-contracts.pass<k>.<ts>.md` with both summary lines. Acceptance: both summary lines have a numeric `passed` count and no `failed` count.
- [x] [P11-T10] Write `<FEATURE>/evidence/qa-gates/final-qc-loop.<ts>.md` listing each pass number, the artifacts of the clean pass, and the restart causes of earlier passes. Acceptance: the artifact names one pass in which P11-T1 through P11-T9 all met their acceptance with no file change.
- [x] [P11-T11] Commit and push Phase 11: `git add <FEATURE>/evidence <FEATURE>/plan.2026-10-11T07-58.md` plus any file changed by a restarted pass (named explicitly in the commit), `git commit -m "docs(896): record final QC loop"`, `git push origin HEAD:<BRANCH>`. When any pass changed a LIST-MIRROR-PAIRS source, run CR-SHA with `<PAIRS>` = all nine LIST-MIRROR-PAIRS entries before the commit and append its output to the P10-T1 `mirror-log` artifact under `## Post-QC re-hash`. Acceptance: when that re-hash ran, nine `SHA:` lines ending `MATCH` and `SHA-DIFFER-COUNT: 0` in that section; `git status --porcelain` prints nothing and after `git fetch origin <BRANCH>`, `git rev-parse HEAD` equals `git rev-parse origin/<BRANCH>`.

### Phase 12 — Verification Records and Acceptance-Criteria Check-off

- [x] [P12-T1] File sizes (AC-10): run CR-LINES with `<LIST>` = LIST-PROD plus LIST-TEST plus `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`; write `<FEATURE>/evidence/qa-gates/file-size.<ts>.md`, stating the 300-line design target and the count of each production file. Acceptance: `LINES-OVER-CAP: 0`; each of H1, H2, H3 reports `WITHIN-TARGET`; T9 reports `count=497`; any `OVER-TARGET` production file (expected: H5) is named with its count.
- [x] [P12-T2] Coverage delta: run CR-COV-CHANGED with `<LIST>` = LIST-PROD (after the Phase 11 commit; `artifacts/pester/powershell-coverage.xml` is the P11-T7 output); write `<FEATURE>/evidence/qa-gates/coverage-delta.<ts>.md` containing a table of baseline `pct=` (P0-T14; `NEW` for H2, H3, H6), post-change `pct=` (P11-T8), and changed-line `pct=` (this task) per file. Acceptance: six `CHANGED-COVERAGE:` lines, `CHANGED-BELOW-85: NONE`, `EXIT_CODE_COMPUTED: 0`, and no post-change figure below 85.00.
- [x] [P12-T3] Fail-first head run (AC-24): run CR-PESTER-LIST with `<LIST>` = T2, T5, T6; `<TAGS-IN>` = `E4-Regression`; `<PATTERNS>` = `E4-TR1:*`, `E4-TR4:*`, `E4-TR5-P*`, `E4-TR7:*`; write `<FEATURE>/evidence/qa-gates/fail-first-head-run.<ts>.md`, and append a `## Branch-head run` section to the P1-T5 artifact with the command, the `NAMED:` lines, and `HEAD_RUN_EXIT_CODE:`. Acceptance: `NAMED: E4-TR1:* | Passed=1 | Failed=0`, `NAMED: E4-TR4:* | Passed=1 | Failed=0`, `NAMED: E4-TR5-P* | Passed=6 | Failed=0`, `NAMED: E4-TR7:* | Passed=1 | Failed=0`, `EXIT_CODE_COMPUTED: 0`.
- [x] [P12-T4] Constraints, AC-26 (a) (PI-1): run `git diff --name-status origin/epic/subagentstop-envelope-integration -- .claude/hooks/ .codex/hooks/` and `git status --porcelain -- .claude/hooks/ .codex/hooks/` (the AC-26 (a) commands verbatim); create `<FEATURE>/evidence/qa-gates/constraints.<ts>.md` with both outputs and the PI-1 statement. Acceptance: the diff output contains the lines for `.claude/hooks/validate-feature-review-coverage-metrics.ps1`, `.claude/hooks/validate-feature-review-coverage-rules.ps1`, and `.codex/hooks/feature-review-coverage-thresholds.ps1` with status `A`; no diff line with status `A` names a path ending `.py`; the status command prints nothing (so no untracked `.py` path exists).
- [x] [P12-T5] Constraints, AC-26 (b) (PI-1): run CR-PESTER-LIST with `<LIST>` = LIST-AUX; no tag filters; no patterns; write the output to its own artifact `<FEATURE>/evidence/qa-gates/constraints-no-python.<ts>.md` (separate from the constraints artifact, because `ExpectedExitCode:` is per file and this step may need `ExpectedExitCode: 1`), and add one line to the constraints artifact naming that path. Acceptance: one `SUITE:` line for `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` with `Failed=0`, `TOTAL:` with `Failed=0`, `EXIT_CODE_COMPUTED: 0`; or, when every `FAILED:` line names a test that P0-T12 lists as `PRE-EXISTING:` and the `TOTAL:` line reads `FailedBlocks=0 | FailedContainers=0` (the PEF condition), `EXIT_CODE_COMPUTED: 1`, process exit code 1, and the constraints-no-python artifact records `ExpectedExitCode: 1` for this step, each such line under `PRE-EXISTING-STILL-FAILING:`, and `AC-26(b): NOT MET`.
- [x] [P12-T6] Constraints, AC-26 (c) (PI-1): run CR-PY-TOKEN with `$Mode = 'final'`; append the output to the constraints artifact. Acceptance: two `PY-TOKEN:` lines (`claude-hooks`, `codex-hooks`) ending `NOT-INCREASED`, `PY-TOKEN-INCREASED-COUNT: 0`, `EXIT_CODE_COMPUTED: 0`.
- [x] [P12-T7] Constraints, AC-26 temporary-file clause: run `git grep -n -F -e New-TemporaryFile -e GetTempFileName -e TestDrive -e '$env:TEMP' -- tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 tests/scripts/claude-hooks/validate-feature-review-coverage.E4.Helpers.ps1 tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1 tests/scripts/claude-hooks/validate-feature-review-coverage.ThresholdsGuard.Tests.ps1 tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1 tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 tests/scripts/codex-hooks/feature-review-coverage-thresholds.Tests.ps1 tests/scripts/codex-hooks/feature-review-coverage-floor-parity.Tests.ps1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` (single-quoted so no shell expands the variable); write the output to its own artifact `<FEATURE>/evidence/qa-gates/constraints-temp-files.<ts>.md` with `ExpectedExitCode: 1` (separate from the constraints artifact, because `ExpectedExitCode:` is per file and the constraints artifact's other steps expect exit 0), and add one line to the constraints artifact naming that path. Acceptance: no output and exit code 1.
- [x] [P12-T8] Scope boundary (AC-27): run `git diff --name-only origin/epic/subagentstop-envelope-integration...HEAD` and `git status --porcelain`; write `<FEATURE>/evidence/qa-gates/scope-boundary.<ts>.md` with the full list and a check line per forbidden path (the nine E2/E3 validator files under `.claude/hooks/` and their mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`, `.claude/settings.json`, `.claude/hooks/subagentstop-envelope.ps1` and its mirror, `.claude/lib/bash/compute-concurrency-batches.sh`, and the prefix `docs/features/active/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824/`). Acceptance: every check line reads `ABSENT`, and `git status --porcelain` prints nothing or only lines that are exactly ` M docs/features/active/subagentstop-envelope-feature-review-coverage-896/plan.2026-10-11T07-58.md` or begin ` M docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/` or `?? docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/` (the P12-T1 through P12-T7 artifacts and the P12-T3 append to the P1-T5 artifact, which P12-T17 commits; plan-file staging rule).
- [x] [P12-T9] Write `<FEATURE>/evidence/other/ac-29-handoff.<ts>.md` stating the AC-29 requirements for the later PR body (`Refs #884` and `Refs #897` present; no closing keyword adjacent to `#884` or `#897`; a closing keyword permitted for `#896` only) and that AC-29 is verified at PR time under the epic orchestrator from `gh pr view <number> --json body` recorded in `<FEATURE>/evidence/issue-updates/`. Acceptance: the artifact exists with those three requirements; AC-29 stays unchecked.
- [x] [P12-T10] Check off AC-10 in `<FEATURE>/spec.md` (P12-T1). Acceptance: only the AC-10 checkbox changed.
- [x] [P12-T11] Check off AC-24 in `<FEATURE>/spec.md` (P1-T5 and P12-T3). Acceptance: only the AC-24 checkbox changed.
- [x] [P12-T12] Check off AC-25 in `<FEATURE>/spec.md` (P0-T14 and P11-T8). Acceptance: only the AC-25 checkbox changed.
- [x] [P12-T13] Check off AC-26 in `<FEATURE>/spec.md`, citing AC-26 (a) P12-T4, (b) P12-T5, (c) P12-T6, and the temporary-file clause P12-T7, under PI-1 (the constraints artifact restates PI-1), only if no `PRE-EXISTING-STILL-FAILING:` entry in the P12-T5 output in `<FEATURE>/evidence/qa-gates/constraints-no-python.<ts>.md` names a test in LIST-AUX, that is, the P12-T5 `SUITE:` line for `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` reads `Failed=0`; otherwise leave it unchecked and record the reason in the constraints artifact. Acceptance: only the AC-26 checkbox changed, or it stays unchecked with the reason recorded.
- [x] [P12-T14] Check off AC-27 in `<FEATURE>/spec.md` (P12-T8). Acceptance: only the AC-27 checkbox changed.
- [x] [P12-T15] Check off AC-28 in `<FEATURE>/spec.md` under PI-7 (format and analyze evaluated by CR-FORMAT-APPLY and CR-PSSA with the PoshQC settings file over LIST-PROD plus LIST-TEST, because the MCP PoshQC results carry no output) only if the P11-T10 clean pass shows `FORMAT-APPLIED-COUNT: 0`, `PSSA-TOTAL: 0`, full-run `failures=0 | errors=0`, and PYTEST-SPEC passing, with no `PRE-EXISTING-STILL-FAILING:` entry in any Phase 11 artifact. Acceptance: only the AC-28 checkbox changed, or it stays unchecked with the reason recorded in `<FEATURE>/evidence/qa-gates/final-qc-loop.<ts>.md`.
- [x] [P12-T16] Write the AC status summary per `acceptance-criteria-tracking` into `<FEATURE>/evidence/other/ac-status.<ts>.md` (source `spec.md`; total 31; checked count; remaining list, expected to be AC-29 only). Acceptance: the counts equal the number of `- [x] AC-` and `- [ ] AC-` lines in `<FEATURE>/spec.md`.
- [x] [P12-T17] Commit and push Phase 12: `git add <FEATURE>/evidence <FEATURE>/spec.md <FEATURE>/plan.2026-10-11T07-58.md`, `git commit -m "docs(896): record verification evidence and acceptance-criteria status"`, `git push origin HEAD:<BRANCH>`. Acceptance: `git status --porcelain` prints nothing and after `git fetch origin <BRANCH>`, `git rev-parse HEAD` equals `git rev-parse origin/<BRANCH>`.

PR authoring, CI monitoring, and feature review are out of this plan's scope; they run later under the epic orchestrator, which verifies AC-29 at PR time.

## Planner Self-Review

SELF-REVIEW: RE-DERIVED THIS PASS

Citations re-derived against the current tree in the v1.8 revision pass (2026-10-12; file and locator):

Y1. `.claude/hooks/validate-feature-review-coverage-rules.ps1` (H3 at HEAD): no top-level statement other than function definitions (help lines 11-12), so dot-sourcing the `git show HEAD:` text in CR-EXEMPLAR defines functions only. `Test-LanguageCoverageRow` is at line 93, with parameters `AuditText`, `Language`, `RepoWidePct`, `BranchPct` (`[Nullable[double]]`), `LineFloor`, `BranchFloor`, `LineSource`, and `BranchSource` (95-104), so the CR-EXEMPLAR call binds. The label map (109-114) equals CR-EXEMPLAR `$LabelMap` and CR-CORPUS line 633. The `$languageLines` filter is line 120. The `$coverageLines` filter is line 129, and its regex equals CR-EXEMPLAR `$CovRe`. The narrowing regex is line 137. Reason fragments: `does not mention` 125, `no coverage-scoped row` 133, `narrows scope` 143, `neither a PASS nor a FAIL` 151. The narrowing check reads only `$coverageLines`, and the verdict check reads only `$coverageLines`, so the REDUCED key-line rule keeps every line those checks read.
Y2. `.claude/hooks/check-powershell-test-purity.ps1`: the `$forbiddenPatterns = @(` assignment spans lines 102-120, and its 17 `@{ Pattern = ...; Reason = ... }` entries are lines 103-119. Every `Pattern` value is a constant string with no `$` expansion (the double-quoted entries at 106-107 contain no variable), so `GetPureExpression().SafeGetValue()` returns each one. This agrees with `PURITY-PATTERNS: 17` in CR-EXEMPLAR and in the BLOCKED artifact.
Y3. `docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/other/corpus-run.initial.2026-10-12T00-11.md` (P4-T1 artifact): the `CORPUS-REJECT:` lines read `<top> | rule3 | <class> | <artifact> ; <language> ; <basis> ; <form key> ; <reason>` (for example lines 482 and 628). The sanctioned form keys have four `|` parts (`rule3|Python|NARROWING|sanctioned`). 21 `NARROWING|sanctioned ; ` lines carry a non-empty reason (17 + 2 + 2). So the CR-EXEMPLAR candidate regex captures the artifact in `A` and the key in `K`, and the `$parts.Count -lt 3` check accepts both the 3-part and the 4-part keys. Python candidates are at lines 628 and 674.
Y4. `docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/other/corpus-rule-changes.2026-10-12T00-18.md` (BLOCKED artifact): `CorpusGate: BLOCKED` (line 8). FIX-1 through FIX-4 read `Status: PENDING`. FIX-2's FULL candidate `.../policy-audit.2026-06-16T16-45.md` qualifies with 37 lines. FIX-3 and FIX-4 read `BlockedReason: EXEMPLAR-UNREPRESENTABLE`. This is the basis of the restart paragraph (new artifact, `RestartOf:`) and of the CR-EXEMPLAR observation-run sentence.
Y5. Plan-internal sibling checks: CR-CORPUS `Get-SectionLineSet` and `Get-Rule3Class` (S2 membership is the nearest preceding `^##\s` heading) agree with the REDUCED rule that keeps each key line's nearest heading. P4-T6, P4-T7 (`## Newly visible true positives`), and P4-T8 (`E4-CORPUS-ROWS:`) say "the rule-changes artifact", which the Phase 4 introduction now defines. P4-T9 names it explicitly. The `### CR-EXEMPLAR output` heading does not begin `## FIX-`, so the P4-T4 `IT-COUNT` and `Status: APPLIED` acceptances still count FIX sections only. The P4-T4 BLOCKED `git restore` paths still exclude `docs/`. P0-T1 through P4-T3 text and check-offs were not edited.

Citations re-derived against the current tree in the v1.7 revision pass (2026-10-11; file and locator; all plan-internal unless a repository file is named):

X1. `git add` inventory (Grep `git add`, 18 matching lines): 16 task commands, each now ending with or containing `<FEATURE>/plan.2026-10-11T07-58.md` (Grep for `git add [^`]*<FEATURE>/plan\.2026-10-11T07-58\.md` returns 16 lines): P0-T8 STOP path, P0-T9 conflict path, P0-T25, P1-T7, P2-T9, P3-T12, P4-T4 BLOCKED procedure, P4-T10, P5-T21, P6-T13, P7-T19, P8-T4, P9-T16, P10-T7, P11-T11, P12-T17; the other two lines are the Execution Notes rule and the v1.7 revision note. No `git add` without the plan path remains in a task.
X2. Unscoped `git status --porcelain` inventory (Grep `porcelain`, 27 occurrences): checks in P0-T8, P0-T9, P0-T25, P1-T7, P2-T9, P3-T12, P4-T1 (two mentions in one task), P4-T10, P5-T21, P6-T13, P7-T19, P8-T4, P9-T16, P10-T7, P11-T11, P12-T8 (two mentions), P12-T17 match the delta list exactly; P0-T10 (AnchorDrift input), P0-T15, P0-T23, P11-T1 (before-and-after comparisons), P7-T14, P9-T11, P12-T4 and PI-1 (path-scoped) are the delta's unchanged set; the self-review line W7 mentions `git restore` only. The P4-T4 BLOCKED procedure has a `git add` but no status check, which agrees with its absence from the status list.
X3. P4-T4 BLOCKED `git restore --source=HEAD -- .claude/hooks tests/scripts/claude-hooks extensions/drm-copilot/resources/claude-customizations/.claude/hooks`: no path operand is under `docs/`, so the plan file and its check-offs are not restored; the subsequent `git add` now stages the plan file with the evidence.
X4. Sibling check, ordering of check-offs: every commit task's status check runs after its own commit and push, so the only possible modification is the check-off of that task or of tasks completed since the commit; the staged plan path makes earlier check-offs part of each commit. P4-T1 runs `git status --porcelain` before it creates `corpus-run.initial.<ts>.md`, so its output can contain only the plan-file line (the P3-T12 check-off).
X5. Sibling defect found and corrected, P12-T8: P12-T1 (`file-size`), P12-T2 (`coverage-delta`), P12-T3 (`fail-first-head-run`), P12-T4 (`constraints`), P12-T5 (`constraints-no-python`), and P12-T7 (`constraints-temp-files`) write under `<FEATURE>/evidence/qa-gates/` after the P11-T11 commit and before P12-T17, so the P12-T8 status output contains their `??` lines; P12-T3 also appends to the P1-T5 artifact under `evidence/regression-testing/`, which is tracked since P1-T7, producing a ` M` line. The P12-T8 acceptance, the Execution Notes P12-T8 sentence, and v1.7 revision item 2 therefore accept lines that begin ` M docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/` or `?? docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/`, in addition to the plan-file line; the three texts carry the same two prefixes. P12-T17 stages `<FEATURE>/evidence`, which covers both kinds of line, and its own status check is the strict one.
X6. Sibling check, AC-27 strength: the widened P12-T8 status acceptance admits only paths under `<FEATURE>/evidence/` and the plan file, none of which is a forbidden path in the P12-T8 check list, and the `ABSENT` check lines over the anchored `git diff --name-only` are unchanged, so an out-of-scope untracked or modified file still fails P12-T8.
X7. `docs/features/active/subagentstop-envelope-feature-review-coverage-896/plan.2026-10-11T07-58.md` exists at the stated repository-relative path (this file); its tracked state is a caller-supplied fact that this pass could not verify without a shell.

Citations re-derived against the current tree in the v1.6 revision pass (2026-10-11; file and locator):

W1. `tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1` — 135 lines (last line 135 is the closing `}` of the `Describe`); same-timestamp test `It` at 38, in-`It` `Mock -CommandName Get-ArtifactFileContent -MockWith { param([string]$Path) ... }` at 39-54, returning `@{ Exists = $true; Text = ...; Lines = @(...) }` for advertised paths (42, 45, 48) and `@{ Exists = $false; Text = $null; Lines = @() }` for `artifacts/pr_context.summary.txt` (50-51) and the default (53); the allow test at 113-133 returns `@{ Exists = $true; Text = 'ok'; Lines = @('ok') }` (119) with the summary absent (116-117) and asserts `Ok` true (131). The P4-T4 rule2 mock shape (delta 3) is the 119 and 51/53 shapes; no adjustment was needed. T1 baseline count 135 is the starting point of the P4-T6 ceiling derivation (delta 4).
W2. `.claude/hooks/validate-feature-review-coverage.ps1` — `Get-ArtifactFileContent` 51-73 with returns at 60 (`@{ Exists = $false; Text = $null; Lines = @() }`) and 72 (`@{ Exists = $true; Text = $text; Lines = $lines }`); the advertised-artifact loop 382-403 calls `Get-ArtifactFileContent -Path $path` (395) and reads `.Exists` (396) and `.Text` (401); the same-folder-and-timestamp comparison 405-415 (message 413); `remediation-inputs-path` read only when advertised (417-418); `artifacts/pr_context.summary.txt` read at 437 with the allow return at 439-441 when no language is found, before the `CLAUDE.md` read at 444. So the rule2 `Accept` row returns `Ok` true and the `Reject` row returns the 413 message (delta 3).
W3. Plan-internal, CR-CORPUS: `Add-CorpusReject` signature (`[string] $Language`, in the function definition above the D1 block) accepts `$stem`; the rule2 call now passes `$stem` (delta 1); `$stem` there is `$Matches[1]` from `^(code-review|feature-audit) artifact must share ...`; the sort `Sort-Object Top, Rule, Artifact, Language, Key`, the `CORPUS-REJECT:` print order (artifact ; language ; basis ; key ; reason), the final-mode parse regex `(?<A>.+?) ; (?<L>.+?) ; `, the `$initTp`/`$nowTp` id `"$($x.Rule)|$($x.Artifact)|$($x.Language)"`, and the `$seen` de-duplication all consume the new value without change; rule1 still passes `'-'` and rule3 `$lang`, matching the Output-lines text.
W4. Plan-internal, P4-T4: the `Exemplar:` rule for rule2 reads the artifact path field, and the rule2 `Accept` row reads the ` [partner: <path>]` suffix from the reason field; neither reads the language field, so delta 1 leaves both unchanged.
W5. Plan-internal, D6 S1 and CR-CORPUS `Get-Rule3Class` (line `if ($Language -eq 'PowerShell' -and $l -match '(?i)\bbranch\b' -and $l -notmatch '(?i)\bline\s+coverage\b') { continue }`): the delta-2 `Reject` transformation removes every `(?i)\bbranch\b` match, so no transformed line meets the S1 condition and a P4-T4 (a) S1 fix (same two regexes) no longer exempts it; the line keeps its label, coverage term (`$CovRe` does not contain `branch`), and narrowing phrase, so `Test-LanguageCoverageRow` returns the `narrows scope` reason the `Reject` assertion names. Sibling bullets (S2 heading removal, combined S1-S2, established rule3, rule1, rule2) are unchanged.
W6. Plan-internal, CR-LINES: `$band` is `OVER-CAP` and `$over` increments when `$count -ge 500`, so the T1 end-state limit is 499 lines; P4-T6's ceiling 400 leaves 99 lines. Planned later T1 additions re-read from task text: P5-T6 (four base tests 26-135 converted; envelope literal keeps each payload's line structure; plus any `E4-CORPUS` rule2 row conversion stated in the Phase 5 pointer), P5-T11 (`E4-ST1` six-row and two-row `-ForEach` blocks, `E4-ST2`, `E4-ST6`), P6-T6 (one name added to the `E4-ST4` H2 row), P7-T12 (`E4-ST3` two-row block); P2-T6 (`E4-ST4`) precedes Phase 4 and is already inside the P4-T6 measurement.
W7. Plan-internal sibling checks for delta 4: the P4-T4 BLOCKED procedure's `git restore` of `tests/scripts/claude-hooks` reverts T1 for `T1-LINE-BUDGET` as for the other reasons; P4-T9 writes `CorpusGate: PASS` only when P4-T6 met its acceptance, so an over-ceiling T1 cannot reach PASS; the Phase 4 re-entry bound repeats P4-T6, so the ceiling is re-checked after every re-entry; P12-T1 and P6-T8 acceptances are unchanged (P6-T8 does not list T1).

Citations re-derived against the current tree in the v1.5 revision pass (2026-10-11; file and locator):

V1. `.claude/hooks/validate-feature-review-coverage.ps1` — still 477 lines after the E1 merge; no `subagentstop` token (so P0-T23's CR-TEXT `Absent = @('subagentstop-envelope.ps1')` still holds); `Get-ReviewArtifactInfo` 106-129 returns `Folder`, `Timestamp`, and `Path` (normalized active-equivalent path, line 127), so `$partner[$stem].Path` in the CR-CORPUS rule2 reason is defined; same-folder-and-timestamp check 405-415 (message 413); `RawPayload` at 349, 354, 359, 471; `feature-review hook:` messages 355, 362, 370, 433, 457; `python` lines 23, 142, 224, 261, 281; entry 464-477.
V2. Presence after the E1 merge `039e53339` (via `f11f1814b`; commit identities as reported by the caller's preflight, file presence verified by Glob): `.claude/hooks/subagentstop-envelope.ps1` (`Get-SubagentStopEnvelopeAnomalyReason` line 20, `Read-SubagentStopEnvelope` line 54, `Exit-SubagentStopBlock` line 171); `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/subagentstop-envelope.ps1`; `tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1`; `docs/features/active/subagentstop-envelope-core-897/spec.md` and sibling files. Supersedes R10 and item 27; sibling: the header Upstream dependency paragraph and the Not-edited list (helper and mirror stay unedited) agree.
V3. `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` — line 59 `".claude/hooks/feature-review-coverage-thresholds.ps1",`, line 66 `hook-dependency-guard.ps1`, line 68 `".claude/hooks/subagentstop-envelope.ps1",`, line 71 `".claude/hooks/validate-executor-output.ps1",`, line 72 `".claude/hooks/validate-feature-review-coverage.ps1",`; P2-T4's insertion point and item 19 now cite 71 and 72.
V4. Sibling of V3: `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` — `paths` line 4, `.codex/hooks/feature-folder-resolution.ps1` line 46, `.codex/hooks/validate-feature-review-coverage.ps1` line 68; unchanged by the E1 merge, so P7-T10 and item 20 hold.
V5. `.claude/hooks/check-powershell-test-purity.ps1` — `$forbiddenPatterns` array lines 102-120 (entries 103-119, including `New-TemporaryFile`, `GetTempFileName`, `GetTempPath`, `$env:TEMP`, `$env:TMP`, `Start-Process`, `Start-Sleep`, and the `Mock git`/`Mock gh`/`Mock actionlint` forms); cited by reference in the P4-T4 rule3 exemplar conditions.
V6. Plan-internal: P12-T7 searches the four literals `New-TemporaryFile`, `GetTempFileName`, `TestDrive`, `$env:TEMP` (the "four P12-T7 literals" P4-T4 cites).
V7. Plan-internal: CR-CORPUS `Get-Rule3Class` line `if ($Language -eq 'PowerShell' -and $l -match '(?i)\bbranch\b' -and $l -notmatch '(?i)\bline\s+coverage\b') { continue }` — the two regexes D6 S1 and P4-T4 (a) now quote; `Get-LabelRe` is the label pattern P4-T4 (b) names; CR-CORPUS rule3 reason classes `NO-COVERAGE-ROW`, `NO-VERDICT`, `NARROWING` and form keys `rule3|<lang>|NARROWING|sanctioned`, `rule3|<lang>|<ReasonClass>` are the keys P4-T4's fragment mapping reads.
V8. Plan-internal: CR-CORPUS rule2 loop — `$partner[$stem]` is assigned for both stems before the decision call; the `Add-CorpusReject` reason argument carries the ` [partner: <path>]` suffix, and (v1.6) its language argument is `$stem` (the stem captured by `$Matches[1]` from the rejection text), not `-`. The final-mode TP comparison key is `rule|artifact|language` (no reason), so the rule2 final-mode key is `rule2|<policy-audit path>|<stem>`; a policy audit whose code-review and feature-audit partners are both rejected therefore yields two distinct keys instead of one collapsed `rule2|<path>|-` key. The rule2 `$text -match` classification and the `CORPUS-REJECT:` parse regex in final mode (`(?<L>.+?) ; `) are unaffected by the suffix and by the stem value, which contains no ` ; `.
V9. Plan-internal: every push (19 occurrences: P0-T8, P0-T9, P0-T25, P1-T7, P2-T9, P3-T12, P4-T4 BLOCKED path, P4-T10, P5-T21, P6-T13, P7-T19, P8-T4, P9-T16, P10-T7, P11-T11, P12-T17, Execution Notes, A10, R11) reads `git push origin HEAD:<BRANCH>`; no push without the `HEAD:` refspec remains (Grep); every `git fetch origin <BRANCH>` and `git rev-parse origin/<BRANCH>` is unchanged.
V10. Plan-internal sibling checks: P0-T8's `Branch:` failure branch (no commit, no push) now covers `Branch: NO-ORIGIN-UPSTREAM`; P0-T10's diff from `ac525c4ef` to the integration ref is expected to list P1 because E1 added line 68, which PI-6 handles by quoted-content location; P4-T8's `E4-CORPUS-ROWS` reference reads the rewritten line; the P4-T4 BLOCKED procedure's `git restore` and push run the same way for the C1, C4, `EXEMPLAR-UNREPRESENTABLE`, and `ReentryExhausted` reasons; P4-T2's added `CorpusCommand:` line is outside the P4-T1 `Command:` field, so that field keeps its six commands.

Citations re-derived against the current tree in the amendment pass (2026-10-11, v1.4; file and locator):

A1. `scripts/dev_tools/validate_orchestration_artifacts.py` — line 48 `PLAN_PHASE_RE = re.compile(r"^### Phase (?P<phase>\d+) — (?P<title>.+)$")`; lines 49-51 `PLAN_TASK_RE` with `P(?P<phase>\d+)-T(?P<task>\d+)`; lines 145-158 (a `### Phase ` line that fails the regex is an error); lines 160-189 (task phase must equal the current heading's number; sequential task numbers per phase). A `3A` heading and `P3A-T#` IDs therefore fail, and the renumbering route was taken. Phase numbers need not be consecutive, but 4-12 are.
A2. `.claude/hooks/validate-feature-review-coverage.ps1` (base, 477 lines) — `Get-ReviewArtifactInfo` 106-129 (pattern line 118, `IgnoreCase` 119); labels 279-284; coverage regex 299; narrowing regex 307; reason texts 295 (`does not mention`), 303 (`no coverage-scoped row`), 313 (`narrows scope`), 321 (`neither a PASS nor a FAIL`), 330 (`line coverage floor`), 338 (`branch coverage floor`); same-folder-and-timestamp check 405-415 (message 413); remediation-inputs check 417-429; error header 432-434; summary-absent allow 437-441; dot-source early return 464-466; `-RawPayload` parameter 349. These are the literals P4-T4's CR-TEXT asserts and the vocabulary CR-CORPUS copies.
A3. `tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1` — `BeforeAll` 7-17 (dot-source of H1 at 9; `Get-ArtifactFileContent` mock at 13); `Describe` 19; first test 26-36 calls `-RawPayload`; the same-timestamp test at 38 uses `Mock -CommandName Get-ArtifactFileContent` (the pattern P4-T4 rule2 rows follow).
A4. `.claude/skills/feature-review-workflow/SKILL.md` — line 106 (coverage mandatory for every changed language), 111 (PowerShell has no branch figure; not a FAIL), 164-172 (`<stem>.<timestamp>.md` shapes), 180 (`## Rejected Scope Narrowing` section with verbatim caller text), 181 (`N/A`, `UNVERIFIED`, "informational only" acceptable only for languages with zero changed files).
A5. `.claude/rules/general-unit-test.md` line 25 and `.claude/rules/quality-tiers.md` line 38 — PowerShell (Pester) exempt from the branch threshold (S1).
A6. `.claude/skills/remediation-handoff-atomic-planner/SKILL.md` — lines 69-77 and 82: `docs/features/active/<slug>/audit/<exit-ts>/{code-review,feature-audit,policy-audit}.md` with no timestamp in the file name (S3); lines 71-72 and 81: `remediation/<entry-ts>/remediation-inputs.md` (D8).
A7. `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` line 46 — `yyyy-MM-ddTHH-mm` for all audit artifacts (D6 step 2 path rule).
A8. `docs/features/templates/policy_audit/` — exactly `code-review.yyyy-MM-ddTHH-mm.md`, `feature-audit.yyyy-MM-ddTHH-mm.md`, `policy-audit.yyyy-MM-ddTHH-mm.md` (Glob), the D1 template exclusion. Also, the local tree holds review artifacts under `docs/features/active/`, `docs/features/completed/`, and `docs/features/archive/`, including `audit-<ts>/` and `<ts>-audit/` subfolders (Glob). Rule 1 accepts these subfolder forms, because `Folder` is `.+`, which is the basis of D2.
A9. `.claude/hooks/validate-planner-output.ps1` — line 96 path-token pattern (every Phase 4 task names a slash-separated path); line 110 exact `PREFLIGHT:` signal set.
A10. Plan-internal sibling checks for the renumbering:
  - No `P4-T`-form ID survives from the former Phase 4. The former P4-T1 is now P5-T1.
  - Task headings run P0, P1, P2, P3, P4 (new), P5-P12, each starting at T1 (Grep).
  - PI-2 lists the Phase 4 exclusions, and "From Phase 6 onward" is unchanged in meaning.
  - The Decision Function Shape now reads "Phase 5 writes" and "Phase 6 replaces", and the Guarded Dot-Source line reads "(Phase 5)".
  - The AC-MAPPING IDs were renumbered by the same mapping.
  - `phase4-` to `phase8-` evidence names became `phase5-` to `phase9-`, and the new Phase 4 uses `phase4-mirror`, `phase4-file-size`, and `phase4-corpus-pester`, which collide with no renamed name.
  - The Phase 4 pushes (P4-T4 BLOCKED path, P4-T10) use `git push origin HEAD:<BRANCH>`.
  - D7 C1 cites P2-T6 and P6-T6 (the E4-ST4 H2 update, formerly P5-T6). C2 cites P5-T2 (formerly P4-T2). The Phase 5 pointer covers P5-T6's `RawPayload` absence check and P5-T14's `-RawPayload` search over T1.
A11. Plan-internal ordering check: CR-CORPUS uses `-RawPayload`, which exists through Phase 4 and is removed by P5-T3, so CR-CORPUS runs before the transport change. The P4-T8 exclusions match P3-T9. The E4-TR5-P rows pass from P3-T8 on, so P4-T8's `Passed=6` is satisfiable. The E4-CORPUS rows are added in P4-T4, before the P4-T8 gate that counts them.

Citations re-derived against the current tree in the round-3 revision pass (v1.3; file and locator; task and phase numbers below follow the v1.4 renumbering):

R3-a. `.claude/hooks/validate-feature-review-coverage.ps1` — line 349 is `        [string] $RawPayload` (the P5-T3 absent token `[string] $RawPayload` matches it); `RawPayload` occurs only at lines 349, 354, 359 (removed by P5-T3) and 471 (`-RawPayload $env:CLAUDE_HOOK_INPUT`, removed by P5-T4); `ConvertFrom-Json` occurs only at 359; so P5-T3 can pass while line 471 remains and P5-T4 then asserts `RawPayload` absent from the whole file.
R3-b. `tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1` — `It` names F824-1 (56), F824-2 (79), F824-3 (103), F824-4 (130), F824-5 (153), F824-6 (176), F824-7 (198), F824-8 (220), F824-9 (242), and the `F824-V<Id>` `-ForEach` with eight rows (269-277); 9 + 8 = 17 matches for `F824-*`, the P5-T13 count. P5-T9 keeps all 17 (F824-9 moves to its own Context; V1-V8 keep their IDs).
R3-c. `tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1` — line 73 asserts a findings collection with `Should -BeNullOrEmpty`, so a long findings list is abbreviated in the failure message; this is the basis of the ` more)` clause added to the N1 rule.
R3-d. Plan-internal: LIST-MIRROR-PAIRS has nine entries (H1, H2, H3, H4; H5, H6, S1, S3; S2), the count P10-T1 and the P11-T11 re-hash assert. `ac525c4ef` is the epic start commit already used by P0-T10; P0-T3 now uses it as the lower bound of the direct-merge scan.
R3-e. Plan-internal per-file `ExpectedExitCode` scan: P12-T5 (may need `ExpectedExitCode: 1` under the PEF) and P12-T7 (always `ExpectedExitCode: 1`) previously appended to the shared constraints artifact, whose P12-T4 and P12-T6 steps expect exit 0; both now write their own artifact (`constraints-no-python.<ts>.md`, `constraints-temp-files.<ts>.md`); PI-1, P12-T13, and the AC-26 mapping were updated to match. Every other `ExpectedExitCode: 1` use (P1-T5, P5-T14, the six PEF gates P2-T7, P3-T9, P5-T13, P6-T9, P7-T13, P11-T6, and P11-T7) already writes its own artifact; the multi-command artifacts P0-T14, P0-T22, P0-T23, P5-T12, P6-T7, P7-T11, and the P10-T1 mirror-log with the P11-T11 re-hash expect exit 0 in every step; P12-T3 appends to the P1-T5 artifact under `HEAD_RUN_EXIT_CODE:`, not a second `EXIT_CODE:` field.
R3-f. Sibling text re-checked: Header line 14 (first-parent merge that introduced the helper) agrees with the oldest-first scan; the Execution Notes PEF sentence and the P12-T5 PEF branch now both require `FailedBlocks=0 | FailedContainers=0`; P5-T11 `E4-ST2` (parameter keys contain no `RawPayload`) and P5-T6/P5-T7/P5-T9/P5-T10 test-file `RawPayload` absences are unaffected by the H1 token change.

Citations from the round-2 pass (carried; this pass's edits do not alter what they assert):

R1. `.claude/rules/powershell.md` — line 30 ("Implement **ShouldProcess/SupportsShouldProcess** for state-changing actions."), cited by P5-T9.
R2. `tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1` — 156 lines; root rows line 19 (`repository`, `mirror`); `N1` It at 67-74, whose failure message is the list of `<SourceLabel>:<Line> <Form>` findings (line 73), so a finding's module path appears after ` :: ` in a CR-PESTER-LIST `FAILED:` line; cited by the GUARD-PATTERNS N1 rule and P0-T12.
R3. `tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1` — 296 lines; top-level `BeforeAll` 13-30 with `$script:HookFile` at 14, `$script:RealGetArtifactFileContent` at 16, `Get-ArtifactFileResult` at 25-29; `Describe` at 32; cited by P1-T1, P5-T9, P6-T8.
R4. `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1` — line 11, a `. (Join-Path $PSScriptRoot '<name>.Helpers.ps1')` dot-source inside a `Describe` `BeforeAll` (8-12); cited by P1-T1 as the T11 dot-source form.
R5. `tests/scripts/claude-hooks/` — existing `*.Helpers.ps1` test-support files (`EpicStateIsolation.Baseline.Helpers.ps1`, `WorktreeResolutionFixture.Helpers.ps1`, and three others), the naming convention T11 follows.
R6. `config/poshqc-coverage.json` — `roots` lines 3-9 (`.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.codex/scripts`, `scripts`); `tests/` is outside the coverage population, so T11 needs no exclude entry and no production path is excluded.
R7. `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` — run paths line 3, `Exit = $true` line 4, JUnit path line 15, coverage output line 22, no coverage `Path` list (lines 23-24); cited by CR-POSHQC-FULL and P11-T7.
R8. `tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1` — 289 lines; file `BeforeAll` 21 (`Get-ArtifactFileContent` mock 27); `Describe` `BeforeAll` 34; `ConvertTo-FeatureReviewPayload` 39; Contexts 55, 129, 258; F824-9 at 242 with the in-`It` mock at 244; cited by P5-T9.
R9. `tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1` — `$global:LASTEXITCODE = 0` at line 35 inside the stdin helper 26-43, the pattern `Invoke-ClaudeReviewEntry` in T11 follows.
R10. (Superseded in v1.5; re-derived as V2 below.) Presence: `docs/features/active/subagentstop-envelope-core-897/` exists in this worktree (Glob: `issue.md`, `spec.md`, `plan.2026-10-11T07-59.md`, and the three `*.2026-10-11T14-01.md` review artifacts) because HEAD contains the E1 merge `039e53339`; P0-T4 through P0-T7 still read E1's helper and spec from the integration ref.
R11. Plan-internal cross-references touched by this pass: every `git push origin HEAD:<BRANCH>` (P0-T8, P0-T9, P0-T25, P1-T7, P2-T9, P3-T12, P5-T21, P6-T13, P7-T19, P8-T4, P9-T16, P10-T7, P11-T11, P12-T17), and no literal branch name remains outside the header (pattern and the v1.5 alias example), P0-T2 (pattern and alias example), and the v1.5 revision note; the five `(PEF)` gate acceptances P2-T7, P3-T9, P5-T13, P6-T9, P7-T13 plus P11-T6; the four `(N1 rule)` acceptances P2-T7, P5-T13, P6-T9, P7-T13; LIST-TEST (T11 added) and its uses P11-T1, P11-T2, P12-T1; LIST-CLAUDE-SUITES (T11 not added; it is not a Pester run path).

Caller-supplied facts this pass could not verify with the available tools (no shell or `gh`): `ac525c4ef` as the epic start commit (if it is unreachable, the P0-T3 `git log` prints no SHA, which records `E1MergeCommit: NONE` and leads to `Verdict: STOP`); the ten-finding abbreviation in Pester failure messages; integration head `cf3108b04` as a direct merge of E1 preparation documents; PR #881 and PR #863 head names; E1's spec stating `-Anomaly` without `Mandatory`. P0-T3 does not depend on the PR examples (it filters by pattern and falls back to the first-parent merge history), and P0-T6 derives `AnomalyReasonCall:` from E1's spec at execution time.

Re-derived in the round-1 revision pass and not changed by this pass's edits (carried; the edits in this pass do not alter what these assert):

1. `docs/features/active/subagentstop-envelope-feature-review-coverage-896/spec.md` — v1.1; Proposed Fix items 1 (lines 68-79), 2 (80-87), 2a (88-106), 2b (107-111), 3 (112-116), 6 (119); AC-1 through AC-31 (lines 210-278); AC-26 text (258); AC-30 (266-270); AC-31 (271-278).
2. `.claude/hooks/validate-feature-review-coverage.ps1` — 477 lines; help 29-35 ("falls back independently" at 33) and `.NOTES` 40-42; bootstrap 46; thresholds dot-source 47; `$ErrorActionPreference` 49; function starts 51, 75, 106, 131, 150, 171, 196, 218, 231, 253, 268, 345; `Test-LanguageCoverageRow` failure returns 293-296, 301-304, 311-314, 319-322, 328-331, branch return 336-339; floor checks 325-340; decision 345-462 (S6 statements 351-352; payload blocks 354-371; `feature-review hook:` messages 355, 362, 370, 433, 457; `CLAUDE.md` read 444-445; row call 450); entry 464-477 (tail 467-469; `CLAUDE_HOOK_INPUT` 471; `Write-Error` 473; `exit 1` 474); `python` lines 23, 142, 224, 261, 281.
3. `.claude/hooks/feature-review-coverage-thresholds.ps1` — 77 lines; help 19-41 (forms 22-36); defaults 48; regex 57; match loop 58-66; no `python` token.
4. `.codex/hooks/validate-feature-review-coverage.ps1` — 304 lines; help 22-25; guard 43; `Test-LanguageCoverageRow` 142-207 (`80.0` at 196, message 201); continuation 209-228; entry 237-304 (stdin 238; audit exit 259-262 with `exit 0` at 261; changed-language exit 267-269 with `exit 0` at 268; row call 275; footer 284; catch 294-304); `python` lines 13, 29, 77, 135, 152.
5. `.claude/hooks/hook-dependency-guard.ps1` — lines 8-10 (fail-closed purpose), 104-105 (SubagentStop decision `ExitCode`/`Reason`).
6. `tests/scripts/claude-runtime/HookGuardShape.Helpers.ps1` — 155 lines; S1 tail 40-55; S2 101-105; S6 109-116 (`$body[1].Extent.Text -eq 'if ($null -ne $dependencyDecision) { return $dependencyDecision }'` at 115).
7. `tests/scripts/claude-runtime/HookDependencyGraph.Helpers.ps1` — `Get-HookRegistration` 64-118 (`Hook` root-relative, 98 and 114); `Get-HookScriptEdge` 168-240; `Get-HookDependencyClosure` 250-296; `Get-HookDecisionFunctionName` 298-328 (rule (b) at 323).
8. `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` — row discovery 17-29 (`Root` = `repository`/`mirror`); It names S1-S6 at 117-139.
9. `tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1` — root rows 19; `N1` at 67-74.
10. `tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1` — 296 lines; top `BeforeAll` 13-30 (`$script:HookFile` 14; `Get-ArtifactFileResult` 25-29); `Describe` mocks 32-37; `Test-LanguageCoverageRow` context 170-198; Invoke context 200-280 (empty/malformed/empty-output tests 216-226); entry context 282-295 (comment 292).
11. `tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1` — 135 lines; four tests 26-135 using `-RawPayload` and `@{ output = ... }`.
12. `tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1` — 289 lines; helper 39-52; F824 contexts 55-127 and 129-256; F824-9 242-255 (in-`It` mock 244); validation-paths context 258-288 (rows 269-277).
13. `tests/scripts/claude-hooks/validate-feature-review-coverage.ThresholdsGuard.Tests.ps1` — 121 lines; process helper 32-50 (comment 33; env var 36-47); TG1 59-75; TG2 77-99; TG3 101-120 (call 113; `ExitCode`/`Reason` 118-119).
14. `tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1` — 51 lines; T824 rows 28-38; body 39-50.
15. `tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1` — 199 lines; stdin helper 26-43; `$script:ReviewStop`/`ReviewStopActive` 45-46; row pattern 135; entry context 150-198 (synthetic audit object 183).
16. `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` — 497 lines; `$script:SharedModuleNames` line 30 (last element `'hook-dependency-guard.ps1'`).
17. `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1` — edge discovery 18-33; reason prefix 97; process helper 104-124; B1 134-164; B3 183-190.
18. `tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1` — first-edge selection 27-33; `StopPrefix` 53-58.
19. `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` — (re-derived in v1.5 as V3) `feature-review-coverage-thresholds.ps1` line 59, `hook-dependency-guard.ps1` line 66, `subagentstop-envelope.ps1` line 68 (E1 entry), `validate-executor-output.ps1` line 71, `validate-feature-review-coverage.ps1` line 72.
20. `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` — `paths` array at line 4; entries 46, 68.
21. `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` — bundles 27-29; `STEP_EIGHT_COPIES` 70; `EXPECTED_LISTED_COPY_COUNT = 36` line 94; existence test 181-196; step-8 test 241-242.
22. `.agents/skills/feature-review-workflow/SKILL.md` lines 112, 113, 114, 148; `.github/skills/feature-review-workflow/SKILL.md` line 126; `.codex/agents/feature-review.toml` lines 121, 122, 123, 133, 134, 135; `.claude/skills/feature-review-workflow/SKILL.md` has no `80%`/`90%` line.
23. `scripts/powershell/PoshQC/PoshQC.Analyzer.psm1` — format loop 56-66; `scripts/powershell/PoshQC/PoshQC.psm1` line 2 (settings path).
24. `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` — run paths 3; `Exit = $true` 4; JUnit path 15; coverage output 22.
25. `docs/features/active/epic-852-main-sync/evidence/qa-gates/final-pester-coverage.md` — success lines 11-12; per-file figures 20-23.
26. Existence: `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`, `tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1`, `docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/evidence/other/observation-scripts.2026-10-08T17-32.md`, `docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/plan.2026-10-08T13-54.md`.
27. (Re-derived in v1.5 as V2.) Presence: `**/subagentstop-envelope*.ps1` matches `.claude/hooks/subagentstop-envelope.ps1`, its mirror `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/subagentstop-envelope.ps1`, and `tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1`, and `docs/features/active/subagentstop-envelope-core-897/` exists (E1 merged into HEAD through `039e53339`).

Carried from the prior pass without re-derivation (no edit in this pass changed what they assert): `observation-scripts.2026-10-08T17-32.md` lines 320-325, 327-347, 359-370; `plan.2026-10-08T13-54.md` lines 120-150, 191-208, 210-228; `research.2026-10-11T08-10.md` lines 152-165, 274-278, 312.

Sibling-region checks performed: (a) S6 reads `$body[0]` and `$body[1]` of the decision function's end block; the `param()` block is not an end-block statement, so the reshaped parameter does not move the two statements. (b) Rule R-DECISION (b) selects `Invoke-FeatureReviewCoverageValidation` because the entry's call inside a top-level `try` is outside every function definition; the scriptblock inside the function is not a `FunctionDefinitionAst`, so E4-ST4's H1 function set stays `Invoke-FeatureReviewCoverageValidation`. (c) The S1 tail check reads the three statements after the dot-source early return; base lines 467-469 stay in place and the new entry statements follow them. (d) B1 discovers H1's direct edges from the AST: three after Phase 2 (thresholds, metrics, rules) and four after Phase 5 (plus `subagentstop-envelope.ps1`); a failure of any edge exits through the inline tail with the reason naming the dependency. (e) SpecialCases first-edge selection keeps the thresholds edge first. (f) The F824 and T2 assertions `below the 85% line coverage floor`, `below the 75% branch coverage floor`, and `Should -Not -Match 'line coverage floor'` remain true after the `(default)` suffix and the report-and-halt clause, which are appended after the matched text. (g) The Codex entry tests at T6 lines 169-197 do not reach the new `CLAUDE.md` read placed after the changed-language exit, except `requests a continuation`, whose `Get-Content` mock returns figure-free text for `CLAUDE.md`, and `stops the continuation loop`, which still ends in `continue:false`. (h) E4-TR9 needs `Get-ChildItem` and PR-summary mocks because the Codex entry exits 0 at line 261 without an audit and at line 268 without a changed language. (i) `Test-LanguageCoverageRow` returns at the first failure, so E4-TR4a uses one row per metric and E4-TR10c uses two languages (Python line, TypeScript branch) to carry both classes. (j) `git grep -c` counts lines, so the expected per-family base count is 5, not the occurrence count.

Sibling-region checks added in this pass: (k) T11 is dot-sourced inside the E4 Context `BeforeAll`, so its functions and `$script:` fixtures are visible to every E4 `It` added later (P1-T2, P5-T8, P6-T4, P6-T5) without moving them; the `Get-ArtifactFileContent` mock stays a literal script block in T2's `BeforeEach`, so the Hermeticity mock rule and E4-ST6 (which parses T3 only) are unaffected. (l) T11 is not named `*.Tests.ps1`, so Pester discovery over `tests/scripts` (`pester.runsettings.psd1:3`) does not run it as a container; it is excluded from LIST-CLAUDE-SUITES and included in LIST-TEST, so it is formatted, analyzed, size-checked (P11-T1, P11-T2, P12-T1), and searched by the P12-T7 temporary-file grep. (m) T11 function verbs `Invoke`, `ConvertTo`, and `Use` are outside the PSSA state-changing verb set; only T3's `Set-ReviewArtifactMap` needed `SupportsShouldProcess`. (n) A CR-SHA or CR-MIRROR pair with a missing file now prints `MISSING` and counts as a difference, so the nine mirror and SHA acceptances (P0-T23, P2-T5, P3-T7, P5-T12, P6-T7, P7-T1, P7-T11, P9-T6, P10-T1) cannot pass on an absent file; CR-PSSA counts a missing file in `PSSA-TOTAL:`; CR-JSON stops non-zero on a missing manifest. (o) Under the PEF a gate artifact can carry `ExpectedExitCode: 1`; each such gate writes its own artifact file, which satisfies the per-file expectation rule of `evidence-and-timestamp-conventions`. (p) With `Branch:` failing, P0-T8 neither commits nor pushes, so no push targets a branch other than `<BRANCH>`. (q) The N1 relaxation applies only when P0-T12 records `N1-BASELINE: FAILING`; the S1, S2, and S6 acceptances stay exact.

PLANNER-INTERNAL-REVIEW: PASS
CITATION-TO-TREE: PASS
CITATION: docs/features/active/subagentstop-envelope-feature-review-coverage-896/spec.md | Proposed Fix items 1, 2, 2a, 2b, 3, 6 (lines 68-119); AC-1 through AC-31 (lines 210-278)
CITATION: .claude/hooks/validate-feature-review-coverage.ps1 | lines 29-35, 40-49, 51-343 (returns 293-339), 345-462 (349, 351-352, 354-371, 444-445, 450), 464-477 (467-469, 471-474); RawPayload lines 349, 354, 359, 471; python lines 23, 142, 224, 261, 281; 477 lines
CITATION: .claude/hooks/feature-review-coverage-thresholds.ps1 | lines 19-41, 48, 57, 58-66; 77 lines
CITATION: .codex/hooks/validate-feature-review-coverage.ps1 | lines 13, 22-25, 29, 43, 77, 135, 142-207 (152, 196, 201), 209-228, 237-304 (261, 268, 275, 284, 294-304); 304 lines
CITATION: .claude/hooks/hook-dependency-guard.ps1 | lines 8-10, 104-105
CITATION: tests/scripts/claude-runtime/HookGuardShape.Helpers.ps1 | lines 40-55, 101-105, 109-116
CITATION: tests/scripts/claude-runtime/HookDependencyGraph.Helpers.ps1 | lines 64-118, 168-240, 250-296, 298-328
CITATION: tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1 | lines 17-29, 117-139
CITATION: tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1 | lines 19, 67-74 (failure message 73); 156 lines
CITATION: tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | lines 13-37 (14, 16, 25-29), 170-198, 200-280, 282-295; 296 lines
CITATION: .claude/rules/powershell.md | line 30
CITATION: config/poshqc-coverage.json | lines 3-9
CITATION: tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1 | lines 8-12 (dot-source at 11)
CITATION: tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 | lines 26-135
CITATION: tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1 | lines 21, 34, 39-52, 55-127, 129-256, 242-255 (mock 244), 258-288 (F824-V rows 269-277); F824 It lines 56, 79, 103, 130, 153, 176, 198, 220, 242; 289 lines
CITATION: tests/scripts/claude-hooks/validate-feature-review-coverage.ThresholdsGuard.Tests.ps1 | lines 32-50, 59-75, 77-99, 101-120
CITATION: tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1 | lines 28-38, 39-50
CITATION: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | lines 26-46, 135, 150-198 (183)
CITATION: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | line 30; 497 lines
CITATION: tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 | lines 18-33, 97, 104-124, 134-164, 183-190
CITATION: tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1 | lines 27-33, 53-58
CITATION: tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py | lines 27-29, 70, 94, 181-196, 241-242
CITATION: extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json | lines 59, 66, 68, 71, 72 (re-derived v1.5)
CITATION: .claude/hooks/subagentstop-envelope.ps1 | function lines 20, 54, 171 (present after the E1 merge)
CITATION: docs/features/active/subagentstop-envelope-core-897/spec.md | file exists (E1 feature folder present after the E1 merge)
CITATION: .claude/hooks/check-powershell-test-purity.ps1 | lines 102-120 ($forbiddenPatterns)
CITATION: extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json | lines 4, 46, 68
CITATION: .agents/skills/feature-review-workflow/SKILL.md | lines 111-114, 148
CITATION: .github/skills/feature-review-workflow/SKILL.md | line 126
CITATION: .codex/agents/feature-review.toml | lines 121-123, 133-135
CITATION: scripts/powershell/PoshQC/PoshQC.Analyzer.psm1 | lines 56-66
CITATION: scripts/powershell/PoshQC/PoshQC.psm1 | line 2
CITATION: scripts/powershell/PoshQC/settings/pester.runsettings.psd1 | lines 3, 4, 15, 22
CITATION: docs/features/active/epic-852-main-sync/evidence/qa-gates/final-pester-coverage.md | lines 11-12, 20-23
CITATION: tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 | file exists
CITATION: scripts/dev_tools/validate_orchestration_artifacts.py | lines 48-51 (PLAN_PHASE_RE, PLAN_TASK_RE), 145-189 (structure walk)
CITATION: .claude/hooks/validate-feature-review-coverage.ps1 | amendment: 106-129 (118-119), 279-284, 295, 299, 303, 307, 313, 321, 330, 338, 405-415 (413), 417-429, 432-441, 464-466
CITATION: tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 | lines 7-17 (9, 13), 19, 26-36, 38-39
CITATION: tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 | v1.6: same-timestamp mock 39-54 (42, 45, 48, 50-51, 53); allow test 113-133 (116-119, 131); 135 lines
CITATION: .claude/hooks/validate-feature-review-coverage.ps1 | v1.6: Get-ArtifactFileContent returns 60 and 72; artifact loop 382-403 (395-396, 401); 405-415 (413); 417-418; 437-441; 444
CITATION: .claude/skills/feature-review-workflow/SKILL.md | lines 106, 111, 164-172, 180, 181
CITATION: .claude/rules/general-unit-test.md | line 25
CITATION: .claude/rules/quality-tiers.md | line 38
CITATION: .claude/skills/remediation-handoff-atomic-planner/SKILL.md | lines 69-77, 81-84
CITATION: .claude/skills/evidence-and-timestamp-conventions/SKILL.md | line 46
CITATION: docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md | template file (D1 exclusion; siblings code-review and feature-audit)
CITATION: .claude/hooks/validate-planner-output.ps1 | lines 96, 110
CITATION: docs/features/active/subagentstop-envelope-feature-review-coverage-896/plan.2026-10-11T07-58.md | v1.7: Execution Notes plan-file staging rule; 16 task git add commands (P0-T8, P0-T9, P0-T25, P1-T7, P2-T9, P3-T12, P4-T4, P4-T10, P5-T21, P6-T13, P7-T19, P8-T4, P9-T16, P10-T7, P11-T11, P12-T17); P4-T4 BLOCKED git restore paths; P0-T10 AnchorDrift; P12-T8 status acceptance
CITATION: .claude/hooks/validate-feature-review-coverage-rules.ps1 | v1.8: help 11-12; Test-LanguageCoverageRow 93 (params 95-104); label map 109-114; languageLines 120; coverageLines 129; narrowing 137; fragments 125, 133, 143, 151
CITATION: .claude/hooks/check-powershell-test-purity.ps1 | v1.8: $forbiddenPatterns entries 103-119 (17 constant Pattern values)
CITATION: docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/other/corpus-run.initial.2026-10-12T00-11.md | v1.8: CORPUS-REJECT field layout lines 482, 628, 674
CITATION: docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/other/corpus-rule-changes.2026-10-12T00-18.md | v1.8: CorpusGate: BLOCKED line 8; FIX-2 exemplar line 40; FIX-3 and FIX-4 BlockedReason lines 70, 90
AC-TRACEABILITY: PASS
SCOPE-BOUNDARY: PASS
AC-INVENTORY: AC-1, AC-2, AC-3, AC-4, AC-5, AC-6, AC-7, AC-8, AC-9, AC-10, AC-11, AC-12, AC-13, AC-14, AC-15, AC-16, AC-17, AC-18, AC-19, AC-20, AC-21, AC-22, AC-23, AC-24, AC-25, AC-26, AC-27, AC-28, AC-29, AC-30, AC-31
AC-MAPPING: AC-1 | IMPLEMENTATION: P0-T2, P0-T3, P0-T4, P0-T5, P0-T6, P0-T7, P0-T8, P0-T9 | TESTS: P0-T8, P0-T24 | EVIDENCE: evidence/other/upstream-merge-check.TS.md
AC-MAPPING: AC-2 | IMPLEMENTATION: P5-T1, P5-T4, P5-T12 | TESTS: P5-T11, P5-T13 | EVIDENCE: evidence/qa-gates/phase5-transport-pester.TS.md
AC-MAPPING: AC-3 | IMPLEMENTATION: P5-T4 | TESTS: P1-T1, P1-T5, P5-T13, P12-T3 | EVIDENCE: evidence/regression-testing/fail-first.TS.md
AC-MAPPING: AC-4 | IMPLEMENTATION: P5-T3, P5-T4 | TESTS: P5-T7, P5-T8, P5-T13 | EVIDENCE: evidence/qa-gates/phase5-transport-pester.TS.md
AC-MAPPING: AC-5 | IMPLEMENTATION: P5-T3 | TESTS: P5-T10, P5-T11, P5-T13 | EVIDENCE: evidence/qa-gates/phase5-transport-pester.TS.md
AC-MAPPING: AC-6 | IMPLEMENTATION: P5-T6, P5-T7, P5-T9, P5-T10 | TESTS: P5-T14, P6-T9 | EVIDENCE: evidence/qa-gates/claude-suites-transport-grep.TS.md
AC-MAPPING: AC-7 | IMPLEMENTATION: P6-T1, P6-T2 | TESTS: P1-T2, P1-T5, P6-T4, P6-T9 | EVIDENCE: evidence/qa-gates/phase6-cr4-pester.TS.md
AC-MAPPING: AC-8 | IMPLEMENTATION: P6-T3, P7-T5 | TESTS: P7-T12, P7-T13, P9-T10 | EVIDENCE: evidence/qa-gates/phase7-codex-pester.TS.md
AC-MAPPING: AC-9 | IMPLEMENTATION: P2-T1, P2-T2, P2-T3, P2-T4, P6-T1 | TESTS: P2-T6, P6-T6, P6-T9, P10-T3 | EVIDENCE: evidence/qa-gates/manifest-pytest.TS.md
AC-MAPPING: AC-10 | IMPLEMENTATION: P2-T1, P2-T2, P2-T3 | TESTS: P12-T1 | EVIDENCE: evidence/qa-gates/file-size.TS.md
AC-MAPPING: AC-11 | IMPLEMENTATION: P3-T1 | TESTS: P1-T3, P1-T5, P3-T8 | EVIDENCE: evidence/qa-gates/phase3-resolver-pester.TS.md
AC-MAPPING: AC-12 | IMPLEMENTATION: P3-T2, P3-T3, P3-T4 | TESTS: P3-T5, P3-T6, P3-T8, P3-T9 | EVIDENCE: evidence/qa-gates/phase3-claude-pester.TS.md
AC-MAPPING: AC-13 | IMPLEMENTATION: P5-T9 | TESTS: P5-T11, P5-T13 | EVIDENCE: evidence/qa-gates/phase5-transport-pester.TS.md
AC-MAPPING: AC-14 | IMPLEMENTATION: P7-T1, P7-T11 | TESTS: P7-T8, P7-T13 | EVIDENCE: evidence/qa-gates/phase7-codex-pester.TS.md
AC-MAPPING: AC-15 | IMPLEMENTATION: P7-T2, P7-T3, P7-T4, P7-T5 | TESTS: P7-T7, P7-T13 | EVIDENCE: evidence/qa-gates/phase7-codex-pester.TS.md
AC-MAPPING: AC-16 | IMPLEMENTATION: P7-T3, P7-T4 | TESTS: P1-T4, P1-T5, P7-T6, P7-T7, P7-T13 | EVIDENCE: evidence/qa-gates/phase7-codex-pester.TS.md
AC-MAPPING: AC-17 | IMPLEMENTATION: P7-T4 | TESTS: P7-T13, P7-T14 | EVIDENCE: evidence/qa-gates/codex-config-unchanged.TS.md
AC-MAPPING: AC-18 | IMPLEMENTATION: P7-T9, P7-T10 | TESTS: P7-T13, P10-T3 | EVIDENCE: evidence/qa-gates/manifest-pytest.TS.md
AC-MAPPING: AC-19 | IMPLEMENTATION: P7-T3, P7-T4 | TESTS: P8-T1, P8-T2 | EVIDENCE: evidence/qa-gates/phase8-parity-pester.TS.md
AC-MAPPING: AC-20 | IMPLEMENTATION: P9-T1, P9-T2, P9-T3, P9-T4, P9-T5, P9-T6 | TESTS: P9-T7, P9-T8 | EVIDENCE: evidence/qa-gates/phase9-texts-pytest.TS.md
AC-MAPPING: AC-21 | IMPLEMENTATION: P9-T7 | TESTS: P9-T9 | EVIDENCE: evidence/qa-gates/phase9-step-eight-pytest.TS.md
AC-MAPPING: AC-22 | IMPLEMENTATION: P9-T1, P9-T3, P9-T4 | TESTS: P9-T11 | EVIDENCE: evidence/qa-gates/policy-files-unchanged.TS.md
AC-MAPPING: AC-23 | IMPLEMENTATION: P2-T5, P3-T7, P5-T12, P6-T7, P7-T1, P7-T11, P9-T6 | TESTS: P10-T1, P10-T2 | EVIDENCE: evidence/other/mirror-log.TS.md
AC-MAPPING: AC-24 | IMPLEMENTATION: P1-T1, P1-T2, P1-T3, P1-T4 | TESTS: P1-T5, P12-T3 | EVIDENCE: evidence/regression-testing/fail-first.TS.md
AC-MAPPING: AC-25 | IMPLEMENTATION: P0-T13, P11-T7 | TESTS: P0-T14, P11-T8, P12-T2 | EVIDENCE: evidence/qa-gates/final-pester-coverage.TS.md
AC-MAPPING: AC-26 | IMPLEMENTATION: P2-T1, P2-T2, P7-T1 | TESTS: P0-T22, P12-T4, P12-T5, P12-T6, P12-T7 | EVIDENCE: evidence/qa-gates/constraints.TS.md, evidence/qa-gates/constraints-no-python.TS.md, evidence/qa-gates/constraints-temp-files.TS.md
AC-MAPPING: AC-27 | IMPLEMENTATION: P0-T9 | TESTS: P12-T8 | EVIDENCE: evidence/qa-gates/scope-boundary.TS.md
AC-MAPPING: AC-28 | IMPLEMENTATION: P11-T1, P11-T3 | TESTS: P11-T2, P11-T4, P11-T5, P11-T6, P11-T7, P11-T9 | EVIDENCE: evidence/qa-gates/final-qc-loop.TS.md
AC-MAPPING: AC-29 | IMPLEMENTATION: P12-T9 | TESTS: PR-time gh pr view body check under the epic orchestrator | EVIDENCE: evidence/other/ac-29-handoff.TS.md
AC-MAPPING: AC-30 | IMPLEMENTATION: P5-T2, P5-T3, P6-T2 | TESTS: P6-T4, P6-T5, P6-T9 | EVIDENCE: evidence/qa-gates/phase6-cr4-pester.TS.md
AC-MAPPING: AC-31 | IMPLEMENTATION: P5-T1, P5-T3, P5-T4 | TESTS: P5-T10, P5-T13 | EVIDENCE: evidence/qa-gates/phase5-transport-pester.TS.md
UNRESOLVED-GAPS: NONE
