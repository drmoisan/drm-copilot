# Code Review: Cleanup-Context Legs for the Checkpoint Gates (#1026)

---

**Review Date:** 2026-11-03
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/cleanup-worktrees-workflow-blocked-by-checkpoint-gates-1026`
**Feature Folder Selection Rule:** the single active folder whose name carries the canonical issue number 1026; no version subfolder exists.
**Base Branch:** `main` (merge base `01706c697f3ad4a53b4a771d99d851afc7417ea9`)
**Head Branch:** `bug/cleanup-worktrees-workflow-blocked-by-checkpoint-gates-1026` at `b12f4b25ac06b94c646b275e8e88e6ea967a3baa`
**Review Type:** Initial review

---

## Executive Summary

The branch makes the `cleanup-merged-worktrees` workflow executable from an agent session that has no orchestrator checkpoint. It adds allow-side legs at the final deny points of the Claude and Codex preimplementation gates, a cleanup exemption in the PR-author preflight, and a cleanup allow for `Agent(pr-author)` in the model-routing receipt gate. The diff is 101 files (+7942/-38): five new PowerShell production files with five byte-identical bundle mirrors, five modified production hooks (each with one guarded dot-source and one call, or a line-neutral rename), skill and brief text in every copy, two pack manifests, 8 new Pester suites, 26 existing test files changed only inside their outermost `BeforeAll` or a constant list, and feature-folder documents and evidence.

Evidence reviewed: the full branch diff, the five new production files read in full, the hunks of the five modified production files, the PR context summary, and every evidence file under the feature folder. Implementation quality is high: every leg is fail-closed, pure prefilters run before any process, I/O is behind named seams, and the deny text outside the cleanup context is byte-for-byte unchanged.

**What changed:**
- `.claude/hooks/hook-cleanup-context.ps1` (and three copies): pure predicates for manifest text, the `docs/` and `.claude/agent-memory/` allowlist, the consolidation record by porcelain branch, the scratch rule, and the delegation branch label.
- `.claude/hooks/enforce-orchestration-preimplementation-gate-cleanup.ps1` (and three copies): `Test-OrchestrationCleanupContextAllowed` composing the manifest, scratch, consolidation Write/Edit, and consolidation `git add`/`git commit` legs, plus the temporary-root and staged-index seams.
- `.claude/hooks/enforce-pr-author-skill.cleanup.ps1` (and bundle copy): `Get-PrAuthorPreflightExemption`, which runs the docs-only exemption first and then K1 to K6.
- `.claude/hooks/enforce-model-routing-receipt.ps1`: `Test-ModelRoutingCleanupDelegation` and one allow before the final deny.
- Codex gate entry tail forwards Write `content` to the decision.

**Top 3 risks:**
1. The PR-author K6 diff evaluates the local `HEAD` of the resolved consolidation worktree, not the remote branch that `gh pr create --head documentationandmemories` publishes. A remote branch that diverged from the local worktree would be judged on the local tree.
2. The live workflow cannot be exercised before merge, because isolated subagents execute `main`'s hook copies; the post-merge manual validation in the spec is the only end-to-end confirmation on real git state.
3. The concurrent-shard isolation run could not be completed cleanly on the Linux Codespace host because of 89 pre-existing Windows-fixture failures outside the diff; the Windows CI shard jobs are the remaining confirmation.

**PR readiness recommendation:** **Go** — no Blocker or Major finding; the Minor and Info items below are hardening suggestions that do not affect the acceptance criteria.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.claude/hooks/enforce-pr-author-skill.cleanup.ps1` | `Get-PrAuthorCleanupExemptionFailure`, lines 132-160 | K6 computes `git diff <origin/main>...HEAD` in the resolved worktree. The PR content is the remote `documentationandmemories` branch, which the exemption does not compare with the local `HEAD`. | In a follow-up, also require `refs/remotes/origin/documentationandmemories` to resolve to the same commit as `HEAD`, or diff against the remote ref. | If the remote branch carries commits the local worktree lacks, the allowlist check evaluates a different tree than the PR. Exposure is low: the push leg runs from the same worktree in the documented workflow. | Code reading; `Resolve-PrAuthorArtifactRoot` resolves the worktree from `--head` (`enforce-pr-author-skill-helpers.ps1` lines 53, 453). |
| Info | `.claude/hooks/enforce-orchestration-preimplementation-gate-cleanup.ps1` | `Test-OrchestrationCleanupConsolidationCommand`, lines 351-366 | The staged index is read before the command runs, so a single chained `git -C <root> add -- docs/x && git -C <root> commit -F <file>` is denied when the index is empty before the add. | Keep the skill's separate `add` and `commit` calls; optionally state in the skill that the two must be separate tool calls. | Usability only; the behavior is fail-closed and the skill text already shows separate commands. | `.claude/skills/cleanup-merged-worktrees/SKILL.md` lines 185-187. |
| Info | `.claude/hooks/hook-cleanup-context.ps1`, gate-cleanup sibling | `Test-CleanupScratchPath`, `Test-OrchestrationCleanupScratchWrite` | The scratch rule applies to every session, not only cleanup runs. | None; this is spec decision D3. Record it in the PR description as an intended scope. | Reviewers reading AC21 ("no relaxation outside the cleanup context") should see that the scratch rule is a deliberate, bounded exception (outside every worktree and the session root, under the temporary root). | `spec.md` D3 and D11. |
| Info | `.claude/hooks/enforce-orchestration-preimplementation-gate-cleanup.ps1` | `Test-OrchestrationCleanupContextAllowed`, lines 417-420 | A failure inside a cleanup leg is reported only through `Write-Debug`; the operator sees the unchanged `PREIMPLEMENTATION_GATE_BLOCKED` text with no sub-code. | Optional follow-up: append a cleanup sub-code when the target is the consolidation worktree, as the spec permits. | Diagnosability of a denied cleanup step; behavior is correct and fail-closed. | Spec `Error handling and logging updates`. |
| Info | `.codex/hooks/enforce-orchestration-preimplementation-gate-cleanup.ps1` | lines 66-72, 92, 210, 274, 359, 418-419 | The Codex copy reports 90.14% line coverage against 97.89% for the byte-identical Claude copy, because the Codex suite mocks both seams. | None required; above the 85% threshold. | The lines are covered in the Claude copy of the same bytes. | Shard-union coverage computed from `artifacts/pester/parallel/shard-*/powershell-coverage.xml`. |
| Info | `docs/features/active/cleanup-worktrees-workflow-blocked-by-checkpoint-gates-1026/plan.2026-11-03T06-52.md` | P9-T7 | The concurrent-shard isolation task is unchecked: 89 failures in 17 suites outside the diff, identical at the merge base. | Confirm through the Windows `poshqc / PowerShell QC` shard jobs at the CI gate. | Host-dependent pre-existing failures; touched suites (415 across hooks, runtime, lib) pass in every shard. | `evidence/regression-testing/isolation-parallel.2026-11-03T18-55.md`. |
| Nit | `docs/features/active/cleanup-worktrees-workflow-blocked-by-checkpoint-gates-1026/issue.md` | line 5 | The `Status:` line names `docs/features/active/cleanup-worktrees-workflow-blocked-by-checkpoint-gates/` without the `-1026` suffix of the actual folder. | Correct the path when the folder is next edited. | Cross-reference accuracy. | `issue.md` line 5. |

No Blockers or Major findings. No covered file is at or above 700 logical lines, so no file-size Warning row applies (largest: `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, 506 lines).

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- Every leg is evaluated only where the gate would already deny, after the epic-scope, delegation-mode, unresolved-target, and ambiguous-resolution decisions, so existing ordering and deny wording are preserved (`enforce-orchestration-preimplementation-gate.ps1` line 415; Codex line 452).
- The consolidation worktree is identified by porcelain branch and never by path, and main-stanza, prunable, detached, and duplicate records fail closed (`Find-CleanupConsolidationRecord`).
- The command leg requires every chained segment to be a recognized `git -C <absolute root> add|commit` shape (issue #539 all-segments rule), rejects `-A`, `-f`, `--amend`, `-a`, pathspecs, and any `-c` configuration override (token 1 must be `-C`), and reads the staged index only after the target matches the consolidation root.
- The allowlist is ordinal and case-sensitive, restricts operands to `A-Z a-z 0-9 . _ / -`, rejects `..` segments, and admits the receipt path only in the Write/Edit leg.
- The scratch rule fails closed when any registered worktree lies under a temporary root, which closes the 8.3 short-name aliasing gap the spec names.
- Literals restated in `hook-cleanup-context.ps1` are pinned to their owners by the parity suite, and the four copies of each new shared file are byte-identical (verified by SHA-256 in this review: two distinct hashes, four files each).
- `enforce-pr-author-skill-helpers.ps1` stays at 499 lines (cap 500) through a line-neutral call rename.

#### API and safety notes

- All new functions use `[CmdletBinding()]`, `[OutputType()]`, approved verbs, and explicit `AllowNull`/`AllowEmptyString` attributes.
- Analyzer hygiene: 0 PSScriptAnalyzer findings in 44 files; Invoke-Formatter reports no change.
- No `ShouldProcess` is required: the files make decisions and do not mutate state.

#### Error handling and logging

- Never-throw wrappers answer `$false`, so any internal error keeps the existing deny. Git seams (`Invoke-DocsOnlyGitExe`, `Invoke-PrAuthorDocsOnlyGitExe`) are bounded and wrapped.
- PR-author K-check failures append a specific sub-code to `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` only when the command names the consolidation branch, so non-cleanup denials are unchanged.

---

## Test Quality Audit

Automated evidence covers every leg with paired allow and deny cases, an end-to-end composition over the ten workflow steps, parity and literal pinning, and skill-text assertions. Coverage, regression (fail-before exit 1, pass-after exit 0), shuffled-order, and contract evidence are present.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Cleanup.Tests.ps1` (30 tests) — Claude gate legs, each allow paired with a non-consolidation and session-root deny asserting the unchanged text.
- `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-cleanup.Tests.ps1` (24 tests) — Codex legs, `apply_patch` Add/Update/Delete/Move, and entry-tail `content` forwarding.
- `tests/scripts/claude-hooks/enforce-pr-author-skill.Cleanup.Tests.ps1` (14 tests) — K1 to K6 sub-codes, docs-only ordering, receipt checks after the exemption.
- `tests/scripts/claude-hooks/enforce-model-routing-receipt.Cleanup.Tests.ps1` (9 tests) — pr-author allow and its denies.
- `tests/scripts/claude-hooks/hook-cleanup-context.Tests.ps1` (20 tests) and `hook-cleanup-context.Parity.Tests.ps1` (3 tests) — pure predicates and byte identity.
- `tests/scripts/claude-hooks/cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1` (12 tests, 10 contexts) — composed workflow with no checkpoint.
- `tests/scripts/claude-hooks/cleanup-merged-worktrees.SkillText.Tests.ps1` (10 tests) — skill and brief text; re-run after the `origin/main` merge in the shuffled runs.
- `evidence/regression-testing/fail-before.2026-11-03T12-59.md` and `pass-after.2026-11-03T14-08.md` — the same regression script denies all seven cleanup calls before the fix and allows them after, with the three controls denied in both.
- `evidence/qa-gates/pester-coverage.2026-11-03T14-32.md` — 13891 passed, 0 failed; per-file coverage reproduced exactly by this review from the shard JaCoCo files.
- `evidence/regression-testing/isolation-shuffle.2026-11-03T18-46.md` — three seeds, 3347/3347 each.

### Quality assessment prompts

- **Determinism:** all I/O seams mocked and registered in the shared baseline helper; no temporary files, sleeps, or wall-clock reads in added test lines.
- **Isolation:** one behavior per `It`; the end-to-end suite loads only the hook under test per context.
- **Speed:** about 75 ms per test in the shuffled runs.
- **Diagnostics:** exact deny strings and sub-codes are asserted, so a regression names the diverging text.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No credentials, tokens, or host paths in the diff; feature documents contain no absolute host paths (grep over the feature folder). |
| No unsafe subprocess or command construction | ✅ PASS | git runs only through existing bounded seams with fixed argument arrays; no string-built command execution and no Python invocation (0 `python`/`poetry` tokens in added hook lines). |
| Input validation at boundaries | ✅ PASS | Operand character set, `..` rejection, absolute-path checks, non-local pattern rejection, JSON object and type checks on the manifest. |
| Error handling remains explicit | ✅ PASS | Fail-closed `$false` on every error path; dependency-load failures reported through `Add-HookDependencyFailure`. |
| Configuration / path handling is safe | ⚠️ PARTIAL | Path comparisons normalize separators and drive-letter case; the only gap noted is the local-versus-remote head comparison in K6 (Minor finding above). |

---

## Research Log

No external research was required. All conclusions are drawn from the repository diff, the feature-folder evidence, and the shard coverage artifacts in the item worktree.

---

## Verdict

The change is ready for the normal PR flow. The implementation follows the spec's design (Approach A, decisions D1 to D11), preserves existing deny behavior outside the cleanup context, and is supported by paired allow/deny tests, an end-to-end composition, parity checks, and coverage of 90.14% to 98.08% on every new production file. The Minor K6 hardening item and the Info items are suitable for a follow-up or the PR description and do not block merge.
