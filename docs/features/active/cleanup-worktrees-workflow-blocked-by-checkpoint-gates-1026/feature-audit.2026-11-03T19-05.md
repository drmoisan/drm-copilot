# Feature Audit: Cleanup-Context Legs for the Checkpoint Gates (#1026)

---

**Audit Date:** 2026-11-03
**Feature Folder:** `docs/features/active/cleanup-worktrees-workflow-blocked-by-checkpoint-gates-1026`
**Base Branch:** `main`
**Head Branch:** `bug/cleanup-worktrees-workflow-blocked-by-checkpoint-gates-1026`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (`origin/main` at `01706c697f3ad4a53b4a771d99d851afc7417ea9`)
- **Head branch/commit:** `bug/cleanup-worktrees-workflow-blocked-by-checkpoint-gates-1026` (commit `b12f4b25ac06b94c646b275e8e88e6ea967a3baa`)
- **Merge base:** `01706c697f3ad4a53b4a771d99d851afc7417ea9`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-03 19:01 UTC at the head SHA)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt` and `git diff 01706c697f3ad4a53b4a771d99d851afc7417ea9 HEAD`
  - Feature evidence: `docs/features/active/cleanup-worktrees-workflow-blocked-by-checkpoint-gates-1026/evidence/**`
  - Additional evidence: `artifacts/pester/parallel/shard-{1..8}/powershell-coverage.xml` (per-file coverage union computed in this review); test-name greps over `tests/scripts`
- **Feature folder used:** `docs/features/active/cleanup-worktrees-workflow-blocked-by-checkpoint-gates-1026`
- **Requirements source:** `spec.md`
- **Work mode resolution note:** `issue.md` carries the explicit marker `- Work Mode: full-bug`, so `spec.md` is the only AC source. The checkbox items under the `Proposed Fix / Validation Ideas` section of `issue.md` are not AC for this mode; they are consistent with the spec criteria and are already checked.
- **Scope note:** full branch diff against the merge base. Test pass/fail status is taken from the recorded evidence runs; this review did not re-run Pester. No hook or test file changed after the final Pester run (`git diff --stat a6277ccd9 HEAD` over hook and test folders is empty), and the suites affected by the later `origin/main` merge (SkillText, EndToEnd, parity, contract tests) were re-run after it (18-39 and 18-46 evidence).

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/cleanup-worktrees-workflow-blocked-by-checkpoint-gates-1026/spec.md` — only source (`## Acceptance Criteria`, 21 checkbox items)

### Acceptance criteria

1. `enforce-orchestration-preimplementation-gate.Cleanup.Tests.ps1` passes the manifest Write allow test and the four deny tests (wrong `tool`, wrong `schema_version`, non-session-root path, Edit of the manifest), each asserting the unchanged `PREIMPLEMENTATION_GATE_BLOCKED` text.
2. The same suite passes `allows git -C <consolidation root> add of docs/ and .claude/agent-memory/ operands` and `denies git add in the consolidation worktree when any operand is outside the allowlist` (scripts/ operand, root `.md`, `-A`, `-f`, missing `-C`).
3. The same suite passes the four commit tests (allowlisted staged index allow; non-allowlisted path, empty or failed seam, and `-a`/`--amend`/`--pathspec-from-file`/pathspec denies).
4. The same suite passes `identifies the consolidation worktree by porcelain branch documentationandmemories and not by path` with prunable, detached, main-stanza, and different-branch denies.
5. The same suite passes the long-name and 8.3 short-name temporary-root allows and the scratch deny cases, with the temporary root supplied through its seam.
6. The same suite passes the receipt Write allow beneath the consolidation worktree and the deny beneath a non-consolidation worktree.
7. `enforce-pr-author-skill.Cleanup.Tests.ps1` passes the `gh pr create --head documentationandmemories --base main` allow and the K1 to K6 failure tests, each returning `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` with its sub-code.
8. The same suite passes `still requires the orchestrator preflight for a non-consolidation PR with no checkpoint`, `evaluates the docs-only exemption before the cleanup exemption with unchanged results`, and `runs the receipt checks unchanged after the cleanup exemption`.
9. `enforce-model-routing-receipt.Cleanup.Tests.ps1` passes the `Agent(pr-author)` allow and the absent/invalid manifest, non-pr-author, and different-label denies, asserting the unchanged `MODEL_ROUTING_RECEIPT_BLOCKED` text.
10. `enforce-orchestration-preimplementation-gate-cleanup.Tests.ps1` (Codex) passes the Codex equivalents plus the `apply_patch` Add allow, the Update/Delete/Move deny, and the entry-tail content forwarding test.
11. `CleanupWorktreeManifestGateMatrix.Tests.ps1` and `enforce-epic-worktree-removal-gate.ManifestBranch.Tests.ps1` pass unchanged, and the end-to-end suite asserts the manifest-authorized removal is allowed by both removal gates with no checkpoint.
12. `cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1` passes with one `Context` per workflow step, each allowed by every registered hook.
13. Each new cleanup suite pairs every allow case with non-consolidation and session-root denies asserting today's deny text, and the existing preimplementation, PR-author, model-routing, manifest, removal, resolver, and docs-only suites pass without expected-string changes.
14. `hook-cleanup-context.Tests.ps1` passes, covering every fail-closed branch of the four predicates, including prefix case sensitivity and `**/*.md` rejection.
15. `hook-cleanup-context.Parity.Tests.ps1` passes, asserting byte identity of every copy and literal equality with `CleanupWorktreeManifest.psm1` and `CLEANUP_WT_CONSOLIDATION_BRANCH`.
16. `cleanup-merged-worktrees.SkillText.Tests.ps1` passes, asserting the skill and brief text requirements and the removal of `--require-pr-creation-ready` for consolidation PRs.
17. `test_execution_environment_brief_contracts.py` passes, confirming every brief copy is byte-identical.
18. The push-down contract tests, `generate_codex_agent_variants.py --check`, the helpers and targets Parity suites, `legacy-codex-hook-contracts.Tests.ps1`, `hook-dependency-guard-completeness.Tests.ps1`, and `enforcement-hooks-no-python-invocation.Tests.ps1` pass.
19. Each new PowerShell production file reports line coverage at or above 85% in `artifacts/pester/powershell-coverage.xml`, and no changed line in an existing production file reduces coverage.
20. `session-root-reads-850.Constraints.Tests.ps1` and `legacy-codex-hook-contracts.Tests.ps1` pass with line caps unchanged, and no changed or new file exceeds the hard block.
21. No new Python file is added and no hook invokes Python; all new hook and library logic is PowerShell.

(Items are abbreviated faithfully from `spec.md`; the source text is unchanged.)

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Manifest Write allow and four denies | PASS | `evidence/other/claude-gate-tests.2026-11-03T13-22.md` (EXIT_CODE 0); test name present in the Claude suite; shuffled runs 3347/3347 | `grep -rlF "allows a Write of the session-root cleanup manifest..." tests/scripts` | Also re-run in `isolation-shuffle.2026-11-03T18-46.md`. |
| 2 | Consolidation `git add` allow and denies | PASS | `other/claude-gate-tests.2026-11-03T13-22.md`; `Test-OrchestrationCleanupSegmentShape` rejects options other than `--` and non-allowlisted operands | Code reading of gate-cleanup lines 266-282 | |
| 3 | Consolidation `git commit` allow and denies | PASS | `other/claude-gate-tests.2026-11-03T13-22.md`; test `denies the commit with -a, --amend, --pathspec-from-file, or a pathspec operand` present in both runtimes' suites | `grep -rlF` over `tests/scripts` (2 files) | |
| 4 | Consolidation identity by porcelain branch | PASS | `other/claude-gate-tests.2026-11-03T13-22.md`; `Find-CleanupConsolidationRecord` skips index 0, prunable, detached, and requires exactly one match | Code reading of `hook-cleanup-context.ps1` lines 158-194 | |
| 5 | Scratch allows in both spellings and denies | PASS | `baseline/temp-root-spelling.2026-11-03T12-55.md`; `other/claude-gate-tests.2026-11-03T13-22.md`; 8.3 test present in both suites | `grep -rlF "allows a Write under the temporary root in its 8.3 short-name spelling"` | Temporary root supplied through `Get-OrchestrationGateTemporaryRoot` mock. |
| 6 | Receipt Write allow and non-consolidation deny | PASS | `other/claude-gate-tests.2026-11-03T13-22.md`; deny test present in both suites | `grep -rlF "denies the same receipt path beneath a non-consolidation worktree"` | |
| 7 | PR-author allow and K1 to K6 sub-codes | PASS | `other/pr-author-tests.2026-11-03T13-31.md` (EXIT_CODE 0, 19 suites); sub-codes defined in `enforce-pr-author-skill.cleanup.ps1` lines 107-160 | Code reading; test-name grep | |
| 8 | Non-consolidation preflight, docs-only ordering, receipt checks after | PASS | `other/pr-author-tests.2026-11-03T13-31.md`; all three test names present | `grep -rlF` for each name | `Get-PrAuthorPreflightExemption` returns the docs-only result unchanged when no consolidation branch is named. |
| 9 | Model-routing pr-author allow and denies | PASS | `other/model-routing-tests.2026-11-03T13-34.md` (EXIT_CODE 0, 6 suites) | Test-name grep (`denies a different branch label` present) | |
| 10 | Codex equivalents, `apply_patch`, content forwarding | PASS | `other/codex-gate-tests.2026-11-03T13-27.md` (EXIT_CODE 0, 14 suites); `apply_patch` and forwarding test names present | `grep -rlF` for the three named tests | Codex entry-tail change at `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` line 482. |
| 11 | Removal suites unchanged; end-to-end removal allowed | PASS | `other/end-to-end-tests.2026-11-03T13-39.md`; `git diff --name-only` over the two removal suites lists 0 files; the end-to-end suite dot-sources both removal gates | `git diff --name-only <merge base> HEAD -- <two suites>` | |
| 12 | End-to-end composition with one Context per step | PASS | `other/end-to-end-tests.2026-11-03T13-39.md`; 10 `Context` blocks (report, manifest Write, --preserve, git commit, git push, Agent(pr-author) delegation, receipt Write, gh pr create, --apply, manifest-authorized removal) | `grep -n "Context '"` over the suite | |
| 13 | Paired denies; existing suites unchanged in expected strings | PASS | `qa-gates/scope-check.2026-11-03T18-55.md` (every modified existing suite changed only inside outermost `BeforeAll`); full run 13891 passed, 0 failed | AST hunk check recorded in scope-check | |
| 14 | Pure predicate suite | PASS | `other/hook-cleanup-context-tests.2026-11-03T13-05.md` (EXIT_CODE 0, 20 tests) | Evidence inspection | |
| 15 | Parity and literal pinning | PASS | `other/parity-and-guard-tests.2026-11-03T14-06.md` (EXIT_CODE 0); SHA-256 recomputed in this review: two distinct hashes, four identical files each | `sha256sum` over the eight files | Superseded 13-47 run (EXIT_CODE 1) is not used. |
| 16 | Skill and brief text | PASS | `other/skill-text-tests.2026-11-03T13-42.md`; re-run after the `origin/main` merge in all three shuffled seeds | Evidence inspection | Merge `29d98ff43` touched the same SKILL.md; post-merge runs pass. |
| 17 | Brief byte-identity contract | PASS | `other/skill-text-tests.2026-11-03T13-42.md`; `qa-gates/contract-tests.2026-11-03T18-39.md` (post-merge) | Evidence inspection | |
| 18 | Contract, generator, parity, and guard suites | PASS | `qa-gates/contract-tests.2026-11-03T18-39.md` (176 passed, generator exit 0); `other/parity-and-guard-tests.2026-11-03T14-06.md` | Evidence inspection | |
| 19 | New-file coverage at or above 85%; no changed-line regression | PASS | New files 97.94%, 97.94%, 97.89%, 90.14%, 98.08%; modified files equal or higher; added lines in modified files all covered | Per-file JaCoCo line union over `artifacts/pester/parallel/shard-*/powershell-coverage.xml` | The canonical merged file is not present in the worktree (gitignored; parallel merge refused on unrelated host failures). The shard union reproduces the 14-32 evidence figures exactly; see the policy audit coverage note. |
| 20 | Line caps unchanged; no file above the hard block | PASS | `qa-gates/scope-check.2026-11-03T18-55.md`; logical counts in this review: largest 506, helpers 499, Codex gate 493 | Logical line count script over added/modified covered files | |
| 21 | No new Python; no hook invokes Python | PASS | `git diff --name-only --diff-filter=A` lists 0 `.py`; 0 `python`/`poetry` tokens in added hook lines | `git diff <merge base> HEAD -- .claude/hooks .codex/hooks` token scan | |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 21 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. At the CI gate, confirm the Windows `poshqc / PowerShell QC` shard jobs and the Linux hook-suite job pass on the PR head; they supply the concurrent-shard confirmation that plan task P9-T7 could not record on the Linux Codespace host.
2. After merge, run the live manual validation in `spec.md` `## Test Strategy` (full cleanup workflow from a main session with no checkpoint) and record it under `evidence/`.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

### Acceptance Criteria Status

- Source: `docs/features/active/cleanup-worktrees-workflow-blocked-by-checkpoint-gates-1026/spec.md`
- Total AC items: 21
- Checked off (delivered): 21
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/cleanup-worktrees-workflow-blocked-by-checkpoint-gates-1026/spec.md` | 21 | 21 | 0 | Checkbox-backed; all 21 were already checked by the executor |

No source-file checkbox change was made in this review: all 21 items evaluated PASS and were already `- [x]`.
