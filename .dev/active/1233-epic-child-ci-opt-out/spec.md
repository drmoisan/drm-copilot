# epic-child-ci-opt-out — Spec

- **Issue:** #1233
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-24T04-02
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-feature
- **Research:** `.dev/active/1233-epic-child-ci-opt-out/research/research.2026-11-24T04-02.md`

## Overview

Every epic child must pass CI on its own pull request before it merges into the epic integration branch. The merge gate helper `enforce-epic-merge-gate-child-ci.ps1` (issue #1130), byte-identical in `.claude/hooks/` and `.codex/hooks/`, enforces this, and the S9 dispatch fallback starts a `CI` run for a child head that has none. An epic with N children pays for N full CI runs plus the integration run. The owner directed on 2026-11-23: "for the epic run, do not run CI on each feature. only run it on the final epic merge to main". The owner chose to change the gate rather than bypass it.

This feature adds an epic-level opt-out, `child_ci: integration_only`. Under the opt-out, an epic child merges into its integration branch on verified local final-QC evidence and a current concurrent review instead of a green `CI` run on its own head. The integration-to-`main` pull request still requires a full green `CI` run. The default, `per_child`, keeps today's behavior on every surface.

Premise correction: `issue.md` states that `ci.yml` does not trigger on pull requests into `epic/**`. In this repository it does (`.github/workflows/ci.yml`, `on.pull_request.branches: [main, development, "epic/**"]`, added by issue #658). A child pull request therefore still starts a `CI` run automatically. Decision D1 records how this is handled.

## Decisions

Decisions taken by the orchestrator in autonomous mode, following the recommended options of research Section 9.

- **D1 — No workflow change.** `.github/workflows/ci.yml` is not changed. Because `ci.yml` already triggers on `pull_request` into `epic/**`, a child pull request still starts a `CI` run automatically. Under `child_ci: integration_only` the merge gate and S9 neither wait for nor dispatch `CI`, and the automatic run is not a merge condition. The residual automatic run is recorded in the process-reduction ledger entry.
- **D2 — Base mismatch falls back.** When the live PR base is not exactly the recorded `epic_context.integration_branch`, or is `main`, the opt-out does not apply and today's per-child CI verification (helper stages 2 to 6) decides the merge.
- **D3 — Concurrent review required.** `integration_only` requires top-level `review_mode: "concurrent"`. The review guard file `enforce-epic-merge-gate-review.ps1` is unchanged.
- **D4 — Integration-tip regeneration unchanged.** The config-gated integration-tip regeneration CI dispatch (`## Integration-Tip Regeneration`) is unchanged.
- **D5 — Gate input is the item checkpoint.** The gate reads `child_ci` from the item checkpoint, verified inside the existing byte-identical child-CI helper (research approach A). Reading the epic checkpoint at the gate (approach B) and encoding the opt-out in `ci_gate.conclusion` (approach C) are rejected.
- **D6 — Codex launch contract unchanged.** `.codex/scripts/epic-child-launch-contract.ps1` tolerates the extra prompt line; the Codex child records `child_ci` from the prompt.
- **D7 — Ledger number confirmed at write time.** The ledger entry takes the next free number in `.dev/engineering/process-reductions/README.md` at the time it is written (`0014` at research time).

## Behavior

- Default: a checkpoint without `child_ci`, or with any value other than the exact string `integration_only`, behaves exactly as today in every hook, validator, and skill. No new process is started by the gate for such a checkpoint.
- Under the opt-out, an epic child merges into its integration branch without a `CI` run on its own head. The gate requires, instead of `ci_gate`:
  - the live PR base equal to the recorded integration branch;
  - `review_mode: "concurrent"` with a `PASS` review at a current head (proved by the existing review guard, which runs first);
  - a valid `local_qc_gate` record bound to the reviewed head;
  - the local-QC evidence file present in the live head tree with `EXIT_CODE: 0`.
- S9 issues no `CI` dispatch for a child head under the opt-out, and does not query checks as a gate.
- The integration-to-`main` pull request (merge-gate branch 2, `epic_merge_pr.ci_gate`) is unchanged and still requires a full green `CI` run.
- The validators and completion-consistency hooks treat an opted-out child as complete with `local_qc_gate` in place of `ci_gate`. `ci_gate` stays absent, so missing CI is never read as green.
- A child acceptance criterion that depends on CI is listed as pending integration CI and does not block the child's DONE; it is checked off in the integration worktree after integration CI is green, under the merged-feature follow-up allowance (issue #1141).

## Keys

| Location | Key | Values | Default | Writer |
|---|---|---|---|---|
| Epic manifest frontmatter (`.dev/epics/<slug>/epic.md`) | `child_ci` | `per_child`, `integration_only` | absent means `per_child` | `epic-planner` (only when the owner chose the opt-out) |
| Epic checkpoint (`artifacts/orchestration/epic-orchestrator-state.json`) | `child_ci` (top level) | copied from the manifest | absent means `per_child` | `epic-orchestrator` at kickoff |
| Item checkpoint (`artifacts/orchestration/orchestrator-state.json`) | `child_ci` (top level) | `integration_only` | absent means `per_child` | child orchestrator at its first checkpoint write, when the delegation prompt carries the separate line `Child CI: integration_only.` |
| Item checkpoint | `local_qc_gate` | object `{ conclusion, head_sha, evidence_path, verified_at }` | absent | child orchestrator at S9 under the opt-out |

- A manifest `child_ci` value other than `per_child` or `integration_only` is a malformed manifest and is rejected before kickoff as a synthetic Blocking finding (skill rule, in the same way as an unresolved `depends_on`).
- The kickoff line `Child CI: integration_only.` is a separate prompt line, so the epic-mode kickoff literal pinned by `ESS-KICKOFF-LITERAL-INTACT` is unchanged.
- The epic validators tolerate the epic-level `child_ci` key without a code change.

## Activation Predicate

The predicate is identical in the hooks and the validators:

- `epic_mode` is the JSON boolean `true`, AND
- `child_ci` is the string `integration_only` (ordinal comparison; a case variant or a non-string does not activate).

The merge gate additionally requires `epic_context.integration_branch` to be a string matching `^epic/[A-Za-z0-9][A-Za-z0-9._-]*-integration$`. When that value is missing or malformed, the gate predicate is false and per-child CI verification applies.

## Merge Gate (child-CI helper, both runtimes)

Changes are made in `enforce-epic-merge-gate-child-ci.ps1`, byte-identical in `.claude/hooks/` and `.codex/hooks/` and in both bundle copies. Inside `Get-EpicMergeGateChildCiFailureDetail`, after stage 1 (PR number), when the gate predicate holds:

| Stage | Name | Check | On failure |
|---|---|---|---|
| B | base | One bounded `gh pr view <PR> --json headRefOid,baseRefName` through the new seam `Get-EpicMergeGateChildCiLivePullRequest` (returns head and base, or `$null`). | `$null` result: deny. Base not exactly `epic_context.integration_branch`, or base ordinally equal to `main`: the opt-out is not applied and stages 2 to 6 run unchanged (D2). |
| R | review | `Test-EpicMergeGateReviewModeConcurrent` holds. Reaching this point under that key proves a `PASS` review at a current head, because the review guard runs before branch 1. | Deny. |
| L1 | record | `local_qc_gate` is an object; `conclusion` is exactly `success`; `head_sha` is a lowercase 40- or 64-character object id; `evidence_path` is a clean relative path that starts with `<feature-folder>/evidence/qa-gates/` and ends with `.md`, with no backslash and no empty, `.`, or `..` segment (`feature-folder` validated by `Test-EpicMergeGateReviewFeatureFolder`). | Deny. |
| L2 | binding | `local_qc_gate.head_sha` equals, ordinally, the `head_sha` of the last `remediation_loop.review_outcomes[]` entry. No extra git call. | Deny. |
| L3 | evidence | One bounded `git cat-file -p <live head>:<evidence_path>` through `Invoke-DocsOnlyGitExe` at `GitRoot`: exit 0; the first `EXIT_CODE:` line has value `0`; the text holds a `Timestamp:` line and the line `Head: <local_qc_gate.head_sha>`. | Deny. |

- Deny reason for every failure in stages B (lookup), R, L1, L2, and L3: `EPIC_MERGE_GATE_BLOCKED: EPIC_CHILD_LOCAL_QC_NOT_VERIFIED: stage <id> (<name>): <detail>`, from a new prefix constant beside `$script:EpicMergeGateChildCiReasonPrefix`. A denial does not fall through to later branches.
- Without the predicate, the helper is unchanged, the new seam is never called, and every deny text is unchanged.
- `Get-EpicMergeGateChildCiDecision` gains an optional `-GitRoot` parameter that defaults to `GhRoot`. The Claude gate `.claude/hooks/enforce-epic-merge-gate.ps1` passes `-GitRoot $childRoot` (the item worktree). The Codex gate needs no call change; its header comment is updated.
- Timing bound: the worst case under the opt-out (review guard, stage B, stage L3) stays within the Codex 30 s registration in `.codex/hooks/pretooluse-dispatch.json`; stage L2 reuses the review guard's head proof for this reason.
- Branch 2 (integration PR into `main`) is unchanged; an epic-level `child_ci` key has no effect on it.

## Completion-Consistency Hooks

- `enforce-completion-helpers.ps1` (byte-identical in `.claude/hooks/` and `.codex/hooks/`, and in both bundle copies) gains the pure functions `Test-CompletionChildCiIntegrationOnly` and `Get-CompletionLocalQcGateMissing`.
- In `Get-MissingCompletionEvidence` of both `.claude/hooks/enforce-completion-consistency.ps1` and `.codex/hooks/enforce-completion-consistency.ps1`, under the predicate, the `ci_gate` evidence check is replaced by a `local_qc_gate` evidence check (object; `conclusion` `success`; non-empty `head_sha` and `evidence_path`), and the `ci_gate.head_sha` / `pr_gate.head_sha` comparison is skipped.
- The deny reason names the `local_qc_gate` alternative only in the opt-out branch. Every deny text produced without the key, including the `COMPLETION_CONSISTENCY_BLOCKED:` reason, is byte-unchanged.

## Validator Error Strings

Under `require_complete`, inside the existing `route_requires_ci_gate` branch, the predicate selects a local-QC check instead of the `ci_gate` check. The following strings are byte-identical across Python, TypeScript, and PowerShell, and are emitted in this order:

1. `Checkpoint completion validation failed: child_ci integration_only requires local_qc_gate to be an object with keys: conclusion, head_sha, evidence_path, verified_at.` (returned alone)
2. `Checkpoint completion validation failed: local_qc_gate missing required fields: <keys>.` (`<keys>` is the missing key names joined by `, `, in the order `conclusion, head_sha, evidence_path, verified_at`, matching the existing `ci_gate` message)
3. `Checkpoint completion validation failed: local_qc_gate.conclusion must be success.`
4. `Checkpoint completion validation failed: child_ci integration_only requires review_mode concurrent.`
5. `Checkpoint completion validation failed: local_qc_gate.head_sha must match the head_sha of the last review_outcomes entry.` (evaluated only when string 4 is not emitted)

- The existing concurrent-review completion rule still runs and still requires the last `PASS` outcome with `head_sha`.
- The same checkpoint without the opt-out reports the existing `ci_gate` errors unchanged.
- Python: inline, key-gated change in `scripts/dev_tools/validate_orchestrator_state.py`, confined to the `route_requires_ci_gate` block and new private helpers in the same file.
- TypeScript: new `extensions/drm-copilot/src/lib/validate/orchestrator-state-child-ci.ts`, selected from `orchestrator-state-core.ts`, with its own `coverageThreshold` entry in `extensions/drm-copilot/jest.config.cjs`.
- PowerShell: inside `Get-OrchestratorStateCompletionCiGateError` in `.claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1` and its bundle copy; `OrchestratorStateCompletion.psm1` is unchanged.
- Shared corpus: `tests/fixtures/orchestrator_state_child_ci/*.json` in the `{name, notes, checkpoint, expected_errors}` shape, read by all three runtimes with a corpus-count floor.

## Local-QC-Gate Evidence File Contract

- Path: `<feature-folder>/evidence/qa-gates/local-qc-gate.<timestamp>.md`, where `<timestamp>` follows `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.
- Writer: the child orchestrator at S9, from the final QA artifacts, under the opt-out only.
- Content: a `Timestamp:` line with a clock-read UTC stamp; the line `Head: <sha>` naming the reviewed head; an `EXIT_CODE:` line whose first occurrence has value `0` (first-occurrence rule of the evidence schema).
- Commit: committed on the PR branch so the file exists in the live head tree. The commit touches only the feature folder, so it does not make the concurrent review stale.
- Record: `local_qc_gate.evidence_path` is the file's repository-relative path with forward slashes; `local_qc_gate.head_sha` equals the `Head:` value; `local_qc_gate.conclusion` is `success`; `local_qc_gate.verified_at` is an ISO 8601 UTC date-time.
- The file is append-only evidence; it is never edited or deleted after it is written.

## Skill Procedure Changes

- **Orchestrate** (`.claude/skills/orchestrate/SKILL.md`, `.agents/skills/orchestrate/SKILL.md`, and bundle copies): a new paragraph `Child CI opt-out (issue #1233)` at the end of `## Step S9 - CI Green Gate` (Codex: `## CI Green Gate`). Under the predicate, S9 resolves head and base with `gh pr view --json headRefOid,baseRefName`; when the base is not `epic_context.integration_branch`, the opt-out does not apply. Otherwise S9 does not query checks as a gate, never dispatches `CI`, writes and commits the local-QC evidence file, records `local_qc_gate` and `step9_status: "passed"`, and step 6 merges. The paragraph states that the opt-out requires `review_mode: "concurrent"` (a resumed sequential run stays `per_child`), that the join's CI conditions (item 5 of `## Concurrent Review and CI (review_mode)`) are met by `local_qc_gate`, that item 11 compares cross-check rows with the local final-QC evidence rather than `gh pr checks`, and that CI-dependent criteria are listed as pending integration CI. `## Checkpoint Schema - CI Gate Fields` adds `child_ci` and `local_qc_gate`. `## PR Creation Gate` condition 6 (Codex: condition 5) adds the `local_qc_gate` alternative under the predicate.
- **Epic-orchestrate** (`.claude/skills/epic-orchestrate/SKILL.md`, `.agents/skills/epic-orchestrate/SKILL.md`, and bundle copies): the manifest `child_ci` key and its validation; copying it to the epic checkpoint; the extra kickoff line; a qualifying paragraph after the `Epic-child CI verification (issue #1130)` paragraph (no child dispatch; no `ci_green` status for an opted-out child, which moves from `pr_open` to `merged`); the `## Epic-Level Checkpoint` field list; a lifecycle step 6 note that the integration PR S9 is unchanged and that child CI-dependent criteria are checked off in the integration worktree after integration CI is green (issue #1141).
- **Epic-run** (`.claude/skills/epic-run/SKILL.md`, `.agents/skills/epic-run/SKILL.md`, and bundle copies): one new sentence stating that the per-child green-`CI` requirement is replaced under `child_ci: integration_only`.
- **Epic-plan** (edit `.agents/skills/epic-plan/SKILL.md`, regenerate `.claude/skills/epic-plan/SKILL.md`, update bundle copies): the planner writes `child_ci` only when the owner chose the opt-out, and avoids CI-dependent child criteria or marks them pending integration CI.
- **Rule** (`scripts/harness-generation/sources/rules/orchestrator-state.md` and `.json`; generated `.claude/rules/orchestrator-state.md` and bundle copy): a new section `epic-child-ci-opt-out-issue-1233` after `epic-child-ci-verification-issue-1130`, added to the Claude target `sections` list, plus one Enforcement bullet. The section discloses that `child_ci` is self-declared by the item checkpoint (policy-level limit) and names the live-base, concurrent-review, and evidence checks that bound the reduction.
- **Execution-environment brief** (edit `.agents/skills/execution-environment/SKILL.md`, regenerate `.claude/skills/execution-environment/SKILL.md`, copy to `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`): extend the `## Hook Execution Context` "Child-CI helper (#1130)" bullet and the `## CI Shape and Required Checks` "Epic-child dispatch (#1130)" bullet; add an MCP-route note (the installed MCP lacks the TypeScript rule until an extension release, so an opted-out child checkpoint is checked with the repository Python CLI on Claude, and the opt-out is unavailable on Codex until then); add the new skill-text contract test to `## Contract Tests That Pin Mirrored Files`.
- **Template** (`.dev/templates/epic/epic.md` and `extensions/drm-copilot/resources/feature-templates/epic/epic.md`): a commented optional `child_ci` key.
- **Copilot surfaces**: no file under `.github/` describes the epic-child CI rule; none is changed (D1).

## Inputs / Outputs

- Inputs: epic manifest `child_ci`; epic checkpoint `child_ci`; delegation prompt line `Child CI: integration_only.`; item checkpoint `epic_mode`, `child_ci`, `epic_context.integration_branch`, `review_mode`, `remediation_loop.review_outcomes[]`, `local_qc_gate`, `pr_gate.pr_number`; live PR `headRefOid` and `baseRefName`; evidence file in the live head tree.
- Outputs: allow or deny decision of the merge gate with `EPIC_CHILD_LOCAL_QC_NOT_VERIFIED` deny reasons; completion-consistency allow or deny; validator error strings; the local-QC evidence file; the process-reduction ledger entry.
- Config keys and defaults: `child_ci` defaults to `per_child` when absent.
- Backward compatibility: every checkpoint, manifest, and hook input without the key behaves as today.

## Data & State

- Invariant: under the opt-out, `ci_gate` is absent from the item checkpoint and `local_qc_gate` is present at completion; a non-success CI conclusion is never synthesized.
- Invariant: `local_qc_gate.head_sha` equals the `head_sha` of the last review outcome and the `Head:` line of the evidence file.
- Persistence: the evidence file is committed on the PR branch; the checkpoint keys are written by the orchestrator only.
- Migration: none. Running epics without the key are unaffected.

## Constraints & Risks

- No new Python module. The Python change is inline and key-gated in `scripts/dev_tools/validate_orchestrator_state.py`. Python test cases go into the existing `tests/scripts/dev_tools/test_validate_orchestrator_state_completion.py`.
- New logic otherwise is PowerShell or bash; TypeScript only for the extension validator port.
- Existing ledger regions recorded by process-reduction entries 0002, 0003, 0007, 0009, 0010, and 0011 must not be edited. The opt-out text goes in new paragraphs outside those regions; in `validate_orchestrator_state.py` the `_orchestrator_state_concurrent_review` import line and the `errors.extend(validate_concurrent_review_completion(state_map))` line are not touched, and the new `jest.config.cjs` entry is placed outside the recorded regions.
- Do not edit `.claude/lib/docs` or the docs skills (epic #1217).
- Keep edits to test-cadence wording files minimal and outside cadence sentences (issue #1228); this feature edits no agent source and not `atomic-plan-contract`.
- Hooks fired for isolated subagents run the default branch's scripts, so the new gate and completion behavior apply only after merge. Behavior is proven by Pester rows with mocked seams only, not by a live run.
- File size: no edited file may exceed 800 lines; new logic goes into the byte-identical helpers and the new TypeScript module.
- Test runs are parallel only. The full suite runs only at the Phase 0 baseline and in the final QC loop; every other run is targeted.
- Pester rows mock `Invoke-DocsOnlyGhExe`, `Invoke-DocsOnlyGitExe`, and the checkpoint read seams by name, create no temporary files, and leave no global state.
- Risk: a child defect that only CI would catch is found later, at the integration PR. The integration PR's full `CI` run is the backstop.
- Risk: `child_ci` is self-declared by the item checkpoint (same-session forgery, the accepted policy-level limit of every gate key). Bounded by the live-base check, the concurrent-review requirement, and the evidence check; disclosed in the rule section and the ledger entry.

## Non-Goals

- No change to any workflow file, including `.github/workflows/ci.yml` and `.github/workflows/README.md` (D1).
- No change to the integration-to-`main` PR gate (merge-gate branch 2) or its S9.
- No change to `per_child` behavior.
- No change to `enforce-epic-merge-gate-review.ps1` (D3) or to integration-tip regeneration CI (D4).
- No change to `.codex/scripts/epic-child-launch-contract.ps1` (D6) or to the epic checkpoint validators.

## Implementation Strategy

- Scope: research Section 7 file inventory.
- New functions: `Get-EpicMergeGateChildCiLivePullRequest`, the `EPIC_CHILD_LOCAL_QC_NOT_VERIFIED` prefix constant and stages B, R, L1, L2, L3 in the child-CI helper; `-GitRoot` on `Get-EpicMergeGateChildCiDecision`; `Test-CompletionChildCiIntegrationOnly` and `Get-CompletionLocalQcGateMissing` in the completion helpers; private local-QC helpers in the Python validator; `orchestrator-state-child-ci.ts`.
- New tests: `tests/scripts/claude-hooks/enforce-epic-merge-gate.ChildCiOptOut.Tests.ps1`; `tests/scripts/codex-hooks/enforce-epic-merge-gate-child-ci-opt-out.Tests.ps1`; `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateChildCi.Tests.ps1`; `extensions/drm-copilot/test/lib/validate/orchestrator-state-child-ci.test.ts`; `tests/scripts/claude-runtime/child-ci-opt-out-skill-contract.Tests.ps1`; corpus `tests/fixtures/orchestrator_state_child_ci/`. Extended: both completion-consistency suites, `tests/scripts/codex-hooks/enforce-completion-helpers.Tests.ps1`, `tests/scripts/dev_tools/test_validate_orchestrator_state_completion.py`.
- Dependency changes: none.
- Rollout: key-gated; inert until an epic manifest sets `child_ci: integration_only`, and effective for isolated subagents only after merge to `main`.

## Acceptance Criteria

- [x] With the activation predicate true, the live PR base equal to `epic_context.integration_branch`, `review_mode: "concurrent"` with a current `PASS` review, a valid `local_qc_gate`, and the evidence file at the live head, the epic merge gate allows a child merge into its integration branch without any `CI` run on the child head, on both Claude and Codex. Verified by allow rows in `enforce-epic-merge-gate.ChildCiOptOut.Tests.ps1` and `enforce-epic-merge-gate-child-ci-opt-out.Tests.ps1`.
- [x] With `child_ci` absent, `per_child`, a case variant, a non-string value, or `epic_mode` not the JSON boolean `true`, the merge gate behaves as today: the new seam `Get-EpicMergeGateChildCiLivePullRequest` is never called and every deny text is unchanged. Verified by default rows in both new merge-gate suites and by the unchanged existing suites `enforce-epic-merge-gate.ChildCi.Tests.ps1` and `tests/scripts/codex-hooks/enforce-epic-merge-gate-child-ci.Tests.ps1`.
- [x] The gate never applies the opt-out to a pull request whose base is `main` or any branch other than the recorded integration branch, nor when `epic_context.integration_branch` is missing or does not match `^epic/[A-Za-z0-9][A-Za-z0-9._-]*-integration$`: in those cases per-child CI verification decides (deny `EPIC_CHILD_CI_NOT_VERIFIED` without `ci_gate`, allow with green CI). Verified by main-base and base-mismatch rows in both new merge-gate suites.
- [x] Each opt-out failure (stage B lookup returns `$null`; stage R without `review_mode: "concurrent"`; stage L1 for a missing object, a non-success conclusion, a malformed `head_sha`, and a malformed or out-of-folder `evidence_path`; stage L2 head mismatch; stage L3 for a missing file, a non-zero first `EXIT_CODE:`, and a missing or mismatched `Head:` line) denies with `EPIC_MERGE_GATE_BLOCKED: EPIC_CHILD_LOCAL_QC_NOT_VERIFIED: stage <id> (<name>): <detail>` and does not fall through. Verified by deny rows in both new merge-gate suites.
- [x] The Claude gate passes the item worktree root as `-GitRoot` to `Get-EpicMergeGateChildCiDecision`, and `-GitRoot` defaults to `GhRoot` when omitted. Verified by a Claude row in `enforce-epic-merge-gate.ChildCiOptOut.Tests.ps1` and a default row in the Codex suite.
- [x] The completion-consistency hooks on Claude and Codex accept a DONE checkpoint of an opted-out child only when `local_qc_gate` has `conclusion` `success` and non-empty `head_sha` and `evidence_path`, deny it otherwise, and keep today's deny text byte-unchanged for every checkpoint without the key. Verified by extended rows in both completion-consistency suites and in `tests/scripts/codex-hooks/enforce-completion-helpers.Tests.ps1`.
- [x] The Python, TypeScript, and PowerShell validators accept a completed opted-out child checkpoint without `ci_gate`, emit each string listed in `## Validator Error Strings` for its failing condition in the stated order, and report the existing `ci_gate` errors for the same checkpoint with the opt-out removed. Verified by the shared corpus `tests/fixtures/orchestrator_state_child_ci/` read by `test_validate_orchestrator_state_completion.py`, `orchestrator-state-child-ci.test.ts`, and `OrchestratorStateChildCi.Tests.ps1`.
- [x] The validator error strings are byte-identical across Python, TypeScript, and PowerShell, proven by the Python, TypeScript, and PowerShell suites each asserting the same `expected_errors` values from the shared corpus.
- [x] The Python change is confined to `scripts/dev_tools/validate_orchestrator_state.py`, adds no new Python module, and leaves the `_orchestrator_state_concurrent_review` import line and the `errors.extend(validate_concurrent_review_completion(state_map))` line unchanged; the new TypeScript module meets its own `coverageThreshold` entry in `extensions/drm-copilot/jest.config.cjs`. Verified by diff review and the jest coverage gate.
- [x] The orchestrate skills (Claude and Codex) state the S9 opt-out procedure: base check, no check query as a gate, no `CI` dispatch for child heads, local-QC evidence written and committed, `local_qc_gate` and `step9_status: "passed"` recorded, and the `review_mode: "concurrent"` requirement; the `## Checkpoint Schema - CI Gate Fields` and `## PR Creation Gate` sections name `child_ci` and `local_qc_gate`. Verified by `child-ci-opt-out-skill-contract.Tests.ps1`, with `test_ci_gate_epic_child_contracts.py` still green.
- [x] The epic-orchestrate, epic-run, and epic-plan skills (Claude, Codex, and bundle copies) and the epic manifest template state the `child_ci` key, its validation, its copy to the epic checkpoint, the separate kickoff line, and that the integration PR still requires green `CI`. Verified by `child-ci-opt-out-skill-contract.Tests.ps1`, with `early-start-skill-contract.Tests.ps1` (kickoff literal) still green.
- [x] The generated rule `.claude/rules/orchestrator-state.md` and its bundle copy contain the section `epic-child-ci-opt-out-issue-1233`, including the self-declared-key disclosure, generated from the rule source. Verified by `HarnessGeneration.RepoGate.Tests.ps1` and the skill-text contract test.
- [x] The execution-environment brief is updated identically in `.agents/skills/execution-environment/SKILL.md`, `.claude/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`, and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`, covering the "Child-CI helper" bullet of `## Hook Execution Context`, the "Epic-child dispatch" bullet of `## CI Shape and Required Checks`, the MCP-route note, and the new contract test entry. Verified by the bundle-parity contract tests and the skill-text contract test.
- [x] `PINNED_FROZEN_SURFACE_HASHES` in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` carries the re-baselined digest of `.claude/skills/epic-orchestrate/SKILL.md` with a `# RE-BASELINED by issue #1233` paragraph naming the edited sections and the moved digest. Verified by `test_parallel_orchestrator_surface_contracts.py`.
- [x] The Claude and Codex copies of `enforce-epic-merge-gate-child-ci.ps1` and `enforce-completion-helpers.ps1` stay byte-identical, and every bundle copy matches its source. Verified by `cross-tree-helper-identity.Tests.ps1`, `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, both pack-manifest completeness tests, and `test_push_down_pack_manifest_dependency_closure.py`.
- [x] `scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Check` reports no drift, and the Codex generator `--check` passes.
- [x] A new process-reduction ledger entry `.dev/engineering/process-reductions/<NNNN>-epic-child-ci-opt-out.md` and its README index row record the reduction with `## Prior Text` and/or a stored patch, the fixed `## Revert Steps` labels, `## Revert Signals`, the residual automatic `CI` run on child PRs (D1), and the self-declared-key disclosure, and no region recorded by an existing ledger entry is edited. Verified by `ProcessReductionChain.Ledger.Tests.ps1` and `ProcessReductionLedger*.Tests.ps1` run on the committed tree.
- [x] No edited file exceeds the file-size hard limit stated in `.claude/rules/general-code-change.md`, and `.github/workflows/ci.yml`, `enforce-epic-merge-gate-review.ps1`, `.claude/lib/docs`, and the docs skills are unchanged. Verified by `FileSizePolicy.RepoGate.Tests.ps1` and diff review.
- [ ] The mandatory toolchain loop passes for PowerShell, Python, and TypeScript in scope, and the pull request's own `CI` run is green.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests
- [ ] Behavior matches acceptance criteria on Claude and Codex surfaces
- [ ] Tests updated/added (Pester, pytest, jest, contract tests)
- [ ] Edge cases and error handling covered by tests
- [ ] Skills, rule, brief, template, and bundle copies updated
- [ ] Toolchain pass completed (format, lint, type-check, test)

## Seeded Test Conditions (from potential)

- [ ] Merge-gate Pester tests: allow, deny, and main-base cases
- [ ] Validator corpus fixtures for the Python, TypeScript, and PowerShell runtimes
- [ ] Hook byte-identity and bundle parity tests
