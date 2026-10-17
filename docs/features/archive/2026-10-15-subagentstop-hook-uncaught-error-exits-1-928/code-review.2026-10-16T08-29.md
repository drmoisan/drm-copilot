# Code Review — Issue #928 (SubagentStop validator uncaught error exits 1), re-review after local coverage regeneration

**Branch:** `bug/subagentstop-hook-uncaught-error-exits-1-928`
**Base:** `origin/main` @ `a880c46b919ca58b1144a925d54488ce51f02bfb`; merge base `a880c46b919ca58b1144a925d54488ce51f02bfb` (37 ahead, 0 behind)
**Head reviewed:** `637876da102759531b42b436dfb248196c77b5e2` (code head `b43188f8377b5c2bbbfd5484f52b7fc226876353`; PR #954)
**Scope:** full branch diff against `origin/main` (145 files, +5447/-51).
**Files reviewed:** eight validators under `.claude/hooks/` (discovery-artifact-gate, executor, orchestrator, planner, pr-author, prd-feature, required-artifact, task-researcher), `.claude/hooks/subagentstop-envelope.ps1`, `.claude/hooks/enforce-epic-wave-barrier.ps1`, `.claude/skills/epic-orchestrate/SKILL.md`, `.claude/agents/epic-orchestrator.md`, `.agents/skills/translate-claude-to-codex/SKILL.md`, `docs/engineering/claude-code-architecture.md`, `tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1`, three edited Pester files, `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`, all bundle mirrors, and the feature documents and evidence added since the prior review.

## Total Blocking Findings: 0

CR4-B1 and CR4-B2 (local coverage artifact state) are resolved. This review parsed both regenerated local reports: PowerShell is at 94.58% repo-wide line coverage, and Python is at 93.80% lines and 88.11% branches. CR4-N2 (branch behind `main`) is resolved by merge `5f4f9a332`. CR4-N1 is carried forward as CR5-N3. Two new non-blocking findings concern the regeneration evidence.

## Executive Summary

No production, test, or bundle file changed since the prior review. `git diff --stat b43188f83 HEAD` over `.claude`, `.agents`, `extensions/drm-copilot/resources`, `tests/scripts/claude-hooks`, `docs/engineering`, and the expectations module is empty. The commits since then are:

- the merge of `origin/main` (`5f4f9a332`), which touched no item file;
- the cycle 3 re-audit artifacts (`6c2c717c3`);
- `evidence/qa-gates/local-coverage-regeneration.2026-10-16T08-25.md` (`637876da1`).

## Prior Findings Verification

| Prior finding | Status | Verification by this review |
|---|---|---|
| CR4-B1 (local PowerShell report 52.00%, partial scope) | Resolved | `artifacts/pester/powershell-coverage.xml` (mtime 08:20:13 UTC) report LINE counter: covered 11632, missed 667, 94.58%. Present changed hooks: discovery 100.00, orchestrator 99.10, planner 99.50, wave-barrier 98.96. |
| CR4-B2 (local Python lcov absent) | Resolved | `artifacts/python/lcov.info` (mtime 08:24:48 UTC): LF 17638, LH 16544 (93.80%); BRF 6368, BRH 5611 (88.11%). No record for the changed test-support module (omitted by configuration). |
| CR4-N1 (CI pending on final head) | Carried as CR5-N3 | CI on `6c2c717c3`: 20 of 20 check runs success (`gh api` by this review). CI on `637876da1` is in progress. |
| CR4-N2 (55 behind `main`) | Resolved | `git rev-list --left-right --count HEAD...origin/main` = `37 0`. |
| CR-N5, CR2-N1, CR2-N2, CR2-N5, CR3-N1, CR3-N2 | Accepted (orchestrator decision) | Not re-raised. |

## Production Code Review

### Tail wrapper correctness (re-confirmed at `637876da1`)

- Catch lines (grep by this review): discovery `:253`, executor `:322`, orchestrator `:344`, planner `:440`, pr-author `:129`, prd-feature `:118`, required-artifact `:199`, task-researcher `:290`. Each calls `Exit-SubagentStopBlock` with the validator's S1 prefix.
- Every catch line is covered: none appears in any missed-line list in the local report or in CI run 38871371045.

### Mirror parity

`cmp` by this review at `637876da1`: all 12 changed `.claude` files are byte-identical to `extensions/drm-copilot/resources/claude-customizations/.claude/...`. `.agents/skills/translate-claude-to-codex/SKILL.md` is byte-identical to its `codex-and-agents-customizations` mirror.

### `parallel_orchestrator_surface_expectations.py`

Unchanged since cycle 3. The pins at lines 174 and 178 equal the current `sha256sum` of both frozen files. Black, Ruff, and Pyright are clean, and the two contract suites pass (50 passed). All were re-run by this review.

## Test Design Review

`subagentstop-uncaught-error.Tests.ps1` (159 lines) is unchanged since cycle 1. The design assessment in the prior review still applies. U2 depends on the set of hooks that dot-source `subagentstop-envelope.ps1`. The merge from `main` changed no `.claude/hooks` file, so that set is unchanged.

## Findings Table

Blocking findings: 0. Non-blocking findings: 3.

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Non-blocking | `artifacts/pester/powershell-coverage.xml` (local, gitignored); cause stated at `evidence/qa-gates/local-coverage-regeneration.2026-10-16T08-25.md:10` | sourcefile records | CR5-N1: the local report has no record for six changed hooks: `validate-executor-output.ps1`, `validate-pr-author-output.ps1`, `validate-prd-feature-output.ps1`, `validate-required-artifact-output.ps1`, `validate-task-researcher-output.ps1`, and `subagentstop-envelope.ps1`. | No action for this item. Optionally track a follow-up so that the MCP PoshQC runner uses the repository's coverage configuration rather than the installed extension's. | The per-file figures for these six files come from CI run 38871371045 on `6c2c717c3`, which has the same code as HEAD: 98.08%-100.00%, with all catch lines covered. | Local XML and CI XML parsed by this review. |
| Non-blocking | `docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/evidence/qa-gates/local-coverage-regeneration.2026-10-16T08-25.md` | line 11 | CR5-N2: the evidence file states "branch coverage 92.07% (5863/6368)". The lcov file reports BRH 5611 / BRF 6368 = 88.11%. The 5863 figure subtracts coverage.py's partial-line count (505) from the branch total, but that count is not a count of missed branches. | Correct the figure to 88.11% (5611/6368) if the file is revised. | Evidence figures should be reproducible from the artifact they cite. Both values are above 75%, so no verdict changes. | lcov LF/LH/BRF/BRH totals summed by this review. |
| Non-blocking (Info) | PR #954 head `637876da1` | CI run 38873583121 | CR5-N3 (carries CR4-N1): CI on the final head was queued or in progress at review time. 5 checks had passed and the rest were pending. | The orchestrator confirms the CI green gate on `637876da1` at S9, as the caller stated. | `637876da1` adds only one Markdown evidence file relative to `6c2c717c3`, which had 20 of 20 checks succeed. | `gh pr checks 954`; `gh run list`; `git diff --name-status 6c2c717c3 HEAD`. |

## Out-of-Loop Observation (accepted; predates this branch)

`.claude/hooks/validate-planner-output.ps1:186` rejects root-level `CITATION:` paths because the pattern requires at least one `/`. The line predates this branch and is accepted per orchestrator decision.

## Positive Observations

- The regeneration changed no tracked file other than the one evidence file, and both local reports are reproducible from their contents.
- The merge from `main` brought no conflict or drift into the item paths, and the frozen-surface pins still match.
- Mirror parity, excluded-path invariants, and evidence-location compliance hold at the final head.
