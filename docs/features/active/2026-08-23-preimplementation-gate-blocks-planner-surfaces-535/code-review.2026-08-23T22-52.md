# Code Review: Preimplementation Gate Blocks Planner Surfaces (#535)

**Review Date:** 2026-08-23
**Reviewer:** feature-review agent (Claude)
**Feature Folder:** `docs/features/active/2026-08-23-preimplementation-gate-blocks-planner-surfaces-535`
**Base Branch:** `main` (merge-base `e96e32e01662035faacec460a12441b253b6f3b2`)
**Head Branch:** `bug/preimplementation-gate-blocks-planner-surfaces-535` (`d6aece5b8ee10f3f791491311b3d8fa5b9c82840`)
**Review Type:** Initial review

---

## Executive Summary

This branch delivers a narrow, well-evidenced fix to the PreToolUse preimplementation gate. The code delta is six PowerShell files: four copies of one hook (two canonical, two byte-identical bundle mirrors) and two extended test suites; the remainder of the diff is feature documentation and evidence. Two enumerated exemptions are layered over unchanged deny logic: a seven-literal checkpoint-path membership check replacing a single-literal equality, and a three-conjunct preparation-mode delegation predicate evaluated before the pre-existing whole-payload regex. The reviewer re-derived the diff from the merge base, re-hashed all four copies, re-parsed the coverage XML, and re-checked the kickoff marker literals against the two SKILL.md sources.

**What changed:**
`Test-ImplementationPath` now consults `$script:CheckpointPaths` (`-contains` over seven repo-relative literals) after the caller's existing separator normalization; the readiness read and block message keep the distinct `$script:CheckpointPath` scalar. `Test-ImplementationDelegation` first calls the new `Test-PreparationModeDelegation` (subagent must be exactly `orchestrator`; the field-scoped `prompt` must contain both `Preparation mode: true.` and `route_id: preparation.`), with a try/catch that falls through to the unchanged regex on any probe failure. The Codex copy implements the same behavior in its own idiom using its file-local `Get-StringProperty` (no cross-runtime import). Tests add 11 Claude-suite cases and one codex table-driven `It` plus two direct predicate assertions.

**Top 3 risks:**
1. Marker drift between the SKILL.md kickoff contracts and the hook literals — mitigated: the allow tests embed the verbatim kickoff lines, so drift fails the suite; reviewer confirmed the test prompts match `.claude/skills/parallel-plan/SKILL.md:105` and `.claude/skills/epic-plan/SKILL.md:99` verbatim.
2. Exemption over-breadth — mitigated: literal set (not prefix/glob) proven by two deny near-miss tests; a preparation-exempted child is still gated on every implementation write/command by the same hook.
3. Copy divergence across the four hook copies — mitigated: both pairs re-verified byte-identical by SHA256 during this review, and the push-down contract pytest suites (12/12) plus the codex hash-binding `It` enforce the pairs automatically.

**PR readiness recommendation:** **Go** — no Blocker, Major, or Minor defects found in the code delta; all toolchain, coverage, and parity evidence passes and was spot-re-verified.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | `Test-PreparationModeDelegation` | The null-payload guard is unreachable through `Test-ImplementationDelegation` (which already null-guards), so it is dead on the composed path; it is live only for direct predicate calls. | Keep as-is; the codex suite exercises it directly. | Defensive guards on a public-ish predicate are acceptable and cheap; noting so a future coverage report is not misread. | `evidence/regression-testing/pass-after-codex.2026-08-23T22-02.md` (line-140 analysis); codex suite direct assertion |
| Info | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` and `.codex` copy | catch block in `Test-ImplementationDelegation` | One `Write-Debug` line per canonical copy is uncovered (`.claude` 157, `.codex` 174); reaching it requires a payload whose property getter throws, which also breaks the downstream `ConvertTo-Json`. | Accept; documented in the coverage-delta artifact. Both files exceed the 85% threshold. | The branch fails closed (falls through to the stricter regex), so the uncovered line cannot open an enforcement gap. | `evidence/qa-gates/coverage-delta.2026-08-23T22-14.md`; reviewer re-parse of `artifacts/pester/powershell-coverage.xml` |
| Info | `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | new `It` (issue #535) | The added allow cases pass `-CheckpointRaw '{}'` (malformed checkpoint) rather than a not-ready checkpoint. | None required. | This is a stronger assertion, not a weaker one: it proves the exemptions short-circuit before checkpoint parsing, so even an unusable checkpoint cannot block an exempt operation. | Diff hunk at `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1:237-252` |
| Info | PR context | `artifacts/pr_context.summary.txt` (Close candidates) | The author-asserted autoclose list contains a malformed token `#ISO-8601` (prose harvested as an issue reference) and `#516`, which this branch explicitly does not fix. | When authoring the PR, assert autoclose for #535 only; do not autoclose #516. | Prevents an incorrect issue closure at merge time. | `artifacts/pr_context.summary.txt` lines 32-35; spec.md Scope & Non-Goals |
| Info | `.claude/state/` (not in diff) | session state | The plan-authorized batch-budget state reset (P2-T9) deleted a gitignored session file so the four-production-file scope could proceed in two capped batches. | None; recorded as an approved exception in the policy audit. | The reset is the mechanism the enforcement hook's own deny message names, was planned up front, and is fully evidenced. | `evidence/other/batch-budget-reset.2026-08-23T21-54.md`; `plan.2026-08-23T20-40.md` P2-T9 |

No Blockers, Major, or Minor findings.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The exemption is exactly the shape the spec mandates: a script-scoped constant array of seven repo-relative literals behind one `-contains`, with no prefix, glob, absolute path, or per-path normalization — verified against the diff and against the deny near-miss tests. The #516 normalization seam is preserved (no `GetFullPath`/`Resolve-Path`/`IsPathRooted` appears in the diff).
- The delegation exemption is field-scoped and conjunctive: `subagent_type` must equal `orchestrator` exactly, and both markers are checked on the extracted `prompt` string, never on the serialized payload. Marker text planted in `description` or `file_path` cannot exempt (proven by test).
- The fail-closed posture is preserved by construction: both exemptions only ever return "not implementation"; every deny path, the anomaly path, `Test-OrchestrationReady`, `Test-ImplementationCommand`, and the decision-JSON schema are untouched (grep-confirmed in `evidence/qa-gates/scope-and-size.2026-08-23T22-16.md` and re-checked against the raw diff).
- The Codex copy respects runtime isolation: it reuses its own `Get-StringProperty` (which returns `''` for absent properties, same tolerance as the Claude helper) rather than importing the Claude `HookPayload.psm1`.

#### API and safety notes

- `Test-PreparationModeDelegation` is a proper advanced function: `[CmdletBinding()]`, `[OutputType([bool])]`, mandatory `$ToolInput` with `[AllowNull()]`, explicit null guard. Approved verb, analyzer-clean.
- Both string getters (`Get-ClaudeHookToolInputString`, `Get-StringProperty`) return an empty string for absent properties, so `$prompt.Contains($marker)` cannot null-throw on a missing prompt; the try/catch is a second, deeper layer for exotic payload objects, and its failure mode is the stricter classifier.
- The two new script-scoped variables are write-once constants, consistent with the file's pre-existing `$script:CheckpointPath` pattern.

#### Error handling and logging

- The catch logs via `Write-Debug` and deliberately does not alter the decision; the comment states why an extraction failure must never become an exemption. Deny reasons keep the asserted `PREIMPLEMENTATION_GATE_BLOCKED` prefix and the `route metadata`/`lifecycle readiness` phrases.

---

## Test Quality Audit

Coverage, regression, fail-before, parity, and scope evidence are all present in the feature folder and were spot-re-verified (hashes, coverage XML, marker literals, line counts, diff surface).

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` — 11 new deterministic pure-seam cases in two issue-keyed contexts; every case supplies an explicit checkpoint; no existing test removed or weakened (+156/-0).
- `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` — one table-driven allow `It` plus two direct predicate falsity assertions; byte-identity `It` untouched (+16/-0, 494 lines).
- `evidence/regression-testing/fail-before-pester.2026-08-23T21-40.md` — exit 4 with exactly the four new allow cases failing against the unfixed hook; also candidly records and corrects an earlier non-discriminating draft (missing `-CheckpointRaw`), which is exactly the unfalsifiable-gate defect class this repository's plan gates exist to catch.
- `evidence/qa-gates/final-pester.2026-08-23T22-12.md` and `evidence/qa-gates/coverage-delta.2026-08-23T22-14.md` — 1532/1532 pass; per-file line coverage 90.00% / 99.18% re-confirmed by the reviewer from `artifacts/pester/powershell-coverage.xml`; no changed-line regression; bundle mirrors inherit measurement by verified byte-identity.
- `evidence/qa-gates/pushdown-parity.2026-08-23T22-18.md` — 12/12 pytest pass after removing a transient gitignored session file unrelated to the diff.

### Quality assessment prompts

- **Determinism:** Every new case is a pure function call on constructed JSON; explicit not-ready checkpoints remove on-disk state dependence. The fail-before artifact documents the determinism correction.
- **Isolation:** One classifier behavior per `It`; allow tables carry per-item `-Because` diagnostics.
- **Speed:** Scoped suite under 1s; full two-folder run 90.8s for 1532 tests.
- **Diagnostics:** Failures name the literal or scenario via `-Because`; deny cases additionally assert the reason prefix.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff contains only path literals, marker literals, and test payloads. |
| No unsafe subprocess or command construction | ✅ PASS | No process invocation added; tests are pure-seam calls. |
| Input validation at boundaries | ✅ PASS | Null guard + StrictMode-safe field extraction; exemption denied on any extraction anomaly. |
| Error handling remains explicit | ✅ PASS | Catch falls through to the stricter classifier and logs via `Write-Debug`; no silent allow path exists. |
| Configuration / path handling is safe | ✅ PASS | Exemption is an exact-literal set over the normalized repo-relative path; near-miss deny tests prove no prefix/glob widening; spoof tests prove field scoping. |
| Enforcement-hook language policy (no Python leg) | ✅ PASS | Both runtimes remain pure PowerShell; no Python was added to any hook. |

---

## Research Log

No external research was required. All conclusions derive from the branch diff against merge-base `e96e32e0`, the feature-folder evidence artifacts, the runner-generated coverage XML, the two SKILL.md kickoff contracts, and repository policy rule files.

---

## Verdict

The change is ready for normal PR flow. The implementation matches the spec's mandated shape exactly (literal set, three-conjunct field-scoped predicate, retained readiness scalar, four-copy parity), preserves the fail-closed default by construction, and is backed by discriminating fail-before evidence, a clean single-pass toolchain, above-threshold per-file coverage with no changed-line regression, and reviewer-re-verified byte-identity of both canonical/bundle pairs. The five Info-level notes require no code change; the only actionable item is for the PR author to restrict the autoclose assertion to #535.
