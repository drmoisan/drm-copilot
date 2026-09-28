# Code Review: Epic-Level Checkpoint Seam for Enforcement Gates (#663)

**Review Date:** 2026-09-25
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/enforcement-gates-lack-epic-level-checkpoint-seam-663`
**Feature Folder Selection Rule:** the only active feature folder in the branch diff; its suffix matches issue #663 in the branch name.
**Base Branch:** `origin/main` (`d754f83f`, equal to the merge base)
**Head Branch:** `bug/enforcement-gates-lack-epic-level-checkpoint-seam-663` (`ac8ef840`)
**Review Type:** Initial review

---

## Executive Summary

The branch introduces `EpicScopeResolution.psm1` (366 lines) and `EpicScopeReadiness.psm1` (176 lines), a dot-sourced gate-4 sibling (127 lines), and wires epic scope into the pr-author PR-creation preflight (gate 1), the epic base-branch check (gate 2), the model-routing receipt gate (gate 3), and the preimplementation gate command and path legs (gate 4). Gate 4b narrows the staging-exemption character check so that `<` and `>` are unresolvable only outside quoted spans. Contract documents, mirrors, the pack manifest, and the Pester coverage allow-list are updated. The implementation is small, readable, well-seamed, and conforms to decisions D1, D3, and D5 as written; D2 and D4 conform in the tested cases with the gaps listed below.

Evidence reviewed: the full diff `git diff origin/main...HEAD`, all new and extended test files, the feature evidence under `evidence/{baseline,regression-testing,qa-gates,other}/`, reviewer-computed SHA-256 mirror comparisons, `git ls-files --eol` for the changed files, and a manual trace of the staging-exemption parser. The PowerShell runtime could not be invoked from this agent worktree (the worktree isolation guard denies `pwsh` and `powershell` command text), so CR-1 was established by code trace rather than execution.

**What changed:**
- Resolver: fail-closed, composes the epic checkpoint path from `Find-WorktreeResolutionRoot` output only, reads it once through a seam, and never takes a path from command or prompt text (`EpicScopeResolution.psm1:313-356`).
- Gate 1/2: `Get-PrAuthorBypassReason` resolves scope once and passes the object to check 6 (`enforce-pr-author-skill-helpers.ps1:338-377`; `enforce-pr-author-skill.epic-base-branch.ps1:96-105`).
- Gate 3: epic-scope receipt lookup before per-feature resolution (`enforce-model-routing-receipt.ps1:243-259`).
- Gate 4: epic decision placed after the implementation classification and before the mode branch, so bookkeeping operands still clear through the existing exemption and only implementation-classified calls reach the D2 rule (`enforce-orchestration-preimplementation-gate.ps1:387-394`; sibling `:88-127`).
- Gate 4b: new `Test-OrchestrationCommandTextUnresolvable` (`enforce-orchestration-preimplementation-gate-helpers.ps1:110-152`).

**Top 3 risks:**
1. CR-1: the quote-aware scanner treats `\"` inside a double-quoted span as a closing quote, so a shell-unquoted `>` redirection can be admitted by the staging exemption. This is a regression relative to `origin/main`, which denied any `>` anywhere.
2. CR-2: in gate 4, a text branch signal overrides the `-C` selector, so the D2 `MERGE_HEAD` probe can inspect a different worktree than the one the command operates on.
3. The #655 end-to-end sequence has not been rerun on a live epic, and no CI run exists yet for the branch head.

**PR readiness recommendation:** **Needs Revision** — CR-1 re-opens a redirection path the pre-change gate denied, and it must be closed fail-closed before the PR is opened.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` (and the three byte-identical copies) | lines 110-152, decisive logic at 139-149; docstring 115-120 | CR-1. `Test-OrchestrationCommandTextUnresolvable` closes a double-quoted span at any `"`, including `\"`. For `git add docs/features/active/x/a.md && git commit -m "a\"" > src/prod.ts "\"" docs/features/active/x/a.md` the scanner regards ` > src/prod.ts ` as quoted; `Split-OrchestrationCommandLine` reports it balanced; `ConvertTo-OrchestrationCommandToken` yields one message token `a\ > src/prod.ts \` consumed by `-m`; the single operand is exempt. `Test-ExemptOrchestrationStagingCommand` returns true, `Test-ImplementationCommand` returns false, and the gate allows with no checkpoint. A POSIX shell parses `"a\""` as `a"` and performs `> src/prod.ts`, truncating a production file. On `origin/main` the whole-line `IndexOfAny` check denied this line. The docstring claims unmodelled escapes fail toward deny; that holds for single quotes only. | Keep D4 (no escape modelling) but fail closed: return true from `Test-OrchestrationCommandTextUnresolvable` when a backslash occurs inside a double-quoted span (or when any `\` is immediately followed by a quote character). Apply to all four copies byte-identically, correct the docstring, and add deny rows for the escaped-quote redirection form and the escaped-quote chain-operator form (CR-3) to both command-exemption suites. | Spec risk mitigation (`spec.md:283`) requires that the quote-aware check not admit a redirection; the boundary that unquoted `<`/`>` stay denied is violated for shell-unquoted text the scanner misclassifies. The exemption is allow-side only, so a false allow bypasses the gate entirely. | Code trace of `helpers.ps1:57-104` (split), `:110-152` (scanner), `:154-205` (tokenizer), `:325-407` (segment rule); `enforce-orchestration-preimplementation-gate.ps1:126-161`; no test row contains `\"` (diff of both command-exemption suites). |
| Major | `.claude/lib/worktree-resolution/EpicScopeResolution.psm1` | lines 336-355; caller `enforce-orchestration-preimplementation-gate-epic-scope.ps1:116-117` | CR-2. When the command text carries a branch signal (`--branch X`, `--head X`, or `branch: X`, for example inside a commit message), `$effectiveRoot` stays the session root and the `-C` selector is ignored. The D2 `MERGE_HEAD` probe then runs against the session root, not the worktree the command stages into. A coordinator mid-merge at its root could therefore stage production paths in another worktree via `git -C <other> commit -m "branch: <integration_branch>" <path>`. | For the command and path legs (`-MatchWorktreeHead`), decide scope and the merge probe from the effective worktree (selector, else session root) and ignore text branch signals, or require the text signal and the effective-worktree HEAD to agree. Add a row with a selector plus a conflicting `branch:` label. | D2 (`spec.md:70`) states the merge must be in progress "in the effective worktree". The tested cases conform; this edge case does not. | `EpicScopeResolution.psm1:313`, `:336-347`, `:352-355`; `WorktreeTargetResolution.psm1:164-185` (branch pattern applies to any text). |
| Minor | `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | lines 57-104 (`Split-OrchestrationCommandLine`) | CR-3 (pre-existing on `origin/main`, #539). The segment splitter shares the unmodelled-`\"` state machine, so `;`, `&&`, or `|` can be hidden in a scanner-quoted span, e.g. `git commit -m "x\"" ; <other command> ; "\"" -- docs/features/active/x/a.md`. Not introduced by this branch. | Closed by the CR-1 remediation if the fail-closed rule is applied before splitting (it is: row 12 runs first at line 460). Add a regression row. | Same parser family; one fix covers both. | `helpers.ps1:57-104`, `:458-470`. |
| Minor | `tests/scripts/claude-hooks/*` (pre-existing, unmodified gate-4, gate-1, gate-3 suites) | n/a | CR-4. Existing suites now call the unmocked resolver, which reads `<repo root>/artifacts/orchestration/epic-orchestrator-state.json` (gitignored) and, if present, the real HEAD. CI has no such file, so CI results are deterministic; a developer machine holding an epic checkpoint whose `integration_branch` equals the current HEAD could see those suites change outcome. Same class as issue #510. | Mock `Get-EpicScopeCheckpointText` to `$null` (inside `EpicScopeResolution`) in the shared fixture helper used by those suites, or record the dependency in the #510 follow-up. | General unit test policy: tests must not rely on mutable external state. | `EpicScopeResolution.psm1:317-322`; `enforce-orchestration-preimplementation-gate.ps1:387-394`. |
| Minor | `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | lines 18-22 | CR-5. The PURITY header says the per-mode read seams live in the main gate hook; they moved to the epic-scope sibling. Already recorded as follow-up 3 in `evidence/other/follow-ups.md`. | Update the sentence in a later change that touches the modes file. | Documentation accuracy. | `evidence/other/follow-ups.md` item 3. |
| Info | `docs/features/active/enforcement-gates-lack-epic-level-checkpoint-seam-663/spec.md` | line 248 (AC-11) | CR-6. For missing `route_id` or `integration_branch`, the gate denies through the single-feature path and the reason does not name the epic checkpoint. This is the only behaviour consistent with the scope-defining rule at `spec.md:83` and the fail-closed invariant at `spec.md:99`; the plan records it as RS-2 and the readiness predicate names both conjuncts when called directly. | None required. | Interpretation documented before execution. | `plan.2026-09-25T08-25.md:157`; gate EpicScope suite rows for `route_id`/`integration_branch`. |
| Info | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1` | lines 228-308 | CR-7. Executor deviation: five extra rows cover the relocated read seams and the no-leg guard, added after final-QC pass 1 found the sibling at 66.67%. The rows are hermetic (mocked `Test-Path`, `Get-Content`, `Get-OrchestrationDelegationCheckpointPath`) and appropriate. | None. | Coverage remediation within policy. | `evidence/qa-gates/final-pester-coverage.pass1.md`, `final-pester-coverage.md`. |
| Info | `docs/features/active/enforcement-gates-lack-epic-level-checkpoint-seam-663/evidence/qa-gates/final-seven-stage-loop.md` | Command note | CR-8. Executor deviation: the plan's `Select-String ... -Recurse` form does not exist in PowerShell 7 and was replaced by `Get-ChildItem -Recurse -File | Select-String -SimpleMatch`. The replacement is equivalent for the stated purpose. One commit was made with `-m`; all 16 commits carry the required attribution trailers. | None. | Deviations are documented and do not change outcomes. | `git log origin/main..HEAD`. |
| Info | `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt` | n/a | CR-9. PR context artifacts are absent in the worktree; the collector is not in this reviewer's toolset. The review used `git diff origin/main...HEAD` directly. | Run `mcp__drm-copilot__collect_pr_context` against `origin/main` before pr-author. | pr-author preflight requires them. | `ls artifacts/`. |

One Blocker and one Major finding.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- `test_validate_accepts_epic_issue_num_and_model_routing_receipts` proves the additive epic fields pass the unchanged validator.
- The frozen-surface pin re-baseline carries an in-file rationale; the new digests equal the reviewer-computed SHA-256 of the committed LF files.

#### Typing and API notes

- No new public Python API surface was added.

#### Error handling and logging

- Not applicable (test-support files only).

### PowerShell implementation audit

#### What changed well

- The resolver's ordered early returns make each fail-closed reason explicit (`no-branch-signal`, `session-root-unresolved`, `epic-checkpoint-absent-or-unparseable`, `route_id`, `integration_branch`, `selector-unresolved`, `branch-mismatch`).
- Checkpoint path is composed only from the resolved root (`EpicScopeResolution.psm1:321`); tests prove text naming another checkpoint is ignored.
- `ConvertFrom-EpicScopeCheckpointText` rejects non-object JSON as well as parse errors.
- Gate 1 resolves once and passes the scope object to check 6, verified by an invocation-count test.
- Gate 4 places the epic decision after `Test-ImplementationCommand`, preserving the bookkeeping exemption for epic-status commits as D2 requires.
- Mirrors are byte-identical; the four helper copies share one SHA-256.

#### API and safety notes

- `[CmdletBinding()]`, `[OutputType()]`, explicit `Export-ModuleMember`, and justified analyzer suppressions.
- CR-1 is the one input-safety defect; CR-2 is an edge-case scope decision.

#### Error handling and logging

- Parse failures log via `Write-Debug` and return `$null`; file reads use `-ErrorAction SilentlyContinue` seams, so the hook never throws on unreadable epic state.
- Denial reasons name `epic-orchestrator-state.json` and the failed conjunct and reuse the existing reason codes.

---

## Test Quality Audit

The new suites are hermetic, use synthetic POSIX roots, and assert both decisions and reason text. Fail-before evidence exists for each batch under `evidence/regression-testing/fail-before-b1.md` through `fail-before-b6.md`.

### Reviewed test and QA artifacts

- `tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.Tests.ps1` — 21 resolver and seam rows; covers every fail-closed branch.
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1` — D2 allow/deny, conjunct denials, selector routing, path legs, standalone unchanged.
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` and the codex twin — eight new rows each; no row exercises `\"` (gap behind CR-1).
- `evidence/qa-gates/final-pester-coverage.md`, `final-coverage-delta.md` — coverage and no-regression proof.

### CI portability review

- No new or extended test references `origin/main` or any remote ref, a gitignored checkpoint file, a drive-rooted host path such as `C:/workspace`, or CRLF-sensitive content. Drive-letter strings in `CommandExemption` rows are pre-existing literal command text evaluated as strings.
- Changed files are committed and checked out LF (`attr/text=auto eol=lf`), so the SHA-256 pins and parity tests are stable on Linux runners.
- The `git diff origin/main` commands named in AC-16/AC-17 are reviewer verification commands, not test code; the coverage-delta script that uses `git diff -U0 origin/main` is an executor evidence tool, not a CI test.
- CR-4 is the only environment dependency, and it is inert in CI.

### Quality assessment prompts

- **Determinism:** module-scoped mocks with closures over local copies; no clock or network.
- **Isolation:** one decision per row.
- **Speed:** full Pester run under four minutes for 5058 tests.
- **Diagnostics:** `-Because` text and exact reason-string assertions.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection. |
| No unsafe subprocess or command construction | ✅ PASS | No process spawn added; no Python invoked from hooks (D5). |
| Input validation at boundaries | ❌ FAIL | CR-1 (escaped double quote admits redirection). |
| Error handling remains explicit | ✅ PASS | Fail-closed returns; no thrown errors escape the hooks. |
| Configuration / path handling is safe | ⚠️ PARTIAL | Checkpoint path composed from resolved root only (PASS); CR-2 selector precedence edge case. |

---

## Research Log

No external research was required. All findings derive from the branch diff, repository code, and feature evidence.

---

## Verdict

The design and most of the implementation are sound and conform to the approved decisions. The branch is not ready for PR: CR-1 must be fixed fail-closed across all four helper copies with regression rows in both command-exemption suites, and CR-2 should be addressed in the same remediation because it concerns the D2 rule this change introduces. CR-3 through CR-5 may be handled in the same remediation or tracked as follow-ups.
