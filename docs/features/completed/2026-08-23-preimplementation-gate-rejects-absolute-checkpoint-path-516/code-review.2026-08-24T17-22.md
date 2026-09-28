# Code Review: Preimplementation Gate Rejects Absolute Checkpoint Path (#516)

**Review Date:** 2026-08-24
**Reviewer:** feature-review agent (Claude)
**Feature Folder:** `docs/features/active/2026-08-23-preimplementation-gate-rejects-absolute-checkpoint-path-516`
**Feature Folder Selection Rule:** Single active folder whose suffix matches the issue number in the branch name; supplied explicitly by the caller and confirmed against the diff.
**Base Branch:** `main` (merge-base `fb3e1f331cc52d1dd7a61332d6d23fcc0b495e24`)
**Head Branch:** `bug/preimplementation-gate-rejects-absolute-checkpoint-path-516` (head `b50f4e2881545685f13d6ce2ae22b2dd1d107542`)
**Review Type:** Initial review

**Template provenance:** Created from the bundled asset source at `extensions/drm-copilot/resources/templates/policy_audit/code-review.yyyy-MM-ddTHH-mm.md`, the identical file the MCP tool `resolve_policy_audit_template_asset` resolves for selector `code-review-template`; that tool is unavailable in this delegated review environment.

---

## Executive Summary

The change repairs a fail-closed defect in the orchestration preimplementation gate: the checkpoint exemption compared the tool-supplied `file_path` for exact equality against seven repo-relative literals, and the documentation exemption used `String.StartsWith`, so neither exemption was reachable through the `Write` tool, which supplies absolute paths by contract. The fix replaces exactly two predicate bodies — `Test-FeatureDocumentationOrEvidencePath` and `Test-ImplementationPath` — in each of four hook copies with segment-anchored matching: a case-sensitive `-cmatch '(^|/)docs/features/active/'` (preserving `StartsWith` case semantics) and a case-insensitive, end-anchored `-match ('(^|/)' + [regex]::Escape($checkpoint) + '$')` loop (preserving `-contains` case semantics). Two new Pester suites (33 + 35 cases) assert the paired relative/absolute matrix, both case-sensitivity directions, the mandatory deny half, and the Codex `apply_patch` idempotence proof.

**What changed:** Two hunks per hook copy, both confined to the two target functions (verified by direct diff inspection); no other function, the deny reason text, the decision-JSON schema, or either entry point changed. The two Claude copies are byte-identical (SHA256 `658c50a9...`), the two Codex copies are byte-identical (SHA256 `98dc6917...`), and the Codex pair landed together in the single commit `b50f4e28`. This reviewer independently re-ran the new suites (68/68), the five run-only suites (176/176), PSScriptAnalyzer over all six changed files (0 findings), and the push-down parity pytest (10/10 after removing a reviewer-session state file).

**Top 3 risks:**
1. The documentation predicate's nested-segment widening is undocumented in its comment and unstated in the spec's backward-compatibility sentence (Minor; zero measured exposure today).
2. The doc-prefix exemption is not end-anchored, so a `..`-bearing path whose text contains the `docs/features/active/` segment is exempt; this behavior pre-existed for relative spellings under `StartsWith` and the `Write` tool does not emit `..` segments (Info).
3. The push-down parity test is sensitive to gitignored hook-generated session files in the working tree, which can produce false failures for future reviewers (Info; out of this change's scope).

**PR readiness recommendation:** **Go** — all gates pass on independently verified evidence; the only findings are one Minor documentation omission and two Info observations, none of which gates merge.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` (and the three sibling copies) | `Test-FeatureDocumentationOrEvidencePath`, comment block (Claude copy lines 62-67) | The segment anchor `(^|/)` also admits a *nested* spelling such as `some/other/dir/docs/features/active/x.json`, which the previous `StartsWith` rejected. The comment documents the absolute-path intent and the `-cmatch` choice but not this nested widening, while the checkpoint predicate's parallel comment documents its own analogous widening explicitly. The spec's backward-compatibility sentence ("the sole intended exception of the absolute spellings of the two exemptions") is likewise inconsistent with the construction the spec itself mandates. | In a follow-up: extend the documentation-predicate comment to record the nested widening and its measured exposure, mirroring the checkpoint comment's pattern; amend the spec sentence to name both admitted spellings (absolute and nested). | The asymmetry invites a later reader to conclude the widening was unnoticed rather than accepted, and undocumented accepted behavior is how the next defect report gets misdiagnosed. Measured exposure today is zero: the tracked tree holds 9 nested `docs/features/active/` paths (test fixtures under `tests/fixtures/resolve_execute_plan_prompt/`), none with a gate-matched extension, so no tracked file changes classification. The widening is inherent to any rootless segment-anchor approach; only its documentation is deficient. | `git ls-files | grep -E '.+/docs/features/active/'` → 9 paths; piped through the extension filter → 0. Diff inspection of all four copies. |
| Info | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` (and siblings) | `Test-FeatureDocumentationOrEvidencePath` | Because the documentation exemption is a prefix/subtree match (deliberately not end-anchored), a path containing `..` after the `docs/features/active/` segment remains exempt — e.g. an absolute spelling that hops back out of the folder. This is not new: `StartsWith` had the same property for relative spellings; the fix extends it to absolute spellings. The `Write` tool does not emit `..` segments, and the checkpoint predicate's `..` behavior (deny) is asserted by test. | No action required for this PR. If the comment amendment above is made, one sentence noting the `..` property of the prefix exemption would complete the record. | The gate is an agent-governance quality gate, not a security boundary against adversarial input; the exposure direction and magnitude are unchanged in kind from the pre-fix behavior. | Predicate inspection; pre-fix `StartsWith` semantics; spec's accepted-miss record covers the checkpoint side only. |
| Info | `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | `test_bundled_claude_payload_contains_all_repo_runtime_contracts` | The parity test enumerates the working tree including gitignored files, so a hook-generated session file (here `.claude/state/python-batch-budget.default.json`, created by the batch-budget hook during this review session) fails the suite even though it is not in the diff. The executor's evidence (10 passed, exit 0) was accurate at its capture time; this reviewer reproduced the pass after removing the session artifact. | Out of scope for this PR. A future hardening could exclude `.claude/state/**` (gitignored session state) from the parity enumeration. | A test that fails on transient gitignored state produces false alarms for reviewers and CI reruns. | Reviewer runs: 1 failed/9 passed with the file present; 10 passed after `rm .claude/state/python-batch-budget.default.json`. File mtime 2026-08-24 17:12 postdates executor evidence (16:49). |

No Blockers or Major findings.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- **Minimal, idiomatic construction.** The rootless segment-anchor approach avoids every workspace-root-resolution failure mode (8.3 short names, drive-letter case, symlinks, linked worktrees) and matches the idiom already used by five other hooks in this repository. The decision function stays pure — no new parameter, environment read, filesystem probe, or subprocess.
- **Case semantics preserved exactly and defended in comments.** `-cmatch` for the documentation prefix preserves `String.StartsWith` case sensitivity; `-match` for the checkpoint literals preserves `-contains` case insensitivity. Both choices are recorded in comments that explicitly warn a later reader against normalizing one operator into the other, and both directions are asserted by tests, not merely commented (caller examination point 4: confirmed — `$CaseSensitivityCases` in each suite carries one allow and one deny assertion).
- **Deny half demonstrably intact.** Absolute production `.ps1`/`.py` paths, non-literal `artifacts/orchestration/` JSON, checkpoint-named files without the preceding segment, and `..`-hop paths all still deny — asserted in both suites, passing both before the fix (fail-before capture, 5/5 deny cases passing in a 38-failure run) and after (reviewer re-run) (caller examination point 2: confirmed).
- **Evaluation order and extension regex untouched.** The documentation exemption still runs before the checkpoint loop, and the extension pattern line is byte-unchanged; verified in the raw diff.
- **`[regex]::Escape` on the literals** removes any risk of regex metacharacters in future checkpoint names.

#### API and safety notes

- Both functions retain `[CmdletBinding()]`, `[OutputType([bool])]`, and `[Parameter(Mandatory)][string]` validation; signatures unchanged, so the existing test seam (`-ToolInputRaw` / `-CheckpointRaw`) is stable across both families.
- Four-copy parity independently confirmed by SHA256 (caller examination point 5: confirmed — Claude pair `658c50a9...`, Codex pair `98dc6917...`), and the byte-identity assertion in `legacy-codex-hook-contracts.Tests.ps1` passes. Commit inspection shows `9c12d20a` touched docs only and `b50f4e28` carried all four copies plus both suites, so no intermediate commit holds a split Codex state.
- The Codex copy carries one extra comment paragraph (the `apply_patch` idempotence note), which is the expected family difference; the families are deliberately not reconciled with each other.

#### Error handling and logging

- No new error path, no new logging, and no change to the `PREIMPLEMENTATION_GATE_BLOCKED` reason text — confirmed by the unmodified message-substring assertions in the existing suites, which pass unchanged. The gate remains fail-closed: the only deny-to-allow transitions are the two exemptions in their newly reachable spellings (plus the nested spelling recorded in the Minor finding above).

---

## Test Quality Audit

Both new suites are structurally incapable of the vacuous pass the spec warns about (caller examination point 3: confirmed against the suite text). Each suite defines exactly one decision-invoking helper path — `Get-GateDecisionFor` in the Claude suite; `Get-GateDecisionFor` and `Get-GateDecisionForCommand` in the Codex suite — and each helper passes `-CheckpointRaw (ConvertTo-NotReadyCheckpointRaw)` unconditionally. Every `It` block routes through those helpers; no case constructs its own call to `Invoke-OrchestrationPreimplementationGateDecision`. The not-ready builder sets `route_id = ''` and `lifecycle_ready = $false`, so `Test-OrchestrationReady` cannot short-circuit to allow, and the ready on-disk checkpoint in this worktree is unreachable from any case. The fail-before capture corroborates this at run level: all 38 positive-half absolute cases failed against the unmodified hooks, which could not have happened had any of them read the ready on-disk checkpoint.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1` — 33 cases; full relative/absolute/backslash matrix over the seven literals, POSIX and `./` edges, documentation matrix, both case directions, five deny cases. Read in full; re-run: all pass.
- `tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1` — 35 cases; same matrix against the flat Codex payload shape, plus the two `apply_patch` file-marker idempotence cases exercising `Test-ImplementationCommand`'s repo-relative call site. Read in full; re-run: all pass.
- `evidence/regression-testing/fail-before-new-suites.2026-08-23T23-25.md` — exit 38; exactly the 19 positive-half cases failed per suite; all deny and relative-regression cases passed in the same run. The failing-set composition matches the defect's predicted signature exactly.
- `evidence/regression-testing/pass-after-new-suites.2026-08-23T23-25.md` — exit 0, all 68 cases pass against the fixed copies; identical command and scan set as the fail-before run.
- `evidence/qa-gates/coverage-delta.2026-08-23T23-25.md` — 8/8 instrumented changed lines covered; per-file percentages non-decreasing. Counters independently re-parsed from `artifacts/pester/powershell-coverage.xml` by this reviewer; they match.
- `evidence/qa-gates/synthetic-path-constant-audit.2026-08-23T23-25.md` — synthetic-prefix discipline audit; re-verified by inspection: all absolute prefixes are bare string literals, and the single `Resolve-Path`/`$PSScriptRoot` use per suite is the `BeforeAll` hook-locating line, not test-path construction.

### Quality assessment prompts

- **Determinism:** Pure decision function, synthetic literal paths, explicit checkpoint input, no clock/RNG/timers/temp files.
- **Isolation:** One decision assertion per case; failure names the exact path shape via templated case names.
- **Speed:** 68 tests in 1.11s (reviewer-observed).
- **Diagnostics:** `Should -Be` on `permissionDecision` yields expected/actual; deny cases additionally pin the `PREIMPLEMENTATION_GATE_BLOCKED` reason substring.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection: predicates, comments, and synthetic test constants only. |
| No unsafe subprocess or command construction | ✅ PASS | No subprocess added; `enforcement-hooks-no-python-invocation.Tests.ps1` passes with its empty allowlist (27/27). |
| Input validation at boundaries | ✅ PASS | Mandatory typed parameters retained; upstream `-replace '\\', '/'` normalization unchanged and proven still effective by the backslash-spelling cases. |
| Error handling remains explicit | ✅ PASS | Fail-closed default retained; deny reason text unchanged and asserted. |
| Configuration / path handling is safe | ✅ PASS | `[regex]::Escape` guards the literal interpolation; end-anchoring bounds the checkpoint widening; the deliberate `..` miss is asserted by test. The unbounded side of the documentation prefix is recorded as the Minor/Info findings above. |

---

## Research Log

No external research was required. All conclusions derive from the branch diff, the feature-folder documents and evidence, direct re-execution of the test and lint toolchain, coverage-XML parsing, git commit inspection, and tracked-tree measurement of the nested-widening exposure.

---

## Verdict

The change is ready for normal PR flow. It is a tightly scoped, well-evidenced fix that repairs the reported bootstrap deadlock without opening the gate: the deny half is proven intact by tests that pass both before and after the fix, the case-sensitivity semantics of both replaced operators are preserved and asserted in both directions, all four copies are in verified byte parity with the Codex pair landing in a single commit, and coverage improved marginally with zero uncovered changed lines. The single Minor finding — the undocumented nested widening of the documentation predicate, with its accompanying spec-sentence inconsistency — has zero measured exposure in the tracked tree and warrants a follow-up comment amendment, not a hold on this PR. The two Info observations require no action in this change.
