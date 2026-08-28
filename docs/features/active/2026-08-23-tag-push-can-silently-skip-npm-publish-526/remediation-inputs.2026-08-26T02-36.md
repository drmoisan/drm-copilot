# Remediation Inputs — Issue #526

- **Timestamp:** 2026-08-26T02-36
- **Branch:** `bug/tag-push-can-silently-skip-npm-publish-526` @ `d9c148a7`
- **Base:** `main` @ merge base `b36179b2`

## Source Artifacts

- `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/policy-audit.2026-08-26T02-36.md`
- `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/code-review.2026-08-26T02-36.md`
- `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/feature-audit.2026-08-26T02-36.md`

## Finding Counts

| Severity | Count |
|---|---|
| Blocking | 2 |
| Major | 3 |
| Minor | 6 |

---

## Remediation-Required Findings

### R1 — B1 (Blocking) — implement the per-check polling budgets from `spec.md` §3.4

**Files:** `scripts/dev-tools/Invoke-ReleaseVerification.ps1:445-477`,
`scripts/dev-tools/Invoke-ReleaseTagPush.ps1:244-250`

**Defect.** `Invoke-TagPublishVerification` accepts a single `$IntervalSeconds` / `$MaxAttempts`
pair and forwards it to check (a), check (b), and the check (c) loop.
`Invoke-ReleaseTagPushGuarded` calls it supplying neither, so the release path runs all three checks
at the module defaults of 10 s x 18 = 3 minutes.

| Check | `spec.md` §3.4 ceiling | Shipped | Shortfall |
|---|---|---|---|
| (a) run appears | 3 min | 3 min | none |
| (b) run reaches terminal conclusion | **20 min** | 3 min | 6.7x |
| (c) npm resolves exact version | **10 min** | 3 min | 3.3x |

**Impact.** A budget expiry on check (b) or (c) occurs *after* the mcp tag has been pushed and
possibly published. It returns `RUN_FAILED` / `UNRESOLVED` and aborts the release; a re-run then hits
the pre-push inverted check at `Invoke-ReleaseTagPush.ps1:198`, finds the version now resolving, and
returns `VERSION_CONSUMED_ELSEWHERE`, forcing another mcp version bump. That is the irreversible
version-number consumption the feature exists to prevent, reached by a false negative.

**Measured counter-evidence, recorded so the fix can be sized honestly.** Real run durations at
review time are 80 s (`publish-mcp-npm` run 32930241401) and 112 s (`publish-extension` run
32930239459) against a 170 s sleep budget. The margin is real but under 2x, and `spec.md` §8.1 sizes
the expected added CI cycle at 8-20 minutes.

**Suggested fix.** Give the composition entry point per-check budgets defaulted to the §4 table, and
forward them:

```powershell
[int]$RunIntervalSeconds  = 10, [int]$RunMaxAttempts  = 18,   # check (a)
[int]$StepIntervalSeconds = 20, [int]$StepMaxAttempts = 60,   # check (b)
[int]$NpmIntervalSeconds  = 15, [int]$NpmMaxAttempts  = 40    # check (c)
```

**Verification.** Add a test asserting the `MaxAttempts` forwarded to each of the three checks, so a
future regression is caught locally. No such test exists today, which is why this was not caught.

**Note on file size.** `Invoke-ReleaseVerification.ps1` is at 499 of 500 lines. This change adds
parameter lines, so it will breach the cap. The plan's recorded remedy applies: extract the five pure
helpers (`ConvertFrom-JsonSafely`, `Resolve-PublishStepConclusion`, `Get-RecoveryInstruction`,
`ConvertTo-VerificationResult`, `Get-CodexPinnedMcpVersion`) into a sibling module, register that
module in **both** `pester.runsettings.psd1` copies, and add its test file. Budget for the coverage
denominator to be re-partitioned, which invalidates the currently recorded per-file figures. Do not
condense comment-based help further; it is already at the limit of usefulness.

### R2 — B2 (Blocking) — obtain the green branch-head runs required by `modified-workflow-needs-green-run`

**Rule:** `.claude/skills/feature-review-workflow/SKILL.md:68-75`
**Affected files:** `.github/workflows/publish-mcp-npm.yml`,
`.github/workflows/verify-published-releases.yml`
**Related AC:** AC18 (unchecked, correctly)
**Existing artifact to update:**
`docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/qa-gates/green-branch-head-run.2026-08-26T02-05.md`

No code change is required. The design work that makes this rule satisfiable is already present and
correct (AC13-AC17 all PASS).

**Step 1 — `publish-mcp-npm.yml`, available now.** The branch head is on origin and this workflow
exists on the default branch with a `workflow_dispatch:` trigger, so the rule's own carve-out at
SKILL.md:74 applies:

```
gh workflow run publish-mcp-npm.yml --ref bug/tag-push-can-silently-skip-npm-publish-526
gh run list --workflow=publish-mcp-npm.yml --limit 5 --json databaseId,headBranch,headSha,conclusion,url
gh run view <RUN_ID> --json conclusion,jobs
```

Expected: conclusion `success` with the publish step, the version-equality step, and the registry
poll all `skipped`, because `github.ref` is `refs/heads/bug/...` and matches none of the three
`startsWith(github.ref, 'refs/tags/mcp-server-v')` guards. No version number is consumed.

**Step 2 — `verify-published-releases.yml`, blocked until the PR exists.** Verified:
`gh run list --workflow=verify-published-releases.yml` returns
`HTTP 404: workflow verify-published-releases.yml not found on the default branch`, so
`workflow_dispatch` cannot reach it. Its `pull_request` trigger produces the branch-head run once the
PR is opened. Expected conclusion `success` with the sweep step skipped by
`if: github.event_name != 'pull_request'`.

**Step 3.** Record both run URLs and step conclusions in the existing artifact, replacing the
`DEFERRED` literals, and check off AC18 in `spec.md`.

### R3 — M1 (Major) — distinguish check-(b) budget exhaustion from a failed run

**File:** `scripts/dev-tools/Invoke-ReleaseVerification.ps1:304`
**Also affects:** `docs/engineering/missed-npm-publish.runbook.md:56-67`,
`tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1:286-290`

`Test-PublishStepConclusion` returns `RUN_FAILED` on budget exhaustion, the same token a run that
concluded `failure` or `cancelled` produces. `spec.md` §3.4 requires: "An exhausted budget must be
reported as a state distinct from a negative result."

The consequence is operator misdirection. `Get-RecoveryInstruction` says "Read the run logs" and the
runbook defines `RUN_FAILED` as "A run existed for the tag ref and reached conclusion `failure` or
`cancelled`". Under exhaustion neither is true — the run was still in progress — and the correct
action (re-run the verifier) is not offered.

**Fix.** Introduce a distinct token, for example `RUN_INCOMPLETE`, with its own
`Get-RecoveryInstruction` entry and its own runbook section, and update the pinning test at `:286-290`
which currently locks the collapse in place. Adding a state token touches `spec.md` §3.2, so if that
is out of scope for this issue, file R3 as a follow-up and land R1 alone; R1 substantially reduces
how often the exhaustion path is reached.

### R4 — M2 (Major) — evidence AC21's network-isolation clause, or narrow the criterion

**AC:** AC21 (currently checked in `spec.md`)
**Artifact:**
`docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/qa-gates/test-purity.2026-08-26T02-05.md`

AC21's second clause is well evidenced and independently confirmed. Its first clause — "The complete
Pester suite passes with no network access available" — has no supporting evidence.

- SearchScope: `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/`
  (recursive, 28 artifacts)
- SearchPatterns: `network[- ](disabled|isolat|off|unavailable)`, `offline run`, `no network access`
  (case-insensitive)
- SearchResult: 0 matches

**Fix (preferred).** Run the suite once with network access removed and add the result to
`evidence/qa-gates/`. This is cheap and settles the clause for the whole suite rather than for the
five changed files.

**Fix (alternative).** If a network-isolated run is impractical in this environment, record that
explicitly in the purity artifact and state that the clause is evidenced by construction for the
change's own tests only. Do not leave the checkbox asserting more than the evidence supports without
a note.

The AC21 checkbox was deliberately **left checked** by this review rather than reverted, because
unchecking would discard verified work on clause 2. That decision is recorded in the feature audit.

### R5 — M3 (Major) — record the `Get-ReconciliationReport` deviation

**File:** `scripts/dev-tools/Invoke-ReleaseReconciliation.ps1:113-158`

The function is not specified by the plan (P5-T1 names only `Get-UnpublishedTagVersion` plus the
dot-source guard) and appears in **zero** files across the whole feature folder.

- SearchScope: `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/`
  (recursive)
- SearchPatterns: `Get-ReconciliationReport` -> 0 files; `deviation` under `evidence/` -> 0 files

**No code change.** The extraction is directly required by the Coverage Exclusion Policy in
`.claude/rules/general-unit-test.md` and raised the file from 70.83% to 88.89% by making logic
testable rather than by excluding anything. **Fix:** add a short deviation record under
`evidence/other/` naming the function, quoting the policy clause that motivated it, and recording the
coverage measurement — mirroring the existing
`evidence/other/marketplace-check-deferral.2026-08-26T02-05.md`.

---

## Minor Findings (not remediation-blocking)

Address at the maintainer's discretion, or file as follow-ups.

| ID | File / location | Summary |
|---|---|---|
| m1 | `Invoke-ReleaseVerification.ps1` (499), `Invoke-ReleaseTagPush.Tests.ps1` (491) | Within 10 lines of the 500-line cap. R1 forces the extraction for the first file. |
| m2 | `publish-mcp-npm.yml`, registry-poll step | `$version = '${{ steps... }}'` interpolates a GitHub expression into a PowerShell literal. Prefer `env:` plus `$env:PUBLISH_VERSION`. |
| m3 | `Invoke-ReleaseTagPush.ps1:48` | Dot-source imports the verification module's nine defaulted `param()` variables into the consumer's script scope. A `.psm1` would remove the coupling. |
| m4 | `Invoke-ReleaseTagPush.ps1:261` | Codex pin guard reads one of two committed `.codex/config.toml` copies. Copy equality is #522's; noted so the narrowing is visible. |
| m5 | `verify-published-releases.yml:66-70` | Comment claims `git ls-remote` exits non-zero with no matching tag; it exits 0 without `--exit-code`. Reset is harmless, reason is wrong. |
| m6 | Both workflow-invariant suites | Exit-code assertions are position-blind: they match `$LASTEXITCODE = 0` / `exit 0` + `exit 1` anywhere in the step rather than checking placement. |

---

## Confirmed Clean — do not re-litigate

Independently re-executed during this review; all reproduced exactly. These need no remediation
work.

| Area | Independent result |
|---|---|
| Pester suite | 3638 passed, 0 failed, 9 skipped (111.55 s) |
| PSScriptAnalyzer | `PSScriptAnalyzer passed: no findings` |
| Formatter idempotence | 8 of 8 changed `.ps1` files unchanged under `pssa.settings.psd1` |
| actionlint | exit 0 |
| Repo-wide coverage | 96.0543% (6792 / 7071, 84 sourcefiles) |
| Per-file coverage | 90.2174% / 97.4026% / 88.8889% — matches the recorded figures to the digit |
| Changed-line coverage | 100.0000% over 69 added lines |
| File sizes | 499, 278, 166, 346, 491, 89, 150, 106 — all <= 500 |
| Test purity | Zero matches for temp-path facilities and `Start-Sleep` across five test files |
| Evidence locations | `validate_evidence_locations.py --root .` exit 0; zero non-canonical paths in the diff |
| Scope boundaries | `README.md` untouched; `quality-tiers.yml` not added; `publish-extension.yml` untouched |
| Layer C wiring | Executed end to end: divergent exit 1, convergent exit 0, offline step reproduces the expected divergence |
| Workflow exit-code assertion | Falsifiability measured: a naked `pwsh` step fails the predicate |
| Uncovered lines | Enumerated independently; all 14 are wrapper-seam bodies or entry-point bodies |
