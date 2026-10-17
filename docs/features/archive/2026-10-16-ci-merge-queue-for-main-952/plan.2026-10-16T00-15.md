# 2026-10-16-ci-merge-queue-for-main (Plan)

- **Issue:** #952
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-16
- **Status:** Draft (revision 5, citation re-derivation after the origin/main merge at merge commit 1195107340f811b565a2ee311e1ad3ce731c5680, which brought #928 and #929; revision 4 applied coordinator decisions D10(a), D10(b), R4 to R6)
- **Version:** 1.5
- **Work Mode:** full-bug (`issue.md` metadata `- Work Mode: full-bug`; `spec.md` `## Acceptance Criteria`, AC-1 through AC-28, is the acceptance-criteria source; `user-story.md` is intentionally absent)
- **Branch:** `bug/ci-merge-queue-for-main-952`
- **Feature folder:** `docs/features/active/2026-10-16-ci-merge-queue-for-main-952`
- **Requirements sources:** `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md`; `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/issue.md`; `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/research/research.2026-10-16T01-30.md`; `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/protect-main.current.2026-10-16.json` (read-only snapshot of ruleset 15241672)

## Conventions (binding for every task)

**FEATURE.** `FEATURE` = `docs/features/active/2026-10-16-ci-merge-queue-for-main-952`. Every evidence artifact is written under `FEATURE/evidence/<kind>/` with `<kind>` one of `baseline`, `regression-testing`, `qa-gates`, `other`. No artifact is written under `artifacts/`. No artifact records an absolute host path; the worktree root is recorded as the literal token `WORKTREE_ROOT`.

**Evidence filenames and timestamps.** Each artifact is named `<name>.<timestamp>.md`. The `<timestamp>` in the filename and the `Timestamp:` field are host-clock UTC in `yyyy-MM-ddTHH-mm` form, read immediately before the write by the first of these that runs: `date -u +%Y-%m-%dT%H-%M`; `poetry run python -c "import datetime; print(datetime.datetime.now(datetime.timezone.utc).strftime('%Y-%m-%dT%H-%M'))"`; `git var GIT_COMMITTER_IDENT` (prints the current epoch seconds; the artifact then records `ClockSource: git var GIT_COMMITTER_IDENT`, the raw epoch value, and its UTC conversion). No stamp is composed or estimated. A task that consumes an artifact selects the lexicographically greatest file matching `<name>.*.md`. Every command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:` and `Output Summary:`.

**SCRATCH.** `SCRATCH` resolves to `<session scratchpad>/issue-952/`. The executor writes no scratch file. The only scratch files of this plan are the orchestrator's CI artifact downloads in `## Orchestrator-Owned Verification`, each under `SCRATCH/issue-952-ci-<runId>/`. Plans and evidence record the literal token `SCRATCH`, never a host path. Scratch files are not committed.

**Executor capability boundary.** The atomic-executor's tools are Read, Grep, Glob, Edit, Write, the Bash patterns `poetry run black *`, `poetry run ruff *`, `poetry run pyright *`, `poetry run pytest *`, `npx prettier *`, `npx eslint *`, `npx tsc *`, `npx jest *`, `pwsh *` and `git *` (`.claude/agents/atomic-executor.md:5-24`; `Bash(pwsh *)` is `:19`), and the PoshQC MCP tools (`:21-24`). The `Bash(pwsh *)` allowlist entry is not usable: the worktree-isolation guard (a runtime guard, not a file in this repository) refuses any command text containing `pwsh`, `bash` or `wsl`, a heredoc, a `cd ... &&` chain, or `git -C`. That refusal is why Option A (below) routes every local PowerShell format, analyze and test step through the PoshQC MCP tools, and no executor command contains those strings. The executor has no `gh`. Every item in `## Orchestrator-Owned Verification` (ORCH-0 to ORCH-7) is performed by this item's orchestrator, which has `gh` and the PowerShell tool; that section carries no checkboxes, and the executor does not perform or block on its items, except that P0-T2 requires the ORCH-0 deletion and P0-T3 requires the committed ORCH-1 artifact.

**Python environment precondition.** `poetry install` is an orchestrator precondition: it was run in this worktree on 2026-10-16 with `EXIT=0`. The executor does not run it. If any `poetry run` command fails with a missing-module, missing-interpreter or environment error (as distinct from a test or lint failure), the executor records the error text and halts for the caller.

**PowerShell verification (Option A).** Local PowerShell verification uses only `mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze` and `mcp__drm-copilot__run_poshqc_test`, each called with `workspace_root` = the worktree root and an explicit `scan_folders` list. No task invokes Pester, PSScriptAnalyzer or Invoke-Formatter through `pwsh`, `sh`, `bash` or any wrapper. Folder keys used by every PowerShell task:

| Key | `scan_folders` value |
|---|---|
| `src-claude-hooks` | `.claude/hooks` |
| `src-codex-hooks` | `.codex/hooks` |
| `src-ci-gate` | `.claude/lib/ci-gate` |
| `src-dev-tools` | `scripts/dev-tools` |
| `t-workflows` | `tests/scripts/workflows` |
| `t-claude-hooks` | `tests/scripts/claude-hooks` |
| `t-codex-hooks` | `tests/scripts/codex-hooks` |
| `t-ci-gate` | `tests/scripts/claude-lib/ci-gate` |
| `t-dev-tools` | `tests/scripts/dev-tools` |
| `t-claude-runtime` | `tests/scripts/claude-runtime` |

`F-SET` (format and analyze) is the nine keys other than `t-claude-runtime`. `T-SET` (test) is the six `t-` keys.

**MCP observation rule (fixed).** A PoshQC MCP result carries only a pre-composed summary string and no count, finding, test name or coverage value. The only observables are: (1) call disposition — the call returned (record `EXIT_CODE: 0`, `Disposition: RETURNED`) or the call raised (record `EXIT_CODE: 1`, `Disposition: RAISED`, and the error text verbatim; the runtime raises `Command exited with code N.` when the child exits non-zero); and (2) for `run_poshqc_format`, the tree comparison `git status --porcelain -- <the scan folders of the call>` recorded immediately before and after the call. No acceptance condition reads a count, percentage, finding or test name from an MCP result. Per-test results, Passed counts and coverage come only from CI artifacts read by the orchestrator in ORCH-1 and ORCH-4 to ORCH-6. The `Command:` field of an MCP artifact is written `mcp__drm-copilot__<tool> workspace_root=WORKTREE_ROOT scan_folders=[<folders>]`.

**Baseline disposition rule.** P0-T9 and P0-T10 record each folder's baseline disposition as `GREEN` (returned) or `RED` (raised). For a later analyze or test call on a folder whose baseline is `GREEN`, the acceptance is the stated disposition. For a folder whose baseline is `RED`, the later call is recorded with `LOCAL-NONDISCRIMINATING (baseline RED)`, it is not counted as evidence for any AC, and the corresponding CI job of `R_final` (ORCH-4 and ORCH-5) is the only gate; an `[expect-fail]` task on a `RED` folder writes the fail-before exception dossier named in that task instead of expecting a raised call.

**Expect-fail artifacts.** Every `[expect-fail]` artifact carries `Timestamp:`, `Command:`, `EXIT_CODE: 1`, `ExpectedExitCode: 1`, `Output Summary:` (the error text), and a `RowAttribution:` section listing each new or changed row named by the task with its expected pre-change outcome and its code-path reason, because an MCP result names no row. A returned call on a `GREEN` folder fails the task and halts execution for the caller: the new tests did not discriminate the pre-change tree.

**Mirror mechanism.** Every bundle mirror is produced from the git index, so its bytes equal what a checkout of the source produces: `git add <source>` and then `git checkout-index -f --prefix=<bundle>/ -- <source>`, where `<bundle>` is `extensions/drm-copilot/resources/claude-customizations` for a `.claude/` source and `extensions/drm-copilot/resources/codex-and-agents-customizations` for a `.codex/` or `.agents/` source (the trailing `/` is part of the prefix). `git checkout-index` prints nothing on success; the observation is `git hash-object <source> <mirror>` printing two equal hashes. The Codex helper `.codex/hooks/enforce-epic-merge-gate-command.ps1` has a different relative path from its Claude twin, so it is written with the Write tool from the Claude file's exact text and verified by equal `git hash-object` hashes.

**Search and count rule.** Searches use `git grep` over tracked paths; a created file is staged with `git add` before any `git grep` names it. Patterns are passed with `-e`. Line counts use `git grep -c -e "^" -- <paths>`, which prints `<path>:<count>` per file and counts a final line without a trailing newline. No search literal contains a backslash.

**Commit rule.** At the end of each executor phase: `git add` of the named paths plus `FEATURE/evidence/` and `FEATURE/plan.2026-10-16T00-15.md`, `git commit -m "<message>"`, `git push origin bug/ci-merge-queue-for-main-952`. Never `git add -A`, never force-push, never rebase. If a hook refuses a staging, commit or push command, the executor records the refusal text and halts; it does not bypass hooks.

**Edit order.** Edits within one file run bottom-up so the cited line numbers stay valid at each step.

**Origin/main merges and cited line numbers.** Every cited line number in this plan was derived against the tree at merge commit `1195107340f811b565a2ee311e1ad3ce731c5680` (merge-base `04f594f2ad2b891cbd8d1388a2e7fe2c67044d28`), whose per-file line counts P0-T7 asserts. The executor never merges, rebases or force-pushes. When P0-T4 or P3-T1 halts on concurrent `origin/main` changes (for example #927 or #928 merging first), the orchestrator merges `origin/main` into this branch (a merge, not a rebase, so both changes are kept), re-runs ORCH-1 (a new `B`, `R_base` and `ci-baseline.<timestamp>.md`), and, when the merge changed any file whose line numbers a not-yet-completed task cites, obtains a planner re-derivation delta of those citations before execution resumes. If that delta is committed, the orchestrator records the revision commit as `PLAN_REVISION_SHA=<sha>` in `FEATURE/evidence/other/plan-revision.<timestamp>.md`. The same record is written for any other planner delta the orchestrator commits during execution (for example the P8-T13 scope-boundary delta that adds the pre-execution lifecycle record to the expected set), with the revision commit as `PLAN_REVISION_SHA`. A cited line number is therefore asserted only against the tree that P0-T7 (or the re-derivation delta) describes; the executor does not adjust a cited line number itself, and a mismatch it observes is recorded and halts execution for the caller.

## Fixed Derivations (orchestrator; not left to choice)

**D-BASE (baseline CI run).** `B` = the output of `git merge-base origin/main HEAD` computed by the orchestrator in ORCH-1 after `git fetch origin`; P0-T2 records the same command's output. `R_base` is the run returned by `gh run list --workflow ci.yml --branch main --event push --commit <B> --status success --limit 1 --json databaseId,headSha`. If that returns no run, `R_base` is the most recent successful `push` run of `ci.yml` on `main` whose `headSha` `X` is an ancestor of `B` and for which `git diff --quiet <X> <B> -- tests scripts .claude .codex config` exits 0. If neither exists, ORCH-1 records `BLOCKED: no baseline run` and the orchestrator stops for operator input.

**D-FINAL (final pre-PR CI run).** After the executor's last push (P9-T13) and the ORCH-2 commit, the orchestrator runs `git fetch origin`, records `H_final` = the output of `git rev-parse origin/bug/ci-merge-queue-for-main-952`, and dispatches `gh workflow run ci.yml --ref bug/ci-merge-queue-for-main-952` (`ci.yml` declares `workflow_dispatch:` at `.github/workflows/ci.yml:8`). `R_final` is the run returned by `gh run list --workflow ci.yml --branch bug/ci-merge-queue-for-main-952 --event workflow_dispatch --commit <H_final> --limit 1 --json databaseId,headSha,status,conclusion`, waited on with `gh run watch <R_final> --exit-status`. A dispatched run can take some seconds to register, so the list can be empty immediately after `gh workflow run`: the orchestrator re-runs the same `gh run list` command every 15 seconds, for at most 20 attempts, until it returns a run whose `headSha` equals `H_final`; when the 20th attempt still returns none, it records `BLOCKED: dispatched run not registered` with the 20 empty outputs and stops for operator input rather than dispatching again. `R_final` is not a pull-request run; it exists before the PR, so ORCH-4 to ORCH-6 complete before feature review. A later commit that changes only paths under `FEATURE/` does not invalidate `R_final`; any other changed path does, and requires a new dispatch (ORCH-7 checks this).

**D-PR (pull-request CI run, AC-28 only).** `R_pr` is the most recent `ci.yml` run of event `pull_request` for the PR whose `headSha` equals the PR head SHA at the time of the check (`gh pr view --json headRefOid`). Only ORCH-3 uses `R_pr`.

**D-JUNIT (suite and row derivation).** Windows file: `pester-junit.xml` from artifact `poshqc-test-results` (job `poshqc / PowerShell QC`, `windows-latest`). Linux file: `pester-junit-linux-hooks.xml` from artifact `poshqc-linux-hook-test-results` (job `poshqc / PowerShell hook suites (Linux)`, `ubuntu-latest`; runs only `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks`, coverage disabled, `.github/workflows/_poshqc.yml:54-90`). Downloads go to `SCRATCH/issue-952-ci-<runId>/`. A testcase belongs to suite `S` when its `classname` attribute, after replacing every backslash with `/`, ends with `/` + the repository-relative path of `S`. The Passed count of `S` is the number of member testcases with no `failure`, `error` or `skipped` child. A named row is always paired with a suite `S`; it passes when at least one member testcase of `S` has a `name` containing the row text and every such member testcase has no `failure`, `error` or `skipped` child; zero matching member testcases of `S` is a FAIL, even when a testcase of another suite matches. Suites under `tests/scripts/workflows`, `tests/scripts/claude-lib`, `tests/scripts/dev-tools` and `tests/scripts/claude-runtime` appear only in the Windows file.

**D-COV (per-file line coverage).** File: `powershell-coverage.xml` from artifact `poshqc-test-results` (CoverageGutters output, JaCoCo shape; population from `config/poshqc-coverage.json` `roots`: `.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.codex/scripts`, `scripts`). The entry for a production path `P` is the `sourcefile` element `s` inside `package` element `p` for which the string `p.name + '/' + s.name`, or `s.name` alone, with every backslash replaced by `/`, equals `P` or ends with `/` + `P`. Exactly one entry must match; zero or several matches is recorded with the candidate names as `FAIL: coverage entry not unique`. Line coverage of `P` = `100 * covered / (covered + missed)` from that `sourcefile`'s direct child `counter` element with `type="LINE"`, rounded to two decimals.

**D-CHANGED (changed-line coverage).** `B` here is the `B=` value of the lexicographically greatest `FEATURE/evidence/baseline/ci-baseline.*.md` (the latest ORCH-1 run; see `## Conventions`, origin/main merges). For production path `P`, the changed lines are the added-line ranges `+start,count` of the hunk headers of `git diff -U0 <B> <R_final headSha> -- <P>` (every line for a new file). The changed executable lines are the changed lines that appear as `line` elements (`nr` attribute) of `P`'s D-COV entry; a changed executable line is covered when its `ci` attribute is greater than 0. Changed-line percent = `100 * covered changed executable lines / changed executable lines`, rounded to two decimals; `n/a` when there are no changed executable lines.

## Scope Recap

Binding scope is `spec.md` `## Scope & Non-Goals` and `## Proposed Fix`:

1. `.github/workflows/ci.yml` gains `merge_group: types: [checks_requested]` with no filter; `.github/workflows/README.md` lists it; `tests/scripts/workflows/CiWorkflow.Tests.ps1` asserts it and asserts that the `ci.yml` call graph reads no pull-request event field.
2. The merge gate becomes method-agnostic on both runtimes. A new helper file per runtime (`enforce-epic-merge-gate-command.ps1`, byte-identical on both runtimes) holds the scope predicate and a gh-aware PR selector reader.
3. A pure parser `.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1` maps one PR snapshot to `merged | pending | not_queued | closed`.
4. Every Claude and Codex merge procedure records a merge only after confirmation by polling and ancestry check.
5. `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` drops `--delete-branch` and waits for a confirmed merge before checkout, pull, and tag; the wait function lives in the new sibling file `scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.ps1`.
6. Three ruleset payloads and a runbook are shipped under `ruleset/` in the feature folder and are not applied.
7. Related in-item fixes decided by the coordinator: D10(a) makes `.claude/skills/cleanup-merged-worktrees/SKILL.md` (and its bundle mirror) queue-aware with a contract pin; D10(b) grants the `epic-orchestrator` persona the two `pwsh` parser invocations its procedure prescribes, with a new permission-seam test; R4 records the three stale policy statements that this item may not edit in `FEATURE/policy-followups.md`.

## Decisions Recorded by the Planner

- **PR-number reader delegation (deviation note for #927).** The caller asked that edits to `.claude/hooks/enforce-epic-merge-gate.ps1` be limited to the scope-filter call site, the dot-source, header comments, and the deny message. `spec.md` `### Implementation strategy` additionally requires the gh-aware selector reader to replace "the body of `Get-EpicMergeGateCommandPrNumber` on Claude and `Get-CodexMergeCommandPrNumber` on Codex", and AC-8 tests that reader by name. The plan therefore also replaces the reader's body (`.claude/hooks/enforce-epic-merge-gate.ps1:131-142`) with a one-line delegation to the helper and rewrites its `.DESCRIPTION` (`:104-118`). All parsing logic lives in the helper file. This is a fifth, small edit region and is listed in `## Concurrency and Out-of-Scope Constraints`.
- **`awaiting_merge_queue` is procedure text only.** `scripts/dev_tools/_orchestrator_state_blocked_reason.py` defines a closed `blocked_reason` vocabulary that contains `awaiting_ci` (`:46`) and not `awaiting_merge_queue`, and the parallel `merge_status` enum is validator-owned. The procedure texts therefore report `awaiting_merge_queue` without writing it into any validated enum field: the parallel procedure leaves `merge_status` at `ci_green`; orchestrate S9 step 6 records a finding naming `awaiting_merge_queue` with `Remediability: awaiting_ci` and uses the existing `blocked_reason: "awaiting_ci"` wait branch. This matches `spec.md` `## Data / API / Config Impact` ("No schema migration is introduced").
- **Poll query.** Procedures and the release flow read merge state with one `gh api graphql` query that includes `isInMergeQueue` (research Q3: `gh pr view --json` has no `isInMergeQueue` field). The query uses gh's documented `{owner}` and `{repo}` placeholder substitution in `-F` field values. The merge gate allows this read query (AC-7 allow case G5 in Appendix B uses the exact procedure query).
- **Release-flow wait lives in a sibling helper file.** After the origin/main merge, `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` is 435 lines (issue #931 moved its pure check-poll helpers into `scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.ps1`, dot-sourced at `:44-47`). Adding the about 75-line wait function to the script would exceed 500 lines, so `Wait-ForPullRequestMerged` and the dot-source of `.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1` go into a new sibling file `scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.ps1` (P5-T5, Appendix H.4(c)), which the script dot-sources the same way it dot-sources the CheckHelpers file (P5-T7, Appendix H.4(b)). The projected script size is 446 lines (435 + H.4(a) +1 + H.4(b) +4 + H.4(d) +6); P5-T10 and P8-T10 assert at most 500. The CheckHelpers file has no bundle mirror and no pack-manifest entry (`git grep` over `extensions/` for `Invoke-FullReleaseFlow` finds nothing), so the MergeWait file gets neither; it is inside the coverage root `scripts` of `config/poshqc-coverage.json:8`, so ORCH-6 measures it as a `NEW` file. The helper calls the `Invoke-GhExe`, `Invoke-Sleep` and `Write-StderrLine` seams that the script defines (`:90-105`, `:127-147`, `:49-56`), which resolve at call time in the dot-sourcing scope.
- **Release-flow test changes after #931.** Main now polls `pr checks <n> --json bucket` with no `--required` flag (`scripts/dev-tools/Invoke-FullReleaseFlow.ps1:233`), so Appendix H.1 expects `'pr checks 291 --json bucket'`, and `tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py:105-110` requires the script text to keep "every GitHub check on the pull request head" and to contain neither `--required` nor the phrase "required check"; Appendix H.4(a) keeps that phrase, and P5-T8 runs `test_release_flow_waits_on_every_check_without_required_wording`.
- **Contract pins.** `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py` is 426 lines and collects 33 test nodes (10 plain tests, four parametrized tests of three cases each, and the 11-pair mirror test at `:412-426`). The new fragment table lives in a new data module `tests/scripts/dev_tools/merge_queue_documentation_expectations.py` with 12 pins (including the D10(a) pin on `.claude/skills/cleanup-merged-worktrees/SKILL.md`) and 5 mirror pairs; the contract module gains one parametrized test and the five mirror pairs (about 20 lines: a four-line import and a sixteen-line test with its two separating blank lines, so the module stays near 446 lines).
- **Frozen epic-surface digests (re-baseline).** `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py:171-180` (`PINNED_FROZEN_SURFACE_HASHES`) pins `.claude/agents/epic-orchestrator.md` and `.claude/skills/epic-orchestrate/SKILL.md` by SHA-256 of their working-tree bytes, and `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py:470-485` (`test_frozen_epic_surface_matches_pinned_baseline_digest`) fails on any byte change. P6-T14 to P6-T16 (skill) and P6-T20 and P6-T21 (agent body and tools grants) change both files by design (AC-18 and D10(b)), so the plan re-baselines both digests after the last of those edits (P6-T24 records the failing run and the two `found` digests; P6-T25 writes them with a `# RE-BASELINED by issue #952.` comment block), following the precedent of the earlier `RE-BASELINED by issue #...` blocks at `:108-170` (the last of them, `RE-BASELINED by issue #928.`, is `:166-170`). The grant edit P6-T21 therefore lands before the re-baseline, and the digests capture the final bytes of both files; a later change to either file repeats P6-T24 and P6-T25 under `## Restart Rule (Phase 8)`. `.gitattributes:1` (`* text=auto eol=lf`) makes the working-tree bytes LF on every host, so the digest computed locally equals the one CI computes. No other line of that file changes; its pin "Execute `gh pr merge --merge <PR>`" (`:229` before P6-T25, `:235` after the six inserted comment lines) stays verbatim.
- **Epic-orchestrator tools grants (coordinator D10(b)).** `.claude/skills/epic-orchestrate/SKILL.md:127` prescribes `pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1`, and Appendix D.4(a) adds an inline `pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1 ... -AsJson` invocation, but `.claude/agents/epic-orchestrator.md:15-16` grants only `Bash(git *)` and `Bash(gh *)`. P6-T21 inserts the two `pwsh` grants (Appendix D.9, the same form as `.claude/agents/parallel-orchestrator.md:24`) in the tools frontmatter only, a region separate from the Appendix D.5 body edit. The new test `tests/scripts/dev_tools/test_epic_orchestrator_permission_contracts.py` (Appendix I.4, P6-T18) reuses `persona_bash_grants`, `prescribed_command_invocations` and `bash_grant_covers` from `tests/scripts/dev_tools/parallel_orchestrator_permission_seam_support.py:128-147`, `:457-496` and `:179-204` with the epic paths, and P6-T19 records its failure against the pre-edit persona. #928 (merged through PR #954; see `## Concurrency and Out-of-Scope Constraints`) changed only `.claude/agents/epic-orchestrator.md:133-135` and `.claude/skills/epic-orchestrate/SKILL.md:279-281`, which none of these edit regions overlaps; P0-T4 checks `origin/main` for any further change to both files.
- **Codex epic persona needs no grant change.** `.codex/agents/epic-orchestrator.toml:5` sets `default_permissions = "orchestrator-workspace"`, a filesystem and network profile (`.codex/config.toml:79-90`, extending `:workspace`) with no per-command allowlist, so a `pwsh` parser invocation inside the workspace needs no persona entry. The toml is edited only by Appendix D.7 (AC-19).
- **Cleanup skill queue-aware wording (coordinator D10(a)).** `.claude/skills/cleanup-merged-worktrees/SKILL.md:206-208` states the strict up-to-date requirement unconditionally. P6-T26 replaces those three lines with Appendix D.8, which states the queue case and keeps the strict requirement for the case without a queue; P6-T27 re-copies the mirror `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`. A repository-wide search finds no other copy of this skill under `.agents/`, `.codex/` or `.github/`. The pin `claude-cleanup-merged-worktrees` (Appendix I.1) and its mirror pair test the new text.
- **Policy follow-up record (coordinator R4).** `.claude/rules/orchestrator-state.md:238` and `.claude/rules/parallel-orchestration.md:154` and `:689` become stale after this item but may not be edited (no policy-edit approval). P7-T6 writes `FEATURE/policy-followups.md` per Appendix P (file, line, verbatim current text, reason, proposed replacement) and verifies each quoted text is still at its line; no rule file is modified.
- **Authorization rows `--squash`.** `tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1:102` and `tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1:95` already expect `allow` with a valid record; under the method-agnostic scope they still allow (the record now authorizes them). Their rows are not edited. The two files are edited only at the pinned deny-text constants (`:83` and `:79`), which AC-11 changes.
- **PowerShell verification route (Option A, decided by the orchestrator).** See `## Conventions`. Local gates are MCP call dispositions and formatter tree comparisons; per-row results, Passed counts and coverage come from CI artifacts of the dispatched pre-PR run `R_final` (D-FINAL) read by the orchestrator in ORCH-4 to ORCH-6. The Pester-verified ACs (AC-1, AC-2, AC-5 through AC-15) and the coverage part of AC-27 are therefore recorded `PENDING-ORCH` by the executor and checked off by the orchestrator in ORCH-6, before feature review and before PR creation. Only AC-28 is CI-dependent in the sense of `.claude/skills/orchestrate/SKILL.md:361` (it needs the `pull_request` run on the PR head); it is recorded `PENDING-CI` and checked off in ORCH-7 at S9.
- **PowerShell coverage.** Per-file line coverage comes from D-COV and changed-line coverage from D-CHANGED. Threshold: 85% line (the root `CLAUDE.md` states no coverage threshold, so the default in `.claude/rules/general-unit-test.md` applies); Pester has no branch metric. Production files in scope are T3 (`.claude/hooks`, `.codex/hooks`, `.claude/lib/ci-gate`) and T4 (`scripts/dev-tools`) per `quality-tiers.yml:19-41`, so no property-test or mutation obligation applies.
- **Python coverage.** No production Python file is created or modified (see `## Files Written`). The touched Python files are two test modules and two test-data modules, all under `tests/`, which coverage tooling excludes. Python coverage is recorded as not applicable by P0-T17 and verified by P8-T13.
- **Ruleset comparison is orchestrator-owned.** The semantic JSON comparison of the three payloads with the snapshot (Appendix O.1) needs the PowerShell tool, which the executor lacks. The executor performs fail-capable token checks (P7-T1 to P7-T3); the orchestrator runs Appendix O.1 in ORCH-2 after the executor returns and before feature review, so AC-21 to AC-23 are verified before PR creation.
- **Orchestrator-owned items carry no checkboxes.** `.claude/hooks/validate-executor-output.ps1:257-287` rejects an execution-run stop while any line of the plan matches the unchecked-task form, so the orchestrator-owned items live in the non-task section `## Orchestrator-Owned Verification` as plain `[ORCH-n]` bullets. The executor can therefore finish with every task line checked. The orchestrator records each item's outcome in its named artifact, not in a checkbox.
- **Parallel-orchestrator tools grant.** `.claude/agents/parallel-orchestrator.md` gains one `Bash` grant for the merge-confirmation parser, `  - "Bash(pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1*)"`, inserted after the existing `Invoke-CiGateParser.ps1*` grant (`:24`) by P6-T9. Appendix D.1(a) prescribes `pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1 -PrJson <snapshot-json> -AsJson` in `.claude/skills/parallel-orchestrate/SKILL.md`, and `tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py::test_every_prescribed_command_invocation_has_a_persona_bash_grant` fails unless a persona `Bash(...)` grant covers every prescribed invocation (prefix match for a `*`-terminated grant, `tests/scripts/dev_tools/parallel_orchestrator_permission_seam_support.py:179-204`). That module is therefore part of the P0-T12 command, which the P6-T33 command (reused by P8-T7) extends with the new epic permission module.
- **AC-16 on the agent file.** `spec.md` AC-16 says both `.claude/skills/parallel-orchestrate/SKILL.md` and `.claude/agents/parallel-orchestrator.md` "keep" "Execute `gh pr merge --merge <PR>`" verbatim, but the agent file has never contained that phrase. `spec.md` is not edited. For the agent file, AC-16 is satisfied by the queue-aware confirmation text appended by P6-T9 per Appendix D.2; the verbatim-keep clause applies to the skill file, where the phrase exists and stays unchanged (Appendix D.1(a)).
- **AC-25 interpretation.** `issue.md`, the research file, the ruleset snapshot, and the plan file were added on this branch before execution, so a diff against `main` lists them as added. AC-25 is verified against `PLAN_BASE_SHA` (recorded by P0-T2): the first three are byte-unchanged, and the plan file's only changes are checklist transitions from `- [ ]` to `- [x]`. The issue's promoted lifecycle record `docs/features/potential/promoted/2026-10-16-ci-merge-queue-for-main.md` was also added on this branch before execution (commit `bf7b5c694`); P8-T13 expects it in the changed-path set and asserts it byte-unchanged since `PLAN_BASE_SHA`.

## Concurrency and Out-of-Scope Constraints

- **Concurrent item #927** is expected to touch `.claude/hooks/enforce-epic-merge-gate*.ps1` (docs-only merge allowance; not verifiable from the tree per research Q5). Overlapping files: `.claude/hooks/enforce-epic-merge-gate.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1`, `.codex/hooks/enforce-epic-merge-gate.ps1`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1`, `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`, and possibly `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1`. Edit regions in `.claude/hooks/enforce-epic-merge-gate.ps1` are limited to: header `:3`, `:7-8`, `:34`; the guarded dot-source inserted after `:72`; the reader `.DESCRIPTION` and body `:104-118`, `:131-142` (delegation only; see Decisions); the scope-filter call site `:334-356`; and the deny message `:415`. All new logic is in `.claude/hooks/enforce-epic-merge-gate-command.ps1`. P0-T4 and P3-T1 check `origin/main` for #927 changes to these files and halt for the caller when any exist. The executor never merges, rebases or force-pushes: on such a halt the orchestrator merges `origin/main` into this branch (no rebase; both changes are kept), re-runs ORCH-1, obtains a re-derivation delta for any cited line the merge moved, and resumes execution (see `## Conventions`, origin/main merges).
- **Item #928 (merged).** #928 (PR #954) has merged into `origin/main` and is included in this branch through merge commit `1195107340f811b565a2ee311e1ad3ce731c5680`, together with #929 (PR #958). It replaced three lines in each epic file (`.claude/agents/epic-orchestrator.md:133-135` and `.claude/skills/epic-orchestrate/SKILL.md:279-281`, line counts unchanged) and added the `RE-BASELINED by issue #928.` block (`tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py:166-170`) with new pinned digests. None of these lines overlaps an edit region of this plan, so no conflict arose; the frozen digests P6-T24 and P6-T25 replace are the #928 values, and the inserted #952 block follows the #928 block. This plan's edits in the two epic files are limited to the tools frontmatter insertion after `.claude/agents/epic-orchestrator.md:16` (P6-T21), the body insertion after `:163` (P6-T20), and the skill lines `:129`, `:141` and `:356` (P6-T14 to P6-T16). P0-T4 still checks `origin/main` for any further change to both files with the same halt-and-merge rule; the frozen digests are re-baselined on the merged bytes by P6-T24 and P6-T25.
- **Concurrent item #953** owns `.github/workflows/_poshqc.yml`. This plan does not edit it (research Q1: reusable workflows inherit the caller's event; only `ci.yml` needs `merge_group`).
- **Not edited by this plan:** `.github/workflows/_poshqc.yml` and every workflow other than `.github/workflows/ci.yml` and `.github/workflows/README.md`; every file under `.claude/rules/` and `.github/instructions/` (the stale statements are recorded by P7-T6, not edited); `.claude/hooks/hook-command-invocation.ps1` and `.codex/hooks/hook-command-invocation.ps1` (no gh-specific flag is added to the shared tables); `.claude/skills/parallel-run/SKILL.md`; `scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.ps1`; every `.github/` agent, skill, prompt, and instruction file; `issue.md`; `research/research.2026-10-16T01-30.md`; `ruleset/protect-main.current.2026-10-16.json`. The ruleset is not applied.
- No force-push. No deletion of any file. No GitHub issue creation. Every commit uses `git add` of explicit paths.

## Out-of-Scope Follow-ups (recorded, not tasks)

- Policy edits (require approval): `.claude/rules/orchestrator-state.md:238`, `.claude/rules/parallel-orchestration.md:154` and `.claude/rules/parallel-orchestration.md:689`. The edits are not made by this item; P7-T6 records the current text, the reason and the proposed replacement in `FEATURE/policy-followups.md` (Appendix P) for a separately approved change.
- Optional: `.github/workflows/README.md:34-75` documents the legacy branch-protection endpoint rather than the ruleset endpoint in use.
- Evaluate gating `gh` invocations issued through the Claude PowerShell tool (no `PreToolUse` matcher covers that tool; research Q6).

## Files Written

Every repository-relative path this plan creates or modifies. No task writes a path absent from this list.

Overlap note: concurrent item #927 is expected to touch `.claude/hooks/enforce-epic-merge-gate*.ps1` (docs-only merge allowance). Files in this list that it may also touch: `.claude/hooks/enforce-epic-merge-gate.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1`, `.codex/hooks/enforce-epic-merge-gate.ps1`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1`, both `pack-manifests/core.json` files, and `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1`. Edit regions in `.claude/hooks/enforce-epic-merge-gate.ps1` are limited as stated in `## Concurrency and Out-of-Scope Constraints`; all new logic is in the new helper file.

Overlap note for #928 (merged into this branch; no conflicting region): `.claude/agents/epic-orchestrator.md`, its bundle mirror, `.claude/skills/epic-orchestrate/SKILL.md`, its bundle mirror, and `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (regions stated in `## Concurrency and Out-of-Scope Constraints`).

Created (19: 14 outside the feature folder, 5 inside it):

- `.claude/hooks/enforce-epic-merge-gate-command.ps1` (P3-T2)
- `.codex/hooks/enforce-epic-merge-gate-command.ps1` (P3-T8, Write-tool copy of the Claude helper)
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-command.ps1` (P3-T14)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate-command.ps1` (P3-T14)
- `.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1` (P4-T4)
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1` (P4-T5)
- `tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1` (P2-T1)
- `tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1` (P2-T5)
- `tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1` (P4-T1)
- `tests/scripts/claude-lib/ci-gate/MergeConfirmationParser.Manifest.Tests.ps1` (P4-T2)
- `tests/scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.Tests.ps1` (P5-T3)
- `scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.ps1` (P5-T5)
- `tests/scripts/dev_tools/merge_queue_documentation_expectations.py` (P6-T1)
- `tests/scripts/dev_tools/test_epic_orchestrator_permission_contracts.py` (P6-T18)
- `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/protect-main.merge-queue.apply.json` (P7-T1)
- `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/protect-main.non-strict.alternative.json` (P7-T2)
- `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/protect-main.rollback.json` (P7-T3)
- `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/runbook.md` (P7-T4)
- `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/policy-followups.md` (P7-T6)

Modified outside the feature folder (33):

- `.github/workflows/ci.yml` (P1-T3)
- `.github/workflows/README.md` (P1-T5)
- `tests/scripts/workflows/CiWorkflow.Tests.ps1` (P1-T1)
- `.claude/hooks/enforce-epic-merge-gate.ps1` (P3-T3 through P3-T7)
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1` (P3-T14)
- `.codex/hooks/enforce-epic-merge-gate.ps1` (P3-T9 through P3-T13)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1` (P3-T14)
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (P3-T15, P4-T6)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` (P3-T15)
- `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` (P2-T2)
- `tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1` (P2-T3)
- `tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1` (P2-T6)
- `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` (P5-T6 through P5-T8)
- `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1` (P5-T1)
- `tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1` (P5-T2)
- `.claude/skills/parallel-orchestrate/SKILL.md` (P6-T4 through P6-T7)
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md` (P6-T8)
- `.claude/agents/parallel-orchestrator.md` (P6-T9; Appendix D.2 body text and one tools grant)
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-orchestrator.md` (P6-T10)
- `.claude/skills/orchestrate/SKILL.md` (P6-T11, P6-T12)
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md` (P6-T13)
- `.claude/skills/epic-orchestrate/SKILL.md` (P6-T14 through P6-T16)
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md` (P6-T17)
- `.claude/agents/epic-orchestrator.md` (P6-T20 Appendix D.5 body text; P6-T21 two tools grants, Appendix D.9)
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/epic-orchestrator.md` (P6-T23)
- `.claude/skills/cleanup-merged-worktrees/SKILL.md` (P6-T26)
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md` (P6-T27)
- `.agents/skills/epic-orchestrate/SKILL.md` (P6-T28)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-orchestrate/SKILL.md` (P6-T29)
- `.codex/agents/epic-orchestrator.toml` (P6-T30)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/epic-orchestrator.toml` (P6-T31)
- `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py` (P6-T2)
- `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (P6-T25; `PINNED_FROZEN_SURFACE_HASHES` digests and one added comment block only)

Inside the feature folder:

- `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md` (AC check-off only: Phase 9 by the executor; ORCH-2, ORCH-6 and ORCH-7 by the orchestrator)
- `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/plan.2026-10-16T00-15.md` (ORCH-0 deletes the preflight directive line and its paragraph before execution; after that, checklist state only, except a planner re-derivation delta committed by the orchestrator under `## Conventions`, origin/main merges)
- `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/` (the four created files above)
- `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/policy-followups.md` (created above)
- `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/**` (every evidence artifact named in the tasks)

Scratch (outside the repository): `SCRATCH/issue-952-ci-<runId>/` (orchestrator CI downloads, ORCH-1 and ORCH-4 to ORCH-6) only.

Deleted: none.

Pre-execution lifecycle record (not written by this plan): `docs/features/potential/promoted/2026-10-16-ci-merge-queue-for-main.md` is the issue's promoted lifecycle record (the issue-adoption potential record). The preparation run added it to this branch in commit `bf7b5c694`, before `PLAN_BASE_SHA`; no task of this plan creates, modifies, reverts or deletes it, so it is not a planned path above. Because the branch adds it relative to the merge-base, the three-dot name-only diff of P8-T13 lists it.

The planned set "outside the feature folder" is therefore exactly 47 paths: the 14 created paths outside the feature folder plus the 33 modified paths. The expected set used by P8-T13 is exactly 48 paths: those 47 planned paths plus the one pre-execution lifecycle record.

## Restart Rule (Phase 8)

P8-T1 through P8-T7 form the final QA loop (format, analyze, test for PowerShell; Black, Ruff, Pyright, pytest for Python). If any of them fails, or if P8-T1 or P8-T4 changes a tracked file, fix the cause, re-copy the affected bundle mirror by the mirror mechanism when the changed file has one, commit, and restart from P8-T1. Write a new artifact for each re-run task (a new `<timestamp>`). P8-T8 records every pass. Do not proceed to P8-T9 until P8-T1 through P8-T7 pass in one uninterrupted pass. If a hook denies a required command, stop and report the denial; do not bypass the hook.

Frozen-digest re-baseline. If any change made after P6-T25 (a Phase 6 fix, a Phase 8 restart repair, a remediation edit, or an orchestrator merge of `origin/main` that changes either epic file) changes `.claude/agents/epic-orchestrator.md` or `.claude/skills/epic-orchestrate/SKILL.md`, the executor repeats P6-T24 and P6-T25 for the changed state (a new `frozen-digest-before.<timestamp>.md` artifact whose summary contains `1 failed` or `2 failed` according to the number of changed files, then the digest update of the changed entries only, with the existing `# RE-BASELINED by issue #952.` block kept unchanged rather than duplicated, and a new `frozen-digest-after.<timestamp>.md` artifact whose re-run summary contains `2 passed`), re-copies the changed file's bundle mirror, commits, and restarts from P8-T1.

### Phase 0 — Baseline Capture

- [x] [P0-T1] Read the policy files in the required order and write `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/baseline/phase0-instructions-read.<timestamp>.md`.
  Order: `CLAUDE.md`; `.github/copilot-instructions.md`; `.claude/rules/tonality.md`; `.github/instructions/tonality.instructions.md`; `.claude/rules/general-code-change.md`; `.github/instructions/general-code-change.instructions.md`; `.claude/rules/general-unit-test.md`; `.github/instructions/general-unit-test.instructions.md`; `.claude/rules/quality-tiers.md`; `quality-tiers.yml`; `.claude/rules/powershell.md`; `.github/instructions/powershell-code-change.instructions.md`; `.github/instructions/powershell-unit-test.instructions.md`; `.claude/rules/python.md`; `.claude/rules/python-suppressions.md`; `.github/instructions/python-code-change.instructions.md`; `.github/instructions/python-unit-test.instructions.md`; `.claude/rules/ci-workflows.md`; `.github/instructions/github-actions.instructions.md`; `.claude/rules/plan-acceptance-gates.md`.
  Acceptance: the artifact contains `Timestamp:`, `Policy Order:`, and the twenty paths above in that order, one per line; it records `Work Mode: full-bug` read from `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/issue.md`, `spec.md: present`, and `user-story.md: absent` after a Glob of `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/{spec.md,user-story.md}`. No policy file is modified.
- [x] [P0-T2] Capture the baseline branch state into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/baseline/branch-state.<timestamp>.md`.
  Commands: `git fetch origin`; `git rev-parse --abbrev-ref HEAD`; `git rev-parse HEAD`; `git rev-parse origin/main`; `git merge-base origin/main HEAD`; `git status --porcelain`; `git grep -c -e "^DIRECTIVE: PREFLIGHT VALIDATION ONLY$" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/plan.2026-10-16T00-15.md`.
  Acceptance: the last command (a basic-regex search anchored at both line ends, so it matches only a line that is exactly the directive and never this acceptance text or any prose line that quotes the directive) exits 1 with no output; it is recorded in its own artifact `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/baseline/directive-removed.<timestamp>.md` with `EXIT_CODE: 1`, `ExpectedExitCode: 1` and `Output Summary: DIRECTIVE_REMOVED=true` (a separate file because the expectation field is per file). Before ORCH-0 the same command prints `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/plan.2026-10-16T00-15.md:1` and exits 0, so the check discriminates; that outcome records `DIRECTIVE_REMOVED=false`, fails the task, and halts execution for the caller (ORCH-0 has not run). `EXIT_CODE: 0` for each other command; `Output Summary:` records the branch name `bug/ci-merge-queue-for-main-952` (any other value fails the task and halts execution), `PLAN_BASE_SHA=<git rev-parse HEAD output>`, the `origin/main` SHA, `B=<merge-base output>` (a 40-character SHA), and the porcelain output verbatim. The orchestrator commits and pushes this plan, the ORCH-1 artifact and the ORCH-0 deletion before delegating, so the porcelain output is expected to list only the untracked P0-T1 artifact (`?? docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/baseline/phase0-instructions-read.<timestamp>.md`); any other listed path fails the task and halts execution.
- [x] [P0-T3] Confirm the orchestrator's CI baseline exists and matches `B`, and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/baseline/ci-baseline-source.<timestamp>.md`.
  Command: `git ls-files -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/baseline/`; then Read the lexicographically greatest listed file matching `ci-baseline.*.md`.
  Acceptance: `EXIT_CODE: 0`; at least one listed path matches `ci-baseline.*.md`; that file's `B=` value equals the P0-T2 `B`, and it records numeric `PS_BASE_CLAUDE_GATE=`, `PS_BASE_CODEX_GATE=` and `PS_BASE_RELEASE=` values. The artifact records the D-BASE rule by name, the file read, and both `B` values. No matching file, unequal `B` values, or a non-numeric value: record `CI-BASELINE-ABSENT` or the mismatch and halt for the caller (ORCH-1 must run first).
- [x] [P0-T4] Check for concurrent changes on `origin/main` to the files this plan shares with #927, #928 and #953, and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/baseline/concurrency-check.<timestamp>.md`.
  Command: `git log --oneline HEAD..origin/main -- .claude/hooks/enforce-epic-merge-gate.ps1 .codex/hooks/enforce-epic-merge-gate.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1 .github/workflows/ci.yml .github/workflows/_poshqc.yml .claude/agents/epic-orchestrator.md .claude/skills/epic-orchestrate/SKILL.md`
  Acceptance: `EXIT_CODE: 0`; the output is recorded verbatim. An empty output records `CONCURRENT_CHANGES=0`. A non-empty output records `CONCURRENT_CHANGES=<line count>`, fails the task, and halts execution for the caller. The executor does not merge, rebase or force-push: the orchestrator merges `origin/main` into this branch (no rebase; both changes are kept), re-runs ORCH-1, obtains a re-derivation delta for any cited line the merge moved (`## Conventions`, origin/main merges), and resumes execution from P0-T2 so that `B`, the porcelain state and the P0-T5 to P0-T7 baselines describe the merged tree.
- [x] [P0-T5] Capture the line endings of the ten existing source and mirror pairs into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/baseline/line-endings.<timestamp>.md`.
  Command: `git ls-files --eol -- .claude/hooks/enforce-epic-merge-gate.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1 .codex/hooks/enforce-epic-merge-gate.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1 .claude/skills/parallel-orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md .claude/agents/parallel-orchestrator.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-orchestrator.md .claude/skills/orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md .claude/skills/epic-orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md .claude/agents/epic-orchestrator.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/epic-orchestrator.md .agents/skills/epic-orchestrate/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-orchestrate/SKILL.md .codex/agents/epic-orchestrator.toml extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/epic-orchestrator.toml .claude/skills/cleanup-merged-worktrees/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`
  Acceptance: `EXIT_CODE: 0`; the output has 20 lines; `Output Summary:` records each pair's `i/` and `w/` values and whether both members match. A mismatched pair is recorded, not repaired (the mirror mechanism makes the pair identical after the edit).
- [x] [P0-T6] Capture the baseline mirror hashes into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/baseline/mirror-hashes.<timestamp>.md`.
  Command: `git hash-object` over the 20 paths of P0-T5, in the same order.
  Acceptance: `EXIT_CODE: 0`; 20 hashes recorded with their paths; `Output Summary:` records `PAIRS_EQUAL=<n>/10`. A value other than `10/10` fails the task and halts execution, because a pre-existing mirror drift would be overwritten silently by the mirror mechanism.
- [x] [P0-T7] Capture the baseline line counts into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/baseline/line-counts.<timestamp>.md`.
  Command: `git grep -c -e "^" -- .claude/hooks/enforce-epic-merge-gate.ps1 .codex/hooks/enforce-epic-merge-gate.ps1 scripts/dev-tools/Invoke-FullReleaseFlow.ps1 tests/scripts/workflows/CiWorkflow.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1 tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py .claude/agents/epic-orchestrator.md .claude/skills/cleanup-merged-worktrees/SKILL.md`
  Acceptance: `EXIT_CODE: 0`; thirteen `<path>:<count>` lines recorded verbatim. `git grep` prints them in its own path order, so output order is not asserted; the output, read as a set of lines, equals exactly this per-path mapping of planner-read values (read on the merged tree at `1195107340f811b565a2ee311e1ad3ce731c5680`): `.claude/hooks/enforce-epic-merge-gate.ps1:472`; `.codex/hooks/enforce-epic-merge-gate.ps1:385`; `scripts/dev-tools/Invoke-FullReleaseFlow.ps1:435`; `tests/scripts/workflows/CiWorkflow.Tests.ps1:174`; `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1:465`; `tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1:181`; `tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1:205`; `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1:438`; `tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1:99`; `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py:426`; `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py:387`; `.claude/agents/epic-orchestrator.md:168`; `.claude/skills/cleanup-merged-worktrees/SKILL.md:579`. A missing, extra or different line is recorded and halts execution, because the cited line numbers in Phases 1 to 6 depend on these counts (`## Conventions`, origin/main merges).
- [x] [P0-T8] Capture the baseline PowerShell format state of F-SET into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/baseline/ps-format.<timestamp>.md`.
  Commands: `git status --porcelain -- .claude/hooks .codex/hooks .claude/lib/ci-gate scripts/dev-tools tests/scripts/workflows tests/scripts/claude-hooks tests/scripts/codex-hooks tests/scripts/claude-lib/ci-gate tests/scripts/dev-tools` (before); `mcp__drm-copilot__run_poshqc_format` with the nine F-SET folders; the same `git status --porcelain` command (after).
  Acceptance: the before-output is empty and the call returned. An empty after-output records `PRE-EXISTING-FORMAT-DRIFT=NONE`. A non-empty after-output records every listed path under `PRE-EXISTING-FORMAT-DRIFT`, each listed path is restored with `git restore -- <listed path>` (the baseline keeps no formatter output), and a final run of the same `git status --porcelain` command is recorded empty. A raised call is recorded and halts execution for the caller.
- [x] [P0-T9] Capture the baseline analyzer disposition of each F-SET folder, one call and one artifact per folder, into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/baseline/ps-analyze-<key>.<timestamp>.md` for each of the nine F-SET keys.
  Command (nine calls): `mcp__drm-copilot__run_poshqc_analyze` with `scan_folders` = the single folder of the key.
  Acceptance: nine artifacts exist, one per F-SET key, each recording the call disposition and `Baseline: GREEN` (returned) or `Baseline: RED` (raised, with the error text). A `RED` folder is not a stop condition; the Baseline disposition rule governs its later calls.
- [x] [P0-T10] Capture the baseline test disposition of each T-SET folder, one call and one artifact per folder, into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/baseline/ps-test-<key>.<timestamp>.md` for each of the six T-SET keys.
  Command (six calls): `mcp__drm-copilot__run_poshqc_test` with `scan_folders` = the single folder of the key.
  Acceptance: six artifacts exist, one per T-SET key, each recording the call disposition and `Baseline: GREEN` or `Baseline: RED`, and stating that per-suite Passed counts and coverage come from ORCH-1 (CI jobs `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)`), not from this call. A `RED` folder is not a stop condition; the Baseline disposition rule governs its later calls.
- [x] [P0-T11] Record the baseline PowerShell coverage headline into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/baseline/ps-coverage.<timestamp>.md`.
  Source: the `ci-baseline.*.md` file read by P0-T3 (written by ORCH-1 from `R_base` by D-COV).
  Acceptance: `Output Summary:` records numeric `PS_BASE_CLAUDE_GATE=` (`.claude/hooks/enforce-epic-merge-gate.ps1`), `PS_BASE_CODEX_GATE=` (`.codex/hooks/enforce-epic-merge-gate.ps1`) and `PS_BASE_RELEASE=` (`scripts/dev-tools/Invoke-FullReleaseFlow.ps1`) copied verbatim, the source file name, the `R_base` run id, and `NEW` for the four production files this plan creates inside the coverage roots (`.claude/hooks/enforce-epic-merge-gate-command.ps1`, `.codex/hooks/enforce-epic-merge-gate-command.ps1`, `.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1`, `scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.ps1`). CI job: `poshqc / PowerShell QC` (the only job that measures coverage).
- [x] [P0-T12] Capture the baseline Python contract-suite result into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/baseline/python-contract-suites.<timestamp>.md`.
  Command: `poetry run pytest tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py tests/scripts/dev_tools/test_skill_bundle_contract_repo.py tests/scripts/dev_tools/test_codex_agent_role_schema.py tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py -q`
  Acceptance: `EXIT_CODE: 0` and the final pytest summary line recorded verbatim, containing `passed` and neither `failed` nor `error`. A failure is recorded with its node IDs and halts execution for the caller.
- [x] [P0-T13] Capture the baseline node count of the documentation contract module into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/baseline/contract-module-count.<timestamp>.md`.
  Command: `poetry run pytest tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py -q`
  Acceptance: `EXIT_CODE: 0`; the summary line `33 passed` (followed by the duration) recorded verbatim; `Output Summary:` records `CONTRACT_BASE_PASSED=33`. A different count is recorded as `CONTRACT_BASE_PASSED=<N>`, and P6-T3 and P6-T32 then use `<N>` in place of 33.
- [x] [P0-T14] Capture the baseline Black state into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/baseline/python-black.<timestamp>.md`.
  Command: `poetry run black --check tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`
  Acceptance: `EXIT_CODE: 0` and the printed line `2 files would be left unchanged.` recorded (check mode writes nothing).
- [x] [P0-T15] Capture the baseline Ruff state into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/baseline/python-ruff.<timestamp>.md`.
  Command: `poetry run ruff check tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`
  Acceptance: `EXIT_CODE: 0` and the printed line `All checks passed!` recorded.
- [x] [P0-T16] Capture the baseline Pyright state into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/baseline/python-pyright.<timestamp>.md`.
  Command: `poetry run pyright tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`
  Acceptance: `EXIT_CODE: 0` and the printed line `0 errors, 0 warnings, 0 informations` recorded.
- [x] [P0-T17] Record Python coverage applicability into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/baseline/python-coverage-applicability.<timestamp>.md`.
  Acceptance: the artifact records `PY_COVERAGE=NOT-APPLICABLE`, the reason (the plan's `## Files Written` names only `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py`, `tests/scripts/dev_tools/merge_queue_documentation_expectations.py`, `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` and `tests/scripts/dev_tools/test_epic_orchestrator_permission_contracts.py` as Python paths, all four under `tests/`, which coverage measurement excludes per `.claude/rules/general-unit-test.md`), and the statement that P8-T13 verifies that these four are the only `.py` paths in the final diff and that none lies outside `tests/`.
- [x] [P0-T18] Commit and push the Phase 0 evidence and the checklist state of `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/plan.2026-10-16T00-15.md`.
  Commands: `git add docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/ docs/features/active/2026-10-16-ci-merge-queue-for-main-952/plan.2026-10-16T00-15.md`; `git commit -m "docs(952): record phase 0 baseline evidence"`; `git push origin bug/ci-merge-queue-for-main-952`.
  Acceptance: `git status --porcelain -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/` prints nothing, and `git rev-parse HEAD` equals `git rev-parse origin/bug/ci-merge-queue-for-main-952`. No force-push.

### Phase 1 — Workflow Trigger (merge_group)

- [x] [P1-T1] Add the two `It` blocks of Appendix A to `tests/scripts/workflows/CiWorkflow.Tests.ps1`, inside the existing `Describe "ci.yml workflow triggers"` block, after the `It "keeps the push branch filter exactly main and development"` block (ends at `:173`) and before the closing `}` of the `Describe` (`:174`).
  Acceptance: `git grep -n -F -e "declares merge_group with types checks_requested" -- tests/scripts/workflows/CiWorkflow.Tests.ps1` prints exactly one line, and `git grep -n -F -e "reads no pull-request event field" -- tests/scripts/workflows/CiWorkflow.Tests.ps1` prints exactly one line. `git grep -n -E -e "New-TemporaryFile|TestDrive|Start-Process" -- tests/scripts/workflows/CiWorkflow.Tests.ps1` exits 1 (no output).
- [x] [P1-T2] [expect-fail] Run the workflow test folder before editing `ci.yml` and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/ciworkflow-before.<timestamp>.md`.
  Command: `mcp__drm-copilot__run_poshqc_test` with `scan_folders` = `["tests/scripts/workflows"]` (key `t-workflows`).
  Acceptance (P0 `t-workflows` GREEN): the call raised; the artifact records the error text, `EXIT_CODE: 1`, `ExpectedExitCode: 1`, and `RowAttribution:` naming `declares merge_group with types checks_requested and no branch or path filter` as failing pre-change (`.github/workflows/ci.yml:3-8` declares no `merge_group` key) and `reads no pull-request event field and declares no path filter anywhere in the ci.yml call graph` as passing pre-change (Appendix A pre-change note). A returned call fails the task and halts execution. Acceptance (P0 `t-workflows` RED): write `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/fail-before-exception.ciworkflow.<timestamp>.md` with `WhyFailingRunImpossible:` (the folder baseline is RED and MCP results name no row) and the same `RowAttribution:` as alternative proof. CI job relied on: `poshqc / PowerShell QC`.
- [x] [P1-T3] Edit `.github/workflows/ci.yml`: insert the two lines `  merge_group:` and `    types: [checks_requested]` immediately after `:8` (`  workflow_dispatch:`) and before the blank line `:9`. No other line changes.
  Acceptance: `git grep -n -F -e "merge_group:" -- .github/workflows/ci.yml` prints exactly one line numbered 9, and `git grep -n -F -e "types: [checks_requested]" -- .github/workflows/ci.yml` prints exactly one line numbered 10; `git diff --numstat HEAD -- .github/workflows/ci.yml` prints `2	0	.github/workflows/ci.yml`.
- [x] [P1-T4] Run the workflow test folder after the edit and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/ciworkflow-after.<timestamp>.md`.
  Command: `mcp__drm-copilot__run_poshqc_test` with `scan_folders` = `["tests/scripts/workflows"]`.
  Acceptance: the call returned (`EXIT_CODE: 0`) when P0 `t-workflows` is GREEN; a raised call fails the task, is fixed, and the task is repeated. P0 `t-workflows` RED: disposition recorded with `LOCAL-NONDISCRIMINATING (baseline RED)`. Per-row results for AC-1 and AC-2 come from ORCH-4 (job `poshqc / PowerShell QC`).
- [x] [P1-T5] Edit `.github/workflows/README.md` `## Triggers`: replace `:10` "`ci.yml` runs on three triggers:" with "`ci.yml` runs on four triggers:", and insert after `:14` ("- `workflow_dispatch`.") the single line "- `merge_group` (`types: [checks_requested]`, no branch or path filter), which serves a merge queue on `main`: when a queue is enabled, every required check is produced by a `merge_group` run of `ci.yml` (issue #952)."
  Acceptance: `git grep -n -F -e "runs on four triggers" -- .github/workflows/README.md` prints exactly one line; `git grep -n -F -e "runs on three triggers" -- .github/workflows/README.md` exits 1; `git grep -n -F -e "which serves a merge queue on" -- .github/workflows/README.md` prints exactly one line whose text also contains `merge_group` (AC-4).
- [x] [P1-T6] Write the required-context mapping evidence `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/other/required-context-map.<timestamp>.md`.
  Commands: `git grep -n -e "uses:" -- .github/workflows/ci.yml`; `git grep -n -e "name:" -- .github/workflows/_quality-checks.yml .github/workflows/_security-scan.yml .github/workflows/_docs-validation.yml .github/workflows/_build-check.yml .github/workflows/_poshqc.yml .github/workflows/_shell-coverage.yml .github/workflows/_drm-copilot-extension-tests.yml .github/workflows/_root-typescript-tests.yml .github/workflows/_npm-audit-gate.yml`.
  Derivation: read the eleven `context` values from `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/protect-main.current.2026-10-16.json` (`:47`, `:51`, `:55`, `:59`, `:63`, `:67`, `:71`, `:75`, `:79`, `:83`, `:87`); split each at ` / ` into the caller job id and the job display name; locate the caller job in the first output and the display name (with matrix value when present) in the second.
  Acceptance: `EXIT_CODE: 0` for both commands, recorded with `Command:`; the artifact has one row per snapshot context (11 rows) naming the context, the `ci.yml` caller job id and line, the reusable workflow file, the job `name:` line, and the matrix value when present; it records `UNMAPPED=0` and `CI_TRIGGERS_MERGE_GROUP=true` (from P1-T3) (AC-3). Any unmapped context records `UNMAPPED=<n>` and fails the task.
- [x] [P1-T7] Commit and push Phase 1: `.github/workflows/ci.yml`, `.github/workflows/README.md`, `tests/scripts/workflows/CiWorkflow.Tests.ps1`, and the feature-folder evidence and plan state.
  Commands: `git add .github/workflows/ci.yml .github/workflows/README.md tests/scripts/workflows/CiWorkflow.Tests.ps1 docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/ docs/features/active/2026-10-16-ci-merge-queue-for-main-952/plan.2026-10-16T00-15.md`; `git commit -m "fix(952): trigger CI on merge_group and assert the trigger"`; `git push origin bug/ci-merge-queue-for-main-952`.
  Acceptance: `git status --porcelain -- .github/workflows/ci.yml .github/workflows/README.md tests/scripts/workflows/CiWorkflow.Tests.ps1 docs/features/active/2026-10-16-ci-merge-queue-for-main-952/` prints nothing, and `git rev-parse HEAD` equals `git rev-parse origin/bug/ci-merge-queue-for-main-952`. No force-push.

### Phase 2 — Merge-Gate Regression Tests (fail first)

No task in this phase runs a gate that expects a passing result; `t-claude-hooks` and `t-codex-hooks` stay red from P2-T4 and P2-T7 until Phase 3.

- [x] [P2-T1] Create `tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1` per Appendix B (36 `It` cases).
  Acceptance: `git add tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1` succeeds; `git grep -c -e "^" -- tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1` prints a count at or below 500; `git grep -c -F -e "baseline mock interception probe" -- tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1` prints a count of 1; `git grep -n -E -e "New-TemporaryFile|TestDrive|Start-Process|Start-Sleep" -- tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1` exits 1.
- [x] [P2-T2] Edit `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1:37-41`: replace the `It 'allows gh pr merge without --merge (e.g., --squash)'` block with the block of Appendix F.11.
  Acceptance: `git grep -n -F -e "allows gh pr merge without --merge" -- tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` exits 1 (no match); `git grep -n -F -e "denies gh pr merge --squash without a checkpoint" -- tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` prints exactly one line; `git grep -c -e "^" -- tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` prints a count at or below 500.
- [x] [P2-T3] Edit `tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1:83`: set `$script:Line433Text` to the exact Claude deny text of Appendix F.1 (variable name unchanged; no other line changes).
  Acceptance: `git grep -n -F -e "a pull-request merge or merge-queue enqueue" -- tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1` prints exactly one line numbered 83; `git grep -n -F -e "gh pr merge --merge requires" -- tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1` exits 1.
- [x] [P2-T4] [expect-fail] Run the Claude hook test folder before any hook change and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/claude-merge-gate-before.<timestamp>.md`.
  Command: `mcp__drm-copilot__run_poshqc_test` with `scan_folders` = `["tests/scripts/claude-hooks"]` (key `t-claude-hooks`).
  Acceptance (P0 `t-claude-hooks` GREEN): the call raised; the artifact records the error text, `EXIT_CODE: 1`, `ExpectedExitCode: 1`, and `RowAttribution:` listing the 27 Appendix B cases marked `pre: fail` and the nine marked `pre: pass`, each with its reason (scope filter `.claude/hooks/enforce-epic-merge-gate.ps1:343-356` requires `--merge`; reader `:131-142` reads only an all-digit operand or a `--merge` value; deny text `:415`; `Test-EpicMergeGateCommandInScope` absent, shown by `git grep -n -F -e "function Test-EpicMergeGateCommandInScope" -- .claude/hooks` exiting 1, recorded), plus the two changed pinned rows `denies gh pr merge --squash without a checkpoint (issue #952 method-agnostic scope)` (fails: `:343-356` allows `--squash`) and `keeps the existing fall-through text for a bare merge even with a valid record present` (`enforce-epic-merge-gate.Authorization.Tests.ps1:142`; fails: `:415` still carries the old text). A returned call fails the task and halts execution. Acceptance (P0 `t-claude-hooks` RED): write `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/fail-before-exception.claude-merge-gate.<timestamp>.md` with `WhyFailingRunImpossible:` and the same `RowAttribution:`. CI jobs relied on later: `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)`.
- [x] [P2-T5] Create `tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1` per Appendix C (34 `It` cases).
  Acceptance: `git add tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1` succeeds; `git grep -c -e "^" -- tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1` prints a count at or below 500; `git grep -c -F -e "baseline mock interception probe" -- tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1` prints a count of 1; `git grep -n -E -e "New-TemporaryFile|TestDrive|Start-Process|Start-Sleep" -- tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1` exits 1.
- [x] [P2-T6] Edit `tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1:79`: set `$script:CodexDenyText` to the exact Codex deny text of Appendix F.6 (no other line changes).
  Acceptance: `git grep -n -F -e "a pull-request merge or merge-queue enqueue" -- tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1` prints exactly one line numbered 79; `git grep -n -F -e "gh pr merge --merge requires" -- tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1` exits 1.
- [x] [P2-T7] [expect-fail] Run the Codex hook test folder before any hook change and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/codex-merge-gate-before.<timestamp>.md`.
  Command: `mcp__drm-copilot__run_poshqc_test` with `scan_folders` = `["tests/scripts/codex-hooks"]` (key `t-codex-hooks`).
  Acceptance (P0 `t-codex-hooks` GREEN): the call raised; the artifact records the error text, `EXIT_CODE: 1`, `ExpectedExitCode: 1`, and `RowAttribution:` listing the 25 Appendix C cases marked `pre: fail` and the nine marked `pre: pass` with their reasons (scope filter `.codex/hooks/enforce-epic-merge-gate.ps1:144-157`; reader `:64-75`; deny text `:191`), plus the changed pinned row `keeps the existing deny text for a bare merge even with a valid record present` (`enforce-epic-merge-gate-authorization.Tests.ps1:123`; fails: `:191` still carries the old text). A returned call fails the task and halts execution. Acceptance (P0 `t-codex-hooks` RED): write `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/fail-before-exception.codex-merge-gate.<timestamp>.md` with `WhyFailingRunImpossible:` and the same `RowAttribution:`. CI jobs relied on later: `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)`.
- [x] [P2-T8] Commit and push Phase 2 (`tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1`, `tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1`, and the three edited merge-gate suites); failing tests are committed deliberately and Phase 3 makes them pass. No CI runs on this push: `ci.yml` runs on `push` only for `main` and `development` and no PR exists yet.
  Commands: `git add tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1 tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/ docs/features/active/2026-10-16-ci-merge-queue-for-main-952/plan.2026-10-16T00-15.md`; `git commit -m "test(952): add failing merge-queue scope and selector cases"`; `git push origin bug/ci-merge-queue-for-main-952`.
  Acceptance: `git status --porcelain -- tests/scripts/claude-hooks tests/scripts/codex-hooks docs/features/active/2026-10-16-ci-merge-queue-for-main-952/` prints nothing, and `git rev-parse HEAD` equals `git rev-parse origin/bug/ci-merge-queue-for-main-952`. No force-push.

### Phase 3 — Merge-Gate Implementation (both runtimes)

Test gates in this phase run only after both runtimes, all four bundle mirrors and both manifests are updated (P3-T16 onward), because `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1:183-191` and `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1:17-29` read the bundle mirrors.

- [x] [P3-T1] Re-check `origin/main` for concurrent changes to the merge-gate files and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/other/concurrency-recheck.<timestamp>.md`.
  Commands: `git fetch origin`; `git log --oneline HEAD..origin/main -- .claude/hooks/enforce-epic-merge-gate.ps1 .codex/hooks/enforce-epic-merge-gate.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1 extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`.
  Acceptance: `EXIT_CODE: 0` for both; an empty `git log` output records `CONCURRENT_CHANGES=0` and execution continues. A non-empty output records the lines, fails the task, and halts execution for the caller before any hook edit. The executor does not merge, rebase or force-push: the orchestrator merges `origin/main` into this branch (no rebase; both changes are kept), re-runs ORCH-1, obtains a re-derivation delta for the Phase 3 line citations the merge moved (`## Conventions`, origin/main merges), and resumes execution at this task.
- [x] [P3-T2] Create `.claude/hooks/enforce-epic-merge-gate-command.ps1` with the content of Appendix E.
  Acceptance: `git add .claude/hooks/enforce-epic-merge-gate-command.ps1` succeeds; `git grep -c -E -e "^function " -- .claude/hooks/enforce-epic-merge-gate-command.ps1` prints a count of 6; `git grep -n -E -e "^[[:space:]]*[.] " -e "Import-Module" -- .claude/hooks/enforce-epic-merge-gate-command.ps1` exits 1 (the helper dot-sources and imports nothing); `git grep -c -e "^" -- .claude/hooks/enforce-epic-merge-gate-command.ps1` prints a count at or below 500.
- [x] [P3-T3] Edit `.claude/hooks/enforce-epic-merge-gate.ps1:415`: replace the deny-reason string literal with the exact Claude text of Appendix F.1.
  Acceptance: `git grep -n -F -e "gh pr merge --merge requires" -- .claude/hooks/enforce-epic-merge-gate.ps1` exits 1, and `git grep -c -F -e "a pull-request merge or merge-queue enqueue" -- .claude/hooks/enforce-epic-merge-gate.ps1` prints a count of 1.
- [x] [P3-T4] Edit `.claude/hooks/enforce-epic-merge-gate.ps1:334-356`: replace the scope-filter comment and code (from `    # Only a gh pr merge invocation carrying --merge is in scope` through the closing `    }` of `if (-not $isMergeInvocation -or -not $hasMergeFlag)`) with the five lines of Appendix F.2. Line `:358` (`$commandPrNumber = ...`) is unchanged.
  Acceptance: `git grep -n -F -e "hasMergeFlag" -- .claude/hooks/enforce-epic-merge-gate.ps1` exits 1, and `git grep -c -F -e "Test-EpicMergeGateCommandInScope -CommandText" -- .claude/hooks/enforce-epic-merge-gate.ps1` prints a count of 1.
- [x] [P3-T5] Edit `.claude/hooks/enforce-epic-merge-gate.ps1` `Get-EpicMergeGateCommandPrNumber`: first replace the function body `:131-142` with the single line of Appendix F.3(b), then the `.DESCRIPTION` body `:104-118` with Appendix F.3(a). The function name, parameters, and `[OutputType([int])]` are unchanged.
  Acceptance: `git grep -n -F -e "Get-CommandLineFlagValue" -- .claude/hooks/enforce-epic-merge-gate.ps1` exits 1, and `git grep -c -F -e "return Get-EpicMergeGateSelectorPrNumber -CommandText" -- .claude/hooks/enforce-epic-merge-gate.ps1` prints a count of 1.
- [x] [P3-T6] Edit `.claude/hooks/enforce-epic-merge-gate.ps1`: insert the two lines of Appendix F.4 immediately after `:72` (the guarded dot-source of `enforce-epic-merge-gate-resolution.ps1`).
  Acceptance: `git grep -n -F -e "Add-HookDependencyFailure -Name 'enforce-epic-merge-gate-command.ps1'" -- .claude/hooks/enforce-epic-merge-gate.ps1` prints exactly one line, numbered 74, whose text begins `try { . (Join-Path` (the dot-source sits in its own guarded `try`).
- [x] [P3-T7] Edit the `.claude/hooks/enforce-epic-merge-gate.ps1` header comment: replace `:34` with Appendix F.5(c), `:7-8` with Appendix F.5(b), and `:3` with Appendix F.5(a), in that order.
  Acceptance: `git grep -n -F -e "is out of scope for this gate" -- .claude/hooks/enforce-epic-merge-gate.ps1` exits 1; `git grep -n -F -e "Regex-matches gh pr merge" -- .claude/hooks/enforce-epic-merge-gate.ps1` exits 1; `git grep -c -F -e "only a pure --disable-auto is out of scope" -- .claude/hooks/enforce-epic-merge-gate.ps1` prints a count of 1 (AC-11 static part).
- [x] [P3-T8] Create `.codex/hooks/enforce-epic-merge-gate-command.ps1` with the Write tool, using the exact text of `.claude/hooks/enforce-epic-merge-gate-command.ps1` as read with the Read tool, and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/other/mirror-sync-helper.<timestamp>.md`.
  Commands: `git add .codex/hooks/enforce-epic-merge-gate-command.ps1`; `git hash-object .claude/hooks/enforce-epic-merge-gate-command.ps1 .codex/hooks/enforce-epic-merge-gate-command.ps1`.
  Acceptance: the hash command prints two identical hashes; the artifact records both and `Output Summary: PAIR_EQUAL=true helper-claude-codex`. Unequal hashes: rewrite the file and repeat the task.
- [x] [P3-T9] Edit `.codex/hooks/enforce-epic-merge-gate.ps1:191`: replace the `permissionDecisionReason` string literal with the exact Codex text of Appendix F.6.
  Acceptance: `git grep -n -F -e "gh pr merge --merge requires" -- .codex/hooks/enforce-epic-merge-gate.ps1` exits 1, and `git grep -c -F -e "a pull-request merge or merge-queue enqueue" -- .codex/hooks/enforce-epic-merge-gate.ps1` prints a count of 1.
- [x] [P3-T10] Edit `.codex/hooks/enforce-epic-merge-gate.ps1:139-157`: replace the scope-filter comment and code (from `    # Both legs are read structurally` through the closing `    }` of `if (-not $isMergeInvocation -or -not $hasMergeFlag)`) with the five lines of Appendix F.7.
  Acceptance: `git grep -n -F -e "hasMergeFlag" -- .codex/hooks/enforce-epic-merge-gate.ps1` exits 1, and `git grep -c -F -e "Test-EpicMergeGateCommandInScope -CommandText" -- .codex/hooks/enforce-epic-merge-gate.ps1` prints a count of 1.
- [x] [P3-T11] Edit `.codex/hooks/enforce-epic-merge-gate.ps1` `Get-CodexMergeCommandPrNumber`: first replace the function body `:64-75` with the single line of Appendix F.8(b), then the `.DESCRIPTION` body `:48-56` with Appendix F.8(a).
  Acceptance: `git grep -n -F -e "Get-CommandLineFlagValue" -- .codex/hooks/enforce-epic-merge-gate.ps1` exits 1, and `git grep -c -F -e "return Get-EpicMergeGateSelectorPrNumber -CommandText" -- .codex/hooks/enforce-epic-merge-gate.ps1` prints a count of 1.
- [x] [P3-T12] Edit `.codex/hooks/enforce-epic-merge-gate.ps1`: insert the three lines of Appendix F.9 immediately after `:13` (the guarded dot-source of `hook-command-invocation.ps1`).
  Acceptance: `git grep -n -F -e "Add-HookDependencyFailure -Name 'enforce-epic-merge-gate-command.ps1'" -- .codex/hooks/enforce-epic-merge-gate.ps1` prints exactly one line, numbered 16, whose text begins `try { . (Join-Path`.
- [x] [P3-T13] Edit `.codex/hooks/enforce-epic-merge-gate.ps1:1-4` (the comment-based help block) to the exact text of Appendix F.10.
  Acceptance: `git grep -c -F -e "only a pure --disable-auto is out of scope" -- .codex/hooks/enforce-epic-merge-gate.ps1` prints a count of 1 (AC-11 static part).
- [x] [P3-T14] Copy the four hook files to their bundle mirrors by the mirror mechanism and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/other/mirror-sync-hooks.<timestamp>.md`.
  Commands: `git add .claude/hooks/enforce-epic-merge-gate.ps1 .claude/hooks/enforce-epic-merge-gate-command.ps1 .codex/hooks/enforce-epic-merge-gate.ps1 .codex/hooks/enforce-epic-merge-gate-command.ps1`; `git checkout-index -f --prefix=extensions/drm-copilot/resources/claude-customizations/ -- .claude/hooks/enforce-epic-merge-gate.ps1 .claude/hooks/enforce-epic-merge-gate-command.ps1`; `git checkout-index -f --prefix=extensions/drm-copilot/resources/codex-and-agents-customizations/ -- .codex/hooks/enforce-epic-merge-gate.ps1 .codex/hooks/enforce-epic-merge-gate-command.ps1`; `git hash-object` over the eight paths (each source followed by its mirror).
  Acceptance: `EXIT_CODE: 0` for each command; the hash output shows four equal pairs; the artifact records `Output Summary: PAIRS_EQUAL=4/4 hooks`.
- [x] [P3-T15] Add the helper paths to the pack manifests: in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` insert the line `    ".claude/hooks/enforce-epic-merge-gate-command.ps1",` immediately after the `.claude/hooks/enforce-epic-merge-gate-resolution.ps1` entry (`:32`); in `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` insert `    ".codex/hooks/enforce-epic-merge-gate-command.ps1",` immediately before the `.codex/hooks/enforce-epic-merge-gate.ps1` entry (`:36`).
  Acceptance: `git grep -c -F -e "enforce-epic-merge-gate-command.ps1" -- extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` prints a count of 1, and the same command on `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` prints a count of 1. Both files still parse as JSON, which P3-T19 verifies (the manifest-completeness modules load every `pack-manifests/*.json` file).
- [x] [P3-T16] Run the Claude hook test folder after the Phase 3 edits and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/claude-merge-gate-after.<timestamp>.md`.
  Command: `mcp__drm-copilot__run_poshqc_test` with `scan_folders` = `["tests/scripts/claude-hooks"]`.
  Acceptance (P0 `t-claude-hooks` GREEN): the call returned. A raised call fails the task; fix the Phase 3 code (never a test expectation of Appendix B or F.11), re-copy any changed mirror, and repeat. (P0 RED): disposition recorded with `LOCAL-NONDISCRIMINATING (baseline RED)`. Per-row results for AC-6 to AC-8, AC-10 and AC-11 come from ORCH-4 and ORCH-5.
- [x] [P3-T17] Run the Codex hook test folder and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/codex-merge-gate-after.<timestamp>.md`.
  Command: `mcp__drm-copilot__run_poshqc_test` with `scan_folders` = `["tests/scripts/codex-hooks"]`.
  Acceptance (P0 `t-codex-hooks` GREEN): the call returned (this folder includes the mirror byte-identity rows of `codex-epic-runtime-contracts.Tests.ps1`). A raised call fails the task; fix and repeat. (P0 RED): disposition recorded with `LOCAL-NONDISCRIMINATING (baseline RED)`. Per-row results for AC-9 to AC-11 come from ORCH-4 and ORCH-5.
- [x] [P3-T18] Run the Claude runtime test folder and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/claude-runtime-after-gate.<timestamp>.md`.
  Command: `mcp__drm-copilot__run_poshqc_test` with `scan_folders` = `["tests/scripts/claude-runtime"]`.
  Acceptance (P0 `t-claude-runtime` GREEN): the call returned (the folder holds `hook-dependency-guard-completeness.Tests.ps1`, the AC-5 guard). A raised call fails the task; fix and repeat. (P0 RED): disposition recorded with `LOCAL-NONDISCRIMINATING (baseline RED)`. AC-5 per-row result comes from ORCH-4 (job `poshqc / PowerShell QC`).
- [x] [P3-T19] Run the push-down resource and manifest tests and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/pushdown-after-gate.<timestamp>.md`.
  Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py -q`
  Acceptance: `EXIT_CODE: 0`; the summary line recorded verbatim contains `passed` and neither `failed` nor `error` (AC-20 hook portion; also proves both manifests parse).
- [x] [P3-T20] Record the line counts of the four hook production files into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/other/line-counts-gate.<timestamp>.md`.
  Command: `git grep -c -e "^" -- .claude/hooks/enforce-epic-merge-gate.ps1 .claude/hooks/enforce-epic-merge-gate-command.ps1 .codex/hooks/enforce-epic-merge-gate.ps1 .codex/hooks/enforce-epic-merge-gate-command.ps1`
  Acceptance: `EXIT_CODE: 0`; four counts recorded, each at or below 500; the `.claude/hooks/enforce-epic-merge-gate.ps1` count is below 472 and the `.codex/hooks/enforce-epic-merge-gate.ps1` count is below 385 (the P0-T7 values).
- [x] [P3-T21] Commit and push Phase 3: the four hook files, their four bundle mirrors, and both `pack-manifests/core.json` files.
  Commands: `git add .claude/hooks/enforce-epic-merge-gate.ps1 .claude/hooks/enforce-epic-merge-gate-command.ps1 .codex/hooks/enforce-epic-merge-gate.ps1 .codex/hooks/enforce-epic-merge-gate-command.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-command.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate-command.ps1 extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/ docs/features/active/2026-10-16-ci-merge-queue-for-main-952/plan.2026-10-16T00-15.md`; `git commit -m "fix(952): gate every merge and enqueue spelling on both runtimes"`; `git push origin bug/ci-merge-queue-for-main-952`.
  Acceptance: `git status --porcelain -- .claude/hooks .codex/hooks extensions/drm-copilot/resources docs/features/active/2026-10-16-ci-merge-queue-for-main-952/` prints nothing, and `git rev-parse HEAD` equals `git rev-parse origin/bug/ci-merge-queue-for-main-952`. No force-push.

### Phase 4 — Merge-Confirmation Parser

- [x] [P4-T1] Create `tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1` per Appendix G.2 (13 `It` cases).
  Acceptance: `git add tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1` succeeds; `git grep -n -e "^Set-StrictMode -Version Latest" -- tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1` prints exactly one line numbered 1; `git grep -c -e "^" -- tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1` prints a count at or below 500; `git grep -n -E -e "New-TemporaryFile|TestDrive|Start-Process|Invoke-GhExe" -- tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1` exits 1.
- [x] [P4-T2] Create `tests/scripts/claude-lib/ci-gate/MergeConfirmationParser.Manifest.Tests.ps1` per Appendix G.3 (2 `It` cases), modeled on `tests/scripts/claude-lib/ci-gate/CiGate.Manifest.Tests.ps1:1-39`.
  Acceptance: `git add tests/scripts/claude-lib/ci-gate/MergeConfirmationParser.Manifest.Tests.ps1` succeeds; `git grep -c -F -e ".claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1" -- tests/scripts/claude-lib/ci-gate/MergeConfirmationParser.Manifest.Tests.ps1` prints a count of at least 1.
- [x] [P4-T3] [expect-fail] Run the CI-gate test folder before the parser and its manifest entry exist and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/parser-before.<timestamp>.md`.
  Command: `mcp__drm-copilot__run_poshqc_test` with `scan_folders` = `["tests/scripts/claude-lib/ci-gate"]` (key `t-ci-gate`).
  Acceptance (P0 `t-ci-gate` GREEN): the call raised; the artifact records the error text, `EXIT_CODE: 1`, `ExpectedExitCode: 1`, and `RowAttribution:` stating that all 13 Appendix G.2 cases fail (the `BeforeAll` dot-sources `.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1`, which does not exist: Glob of that path returns no file, recorded) and both Appendix G.3 cases fail (`git grep -c -F -e "Invoke-MergeConfirmationParser" -- extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` exits 1, recorded). A returned call fails the task and halts execution. (P0 RED): write `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/fail-before-exception.parser.<timestamp>.md` with `WhyFailingRunImpossible:` and the same `RowAttribution:`. CI job relied on later: `poshqc / PowerShell QC`.
- [x] [P4-T4] Create `.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1` implementing the contract of Appendix G.1.
  Acceptance: `git add .claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1` succeeds; `git grep -n -E -e "Invoke-RestMethod|Invoke-WebRequest|Start-Process|Invoke-GhExe|& gh " -- .claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1` exits 1 (no process, network or gh call); `git grep -c -F -e "Invoke-MergeConfirmationParser: " -- .claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1` prints a count of at least 4 (one per throw class of Appendix G.1); `git grep -c -e "^" -- .claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1` prints a count at or below 500.
- [x] [P4-T5] Copy the parser to its bundle mirror by the mirror mechanism and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/other/mirror-sync-parser.<timestamp>.md`.
  Commands: `git checkout-index -f --prefix=extensions/drm-copilot/resources/claude-customizations/ -- .claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1`; `git hash-object .claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1`.
  Acceptance: two identical hashes; the artifact records `Output Summary: PAIR_EQUAL=true parser`.
- [x] [P4-T6] Edit `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`: insert the line `    ".claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1",` immediately after the `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` entry (`:182`, which shifts to `:183` after P3-T15).
  Acceptance: `git grep -c -F -e "Invoke-MergeConfirmationParser.ps1" -- extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` prints a count of 1; JSON validity is verified by P4-T8.
- [x] [P4-T7] Run the CI-gate test folder after the parser exists and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/parser-after.<timestamp>.md`.
  Command: `mcp__drm-copilot__run_poshqc_test` with `scan_folders` = `["tests/scripts/claude-lib/ci-gate"]`.
  Acceptance (P0 `t-ci-gate` GREEN): the call returned. A raised call fails the task; fix the parser (never an Appendix G.2 expectation), re-copy the mirror, and repeat. (P0 RED): disposition recorded with `LOCAL-NONDISCRIMINATING (baseline RED)`. Per-row results for AC-12 and AC-13 come from ORCH-4 (job `poshqc / PowerShell QC`).
- [x] [P4-T8] Run the Claude push-down resource and manifest tests and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/pushdown-after-parser.<timestamp>.md`.
  Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py -q`
  Acceptance: `EXIT_CODE: 0`; summary line recorded verbatim, containing `passed` and neither `failed` nor `error` (AC-13 and AC-20 parser portion).
- [x] [P4-T9] Commit and push Phase 4: the parser, its bundle mirror, `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, and the two new `tests/scripts/claude-lib/ci-gate/` suites.
  Commands: `git add .claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1 extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1 tests/scripts/claude-lib/ci-gate/MergeConfirmationParser.Manifest.Tests.ps1 docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/ docs/features/active/2026-10-16-ci-merge-queue-for-main-952/plan.2026-10-16T00-15.md`; `git commit -m "feat(952): add the merge-confirmation parser"`; `git push origin bug/ci-merge-queue-for-main-952`.
  Acceptance: `git status --porcelain -- .claude/lib/ci-gate extensions/drm-copilot/resources tests/scripts/claude-lib/ci-gate docs/features/active/2026-10-16-ci-merge-queue-for-main-952/` prints nothing, and `git rev-parse HEAD` equals `git rev-parse origin/bug/ci-merge-queue-for-main-952`. No force-push.

### Phase 5 — Release-Flow Merge Wait

- [x] [P5-T1] Edit `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1` per Appendix H.1, bottom-up: `:338`, then `:168-172`, then the new branch inserted after `:77`, then `:75`.
  Acceptance: `git grep -n -F -e "--delete-branch" -- tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1` exits 1; `git grep -c -F -e "'^api graphql '" -- tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1` prints a count of at least 2; `git grep -c -e "^" -- tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1` prints a count at or below 500.
- [x] [P5-T2] Edit `tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1`: insert the line of Appendix H.2 immediately after `:80` (the `^pr checks ` branch of the post-PR `Invoke-GhExe` mock).
  Acceptance: `git grep -c -F -e "'^api graphql '" -- tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1` prints a count of 1.
- [x] [P5-T3] Create `tests/scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.Tests.ps1` per Appendix H.3 (12 `It` cases).
  Acceptance: `git add tests/scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.Tests.ps1` succeeds; `git grep -n -e "^Set-StrictMode -Version Latest" -- tests/scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.Tests.ps1` prints exactly one line numbered 1; `git grep -c -e "^" -- tests/scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.Tests.ps1` prints a count at or below 500; `git grep -c -F -e "Mock -CommandName Invoke-Sleep" -- tests/scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.Tests.ps1` prints a count of at least 1; `git grep -n -E -e "Start-Sleep|New-TemporaryFile|TestDrive" -- tests/scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.Tests.ps1` exits 1.
- [x] [P5-T4] [expect-fail] Run the dev-tools test folder before the script changes and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/release-flow-before.<timestamp>.md`.
  Command: `mcp__drm-copilot__run_poshqc_test` with `scan_folders` = `["tests/scripts/dev-tools"]` (key `t-dev-tools`).
  Acceptance (P0 `t-dev-tools` GREEN): the call raised; the artifact records the error text, `EXIT_CODE: 1`, `ExpectedExitCode: 1`, and `RowAttribution:` naming the 12 Appendix H.3 cases (fail: `Wait-ForPullRequestMerged` is absent, `git grep -n -F -e "function Wait-ForPullRequestMerged" -- scripts/dev-tools` exits 1, recorded) and the two `Invoke-FullReleaseFlow.Tests.ps1` cases `opens the release PR, waits for checks, merges, pulls main, and invokes tag push` and `stops before checkout, pull, and tag push when merge fails` (fail: `scripts/dev-tools/Invoke-FullReleaseFlow.ps1:403` still passes `--delete-branch`, so the updated mocks do not match), and stating that no `Invoke-FullReleaseFlow.ChecksWait.Tests.ps1`, `Invoke-FullReleaseFlow.CheckHelpers.Tests.ps1` or `Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1` case is expected to fail. A returned call fails the task and halts execution. (P0 RED): write `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/fail-before-exception.release-flow.<timestamp>.md` with `WhyFailingRunImpossible:` and the same `RowAttribution:`. CI job relied on later: `poshqc / PowerShell QC`.
- [x] [P5-T5] Create `scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.ps1` with the exact content of Appendix H.4(c) (comment-based help, the dot-source of the merge-confirmation parser, and `Wait-ForPullRequestMerged`).
  Acceptance: `git add scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.ps1` succeeds; `git grep -c -F -e "function Wait-ForPullRequestMerged" -- scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.ps1` prints a count of 1; `git grep -c -F -e "floor(TimeoutSeconds / PollIntervalSeconds) + 1" -- scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.ps1` prints a count of 1; `git grep -c -F -e "../../.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1" -- scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.ps1` prints a count of 1; `git grep -n -E -e "Start-Sleep|Invoke-RestMethod|Invoke-WebRequest|& gh " -- scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.ps1` exits 1 (every wait and gh call goes through the `Invoke-Sleep` and `Invoke-GhExe` seams); `git grep -c -e "^" -- scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.ps1` prints a count at or below 500.
- [x] [P5-T6] Edit `scripts/dev-tools/Invoke-FullReleaseFlow.ps1:403-407` (the merge call and its failure branch) to the exact text of Appendix H.4(d).
  Acceptance: `git grep -n -F -e "--delete-branch" -- scripts/dev-tools/Invoke-FullReleaseFlow.ps1` exits 1, and `git grep -c -F -e "Wait-ForPullRequestMerged -PrNumber" -- scripts/dev-tools/Invoke-FullReleaseFlow.ps1` prints a count of 1.
- [x] [P5-T7] Edit `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`: insert the four lines of Appendix H.4(b) (one blank line, then three lines) immediately after `:47` (the dot-source of `Invoke-FullReleaseFlow.CheckHelpers.ps1`), so the existing blank line `:48` still separates them from `function Write-StderrLine`.
  Acceptance: `git grep -c -F -e "Invoke-FullReleaseFlow.MergeWait.ps1" -- scripts/dev-tools/Invoke-FullReleaseFlow.ps1` prints a count of 1 (the literal "Invoke-FullReleaseFlow.MergeWait.ps1" is absent from the script before this task), and `git grep -n -F -e "Invoke-FullReleaseFlow.CheckHelpers.ps1')" -- scripts/dev-tools/Invoke-FullReleaseFlow.ps1` prints exactly one line numbered 47.
- [x] [P5-T8] Edit the `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` header `.DESCRIPTION` step 4 (`:15-16`) to the exact text of Appendix H.4(a), then run the release-flow all-checks contract.
  Command: `poetry run pytest tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py -q -k test_release_flow_waits_on_every_check_without_required_wording`
  Acceptance: `git grep -c -F -e "waits until the merge is confirmed" -- scripts/dev-tools/Invoke-FullReleaseFlow.ps1` prints a count of 1; the pytest command exits 0 and its summary line contains `1 passed` (the script still contains "every GitHub check on the pull request head" and neither `--required` nor "required check", `tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py:251-271`).
- [x] [P5-T9] Run the dev-tools test folder after the change and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/release-flow-after.<timestamp>.md`.
  Command: `mcp__drm-copilot__run_poshqc_test` with `scan_folders` = `["tests/scripts/dev-tools"]`.
  Acceptance (P0 `t-dev-tools` GREEN): the call returned. A raised call fails the task; fix the script (never an Appendix H.3 expectation) and repeat. (P0 RED): disposition recorded with `LOCAL-NONDISCRIMINATING (baseline RED)`. Per-row results for AC-14 and AC-15 come from ORCH-4 (job `poshqc / PowerShell QC`).
- [x] [P5-T10] Record the release-flow line counts into `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/other/line-counts-release.<timestamp>.md`.
  Command: `git grep -c -e "^" -- scripts/dev-tools/Invoke-FullReleaseFlow.ps1 scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.ps1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.Tests.ps1`
  Acceptance: `EXIT_CODE: 0`; five counts recorded, each at or below 500; the `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` count is recorded against its projection of 446 (435 at P0-T7 plus 11). A count above 500 for any of the five fails the task and halts execution for the caller.
- [x] [P5-T11] Commit and push Phase 5: `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`, `scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.ps1` and the three `tests/scripts/dev-tools/Invoke-FullReleaseFlow*.Tests.ps1` files this phase changed or created.
  Commands: `git add scripts/dev-tools/Invoke-FullReleaseFlow.ps1 scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.ps1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.Tests.ps1 docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/ docs/features/active/2026-10-16-ci-merge-queue-for-main-952/plan.2026-10-16T00-15.md`; `git commit -m "fix(952): wait for a confirmed merge in the release flow"`; `git push origin bug/ci-merge-queue-for-main-952`.
  Acceptance: `git status --porcelain -- scripts/dev-tools tests/scripts/dev-tools docs/features/active/2026-10-16-ci-merge-queue-for-main-952/` prints nothing, and `git rev-parse HEAD` equals `git rev-parse origin/bug/ci-merge-queue-for-main-952`. No force-push.

### Phase 6 — Queue-Aware Merge Procedures

Each mirror task in this phase stages its source first (`git add <source>`) and then runs `git checkout-index -f --prefix=<bundle>/ -- <source>` per the mirror mechanism, appending the `git hash-object <source> <mirror>` result to `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/other/mirror-sync-procedures.<timestamp>.md` (one artifact for the phase, stamped at its first write).

- [x] [P6-T1] Create `tests/scripts/dev_tools/merge_queue_documentation_expectations.py` with the exact content of Appendix I.1.
  Acceptance: `git add tests/scripts/dev_tools/merge_queue_documentation_expectations.py` succeeds; `poetry run ruff check tests/scripts/dev_tools/merge_queue_documentation_expectations.py` exits 0 and prints `All checks passed!`; `git grep -c -F -e "MERGE_QUEUE_MIRROR_PAIRS" -- tests/scripts/dev_tools/merge_queue_documentation_expectations.py` prints a count of 1. The pin and pair counts (12 and 5) are verified by the P6-T3 summary line.
- [x] [P6-T2] Edit `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py` per Appendix I.2: extend the mirror test parametrization (`:414-415`), add the parametrized test before the mirror test (`:412`), and add the import after `:22` (before the `tests.scripts.dev_tools.parallel_orchestrator_surface_test_support` import at `:23`, which keeps the isort order), in that order.
  Acceptance: `git grep -c -F -e "def test_merge_procedure_records_merge_only_after_confirmation" -- tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py` prints a count of 1; `git grep -c -e "^" -- tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py` prints a count at or below 500; `poetry run ruff check tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py tests/scripts/dev_tools/merge_queue_documentation_expectations.py` exits 0 and prints `All checks passed!` (this covers import order `I001` and line length `E501` for both files).
- [x] [P6-T3] [expect-fail] Run the contract module before any procedure edit and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/procedure-pins-before.<timestamp>.md`.
  Command: `poetry run pytest tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py -q`
  Acceptance: the artifact records `EXIT_CODE: 1`, `ExpectedExitCode: 1`, and the summary line `12 failed, 38 passed` (followed by the duration; 38 = `CONTRACT_BASE_PASSED` 33 + the five new mirror pairs, already byte-identical per P0-T6). The 12 failing node IDs are the 12 `test_merge_procedure_records_merge_only_after_confirmation[...]` ids of Appendix I.1, including `claude-cleanup-merged-worktrees` (fails: `.claude/skills/cleanup-merged-worktrees/SKILL.md:206-208` states the strict requirement with no queue case). Any other summary fails the task.
- [x] [P6-T4] Edit `.claude/skills/parallel-orchestrate/SKILL.md:470` per Appendix D.1(c) (second replacement).
  Acceptance: `git grep -c -F -e "merge confirmation whose" -- .claude/skills/parallel-orchestrate/SKILL.md` prints a count of 1 (the token is absent before this task).
- [x] [P6-T5] Edit `.claude/skills/parallel-orchestrate/SKILL.md:450` per Appendix D.1(c) (first replacement).
  Acceptance: `git grep -c -F -e "merge confirmation whose" -- .claude/skills/parallel-orchestrate/SKILL.md` prints a count of 2, and `git grep -c -F -e "the parent runs the two commands" -- .claude/skills/parallel-orchestrate/SKILL.md` prints a count of 1.
- [x] [P6-T6] Edit `.claude/skills/parallel-orchestrate/SKILL.md:436-439` (the strict up-to-date pacing paragraph) per Appendix D.1(b).
  Acceptance: `git grep -c -F -e "the queue replaces that" -- .claude/skills/parallel-orchestrate/SKILL.md` prints a count of 1.
- [x] [P6-T7] Edit `.claude/skills/parallel-orchestrate/SKILL.md:397` per Appendix D.1(d), then `:391-393` per Appendix D.1(a).
  Acceptance: `git grep -c -F -e "Invoke-MergeConfirmationParser.ps1 -PrJson" -- .claude/skills/parallel-orchestrate/SKILL.md` prints a count of 1; `git grep -c -F -e "denies every merge or merge-queue enqueue action" -- .claude/skills/parallel-orchestrate/SKILL.md` prints a count of 1; `poetry run pytest tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py -q` exits 0 with a summary line containing `passed` and neither `failed` nor `error` (its pin "Execute `gh pr merge --merge <PR>`" from `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py:229` still holds).
- [x] [P6-T8] Mirror `.claude/skills/parallel-orchestrate/SKILL.md` to `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md`.
  Commands: `git add .claude/skills/parallel-orchestrate/SKILL.md`; `git checkout-index -f --prefix=extensions/drm-copilot/resources/claude-customizations/ -- .claude/skills/parallel-orchestrate/SKILL.md`; `git hash-object .claude/skills/parallel-orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md`.
  Acceptance: two identical hashes, appended with `PAIR_EQUAL=true claude-parallel-orchestrate`.
- [x] [P6-T9] Edit `.claude/agents/parallel-orchestrator.md`: first `:288-289` (Completion Requirements item 1) per Appendix D.2, then insert the line `  - "Bash(pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1*)"` immediately after `:24` (`  - "Bash(pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1*)"`), because `tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py` (`test_every_prescribed_command_invocation_has_a_persona_bash_grant`, `:86-110`) requires every command prescribed by Appendix D.1(a) to be covered by a persona `Bash(...)` grant. The bundle mirror is made byte-identical by P6-T10, which copies the file after both edits.
  Acceptance: `git grep -c -F -e "value is recorded only after the merge is confirmed by polling" -- .claude/agents/parallel-orchestrator.md` prints a count of 1, and `git grep -c -F -e "ci-gate/Invoke-MergeConfirmationParser.ps1*)" -- .claude/agents/parallel-orchestrator.md` prints a count of 1 (the literal is absent before this task).
- [x] [P6-T10] Mirror `.claude/agents/parallel-orchestrator.md` to `extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-orchestrator.md`.
  Commands: `git add .claude/agents/parallel-orchestrator.md`; `git checkout-index -f --prefix=extensions/drm-copilot/resources/claude-customizations/ -- .claude/agents/parallel-orchestrator.md`; `git hash-object .claude/agents/parallel-orchestrator.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-orchestrator.md`.
  Acceptance: two identical hashes, appended with `PAIR_EQUAL=true claude-parallel-orchestrator-agent`.
- [x] [P6-T11] Edit `.claude/skills/orchestrate/SKILL.md:366` (PR Creation Gate condition 7) per Appendix D.3(b).
  Acceptance: `git grep -c -F -e "recorded only after the merge is confirmed by polling and ancestry check (S9 step 6)" -- .claude/skills/orchestrate/SKILL.md` prints a count of 1.
- [x] [P6-T12] Edit `.claude/skills/orchestrate/SKILL.md:301` (S9 step 6) per Appendix D.3(a).
  Acceptance: `git grep -c -F -e "Merge confirmation (issue #952)" -- .claude/skills/orchestrate/SKILL.md` prints a count of 1, and `git diff -U0 HEAD -- .claude/skills/orchestrate/SKILL.md` shows the line 301 change as one removed and one added line whose added text begins with the removed text (existing step 6 text kept; the new text is appended).
- [x] [P6-T13] Mirror `.claude/skills/orchestrate/SKILL.md` to `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`.
  Commands: `git add .claude/skills/orchestrate/SKILL.md`; `git checkout-index -f --prefix=extensions/drm-copilot/resources/claude-customizations/ -- .claude/skills/orchestrate/SKILL.md`; `git hash-object .claude/skills/orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`.
  Acceptance: two identical hashes, appended with `PAIR_EQUAL=true claude-orchestrate`.
- [x] [P6-T14] Edit `.claude/skills/epic-orchestrate/SKILL.md:356` (second line of Completion Requirements item 2) per Appendix D.4(c).
  Acceptance: `git grep -c -F -e "recorded, and it is recorded only after the merge is confirmed" -- .claude/skills/epic-orchestrate/SKILL.md` prints a count of 1.
- [x] [P6-T15] Edit `.claude/skills/epic-orchestrate/SKILL.md:141` per Appendix D.4(b).
  Acceptance: `git grep -c -F -e "The child records" -- .claude/skills/epic-orchestrate/SKILL.md` prints a count of 1.
- [x] [P6-T16] Edit `.claude/skills/epic-orchestrate/SKILL.md:129` per Appendix D.4(a).
  Acceptance: `git grep -c -F -e "Under a merge queue" -- .claude/skills/epic-orchestrate/SKILL.md` prints a count of 1, and `git grep -c -F -e "ci-gate/Invoke-MergeConfirmationParser.ps1 -PrJson" -- .claude/skills/epic-orchestrate/SKILL.md` prints a count of 1 (the inline invocation is on one line, so the permission-seam parser reads it as one span).
- [x] [P6-T17] Mirror `.claude/skills/epic-orchestrate/SKILL.md` to `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md`.
  Commands: `git add .claude/skills/epic-orchestrate/SKILL.md`; `git checkout-index -f --prefix=extensions/drm-copilot/resources/claude-customizations/ -- .claude/skills/epic-orchestrate/SKILL.md`; `git hash-object .claude/skills/epic-orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md`.
  Acceptance: two identical hashes, appended with `PAIR_EQUAL=true claude-epic-orchestrate`.
- [x] [P6-T18] Create `tests/scripts/dev_tools/test_epic_orchestrator_permission_contracts.py` with the exact content of Appendix I.4 (coordinator D10(b)).
  Acceptance: `git add tests/scripts/dev_tools/test_epic_orchestrator_permission_contracts.py` succeeds; `git grep -c -F -e "invocation_has_an_epic_persona_" -- tests/scripts/dev_tools/test_epic_orchestrator_permission_contracts.py` prints a count of 1 (the token is a substring of the test name, chosen so that no executor command text contains the strings the worktree-isolation guard refuses); `poetry run ruff check tests/scripts/dev_tools/test_epic_orchestrator_permission_contracts.py` exits 0 and prints `All checks passed!`; `git grep -n -E -e "tmp_path|tempfile|mkstemp|subprocess" -- tests/scripts/dev_tools/test_epic_orchestrator_permission_contracts.py` exits 1.
- [x] [P6-T19] [expect-fail] Run the new permission test against the pre-edit epic persona and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/epic-permission-before.<timestamp>.md`.
  Commands: `poetry run pytest tests/scripts/dev_tools/test_epic_orchestrator_permission_contracts.py -q`; `git grep -c -F -e "lib/ci-gate/" -- .claude/agents/epic-orchestrator.md`.
  Acceptance: the artifact records `EXIT_CODE: 1`, `ExpectedExitCode: 1`, and the pytest summary line verbatim, which contains `1 failed` and does not contain `passed`; the `git grep` exits 1 with no output (the persona file, whose tools are `.claude/agents/epic-orchestrator.md:5-18`, names no `.claude/lib/ci-gate/` path and so holds no parser grant), recorded. `RowAttribution:` names `test_every_prescribed_pwsh_invocation_has_an_epic_persona_bash_grant` as failing pre-change on the `uncovered` assertion (not on the floor assertion), listing the two uncovered invocations from the `AssertionError` text: `pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1` (`.claude/skills/epic-orchestrate/SKILL.md:127`) and `pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1 -PrJson <snapshot-json> -AsJson` (P6-T16). An exit code of 0, a summary containing `passed`, or a failure on the floor assertion fails the task and halts execution for the caller.
- [x] [P6-T20] Edit `.claude/agents/epic-orchestrator.md`: insert the three lines of Appendix D.5 immediately after `:163` (Completion Requirements item 2). This is the body edit; the tools frontmatter is edited separately by P6-T21, and the body edit runs first (bottom-up).
  Acceptance: `git grep -c -F -e "can return before the" -- .claude/agents/epic-orchestrator.md` prints a count of 1.
- [x] [P6-T21] Edit the `.claude/agents/epic-orchestrator.md` tools frontmatter: insert the two lines of Appendix D.9 immediately after `:16` (`  - "Bash(gh *)"`) and before `:17` (`  - "mcp__drm-copilot__collect_pr_context"`). No other line changes.
  Acceptance: `git grep -c -F -e "File .claude/lib/ci-gate/Invoke-" -- .claude/agents/epic-orchestrator.md` prints a count of 2 (the P6-T19 `git grep` for `lib/ci-gate/` printed nothing before this task); `git grep -n -F -e "ci-gate/Invoke-MergeConfirmationParser.ps1*)" -- .claude/agents/epic-orchestrator.md` prints exactly one line numbered 18.
- [x] [P6-T22] Run the new permission test after the grant edit and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/epic-permission-after.<timestamp>.md`.
  Command: `poetry run pytest tests/scripts/dev_tools/test_epic_orchestrator_permission_contracts.py -q`
  Acceptance: `EXIT_CODE: 0` and the summary line, recorded verbatim, contains `1 passed` and does not contain `failed`.
- [x] [P6-T23] Mirror `.claude/agents/epic-orchestrator.md` to `extensions/drm-copilot/resources/claude-customizations/.claude/agents/epic-orchestrator.md` after both P6-T20 and P6-T21.
  Commands: `git add .claude/agents/epic-orchestrator.md`; `git checkout-index -f --prefix=extensions/drm-copilot/resources/claude-customizations/ -- .claude/agents/epic-orchestrator.md`; `git hash-object .claude/agents/epic-orchestrator.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/epic-orchestrator.md`.
  Acceptance: two identical hashes, appended with `PAIR_EQUAL=true claude-epic-orchestrator-agent`.
- [x] [P6-T24] [expect-fail] Run the frozen epic-surface digest test after both epic files reached their final bytes (skill: P6-T14 to P6-T16; agent: P6-T20 and P6-T21) and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/frozen-digest-before.<timestamp>.md`.
  Command: `poetry run pytest tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py -q -k test_frozen_epic_surface_matches_pinned_baseline_digest`
  Acceptance: the artifact records `EXIT_CODE: 1`, `ExpectedExitCode: 1`, the final summary line verbatim (it contains `2 failed` and does not contain `passed`), and, from the two `AssertionError` lines (`tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py:482-485` prints `expected SHA-256 <pinned>, found <actual>`), the two `found` values as `FOUND_AGENT=<64 hex characters>` for `.claude/agents/epic-orchestrator.md` and `FOUND_SKILL=<64 hex characters>` for `.claude/skills/epic-orchestrate/SKILL.md`. `RowAttribution:` names both parametrized cases and the reason (P6-T14 to P6-T16 changed the skill, P6-T20 and P6-T21 changed the agent; `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py:171-180` still holds the pre-change digests). On this first run, a summary with `1 failed`, with any `passed`, or an exit code of 0 fails the task and halts execution for the caller. A repeat under the frozen-digest clause of `## Restart Rule (Phase 8)` expects `1 failed` and `1 passed` when only one of the two files changed after P6-T25, and records only that file's `found` value.
- [x] [P6-T25] Re-baseline `PINNED_FROZEN_SURFACE_HASHES` in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` per Appendix I.3 and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/frozen-digest-after.<timestamp>.md`.
  Edits (bottom-up): replace the skill digest string (`:178`, currently `b7af3a42d128a140951a07d592067a780429bc9beba0b6ec16afe54c3084b83f`) with the P6-T24 `FOUND_SKILL` value; replace the agent digest string (`:174`, currently `c5b50974afe1718efce7023b2a7e6965d43979de333a84fb4d9fc2192eadd96d`) with the P6-T24 `FOUND_AGENT` value; insert the six comment lines of Appendix I.3 immediately after `:170` (the last line of the `RE-BASELINED by issue #928.` block) and before `:171` (`PINNED_FROZEN_SURFACE_HASHES: tuple[tuple[str, str], ...] = (`). No other line changes.
  Commands: `poetry run pytest tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py -q -k test_frozen_epic_surface_matches_pinned_baseline_digest`; `git grep -n -F -e "c5b50974afe1718efce7023b2a7e6965d43979de333a84fb4d9fc2192eadd96d" -e "b7af3a42d128a140951a07d592067a780429bc9beba0b6ec16afe54c3084b83f" -- tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`; `git grep -c -F -e "RE-BASELINED by issue #952." -- tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`; `poetry run ruff check tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`.
  Acceptance: the pytest command exits 0 and its summary line, recorded verbatim, contains `2 passed` and does not contain `failed`; the first `git grep` exits 1 with no output (both pre-change digests are gone); the second `git grep` prints a count of 1 (the literal `RE-BASELINED by issue #952.` is absent before this task); the ruff command exits 0 and prints `All checks passed!`. The artifact records `FOUND_AGENT` and `FOUND_SKILL` as written into the file.
- [x] [P6-T26] Edit `.claude/skills/cleanup-merged-worktrees/SKILL.md:206-208` (inside step 5, "Wait for merge and verify git-natively", of `## End-to-End Workflow`) per Appendix D.8 (coordinator D10(a)): replace the three lines with the seven lines of Appendix D.8. Lines `:199-205` and `:209-212` are unchanged.
  Acceptance: `git grep -c -F -e "operator and stops. The ruleset on" -- .claude/skills/cleanup-merged-worktrees/SKILL.md` exits 1 with no output (the old opening of `:206` is gone; before this task it prints a count of 1); `git grep -c -F -e "the queue tests the merged" -- .claude/skills/cleanup-merged-worktrees/SKILL.md` prints a count of 1; `git grep -c -F -e "Without a merge queue, the ruleset on" -- .claude/skills/cleanup-merged-worktrees/SKILL.md` prints a count of 1; `git grep -c -F -e "git merge-base --is-ancestor documentationandmemories main" -- .claude/skills/cleanup-merged-worktrees/SKILL.md` prints a count of 1 (the verification sentence after the edit region is intact).
- [x] [P6-T27] Mirror `.claude/skills/cleanup-merged-worktrees/SKILL.md` to `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`.
  Commands: `git add .claude/skills/cleanup-merged-worktrees/SKILL.md`; `git checkout-index -f --prefix=extensions/drm-copilot/resources/claude-customizations/ -- .claude/skills/cleanup-merged-worktrees/SKILL.md`; `git hash-object .claude/skills/cleanup-merged-worktrees/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`.
  Acceptance: two identical hashes, appended with `PAIR_EQUAL=true claude-cleanup-merged-worktrees`.
- [x] [P6-T28] Edit `.agents/skills/epic-orchestrate/SKILL.md:172` (last line of `## Final Integration PR`) per Appendix D.6.
  Acceptance: `git grep -c -F -e "The final merge SHA is recorded" -- .agents/skills/epic-orchestrate/SKILL.md` prints a count of 1.
- [x] [P6-T29] Mirror `.agents/skills/epic-orchestrate/SKILL.md` to `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-orchestrate/SKILL.md`.
  Commands: `git add .agents/skills/epic-orchestrate/SKILL.md`; `git checkout-index -f --prefix=extensions/drm-copilot/resources/codex-and-agents-customizations/ -- .agents/skills/epic-orchestrate/SKILL.md`; `git hash-object .agents/skills/epic-orchestrate/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-orchestrate/SKILL.md`.
  Acceptance: two identical hashes, appended with `PAIR_EQUAL=true agents-epic-orchestrate`.
- [x] [P6-T30] Edit `.codex/agents/epic-orchestrator.toml`: insert the two lines of Appendix D.7 after `:83` and before the closing `'''` (`:84`). No permission entry is added (`## Decisions Recorded by the Planner`, Codex epic persona).
  Acceptance: `git grep -c -F -e "The final merge SHA is recorded only after the merge is confirmed by polling and ancestry check:" -- .codex/agents/epic-orchestrator.toml` prints a count of 1, and `poetry run pytest tests/scripts/dev_tools/test_codex_agent_role_schema.py -q` exits 0 with a summary line containing `passed` and neither `failed` nor `error` (the module parses every `.codex/agents/*.toml` file with `tomllib` at collection, `tests/scripts/dev_tools/test_codex_agent_role_schema.py:106-108`, so a TOML syntax error fails collection).
- [x] [P6-T31] Mirror `.codex/agents/epic-orchestrator.toml` to `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/epic-orchestrator.toml`.
  Commands: `git add .codex/agents/epic-orchestrator.toml`; `git checkout-index -f --prefix=extensions/drm-copilot/resources/codex-and-agents-customizations/ -- .codex/agents/epic-orchestrator.toml`; `git hash-object .codex/agents/epic-orchestrator.toml extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/epic-orchestrator.toml`.
  Acceptance: two identical hashes, appended with `PAIR_EQUAL=true codex-epic-orchestrator-agent`.
- [x] [P6-T32] Run the contract module after all procedure edits and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/procedure-pins-after.<timestamp>.md`.
  Command: `poetry run pytest tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py -q`
  Acceptance: `EXIT_CODE: 0` and the summary line `50 passed` (followed by the duration; 50 = 33 + 12 pins + 5 mirror pairs) recorded verbatim (AC-16 through AC-19, AC-20 procedure portion, and the D10(a) cleanup-skill pin and mirror pair).
- [x] [P6-T33] Run the related Python contract suites and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/regression-testing/procedure-suites-after.<timestamp>.md`.
  Command: `poetry run pytest tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py tests/scripts/dev_tools/test_skill_bundle_contract_repo.py tests/scripts/dev_tools/test_codex_agent_role_schema.py tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py tests/scripts/dev_tools/test_epic_orchestrator_permission_contracts.py -q` (the P0-T12 command plus the new epic permission module; P8-T7 reuses this command).
  Acceptance: `EXIT_CODE: 0`; the summary line recorded verbatim contains `passed` and neither `failed` nor `error` (includes `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py`, which pins "Execute `gh pr merge --merge <PR>`" and, after P6-T25, the re-baselined frozen epic-surface digests; `tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py`, which passes only when the P6-T9 grant covers the Appendix D.1(a) parser invocation; `tests/scripts/dev_tools/test_epic_orchestrator_permission_contracts.py`, which passes only when the P6-T21 grants cover both epic `pwsh` invocations; and `tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py`, whose release-flow case P5-T8 already ran).
- [x] [P6-T34] Commit and push Phase 6: `tests/scripts/dev_tools/merge_queue_documentation_expectations.py`, `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py`, `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`, `tests/scripts/dev_tools/test_epic_orchestrator_permission_contracts.py`, and the eight procedure files with their bundle mirrors.
  Commands: `git add tests/scripts/dev_tools/merge_queue_documentation_expectations.py tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py tests/scripts/dev_tools/test_epic_orchestrator_permission_contracts.py .claude/skills/cleanup-merged-worktrees/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md .claude/skills/parallel-orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md .claude/agents/parallel-orchestrator.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-orchestrator.md .claude/skills/orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md .claude/skills/epic-orchestrate/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md .claude/agents/epic-orchestrator.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/epic-orchestrator.md .agents/skills/epic-orchestrate/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-orchestrate/SKILL.md .codex/agents/epic-orchestrator.toml extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/epic-orchestrator.toml docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/ docs/features/active/2026-10-16-ci-merge-queue-for-main-952/plan.2026-10-16T00-15.md`; `git commit -m "docs(952): confirm merges by polling and ancestry before recording them"`; `git push origin bug/ci-merge-queue-for-main-952`.
  Acceptance: `git status --porcelain -- tests/scripts/dev_tools .claude .agents .codex extensions/drm-copilot/resources docs/features/active/2026-10-16-ci-merge-queue-for-main-952/` prints nothing, and `git rev-parse HEAD` equals `git rev-parse origin/bug/ci-merge-queue-for-main-952`. No force-push.

### Phase 7 — Ruleset Deliverables (not applied)

The semantic comparison of the three payloads with the snapshot (Appendix O.1) is orchestrator-owned (ORCH-2). The tasks below verify concrete tokens only.

- [x] [P7-T1] Create `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/protect-main.merge-queue.apply.json` per Appendix S.1.
  Acceptance: after `git add` of the file, `git grep -c -F -e '"merge_queue"' -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/protect-main.merge-queue.apply.json` prints a count of 1; `git grep -c -F -e '"check_response_timeout_minutes": 60' -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/protect-main.merge-queue.apply.json` prints a count of 1; `git grep -c -F -e '"strict_required_status_checks_policy": true' -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/protect-main.merge-queue.apply.json` prints a count of 1; `git grep -n -F -e '"node_id"' -e '"_links"' -e '"current_user_can_bypass"' -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/protect-main.merge-queue.apply.json` exits 1 (read-only fields omitted).
- [x] [P7-T2] Create `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/protect-main.non-strict.alternative.json` per Appendix S.2.
  Acceptance: after `git add` of the file, `git grep -c -F -e '"strict_required_status_checks_policy": false' -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/protect-main.non-strict.alternative.json` prints a count of 1; `git grep -n -F -e '"merge_queue"' -e '"node_id"' -e '"_links"' -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/protect-main.non-strict.alternative.json` exits 1.
- [x] [P7-T3] Create `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/protect-main.rollback.json` per Appendix S.3.
  Acceptance: after `git add` of the file, `git grep -c -F -e '"strict_required_status_checks_policy": true' -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/protect-main.rollback.json` prints a count of 1; `git grep -n -F -e '"merge_queue"' -e '"node_id"' -e '"_links"' -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/protect-main.rollback.json` exits 1.
- [x] [P7-T4] Create `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/runbook.md` per Appendix S.4.
  Acceptance: `git add docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/runbook.md` succeeds and `git grep -c -e "^## " -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/runbook.md` prints a count of 8.
- [x] [P7-T5] Verify the runbook sections and the three operator statements (coordinator R5) and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/runbook-sections.<timestamp>.md`.
  Command: `git grep -n -F -e "## Preconditions" -e "## Capture and Diff Before Applying" -e "## Apply" -e "## Post-Apply Verification" -e "## Expected Failure on a User-Owned Repository" -e "## Rollback" -e "## Non-Strict Alternative (Separate Operator Decision)" -e "## Admin Merges Skip the Queue" -e "gh api --method PUT repos/drmoisan/drm-copilot/rulesets/15241672 --input" -e "422" -e "gh pr update-branch" -e "This item applies nothing" -e "merge queues for organization-owned repositories" -e "is expected to be rejected" -e "is a separate operator decision" -e "--input protect-main.rollback.json" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/runbook.md`
  Acceptance: `EXIT_CODE: 0`; the output contains at least one line for each of the sixteen patterns, recorded verbatim with `Output Summary: TOKENS_FOUND=16/16` (AC-24). The last five patterns verify the R5 statements of Appendix S.4: (c) the item applies nothing ("This item applies nothing"); (a) the ownership precondition and the expected rejection of the apply payload ("merge queues for organization-owned repositories", "is expected to be rejected"); (b) the fallback, namely the non-strict payload as a separate operator decision ("is a separate operator decision") and the rollback payload ("--input protect-main.rollback.json"). A pattern with no output line fails the task.
- [x] [P7-T6] Write the policy follow-up record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/policy-followups.md` per Appendix P (coordinator R4) and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/other/policy-followups-check.<timestamp>.md`. No file under `.claude/rules/` is edited.
  Commands: `git grep -n -F -e "The gate consults the array only for a" -- .claude/rules/orchestrator-state.md`; `git grep -n -F -e "pull-request state, merge time, and merge commit" -- .claude/rules/parallel-orchestration.md`; `git grep -n -F -e "authorizes a per-item" -e "gh pr merge --merge" -- .claude/rules/parallel-orchestration.md`; `git add docs/features/active/2026-10-16-ci-merge-queue-for-main-952/policy-followups.md`; `git grep -c -F -e "Current text (verbatim):" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/policy-followups.md`; `git status --porcelain -- .claude/rules`.
  Acceptance: the first command prints exactly one line numbered 238 and the second exactly one line numbered 154; the third prints a line numbered 689 whose text contains both `authorizes a per-item` and `gh pr merge --merge`. Each record of the file quotes the full current text of the line printed for it (Appendix P gives the text read at `1195107340f811b565a2ee311e1ad3ce731c5680`; when a printed line number differs after an orchestrator merge of `origin/main`, the record uses the printed number and the text then on that line, and the artifact notes the difference; a command with no output fails the task). The `Current text (verbatim):` count is 3; the porcelain output for `.claude/rules` is empty.
- [x] [P7-T7] Commit and push Phase 7: the four files under `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/` created by P7-T1 to P7-T4 and `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/policy-followups.md` created by P7-T6.
  Commands: `git add docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/protect-main.merge-queue.apply.json docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/protect-main.non-strict.alternative.json docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/protect-main.rollback.json docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/runbook.md docs/features/active/2026-10-16-ci-merge-queue-for-main-952/policy-followups.md docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/ docs/features/active/2026-10-16-ci-merge-queue-for-main-952/plan.2026-10-16T00-15.md`; `git commit -m "docs(952): ship merge-queue ruleset payloads, runbook and policy follow-up record"`; `git push origin bug/ci-merge-queue-for-main-952`.
  Acceptance: `git status --porcelain -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/` prints nothing, and `git rev-parse HEAD` equals `git rev-parse origin/bug/ci-merge-queue-for-main-952`. No force-push.

### Phase 8 — Final QA Loop

P8-T1 through P8-T7 run under the Restart Rule. Every command is unconditional; no task may record `EXIT_CODE: SKIPPED`. Type checking does not apply to PowerShell.

- [x] [P8-T1] Run the PowerShell formatter over F-SET and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/final-ps-format.<timestamp>.md`.
  Commands: `git status --porcelain -- .claude/hooks .codex/hooks .claude/lib/ci-gate scripts/dev-tools tests/scripts/workflows tests/scripts/claude-hooks tests/scripts/codex-hooks tests/scripts/claude-lib/ci-gate tests/scripts/dev-tools` (before; expected empty after the Phase 7 commit); `mcp__drm-copilot__run_poshqc_format` with the nine F-SET folders; the same `git status --porcelain` command (after).
  Acceptance: the call returned and the after-output is empty (the formatter changed nothing). A non-empty after-output is classified path by path: a path listed under `PRE-EXISTING-FORMAT-DRIFT` by P0-T8 and absent from `## Files Written` is restored with `git restore -- <path>` and recorded; a path in `## Files Written` keeps the formatter output, its mirror is re-copied, the files are committed, and the loop restarts at P8-T1; any other path fails the task and halts execution for the caller.
- [x] [P8-T2] Run the analyzer over each F-SET folder (nine calls) and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/final-ps-analyze-<key>.<timestamp>.md` per key.
  Command (nine calls): `mcp__drm-copilot__run_poshqc_analyze` with `scan_folders` = the single folder of the key.
  Acceptance: every key whose P0-T9 baseline is `GREEN` returned. A key whose baseline is `RED` is recorded `LOCAL-NONDISCRIMINATING (baseline RED)`; the CI Analyze step of job `poshqc / PowerShell QC` in `R_final` (ORCH-4 requires that job to conclude `success`) is its gate. A raised call on a `GREEN` key fails the task: fix the finding without adding a suppression attribute and restart the loop.
- [x] [P8-T3] Run the tests of each T-SET folder (six calls) and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/final-ps-test-<key>.<timestamp>.md` per key.
  Command (six calls): `mcp__drm-copilot__run_poshqc_test` with `scan_folders` = the single folder of the key.
  Acceptance: every key whose P0-T10 baseline is `GREEN` returned. A key whose baseline is `RED` is recorded `LOCAL-NONDISCRIMINATING (baseline RED)`. Each artifact states that post-change coverage and per-suite Passed counts are recorded by ORCH-4 to ORCH-6. A raised call on a `GREEN` key fails the task: fix and restart the loop.
- [x] [P8-T4] Run Black in check mode on the four touched Python files and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/final-python-black.<timestamp>.md`.
  Command: `poetry run black --check tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py tests/scripts/dev_tools/merge_queue_documentation_expectations.py tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py tests/scripts/dev_tools/test_epic_orchestrator_permission_contracts.py`
  Acceptance: `EXIT_CODE: 0` and the printed line `4 files would be left unchanged.` recorded. On a non-zero exit, run `poetry run black tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py tests/scripts/dev_tools/merge_queue_documentation_expectations.py tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py tests/scripts/dev_tools/test_epic_orchestrator_permission_contracts.py`, record its `reformatted` line and the `git status --porcelain -- tests/scripts/dev_tools` output, commit, and restart from P8-T1.
- [x] [P8-T5] Run Ruff on the four files and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/final-python-ruff.<timestamp>.md`.
  Command: `poetry run ruff check tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py tests/scripts/dev_tools/merge_queue_documentation_expectations.py tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py tests/scripts/dev_tools/test_epic_orchestrator_permission_contracts.py`
  Acceptance: `EXIT_CODE: 0` and the printed line `All checks passed!` recorded. No suppression is added.
- [x] [P8-T6] Run Pyright on the four files and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/final-python-pyright.<timestamp>.md`.
  Command: `poetry run pyright tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py tests/scripts/dev_tools/merge_queue_documentation_expectations.py tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py tests/scripts/dev_tools/test_epic_orchestrator_permission_contracts.py`
  Acceptance: `EXIT_CODE: 0` and the printed line `0 errors, 0 warnings, 0 informations` recorded.
- [x] [P8-T7] Run the Python contract suites and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/final-python-contract-suites.<timestamp>.md`.
  Command: the P6-T33 command (the P0-T12 modules plus `tests/scripts/dev_tools/test_epic_orchestrator_permission_contracts.py`).
  Acceptance: `EXIT_CODE: 0`; the summary line recorded verbatim contains `passed` and neither `failed` nor `error` (AC-16 through AC-20 regression check, and the D10(a) and D10(b) contracts).
- [x] [P8-T8] Write the loop record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/final-loop-status.<timestamp>.md`.
  Acceptance: the artifact lists each loop pass with the artifact file names of P8-T1 to P8-T7 and their dispositions or exit codes; the last listed pass has an empty P8-T1 after-output, every `GREEN`-baseline call of P8-T2 and P8-T3 returned, and P8-T4 to P8-T7 recorded `EXIT_CODE: 0`.
- [x] [P8-T9] Verify the final mirror hashes and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/final-mirror-hashes.<timestamp>.md`.
  Command: `git hash-object` over the 20 P0-T5 paths followed by `.claude/hooks/enforce-epic-merge-gate-command.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-command.ps1 .codex/hooks/enforce-epic-merge-gate-command.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate-command.ps1 .claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1`.
  Acceptance: `EXIT_CODE: 0`; 26 hashes recorded; `Output Summary:` records `PAIRS_EQUAL=13/13` and `HELPER_RUNTIMES_EQUAL=true` (the `.claude` and `.codex` helper hashes are equal); every one of the ten P0-T6 pairs has a hash different from its P0-T6 value (AC-20, and the D10(a) and D10(b) mirrors).
- [x] [P8-T10] Verify the line counts of every new and modified production and test file and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/final-line-counts.<timestamp>.md`.
  Command: `git grep -c -e "^" -- .claude/hooks/enforce-epic-merge-gate.ps1 .claude/hooks/enforce-epic-merge-gate-command.ps1 .codex/hooks/enforce-epic-merge-gate.ps1 .codex/hooks/enforce-epic-merge-gate-command.ps1 .claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1 scripts/dev-tools/Invoke-FullReleaseFlow.ps1 scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.ps1 tests/scripts/workflows/CiWorkflow.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1 tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1 tests/scripts/claude-lib/ci-gate/MergeConfirmationParser.Manifest.Tests.ps1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.Tests.ps1 tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py tests/scripts/dev_tools/merge_queue_documentation_expectations.py tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py tests/scripts/dev_tools/test_epic_orchestrator_permission_contracts.py`
  Acceptance: `EXIT_CODE: 0`; 22 `<path>:<count>` lines recorded (output order is not asserted); every count is at or below 500 (AC-26); the `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` count is recorded against its projection of 446.
- [x] [P8-T11] Verify that no new or changed test creates a temporary file and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/final-temp-file-scan.<timestamp>.md`.
  Command: `git grep -n -E -e "New-TemporaryFile|TestDrive|GetTempFileName|GetTempPath|tmp_path|tempfile|mkstemp" -- tests/scripts/workflows/CiWorkflow.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1 tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1 tests/scripts/claude-lib/ci-gate/MergeConfirmationParser.Manifest.Tests.ps1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1 tests/scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.Tests.ps1 tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py tests/scripts/dev_tools/merge_queue_documentation_expectations.py tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py tests/scripts/dev_tools/test_epic_orchestrator_permission_contracts.py`
  Acceptance: `EXIT_CODE: 1` with no output, recorded with `ExpectedExitCode: 1` (git grep exits 1 when nothing matches) (AC-26).
- [x] [P8-T12] Write the coverage status `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/coverage-status.<timestamp>.md`.
  Acceptance: the artifact records `PYTHON: NOT-APPLICABLE` with the P0-T17 reason, the baseline values `PS_BASE_CLAUDE_GATE`, `PS_BASE_CODEX_GATE` and `PS_BASE_RELEASE` copied from P0-T11 (or, after an orchestrator merge of `origin/main`, from the greatest `ci-baseline.*.md`), `NEW` for the four created production files named by P0-T11, and `POWERSHELL: PENDING-ORCH (ORCH-6; D-COV and D-CHANGED on the dispatched run R_final, job poshqc / PowerShell QC)`. It records no PowerShell `PASS` verdict.
- [x] [P8-T13] Verify the changed-path set and the unchanged inputs and record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/final-scope-boundary.<timestamp>.md`.
  Commands: `git fetch origin`; `git diff --name-only origin/main...HEAD`; `git status --porcelain`; `git diff --quiet <PLAN_BASE_SHA> HEAD -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/issue.md docs/features/active/2026-10-16-ci-merge-queue-for-main-952/research/research.2026-10-16T01-30.md docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/protect-main.current.2026-10-16.json docs/features/potential/promoted/2026-10-16-ci-merge-queue-for-main.md`; `git diff -U0 <PLAN_BASE_SHA> HEAD -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/plan.2026-10-16T00-15.md`.
  Acceptance: the union of the name-only diff and the porcelain paths, excluding paths under `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/`, equals exactly the 48-path expected set of `## Files Written`: the 47 planned paths outside the feature folder plus the pre-execution lifecycle record `docs/features/potential/promoted/2026-10-16-ci-merge-queue-for-main.md` (`OUTSIDE_PATHS=48`, `LIFECYCLE_RECORD_PRESENT=true`); a missing planned path, a missing lifecycle record, or any other path fails the task; the lifecycle record is byte-unchanged since `PLAN_BASE_SHA` (it is in the `git diff --quiet` path list) and does not appear in the porcelain output; in particular `.github/workflows/_poshqc.yml`, every other `.github/workflows/*.yml` except `ci.yml`, every path under `.claude/rules/` and `.github/instructions/`, `.claude/hooks/hook-command-invocation.ps1`, `.codex/hooks/hook-command-invocation.ps1`, and `scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.ps1` are absent (AC-5 static part, AC-25); the only `.py` paths are exactly the four test paths `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py`, `tests/scripts/dev_tools/merge_queue_documentation_expectations.py`, `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` and `tests/scripts/dev_tools/test_epic_orchestrator_permission_contracts.py` (`PY_PATHS=4`, `PY_PRODUCTION_FILES=0`); the `git diff --quiet` command exits 0; every removed line of the plan diff begins with `- [ ] [P` and its paired added line is identical except `[ ]` became `[x]` (`PLAN_NONCHECKBOX_CHANGES=0`). When a `FEATURE/evidence/other/plan-revision.*.md` artifact exists (a planner delta committed by the orchestrator under `## Conventions`, origin/main merges), the plan-diff command uses the `PLAN_REVISION_SHA` of the lexicographically greatest such file in place of `PLAN_BASE_SHA`, and the artifact records which base was used; the `git diff --quiet` command keeps `PLAN_BASE_SHA`. Any additional path fails the task; the executor records it with `git log --oneline origin/main..HEAD -- <path>` and halts for the caller rather than reverting or deleting it.
- [x] [P8-T14] Commit and push the Phase 8 evidence, the checklist state of `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/plan.2026-10-16T00-15.md`, and any Phase 8 restart repair.
  Commands: `git add` of each path in `## Files Written` that the Phase 8 loop changed, then `git add docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/ docs/features/active/2026-10-16-ci-merge-queue-for-main-952/plan.2026-10-16T00-15.md`; `git commit -m "docs(952): record final QA evidence"`; `git push origin bug/ci-merge-queue-for-main-952`.
  Acceptance: `git status --porcelain` prints nothing, and `git rev-parse HEAD` equals `git rev-parse origin/bug/ci-merge-queue-for-main-952`. No force-push.

### Phase 9 — Acceptance-Criteria Tracking and Handoff

Each check-off task below verifies one acceptance criterion of `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md` from local evidence and, when the evidence shows the passing result, changes that criterion's `- [ ]` to `- [x]` in `spec.md`. A task whose evidence does not show the passing result leaves the box unchecked and halts execution for the caller. ACs whose verification needs CI rows, CI coverage or the orchestrator's PowerShell comparison stay unchecked and are listed by P9-T11 (`PENDING-ORCH` for those the orchestrator verifies before feature review, `PENDING-CI` for AC-28 only). `issue.md` is not edited.

- [x] [P9-T1] Verify AC-3 from `evidence/other/required-context-map.*.md` (P1-T6, `UNMAPPED=0`, `CI_TRIGGERS_MERGE_GROUP=true`), then check off AC-3 in `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md`.
  Acceptance: `git grep -c -F -e "- [x] AC-3:" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md` prints a count of 1.
- [x] [P9-T2] Verify AC-4 by re-running `git grep -n -F -e "which serves a merge queue on" -- .github/workflows/README.md` (one line, containing `merge_group`; recorded in the P9-T11 ledger), then check off AC-4 in `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md`.
  Acceptance: `git grep -c -F -e "- [x] AC-4:" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md` prints a count of 1.
- [x] [P9-T3] Verify AC-16 from `evidence/regression-testing/procedure-pins-after.*.md` (P6-T32, `50 passed`, which includes the `claude-parallel-orchestrate-merge`, `claude-parallel-orchestrate-conflict` and `claude-parallel-orchestrator-agent` pins) and `evidence/qa-gates/final-python-contract-suites.*.md` (P8-T7, includes `test_parallel_orchestrator_surface_contracts.py`), then check off AC-16 in `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md`.
  Acceptance: `git grep -c -F -e "- [x] AC-16:" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md` prints a count of 1.
- [x] [P9-T4] Verify AC-17 from the same two artifacts (`claude-orchestrate-s9` and `claude-orchestrate-pr-gate` pins), then check off AC-17 in `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md`.
  Acceptance: `git grep -c -F -e "- [x] AC-17:" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md` prints a count of 1.
- [x] [P9-T5] Verify AC-18 from the same two artifacts (`claude-epic-orchestrate-lifecycle`, `claude-epic-orchestrate-kickoff`, `claude-epic-orchestrate-completion` and `claude-epic-orchestrator-agent` pins) and from `evidence/regression-testing/frozen-digest-before.*.md` (P6-T24, `2 failed`) and `evidence/regression-testing/frozen-digest-after.*.md` (P6-T25, `2 passed`), which show that the frozen epic-surface digests were re-baselined on the final bytes of both epic files (including the P6-T21 tools grants) rather than left failing, then check off AC-18 in `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md`.
  Acceptance: `git grep -c -F -e "- [x] AC-18:" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md` prints a count of 1.
- [x] [P9-T6] Verify AC-19 from the same two artifacts (`agents-epic-orchestrate` and `codex-epic-orchestrator-agent` pins), then check off AC-19 in `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md`.
  Acceptance: `git grep -c -F -e "- [x] AC-19:" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md` prints a count of 1.
- [x] [P9-T7] Verify AC-20 from `evidence/qa-gates/final-mirror-hashes.*.md` (`PAIRS_EQUAL=13/13`), `evidence/qa-gates/final-python-contract-suites.*.md` (the four push-down resource and manifest-completeness modules passed) and the P3-T15 and P4-T6 manifest token counts, then check off AC-20 in `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md`.
  Acceptance: `git grep -c -F -e "- [x] AC-20:" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md` prints a count of 1.
- [x] [P9-T8] Verify AC-24 from `evidence/qa-gates/runbook-sections.*.md` (`TOKENS_FOUND=16/16`), then check off AC-24 in `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md`.
  Acceptance: `git grep -c -F -e "- [x] AC-24:" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md` prints a count of 1.
- [x] [P9-T9] Verify AC-25 from `evidence/qa-gates/final-scope-boundary.*.md`, then check off AC-25 in `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md`.
  Acceptance: `git grep -c -F -e "- [x] AC-25:" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md` prints a count of 1.
- [x] [P9-T10] Verify AC-26 from `evidence/qa-gates/final-line-counts.*.md` and `evidence/qa-gates/final-temp-file-scan.*.md`, then check off AC-26 in `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md`.
  Acceptance: `git grep -c -F -e "- [x] AC-26:" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md` prints a count of 1.
- [x] [P9-T11] Write the AC ledger `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/ac-status.<timestamp>.md`.
  Acceptance: AC-1 through AC-28 each appear exactly once with their local evidence artifact names and a status: `LOCAL-PASS` for AC-3, AC-4, AC-16 to AC-20, and AC-24 to AC-26; `PENDING-ORCH` for AC-21, AC-22 and AC-23 (ORCH-2, orchestrator PowerShell comparison, Appendix O.1), AC-1, AC-2, AC-5 and AC-12 to AC-15 (ORCH-4 on the dispatched pre-PR run `R_final`, job `poshqc / PowerShell QC`), AC-6 to AC-11 (ORCH-4 and ORCH-5, jobs `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)` of `R_final`), and AC-27 (ORCH-6, job `poshqc / PowerShell QC` of `R_final`; the Python part is `LOCAL-PASS` from P8-T4 to P8-T7); `PENDING-CI` for AC-28 only (ORCH-3 at S9, the single CI-dependent criterion under `.claude/skills/orchestrate/SKILL.md:361`). Every `PENDING-ORCH` AC is verified and checked off by the orchestrator before feature review; no `PENDING-ORCH` or `PENDING-CI` AC is checked off by the executor. A separate `Related in-item fixes (not acceptance criteria)` section lists, without adding AC items: D10(a) with `evidence/regression-testing/procedure-pins-before.*.md` (P6-T3, the `claude-cleanup-merged-worktrees` pin failing) and `evidence/regression-testing/procedure-pins-after.*.md` (P6-T32); D10(b) with `evidence/regression-testing/epic-permission-before.*.md` (P6-T19, `1 failed`) and `evidence/regression-testing/epic-permission-after.*.md` (P6-T22, `1 passed`); R4 with `evidence/other/policy-followups-check.*.md` (P7-T6); and R5 with `evidence/qa-gates/runbook-sections.*.md` (P7-T5).
- [x] [P9-T12] Write the review handoff record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/other/review-handoff.<timestamp>.md`.
  Acceptance: the artifact names the next step (orchestrator ORCH-2, then ORCH-4 to ORCH-6 on the dispatched run `R_final`, then feature review), the AC source (`spec.md` `## Acceptance Criteria`), the Phase 0 artifact paths, the Phase 8 artifact paths, the P9-T11 ledger, the pending items and the ORCH item owning each, the out-of-scope follow-ups of this plan, the policy follow-up record `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/policy-followups.md` (P7-T6), the related in-item fixes D10(a) and D10(b), and the #927 and #928 overlap regions.
- [x] [P9-T13] Commit and push Phase 9: `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md` (AC check-off), the evidence, and the plan checklist state.
  Commands: `git add docs/features/active/2026-10-16-ci-merge-queue-for-main-952/spec.md docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/ docs/features/active/2026-10-16-ci-merge-queue-for-main-952/plan.2026-10-16T00-15.md`; `git commit -m "docs(952): check off locally verified acceptance criteria"`; `git push origin bug/ci-merge-queue-for-main-952`.
  Acceptance: `git status --porcelain` prints nothing, and `git rev-parse HEAD` equals `git rev-parse origin/bug/ci-merge-queue-for-main-952`. No force-push.

## Orchestrator-Owned Verification

This section is not a phase and its items are not tasks: each is a plain `[ORCH-n]` bullet with no checkbox, so the executor stop hook (`.claude/hooks/validate-executor-output.ps1:257-287`) never counts it, and the executor neither performs nor checks off any item. The orchestrator performs the items in this order:

1. Before delegating execution: ORCH-1, then ORCH-0 (each committed and pushed).
2. After the executor returns and before feature review: ORCH-2; then ORCH-4, ORCH-5 and ORCH-6 on the dispatched run `R_final` (D-FINAL), which ORCH-4 dispatches after the ORCH-2 push. ORCH-6 checks off AC-1, AC-2, AC-5 to AC-15 and AC-27 when ORCH-4 to ORCH-6 all pass, so the PR Creation Gate condition 2 (`.claude/skills/orchestrate/SKILL.md:360-361`) holds with only AC-28 pending-CI.
3. At S9, after the PR exists: ORCH-3 (AC-28 on `R_pr`, D-PR) and ORCH-7 (re-confirmation and final ledger).

For each item the orchestrator writes the named artifact under `FEATURE/evidence/<kind>/` and commits and pushes with `git add` of the named artifacts (plus `FEATURE/spec.md` when the item checks off an AC), `git commit`, `git push origin bug/ci-merge-queue-for-main-952`. Never force-push. The `gh workflow run` dispatch, every `gh` command and the PowerShell tool are orchestrator-only. Any FAIL outcome routes to remediation; it is not a pass.

- [ORCH-0] Pre-execution directive removal, before delegating atomic execution: in `FEATURE/plan.2026-10-16T00-15.md` delete the line that consists only of the preflight directive (line 14 at approval), the paragraph that follows it (line 16 at approval, beginning "The directive line above serves preflight rounds only"), and the blank line after each, leaving one blank line between the metadata list and `## Conventions (binding for every task)`. No other line changes. Then `git add FEATURE/plan.2026-10-16T00-15.md`, `git commit -m "docs(952): remove the preflight directive before execution"`, `git push origin bug/ci-merge-queue-for-main-952`.
  Acceptance: `git grep -c -e "^DIRECTIVE: PREFLIGHT VALIDATION ONLY$" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/plan.2026-10-16T00-15.md` exits 1 with no output (the same check P0-T2 repeats); `git diff -U0 HEAD~1 HEAD -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/plan.2026-10-16T00-15.md` shows only removed lines (four) and no added line; `git rev-parse HEAD` equals `git rev-parse origin/bug/ci-merge-queue-for-main-952`.
- [ORCH-1] Baseline CI values (AC-27 baseline, ORCH-4 and ORCH-5 baselines), before delegating execution: compute `B` and select `R_base` by D-BASE; `gh run download <R_base> -n poshqc-test-results -D SCRATCH/issue-952-ci-<R_base>` and `gh run download <R_base> -n poshqc-linux-hook-test-results -D SCRATCH/issue-952-ci-<R_base>`; by D-JUNIT record the Windows Passed count of each B-SUITES member and the Linux Passed count of each B-SUITES member under `tests/scripts/claude-hooks` or `tests/scripts/codex-hooks`; by D-COV record `PS_BASE_CLAUDE_GATE` (`.claude/hooks/enforce-epic-merge-gate.ps1`), `PS_BASE_CODEX_GATE` (`.codex/hooks/enforce-epic-merge-gate.ps1`) and `PS_BASE_RELEASE` (`scripts/dev-tools/Invoke-FullReleaseFlow.ps1`). B-SUITES (17): `tests/scripts/workflows/CiWorkflow.Tests.ps1`; `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.AuthorizationFields.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1`; `tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1`, `tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1`, `tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1`; `tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1`, `tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1`, `tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.Tests.ps1`, `tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1`; `tests/scripts/claude-lib/ci-gate/CiGate.Manifest.Tests.ps1`, `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1`. Write `FEATURE/evidence/baseline/ci-baseline.<timestamp>.md` with `Command:`, `EXIT_CODE:`, `Output Summary:` (`B=`, run id, headSha, the counts, and the three `PS_BASE_*=` values). ORCH-1 is repeated, writing a new `ci-baseline.<timestamp>.md`, whenever the orchestrator merges `origin/main` into this branch after an earlier ORCH-1 (`## Conventions`, origin/main merges); every consumer reads the lexicographically greatest file.
  Acceptance: `B` is a 40-character SHA; all 17 Windows counts, all 10 Linux counts and the three coverage values are numeric; the artifact is committed and pushed before execution is delegated.
- [ORCH-2] Ruleset comparison (AC-21, AC-22, AC-23), after the executor returns and before feature review: run Appendix O.1 in the PowerShell tool and write `FEATURE/evidence/qa-gates/ruleset-compare.<timestamp>.md` with the command text and its full output.
  Acceptance: three `PAYLOAD file=` lines, each with `Keys=bypass_actors,conditions,enforcement,name,rules,target KeysOk=True FieldsOk=True RulesOk=True`, with `RuleCount=5` for the apply payload and `RuleCount=4` for the other two, and the final line `RULESET-COMPARE AllOk=True`; then change `- [ ]` to `- [x]` for AC-21, AC-22 and AC-23 in `FEATURE/spec.md` and confirm `git grep -c -F -e "- [x] AC-21:" -- FEATURE/spec.md` (and likewise AC-22, AC-23) prints a count of 1. Any `False` routes to remediation of the payload files.
- [ORCH-3] Pull-request CI conclusions (AC-28), at S9 after the PR exists: select `R_pr` by D-PR; record `gh run view <R_pr> --json jobs,headSha,conclusion,event` in `FEATURE/evidence/qa-gates/ci-final.<timestamp>.md`.
  Acceptance: `event` is `pull_request` and `headSha` equals the PR head; each of the eleven snapshot contexts (`drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)`, `drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)`, `docs-validation / Documentation Validation`, `poshqc / PowerShell QC`, `shell-coverage / Shell Coverage (Bats + kcov)`, `security-scan / Security Scanning`, `quality-checks7 / Code Quality & Tests (3.10)`, `quality-checks7 / Code Quality & Tests (3.11)`, `quality-checks7 / Code Quality & Tests (3.12)`, `quality-checks7 / Code Quality & Tests (3.13)`, `build-check / Build Package`, as listed at snapshot `:47` to `:87`) is a job of `R_pr` concluding `success`, and job `poshqc / PowerShell hook suites (Linux)` concludes `success`.
- [ORCH-4] Windows per-suite results (AC-1, AC-2, AC-5 to AC-15), after the ORCH-2 push and before feature review: perform the D-FINAL dispatch (`git fetch origin`; record `H_final`; `gh workflow run ci.yml --ref bug/ci-merge-queue-for-main-952`; select `R_final`; `gh run watch <R_final> --exit-status`); record `gh run view <R_final> --json jobs,headSha,conclusion,event`; download `poshqc-test-results` of `R_final` to `SCRATCH/issue-952-ci-<R_final>`; by D-JUNIT on the Windows file (job `poshqc / PowerShell QC`) record each suite's Passed count and its failure/error count, and the named rows below; write `FEATURE/evidence/qa-gates/ci-rows-windows.<timestamp>.md` recording `H_final`, the `R_final` id and the job conclusions.
  Acceptance: `event` is `workflow_dispatch`, `headSha` equals `H_final`, and jobs `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)` of `R_final` conclude `success`; every listed suite has zero testcases with a `failure` or `error` child, and Passed counts equal: `CiWorkflow.Tests.ps1` = ORCH-1 + 2; `tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1` = 36; `tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1` = 34; `tests/scripts/claude-lib/ci-gate/Invoke-MergeConfirmationParser.Tests.ps1` = 13; `tests/scripts/claude-lib/ci-gate/MergeConfirmationParser.Manifest.Tests.ps1` = 2; `tests/scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.Tests.ps1` = 12; every other B-SUITES member = its ORCH-1 value; `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`, `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1` and `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` each have at least one testcase and none failing. Named rows pass, each evaluated only among the member testcases of the suite paired with it (D-JUNIT): (a) `declares merge_group with types checks_requested and no branch or path filter` (AC-1) in `tests/scripts/workflows/CiWorkflow.Tests.ps1`; (b) `reads no pull-request event field and declares no path filter anywhere in the ci.yml call graph` (AC-2) in `tests/scripts/workflows/CiWorkflow.Tests.ps1`; (c) `denies gh pr merge --squash without a checkpoint (issue #952 method-agnostic scope)` (AC-10) in `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1`; (d) `denies a bare gh pr merge --squash with the method-agnostic message` (AC-11), evaluated separately in `tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1` and in `tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1`, each of which must pass on its own; (e) `keeps the existing fall-through text for a bare merge even with a valid record present` (AC-10, AC-11) in `tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1`; (f) `keeps the existing deny text for a bare merge even with a valid record present` (AC-10, AC-11) in `tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1`. Zero matches for a named row in its paired suite is a FAIL.
- [ORCH-5] Linux per-suite results (AC-6 to AC-11), after ORCH-4 and before feature review: download `poshqc-linux-hook-test-results` of `R_final`; by D-JUNIT on the Linux file (job `poshqc / PowerShell hook suites (Linux)`, no coverage) write `FEATURE/evidence/qa-gates/ci-rows-linux.<timestamp>.md`.
  Acceptance: every B-SUITES member under `tests/scripts/claude-hooks` or `tests/scripts/codex-hooks` has zero failing or erroring testcases and a Passed count equal to its ORCH-1 Linux value; `tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1` = 36 and `tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1` = 34 with zero failing. This task makes no coverage claim.
- [ORCH-6] Coverage comparison (AC-27), after ORCH-5 and before feature review: by D-COV and D-CHANGED on `R_final` (job `poshqc / PowerShell QC`), write `FEATURE/evidence/qa-gates/coverage-comparison.<timestamp>.md` with, per file, baseline (`PS_BASE_*` from ORCH-1, or `NEW`), post-change percent, changed executable lines, covered changed lines and changed-line percent, for `.claude/hooks/enforce-epic-merge-gate.ps1`, `.claude/hooks/enforce-epic-merge-gate-command.ps1`, `.codex/hooks/enforce-epic-merge-gate.ps1`, `.codex/hooks/enforce-epic-merge-gate-command.ps1`, `.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1`, `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` and `scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.ps1` (`NEW`); and `PYTHON: NOT-APPLICABLE` with the P0-T17 reason.
  Acceptance: verdict `POWERSHELL: PASS` only when every new file's post value is at least 85.00, every modified file's post value is at least 85.00 (or, when its baseline is below 85.00, at least its baseline, recorded as a pre-existing gap), and every file's changed-line percent is at least 85.00 or `n/a`; otherwise `POWERSHELL: FAIL` and the item routes to remediation (add tests, then a new D-FINAL dispatch and a repeat of ORCH-4 to ORCH-6). A `FAIL: coverage entry not unique` is a FAIL. When ORCH-4, ORCH-5 and ORCH-6 all pass, change the AC box to checked in `FEATURE/spec.md` for AC-1, AC-2, AC-5 to AC-15 and AC-27, confirm `git grep -c -F -e "- [x] AC-27:" -- FEATURE/spec.md` (and likewise each of the other thirteen) prints a count of 1, and commit and push the ORCH-4 to ORCH-6 artifacts with `FEATURE/spec.md`. That commit changes only `FEATURE/` paths, so `R_final` stays valid (D-FINAL).
- [ORCH-7] Re-confirmation and final AC ledger, at S9 after ORCH-3: record `git diff --name-only <H_final> <PR head SHA>`; every listed path must lie under `FEATURE/` (otherwise a non-feature-folder change landed after `R_final`: dispatch again by D-FINAL and repeat ORCH-4 to ORCH-6 before continuing). Then write `FEATURE/evidence/qa-gates/ac-status.<timestamp>.md` (newer than the P9-T11 ledger) mapping every `PENDING-ORCH` and `PENDING-CI` AC to its ORCH artifact and result.
  Acceptance: the diff check holds; every AC is `PASS` with an artifact name, or the item routes to remediation. Then change the AC-28 box to checked in `FEATURE/spec.md` (AC-28 is the CI-dependent criterion under `.claude/skills/orchestrate/SKILL.md` `## Step S9 — CI Green Gate`), confirm `git grep -c -F -e "- [x] AC-28 (CI-dependent):" -- FEATURE/spec.md` prints a count of 1, commit and push the ORCH-3 and ORCH-7 artifacts and `FEATURE/spec.md`, confirm `git status --porcelain -- FEATURE` is empty, and re-run S9 so that `ci_gate.head_sha` equals the final PR head before DONE.

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

Pre-change outcome: case 1 fails (no `merge_group` key), case 2 passes (planner Grep over `.github/workflows` for these patterns matched only files outside the call graph: `npm-audit-gate.yml:10`, `publish-mcp-npm.yml:13`, `publish-extension.yml:13`, `verify-published-releases.yml:17`, `:51`, `:57`; the call graph is `ci.yml` and the nine reusable workflows of `ci.yml:12-39`).

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
   with `main` as the base branch; each pull-request snapshot is classified with
   `pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1 -PrJson <snapshot-json> -AsJson`
   (issue #952).
```

The inline invocation stays on one line inside one backtick span, so `prescribed_command_invocations` (`tests/scripts/dev_tools/parallel_orchestrator_permission_seam_support.py:457-496`, which reads backtick spans line by line) returns it as one invocation for the Appendix I.4 test.

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

D.8 `.claude/skills/cleanup-merged-worktrees/SKILL.md` (coordinator D10(a)): `:206-208`, currently

```text
   operator and stops. The ruleset on `main` sets `strict_required_status_checks_policy`,
   so the branch must be up to date with `main` before the merge becomes available to the
   operator; the wait for the merge is unbounded within a session. After the consolidation
```

become the seven lines:

```text
   operator and stops. When `main` uses a merge queue (issue #952), the queue tests the merged
   result of the pull request and the entries ahead of it against the latest `main`, so the
   branch need not be up to date with `main`, and the operator adds it to the queue once its
   checks pass. Without a merge queue, the ruleset on `main` sets
   `strict_required_status_checks_policy`, so the branch must be up to date with `main` before
   the merge becomes available to the operator. In either case the wait for the merge is
   unbounded within a session. After the consolidation
```

The last line keeps the trailing words "After the consolidation", so `:209` ("   PR merges, verify it with `git fetch` followed by") continues the sentence unchanged. The merge stays human-performed; the text adds no agent merge action.

D.9 `.claude/agents/epic-orchestrator.md` tools frontmatter (coordinator D10(b)): insert after `:16` (`  - "Bash(gh *)"`) these two lines, in the form of `.claude/agents/parallel-orchestrator.md:24`:

```text
  - "Bash(pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1*)"
  - "Bash(pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1*)"
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

The executor may adjust this code to satisfy the analyzer and the Appendix B/C cases; any change keeps the six function names, keeps the file free of dot-sources and imports, and is reproduced byte-identically in `.codex/hooks/` (P3-T8) and both bundle mirrors (P3-T14). `Get-CommandLineInvocation` is defined in `.claude/hooks/hook-command-invocation.ps1:320` and `Get-CommandLineStructuralMatch` in `.claude/hooks/hook-command-invocation-operands.ps1:16`, which `hook-command-invocation.ps1:24` dot-sources (the Codex copies are at the same lines).

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
- Script `param`: `[Parameter(ValueFromPipeline = $true)][AllowEmptyString()][string]$PrJson = ''` and `[switch]$AsJson`. No parameter is mandatory, so the file can be dot-sourced with no arguments (by the tests and by `scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.ps1`).
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
- `:168-172` (`$ghFlat | Should -Be @(...)`) becomes: `$ghFlat.Count | Should -Be 4`; `$ghFlat[0..2] | Should -Be @('pr view release/full-20260703171500 --json number --jq .number', 'pr checks 291 --json bucket', 'pr merge 291 --merge')`; `$ghFlat[3] | Should -Match '^api graphql '`. (The second element is the all-checks poll of `:170` after #931; the script carries no `--required` flag.)
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

H.3 `tests/scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.Tests.ps1`: first line `Set-StrictMode -Version Latest`; `Describe "Invoke-FullReleaseFlow.ps1 - merge wait (issue #952)"` with the `BeforeAll`/`BeforeEach` of `Invoke-FullReleaseFlow.Tests.ps1:3-15` (dot-source `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` with `-ConfirmToken 'no'`, which through H.4(b) also dot-sources `scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.ps1` and the parser, so `Wait-ForPullRequestMerged` and the mocked seams share one scope; `Invoke-Sleep` mocked in `BeforeEach` with `Mock -CommandName Invoke-Sleep`). Snapshot fixtures: merged `{"state":"MERGED","mergedAt":"2026-10-16T12:34:56Z","isInMergeQueue":false,"mergeCommit":{"oid":"0123456789abcdef0123456789abcdef01234567"},"autoMergeRequest":null}`; pending `{"state":"OPEN","mergedAt":null,"isInMergeQueue":true,"mergeCommit":null,"autoMergeRequest":{"enabledAt":"2026-10-16T12:00:00Z"}}`; not queued `{"state":"OPEN","mergedAt":null,"isInMergeQueue":false,"mergeCommit":null,"autoMergeRequest":null}`; closed `{"state":"CLOSED","mergedAt":null,"isInMergeQueue":false,"mergeCommit":null,"autoMergeRequest":null}`. Flow-level cases reuse the git and child-script mock shapes of `Invoke-FullReleaseFlow.Tests.ps1:17-96` with a gh mock that returns the scripted snapshot sequence for `^api graphql `.

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

H.4 `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` and the new sibling `scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.ps1`

(a) `scripts/dev-tools/Invoke-FullReleaseFlow.ps1` `.DESCRIPTION` step 4, `:15-16`, currently

```text
      4. Waits through gh for every GitHub check on the pull request head and
         merges only after every reported check passed or was skipped.
```

becomes the three lines:

```text
      4. Waits through gh for every GitHub check on the pull request head,
         merges only after every reported check passed or was skipped, and
         waits until the merge is confirmed (issue #952).
```

The phrase "every GitHub check on the pull request head" stays on one line, and the text contains neither `--required` nor "required check" (`tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py:105-110`).

(b) `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`, inserted immediately after `:47` (the CheckHelpers dot-source); the first of the four lines is blank:

```powershell

# The merge-confirmation wait (issue #952) lives in a second sibling file,
# which also loads the shared merge-state parser.
. (Join-Path -Path $PSScriptRoot -ChildPath 'Invoke-FullReleaseFlow.MergeWait.ps1')
```

(c) New file `scripts/dev-tools/Invoke-FullReleaseFlow.MergeWait.ps1`: the help block and parser dot-source below, one blank line, then the function that follows.

```powershell
<#
.SYNOPSIS
    Merge-confirmation wait for scripts/dev-tools/Invoke-FullReleaseFlow.ps1 (issue #952).

.DESCRIPTION
    Defines Wait-ForPullRequestMerged. It lives in this sibling file so that
    scripts/dev-tools/Invoke-FullReleaseFlow.ps1 stays under the 500-line cap.
    This file declares no entry-point block and is dot-sourced by
    scripts/dev-tools/Invoke-FullReleaseFlow.ps1. Wait-ForPullRequestMerged calls
    the Invoke-GhExe, Invoke-Sleep, and Write-StderrLine seams that the release
    script defines, so Pester tests mock them without touching gh or the clock.
#>

# Merge-state parser shared with the orchestration procedures; dot-sourcing defines
# Invoke-MergeConfirmationParser without running it.
. (Join-Path -Path $PSScriptRoot -ChildPath '../../.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1')
```

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

(d) `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`, replacement for `:403-407` (the `--delete-branch` merge call and its failure branch):

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
CLEANUP_MERGED_WORKTREES = Path(".claude/skills/cleanup-merged-worktrees/SKILL.md")

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
        (
            "or a `not_queued` merge confirmation whose `mergeable` value is"
            " `CONFLICTING`",
        ),
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
    (
        "claude-cleanup-merged-worktrees",
        CLEANUP_MERGED_WORKTREES,
        "## End-to-End Workflow",
        (
            "When `main` uses a merge queue (issue #952), the queue tests the merged"
            " result of the pull request",
            "so the branch need not be up to date with `main`",
            "Without a merge queue, the ruleset on `main` sets"
            " `strict_required_status_checks_policy`, so the branch must be up to"
            " date with `main`",
        ),
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
    (
        "claude-cleanup-merged-worktrees",
        (CLEANUP_MERGED_WORKTREES, _CLAUDE_BUNDLE / CLEANUP_MERGED_WORKTREES),
    ),
)
```

The `claude-cleanup-merged-worktrees` pin reads the `## End-to-End Workflow` section of `.claude/skills/cleanup-merged-worktrees/SKILL.md` (heading at `:154`, next heading `## Nothing to Consolidate (Short Path)` at `:248`), which contains step 5 and the Appendix D.8 text.

I.2 `tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py`:

- After `:22` (`from scripts.dev_tools.validate_orchestrator_state import CI_GATE_KEYS`) and before `:23` (`from tests.scripts.dev_tools.parallel_orchestrator_surface_test_support import (`) add the block below; `merge_queue_documentation_expectations` sorts before `parallel_orchestrator_surface_test_support`, so the isort order (ruff rule set `I`, `pyproject.toml:97`) holds:

```python
from tests.scripts.dev_tools.merge_queue_documentation_expectations import (
    MERGE_QUEUE_FRAGMENT_PINS,
    MERGE_QUEUE_MIRROR_PAIRS,
)
```

- Before the mirror test (`:412`) add the block below, followed by two blank lines. The comprehension is wrapped in the form Black produces, because its one-line form is 94 characters (limit 88, `pyproject.toml:89`):

```python
@pytest.mark.parametrize(
    ("relative_path", "heading", "fragments"),
    [
        (path, heading, fragments)
        for _, path, heading, fragments in MERGE_QUEUE_FRAGMENT_PINS
    ],
    ids=[pin_id for pin_id, _, _, _ in MERGE_QUEUE_FRAGMENT_PINS],
)
def test_merge_procedure_records_merge_only_after_confirmation(
    relative_path: Path, heading: str, fragments: tuple[str, ...]
) -> None:
    """Each merge procedure records a merge only after confirmation (#952)."""
    # Arrange / Act / Assert
    _assert_section_contains(relative_path, heading, fragments)
```

- Mirror test parametrization (`:414-415`): the value list becomes `[pair for _, pair in MIRROR_PAIRS + MERGE_QUEUE_MIRROR_PAIRS]` and the ids list becomes `[pair_id for pair_id, _ in MIRROR_PAIRS + MERGE_QUEUE_MIRROR_PAIRS]`.

I.3 `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` re-baseline (P6-T25). Insert these six lines immediately after `:170` (the last line of the `RE-BASELINED by issue #928.` block) and before `PINNED_FROZEN_SURFACE_HASHES` (`:171`); every line is at most 81 characters:

```python
#
# RE-BASELINED by issue #952. That change made the epic skill and the epic agent
# record the integration-branch merge commit SHA only after the merge is
# confirmed by polling and ancestry check, and granted the epic agent the two
# parser invocations its skill prescribes. Both digests moved, and the pin
# stays live for both entries.
```

Then the two digest strings (`:174` and `:178` before the insertion, `:180` and `:184` after it) become the P6-T24 `FOUND_AGENT` and `FOUND_SKILL` values, each still a single double-quoted string on its own line followed by a comma, so the tuple shape and Black formatting are unchanged.

I.4 `tests/scripts/dev_tools/test_epic_orchestrator_permission_contracts.py` (P6-T18, coordinator D10(b)), modeled on `tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py:86-110`. Every line is at most 88 characters (`pyproject.toml:89`), and the imports follow the isort order of the model module (`:26-35`):

```python
"""Permission-seam contract for the epic-orchestrator persona (issue #952).

Purpose:
    The ``epic-orchestrate`` procedure prescribes ``pwsh`` invocations of the
    CI-gate parser and the merge-confirmation parser, and the
    ``epic-orchestrator`` persona must hold a ``Bash(...)`` grant for each of
    them. Both sides are parsed from the delivered files at run time by the
    shared seam parsers, so neither the grant set nor the prescribed set is
    restated here.

Invariants and constraints:
    The test carries a cardinality floor so a degenerate parse that returns no
    invocation cannot pass. It reads committed files only: no temporary file,
    no external process, and no network access.
"""

from __future__ import annotations

from pathlib import Path

from tests.scripts.dev_tools.parallel_orchestrator_permission_seam_support import (
    bash_grant_covers,
    persona_bash_grants,
    prescribed_command_invocations,
)

EPIC_ORCHESTRATOR_AGENT = Path(".claude/agents/epic-orchestrator.md")
EPIC_ORCHESTRATE_SKILL = Path(".claude/skills/epic-orchestrate/SKILL.md")

# The procedure prescribes the CI-gate parser and the merge-confirmation parser.
MINIMUM_PRESCRIBED_PWSH_INVOCATIONS = 2


def test_every_prescribed_pwsh_invocation_has_an_epic_persona_bash_grant() -> None:
    """Require an epic persona ``Bash`` grant for every prescribed ``pwsh`` call."""

    # Arrange
    grants = persona_bash_grants(EPIC_ORCHESTRATOR_AGENT)
    invocations = tuple(
        invocation
        for invocation in prescribed_command_invocations(EPIC_ORCHESTRATE_SKILL)
        if invocation.split()[0] == "pwsh"
    )

    # Act
    uncovered = tuple(
        invocation
        for invocation in invocations
        if not any(bash_grant_covers(grant, invocation) for grant in grants)
    )

    # Assert
    assert len(invocations) >= MINIMUM_PRESCRIBED_PWSH_INVOCATIONS, (
        "the epic-orchestrate procedure must prescribe at least "
        f"{MINIMUM_PRESCRIBED_PWSH_INVOCATIONS} pwsh invocations; parsed "
        f"{len(invocations)}: {invocations}"
    )
    assert not uncovered, (
        "the epic-orchestrate procedure prescribes a pwsh invocation no "
        f"epic-orchestrator Bash grant covers: {uncovered}. Declared Bash grants "
        f"are {grants}."
    )
```

`persona_bash_grants` and `prescribed_command_invocations` accept a repo-relative `Path` argument (`tests/scripts/dev_tools/parallel_orchestrator_permission_seam_support.py:128` and `:457-459`); `prescribed_command_invocations` returns only spans of at least two tokens (`:491-493`), so `invocation.split()[0]` is always defined. Before P6-T21 the two prescribed `pwsh` invocations (`.claude/skills/epic-orchestrate/SKILL.md:127` and the P6-T16 line) satisfy the floor and are uncovered, so the test fails on the `uncovered` assertion; after P6-T21 both are covered by prefix.

## Appendix P — Policy follow-up record (`FEATURE/policy-followups.md`, P7-T6, coordinator R4)

The file has a title, a status line stating that no rule file is edited by issue #952 and that each change requires policy-edit approval, and three records. Each record has the lines `File:`, `Line:`, `Current text (verbatim):` (followed by the full current line as a quotation), `Why it becomes stale after issue #952:` and `Proposed replacement wording:`. The text below was read at merge commit `1195107340f811b565a2ee311e1ad3ce731c5680`; P7-T6 re-reads each line before writing.

1. `File: .claude/rules/orchestrator-state.md`, `Line: 238`. Current text: the full line 238, which begins "Each entry records one authorized standalone merge with the shape" and contains "The gate consults the array only for a `gh pr merge --merge` command that names an explicit pull request number, and only after its per-feature, epic, and parallel allow conditions have all declined." Why stale: after this item the gate's scope predicate (Appendix E, `Test-EpicMergeGateCommandInScope`) covers every `gh pr merge` spelling except a pure `--disable-auto` and every `gh api` merge or enqueue mutation, and the standalone authorization branch is reached for all of them, so "only for a `gh pr merge --merge` command" understates the scope. Proposed replacement for that sentence: "The gate consults the array only for a gated merge or merge-queue enqueue command (any `gh pr merge` spelling except a pure `--disable-auto`, or a `gh api` merge or enqueue mutation; issue #952) that names an explicit pull request number, and only after its per-feature, epic, and parallel allow conditions have all declined."
2. `File: .claude/rules/parallel-orchestration.md`, `Line: 154`. Current text: "- `gh pr view --json state,mergedAt,headRefOid` — pull-request state, merge time, and merge commit (`items[].pr_number`, `pr_url`, `merge_status`, `merged_at`, `merge_commit_sha`)." Why stale: none of the three requested fields is the merge commit, and after this item a merge is recorded only after polling reports `MERGED` with a merge commit oid and `git merge-base --is-ancestor` confirms it, so the line names an incomplete source for `merge_commit_sha`. Proposed replacement: "- `gh pr view --json state,mergedAt,mergeCommit,headRefOid` — pull-request state, merge time, merge commit (`mergeCommit.oid`), and head (`items[].pr_number`, `pr_url`, `merge_status`, `merged_at`, `merge_commit_sha`); under a merge queue `merge_commit_sha` is recorded only after the merge is confirmed by polling and ancestry check (issue #952)."
3. `File: .claude/rules/parallel-orchestration.md`, `Line: 689`. Current text: "- The `PreToolUse` merge gate `.claude/hooks/enforce-epic-merge-gate.ps1` carries a parallel allow-branch that authorizes a per-item `gh pr merge --merge` from the parallel-orchestrator checkpoint when `route_id == "parallel"`, the target item's `merge_status == "ci_green"`, and the command's PR number matches that item's `pr_number`; any other case fails closed with `EPIC_MERGE_GATE_BLOCKED`." Why stale: after this item the gate is method-agnostic, so the parallel allow-branch authorizes any gated merge or enqueue command for the item, not only `gh pr merge --merge`. Proposed replacement for "authorizes a per-item `gh pr merge --merge`": "authorizes a per-item merge or merge-queue enqueue (any `gh pr merge` spelling except a pure `--disable-auto`, or a `gh api` merge or enqueue mutation; issue #952)".

## Appendix O — Orchestrator-only commands (PowerShell tool)

O.1 Ruleset comparison (ORCH-2). Run from the worktree root in the orchestrator's PowerShell tool:

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

A payload that is not valid JSON makes `ConvertFrom-Json` raise; the raised error is recorded and is a FAIL.

## Appendix S — Ruleset deliverables

Each payload is a JSON object with exactly the keys `name`, `target`, `enforcement`, `conditions`, `rules`, `bypass_actors`, in that order, copied from the snapshot text with the snapshot's nested key order and two-space indentation. Read-only snapshot fields (`id`, `source_type`, `source`, `node_id`, `created_at`, `updated_at`, `current_user_can_bypass`, `_links`) are omitted.

- S.1 `protect-main.merge-queue.apply.json`: `name` through `conditions` copied from snapshot `:3-4`, `:7-15`; `rules` copied from `:16-93` with one element appended after the `required_status_checks` rule: `{ "type": "merge_queue", "parameters": { "check_response_timeout_minutes": 60, "grouping_strategy": "ALLGREEN", "max_entries_to_build": 5, "max_entries_to_merge": 5, "merge_method": "MERGE", "min_entries_to_merge": 1, "min_entries_to_merge_wait_minutes": 5 } }`, written in the same two-space style with one `"key": value` pair per line (so the line `"check_response_timeout_minutes": 60` appears once); `bypass_actors` copied from `:97-103`. `strict_required_status_checks_policy` stays `true`.
- S.2 `protect-main.non-strict.alternative.json`: as S.1 without the appended rule, and with `"strict_required_status_checks_policy": false` in place of snapshot `:43`.
- S.3 `protect-main.rollback.json`: as S.1 without the appended rule; every value equals the snapshot.
- S.4 `runbook.md`: title, a status line that states, on one line, "Status: shipped, not applied. This item applies nothing: issue #952 ships these payloads and this runbook, and every apply, rollback or alternative step below is a separate operator action.", and these eight sections, each heading on its own line. Each quoted sentence below is written on a single line of the runbook so its P7-T5 token is not split by a wrap:
  - `## Preconditions`: the sentence "GitHub documents merge queues for organization-owned repositories, and `drmoisan/drm-copilot` is user-owned, so the `merge_queue` apply payload is expected to be rejected until the repository is organization-owned or the API accepts the rule."; the issue #952 PR is merged so `ci.yml` triggers on `merge_group`; a token with repository administration write permission; `conditions.ref_name.include` is `~DEFAULT_BRANCH` with no wildcard.
  - `## Capture and Diff Before Applying`: `gh api repos/drmoisan/drm-copilot/rulesets/15241672` captured to a file, diffed against `protect-main.current.2026-10-16.json`; on any difference in a writable field, regenerate the three payloads from the fresh capture before applying.
  - `## Apply`: the command `gh api --method PUT repos/drmoisan/drm-copilot/rulesets/15241672 --input protect-main.merge-queue.apply.json` on one line.
  - `## Post-Apply Verification`: GET the ruleset and confirm the `merge_queue` rule; enqueue one green PR and confirm every context in `required_status_checks` reports on a `merge_group` run; queue two green PRs and confirm both merge without `gh pr update-branch`; enqueue a `BEHIND` PR to confirm the queue accepts it with `strict_required_status_checks_policy: true`, applying a follow-up payload with `false` if it is refused.
  - `## Expected Failure on a User-Owned Repository`: the PUT is expected to fail with HTTP 422 while the repository is user-owned (expected, not observed); no partial change is expected; take no further action, and see the two fallbacks below.
  - `## Rollback`: the command `gh api --method PUT repos/drmoisan/drm-copilot/rulesets/15241672 --input protect-main.rollback.json` on one line; roll back when a required context does not report within `check_response_timeout_minutes`; the rollback payload restores the snapshot's writable fields.
  - `## Non-Strict Alternative (Separate Operator Decision)`: the sentence "Applying `protect-main.non-strict.alternative.json` is a separate operator decision and is not part of issue #952."; the payload removes the re-sync loop now and works on a user-owned repository, but loses pre-merge validation of the combined result; `push` CI on `main` detects breakage only after it lands.
  - `## Admin Merges Skip the Queue`: `gh pr merge --admin` merges directly for the bypass actor (user 54180981, `bypass_mode: pull_request`) and skips the queue; the merge gate requires an authorization record for `--admin` like any merge.
