# Code Review: Epic Merge Gate Standalone Authorization Record (#670)

---

**Review Date:** 2026-09-17
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-09-13-epic-merge-gate-authorization-record-670`
**Feature Folder Selection Rule:** The only active feature folder changed on the branch; its `-670` suffix matches the issue number in the branch name.
**Base Branch:** `origin/epic/worktree-scoped-state-resolution-integration` (`79fd5a95c00cd99238b69a3195788206ae96f4cd`; epic child, so the PR base is the integration branch)
**Head Branch:** `feature/2026-09-13-epic-merge-gate-authorization-record-670` (`332ab835133af49092d8155c40ea0152560f5557`)
**Review Type:** Initial review

---

## Executive Summary

The branch implements the RULING 1 fix for issue #670. The epic merge gate gains a fourth allow condition, evaluated last: a standalone `gh pr merge <N> --merge` is permitted only when one of the orchestrator checkpoints the gate already reads carries a `standalone_merge_authorizations` record. That record must name PR `<N>`, pass eight ordered field checks, and carry the live envelope's `session_id`. A blanket flag is rejected with its own reason code. The Claude hook was at the 500-line cap, so the logic lives in a new dot-sourced helpers file. The Codex hook receives an in-place counterpart with byte-identical reason codes and no parallel path. The production delta is 443 new lines, 33 added and 37 removed in the parent hook, and 193 added in the Codex hook. The branch also adds three Pester suites (80 cases), coverage and manifest registration, documentation, and five byte-identical bundled mirrors.

Evidence reviewed: the full base-anchored diff, all production and test source, the PR-context summary and appendix, the 40 executor evidence files, the coverage and JUnit artifacts (parsed directly), and this review's own runs. Those runs were: check-only format, PSScriptAnalyzer, 17 targeted Pester suites (434 passed, 0 failed), SHA-256 mirror pairs, line counts, a test-purity decision, and a clean `git archive` export of HEAD in which the environment-dependent failures do not reproduce (227/227 Pester, 17/17 pytest). The implementation is small, fail-closed, and consistent with the spec's structural argument: different key, evaluated last, and extractor untouched.

**What changed:**
- `.claude/hooks/enforce-epic-merge-gate-authorization.ps1` (new): `Get-StandaloneMergeAuthorizationRecord`, `Test-StandaloneMergeAuthorizationRecord`, `Get-StandaloneAuthorizationBlockState`, `Test-StandaloneCheckpointAllowsMerge`, and small type helpers. It also holds four reason-code constants declared once each, and the two envelope factories moved unchanged from the parent.
- `.claude/hooks/enforce-epic-merge-gate.ps1`: header rewritten from three conditions to four, with the squash scope statement; `.NOTES` disclosure; one dot-source line; a branch-4 block (lines 418-427) that runs only when the extractor returned a PR number; factories removed. `Get-EpicMergeGateCommandPrNumber` (146-190), the checkpoint path assignments (63-65), and the scope filter are unchanged.
- `.codex/hooks/enforce-epic-merge-gate.ps1`: branch block at 166-182 and helper functions at 193-358, reading only the child and epic checkpoints.
- Registration and documentation: `pester.runsettings.psd1` (and its bundled copy), `core.json`, `.claude/rules/orchestrator-state.md`, and `.claude/skills/parallel-orchestrate/SKILL.md`, each with a matching mirror.

**Top 3 risks:**
1. Same-session forgery remains possible: any actor in the authorizing session can write a record. This is the accepted, disclosed trade (FU-1), stated in the hook `.NOTES`, the helpers header, and the rule file.
2. The design assumes the live Bash `PreToolUse` envelope carries `session_id`. If it does not, every standalone merge denies with `..._MALFORMED` naming `session_id`. The failure is closed, not a false allow, but it would stall the use case the feature exists for. The first real use should be watched, as the spec's rollout notes state.
3. Codex operators are directed to `.claude/rules/orchestrator-state.md`, which the Codex bundle does not ship, and no Codex-side document describes the writer procedure (Minor finding below).

**PR readiness recommendation:** **Go**. There are no Blocker or Major findings. Remaining items are Minor or informational, and the one open acceptance criterion is a PR-description hand-off.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.codex/hooks/enforce-epic-merge-gate.ps1` | line 356 | The Codex deny guidance says the record format is "described in .claude/rules/orchestrator-state.md". The Codex bundle (`extensions/drm-copilot/resources/codex-and-agents-customizations/`) contains no `orchestrator-state.md`, and no `.agents`/`.codex` document describes the writer procedure. | In a follow-up, point the Codex message at a document the Codex payload ships, or add a Codex-side writer note. Do not change it in this branch unless a remediation cycle is opened for another reason. | A Codex-only push-down target would receive guidance that names a file it may not have. The deny remains correct and fail-closed, so the impact is operator friction, not a safety gap. | `Glob extensions/drm-copilot/resources/codex-and-agents-customizations/**/orchestrator-state*` returned no files; `Grep '\.claude/rules' .codex/hooks` matched only line 356. |
| Minor | `docs/features/active/2026-09-13-epic-merge-gate-authorization-record-670/evidence/qa-gates/p8-pester-coverage.2026-09-13T20-46.md` | `Timestamp:` and `LastWriteTime` lines; `post-change-coverage` "Remaining uncovered lines" | Evidence timestamps do not match file system times. The artifact records loop pass 2 at `08-52`, but the coverage and JUnit files it cites were written at 08:44:42 and 08:45:35, and `p8-format` records pass 1 at `08-45` while the lint-fixed sources carry mtimes of 08:39. `post-change-coverage` names Codex uncovered line 372; the current artifact reports 373 (shifted by the added `[OutputType]` line). | Record wall-clock times from the command that produced each artifact, and recompute line citations after late edits. | Coverage figures are correct: sources were last modified at 08:39:12, before the coverage run, and this review's parse matches 100.00 / 96.67 / 99.34. Inaccurate labels still weaken audit traceability. | `ls --time-style=full-iso` on sources and `artifacts/pester/*`; coverage XML parse shows Codex missed line `373`. |
| Nit | `.claude/hooks/enforce-epic-merge-gate.ps1` | line 7 | The header still says the hook "Regex-matches gh pr merge", but the scope filter has been structural since issue #545. The line sits beside the rewritten header text. | Reword to "structurally matches" in a later documentation pass. | This text predates the branch; the surrounding rewrite left it in place. | File header lines 5-9; `Invoke-EpicMergeGateDecision` lines 377-399. |
| Nit | `.claude/rules/orchestrator-state.md` | new section, disclosure paragraph and last Enforcement bullet | Sentences are broken mid-phrase ("and is / not a cryptographic ..."; "validator / does not currently validate standalone_merge_authorizations / entries"), apparently so literal single-line greps match. | None required; the Markdown renders as continuous text. | Readability of the raw source only. | `git diff` of `.claude/rules/orchestrator-state.md`. |
| Info | `.claude/hooks/enforce-epic-merge-gate-authorization.ps1` | lines 331-370, 412-414 | A non-PR-specific block in any checkpoint, or a single non-PR-specific entry in an otherwise valid array, makes the whole standalone path deny with `..._NOT_PR_SPECIFIC`, even when a valid record exists elsewhere. The Codex side behaves the same way. | No change. This is the stricter reading of the spec's "entry is not an object" rule; it is documented as invariant 1 in the rule file and pinned by the "a blanket flag beside a valid record" case. | Fail-closed and visible in the transcript, which is the purpose of the distinct code. | `enforce-epic-merge-gate.AuthorizationFields.Tests.ps1:169`; `.claude/rules/orchestrator-state.md` invariant 1. |
| Info | `.claude/hooks/enforce-epic-merge-gate-authorization.ps1` | lines 299-304 | The `pr_url` check is a suffix match (`/pull/<pr_number>`), so a URL for another repository with the same number is accepted. | No change; this matches the spec, which targets copy-paste mismatches between `pr_url` and `pr_number`. | The `session_id` binding, not the URL, is the anti-reuse control. | `spec.md` field contract, `pr_url` row. |
| Info | `.codex/hooks/enforce-epic-merge-gate.ps1` | line 350 | The Codex `..._MALFORMED` message names the field but omits the rule text that the Claude message includes. | No change; the spec requires identical tokens and a message naming the field, and both are met. | Cosmetic parity only. | Codex suite row assertions `'<Field>'`; parity test `spells the four reason codes identically`. |
| Info | `.claude/skills/parallel-orchestrate/SKILL.md` | Merge-gate authorization paragraph | The writer procedure is documented only in the parallel-orchestrate skill and the rule file. The gate also reads the per-feature and epic checkpoints, but the epic and per-feature orchestration skills do not describe writing the record. | No change in this branch; the spec bounds the writer surface to these two authored surfaces. Consider a follow-up if epic runs need standalone merges. | Matches the spec's "writer surface is bounded" criterion. | `spec.md` Documentation and disclosure criteria; `git diff --name-only` shows no other skill or agent edits. |
| Info | `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` | lines 45-46 | This bundled copy is not listed in the spec's in-scope table but was updated alongside the repository file. | No change. | Required by `test_poshqc_bundled_parity.py`; SHA-256 matches the source. | Mirror hash `0302FB41A7C3...` on both paths. |
| Info | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`; `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` | lines 145 and 165 | These pre-existing suites, not changed by this branch, read the live gitignored `artifacts/orchestration/orchestrator-state.json` and fail whenever an epic-child checkpoint is present. | File a follow-up issue to mock or isolate those reads. | Violates the determinism rule and repeatedly produces non-zero whole-tree runs in orchestrated worktrees. | Reproduced in the worktree (2 failed); 43/43 and 6/6 in the clean export. |

No Blocker or Major findings.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The structural safety argument holds in code. Branch 4 runs after the three existing predicates return (parent lines 403-416), reads a key none of them read, and consumes the unchanged extractor's value. It is guarded by `if ($null -ne $commandPrNumber)`, so a bare merge keeps the exact line-429 text.
- Every denial keeps the existing `EPIC_MERGE_GATE_BLOCKED` token first, so existing token-based assertions and transcript greps keep working.
- Type discipline follows the spec: `Test-StandalonePositiveJsonInteger` accepts only `[int]`/`[long]`, so `"691"`, `691.5`, and `[691]` are rejected. The unary comma in `Get-StandaloneRecordField` preserves one-element arrays, with a comment explaining why.
- Field checks run in the declared order, and the first failure wins, which the tests pin.
- `session_id` comparison is ordinal (case-sensitive, tested), and a blank envelope value fails closed.
- No new I/O: the parsed checkpoints are passed in, and `session_id` comes from `$payload.Envelope` through the exported `Get-ClaudeHookEnvelopeValue`. The helpers file contains no process, clock, disk, or Python usage.
- Reason-code literals appear exactly once per file and are verified equal across runtimes by a source-text test.
- The extraction is behaviour-neutral for existing suites: the moved factories are unchanged, and all 88 cases in the four existing merge-gate suites pass unedited.

#### API and safety notes

- Every new function has `[CmdletBinding()]` and `[OutputType()]` and uses approved verbs. The analyzer findings from pass 1 were fixed by renaming, with no suppressions.
- `[int] $CommandPrNumber` is mandatory. A command naming PR `0` enters branch 4 and can never match, because records require `pr_number > 0`, so it denies.
- No `ShouldProcess` is needed; nothing mutates state.

#### Error handling and logging

- The Claude path stays non-throwing and expresses every outcome through the decision envelope (exit 0), preserving the PreToolUse contract that exit 1 is non-blocking.
- The Codex path keeps its exit-2 throw channel for payload anomalies. Two tests re-pin this.
- Deny messages name the failing field and state how to take the authorized path. The Claude message cites the rule-file section by name, and that section exists: `## Standalone-Merge-Authorization Scope and Backward Compatibility`.

---

## Test Quality Audit

The three new suites cover every spec matrix row assigned to them, plus additional edge cases: case-only session mismatch, blank record session, non-string `authorized_at`, and a parseable non-ISO date. The Claude decision suite follows the four-property false-allow idiom for the 501/777 discriminator: only the epic seam is populated, the unauthorized number is the operand, and a paired positive is present. The branch-order case mocks `Test-StandaloneCheckpointAllowsMerge` to throw and asserts zero invocations, which is a stronger proof than asserting the allow alone.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1`: 15 decision-level cases, including three checkpoint placements, the discriminator, the exact line-429 text, branch order, and the six matcher spellings.
- `tests/scripts/claude-hooks/enforce-epic-merge-gate.AuthorizationFields.Tests.ps1`: 37 predicate-level cases (13 non-PR-specific spellings, 8 field failures, order, session binding, checkpoint verdicts). It dot-sources only the helpers file, which proves the file loads standalone.
- `tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1`: 28 cases, including `$null` allow representation, throw channel, shape counterparts, and cross-runtime token parity.
- `evidence/regression-testing/fail-before-*` and `pass-after-*`: fail-first then pass for both runtimes.
- `evidence/qa-gates/coverage-comparison.2026-09-13T20-46.md`: 100.00% of changed executable lines (187/187).
- `evidence/qa-gates/review-clean-state-verification.2026-09-17T09-12.md`: this review's clean-export proof that the whole-tree failures are environmental.

### Quality assessment prompts

- **Determinism:** fixed literals; no clock, process, or disk access; checkpoint seams mocked or passed as parameters. The purity decision returned no denial.
- **Isolation:** one input combination per row; predicates tested separately from the decision router.
- **Speed:** the 80 cases add a negligible amount to the 434-case targeted run.
- **Diagnostics:** templated row names; `-BeExactly` on codes and the full fall-through text; field names asserted in messages.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Inspected all added lines; fixtures use placeholder session ids. |
| No unsafe subprocess or command construction | PASS | No process start in either hook's new code; `enforcement-hooks-no-python-invocation.Tests.ps1` 27/27. |
| Input validation at boundaries | PASS | Type-strict JSON checks, trimmed-length checks, invariant-culture date parse, ordinal session comparison. |
| Error handling remains explicit | PASS | Fail-closed on a blank session, non-PR-specific block, or malformed checkpoint; existing deny sites unchanged. |
| Configuration / path handling is safe | PASS | Checkpoint path assignments and Codex root anchoring are unchanged; `branch_name` is never compared with the working directory. |
| Gate cannot be widened by the new branch | PASS | Evaluated last; distinct key; extractor diff has no hunk inside lines 146-190; branch-3-first case asserts branch 4 is not invoked. |
| Closed anti-patterns absent | PASS | No `items[]` writes anywhere in the diff; `--squash` remains out of trigger scope (existing line-27 test and new paired case green). |

---

## Research Log

No external research was required. All conclusions rest on repository sources, the spec's research record, and commands run in this session.

---

## Verdict

The change is ready for the normal PR flow. The implementation matches the spec's design and invariants, keeps both runtimes fail-closed, and leaves the three existing branches and the PR-number matcher unchanged. Coverage is 100% on changed executable lines, and all toolchain stages are clean on the committed tree. The two Minor findings (Codex guidance path; evidence timestamp and line labels) do not affect behaviour and can be addressed in follow-up work.

Before merge, the PR author must include the FU-1 through FU-4 deferral paragraph from `evidence/issue-updates/ac-status-and-followups.2026-09-13T20-46.md` in the PR description. CI on the PR head should also be confirmed green, dispatching it manually if the epic-child PR does not trigger it.
