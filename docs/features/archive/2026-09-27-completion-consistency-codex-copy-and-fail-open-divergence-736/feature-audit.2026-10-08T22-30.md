# Feature Audit (issue #736)

- Branch: `bug/completion-consistency-codex-copy-and-fail-open-divergence-exec-736`
- Base: `origin/epic/enforcement-hook-precision-integration`
- Work mode: full-bug; AC source: `spec.md` (19 criteria)
- Reviewed: 2026-10-08

## Verification Basis

- Reviewer re-ran the in-scope Pester suites once: PASSED=284, FAILED=0, SKIPPED=0 (the `enforce-completion-consistency*.Tests.ps1` family including the `-codex`, `.Payload`, `-epic-scope`, and SHA suites, the four new Codex suites, `codex-pretooluse-transport.Tests.ps1`, and `enforcement-hooks-no-python-invocation.Tests.ps1`).
- Reviewer re-computed SHA-256 for all four mirror pairs and the helper pair, `wc -l` for every changed file, and per-file line coverage from a coverage-enabled run of the changed production files.
- Reviewer read the changed production code and the Claude default-reader suite and the diffs of the two modified Claude/Codex suites.
- Reviewer did not re-run: the full repository Pester suite, `codex-completion-consistency-hook.Tests.ps1`, `PreToolUseSchema.Contract.Tests.ps1`, the two Python bundle-parity tests, or the format and analyze routes. For these, executor evidence under `evidence/` was read and is cited.

## Acceptance Criteria Evaluation

| AC | Verdict | Evidence |
|---|---|---|
| AC-1 | PASS | Codex `Resolve-EditedCheckpointContent` declares mandatory `-CheckpointPath` and passes `$filePath`; the literal no longer appears as a reader argument (`p4-codex-literals.md`; diff read). New suite `enforce-completion-consistency-edit-target.Tests.ps1` (279 lines) passed. |
| AC-2 | PASS | Transport suite is 450 lines (was 492); the five rows pinning the relative literal were removed (diff read); suite passed in the reviewer run. |
| AC-3 | PASS | Both helper files define `Get-EditReplaceAllFlag` and `Invoke-SingleOccurrenceEdit` and share SHA-256 `94b891d2...` (reviewer computed). EditSemantics suites on both surfaces passed. |
| AC-4 | PASS | Helper logic read: string `'false'` handled without `[bool]` cast, non-overlapping count via second `IndexOf` after first match, ordinal `Replace`/`Substring` (no regex), CRLF normalized to LF. Corresponding rows passed (EditSemantics suites). |
| AC-5 | PASS | Decision-level rows (ambiguous deny, replace-all evaluated on all-replaced content, single-occurrence evaluated on spliced content, differing-result row D7) exist in `EditSemantics` (Claude) and `-edit-semantics` (Codex) and passed. |
| AC-6 | PASS | `FailClosed` suites on both surfaces passed; code path read: each cause (`checkpoint-missing`, `checkpoint-empty`, `checkpoint-unreadable`, `no-old_string`, `write-content-empty`) returns a deny with the `COMPLETION_CONSISTENCY_BLOCKED:` token and `replaced through an unresolved patch`. |
| AC-7 | PASS | Gate order read: empty `file_path` and non-checkpoint target return allow before the reader is referenced. FailClosed rows F8-F10 (throwing reader never invoked) passed. |
| AC-8 | PASS | Reader exceptions are caught in `Resolve-EditedCheckpointContent` and converted to `checkpoint-unreadable`; the Claude entrypoint only calls the decision function. Decision-level proof is permitted by the AC wording (rows F3a/F3b passed). |
| AC-9 | PASS | `enforce-completion-consistency.Tests.ps1` is 491 lines; relative default-reader row replaced by an injected-reader row; rows at the former 374-401 flipped to deny (diff read); `EditTarget` is 231 lines. All passed. |
| AC-10 | PASS | Claude and Codex default-reader suites resolve the four fixtures from `$PSScriptRoot`; rows assert deny naming `ci_gate`, allow for non-completion edit, ambiguous deny without and allow with `replace_all`, `checkpoint-empty`, `checkpoint-missing`, plus a precondition `It`. Claude suite read in full; both suites passed. |
| AC-11 | PASS | Grep over the new suites found none of `New-TemporaryFile`, `$env:TEMP`, `TestDrive`, `Set-Location`, `Push-Location`, `Start-Sleep`; remaining `orchestrator-state.json` strings are injected-reader arguments or fixture paths. Executor ran the suites from two directories (`p4-two-directories.md`, PASSED=240 each). The reviewer ran from the repo root only. |
| AC-12 | PASS | Deny reason keeps both substrings; transport suite rows at the existing markers passed unchanged. |
| AC-13 | PASS | Codex header rewritten (diff read); no remaining statement that Edit calls are allowed (`grep` found none). |
| AC-14 | PASS (CI pending) | Four mirrors byte-identical to canonical (reviewer SHA-256). `enforce-completion-consistency-codex.Tests.ps1` SHA suite passed. The two Python bundle-parity tests are recorded as passing locally (`p5-pytest-*-parity.md`); reviewer did not re-run them. CI confirmation is an orchestrator step, as the spec notes a known local false failure (#510). |
| AC-15 | PASS | No `python`/`.py` text in changed hooks; `enforcement-hooks-no-python-invocation.Tests.ps1` passed. |
| AC-16 | PASS | All changed files at or under 500 lines (largest: Codex hook 486, Claude test 491). |
| AC-17 | PASS | Per-file line coverage: Claude hook 93.62%, Claude helpers 97.01%, Codex hook 100% (executor full run; 93.92% in the reviewer's subset run), Codex helpers 88.06%; all baselines met or improved; changed lines fully covered (`p5-changed-lines.md`). |
| AC-18 | PASS (baseline caveat) | Format and analyze clean (`p5-format.md`, `p5-analyze.md`, 0 findings, 14 files). Test route exit code 2 is attributable solely to two baseline failures (`enforce-pr-author-skill.Tests.ps1`, `codex-pretooluse-integration.Tests.ps1`) recorded in the Phase 0 baseline (Passed 3413, Failed 2) and outside the eight listed suites. The listed suites pass per `p5-junit.md`; the reviewer re-ran six of the eight with zero failures. |
| AC-19 | PASS | `evidence/other/follow-ups.md` records the three follow-ups (patch-source read, invalid-JSON divergence, `enforce-checkpoint-monotonic.ps1`). The AC permits a follow-up artifact in place of issues. |

## Acceptance Criteria Status

- Source: `docs/features/active/2026-09-27-completion-consistency-codex-copy-and-fail-open-divergence-736/spec.md`
- Total AC items: 19
- Checked off (delivered): 19
- Remaining (unchecked): 0
- Items remaining: none
- Newly checked off by this review: none (all 19 were already checked by the executor; the reviewer concurs with each).

## Baseline Comparison

- Defect 1 (Codex relative literal): removed.
- Defect 2 (`String.Replace` ignoring `replace_all`): replaced on both surfaces by one-occurrence semantics.
- Defect 3 (Claude fail-open versus Codex fail-closed): both surfaces now deny with identical cause identifiers; Claude no longer lets a reader throw escape.
- Defect 4 (cwd-dependent default-reader test): replaced with injected-reader row plus hermetic fixture suites.
- Out-of-scope files (`codex-pretooluse-file-mapping.ps1`, `enforce-checkpoint-monotonic.ps1`, `HookPayload.psm1`) are not in the branch diff (`p4-out-of-scope-untouched.md`; diff file list confirmed).

## Executor Notes Assessment

- Two baseline Pester failures: confirmed present in the Phase 0 baseline and outside the changed files; not a regression from this branch.
- Plan branch-name deviation (`-exec-` suffix): no effect on deliverables.

## Gaps

- Pending CI confirmation of the two Python bundle-parity tests (AC-14) and a full-suite CI run.
- Repo-wide PowerShell line coverage of 56.70% (artifact total) is below policy; it is pre-existing and recorded in the policy audit and remediation inputs. It is not an acceptance criterion of this feature.

## Counts

- FAIL: 0
- Blocking PARTIAL: 0
- Non-blocking caveats: 2 (AC-14 CI confirmation pending; AC-18 baseline failures)
