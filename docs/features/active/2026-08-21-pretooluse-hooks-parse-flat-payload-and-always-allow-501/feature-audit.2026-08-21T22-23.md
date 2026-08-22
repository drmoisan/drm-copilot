# Feature Audit: PreToolUse hooks parse flat payload and always allow (#501)

**Audit Date:** 2026-08-21
**Feature Folder:** `docs/features/active/2026-08-21-pretooluse-hooks-parse-flat-payload-and-always-allow-501/`
**Base Branch:** `main`
**Head Branch:** `bug/pretooluse-hooks-parse-flat-payload-501`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

**Template source note:** the MCP template-resolution tool is unavailable in this session; the bundled asset `extensions/drm-copilot/resources/templates/policy_audit/feature-audit.yyyy-MM-ddTHH-mm.md` was used directly (documented assumption: byte-equivalent to the MCP-resolved asset).

---

## Scope and Baseline

- **Base branch:** `main` (`origin/main @ fb30a9a58b8422e610a09b07361421e97367807a`)
- **Head branch/commit:** `bug/pretooluse-hooks-parse-flat-payload-501` (`6a8d59f34441068c994e885abfee5fe7f0fc5bc5`)
- **Merge base:** `fb30a9a58b8422e610a09b07361421e97367807a` (identical to base head; no divergence)
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (freshly refreshed; head SHA matches branch head)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-08-21-pretooluse-hooks-parse-flat-payload-and-always-allow-501/evidence/{baseline,qa-gates,regression-testing}/`
  - Additional evidence: reviewer re-execution — live hook differentials (AC-2/3/4), full Pester re-run (3330 tests, 0 failures), independent repository-denominator coverage regeneration, byte-level mirror comparison, merge-base worktree coverage measurement
- **Feature folder used:** `docs/features/active/2026-08-21-pretooluse-hooks-parse-flat-payload-and-always-allow-501/`
- **Requirements source:** `spec.md`, `## Acceptance Criteria`, AC-1 through AC-14
- **Work mode resolution note:** `issue.md` carries the explicit marker `- Work Mode: full-bug`; under `full-bug` the AC source is `spec.md` only. `user-story.md` is legitimately absent for this mode.
- **Scope note:** full feature-vs-base audit over the entire branch diff (113 files, +8457/−2973 measured at review time). No caller scope narrowing was attempted or accepted.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-08-21-pretooluse-hooks-parse-flat-payload-and-always-allow-501/spec.md` — only source (work mode `full-bug`)

### Acceptance criteria

All 14 criteria are checkbox items under `## Acceptance Criteria` in `spec.md`, already marked `[x]` by the executor. Abbreviated labels (full text preserved in the source file):

1. **AC-1 (transport, unit)** — `HookPayload.Tests.ps1` exists and passes with named stdin-precedence, fallback-order, and throwing-stdin tests.
2. **AC-2 (transport, end-to-end differential)** — nested envelope on stdin, env unset, no satisfiable allow-branch: emitted deny beginning `EPIC_MERGE_GATE_BLOCKED:`.
3. **AC-3 (shape, isolated from transport)** — nested envelope via `CLAUDE_TOOL_INPUT`, empty stdin: same deny.
4. **AC-4 (fail-closed anomalies)** — empty payload, unparseable JSON, and missing-`tool_input` (incl. flat root) each emit deny at exit 0 (or 2), never exit 1.
5. **AC-5 (deliberate exception pinned)** — `validate-bash.ps1` retains allow-on-empty and unparseable-raw-as-command behavior via named tests.
6. **AC-6 (property-level tolerance preserved)** — well-formed nested envelope lacking the hook's gated property still allows.
7. **AC-7 (per-hook nested deny test)** — each of the 24 PreToolUse hooks has at least one nested-envelope deny test; full hook tree passes with migrated fixtures.
8. **AC-8 (structural regression guard)** — source-scanning contract suite derived from `.claude/settings.json`; falsifiable by construction.
9. **AC-9 (mirror parity)** — `test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes with byte-identical mirror copies.
10. **AC-10 (end-to-end, tied to the baseline probe)** — live in-session `gh pr merge 999999 --merge` is denied; command does not reach the `gh` CLI.
11. **AC-11 (coverage)** — PoshQC Pester line coverage >= 85% with the module and every modified hook in the denominator; no new production-path coverage exclusion.
12. **AC-12 (file-size ceiling)** — no new or modified production file exceeds 500 lines.
13. **AC-13 (scope boundaries held)** — no `.codex/hooks/` path and none of the eight SubagentStop validators in the diff.
14. **AC-14 (toolchain clean pass)** — format, analyze, and test all pass in a single sequential pass with no file modified by format.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-1 transport unit suite | PASS | Suite exists (487 lines, 53 tests); passes in executor MCP run and in the reviewer's full re-run; named tests confirmed in [P7-T3] evidence | reviewer full `Invoke-Pester` run (0 failures); `evidence/qa-gates/2026-08-22T00-40-poshqc-test-final.md` | Stdin injected through scriptblock seams; both redirect-guard polarities tested |
| 2 | AC-2 stdin nested differential | PASS | Reviewer re-executed live: emitted deny JSON, reason begins `EPIC_MERGE_GATE_BLOCKED:`, exit 0 | `printf '<nested envelope>' \| pwsh -NoProfile -File .claude/hooks/enforce-epic-merge-gate.ps1` with env unset, `epic_mode:false`, `step9_status:pending`, no epic/parallel checkpoints | Matches `evidence/regression-testing/2026-08-22T00-10-merge-gate-differential-postfix.md`; pre-fix baseline recorded allow |
| 3 | AC-3 env nested, empty stdin | PASS | Reviewer re-executed live: identical deny, exit 0 | `CLAUDE_TOOL_INPUT='<nested envelope>'` with closed empty stdin | Discriminates shape fix from transport fix as specified |
| 4 | AC-4 fail-closed anomalies | PASS | Reviewer re-executed all three legs live: (a) empty on all transports -> deny "empty payload" exit 0; (b) unparseable -> deny "not parseable JSON" exit 0; (c) flat root -> deny "no tool_input key" exit 0. Never exit 1 | three `pwsh -NoProfile -File` invocations, exit codes captured | Named Pester anomaly tests additionally assert the entry-point `[int]` return per [P7-T3] |
| 5 | AC-5 validate-bash exception | PASS | Named tests present: "returns $null (allow) for an empty payload rather than an envelope-anomaly deny", "returns $null (allow) when every transport is empty", "denies when unparseable raw input carries a blocked pattern", "returns $null (allow) when the unparseable raw input is safe" | `grep` of `tests/scripts/claude-hooks/validate-bash.Tests.ps1`; suite passes in full run | Exception is pinned exactly as specified |
| 6 | AC-6 property-level tolerance | PASS | Named test at `enforce-orchestration-preimplementation-gate.Tests.ps1:192`: "allows a well-formed nested Bash envelope whose tool_input carries no file_path (AC-6)"; reviewer additionally observed live allow for a benign nested Bash envelope on the merge gate | grep + full-run pass; live probe | Scope filters survive the strict reader |
| 7 | AC-7 per-hook nested deny tests | PASS | Reviewer scan: all 24 registered hooks (derived from `.claude/settings.json`) have sibling suites containing nested-envelope deny assertions; full hook tree passes | settings-derived scan script; reviewer full Pester run (3330/0) | 24 of 24 covered; several hooks have dedicated `.Payload.Tests.ps1` siblings |
| 8 | AC-8 structural regression guard | PASS | `PreToolUsePayload.Contract.Tests.ps1` derives the hook set from settings (with a non-empty-derivation assertion preventing vacuity), asserts import + reader call + literal absence per hook; tamper probe shows exactly one assertion failing when a literal is restored (76/1), reverting restores 77/0 | suite in full run; `evidence/regression-testing/2026-08-22T00-05-payload-contract-falsifiability.md` | Falsifiable, specific, and self-extending to newly registered hooks |
| 9 | AC-9 mirror parity | PASS | Reviewer `cmp` of every changed `.claude/**` file against its bundle mirror: zero divergent, zero missing; pytest gate passes on a clean tree | `cmp` loop; `poetry run pytest ... -k test_bundled_claude_payload_contains_all_repo_runtime_contracts` | Initial pytest failure was environmental (untracked, gitignored `.claude/state/` runtime file recreated by live hook activity after the executor run); removed, pass |
| 10 | AC-10 live end-to-end probe | PASS | Executor probe evidence with the decisive `gh` GraphQL-error discriminator on the baseline side; corroborated three times during this review: the merge gate denied the reviewer's own probe command text, the worktree-removal gate denied `git worktree remove`, and the dangerous-command validator blocked recursive deletes | `evidence/qa-gates/2026-08-22T00-55-merge-gate-live-probe-postfix.md` vs `evidence/baseline/2026-08-21T21-58-merge-gate-inert-in-session-probe.md` | The enforcement surface is demonstrably live in this session |
| 11 | AC-11 coverage | PASS (as written) | Repo-wide line coverage 95.8226% >= 85% on the repository denominator that includes `HookPayload.psm1` and all 24 modified hooks (reviewer-regenerated, byte-exact with executor figures); runsettings diff is purely additive (nine paths added, zero excludes) | reviewer `Invoke-Pester` with repo runsettings + JaCoCo parse; `git diff` of runsettings | AC-11's own clauses all hold. A distinct policy-level Blocking finding exists outside AC-11's text: per-file regression on the two batch-budget hooks (see Summary); AC-11 does not require per-file thresholds, so the criterion itself is PASS |
| 12 | AC-12 file-size ceiling | PASS | Reviewer scan of every changed `.ps1/.psm1/.psd1` in the diff: zero files over 500 lines (max production 494, max test 493) | `wc -l` loop over `git diff --name-only` | Executor evidence `2026-08-22T00-15-file-size-ceiling.md` concurs |
| 13 | AC-13 scope boundaries | PASS | `git diff --name-status fb30a9a5..HEAD` contains no `.codex/hooks/` path and none of the eight SubagentStop validators | `git diff --name-only main...HEAD \| grep` | The changed `validate-bash.ps1` is a PreToolUse hook, not a SubagentStop validator |
| 14 | AC-14 toolchain clean pass | PASS (evidence-verified) | Executor artifacts record format (exit 0, zero files changed), analyze (exit 0), test (exit 0, 3330/0) in a single sequential pass at 00-35/00-36/00-40; reviewer corroborated the test stage independently (3330/0) and observed a clean working tree | `evidence/qa-gates/2026-08-22T00-35..00-40` artifacts; reviewer full Pester run | Format and analyze stages verified from evidence; test stage independently re-executed |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**
- **PASS:** 14 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. All 14 acceptance criteria pass as written. The NEEDS REVISION verdict comes from a policy-level Blocking finding outside the AC text: `enforce-powershell-batch-budget.ps1` and `enforce-python-batch-budget.ps1` regressed from 96.30% to 81.93% per-file line coverage, including one changed line each (the tail payload-acquisition statement) going from covered to uncovered — a violation of the no-regression-on-changed-lines rule and the feature-review modified-file coverage gate. See `policy-audit.2026-08-21T22-23.md` section 5 and `remediation-inputs.2026-08-21T22-23.md`.
2. (Documentation) The coverage-comparison evidence asserts "no regression on changed lines" without having measured the two batch-budget hooks; correct the record during remediation.

**Recommended follow-up verification steps:**

1. After remediation, re-run the repository-runsettings coverage measurement and confirm both batch-budget hooks >= 85% per-file with the changed tail lines covered.
2. Re-run `PreToolUsePayload.Contract.Tests.ps1` and the two batch-budget suites to confirm the entry-point seam additions keep the transport contract and the AC-4 anomaly posture intact.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if not already checked.
- All 14 criteria in `spec.md` were already checked `[x]` by the executor at completion. This audit independently evaluated every criterion as PASS, so the existing check-off state is correct and no source-file change was made by the reviewer.

### AC Status Summary

- Source: `docs/features/active/2026-08-21-pretooluse-hooks-parse-flat-payload-and-always-allow-501/spec.md`
- Total AC items: 14
- Checked off (delivered): 14
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 14 | 14 | 0 | Checkbox-backed; pre-checked by executor, independently confirmed by this audit |

No source-file checkbox change was made: every PASS criterion was already checked, and no criterion required unchecking.
