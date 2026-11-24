# Research: Epic-level child CI opt-out (`child_ci: integration_only`) - Issue #1233

- Issue: #1233
- Branch: feature/epic-child-ci-opt-out-1233
- Feature folder: .dev/active/1233-epic-child-ci-opt-out
- Timestamp: 2026-11-24T04-02 (UTC, read from an external time service because the researcher has no shell clock; see Evidence bullet of the Pre-Mortem)

## 1. Scope and Summary

The owner directed that an epic may opt out of per-child CI: children merge into `epic/<slug>-integration` without a `CI` run on the child head, and CI runs only on the integration-to-`main` pull request. The owner chose to change the gate, not to bypass it. The recommended design adds a key-gated opt-out read from the per-feature (item) checkpoint, verified in the existing byte-identical child-CI helper, plus a new `local_qc_gate` checkpoint object that replaces `ci_gate` for completion only under the opt-out. Every surface without the key keeps today's behavior.

One premise in `issue.md` does not hold for this repository: `.github/workflows/ci.yml` triggers on `pull_request` into `epic/**` (`on.pull_request.branches: [main, development, "epic/**"]`, and `.github/workflows/README.md` `## Triggers` states this was added by issue #658). In this repository a child pull request therefore starts a `CI` run automatically; the opt-out stops the gate and S9 from waiting for or dispatching CI, but does not stop that automatic run. Section 9 gives the recommended handling.

## 2. Current State (verified)

### 2.1 Merge gate, Claude (`.claude/hooks/enforce-epic-merge-gate.ps1`)

- `Invoke-EpicMergeGateDecision` reads only the item checkpoint for branch 1. With an explicit PR number, `Resolve-EpicMergeGateItemTarget` (in `enforce-epic-merge-gate-resolution.ps1`) locates the live worktree whose `artifacts/orchestration/orchestrator-state.json` records the number in `pr_gate.pr_number` or a standalone record; a bare command reads the session worktree. The epic checkpoint `artifacts/orchestration/epic-orchestrator-state.json` is read only later, for branch 2 (`Test-EpicCheckpointAllowsMerge`, `epic_merge_pr.ci_gate.conclusion`), through `Resolve-EpicMergeGateRunTarget -Kind epic`, which matches `features[]`/`epic_merge_pr` records by PR number.
- Order: review shape rule and review guard (`Get-EpicMergeGateReviewShapeDecision`, `Get-EpicMergeGateReviewDecision`, GhRoot = session root, GitRoot = item root), then `Get-EpicMergeGateRegenerationDecision`, then branch 1.
- An epic child is identified by `Test-ChildCheckpointAllowsEpicMerge` (JSON boolean `epic_mode` true and `step9_status` exactly `passed`) plus `Test-ChildCheckpointPrGateBinding`. Branch 1 then calls `Get-EpicMergeGateChildCiDecision -Checkpoint -CommandPrNumber -GhRoot $sessionRoot`, and a failure denies without fall-through.
- The PR base is never read by branch 1 today. The child checkpoint records `epic_context.integration_branch` (written at the first checkpoint write per `## Merge-on-Green Kickoff Parameter` of `.claude/skills/epic-orchestrate/SKILL.md`), which `enforce-pr-author-skill.epic-base-branch.ps1` already uses to require `--base <integration_branch>` on `gh pr create`.

### 2.2 Merge gate, Codex (`.codex/hooks/enforce-epic-merge-gate.ps1`)

- Reads the child checkpoint and the epic checkpoint only at the repository root of the hook script (`Split-Path (Split-Path $PSScriptRoot -Parent) -Parent`); there is no worktree resolution.
- `Test-CodexChildMergeReady` accepts `step9_status` `passed` or `verified`; then `Get-EpicMergeGateChildCiDecision -GhRoot $RepositoryRoot`. No PR binding exists on Codex.
- Registered in `.codex/hooks/pretooluse-dispatch.json` with `"timeout": 30`.

### 2.3 Child-CI helper (`enforce-epic-merge-gate-child-ci.ps1`, 316 lines, byte-identical in `.claude/hooks/` and `.codex/hooks/`)

- Six stages in `Get-EpicMergeGateChildCiFailureDetail`; seams `Get-EpicMergeGateChildCiLiveHeadSha` (one `gh pr view <PR> --json headRefOid`) and `Get-EpicMergeGateChildCiRunList` (one `gh run list --commit`). Deny prefix `$script:EpicMergeGateChildCiReasonPrefix` = `EPIC_MERGE_GATE_BLOCKED: EPIC_CHILD_CI_NOT_VERIFIED: `.
- The helper dot-sources nothing; it calls `Invoke-DocsOnlyGhExe` from `hook-docs-only-diff.ps1` (gh bound 7000 ms, git bound 3000 ms, each plus at most 1000 ms for output).

### 2.4 Review guard (`enforce-epic-merge-gate-review.ps1`, byte-identical)

- Inert unless `Test-EpicMergeGateReviewModeConcurrent` (top-level `review_mode` exactly `concurrent`). Under the key it requires the last `remediation_loop.review_outcomes[]` entry to be `PASS` with a full lowercase `head_sha` that is current: equal to the live head, or an ancestor whose diff to the live head lists only `feature-folder` paths (`Get-EpicMergeGateReviewHeadState`). It runs before every allow branch, so when branch 1 is reached under the key, a PASS review at a current head has already been verified.
- Sequential review outcomes carry no `head_sha` (only concurrent runs record it, `## Concurrent Review and CI (review_mode)` item 4 of the orchestrate skill), so "the existing review guard at a current head" is only meaningful under `review_mode: "concurrent"`.

### 2.5 Regeneration check (`enforce-epic-merge-gate-regeneration.ps1`, byte-identical)

Runs after the review guard; inert unless the last outcome has `review_kind: "regeneration_delta"`. Unaffected by this feature.

### 2.6 Completion-consistency hooks (not named in the delegation, but on the critical path)

- `.claude/hooks/enforce-completion-consistency.ps1` (508 lines) and `.codex/hooks/enforce-completion-consistency.ps1` (499 lines, not byte-identical) deny a checkpoint Write that asserts completion (`next_step: complete`, `S12_complete`, or step 8/9/10 `completed`) unless `Get-MissingCompletionEvidence` finds a `ci_gate` object with `conclusion` `success` and a non-empty `head_sha`. Both dot-source the byte-identical `enforce-completion-helpers.ps1` (in `$script:IdenticalHelpers` of `tests/scripts/codex-hooks/cross-tree-helper-identity.Tests.ps1`).
- Without a key-gated change, an opted-out child can never write its DONE checkpoint. This is a required file family.

### 2.7 Validators

- Python authority `scripts/dev_tools/validate_orchestrator_state.py` (433 lines): under `require_complete`, `if route_requires_ci_gate(state_map): errors.extend(_validate_completion_ci_gate(state_map))`. `_validate_completion_ci_gate` requires `CI_GATE_KEYS = ("conclusion", "head_sha", "verified_at")`, `conclusion == "success"`, and `ci_gate.head_sha == pr_gate.head_sha` when `pr_gate.head_sha` is present. No code reads `epic_mode`. `collect_completion_blocking_step_errors` (`_orchestrator_state_step_status.py`) accepts `step9_status: passed`.
- TypeScript port: `extensions/drm-copilot/src/lib/validate/orchestrator-state-completion.ts` (`validateCompletionCiGate`, byte-identical strings) called from `orchestrator-state-core.ts` under `routeRequiresCiGate`. `orchestrator-state-completion.ts` has no per-file `coverageThreshold` entry in `extensions/drm-copilot/jest.config.cjs`; `orchestrator-state-core.ts` and `orchestrator-state-concurrent-review.ts` do. No port exists under `packages/mcp-server`.
- PowerShell port: `Get-OrchestratorStateCompletionCiGateError` in `.claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1` (467 lines), composed by `Test-OrchestratorStateCompletionReadiness` in `OrchestratorStateCompletion.psm1`, which the Claude stop hook reaches through `validate-orchestrator-output-routing.ps1`. Bundle copy under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/`.
- Epic checkpoint validator `scripts/dev_tools/validate_epic_orchestrator_state.py`: `features[]` entries are checked for `feature_folder` uniqueness, `depends_on` resolution, `merge_status` enum (includes `ci_green`), wave-barrier ordering, and, under `require_complete`, `merged`/`worktree_removed` plus `epic_merge_pr.merge_commit_sha`. It reads no per-feature CI and tolerates unknown top-level keys, so an epic-level `child_ci` key needs no validator change.
- Shared corpus precedent: `tests/fixtures/orchestrator_state_concurrent_review/*.json` (`{name, notes, checkpoint, expected_errors}`), read by `tests/scripts/dev_tools/test_orchestrator_state_concurrent_review.py` (`MINIMUM_CORPUS_COUNT = 12`), `extensions/drm-copilot/test/lib/validate/orchestrator-state-concurrent-review.test.ts`, and `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateConcurrentReview.Tests.ps1`.

### 2.8 Skills and manifest

- Orchestrate (Claude, native): `## Step S9 - CI Green Gate` (epic-child rule, dispatch fallback, step 6 merge), `## Checkpoint Schema - CI Gate Fields`, `## PR Creation Gate` condition 6. Codex copy `.agents/skills/orchestrate/SKILL.md` (shared parity group, separate text): `## CI Green Gate` step 5 dispatch fallback and the `ci_gate` paragraph, `## PR Creation Gate` condition 5.
- `.claude/skills/epic-orchestrate/SKILL.md` (native) and `.agents/skills/epic-orchestrate/SKILL.md` (separate text): manifest frontmatter schema (`## Epic Dependency Manifest` / `## Manifest Contract`), the epic-mode kickoff line and the `Epic-child CI verification (issue #1130)` paragraph (`## Merge-on-Green Kickoff Parameter`; Codex: `## Fan-In and Conflict Handling`), `## Epic-Level Checkpoint`, lifecycle step 6 (integration PR).
- `.claude/skills/epic-run/SKILL.md` and `.agents/skills/epic-run/SKILL.md`: one sentence each that a child merge requires a green `CI` run.
- `.claude/skills/epic-plan/SKILL.md` is generated from `.agents/skills/epic-plan/SKILL.md` with `scripts/harness-generation/sources/skills/epic-plan.substitutions.json` (`config/harness-parity-matrix.json`, `claude:skill:epic-plan`, disposition `generated`).
- Manifest template: `.dev/templates/epic/epic.md`, bundled as `extensions/drm-copilot/resources/feature-templates/epic/epic.md`. No machine validator rejects unknown frontmatter keys (`EpicWave.psm1` and `EpicCrossDependency.psm1` parse `features` and `cross_epic_depends_on` only; `epic_planner_readiness.py` checks presence and commit of the manifest only).
- The epic-mode kickoff literal is pinned as a prefix by `ESS-KICKOFF-LITERAL-INTACT` in `tests/scripts/claude-runtime/early-start-skill-contract.Tests.ps1`; the Codex launch contract (`.codex/scripts/epic-child-launch-contract.ps1`) checks required substrings only, so an extra prompt line is tolerated.

### 2.9 Generated rule and brief

- `.claude/rules/orchestrator-state.md` is generated from `scripts/harness-generation/sources/rules/orchestrator-state.md` plus `orchestrator-state.json` (sections are `<!-- harness-section: <id> -->` blocks listed in the JSON `sections` array; the Claude target lists `epic-child-ci-verification-issue-1130`; the Codex target `.agents/skills/orchestrator-state/SKILL.md` does not include the epic-child sections). Bundle copy under `extensions/drm-copilot/resources/claude-customizations/.claude/rules/`.
- The execution-environment brief: `.claude/skills/execution-environment/SKILL.md` is generated from `.agents/skills/execution-environment/SKILL.md` (`claude:skill:execution-environment`); the four byte-identical copies are the two above plus the two bundle copies. Affected bullets: `## Hook Execution Context` "Child-CI helper (#1130)" and `## CI Shape and Required Checks` "Epic-child dispatch (#1130)". No test pins either bullet's text (grep of `tests/` for `Child-CI helper` and `Epic-child dispatch` finds only the two child-CI Pester suites, which pin the deny code).
- Copilot `.github/` surfaces: no file under `.github/` describes the epic-child CI rule (grep for `EPIC_CHILD_CI_NOT_VERIFIED`, `1130`, `epic child` finds only `.github/workflows/README.md` line on the `epic/**` trigger). Nothing to update unless the trigger changes (Section 9, option B).

### 2.10 Frozen-surface pin

`PINNED_FROZEN_SURFACE_HASHES` in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` pins `.claude/agents/epic-orchestrator.md` and `.claude/skills/epic-orchestrate/SKILL.md`, consumed by `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py`. A legitimate change appends a `# RE-BASELINED by issue #1233 ...` comment paragraph naming the edited sections and which digest moved, and replaces the digest with the SHA-256 of the new bytes (recomputed after any later main merge). The epic-orchestrator agent has no child-CI text (grep of `.claude/agents` and `.codex/agents`), so only the skill digest moves. The agent source `scripts/harness-generation/sources/agents/epic-orchestrator.md` is not touched.

### 2.11 Process-reduction ledger

`.dev/engineering/process-reductions/README.md`: entry file `NNNN-<short-name>.md` (next free number today is `0014`) with `## Summary` (`reduction: NNNN`, `Date:`, `Issue:`, `Merge commit: pending (PR #N)`), `## Reason and Evidence`, `## Files Changed` (every path incl. mirrors, bundles, pins, contract tests), `## Prior Text` (`### Revert Block: <path>` with `Current`/`Prior` fences; `Current` must occur exactly once) and/or `## Stored Patch` (`patches/NNNN-<short-name>.patch`), `## Revert Steps` with the six fixed labels, `## Revert Signals`, plus the index row. `tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1` replays every entry newest-first and fails when a block's `Current` or a hunk with its context no longer applies.

Ledger regions on files this feature edits (verified by grep of `### Revert Block:` and `diff --git` in the ledger):

- `0002`: blocks covering the whole `## Concurrent Review and CI (review_mode)` section of both orchestrate skills, the whole `## Concurrent-Review Scope and Backward Compatibility` section of `.claude/rules/orchestrator-state.md`, and two single lines of `validate_orchestrator_state.py` (the `_orchestrator_state_concurrent_review` import and `errors.extend(validate_concurrent_review_completion(state_map))`).
- `0003`, `0011`: blocks in orchestrate `## Post-Review Outcome Evaluation`, `## Remediation Loop (R1-R5)`, and `## Delegation Model`.
- `0009` patch: hunks in the concurrent section (item 11) of both orchestrate skills.
- `0007`: blocks on lifecycle step 3 of both epic-orchestrate skills.
- `0010` patch: hunks on both epic-orchestrate skills (the `## Early Dependent Starts` section and its context), both epic-run skills (context lines include the #1130 child-CI sentence), the pin file, and `jest.config.cjs` (with `0002`/`0003` blocks there too).

Consequence: none of the existing sentences inside these regions may be edited. The opt-out text must be added outside them, as new paragraphs that qualify the existing rule.

## 3. Candidate Approaches

### A. Gate input from the item checkpoint, verified in the child-CI helper (recommended)

- The child records `child_ci: "integration_only"` in its own checkpoint at the first write (relayed from the epic checkpoint through the delegation prompt), and the existing helper branches on it. Advantages: both gates already read the item checkpoint; the helper is byte-identical, so Claude and Codex get one implementation; no new resolution on Codex (which has none). Limitations: the key is self-declared by the child checkpoint (same-session forgery, the accepted policy-level limit of every gate key, decision D10); mitigated by the live base check and the review and local-QC predicates.

### B. Gate input from the epic checkpoint

- The gate resolves the epic checkpoint by `epic_context.integration_branch` (`Resolve-WorktreeEpicTarget` in `WorktreeRunResolution.psm1`) and reads `child_ci` there. Rejected: Claude-only (the Codex gate has no worktree resolution and reads only its root), adds worktree listing and checkpoint reads to the merge path, and depends on the epic coordinator's worktree being live.

### C. Write `ci_gate` with a non-CI conclusion

- Rejected: every consumer of `ci_gate.conclusion` (`enforce-completion-consistency.ps1`, the PR Creation Gate, the green-CI branch, the validators) would need to learn a new value, and it risks reading missing CI as green.

## 4. Recommended Design

### 4.1 Keys

- Epic manifest (frontmatter of `.dev/epics/<slug>/epic.md`): optional top-level `child_ci: per_child | integration_only`; absent means `per_child`. A present value other than these two is a malformed manifest, rejected before kickoff as a synthetic Blocking finding (skill rule, like an unresolved `depends_on`).
- Epic checkpoint: top-level `child_ci`, copied from the manifest at kickoff by `epic-orchestrator`. Tolerated by all epic validators (no code change).
- Item checkpoint: top-level `child_ci: "integration_only"` written at the child's first checkpoint write when the delegation prompt carries the separate line `Child CI: integration_only.` (a separate line, so the pinned kickoff literal is unchanged). Absent or any other value means `per_child`.
- Item checkpoint: `local_qc_gate: { conclusion, head_sha, evidence_path, verified_at }` written by S9 under the opt-out. `ci_gate` stays absent, so missing CI is never read as green.

Activation predicate (identical in hooks and validators): `epic_mode` is the JSON boolean `true` AND `child_ci` is the string `integration_only` (ordinal). The gate adds: `epic_context.integration_branch` is a string matching `^epic/[A-Za-z0-9][A-Za-z0-9._-]*-integration$`.

### 4.2 Merge gate (helper change, both runtimes)

Inside `Get-EpicMergeGateChildCiFailureDetail`, after stage 1 (PR number), when the activation predicate holds:

1. Stage B (base): one bounded `gh pr view <PR> --json headRefOid,baseRefName` through a new seam `Get-EpicMergeGateChildCiLivePullRequest` (returns head and base, or `$null`). A `$null` result denies. When the live base is not exactly `epic_context.integration_branch`, or is `main`, the opt-out is not applied and stages 2 to 6 run unchanged (fall back to per-child CI verification, which is today's behavior for that checkpoint). This guarantees the opt-out never applies to a pull request whose base is `main`: the base must equal a recorded value that matches the integration-branch pattern, which `main` cannot match, and it is also compared ordinally with `main`.
2. Stage R (review): `Test-EpicMergeGateReviewModeConcurrent` must hold. Because the review guard runs before branch 1 under that key, reaching this point proves a `PASS` review at a current head. Without the key, deny.
3. Stage L1 (record): `local_qc_gate` is an object; `conclusion` exactly `success`; `head_sha` a lowercase 40/64-character object id; `evidence_path` a clean relative path that starts with `<feature-folder>/evidence/qa-gates/` and ends with `.md` (no backslash, empty, `.` or `..` segment; `feature-folder` validated by `Test-EpicMergeGateReviewFeatureFolder`).
4. Stage L2 (binding): `local_qc_gate.head_sha` equals, ordinally, the `head_sha` of the last `review_outcomes[]` entry. The guard already proved that head current, so no extra ancestry or diff git call is needed.
5. Stage L3 (evidence at the live head): one bounded `git cat-file -p <live head>:<evidence_path>` through `Invoke-DocsOnlyGitExe` (GitRoot): exit 0; the first `EXIT_CODE:` line has value `0` (first-occurrence rule of the evidence schema); the text holds a `Timestamp:` line and the line `Head: <local_qc_gate.head_sha>`.

Every failure in stages B (lookup), R, and L returns `EPIC_MERGE_GATE_BLOCKED: EPIC_CHILD_LOCAL_QC_NOT_VERIFIED: stage <id> (<name>): <detail>` (new prefix constant), with no fall-through to later branches. Without the key, the helper is unchanged and the new seam is never called.

Parameter change: `Get-EpicMergeGateChildCiDecision` gains an optional `-GitRoot` that defaults to `GhRoot`. The Claude gate passes `-GitRoot $childRoot` (the item worktree, as for the review guard); the Codex gate needs no call change (gh and git both run in the repository root).

Timing (Codex 30 s registration): worst case under the opt-out is the review guard (one gh, up to two git: 16 s) plus stage B (one gh: 8 s) plus stage L3 (one git: 4 s), 28 s. Stage L2 deliberately reuses the guard's head proof to stay under 30 s.

"Local final-QC evidence at the live head" therefore means: a summary artifact `<feature-folder>/evidence/qa-gates/local-qc-gate.<timestamp>.md`, written by the child orchestrator at S9 from the final QA artifacts, committed on the PR branch so that it exists in the live head tree, naming the reviewed head, with `EXIT_CODE: 0`. Its commit is feature-folder-only, so it does not make the review stale.

### 4.3 Completion-consistency hooks

Add to `enforce-completion-helpers.ps1` (byte-identical, both runtimes) a pure `Test-CompletionChildCiIntegrationOnly` and `Get-CompletionLocalQcGateMissing`. In both `Get-MissingCompletionEvidence` functions, under the predicate, replace the `ci_gate` evidence check with `local_qc_gate` evidence (object, `conclusion` `success`, non-empty `head_sha` and `evidence_path`) and skip the `ci_gate.head_sha`/`pr_gate.head_sha` comparison. The deny reason gains the `local_qc_gate` alternative only in the opt-out branch, so every existing deny text without the key is unchanged.

### 4.4 Validators (three runtimes, byte-identical strings)

Under `require_complete`, within the existing `route_requires_ci_gate` branch, the opt-out predicate selects a local-QC check instead of `_validate_completion_ci_gate`. Errors, in order:

1. `Checkpoint completion validation failed: child_ci integration_only requires local_qc_gate to be an object with keys: conclusion, head_sha, evidence_path, verified_at.` (returns alone)
2. `Checkpoint completion validation failed: local_qc_gate missing required fields: <keys>.`
3. `Checkpoint completion validation failed: local_qc_gate.conclusion must be success.`
4. `Checkpoint completion validation failed: child_ci integration_only requires review_mode concurrent.`
5. `Checkpoint completion validation failed: local_qc_gate.head_sha must match the head_sha of the last review_outcomes entry.` (only when rule 4 passes)

The existing concurrent-review completion rule then still requires the last `PASS` with `head_sha`. The same checkpoint without the opt-out reports the existing `ci_gate` errors, which satisfies "reject the same checkpoint when the opt-out is absent".

- Python: inline in `scripts/dev_tools/validate_orchestrator_state.py` (no new module), edited only in the `route_requires_ci_gate` block and new private helpers; do not touch the two lines that `0002` records. Estimated result about 470 lines.
- TypeScript: new `extensions/drm-copilot/src/lib/validate/orchestrator-state-child-ci.ts` (precedent: `orchestrator-state-concurrent-review.ts`) with its own `coverageThreshold` entry placed outside the `0002`, `0003`, and `0010` regions of `jest.config.cjs`; `orchestrator-state-core.ts` selects it.
- PowerShell: inside `Get-OrchestratorStateCompletionCiGateError` (select local-QC errors under the predicate), so `OrchestratorStateCompletion.psm1` is unchanged; the module grows past 500 lines (guidance tier only).
- Corpus: `tests/fixtures/orchestrator_state_child_ci/*.json` in the concurrent-review shape, read by all three runtimes with a corpus-count floor.

### 4.5 Skills (procedure)

- Orchestrate (Claude and Codex), new paragraph `Child CI opt-out (issue #1233)` at the end of S9 / `## CI Green Gate` (outside every ledger region): under the predicate S9 resolves head and base with `gh pr view --json headRefOid,baseRefName`; if the base is not `epic_context.integration_branch`, the opt-out does not apply. Otherwise S9 does not query checks as a gate, never dispatches `CI`, writes and commits the `local-qc-gate.<timestamp>.md` summary, records `local_qc_gate` and `step9_status: "passed"`, and step 6 merges. The opt-out requires `review_mode: "concurrent"`; a resumed sequential run stays `per_child`. The paragraph also states that, under the opt-out, the join's CI conditions (item 5 of `## Concurrent Review and CI (review_mode)`) are met by `local_qc_gate` and that item 11 compares cross-check rows with the local final-QC evidence, not with `gh pr checks` (a check that is not reported is not a mismatch). CI-dependent acceptance criteria are listed as pending integration CI and do not block the child's DONE.
- `## Checkpoint Schema - CI Gate Fields`: add `child_ci` and `local_qc_gate`. `## PR Creation Gate` condition 6 (Codex: 5): add the `local_qc_gate` alternative under the predicate.
- Epic-orchestrate (Claude and Codex): manifest key and validation; copy to epic checkpoint; the extra kickoff line; a qualifying paragraph after the #1130 paragraph (no child dispatch, no `ci_green` status for an opted-out child, which moves `pr_open` to `merged`); `## Epic-Level Checkpoint` field list; lifecycle step 6 note that the integration PR S9 is unchanged and that child CI-dependent criteria are checked off in the integration worktree under the merged-feature follow-up allowance (issue #1141) after integration CI is green. Re-baseline the skill digest.
- Epic-run (both): one new sentence outside the `0010` hunk context that the requirement is replaced under `child_ci: integration_only`.
- Epic-plan (edit `.agents` source, regenerate `.claude`): the planner writes `child_ci` only when the owner chose the opt-out, and avoids CI-dependent child criteria or marks them pending integration CI.
- Rule source: new section `epic-child-ci-opt-out-issue-1233` after `epic-child-ci-verification-issue-1130` (added to the Claude target `sections` list), plus one Enforcement bullet; regenerate.
- Brief (edit `.agents` source, regenerate `.claude`, copy both bundles): extend the two #1130 bullets; add an MCP-route note (installed MCP lacks the TypeScript rule until an extension release, so an opted-out child checkpoint is checked with the repository Python CLI on Claude and the opt-out is unavailable on Codex until then); add the new contract test to `## Contract Tests That Pin Mirrored Files`.
- Template: `.dev/templates/epic/epic.md` and its `feature-templates` bundle copy gain the commented optional `child_ci` key.

## 5. Behavior Semantics and Edge Cases

- Key absent, `per_child`, a case variant, a non-string, or `epic_mode` not JSON `true`: today's behavior in every surface; the new seam starts no process.
- Opt-out with live base equal to `main` or any branch other than the recorded integration branch: per-child CI verification (stages 2 to 6).
- Opt-out with `epic_context.integration_branch` missing or malformed: predicate false at the gate, per-child CI verification.
- Opt-out without `review_mode: "concurrent"`: deny `EPIC_CHILD_LOCAL_QC_NOT_VERIFIED` (stage R); validators report error 4.
- Review stale after a code push: the review guard denies first (`REVIEW_GATE_HEAD_STALE`), unchanged.
- Evidence file missing at live head, `EXIT_CODE` not 0, or `Head:` mismatch: deny stage L3.
- Integration PR into `main`: branch 2 on the epic checkpoint, unchanged; a `child_ci` key on the epic checkpoint has no effect on branch 2.
- Bare `gh pr merge` command: stage 1 uses `pr_gate.pr_number`, as today.

## 6. Requirements Mapping

| Draft AC | Design element |
|---|---|
| Opt-out allows child merge without CI; default unchanged | 4.2 stages B, R, L1-L3; activation predicate; zero new calls without key |
| Never applies to a base of `main` | 4.2 stage B (recorded integration branch, pattern, ordinal `main` check, fallback to CI stages) |
| S9 issues no dispatch; integration PR still needs green CI | 4.5 orchestrate paragraph; branch 2 unchanged |
| Validators accept opted-out child, reject without opt-out, byte-identical | 4.4 strings and corpus |
| Claude/Codex byte identity, bundle parity, no generation drift | 7 inventory; generator run for rule, brief, epic-plan |
| Pester covers allow, deny, main-base, default | 8 |
| Ledger entry with prior text and revert steps | entry `0014-epic-child-ci-opt-out.md` (number to confirm at write time) |

## Numeric Derivation Evidence

No numeric count, enumeration, or population is proposed for an approved `spec.md` acceptance criterion. Line counts, timing bounds, and the next ledger number in this document are context for the plan, not acceptance criteria.

## 7. File Inventory

Production (PowerShell; byte-identical twin and bundle copies listed as pairs):

- `.claude/hooks/enforce-epic-merge-gate-child-ci.ps1`, `.codex/hooks/enforce-epic-merge-gate-child-ci.ps1`, and both bundle copies.
- `.claude/hooks/enforce-epic-merge-gate.ps1` (pass `-GitRoot $childRoot`, header) and its bundle copy.
- `.codex/hooks/enforce-epic-merge-gate.ps1` (header comment only) and its bundle copy.
- `.claude/hooks/enforce-completion-helpers.ps1`, `.codex/hooks/enforce-completion-helpers.ps1`, and both bundle copies.
- `.claude/hooks/enforce-completion-consistency.ps1`, `.codex/hooks/enforce-completion-consistency.ps1`, and both bundle copies.
- `.claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1` and its bundle copy.

Production (Python): `scripts/dev_tools/validate_orchestrator_state.py`.

Production (TypeScript): `extensions/drm-copilot/src/lib/validate/orchestrator-state-child-ci.ts` (new), `extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts`, `extensions/drm-copilot/jest.config.cjs`.

Skills, rule, template, brief, and their copies: both orchestrate skills, both epic-orchestrate skills, both epic-run skills, `.agents/skills/epic-plan/SKILL.md` (generated `.claude` copy), each with bundle copies; `scripts/harness-generation/sources/rules/orchestrator-state.md` and `.json` (generated `.claude/rules/orchestrator-state.md` and its bundle copy); `.agents/skills/execution-environment/SKILL.md` (generated `.claude` copy and both bundle copies); `.dev/templates/epic/epic.md` and `extensions/drm-copilot/resources/feature-templates/epic/epic.md`.

Pins and ledger: `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`; `.dev/engineering/process-reductions/0014-epic-child-ci-opt-out.md`, an optional `patches/0014-epic-child-ci-opt-out.patch`, and the README index row.

Tests (new or extended):

- New `tests/scripts/claude-hooks/enforce-epic-merge-gate.ChildCiOptOut.Tests.ps1` and `tests/scripts/codex-hooks/enforce-epic-merge-gate-child-ci-opt-out.Tests.ps1`.
- Extended completion-consistency suites in both hook folders and `tests/scripts/codex-hooks/enforce-completion-helpers.Tests.ps1`.
- New corpus `tests/fixtures/orchestrator_state_child_ci/`, with a new `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateChildCi.Tests.ps1` and a new `extensions/drm-copilot/test/lib/validate/orchestrator-state-child-ci.test.ts`. The Python cases go into the existing `tests/scripts/dev_tools/test_validate_orchestrator_state_completion.py`, so no new Python file is created.
- New skill-text contract test `tests/scripts/claude-runtime/child-ci-opt-out-skill-contract.Tests.ps1`, which pins the opt-out text in every copy.

## 8. Testing Implications

- Merge gate rows (both runtimes): allow (opt-out, base equals the integration branch, concurrent PASS current, record valid, evidence at live head); deny per stage B lookup, R, L1 variants, L2, and L3 variants; main-base fallback (opt-out plus base `main`: denies `EPIC_CHILD_CI_NOT_VERIFIED` stage 2 without `ci_gate`, allows with green CI); default rows (key absent, `per_child`, case variant) assert the new seam is never called and the deny text is unchanged; Claude rows assert `-GitRoot` receives the item root.
- Existing suites that must stay green unchanged: `enforce-epic-merge-gate.ChildCi.Tests.ps1`, `enforce-epic-merge-gate-child-ci.Tests.ps1` (Codex), `GreenCiRegression`, `EpicModeStrict`, `ReviewGuard`, `Regeneration`, `hook-dependency-failure.SpecialCases.Tests.ps1` (C11), `cross-tree-helper-identity.Tests.ps1`, `codex-epic-runtime-contracts.Tests.ps1`, `EpicMergeGateReview.Cases.Helpers.ps1` consumers.
- Contract and parity: `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, both pack-manifest completeness tests, `test_push_down_pack_manifest_dependency_closure.py` (no new dot-source dependency if the design is followed), `HarnessGeneration.RepoGate.Tests.ps1`, the Codex generator `--check`, `test_parallel_orchestrator_surface_contracts.py`, `test_ci_gate_epic_child_contracts.py` (S9 fragments must stay), `early-start-skill-contract.Tests.ps1` (kickoff literal), `regeneration-path-skill-contract.Tests.ps1`, `concurrent-review-skill-contract.Tests.ps1`, `review-verdict-skill-contract.Tests.ps1`, `ProcessReductionChain.Ledger.Tests.ps1`, `ProcessReductionLedger*.Tests.ps1`, `FileSizePolicy.RepoGate.Tests.ps1`.
- Cadence: one parallel run of each gate at the Phase 0 baseline and at final QC; task checks run the selection of the changed files through the launcher (`pester -TestPath`); the suites listed above are the task-check selection of the matching tasks.

## Pre-Mortem

- Review checklists: a reviewer may find that the opt-out reads a self-declared item key; the plan must state the D10 policy-level disclosure in the rule section and the ledger entry, and show that the live base check, the concurrent review requirement, and the evidence check bound the reduction.
- Coverage: new branches in the helper, the completion helpers, the PowerShell module, the Python validator, and the new TypeScript module can miss the per-file 85% line and 75% branch thresholds; the plan must give every stage and every error string a test row and add the TypeScript `coverageThreshold` entry.
- Mirror parity: twin hooks, bundle copies, the generated rule, the generated `epic-plan` and brief copies, and the frozen pin can drift; the plan must copy every mirror in the same task as its source, run the generator with `-Check`, re-baseline the skill digest with a `RE-BASELINED by issue #1233` paragraph, and update all four brief copies (maintenance rule of the brief).
- File size: `enforce-completion-consistency.ps1` (Claude 508, Codex 499 lines), `OrchestratorStateCompletionChecks.psm1` (467), and the child-CI helper (316) will grow; none may exceed 800, and a file passing 700 draws a review warning, so new logic goes into the byte-identical helpers and the new TypeScript module.
- Test isolation: new Pester rows must mock `Invoke-DocsOnlyGhExe`, `Invoke-DocsOnlyGitExe`, and the checkpoint read seams by name, create no temporary files, and leave no global state; `Invoke-PoshQCLeakScan` must stay clean.
- CI-only behavior: the Linux hook-suite job runs `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks` on a case-sensitive file system; fixtures must use forward-slash relative paths and no drive letters; the ledger chain test runs only meaningfully on the committed tree, so the plan must run it after the ledger commit.
- Evidence: the plan's evidence must be append-only with clock-read UTC stamps; this research file's stamp came from an external time service because the researcher has no shell; the ledger `Merge commit:` line starts as `pending (PR #N)` and is back-filled after merge.

## 9. Open Questions and Recommended Options

1. Automatic `CI` runs on child PRs in this repository (premise mismatch). Recommended: option A, no workflow change. The gate and S9 stop waiting for or dispatching CI, which removes the per-child wait, and the automatic run is ignored. Alternative B: remove `"epic/**"` from `ci.yml` `pull_request.branches` and update the `.github/workflows/README.md` `## Triggers` note and the brief `## CI Shape and Required Checks` first bullet. That stops the compute, but changes `per_child` epics to the #1130 dispatch path, which conflicts with "behavior unchanged" for `per_child`. Alternative C, a `[skip ci]` token in each child head commit, is rejected because every push would need the token. Record option A's residual in the ledger entry.
2. Base mismatch handling. Recommended: fall back to per-child CI verification (today's behavior); the alternative is to deny outright.
3. Review requirement. Recommended: the opt-out requires `review_mode: "concurrent"`. The alternative, activating the guard under the opt-out, would change `enforce-epic-merge-gate-review.ps1` and its tests.
4. Integration-tip regeneration CI (`## Integration-Tip Regeneration`, config-gated). Recommended: unchanged. The config is absent in this repository, and the dispatch verifies regenerated integration output, not a child head.
5. Ledger number. Recommended: `0014`, confirmed against the index at write time, because a concurrent item can take the number first.
6. Codex launch contract. Recommended: no change (`epic-child-launch-contract.ps1` tolerates the extra prompt line); the Codex child records `child_ci` from the prompt.

## 10. Concurrency Constraints

- Epic #1217 (`.claude/lib/docs`, docs skills): not touched by this design.
- Issue #1228 (test-cadence wording): edits `## Delegation Model` and R3 of `## Remediation Loop (R1-R5)` in the orchestrate skills (verified cadence sentences there), `atomic-plan-contract`, epic and parallel test-cadence wording such as the early-start "local gate", qa-gate skills, and agent sources. This feature edits S9 / `## CI Green Gate`, `## Checkpoint Schema - CI Gate Fields`, `## PR Creation Gate`, the epic manifest, kickoff, checkpoint, and lifecycle step 6 sections, the epic-run scope sentence, and no agent source or `atomic-plan-contract`. The sections are distinct. Expected merge conflicts: the epic-orchestrate digest line in the pin file (resolve by recomputing the merged digest) and possibly the ledger number.

## 11. Hook-Runtime Caveat

Hooks for isolated subagents run the default-branch scripts (`## Hook Execution Context`), so the new gate and completion behavior apply only after merge. The design is proven by Pester rows that drive `Invoke-EpicMergeGateDecision`, `Invoke-CodexEpicMergeDecision`, and the completion decisions with mocked seams, never by a live run. This item's own merge to `main` is a standalone green-CI merge and does not exercise the opt-out.

## Automation Feasibility

No human interaction is expected. Every step is a file edit, a generator run, a contract or Pester run, or a commit by the orchestrator. The owner already decided to change the gate (relayed by the coordinator), and the open questions in Section 9 each carry a recommended option, so execution needs no further decision. The only owner-visible choice, workflow option B, is not required for the acceptance criteria.

## Rejected Alternatives (summary)

- Reading `child_ci` from the epic checkpoint at the gate: Claude-only, and it adds resolution I/O.
- Encoding the opt-out in `ci_gate.conclusion`: it widens every `ci_gate` consumer and risks reading missing CI as green.
- A separate new hook file for the opt-out: it adds pack-manifest, dependency-closure, and identity-list entries, while the existing byte-identical helpers already cover both runtimes.
