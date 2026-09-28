# Remediation Inputs: F7 Parallel Enforcement Hooks (Issue #440)

**Created:** 2026-08-08T23-10
**Author:** feature-review agent
**Feature folder:** `docs/features/active/2026-08-07-parallel-enforcement-hooks-440`
**Branch:** `feature/parallel-enforcement-hooks-440`
**Base branch:** `epic/parallel-orchestration-integration` (merge base `c939b5b80c8c297db49febaebdd35dda2c869a3f`)

## Why Remediation Was Triggered

Per step 8 of `feature-review-workflow`, remediation is required when the policy audit contains meaningful FAIL results or the code review contains blockers. Both conditions are met by a single finding.

Remediation is **not** triggered by any of the following, all of which passed: toolchain checks (black, ruff, pyright, PoshQC format, PoshQC analyze all clean), coverage thresholds (every language and every changed file above threshold, with no regression), acceptance criteria (16 of 16 PASS), or evidence locations (validator exit 0).

## Source Review Artifacts

| Artifact | Path |
|---|---|
| Policy audit | `docs/features/active/2026-08-07-parallel-enforcement-hooks-440/policy-audit.2026-08-08T23-10.md` |
| Code review | `docs/features/active/2026-08-07-parallel-enforcement-hooks-440/code-review.2026-08-08T23-10.md` |
| Feature audit | `docs/features/active/2026-08-07-parallel-enforcement-hooks-440/feature-audit.2026-08-08T23-10.md` |
| Approved plan (all 53 tasks complete) | `docs/features/active/2026-08-07-parallel-enforcement-hooks-440/plan.2026-08-07T11-10.md` |
| AC sources (`full-feature` mode) | `spec.md` and `user-story.md` in the same folder |
| Coverage comparison evidence | `evidence/qa-gates/coverage-comparison.2026-08-08T22-50.md` |

## Remediation-Required Findings

### B-1 (Blocking) — TypeScript F7 parity seam left empty

**Files.**
- `extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts` — lines 307-314, the unmodified `BEGIN/END F7 EXTENSION SEAM -- PARALLEL_COHORT_BARRIER_VIOLATION` block.
- `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts` — line 263, the `case "parallel-orchestrator-state":` dispatch that routes to the un-extended core.
- Reference implementation to port: `scripts/dev_tools/_parallel_orchestrator_state_cohort_barrier.py` (378 lines).

**Statement of the defect.** F7 added the Layer 2 cohort-ordering invariant to the Python validator (four lines inside the Python seam) but not to the TypeScript parity port. The invariant is now present in one of the two validation runtimes. `.claude/rules/parallel-orchestration.md` states that enforcement is "Python validator logic, **plus the TypeScript parity port**, plus this prose file," and that the port "reproduces the same invariants." F3 constructed the TypeScript seam specifically for F7 and recorded that expectation in its own accepted review artifact (`docs/features/active/2026-08-07-parallel-schema-validators-444/code-review.2026-08-07T20-36.md:137`: "Python and TypeScript entry points carry the same seam in the same position. F7's edit will be one appended...").

**Observable consequence.** A checkpoint recording a cohort-barrier violation is rejected by the `SubagentStop` path, which invokes the Python validator (`.claude/hooks/validate-orchestrator-output.ps1:196` runs `python -m scripts.dev_tools.validate_orchestration_artifacts`), but is reported clean by the MCP tool `validate_orchestration_artifacts`, which dispatches to the TypeScript core. Two enforcement surfaces disagree about the same document, and the disagreement is silent.

**Why no existing test catches it.** The three TypeScript parallel-validation suites (`extensions/drm-copilot/test/mcp-parallel-validation-definitions.test.ts`, `mcp-server-parallel-validation.test.ts`, `mcp-tool-inputs-parallel-validation.test.ts`) assert the TypeScript implementation against TypeScript-side expectations. None cross-checks against Python output, so per-side coverage is blind to the divergence. This is the same class of defect the directive's adjudication point 7 was constructed to prevent, manifesting at the Python/TypeScript parity boundary rather than at the producer/consumer boundary.

**Scope note for the planner.** This work was never scoped. Neither `spec.md` nor `plan.2026-08-07T11-10.md` contains the string "TypeScript" or "parity"; the spec's `## Non-Goals` does not exclude it either. All 16 acceptance criteria are satisfied without it. The gap is against a standing rule and against upstream's recorded expectation, not against a stated feature requirement.

**Acceptable resolutions — choose exactly one.**

*Option A — port the invariant (restores full parity).*
1. Create `extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-cohort-barrier.ts` exporting a function equivalent to `validate_cohort_barrier_ordering`, reproducing: the key gate on `conflict_edges` and `cohorts`; the union reference index over `items[]` keyed by `issue_num` with `feature_folder` hint tolerance and the four lifecycle-prefix strips; the current-generation cohort projection (`generation === recolorGeneration`); the structural reading (equal cohort index) and the temporal reading (status disjunct plus ISO-8601 string-compare of `merged_at` against `worktree_created_at`, degrading when either is absent or non-string); and the byte-exact message `PARALLEL_COHORT_BARRIER_VIOLATION: <a> ran concurrently with conflicting <b>` with no context prefix and no trailing period.
2. Add exactly one `errors.push(...)` invocation inside the existing delimited seam at `parallel-orchestrator-state-core.ts` lines 307-314, plus the helper import. Do not reflow surrounding code — the seam exists to make this a non-contending edit.
3. Add Jest tests under `extensions/drm-copilot/test/` covering the same scenario matrix as `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_cohort_barrier.py`, exercising the invariant **through the public entry point** `validateParallelOrchestratorStateText` rather than importing the helper directly, mirroring the binding discipline the Python tests already demonstrate.
4. Add at least one parity assertion pinning the TypeScript error string to the identical literal the Python side emits, so a future edit to one side fails a test.
5. Honor the three known Python/TypeScript divergence classes already documented in `.claude/rules/parallel-orchestration.md` (`pythonRepr` quote selection, integral floats, boolean/integer equality); do not attempt to close them here.
6. Run the TypeScript toolchain to completion: `npm run format`, `npm run lint`, `npm run typecheck`, `npm run test:unit`, then `npm run test:unit:coverage`. Because TypeScript files will then have changed, TypeScript coverage becomes mandatory: `coverage/lcov.info` must show line >= 85% and branch >= 75% for the new file and repo-wide.
7. Mirror any `.claude`-side change if one arises (none is expected; this option touches only `extensions/drm-copilot/src/` and `test/`).

*Option B — record an explicit authoritative deferral (no port).*
1. Amend `.claude/rules/parallel-orchestration.md` to state plainly that the TypeScript surface intentionally omits the Layer 2 cohort-barrier invariant and that the Python validator is authoritative for it. Follow the existing precedent in `.claude/rules/orchestrator-state.md`, which already records "The MCP TypeScript surface performs the existence check only ...; the Python validator remains authoritative for per-receipt correctness."
2. Remove or explicitly re-purpose the now-permanently-empty F7 seam comment in `parallel-orchestrator-state-core.ts` so a future reader is not misled into thinking work remains, or annotate it as intentionally unused with a pointer to the rule text.
3. Open a tracked GitHub issue if the port is merely deferred rather than declined, and reference it from the rule text.
4. **Constraint:** editing `.claude/rules/**` is a policy-document change. This review agent must not make it. It requires the owner's decision and must be performed by an authorized path, not silently by an executor.

**Not acceptable:** leaving the seam empty with no rule amendment and no tracked issue. That is the current state and is what makes this Blocking.

**Verification of remediation.** Option A: the new Jest suite passes, `npm run typecheck` and `npm run lint` are clean, TypeScript coverage meets both thresholds, and a parity test pins the shared literal. Option B: the rule text states the omission explicitly and the misleading seam comment is resolved.

## Merge-Mechanics Precondition (not a code defect)

### R-1 — the branch has zero commits

`HEAD` of `feature/parallel-enforcement-hooks-440` is `c939b5b8`, **identical to the merge base**. All 26 changed paths exist only as uncommitted working-tree state (17 modified tracked files, 8 added files, 50 evidence artifacts).

Consequences:
- No pull request can be opened, and no `headRefOid` exists for any gate, CI reference, or PR-context collector to resolve.
- `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` could not be meaningfully regenerated for this review, because the repository collector diffs `merge_base..head_sha` and those are the same commit. The working-tree diff was substituted as primary evidence and this deviation is recorded in all three review artifacts.

**Required action:** commit the working tree on `feature/parallel-enforcement-hooks-440`. After committing, regenerate the PR-context artifacts against `epic/parallel-orchestration-integration` so downstream PR authoring has a valid baseline. This is mechanical and requires no code change.

## Advisory Findings (not remediation-required)

Recorded so the planner can bundle them opportunistically if a remediation cycle opens anyway. None blocks merge; none needs its own cycle.

| ID | File | Summary |
|---|---|---|
| A-1 | `.claude/hooks/enforce-parallel-cohort-barrier.ps1` | 499 lines against a 500-line hard limit — one line of headroom. Consider extracting the six pure resolution helpers pre-emptively. |
| A-2 | `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` + bundled mirror | The three newly-registered hooks enter the coverage denominator only from a republished bundle. Republish as part of landing, or record the interim gap. |
| A-3 | `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` | Once F6 and F8 land, `LANDED_WAVE_FOUR_FEATURES` will contain all three and the reserved-body pin becomes a vacuously-passing dead test. Assign the last feature to land the cleanup. |
| A-4 | `.claude/skills/parallel-orchestrate/SKILL.md` + bundled mirror | F7 section uses British `neighbour`/`behaviour` while the code it documents uses American `neighbor`/`behavior`. Normalize for greppability. |
| A-5 | `.claude/hooks/enforce-parallel-cohort-barrier.ps1:453` | `if (-not $subagent -or $subagent -ne 'orchestrator')` — first clause is subsumed by the second. Simplify. |
| A-6 | `.claude/hooks/enforce-parallel-cohort-barrier.ps1:482` | Fail-closed deny reason is a single disjunctive message covering five causes, so an operator cannot tell which fired. **Matches the epic precedent** (`enforce-epic-wave-barrier.ps1:287`) that the plan mandated adapting, so changing it would break intentional symmetry. Low priority. |
| A-7 | Pester evidence artifacts | Reported "2140 passed"; the JUnit artifact records `tests="2141" failures="1" disabled="9"`, i.e. 2131 passed / 1 failed / 9 skipped. Report the three figures separately in future evidence. |

## Out of Scope — Do Not Remediate in This Feature

**Pre-existing Pester failure.** `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`, case `enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`. This test reads the live gitignored `artifacts/orchestration/orchestrator-state.json` instead of a mocked seam and fails whenever an orchestrated run is live. The file is **not in this branch's diff**, the same failure is present in the P0-T4 baseline, and the codex hook suites share the identical coupling.

It is a genuine repository defect and deserves its own issue, but it must **not** be fixed inside this feature's remediation cycle: doing so would expand scope into a file this feature does not own, during a wave in which two sibling features (F6 #442 and F8 #446) are executing concurrently against the same integration branch.

**F6 and F8 surfaces.** `## Mutation Protocol (F6)` and `## Radius Drift Detection (F8)` in `parallel-orchestrate/SKILL.md`, and any future F6/F8 additions to `validate_parallel_orchestrator_state.py`, remain owned by those features. Verified untouched by F7 and must stay that way.

**F3-owned schema.** No checkpoint schema field may be added. Layer 2 validates existing fields only. The nine parallel-surface enums are F3-owned and must be consumed, never extended.

## Handoff

Per `remediation-handoff-atomic-planner`, plan authoring is delegated, not performed by this review agent. The remediation plan file must be created from the canonical plan template by the atomic-planner, taking this document as its input.

**Recommended scope for the remediation plan:** B-1 and R-1 only, with A-1 through A-7 as optional bundled cleanups. B-1 requires an owner decision between Option A (port) and Option B (recorded deferral) before planning proceeds, because Option B involves a policy-document edit that no executor may make unilaterally.

**Binding constraints to carry into the plan:** the wave-4 contention rules remain in force — no edit to F6- or F8-owned regions, no reflow of `parallel-orchestrate/SKILL.md` outside F7's own section, no reflow of `validate_parallel_orchestrator_state.py` outside the F7 seam, no checkpoint schema fields, and any `.claude` change must be byte-mirrored into `extensions/drm-copilot/resources/claude-customizations/.claude/` per `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`.
