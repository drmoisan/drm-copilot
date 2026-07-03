# Policy Compliance Audit: parallel-ci-subworkflows (Issue #294)

**Audit Date:** 2026-07-03
**Code Under Test:** `.github/workflows/ci.yml`, `.github/workflows/_quality-checks.yml`,
`.github/workflows/_security-scan.yml`, `.github/workflows/_docs-validation.yml`,
`.github/workflows/_build-check.yml`, `.github/workflows/_poshqc.yml`,
`.github/workflows/_shell-coverage.yml`, `.github/workflows/_drm-copilot-extension-tests.yml`,
`.github/workflows/README.md`, and feature documentation under
`docs/features/active/2026-07-03-parallel-ci-subworkflows-294/`.

**Base branch:** `main` (merge-base `9a36e9b3dd9da626a33a45b2318165f5e49c69ec`)
**Head branch:** `feature/parallel-ci-subworkflows-294` (`5cd712c9d16d86c1f6cd122ab8c818f306c4c9e3`)
**Work Mode:** `full-feature` (per `issue.md`); AC sources: `spec.md` + `user-story.md`

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 0 files | N/A | N/A — no `.py` file in diff | N/A | N/A | N/A |
| TypeScript | 0 files | N/A | N/A — no `.ts` file in diff | N/A | N/A | N/A |
| PowerShell | 0 files | N/A | N/A — no `.ps1` file in diff | N/A | N/A | N/A |
| C# | 0 files | N/A | N/A — no `.cs` file in diff | N/A | N/A | N/A |
| GitHub Actions YAML | 8 files (7 new, 1 rewritten) | actionlint | PASS — 0 errors | N/A (no coverage concept for YAML) | N/A | N/A |

Verified independently: `git diff --stat 9a36e9b3dd9da626a33a45b2318165f5e49c69ec...5cd712c9d16d86c1f6cd122ab8c818f306c4c9e3`
shows the entire diff confined to `.github/workflows/**` and
`docs/features/active/2026-07-03-parallel-ci-subworkflows-294/**`. No `.py`, `.ts`, `.ps1`, or `.cs`
file appears anywhere in the diff. Per this workflow's coverage-verification procedure, coverage
artifacts (`coverage/lcov.info`, `artifacts/python/lcov.info`, `artifacts/pester/powershell-coverage.xml`,
`artifacts/csharp/coverage.xml`) are required only for languages with changed files in the branch
diff; since zero files changed for TypeScript, Python, PowerShell, and C#, the `N/A` verdicts above
are the acceptable form for those four languages under the workflow contract ("N/A ... acceptable
only for languages with zero changed files on the branch"). GitHub Actions YAML has no defined
coverage artifact/threshold in this repository's policy set; its verification surface is
`actionlint` plus a green workflow run, both evaluated below.

### Coverage Evidence Checklist

- TypeScript baseline/post-change coverage artifact: `N/A - zero changed .ts files in branch diff`
- Python baseline/post-change coverage artifact: `N/A - zero changed .py files in branch diff`
- PowerShell baseline/post-change coverage artifact: `N/A - zero changed .ps1 files in branch diff`
- C# baseline/post-change coverage artifact: `N/A - zero changed .cs files in branch diff`
- Per-language comparison summary: not applicable; see `## Coverage Verification` below for the
  explicit zero-changed-files determination per language.

**Fail-closed rule:** No coverage regression claim is made because no coverage-bearing language has
a changed file in this branch. This is a verified fact (`git diff --stat`), not an assumption.

---

## Rejected Scope Narrowing

No caller instruction in this delegation attempted to narrow scope to a plan/task/phase subset, to
mark any language "plan scope only," "out of scope," or "informational only" while it had changed
files, or to skip a toolchain/coverage check for a language with changed files. The delegating
prompt explicitly stated "Scope determination is your responsibility per your own scope invariant"
and did not attempt narrowing. Nothing to reject.

The feature's own `plan.2026-07-03T18-07.md` "Scope Statement" declares the Python/TypeScript/
PowerShell/C# toolchain loops "do not apply" to this change — this is not a caller-imposed
narrowing of reviewer scope; it is independently verified true by this audit's own `git diff --stat`
re-run against the resolved base/merge-base (see Coverage Verification below), so it is accepted as
a correct factual statement, not an attempted override of this audit's authority.

---

## Coverage Verification

Per-language determination, independently re-run against the resolved base branch:

- **Python:** `git diff --stat` shows 0 `.py` files. Verdict: **PASS** (N/A is the correct verdict
  for a language with zero changed files; no coverage artifact is required or expected).
- **TypeScript:** 0 `.ts` files changed. Verdict: **PASS** (same basis).
- **PowerShell:** 0 `.ps1` files changed. Verdict: **PASS** (same basis).
- **C#:** 0 `.cs` files changed. Verdict: **PASS** (same basis).
- **GitHub Actions (YAML):** 8 files changed/added. This language has no entry in the
  Coverage Artifact Paths table (TypeScript/Python/PowerShell/C# only) and no coverage concept
  applies to declarative workflow YAML. Its mandatory verification surface instead is (a)
  `actionlint` validity and (b) the `modified-workflow-needs-green-run` policy rule, both audited
  below under Sections 3 and 7.

Verification command re-run by this audit:
```
git diff --stat 9a36e9b3dd9da626a33a45b2318165f5e49c69ec...5cd712c9d16d86c1f6cd122ab8c818f306c4c9e3
```
Result: 26 files changed, all under `.github/workflows/**` or
`docs/features/active/2026-07-03-parallel-ci-subworkflows-294/**`.

---

## Executive Summary

This feature extracts the seven jobs of `.github/workflows/ci.yml` into seven callable reusable
workflows (`_<name>.yml`, each declaring `workflow_call` + `workflow_dispatch`) and rewrites
`ci.yml` into a thin orchestrator with no inline `steps:` and no `needs:` edges, matching the
`_npm-audit-gate.yml` precedent already in the repository. A new `.github/workflows/README.md`
documents per-stage dispatch and the required-status-check rename procedure. This is a
`.github/workflows/**`-only change; independently confirmed zero `.py`/`.ts`/`.ps1`/`.cs` files are
touched.

Independent re-verification (not just reading the executor's evidence files) confirmed:
- `actionlint` passes with 0 errors across all 8 touched workflow files (reproduced directly).
- Every extracted job's step content is byte-for-byte identical to the pre-extraction `ci.yml`
  (spot-checked against the merge-base copy of `ci.yml` for all seven jobs).
- The rewritten `ci.yml` contains zero `needs:` and zero `steps:` keys (reproduced via `grep`).
- `main` has no branch-protection rule configured (reproduced live via `gh api`), which is why the
  required-status-check "rename" risk described in `spec.md` is currently moot; this matches the
  feature's own baseline/reconciliation evidence exactly.
- **The `modified-workflow-needs-green-run` policy rule is not currently satisfied at the actual
  current branch head.** The evidence at `evidence/qa-gates/green-run-branch-head.2026-07-03T18-07.md`
  documents a green run at head SHA `574aaa2a086d77857a5cd7d46723f87e090558c2`. The current branch
  head is `5cd712c9d16d86c1f6cd122ab8c818f306c4c9e3` (one commit later — a docs-only evidence-file
  update per `git show --stat 5cd712c...`). A live query,
  `gh api repos/drmoisan/drm-copilot/commits/5cd712c9d16d86c1f6cd122ab8c818f306c4c9e3/check-runs`,
  returns `{"total_count":0,"check_runs":[]}`: **zero workflow runs exist against the current head
  SHA.** This is a Blocking finding — see Section 7 and the Compliance Verdict.

**Policy documents evaluated:**
- [✅] `.github/copilot-instructions.md` (tone; observed in this audit's own writing)
- [✅] `general-code-change.instructions.md`
- [✅] `general-unit-test.instructions.md` (N/A in substance — no test-bearing language changed)

**Language-specific policies evaluated:**
- [N/A] Python code-change/unit-test policy — 0 `.py` files in scope
- [N/A] PowerShell code-change/unit-test policy — 0 `.ps1` files in scope
- [N/A] TypeScript code-change/unit-test policy — 0 `.ts` files in scope
- [N/A] C# code-change/unit-test policy — 0 `.cs` files in scope
- [✅] `.github/instructions/github-actions.instructions.md` — evaluated in Section 3

**Temporary artifacts cleanup:**
- [✅] No temporary/one-time scripts were created during development; the feature's only file
  changes are the 8 workflow files, the README, and feature-folder documentation/evidence.

---

## 1. General Unit Test Policy Compliance

N/A in full. This feature contains no test-bearing production code in any language governed by
`general-unit-test.instructions.md` (Python/PowerShell/TypeScript/C#). No unit test was added,
modified, or required. The feature's actual verification surface (YAML validity + a green workflow
run) is audited under Sections 3 and 7, not this section.

| Requirement | Status | Evidence |
|------------|--------|----------|
| Independence / Isolation / Fast Execution / Determinism / Readability | N/A | No unit test file exists in this diff for any language governed by this policy. |
| Coverage requirements | N/A | No coverage-bearing language has a changed file (independently confirmed, see Coverage Verification). |

---

## 2. General Code Change Policy Compliance

### 2.1–2.4 Design, Structure, Naming

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | Each `_<name>.yml` is a minimal wrapper (`on: workflow_call/workflow_dispatch` + one job whose steps are lifted verbatim); `ci.yml` reduced to seven one-line `uses:` job bodies. |
| **Reusability** | PASS | Mirrors the existing `_npm-audit-gate.yml`/`npm-audit-gate.yml` reusable-workflow pattern already in this repository, rather than inventing a new shape. |
| **Extensibility** | PASS | Each callee independently declares `workflow_dispatch`, giving future callers a per-gate re-run entry point without touching the orchestrator. |
| **Separation of concerns** | PASS | Orchestration (`ci.yml`) is now fully separated from gate implementation (`_<name>.yml`); no inline `steps:` remain in the orchestrator (`grep -n "steps:" .github/workflows/ci.yml` → 0 matches, reproduced). |
| **File size (<500 lines)** | PASS | Largest new file, `_shell-coverage.yml`, is 86 lines; `ci.yml` is 31 lines. |
| **Naming** | PASS | `_<name>.yml` prefix convention matches the existing `_npm-audit-gate.yml` precedent. |

### 2.5 Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| Formatting | N/A | No formatter is defined for GitHub Actions YAML in this repository's toolchain; `actionlint` is the governing check (see Section 3). |
| Linting (`actionlint`) | **PASS** | Independently re-run: `pwsh -NoProfile -File ./scripts/dev-tools/run-actionlint.ps1 .github/workflows/ci.yml .github/workflows/_quality-checks.yml .github/workflows/_security-scan.yml .github/workflows/_docs-validation.yml .github/workflows/_build-check.yml .github/workflows/_poshqc.yml .github/workflows/_shell-coverage.yml .github/workflows/_drm-copilot-extension-tests.yml` → exit code 0, "Running actionlint..." with no errors reported. |
| Type checking | N/A | Not applicable to YAML. |
| Testing | N/A | No test suite applies to `.github/workflows/**`; the closest equivalent (a real workflow run) is audited under Section 7. |
| Full toolchain loop | PASS | Single-pass clean `actionlint` run; no restart was required. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3E: GitHub Actions Workflow Policy (`.github/instructions/github-actions.instructions.md`)

| Requirement | Status | Evidence |
|------------|--------|----------|
| Do not change overall job structure unless explicitly requested | PASS | The job-structure change (inline → `uses:` callee) is exactly the explicitly requested behavior of Issue #294; the seven job **names** and their `on:` trigger set for `ci.yml` are preserved unchanged. |
| Preserve existing `on:` triggers/branch filters/permissions unless intentional | PASS | `ci.yml`'s `on:` block (`push`/`pull_request` to `main`/`development`, `workflow_dispatch`) is byte-for-byte unchanged from the merge-base copy (verified via `git show 9a36e9b3d...:.github/workflows/ci.yml` comparison). |
| All workflows must pass `actionlint` | **PASS** | Reproduced directly (see 2.5 above), 0 errors across all 8 files. |
| Avoid constructs unsupported by `actionlint`/GitHub Actions | PASS | `strategy.matrix` is declared correctly inside each `workflow_call`-invoked job (`_quality-checks.yml`, `_drm-copilot-extension-tests.yml`), matching the `_npm-audit-gate.yml` precedent; no misplaced keys found by `actionlint`. |
| Keep jobs small and focused | PASS | Each reusable workflow now contains exactly one job matching its original scope. |

---

## 4. Language-Specific Unit Test Policy Compliance

N/A in full — no test-bearing language file is in scope for this feature (see Section 1 and
Coverage Verification).

---

## 5. Test Coverage Detail

N/A — no coverage-bearing language has a changed file. See Coverage Verification above for the
independently re-run diff-scope determination.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Unit tests (Python/TS/PowerShell/C#) | N/A | N/A — no test-bearing file in scope |
| `actionlint` errors | 0 (reproduced) | PASS |
| Green workflow run at **current** branch head | **0 runs found** (`total_count: 0` at SHA `5cd712c...`) | **FAIL** |

---

## 7. Code Quality Checks

**For GitHub Actions YAML:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| actionlint (all 8 files) | `pwsh -NoProfile -File ./scripts/dev-tools/run-actionlint.ps1 <8 files>` | Exit 0, no errors | PASS |
| `needs:` absent from `ci.yml` | `grep -n "needs:" .github/workflows/ci.yml` | 0 matches | PASS |
| `steps:` absent from `ci.yml` | `grep -n "steps:" .github/workflows/ci.yml` | 0 matches | PASS |
| Byte-for-byte step content preserved | Manual diff of each `_<name>.yml` job body against the merge-base `ci.yml` job block | Identical apart from indentation/wrapper shape, for all 7 jobs | PASS |
| **`modified-workflow-needs-green-run` (this workflow's own Policy Rule)** | `gh api repos/drmoisan/drm-copilot/commits/{current-head-sha}/check-runs` | `{"total_count":0,"check_runs":[]}` at the current branch head `5cd712c9d16d86c1f6cd122ab8c818f306c4c9e3` | **FAIL (Blocking)** |
| Branch-protection state, reconfirmed live | `gh api repos/drmoisan/drm-copilot/branches/main/protection/required_status_checks` | `{"message":"Branch not protected", ..., "status":"404"}` — matches the feature's own P0-T8 baseline and P4-T10 reconciliation exactly | PASS |
| Evidence-location compliance | `python scripts/dev_tools/validate_evidence_locations.py --root .` | Exit 0, no violations | PASS |

**Notes:**

The diff modifies `.github/workflows/**`, which triggers this workflow's `modified-workflow-needs-green-run`
policy rule: *"a diff under `.github/workflows/**` ... is Blocking unless evidence of a green workflow
run against the branch head is present"* where *"branch head"* is explicitly defined as *"a workflow
run whose head SHA matches the current branch head."*

The feature's own evidence (`evidence/qa-gates/green-run-branch-head.2026-07-03T18-07.md`) documents
a green run at head SHA `574aaa2a086d77857a5cd7d46723f87e090558c2`. That was the branch head at the
time evidence was captured. Since then, one additional commit (`5cd712c`, a docs-only update to the
same evidence files, re-titled "refresh green-run evidence for rebased head SHA") has landed, moving
the branch head to `5cd712c9d16d86c1f6cd122ab8c818f306c4c9e3`. Independently re-querying GitHub via
`gh api repos/drmoisan/drm-copilot/actions/runs` confirms the three most recent CI runs against this
branch are at head SHAs `574aaa2a...`, `1a9d2000...`, and `4125238f...` — none of them at the current
head SHA `5cd712c9...`. No workflow run of any kind exists against the current head.

Because the last commit is docs-only (it does not touch any `.github/workflows/**` file — confirmed
via `git show --stat 5cd712c9...`), the workflow YAML content that would actually execute is
identical to what ran successfully at `574aaa2a...`. This is a mitigating factor for risk, but it
does not satisfy the rule's literal text, which defines "branch head" as an exact head-SHA match,
not "logically equivalent content." This audit applies the rule as literally written rather than
inferring an exception for docs-only trailing commits, consistent with this repository's
demonstrated fail-closed posture on CI-gate provenance (see `.claude/rules/ci-workflows.md` and
`.claude/rules/benchmark-baselines.md`, both born from prior incidents of exactly this kind of
silent gap). Remediation is a low-cost, mechanical fix: re-dispatch `ci.yml` against the current
head and capture fresh evidence.

---

## 8. Gaps and Exceptions

### Identified Gaps

1. **`modified-workflow-needs-green-run` not satisfied at the current branch head.** No workflow
   run exists at head SHA `5cd712c9d16d86c1f6cd122ab8c818f306c4c9e3` (verified via
   `gh api repos/drmoisan/drm-copilot/commits/5cd712c9d16d86c1f6cd122ab8c818f306c4c9e3/check-runs` →
   `total_count: 0`). The most recent evidence is one commit stale. **Blocking** — routed to
   remediation (see `remediation-inputs.2026-07-03T23-36.md`).
2. **Seeded Test Condition "Each new `_<name>.yml` reusable workflow can be invoked standalone via
   `gh workflow run _<name>.yml`" is marked `[x]` in `spec.md` but was not literally achieved.** The
   feature's own evidence (`evidence/other/workflow-dispatch-substitution-note.2026-07-03T18-07.md`)
   documents a genuine, verified GitHub platform constraint (HTTP 404 — a workflow file must exist on
   the default branch before `gh workflow run <file>` can dispatch it by name) and a reasonable
   substitution (dispatching `ci.yml` itself, which exercises all seven callees via `uses:`). The
   substitution is accepted as adequate verification of execution correctness, but the literal
   criterion (standalone per-file `workflow_dispatch`) was not satisfied pre-merge. This is a
   **Minor, non-blocking** gap: it will resolve automatically once the branch merges to `main` and
   each `_<name>.yml` becomes independently dispatchable. See feature-audit for the checkbox
   correction.

### Approved Exceptions

**None.** No exceptions were requested or granted for this feature.

### Removed/Skipped Tests

**None.** No test was planned, removed, or skipped — no test-bearing language file is in scope.

---

## 9. Summary of Changes

### Commits in This Branch (relative to merge-base `9a36e9b3d`)

1. **`5d4bc52`** — ci: split ci.yml into parallel reusable subworkflows
2. **`574aaa2`** — docs(294): capture Phase 4 gh-dependent evidence and AC check-off
3. **`5cd712c`** — docs(294): refresh green-run evidence for rebased head SHA

### Files Modified

1. **`.github/workflows/ci.yml`** (MODIFIED) — reduced from 324 to 31 lines; now a thin orchestrator
   with seven `uses:` job bodies, no `needs:`, no inline `steps:`.
2. **`.github/workflows/_quality-checks.yml`** (NEW) — `quality-checks7` extracted, 4-way Python
   matrix preserved.
3. **`.github/workflows/_security-scan.yml`** (NEW) — `security-scan` extracted verbatim.
4. **`.github/workflows/_docs-validation.yml`** (NEW) — `docs-validation` extracted verbatim.
5. **`.github/workflows/_build-check.yml`** (NEW) — `build-check` extracted verbatim.
6. **`.github/workflows/_poshqc.yml`** (NEW) — `poshqc` extracted verbatim, including artifact upload.
7. **`.github/workflows/_shell-coverage.yml`** (NEW) — `shell-coverage` extracted verbatim, including
   cache and artifact-upload configuration.
8. **`.github/workflows/_drm-copilot-extension-tests.yml`** (NEW) — `drm-copilot-extension-tests`
   extracted verbatim, 2-way OS matrix preserved.
9. **`.github/workflows/README.md`** (NEW) — per-stage dispatch table, required-check rename
   procedure, scope-of-refactor statement.
10. **`docs/features/active/2026-07-03-parallel-ci-subworkflows-294/**`** (NEW) — feature
    documentation, plan, research, and evidence artifacts.

---

## 10. Compliance Verdict

### Overall Status: ⚠️ PARTIALLY COMPLIANT

The implementation itself (YAML structure, verbatim step preservation, `actionlint` cleanliness,
README documentation) is independently verified sound. The blocking gap is entirely evidentiary,
not implementational: the required green-run evidence for `modified-workflow-needs-green-run` is
one commit stale relative to the actual current branch head, and zero workflow runs exist at the
current head SHA.

**Fail-closed reminder honored:** this audit does not report PASS/ready-for-merge while a required
policy-rule check-run is absent at the current head.

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- ✅ Design Principles: simple, reusable, well-separated
- ✅ Module & File Structure: all files well under 500 lines
- ✅ Toolchain Execution: `actionlint` reproduced clean

#### Language-Specific Code Change Policy (Section 3)
- ✅ GitHub Actions workflow policy: triggers preserved, `actionlint` clean, matrix placement correct

#### General/Language-Specific Unit Test Policy (Sections 1, 4)
- N/A: no test-bearing language file in scope

#### Coverage Verification
- ✅ Python/TypeScript/PowerShell/C#: N/A verdict correct (zero changed files, independently confirmed)
- ⚠️ GitHub Actions YAML: no coverage concept; verification surface is `actionlint` (PASS) + green
  run (**FAIL** — see below)

### Metrics Summary

- ✅ 0 `actionlint` errors (reproduced)
- ✅ 0 `needs:`/`steps:` in rewritten `ci.yml` (reproduced)
- ✅ 7/7 extracted jobs verified byte-for-byte identical to source
- ❌ 0 workflow runs at the current branch head SHA (`5cd712c9...`) — required by
  `modified-workflow-needs-green-run`
- ✅ Evidence-location compliance: 0 violations (`validate_evidence_locations.py` exit 0)

### Recommendation

**Needs revision (Blocked pending remediation).** Re-dispatch `ci.yml` (or otherwise produce a
`push`/`pull_request`-triggered run) against the current branch head
(`5cd712c9d16d86c1f6cd122ab8c818f306c4c9e3`), confirm all 11 job runs conclude `success`, and
refresh `evidence/qa-gates/green-run-branch-head.*.md` (and, if the branch head moves again before
merge, repeat once more against the final head). This is a single, low-risk, mechanical
verification step; no code or workflow-file change is implicated.

---

## Appendix A: Test Inventory

N/A — no unit test file exists in this diff for any governed language.

---

## Appendix B: Toolchain Commands Reference

**For GitHub Actions workflows (this feature's actual verification surface):**
```bash
# YAML/actionlint validation (reproduced by this audit, exit 0)
pwsh -NoProfile -File ./scripts/dev-tools/run-actionlint.ps1 \
  .github/workflows/ci.yml \
  .github/workflows/_quality-checks.yml \
  .github/workflows/_security-scan.yml \
  .github/workflows/_docs-validation.yml \
  .github/workflows/_build-check.yml \
  .github/workflows/_poshqc.yml \
  .github/workflows/_shell-coverage.yml \
  .github/workflows/_drm-copilot-extension-tests.yml

# Structural checks (reproduced by this audit)
grep -n "needs:" .github/workflows/ci.yml   # 0 matches
grep -n "steps:" .github/workflows/ci.yml   # 0 matches

# Green-run verification (reproduced by this audit; shows the gap)
gh api repos/drmoisan/drm-copilot/actions/runs \
  --paginate -q '.workflow_runs[] | select(.head_branch=="feature/parallel-ci-subworkflows-294") | {id, head_sha, name, status, conclusion, created_at}'
gh api repos/drmoisan/drm-copilot/commits/5cd712c9d16d86c1f6cd122ab8c818f306c4c9e3/check-runs
# -> {"total_count":0,"check_runs":[]}

# Branch protection re-check (reproduced by this audit; confirms no drift)
gh api repos/drmoisan/drm-copilot/branches/main/protection/required_status_checks
# -> {"message":"Branch not protected", ..., "status":404}

# Evidence-location compliance (reproduced by this audit)
python scripts/dev_tools/validate_evidence_locations.py --root .
```

---

**Audit Completed By:** feature-review agent (Claude Sonnet 5)
**Audit Date:** 2026-07-03
**Policy Version:** Current (as of audit date)
