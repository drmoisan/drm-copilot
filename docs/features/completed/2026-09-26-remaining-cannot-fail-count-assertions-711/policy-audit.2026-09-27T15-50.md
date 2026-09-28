# Policy Audit — Issue #711 (remaining-cannot-fail-count-assertions)

- Timestamp: 2026-09-27T15-50
- Branch: `bug/remaining-cannot-fail-count-assertions-711`
- Reviewed against: `origin/main` at `bd4284c57be52d222eec3983671fc7e444f9a88b` (verified via `git fetch origin main` and `git rev-parse origin/main`, which returned this exact SHA)
- Work mode: `full-bug` (per `issue.md` marker), AC source: `spec.md`

## Scope Verification (independent, not trusting the caller summary)

The local `main` branch ref in this worktree was stale (pointing to an older commit, `736a5007`, that predates several merged PRs). `git diff --name-status main...HEAD` against the stale local ref returned hundreds of unrelated files from issues #706-#714. This was resolved by fetching `origin/main` directly, which resolved to `bd4284c57be52d222eec3983671fc7e444f9a88b` — exactly the merge-base the task description named. Re-running the diff against `origin/main` produced the expected, narrow result:

```
git diff --name-status origin/main...HEAD
```

Result: 34 added files (issue.md, plan.2026-09-26T22-56.md, research/, spec.md, and 30 evidence files) under `docs/features/active/2026-09-26-remaining-cannot-fail-count-assertions-711/`, plus exactly 4 modified files:
- `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1`
- `tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1`
- `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`
- `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`

No file under `.claude/`, `.codex/`, or `scripts/` appears in this diff (confirmed separately with `git diff origin/main...HEAD --stat -- .claude .codex scripts`, which returned no output). AC-9 scope discipline is verified independently, not merely trusted from the executor's own claim.

## Rejected Scope Narrowing

None detected. The caller-supplied summary in this task description did not attempt to narrow the audit scope to a plan/task/phase subset, mark any language as out of scope, or instruct skipping a toolchain/coverage check. The summary's account of files-in-scope matched the independently derived diff exactly once the correct base (`origin/main`) was used.

## Evidence Location Compliance

- Ran `python scripts/dev_tools/validate_evidence_locations.py --root .` — exit code 0, no violations reported.
- Manual scan for `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, `artifacts/coverage/` paths in the branch diff found none.
- All evidence artifacts are correctly located under `docs/features/active/2026-09-26-remaining-cannot-fail-count-assertions-711/evidence/{baseline,regression-testing,qa-gates,other}/`.
- No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` entries were necessary; no non-canonical path was ever proposed.

**Verdict: PASS.**

## Coverage Verification

All four changed files are Pester test files (`*.Tests.ps1`) under `tests/`. Per `.claude/rules/general-unit-test.md`, test files are excluded from production coverage measurement by design (the "Configure coverage tooling to exclude test files" clause), and `spec.md`'s Test Strategy section explicitly states: "Coverage impact and targets for changed lines/modules: none required. All four changed files are test code and are excluded from production coverage measurement per `.claude/rules/general-unit-test.md`; no production module's coverage is affected by this change."

No `.claude/lib/discovery-validation/DiscoveryValidation.psm1` (the AC-3/AC-4 producer) or any other production module was modified, so no production coverage artifact needed to change. This is correctly treated as "not applicable because zero production files changed," not silently skipped: the spec states the reasoning explicitly and it was verified independently by confirming (via `grep`) that the only producer module (`DiscoveryValidation.psm1`) is unmodified.

**Verdict: PASS** — no coverage language has a changed production file in this branch diff; the exclusion is correctly and explicitly justified, not silently assumed.

## AC-1 through AC-5: Root-Cause Verification (independent code inspection)

Each edit's justification was checked directly against the current producer source, not merely accepted from `spec.md`'s claims:

- **AC-1** (`BlastRadius.TruthTable.Tests.ps1`): `$entries = @($script:CommittedConfig['mandate_reads'])` is a raw hashtable-indexer read that returns `$null` on an absent/null key; `@($null).Count` is `1` in PowerShell, so the prior `$entries.Count | Should -BeGreaterThan 0` passed vacuously. The replacement calls `Test-NonVacuousCollection`, a helper already present in the file (added by #513/PR #702) at line 49, whose body (`return @($Value | Where-Object { $null -ne $_ }).Count -gt 0`) correctly discriminates null/empty from non-empty. Verified by reading the helper body directly.
- **AC-2/AC-3/AC-4**: verified by reading the actual producer bodies. `Get-GuardedPowerShellFile` (`enforcement-hooks-no-python-invocation.Tests.ps1:75,95`) and `Get-DiscoveryProfileValidationError`/`Get-DiscoverySchemaArtifactValidationError` (`.claude/lib/discovery-validation/DiscoveryValidation.psm1:235,240,246,256,333,342,347,356,374`) all use the leading-comma idiom `return , $x.ToArray()`, which forecloses a raw `$null` capture. The spec's claim that these three producers cannot return `$null` is independently confirmed.
- **AC-5**: `Get-CodexPreToolUseRegistration` (`codex-pretooluse-integration.Tests.ps1:55`) uses `return $registrations.ToArray()` with no leading comma — confirmed by direct inspection — which is the asymmetric root cause the spec identifies. Zero-registration results collapse to `$null` on assignment, making the pre-edit assertion exploitable. The fix (filtered `Where-Object` form) correctly discriminates this case.

All five edits are same-line, content-anchored, and produce a `$false`/count-0 result on `$null` and `@()` inputs while preserving the pass outcome for real non-empty data, per direct inspection of each site.

**Verdict: PASS.**

## AC-9 Scope Discipline (Production File Exclusion)

Confirmed independently (see Scope Verification above): zero files under `.claude/lib`, `.claude/hooks`, or `scripts` appear in the branch diff. The executor's own `evidence/qa-gates/ac9-scope-check.2026-09-27T16-40.md` reaches the same conclusion via `git diff --name-status` against the plan's base SHA and `git status --porcelain`.

**Verdict: PASS.**

## Enforcement-Hook Bypass Check

No file under `.claude/hooks/`, `.codex/hooks/`, `.claude/settings.json`, or any PreToolUse/SubagentStop hook script is touched by this branch. No new enforcement-hook bypass is introduced.

**Verdict: PASS — no Major finding of this class exists in this branch.**

## Deviation #2 — Batch-Budget Counter Reset (Gitignored State)

Claim: the file `.claude/state/powershell-batch-budget.worktree-*.json` reset mid-run is gitignored, per-worktree, and untracked.

Verified independently:
- `.gitignore` line 68: `.claude/state/` — confirms the entire directory is ignored.
- `git ls-files .claude/state/` returns no output — confirms no file under this path is tracked in the repository.
- `git diff origin/main...HEAD --stat -- .claude` returns no output — confirms no tracked file under `.claude/` (including `.claude/state/`) was touched by this branch.

**Verdict: PASS** — the reset touched only ephemeral, gitignored, untracked local state; no tracked or production file was affected.

## Deviation #1 — Seventh Helper Script (`select-string-count.ps1`)

Claim: a seventh scratchpad helper script was added, beyond the plan's original six, to route `Select-String`/`Get-Content` checks through the Bash-tool-compatible route.

Verified: `evidence/baseline/anchor-uniqueness-confirmation.2026-09-27T15-20.md` documents this deviation explicitly with rationale ("no separate bare-PowerShell tool is available... byte-identical semantics"), and the script's invocations (visible in `ac1-before-after-token-check.md`, `ac2-before-after-token-check.md`, `ac5-assertion-before-after-token-check.md`, `ac5-new-context-it-pair.md`) reproduce the exact `Select-String -Pattern ... -SimpleMatch).Count` command class the plan specifies, against the same target files and patterns.

**Verdict: PASS** — deviation is documented, and the substituted execution route is evidenced to be mechanically equivalent, not a lowering of rigor.

## Deviation #3 — Baseline Mismatch for `codex-pretooluse-integration.Tests.ps1`

Claim: the Phase 0 baseline for this file came back `TotalCount=6, FailedCount=0` rather than the plan's documented expectation of `TotalCount=5, FailedCount=1`, and the executor used the actual captured baseline per AC-6's baseline-relative wording (spec.md Decision D9).

Verified: `evidence/baseline/codex-pretooluse-pester.2026-09-27T15-20.md` records the actual `TotalCount=6, FailedCount=0` result and states the deviation explicitly, attributing the `TotalCount` discrepancy to a `-ForEach`-parameterized `It` and noting the absence of the previously documented pre-existing failure as an environment observation, not a regression introduced by this work. The Phase 4 final run (`evidence/regression-testing/final-per-file-pester-and-ac6-comparison.2026-09-27T16-30.md`) shows `TotalCount=7, FailedCount=0`, a delta of `+1` matching exactly the one new `Context`/`It` pair added for AC-5's documentation requirement. `spec.md` Decision D9 explicitly requires baseline-relative comparison rather than a hard-coded numeric baseline, so using the freshly captured baseline is the specified behavior, not an unapproved substitution.

**Verdict: PASS** — no regression is masked; the baseline-relative comparison method was applied as specified, and the delta is fully accounted for.

## Deviation #4 — Commit-Message Trigger Reword

Claim: one commit message triggered `enforce-promotion-mcp-only.ps1` on a false-positive match of the word "through," resolved by rewording; no `gh` command involved.

This does not affect source content and is not independently verifiable from artifacts alone (it is a description of an interactive authoring step). No evidence artifact records this specific event, and none is required by `spec.md`'s Test Strategy (it names no AC or evidence obligation for commit-message wording). Treated as **UNVERIFIED but non-blocking**: the claim is plausible, internally consistent with the observed final commit messages (all of which are professional and contain no policy-triggering content), and has no bearing on any AC or coverage gate.

## Tonality Compliance

Scanned `spec.md`, `issue.md`, all 30 evidence files, and all six commit messages for hyperbolic/informal language (jokes, sensational claims, absolute praise). No matches found. Language throughout is factual, evidence-first, and uses measured wording (e.g., "Verified," "Confirmed," "per spec.md Decision D9") rather than unsupported certainty claims.

**Verdict: PASS.**

## Evidence Schema Compliance

Spot-checked baseline, regression-testing, and qa-gates evidence files against the `Timestamp:`/`Command:`/`EXIT_CODE:`/`Output Summary:` schema in `evidence-and-timestamp-conventions`. All command-execution evidence files (qa-gates, regression-testing) carry all four required fields. One file, `evidence/baseline/phase0-instructions-read.2026-09-27T15-20.md`, records a policy-reading checklist rather than a command execution and omits `Command:`/`EXIT_CODE:`; this is a minor, non-blocking gap since the artifact's content (a list of files read, in order, before any change) is not itself a machine-checkable command result and this pattern is consistent with prior accepted reviews in this repository (issues #706-#709).

**Verdict: PARTIAL (non-blocking)** — one evidence file lacks Command/EXIT_CODE fields, but the omission is inherent to its "policy reads" record type and does not affect the verifiability of any AC.

## PR Context Artifacts

`artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` do not exist in this worktree. Per this skill's routing, missing PR context artifacts should be regenerated; however, the task's own prompt already supplies a full, verifiable summary, and this audit independently reconstructed and verified the full branch diff via `git diff --name-status origin/main...HEAD` rather than relying on the caller's text. This substitutes for the missing artifact with an equivalent or stronger evidentiary basis (direct git verification) and is recorded here as an assumption: no PR context artifact regeneration was performed because check-only, no-mutation review was preferred per this agent's constraints, and the direct-git-diff method fully satisfied the Scope Invariant requirement.

## Overall Policy-Audit Verdict

**PASS.** No blocking (FAIL or blocking-PARTIAL) findings. One non-blocking PARTIAL (evidence schema gap in a single policy-reads artifact) is noted for completeness but does not affect any acceptance criterion, coverage gate, or scope-discipline requirement.

**Blocking finding count: 0.**
