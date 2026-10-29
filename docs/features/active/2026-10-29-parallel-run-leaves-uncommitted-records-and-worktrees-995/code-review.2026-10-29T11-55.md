# Code Review: Parallel run leaves uncommitted records and worktrees (#995)

---

**Review Date:** 2026-10-29
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-29-parallel-run-leaves-uncommitted-records-and-worktrees-995`
**Feature Folder Selection Rule:** the only active feature folder added on the branch; its suffix matches issue #995 in the branch name.
**Base Branch:** `main` (merge base `972e4083c59fefd1d40984929503c9956eed7137`)
**Head Branch:** `bug/parallel-run-leaves-uncommitted-records-and-worktrees-995` (`bed21939d7da24cce0c2100ef619fe3aaa23f19d`)
**Review Type:** Initial review

---

## Executive Summary

The branch fixes two causes of issue #995. First, the removal gates never recognised a parallel item whose checkpoint records `worktree_path` relative to the main checkout, because six sites each compared the recorded string to the absolute command target after only separator normalisation. A new pure module, `WorktreeRunRecordPath.psm1`, now owns the comparison: a rooted record compares as before, a relative record is joined to the main checkout root and to the root holding the checkpoint, and a blank, `.`, `..`, dot-segment, or `:`-bearing relative record matches nothing. All six matcher-family sites call it. Second, the `parallel-orchestrate` skill and the `parallel-orchestrator` agent gain a `### Run Closing` procedure (item worktree removal without force, final status, docs-only records pull request through `Agent(pr-author)`, scratch-worktree cleanup, deferral reporting), and the agent's `tools:` gains `Agent(pr-author)` and the cleanup-script grant.

The production delta is focused and the fail-closed ordering is preserved: the matcher only widens recognition of records whose status already permits removal, and every deny prefix is unchanged. Test coverage of the new behavior is thorough, including end-to-end gate decisions, ambiguity, the manifest exclusion, and content checks on both skill and agent copies. Mirrors are byte-identical, the merge-gate hooks and Codex surfaces are untouched, and every changed file is under 500 lines.

**What changed:**
New `.claude/lib/worktree-resolution/WorktreeRunRecordPath.psm1`; `Test-WorktreeRunPathEqual` moved out of `WorktreeRunResolution.psm1`; `-BaseRoot` added to `Test-WorktreeRunCheckpointRecord`, `Find-ParallelWorktreeItemRecord`, `Find-EpicWorktreeFeatureRecord`, `Test-ParallelCheckpointAllowsWorktreeRemoval`, `Find-EpicWorktreeGateParallelItemRecord`, and `Test-CleanupManifestCheckpointCoversPath`; new `Get-ParallelWorktreeGateBaseRoot` and `Get-EpicWorktreeGateBaseRoot`; `-MainRoot` on `Get-EpicWorktreeGateDenyDiagnostics`; Run Closing prose in the skill and agent; rule bullet; `core.json` entry; five new Pester suites; one Python contract test replaced.

**Top 3 risks:**
1. The manifest-removal lookup (`Find-CleanupWorktreeManifestRemovalRecord`) remains case-insensitive for every path while the checkpoint-coverage exclusion is now ordinal for single-slash POSIX paths. On a case-insensitive POSIX filesystem this narrows the exclusion that keeps a manifest from overriding a checkpoint record.
2. The Run Closing procedure (unlock and remove under a live harness lock, docs-only pull request through `Agent(pr-author)` without an issue number, merge-gate evaluation) cannot be proven by unit tests; the spec records LV1 to LV4 with deferral behavior.
3. `Get-WorktreeRunMainCheckoutRoot` adds `git worktree list` reads on each `git worktree remove` command (once in the gate and once per resolution read). The cost is bounded and applies only to removal commands.

**PR readiness recommendation:** **Go** — no Blocker or Major finding; toolchain and coverage thresholds pass, subject to the S9 CI gate on the final PR head.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1` | `Find-CleanupWorktreeManifestRemovalRecord` vs `Test-CleanupManifestCheckpointCoversPath` | The manifest lookup compares with `-eq` (case-insensitive for all paths); the checkpoint-coverage test now uses the shared matcher (ordinal for single-slash POSIX paths). Before this change both were case-insensitive. A checkpoint record that differs from the target only by case on a POSIX root no longer counts as covering it, so the manifest exclusion clause does not fire for that record. | Route the manifest `removals[]` comparison through `Test-WorktreeRunPathEqual` (or the shared matcher with no base roots) so both sides of the exclusion apply the same case rule. | Keeps the exclusion that prevents a manifest from overriding a checkpoint symmetric with the manifest lookup. The residual exposure is limited to case-insensitive POSIX filesystems, and the manifest predicate's disposition, evidence, verdict, and branch-state conditions still apply. | Diff of `Test-CleanupManifestCheckpointCoversPath`; `CleanupWorktreeManifest.psm1` lines 188-199; M5 and P2 in `WorktreeRunRecordPath.Tests.ps1` show POSIX case variants do not match. |
| Minor | `.claude/skills/parallel-orchestrate/SKILL.md`, `.claude/agents/parallel-orchestrator.md` | `### Run Closing`, substep 3 | The prose allows `git add`/`git commit` pathspecs beginning `artifacts/orchestration/`, but `/artifacts` is ignored by `.gitignore` (a plain `git add` of such a path is refused) and the same substep requires the branch diff to list only `docs/` paths. | State that only `docs/features/` paths are staged by Run Closing, or note that `artifacts/orchestration/` is named only because it is the other prefix the documentation-only exemption accepts. | Removes an instruction that cannot succeed and that would contradict the docs-only precondition. | `git check-ignore -v artifacts/orchestration/parallel-orchestrator-state.json` reports `.gitignore:6:/artifacts`. |
| Minor | `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.RelativeRecord.Tests.ps1` | RE2 | The epic gate's relative-record deny rows exercise only the parallel-item branch; no epic-gate row drives a relative `features[]` record with `pr_open`, `worktree_created`, or absent status. | Add RE2 rows for the `features[]` branch. | AC-6 is met at the gate level and the matcher is shared, but a features-branch deny row would pin the epic-topology fail-closed behavior directly. | RE1 covers `features[]` allow; RP4 and RR2 cover `features[]` matching; RE2 rows all use `-Parallel`. |
| Minor | `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`, `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1` | `Get-ParallelWorktreeGateBaseRoot`, `Get-EpicWorktreeGateBaseRoot` | The two helpers have identical bodies, and `Resolve-WorktreeRunTargetByRecord` builds the same base-root list inline. | Consider one exported helper in `WorktreeRunRecordPath.psm1` (for example `Get-WorktreeRunRecordBaseRoot -MainRoot -ReadRoot`). | Reusability; one definition of the D1 base-root rule. | Diff of both hook files and `WorktreeRunResolution.psm1`. |
| Info | `.claude/lib/worktree-resolution/WorktreeRunRecordPath.psm1` | `$script:AbsolutePathPattern` | The pattern is duplicated from `WorktreeRunResolution.psm1`; the comment acknowledges it. | No change required. | Recorded so a future edit updates both. | Module source line 30-32. |
| Info | `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | `Get-*RemovalTargetDenial` | The gate derives the main root once, and each `Resolve-WorktreeRunTargetByRecord` read derives it again, so a removal command reads the live-root list several times. | No change required; the spec's constraint (once per resolution, not per record) holds, and RR6 pins it. | Cost applies only to `git worktree remove` commands. | RR6 in `WorktreeRunResolution.RelativeRecord.Tests.ps1`. |
| Info | `.claude/agent-memory/parallel-orchestrator/worktree-removal-gate-path-mismatch.md` | — | The updated note exists only in the executing checkout because `.claude/agent-memory` is ignored. | No change required. | Recorded in `spec.md` `## Implementation Deviations`; AC-19 is evaluated on the rule text. | `git check-ignore -v` reports `.gitignore:69:.claude/agent-memory`. |
| Info | `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` | `test_agent_tools_allowlist_grants_only_the_records_pr_author_channel` | Replaces a test whose asserted behavior D4 reverses. | No change required. | The new assertion requires exactly one `pr-author` entry equal to `Agent(pr-author)`, so a broader grant still fails. | Diff; `spec.md` `## Implementation Deviations`. |

No Blocker or Major findings. No covered file in the branch diff is at or above 700 lines (largest 495), so no file-size Warning row applies, and `config/file-size-baseline.json` is unchanged.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- The replaced contract test is stricter than a containment check: it collects every `pr-author` entry and requires the list to equal `["Agent(pr-author)"]`.

#### Typing and API notes

- Pyright strict: 0 errors. No production Python change.

#### Error handling and logging

- The assertion message prints the full tools list.

### TypeScript implementation audit

#### What changed well

- Not applicable; no TypeScript file changed.

#### Type safety and maintainability

- Not applicable.

#### Error handling and logging

- Not applicable.

### PowerShell implementation audit

#### What changed well

- One pure matcher replaces six inline normalise-and-compare copies; the matcher family is documented by name in the spec and verified by a two-strategy search (`evidence/other/matcher-family-search.2026-10-29T10-58.md`).
- Unsafe relative records are rejected before any join, so `.`/`..`/dot segments/`:` cannot name the main checkout or a path outside it; M7 checks eight forms against six candidate targets including the main root.
- `-BaseRoot` defaults to an empty array, so a caller that passes no base roots keeps the previous behavior for rooted records and fails closed for relative ones.
- `Test-WorktreeRunPathEqual` moved unchanged, keeping `WorktreeRunResolution.psm1` at 487 lines.
- Hooks import the new module in the guarded `try/catch Add-HookDependencyFailure` form; `hook-dependency-guard-completeness.Tests.ps1` passes.

#### API and safety notes

- Exported surface: `Test-WorktreeRunPathEqual`, `Test-WorktreeRunRecordedPathMatchesTarget`, `Get-WorktreeRunMainCheckoutRoot` (X1 pins the list).
- Comparison semantics in the gates' own record lookup changed from PowerShell `-eq` (case-insensitive) to the shared rule (case-insensitive for drive-letter and UNC, ordinal for single-slash POSIX). For the allow lookups this only narrows matching (fail-closed direction). The manifest exclusion is the one site where narrowing has the opposite effect (Findings Table, first row).

#### Error handling and logging

- Deny reason prefixes and text are unchanged; `Get-EpicWorktreeGateDenyDiagnostics` uses the same matcher, so the diagnostics name the relative record (RE4).

### C# implementation audit

#### What changed well

- Not applicable; no C# file changed.

#### Type safety and API notes

- Not applicable.

#### Error handling and logging

- Not applicable.

---

## Test Quality Audit

The reviewer parsed `artifacts/pester/powershell-coverage.xml`, re-ran nine Pester suites (332 passed, 0 failed), PSScriptAnalyzer (0 findings on 26 files), and the Python checks. Fail-before evidence (`evidence/regression-testing/expect-fail.2026-10-29T10-48.md`) shows the allow cases and the manifest relative-record rows failing before the fix, while the deny cases already passed, as the plan required.

### Reviewed test and QA artifacts

- `tests/scripts/claude-lib/worktree-resolution/WorktreeRunRecordPath.Tests.ps1` — M1-M11, P1-P5, R1-R4, X1.
- `tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.RelativeRecord.Tests.ps1` — RR1-RR7, including the once-per-resolution and never-for-`pr_number` seam counts.
- `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.RelativeRecord.Tests.ps1`, `enforce-epic-worktree-removal-gate.RelativeRecord.Tests.ps1` — end-to-end allow, deny, ambiguity, diagnostics, and the interception probe required by the gate-suite isolation guard.
- `tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1` — "denies the relative-record case when ..." rows for both gates.
- `tests/scripts/claude-runtime/parallel-orchestrate-run-closing.Tests.ps1` — RC1-RC4 and RA1-RA4 over repository and bundle copies; RC4 tokenizes every backticked `git add`/`git commit` span and permits `git add -A`/`git add .` only inside a sentence containing `Never`.
- `evidence/qa-gates/assertion-preservation.2026-10-29T11-42.md` — two removed lines across 15 pre-existing suites, neither containing `Should`.
- `evidence/regression-testing/isolation.2026-10-29T11-44.md` — three seeded shuffles, 474 of 474 each.

### Quality assessment prompts

- **Determinism:** POSIX literals; filesystem seams mocked in module scope; `git` never mocked or invoked; seeded shuffles pass.
- **Isolation:** pre-existing suites gained `Get-WorktreeRunMainCheckoutRoot { $null }` mocks so no row reads the real repository.
- **Speed:** the matcher suite has no I/O; the nine-suite reviewer re-run completed in one process.
- **Diagnostics:** `-Because` on key assertions; deny-prefix assertions use `StartsWith`.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection; no credentials or tokens. |
| No unsafe subprocess or command construction | PASS | No new executable call; the main-root function uses the existing `Get-WorktreeItemLiveRoot` seam. |
| Input validation at boundaries | PASS | Unsafe relative records match nothing (M7, RR4, RP2, RE2); blank targets match nothing (M10). |
| Error handling remains explicit | PASS | Fail-closed ordering unchanged; deny prefixes unchanged; ambiguity still denies (RP3, RE3, RR5). |
| Configuration / path handling is safe | PASS | Separator and trailing-slash normalisation on record, target, and base root; manifest case-rule asymmetry recorded as Minor. |
| Least privilege for the agent | PASS | `Agent(pr-author)` is the only `pr-author` grant (Python contract test); the cleanup grant names one existing script. |
| No host paths in committed artifacts | PASS | Added-line scan for `C:/Users`, `C:\Users`, `/home/`, `AppData`: 0 matches. |

---

## Research Log

No external research was required. The review relied on the branch diff, the feature folder's research record and evidence, and repository policy files.

---

## Verdict

The change is ready for the normal PR flow. The matcher consolidation is correct, pure, and fully covered, and the fail-closed behavior of both gates is preserved and pinned by new negative cases. The Run Closing procedure is specified consistently in the skill and the agent and is guarded by content tests; its live behavior is deferred to LV1-LV4 by design. The four Minor findings (manifest case-rule asymmetry, the `artifacts/orchestration/` pathspec wording, an epic features-branch deny row, and the duplicated base-root helper) do not block merge; the orchestrator may fold them into a remediation cycle at its discretion. Merge remains subject to the S9 CI green gate on the final PR head.
