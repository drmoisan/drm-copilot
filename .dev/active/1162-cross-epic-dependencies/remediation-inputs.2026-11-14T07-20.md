# Remediation Inputs — Issue 1162

Timestamp: 2026-11-14T07-20
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Path: full
Remediation-Mode: proportionate
Source review artifacts:
- `docs/features/active/2026-11-09-cross-epic-dependencies-1162/policy-audit.2026-11-14T07-20.md`
- `docs/features/active/2026-11-09-cross-epic-dependencies-1162/code-review.2026-11-14T07-20.md`
- `docs/features/active/2026-11-09-cross-epic-dependencies-1162/feature-audit.2026-11-14T07-20.md`
Head reviewed: `73ecccd13b3f8f7601de848136eca93fdafaa328` (merge base `2c8dee6dd3a82f210561d9efe623767ae902de51`)
Prior cycle: none (first review).

Path rationale: both findings are autonomous and contained, but the F2 fix edits `.claude/skills/epic-orchestrate/SKILL.md`. That requires a fresh frozen-surface digest in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` and, where the digest line or the edited text falls inside a recorded region, regenerated hunks in `docs/engineering/process-reductions/patches/0010-early-dependent-starts.patch`. That chain failed once in this item's first Pester gate, so a planned and preflighted cycle is preferred over the light path.

## Findings requiring remediation

### F1 — The readiness CLI reads a deleted prerequisite integration branch through a stale remote-tracking ref

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The fix is a change to one fetch argument array (or a presence probe through the existing git wrapper) in a module this branch adds, with its two byte-identical copies and one adapter test; it needs no external party, owner decision, or pending CI result.
Finding-Scope: contained

- Files: `.claude/lib/epic-wave/EpicCrossDependency.psm1`, `extensions/drm-copilot/resources/claude-customizations/.claude/lib/epic-wave/EpicCrossDependency.psm1`, `extensions/drm-copilot/resources/lib/epic-wave/EpicCrossDependency.psm1`, `tests/scripts/claude-lib/epic-wave/EpicCrossDependency.Adapters.Tests.ps1` (and `Invoke-EpicCrossReadiness.Tests.ps1` if it asserts the fetch arguments).
- Location: `Get-EpicCrossReadinessResult` (the `Invoke-EpicCrossGitExe -GitArgs @('fetch', '-q', 'origin')` call) and the branch-presence inference in `Read-EpicCrossManifestText` / `Get-EpicCrossFeatureEvidence`.
- Problem: `git fetch -q origin` does not prune, and `fetch.prune` is unset in the repository. Once another clone deletes `epic/<other>-integration`, as the end of an epic does, the local `origin/epic/<other>-integration` ref survives. `git show origin/<branch>:<manifest>` succeeds, so `OtherBranchPresent` is true. Row 2 (`PREREQ_IN_MAIN`) cannot fire, the edge evaluates against the stale ref, and a `merge_required` result sends the orchestrator into a D4 fetch of a branch that no longer exists. This contradicts spec `## Alternate and edge flows` (third bullet) and D4. A reviewer real-git probe confirmed that `git show` of the stale ref exits 0 after an unpruned fetch and 128 after `git fetch --prune`.
- Required change: run the fetch as `git fetch -q --prune origin`, or decide branch presence from `git ls-remote --exit-code --heads origin <branch>` through `Invoke-EpicCrossGitExe`. A non-zero exit other than "no matching ref" must stay an adapter error, so the module still fails closed. Update the adapter tests to assert the new exact argument array. Add a case in which the remote branch is absent, the stale-ref read would have succeeded, and the decision is `release` with `PREREQ_IN_MAIN`. Copy the module byte-identically to both copies.
- Verification required: the new case fails against the current module text and passes after the fix (record both results append-only under `evidence/other/`). Then the final QA loop: PoshQC format, analyzer, and leak scan clean; one `Invoke-PoshQCParallelTest` run with 0 failures; `EpicCrossDependency.psm1` at or above 85% line coverage with no drop; blob-id parity of the three copies.

### F2 — The cross-epic hold-record statuses have no decision-to-status mapping, and `released` fails the started-while-held invariant

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The fix adds one mapping statement to skill and agent text on this branch, with its mirrors, one contract-test row, and the digest and ledger refresh the spec already prescribes; it needs no external party, owner decision, or pending CI result.
Finding-Scope: contained

- Files: `.claude/skills/epic-orchestrate/SKILL.md`, `.agents/skills/epic-orchestrate/SKILL.md`, `.claude/agents/epic-orchestrator.md` and `.codex/agents/epic-orchestrator.toml` (where they describe the records), their bundle copies under `extensions/drm-copilot/resources/`, `tests/scripts/claude-runtime/cross-epic-skill-contract.Tests.ps1`, `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`, and, as needed, `docs/engineering/process-reductions/patches/0010-early-dependent-starts.patch`.
- Location: the **Records (D7)** paragraph of `## Cross-Epic Dependencies (cross_epic_depends_on)` (SKILL.md lines 492 to 497; `.agents` line 300).
- Problem: the paragraph lists `held`, `released`, `integrated`, and `in_main` but does not say which status follows each decision. The started-while-held invariant (Python `CROSS_EPIC_INTEGRATED_STATUSES`, the TypeScript and PowerShell twins) rejects any launched feature whose entry is not `integrated` or `in_main`. The progress report counts only those two as done. An orchestrator that records `released` for a `PREREQ_ALREADY_INTEGRATED` release, which the spec expects for every feature after the first that names the same other epic, then fails the stop hook and both validators once the feature has a worktree.
- Required change: state the mapping in the records paragraph and in each Codex and agent counterpart that describes the records. Proposed mapping:
  - `hold` gives `held`.
  - `PREREQ_IN_MAIN` gives `in_main`.
  - `PREREQ_ALREADY_INTEGRATED`, or a completed D4 merge, gives `integrated`, recorded before the feature is launched.
  - `released` applies only between a `merge_required` decision and the completed D4 merge.

  Add a row to `cross-epic-skill-contract.Tests.ps1` that pins the mapping in both skill variants. Re-copy the bundle copies and regenerate the codex-and-agents variants with the generator. After the last `origin/main` merge, recompute the frozen digest of `.claude/skills/epic-orchestrate/SKILL.md` (and of `.claude/agents/epic-orchestrator.md` if edited) from the final bytes, with an updated `# RE-BASELINED by issue #1162.` paragraph. Then regenerate the affected `0010-early-dependent-starts.patch` sections per its README `## Revert Order`, as was done in commit `6c6959e96`.
- Verification required: the new contract row fails before the text change and passes after it. The final QA loop includes `test_frozen_epic_surface_matches_pinned_baseline_digest`, the `PRC-LEDGER-CHAIN-HOLDS` and `PRC-LEDGER-SUBCHAIN-HOLDS` Pester suites, the push-down resource and pack-manifest contract tests, and the Codex generator `--check`.

## Non-remediation items (record only)

- Warning: `.claude/lib/epic-wave/EpicCrossDependency.psm1` and its two copies are 769 logical lines (advisory tier). F1 must not take the file past 800 lines. If the fix grows it, move the gather functions to a sibling file in the same directory, with a pack-manifest entry and copies.
- Info: a trailing YAML comment on the `cross_epic_depends_on` line is rejected as malformed (fail-closed); no change required.
- Evidence note: the executor's Pester coverage report predated the last PowerShell-touching commit (`6c6959e96`) by 46 seconds, with identical file contents. The root TypeScript report was absent. The reviewer re-ran both gates in the item worktree (`evidence/qa-gates/pester-reviewer-gate.2026-11-14T07-32.md`, `evidence/qa-gates/jest-root-gate.2026-11-14T07-12.md`). The remediation cycle's final gates must write all three canonical reports after its last code commit: `artifacts/pester/powershell-coverage.xml`, `artifacts/python/lcov.info`, and the worktree-root `coverage/lcov.info`.
- CI on the PR head is pending-CI and owned by the orchestrator at S9; no PR exists yet. It is not a finding.

## Constraints

- Tests run in parallel only: one `Invoke-PoshQCParallelTest`, `pytest -n auto`, and Jest-worker run per gate. No serial, single-process, shuffled, or reversed runs, and one suite at a time on this machine.
- Evidence is append-only; do not edit or delete existing evidence files. No artifact records an absolute path or host name.
- No new Python file; no hook file or hook registration change.
- Merge `origin/main` into the branch if it has advanced, before the digest recomputation.
- Any commit makes this review stale, so a re-review follows.
