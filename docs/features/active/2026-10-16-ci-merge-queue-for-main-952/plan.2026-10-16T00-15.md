# 2026-10-16-ci-merge-queue-for-main (Plan)

- **Issue:** #952
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-16T03-30
- **Status:** Draft (awaiting executor preflight)
- **Version:** 1.0
- **Work Mode:** full-bug (`issue.md` metadata `- Work Mode: full-bug`; `spec.md` `## Acceptance Criteria`, AC-1 through AC-28, is the acceptance-criteria source; `user-story.md` is intentionally absent)
- **Branch:** `bug/ci-merge-queue-for-main-952`
- **Feature folder:** `docs/features/active/2026-10-16-ci-merge-queue-for-main-952`
- **Requirements sources:** `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md`; `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/issue.md`; `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/research/research.2026-10-16T01-30.md`; `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/protect-main.current.2026-10-16.json` (read-only snapshot of ruleset 15241672)

**Fail-closed evidence rule:** Include explicit baseline artifact tasks, final-QA artifact tasks, and coverage-comparison tasks for each in-scope language when policy requires coverage. If any required baseline artifact, QA artifact, or coverage-comparison artifact is missing, the audit verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Record the expected artifact path in each evidence-producing task. Do not mark evidence-backed work complete without the artifact. Every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. `Timestamp:` is UTC read from the host clock when the command runs (`Get-Date -AsUTC -Format yyyy-MM-ddTHH-mm`). Each artifact file name is `<name>.<timestamp>.md`, where `<timestamp>` is the UTC write time in `yyyy-MM-ddTHH-mm` form; a task that consumes an artifact selects the lexicographically greatest file matching `<name>.*.md`.

**Evidence location:** every artifact is written under `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/<kind>/` with `<kind>` one of `baseline`, `regression-testing`, `qa-gates`, `other`. No artifact is written under `artifacts/`. No artifact records an absolute host path.

**Scratch location:** `SCRATCH` resolves to `<session scratchpad>/issue-952/`. The only scratch files this plan produces are Pester coverage XML outputs, each named `SCRATCH/issue-952-<run>.coverage.xml`. Evidence records the literal token `SCRATCH`, never a host path. No executor writes a PowerShell scratch file with the Write or Edit tool; every PowerShell command in Appendix R is entered directly into the PowerShell tool.

## Scope Recap

Binding scope is `spec.md` `## Scope & Non-Goals` and `## Proposed Fix`:

1. `.github/workflows/ci.yml` gains `merge_group: types: [checks_requested]` with no filter; `.github/workflows/README.md` lists it; `tests/scripts/workflows/CiWorkflow.Tests.ps1` asserts it and asserts that the `ci.yml` call graph reads no pull-request event field.
2. The merge gate becomes method-agnostic on both runtimes. A new helper file per runtime (`enforce-epic-merge-gate-command.ps1`, byte-identical on both runtimes) holds the scope predicate and a gh-aware PR selector reader.
3. A pure parser `.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1` maps one PR snapshot to `merged | pending | not_queued | closed`.
4. Every Claude and Codex merge procedure records a merge only after confirmation by polling and ancestry check.
5. `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` drops `--delete-branch` and waits for a confirmed merge before checkout, pull, and tag.
6. Three ruleset payloads and a runbook are shipped under `ruleset/` in the feature folder and are not applied.

## Decisions Recorded by the Planner

- **PR-number reader delegation (deviation note for #927).** The caller asked that edits to `.claude/hooks/enforce-epic-merge-gate.ps1` be limited to the scope-filter call site, the dot-source, header comments, and the deny message. `spec.md` `### Implementation strategy` additionally requires the gh-aware selector reader to replace "the body of `Get-EpicMergeGateCommandPrNumber` on Claude and `Get-CodexMergeCommandPrNumber` on Codex", and AC-8 tests that reader by name. The plan therefore also replaces the reader's body (`.claude/hooks/enforce-epic-merge-gate.ps1:131-142`) with a one-line delegation to the helper and rewrites its `.DESCRIPTION` (`:104-118`). All parsing logic lives in the helper file. This is a fifth, small edit region and is listed in `## Concurrency and Out-of-Scope Constraints`.
- **`awaiting_merge_queue` is procedure text only.** `scripts/dev_tools/_orchestrator_state_blocked_reason.py` defines a closed `blocked_reason` vocabulary that does not contain `awaiting_merge_queue`, and the parallel `merge_status` enum is validator-owned. The procedure texts therefore report `awaiting_merge_queue` without writing it into any validated enum field: the parallel procedure leaves `merge_status` at `ci_green`; orchestrate S9 step 6 records a finding naming `awaiting_merge_queue` with `Remediability: awaiting_ci` and uses the existing `blocked_reason: "awaiting_ci"` wait branch. This matches `spec.md` `## Data / API / Config Impact` ("No schema migration is introduced").
- **Poll query.** Procedures and the release flow read merge state with one `gh api graphql` query that includes `isInMergeQueue` (research Q3: `gh pr view --json` has no `isInMergeQueue` field). The query uses gh's documented `{owner}` and `{repo}` placeholder substitution in `-F` field values. The merge gate allows this read query (AC-7 allow case G5 in Appendix B uses the exact procedure query).
- **Release-flow wait stays in `Invoke-FullReleaseFlow.ps1`.** The file is 401 lines; the projected size after the change is about 475 lines. P5-T10 asserts at most 500. The wait reuses the parser by dot-sourcing `.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1`.
- **Contract pins.** `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py` is 426 lines. The new fragment table lives in a new data module `tests/scripts/dev_tools/merge_queue_documentation_expectations.py`; the contract module gains one parametrized test and four mirror pairs (about 25 lines). `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` is not edited; its pin "Execute `gh pr merge --merge <PR>`" stays verbatim.
- **Authorization rows `--squash`.** `tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1:102` and `tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1:95` already expect `allow` with a valid record; under the method-agnostic scope they still allow (the record now authorizes them). Their rows are not edited. The two files are edited only at the pinned deny-text constants (`:83` and `:79`), which AC-11 changes.
- **PowerShell verification route.** Format check, analyzer, and Pester run in-process in the PowerShell tool using the commands of Appendix R, which print the same `FORMAT-SUMMARY ChangedCount=`, `TotalCount=`, `PassedCount=`, `FailedCount=`, `FailedContainersCount=`, and `COVERAGE file=... LinePercent=` lines observed in the committed runs `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/baseline/format-check.2026-10-11T23-59.md:24` and `docs/features/active/subagentstop-envelope-orchestrator-family-903/evidence/baseline/pester-coverage.2026-10-12T00-02.md:12`. The MCP PoshQC tools are not used for any asserted value.
- **PowerShell coverage.** Line coverage per production file comes from the R1 `COVERAGE` lines (analyzed lines are the distinct lines of executed or missed commands; covered lines are the distinct lines of executed commands). Threshold: 85% line (the root `CLAUDE.md` states no threshold, so the default in `.claude/rules/general-unit-test.md` applies); Pester has no branch metric. Production files in scope are T3 (`.claude/hooks`, `.codex/hooks`, `.claude/lib/ci-gate`) and T4 (`scripts/dev-tools`) per `quality-tiers.yml`, so no property-test or mutation obligation applies.
- **Python coverage.** No production Python file is created or modified (see `## Files Written`). The touched Python files are a test module and a test-data module, which coverage tooling excludes. Python coverage is recorded as not applicable by P0-T19 and verified by P8-T16.
- **Mirror mechanism.** Every bundle mirror is produced by a byte copy (`Copy-Item -LiteralPath <source> -Destination <mirror> -Force` in the PowerShell tool) immediately after the source edit, then verified by `git hash-object`. The Codex helper `.codex/hooks/enforce-epic-merge-gate-command.ps1` is a byte copy of the Claude helper.
- **Edit order.** Edits within one file run bottom-up so the cited line numbers stay valid at each step.
- **AC-25 interpretation.** `issue.md`, the research file, the ruleset snapshot, and the plan file were added on this branch before execution, so a diff against `main` lists them as added. AC-25 is verified against `PLAN_BASE_SHA` (recorded by P0-T2): the first three are byte-unchanged, and the plan file's only changes are checklist transitions from `- [ ]` to `- [x]`.

## Concurrency and Out-of-Scope Constraints

- **Concurrent item #927** is expected to touch `.claude/hooks/enforce-epic-merge-gate*.ps1` (docs-only merge allowance; not verifiable from the tree per research Q5). Overlapping files: `.claude/hooks/enforce-epic-merge-gate.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1`, `.codex/hooks/enforce-epic-merge-gate.ps1`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1`, `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`, and possibly `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1`. Edit regions in `.claude/hooks/enforce-epic-merge-gate.ps1` are limited to: header `:3`, `:7-8`, `:34`; the guarded dot-source inserted after `:72`; the reader `.DESCRIPTION` and body `:104-118`, `:131-142` (delegation only; see Decisions); the scope-filter call site `:334-356`; and the deny message `:415`. All new logic is in `.claude/hooks/enforce-epic-merge-gate-command.ps1`. P0-T3 and P3-T1 check `origin/main` for #927 changes to these files and halt for the caller when any exist; the plan never rebases or force-pushes.
- **Concurrent item #953** owns `.github/workflows/_poshqc.yml`. This plan does not edit it (research Q1: reusable workflows inherit the caller's event; only `ci.yml` needs `merge_group`).
- **Not edited by this plan:** `.github/workflows/_poshqc.yml` and every workflow other than `.github/workflows/ci.yml` and `.github/workflows/README.md`; every file under `.claude/rules/` and `.github/instructions/`; `.claude/hooks/hook-command-invocation.ps1` and `.codex/hooks/hook-command-invocation.ps1` (no gh-specific flag is added to the shared tables); `.claude/skills/parallel-run/SKILL.md`; `.claude/skills/cleanup-merged-worktrees/SKILL.md`; every `.github/` agent, skill, prompt, and instruction file; `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`; `issue.md`; `research/research.2026-10-16T01-30.md`; `ruleset/protect-main.current.2026-10-16.json`. The ruleset is not applied.
- No force-push. No deletion of any file. No GitHub issue creation. Every commit uses `git add` of explicit paths.

## Out-of-Scope Follow-ups (recorded, not tasks)

- Policy edit (requires approval): `.claude/rules/orchestrator-state.md:238` states the gate consults authorization records only for a `gh pr merge --merge` command; after this item the gate covers every merge and enqueue spelling.
- Policy edit (requires approval): `.claude/rules/parallel-orchestration.md:689` describes the gate as authorizing a per-item `gh pr merge --merge`; `.claude/rules/parallel-orchestration.md:154` lists `gh pr view --json state,mergedAt,headRefOid` as the source of the merge commit although none of those fields is a merge commit.
- `.claude/skills/cleanup-merged-worktrees/SKILL.md:206-208` describes strict up-to-date enforcement; the wording becomes stale only after a merge queue is applied.
- Optional: `.github/workflows/README.md:34-75` documents the legacy branch-protection endpoint rather than the ruleset endpoint in use.
- Evaluate gating `gh` invocations issued through the Claude PowerShell tool (no `PreToolUse` matcher covers that tool; research Q6).

## Files Written

Every repository-relative path this plan creates or modifies. No task writes a path absent from this list.

Overlap note: concurrent item #927 is expected to touch `.claude/hooks/enforce-epic-merge-gate*.ps1` (docs-only merge allowance). Files in this list that it may also touch: `.claude/hooks/enforce-epic-merge-gate.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1`, `.codex/hooks/enforce-epic-merge-gate.ps1`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1`, both `pack-manifests/core.json` files, and `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1`. Edit regions in `.claude/hooks/enforce-epic-merge-gate.ps1` are limited as stated in `## Concurrency and Out-of-Scope Constraints`; all new logic is in the new helper file.

Created (16: 12 outside the feature folder, 4 inside it):

- `.claude/hooks/enforce-epic-merge-gate-command.ps1` (P3-T2)
- `.codex/hooks/enforce-epic-merge-gate-command.ps1` (P3-T9, byte copy)
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-command.ps1` (P3-T16)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate-command.ps1` (P3-T16)
- `.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1` (P4-T5)
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1` (P4-T7)
- `tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1` (P2-T1)
- `tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1` (P2-T3)
- `tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1` (P4-T1)
- `tests/scripts/claude-lib/ci-gate/MergeConfirmationParser.Manifest.Tests.ps1` (P4-T3)
- `tests/scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.Tests.ps1` (P5-T3)
- `tests/scripts/dev_tools/merge_queue_documentation_expectations.py` (P6-T1)
- `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/protect-main.merge-queue.apply.json` (P7-T1)
- `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/protect-main.non-strict.alternative.json` (P7-T2)
- `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/protect-main.rollback.json` (P7-T3)
- `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/runbook.md` (P7-T5)

Modified outside the feature folder (30):

- `.github/workflows/ci.yml` (P1-T3)
- `.github/workflows/README.md` (P1-T5)
- `tests/scripts/workflows/CiWorkflow.Tests.ps1` (P1-T1)
- `.claude/hooks/enforce-epic-merge-gate.ps1` (P3-T3 through P3-T7)
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1` (P3-T16)
- `.codex/hooks/enforce-epic-merge-gate.ps1` (P3-T10 through P3-T14)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1` (P3-T16)
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (P3-T17, P4-T8)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` (P3-T17)
- `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` (P2-T5)
- `tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1` (P2-T6)
- `tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1` (P2-T7)
- `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` (P5-T5 through P5-T8)
- `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1` (P5-T1)
- `tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1` (P5-T2)
- `.claude/skills/parallel-orchestrate/SKILL.md` (P6-T4 through P6-T7)
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md` (P6-T8)
- `.claude/agents/parallel-orchestrator.md` (P6-T9)
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-orchestrator.md` (P6-T10)
- `.claude/skills/orchestrate/SKILL.md` (P6-T11, P6-T12)
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md` (P6-T13)
- `.claude/skills/epic-orchestrate/SKILL.md` (P6-T14 through P6-T16)
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md` (P6-T17)
- `.claude/agents/epic-orchestrator.md` (P6-T18)
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/epic-orchestrator.md` (P6-T19)
- `.agents/skills/epic-orchestrate/SKILL.md` (P6-T20)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-orchestrate/SKILL.md` (P6-T21)
- `.codex/agents/epic-orchestrator.toml` (P6-T22)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/epic-orchestrator.toml` (P6-T23)
- `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py` (P6-T2)

Inside the feature folder:

- `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md` (Phase 9 AC check-off only)
- `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/plan.2026-10-16T00-15.md` (checklist state only)
- `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/` (the four created files above)
- `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/**` (every evidence artifact named in the tasks)

Scratch (outside the repository): `SCRATCH/issue-952-*.coverage.xml` only.

Deleted: none.

The set "outside the feature folder" used by P8-T17 is therefore exactly 42 paths: the 12 created paths outside the feature folder plus the 30 modified paths.

## Restart Rule (Phase 8)

P8-T1 through P8-T15 form the final QA loop. If any of them fails, or if any of them changes a tracked file, fix the cause, re-copy the affected bundle mirror when the changed file has one, and restart from P8-T1. Write a new artifact for each re-run task (a new `<timestamp>`). Do not proceed to P8-T16 until P8-T1 through P8-T15 pass in one uninterrupted pass. If a hook denies a required command, stop and report the denial; do not bypass the hook.

### Phase 0 — Baseline Capture

- [ ] [P0-T1] Read the policy files in the required order and write `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/baseline/phase0-instructions-read.<timestamp>.md`.
  Order: `CLAUDE.md`; `.github/copilot-instructions.md`; `.claude/rules/tonality.md`; `.github/instructions/tonality.instructions.md`; `.claude/rules/general-code-change.md`; `.github/instructions/general-code-change.instructions.md`; `.claude/rules/general-unit-test.md`; `.github/instructions/general-unit-test.instructions.md`; `.claude/rules/quality-tiers.md`; `quality-tiers.yml`; `.claude/rules/powershell.md`; `.github/instructions/powershell-code-change.instructions.md`; `.github/instructions/powershell-unit-test.instructions.md`; `.claude/rules/python.md`; `.claude/rules/python-suppressions.md`; `.github/instructions/python-code-change.instructions.md`; `.github/instructions/python-unit-test.instructions.md`; `.claude/rules/ci-workflows.md`; `.github/instructions/github-actions.instructions.md`; `.claude/rules/plan-acceptance-gates.md`.
  Acceptance: the artifact contains `Timestamp:`, `Policy Order:`, and the twenty paths above in that order, one per line; it records `Work Mode: full-bug` read from `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/issue.md`, `spec.md: present`, and `user-story.md: absent` after a Glob of `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/{spec.md,user-story.md}`. No policy file is modified.
- [ ] [P0-T2] Capture the baseline branch state into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/baseline/branch-state.<timestamp>.md`.
  Commands: `git fetch origin`; `git rev-parse --abbrev-ref HEAD`; `git rev-parse HEAD`; `git rev-parse origin/main`; `git merge-base HEAD origin/main`; `git status --porcelain`.
  Acceptance: `EXIT_CODE: 0` for each command; `Output Summary:` records the branch name `bug/ci-merge-queue-for-main-952` (any other value fails the task and halts execution), `PLAN_BASE_SHA=<git rev-parse HEAD output>`, the `origin/main` SHA, the merge-base SHA, and the porcelain output verbatim (expected empty; a non-empty output fails the task and halts execution).
- [ ] [P0-T3] Check for concurrent changes on `origin/main` to the files this plan shares with #927 and #953, and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/baseline/concurrency-check.<timestamp>.md`.
  Command: `git log --oneline HEAD..origin/main -- .claude/hooks/enforce-epic-merge-gate.ps1 .codex/hooks/enforce-epic-merge-gate.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1 .github/workflows/ci.yml .github/workflows/_poshqc.yml`
  Acceptance: `EXIT_CODE: 0`; the output is recorded verbatim. An empty output records `CONCURRENT_CHANGES=0`. A non-empty output records `CONCURRENT_CHANGES=<line count>`, fails the task, and halts execution for the caller (a branch update decision belongs to the orchestrator; this plan neither rebases nor force-pushes).
- [ ] [P0-T4] Record the PowerShell runtime into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/baseline/powershell-runtime.<timestamp>.md`.
  Command (PowerShell tool): `"PS=$($PSVersionTable.PSVersion)"; "PESTER=$((Get-Module -ListAvailable Pester | Sort-Object Version -Descending | Select-Object -First 1).Version)"; "PSSA=$((Get-Module -ListAvailable PSScriptAnalyzer | Sort-Object Version -Descending | Select-Object -First 1).Version)"`
  Acceptance: the three printed lines are recorded; `PS` major version is at least 7, `PESTER` is at least 5.6.1, and `PSSA` is non-empty. Any other value fails the task and halts execution, because every suite in scope declares `#Requires -Version 7.0` and Appendix R needs Pester 5.6.1 or later.
- [ ] [P0-T5] Capture the line endings of the nine existing source and mirror pairs into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/baseline/line-endings.<timestamp>.md`.
  Command: `git ls-files --eol -- .claude/hooks/enforce-epic-merge-gate.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1 .codex/hooks/enforce-epic-merge-gate.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1 .claude/skills/parallel-orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md .claude/agents/parallel-orchestrator.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-orchestrator.md .claude/skills/orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md .claude/skills/epic-orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md .claude/agents/epic-orchestrator.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/epic-orchestrator.md .agents/skills/epic-orchestrate/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-orchestrate/SKILL.md .codex/agents/epic-orchestrator.toml extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/epic-orchestrator.toml`
  Acceptance: `EXIT_CODE: 0`; the output has 18 lines; `Output Summary:` records each pair's `i/` and `w/` values and whether both members match. A mismatched pair is recorded, not repaired (the byte-copy mirror mechanism makes the pair identical after the edit).
- [ ] [P0-T6] Capture the baseline mirror hashes into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/baseline/mirror-hashes.<timestamp>.md`.
  Command: `git hash-object` over the 18 paths of P0-T5, in the same order.
  Acceptance: `EXIT_CODE: 0`; 18 hashes recorded with their paths; `Output Summary:` records `PAIRS_EQUAL=<n>/9`. A value other than `9/9` fails the task and halts execution, because a pre-existing mirror drift would be overwritten silently by the byte-copy mechanism.
- [ ] [P0-T7] Capture the baseline line counts into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/baseline/line-counts.<timestamp>.md`.
  Command: `git grep -c "" -- .claude/hooks/enforce-epic-merge-gate.ps1 .codex/hooks/enforce-epic-merge-gate.ps1 scripts/dev-tools/Invoke-FullReleaseFlow.ps1 tests/scripts/workflows/CiWorkflow.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1 tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py`
  Acceptance: `EXIT_CODE: 0`; ten counts recorded verbatim, each at or below 500. Planner-read values for cross-check: 472, 385, 401, 174, 465, 181, 205, 426, 99, 426.
- [ ] [P0-T8] Capture the baseline PowerShell format state of the nine existing PowerShell files this plan modifies into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/baseline/powershell-format.<timestamp>.md`.
  Command: Appendix R2 (read-only) with `$Path` = `.claude/hooks/enforce-epic-merge-gate.ps1`, `.codex/hooks/enforce-epic-merge-gate.ps1`, `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`, `tests/scripts/workflows/CiWorkflow.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1`, `tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1`, `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1`, `tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1`.
  Acceptance: the artifact records every `FORMAT file=` line and the line `FORMAT-SUMMARY ChangedCount=0`. Any other count fails the task and halts execution, because pre-existing format drift would make the P8-T1 gate unattributable.
- [ ] [P0-T9] Capture the baseline analyzer state of the same nine files into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/baseline/powershell-analyze.<timestamp>.md`.
  Command: Appendix R3 with the P0-T8 `$Path` list.
  Acceptance: the artifact records every `PSSA file=` line, every `PSSA-FINDING` line, and the `PSSA-SUMMARY FindingCount=<n>` line. The per-file counts are the baseline that P8-T2 compares against.
- [ ] [P0-T10] Capture the baseline Pester result and coverage of the Claude merge gate into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/baseline/pester-claude-merge-gate.<timestamp>.md`.
  Command: Appendix R1 with `$TestPath` = the seven files `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.AuthorizationFields.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1`; `$CoveragePath` = `.claude/hooks/enforce-epic-merge-gate.ps1`; run name `claude-gate-base`.
  Acceptance: the artifact records the `TotalCount=`, `PassedCount=`, `FailedCount=`, and `FailedContainersCount=` lines and the `COVERAGE file=.claude/hooks/enforce-epic-merge-gate.ps1` and `MISSED` lines verbatim; `Output Summary:` records `PS_BASE_CLAUDE_GATE=<LinePercent>` (numeric). `FailedCount=0` and `FailedContainersCount=0` are required; any failure is recorded with its `FAILED:` lines and halts execution for the caller. CI equivalent: job `poshqc / PowerShell QC` (coverage) and job `poshqc / PowerShell hook suites (Linux)` (no coverage).
- [ ] [P0-T11] Capture the baseline Pester result and coverage of the Codex merge gate into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/baseline/pester-codex-merge-gate.<timestamp>.md`.
  Command: Appendix R1 with `$TestPath` = `tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1`, `tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1`, `tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1`; `$CoveragePath` = `.codex/hooks/enforce-epic-merge-gate.ps1`; run name `codex-gate-base`.
  Acceptance: as P0-T10, with `PS_BASE_CODEX_GATE=<LinePercent>` recorded. CI equivalent: job `poshqc / PowerShell QC` and job `poshqc / PowerShell hook suites (Linux)`.
- [ ] [P0-T12] Capture the baseline Pester result and coverage of the release flow into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/baseline/pester-release-flow.<timestamp>.md`.
  Command: Appendix R1 with `$TestPath` = `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1`, `tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1`, `tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1`; `$CoveragePath` = `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`; run name `release-base`.
  Acceptance: as P0-T10, with `PS_BASE_RELEASE=<LinePercent>` recorded. CI equivalent: job `poshqc / PowerShell QC`.
- [ ] [P0-T13] Capture the baseline Pester result of the guard, workflow, and CI-gate suites into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/baseline/pester-guards.<timestamp>.md`.
  Command: Appendix R1 with `$TestPath` = the Appendix R1 guard set (G-SET) and `$CoveragePath` empty; run name `guards-base`.
  Acceptance: the four count lines are recorded verbatim; `FailedCount=0` and `FailedContainersCount=0` are required; any failure is recorded with its `FAILED:` lines and halts execution for the caller. CI equivalent: job `poshqc / PowerShell QC`; the `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks` members also run in job `poshqc / PowerShell hook suites (Linux)`.
- [ ] [P0-T14] Capture the baseline Python contract-suite result into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/baseline/python-contract-suites.<timestamp>.md`.
  Command: `poetry run pytest tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py tests/scripts/dev_tools/test_skill_bundle_contract_repo.py -q`
  Acceptance: `EXIT_CODE: 0` and the final pytest summary line recorded verbatim, containing `passed` and neither `failed` nor `error`. A failure is recorded with its node IDs and halts execution for the caller.
- [ ] [P0-T15] Capture the baseline node count of the documentation contract module into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/baseline/contract-module-count.<timestamp>.md`.
  Command: `poetry run pytest tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py -q`
  Acceptance: `EXIT_CODE: 0`; the summary line `<N> passed` recorded verbatim; `Output Summary:` records `CONTRACT_BASE_PASSED=<N>` (planner count from the module text: 33). P6-T3 and P6-T24 derive their expected counts from this value.
- [ ] [P0-T16] Capture the baseline Black state into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/baseline/python-black.<timestamp>.md`.
  Command: `poetry run black --check tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py`
  Acceptance: `EXIT_CODE: 0` and the printed line `1 file would be left unchanged.` recorded.
- [ ] [P0-T17] Capture the baseline Ruff state into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/baseline/python-ruff.<timestamp>.md`.
  Command: `poetry run ruff check tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py`
  Acceptance: `EXIT_CODE: 0` and the printed line `All checks passed!` recorded.
- [ ] [P0-T18] Capture the baseline Pyright state into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/baseline/python-pyright.<timestamp>.md`.
  Command: `poetry run pyright tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py`
  Acceptance: `EXIT_CODE: 0` and the printed line `0 errors, 0 warnings, 0 informations` recorded.
- [ ] [P0-T19] Record Python coverage applicability into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/baseline/python-coverage-applicability.<timestamp>.md`.
  Acceptance: the artifact records `PY_COVERAGE=NOT-APPLICABLE`, the reason (the plan's `## Files Written` names only `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py` and `tests/scripts/dev_tools/merge_queue_documentation_expectations.py` as Python paths, both under `tests/`, which coverage measurement excludes per `.claude/rules/general-unit-test.md`), and the statement that P8-T16 verifies zero `.py` paths outside `tests/` in the final diff.
- [ ] [P0-T20] Commit and push the Phase 0 evidence under `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/` and the checklist state of `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/plan.2026-10-16T00-15.md`.
  Commands: `git add docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/ docs/features/active/2026-10-16-ci-merge-queue-for-main-952/plan.2026-10-16T00-15.md`; `git commit -m "docs(952): record phase 0 baseline evidence"`; `git push origin bug/ci-merge-queue-for-main-952`.
  Acceptance: `git status --porcelain -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/` prints nothing, and `git rev-parse HEAD` equals `git rev-parse origin/bug/ci-merge-queue-for-main-952`. No force-push.

### Phase 1 — Workflow Trigger (merge_group)

- [ ] [P1-T1] Add the two `It` blocks of Appendix A to `tests/scripts/workflows/CiWorkflow.Tests.ps1`, inside the existing `Describe "ci.yml workflow triggers"` block, after the `It "keeps the push branch filter exactly main and development"` block (ends at `:173`) and before the closing `}` of the `Describe` (`:174`).
  Acceptance: `git grep -n -F -e "declares merge_group with types checks_requested" -- tests/scripts/workflows/CiWorkflow.Tests.ps1` prints exactly one line, and `git grep -n -F -e "reads no pull-request event field" -- tests/scripts/workflows/CiWorkflow.Tests.ps1` prints exactly one line. The file creates no file, starts no process, and reads only `.github/workflows/*.yml`.
- [ ] [P1-T2] [expect-fail] Run the workflow suite before editing `ci.yml` and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/ciworkflow-before.<timestamp>.md`.
  Command: Appendix R1 with `$TestPath` = `tests/scripts/workflows/CiWorkflow.Tests.ps1`, `$CoveragePath` empty, run name `ciworkflow-before`.
  Acceptance: the artifact records `TotalCount=4`, `PassedCount=3`, `FailedCount=1`, `FailedContainersCount=0`, and exactly one `FAILED:` line naming `declares merge_group with types checks_requested and no branch or path filter`. Any other outcome fails the task: the new test must discriminate the current tree before `ci.yml` changes. CI equivalent: job `poshqc / PowerShell QC`.
- [ ] [P1-T3] Edit `.github/workflows/ci.yml`: insert the two lines `  merge_group:` and `    types: [checks_requested]` immediately after `:8` (`  workflow_dispatch:`) and before the blank line `:9`. No other line changes.
  Acceptance: `git grep -n -F -e "merge_group:" -- .github/workflows/ci.yml` prints exactly one line numbered 9, and `git grep -n -F -e "types: [checks_requested]" -- .github/workflows/ci.yml` prints exactly one line numbered 10; `git diff --numstat HEAD -- .github/workflows/ci.yml` prints `2	0	.github/workflows/ci.yml`.
- [ ] [P1-T4] Run the workflow suite after the edit and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/ciworkflow-after.<timestamp>.md`.
  Command: Appendix R1 with `$TestPath` = `tests/scripts/workflows/CiWorkflow.Tests.ps1`, `$CoveragePath` empty, run name `ciworkflow-after`.
  Acceptance: `TotalCount=4`, `PassedCount=4`, `FailedCount=0`, `FailedContainersCount=0` recorded (AC-1, AC-2). CI equivalent: job `poshqc / PowerShell QC`.
- [ ] [P1-T5] Edit `.github/workflows/README.md` `## Triggers`: replace `:10` "`ci.yml` runs on three triggers:" with "`ci.yml` runs on four triggers:", and insert after `:14` ("- `workflow_dispatch`.") the single line "- `merge_group` (`types: [checks_requested]`, no branch or path filter), which serves a merge queue on `main`: when a queue is enabled, every required check is produced by a `merge_group` run of `ci.yml` (issue #952)."
  Acceptance: `git grep -n -F -e "runs on four triggers" -- .github/workflows/README.md` prints exactly one line, and `git grep -n -F -e "which serves a merge queue on" -- .github/workflows/README.md` prints exactly one line whose text also contains `merge_group` (AC-4).
- [ ] [P1-T6] Write the required-context mapping evidence `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/other/required-context-map.<timestamp>.md`.
  Derivation: read the eleven `context` values from `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/protect-main.current.2026-10-16.json` (`:47`, `:51`, `:55`, `:59`, `:63`, `:67`, `:71`, `:75`, `:79`, `:83`, `:87`); for each, locate the `ci.yml` caller job (`git grep -n -e "uses:" -- .github/workflows/ci.yml`) and the reusable workflow's job `name:` (`git grep -n -e "name:" -- .github/workflows/_quality-checks.yml .github/workflows/_security-scan.yml .github/workflows/_docs-validation.yml .github/workflows/_build-check.yml .github/workflows/_poshqc.yml .github/workflows/_shell-coverage.yml .github/workflows/_drm-copilot-extension-tests.yml`).
  Acceptance: the artifact has one row per snapshot context (11 rows) naming the context, the `ci.yml` caller job id and line, the reusable workflow file, job id, `name:` line, and matrix value when present; it records `UNMAPPED=0`, `CI_TRIGGERS_MERGE_GROUP=true` (from P1-T3), and `Command:`/`EXIT_CODE:` for both `git grep` commands (AC-3).
- [ ] [P1-T7] Commit and push Phase 1: `.github/workflows/ci.yml`, `.github/workflows/README.md`, `tests/scripts/workflows/CiWorkflow.Tests.ps1`, and the feature-folder evidence and plan state.
  Commands: `git add .github/workflows/ci.yml .github/workflows/README.md tests/scripts/workflows/CiWorkflow.Tests.ps1 docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/ docs/features/active/2026-10-16-ci-merge-queue-for-main-952/plan.2026-10-16T00-15.md`; `git commit -m "fix(952): trigger CI on merge_group and assert the trigger"`; `git push origin bug/ci-merge-queue-for-main-952`.
  Acceptance: `git status --porcelain -- .github/workflows/ci.yml .github/workflows/README.md tests/scripts/workflows/CiWorkflow.Tests.ps1 docs/features/active/2026-10-16-ci-merge-queue-for-main-952/` prints nothing, and `git rev-parse HEAD` equals `git rev-parse origin/bug/ci-merge-queue-for-main-952`. No force-push.

### Phase 2 — Merge-Gate Regression Tests (fail first)

- [ ] [P2-T1] Create `tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1` per Appendix B (36 `It` cases).
  Acceptance: the file exists; `git add tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1` succeeds; the PowerShell tool command `(Get-Content -LiteralPath tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1).Count` prints a value at or below 500; `git grep -c -F -e "baseline mock interception probe" -- tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1` prints a count of 1; the file contains no `New-TemporaryFile`, `TestDrive`, `Start-Process`, or `Start-Sleep`.
- [ ] [P2-T2] [expect-fail] Run the Claude merge-queue suite before any hook change and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/claude-merge-queue-before.<timestamp>.md`.
  Command: Appendix R1 with `$TestPath` = `tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1`, `$CoveragePath` empty, run name `claude-mq-before`.
  Acceptance: the artifact records `TotalCount=36`, `PassedCount=9`, `FailedCount=27`, `FailedContainersCount=0`, and the 27 `FAILED:` lines; the nine passing cases are exactly those Appendix B marks `pre: pass`. Any other outcome fails the task: the suite must discriminate the current gate before the gate changes. CI equivalent: jobs `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)`.
- [ ] [P2-T3] Create `tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1` per Appendix C (34 `It` cases).
  Acceptance: the file exists; `git add tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1` succeeds; `(Get-Content -LiteralPath tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1).Count` prints a value at or below 500; `git grep -c -F -e "baseline mock interception probe" -- tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1` prints a count of 1; no `New-TemporaryFile`, `TestDrive`, `Start-Process`, or `Start-Sleep`.
- [ ] [P2-T4] [expect-fail] Run the Codex merge-queue suite before any hook change and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/codex-merge-queue-before.<timestamp>.md`.
  Command: Appendix R1 with `$TestPath` = `tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1`, `$CoveragePath` empty, run name `codex-mq-before`.
  Acceptance: `TotalCount=34`, `PassedCount=9`, `FailedCount=25`, `FailedContainersCount=0`, and the 25 `FAILED:` lines recorded; the passing cases are exactly those Appendix C marks `pre: pass`. Any other outcome fails the task. CI equivalent: jobs `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)`.
- [ ] [P2-T5] Edit `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1:37-41`: replace the `It 'allows gh pr merge without --merge (e.g., --squash)'` block with the block of Appendix F.11.
  Acceptance: `git grep -n -F -e "allows gh pr merge without --merge" -- tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` exits 1 (no match); `git grep -n -F -e "denies gh pr merge --squash without a checkpoint" -- tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` prints exactly one line; `git grep -c "" -- tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` prints a count at or below 500.
- [ ] [P2-T6] Edit `tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1:83`: set `$script:Line433Text` to the exact Claude deny text of Appendix F.1 (variable name unchanged; no other line changes).
  Acceptance: `git grep -n -F -e "a pull-request merge or merge-queue enqueue" -- tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1` prints exactly one line numbered 83; `git grep -n -F -e "gh pr merge --merge requires" -- tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1` exits 1.
- [ ] [P2-T7] Edit `tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1:79`: set `$script:CodexDenyText` to the exact Codex deny text of Appendix F.6 (no other line changes).
  Acceptance: `git grep -n -F -e "a pull-request merge or merge-queue enqueue" -- tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1` prints exactly one line numbered 79; `git grep -n -F -e "gh pr merge --merge requires" -- tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1` exits 1.
- [ ] [P2-T8] [expect-fail] Run the three edited suites before any hook change and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/pinned-suites-before.<timestamp>.md`.
  Command: Appendix R1 with `$TestPath` = `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1`, `tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1`; `$CoveragePath` empty; run name `pinned-before`.
  Acceptance: `FailedCount=3` and `FailedContainersCount=0` recorded with exactly three `FAILED:` lines naming `denies gh pr merge --squash without a checkpoint (issue #952 method-agnostic scope)`, `keeps the existing fall-through text for a bare merge even with a valid record present`, and `keeps the existing deny text for a bare merge even with a valid record present`. Any other outcome fails the task. CI equivalent: jobs `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)`.
- [ ] [P2-T9] Commit and push Phase 2 (`tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1`, `tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1`, and the three edited merge-gate suites); failing tests are committed deliberately and Phase 3 makes them pass.
  Commands: `git add tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1 tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/ docs/features/active/2026-10-16-ci-merge-queue-for-main-952/plan.2026-10-16T00-15.md`; `git commit -m "test(952): add failing merge-queue scope and selector cases"`; `git push origin bug/ci-merge-queue-for-main-952`.
  Acceptance: `git status --porcelain` prints nothing for the five test paths and the feature folder, and `git rev-parse HEAD` equals `git rev-parse origin/bug/ci-merge-queue-for-main-952`. No force-push.

### Phase 3 — Merge-Gate Implementation (both runtimes)

- [ ] [P3-T1] Re-check `origin/main` for concurrent changes to the merge-gate files and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/other/concurrency-recheck.<timestamp>.md`.
  Commands: `git fetch origin`; `git log --oneline HEAD..origin/main -- .claude/hooks/enforce-epic-merge-gate.ps1 .codex/hooks/enforce-epic-merge-gate.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1 extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`.
  Acceptance: `EXIT_CODE: 0` for both; an empty `git log` output records `CONCURRENT_CHANGES=0` and execution continues. A non-empty output records the lines, fails the task, and halts execution for the caller before any hook edit (the branch-update decision belongs to the orchestrator).
- [ ] [P3-T2] Create `.claude/hooks/enforce-epic-merge-gate-command.ps1` with the content of Appendix E.
  Acceptance: the file exists; `git add .claude/hooks/enforce-epic-merge-gate-command.ps1` succeeds; `git grep -c -E -e "^function " -- .claude/hooks/enforce-epic-merge-gate-command.ps1` prints a count of 6; `git grep -n -E -e "^[[:space:]]*[.] " -e "Import-Module" -- .claude/hooks/enforce-epic-merge-gate-command.ps1` exits 1 (the helper dot-sources and imports nothing); `(Get-Content -LiteralPath .claude/hooks/enforce-epic-merge-gate-command.ps1).Count` prints a value at or below 500.
- [ ] [P3-T3] Edit `.claude/hooks/enforce-epic-merge-gate.ps1:415`: replace the deny-reason string literal with the exact Claude text of Appendix F.1.
  Acceptance: `git grep -n -F -e "gh pr merge --merge requires" -- .claude/hooks/enforce-epic-merge-gate.ps1` exits 1, and `git grep -c -F -e "a pull-request merge or merge-queue enqueue" -- .claude/hooks/enforce-epic-merge-gate.ps1` prints a count of 1.
- [ ] [P3-T4] Edit `.claude/hooks/enforce-epic-merge-gate.ps1:334-356`: replace the scope-filter comment and code (from `    # Only a gh pr merge invocation carrying --merge is in scope` through the closing `    }` of `if (-not $isMergeInvocation -or -not $hasMergeFlag)`) with the five lines of Appendix F.2. Line `:358` (`$commandPrNumber = ...`) is unchanged.
  Acceptance: `git grep -n -F -e "hasMergeFlag" -- .claude/hooks/enforce-epic-merge-gate.ps1` exits 1, and `git grep -c -F -e "Test-EpicMergeGateCommandInScope -CommandText" -- .claude/hooks/enforce-epic-merge-gate.ps1` prints a count of 1.
- [ ] [P3-T5] Edit `.claude/hooks/enforce-epic-merge-gate.ps1` `Get-EpicMergeGateCommandPrNumber`: first replace the function body `:131-142` with the single line of Appendix F.3(b), then the `.DESCRIPTION` body `:104-118` with Appendix F.3(a). The function name, parameters, and `[OutputType([int])]` are unchanged.
  Acceptance: `git grep -n -F -e "Get-CommandLineFlagValue" -- .claude/hooks/enforce-epic-merge-gate.ps1` exits 1, and `git grep -c -F -e "return Get-EpicMergeGateSelectorPrNumber -CommandText" -- .claude/hooks/enforce-epic-merge-gate.ps1` prints a count of 1.
- [ ] [P3-T6] Edit `.claude/hooks/enforce-epic-merge-gate.ps1`: insert the two lines of Appendix F.4 immediately after `:72` (the guarded dot-source of `enforce-epic-merge-gate-resolution.ps1`).
  Acceptance: `git grep -n -F -e "Add-HookDependencyFailure -Name 'enforce-epic-merge-gate-command.ps1'" -- .claude/hooks/enforce-epic-merge-gate.ps1` prints exactly one line, numbered 74, whose text begins `try { . (Join-Path` (the dot-source sits in its own guarded `try`).
- [ ] [P3-T7] Edit the `.claude/hooks/enforce-epic-merge-gate.ps1` header comment: replace `:34` with Appendix F.5(c), `:7-8` with Appendix F.5(b), and `:3` with Appendix F.5(a), in that order.
  Acceptance: `git grep -n -F -e "is out of scope for this gate" -- .claude/hooks/enforce-epic-merge-gate.ps1` exits 1; `git grep -n -F -e "Regex-matches gh pr merge" -- .claude/hooks/enforce-epic-merge-gate.ps1` exits 1; `git grep -c -F -e "only a pure --disable-auto is out of scope" -- .claude/hooks/enforce-epic-merge-gate.ps1` prints a count of 1 (AC-11).
- [ ] [P3-T8] Run every Claude merge-gate suite after the Claude edits and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/claude-merge-gate-after.<timestamp>.md`.
  Command: Appendix R1 with `$TestPath` = the seven P0-T10 files plus `tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1`; `$CoveragePath` = `.claude/hooks/enforce-epic-merge-gate.ps1`, `.claude/hooks/enforce-epic-merge-gate-command.ps1`; run name `claude-gate-after`.
  Acceptance: `FailedCount=0` and `FailedContainersCount=0` recorded; `TotalCount` equals the P0-T10 `TotalCount` plus 36; both `COVERAGE` lines recorded. CI equivalent: jobs `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)` (AC-6, AC-7, AC-8, AC-10).
- [ ] [P3-T9] Copy the Claude helper to the Codex runtime: PowerShell tool `Copy-Item -LiteralPath .claude/hooks/enforce-epic-merge-gate-command.ps1 -Destination .codex/hooks/enforce-epic-merge-gate-command.ps1 -Force`.
  Acceptance: `git hash-object .claude/hooks/enforce-epic-merge-gate-command.ps1 .codex/hooks/enforce-epic-merge-gate-command.ps1` prints two identical hashes; the result is appended to `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/other/mirror-sync.<timestamp>.md` with `Output Summary: PAIR_EQUAL=true helper-claude-codex`.
- [ ] [P3-T10] Edit `.codex/hooks/enforce-epic-merge-gate.ps1:191`: replace the `permissionDecisionReason` string literal with the exact Codex text of Appendix F.6.
  Acceptance: `git grep -n -F -e "gh pr merge --merge requires" -- .codex/hooks/enforce-epic-merge-gate.ps1` exits 1, and `git grep -c -F -e "a pull-request merge or merge-queue enqueue" -- .codex/hooks/enforce-epic-merge-gate.ps1` prints a count of 1.
- [ ] [P3-T11] Edit `.codex/hooks/enforce-epic-merge-gate.ps1:139-157`: replace the scope-filter comment and code (from `    # Both legs are read structurally` through the closing `    }` of `if (-not $isMergeInvocation -or -not $hasMergeFlag)`) with the five lines of Appendix F.7.
  Acceptance: `git grep -n -F -e "hasMergeFlag" -- .codex/hooks/enforce-epic-merge-gate.ps1` exits 1, and `git grep -c -F -e "Test-EpicMergeGateCommandInScope -CommandText" -- .codex/hooks/enforce-epic-merge-gate.ps1` prints a count of 1.
- [ ] [P3-T12] Edit `.codex/hooks/enforce-epic-merge-gate.ps1` `Get-CodexMergeCommandPrNumber`: first replace the function body `:64-75` with the single line of Appendix F.8(b), then the `.DESCRIPTION` body `:48-56` with Appendix F.8(a).
  Acceptance: `git grep -n -F -e "Get-CommandLineFlagValue" -- .codex/hooks/enforce-epic-merge-gate.ps1` exits 1, and `git grep -c -F -e "return Get-EpicMergeGateSelectorPrNumber -CommandText" -- .codex/hooks/enforce-epic-merge-gate.ps1` prints a count of 1.
- [ ] [P3-T13] Edit `.codex/hooks/enforce-epic-merge-gate.ps1`: insert the three lines of Appendix F.9 immediately after `:13` (the guarded dot-source of `hook-command-invocation.ps1`).
  Acceptance: `git grep -n -F -e "Add-HookDependencyFailure -Name 'enforce-epic-merge-gate-command.ps1'" -- .codex/hooks/enforce-epic-merge-gate.ps1` prints exactly one line, numbered 16, whose text begins `try { . (Join-Path`.
- [ ] [P3-T14] Edit `.codex/hooks/enforce-epic-merge-gate.ps1:1-4` (the comment-based help block) to the exact text of Appendix F.10.
  Acceptance: `git grep -c -F -e "only a pure --disable-auto is out of scope" -- .codex/hooks/enforce-epic-merge-gate.ps1` prints a count of 1 (AC-11).
- [ ] [P3-T15] Run every Codex merge-gate suite after the Codex edits and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/codex-merge-gate-after.<timestamp>.md`.
  Command: Appendix R1 with `$TestPath` = the three P0-T11 files plus `tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1`; `$CoveragePath` = `.codex/hooks/enforce-epic-merge-gate.ps1`, `.codex/hooks/enforce-epic-merge-gate-command.ps1`; run name `codex-gate-after`.
  Acceptance: `FailedCount=0` and `FailedContainersCount=0` recorded; `TotalCount` equals the P0-T11 `TotalCount` plus 34; both `COVERAGE` lines recorded. CI equivalent: jobs `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)` (AC-9, AC-10).
- [ ] [P3-T16] Copy the four hook files to their bundle mirrors with the PowerShell tool: `Copy-Item -LiteralPath <source> -Destination <mirror> -Force` for (`.claude/hooks/enforce-epic-merge-gate.ps1` → `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1`), (`.claude/hooks/enforce-epic-merge-gate-command.ps1` → `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-command.ps1`), (`.codex/hooks/enforce-epic-merge-gate.ps1` → `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1`), (`.codex/hooks/enforce-epic-merge-gate-command.ps1` → `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate-command.ps1`).
  Acceptance: `git hash-object` over the eight paths prints four equal pairs; the result is appended to `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/other/mirror-sync.<timestamp>.md` with `Output Summary: PAIRS_EQUAL=4/4 hooks`.
- [ ] [P3-T17] Add the helper paths to the pack manifests: in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` insert the entry `    ".claude/hooks/enforce-epic-merge-gate-command.ps1",` immediately after the `.claude/hooks/enforce-epic-merge-gate-resolution.ps1` entry (`:32`); in `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` insert `    ".codex/hooks/enforce-epic-merge-gate-command.ps1",` immediately before the `.codex/hooks/enforce-epic-merge-gate.ps1` entry (`:36`).
  Acceptance: the PowerShell tool command `foreach ($m in 'extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json','extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json') { $p = @((Get-Content -Raw -LiteralPath $m | ConvertFrom-Json).paths); "MANIFEST file=$m Entries=$($p.Count) Helper=$(@($p | Where-Object { $_ -like '*/hooks/enforce-epic-merge-gate-command.ps1' }).Count)" }` prints `Helper=1` for both files (each file parses as JSON).
- [ ] [P3-T18] Run the hook guard suites and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/hook-guards-after.<timestamp>.md`.
  Command: Appendix R1 with `$TestPath` = G-SET and `$CoveragePath` empty; run name `guards-after-gate`.
  Acceptance: `FailedCount=0` and `FailedContainersCount=0` recorded; the run includes `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` (AC-5 guarded dot-source) and `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` (the new suites comply with the epic-state isolation forms). CI equivalent: job `poshqc / PowerShell QC`; hook-suite members also in job `poshqc / PowerShell hook suites (Linux)`.
- [ ] [P3-T19] Run the push-down resource and manifest tests and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/pushdown-after-gate.<timestamp>.md`.
  Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py -q`
  Acceptance: `EXIT_CODE: 0`; the summary line recorded verbatim contains `passed` and neither `failed` nor `error` (AC-20 hook portion).
- [ ] [P3-T20] Record the line counts of the four hook production files into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/other/line-counts-gate.<timestamp>.md`.
  Command: `git grep -c "" -- .claude/hooks/enforce-epic-merge-gate.ps1 .claude/hooks/enforce-epic-merge-gate-command.ps1 .codex/hooks/enforce-epic-merge-gate.ps1 .codex/hooks/enforce-epic-merge-gate-command.ps1` (run after `git add` of the two helper files in P3-T2 and P3-T9).
  Acceptance: `EXIT_CODE: 0`; four counts recorded, each at or below 500; the `.claude/hooks/enforce-epic-merge-gate.ps1` count is below its P0-T7 value.
- [ ] [P3-T21] Commit and push Phase 3: `.claude/hooks/enforce-epic-merge-gate.ps1`, `.claude/hooks/enforce-epic-merge-gate-command.ps1`, `.codex/hooks/enforce-epic-merge-gate.ps1`, `.codex/hooks/enforce-epic-merge-gate-command.ps1`, their four bundle mirrors, and both `pack-manifests/core.json` files.
  Commands: `git add .claude/hooks/enforce-epic-merge-gate.ps1 .claude/hooks/enforce-epic-merge-gate-command.ps1 .codex/hooks/enforce-epic-merge-gate.ps1 .codex/hooks/enforce-epic-merge-gate-command.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-command.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate-command.ps1 extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/ docs/features/active/2026-10-16-ci-merge-queue-for-main-952/plan.2026-10-16T00-15.md`; `git commit -m "fix(952): gate every merge and enqueue spelling on both runtimes"`; `git push origin bug/ci-merge-queue-for-main-952`.
  Acceptance: `git status --porcelain` prints nothing for the ten code paths and the feature folder, and `git rev-parse HEAD` equals `git rev-parse origin/bug/ci-merge-queue-for-main-952`. No force-push.

### Phase 4 — Merge-Confirmation Parser

- [ ] [P4-T1] Create `tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1` per Appendix G.2 (13 `It` cases).
  Acceptance: the file exists; `git add tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1` succeeds; its first line is `Set-StrictMode -Version Latest`; `(Get-Content -LiteralPath tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1).Count` prints a value at or below 500; no `New-TemporaryFile`, `TestDrive`, `Start-Process`, or `gh` invocation.
- [ ] [P4-T2] [expect-fail] Run the parser suite before the parser exists and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/parser-before.<timestamp>.md`.
  Command: Appendix R1 with `$TestPath` = `tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1`, `$CoveragePath` empty, run name `parser-before`.
  Acceptance: `PassedCount=0` recorded and the sum of `FailedCount` and `FailedContainersCount` is greater than 0 (the `BeforeAll` cannot dot-source a missing file). Any passing case fails the task. CI equivalent: job `poshqc / PowerShell QC`.
- [ ] [P4-T3] Create `tests/scripts/claude-lib/ci-gate/MergeConfirmationParser.Manifest.Tests.ps1` per Appendix G.3 (2 `It` cases), modeled on `tests/scripts/claude-lib/ci-gate/CiGate.Manifest.Tests.ps1:1-39`.
  Acceptance: the file exists; `git add tests/scripts/claude-lib/ci-gate/MergeConfirmationParser.Manifest.Tests.ps1` succeeds; `git grep -c -F -e ".claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1" -- tests/scripts/claude-lib/ci-gate/MergeConfirmationParser.Manifest.Tests.ps1` prints a count of at least 1.
- [ ] [P4-T4] [expect-fail] Run the manifest suite before the manifest entry exists and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/parser-manifest-before.<timestamp>.md`.
  Command: Appendix R1 with `$TestPath` = `tests/scripts/claude-lib/ci-gate/MergeConfirmationParser.Manifest.Tests.ps1`, `$CoveragePath` empty, run name `parser-manifest-before`.
  Acceptance: `TotalCount=2`, `PassedCount=0`, `FailedCount=2`, `FailedContainersCount=0` recorded. Any other outcome fails the task. CI equivalent: job `poshqc / PowerShell QC`.
- [ ] [P4-T5] Create `.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1` implementing the contract of Appendix G.1.
  Acceptance: the file exists; `git add .claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1` succeeds; `git grep -n -E -e "gh |Invoke-RestMethod|Invoke-WebRequest|Start-Process" -- .claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1` prints only comment-help lines (no executable `gh` call); `(Get-Content -LiteralPath .claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1).Count` prints a value at or below 500.
- [ ] [P4-T6] Run the parser suite after the parser exists and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/parser-after.<timestamp>.md`.
  Command: Appendix R1 with `$TestPath` = `tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1`; `$CoveragePath` = `.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1`; run name `parser-after`.
  Acceptance: `TotalCount=13`, `PassedCount=13`, `FailedCount=0`, `FailedContainersCount=0`, and the `COVERAGE` line recorded (AC-12). CI equivalent: job `poshqc / PowerShell QC`.
- [ ] [P4-T7] Copy the parser to its bundle mirror with the PowerShell tool: `Copy-Item -LiteralPath .claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1 -Destination extensions/drm-copilot/resources/claude-customizations/.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1 -Force`.
  Acceptance: `git hash-object .claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1` prints two identical hashes; appended to `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/other/mirror-sync.<timestamp>.md` with `Output Summary: PAIR_EQUAL=true parser`.
- [ ] [P4-T8] Edit `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`: insert the entry `    ".claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1",` immediately after the `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` entry.
  Acceptance: `git grep -c -F -e '".claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1",' -- extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` prints a count of 1, and the P3-T17 JSON-parse command prints a non-error line for this file.
- [ ] [P4-T9] Run the whole CI-gate test folder and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/ci-gate-folder-after.<timestamp>.md`.
  Command: Appendix R1 with `$TestPath` = `tests/scripts/claude-lib/ci-gate`, `$CoveragePath` empty, run name `ci-gate-folder-after`.
  Acceptance: `FailedCount=0` and `FailedContainersCount=0` recorded; the run includes the 2 manifest cases now passing (AC-13). CI equivalent: job `poshqc / PowerShell QC`.
- [ ] [P4-T10] Run the Claude push-down resource and manifest tests and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/pushdown-after-parser.<timestamp>.md`.
  Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py -q`
  Acceptance: `EXIT_CODE: 0`; summary line recorded verbatim, containing `passed` and neither `failed` nor `error` (AC-13, AC-20 parser portion).
- [ ] [P4-T11] Commit and push Phase 4: `.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1`, its bundle mirror, `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, and the two new `tests/scripts/claude-lib/ci-gate/` suites.
  Commands: `git add .claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1 extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1 tests/scripts/claude-lib/ci-gate/MergeConfirmationParser.Manifest.Tests.ps1 docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/ docs/features/active/2026-10-16-ci-merge-queue-for-main-952/plan.2026-10-16T00-15.md`; `git commit -m "feat(952): add the merge-confirmation parser"`; `git push origin bug/ci-merge-queue-for-main-952`.
  Acceptance: `git status --porcelain` prints nothing for the five code paths and the feature folder, and `git rev-parse HEAD` equals `git rev-parse origin/bug/ci-merge-queue-for-main-952`. No force-push.

### Phase 5 — Release-Flow Merge Wait

- [ ] [P5-T1] Edit `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1` per Appendix H.1, bottom-up: `:338`, then `:168-172`, then the new branch inserted after `:77`, then `:75`.
  Acceptance: `git grep -n -F -e "--delete-branch" -- tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1` exits 1; `git grep -c -F -e "'^api graphql '" -- tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1` prints a count of at least 2; `git grep -c "" -- tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1` prints a count at or below 500.
- [ ] [P5-T2] Edit `tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1`: insert the line of Appendix H.2 immediately after `:80` (the `^pr checks ` branch of the post-PR `Invoke-GhExe` mock).
  Acceptance: `git grep -c -F -e "'^api graphql '" -- tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1` prints a count of 1.
- [ ] [P5-T3] Create `tests/scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.Tests.ps1` per Appendix H.3 (12 `It` cases).
  Acceptance: the file exists; `git add tests/scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.Tests.ps1` succeeds; its first line is `Set-StrictMode -Version Latest`; `(Get-Content -LiteralPath tests/scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.Tests.ps1).Count` prints a value at or below 500; every case mocks `Invoke-Sleep` (in `BeforeEach`) and no case calls `Start-Sleep` or creates a file.
- [ ] [P5-T4] [expect-fail] Run the four release-flow suites before the script changes and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/release-flow-before.<timestamp>.md`.
  Command: Appendix R1 with `$TestPath` = `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1`, `tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1`, `tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1`, `tests/scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.Tests.ps1`; `$CoveragePath` empty; run name `release-before`.
  Acceptance: `FailedContainersCount=0`; the `FAILED:` lines are exactly the 12 Appendix H.3 cases plus the two `Invoke-FullReleaseFlow.Tests.ps1` cases `opens the release PR, waits for checks, merges, pulls main, and invokes tag push` and `stops before checkout, pull, and tag push when merge fails` (`FailedCount=14`); no `Invoke-FullReleaseFlow.ChecksWait.Tests.ps1` or `Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1` case fails. Any other outcome fails the task. CI equivalent: job `poshqc / PowerShell QC`.
- [ ] [P5-T5] Edit `scripts/dev-tools/Invoke-FullReleaseFlow.ps1:369-373` (the merge call and its failure branch) to the exact text of Appendix H.4(d).
  Acceptance: `git grep -n -F -e "--delete-branch" -- scripts/dev-tools/Invoke-FullReleaseFlow.ps1` exits 1, and `git grep -c -F -e "Wait-ForPullRequestMerged -PrNumber" -- scripts/dev-tools/Invoke-FullReleaseFlow.ps1` prints a count of 1.
- [ ] [P5-T6] Edit `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`: insert the function of Appendix H.4(c) after the closing `}` of `Wait-ForPullRequestChecks` (`:258`) and before `function Invoke-FullReleaseFlowGuarded` (`:260`), separated by one blank line on each side.
  Acceptance: `git grep -c -F -e "function Wait-ForPullRequestMerged" -- scripts/dev-tools/Invoke-FullReleaseFlow.ps1` prints a count of 1, and `git grep -c -F -e "floor(TimeoutSeconds / PollIntervalSeconds) + 1" -- scripts/dev-tools/Invoke-FullReleaseFlow.ps1` prints a count of 1.
- [ ] [P5-T7] Edit `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`: insert the three lines of Appendix H.4(b) after the closing `)` of the script `param` block (`:42`), separated by one blank line on each side.
  Acceptance: `git grep -c -F -e "../../.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1" -- scripts/dev-tools/Invoke-FullReleaseFlow.ps1` prints a count of 1.
- [ ] [P5-T8] Edit the `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` header `.DESCRIPTION` step 4 (`:15-16`) to the exact text of Appendix H.4(a).
  Acceptance: `git grep -c -F -e "waits until the merge is confirmed" -- scripts/dev-tools/Invoke-FullReleaseFlow.ps1` prints a count of 1.
- [ ] [P5-T9] Run the four release-flow suites after the change, with coverage, and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/release-flow-after.<timestamp>.md`.
  Command: Appendix R1 with the P5-T4 `$TestPath`; `$CoveragePath` = `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`; run name `release-after`.
  Acceptance: `FailedCount=0` and `FailedContainersCount=0` recorded; `TotalCount` equals the P0-T12 `TotalCount` plus 12; the `COVERAGE` line recorded (AC-14, AC-15). CI equivalent: job `poshqc / PowerShell QC`.
- [ ] [P5-T10] Record the release-flow line counts into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/other/line-counts-release.<timestamp>.md`.
  Command (PowerShell tool): `foreach ($f in 'scripts/dev-tools/Invoke-FullReleaseFlow.ps1','tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1','tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1','tests/scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.Tests.ps1') { "LINES file=$f Count=$((Get-Content -LiteralPath $f).Count)" }`
  Acceptance: four `LINES` lines recorded, each `Count` at or below 500. A count above 500 for `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` fails the task and halts execution for the caller (the extraction alternative of `spec.md` `## Risks & Mitigations` needs a plan revision because it adds a file).
- [ ] [P5-T11] Commit and push Phase 5: `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` and the three `tests/scripts/dev-tools/Invoke-FullReleaseFlow*.Tests.ps1` files this phase changed or created.
  Commands: `git add scripts/dev-tools/Invoke-FullReleaseFlow.ps1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.Tests.ps1 docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/ docs/features/active/2026-10-16-ci-merge-queue-for-main-952/plan.2026-10-16T00-15.md`; `git commit -m "fix(952): wait for a confirmed merge in the release flow"`; `git push origin bug/ci-merge-queue-for-main-952`.
  Acceptance: `git status --porcelain` prints nothing for the four code paths and the feature folder, and `git rev-parse HEAD` equals `git rev-parse origin/bug/ci-merge-queue-for-main-952`. No force-push.

### Phase 6 — Queue-Aware Merge Procedures

- [ ] [P6-T1] Create `tests/scripts/dev_tools/merge_queue_documentation_expectations.py` with the exact content of Appendix I.1.
  Acceptance: the file exists; `git add tests/scripts/dev_tools/merge_queue_documentation_expectations.py` succeeds; `poetry run python -c "from tests.scripts.dev_tools.merge_queue_documentation_expectations import MERGE_QUEUE_FRAGMENT_PINS, MERGE_QUEUE_MIRROR_PAIRS; print(len(MERGE_QUEUE_FRAGMENT_PINS), len(MERGE_QUEUE_MIRROR_PAIRS))"` exits 0 and prints `11 4`.
- [ ] [P6-T2] Edit `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py` per Appendix I.2: add the import after `:30`, add the parametrized test before the mirror test (`:412`), and extend the mirror test parametrization (`:413-416`).
  Acceptance: `git grep -c -F -e "def test_merge_procedure_records_merge_only_after_confirmation" -- tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py` prints a count of 1; `git grep -c "" -- tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py` prints a count at or below 500.
- [ ] [P6-T3] [expect-fail] Run the contract module before any procedure edit and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/procedure-pins-before.<timestamp>.md`.
  Command: `poetry run pytest tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py -q`
  Acceptance: the artifact records `EXIT_CODE: 1`, `ExpectedExitCode: 1`, and the summary line `11 failed, <CONTRACT_BASE_PASSED + 4> passed` (with `CONTRACT_BASE_PASSED` from P0-T15; the four extra passing nodes are the new mirror pairs, already byte-identical). The 11 failing node IDs are the 11 `test_merge_procedure_records_merge_only_after_confirmation[...]` ids of Appendix I.1. Any other summary fails the task.
- [ ] [P6-T4] Edit `.claude/skills/parallel-orchestrate/SKILL.md:470` per Appendix D.1(c) (second replacement).
  Acceptance: `git grep -c -F -e "merge confirmation whose" -- .claude/skills/parallel-orchestrate/SKILL.md` prints a count of 1 (the token is absent before this task).
- [ ] [P6-T5] Edit `.claude/skills/parallel-orchestrate/SKILL.md:450` per Appendix D.1(c) (first replacement).
  Acceptance: `git grep -c -F -e "the parent runs the two commands" -- .claude/skills/parallel-orchestrate/SKILL.md` prints a count of 1, and `git grep -c -F -e "merge confirmation whose" -- .claude/skills/parallel-orchestrate/SKILL.md` prints a count of 2.
- [ ] [P6-T6] Edit `.claude/skills/parallel-orchestrate/SKILL.md:436-439` (the strict up-to-date pacing paragraph) per Appendix D.1(b).
  Acceptance: `git grep -c -F -e "the queue replaces that" -- .claude/skills/parallel-orchestrate/SKILL.md` prints a count of 1.
- [ ] [P6-T7] Edit `.claude/skills/parallel-orchestrate/SKILL.md:397` per Appendix D.1(d), then `:391-393` per Appendix D.1(a).
  Acceptance: `git grep -c -F -e "Invoke-MergeConfirmationParser.ps1 -PrJson" -- .claude/skills/parallel-orchestrate/SKILL.md` prints a count of 1; `git grep -c -F -e "Bash-matcher hook that denies every merge" -- .claude/skills/parallel-orchestrate/SKILL.md` prints a count of 1; `poetry run pytest tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py -q` exits 0 (its pin "Execute `gh pr merge --merge <PR>`" from `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py:223` still holds).
- [ ] [P6-T8] Copy `.claude/skills/parallel-orchestrate/SKILL.md` to `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md` with `Copy-Item -LiteralPath <source> -Destination <mirror> -Force` (PowerShell tool).
  Acceptance: `git hash-object` over both paths prints identical hashes; appended to `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/other/mirror-sync.<timestamp>.md` with `Output Summary: PAIR_EQUAL=true claude-parallel-orchestrate`.
- [ ] [P6-T9] Edit `.claude/agents/parallel-orchestrator.md:288-289` (Completion Requirements item 1) per Appendix D.2.
  Acceptance: `git grep -c -F -e "value is recorded only after the merge is confirmed by polling" -- .claude/agents/parallel-orchestrator.md` prints a count of 1.
- [ ] [P6-T10] Copy `.claude/agents/parallel-orchestrator.md` to `extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-orchestrator.md` with `Copy-Item -LiteralPath <source> -Destination <mirror> -Force`.
  Acceptance: identical `git hash-object` hashes; appended to the mirror-sync artifact with `Output Summary: PAIR_EQUAL=true claude-parallel-orchestrator-agent`.
- [ ] [P6-T11] Edit `.claude/skills/orchestrate/SKILL.md:366` (PR Creation Gate condition 7) per Appendix D.3(b).
  Acceptance: `git grep -c -F -e "recorded only after the merge is confirmed by polling and ancestry check (S9 step 6)" -- .claude/skills/orchestrate/SKILL.md` prints a count of 1.
- [ ] [P6-T12] Edit `.claude/skills/orchestrate/SKILL.md:301` (S9 step 6) per Appendix D.3(a).
  Acceptance: `git grep -c -F -e "Merge confirmation (issue #952)" -- .claude/skills/orchestrate/SKILL.md` prints a count of 1, and `git diff -U0 HEAD -- .claude/skills/orchestrate/SKILL.md` shows the line 301 change as one removed and one added line whose added text begins with the removed text (existing step 6 text kept; the new text is appended).
- [ ] [P6-T13] Copy `.claude/skills/orchestrate/SKILL.md` to `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md` with `Copy-Item -LiteralPath <source> -Destination <mirror> -Force`.
  Acceptance: identical `git hash-object` hashes; appended to the mirror-sync artifact with `Output Summary: PAIR_EQUAL=true claude-orchestrate`.
- [ ] [P6-T14] Edit `.claude/skills/epic-orchestrate/SKILL.md:356` (second line of Completion Requirements item 2) per Appendix D.4(c).
  Acceptance: `git grep -c -F -e "recorded, and it is recorded only after the merge is confirmed" -- .claude/skills/epic-orchestrate/SKILL.md` prints a count of 1.
- [ ] [P6-T15] Edit `.claude/skills/epic-orchestrate/SKILL.md:141` per Appendix D.4(b).
  Acceptance: `git grep -c -F -e "The child records" -- .claude/skills/epic-orchestrate/SKILL.md` prints a count of 1.
- [ ] [P6-T16] Edit `.claude/skills/epic-orchestrate/SKILL.md:129` per Appendix D.4(a).
  Acceptance: `git grep -c -F -e "Under a merge queue" -- .claude/skills/epic-orchestrate/SKILL.md` prints a count of 1.
- [ ] [P6-T17] Copy `.claude/skills/epic-orchestrate/SKILL.md` to `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md` with `Copy-Item -LiteralPath <source> -Destination <mirror> -Force`.
  Acceptance: identical `git hash-object` hashes; appended to the mirror-sync artifact with `Output Summary: PAIR_EQUAL=true claude-epic-orchestrate`.
- [ ] [P6-T18] Edit `.claude/agents/epic-orchestrator.md:163` per Appendix D.5.
  Acceptance: `git grep -c -F -e "can return before the" -- .claude/agents/epic-orchestrator.md` prints a count of 1.
- [ ] [P6-T19] Copy `.claude/agents/epic-orchestrator.md` to `extensions/drm-copilot/resources/claude-customizations/.claude/agents/epic-orchestrator.md` with `Copy-Item -LiteralPath <source> -Destination <mirror> -Force`.
  Acceptance: identical `git hash-object` hashes; appended to the mirror-sync artifact with `Output Summary: PAIR_EQUAL=true claude-epic-orchestrator-agent`.
- [ ] [P6-T20] Edit `.agents/skills/epic-orchestrate/SKILL.md:172` (last line of `## Final Integration PR`) per Appendix D.6.
  Acceptance: `git grep -c -F -e "The final merge SHA is recorded" -- .agents/skills/epic-orchestrate/SKILL.md` prints a count of 1.
- [ ] [P6-T21] Copy `.agents/skills/epic-orchestrate/SKILL.md` to `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-orchestrate/SKILL.md` with `Copy-Item -LiteralPath <source> -Destination <mirror> -Force`.
  Acceptance: identical `git hash-object` hashes; appended to the mirror-sync artifact with `Output Summary: PAIR_EQUAL=true agents-epic-orchestrate`.
- [ ] [P6-T22] Edit `.codex/agents/epic-orchestrator.toml`: insert the two lines of Appendix D.7 after `:83` and before the closing `'''` (`:84`).
  Acceptance: `git grep -c -F -e "The final merge SHA is recorded only after the merge is confirmed by polling and ancestry check:" -- .codex/agents/epic-orchestrator.toml` prints a count of 1, and the single-line command `poetry run python -c "import tomllib; tomllib.load(open('.codex/agents/epic-orchestrator.toml', 'rb')); print('TOML-OK')"` exits 0 and prints `TOML-OK` (the file still parses as TOML).
- [ ] [P6-T23] Copy `.codex/agents/epic-orchestrator.toml` to `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/epic-orchestrator.toml` with `Copy-Item -LiteralPath <source> -Destination <mirror> -Force`.
  Acceptance: identical `git hash-object` hashes; appended to the mirror-sync artifact with `Output Summary: PAIR_EQUAL=true codex-epic-orchestrator-agent`.
- [ ] [P6-T24] Run the contract module after all procedure edits and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/procedure-pins-after.<timestamp>.md`.
  Command: `poetry run pytest tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py -q`
  Acceptance: `EXIT_CODE: 0` and the summary line `<CONTRACT_BASE_PASSED + 15> passed` recorded verbatim (AC-16 through AC-19, AC-20 procedure portion).
- [ ] [P6-T25] Run the related Python contract suites and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/procedure-suites-after.<timestamp>.md`.
  Command: the P0-T14 command.
  Acceptance: `EXIT_CODE: 0`; the summary line recorded verbatim contains `passed` and neither `failed` nor `error` (includes `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py`, which pins "Execute `gh pr merge --merge <PR>`").
- [ ] [P6-T26] Commit and push Phase 6: `tests/scripts/dev_tools/merge_queue_documentation_expectations.py`, `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py`, and the seven procedure files with their bundle mirrors.
  Commands: `git add tests/scripts/dev_tools/merge_queue_documentation_expectations.py tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py .claude/skills/parallel-orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md .claude/agents/parallel-orchestrator.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-orchestrator.md .claude/skills/orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md .claude/skills/epic-orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md .claude/agents/epic-orchestrator.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/epic-orchestrator.md .agents/skills/epic-orchestrate/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-orchestrate/SKILL.md .codex/agents/epic-orchestrator.toml extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/epic-orchestrator.toml docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/ docs/features/active/2026-10-16-ci-merge-queue-for-main-952/plan.2026-10-16T00-15.md`; `git commit -m "docs(952): confirm merges by polling and ancestry before recording them"`; `git push origin bug/ci-merge-queue-for-main-952`.
  Acceptance: `git status --porcelain` prints nothing for the sixteen paths and the feature folder, and `git rev-parse HEAD` equals `git rev-parse origin/bug/ci-merge-queue-for-main-952`. No force-push.

### Phase 7 — Ruleset Deliverables (not applied)

- [ ] [P7-T1] Create `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/protect-main.merge-queue.apply.json` per Appendix S.1.
  Acceptance: the file exists and parses (`Get-Content -Raw -LiteralPath <file> | ConvertFrom-Json` in the PowerShell tool raises no error); `git grep -c -F -e '"merge_queue"' -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/protect-main.merge-queue.apply.json` prints a count of 1 after `git add` of the file.
- [ ] [P7-T2] Create `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/protect-main.non-strict.alternative.json` per Appendix S.2.
  Acceptance: the file parses as JSON; after `git add`, `git grep -c -F -e '"strict_required_status_checks_policy": false' -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/protect-main.non-strict.alternative.json` prints a count of 1.
- [ ] [P7-T3] Create `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/protect-main.rollback.json` per Appendix S.3.
  Acceptance: the file parses as JSON; after `git add`, `git grep -c -F -e '"merge_queue"' -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/protect-main.rollback.json` exits 1 (no match).
- [ ] [P7-T4] Compare the three payloads with the snapshot and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/ruleset-compare.<timestamp>.md`.
  Command: Appendix R5 (PowerShell tool).
  Acceptance: the artifact records three `PAYLOAD file=` lines, each with `Keys=bypass_actors,conditions,enforcement,name,rules,target KeysOk=True FieldsOk=True RulesOk=True`, with `RuleCount=5` for the apply payload and `RuleCount=4` for the other two, and the final line `RULESET-COMPARE AllOk=True` (AC-21, AC-22, AC-23).
- [ ] [P7-T5] Create `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/runbook.md` per Appendix S.4.
  Acceptance: the file exists; `git add` succeeds.
- [ ] [P7-T6] Verify the runbook sections and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/runbook-sections.<timestamp>.md`.
  Command: `git grep -n -F -e "## Preconditions" -e "## Capture and Diff Before Applying" -e "## Apply" -e "## Post-Apply Verification" -e "## Expected Failure on a User-Owned Repository" -e "## Rollback" -e "## Non-Strict Alternative (Separate Operator Decision)" -e "## Admin Merges Skip the Queue" -e "gh api --method PUT repos/drmoisan/drm-copilot/rulesets/15241672 --input" -e "422" -e "gh pr update-branch" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/runbook.md`
  Acceptance: `EXIT_CODE: 0`; the output contains at least one line for each of the eleven patterns, recorded verbatim with `Output Summary: SECTIONS_FOUND=11/11` (AC-24).
- [ ] [P7-T7] Commit and push Phase 7: the four files under `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/` created by P7-T1, P7-T2, P7-T3, and P7-T5.
  Commands: `git add docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/protect-main.merge-queue.apply.json docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/protect-main.non-strict.alternative.json docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/protect-main.rollback.json docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/runbook.md docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/ docs/features/active/2026-10-16-ci-merge-queue-for-main-952/plan.2026-10-16T00-15.md`; `git commit -m "docs(952): ship merge-queue ruleset payloads and runbook"`; `git push origin bug/ci-merge-queue-for-main-952`.
  Acceptance: `git status --porcelain -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/` prints nothing, and `git rev-parse HEAD` equals `git rev-parse origin/bug/ci-merge-queue-for-main-952`. No force-push.

### Phase 8 — Final QA Loop

P8-T1 through P8-T15 run under the Restart Rule. Every command is unconditional; no task may record `EXIT_CODE: SKIPPED`.

- [ ] [P8-T1] Run the PowerShell format check over every new and modified PowerShell file and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/final-powershell-format.<timestamp>.md`.
  Command: Appendix R2 with `$Path` = PS-SET (Appendix R).
  Acceptance: every `FORMAT file=` line shows `Changed=False` and the line `FORMAT-SUMMARY ChangedCount=0` is recorded. On a non-zero count, run Appendix R4 (write mode) on the same `$Path`, record its `FORMAT-APPLY-SUMMARY AppliedCount=<n>` line, re-copy each affected bundle mirror, and restart from P8-T1.
- [ ] [P8-T2] Run PSScriptAnalyzer over PS-SET and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/final-powershell-analyze.<timestamp>.md`.
  Command: Appendix R3 with `$Path` = PS-SET.
  Acceptance: the `PSSA-SUMMARY FindingCount=<n>` line and every `PSSA file=` line are recorded; every new file shows `Findings=0`; every modified file shows a count not above its P0-T9 count, and every `PSSA-FINDING` line of a modified file names a line outside the lines this plan changed (checked against `git diff -U0 <PLAN_BASE_SHA> HEAD -- <file>`). No suppression attribute is added.
- [ ] [P8-T3] Run the Claude merge-gate suites with coverage and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/final-pester-claude-gate.<timestamp>.md`.
  Command: Appendix R1 with the P3-T8 `$TestPath` and `$CoveragePath`; run name `claude-gate-final`.
  Acceptance: `FailedCount=0`, `FailedContainersCount=0`, and both `COVERAGE` and `MISSED` lines recorded; `PS_POST_CLAUDE_GATE` and `PS_POST_CLAUDE_HELPER` are the two `LinePercent` values. CI equivalent: jobs `poshqc / PowerShell QC` (coverage) and `poshqc / PowerShell hook suites (Linux)` (no coverage).
- [ ] [P8-T4] Run the Codex merge-gate suites with coverage and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/final-pester-codex-gate.<timestamp>.md`.
  Command: Appendix R1 with the P3-T15 `$TestPath` and `$CoveragePath`; run name `codex-gate-final`.
  Acceptance: `FailedCount=0`, `FailedContainersCount=0`, both `COVERAGE` and `MISSED` lines recorded; `PS_POST_CODEX_GATE` and `PS_POST_CODEX_HELPER` recorded. CI equivalent: jobs `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)`.
- [ ] [P8-T5] Run the CI-gate folder with parser coverage and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/final-pester-ci-gate.<timestamp>.md`.
  Command: Appendix R1 with `$TestPath` = `tests/scripts/claude-lib/ci-gate`; `$CoveragePath` = `.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1`; run name `ci-gate-final`.
  Acceptance: `FailedCount=0`, `FailedContainersCount=0`, the `COVERAGE` and `MISSED` lines recorded; `PS_POST_PARSER` recorded. CI equivalent: job `poshqc / PowerShell QC`.
- [ ] [P8-T6] Run the release-flow suites with coverage and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/final-pester-release.<timestamp>.md`.
  Command: Appendix R1 with the P5-T9 `$TestPath` and `$CoveragePath`; run name `release-final`.
  Acceptance: `FailedCount=0`, `FailedContainersCount=0`, the `COVERAGE` and `MISSED` lines recorded; `PS_POST_RELEASE` recorded. CI equivalent: job `poshqc / PowerShell QC`.
- [ ] [P8-T7] Run the guard and workflow suites and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/final-pester-guards.<timestamp>.md`.
  Command: Appendix R1 with `$TestPath` = G-SET; `$CoveragePath` empty; run name `guards-final`.
  Acceptance: `FailedCount=0` and `FailedContainersCount=0` recorded. CI equivalent: job `poshqc / PowerShell QC`; hook-suite members also in job `poshqc / PowerShell hook suites (Linux)`.
- [ ] [P8-T8] Run Black in check mode on the two touched Python files and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/final-python-black.<timestamp>.md`.
  Command: `poetry run black --check tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py tests/scripts/dev_tools/merge_queue_documentation_expectations.py`
  Acceptance: `EXIT_CODE: 0` and the printed line `2 files would be left unchanged.` recorded. On a non-zero exit, run `poetry run black tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py tests/scripts/dev_tools/merge_queue_documentation_expectations.py`, record its `reformatted` line, and restart from P8-T1.
- [ ] [P8-T9] Run Ruff on the two files and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/final-python-ruff.<timestamp>.md`.
  Command: `poetry run ruff check tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py tests/scripts/dev_tools/merge_queue_documentation_expectations.py`
  Acceptance: `EXIT_CODE: 0` and the printed line `All checks passed!` recorded. No suppression is added.
- [ ] [P8-T10] Run Pyright on the two files and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/final-python-pyright.<timestamp>.md`.
  Command: `poetry run pyright tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py tests/scripts/dev_tools/merge_queue_documentation_expectations.py`
  Acceptance: `EXIT_CODE: 0` and the printed line `0 errors, 0 warnings, 0 informations` recorded.
- [ ] [P8-T11] Run the Python contract suites and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/final-python-contract-suites.<timestamp>.md`.
  Command: the P0-T14 command.
  Acceptance: `EXIT_CODE: 0`; the summary line recorded verbatim contains `passed` and neither `failed` nor `error`; it includes `test_completion_gate_documentation_contracts.py::test_merge_procedure_records_merge_only_after_confirmation` and `test_completion_gate_documentation_contracts.py::test_edited_surface_matches_bundled_mirror` (AC-16 through AC-20).
- [ ] [P8-T12] Verify the final mirror hashes and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/final-mirror-hashes.<timestamp>.md`.
  Command: `git hash-object` over the 18 P0-T5 paths followed by `.claude/hooks/enforce-epic-merge-gate-command.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-command.ps1 .codex/hooks/enforce-epic-merge-gate-command.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate-command.ps1 .claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1`.
  Acceptance: `EXIT_CODE: 0`; 24 hashes recorded; `Output Summary:` records `PAIRS_EQUAL=12/12` and `HELPER_RUNTIMES_EQUAL=true` (the `.claude` and `.codex` helper hashes are equal); every one of the nine P0-T6 pairs has a hash different from its P0-T6 value (AC-20).
- [ ] [P8-T13] Verify the line counts of every new and modified production and test file and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/final-line-counts.<timestamp>.md`.
  Command (PowerShell tool): `foreach ($f in <PS-SET paths> + 'tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py','tests/scripts/dev_tools/merge_queue_documentation_expectations.py') { "LINES file=$f Count=$((Get-Content -LiteralPath $f).Count)" }`
  Acceptance: one `LINES` line per file (19 lines: the 17 PS-SET paths and the two Python files) recorded; every `Count` is at or below 500 (AC-26).
- [ ] [P8-T14] Verify that no new or changed test creates a temporary file and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/final-temp-file-scan.<timestamp>.md`.
  Command: `git grep -n -E -e "New-TemporaryFile|TestDrive|GetTempFileName|GetTempPath|tmp_path|tempfile|mkstemp" -- tests/scripts/workflows/CiWorkflow.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1 tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1 tests/scripts/claude-lib/ci-gate/MergeConfirmationParser.Manifest.Tests.ps1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.Tests.ps1 tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py tests/scripts/dev_tools/merge_queue_documentation_expectations.py`
  Acceptance: `EXIT_CODE: 1` with no output, recorded with `ExpectedExitCode: 1` (git grep exits 1 when nothing matches) (AC-26).
- [ ] [P8-T15] Write the coverage comparison `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/coverage-comparison.<timestamp>.md`.
  Derivation: for each changed production file, the changed lines are the added-line ranges of `git diff -U0 <PLAN_BASE_SHA> HEAD -- <file>` (every line for a new file); the changed executable lines are those changed lines that appear in the file's analyzed set (covered lines plus the `MISSED` list of the P8-T3 to P8-T6 run); the changed-line coverage is the share of changed executable lines not in the `MISSED` list.
  Acceptance: the artifact records, per file, baseline (`PS_BASE_*` from P0-T10 to P0-T12, or `NEW` for a new file), post (`PS_POST_*` from P8-T3 to P8-T6), changed executable lines, missed changed lines, and changed-line percent, for `.claude/hooks/enforce-epic-merge-gate.ps1`, `.claude/hooks/enforce-epic-merge-gate-command.ps1`, `.codex/hooks/enforce-epic-merge-gate.ps1`, `.codex/hooks/enforce-epic-merge-gate-command.ps1`, `.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1`, and `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`. Verdict `POWERSHELL: PASS` only when every new file's post value is at least 85, every modified file's post value is at least 85 (or, when its baseline is below 85, at least its baseline, recorded as a pre-existing gap), and every file's changed-line percent is at least 85; otherwise `POWERSHELL: FAIL` and the loop restarts after adding tests. `PYTHON: NOT-APPLICABLE` is recorded with the P0-T19 reason (AC-27).
- [ ] [P8-T16] Verify the changed-path set and the unchanged inputs and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/final-scope-boundary.<timestamp>.md`.
  Commands: `git fetch origin`; `git diff --name-only origin/main...HEAD`; `git status --porcelain`; `git diff --quiet <PLAN_BASE_SHA> HEAD -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/issue.md docs/features/active/2026-10-16-ci-merge-queue-for-main-952/research/research.2026-10-16T01-30.md docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/protect-main.current.2026-10-16.json`; `git diff -U0 <PLAN_BASE_SHA> HEAD -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/plan.2026-10-16T00-15.md`.
  Acceptance: the union of the name-only diff and the porcelain paths, excluding paths under `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/`, equals exactly the 42 paths outside the feature folder listed in `## Files Written`; in particular `.github/workflows/_poshqc.yml`, every other `.github/workflows/*.yml` except `ci.yml`, every path under `.claude/rules/` and `.github/instructions/`, `.claude/hooks/hook-command-invocation.ps1`, and `.codex/hooks/hook-command-invocation.ps1` are absent (AC-5, AC-25); the only `.py` paths are the two under `tests/scripts/dev_tools/` (`PY_PRODUCTION_FILES=0`); the `git diff --quiet` command exits 0; every removed line of the plan diff begins with `- [ ] [P` and its paired added line is identical except `[ ]` became `[x]` (`PLAN_NONCHECKBOX_CHANGES=0`). Any additional path fails the task; the executor records it with `git log --oneline origin/main..HEAD -- <path>` and halts for the caller rather than reverting or deleting it.
- [ ] [P8-T17] Commit and push the Phase 8 evidence under `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/`, the checklist state of `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/plan.2026-10-16T00-15.md`, and any Phase 8 restart repair.
  Commands: `git add` of each path in `## Files Written` that the Phase 8 loop changed (no effect on an unchanged path) and `git add docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/ docs/features/active/2026-10-16-ci-merge-queue-for-main-952/plan.2026-10-16T00-15.md`; `git commit -m "docs(952): record final QA evidence"`; `git push origin bug/ci-merge-queue-for-main-952`.
  Acceptance: `git status --porcelain` prints nothing, and `git rev-parse HEAD` equals `git rev-parse origin/bug/ci-merge-queue-for-main-952`. No force-push.

### Phase 9 — Acceptance-Criteria Tracking and Handoff

Each task below verifies one acceptance criterion of `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md` against the named evidence and, when the evidence shows the passing result, changes that criterion's `- [ ]` to `- [x]` in `spec.md`. A task whose evidence does not show the passing result leaves the box unchecked and halts execution for the caller. `issue.md` is not edited.

- [ ] [P9-T1] Verify AC-1 from `evidence/regression-testing/ciworkflow-after.*.md` (P1-T4) and `evidence/qa-gates/final-pester-guards.*.md` (P8-T7, includes `tests/scripts/workflows/CiWorkflow.Tests.ps1`), then check off AC-1 in `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md`. CI job relied on later: `poshqc / PowerShell QC`.
  Acceptance: `git grep -c -F -e "- [x] AC-1:" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md` prints a count of 1.
- [ ] [P9-T2] Verify AC-2 from the same two artifacts (the `reads no pull-request event field` case passed), then check off AC-2 in `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md`. CI job: `poshqc / PowerShell QC`.
  Acceptance: `git grep -c -F -e "- [x] AC-2:" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md` prints a count of 1.
- [ ] [P9-T3] Verify AC-3 from `evidence/other/required-context-map.*.md` (P1-T6, `UNMAPPED=0`), then check off AC-3 in `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md`.
  Acceptance: `git grep -c -F -e "- [x] AC-3:" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md` prints a count of 1.
- [ ] [P9-T4] Verify AC-4 from the P1-T5 acceptance output (re-run `git grep -n -F -e "which serves a merge queue on" -- .github/workflows/README.md` and record it in the AC artifact of P9-T29), then check off AC-4 in `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md`.
  Acceptance: `git grep -c -F -e "- [x] AC-4:" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md` prints a count of 1.
- [ ] [P9-T5] Verify AC-5 from `evidence/qa-gates/final-pester-guards.*.md` (`tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` passed) and `evidence/qa-gates/final-scope-boundary.*.md` (`hook-command-invocation.ps1` absent from the changed set), then check off AC-5 in `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md`. CI job: `poshqc / PowerShell QC`.
  Acceptance: `git grep -c -F -e "- [x] AC-5:" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md` prints a count of 1.
- [ ] [P9-T6] Verify AC-6 from `evidence/qa-gates/final-pester-claude-gate.*.md` (Appendix B Contexts B-1 and B-2 passed), then check off AC-6 in `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md`. CI jobs: `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)`.
  Acceptance: `git grep -c -F -e "- [x] AC-6:" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md` prints a count of 1.
- [ ] [P9-T7] Verify AC-7 from `evidence/qa-gates/final-pester-claude-gate.*.md` (Appendix B Context B-3 passed), then check off AC-7 in `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md`. CI jobs: `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)`.
  Acceptance: `git grep -c -F -e "- [x] AC-7:" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md` prints a count of 1.
- [ ] [P9-T8] Verify AC-8 from `evidence/qa-gates/final-pester-claude-gate.*.md` (Appendix B Contexts B-4 and B-5 passed), then check off AC-8 in `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md`. CI jobs: `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)`.
  Acceptance: `git grep -c -F -e "- [x] AC-8:" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md` prints a count of 1.
- [ ] [P9-T9] Verify AC-9 from `evidence/qa-gates/final-pester-codex-gate.*.md` (every Appendix C case passed), then check off AC-9 in `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md`. CI jobs: `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)`.
  Acceptance: `git grep -c -F -e "- [x] AC-9:" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md` prints a count of 1.
- [ ] [P9-T10] Verify AC-10 from `evidence/regression-testing/pinned-suites-before.*.md` (P2-T8), `evidence/qa-gates/final-pester-claude-gate.*.md`, and `evidence/qa-gates/final-pester-codex-gate.*.md` (every merge-gate suite on both runtimes passed, including the `--squash` rows at `enforce-epic-merge-gate.Authorization.Tests.ps1:102` and `enforce-epic-merge-gate-authorization.Tests.ps1:95`), then check off AC-10 in `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md`. CI jobs: `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)`.
  Acceptance: `git grep -c -F -e "- [x] AC-10:" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md` prints a count of 1.
- [ ] [P9-T11] Verify AC-11 from the P3-T7 and P3-T14 acceptance outputs (re-run `git grep -n -F -e "squash is out of scope" -- .claude/hooks/enforce-epic-merge-gate.ps1 .codex/hooks/enforce-epic-merge-gate.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1`, expected exit 1) and the Appendix B case B-6 and Appendix C case C-6 deny-text assertions in the final Pester artifacts, then check off AC-11 in `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md`.
  Acceptance: `git grep -c -F -e "- [x] AC-11:" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md` prints a count of 1.
- [ ] [P9-T12] Verify AC-12 from `evidence/qa-gates/final-pester-ci-gate.*.md` (13 parser cases passed), then check off AC-12 in `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md`. CI job: `poshqc / PowerShell QC`.
  Acceptance: `git grep -c -F -e "- [x] AC-12:" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md` prints a count of 1.
- [ ] [P9-T13] Verify AC-13 from `evidence/qa-gates/final-pester-ci-gate.*.md` (manifest cases passed), `evidence/qa-gates/final-python-contract-suites.*.md` (`test_push_down_claude_pack_manifest_completeness.py` passed), and `evidence/qa-gates/final-mirror-hashes.*.md` (parser pair equal), then check off AC-13 in `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md`. CI job: `poshqc / PowerShell QC`.
  Acceptance: `git grep -c -F -e "- [x] AC-13:" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md` prints a count of 1.
- [ ] [P9-T14] Verify AC-14 from `evidence/qa-gates/final-pester-release.*.md` (Appendix H.3 cases W-8 and W-9 and the updated `Invoke-FullReleaseFlow.Tests.ps1` cases passed), then check off AC-14 in `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md`. CI job: `poshqc / PowerShell QC`.
  Acceptance: `git grep -c -F -e "- [x] AC-14:" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md` prints a count of 1.
- [ ] [P9-T15] Verify AC-15 from `evidence/qa-gates/final-pester-release.*.md` (Appendix H.3 cases W-1 to W-7 and W-10 to W-12 passed), then check off AC-15 in `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md`. CI job: `poshqc / PowerShell QC`.
  Acceptance: `git grep -c -F -e "- [x] AC-15:" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md` prints a count of 1.
- [ ] [P9-T16] Verify AC-16 from `evidence/qa-gates/final-python-contract-suites.*.md` (the `claude-parallel-orchestrate-merge`, `claude-parallel-orchestrate-conflict`, and `claude-parallel-orchestrator-agent` pins and `test_parallel_orchestrator_surface_contracts.py` passed), then check off AC-16 in `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md`.
  Acceptance: `git grep -c -F -e "- [x] AC-16:" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md` prints a count of 1.
- [ ] [P9-T17] Verify AC-17 from the same artifact (`claude-orchestrate-s9` and `claude-orchestrate-pr-gate` pins passed), then check off AC-17 in `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md`.
  Acceptance: `git grep -c -F -e "- [x] AC-17:" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md` prints a count of 1.
- [ ] [P9-T18] Verify AC-18 from the same artifact (`claude-epic-orchestrate-lifecycle`, `claude-epic-orchestrate-kickoff`, `claude-epic-orchestrate-completion`, and `claude-epic-orchestrator-agent` pins passed), then check off AC-18 in `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md`.
  Acceptance: `git grep -c -F -e "- [x] AC-18:" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md` prints a count of 1.
- [ ] [P9-T19] Verify AC-19 from the same artifact (`agents-epic-orchestrate` and `codex-epic-orchestrator-agent` pins passed), then check off AC-19 in `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md`.
  Acceptance: `git grep -c -F -e "- [x] AC-19:" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md` prints a count of 1.
- [ ] [P9-T20] Verify AC-20 from `evidence/qa-gates/final-mirror-hashes.*.md` (`PAIRS_EQUAL=12/12`) and `evidence/qa-gates/final-python-contract-suites.*.md` (the four push-down resource and manifest-completeness modules passed), then check off AC-20 in `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md`.
  Acceptance: `git grep -c -F -e "- [x] AC-20:" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md` prints a count of 1.
- [ ] [P9-T21] Verify AC-21 from `evidence/qa-gates/ruleset-compare.*.md` (apply payload line `KeysOk=True FieldsOk=True RulesOk=True RuleCount=5`), then check off AC-21 in `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md`.
  Acceptance: `git grep -c -F -e "- [x] AC-21:" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md` prints a count of 1.
- [ ] [P9-T22] Verify AC-22 from the same artifact (non-strict payload line passed, `RuleCount=4`), then check off AC-22 in `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md`.
  Acceptance: `git grep -c -F -e "- [x] AC-22:" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md` prints a count of 1.
- [ ] [P9-T23] Verify AC-23 from the same artifact (rollback payload line passed, `RuleCount=4`), then check off AC-23 in `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md`.
  Acceptance: `git grep -c -F -e "- [x] AC-23:" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md` prints a count of 1.
- [ ] [P9-T24] Verify AC-24 from `evidence/qa-gates/runbook-sections.*.md` (`SECTIONS_FOUND=11/11`), then check off AC-24 in `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md`.
  Acceptance: `git grep -c -F -e "- [x] AC-24:" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md` prints a count of 1.
- [ ] [P9-T25] Verify AC-25 from `evidence/qa-gates/final-scope-boundary.*.md`, then check off AC-25 in `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md`.
  Acceptance: `git grep -c -F -e "- [x] AC-25:" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md` prints a count of 1.
- [ ] [P9-T26] Verify AC-26 from `evidence/qa-gates/final-line-counts.*.md` and `evidence/qa-gates/final-temp-file-scan.*.md`, then check off AC-26 in `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md`.
  Acceptance: `git grep -c -F -e "- [x] AC-26:" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md` prints a count of 1.
- [ ] [P9-T27] Verify AC-27 from the P0-T8 to P0-T18 baseline artifacts, the P8-T1 to P8-T11 final artifacts, and `evidence/qa-gates/coverage-comparison.*.md` (`POWERSHELL: PASS`, `PYTHON: NOT-APPLICABLE`), then check off AC-27 in `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md`.
  Acceptance: `git grep -c -F -e "- [x] AC-27:" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md` prints a count of 1.
- [ ] [P9-T28] Record AC-28 as pending-CI; do not check it off. AC-28 is CI-dependent: its verification requires the `pull_request` run of `ci.yml` on the final PR head, which does not exist during atomic execution. Under `.claude/skills/orchestrate/SKILL.md` `## Step S9 — CI Green Gate`, the item's own orchestrator run checks it off after S9 records `ci_gate.conclusion == "success"` for every snapshot context, commits, pushes, and re-runs S9 against the new head.
  Acceptance: `git grep -c -F -e "- [ ] AC-28 (CI-dependent):" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md` prints a count of 1.
- [ ] [P9-T29] Write the AC verification artifact `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/ac-verification.<timestamp>.md`.
  Acceptance: one row per AC-1 through AC-28, each naming its verifying test or command, its evidence artifact path, and its status; AC-1 through AC-27 are `PASS` only when their cited artifacts show the passing result; AC-28 is `PENDING-CI` with owner "item orchestrator S9 (CI on the final PR head; contexts per the snapshot)"; the artifact also records the CI job each Pester-verified AC relies on (`poshqc / PowerShell QC`, and `poshqc / PowerShell hook suites (Linux)` for AC-6 to AC-11).
- [ ] [P9-T30] Write the review handoff record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/other/review-handoff.<timestamp>.md`.
  Acceptance: the artifact names the feature-review step as next, the AC source (`spec.md` `## Acceptance Criteria`), the Phase 0 artifact paths, the Phase 8 artifact paths, the pending-CI item AC-28, the out-of-scope follow-ups of this plan, and the #927 overlap regions.
- [ ] [P9-T31] Commit and push Phase 9: `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md` (AC check-off), the evidence, and the plan checklist state.
  Commands: `git add docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/ docs/features/active/2026-10-16-ci-merge-queue-for-main-952/plan.2026-10-16T00-15.md`; `git commit -m "docs(952): check off acceptance criteria and record AC-28 as pending CI"`; `git push origin bug/ci-merge-queue-for-main-952`.
  Acceptance: `git status --porcelain` prints nothing, and `git rev-parse HEAD` equals `git rev-parse origin/bug/ci-merge-queue-for-main-952`. No force-push.

## Appendix A — `tests/scripts/workflows/CiWorkflow.Tests.ps1` additions

Two `It` blocks inside the existing `Describe`, reusing `$script:triggerLines` and `$script:workflowPath`. Each follows Arrange-Act-Assert with `-Because` messages; neither creates a file or starts a process.

1. `It "declares merge_group with types checks_requested and no branch or path filter"`:
   - Arrange: assert `$script:triggerLines.Count` is greater than 0.
   - Act: find the index of the line matching `'^\s{2}merge_group:\s*$'` in `$script:triggerLines`; collect the body lines after it up to (not including) the next line matching `'^\s{2}\S'`.
   - Assert: the index is found; the body contains exactly one line matching `'^\s{4}types:\s*\[\s*checks_requested\s*\]\s*$'`; no body line matches `'^\s{4}(branches|branches-ignore|paths|paths-ignore):'`; `$script:triggerLines` contains a line matching `'^\s{2}workflow_dispatch:\s*$'`; `@(Get-CiTriggerBranchList -TriggerLines $script:triggerLines -EventName 'pull_request') -join ','` is exactly `main,development,epic/**`.
2. `It "reads no pull-request event field and declares no path filter anywhere in the ci.yml call graph"`:
   - Arrange: read every `uses:\s*\./\.github/workflows/(?<File>[^\s]+\.yml)` match from `$script:workflowLines`; assert the match count is greater than 0; build the file list `ci.yml` plus each matched file under the workflows directory (`Join-Path (Split-Path $script:workflowPath -Parent) $file`).
   - Act: for each file, read its lines with `Get-Content -LiteralPath`.
   - Assert: for each file, no line matches `'github\.event\.pull_request|github\.head_ref|github\.base_ref|github\.event_name'` and no line matches `'^\s*(paths|paths-ignore):'`; each failure message names the file.

Pre-change outcome: case 1 fails (no `merge_group` key), case 2 passes (planner Grep over `.github/workflows` for these patterns matched only files outside the call graph: `publish-mcp-npm.yml:13`, `publish-extension.yml:13`, `npm-audit-gate.yml:10`, `verify-published-releases.yml:17`, `:51`, `:57`).

## Appendix B — `tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1`

Header: `#Requires -Version 7.0`, `#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }`, and a comment-help block naming issue #952, the cases, and the determinism rules (no file, no process, no live executable, every checkpoint seam mocked).

`Describe 'enforce-epic-merge-gate.ps1 merge-queue scope (issue #952)'` with a `BeforeAll` that reproduces `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1:24-50` (dot-source the hook, dot-source `EpicStateIsolation.Baseline.Helpers.ps1`, import both worktree-resolution modules, null-mock the three `Get-*OrchestratorCheckpointContent` seams and the three worktree text seams, mock `Resolve-EpicMergeGateRunTarget` and `Resolve-EpicMergeGateItemTarget` to the synthetic `SessionRoot`), and additionally defines:

- `$script:SessionId = 'session-952-q1'`;
- `$script:Record5` = `'{"standalone_merge_authorizations":[{"pr_number":5,"pr_url":"https://github.com/drmoisan/drm-copilot/pull/5","issue_num":952,"branch_name":"bug/ci-merge-queue-for-main-952","authorized_by":"parallel-orchestrator","authorized_at":"2026-10-16T02:00:00Z","session_id":"session-952-q1","basis":"Merge-queue scope regression fixture for issue #952."}]}'`;
- `ConvertTo-MergeQueueEnvelope -Command <string>` returning `[ordered]@{ tool_name = 'Bash'; tool_input = @{ command = $Command }; session_id = $script:SessionId } | ConvertTo-Json -Depth 5 -Compress`;
- `$script:ClaudeDenyText` = the exact Appendix F.1 text.

First `It`: `'baseline mock interception probe'` copied from `enforce-epic-merge-gate.TriggerScoping.Tests.ps1:52` (pre: pass).

Every decision case mocks the three checkpoint seams inside the `It` (null unless stated) and calls `Invoke-EpicMergeGateDecision -ToolInputRaw (ConvertTo-MergeQueueEnvelope -Command <command>)`. A deny case asserts `permissionDecision` is `deny` and `permissionDecisionReason` matches `'^EPIC_MERGE_GATE_BLOCKED: '`; an allow case asserts `permissionDecision` is `allow`.

Context B-1 `'every gh pr merge spelling is gated (AC-6)'`, one `-ForEach` `It 'denies <Command> without an authorization record'`:

| Row | Command | Pre-change |
|---|---|---|
| D1 | `gh pr merge 5 --merge` | pre: pass |
| D2 | `gh pr merge 5 -m` | pre: fail |
| D3 | `gh pr merge 5 --squash` | pre: fail |
| D4 | `gh pr merge 5 -s` | pre: fail |
| D5 | `gh pr merge 5 --rebase` | pre: fail |
| D6 | `gh pr merge 5 -r` | pre: fail |
| D7 | `gh pr merge 5 --auto` | pre: fail |
| D8 | `gh pr merge 5 --admin` | pre: fail |
| D9 | `gh pr merge 5` | pre: fail |
| D10 | `bash -c "gh pr merge 5 --squash"` | pre: fail |

Context B-2 `'non-merge commands stay allowed (AC-6)'`, one `-ForEach` `It 'allows <Command>'`:

| Row | Command | Pre-change |
|---|---|---|
| A1 | `gh pr merge 5 --disable-auto` | pre: pass |
| A2 | `git commit -m "gh pr merge 5 --squash"` | pre: pass |
| A3 | `printf '%s\n' "gh api graphql enqueuePullRequest" >> notes.md` | pre: pass |

Context B-3 `'gh api merge and enqueue mutations are gated (AC-7)'`:

| Row | Command | Expected | Pre-change |
|---|---|---|---|
| G1 | `gh api graphql -f query='mutation { enqueuePullRequest(input: {pullRequestId: "PR_kwDO"}) { clientMutationId } }'` | deny | pre: fail |
| G2 | `gh api graphql -f query='mutation { enablePullRequestAutoMerge(input: {pullRequestId: "PR_kwDO"}) { clientMutationId } }'` | deny | pre: fail |
| G3 | `gh api graphql -f query='mutation { mergePullRequest(input: {pullRequestId: "PR_kwDO"}) { clientMutationId } }'` | deny | pre: fail |
| G4 | `gh api -X PUT repos/drmoisan/drm-copilot/pulls/5/merge` | deny | pre: fail |
| G5 | `gh api graphql -f query='query($owner:String!,$name:String!,$number:Int!){repository(owner:$owner,name:$name){pullRequest(number:$number){state mergedAt isInMergeQueue mergeCommit{oid} autoMergeRequest{enabledAt}}}}' -F owner='{owner}' -F name='{repo}' -F number=5 --jq .data.repository.pullRequest` | allow | pre: pass |

Context B-4 `'the PR selector reader resolves every spelling (AC-8)'`, one `-ForEach` `It 'resolves 5 for <Command>'` calling `Get-EpicMergeGateCommandPrNumber -CommandText <command>` and asserting `Should -Be 5`:

| Row | Command | Pre-change |
|---|---|---|
| S1 | `gh pr merge --merge --auto 5` | pre: fail |
| S2 | `gh pr merge --subject x 5 --merge` | pre: fail |
| S3 | `gh pr merge -R o/r 5 --squash` | pre: pass |
| S4 | `gh pr merge --body-file f 5 -m` | pre: fail |
| S5 | `gh pr merge https://github.com/o/r/pull/5 --merge` | pre: fail |
| S6 | `gh api -X PUT repos/o/r/pulls/5/merge` | pre: fail |

Context B-5 `'a matching authorization record allows every gated spelling (AC-8)'`, child checkpoint seam returns `$script:Record5`, epic and parallel seams null:

| Row | Command | Expected | Pre-change |
|---|---|---|---|
| R1 | `gh pr merge --merge --auto 5` | allow | pre: fail |
| R2 | `gh pr merge 5 --squash` | allow | pre: pass |
| R3 | `gh pr merge https://github.com/drmoisan/drm-copilot/pull/5 --merge` | allow | pre: fail |
| R4 | `gh pr merge --subject x 5 --merge` | allow | pre: fail |
| R5 | `gh api -X PUT repos/drmoisan/drm-copilot/pulls/5/merge` | allow | pre: pass |
| R6 | `gh pr merge 6 --auto` | deny, reason like `'EPIC_MERGE_GATE_BLOCKED: STANDALONE_MERGE_AUTHORIZATION_PR_MISMATCH: *'` | pre: fail |

Context B-6 `'deny text names the method-agnostic scope (AC-11)'`: `It 'denies a bare gh pr merge --squash with the method-agnostic message'` — command `gh pr merge --squash`, all seams null; assert `permissionDecisionReason | Should -BeExactly $script:ClaudeDenyText` (pre: fail).

Context B-7 `'scope predicate (issue #952)'`, four `It` cases calling `Test-EpicMergeGateCommandInScope -CommandText <command>` (each pre: fail, because the function does not exist yet):

| Row | Command | Expected |
|---|---|---|
| P1 | `gh pr merge 5 --disable-auto` | `$false` |
| P2 | `gh pr merge 5 --squash` | `$true` |
| P3 | `gh api graphql -f query='query { viewer { login } }'` | `$false` |
| P4 | `bash -c "gh pr merge 5 --squash"` | `$true` |

Totals: 36 cases (1 + 10 + 3 + 5 + 6 + 6 + 1 + 4); pre-change pass 9 (probe, D1, A1, A2, A3, G5, S3, R2, R5); pre-change fail 27.

## Appendix C — `tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1`

Header as Appendix B. `Describe 'Codex enforce-epic-merge-gate merge-queue scope (issue #952)'` with a `BeforeAll` that reproduces `tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1:32-58` (dot-source `.codex/hooks/enforce-epic-merge-gate.ps1`, the baseline helpers, both worktree modules, the conditional null mocks, the three worktree text-seam mocks, and `ConvertTo-CodexMergeTriggerScopingPayload` extended to add `session_id = 'session-952-q1'`), plus `$script:Record5` (identical to Appendix B) and `$script:CodexDenyText` = the exact Appendix F.6 text.

Decision calls use `Invoke-CodexEpicMergeDecision -PayloadRaw <payload> -ChildCheckpointRaw <'' or $script:Record5> -EpicCheckpointRaw ''`. A deny case asserts `hookSpecificOutput.permissionDecision` is `deny` and the reason matches `'^EPIC_MERGE_GATE_BLOCKED: '`; an allow case asserts `Should -BeNullOrEmpty`.

- First `It`: `'baseline mock interception probe'` copied from `enforce-epic-merge-gate-trigger-scoping.Tests.ps1:61` (pre: pass).
- C-1: the ten Appendix B-1 rows, deny, child `''` (D1 pre: pass; D2 to D10 pre: fail).
- C-2: the three Appendix B-2 rows, allow (pre: pass).
- C-3: the five Appendix B-3 rows with the same expectations (G1 to G4 pre: fail; G5 pre: pass).
- C-4: the six Appendix B-4 rows calling `Get-CodexMergeCommandPrNumber -Command <command>`, `Should -Be 5` (S3 pre: pass; others pre: fail).
- C-5: the six Appendix B-5 rows with `-ChildCheckpointRaw $script:Record5` (R2 and R5 pre: pass; R1, R3, R4, R6 pre: fail).
- C-6: `It 'denies a bare gh pr merge --squash with the method-agnostic message'`, reason `Should -BeExactly $script:CodexDenyText` (pre: fail).
- C-7: two predicate cases, P1 (`$false`) and P4 (`$true`) of Appendix B-7, calling `Test-EpicMergeGateCommandInScope` loaded through the Codex hook (pre: fail).

Totals: 34 cases (1 + 10 + 3 + 5 + 6 + 6 + 1 + 2); pre-change pass 9; pre-change fail 25.

## Appendix D — Procedure texts

D.1 `.claude/skills/parallel-orchestrate/SKILL.md`

(a) Replace `:391-393`:

```text
3. Execute `gh pr merge --merge <PR>` for that item's pull request, whose base is `main`.
4. On success, record `merge_commit_sha`, `merged_at`, and `merge_status: merged`, then regenerate
   `docs/features/parallel/<slug>/parallel-status.md`.
```

with:

```text
3. Execute `gh pr merge --merge <PR>` for that item's pull request, whose base is `main`.
   Do not pass `--delete-branch` or `--auto`. A zero exit status does not prove a merge: when
   `main` uses a merge queue, `gh pr merge` exits 0 after it enqueues the pull request or enables
   auto-merge (issue #952). Confirm the merge before step 4. Every 30 seconds, for at most 90
   minutes, read the pull-request state with
   `gh api graphql -f query='query($owner:String!,$name:String!,$number:Int!){repository(owner:$owner,name:$name){pullRequest(number:$number){state mergedAt isInMergeQueue mergeCommit{oid} autoMergeRequest{enabledAt}}}}' -F owner='{owner}' -F name='{repo}' -F number=<PR> --jq .data.repository.pullRequest`
   and classify it with
   `pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1 -PrJson <snapshot-json> -AsJson`.
   On `pending`, read again. When the 90 minutes are exhausted, report the item as
   `awaiting_merge_queue`, leave its `merge_status` at `ci_green`, and do not record `merged`.
   On `merged`, run `git fetch origin main` and
   `git merge-base --is-ancestor <merge-commit-oid> origin/main`; the merge is confirmed only
   when that command exits 0. On `not_queued`, read `gh pr view <PR> --json mergeable`: a
   `CONFLICTING` value enters `## Per-Item Merge-Conflict Handling`, and any other value is a
   merge-group CI failure that re-delegates the item's child to merge `origin/main` and re-run
   S9 as one CI-failure remediation cycle, consuming a remediation attempt. On `closed`, stop
   and report a failure for the item. Never re-issue `gh pr merge` in a loop after a
   `not_queued` outcome.
4. Record `merge_commit_sha`, `merged_at`, and `merge_status: merged` only after the merge is
   confirmed by polling and ancestry check, then regenerate
   `docs/features/parallel/<slug>/parallel-status.md`.
```

(b) Replace `:436-439` with the same four lines followed by three new lines:

```text
Branch protection on `main` affects only the pacing of step 3, not its ownership: if `main`
requires branches to be up to date, an automated `gh pr update-branch` plus re-green cycle is
inserted between same-cohort merges, which serializes those merges in practice while remaining
unattended. When `main` uses a merge queue, the queue replaces that `gh pr update-branch` cycle:
step 3 enqueues each green pull request, the queue validates it against the latest `main`
together with the entries ahead of it, and step 3's confirmation polling waits for the merge.
```

(c) First replacement, `:450`: `- (a) On a conflicted \`gh pr merge --merge\`, the parent runs the two commands` becomes the two lines:

```text
- (a) On a conflicted `gh pr merge --merge`, or a `not_queued` merge confirmation whose
  `mergeable` value is `CONFLICTING`, the parent runs the two commands
```

Second replacement, `:470`: `1. On a conflicted \`gh pr merge --merge\`, the parent detects the failure and re-delegates that item's` becomes the two lines:

```text
1. On a conflicted `gh pr merge --merge`, or a `not_queued` merge confirmation whose `mergeable`
   value is `CONFLICTING`, the parent detects the failure and re-delegates that item's
```

(d) `:397`: `` `PreToolUse` Bash-matcher hook that denies any `gh pr merge --merge` unless a checkpoint satisfies `` becomes the three lines:

```text
`PreToolUse` Bash-matcher hook that denies every merge or merge-queue enqueue action (any
`gh pr merge` spelling except a pure `--disable-auto`, and every `gh api` merge or enqueue
mutation; issue #952) unless a checkpoint satisfies
```

D.2 `.claude/agents/parallel-orchestrator.md`: after `:289` ("   confirmed by `git` and `gh` rather than by an in-memory notification.") insert:

```text
   A `merged` value is recorded only after the merge is confirmed by polling and ancestry check
   (step 3 of the `parallel-orchestrate` skill's `## Per-Item Merge to Main (Merge-on-Green)`),
   because under a merge queue `gh pr merge` exits 0 before the merge happens.
```

D.3 `.claude/skills/orchestrate/SKILL.md`

(a) Append to the end of `:301` (after "do not proceed to DONE."), on the same line, the text:

```text
 Merge confirmation (issue #952): a zero exit from `gh pr merge` does not prove a merge when the base branch uses a merge queue, so `epic_merge.merge_commit_sha` is recorded only after the merge is confirmed by polling and ancestry check. Read the pull-request state every 30 seconds, for at most 90 minutes, with the `gh api graphql` query and `.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1` exactly as step 3 of `## Per-Item Merge to Main (Merge-on-Green)` in `.claude/skills/parallel-orchestrate/SKILL.md` defines them; on `merged`, run `git fetch origin <integration_branch>` and confirm that `git merge-base --is-ancestor <merge-commit-oid> origin/<integration_branch>` exits 0 before recording `epic_merge`. When the 90 minutes are exhausted, record a finding naming `awaiting_merge_queue` with `Remediability: awaiting_ci` in `remediation-inputs.<timestamp>.md` and follow the wait branch (`blocked_reason: "awaiting_ci"`, `next_step: "S9_ci_green"`). A `not_queued` outcome whose `mergeable` value is `CONFLICTING` follows "Merge-Conflict Remediation"; any other `not_queued` outcome enters `## Remediation Loop — CI-Failure Handling`; a `closed` outcome halts the run with a failure. `gh pr merge` is never re-issued in a loop after `not_queued`.
```

(b) Append to the end of `:366`, on the same line: `` `epic_merge.merge_commit_sha` is recorded only after the merge is confirmed by polling and ancestry check (S9 step 6). `` (preceded by one space).

D.4 `.claude/skills/epic-orchestrate/SKILL.md`

(a) `:129` (`` `gh pr merge --merge` once green, gated by `enforce-epic-merge-gate.ps1`. ``) becomes:

```text
   `gh pr merge --merge` once green, gated by `enforce-epic-merge-gate.ps1`. Under a merge queue
   on `main`, `gh pr merge` can return before the merge happens, so
   `epic_merge_pr.merge_commit_sha` is recorded only after the merge is confirmed by polling and
   ancestry check, using the confirmation procedure of step 3 of
   `## Per-Item Merge to Main (Merge-on-Green)` in `.claude/skills/parallel-orchestrate/SKILL.md`
   with `main` as the base branch (issue #952).
```

(b) `:141` (`` recording `epic_merge: { merge_commit_sha, target_branch, merged_at }`. Standalone (non-epic) ``) becomes:

```text
recording `epic_merge: { merge_commit_sha, target_branch, merged_at }`. The child records
`epic_merge` only after the merge is confirmed by polling and ancestry check against
`origin/<integration_branch>` (S9 step 6). Standalone (non-epic)
```

(c) `:356` (`   recorded.`) becomes `   recorded, and it is recorded only after the merge is confirmed by polling and ancestry check.`

D.5 `.claude/agents/epic-orchestrator.md`: after `:163` insert:

```text
   `epic_merge_pr.merge_commit_sha` is recorded only after the merge is confirmed by polling and
   ancestry check, because under a merge queue on `main` `gh pr merge` can return before the
   merge happens (issue #952).
```

D.6 `.agents/skills/epic-orchestrate/SKILL.md`: `:172` (`` `main` only through the merge gate. ``) becomes:

```text
`main` only through the merge gate. A zero exit from `gh pr merge` does not prove a merge when
`main` uses a merge queue: read the pull-request state (`state`, `mergeCommit`, `mergedAt`,
`isInMergeQueue`, and `autoMergeRequest`) every 30 seconds for at most 90 minutes until it is
`MERGED`, then run `git fetch origin main` and
`git merge-base --is-ancestor <merge-commit-oid> origin/main`. The final merge SHA is recorded
only after the merge is confirmed by polling and ancestry check. When the 90 minutes are
exhausted, report `awaiting_merge_queue` and do not record a merge; never re-issue the merge in
a loop (issue #952).
```

D.7 `.codex/agents/epic-orchestrator.toml`: after `:83` insert:

```text
The final merge SHA is recorded only after the merge is confirmed by polling and ancestry check:
under a merge queue on `main`, `gh pr merge` can return before the merge happens (issue #952).
```

## Appendix E — `.claude/hooks/enforce-epic-merge-gate-command.ps1`

```powershell
<#
.SYNOPSIS
    Scope predicate and pull-request selector reader for the epic merge gate (issue #952).
.DESCRIPTION
    Dot-sourced by enforce-epic-merge-gate.ps1 on both runtimes; this file is byte-identical in
    .claude/hooks and .codex/hooks. Under a merge queue every gh pr merge spelling (--merge, -m,
    --squash, -s, --rebase, -r, --auto, --admin, or no method flag) adds the pull request to the
    queue, and the gh api mutations enqueuePullRequest, enablePullRequestAutoMerge, and
    mergePullRequest and the REST pulls/<n>/merge endpoint also reach the base branch. All of
    them are in scope. A gh pr merge whose only action flag is --disable-auto is out of scope.

    Pure string logic only: no disk, process, network, clock, or environment access. The file
    dot-sources and imports nothing; it consumes Get-CommandLineInvocation and
    Get-CommandLineStructuralMatch, which the gate loads from hook-command-invocation.ps1 first.
#>

# gh pr merge flags that perform or schedule a merge. Any of them keeps a command in scope even
# when it also carries --disable-auto.
$script:EpicMergeGateActionFlags = @('--merge', '-m', '--squash', '-s', '--rebase', '-r', '--auto', '--admin')

# gh pr merge flags, including the inherited --repo, that consume the following token as a value.
$script:EpicMergeGateValueFlags = @('-b', '--body', '-F', '--body-file', '-t', '--subject', '-A', '--author-email', '--match-head-commit', '-R', '--repo')

# GraphQL mutations that merge, enqueue, or schedule the merge of a pull request.
$script:EpicMergeGateMutationNames = @('enqueuePullRequest', 'enablePullRequestAutoMerge', 'mergePullRequest')

# The REST merge endpoint path; group 1 is the pull-request number.
$script:EpicMergeGateRestMergePattern = '(?:^|/)pulls/(\d+)/merge(?:$|[^\w-])'

function Get-EpicMergeGateFlagName {
    <#
    .SYNOPSIS
        Return the flag name of a dash-led token without any '=value' suffix.
    .OUTPUTS
        System.String
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][AllowEmptyString()][string] $Token)

    $split = $Token.IndexOf('=')
    if ($split -gt 0) { return $Token.Substring(0, $split) }
    return $Token
}

function ConvertFrom-EpicMergeGateSelector {
    <#
    .SYNOPSIS
        Convert a gh pr merge selector to a pull-request number, or $null.
    .DESCRIPTION
        Accepts an all-digit selector or a URL whose path ends in /pull/<n>. A branch-name
        selector carries no number and yields $null.
    .OUTPUTS
        System.Nullable[int]
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param([Parameter(Mandatory)][AllowEmptyString()][string] $Selector)

    $digits = $null
    if ($Selector -match '^\d+$') {
        $digits = $Selector
    } elseif ($Selector -match '/pull/(\d+)/?(?:[?#].*)?$') {
        $digits = $Matches[1]
    }
    $number = 0
    if ($null -ne $digits -and [int]::TryParse($digits, [ref] $number)) { return $number }
    return $null
}

function Test-EpicMergeGateDisableAutoOnly {
    <#
    .SYNOPSIS
        Report whether a Structural gh pr merge match carries --disable-auto and no action flag.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory)][pscustomobject] $Match)

    $tokens = [string[]]@($Match.Segment.Tokens)
    $hasDisableAuto = $false
    for ($index = $Match.OperandIndex; $index -lt $tokens.Count; $index++) {
        $name = Get-EpicMergeGateFlagName -Token $tokens[$index]
        if ($script:EpicMergeGateActionFlags -ccontains $name) { return $false }
        if ($name -ceq '--disable-auto') { $hasDisableAuto = $true }
    }
    return $hasDisableAuto
}

function Test-EpicMergeGateApiMutationText {
    <#
    .SYNOPSIS
        Report whether gh api text names a merge or enqueue mutation or the REST merge endpoint.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory)][AllowEmptyString()][AllowNull()][string] $Text)

    if ([string]::IsNullOrEmpty($Text)) { return $false }
    foreach ($name in $script:EpicMergeGateMutationNames) {
        if ($Text.IndexOf($name, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) { return $true }
    }
    return [regex]::IsMatch($Text, $script:EpicMergeGateRestMergePattern)
}

function Test-EpicMergeGateCommandInScope {
    <#
    .SYNOPSIS
        Report whether a command line is a gated merge or enqueue action (issue #952).
    .DESCRIPTION
        True for any gh pr merge match, Structural or Indeterminate, unless the match is Structural
        and its only action flag is --disable-auto; true for any gh api match whose tokens name a
        merge or enqueue mutation or a pulls/<n>/merge path. Text that only mentions these words
        produces no match and stays out of scope. An Indeterminate gh pr merge match stays in scope
        (fail closed).
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory)][AllowEmptyString()][AllowNull()][string] $CommandText)

    foreach ($match in @(Get-CommandLineInvocation -CommandText $CommandText -CommandWord 'gh' -SubcommandPath @('pr', 'merge'))) {
        if ($match.Status -ne 'Structural' -or -not (Test-EpicMergeGateDisableAutoOnly -Match $match)) { return $true }
    }
    foreach ($match in @(Get-CommandLineInvocation -CommandText $CommandText -CommandWord 'gh' -SubcommandPath @('api'))) {
        if (Test-EpicMergeGateApiMutationText -Text (@($match.Segment.Tokens) -join ' ')) { return $true }
    }
    return $false
}

function Get-EpicMergeGateSelectorPrNumber {
    <#
    .SYNOPSIS
        Resolve the pull-request number of a gated merge or enqueue command, or $null.
    .DESCRIPTION
        For gh pr merge, only the first Structural match is read. Value flags are skipped with
        their values, other flags are skipped, an equals-joined --merge=<digits> yields its
        digits, and the first non-flag token (or the token after a bare '--') is the selector.
        For gh api, the number comes from a pulls/<n>/merge token. Any other command yields
        $null, which the gate handles through its no-number branches.
    .OUTPUTS
        System.Nullable[int]
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param([Parameter(Mandatory)][AllowEmptyString()][AllowNull()][string] $CommandText)

    $match = Get-CommandLineStructuralMatch -CommandText $CommandText -CommandWord 'gh' -SubcommandPath @('pr', 'merge')
    if ($null -ne $match) {
        $tokens = [string[]]@($match.Segment.Tokens)
        $index = $match.OperandIndex
        while ($index -lt $tokens.Count) {
            $token = $tokens[$index]
            if ($token -ceq '--') {
                if ($index + 1 -lt $tokens.Count) { return ConvertFrom-EpicMergeGateSelector -Selector $tokens[$index + 1] }
                return $null
            }
            if ($token.StartsWith('-') -and $token.Length -gt 1) {
                $name = Get-EpicMergeGateFlagName -Token $token
                if ($name -ceq '--merge' -and $token.Length -gt $name.Length) {
                    return ConvertFrom-EpicMergeGateSelector -Selector $token.Substring($name.Length + 1)
                }
                $index += if ($script:EpicMergeGateValueFlags -ccontains $token) { 2 } else { 1 }
                continue
            }
            return ConvertFrom-EpicMergeGateSelector -Selector $token
        }
        return $null
    }

    foreach ($apiMatch in @(Get-CommandLineInvocation -CommandText $CommandText -CommandWord 'gh' -SubcommandPath @('api'))) {
        foreach ($token in @($apiMatch.Segment.Tokens)) {
            $rest = [regex]::Match([string]$token, $script:EpicMergeGateRestMergePattern)
            $number = 0
            if ($rest.Success -and [int]::TryParse($rest.Groups[1].Value, [ref] $number)) { return $number }
        }
    }
    return $null
}
```

The executor may adjust this code to satisfy PSScriptAnalyzer and the Appendix B/C cases; any change keeps the six function names, keeps the file free of dot-sources and imports, and is copied byte-identically to `.codex/hooks/` (P3-T9) and both bundle mirrors (P3-T16).

## Appendix F — Hook and pinned-test edit texts

F.1 Claude deny text (`.claude/hooks/enforce-epic-merge-gate.ps1:415`; also the value of `$script:Line433Text` at `tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1:83` and `$script:ClaudeDenyText` in Appendix B):

```text
EPIC_MERGE_GATE_BLOCKED: a pull-request merge or merge-queue enqueue (gh pr merge with any method, --auto, or --admin, or a gh api merge or enqueue mutation) requires either a per-feature checkpoint with epic_mode == true and step9_status == "passed", an epic checkpoint with epic_merge_pr.ci_gate.conclusion == "success" and a matching pr_number, or a parallel-orchestrator checkpoint with route_id == "parallel" whose target item (matched by pr_number) has merge_status == "ci_green". No checkpoint satisfied this gate.
```

F.2 Claude scope-filter replacement (`:334-356`):

```powershell
    # Scope (issue #952): every gh pr merge invocation except a pure --disable-auto, and every gh api
    # merge or enqueue mutation, is gated; Test-EpicMergeGateCommandInScope holds the predicate.
    if (-not (Test-EpicMergeGateCommandInScope -CommandText $commandText)) {
        return Get-EpicMergeGateAllowDecision
    }
```

F.3 Claude reader. (a) `.DESCRIPTION` body replacing `:104-118`:

```text
        The number is resolved by Get-EpicMergeGateSelectorPrNumber in
        enforce-epic-merge-gate-command.ps1 (issue #952), from the segment that structurally
        invokes gh pr merge or gh api and never from the whole command line: value flags are
        skipped with their values, an all-digit or /pull/<n> URL selector is accepted, and a
        pulls/<n>/merge path supplies the number for gh api. A command with no resolvable number
        yields $null, which the parallel and standalone branches treat as fail-closed. No
        whole-line digit scan exists, so a cd path component can never supply the number.
```

(b) Body replacing `:131-142`: `    return Get-EpicMergeGateSelectorPrNumber -CommandText $CommandText`

F.4 Claude dot-source, inserted after `:72`:

```powershell
# Merge and enqueue scope predicate and the PR selector reader (issue #952).
try { . (Join-Path $PSScriptRoot 'enforce-epic-merge-gate-command.ps1') } catch { Add-HookDependencyFailure -Name 'enforce-epic-merge-gate-command.ps1' -ErrorRecord $_ }
```

F.5 Claude header. (a) `:3` becomes `    Pre-tool-use hook that gates every pull-request merge or merge-queue enqueue behind checkpoint state.` (b) `:7-8` become:

```text
    command runs. Brings every gh pr merge invocation except a pure --disable-auto, and every gh
    api merge or enqueue mutation, into scope from the envelope's tool_input.command and, when
    matched, allows the action only when one of four
```

(c) `:34` becomes:

```text
    Trigger scope (issue #952): every merge method (--merge/-m, --squash/-s, --rebase/-r), --auto,
    --admin, and a bare gh pr merge are gated alike, because under a merge queue each spelling
    enqueues the pull request; only a pure --disable-auto is out of scope. The predicate and the
    PR selector reader live in enforce-epic-merge-gate-command.ps1.
```

F.6 Codex deny text (`.codex/hooks/enforce-epic-merge-gate.ps1:191`; also `$script:CodexDenyText` at `tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1:79` and in Appendix C):

```text
EPIC_MERGE_GATE_BLOCKED: a pull-request merge or merge-queue enqueue (gh pr merge with any method, --auto, or --admin, or a gh api merge or enqueue mutation) requires a safe epic child checkpoint or a successful final epic CI gate with a matching PR number.
```

F.7 Codex scope-filter replacement (`:139-157`):

```powershell
    # Scope (issue #952): every gh pr merge invocation except a pure --disable-auto, and every gh api
    # merge or enqueue mutation, is gated; Test-EpicMergeGateCommandInScope holds the predicate.
    if (-not (Test-EpicMergeGateCommandInScope -CommandText $command)) {
        return $null
    }
```

F.8 Codex reader. (a) `.DESCRIPTION` body replacing `:48-56`:

```text
        The number is resolved by Get-EpicMergeGateSelectorPrNumber in
        enforce-epic-merge-gate-command.ps1 (issue #952), the file shared byte-identically with
        the Claude runtime, from the segment that structurally invokes gh pr merge or gh api and
        from nowhere else. A leading cd <path> segment contributes no selector, so no digit run
        outside the merge segment can be mistaken for a pull-request number.
```

(b) Body replacing `:64-75`: `    return Get-EpicMergeGateSelectorPrNumber -CommandText $Command`

F.9 Codex dot-source, inserted after `:13`:

```powershell
# Merge and enqueue scope predicate and the PR selector reader (issue #952), byte-identical to the
# Claude copy.
try { . (Join-Path $PSScriptRoot 'enforce-epic-merge-gate-command.ps1') } catch { Add-HookDependencyFailure -Name 'enforce-epic-merge-gate-command.ps1' -ErrorRecord $_ }
```

F.10 Codex help block replacing `:1-4`:

```text
<#
.SYNOPSIS
    Gates epic child and integration PR merges behind checkpointed green state.
.DESCRIPTION
    Trigger scope (issue #952): every gh pr merge invocation (any merge method, --auto, --admin,
    or no method flag) and every gh api merge or enqueue mutation is gated, because under a merge
    queue each of them reaches the base branch; only a pure --disable-auto is out of scope. The
    predicate and the PR selector reader live in enforce-epic-merge-gate-command.ps1.
#>
```

F.11 `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1:37-41` replacement:

```powershell
        It 'denies gh pr merge --squash without a checkpoint (issue #952 method-agnostic scope)' {
            Mock -CommandName Get-ChildOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-EpicOrchestratorCheckpointContent -MockWith { $null }
            Mock -CommandName Get-ParallelOrchestratorCheckpointContent -MockWith { $null }
            $json = '{"tool_input":{"command":"gh pr merge 10 --squash"}}'
            $decision = Invoke-EpicMergeGateDecision -ToolInputRaw $json
            $decision.hookSpecificOutput.permissionDecision | Should -Be 'deny'
            $decision.hookSpecificOutput.permissionDecisionReason | Should -Match 'EPIC_MERGE_GATE_BLOCKED'
        }
```

## Appendix G — Merge-confirmation parser

G.1 Contract for `.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1` (modeled on `.claude/lib/ci-gate/Invoke-CiGateParser.ps1:1-117` and `:385-401`):

- Comment-based help states the purpose, the input shapes (`gh pr view --json state,mergeCommit,mergedAt,autoMergeRequest` output or a GraphQL `pullRequest` node with optional `isInMergeQueue`), the mapping below, the error prefix, and that the script never invokes `gh`.
- Script `param`: `[Parameter(ValueFromPipeline = $true)][AllowEmptyString()][string]$PrJson = ''` and `[switch]$AsJson`. No parameter is mandatory, so the file can be dot-sourced with no arguments (by the tests and by `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`).
- `begin` block defines `Get-MergeConfirmationStatus -Snapshot <object>` (pure mapping) and `Invoke-MergeConfirmationParser -PrJson <string> [-AsJson]` (parse plus mapping). `process` block runs `Invoke-MergeConfirmationParser -PrJson $PrJson -AsJson:$AsJson` only when `$MyInvocation.InvocationName -ne '.'`.
- Every property read uses `$Snapshot.PSObject.Properties['<name>']`, so the parser is safe under `Set-StrictMode -Version Latest`.
- Mapping (case-sensitive `state` values): `MERGED` with a non-empty `mergeCommit.oid` → `merged`; `MERGED` with a null `mergeCommit` or an empty or missing `oid` → throw; `CLOSED` → `closed`; `OPEN` with `isInMergeQueue` equal to `$true`, or with a present non-null `autoMergeRequest` → `pending`; `OPEN` otherwise → `not_queued`; a null snapshot, a missing `state`, or any other `state` value → throw.
- Output: `[pscustomobject]@{ Status = <status>; MergeCommitSha = <oid or ''>; MergedAt = <text or ''> }`. `MergeCommitSha` and `MergedAt` are empty unless `Status` is `merged`. `MergedAt` is the `mergedAt` value as text: a string is returned verbatim; a `[datetime]` or `[datetimeoffset]` (produced by `ConvertFrom-Json`) is formatted `yyyy-MM-ddTHH:mm:ssZ` in UTC with `[System.Globalization.CultureInfo]::InvariantCulture`. `-AsJson` returns `ConvertTo-Json -Depth 3 -Compress` of the object.
- Errors: every `throw` message starts `Invoke-MergeConfirmationParser: ` (malformed JSON, null snapshot or missing state, unrecognized state naming the value, `MERGED` without a merge commit oid).

G.2 `tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1`: first line `Set-StrictMode -Version Latest`; `Describe 'Invoke-MergeConfirmationParser (issue #952)'` whose `BeforeAll` sets `$script:ParserPath` from `$PSScriptRoot/../../../../.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1` and dot-sources it. Thirteen cases:

1. `'maps MERGED with a merge commit to merged with the commit SHA and merge time'` (input `{"state":"MERGED","mergedAt":"2026-10-16T12:34:56Z","isInMergeQueue":false,"mergeCommit":{"oid":"0123456789abcdef0123456789abcdef01234567"},"autoMergeRequest":null}`; asserts `Status` `merged`, the oid, and `MergedAt` `2026-10-16T12:34:56Z`).
2. `'throws when MERGED carries an empty merge commit oid'`.
3. `'throws when MERGED carries a null merge commit'`.
4. `'maps CLOSED to closed with an empty SHA and merge time'`.
5. `'maps OPEN with isInMergeQueue true to pending'`.
6. `'maps OPEN with a non-null autoMergeRequest and no isInMergeQueue field to pending'`.
7. `'maps OPEN with isInMergeQueue false and a null autoMergeRequest to not_queued'`.
8. `'maps OPEN with neither field present to not_queued'`.
9. `'throws on malformed JSON'`.
10. `'throws on an unrecognized state'` (input `{"state":"DRAFT"}`; message names `DRAFT`).
11. `'throws when the state field is absent'`.
12. `'emits compressed JSON with Status, MergeCommitSha, and MergedAt when -AsJson is set'`.
13. `'runs the script entry point when invoked directly'` (`& $script:ParserPath -PrJson <closed input>` returns `Status` `closed`; in-process, no child process).

Every throw case asserts `Should -Throw -ExpectedMessage 'Invoke-MergeConfirmationParser:*'`.

G.3 `tests/scripts/claude-lib/ci-gate/MergeConfirmationParser.Manifest.Tests.ps1`: a copy of `tests/scripts/claude-lib/ci-gate/CiGate.Manifest.Tests.ps1` with `$script:ExpectedPath = '.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1'`, `Describe 'MergeConfirmationParser core.json manifest membership'`, and the cases `'lists the merge confirmation parser path in core.json paths'` and `'lists the merge confirmation parser path exactly once'`.

## Appendix H — Release flow

H.1 `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1`:

- `:338` `'pr merge 291 --merge --delete-branch'` becomes `'pr merge 291 --merge'`.
- `:168-172` (`$ghFlat | Should -Be @(...)`) becomes: `$ghFlat.Count | Should -Be 4`; `$ghFlat[0..2] | Should -Be @('pr view release/full-20260703171500 --json number --jq .number', 'pr checks 291 --required --json bucket', 'pr merge 291 --merge')`; `$ghFlat[3] | Should -Match '^api graphql '`.
- Insert after `:77` (inside `Initialize-SuccessfulGhFlowMock`, after the merge branch's closing `}`):

```powershell
            if ($joined -match '^api graphql ') {
                return @{ Output = @('{"state":"MERGED","mergedAt":"2026-07-03T17:30:00Z","isInMergeQueue":false,"mergeCommit":{"oid":"def456"},"autoMergeRequest":null}'); ExitCode = 0 }
            }
```

- `:75` `'pr merge 291 --merge --delete-branch'` becomes `'pr merge 291 --merge'`.

H.2 `tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1`, inserted after `:80`:

```powershell
                if ($joined -match '^api graphql ') { return @{ Output = @('{"state":"MERGED","mergedAt":"2026-07-03T17:30:00Z","isInMergeQueue":false,"mergeCommit":{"oid":"def456"},"autoMergeRequest":null}'); ExitCode = 0 } }
```

H.3 `tests/scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.Tests.ps1`: first line `Set-StrictMode -Version Latest`; `Describe "Invoke-FullReleaseFlow.ps1 - merge wait (issue #952)"` with the `BeforeAll`/`BeforeEach` of `Invoke-FullReleaseFlow.Tests.ps1:3-15` (dot-source with `-ConfirmToken 'no'`; `Invoke-Sleep` mocked in `BeforeEach`). Snapshot fixtures: merged `{"state":"MERGED","mergedAt":"2026-10-16T12:34:56Z","isInMergeQueue":false,"mergeCommit":{"oid":"0123456789abcdef0123456789abcdef01234567"},"autoMergeRequest":null}`; pending `{"state":"OPEN","mergedAt":null,"isInMergeQueue":true,"mergeCommit":null,"autoMergeRequest":{"enabledAt":"2026-10-16T12:00:00Z"}}`; not queued `{"state":"OPEN","mergedAt":null,"isInMergeQueue":false,"mergeCommit":null,"autoMergeRequest":null}`; closed `{"state":"CLOSED","mergedAt":null,"isInMergeQueue":false,"mergeCommit":null,"autoMergeRequest":null}`. Flow-level cases reuse the git and child-script mock shapes of `Invoke-FullReleaseFlow.Tests.ps1:17-96` with a gh mock that returns the scripted snapshot sequence for `^api graphql `.

1. `W-1 returns 0 after a pending snapshot followed by a merged snapshot, sleeping once for the poll interval` (`-PollIntervalSeconds 30 -TimeoutSeconds 90`; `Invoke-Sleep` invoked exactly once with `Seconds` 30).
2. `W-2 returns 0 on the first poll with no sleep when the pull request is already merged`.
3. `W-3 returns 1 after polling floor(timeout / interval) + 1 times when every snapshot is pending` (`-PollIntervalSeconds 30 -TimeoutSeconds 90`; `Invoke-GhExe` invoked 4 times, `Invoke-Sleep` 3 times; stderr matches `did not merge within 90 seconds`).
4. `W-4 returns 1 with a not-queued message when the pull request is open and neither merged nor queued` (stderr matches `neither merged nor queued`).
5. `W-5 returns 1 with a closed message when the pull request is closed` (stderr matches `was closed without merging`).
6. `W-6 returns 1 when the merge-state read fails` (gh `ExitCode` 1; stderr matches `Failed to read merge state for PR #291`).
7. `W-7 returns 1 with the parser message when the snapshot is malformed` (gh output `not json`; stderr matches `Invoke-MergeConfirmationParser:`).
8. `W-8 reads merge state with the exact gh api graphql argument list` (captured `$GhArgs -join ' '` equals `'api graphql -f query=query($owner:String!,$name:String!,$number:Int!){repository(owner:$owner,name:$name){pullRequest(number:$number){state mergedAt isInMergeQueue mergeCommit{oid} autoMergeRequest{enabledAt}}}} -F owner={owner} -F name={repo} -F number=291 --jq .data.repository.pullRequest'`, written as a single-quoted literal).
9. `W-9 flow: merges with no --delete-branch, waits for the merge, then checks out, pulls, and pushes the tag` (result 0; gh calls contain `pr merge 291 --merge` and no `--delete-branch`; the first `^api graphql ` call index is after the merge call; `checkout main` and `pull origin main` occur; both child scripts called).
10. `W-10 flow: stops before checkout, pull, and tag push when the merge wait times out` (every snapshot pending; result 1; no `checkout main`, no `pull origin main`, one child call).
11. `W-11 flow: stops before checkout, pull, and tag push when the pull request is not queued`.
12. `W-12 flow: stops before checkout, pull, and tag push when the pull request is closed`.

H.4 `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`

(a) `.DESCRIPTION` step 4 (`:15-16`):

```text
      4. Waits for GitHub checks through gh, merges only after gh reports checks
         success, and waits until the merge is confirmed (issue #952).
```

(b) After the `param` block:

```powershell
# Merge-state parser shared with the orchestration procedures (issue #952); dot-sourcing defines
# Invoke-MergeConfirmationParser without running it.
. (Join-Path -Path $PSScriptRoot -ChildPath '../../.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1')
```

(c) New function:

```powershell
function Wait-ForPullRequestMerged {
    <#
    .SYNOPSIS
        Waits until a pull request's merge is confirmed (issue #952).
    .DESCRIPTION
        Under a merge queue gh pr merge exits 0 after it enqueues the pull request, so a zero exit
        does not prove a merge. Reads the pull-request state through gh api graphql (Invoke-GhExe
        seam) and classifies each snapshot with Invoke-MergeConfirmationParser. Polls at most
        floor(TimeoutSeconds / PollIntervalSeconds) + 1 times and calls Invoke-Sleep between
        consecutive polls, never after the last one. Without a queue the first poll reports merged.
    .PARAMETER PrNumber
        The pull request number.
    .PARAMETER PollIntervalSeconds
        Seconds between polls.
    .PARAMETER TimeoutSeconds
        Total wait budget in seconds (5400 is 90 minutes).
    .OUTPUTS
        Integer: 0 when the merge is confirmed; 1 on a read failure, an unclassifiable snapshot, a
        closed or not-queued pull request, or timeout. Each 1 writes one stderr line.
    #>
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PrNumber,

        [Parameter()]
        [ValidateRange(1, 86400)]
        [int]$PollIntervalSeconds = 30,

        [Parameter()]
        [ValidateRange(1, 86400)]
        [int]$TimeoutSeconds = 5400
    )

    $query = 'query($owner:String!,$name:String!,$number:Int!){repository(owner:$owner,name:$name){pullRequest(number:$number){state mergedAt isInMergeQueue mergeCommit{oid} autoMergeRequest{enabledAt}}}}'
    $ghArgs = @('api', 'graphql', '-f', "query=$query", '-F', 'owner={owner}', '-F', 'name={repo}', '-F', "number=$PrNumber", '--jq', '.data.repository.pullRequest')
    $stop = 'Stopping before checkout, pull, and tag push.'
    $maxPolls = [int][Math]::Floor($TimeoutSeconds / $PollIntervalSeconds) + 1

    for ($poll = 1; $poll -le $maxPolls; $poll++) {
        if ($poll -gt 1) {
            Invoke-Sleep -Seconds $PollIntervalSeconds
        }

        $result = Invoke-GhExe -GhArgs $ghArgs
        if ($result.ExitCode -ne 0) {
            Write-StderrLine -Message "Failed to read merge state for PR #$PrNumber (gh exit code $($result.ExitCode)). $stop"
            return 1
        }

        try {
            $state = Invoke-MergeConfirmationParser -PrJson ($result.Output -join "`n")
        }
        catch {
            Write-StderrLine -Message "Merge state for PR #$PrNumber could not be classified: $($_.Exception.Message) $stop"
            return 1
        }

        switch ($state.Status) {
            'merged' { return 0 }
            'closed' {
                Write-StderrLine -Message "PR #$PrNumber was closed without merging. $stop"
                return 1
            }
            'not_queued' {
                Write-StderrLine -Message "PR #$PrNumber is open but neither merged nor queued; it was removed from the merge queue or never enqueued. $stop"
                return 1
            }
        }
    }

    Write-StderrLine -Message "PR #$PrNumber did not merge within $TimeoutSeconds seconds and is still awaiting the merge queue. $stop"
    return 1
}
```

(d) Replacement for `:369-373`:

```powershell
    $merge = Invoke-GhExe -GhArgs @('pr', 'merge', $prNumber, '--merge')
    if ($merge.ExitCode -ne 0) {
        Write-StderrLine -Message "Pull request merge failed for PR #$prNumber (gh exit code $($merge.ExitCode)). Stopping before checkout, pull, and tag push."
        return 1
    }

    # A merge queue makes gh pr merge return before the merge happens (issue #952).
    $mergeWait = Wait-ForPullRequestMerged -PrNumber $prNumber
    if ($mergeWait -ne 0) {
        return 1
    }
```

## Appendix I — Python contract pins

I.1 `tests/scripts/dev_tools/merge_queue_documentation_expectations.py`:

```python
"""Fragment pins for the issue #952 queue-aware merge procedures.

Consumed by ``test_completion_gate_documentation_contracts.py``. Each pin names a
surface, the exact ``##`` heading that opens the section, and the fragments the
section must contain after whitespace collapsing. The module holds data only: it
reads no file, spawns no process, and performs no network access.
"""

from __future__ import annotations

from pathlib import Path

CONFIRMED = "only after the merge is confirmed by polling and ancestry check"

_CLAUDE_BUNDLE = Path("extensions/drm-copilot/resources/claude-customizations")
_CODEX_BUNDLE = Path("extensions/drm-copilot/resources/codex-and-agents-customizations")

PARALLEL_ORCHESTRATE = Path(".claude/skills/parallel-orchestrate/SKILL.md")
PARALLEL_ORCHESTRATOR_AGENT = Path(".claude/agents/parallel-orchestrator.md")
CLAUDE_ORCHESTRATE = Path(".claude/skills/orchestrate/SKILL.md")
EPIC_ORCHESTRATE = Path(".claude/skills/epic-orchestrate/SKILL.md")
EPIC_ORCHESTRATOR_AGENT = Path(".claude/agents/epic-orchestrator.md")
AGENTS_EPIC_ORCHESTRATE = Path(".agents/skills/epic-orchestrate/SKILL.md")
CODEX_EPIC_ORCHESTRATOR_AGENT = Path(".codex/agents/epic-orchestrator.toml")

MERGE_QUEUE_FRAGMENT_PINS: tuple[tuple[str, Path, str, tuple[str, ...]], ...] = (
    (
        "claude-parallel-orchestrate-merge",
        PARALLEL_ORCHESTRATE,
        "## Per-Item Merge to Main (Merge-on-Green)",
        (
            "Execute `gh pr merge --merge <PR>`",
            "Do not pass `--delete-branch` or `--auto`.",
            "A zero exit status does not prove a merge",
            ".claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1 -PrJson"
            " <snapshot-json> -AsJson",
            "report the item as `awaiting_merge_queue`, leave its `merge_status` at"
            " `ci_green`, and do not record `merged`",
            "the merge is confirmed only when that command exits 0",
            "Never re-issue `gh pr merge` in a loop after a `not_queued` outcome",
            "`merge_status: merged` " + CONFIRMED,
            "the queue replaces that `gh pr update-branch` cycle",
        ),
    ),
    (
        "claude-parallel-orchestrate-conflict",
        PARALLEL_ORCHESTRATE,
        "## Per-Item Merge-Conflict Handling",
        ("or a `not_queued` merge confirmation whose `mergeable` value is `CONFLICTING`",),
    ),
    (
        "claude-parallel-orchestrator-agent",
        PARALLEL_ORCHESTRATOR_AGENT,
        "## Completion Requirements",
        ("A `merged` value is recorded " + CONFIRMED,),
    ),
    (
        "claude-orchestrate-s9",
        CLAUDE_ORCHESTRATE,
        "## Step S9 — CI Green Gate",
        (
            "`epic_merge.merge_commit_sha` is recorded " + CONFIRMED,
            "record a finding naming `awaiting_merge_queue` with"
            " `Remediability: awaiting_ci`",
            "`gh pr merge` is never re-issued in a loop after `not_queued`",
        ),
    ),
    (
        "claude-orchestrate-pr-gate",
        CLAUDE_ORCHESTRATE,
        "## PR Creation Gate",
        ("`epic_merge.merge_commit_sha` is recorded " + CONFIRMED + " (S9 step 6)",),
    ),
    (
        "claude-epic-orchestrate-lifecycle",
        EPIC_ORCHESTRATE,
        "## Epic Integration Branch Lifecycle",
        ("`epic_merge_pr.merge_commit_sha` is recorded " + CONFIRMED,),
    ),
    (
        "claude-epic-orchestrate-kickoff",
        EPIC_ORCHESTRATE,
        "## Merge-on-Green Kickoff Parameter",
        ("The child records `epic_merge` " + CONFIRMED,),
    ),
    (
        "claude-epic-orchestrate-completion",
        EPIC_ORCHESTRATE,
        "## Completion Requirements",
        ("and it is recorded " + CONFIRMED,),
    ),
    (
        "claude-epic-orchestrator-agent",
        EPIC_ORCHESTRATOR_AGENT,
        "## Completion Requirements",
        ("`epic_merge_pr.merge_commit_sha` is recorded " + CONFIRMED,),
    ),
    (
        "agents-epic-orchestrate",
        AGENTS_EPIC_ORCHESTRATE,
        "## Final Integration PR",
        ("The final merge SHA is recorded " + CONFIRMED,),
    ),
    (
        "codex-epic-orchestrator-agent",
        CODEX_EPIC_ORCHESTRATOR_AGENT,
        "## Completion",
        ("The final merge SHA is recorded " + CONFIRMED,),
    ),
)

MERGE_QUEUE_MIRROR_PAIRS: tuple[tuple[str, tuple[Path, Path]], ...] = (
    ("claude-epic-orchestrate", (EPIC_ORCHESTRATE, _CLAUDE_BUNDLE / EPIC_ORCHESTRATE)),
    (
        "claude-epic-orchestrator-agent",
        (EPIC_ORCHESTRATOR_AGENT, _CLAUDE_BUNDLE / EPIC_ORCHESTRATOR_AGENT),
    ),
    (
        "agents-epic-orchestrate",
        (AGENTS_EPIC_ORCHESTRATE, _CODEX_BUNDLE / AGENTS_EPIC_ORCHESTRATE),
    ),
    (
        "codex-epic-orchestrator-agent",
        (CODEX_EPIC_ORCHESTRATOR_AGENT, _CODEX_BUNDLE / CODEX_EPIC_ORCHESTRATOR_AGENT),
    ),
)
```

I.2 `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py`:

- After `:30` add:

```python
from tests.scripts.dev_tools.merge_queue_documentation_expectations import (
    MERGE_QUEUE_FRAGMENT_PINS,
    MERGE_QUEUE_MIRROR_PAIRS,
)
```

- Before the mirror test (`:412`) add:

```python
@pytest.mark.parametrize(
    ("relative_path", "heading", "fragments"),
    [(path, heading, fragments) for _, path, heading, fragments in MERGE_QUEUE_FRAGMENT_PINS],
    ids=[pin_id for pin_id, _, _, _ in MERGE_QUEUE_FRAGMENT_PINS],
)
def test_merge_procedure_records_merge_only_after_confirmation(
    relative_path: Path, heading: str, fragments: tuple[str, ...]
) -> None:
    """Each merge procedure records a merge only after queue-aware confirmation (#952)."""
    # Arrange / Act / Assert
    _assert_section_contains(relative_path, heading, fragments)
```

- Mirror test parametrization (`:413-416`): the value list becomes `[pair for _, pair in MIRROR_PAIRS + MERGE_QUEUE_MIRROR_PAIRS]` and the ids list becomes `[pair_id for pair_id, _ in MIRROR_PAIRS + MERGE_QUEUE_MIRROR_PAIRS]`.

## Appendix R — PowerShell runner commands (PowerShell tool, in-process)

Path sets:

- **PS-SET** (17 files): `.claude/hooks/enforce-epic-merge-gate.ps1`, `.claude/hooks/enforce-epic-merge-gate-command.ps1`, `.codex/hooks/enforce-epic-merge-gate.ps1`, `.codex/hooks/enforce-epic-merge-gate-command.ps1`, `.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1`, `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`, `tests/scripts/workflows/CiWorkflow.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1`, `tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1`, `tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1`, `tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1`, `tests/scripts/claude-lib/ci-gate/MergeConfirmationParser.Manifest.Tests.ps1`, `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1`, `tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1`, `tests/scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.Tests.ps1`. (Bundle mirrors are byte copies of the first five and are verified by hash in P8-T12.)
- **G-SET**: `tests/scripts/workflows/CiWorkflow.Tests.ps1`, `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`, `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1`, `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1`, `tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1`, `tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1`, `tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1`, `tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1`, `tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1`, `tests/scripts/claude-lib/ci-gate`.

R1 — Pester run (replace `<...>` before entering; the coverage output path stays under `SCRATCH` with the `issue-952-` prefix):

```powershell
Import-Module Pester -MinimumVersion 5.6.1 -ErrorAction Stop
$TestPath = @(<test paths>)
$CoveragePath = @(<coverage paths, or nothing>)
$configuration = New-PesterConfiguration
$configuration.Run.Path = $TestPath
$configuration.Run.PassThru = $true
$configuration.Output.Verbosity = 'Normal'
if ($CoveragePath.Count -gt 0) {
    $configuration.CodeCoverage.Enabled = $true
    $configuration.CodeCoverage.Path = $CoveragePath
    $configuration.CodeCoverage.OutputPath = '<SCRATCH>/issue-952-<run name>.coverage.xml'
}
$result = Invoke-Pester -Configuration $configuration
"TotalCount=$($result.TotalCount)"
"PassedCount=$($result.PassedCount)"
"FailedCount=$($result.FailedCount)"
"FailedContainersCount=$($result.FailedContainersCount)"
foreach ($failedTest in $result.Failed) { "FAILED: $($failedTest.ExpandedPath)" }
foreach ($failedContainer in $result.FailedContainers) { "FAILED-CONTAINER: $($failedContainer.Item)" }
if ($CoveragePath.Count -gt 0) {
    $executed = @($result.CodeCoverage.CommandsExecuted)
    $missed = @($result.CodeCoverage.CommandsMissed)
    foreach ($file in $CoveragePath) {
        $fullPath = (Resolve-Path -LiteralPath $file).Path
        $hitLines = @($executed | Where-Object { $_.File -eq $fullPath } | ForEach-Object { $_.Line } | Sort-Object -Unique)
        $missLines = @($missed | Where-Object { $_.File -eq $fullPath } | ForEach-Object { $_.Line } | Sort-Object -Unique | Where-Object { $hitLines -notcontains $_ })
        $analyzed = @(@($hitLines) + @($missLines) | Sort-Object -Unique)
        $percent = if ($analyzed.Count -eq 0) { 'NA' } else { [math]::Round(100 * $hitLines.Count / $analyzed.Count, 2) }
        "COVERAGE file=$file AnalyzedLines=$($analyzed.Count) CoveredLines=$($hitLines.Count) LinePercent=$percent"
        "MISSED file=$file Lines=$($missLines -join ',')"
    }
}
```

A `LinePercent=NA` for a listed production file fails the task that ran it (no data was collected).

R2 — Format check (read-only):

```powershell
$Path = @(<paths>)
$settings = 'scripts/powershell/PoshQC/settings/pssa.settings.psd1'
$changedCount = 0
foreach ($file in $Path) {
    $original = Get-Content -Raw -LiteralPath $file
    $formatted = Invoke-Formatter -ScriptDefinition $original -Settings $settings
    $changed = $formatted -cne $original
    if ($changed) { $changedCount++ }
    "FORMAT file=$file Changed=$changed"
}
"FORMAT-SUMMARY ChangedCount=$changedCount"
```

R3 — Analyzer:

```powershell
$Path = @(<paths>)
$settings = 'scripts/powershell/PoshQC/settings/pssa.settings.psd1'
$total = 0
foreach ($file in $Path) {
    $findings = @(Invoke-ScriptAnalyzer -Path $file -Settings $settings -Severity Error, Warning, Information)
    $total += $findings.Count
    "PSSA file=$file Findings=$($findings.Count)"
    foreach ($finding in $findings) { "PSSA-FINDING file=$file line=$($finding.Line) rule=$($finding.RuleName)" }
}
"PSSA-SUMMARY FindingCount=$total"
```

R4 — Format apply (write mode; used only by the P8-T1 restart branch; its success-case output is the printed `FORMAT-APPLY-SUMMARY AppliedCount=<n>` line, and the following R2 run must print `FORMAT-SUMMARY ChangedCount=0`):

```powershell
$Path = @(<paths>)
$settings = 'scripts/powershell/PoshQC/settings/pssa.settings.psd1'
$applied = 0
foreach ($file in $Path) {
    $original = Get-Content -Raw -LiteralPath $file
    $formatted = Invoke-Formatter -ScriptDefinition $original -Settings $settings
    if ($formatted -cne $original) {
        Set-Content -LiteralPath $file -Value $formatted -Encoding UTF8 -NoNewline
        $applied++
        "FORMAT-APPLIED file=$file"
    }
}
"FORMAT-APPLY-SUMMARY AppliedCount=$applied"
```

R5 — Ruleset comparison:

```powershell
$ff = 'docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset'
$snap = Get-Content -Raw -LiteralPath "$ff/protect-main.current.2026-10-16.json" | ConvertFrom-Json
$toJson = { param($Value) $Value | ConvertTo-Json -Depth 20 -Compress }
$queueRule = '{"type":"merge_queue","parameters":{"check_response_timeout_minutes":60,"grouping_strategy":"ALLGREEN","max_entries_to_build":5,"max_entries_to_merge":5,"merge_method":"MERGE","min_entries_to_merge":1,"min_entries_to_merge_wait_minutes":5}}'
$snapRules = @($snap.rules | ForEach-Object { & $toJson $_ })
$nonStrictRules = @($snap.rules | ForEach-Object {
        $text = & $toJson $_
        if ($_.type -eq 'required_status_checks') { $text.Replace('"strict_required_status_checks_policy":true', '"strict_required_status_checks_policy":false') } else { $text }
    })
$expected = [ordered]@{
    'protect-main.merge-queue.apply.json'      = @($snapRules + $queueRule)
    'protect-main.non-strict.alternative.json' = $nonStrictRules
    'protect-main.rollback.json'               = $snapRules
}
$allOk = $true
foreach ($name in $expected.Keys) {
    $payload = Get-Content -Raw -LiteralPath "$ff/$name" | ConvertFrom-Json
    $keys = @($payload.PSObject.Properties.Name | Sort-Object) -join ','
    $keysOk = $keys -ceq 'bypass_actors,conditions,enforcement,name,rules,target'
    $fieldsOk = $true
    foreach ($field in 'name', 'target', 'enforcement', 'conditions', 'bypass_actors') {
        if ((& $toJson $payload.$field) -cne (& $toJson $snap.$field)) { $fieldsOk = $false }
    }
    $rules = @($payload.rules | ForEach-Object { & $toJson $_ })
    $rulesOk = ($rules -join "`n") -ceq ($expected[$name] -join "`n")
    "PAYLOAD file=$name Keys=$keys KeysOk=$keysOk FieldsOk=$fieldsOk RulesOk=$rulesOk RuleCount=$($rules.Count)"
    if (-not ($keysOk -and $fieldsOk -and $rulesOk)) { $allOk = $false }
}
"RULESET-COMPARE AllOk=$allOk"
```

## Appendix S — Ruleset deliverables

Each payload is a JSON object with exactly the keys `name`, `target`, `enforcement`, `conditions`, `rules`, `bypass_actors`, in that order, copied from the snapshot text with the snapshot's nested key order and two-space indentation. Read-only snapshot fields (`id`, `source_type`, `source`, `node_id`, `created_at`, `updated_at`, `current_user_can_bypass`, `_links`) are omitted.

- S.1 `protect-main.merge-queue.apply.json`: `name` through `conditions` copied from snapshot `:3-4`, `:7-15`; `rules` copied from `:16-93` with one element appended after the `required_status_checks` rule: `{ "type": "merge_queue", "parameters": { "check_response_timeout_minutes": 60, "grouping_strategy": "ALLGREEN", "max_entries_to_build": 5, "max_entries_to_merge": 5, "merge_method": "MERGE", "min_entries_to_merge": 1, "min_entries_to_merge_wait_minutes": 5 } }`; `bypass_actors` copied from `:97-103`. `strict_required_status_checks_policy` stays `true`.
- S.2 `protect-main.non-strict.alternative.json`: as S.1 without the appended rule, and with `"strict_required_status_checks_policy": false` in place of snapshot `:43`.
- S.3 `protect-main.rollback.json`: as S.1 without the appended rule; every value equals the snapshot.
- S.4 `runbook.md`: title, a status line stating the payloads are shipped and not applied by issue #952, and these sections, each heading on its own line:
  - `## Preconditions`: the repository is organization-owned or the API accepts the `merge_queue` rule (GitHub documents merge queues for organization-owned repositories; `drmoisan/drm-copilot` is user-owned); the issue #952 PR is merged so `ci.yml` triggers on `merge_group`; a token with repository administration write permission; `conditions.ref_name.include` is `~DEFAULT_BRANCH` with no wildcard.
  - `## Capture and Diff Before Applying`: `gh api repos/drmoisan/drm-copilot/rulesets/15241672` captured to a file, diffed against `protect-main.current.2026-10-16.json`; on any difference in a writable field, regenerate the three payloads from the fresh capture before applying.
  - `## Apply`: the command `gh api --method PUT repos/drmoisan/drm-copilot/rulesets/15241672 --input protect-main.merge-queue.apply.json` on one line.
  - `## Post-Apply Verification`: GET the ruleset and confirm the `merge_queue` rule; enqueue one green PR and confirm every context in `required_status_checks` reports on a `merge_group` run; queue two green PRs and confirm both merge without `gh pr update-branch`; enqueue a `BEHIND` PR to confirm the queue accepts it with `strict_required_status_checks_policy: true`, applying a follow-up payload with `false` if it is refused.
  - `## Expected Failure on a User-Owned Repository`: the PUT is expected to fail with HTTP 422 while the repository is user-owned (expected, not observed); no partial change is expected; take no further action.
  - `## Rollback`: `gh api --method PUT repos/drmoisan/drm-copilot/rulesets/15241672 --input protect-main.rollback.json`; roll back when a required context does not report within `check_response_timeout_minutes`.
  - `## Non-Strict Alternative (Separate Operator Decision)`: `protect-main.non-strict.alternative.json` removes the re-sync loop now and works on a user-owned repository, but loses pre-merge validation of the combined result; `push` CI on `main` detects breakage only after it lands.
  - `## Admin Merges Skip the Queue`: `gh pr merge --admin` merges directly for the bypass actor (user 54180981, `bypass_mode: pull_request`) and skips the queue; the merge gate requires an authorization record for `--admin` like any merge.
