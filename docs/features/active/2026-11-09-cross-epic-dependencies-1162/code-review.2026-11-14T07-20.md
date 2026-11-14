# Code Review: cross-epic-dependencies (#1162)

**Review Date:** 2026-11-14
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-09-cross-epic-dependencies-1162`
**Feature Folder Selection Rule:** named by the caller; matches the branch issue number 1162
**Base Branch:** `main` (merge base `2c8dee6dd3a82f210561d9efe623767ae902de51`, equal to `origin/main` after a fetch at review time)
**Head Branch:** `feature/cross-epic-dependencies-1162` (head `73ecccd13b3f8f7601de848136eca93fdafaa328`, clean worktree)
**Review Type:** Initial feature review (S7). Plan `plan.2026-11-09T16-32.md`, 34 of 34 tasks checked.

---

## Executive Summary

The branch adds an optional cross-epic dependency edge (`cross_epic_depends_on`) to the epic manifest. The pieces are:
- A PowerShell readiness module and CLI (`.claude/lib/epic-wave/EpicCrossDependency.psm1`, `Invoke-EpicCrossReadiness.ps1`).
- Key-gated checkpoint invariants in Python, TypeScript, and a new PowerShell Layer 2 module, pinned by a shared corpus.
- External nodes in the epic progress report.
- Skill, agent, template, bundle, and pack-manifest updates.

The design follows the spec decisions D1 to D11. Pure decision functions are separated from two thin executable wrappers, and every clock, sleep, and read goes through an injected seam. No hook or hook registration changed, and no new Python production file was added. The reviewer confirmed the following at head:
- All Claude bundle copies and Codex stored copies have one blob id with their sources (`git ls-files -s`).
- Both epic templates share one blob id.
- `config/file-size-baseline.json` is unchanged.

**Top 3 risks:**
1. Finding F1. After a prerequisite epic's integration branch is deleted on the remote, the readiness CLI still treats the branch as present. `Get-EpicCrossReadinessResult` runs `git fetch -q origin` without `--prune`, so the stale `origin/<branch>` ref keeps resolving. Spec row 2 (`PREREQ_IN_MAIN`) and the D4 rule "no extra merge" are then unreachable in that case.
2. Finding F2. The skill lists four hold-record statuses (`held`, `released`, `integrated`, `in_main`) but does not say which status to record for each decision reason. The started-while-held invariant accepts only `integrated` or `in_main`. An orchestrator that records `released` for a `PREREQ_ALREADY_INTEGRATED` release, and then launches the feature, fails the stop hook and both validators.
3. The integration-to-main hold is a skill-level control with a retrospective validator backstop, as disclosed under D5. A run that ignores the skill can open the PR early. This is documented and accepted by the spec.

**PR readiness recommendation:** **No-Go** until F1 and F2 are fixed. Both are small, contained changes.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `.claude/lib/epic-wave/EpicCrossDependency.psm1` (and its two byte-identical copies) | `Get-EpicCrossReadinessResult`, line 653; `Read-EpicCrossManifestText`, lines 535 to 538 | F1. The fetch runs as `git fetch -q origin`, without `--prune`. When another clone deletes the prerequisite epic's integration branch (the normal end of an epic), the local `origin/<branch>` ref survives. `Read-EpicCrossManifestText` then returns `Source = 'branch'`, so `OtherBranchPresent` is true. Row 2 (`PREREQ_IN_MAIN`) cannot fire: the edge evaluates against the stale ref and returns `PREREQ_ALREADY_INTEGRATED` or `merge_required`. On `merge_required`, the D4 step "fetch it from origin" then fails for a branch that no longer exists. | Fetch with pruning (`git fetch -q --prune origin`), or decide branch presence with `git ls-remote --exit-code --heads origin <branch>` through `Invoke-EpicCrossGitExe`. Add an adapter test that asserts the new argument array and a case where the remote branch is gone but a stale ref would resolve. Re-copy both bundle copies. | Spec `## Alternate and edge flows` (third bullet) and D4 require `PREREQ_IN_MAIN` with no extra merge once the other integration branch no longer exists. The current adapter cannot detect that. The defect cannot release a feature early, because the prerequisite is already in `main`. It does produce a wrong decision and a D4 sequence that cannot complete. | Reviewer real-git probe in SCRATCH (`r1162-staleref.sh`). A bare remote held `epic/prov-integration`; a second clone deleted it. In the working clone, after `git fetch -q origin`, `git show origin/epic/prov-integration:<path>` exited 0. After `git fetch -q --prune origin`, it exited 128. `git config fetch.prune` and `remote.origin.prune` are unset in the worktree. The adapter test for "a deleted branch" mocks `git show` of the branch as failing, so it does not cover the stale-ref state. |
| Major | `.claude/skills/epic-orchestrate/SKILL.md` (and `.agents/skills/epic-orchestrate/SKILL.md`, `.claude/agents/epic-orchestrator.md`, `.codex/agents/epic-orchestrator.toml`, bundle copies) | `## Cross-Epic Dependencies`, **Records (D7)** paragraph (lines 492 to 497) | F2. The records paragraph lists the `status` values `held`, `released`, `integrated`, and `in_main`, but maps no decision or reason to a status. The started-while-held invariant (Python, TypeScript, PowerShell) fails any started feature whose entry is not `integrated` or `in_main`. `released` is therefore never valid once the feature has a worktree. The skill does not say which status follows `PREREQ_ALREADY_INTEGRATED` (a release with no merge) or `PREREQ_IN_MAIN`. The progress report also counts only `integrated` and `in_main` as `done`. | State the mapping explicitly in the records paragraph and its Codex and agent counterparts. Examples: `hold` gives `held`; `PREREQ_IN_MAIN` gives `in_main`; `PREREQ_ALREADY_INTEGRATED`, or a completed D4 merge, gives `integrated` before the feature is launched; `released` is used only between a `merge_required` decision and the D4 merge. Pin the sentence in `cross-epic-skill-contract.Tests.ps1`. Re-baseline the frozen digest of the skill, and regenerate any `0010-early-dependent-starts.patch` hunk the digest line touches, after the final `origin/main` merge, as the spec requires. | A documented status that the validators reject after launch is a likely failure in the first real run. The spec's own example, several features naming the same other epic, produces `PREREQ_ALREADY_INTEGRATED` for every feature after the first. The validators are correct; the guidance that feeds them is incomplete. | `grep` of the four status words across the skill, agent, Codex skill, and Codex agent finds only the enumeration (SKILL.md line 493, `.agents` line 300). Invariant text: `_epic_orchestrator_state_wave_barrier.py` `CROSS_EPIC_INTEGRATED_STATUSES = ("integrated", "in_main")` and the TypeScript and PowerShell twins. Progress report: `Get-EpicProgressReport.CrossEpic.ps1` line 123. |
| Warning | `.claude/lib/epic-wave/EpicCrossDependency.psm1` | whole file | 769 logical lines, at or above the 700-line advisory tier and below the 800-line hard limit. The same count applies to both byte-identical copies (`extensions/drm-copilot/resources/claude-customizations/.claude/lib/epic-wave/` and `extensions/drm-copilot/resources/lib/epic-wave/`). | Consider moving the gather functions and `Invoke-EpicCrossReadinessCommand` into a sibling adapter file when this module next grows. | Advisory tier only. The file is new, so the spec's "no edited code file reaches 700 lines" constraint (edited files) is not engaged. | Reviewer logical line count (`awk 'END{print NR}'`, each file ends with one terminator). |
| Info | `.claude/lib/epic-wave/EpicCrossDependency.psm1` | `ConvertFrom-EpicCrossFlowValue` | A trailing YAML comment after the inline value (`cross_epic_depends_on: [{...}]  # note`) makes the value malformed. This is fail-closed: kickoff stops with `EPIC_CROSS_DEPENDENCY_MALFORMED`. | None required. A template comment could say that trailing comments are not accepted on that line. | Conservative parse; the template documents the key in frontmatter comments above the line. | Code reading of the parser; the regex requires the value to end with `]`. |

Blocking findings: F1 and F2 (both Major, autonomous, contained). The Warning and Info rows are non-blocking.

---

## Implementation Audit

### Python implementation audit (if applicable)

#### What changed well

- Existing validators were extended in place, with no new Python production file (spec constraint; owner rule against new Python). `validate_cross_epic_dependency_shape`, `validate_cross_epic_main_gate`, and `validate_cross_epic_started_while_held` are key-gated and are appended after the existing checks, so a checkpoint without the key keeps its error list unchanged.
- Docstrings follow the repository template (Purpose, Args, Returns, Raises, Side Effects).

#### Typing and API notes

- Uses `cast` over `Any`-typed JSON, consistent with the module. Pyright reports 0 errors (`python-static.2026-11-14T05-55.md`).

#### Error handling and logging

- Pure functions return error lists; no exception handling was added.

### PowerShell implementation audit (if applicable)

#### What changed well

- The wrapper seams follow `.claude/rules/powershell.md`: `Invoke-EpicCrossGhExe -GhArgs` and `Invoke-EpicCrossGitExe -GitArgs` splat array arguments. The exit code is read through `Get-EpicCrossLastExitCode`. No string-built commands.
- Fail-closed adapters: every gather function wraps its calls in `try` and sets `AdapterError`. Ancestry exits other than 0 or 1 yield `PREREQ_UNVERIFIABLE` or `MAIN_PREREQ_UNVERIFIABLE`.
- The bounded wait uses the injected `Wait-EpicCrossInterval` and stops when another poll would pass the bound. With `-WaitSeconds 540` that is 10 evaluations and 9 sleeps.
- The Gate-1 fix (commit `6c6959e96`) replaced a `$usage` scriptblock invocation with the private `ConvertTo-EpicCrossUsageResult`, which removed six dynamic-invocation sites flagged by the no-Python-in-hooks repository scan.
- `OrchestratorStateEpicWaveBarrier.psm1` imports the new Layer 2 module with a guarded import that fails closed, as the spec requires.

#### API and safety notes

- F1 (above) is the one adapter-level correctness defect.
- The token rule compares exact hyphen-delimited tokens of the last head-branch segment (`-ccontains`), so `11880` does not match `1188`. Main-sync chore PRs are excluded before either rule runs.

#### Error handling and logging

- Usage errors exit 2 with an `EPIC_CROSS_READINESS_USAGE:` prefix; validation errors exit 1 with codes on stderr.

### TypeScript implementation audit (if applicable)

- `epic-orchestrator-state-resolution.ts`, `-core.ts`, `-wave-barrier.ts`, and `epic-planner-state-core.ts` port the Python rules with byte-identical strings. The shared corpus `tests/fixtures/epic_cross_dependency/cross-dependency-cases.json` drives both runtimes and the PowerShell parity suite.
- No `any`, `ts-ignore`, or `eslint-disable` in the added lines.
- `jest.config.cjs` gains per-file `coverageThreshold` entries for the three files named in the spec.

### C# implementation audit (if applicable)

- N/A: no C# file in the branch diff.

---

## Test Quality Audit

- Determinism: tests use in-memory manifest text, PR JSON, and checkpoint text, plus committed LF fixtures. No test starts `gh` or `git`; mocks target the wrappers with matching parameter names. No temporary file or wall-clock wait appears in the added test lines (reviewer search of the test diff for temporary-path APIs: no match).
- Discrimination: the main-sync exclusion test, the longer-token test, and the cap-1 external-node schedule test each assert a value that a plausible regression would change.
- Gap tied to F1: the "deleted branch" adapter row mocks `git show origin/<branch>` as failing, which models a pruned clone only. No case models a stale remote-tracking ref.
- Gap tied to F2: no contract row pins a decision-to-status mapping, because the skill states none.

### Reviewed test and QA artifacts

- `evidence/qa-gates/pester.2026-11-14T06-37.md` (failed first pass, two fixes) and `pester.2026-11-14T06-55.md`
- `evidence/qa-gates/pytest.2026-11-14T06-59.md`, `jest.2026-11-14T07-01.md`
- `evidence/qa-gates/powershell-static.2026-11-14T05-53.md`, `powershell-static.2026-11-14T06-41.md`, `python-static.2026-11-14T05-55.md`, `typescript-static.2026-11-14T05-56.md`
- `evidence/qa-gates/coverage-comparison.2026-11-14T07-02.md`, `self-review.2026-11-14T07-04.md`
- Reviewer gates: `evidence/qa-gates/jest-root-gate.2026-11-14T07-12.md` and `evidence/qa-gates/pester-reviewer-gate.2026-11-14T07-32.md`

### Quality assessment prompts

- Do the tests discriminate? Yes for the decision tables and the parser. The adapter suite does not model a stale remote-tracking ref (F1).
- Are legacy inputs covered? Yes: the absent-key regression baseline is the existing epic validator, wave, wave-barrier, and progress-report suites, all passing.

---

## Security / Correctness Checks

- No secrets, absolute paths, or host names in the added lines or the evidence (reviewer search of the diff).
- No unsafe command construction; executables run only through the two wrappers.
- No hook file and no `settings.json` registration changed (`git diff --stat` of `.claude/hooks` and `.claude/settings.json` is empty).
- Ledger: `docs/engineering/process-reductions/patches/0010-early-dependent-starts.patch` was regenerated so the stored reversal still applies over this item's edits. The `PRC-LEDGER-CHAIN-HOLDS` and `PRC-LEDGER-SUBCHAIN-HOLDS` suites pass in the reviewer's full Pester run.

---

## Research Log

- Read `issue.md`, `spec.md` (D1 to D11, 25 AC), `user-story.md` (8 AC), the plan, and all final-gate and self-review evidence.
- Reviewed the full diff `2c8dee6dd..73ecccd13` (117 files) and read `EpicCrossDependency.psm1` in full, the Python and TypeScript invariant diffs, the new progress-report part file, and the `## Cross-Epic Dependencies` skill section.
- Verified blob-id parity of every bundle and stored copy, and logical line counts of every changed covered file.
- Ran a real-git stale-ref probe in SCRATCH.
- Ran the root Jest configuration with coverage and a full `Invoke-PoshQCParallelTest` in the item worktree, because the existing PowerShell report predated the last PowerShell-touching commit by 46 seconds and the root TypeScript report was absent.

---

## Verdict

**No-Go.** Two blocking findings (F1 and F2), both autonomous and contained. One file-size Warning and one Info row are non-blocking.
