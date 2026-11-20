# Research: Regenerate-after-merge path for integration and main syncs (Issue #1156)

- Issue: #1156
- Branch: feature/regenerate-after-integration-merge-1156
- Scope source: `docs/features/active/regenerate-after-integration-merge-1156/issue.md` (authoritative; seven acceptance criteria AC1-AC7, numbered in issue order)
- Spec status: `spec.md` and `plan.2026-11-09T16-31.md` in the feature folder are unfilled templates at the time of this research.
- Method: every finding below was verified by reading the cited file. Facts that need `git` or `gh` are marked "to confirm by orchestrator". No line numbers or commit identifiers are cited.

## 1. Current State: merge-conflict and main-sync handling

### 1.1 Where "merge conflict -> synthetic Blocking finding -> remediation cycle" is stated

| Surface | Location | What it states |
|---|---|---|
| `.claude/skills/orchestrate/SKILL.md` | `## Step S9 — CI Green Gate`, step 6 | On a non-mergeable epic-child PR: "convert the conflict into a synthetic Blocking finding per "Merge-Conflict Remediation" below and re-enter the standard R1–R5 remediation loop". A `not_queued` outcome with `mergeable: CONFLICTING` also follows "Merge-Conflict Remediation". |
| same | (no such heading) | **Defect found:** the skill has no section named `Merge-Conflict Remediation`; the headings are `## Remediation Loop (R1–R5)`, `## Remediation Loop — CI-Failure Handling`, `## Concurrent Review and CI (review_mode)`. The reference in S9 step 6 is dangling (same in the bundle mirror `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`). The new regenerate path is the natural content for that missing section (see D2). |
| same | `## Remediation Loop (R1–R5)`, "Cycle accounting" paragraph | `candidate_applied: true` + increment `completed_attempts` only after R3 `execution_status: "complete"` and a non-empty pre-R4 commit. "Local, CI-failure, merge-conflict, and parallel-drift cycles share the one count." |
| same | "Remediation mode" paragraph | "CI-failure and merge-conflict cycles are never light" (pinned token in `tests/scripts/claude-runtime/light-remediation-skill-contract.Tests.ps1`). |
| same | `**Termination guard:**` | halt when `completed_attempts` equals 3 and the latest verdict is not `PASS`. |
| same | `## Concurrent Review and CI (review_mode)` rule 7 "Re-entry" | "Any code push after a `PASS`, including a CI fix or a merge of `origin/main`, is a stale head and requires a new review" (pinned token in `tests/scripts/claude-runtime/concurrent-review-skill-contract.Tests.ps1`). |
| same | rule 11 "CI cross-check" | the join compares the policy audit's `## CI Cross-check` rows against the `head_sha` of the last `review_outcomes[]` entry; a mismatch becomes a synthetic Blocking finding. Relevant to D5. |
| same | `## Review Verdict Status (review/verdict)` rules 2 and 4 | a merge of `origin/main` is a new push; the entry point `Invoke-ReviewVerdictStatus.ps1` runs immediately before S9 steps 6 and 7 and "A refusal means no merge and a new review." Relevant to D5. |
| `.claude/skills/epic-orchestrate/SKILL.md` | `## Merge-Conflict Handling (Fan-In)` steps 1-6 | Child `atomic-executor` runs `git fetch origin <integration_branch>`, `git merge --no-commit origin/<integration_branch>`, captures `git diff --name-only --diff-filter=U` plus marker excerpts, writes `remediation-inputs.<timestamp>.md` (severity Blocking) in the child folder; R1-R5 runs "unmodified"; conflict cycles share `completed_attempts`; `blocked_conflict_loop_limit` after three. |
| same | `## Epic Integration Branch Lifecycle` step 3 | epic-orchestrator merges `origin/main` into the integration branch (`git merge --no-ff origin/main`, "resolving any conflicts"), pushes, then launches the wave. No CI verification step is stated for the integration tip. |
| same | `## Early Dependent Starts (early_start)` step 7 | child merges `origin/<integration_branch>`; "A conflict enters `## Merge-Conflict Handling (Fan-In)`". |
| `.claude/skills/parallel-orchestrate/SKILL.md` | `## Per-Item Merge-Conflict Handling` | Parent first runs `Resolve-MergeableConflict.ps1` (issue #643, project-file class); on `escalate`, parent re-delegates the child, whose `atomic-executor` captures conflicts after `git merge --no-commit origin/main` and writes a synthetic Blocking finding; the child runs "its unmodified R1 through R5"; "Drift cycles share the child's `remediation_loop.completed_attempts`". |
| same | `## Per-Item Merge to Main (Merge-on-Green)` step 3 | a `not_queued` non-conflict outcome "re-delegates the item's child to merge `origin/main` and re-run S9 as one CI-failure remediation cycle, consuming a remediation attempt". |
| `.claude/agents/orchestrator.md` | `### Remediation Loop Checkpoint Shape` | `completed_attempts` "is the shared attempt count for local, CI-failure, merge-conflict, and parallel-drift cycles"; full `cycles[]` field list; `remediation_path` is `light` or `full`. |
| `.claude/agents/epic-orchestrator.md` | `## Skill` | defers merge-conflict handling to the skill. Tools: `Bash(git *)`, `Bash(gh *)`, and four named `pwsh -NoProfile -File` scripts only; no generic command route. |
| `.claude/agents/parallel-orchestrator.md` | references the skill's `## Per-Item Merge-Conflict Handling` | no independent rule. |
| `.claude/skills/remediation-handoff/SKILL.md` | not present | only `remediation-handoff-atomic-planner` is referenced from the orchestrate skill (R2 halt). |

### 1.2 Accounting authority

`completed_attempts` / `candidate_applied` are validated by invariants R5-R7 in `.claude/rules/orchestrator-state.md` (`## Invariants (per remediation cycle)` items 4, 5, 7) and implemented in `_validate_remediation_accounting` of `scripts/dev_tools/_orchestrator_state_remediation_loop.py`: `completed_attempts` must equal the count of `cycles[]` objects whose `candidate_applied` is `true`. Consequence: anything recorded **outside** `cycles[]` cannot affect the count; anything recorded **inside** `cycles[]` with `candidate_applied: true` always consumes an attempt.

## 2. Orchestration config

- `config/orchestration-routing.json` top-level keys: `version`, `routes`, `model_policy`, `model_budget`, `codex_topology_policy`, `discovery_operations`, `codex_model_policy`, `docs_operations`.
- It is byte-mirrored to `extensions/drm-copilot/resources/config/orchestration-routing.json`, pinned by `tests/scripts/dev_tools/test_orchestration_routing_config_parity.py` (`test_canonical_and_bundled_routing_config_are_byte_identical`).
- Push-down merges it into destinations through `merge_routing_documents` (`scripts/dev_tools/push_down_claude_routing_merge.py`, TypeScript twin `extensions/drm-copilot/src/lib/push-down/claude-routing-merge.ts`): destination top-level keys keep destination values; **source top-level keys the destination lacks are appended**. A `regeneration` block committed here would therefore be byte-mirrored into the bundle and appended into every destination that lacks one, carrying this repository's command and globs into unrelated repositories. That is the opposite of "repository-declared".
- `push_down_customizations` in `scripts/dev_tools/push_down_claude_customizations.py` reads `config/` from the bundle only: "repo-only configuration is never published". `EXCLUDED_RELATIVE_PATHS` lists `config/blast-radius.local.json` (the destination-owned overlay precedent of issue #508). No delete-on-push of unknown destination config files was found in `scripts/dev_tools/push_down_claude_destination_writes.py` (searched for unlink/remove/delete/stale; none). Destination preservation of a destination-only file is to be confirmed by a push-down test in the plan.
- Loaders of `orchestration-routing.json`: Python (`scripts/dev_tools/resolve_delegation_model.py`, `_orchestrator_state_route_gates.py`, `_orchestrator_state_model_routing_gate.py`, `compute_complexity_floor.py`), PowerShell (`.claude/lib/orchestrator-state/OrchestratorStateRoutingMatrix.psm1`, `.claude/lib/model-routing/ModelRouting.psm1`, `.claude/lib/codex-routing/*.psm1`), TypeScript (`extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts`). None needs a regeneration key.

## 3. Checkpoint schema and validators

- Python, TypeScript, and PowerShell validators carry no closed top-level key set: `.claude/rules/orchestrator-state.md` (`## Owner-Directive Scope and Backward Compatibility`, "Known limitations") states the Python and TypeScript validators ignore unknown top-level keys; searches for "unknown key"/"unexpected key" in `.claude/lib/orchestrator-state/` and `scripts/dev_tools/*orchestrator_state*.py` found none. Tolerated-key precedents: `parallel_mode`, `parallel_slug`, `pr_merge`, `stage_timing`, `early_start_synced_at`, `ci_gate.dispatch_run_id`.
- `review_outcomes[]` entries: `_validate_review_outcome` reads only `verdict` and `findings[].remediability` (R8-R10); extra keys such as `head_sha` are tolerated. A `PASS` entry with `findings: []` is valid in all three runtimes (corpus fixture `verdict_pass_valid.json`).
- Invariant 8 rule 1 (`scripts/dev_tools/_orchestrator_state_light_cycle.py`, `extensions/drm-copilot/src/lib/validate/orchestrator-state-light-cycle.ts`, `Get-RemediationLightCycleError` in `.claude/lib/orchestrator-state/OrchestratorStateRemediationAccounting.psm1`) rejects any `remediation_path` other than `light`/`full`. A `regenerate` value is a three-runtime contract change plus corpus edits, and a regenerate cycle inside `cycles[]` would also have to carry `plan_path` (invariant 1) and be excluded from R7 by a new rule.
- Shared corpus `tests/fixtures/orchestrator_state_remediation_loop/*.json` (`name`, `notes`, `checkpoint`, `expected_errors`) is globbed by all three parity suites: `tests/scripts/dev_tools/test_orchestrator_state_remediation_loop_parity.py`, `extensions/drm-copilot/test/lib/validate/orchestrator-state-remediation-loop-parity.test.ts`, `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationLoop.Parity.Tests.ps1`. Adding a fixture with `expected_errors: []` proves tolerance in all three runtimes with no validator code change.
- `tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py` (`test_docs_contract_documents_share_review_outcome_section`) requires the `## Invariants (remediation_loop.review_outcomes)` section of the rules file to equal the same section of `.agents/skills/orchestrator-state/SKILL.md`. New documentation therefore belongs in a new section, not inside that one.
- Epic checkpoint (`scripts/dev_tools/validate_epic_orchestrator_state.py` and helpers): no closed key set found; a tolerated top-level key is accepted (to be proven by a fixture or test in the plan).
- Portable handoff projection is a closed key set (`## Concurrent Review and CI (review_mode)` rule 8), so a tolerated key is dropped on handoff, the same as `review_mode`.

## 4. Merge gates

- `.claude/hooks/enforce-epic-merge-gate.ps1` dot-sources `-authorization`, `-resolution`, `-command`, `-green-ci`, `-review`, `-child-ci` (guarded `try { . (Join-Path $PSScriptRoot ...) } catch { Add-HookDependencyFailure ... }`). The review guard runs before every allow branch: `Get-EpicMergeGateReviewShapeDecision`, then `Get-EpicMergeGateReviewDecision`.
- `.claude/hooks/enforce-epic-merge-gate-review.ps1` (byte-identical at `.codex/hooks/`) is inert without `review_mode: "concurrent"`. `Get-EpicMergeGateReviewDecision` reads only the last `review_outcomes[]` entry's `verdict` and `head_sha`, then `Get-EpicMergeGateReviewHeadState`: equal to the live head is current; an ancestor is current only when every changed path lies under `feature-folder`.
- Consequence for the regenerate path: a merge commit (and any regeneration content in it) is a code change, so the prior feature-review `PASS` becomes `REVIEW_GATE_HEAD_STALE`. If the regenerate path appends a new `review_outcomes[]` entry `{verdict: "PASS", findings: [], head_sha: <new pushed head>}`, the guard allows with **no logic change**, because `head_sha` equals the live head. The minimal acceptance of regenerate evidence is therefore producer-side; any gate change is a consistency check, not a relaxation (D6).
- `Get-ReviewVerdictReviewDecision` in `.claude/lib/review-verdict/ReviewVerdictEligibility.psm1` also reads the last entry's `head_sha`; with the delta entry at the live head and the earlier `policy-audit.<ts>.md` still the latest committed audit, `-Mode Review` returns eligible (`$live -ceq $reviewed`). The posted description would read `feature-review PASS: <older audit>` (disclosure item, D5).
- `Get-ReviewVerdictMainSyncDecision` (same module) is a verified precedent for the delta check: two parents R and M, merge base B, `diff(B,R)` and `diff(B,M)` disjoint, `diff(R,H) ⊆ diff(B,M)`, `diff(M,H) ⊆ diff(B,R)`, all via `git diff --name-only -z --no-renames`. It uses a pure fact-request decision pattern (`REVIEW_VERDICT_FACT_REQUIRED` with a `Request` naming one `git`/`gh` call) with all I/O in `Invoke-ReviewVerdictStatus.ps1`.
- Child-CI branch (`enforce-epic-merge-gate-child-ci.ps1`) requires `ci_gate.head_sha` equal to the live PR head and a successful `CI` `pull_request` or recorded `workflow_dispatch` run; unchanged by this item because the regenerate path re-runs S9 on the new head.
- Existing Pester suites pinning gate decisions (AC7 regression base): `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1`, `.ReviewGuard.Tests.ps1`, `.ReviewPaths.Tests.ps1`, `.ChildCi.Tests.ps1`, `.GreenCi.Tests.ps1`, `.GreenCiDecision.Tests.ps1`, `.GreenCiRegression.Tests.ps1`, `.EpicModeStrict.Tests.ps1`, `.Authorization.Tests.ps1`, `.AuthorizationFields.Tests.ps1`, `.MergeQueue.Tests.ps1`, `.DocsOnly.Tests.ps1`, `.ItemResolution.Tests.ps1`, `.WorktreeResolution.Tests.ps1`, `.TriggerScoping.Tests.ps1`, `.Coverage.Tests.ps1`; Codex: `tests/scripts/codex-hooks/enforce-epic-merge-gate-*.Tests.ps1`; review-verdict: `tests/scripts/claude-lib/review-verdict/ReviewVerdictEligibility.Review.Tests.ps1`; preimplementation epic scope: `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicFanIn.Tests.ps1`, `.EpicScope.Tests.ps1`, `hook-epic-fan-in.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-fan-in.Tests.ps1`.

### 4.1 Preimplementation gate on the integration branch (affects AC5)

- `Get-EpicCommandLegReadinessFailure` (`.claude/lib/worktree-resolution/EpicScopeReadiness.psm1`) returns `'merge-in-progress'` when **no** merge is in progress (`MERGE_HEAD` absent). In epic scope (worktree HEAD equals `integration_branch`), `git add`, `git commit`, and Write/Edit are denied unless a merge is in progress or an allowance applies (`Get-EpicFanInAllowance`, `Get-EpicMergedFeatureFollowUpAllowance` in `.claude/hooks/hook-epic-fan-in.ps1`, called from `Get-OrchestrationEpicScopeDecision` in `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`).
- Consequence: the epic main sync (lifecycle step 3) can commit regenerated outputs because `MERGE_HEAD` exists during `git merge --no-ff --no-commit`; the **post-feature-merge** regeneration of AC5 (no merge in progress) is denied today. A narrow new allowance is required (D7). Running `git commit` inside a script to avoid the hook would be a gate bypass and is rejected.

## 5. Language and placement

- Owner brief: new pushed-down logic in PowerShell or bash; TypeScript only for MCP/extension; no new Python. Enforcement hooks must not invoke Python (`tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`).
- Reusable glob engine: `Test-GlobMatch` in `.claude/lib/blast-radius/BlastRadiusGlob.psm1` (pure; `**`, `*`, `?` only; whole-string, ordinal, case-sensitive; `*`/`?` do not cross `/`; character classes unsupported and escaped as literals). It is already in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, so importing it satisfies the dependency-closure test for a core lib. Semantics caveat: `**/x` does not match a root-level `x`; the mechanically-mergeable matcher in `.claude/rules/parallel-orchestration.md` (`### Mechanically-mergeable path class (issue #643)`) handles this by also testing the entry with the `**/` prefix removed. The classifier should adopt the same rule.
- Coverage and test discovery: `config/poshqc-coverage.json` roots include `.claude/lib` and `.claude/hooks`; `config/poshqc-scan.json` scans `tests/scripts`. New modules and tests are picked up with no config change.

## 6. Deterministic derivation of conflicted and auto-merged paths

During an in-progress `git merge --no-commit --no-ff <ref>` (HEAD = feature head P1, `MERGE_HEAD` = incoming tip P2):

1. Merge bases: `git merge-base --all HEAD MERGE_HEAD`. More than one base (criss-cross history) makes the "changed on both sides" relation ill-defined against git's virtual base; fail closed to the remediation loop.
2. Ours: `git diff --name-only -z --no-renames <B> HEAD`. Theirs: `git diff --name-only -z --no-renames <B> MERGE_HEAD`. `--no-renames` lists both sides of a rename, as `Invoke-CiChangeScope.ps1` and `Get-ReviewVerdictMainSyncDecision` already do.
3. Conflicted: `git diff --name-only -z --diff-filter=U` (the form `## Merge-Conflict Handling (Fan-In)` already uses); `git ls-files -u -z` is an equivalent cross-check (stage 1-3 entries).
4. Classifier input set = ours ∩ theirs (this contains every conflicted path and every auto-merged path). It also contains paths both sides changed identically; including them is conservative (fail-closed direction). Parsing `Auto-merging <path>` lines from merge output is rejected: the text is localizable porcelain.
5. Completed merge commit H: parents from `git log -1 --format=%P <H>` (exactly two required), then steps 1-4 with P1, P2 in place of `HEAD`, `MERGE_HEAD`.

All of these are `git` reads with deterministic output; they belong in the I/O adapter, with the pure module receiving NUL-separated listings.

## 7. Push-down payload and contract tests

Mirrors required for each edited or new file:

- `.claude/skills/orchestrate/SKILL.md`, `.claude/skills/epic-orchestrate/SKILL.md`, `.claude/skills/parallel-orchestrate/SKILL.md`, `.claude/agents/orchestrator.md`, `.claude/agents/epic-orchestrator.md`, `.claude/rules/orchestrator-state.md`: bundle copies under `extensions/drm-copilot/resources/claude-customizations/.claude/...` (`test_push_down_claude_resource_contracts.py`).
- New `.claude/lib/regeneration/*` and new `.claude/hooks/*.ps1`: bundle copies plus entries in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (`test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`).
- New `.codex/hooks/*.ps1` twins: bundle copies under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/` and entries in `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`. The brief says the Codex `core.json` is generated by `scripts/dev_tools/generate_codex_agent_variants.py`; whether that covers hook entries is to confirm by running the generator with `--check`.
- `PINNED_FROZEN_SURFACE_HASHES` in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` pins `.claude/agents/epic-orchestrator.md` and `.claude/skills/epic-orchestrate/SKILL.md`; both digests move and must be re-baselined with a dated comment, following the twelve prior re-baseline comments in that file.
- Pinned wording to preserve verbatim: `concurrent-review-skill-contract.Tests.ps1` (rule 7 sentence), `light-remediation-skill-contract.Tests.ps1` ("CI-failure and merge-conflict cycles are never light"), `test_orchestrator_state_remediation_docs.py` literals (`completed_attempts + 1`, "three completed attempts", `` `remediation_pass` equals `remediation_loop.completed_attempts` ``). Additions must be appended sentences, not rewrites.
- `.agents/` (Codex) skills: `.agents/skills/orchestrate/SKILL.md` and `.agents/skills/epic-orchestrate/SKILL.md` are hand-maintained Codex variants, not byte copies. Recommended: no edit (Codex behavior stays today's behavior; disclosed in the rules file), see D10.
- Execution-environment brief (six byte-identical copies): this change alters stated facts (the preimplementation gate's epic allowances in `## Hook Execution Context`, the merge-guard bullet, and the epic-child dispatch bullet in `## CI Shape and Required Checks` gains an integration-tip dispatch). A brief-update task in all six copies is required: `.claude/skills/execution-environment/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md`.

## 8. File-size risk (line counts by line-anchored match; Markdown is exempt)

| File | Lines | Tier / note |
|---|---|---|
| `.claude/hooks/enforce-epic-merge-gate-review.ps1` | 699 | one line below the 700 advisory tier; do **not** edit; byte-identical Codex twin also 699 |
| `.claude/lib/review-verdict/ReviewVerdictEligibility.psm1` | 507 | guidance tier; not edited by the recommendation |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | 500 | guidance tier; recommendation adds about 4 lines (dot-source + call) |
| `.claude/hooks/hook-epic-fan-in.ps1` | 488 | near guidance tier; do not extend; new sibling file instead |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 473 | not edited |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 462 | adds about 4 lines |
| `.codex/hooks/enforce-epic-merge-gate.ps1` | 436 | adds about 4 lines |
| `.claude/hooks/validate-orchestrator-output.ps1` | 430 | not edited by the recommendation |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 402 | adds about 4 lines |
| `.claude/skills/orchestrate/SKILL.md` | 538 | Markdown, exempt |
| `.claude/skills/parallel-orchestrate/SKILL.md` | 1392 | Markdown, exempt |
| `.claude/rules/orchestrator-state.md` | 412 | Markdown, exempt |

None of these files is listed in `config/file-size-baseline.json` (searched for each name; no match).

## 9. Sibling-item contention (parallel run)

The sibling feature folders are not present in this worktree; their file sets are inferred from their titles and are to be confirmed by the orchestrator against their plans.

| Sibling | Likely shared surfaces | Mitigation |
|---|---|---|
| #1159 single hook dispatcher | `.claude/settings.json` registrations, hook entry files such as `enforce-epic-merge-gate.ps1` and the preimplementation gate entry | Register no new hook (new code is dot-sourced helpers only); keep entry-file edits to one guarded dot-source line plus one call line each, so a dispatcher refactor rebases mechanically. |
| #1160 preimplementation gate false positives | `enforce-orchestration-preimplementation-gate-epic-scope.ps1` (both surfaces), `hook-epic-fan-in.ps1`, `EpicScopeReadiness.psm1` | Put the new allowance in a new file `hook-epic-regeneration.ps1`; touch the epic-scope decision with one added `if` block beside the two existing allowance checks; do not edit `hook-epic-fan-in.ps1`. |
| #1162 cross-epic dependencies | `.claude/skills/epic-orchestrate/SKILL.md`, `.claude/agents/epic-orchestrator.md`, `PINNED_FROZEN_SURFACE_HASHES`, epic checkpoint validators | Guaranteed textual conflict on the two digests. Whichever item merges second recomputes both digests after its merge of `origin/main` and records a combined re-baseline comment (precedent: "merged result of ..." comments in that file). Add text in new paragraphs/sections, not inside sections #1162 is likely to rewrite (`## Wave Assignment`, `## Context Handoff to Dependent Features`, `## Wave Barrier`). |
| #1157 owner directives reach agents | agent files including `orchestrator.md` and `epic-orchestrator.md` | Same digest re-baseline rule for `epic-orchestrator.md`; edit only `tools:` (one grant) and one paragraph in `## Skill` or a new section. |
| #1158 test-execution policy | execution-environment brief (six copies), unit-gate wording | Cite the brief's `## Test Isolation Checks` by heading for the "local unit gate" instead of restating commands; brief edits limited to the bullets named in section 7. |
| #1163 isolated worktrees / session-root resolution in hooks | `HookTargetWorktree.psm1`, hook resolution helpers used by the epic-scope gate | Consume existing functions (`Get-HookTargetWorktreeRelativePath`) only; add no resolver logic. |
| #1161 planner worktree removal | worktree-removal gates | No expected overlap. |

## Design Decisions

### D1 — Config location, schema, default-off

Options:
- (a) `regeneration` top-level key in `config/orchestration-routing.json`. Rejected: byte-mirrored into the bundle and appended into destinations by `merge_routing_documents` (section 2), publishing this repository's command to other repositories.
- (b) **Recommended:** a repository-local file `config/orchestration-regeneration.json` that is never placed in `extensions/drm-copilot/resources/config/`, so push-down never publishes it (bundle-only config reads) and a destination authors its own. It is "orchestration config" in the same `config/` tree, and it carries no routing-merge interaction and no parity mirror.

Schema (version 1), validated by a pure PowerShell function, errors returned as a list:

```json
{
  "version": 1,
  "regeneration": {
    "command": ["<exe>", "<arg>", "..."],
    "paths": ["<glob>", "..."],
    "idempotency_check": ["<exe>", "<arg>", "..."],
    "unit_gate": [["<exe>", "<arg>"], ["..."]]
  }
}
```

- `command` (required): non-empty array of non-empty strings, executed as argv with no shell, from the worktree root. An argv array avoids shell parsing differences between Windows and Linux.
- `paths` (required): non-empty array of globs; each is non-empty, forward-slash, relative, with no leading `/`, no `..` or `.` segment, no backslash, no drive letter, no `[`/`]` (unsupported by the engine).
- `idempotency_check` (optional): argv that must exit 0 after the second run; see D9.
- `unit_gate` (optional): list of argv arrays; absent means the repository's standard parallel test gates per `## Test Isolation Checks` of the execution-environment brief.
- Default-off: file absent, `regeneration` key absent, or `regeneration: null` means today's behavior; the classifier returns `remediation_loop` with reason `no_config`. A present but invalid block also returns `remediation_loop` (reason `config_invalid`) and the orchestrator records the validator errors under `artifact_errors`; it never partially applies an invalid block.
- Documentation: the keys are documented in the new orchestrate section (D2) and in the new rules section (D3). Validation is exercised by Pester tests and, when the file exists in a repository, by the entry point before any use.
- Self-hosted declaration: recommended **not** to add `config/orchestration-regeneration.json` to this repository in this item, so the item's own runs and the sibling runs keep today's behavior. A later declaration (candidate: the Codex variant generator `scripts/dev_tools/generate_codex_agent_variants.py`, whose `--check` mode fits `idempotency_check`) is an owner decision; its exact output paths are to be confirmed before any declaration.

### D2 — Classifier input/output contract and glob semantics

Function `Get-RegenerationPathDecision` (pure, `.claude/lib/regeneration/RegenerationClassifier.psm1`):

- Input: `-ChangedPath [string[]]` (ours ∩ theirs, repository-relative, forward slash, as produced in section 6), `-MergeBaseCount [int]`, `-Config [object]` (the parsed `regeneration` object or `$null`), `-ConfigError [string[]]`.
- Output: `[pscustomobject]@{ Decision = 'regenerate' | 'remediation_loop'; Reason = <code>; UnmatchedPath = [string[]] (ordinal-sorted) }`.
- Rule order (first match wins): config absent -> `no_config`; config errors -> `config_invalid`; `MergeBaseCount -ne 1` -> `multiple_merge_bases`; empty `ChangedPath` -> `empty_set` (fail closed: the classifier is only consulted for a conflicted merge, so an empty set means inconsistent input); any path matching no glob -> `unmatched_path` with the unmatched list; otherwise `regenerate` / `all_match`.
- Glob semantics: `Test-GlobMatch` from `BlastRadiusGlob.psm1` (ordinal, case-sensitive, whole-string, `*` and `?` stop at `/`, `**` crosses `/`), plus the `**/`-prefix rule of the mergeable matcher so `**/foo.json` also matches root-level `foo.json`. A candidate containing a backslash never matches. Case sensitivity is deliberate: git reports paths with exact case, and the Linux hook-suite job runs on a case-sensitive file system.
- Unit tests (AC2): all-match, partial-match (reports the unmatched path), no config, empty set, plus config-invalid, multiple merge bases, root-level `**/` rule, case variant does not match, backslash candidate does not match.
- The orchestrate skill's missing `Merge-Conflict Remediation` section is created as `## Merge-Conflict Remediation`, holding: capture (section 6), classification, the regenerate path, and the unchanged fallback (synthetic Blocking finding and R1-R5). This also repairs the dangling reference in S9 step 6.

### D3 — Checkpoint recording and exclusion from `completed_attempts`

Options:
- (a) `remediation_path: "regenerate"` cycles in `cycles[]`. Rejected: invariant 8 rule 1 contract change in three runtimes plus corpus; a cycle needs `plan_path`; R7 counts any `candidate_applied: true`, so exclusion would need a new R7 rule in three runtimes; and a `candidate_applied: false` cycle collides with the skill rule "Two consecutive no-candidate cycles halt".
- (b) **Recommended:** a tolerated, unvalidated top-level list `regeneration_events[]` in the per-feature checkpoint. No `cycles[]` entry is written, so R7 is satisfied by construction and the three-attempt guard is unchanged (AC4). Entry shape: `{ at, trigger ("integration_sync" | "main_sync"), feature_head_sha, merge_head_sha, merge_base_sha, classifier: { decision, reason, unmatched_paths[] }, command_exit_code, confined (bool), idempotent (bool), unit_gate ("pass" | "fail" | "not_run"), delta_check ("pass" | "fail" | "not_run"), head_sha (resulting commit or null), evidence_path, outcome ("regenerated" | "fell_back") }`. A fallback is recorded too, so the audit trail shows why the loop ran.
- Tolerance proof: two new corpus fixtures with `expected_errors: []` in `tests/fixtures/orchestrator_state_remediation_loop/` (one with `regeneration_events` and a delta `PASS` outcome and no cycles, `completed_attempts: 0`; one with a prior completed cycle, `completed_attempts: 1`, plus a regeneration event and delta outcome) run automatically in the Python, TypeScript, and PowerShell parity suites.
- Documentation: a new section `## Regeneration-Path Scope and Backward Compatibility` in `.claude/rules/orchestrator-state.md` (not inside the review-outcome section, which must stay equal to the `.agents` copy), with an honest disclosure that the key is tolerated and unvalidated and that the regenerate path is Claude-only.

### D4 — Delta-review recording shape

- The delta review is a deterministic merge-delta verification, recorded as one `remediation_loop.review_outcomes[]` entry: `{ verdict: "PASS", findings: [], head_sha: <pushed head>, review_kind: "regeneration_delta", evidence_path: "<FEATURE>/evidence/qa-gates/regeneration-delta.<timestamp>.md" }`. `review_kind` and `evidence_path` are tolerated extra keys (R9 reads only `verdict` and `findings`).
- The verification (pure, `RegenerationDelta.psm1`) generalizes `Get-ReviewVerdictMainSyncDecision` with an exemption set: for every path in `diff(P1, H)` that matches no regeneration glob, the path is in `diff(B, P2)`; for every path in `diff(P2, H)` that matches no glob, the path is in `diff(B, P1)`. Together with the classifier precondition (no non-generated path changed on both sides), this proves that every non-generated path in the merge result equals the content of exactly one already-reviewed parent: the feature head (reviewed by the last feature-review) or the incoming tip (each change reviewed and merged in its own pull request). The only new content is the output of the declared, idempotent command, confined to the declared globs.
- Rejected: a `feature-review` delegation with a narrowed scope. `.claude/agents/feature-review.md` `## Scope Invariant (non-negotiable)` ignores any narrowing and runs the full audit, and `## Step 6 Delegation — Prohibited Prompt Language` forbids the orchestrator from narrowing; a delta mode would need a change to a non-negotiable agent invariant and its coverage hook (`validate-feature-review-coverage-rules.ps1`).
- Rejected: `staged-review` over the staged merge. It writes only `artifacts/reviews/staged-review.<timestamp>.md` (gitignored, outside canonical evidence), and it would re-judge changes already reviewed in their own pull requests.
- Evidence artifact: `<FEATURE>/evidence/qa-gates/regeneration-delta.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (classifier reason, confined, idempotent, unit-gate result, delta result), the UTC write time from the clock, no absolute path; append-only (a later pass writes a new file).

### D5 — Concurrent review, CI join, CI cross-check, and review/verdict status

- Rule 7 "Re-entry": keep the pinned sentence and append: a merge that completes the regenerate path records its delta outcome at the new head, which is the new review for that head; S9 still re-runs.
- Rule 5 "Join": unchanged. The join's `CI full run` requirement at the reviewed head is met because the regenerate commit changes non-allowlisted paths, so its CI run is a full run.
- Rule 11 "CI cross-check": applies to outcomes produced by `feature-review` only. A `regeneration_delta` outcome relies on no policy-audit CI row; its CI requirement is the join's own `ci_gate` at the live head. Without this sentence, the cross-check would compare the older policy audit's rows against the delta outcome's `head_sha` and raise synthetic Blocking findings for every regenerate path.
- `## Review Verdict Status (review/verdict)`: no code change. `-Mode Review` with the latest committed policy audit is eligible because the delta outcome's `head_sha` equals the live head. Disclose that the posted description names the last full review's audit file.
- Sequential mode (epic S9 step 6 conflict): PR Creation Gate condition 1 stays satisfied by the last feature-review; the delta outcome is appended for the record and S9 re-runs on the new head before step 6 retries.

### D6 — Merge-gate acceptance of regenerate evidence

- Required behavior needs no gate relaxation: the review guard already accepts a last `PASS` at the live head.
- **Recommended addition (satisfies AC6 explicitly, inert for every existing checkpoint):** a key-gated consistency check in a new byte-identical helper `enforce-epic-merge-gate-regeneration.ps1` (`.claude/hooks/` and `.codex/hooks/`), dot-sourced by both gates and evaluated immediately after the review guard returns no denial. It applies only when the last `review_outcomes[]` entry carries `review_kind` exactly `regeneration_delta` (ordinal): it then requires a `regeneration_events[]` entry whose `head_sha` equals that outcome's `head_sha` with `outcome: "regenerated"`, `idempotent: true`, `confined: true`, `unit_gate: "pass"`, and `delta_check: "pass"`; otherwise it denies with `EPIC_MERGE_GATE_BLOCKED: REVIEW_GATE_REGENERATION_UNVERIFIED: <detail>`. It runs no process, so it adds no `gh`/`git` call. It is a policy-level control, not a security control.
- The check is placed in the gate entry files (500 and 436 lines), not in `enforce-epic-merge-gate-review.ps1` (699 lines).
- AC7 regression: the full existing suite set in section 4 runs unchanged in the Pester gate; new cases add (1) delta outcome at the live head with a matching event allowed, (2) delta outcome without a matching event denied with the new code, (3) delta outcome at a stale ancestor with a code change still `REVIEW_GATE_HEAD_STALE`, (4) a checkpoint without `review_kind` and with `regeneration_events` present produces the same decision as before, (5) sequential (no `review_mode`) child-CI and green-CI decisions unchanged.

### D7 — Epic post-merge regeneration and CI verification before the next sync

- Who: `epic-orchestrator`, after it records a child's `merge_status: "merged"` (`## Worktree Cleanup` mirror step), when the integration worktree holds a valid regeneration config.
- Procedure: `git fetch origin <integration_branch>`, fast-forward the integration worktree, run the entry point in a mode that executes the command twice (D9) and the confinement check, then `git add -- <changed paths>` and `git commit -F <file>` when the diff is non-empty, push, dispatch CI with `gh workflow run CI --ref <integration_branch>` (a push to `epic/**` triggers no `ci.yml` run; `ci.yml` pushes trigger only on `main` and `development`), locate the run with `gh run list --commit <tip> --workflow CI`, poll every 30 seconds for at most 90 minutes, and record the result. The dispatch runs even when regeneration produced no diff, because the feature merge commit itself has no CI run on the integration branch.
- Recording: tolerated top-level `integration_regenerations[]` in the epic checkpoint: `{ after_feature_issue_num, merge_commit_sha, regeneration_commit_sha (or null), command_exit_code, idempotent, ci_run_id, ci_conclusion, verified_at }`.
- Gate: a new allowance `Get-EpicRegenerationAllowance` in a new byte-identical file `hook-epic-regeneration.ps1` (`.claude/hooks/`, `.codex/hooks/`), called from `Get-OrchestrationEpicScopeDecision` for the exact `'merge-in-progress'` failure, beside the two existing allowances. It admits only `git add [--] <paths>` and `git commit` (options `-m`, `--message`, `-F`, `--file`, `--trailer`, with `-- <paths>` or a staged index), on the integration branch HEAD, when every path matches a glob of the regeneration config read from the integration worktree through an injected reader; no Write/Edit is admitted. Every other deny is unchanged. Same reject rules as #1141 (no backslash, glob character, `.`/`..` segment, leading `/`).
- Agent grant: `epic-orchestrator` gains `Bash(pwsh -NoProfile -File .claude/lib/regeneration/Invoke-RegenerationPath.ps1*)`; it gets no generic command route, because the entry point runs the declared argv itself.
- "Before the next feature syncs": the parent cannot pause a child that is already running, so the guarantee is enforced on the child side by durable GitHub state. In epic mode, when the integration worktree declares regeneration, a child about to merge `origin/<integration_branch>` (fan-in conflict handling or early-start step 7) first confirms that the integration tip has a completed, successful `CI` run (`gh run list --commit <tip> --workflow CI`), polling 30 seconds for at most 90 minutes; on timeout it follows the wait branch (`blocked_reason: "awaiting_ci"`). Without a declaration the child does not wait (today's behavior).
- Epic main sync (lifecycle step 3): when conflicts occur, the same classifier and regenerate path run inside the in-progress merge (the gate already admits commits while `MERGE_HEAD` exists), followed by the same CI dispatch and verification before the wave launches.

### D8 — Parallel-orchestrator main sync

- **Recommended: adopt by reference.** The per-item conflict is resolved by the child `orchestrator`, which applies `## Merge-Conflict Remediation` of the orchestrate skill; the classifier runs before the synthetic finding is written. `## Per-Item Merge-Conflict Handling` steps 1-3 gain one sentence: the child applies the regenerate path first, and only a fallback writes the synthetic Blocking finding and consumes an attempt. The parent order is unchanged: the issue #643 project-file resolver still runs first.
- The parent records nothing new; the parallel `merge_status` enum is unchanged (F3-owned, `## Enum Ownership` in `.claude/rules/parallel-orchestration.md`).
- The `not_queued` non-conflict merge-group failure stays a CI-failure cycle (unchanged).
- Rejected: parent-level regeneration (the #643 pattern). The delta outcome must live in the child checkpoint that the merge guard and the parent's join read.

### D9 — Idempotency check definition

1. Before the command: resolve conflicted generated paths with `git checkout --ours -- <paths>` then `git add -- <paths>`; require `git diff --name-only -z` and `git ls-files --others --exclude-standard -z` to be empty.
2. Run 1: `command`. C1 = unstaged changes ∪ untracked files. Confinement: every path in C1 matches a glob; otherwise fall back. Stage C1 (`git add -A -- <C1 paths>`).
3. Run 2: `command` again, then `idempotency_check` when declared (exit 0 required). C2 = unstaged ∪ untracked. Idempotent iff C2 is empty.
4. Delta verification (D4) on the index against `HEAD` and `MERGE_HEAD`; then the unit gate; then `git commit -F <file>` (one merge commit containing the regenerated outputs); push; S9.
5. Any failure before the commit runs `git merge --abort` and falls back to today's path (fresh `git merge --no-commit`, synthetic Blocking finding, R1-R5). No `git reset --hard` is needed (it is denied by `validate-bash.ps1`). The regenerate attempt consumes no attempt whether it succeeds or falls back.

### D10 — Language, module placement, seams, and runtime scope

- PowerShell 7, all files under 500 lines:
  - `.claude/lib/regeneration/RegenerationConfig.psm1` — pure parse and validation (`ConvertFrom-RegenerationConfigText`, `Get-RegenerationConfigError`).
  - `.claude/lib/regeneration/RegenerationClassifier.psm1` — pure set derivation from listings and `Get-RegenerationPathDecision`; imports `BlastRadiusGlob.psm1`.
  - `.claude/lib/regeneration/RegenerationDelta.psm1` — pure confinement, idempotency, and delta decisions, and builders for the `regeneration_events[]` entry, the review outcome, and the evidence text.
  - `.claude/lib/regeneration/Invoke-RegenerationPath.ps1` — thin adapter. Seams: `Invoke-RegenerationGitExe -GitArgs`, `Invoke-RegenerationProcess -Argv` (declared command), a config-text reader, and a clock (`-UtcNow` scriptblock). Emits one JSON object; exit 0 regenerated, 3 fall back, 1 git/process failure, 2 usage. It follows the fact-request pattern of `ReviewVerdictEligibility.psm1`.
- Tests: `tests/scripts/claude-lib/regeneration/*.Tests.ps1`, mocks on wrapper functions only, in-memory listings, no temporary files, no waits.
- Runtime scope: Claude only in this item. Codex orchestrators do not run the path, so Codex behavior equals today's behavior; disclosed in the rules section. The hook helpers are still byte-identical twins on `.codex/hooks/` (inert without the evidence keys), following the #1136/#1141 precedent.
- Invocation route from an isolated child worktree: `pwsh -NoProfile -File <script>` is the documented route for `Invoke-CiGateParser.ps1` and `Invoke-ReviewVerdictStatus.ps1` in the same skill; whether the worktree isolation guard admits it from an isolated child is to be confirmed by the orchestrator (fallback: an `sh` launcher under `SCRATCH`).

## Automation Feasibility

No step requires human interaction. Every decision is mechanical: the classifier is a pure function of git listings and declared globs; regeneration, idempotency, and confinement are process exit codes and git listings; the delta verification is a set relation over git listings; CI is observed through `gh`; fallbacks re-enter the existing autonomous loop. The only owner-level choice is whether this repository declares its own `config/orchestration-regeneration.json` (D1), and the recommendation is no declaration in this item, so the item ships default-off.

## Numeric Derivation Evidence

No numeric count, enumeration, or population is proposed for an approved `spec.md` acceptance criterion (the spec is an unfilled template, and AC1-AC7 contain no numeric assertion). Line counts in section 8 are risk context, not acceptance assertions.

## Testing Implications

- Pure modules: Pester unit tests per function in AAA form, covering AC2's four named cases plus the fail-closed cases of D2, config validation rules (D1), the delta subset relations (positive, one-sided violation each way, generated path exemption), confinement and idempotency (empty C2, non-empty C2, out-of-glob C1), and event/outcome/evidence builders with an injected clock.
- Adapter: tests mock `Invoke-RegenerationGitExe` and `Invoke-RegenerationProcess` (signature parity), assert argv sequences, `git merge --abort` on every failure branch, and exit codes.
- Validator tolerance: two corpus fixtures (D3) run in all three parity suites; one epic checkpoint fixture or test proving `integration_regenerations[]` tolerance.
- Gates: new Pester files for `enforce-epic-merge-gate-regeneration.ps1` (Claude and Codex) and `hook-epic-regeneration.ps1`, plus regression cases appended to `enforce-epic-merge-gate.ReviewGuard.Tests.ps1` and `enforce-orchestration-preimplementation-gate.EpicFanIn.Tests.ps1` showing unchanged decisions without the new keys.
- Skill contract: a new `tests/scripts/claude-runtime/regeneration-path-skill-contract.Tests.ps1` pinning the new section headings and key sentences in the orchestrate, epic-orchestrate, and parallel-orchestrate skills, the rules file, and their bundle mirrors.
- Gates are parallel-only: one `Invoke-PoshQCParallelTest`, one `pytest -n auto`, one Jest run; a focused run is debugging only.

## Risks

1. Frozen epic surfaces: both pinned digests move; a concurrent #1162 or #1157 merge forces a second re-baseline. Mitigation in section 9.
2. CI cross-check (rule 11) false Blocking findings if the D5 sentence is omitted.
3. Child wait on integration CI (D7) adds up to 90 minutes per sync when the parent is slow to dispatch; bounded and only when a declaration exists.
4. `review/verdict` status description names the last full audit, not the delta artifact (disclosure).
5. Same-session forgery of `regeneration_events[]` and the delta outcome is possible, as for every checkpoint-backed gate; policy-level control.
6. A regeneration command that writes outside its declared globs, or that is not deterministic, always falls back; repositories with nondeterministic generators get no benefit, but no new risk.
7. Parallel drift detection: a regenerated generated path outside an item's declared radius could appear as an escaped path. Likely rare, because a generated file changed on both sides was already in the item's diff; to be confirmed against `detect_escaped_paths` inputs during planning.
8. Installed-extension lag: none of the new logic is in the MCP validators, so no D9-style lag applies; the hooks run from `main` copies for isolated subagents until merge, so branch hook behavior is proven by Pester only.
9. Push-down of a destination-only `config/orchestration-regeneration.json`: preservation is inferred from bundle-only reads and the absence of a delete path; a push-down test should pin it.

## Likely Write Paths

New:
- `.claude/lib/regeneration/RegenerationConfig.psm1`
- `.claude/lib/regeneration/RegenerationClassifier.psm1`
- `.claude/lib/regeneration/RegenerationDelta.psm1`
- `.claude/lib/regeneration/Invoke-RegenerationPath.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/regeneration/RegenerationConfig.psm1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/regeneration/RegenerationClassifier.psm1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/regeneration/RegenerationDelta.psm1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/regeneration/Invoke-RegenerationPath.ps1`
- `.claude/hooks/enforce-epic-merge-gate-regeneration.ps1`
- `.codex/hooks/enforce-epic-merge-gate-regeneration.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-regeneration.ps1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate-regeneration.ps1`
- `.claude/hooks/hook-epic-regeneration.ps1`
- `.codex/hooks/hook-epic-regeneration.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-epic-regeneration.ps1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-epic-regeneration.ps1`
- `tests/scripts/claude-lib/regeneration/RegenerationConfig.Tests.ps1`
- `tests/scripts/claude-lib/regeneration/RegenerationClassifier.Tests.ps1`
- `tests/scripts/claude-lib/regeneration/RegenerationDelta.Tests.ps1`
- `tests/scripts/claude-lib/regeneration/Invoke-RegenerationPath.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-epic-merge-gate.Regeneration.Tests.ps1`
- `tests/scripts/claude-hooks/hook-epic-regeneration.Tests.ps1`
- `tests/scripts/codex-hooks/enforce-epic-merge-gate-regeneration.Tests.ps1`
- `tests/scripts/claude-runtime/regeneration-path-skill-contract.Tests.ps1`
- `tests/fixtures/orchestrator_state_remediation_loop/regeneration_event_tolerated_accepted.json`
- `tests/fixtures/orchestrator_state_remediation_loop/regeneration_after_completed_cycle_accepted.json`

Edited:
- `.claude/skills/orchestrate/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md`
- `.claude/skills/epic-orchestrate/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md`
- `.claude/skills/parallel-orchestrate/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md`
- `.claude/agents/orchestrator.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/orchestrator.md`
- `.claude/agents/epic-orchestrator.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/epic-orchestrator.md`
- `.claude/rules/orchestrator-state.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`
- `.claude/hooks/enforce-epic-merge-gate.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1`
- `.codex/hooks/enforce-epic-merge-gate.ps1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1`
- `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`
- `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`
- `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`
- `tests/scripts/claude-hooks/enforce-epic-merge-gate.ReviewGuard.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicFanIn.Tests.ps1`
- `.claude/skills/execution-environment/SKILL.md`
- `.agents/skills/execution-environment/SKILL.md`
- `.github/skills/execution-environment/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`
- `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md`

The production PowerShell count exceeds three, so the item runs on the orchestrated large path (batch-budget exemption through the `large` route).

## Pre-Mortem

- Review checklists: a reviewer may flag the regenerate path as a gate bypass (writing `PASS` without `feature-review`) or flag the dangling `Merge-Conflict Remediation` reference left unrepaired. Mitigation: the plan states D4's soundness argument in the skill and rules text, adds the D6 consistency check, creates the `## Merge-Conflict Remediation` section, and keeps the honest-disclosure paragraph (policy-level control, same-session forgery).
- Coverage: the four new PowerShell lib files and two new hook helpers are in the coverage denominator (`config/poshqc-coverage.json` roots); the adapter's process branches can fall below 85% line coverage if only happy paths are tested. Mitigation: the plan carries one test per failure branch (command non-zero, out-of-glob write, non-idempotent second run, delta failure, unit-gate failure, git failure) and reads per-file figures from `artifacts/pester/powershell-coverage.xml` of the single parallel gate run.
- Mirror parity: missing bundle copies, pack-manifest entries, the Codex `core.json` regeneration, the `PINNED_FROZEN_SURFACE_HASHES` re-baseline, or the six-copy execution-environment brief update would fail the contract tests listed in section 7. Mitigation: one task per mirror family, the generator run with `--check`, and a brief-update task named in the plan's Mirror parity bullet.
- File size: editing `enforce-epic-merge-gate-review.ps1` (699) would cross the 700 advisory tier, and extending `hook-epic-fan-in.ps1` (488) would cross 500. Mitigation: new logic only in new files; entry-file edits limited to a guarded dot-source and one call each.
- Test isolation: adapter tests could create real git repositories or temp files, or leak mocked functions and imported modules across a shard. Mitigation: wrapper-function mocks with in-memory listings only, module import and removal paired in `BeforeAll`/`AfterAll`, and `Invoke-PoshQCLeakScan` in the static job as the check.
- CI-only behavior: Linux hook-suite job (case-sensitive, forward slash) can fail on path joins or case in the new hook tests; the docs-only change-scope rule does not apply because code paths change. Mitigation: `Join-Path`, forward-slash relative fixtures, no drive letters, exact file-name case, and no reads of gitignored `artifacts/` state in tests.
- Evidence: the delta artifact and baselines must carry write-time UTC stamps, `Timestamp:`/`Command:`/`EXIT_CODE:`/`Output Summary:`, no absolute paths, and must be append-only. Mitigation: the evidence builder takes an injected clock and the skill text states "a later pass writes a new file"; the plan's Phase 0 baseline records one parallel run per gate.
