# Code Review: PreToolUse hooks parse flat payload and always allow (#501)

**Review Date:** 2026-08-21
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-08-21-pretooluse-hooks-parse-flat-payload-and-always-allow-501/`
**Feature Folder Selection Rule:** Sole active folder whose suffix matches the issue number in the branch name (`bug/pretooluse-hooks-parse-flat-payload-501`); supplied by the caller and confirmed against the diff.
**Base Branch:** `main` (`origin/main @ fb30a9a58b8422e610a09b07361421e97367807a`, merge-base identical)
**Head Branch:** `bug/pretooluse-hooks-parse-flat-payload-501 @ 6a8d59f34441068c994e885abfee5fe7f0fc5bc5`
**Review Type:** Initial review

**Template source note:** the MCP template-resolution tool is unavailable in this session; the bundled asset `extensions/drm-copilot/resources/templates/policy_audit/code-review.yyyy-MM-ddTHH-mm.md` was used directly (documented assumption: byte-equivalent to the MCP-resolved asset).

---

## Executive Summary

This change repairs the entire `.claude/hooks` PreToolUse enforcement surface, which was fail-open for two stacked reasons: every hook read an environment-variable transport the harness never sets (so it saw an empty payload), and 23 of 24 hooks additionally parsed the flat root shape rather than the documented nested `tool_input` object. The fix introduces a single shared reader module (`.claude/lib/hook-payload/HookPayload.psm1`, 494 lines) that owns transport (stdin-first behind injectable seams, env fallback), envelope parsing (typed anomaly results, never silent null), and strict nested extraction (no flat-root fallback), and migrates all 24 registered hooks plus their mirrors and test suites. Envelope anomalies now emit a deny decision at exit 0, closing the third fail-open (exit 1 is non-blocking for PreToolUse).

The scope is 113 changed files (+8457/−2973 measured at review time over `fb30a9a5..6a8d59f3`). Evidence reviewed includes the full baseline and QA-gate artifact set, the executor's differential and live-probe records, and the reviewer's own re-execution of the AC-2/AC-3/AC-4 differentials, a full Pester re-run (3330 tests, 0 failures), an independent repository-denominator coverage regeneration, byte-level mirror comparison, and a merge-base worktree coverage measurement. Implementation quality is high: the module is well-documented, StrictMode-safe, seam-injected, and the migration is uniform. During this very review, three live hook denials were observed (merge gate, worktree-removal gate, dangerous-command validator), which is direct confirmation the surface is active.

**What changed:**
24 PreToolUse hooks migrated to `Import-Module .../HookPayload.psm1` + `Read-ClaudeHookRawPayload` + `Resolve-ClaudeHookToolInput`; eight hooks gained an `Invoke-<Name>EntryPoint` seam with a corrected write-then-exit tail; two hooks (`enforce-pr-author-skill.ps1`, `enforce-parallel-cohort-barrier.ps1`) shed helper functions into dot-sourced siblings to stay under the 500-line ceiling; `enforce-mermaid-validation.ps1`'s allow-on-unparseable header note was rewritten to distinguish envelope-level anomalies (now deny) from content-level tolerance (still allow); nine paths were added to the `CodeCoverage.Path` allow-list; every changed `.claude/**` file is mirrored byte-identically; the test tree was migrated wholesale to nested-envelope fixtures with per-hook deny tests, a 53-test module suite, and a 77-assertion source-scanning transport contract suite.

**Top 3 risks:**
1. The two batch-budget hooks lost their tail coverage in the suite migration (96.30% -> 81.93% per file, one changed line each regressed covered -> uncovered) — the only Blocking finding; narrow, with an in-branch precedent for the fix (entry-point seam).
2. Residual transport uncertainty is acknowledged and mitigated (stdin-first with env fallback); the live probes and this review's own observed denials confirm behavior under the installed harness, but a future harness envelope change would surface as fail-closed denials rather than silent allows — the correct failure direction.
3. The strict no-flat-fallback posture means any out-of-tree caller still sending the flat shape is now denied; this is by design and pinned by tests, but operators should expect anomaly-deny reasons rather than silent allows in mixed-version environments.

**PR readiness recommendation:** **Needs Revision** — one Blocking coverage-regression finding on two modified hooks; everything else is ready.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `.claude/hooks/enforce-powershell-batch-budget.ps1`, `.claude/hooks/enforce-python-batch-budget.ps1` | tail regions (lines 217-241 / 214-238); changed lines 235 / 232 | Per-file line coverage regressed 96.30% -> 81.93%; the migrated suites removed the in-process full-file execution (`& $script:ScriptPath`) that covered the tail, and did not add the entry-point seam other hooks received. One changed line per file (the tail `Read-ClaudeHookRawPayload` acquisition statement) went from covered at baseline to uncovered. | Apply the `Invoke-<Name>EntryPoint` seam pattern (as in `enforce-epic-merge-gate.ps1`) to both hooks; add seam-driven tail tests asserting the emitted decision and `[int]` return; re-measure per-file coverage >= 85%. | Violates the no-regression-on-changed-lines rule (`.claude/rules/general-unit-test.md`) and the feature-review modified-file coverage gate. | Reviewer merge-base worktree measurement (baseline 78/81 covered each) vs `artifacts/pester/powershell-coverage.review-repo-runsettings.xml` (68/83 each); `git diff -U0` changed-line intersection. |
| Major | `docs/features/active/.../evidence/qa-gates/2026-08-22T00-50-coverage-comparison.md` | "Changed-line coverage" section | Asserts "there is no regression on changed lines" based only on the nine newly registered denominator files; the two batch-budget hooks were already in the denominator and were not re-examined, so the assertion is falsified by measurement. | Correct the evidence record during remediation; future coverage comparisons should intersect changed lines with missed lines for every changed file, not only newly registered ones. | An audit-trail assertion that is stronger than its measurement misleads downstream gates. | This review's per-file comparison (policy audit section 5). |
| Minor | `artifacts/pester/powershell-coverage.repo-runsettings.xml` | n/a (absent file) | Evidence [P7-T3] cites this artifact as the supplementary run's numeric source, but it was not on disk at review time (`artifacts/` is ephemeral). | None required beyond remediation re-run; consider copying report-level counters into the evidence artifact (already done) — mitigated. | The claimed figures could not be inspected directly; the reviewer regenerated the run and reproduced every counter byte-exactly, so the record is confirmed accurate. | `artifacts/pester/powershell-coverage.review-repo-runsettings.xml` (LINE 275/6308 = 95.8226%; nine-file table identical). |
| Info | `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | `test_bundled_claude_payload_contains_all_repo_runtime_contracts` | The parity test walks the filesystem, so an untracked, gitignored `.claude/state/*.json` runtime file (recreated by live hook activity) fails it. Observed and cleared during this review by deleting the ephemeral file. | Optional hardening: exclude gitignored paths from the parity walk in a future change. | Environmental sensitivity, not a defect of this branch; the executor hit the same issue and documented the same cleanup. | Initial pytest FAIL then PASS after removing `.claude/state/python-batch-budget.default.json`. |
| Info | `artifacts/pr_context.summary.txt` | Close candidates | The generator lists `#AC-1`..`#AC-14`, `#ISO-8601`, `#SHA-256` as author-asserted autoclose issues (misparsed spec anchors). | Pre-existing generator behavior; out of scope for #501. PR author should assert only `#501` for autoclose. | Avoids accidental issue references in the PR body. | Summary artifact, "Close candidates" section. |

No other Blockers or Major findings.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The shared module cleanly separates the three concerns (transport, parse, extract) and returns typed results (`IsValid`/`Value`/`Anomaly`) so no caller ever branches on a silent `$null`. Anomaly reason strings are distinct per failure class, which makes a drifted contract diagnosable from the emitted decision alone.
- The stdin read is guarded by a redirect probe (`[Console]::IsInputRedirected`) with the guard in the function body rather than inside the seam default, so both polarities are testable by injection and a manual console invocation cannot hang — a subtle correctness point the plan revision history shows was reasoned through deliberately.
- The entry-point tail correction is right. The plan-mandated `exit (Invoke-<Name>EntryPoint)` would capture the function's pipeline output (the decision JSON) into the exit expression and emit nothing; the shipped tail re-emits all but the last pipeline element and exits on `[int]$entryPointResult[-1]`. Reviewer-verified empirically: all differential legs emit the deny JSON at exit 0. Applying the correction to the pre-existing `enforce-evidence-locations.ps1` tail fixes a latent defect of the same class.
- The `enforce-mermaid-validation.ps1` revision holds up in code, not just in the rewritten note: `Resolve-ClaudeHookToolInput` failure denies (envelope level), while missing `file_path`, out-of-scope paths, absent validation module, Edit fragments, and fence-free Markdown all still allow (content level). The distinction is exactly the one the original note conflated.
- Helper extraction (`enforce-pr-author-skill-helpers.ps1`, `enforce-parallel-cohort-barrier-helpers.ps1`) keeps both hosts well under the 500-line ceiling, and both helpers were registered in the coverage denominator rather than left unmeasured.

#### API and safety notes

- Exported surface is ten functions; the convenience composer `Resolve-ClaudeHookToolInput` also surfaces the envelope root for `enforce-epic-invocation-origin.ps1`'s `agent_type` read, avoiding a second parse.
- `Test-ClaudeHookObjectValue` correctly distinguishes JSON objects from scalars, arrays, and dictionaries under `ConvertFrom-Json` semantics; `tool_input` present-but-null and present-but-non-object are distinct anomalies.
- Property-level tolerance (`Get-ClaudeHookToolInputString` returning `''` for absence) preserves every hook's scope filter, verified live: a well-formed nested envelope with a benign command produces allow from the merge gate.

#### Error handling and logging

- The three fail-open paths are all closed: empty payload, unparseable JSON, and missing/null/non-object `tool_input` each produce an emitted deny at exit 0, never `throw`/exit 1. Reviewer-verified for `enforce-epic-merge-gate.ps1` on all three legs.
- `validate-bash.ps1`'s deliberate allow-on-empty and unparseable-raw-as-command-text exception is pinned by named tests (AC-5), and the rationale (denylist, not receipt gate) is documented in the spec.

---

## Test Quality Audit

Automated evidence is strong: the full tree passes (3330 tests, 0 failures, 9 skipped) in the executor's MCP run and in the reviewer's independent repository-runsettings run; the differential legs and the live probes are recorded with verbatim outputs and were re-executed by the reviewer with identical results. The one gap is the batch-budget tail coverage regression recorded in the Findings Table.

### Reviewed test and QA artifacts

- `tests/scripts/claude-lib/hook-payload/HookPayload.Tests.ps1` — 53 tests over transport precedence, redirect-guard polarities (both driven by injection), fallback order, throwing-stdin fallback, anomaly classification, CRLF/BOM, Edit-shaped and Agent-shaped envelopes; entirely seam-injected, no child processes, no temp files.
- `tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1` — the AC-8 structural guard; derives the 24-hook set from `.claude/settings.json` (with an explicit non-empty-derivation test that prevents vacuous passes), asserts per hook the module import, the reader call, and the absence of both retired env-var literals (composed from fragments so the suite's own text cannot satisfy the scan).
- `evidence/regression-testing/2026-08-22T00-05-payload-contract-falsifiability.md` — tamper probe: restoring the retired literal in one hook fails exactly that hook's assertion (76 pass / 1 fail), revert restores 77/0 with SHA-256 parity confirmed. The guard is falsifiable, not vacuous.
- `evidence/baseline/2026-08-21T22-11-merge-gate-differential-prefix.md` and `evidence/regression-testing/2026-08-22T00-10-merge-gate-differential-postfix.md` — fail-before/pass-after differentials with verbatim decisions.
- `evidence/qa-gates/2026-08-22T00-55-merge-gate-live-probe-postfix.md` — AC-10 live probe with the decisive `gh` GraphQL-error discriminator on the baseline side; corroborated by three independent denials observed during this review session.

### Quality assessment prompts

- **Determinism:** all payload acquisition is injected; no wall-clock, no network, no child processes in the new/migrated suites.
- **Isolation:** per-hook suites drive the decision functions directly; anomaly tests target the entry-point seam's `[int]` return.
- **Speed:** full tree ~134 s without coverage; ~4 min with coverage instrumentation.
- **Diagnostics:** contract-suite assertions carry `-Because` messages naming the offending hook path; anomaly deny reasons are distinct strings per failure class.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection; hooks read checkpoints and payload text only. |
| No unsafe subprocess or command construction | ✅ PASS | The module starts no subprocess; hooks retain their existing read-only seams. |
| Input validation at boundaries | ✅ PASS | Envelope validation is the change's whole subject; strict typed anomalies at the boundary. |
| Error handling remains explicit | ✅ PASS | No catch-and-continue without a typed result; fail-closed deny on anomalies. |
| Configuration / path handling is safe | ✅ PASS | `$PSScriptRoot`-relative module import; `Join-Path` throughout; no user-controlled path concatenation. |
| Fail-open eliminated (the vulnerability under review) | ✅ PASS | Reviewer-verified: empty/unparseable/flat payloads all deny at exit 0; live session denials observed. |

---

## Research Log

No external research was required for this review. The spec's envelope contract citation (official Claude Code hooks documentation, fetched 2026-08-21) was accepted as recorded in the research artifact `research/2026-08-21T17-45-pretooluse-hook-payload-envelope-501-research.md`; the review verified behavior empirically against the installed harness rather than re-fetching documentation.

---

## Verdict

The change is a correct, well-tested, and well-evidenced repair of a Blocker-severity fail-open, with the enforcement surface demonstrably live again under the real harness. It is not yet ready for the normal PR flow because one Blocking finding remains: the two batch-budget hooks regressed to 81.93% per-file line coverage with a changed-line regression, a direct side effect of removing child-process/full-file test executions without giving those two hooks the entry-point seam the rest of the migration used. The remediation is small, has an exact in-branch precedent, and does not touch the fix's behavior. After that cycle, this branch is ready.
