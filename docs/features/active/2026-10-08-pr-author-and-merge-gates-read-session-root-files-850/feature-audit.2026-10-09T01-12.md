# Feature Audit: pr-author and merge gates read session-root files (#850, bundled #788, #789, #851)

- Timestamp: 2026-10-09T01-12
- Reviewer: feature-review agent
- Blocking findings in this artifact: 0

## Scope and Baseline

- Branch: `bug/pr-author-and-merge-gates-read-session-root-files-exec-850`, head `e2f42811`.
- Base (epic mode): `origin/epic/enforcement-hook-precision-integration`, merge base `497cb504`.
- Diff: `git diff origin/epic/enforcement-hook-precision-integration...HEAD` (167 files; 10 production PowerShell files plus their 10 bundled mirrors and one new sibling mirror, `orchestrate/SKILL.md` and its mirror, `core.json`, fixtures, 19 test files, plan, spec, and evidence).
- Work mode marker in `issue.md`: `- Work Mode: full-bug`. AC source: `spec.md` only (`## Acceptance Criteria`, heading at line 204).
- Bundled scope: #788, #789 (CR-4, CR-5), #851 (diagnostics only). Codex gates are out of scope per the spec and are unchanged on the branch.
- Verification method: (a) reviewer re-ran the verifying Pester suites directly (701 tests, 0 failures), the three Python parity tests (25 passed), PSScriptAnalyzer and Invoke-Formatter (0 diagnostics, no format difference), mirror `cmp`, line counts, and the evidence-location validator; (b) reviewer read the diff for each AC's behavior; (c) executor evidence under `evidence/` was cross-checked where the reviewer did not re-run (coverage group runs).

Assumptions:

- The coverage figures for the new file `enforce-pr-author-skill.artifact-root.ps1` are taken from the executor's targeted Pester coverage run because the canonical `artifacts/pester/powershell-coverage.xml` does not list that file (policy-audit G-3). The reviewer cross-checked all other changed files against the canonical artifact and found them consistent with the evidence.
- The plan's dropped `.claude/rules/orchestrator-state.md` sentence (plan D4) is not an acceptance criterion and is recorded as a gap, not a FAIL.

## Acceptance Criteria Inventory

- Source: `docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/spec.md`
- Total AC items: 47 (AC-01 to AC-47 in spec order; spec lines 210-223, 227-237, 241-244, 248-249, 253-255, 259-262, 266-269, 273-277)
- Checked at review start: 47
- Groups: #850 pr-author gate (AC-01 to AC-14), #850 merge gate (AC-15 to AC-25), #788 (AC-26 to AC-29), #789 CR-4 (AC-30, AC-31), #789 CR-5 (AC-32 to AC-34), #851 (AC-35 to AC-38), mirrors and parity (AC-39 to AC-42), constraints (AC-43 to AC-47).

## Acceptance Criteria Evaluation

Reviewer runs referenced below: RUN-A = 8 new and CR suites, 140 passed / 0 failed; RUN-B = 23 existing edited and guard suites, 561 passed / 0 failed; PYT = 3 parity test files, 25 passed.

| AC | Spec line | Criterion (short) | Verdict | Evidence |
|---|---|---|---|---|
| AC-01 | 210 | Two-worktree allow for OtherWorktree with artifacts only in item worktree | PASS | ItemArtifactRoot row passed in RUN-A; diff: `Resolve-PrAuthorArtifactRoot` + absolute-path seams. `evidence/regression-testing/pr-author-artifact-root-pass-after.2026-10-09T00-38.md` |
| AC-02 | 211 | Session-root artifacts ignored; deny `PR_CONTEXT_MISSING` naming item worktree | PASS | Row passed in RUN-A; Case C text `PR_CONTEXT_MISSING: '...' in worktree '<root>' is absent.` in helpers diff |
| AC-03 | 212 | Four seams receive paths beneath `/synthetic-worktrees/item-a/artifacts/` | PASS | Row passed in RUN-A (path capture via `Set-ArtifactSeamCapture`) |
| AC-04 | 213 | Receipt freshness compared against item-root summary | PASS | Row passed in RUN-A; `Get-PrContextSummaryLastWriteUtc -Path $summaryPath` composed beneath `$ArtifactRoot` |
| AC-05 | 214 | Target resolved once; checkpoint reused for preflight and Check 6 | PASS | Row passed in RUN-A (`-Times 1 -Exactly`); single `Resolve-PrAuthorArtifactRoot` call in `Get-PrAuthorBypassReason` |
| AC-06 | 215 | Unresolvable target denies with no-target code ahead of `PR_CONTEXT_MISSING`, no preflight | PASS | Row passed in RUN-A; `if ($artifact.Reason) { return ... }` precedes Case C |
| AC-07 | 216 | Ambiguous target denies with ambiguity code ahead of `PR_CONTEXT_MISSING`, no preflight | PASS | Row passed in RUN-A |
| AC-08 | 217 | Relative body path for OtherWorktree denied with `PR_BODY_PATH_NONCANONICAL` naming absolute path | PASS | Row passed in RUN-A; `Get-PrAuthorBodyPathBindingReason` lines 181-186 |
| AC-09 | 218 | Absolute body path outside resolved root denied | PASS | Row passed in RUN-A |
| AC-10 | 219 | Drive/UNC case-insensitive, POSIX case-sensitive body comparison | PASS | Row passed in RUN-A; `Test-PrAuthorBodyPathEqual` regex `^([A-Za-z]:|//)` |
| AC-11 | 220 | SessionRoot keeps relative literal; seams get absolute paths | PASS | Row passed in RUN-A |
| AC-12 | 221 | Epic scope reads artifacts beneath epic checkpoint worktree | PASS | Row passed in RUN-A; `Get-PrAuthorEpicArtifactRoot` strips `Get-EpicScopeCheckpointRelativePath` suffix |
| AC-13 | 222 | Commands without `--body-file` do no resolution | PASS | Row passed in RUN-A; Cases A/B and `gh pr edit` no-body return before resolution (helpers lines 363-379) |
| AC-14 | 223 | Updated existing pr-author suites and `OrchestratorState.Tests.ps1` pass | PASS | All six suites in RUN-B, 0 failures. `evidence/qa-gates/pester-set-pra-p6.2026-10-09T00-38.md` |
| AC-15 | 227 | Resolver matches `pr_gate.pr_number` | PASS | PrNumber row passed in RUN-A |
| AC-16 | 228 | Resolver matches positive-integer standalone `pr_number` | PASS | PrNumber row passed in RUN-A |
| AC-17 | 229 | NoTarget / Ambiguous with reason codes | PASS | Both rows passed in RUN-A |
| AC-18 | 230 | Reads only through checkpoint-text seam; export set = prior + resolver | PASS | Both rows passed in RUN-A; `Export-ModuleMember` diff adds one name |
| AC-19 | 231 | Two-worktree standalone allow reads item-a checkpoint, not session root | PASS | Merge ItemResolution row passed in RUN-A (`Should -Invoke ... -Times 0` for session path) |
| AC-20 | 232 | Stale session-root copy cannot authorize; deny with ambiguity code | PASS | Row passed in RUN-A |
| AC-21 | 233 | Unresolvable item target denies with no-target code and item detail | PASS | Row passed in RUN-A (asserts `pull request 812 is recorded in pr_gate.pr_number`) |
| AC-22 | 234 | Ambiguous item target denies; ambiguity precedes no-target | PASS | Row passed in RUN-A; `Get-EpicMergeGateUnresolvedReason` selects first Ambiguous target |
| AC-23 | 235 | Module-scoped WIR mocks observed after dot-sourcing | PASS | Row passed in RUN-A; second guarded `Import-Module` in MRGR |
| AC-24 | 236 | Bare merge reads session root, no item resolution | PASS | M6 passed in RUN-B; ItemResolution row passed in RUN-A |
| AC-25 | 237 | Updated existing merge-gate suites pass | PASS | All six suites in RUN-B, 0 failures. `evidence/qa-gates/pester-set-mrg-p5.2026-10-09T00-23.md` |
| AC-26 | 241 | Explicit number with no `pr_gate`/standalone denies (M5 flipped) | PASS | M5 (now deny) passed in RUN-B; ItemResolution row passed in RUN-A |
| AC-27 | 242 | PR number differing from `pr_gate` denies | PASS | Row passed in RUN-A; M3 passed in RUN-B |
| AC-28 | 243 | Binding function truth table | PASS | Context "child checkpoint pull request binding" passed in RUN-A (one uncovered fail-closed branch noted in code-review, not part of this AC's enumerated cases) |
| AC-29 | 244 | Binding re-checked on checkpoint the gate reads | PASS | Row passed in RUN-A; `Test-ChildCheckpointPrGateBinding` runs on `$childCheckpoint` read by the gate |
| AC-30 | 248 | UNC case-insensitive record match (B14) | PASS | B14 passed in RUN-A |
| AC-31 | 249 | Drive insensitive, POSIX sensitive, export set unchanged (B11, B12, X1) | PASS | Record suite passed in RUN-A; WRR diff is a 3-line in-place change |
| AC-32 | 253 | Parallel gate single leading token (Y7) | PASS | Y7 passed in RUN-A |
| AC-33 | 254 | Parallel resolved-target text byte-identical; exact-text row and Y3 unmodified | PASS | `enforce-parallel-worktree-removal-gate.Tests.ps1` absent from diff; Y3 untouched in the WorktreeResolution diff (only Y7 appended); both suites passed in RUN-A |
| AC-34 | 255 | Epic removal gate single leading token | PASS | Diagnostics row passed in RUN-A |
| AC-35 | 259 | Deny names each run kind's status and checkpoint path | PASS | Row passed in RUN-A |
| AC-36 | 260 | Deny names `merge_status`, no-match, or absent/unparseable | PASS | Three rows passed in RUN-A |
| AC-37 | 261 | Pure builder in resolution sibling; read result exposes `Path` | PASS | Context passed in RUN-A; diff adds `Path` to `Read-EpicWorktreeGateRunCheckpoint` |
| AC-38 | 262 | Removal decisions unchanged; exact-text row only appended | PASS | EREM Tests, TriggerScoping, WorktreeResolution, CleanupWorktreeManifestGateMatrix passed in RUN-B; the only EREM Tests diff is one `$expected +=` line |
| AC-39 | 266 | Changed `.claude` files byte-identical to mirrors | PASS | Reviewer `cmp` on 11 files: all identical; PYT passed |
| AC-40 | 267 | Pack manifest complete | PASS | `test_push_down_claude_pack_manifest_completeness.py` passed in PYT; `core.json` lists the new sibling |
| AC-41 | 268 | Worktree-resolution modules registered and SHA-identical | PASS | `WorktreeResolution.Manifest.Tests.ps1` passed in RUN-B |
| AC-42 | 269 | Codex gates and mirrors unchanged | PASS | No `.codex` or codex mirror file in diff; `test_push_down_codex_and_agents_resource_contracts.py` passed in PYT |
| AC-43 | 273 | No enforcement hook invokes Python | PASS | `enforcement-hooks-no-python-invocation.Tests.ps1` passed in RUN-B; grep of changed hooks empty |
| AC-44 | 274 | No changed PowerShell file exceeds 500 lines | PASS | Constraints row passed in RUN-A; `wc -l` maximum 498 |
| AC-45 | 275 | No temporary files, no host paths in changed suites | PASS | Constraints row passed in RUN-A; `evidence/qa-gates/added-lines-scan.2026-10-09T01-00.md` |
| AC-46 | 276 | Line coverage >= 85% per changed production file, numeric | PASS | Lowest 90.00% (MRGR); new file 96.55%; `evidence/qa-gates/coverage-comparison.2026-10-09T01-02.md`; canonical artifact cross-check in policy audit section 1.2.2 |
| AC-47 | 277 | Epic gate-suite isolation guard includes the new pr-author suite | PASS | `enforce-gate-suites.EpicStateIsolation.Tests.ps1` passed in RUN-B; diff adds `ItemArtifactRoot` to its list |

## Summary

All 47 acceptance criteria evaluate PASS against reviewer-reproduced test results and code inspection. No criterion was found unmet. No Blocking finding exists in this artifact.

Non-blocking items carried from the other artifacts:

- P8-T3 (plan task, not an AC) remains unchecked: the MCP PoshQC test reported one failure, a pre-existing, environment-specific Codex wave-barrier row identical to the Phase 0 baseline. Non-blocking.
- The spec's in-scope sentence for `.claude/rules/orchestrator-state.md` was not delivered because the file is a policy document (plan D4). No AC depends on it; it needs an explicit user decision.
- Pre-existing failures outside the diff: 38 rows in `OrchestratorStateIssueAdoption.Tests.ps1` on the epic base.
- Recommended follow-ups: guard the `[int]` body-number cast against overflow (pre-existing fail-open edge), and add a row for the unparseable `pr_gate.pr_number` branch.

Baseline comparison: relative to the base, the pr-author gate no longer reads PR artifacts from the process directory, the merge gate no longer reads the per-feature checkpoint from the session root for an explicit PR number, and the accepted behavior changes in the spec (fail-closed #788 binding, resolution reason ahead of `PR_CONTEXT_MISSING`, relative body denied for OtherWorktree) are each covered by a passing row.

## Acceptance Criteria Check-off

- No AC was newly checked off by this review: all 47 items were already `- [x]` in `spec.md`, and each evaluated PASS, so each check mark is confirmed.
- No AC was unchecked; none evaluated PARTIAL, FAIL, or UNVERIFIED.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/spec.md`
- Total AC items: 47
- Checked off (delivered): 47
- Remaining (unchecked): 0
- Items remaining: none
