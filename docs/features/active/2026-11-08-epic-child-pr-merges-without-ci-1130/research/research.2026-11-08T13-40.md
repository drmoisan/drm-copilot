# Research: epic child PR merges without CI (#1130)

Scope: verified answers to the six orchestrator questions. Read-only research; no `gh` or `git` was run (task-researcher has neither), so items marked "confirm" need an orchestrator `gh` check.

## Root cause (confirmed)

- Claude: `Invoke-EpicMergeGateDecision` in `.claude/hooks/enforce-epic-merge-gate.ps1` returns allow when `Test-ChildCheckpointAllowsEpicMerge` (JSON `epic_mode` true, `step9_status` `passed`) and `Test-ChildCheckpointPrGateBinding` (`.claude/hooks/enforce-epic-merge-gate-resolution.ps1`) hold. The binding returns true for a bare command. No CI result, head SHA, or `gh` lookup is consulted.
- Codex: `Invoke-CodexEpicMergeDecision` in `.codex/hooks/enforce-epic-merge-gate.ps1` returns `$null` (allow) when `Test-CodexChildMergeReady` holds (`epic_mode` true, `step9_status` `passed` or `verified`). It has no PR binding at all.
- `.claude/skills/orchestrate/SKILL.md` S9 step 6 makes the child `orchestrator` merge its own PR into the integration branch; `epic-orchestrator` does not merge children (`## Merge-on-Green Kickoff Parameter` in `.claude/skills/epic-orchestrate/SKILL.md`).

## Q1. gh invocation, checkpoint resolution, shared-helper seam

- Codex checkpoint: the script tail derives `$repositoryRoot` from `$PSScriptRoot` (two levels up) and reads `artifacts/orchestration/orchestrator-state.json` and `epic-orchestrator-state.json` there; it passes the raw text plus `-RepositoryRoot` to `Invoke-CodexEpicMergeDecision`. `gh` and `git` both run in that root (the review helper's `.NOTES` states this).
- Claude checkpoint: `Resolve-EpicMergeGateItemTarget` (explicit number) or `Get-EpicMergeGateSessionWorktreeRoot` (bare) selects the root; `gh` runs in the session root, `git` in the item root.
- Process seam: both gates dot-source `hook-docs-only-diff.ps1`, whose `Invoke-DocsOnlyGhExe -WorkingRoot -GhArgs` is the only `gh` path (bounded by `Invoke-DocsOnlyBoundedNative`, 7000 ms default `GhInvoker`, never throws, returns `ExitCode`/`Output`, `-1` for a missing or blank root). `Invoke-DocsOnlyGitExe -WorktreeRoot -GitArgs` is the `git` twin (3000 ms).
- The review helper `enforce-epic-merge-gate-review.ps1` does not take an injected scriptblock. It dot-sources nothing, calls `Invoke-DocsOnlyGhExe`/`Invoke-DocsOnlyGitExe` at run time, and wraps the `gh` call in its own named seam `Get-EpicMergeGateReviewLiveHeadSha` that tests mock by name. Root differences are passed as parameters (`-GhRoot`, `-GitRoot`).
- Recommendation: follow that precedent, not an injected scriptblock. The repository PowerShell rule prefers the wrapper-function seam over a ScriptBlock seam, and a scriptblock parameter would add a second seam style to a byte-identical pair. Create `.claude/hooks/enforce-epic-merge-gate-child-ci.ps1` and a byte-identical `.codex/hooks/enforce-epic-merge-gate-child-ci.ps1`, each dot-sourcing nothing, with its own seams:
  - `Get-EpicMergeGateChildCiLiveHeadSha -PrNumber -WorktreeRoot` (one `gh pr view <PR> --json headRefOid`).
  - `Get-EpicMergeGateChildCiRunList -HeadSha -WorktreeRoot` (one `gh run list`).
  - Pure: `Test-EpicMergeGateChildCiObjectId`, `Get-EpicMergeGateChildCiPrNumber`, `Select-EpicMergeGateChildCiRun`.
  - Entry: `Get-EpicMergeGateChildCiDecision -Checkpoint -CommandPrNumber -GhRoot` returning `[ordered]@{ Verified; Reason }`.
- The helper must not reuse `Get-EpicMergeGateLivePrHeadSha` (`.claude/hooks/enforce-epic-merge-gate-green-ci.ps1`, Claude-only, so unavailable to Codex; and `enforce-epic-merge-gate.GreenCiRegression.Tests.ps1` and `enforce-epic-merge-gate.EpicModeStrict.Tests.ps1` assert it is called zero times on branch 1). It should not call `Get-EpicMergeGateReviewLiveHeadSha` either, because the review suites count that seam's `gh` calls.
- Wiring: Claude adds one guarded line after the review dot-source (`try { . (Join-Path $PSScriptRoot 'enforce-epic-merge-gate-child-ci.ps1') } catch { Add-HookDependencyFailure ... }`, the pattern `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` checks), and replaces the branch-1 allow with: call `Get-EpicMergeGateChildCiDecision -GhRoot $sessionRoot`; allow when `Verified`, otherwise `Get-EpicMergeGateBlockDecision -Reason $decision.Reason`. Codex does the same inside the `Test-CodexChildMergeReady` branch with `-GhRoot $RepositoryRoot`. The Claude gate is 496 physical lines; the net addition is a few lines, so the 500-line guidance tier is reached but the 800-line hard limit is not.

## Q2. Live verification design

Evaluated only when the existing branch-1 predicate holds (and, on Claude, the binding). Stages run cheapest first; the first failure denies with `EPIC_MERGE_GATE_BLOCKED: EPIC_CHILD_CI_NOT_VERIFIED: <detail>`.

1. PR number: the command's explicit number; else `pr_gate.pr_number` as a positive JSON integer; when both exist they must be equal (this adds the binding Codex lacks). Neither: deny (a bare command cannot be tied to a head otherwise).
2. Checkpoint: `ci_gate` is an object, `ci_gate.conclusion` is exactly `success`, `ci_gate.head_sha` is a lowercase 40- or 64-hex id (same regex as `Test-EpicMergeGateGreenCiObjectId`).
3. Live head: one bounded `gh pr view <PR> --json headRefOid`; unresolved or malformed denies; it must equal `ci_gate.head_sha` ordinally; a `--match-head-commit` value, if present, must equal it (optional; reuse of `Get-CommandLineFlagValue` exists in both runtimes only through the shared command parser, so confirm availability before adding this check on Codex).
4. Runs: one bounded `gh run list --commit <head> --limit 100 --json databaseId,event,status,conclusion,headSha,workflowName,createdAt`. Output must parse to a JSON array. Keep entries with `workflowName` exactly `CI` and `headSha` equal to the head; select the one with the greatest `createdAt` (ordinal compare of the ISO strings; do not rely on output order). None: deny (`no CI run on <head>`).
5. The selected run must have `event` `pull_request` or `workflow_dispatch`, `status` `completed`, `conclusion` `success`.
6. When `event` is `workflow_dispatch`, `ci_gate.dispatch_run_id` must be a positive JSON integer equal to `databaseId`.

Problems and constraints:
- Workflow name: `CI` is the `name:` of this repository's `.github/workflows/ci.yml` and matches the existing S9 `-RequireWorkflow CI` assumption. A destination whose workflow has another name is denied (fail closed). State this in `.claude/rules/ci-workflows.md` and the skill text; do not make the hook configurable in this change.
- `gh run list --commit` and the JSON field names: believed present in the pinned GitHub CLI 2.103.3; confirm with `gh run list --help` before the plan freezes. Do not pass `--workflow CI`, which fails when the name is ambiguous; filter in PowerShell instead.
- A `push`-event run on the same SHA is not accepted, per the spec's Expected text. A destination with branch-wide `push` CI then needs a dispatch; record this as a deliberate limitation.
- Timeouts: two new 7000 ms-bounded calls. Codex registers the gate with `timeout = 30` in `.codex/config.toml`; with the review guard active (one `gh` plus two `git` calls) the worst case is about 27 s. `.claude/settings.json` sets no timeout for the gate. Keep the run list to one call.
- Residual: a push after the lookup can change the head unless `--match-head-commit` is passed (same disclosure as #997). Policy-level control, as D10.
- Linux hook-suite job: fixtures must use `/synthetic-worktrees/...`, `Join-Path`, no backslash literals, exact file-name case.
- Existing reason-code families: `STANDALONE_MERGE_AUTHORIZATION_*`, `REVIEW_GATE_*`, `TARGET_WORKTREE_*`, and the `GREEN_CI_*` deny suffixes; each is emitted as `EPIC_MERGE_GATE_BLOCKED: <CODE>: <message>`. `EPIC_CHILD_CI_NOT_VERIFIED` fits that form. Deny immediately rather than falling through, so the specific reason is shown; the generic final deny text can stay as is (it names minimum preconditions and is pinned verbatim in seven test files listed under Q3).

## Q3. Pester suites whose branch-1 allow changes

`gh` is mocked as `Mock Invoke-DocsOnlyGhExe { ExitCode = 1 }` in most suites. Once branch 1 needs CI, every row below must supply a green `ci_gate` and mock the two child-CI seams to green (or mock `Get-EpicMergeGateChildCiDecision`), or flip its expectation to deny.

Claude (`tests/scripts/claude-hooks/`):
- `enforce-epic-merge-gate.Tests.ps1`: "allows gh pr merge --merge when the child checkpoint is epic_mode true and step9_status passed"; "allows the nested envelope when the child checkpoint authorizes the merge". This suite has no `Invoke-DocsOnlyGhExe` mock and does not mock the session root, so without a seam mock the bare-command path would reach a real root; both rows are bare commands with no `pr_gate`, so under Q2 stage 1 they deny before any process.
- `enforce-epic-merge-gate.EpicModeStrict.Tests.ps1`: "returns <Expected> for gh pr merge 42 --merge when epic_mode is <Label>" (JSON true row expects allow).
- `enforce-epic-merge-gate.GreenCiRegression.Tests.ps1`: "branch 1 still allows epic_mode true with step9_status passed" (also asserts zero `Get-EpicMergeGateLivePrHeadSha` calls; keep that true).
- `enforce-epic-merge-gate.WorktreeResolution.Tests.ps1`: "M4 allows a child merge whose pr_gate.pr_number equals the command PR number"; "M6 reads every checkpoint beneath the session worktree for a bare command without resolving" (check its expectation).
- Review rows through the shared table `EpicMergeGateReview.Cases.Helpers.ps1` (`ConvertTo-EpicMergeGateReviewCheckpointJson` builds an epic child with `step9_status` passed and no `ci_gate`): every `Expected = 'allow'` row in `enforce-epic-merge-gate.ReviewGuard.Tests.ps1` (`RG-<Name>`, `RG-LIVE-HEAD-SEAM-USES-ONE-GH-CALL`, `RG-SHAPE-BOUND-COMMAND-READS-NO-EXTRA-CHECKPOINT`, the `RG-SHAPE-NOKEY-RESOLUTION-FAILURE-KEEPS-DECISION` rows) and `enforce-epic-merge-gate.ReviewPaths.Tests.ps1` (`RGP-PATH1-BOTH-ALLOWED`, `RGP-PATH3-BOTH-ALLOWED`, `RGP-PATH3B-BOTH-ALLOWED`, and allow-side `RGP-NOKEY-*`). Rows with `NoProcess = $true` assert no process; mocking the child-CI seams by name keeps `Invoke-DocsOnlyGhExe` counts unchanged. The fixture should gain a green `ci_gate` whose `head_sha` equals the live head of each row.
- Deny-only rows (no change expected): `enforce-epic-merge-gate.ItemResolution.Tests.ps1` epic_mode rows, `Authorization`, `DocsOnly`, `MergeQueue`, `TriggerScoping`, `Coverage`.

Codex (`tests/scripts/codex-hooks/`):
- `epic-execution-gates.Tests.ps1`: "allows a verified epic child merge" (no `-RepositoryRoot`, so the seam returns `-1` and the row denies without a process).
- `enforce-epic-merge-gate-authorization.Tests.ps1`: matrix row "the unchanged branch-1 child guard" (`Expected = 'allow'`, bare command, no root).
- `enforce-epic-merge-gate-review.Tests.ps1`: allow rows of the shared table (`RGC-<Name>`) and `RGC-EPIC-CI-GREEN-NO-CHILD-KEY-ALLOWED` (epic branch, likely unaffected); it asserts `Invoke-DocsOnlyGhExe -Times $GhCount`, so the child-CI seams must be mocked by name.
- `enforce-epic-merge-gate-decision-surface.Tests.ps1` `Test-CodexChildMergeReady` rows test the predicate only and stay valid.

Pinned generic deny text (unchanged if the recommendation is followed): Claude `MergeQueue`, `Authorization`, `DocsOnly`, `GreenCiDecision`; Codex `merge-queue`, `docs-only`, `authorization`.

## Q4. CI gate parser

`.claude/lib/ci-gate/Invoke-CiGateParser.ps1` builds its output in a helper that emits exactly `head_sha`, `pr_pipeline_run_id`, `pr_pipeline_run_url`, `conclusion`, `verified_at`; `pr_pipeline_run_id` is caller-supplied and may be empty. It parses `gh pr checks` output only and never sees run events. Keep `event`/`dispatch_run_id` out of the parser (its contract and `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1` stay unchanged). Define `ci_gate.dispatch_run_id` in skill text and `.claude/rules/orchestrator-state.md`: the orchestrator adds it to the parser's object before writing the checkpoint. The Python completion check `_validate_completion_ci_gate` in `scripts/dev_tools/validate_orchestrator_state.py` checks required keys only, so an extra key is tolerated. Whether `gh pr checks` lists check runs of a `workflow_dispatch` run on the PR head is likely but unverified; confirm, because S9 step 2 depends on it.

## Q5. Text surfaces and pins

- Dispatch location: the child merges itself, so the dispatch belongs in `.claude/skills/orchestrate/SKILL.md` `## Step S9 — CI Green Gate` epic-child rule: when `gh pr checks` reports `no checks reported` (or no `CI` check appears) on an epic child, run `gh workflow run CI --ref <child branch>` once, find the run with `gh run list --commit <head>`, record `ci_gate.dispatch_run_id`, then poll. Add `dispatch_run_id` to `## Checkpoint Schema — CI Gate Fields`, and state in step 6 that the gate verifies the run. Keep every fragment pinned by `tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py` (`S9_EPIC_CHILD_FRAGMENTS`, `SCHEMA_FRAGMENTS`); the parser command must stay on one line.
- Mirror `.agents/skills/orchestrate/SKILL.md` (Codex S9 steps 3-5 carry the same epic-child rule) and both bundle copies.
- `.claude/skills/epic-orchestrate/SKILL.md` `## Merge-on-Green Kickoff Parameter`: one sentence that the child verifies CI on its head (dispatching when none ran) and that the merge gate denies otherwise. This moves the pinned digest in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` `PINNED_FROZEN_SURFACE_HASHES`; refresh it with a `RE-BASELINED by issue #1130` comment like the existing entries. Leave `.claude/agents/epic-orchestrator.md` unchanged unless needed, so its pin stays.
- `.agents/skills/epic-orchestrate/SKILL.md` (line on child CI-green gate) and bundle copy: matching sentence. `.claude/skills/epic-run/SKILL.md` and `.agents/skills/epic-run`: no CI text found; no change needed. `.codex/agents/epic-orchestrator.toml` has no child-CI text and no generated variants; no change, so `generate_codex_agent_variants.py --check` is unaffected unless a base agent changes.
- `.github`: no epic-child CI text (only `.github/workflows/README.md`); no Copilot change.
- `.claude/rules/orchestrator-state.md`: new section "Epic-child CI verification (issue #1130)" listing the six stages, `ci_gate.dispatch_run_id` as tolerated, and the D10-style disclosure; update the `## Enforcement` bullet that names the gate helpers.
- `.claude/rules/ci-workflows.md` and `.agents/skills/ci-workflows/SKILL.md` (+ bundles): state that a repository using epic integration branches lists `epic/**` in the `pull_request` trigger of a workflow named `CI`, otherwise children rely on dispatch. Note: `test_ci_gate_epic_child_contracts.py` reads `.agents/skills/ci-workflows/SKILL.md` for a citation pattern; keep it intact.
- Execution-environment brief (six copies): add the child-CI helper to the `Merge guard (#1097)` style bullet under `## Hook Execution Context`, and adjust the `## CI Shape and Required Checks` dispatch bullet. Required by the brief's maintenance rule.

## Q6. Manifests and registration

- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` lists the Claude gate and its five helpers; add `.claude/hooks/enforce-epic-merge-gate-child-ci.ps1`.
- `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` lists the Codex gate, its command helper, and the review helper; add `.codex/hooks/enforce-epic-merge-gate-child-ci.ps1`. The generator rewrites only agent families (`CORE_FAMILIES`) there; run `--check` to confirm hook entries survive.
- Bundle copies of both new files under the two resource trees (`test_push_down_*_resource_contracts.py`, `*_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`).
- Registration is unchanged: `.claude/settings.json` (PreToolUse `pwsh -NoProfile -File .claude/hooks/enforce-epic-merge-gate.ps1`) and `.codex/config.toml` (`[[hooks.PreToolUse.hooks]]`, timeout 30).

## Rejected alternatives

- Injected gh-invoker scriptblock on the helper: second seam style, contrary to the wrapper-seam rule; mocks by name already work.
- Extending `Invoke-CiGateParser.ps1` with event data: it consumes `gh pr checks`, which carries no event or run id.
- Reusing the green-CI helper on Codex: Claude-only file and branch-1 zero-call assertions.

## Pre-Mortem

- Review checklists: a reviewer flags the gate change as weakening if any path still allows an epic child without a run; mitigation: deny immediately on every stage failure, no fall-through, and a test per stage.
- Coverage: the new helper is a production PowerShell file needing at least 85% line coverage; mitigation: direct unit tests of each pure function and of both seams via a mocked `Invoke-DocsOnlyGhExe`, plus decision rows through both gates.
- Mirror parity: two byte-identical helpers, two bundle copies, two manifests, mirrored skills, and the six brief copies; mitigation: a twin byte-identity test like `RG-TWIN-IS-BYTE-IDENTICAL`, and the plan's mirror-parity bullet names the brief-update task and the `PINNED_FROZEN_SURFACE_HASHES` refresh.
- File size: the Claude gate sits near the 500-line guidance tier; mitigation: all new logic in the helper, gate change limited to the dot-source line and the branch-1 call.
- Test isolation: the suites listed in Q3 must mock the child-CI seams by name so no real `gh` runs and `Invoke-DocsOnlyGhExe` counts stay stable; mitigation: register mocks in `BeforeAll`, no temporary files, parallel Pester gate.
- CI-only behavior: the Linux hook-suite job is case-sensitive; mitigation: forward-slash synthetic roots and `Join-Path` only. The live `gh run list` shape is not exercised in CI; mitigation: orchestrator confirms the flags and fields once with `gh run list --help` and records it.
- Evidence: write evidence under `<FEATURE>/evidence/<kind>/` with write-time UTC stamps. This research file's stamp could not be read from a clock by this agent (no shell); the orchestrator may rename it.
