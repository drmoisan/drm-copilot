# Policy Audit — issue #554, remediation cycle 2 exit re-audit

- Timestamp: 2026-08-28T02-02
- Branch: `bug/preimplementation-gate-blocks-epic-execution-554-r3` at `2c8f2ffc`
- Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a502f12120e44837d` (adopted worktree, not the session root)
- Working tree: clean; `HEAD` equals `origin/bug/preimplementation-gate-blocks-epic-execution-554-r3`
- Scope base: `git diff origin/main...HEAD` (`origin/main` at `c62af7a7`, which is an ancestor of `HEAD`)
- Changed-line anchor: the pinned constant `1e991b86d78e4f979922b79268f19ca0e5ab19e3`, verified an ancestor of `HEAD` by `git merge-base --is-ancestor` (exit 0)
- Work mode: `full-bug` (`issue.md` line 4, `- Work Mode: full-bug`); sole AC source `spec.md`
- Supersedes: `policy-audit.2026-08-28T00-30.md` (retained) and `policy-audit.2026-08-27T22-47.md` (retained, corrected by appended notice)

## Verdict Summary

| Area | Verdict |
| --- | --- |
| Tone policy | PASS |
| General code-change policy | PASS |
| General unit-test policy | PASS |
| PowerShell language policy | PASS |
| Coverage — PowerShell, repo-wide | **PASS** (94.7071%) |
| Coverage — new files | **PASS** (98.4848% each) |
| Coverage — modified files vs the 85% uniform threshold | **PARTIAL** — one named, accepted, PR-disclosed exception (issue #555) |
| Coverage — no regression on changed lines | **PASS** |
| Coverage — no regression on pre-existing lines | **PASS** — B5 closed |
| Coverage — TypeScript / Python / C# | N/A — zero changed files of those languages on the branch |
| Evidence location compliance | PASS |
| Blast-radius declaration | PASS |
| Policy-path immutability | PASS |
| Change-budget compliance | PASS |
| File-size cap (500 lines) | PASS |
| Determinism infrastructure in the new test code | PASS |

**Blocking findings: 0. Non-blocking findings: 5 carried forward, 1 new (N10).**

`remediation-inputs.2026-08-28T02-02.md` is **deliberately not written**, because there are zero
blocking findings.

## Rejected Scope Narrowing

The caller wrote, verbatim:

> YOU HAVE AUDITED THIS BRANCH TWICE. Cycle 1 closed your findings B1 through B4. Cycle 2 was opened
> by your single finding B5 and has now executed `remediation-plan.2026-08-28T00-30.md`, 34 tasks,
> test-only. Verify closure; do not re-derive the whole review.

That instruction is recorded here because the scope invariant requires any apparent narrowing to be
logged verbatim. It was read as **efficiency guidance, not a scope limit**, and it was not treated as
authorising any reduction of coverage scope: the caller separately directed evaluation of all 35
acceptance criteria, of every listed scope constraint, and of the `origin/main` merge. The audit
performed here is the **full branch diff against the resolved base**: 133 changed files, every
acceptance criterion, and every language with changed files. Nothing was excluded and no language
coverage verdict was suppressed.

**Languages with changed files on this branch**, from `git diff --name-only origin/main...HEAD`:

| Extension | Count | Coverage obligation |
| --- | --- | --- |
| `.md` | 118 | none — documentation |
| `.ps1` | 11 | **PowerShell — measured, verdict below** |
| `.psd1` | 2 | PowerShell data (Pester runsettings); not executable, not measured |
| `.json` | 2 | configuration (pack manifests); not a coverage language |

`git diff --name-only origin/main...HEAD | grep -Ei '\.(ts|tsx|py|cs|js|mjs|cjs|sh|bash)$'` returns
**no matches** (exit 1). TypeScript, Python, C#, JavaScript, and bash therefore have **zero changed
files on this branch**, which is the only condition under which an `N/A` verdict is permitted. No
coverage artifact is required for them and their absence is not a finding.

## Evidence Location Compliance

`python scripts/dev_tools/validate_evidence_locations.py --root .` exits **0**.

`git diff --name-only origin/main...HEAD | grep -E '^artifacts/(baselines|qa|evidence|coverage)/'`
returns **no matches**. Every evidence artifact this branch writes sits under
`docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/<kind>/` across the
six declared kinds (`baseline`, `remediation-baseline`, `qa-gates`, `regression-testing`,
`issue-updates`, `other`), which is the canonical scheme of
`.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.

The caller supplied no non-canonical evidence path, so no `EVIDENCE_LOCATION_OVERRIDE_REJECTED`
record is required. **PASS.**

## Coverage Verification — measured independently

Coverage was verified by parsing `artifacts/pester/powershell-coverage.xml` directly with an
independent per-line probe. No coverage run was re-executed, per the evidence-verification model.

**Artifact currency.** The report root carries `<report name="Pester (08/28/2026 01:42:29)">`. That is
after the last commit that changed a `.ps1` file (`a9db81d0`, 01:38:23) and before the final
documentation-only commit (`2c8f2ffc`, 01:54:35). The artifact therefore reflects the final test
state of `HEAD`.

### Repository-wide, PowerShell

| Counter | Covered | Missed | Total | Percentage |
| --- | --- | --- | --- | --- |
| LINE | 7211 | 403 | 7614 | **94.7071%** |

Threshold 85%. **PASS**, margin +9.71 pp, and +0.03 pp above the cycle-2 baseline of 94.6809%
(7209 covered), the +2 lines B5 closed.

Pester measures command (instruction) and line coverage only and produces no branch figure, so no
branch percentage exists to evaluate and no branch threshold applies
(`.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md`). An absent PowerShell branch figure
is **not** recorded as FAIL.

### Per-file, the four production files

| File | Covered | Missed | Total | Line % | Tier verdict |
| --- | --- | --- | --- | --- | --- |
| `.claude/hooks/…-gate.ps1` (modified) | 132 | 18 | 150 | **88.0000%** | PASS |
| `.claude/hooks/…-gate-modes.ps1` (new) | 130 | 2 | 132 | **98.4848%** | PASS |
| `.codex/hooks/…-gate.ps1` (modified) | 137 | 25 | 162 | **84.5679%** | Named issue #555 exception |
| `.codex/hooks/…-gate-modes.ps1` (new) | 130 | 2 | 132 | **98.4848%** | PASS |

The four `-helpers.ps1` copies measure 112 of 118 = 94.9153% and are byte-untouched by this branch.

**New files** (`-modes.ps1`, both surfaces) clear the 85% uniform line threshold and also clear the
90% figure named in the reviewer procedure. **PASS.**

**Modified files:** the Claude gate hook clears 85%. The Codex gate hook sits at 84.5679%, 0.43 pp
below the uniform threshold — the accepted issue #555 shipping exception, adjudicated below.

### Independent per-line probe of the two lines B5 concerned

Read from the `line` elements of `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`:

| Line | `mi` | `ci` | Verdict |
| --- | --- | --- | --- |
| **197** — `return $false`, the non-`orchestrator` branch | 0 | **1** | **COVERED** |
| **206** — `return $true`, the all-conjuncts-hold return | 0 | **1** | **COVERED** |

### Measured missed sets

| File | Missed lines |
| --- | --- |
| `.claude/…/gate.ps1` | 125, 252, 253, 255, 266, 267, 268, 270, 278, 279, 280, 282, 408, 425, 485, 486, 487, 490 |
| `.claude/…/gate-modes.ps1` | 94, 95 |
| `.codex/…/gate.ps1` | 292, 293, 294, 296, 304, 305, 306, 308, 421, 422, 426, 427, 428, 429, 430, 432, 433, 434, 435, 436, 437, 439, 441, 442, 443 |
| `.codex/…/gate-modes.ps1` | 94, 95 |

The Codex missed set is **exactly the 25 members predicted by `remediation-inputs.2026-08-28T00-30.md`
and required by `[P3-T6]`**, beginning at 292. Neither 197 nor 206 appears. This reproduces the
caller's own measurement of 137/162 = 84.57% with a missed set beginning at 292.

### Changed-line partition, computed against the pinned anchor

Computed by intersecting each file's measured missed set with the added-line set of
`git diff -U0 1e991b86d78e4f979922b79268f19ca0e5ab19e3 -- <path>`. The anchor is the pinned constant,
never `git merge-base HEAD origin/main` (which the `origin/main` merge moved to `c62af7a7`).

| File | Changed lines vs anchor | Uncovered **changed** | Uncovered **pre-existing** |
| --- | --- | --- | --- |
| `.claude/…/gate.ps1` | 120 | **9** — 266, 267, 268, 270, 278, 279, 280, 282, 408 | 9 — 125, 252, 253, 255, 425, 485, 486, 487, 490 |
| `.codex/…/gate.ps1` | 125 | **25** — the full missed set above | **0** |

Membership test for the two B5 lines against the Codex added-line set: **197 is a pre-existing line;
206 is a pre-existing line.** Neither is a changed line. This is the measurement that makes the
criterion's literal text hold and that makes the `[P6-T6]` disposition correct.

Both the 120/125 changed-line counts and the 9/25 uncovered-changed counts reproduce
`coverage-delta.2026-08-28T00-30.md` §6 exactly.

## B5 Closure — both halves

### Half 1 — the coverage gap: **CLOSED**

Verified by the independent per-line probe above. Lines 197 and 206 both read `ci="1"`. The file rose
from 135/162 = 83.3333% to **137/162 = 84.5679%**, +1.24 pp, and its uncovered pre-existing count
fell from 2 to **0**.

The closing work is a new `Context 'the preparation-mode delegation predicate on the Codex surface'`
at `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`
lines 270-298, carrying two `It` blocks that call `Test-PreparationModeDelegation` directly with
literal `[pscustomobject]` fixtures. The suite reports **55 cases, 0 failures** in
`artifacts/pester/pester-junit.xml`, which is the 53 of cycle-1 exit plus two.

Decision D5 is correctly not engaged: the predicate takes a `[pscustomobject]` and returns a `[bool]`,
constructs no `Agent` envelope, and claims no transport.

### Half 2 — the false factual claim: **CLOSED in all three propagation sites**

| Site | Method specified | Method verified applied |
| --- | --- | --- |
| `policy-audit.2026-08-27T22-47.md` | appended, dated correction notice; prior text byte-untouched | **CONFIRMED** |
| `evidence/qa-gates/r1-acceptance-criterion-reevaluation.2026-08-27T22-47.md` | appended, dated correction notice; prior text byte-untouched | **CONFIRMED** |
| `tests/scripts/claude-hooks/…-gate-classifier.Tests.ps1` comment | in-place rewrite | **CONFIRMED** |

**Byte-untouchedness, verified independently by count-free prefix comparison.** The prior blob was
read at `093315b2` (the parent of the appending commit `a9db81d0`), the current blob at `HEAD`, and
the first `len(prior)` bytes of the current blob were compared with `cmp`:

| Artifact | Prior bytes | Current bytes | Appended bytes | Prefix comparison |
| --- | --- | --- | --- | --- |
| `policy-audit.2026-08-27T22-47.md` | 20856 | 22759 | 1903 | **BYTE-IDENTICAL** |
| `evidence/qa-gates/r1-acceptance-criterion-reevaluation.2026-08-27T22-47.md` | 7915 | 9984 | 2069 | **BYTE-IDENTICAL** |

The comparison is blob-to-blob, so it is unaffected by end-of-line conversion on checkout, and it
names no line number, so it covers every byte of each prior artifact rather than a prefix of N lines.

**Remainder content, verified.** The trailing 1903 and 2069 bytes were read and are, in each case,
**solely** the correction block specified by `[P2-T1]` and `[P2-T2]`, preceded by one blank line and a
`---` rule. No other text was added.

**In-place rewrite, verified.** `git show a9db81d0 -- <classifier tests>` shows a single hunk at
`@@ -78,11 +78,16 @@` replacing five comment lines with ten. No line outside the comment block
differs. The current file contains `PARTIAL` at line 81 and no longer contains the phrase
`kept coverage from` (grep exit 1). The suite reports **7 cases, 0 failures**, unchanged by a
comment-only edit.

**Method adjudication.** The two methods are correctly assigned. A superseded evidence artifact is an
audit record whose function is to preserve what was believed and when, so an appended notice is the
right instrument and a rewrite would destroy the record. A live source comment has no audit-trail
function and its only obligation is to be true for a reader of the current file, so an in-place
rewrite is the right instrument and an appended notice would leave a false statement standing.
`git` preserves the superseded comment text.

## Coverage Regression Analysis

`.claude/rules/general-unit-test.md` requires that a change not reduce coverage for the lines it
changed, and `.claude/rules/quality-tiers.md` restates it as "no regression on changed lines".

- **On changed lines:** all 34 uncovered changed lines (9 Claude, 25 Codex) are **added** lines, which
  had no base coverage to lose. **PASS.**
- **On pre-existing lines:** the branch orphaned `Test-PreparationModeDelegation` on both surfaces,
  which cost 10 Claude lines (cycle-1 finding B2, closed) and 2 Codex lines (cycle-2 finding B5, now
  closed). Both losses are restored. The Claude gate's remaining 9 uncovered pre-existing lines
  (125, 252, 253, 255, 425, 485, 486, 487, 490) were uncovered at the anchor as well and are outside
  the scope of this change. **PASS.**

## Accepted Shipping Exception — issue #555

`.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` ships at **84.5679%**, below the 85%
uniform line threshold of `.claude/rules/quality-tiers.md`.

**Name:** the Codex epic/parallel decision branch.
**Line range:** lines **426 through 443**, 15 measurable lines —
`426, 427, 428, 429, 430, 432, 433, 434, 435, 436, 437, 439, 441, 442, 443`.
**Reason:** driving the branch requires constructing a delegation payload for the Codex decision
function, which decision **D5** prohibits because `.codex/config.toml` registers no `PreToolUse`
matcher admitting an `Agent` or `Task` tool name. Fabricating that envelope would assert a transport
the Codex runtime never exercises.
**Linkage:** **issue #555** owns the transport gap and is explicitly out of scope for issue #554.

**The shortfall is wholly owned by this exception.** Of the 25 residual missed lines, 15 are these;
covering them alone would take the file to 152/162 = 93.83%, above the threshold. B5 raised the file
from 83.33% to 84.57% and could not remove the shortfall, because B5 concerned two pre-existing lines
elsewhere in the file.

This reviewer **proposed the exception in cycle 1 and accepted it in cycle 2. It is accepted again
here, unchanged.** It is preserved by name, line range, and #555 linkage in
`evidence/qa-gates/coverage-delta.2026-08-28T00-30.md` §5, stated as its own named exception and not
absorbed into an aggregate. **It must be disclosed in the pull-request description.** The exact
wording to use is given in the Output Summary of this audit and in `feature-audit.2026-08-28T02-02.md`.

Verdict on this line: **PARTIAL, not FAIL**, and explicitly **not a blocking finding**. Re-raising it
would contradict this reviewer's own prior adjudication and would block on a condition decision D5
genuinely constrains.

## Scope Constraints — verified independently

| Constraint | Method | Result |
| --- | --- | --- |
| Zero production `.ps1` changed by cycle 2 | `git show --name-only` over each of the eight post-cycle-1 commits | **NONE** — the only two `.ps1` paths touched are `tests/scripts/codex-hooks/…-mode-resolution.Tests.ps1` and `tests/scripts/claude-hooks/…-classifier.Tests.ps1`, both created by this branch — PASS |
| Production `.ps1` unchanged since cycle-1 exit | blob-id equality `git rev-parse 3140652d:<f>` vs `HEAD:<f>` on all eight mirrored files | 8/8 **SAME** — PASS |
| Four mirrored pairs SHA-256 byte-identical per surface | `Get-FileHash -Algorithm SHA256` on all eight | 4/4 **EQUAL** — PASS |
| Mirror hashes equal to pre-remediation values | measured hashes vs those recorded in `policy-audit.2026-08-28T00-30.md` | 4/4 **MATCH** — PASS |
| Four `-helpers.ps1` copies byte-untouched | absent from `git diff --name-only origin/main...HEAD` and from `1e991b86..HEAD`; all four SHA-256 equal | 4/4 **UNTOUCHED** — PASS |
| Six pre-existing suites unmodified | absent from `git diff --name-only origin/main...HEAD` | **NONE PRESENT** — PASS |
| Six pre-existing suites passing | `artifacts/pester/pester-junit.xml` per-suite counters | 35 / 58 / 33 / 58 / 15 / 43 cases, **0 failures each** — PASS |
| No `.claude/rules/`, `.claude/skills/`, `.github/` file | path filter over `git diff --name-only origin/main...HEAD` | **NONE** — PASS |
| Exactly seven files under `extensions/drm-copilot/resources/` | count over `git diff --name-only origin/main...HEAD` | **7** — PASS |

Measured mirror-pair hashes, all four equal per surface and equal to their pre-remediation values:

| Pair | SHA-256 |
| --- | --- |
| Claude `gate.ps1` | `0c8c55ce222ee9241b061a2964d5a0bb7154eb57f2b91a9d0f049b4da82b863e` |
| Claude `gate-modes.ps1` | `0ffab72ef27b3ae38f60a38dc1ba60a5f974fac91a4fa7d28f5094a790b455a4` |
| Codex `gate.ps1` | `b978bad8b304b2917afbe524f0043f5018ff0f06c7719a27550c6e888a3b706d` |
| Codex `gate-modes.ps1` | `8e1165818ae0ae20b63486d2aa51d98a7875fea9ba7d2f15e0762df850aa4f0a` |

The four `-helpers.ps1` copies all measure `45c339fd4b4b1702230518b6fcdeb863a08bcb7a7540f46c5f7851c730765c0b`.

The seven `extensions/drm-copilot/resources/` files are the two Claude hook copies, the two Codex hook
copies, the two pack manifests, and the bundled `pester.runsettings.psd1`. This is the count against
`origin/main...HEAD`, which is the branch's own writes. A two-dot diff `3140652d..HEAD` additionally
reports `resources/claude-customizations/.claude/rules/plan-acceptance-gates.md` and
`resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md`; **both arrived from the
`origin/main` merge of PR #571 and are not this branch's writes.** This is exactly why the constraint
must be evaluated on the three-dot form.

## The `origin/main` Merge — no regression introduced

`13d68f8a` merged `origin/main` (`c62af7a7`, PR #571, the plan-acceptance-gates feature) into this
branch. Parents: `85277762` (branch) and `c62af7a7` (main).

`git diff --name-only 13d68f8a^1 13d68f8a` restricted to
`docs/features/active/preimplementation-gate-blocks-epic-execution-554/`, `.claude/hooks/`,
`.codex/hooks/`, `tests/scripts/claude-hooks/`, `tests/scripts/codex-hooks/`, `scripts/powershell/`,
`extensions/drm-copilot/resources/powershell/`, and both mirrored hook directories returns
**empty output**. The merge changed nothing on any surface this feature owns.

Consequences, each verified rather than inferred:

- The four mirror pairs are byte-identical and unchanged since cycle-1 exit (blob-id equality above).
- The six pre-existing suites remain absent from the branch diff and pass (0 failures each).
- The two `pester.runsettings.psd1` copies still carry all six `CodeCoverage.Path` entries at lines
  131/135/139 and 206/210/214, byte-parallel across the two copies.
- PR #571 added plan-acceptance gates G1-G6 as validator logic invoked only against an artifact a
  caller points it at. `.claude/rules/plan-acceptance-gates.md` states the scope explicitly: no CI
  job, test, or scheduled task sweeps the committed plan corpus, and none is added. This feature's
  `plan.2026-08-26T08-40.md` is therefore never evaluated by it, and no grandfathering or suppression
  mechanism is needed or used.
- No policy file under `.claude/rules/` or `.claude/skills/` appears in this branch's own diff; the
  two that PR #571 changed arrived from main and are outside this branch's writes.

**No regression. PASS.**

## Change Budget

`.claude/rules/powershell.md` caps a batch at 3 production and 3 test PowerShell files. Remediation
cycle 2 touched **0 production and 2 test files**, inside a single batch, with one budget reset
recorded at `[P1-T1]`. **PASS.**

## File-Size Cap (500 lines)

| File | Lines | vs 500 |
| --- | --- | --- |
| `.claude/…/gate.ps1` | 489 | PASS |
| `.claude/…/gate-modes.ps1` | 477 | PASS |
| `.codex/…/gate.ps1` | 495 | PASS |
| `.codex/…/gate-modes.ps1` | 477 | PASS |
| `claude-hooks/…-mode-resolution.Tests.ps1` | 494 | PASS |
| `claude-hooks/…-classifier.Tests.ps1` | 159 | PASS |
| `codex-hooks/…-mode-resolution.Tests.ps1` | 332 | PASS |

The four `extensions/` mirrors are byte-identical to their sources and carry the same counts. The
cycle-2 edits raised the classifier suite 154 → 159 and the Codex mode-resolution suite 302 → 332.
Non-blocking N7 (the 495- and 494-line files) is unaffected and remains open.

## Toolchain Loop

The mandatory PowerShell loop ran in a single uninterrupted pass at iteration 1:

| Order | Stage | Outcome | Artifact |
| --- | --- | --- | --- |
| 1 | format | `EXIT_CODE: 0`; 0 files reformatted; post-run `git status --porcelain` empty | `r2-final-poshqc-format.2026-08-28T00-30.md` |
| 2 | analyze | `EXIT_CODE: 0`; `PSScriptAnalyzer passed: no findings`; 0 findings | `r2-final-poshqc-analyze.2026-08-28T00-30.md` |
| 3 | type check | not applicable to PowerShell; recorded, not run | `r2-final-typecheck-not-applicable.2026-08-28T00-30.md` |
| 4 | test with coverage | `EXIT_CODE: 0` | `r2-final-poshqc-test-coverage.2026-08-28T00-30.md` |

Independently corroborated from `artifacts/pester/pester-junit.xml`: **3827 cases, 0 failures,
0 errors, 9 skipped**, 115.6 s. The executor's "3818 passed" plus 9 skipped reconciles to 3827.
Architecture-boundary, contract-schema, and integration stages are not applicable to a PowerShell
hook change and are correctly not run. **PASS.**

## Determinism and Test Policy

The two edited suites contain no `Start-Sleep`, `New-TemporaryFile`, `$env:TEMP`, `TestDrive`,
`Get-Date`, `Get-Random`, `Invoke-WebRequest`, `Out-File`, `Set-Content`, or `New-Item`, and the Codex
suite uses no `Mock`. Both new cases build a literal `[pscustomobject]` in the case body and call a
pure predicate. No temporary file is created, no filesystem is touched, no wall-clock is read, and no
external process is invoked. Test files sit under `tests/` mirroring the production tree, not
colocated. **PASS** against `.claude/rules/general-unit-test.md`.

## Coverage Exclusion Policy

No `exclude` entry matching a production source path was added or is present in either
`pester.runsettings.psd1` copy. All four production hook files and all four `-helpers.ps1` copies
appear in the coverage report as `sourcefile` elements with measured lines. **PASS.**

Observation, not a finding: the four `extensions/drm-copilot/resources/` hook mirrors are not
separately instrumented. They are byte-identical copies of measured sources, verified by SHA-256, and
this is the repository's pre-existing convention for the entire payload tree. It was settled in cycle
1 and is not reopened here.

## Non-Blocking Findings

| ID | Item | Status |
| --- | --- | --- |
| N3 | `Find-OrchestrationDelegationIssueNumber` returns the *first* bare-hash match, so two hash numbers in one prompt make the resolved target order-dependent | **OPEN** — follow-up issue |
| N5 | Codex pack manifest omits `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`; verified pre-existing at the anchor, and it does list the helpers and modes files | **OPEN** — separate follow-up issue |
| N7 | `.codex/…/gate.ps1` at 495 of 500 and `codex-hooks/legacy-codex-hook-contracts.Tests.ps1` at 494 | **OPEN** — a sibling file will be required for the next change to either |
| N8 | The classifier suite comment repeated the incorrect "kept coverage" claim | **CLOSED** — rewritten in place at `[P2-T3]`; the phrase is absent from the file |
| N9 | `Test-PreparationModeDelegation` is now dead code on both surfaces, its coverage maintained by tests alone, and the preparation-marker rule has two independent implementations in one file | **OPEN** — follow-up refactor; out of scope because `spec.md` lists the function under "Not modified" |
| **N10** | **New.** Ten cycle-2 evidence artifacts carry internal `Timestamp:` values later than the commit that introduced them. `2c8f2ffc` was authored at `01:54:35`, yet `r2-final-poshqc-test-coverage` reads `02-02`, `r2-final-single-pass-confirmation` `02-04`, `r2-codex-gate-coverage-probe` `02-06`, `coverage-delta` `02-09`, `r2-false-claim-corrections` `02-12`, `r2-preexisting-suites` `02-15`, `r2-no-production-change` `02-18`, `r2-policy-paths-untouched` `02-21`, `r2-mirror-pair-hashes` `02-23`, `r2-spec-and-plan-untouched` `02-25`, `r2-blast-radius-conformance` `02-28`, `r2-blast-radius-amendment` `02-30`, and `r2-remediation-closeout` `02-32`. The values increase monotonically in task order at a near-constant interval, which is the signature of a synthetic sequence rather than a clock read. **Non-blocking:** every load-bearing measurement in those artifacts was independently reproduced here and is correct; the defect is records accuracy, not measurement accuracy. Recommended: read the clock per artifact in future cycles | **OPEN** — advisory |

Also recorded, minor and non-blocking: `policy-audit.2026-08-28T00-30.md` refers to the coverage
criterion as "acceptance criterion 33" in one sentence; it is the 28th criterion (`spec.md` line 932).
The artifact is superseded and the substantive verdict is unaffected, so no correction notice is
required.

## Timestamp Ordering Note

This audit is stamped `2026-08-28T02-02`, the true wall-clock reading at the time it was written. Ten
cycle-2 evidence artifacts self-report internal timestamps between `02-02` and `02-32`, which are
forward-dated relative to both the commit that contains them and this clock — see N10. This audit's
filename timestamp is therefore genuine, distinct from the `2026-08-27T22-47` and `2026-08-28T00-30`
sets, and does not overwrite either.

## Policy Reading Order Observed

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/powershell.md`
5. `.claude/rules/quality-tiers.md`
6. `.claude/rules/plan-acceptance-gates.md`
7. `.claude/rules/parallel-orchestration.md`
8. `.claude/rules/tonality.md`

No policy document was modified by this audit or by the branch.

## Output Summary

**Zero blocking findings.** B5 is closed in both halves, verified independently: lines 197 and 206 of
the Codex gate hook read `ci="1"`, the file measures 137/162 = 84.5679% with a missed set of exactly
the 25 predicted lines beginning at 292, and the three false-claim sites are corrected by the two
methods specified, with both appended notices proven byte-exact prefixes of their prior blobs and the
source comment rewritten in place. Repository-wide PowerShell line coverage is 94.7071%. All scope
constraints hold: zero production `.ps1` touched by cycle 2, four mirror pairs byte-identical and
unchanged, four `-helpers.ps1` copies untouched, six pre-existing suites unmodified and passing, no
policy-path file written, exactly seven `extensions/drm-copilot/resources/` files. The `origin/main`
merge of PR #571 disturbed none of this feature's surfaces. One accepted shipping exception persists —
the Codex gate hook at 84.5679% on the 15-line decision-D5-constrained epic/parallel branch at lines
426-443, tied to **issue #555** — and **must be disclosed in the pull-request description**.
`remediation-inputs.2026-08-28T02-02.md` is deliberately not written. EXIT_CODE 0.
