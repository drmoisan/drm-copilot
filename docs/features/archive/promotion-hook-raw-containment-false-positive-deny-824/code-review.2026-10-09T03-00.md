# Code Review: Structural command-invocation matcher (#824, bundles #742 and #733) — Remediation Cycle 1 Re-review

---

**Review Date:** 2026-10-09
**Reviewer:** feature-review agent (Claude)
**Feature Folder:** `docs/features/active/promotion-hook-raw-containment-false-positive-deny-824`
**Feature Folder Selection Rule:** The only active feature folder changed on the branch; its suffix matches issue 824 in the branch name.
**Base Branch:** `origin/epic/enforcement-hook-precision-integration` (tip and merge base `e1433ff3`)
**Head Branch:** `bug/promotion-hook-raw-containment-false-positive-deny-exec-824` (local `c1a-824-resume`, head `a1201d73`)
**Review Type:** Remediation cycle 1 re-review (R4). Cycle input: `remediation-inputs.2026-10-09T01-50.md` (MC-1). Prior review: `code-review.2026-10-09T01-20.md`.

---

## Executive Summary

Remediation cycle 1 addressed one Blocking finding, MC-1: PR #855 could not merge because the integration branch (`e1433ff3`, PR #854, issue #565) added `feature-folder-resolution.ps1` to the same two list sites this branch extended, the Claude `pack-manifests/core.json` and `SharedModuleNames` in `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`. The executor merged the integration branch into the feature branch (`b230eaf5`; parents `af036e0f` and `e1433ff3`; fast-forward push, no force) and resolved both conflicts as a union.

The reviewer verified the resolution directly from the merge's combined diff and from the tree at HEAD:

- `git diff-tree --cc --name-only b230eaf5` lists only the Claude manifest, the Codex manifest (auto-merged), and the legacy contracts test. The merge introduced no hunk outside the list sites.
- Claude manifest: `.claude/hooks/feature-folder-resolution.ps1` then `.claude/hooks/hook-command-heredoc.ps1`, in sorted position after `enforce-promotion-mcp-only.ps1`. The manifest parses, has 208 entries and 0 duplicates, and every entry exists in the Claude bundle.
- Codex manifest: both sides' entries are retained; 122 entries, 0 duplicates.
- `SharedModuleNames`: ten unique names, the base's six (including `feature-folder-resolution.ps1`) and this branch's four new shared modules.
- No conflict markers remain anywhere in the hook, bundle, or test trees.
- No production `.ps1` file of this branch changed after QC pass 2 (`f0c55759`), and every shared-module and mirror hash at HEAD equals the QC pass 2 record.

Regression check at HEAD: 61 Pester files (2374 tests, 2373 passed). The one failure is the pre-existing B_FULL row. The run covered all 22 changed suites and every #565 suite the merge brought in. The pytest manifest and resource-contract suites also passed (27). PR #855 reported `MERGEABLE` after the merge, and all 20 CI checks on head `a1201d73` pass (run 37872995191, including `poshqc / PowerShell QC`).

**What changed:**
Since the prior review: one merge commit with a two-line union resolution, plus feature-folder documents (remediation inputs, plan, baseline, merge, and QC evidence). No production hook, mirror, agent, or skill file changed.

**Top 3 risks:**
1. AC-20's live smoke has not exercised this branch's `pr-author.md`, because the session that ran it loaded the agent definition from a different checkout. `pr-author.md` is the only agent in the repository with a frontmatter `PreToolUse` hook, so no other in-repo agent shows that the runtime honors this registration shape.
2. Two test files remain at 497 lines (`enforce-epic-worktree-removal-gate.Tests.ps1`, `legacy-codex-hook-contracts.Tests.ps1`). The next list addition to `SharedModuleNames` by any epic child will conflict at the same single-line site again, and a multi-line reflow would breach the 500-line limit.
3. The prior review's design residuals are unchanged and still open: a misattributed deny reason for malformed PowerShell payloads, and `git log --output=<file>` passing the allowlist.

**PR readiness recommendation:** **Go**. MC-1 is resolved, no Blocking or Major finding exists, and CI is green on the PR head. AC-20 is an operator follow-up (see feature audit).

---

## Findings Table

All findings are Non-blocking. Blocking count: 0.

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`; `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | merge `b230eaf5`, manifest lines 55-58; test line 30 | MC-1 resolution verified: a union with no lost or duplicated entry, sorted placement in the Claude manifest, ten-name `SharedModuleNames`, and no conflict markers. | None. | Confirms closure of the cycle input. | `git show b230eaf5 --cc`; reviewer `mf.js` (208 entries / 0 duplicates / 0 absent from disk; Codex 122 / 0 duplicates); `grep` for conflict markers: none; legacy suite 43 passed at HEAD |
| Minor | `.claude/agents/pr-author.md` | frontmatter `hooks.PreToolUse` | The AC-20 live smoke ran from a session whose root `pr-author.md` lacks the `PreToolUse` registration (reviewer read the session-root file: only `SubagentStop`). The smoke did not test this branch's definition. No other agent in `.claude/agents/` registers a frontmatter `PreToolUse` hook, so the runtime behavior of this registration shape is not yet demonstrated in the repository. | Operator: run the documented smoke from a Claude Code session rooted at a checkout that contains this branch's `pr-author.md` (this branch, or the integration branch after merge). Record the result, and check off AC-20 if the deny prefix is `PR_AUTHOR_COMMAND_NOT_ALLOWED:`. If the hook does not fire there, file a defect against the registration. | The static row AL-33 proves the file content but not the runtime wiring. The allowlist hook is defense in depth: the project-level `enforce-pr-author-skill.ps1` gate is registered in `.claude/settings.json` and is unaffected. | `evidence/other/pr-author-hook-live-smoke.2026-10-08T22-52.md`; `head -20` of both `pr-author.md` copies; `Grep '^  PreToolUse:' .claude/agents/*.md` (one match) |
| Info | `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | line 30 (`$script:SharedModuleNames`) | Every epic child that adds a shared hook module edits this single line, and the file is at 497 lines. MC-1 was caused by exactly this pattern, and the next sibling (C1b, C3) will hit the same conflict. | In a later change, derive the shared-module set from a data source (for example the Codex manifest plus a module-marker comment) or move the list to a one-name-per-line array in a separate data file, keeping the test under 500 lines. | Reduces repeated merge conflicts across the epic's parallel children. | MC-1 cause in `remediation-inputs.2026-10-09T01-50.md`; reviewer line count 497 |
| Info | `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` | entries `config/orchestration-handoff-registry.json`, `config/orchestration-handoff.schema.json`, `.codex/lib/codex-routing/CodexDeployment.psm1`, `.codex/lib/codex-routing/CodexTopology.psm1` | Four entries do not resolve to files under the Codex bundle root. They are identical at the base tip `e1433ff3` and are not touched by this branch; the completeness suites pass, so they are presumably resolved against another root or covered by an exception list. | None for this branch. | Recorded so the reviewer's manifest parse result is not misread as a regression. | `git show origin/epic/enforcement-hook-precision-integration:<Codex core.json>` lines 119-122; pytest 27 passed |
| Info | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` (merged from #565) | `Invoke-OrchestrationPreimplementationGateDecision` | This is the only #565 production file that also loads the #824-modified scanner and invocation modules. The #565 edit changes Agent-prompt issue-number parsing (`-KeyedOnly`, `-FallbackIssueNumber`) and does not interact with Bash command classification. The executor's 27-file remediation QC set did not include the preimplementation-gate suites; the reviewer ran all 20 of them at HEAD and they passed. | None. | Closes the semantic-merge question that a conflict-free auto-merge leaves open. | `git diff af036e0f b230eaf5 -- .claude/hooks/enforce-orchestration-preimplementation-gate.ps1`; reviewer run FILE_RESULT lines (13 Claude, 7 Codex suites, 0 failed) |
| Info | `docs/features/active/promotion-hook-raw-containment-false-positive-deny-824/evidence/**` | file-name timestamps | Remediation evidence files carry local-time stamps (`2026-10-08T22-14` .. `22-34`), while the remediation inputs, plan, and review artifacts carry UTC-looking stamps (`2026-10-09T01-50`). Within the remediation evidence the order is consistent. | Use one time basis for feature-folder timestamps in later cycles. | Mixed bases make cross-artifact ordering harder to read. | Directory listing of `evidence/other/` and `evidence/qa-gates/`; PR-context generation time `2026-10-09 02:08:31 UTC` versus local file time `22:08` |
| Minor (carried) | `.claude/hooks/hook-command-invocation.ps1` (and Codex copy, mirrors) | `Get-CommandLineInvocation` | Carried unchanged from the prior review: an unparsable PowerShell payload is Indeterminate for every governed query, so the promotion hook denies it with a reason naming `gh issue create`. | Follow-up for the matcher owner (prior review row 1). | Code unchanged since the prior review (hash identity). | `code-review.2026-10-09T01-20.md` Findings row 1 |
| Minor (carried) | `.claude/hooks/enforce-pr-author-command-allowlist.ps1` | `Test-PrAuthorAllowlistForm` | Carried unchanged: `git log --output=<file>` is allowed. | Follow-up (prior review row 2). | Code unchanged since the prior review. | `code-review.2026-10-09T01-20.md` Findings row 2 |
| Minor (carried) | `evidence/qa-gates/qc-pass-2-parity-hashes.2026-10-08T23-24.md` | Output Summary | Carried: states 16 groups and lists 15. Reviewer recomputation at HEAD again matches the 15 listed hashes. | Correct on a later evidence touch. | Evidence text accuracy. | Reviewer `hash.ps1` output |

No Blockers or Major findings.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The merge was performed as a true merge (two parents, fast-forward push). The pre-resolution state was recorded with `git ls-files -u` (stage 1/2/3 blobs for exactly the two paths), a merge check that demonstrably fails on the conflicted tree (6 markers, `MERGE_CHECK: FAIL`), and the same check passing after resolution. This makes the resolution reproducible and auditable.
- The resolution kept the test assignment on one line, so the conflicted file returned from 501 lines (with markers) to 497.
- The scope check after QC (`git diff --name-only b230eaf5`) shows that only feature-folder files changed after the merge commit, so no fix-up edit was hidden after the merge.

#### API and safety notes

- No public function, signature, or hook registration changed in this cycle.
- `feature-folder-resolution.ps1` is byte-identical across `.claude/hooks/`, `.codex/hooks/`, and both bundles (reviewer hash, 1 distinct value), and the Codex manifest lists it, so the legacy completeness row holds for all ten names.

#### Error handling and logging

- Unchanged in this cycle.

---

## Test Quality Audit

The cycle changed one test literal. The reviewer reproduced the executor's per-file results for the overlapping files (for example legacy contracts 43, `feature-folder-resolution` 61 per surface, Issue824 suites identical counts) and extended the run to the adjacent suites the merge could affect.

### Reviewed test and QA artifacts

- `evidence/remediation-baseline/merge-tree-conflicts.2026-10-08T21-58.md`: pre-merge prediction of the two conflicts.
- `evidence/remediation-baseline/legacy-pester.2026-10-08T22-10.md`, `legacy-format`, `legacy-analyze`: pre-merge state of the conflicted test file.
- `evidence/other/remediation-1-merge.2026-10-08T22-14.md`: merge output, unmerged index entries, failing pre-resolution check.
- `evidence/other/remediation-1-merge-check.2026-10-08T22-17.md`: post-resolution check (`MERGE_CHECK: PASS`, 0 markers, 10 shared names, 0 duplicates).
- `evidence/other/remediation-1-merge-commit.2026-10-08T22-20.md`: parents and push output.
- `evidence/qa-gates/remediation-1-format`, `-analyze`, `-pester` (27 files, 1194 passed), `-pytest-manifest-parity` (6 passed), `-pytest-files` (27 passed), `-qc-summary` (`MC-1: RESOLVED`).

### Quality assessment prompts

- **Determinism:** The reviewer's independent run matches the executor's counts.
- **Isolation:** Unchanged.
- **Speed:** 2374 tests in 45 s.
- **Diagnostics:** The legacy completeness row's `-Because` names the module that fails to publish.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Combined diff of `b230eaf5` adds only path strings. |
| No unsafe subprocess or command construction | ✅ PASS | No production code changed in this cycle. |
| Input validation at boundaries | ⚠️ PARTIAL | Unchanged from the prior review; two carried Non-blocking residuals (Findings rows 7-8). |
| Error handling remains explicit | ✅ PASS | Unchanged. |
| Configuration / path handling is safe | ✅ PASS | Manifests parse; no duplicate or dangling entry introduced by the branch. |
| Byte-identical surfaces | ✅ PASS | Reviewer `Get-FileHash` at HEAD: six #824 shared modules and `feature-folder-resolution.ps1` identical across four copies; promotion and epic-gate hooks identical to their mirrors per surface; allowlist, parallel gate, helpers, `pr-author.md`, `SKILL.md` identical to mirrors. |

---

## Research Log

No external research was required. Sources: the merge commit's combined diff, the base-tip manifest, the session-root `pr-author.md`, PR #855 state and checks via `gh`, and reviewer runs at HEAD.

---

## Verdict

MC-1 is resolved correctly and the merge introduced no regression. The branch content reviewed in `code-review.2026-10-09T01-20.md` is unchanged. The change is ready for merge into the integration branch; CI is green on the PR head. The AC-20 runtime smoke should be completed by the operator from a session that loads this branch's agent definition.
