# Policy Audit — issue #554, remediation cycle 1 exit re-audit

- Timestamp: 2026-08-28T00-30
- Branch: `bug/preimplementation-gate-blocks-epic-execution-554-r3` at `3140652d`
- Base: `origin/main`; merge base `1e991b86` (`origin/main` has since advanced to `c62af7a7`; the
  three-dot form `git diff origin/main...HEAD` resolves to the stated base `1e991b86`)
- Working tree: clean; branch pushed
- Work mode: `full-bug`; sole AC source `spec.md`
- Supersedes: `policy-audit.2026-08-27T22-47.md` (retained; **corrected** in one place — see B5)

## Verdict Summary

| Area | Verdict |
| --- | --- |
| Tone policy | PASS |
| General code-change policy | PASS |
| General unit-test policy | PARTIAL — see B5 |
| PowerShell language policy | PASS |
| Coverage — PowerShell, repo-wide | PASS (94.6809%) |
| Coverage — new files | PASS |
| Coverage — modified files vs 85% | PARTIAL — one named exception (#555) |
| Coverage — no regression on pre-existing lines | **FAIL** — see B5 |
| Evidence location compliance | PASS |
| Blast-radius declaration | PASS |
| Policy-path immutability | PASS |
| Change-budget compliance | PASS |
| File-size cap (500 lines) | PASS |

**Blocking findings: 1 (B5). Non-blocking findings: 5.**

## Rejected Scope Narrowing

No narrowing was attempted. The caller's instruction to "concentrate on" closure of B1 through B4
was read as prioritisation, not as a scope limit, and the caller separately directed evaluation of
all 35 acceptance criteria and all scope constraints. The audit performed here is the full branch
diff against the resolved merge base: **99 changed files**, every acceptance criterion, and every
language with changed files. Nothing was excluded.

Languages with changed files on this branch: **PowerShell only**. There are zero changed `.py`,
`.ts`, `.tsx`, or `.cs` files, so those languages take no coverage verdict. The changed `.json` and
`.psd1` files are configuration consumed by pre-existing Python tests; no Python source changed.

## Evidence Location Compliance

`python scripts/dev_tools/validate_evidence_locations.py --root .` exits **0**.

`git diff --name-only origin/main...HEAD` contains no path matching
`artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. Every
evidence artifact this branch writes sits under
`docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/<kind>/`, which is
the canonical scheme. **PASS.**

## Coverage Verification — measured independently

Coverage was verified by parsing `artifacts/pester/powershell-coverage.xml` directly, not by reading
the executor's artifacts. The report root carries `<sessioninfo>` for a run at `2026-08-28 00:05:34`,
after the last test commit `f7668332` (`00:02:01`) and before the final documentation commit
`3140652d` (`00:20:21`), so it reflects the final test state. No coverage run was re-executed.

### Repository-wide

| Counter | Missed | Covered | Total | Percentage |
| --- | --- | --- | --- | --- |
| LINE | 405 | 7209 | 7614 | **94.6809%** |

Threshold 85%. **PASS**, margin +9.68 pp. Pester measures no branch coverage, so no branch figure
exists and no branch threshold applies (`.claude/rules/quality-tiers.md`, `.claude/rules/powershell.md`).

### Per-file, the four production files

| File | Missed | Covered | Total | Line % | vs 85% |
| --- | --- | --- | --- | --- | --- |
| `.claude/…/gate.ps1` | 18 | 132 | 150 | **88.00%** | PASS |
| `.claude/…/gate-modes.ps1` | 2 | 130 | 132 | **98.48%** | PASS |
| `.codex/…/gate.ps1` | 27 | 135 | 162 | **83.33%** | Named #555 exception |
| `.codex/…/gate-modes.ps1` | 2 | 130 | 132 | **98.48%** | PASS |

These reproduce `evidence/qa-gates/coverage-delta.2026-08-27T22-47.md` §6 exactly. The executor's
measurement is accurate.

### Fully-missed line sets, measured

| File | Missed lines |
| --- | --- |
| `.claude/…/gate.ps1` | 125, 252, 253, 255, 266, 267, 268, 270, 278, 279, 280, 282, 408, 425, 485, 486, 487, 490 |
| `.claude/…/gate-modes.ps1` | 94, 95 |
| `.codex/…/gate.ps1` | **197**, **206**, 292, 293, 294, 296, 304, 305, 306, 308, 421, 422, 426, 427, 428, 429, 430, 432, 433, 434, 435, 436, 437, 439, 441, 442, 443 |
| `.codex/…/gate-modes.ps1` | 94, 95 |

The four `-helpers.ps1` copies sit at 94.92% (6 missed of 118) and are byte-untouched by this branch.

## Closure of the Cycle-1 Blocking Findings

Each was verified by independent measurement against the coverage XML and against the source at the
cited line numbers. All four are **CLOSED**.

| Finding | Claim | Measured | Verdict |
| --- | --- | --- | --- |
| **B1** | `.codex/…/gate-modes.ps1` 81.82% → 98.48%, only the `Write-Debug` catch at 94-95 remaining | 130 covered of 132 = **98.48%**; missed set is exactly `{94, 95}` | **CLOSED** |
| **B2** | Claude lines 170-185, the body of `Test-PreparationModeDelegation`, restored to covered | None of 170-185 appears in the measured missed set; the function body spans 170-185 as claimed | **CLOSED** |
| **B3** | `Get-OrchestrationModeDenyReason` at Codex 352-353 covered | Neither 352 nor 353 appears in the measured missed set | **CLOSED** |
| **B4** | Claude line 210, the classifier's non-orchestrator allow branch, covered | 210 does not appear in the measured missed set | **CLOSED** |

The `.codex/…/gate.ps1` figure of **27 uncovered of 162 (83.33%)** matches the projection recorded in
`remediation-inputs.2026-08-27T22-47.md` to the line.

## Blocking Finding

### B5 — the Codex twin of B2 is open, and the artifact that closes the acceptance criterion states a false fact about it

**Severity: Blocking.** Rules: `.claude/rules/general-unit-test.md` (no-regression principle;
"untested critical behavior is not acceptable even if the overall percentage looks good"); evidence
integrity of an artifact that justifies an acceptance-criterion check-off.

**The measurement.** Two lines of `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` are
uncovered and are attributed to no named exception:

| Line | Text | Role |
| --- | --- | --- |
| 197 | `return $false` | `Test-PreparationModeDelegation`, the non-`orchestrator` branch |
| 206 | `return $true` | `Test-PreparationModeDelegation`, the all-conjuncts-hold return |

`coverage-delta.2026-08-27T22-47.md` accounts for **25** uncovered *changed* lines in that file. The
measured missed set has **27** members. The difference is exactly `{197, 206}`, which are pre-existing
lines and therefore fall outside that artifact's "zero uncovered added lines are unattributed" claim.
That claim is true as worded; it is the omission of the pre-existing pair that is the defect.

**These two lines were covered at the merge base.** Verified from merge-base sources, not inferred:

1. Merge-base `.codex/…/gate.ps1` line 213 — inside `Test-ImplementationDelegation` — called
   `Test-PreparationModeDelegation`. That call site no longer exists; `grep` for
   `Test-PreparationModeDelegation` across both current production copies returns **only the function
   definitions**. The function is now orphaned on *both* surfaces.
2. Merge-base `Invoke-OrchestrationPreimplementationGateDecision` called `Test-ImplementationDelegation`.
3. Merge-base `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` line 367 passed
   `subagent_type = 'atomic-executor'` and line 373 passed `'task-researcher'` through
   `Test-ImplementationDelegation`, reaching the non-`orchestrator` `return $false`.
4. The same file's line 242 passed `subagent_type = 'orchestrator'` with
   `prompt = 'Preparation mode: true. route_id: preparation. Hand off to atomic-executor later.'`
   through the decision function. Merge-base `$script:PreparationModeMarkers` is
   `@('Preparation mode: true.', 'route_id: preparation.')`; the prompt contains both, so the
   all-conjuncts `return $true` was reached.

The two surviving direct callers at current lines 249-250 supply only `$null` and an
`orchestrator` payload carrying a single marker. Those reach the null branch and the marker-loop
`return $false`; neither reaches 197 or 206.

**This is the identical defect class as B2**, on the other surface, at 2 lines instead of 10, caused
by the same orphaning, and it was not remediated.

**The false statement.** `evidence/qa-gates/r1-acceptance-criterion-reevaluation.2026-08-27T22-47.md`
lines 100-102 state:

> its two uncovered pre-existing lines, 197 and 206, were uncovered at the merge base as well, which
> is why the audit's derived-baseline calculation restored only the ten. On that basis no line that
> was covered at the merge base is uncovered now.

Both sentences are false. The executor is not the origin of the error: it is a faithful reading of
**this reviewer's own cycle-1 artifact**, `policy-audit.2026-08-27T22-47.md` line 173 ("the Codex
copy … retains coverage … which is why only lines 197 and 206 are uncovered there") and its derived
baseline at line 181 (`≈ 98.3% (118/120)`), which assumed those two lines uncovered at base without
verifying it. **That cycle-1 statement is hereby corrected.** The corrected derived Codex baseline is
120 of 120 pre-existing measurable lines covered.

The same incorrect claim is repeated in a code comment at
`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1`
line 82.

**Why Blocking rather than Non-blocking.** The counter-argument is real and is recorded rather than
suppressed: the acceptance criterion is scoped to *changed* lines, 197 and 206 are unchanged, the
function is dead code on both surfaces, and the identical algorithm is now fully covered on the
Claude copy. Against that: this reviewer ruled the same defect Blocking in cycle 1 on the Claude
surface, and a magnitude threshold that would separate 10 lines from 2 was never declared; a false
statement of fact stands in the artifact that constitutes the auditable justification for checking an
acceptance criterion; and the remedy is two `It` blocks in
`tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`,
a file this remediation already edited, which stands at 302 of 500 lines. Decision D5 raises no
obstacle: the function takes a `[pscustomobject]` and returns a `[bool]`, constructs no `Agent`
envelope, and is already called directly by the Codex legacy-contract suite. **Blocking.**

**B5 does not bear on acceptance criterion 33.** That criterion is scoped to changed lines; neither
197 nor 206 is a changed line. The criterion remains checked. See the feature audit.

## Accepted Shipping Exception

`.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` ships at **83.33%**, below the 85%
uniform threshold, on account of the 15-line epic/parallel decision branch at lines **426-443**. This
reviewer proposed the exception in cycle 1 and **accepts it**. It is genuinely constrained by decision
D5: `.codex/config.toml` registers no `PreToolUse` matcher admitting an `Agent` or `Task` tool name,
so driving the branch requires fabricating an envelope for a path the Codex runtime never exercises.
It is tied to **issue #555** and is stated by name, line range, reason, and linkage in
`coverage-delta.2026-08-27T22-47.md` §5, not absorbed into an aggregate. **This must be disclosed in
the pull-request description.**

## Scope Constraints — verified independently

| Constraint | Method | Result |
| --- | --- | --- |
| Zero production `.ps1` changed by remediation | `git diff --name-only f24bbc7f..HEAD` filtered to non-test `.ps1` | **NONE** — PASS |
| Four mirrored pairs SHA-256 byte-identical per surface | `sha256sum` on all eight files | 4/4 **MATCH** — PASS |
| Mirror hashes equal to pre-remediation values | `git show f24bbc7f:<f>` vs `git show HEAD:<f>`, all eight | 8/8 **UNCHANGED** — PASS |
| Four `-helpers.ps1` byte-untouched | `git show 1e991b86:<f>` vs `git show HEAD:<f>` | 4/4 **UNTOUCHED** — PASS |
| Six pre-existing suites unmodified | absent from `git diff --name-only origin/main...HEAD` | PASS |
| Six pre-existing suites passing | `artifacts/pester/pester-junit.xml` | PASS |
| No `.claude/rules/`, `.claude/skills/`, `.github/instructions/`, `.github/copilot-instructions.md` | path filter over the branch diff | **NONE** — PASS |
| Exactly seven files under `extensions/drm-copilot/resources/` | count over the branch diff | **7** — PASS |

Measured mirror-pair hashes:

| Pair | SHA-256 |
| --- | --- |
| Claude `gate.ps1` | `0c8c55ce222ee9241b061a2964d5a0bb7154eb57f2b91a9d0f049b4da82b863e` |
| Claude `gate-modes.ps1` | `0ffab72ef27b3ae38f60a38dc1ba60a5f974fac91a4fa7d28f5094a790b455a4` |
| Codex `gate.ps1` | `b978bad8b304b2917afbe524f0043f5018ff0f06c7719a27550c6e888a3b706d` |
| Codex `gate-modes.ps1` | `8e1165818ae0ae20b63486d2aa51d98a7875fea9ba7d2f15e0762df850aa4f0a` |

The seven `extensions/drm-copilot/resources/` files are the two Claude hook copies, the two Codex hook
copies, the two pack manifests, and the bundled `pester.runsettings.psd1`.

## Test Results

`artifacts/pester/pester-junit.xml`: **3825 cases, 0 failures, 0 errors**, 119.1 s.

| Suite | Cases | Result |
| --- | --- | --- |
| `claude-hooks/…-gate.Tests.ps1` | 35 | pass |
| `claude-hooks/…-gate.CommandExemption.Tests.ps1` | 58 | pass |
| `claude-hooks/…-gate-absolute-paths.Tests.ps1` | 33 | pass |
| `claude-hooks/…-gate-mode-resolution.Tests.ps1` | 83 | pass |
| `claude-hooks/…-gate-classifier.Tests.ps1` (new) | 7 | pass |
| `codex-hooks/…-gate-command-exemption.Tests.ps1` | 58 | pass |
| `codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1` | 35 | pass |
| `codex-hooks/…-gate-mode-resolution.Tests.ps1` | 53 | pass |

The known issue #510 bundle-parity failure did not reproduce in this worktree.

## File-Size Cap

| File | Lines | vs 500 |
| --- | --- | --- |
| `.claude/…/gate.ps1` | 489 | PASS |
| `.claude/…/gate-modes.ps1` | 477 | PASS |
| `.codex/…/gate.ps1` | 495 | PASS |
| `.codex/…/gate-modes.ps1` | 477 | PASS |
| `claude-hooks/…-mode-resolution.Tests.ps1` | 494 | PASS |
| `claude-hooks/…-classifier.Tests.ps1` | 154 | PASS |
| `codex-hooks/…-mode-resolution.Tests.ps1` | 302 | PASS |

The four `extensions/` mirrors are byte-identical to their sources and carry the same counts.

## Change Budget

`.claude/rules/powershell.md` caps a batch at 3 production and 3 test files. Remediation cycle 1
touched **0 production and 2 test files**, inside one batch. PASS.

## Non-Blocking Findings

| ID | Item | Status |
| --- | --- | --- |
| N1 | Cycle-1: per-group uncovered counts inaccurate in `coverage-delta.2026-08-27T22-36.md` | **CLOSED** — corrected to 16/3/39/4 in the re-issued artifact, with the superseded artifact's two wrong locations named by line |
| N3 | `Find-OrchestrationDelegationIssueNumber` returns the *first* bare-hash match, so two hash numbers in one prompt make the resolved target order-dependent | **OPEN** — follow-up issue |
| N5 | Codex pack manifest omits `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`; verified pre-existing at the merge base, and it lists the helpers and modes files | **OPEN** — separate follow-up issue |
| N7 | `.codex/…/gate.ps1` is at 495 of 500 lines; `codex-hooks/legacy-codex-hook-contracts.Tests.ps1` is at 494 | **OPEN** — note for the next change to either file |
| N8 | The classifier suite comment at line 82 repeats the incorrect claim that the Codex copy "kept coverage" | **OPEN** — correct alongside B5 |

N6 from cycle 1 (the #510 failure not reproducing) is recorded in
`evidence/other/known-preexisting-failure-510.2026-08-26T11-36.md` and is closed.
