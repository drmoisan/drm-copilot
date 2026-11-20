# Policy Compliance Audit — Issue #573

- **Timestamp:** 2026-08-28T12-25
- **Issue:** #573
- **Branch under review:** `bug/epic-worktree-removal-gate-blocks-parallel-runs-573-r2`
- **Base branch:** `main`
- **Merge-base anchor:** `c7133fe75ce1ea1737843330b2232c175a689e37`
- **Work mode:** `full-bug` (persisted marker, `issue.md` line 12) — `spec.md` is the sole AC source
- **Reviewer:** feature-review agent
- **Diff form used:** two-dot, merge-base anchored (`git diff c7133fe7..HEAD`). The work is committed; an unanchored diff would be empty.

## Rejected Scope Narrowing

None detected. The caller prompt requested a full feature review of the whole branch against the resolved base branch and supplied the correct merge-base anchor. No instruction attempted to limit scope to a plan, task, phase, file subset, or language subset, and no instruction attempted to mark any language "informational only" or to skip a toolchain or coverage check. The audit was conducted over the full branch diff.

## Policy Reading Order Applied

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/powershell.md` (language in scope: PowerShell)
5. `.claude/rules/quality-tiers.md`
6. `.claude/rules/parallel-orchestration.md` (written by this change)
7. `.claude/rules/tonality.md`

## Languages With Changed Files in the Branch Diff

| Language | Changed files | Coverage verdict |
|---|---|---|
| PowerShell | 3 (`.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, its claude-customizations mirror, `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1`) | **PASS** |
| Markdown | 5 (2 rule/skill files, 2 bundle mirrors, feature-folder docs and evidence) | not a coverage language |
| TypeScript | 0 | N/A (zero changed files) |
| Python | 0 | N/A (zero changed files) |
| C# | 0 | N/A (zero changed files) |

## Coverage Verification

Coverage artifact for PowerShell: `artifacts/pester/powershell-coverage.xml` — **present**, written 2026-08-28 12:07, i.e. after the last code-bearing commit (`fc2dbc61`) and before the final evidence-only commit (`f6161c36`, 12:15). `git show --stat f6161c36` confirms that commit touches only feature-folder documents, so the artifact is current with respect to all code.

The agent did not rerun coverage generation. Figures below were parsed independently from the existing artifact, not read from the executor's evidence file.

| Metric | Value | Threshold | Verdict |
|---|---|---|---|
| Repo-wide PowerShell line coverage | 94.72% (7236 covered / 403 missed of 7639) | >= 85% | PASS |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` line coverage (modified file) | 95.70% (89 covered / 4 missed of 93) | >= 85% | PASS |
| Regression on changed lines | none — the file's missed set is exactly `{414, 415, 416, 419}`; the intersection with the added-line set is empty | no regression | PASS |
| Baseline for the same file | 94.12% (64 covered / 4 missed of 68) | not lower | PASS (+1.58 pp) |
| Branch coverage | not measured | no branch threshold applies to PowerShell (Pester measures command and line coverage only; `.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md`) | not a FAIL |

The four uncovered lines are the pre-existing entry-point tail below the `if ($MyInvocation.InvocationName -eq '.') { return }` dot-source guard at line 407. They are unreachable when the suite dot-sources the hook, are counted in the denominator rather than excluded, and are not lines this change adds.

Independent confirmation of the executor's recorded coverage values: the recorded 95.70% / 89 covered / 4 missed and the missed-line set `{414, 415, 416, 419}` were recomputed from the artifact and match exactly. The evidence artifact is **not stale**.

## Evidence Location Compliance

- `python scripts/dev_tools/validate_evidence_locations.py --root .` — **exit 0, no output**. No violations.
- Manual scan of the branch diff for `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, `artifacts/coverage/`: **zero matches**. No `artifacts/` path appears in the diff at all (`artifacts/` is gitignored).
- All evidence sits under `docs/features/active/2026-08-28-epic-worktree-removal-gate-blocks-parallel-runs-573/evidence/{baseline,regression-testing,qa-gates,other}/`, which is the canonical `<FEATURE>/evidence/<kind>/` scheme.
- No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` condition arose during this review.

**Verdict: PASS.**

## Policy-by-Policy Findings

### 1. `CLAUDE.md` — canonical policy source not modified

**PASS.** No file under `.github/instructions/` or `.github/copilot-instructions.md` appears in the diff.

`.claude/rules/parallel-orchestration.md` *is* modified. `.claude/skills/policy-compliance-order/SKILL.md` line 32 states "Do NOT modify policy documents under `.claude/rules/`". The spec anticipates this at lines 65-73 and records a four-point justification: `CLAUDE.md` scopes the canonical-source prohibition to `.github/`; the rule file carries its own amendment provision ("must amend this rule file and the validators at spec review"); there is landed precedent (issue #502, with a dedicated QA gate artifact); and declining the edit would leave the `## Enforcement` section silently incomplete.

The justification is accepted, and the scope limit it declares was independently verified. The rule-file diff is **one added line, zero deleted lines**, appended as the last bullet of `## Enforcement`. The Foreign Schema Warning, every numbered invariant, every enum-table row, and the Cache Doctrine are untouched. **Non-blocking**, recorded here so a later reader does not read the edit as a violation.

### 2. `.claude/rules/general-code-change.md`

| Requirement | Verdict | Evidence |
|---|---|---|
| Simplicity first | PASS | Branch 2 is one predicate plus one read seam; the cascade is a flat disjunction with a single terminal deny. No indirection added. |
| Reusability, no copy-paste | PASS | The inline parse at old lines 207-213 was extracted into `ConvertFrom-EpicWorktreeGateJson` and is used by both branches, mirroring `ConvertFrom-EpicMergeGateJson`. |
| Separation of concerns | PASS | Filesystem I/O is confined to the two named read seams; the predicates are pure functions over parsed objects. |
| Mandatory toolchain loop (format -> lint -> type check -> arch -> unit -> contract -> integration) | PASS | See "Toolchain Verification" below. Type check is correctly recorded as not applicable to PowerShell rather than silently omitted (`evidence/qa-gates/final-type-check-not-applicable.2026-08-28T11-36.md`). |
| 500-line file limit | PASS | Hook: 419 lines. Test suite: 428 lines. Bundle mirror: 419 lines (byte-identical). All under 500. |
| Fail fast and explicitly, no silent error swallowing | PASS | `ConvertFrom-EpicWorktreeGateJson` catches and returns `$null`, which routes to a deny. This is deliberate fail-closed behavior for an enforcement gate, documented in `.DESCRIPTION` lines 20-26, not a silent ignore. |
| No new dependencies | PASS | Only the pre-existing `../lib/hook-payload/HookPayload.psm1` import. |
| Naming conventions | PASS | Approved PowerShell verbs (`Get-`, `Test-`, `ConvertFrom-`), descriptive nouns, `[CmdletBinding()]` and `[OutputType]` present. PSScriptAnalyzer reports zero findings. |
| Public API compatibility | PASS | No existing function name, parameter, or return type changed. The function set grows by two functions and one script variable. |

### 3. `.claude/rules/general-unit-test.md`

| Requirement | Verdict | Evidence |
|---|---|---|
| Independence | PASS | Every test mocks its own seams; no shared mutable state across `It` blocks. `$script:RemoveItemA` is set in a `BeforeEach` and is a read-only literal. |
| Isolation | PASS | Direct-predicate and read-seam contexts test single functions; end-to-end contexts test one decision path each. |
| Determinism | PASS with a non-blocking observation — see finding N-1. |
| Temporary files prohibited | PASS | The repository's own purity hook (`.claude/hooks/check-powershell-test-purity.ps1`) was run against the suite content and returned **no decision (clean)**. Manual read of all 46 `It` blocks confirms zero `New-TemporaryFile`, `GetTempPath`, `Start-Process`, or filesystem writes. |
| No external dependencies / no real I/O | PASS | Every checkpoint fixture is a literal JSON string returned by a mocked seam. The two `real Test-Path read seam` contexts mock both `Test-Path` and `Get-Content` under `-ParameterFilter`, so no real file is opened. |
| Arrange-Act-Assert | PASS | Each `It` follows mock-setup, invoke, assert. |
| Test file location mirrors source | PASS | `tests/scripts/claude-hooks/` mirrors `.claude/hooks/`; matches the repository's established layout for every hook suite. |
| Scenario completeness (positive, negative, edge, error) | PASS | 3 allow, 8 deny, 2 ordering/precedence, 4 guard-clause, 2 read-seam. |
| Coverage exclusion policy — no production file excluded | PARTIAL, non-blocking — see finding N-2. |

### 4. `.claude/rules/quality-tiers.md`

**PASS.** Uniform thresholds applied (line >= 85%, no tier-specific lower floor). Branch threshold correctly not applied to PowerShell. The evidence artifact states the exemption explicitly rather than reporting an absent figure as a pass.

### 5. `.claude/rules/parallel-orchestration.md` (contract the change implements)

**PASS.**

- Orchestrator invariant 2 (route identity `route_id == 'parallel'`) is enforced by the new predicate at hook lines 257-259, and the reason for enforcing it is recorded in an inline comment.
- Merge-status members `merged` and `worktree_removed` are consumed from the existing `$script:AllowedMergeStatuses`; **no enum is extended**, consistent with the Enum Ownership section.
- No JSON Schema is authored, imported, or read. Enforcement remains prose plus hook logic, as the rule's doctrine requires.
- No `depends_on` or `integration_branch` field is introduced anywhere.
- The mirrored bundle copy is byte-identical (verified below), satisfying the rule's mirroring requirement.

### 6. `.claude/rules/tonality.md`

**PASS.** The rewritten `.DESCRIPTION`, the two SKILL.md passages, the rule-file bullet, and the evidence artifacts are factual and neutral. No hyperbole, humor, or decorative metaphor. Evidence-first wording is used consistently (the accepted-residual passage states the trade and its bound rather than asserting safety).

### 7. Push-down / bundle mirror contract

**PASS.** `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py -q` — **12 passed in 0.15s**, run by this reviewer.

## Mirror Identity — Recomputed by the Reviewer

Hashes recomputed independently (both `git hash-object` SHA-1 over content and `Get-FileHash -Algorithm SHA256`), not read from any evidence artifact.

| Pair | Path | SHA-256 | Result |
|---|---|---|---|
| A | `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | `56C8FDB4…7BE47C4A` | **IDENTICAL** |
| A | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | `56C8FDB4…7BE47C4A` | |
| B | `.claude/skills/parallel-orchestrate/SKILL.md` | `ABCCECFA…0994B6699` | **IDENTICAL** |
| B | `extensions/…/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md` | `ABCCECFA…0994B6699` | |
| C | `.claude/rules/parallel-orchestration.md` | `6E86239D…6F5D736E26` | **IDENTICAL** |
| C | `extensions/…/claude-customizations/.claude/rules/parallel-orchestration.md` | `6E86239D…6F5D736E26` | |

`git diff --no-index` over pair A also reports no difference. The SHA-256 values recomputed here match the six values recorded in `evidence/qa-gates/final-mirror-identity.2026-08-28T11-36.md` digit for digit; that artifact is **not stale**.

## Scope Verification

`git diff --name-status c7133fe7..HEAD` reports **45 paths**: 7 code paths and 38 feature-folder paths.

The seven code paths are exactly the seven the spec declares:

1. `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`
2. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1`
3. `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1`
4. `.claude/skills/parallel-orchestrate/SKILL.md`
5. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md`
6. `.claude/rules/parallel-orchestration.md`
7. `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md`

Prohibited paths confirmed **absent** from the diff:

| Prohibited path | Present? |
|---|---|
| `.codex/**` (any path) | absent |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/**` | absent |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | absent |
| `.claude/settings.json` and its bundle mirror | absent |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | absent |
| Any eighth code file | absent |
| Any scratch `.ps1` | absent |

`git status --porcelain` at review start: **empty**. No scratch `.ps1` file leaked into the tree or the diff. Executor note (c) confirmed.

The remaining 38 paths are `issue.md`, `spec.md`, `plan.2026-08-28T09-30.md`, `research/research.2026-08-28T10-05.md`, and 34 evidence artifacts, all under the feature folder.

## Toolchain Verification (independently re-run by the reviewer)

| Stage | Command run by this reviewer | Result |
|---|---|---|
| Format | `Invoke-Formatter` over the three changed `.ps1` files with `pssa.settings.psd1`, compared in memory (no write) | `UNCHANGED` for all three — the files are format-idempotent |
| Lint | `Invoke-PoshQCAnalyze -Root <worktree>` (whole repository, self-hosted module) | `PSScriptAnalyzer passed: no findings` — **0 findings whole-run** |
| Type check | not applicable to PowerShell | recorded, not omitted |
| Unit tests (in-scope suite) | `Invoke-Pester` on `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1` | TOTAL=46, PASSED=46, FAILED=0 |
| Unit tests (whole PowerShell suite) | `Invoke-Pester` over `scripts`, `tests/powershell`, `tests/scripts` with `Should.ErrorAction = Stop` | **TOTAL=3846, PASSED=3837, FAILED=0, SKIPPED=9** |
| Codex regression suite | `Invoke-Pester` on `tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1` | TOTAL=40, PASSED=40, FAILED=0 |
| Contract / bundle parity | `poetry run pytest` on the two push-down contract modules | 12 passed |

The full-suite run was executed with `TestResult` disabled and coverage disabled so that the executor's `artifacts/pester/*` evidence was not overwritten. No command was judged by a piped exit status; every result above is a value read from a Pester result object, an analyzer return, or a direct string comparison.

**AC-22's literal wording ("PSScriptAnalyzer with zero findings") is satisfied whole-run, not merely under the scoping caveat the plan's P5-T13 anticipated.** The caveat proved unnecessary.

## Executor Claims — Verification Status

| Claim | Status | Basis |
|---|---|---|
| All plan tasks complete | **Verified with a discrepancy in the count** | Every task checkbox in `plan.2026-08-28T09-30.md` is `[x]`. The plan contains **40** tasks (P0×7, P1×6, P2×5, P3×3, P4×6, P5×13), not the 31 the caller reported. The plan is at revision 3 / version 1.2; the figure 31 does not match the committed artifact. All 40 are checked. Non-blocking (finding N-4). |
| All 23 acceptance criteria checked off | **Verified** — all 23 are `[x]` in `spec.md`; see the feature audit for per-criterion discharge |
| Single clean PowerShell toolchain pass | **Verified independently** for format (in-scope files), lint (whole repo), and test (whole suite). The "single pass, no restart" attestation is accepted on the artifact's word, since a restart history is not reconstructable post hoc from the tree. |
| Format: 0 files rewritten | **Partially verified** — verified format-idempotent for the three changed files and corroborated by an empty `git status --porcelain`. The whole-repo figure of 421 files scanned / 0 rewritten is accepted on the artifact's word. |
| Lint: 0 findings | **Verified independently** (whole repository, 0 findings) |
| 3846 tests, 0 failures, 9 skipped | **Verified independently** (exact match) |
| Hook line coverage 95.70%, 89 covered / 4 missed | **Verified independently** by parsing `artifacts/pester/powershell-coverage.xml` (exact match, including the missed-line set) |
| Mirror pairs byte-identical | **Verified independently** by recomputing both SHA-1 and SHA-256 (exact match to the recorded digests) |
| Note (a): bundle-parity red is attributable to issue #510 and a controlled run reports 1 passed | **Verified as currently moot** — `.claude/state/` does not exist in the tree at review time, and the two push-down contract modules report 12 passed with no qualifier. |
| Note (b): the commit-message block is a pre-existing over-broad match named as a non-goal | **Partially verified** — see finding N-3 |
| Note (c): no scratch `.ps1` leaked | **Verified** — clean working tree, no `.ps1` outside the three in the diff |

## Findings

### B-0 — none

No Blocking finding was identified.

### N-1 (Non-blocking) — three allow-expecting tests do not mock the parallel seam

**Location:** `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1` lines 57-64, 68-75, 125-132 (contexts `allow on merge_status merged`, `allow on merge_status worktree_removed`, `path normalization`).

These three pre-existing tests mock only the epic seam. They are deterministic **today** because the epic branch authorizes and `Invoke-EpicWorktreeRemovalGateDecision` returns at line 357 before the parallel seam is read (hook line 360). The determinism obligation in AC-10 is scoped to deny-expecting tests, and all nine of those (plus the entry-point `BeforeEach`) do mock the seam to `$null` — independently confirmed by reading all 46 `It` blocks and by counting nine `-MockWith { $null }` occurrences on `Get-EpicWorktreeGateParallelCheckpointContent`.

The residual is second-order: if a future change regressed branch 1, these three tests would fall through to a real read of the gitignored `artifacts/orchestration/parallel-orchestrator-state.json`, and a live checkpoint recording the same path would return `allow` and mask the regression. The fixture paths (`/repo/worktrees/child-a`, `C:/repo/worktrees/child-a`) make a real collision implausible.

**Recommendation (not required for merge):** add `Mock -CommandName Get-EpicWorktreeGateParallelCheckpointContent -MockWith { $null }` to these three tests so the suite's determinism property holds unconditionally rather than by short-circuit.

### N-2 (Non-blocking, pre-existing) — the bundle mirror is not in the coverage denominator

**Location:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, `CodeCoverage.Path` (line 46 lists the `.claude` hook; a search for `claude-customizations` in that file returns **zero** matches).

`extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1` is a modified `.ps1` file with no coverage measurement. Under the strictest reading of the Coverage Exclusion Policy this is an omission.

Assessed as non-blocking for three reasons: the file is a shipped payload resource that is never executed in this repository; it is **byte-identical** to a file measured at 95.70%, so its behavior is covered; and no bundle mirror of any hook has ever been listed in `CodeCoverage.Path`, so this is a long-standing repo-wide convention and is not introduced by this change. Adding the entry would also have required editing the runsettings file, which the spec explicitly declares a non-goal.

**Recommendation:** file separately if the convention should change; do not change it in this pull request.

### N-3 (Non-blocking) — executor note (b) is substantially but not exactly accurate

**Location:** `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` line 347 (`if ($commandText -notmatch '(?i)\bgit\s+worktree\s+remove\b')`) and line 147 (`Get-EpicWorktreeRemovalCommandPath`).

Verified: **both regexes are untouched by this change.** Neither line appears as an added or deleted line in the merge-base-anchored hook diff. The reported behavior — a `git commit -m` whose message body contains a worktree-removal phrase being blocked — is therefore pre-existing and is **not** introduced or worsened by this change. The executor's core claim holds.

The characterization is imprecise on one point. `spec.md` line 59 declares a non-goal for the **`--force` path-extraction defect**, describing the `(?<path>\S+)` capture. The commit-message case is a manifestation of the **in-scope detection** regex at line 347 matching a phrase inside a quoted argument, which the spec does not name explicitly. It is the same class of over-broad matching, and the spec's non-goal reasoning ("fail-closed and therefore safe … widening the regex would change epic-path behavior currently pinned by tests") applies to it directly, but a reader looking for the commit-message case in the spec will not find it stated.

**Recommendation:** when filing the `--force` follow-up the spec's Rollout section already contemplates (line 300), widen its scope to name the in-scope detection regex and the commit-message manifestation.

### N-4 (Non-blocking) — plan task count differs from the reported figure

**Location:** `docs/features/active/2026-08-28-epic-worktree-removal-gate-blocks-parallel-runs-573/plan.2026-08-28T09-30.md`.

The committed plan contains 40 tasks; the caller reported 31 complete. Every one of the 40 is checked `[x]`, so completeness is not in question. The plan header records "Version: 1.2 … revision 3", so the figure 31 most likely refers to a superseded revision. Additionally, the plan's `Last Updated: 2026-08-28T13-20` postdates its filename timestamp `09-30` and the current wall clock; this is a metadata inconsistency only.

### N-5 (Non-blocking, out of scope) — the PowerShell change-budget hook classifies scratch files as production

**Location:** `.claude/hooks/enforce-powershell-batch-budget.ps1` lines 17-22.

The hook classifies as "test" only `tests/**/*.ps1` and `*.Tests.ps1`, and treats every other `.ps1`/`.psm1`/`.psd1` as production. A throwaway analysis script written to the scratchpad therefore consumes a production-cap slot.

Executor note (c) states the budget state file was deleted to reset the counter. This is **not a policy bypass**: the hook's own `.DESCRIPTION` at lines 29-32 states "The session must explicitly reset the counter by deleting the state file before starting a new batch." Deletion is the documented, sanctioned mechanism, the state file is gitignored, and the change's actual production-file count in the diff is 2, within the cap of 3.

**Recommendation:** consider filing the misclassification separately. Out of scope for this pull request.

## Verdict

| Area | Verdict |
|---|---|
| Policy reading order and canonical-source protection | PASS |
| General code change policy | PASS |
| General unit test policy | PASS |
| Quality tiers / coverage thresholds | PASS |
| Parallel-orchestration contract | PASS |
| Tonality | PASS |
| Evidence location compliance | PASS |
| Scope containment | PASS |
| Mirror identity | PASS |
| Toolchain (format / lint / test) | PASS |
| PowerShell coverage | PASS |

**Blocking findings: 0. Non-blocking findings: 5 (N-1 … N-5).**
