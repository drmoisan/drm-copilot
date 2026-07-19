# Policy Audit — legacy-discovery-validators (#361) — Remediation Cycle 1 Exit Reaudit

- Timestamp: 2026-07-18T17-05
- Scope: full branch diff of `feature/legacy-discovery-validators-361` against
  `origin/epic/legacy-discovery-and-parity-integration` (merge-base
  `f18c1c16f3eb111f0acef5eb3c46be1fb563aac0`), with specific focus on the
  remediation-cycle-1 delta (`d580d5a5..HEAD`) that this reaudit is closing
  out. This is a reaudit of remediation cycle 1, not a rescoped or partial
  review; the prior full-feature policy audit
  (`policy-audit.2026-07-18T16-04.md`) already covered the pre-remediation
  branch and is not repeated verbatim here except where the remediation
  cycle changes its conclusions.
- Work mode: `full-feature` (per `issue.md` marker "Work Mode: full-feature").
- Predecessor artifacts: `policy-audit.2026-07-18T16-04.md`,
  `code-review.2026-07-18T16-04.md`, `feature-audit.2026-07-18T16-04.md`,
  `remediation-inputs.2026-07-18T16-04.md`,
  `remediation-plan.2026-07-18T16-04.md`.

## Rejected Scope Narrowing

None detected. The task instructions for this reaudit explicitly direct
independent re-verification of the executor's claims (re-running coverage,
reading the new tests, re-running the toolchain, checking for new issues)
rather than narrowing scope. No caller text attempted to limit scope to a
subset of files, mark a language as out of scope, or instruct skipping a
toolchain/coverage check.

## Policy Reading Order Followed

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/python.md` (only language with changed files in this
   remediation cycle: the diff `d580d5a5..HEAD` touches one Python test file,
   two Markdown AC-source files, and Markdown evidence/plan artifacts — no
   PowerShell, TypeScript, or C# files)
5. `.claude/rules/quality-tiers.md` (uniform coverage-threshold source)

## Language Coverage Verdicts (mandatory per changed-file language)

- **Python:** changed files in this remediation cycle —
  `tests/scripts/dev_tools/test_schema_loading.py` (test-only addition, +37
  lines, 3 new test functions). **Verdict: PASS.** See Coverage Verification
  below.
- **PowerShell / TypeScript / C#:** zero changed files in this remediation
  cycle. No coverage verdict required for these languages under this cycle's
  diff (system-prompt rule: N/A verdicts are acceptable only for languages
  with zero changed files on the branch). Confirmed zero changed files of
  these types via `git diff --stat d580d5a5..HEAD` (Python and Markdown
  only).
- Markdown/docs files (spec.md, user-story.md, evidence artifacts,
  remediation-plan.md) are documentation, not a coverage-gated language.

## Coverage Verification (independently reproduced, not taken on faith)

### Scoped run — `tests/scripts/dev_tools/test_schema_loading.py` only

Command: `poetry run pytest --cov=scripts.dev_tools.schema_loading --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage-schema-loading-reaudit.json tests/scripts/dev_tools/test_schema_loading.py`

Result: `8 passed` (5 pre-existing + 3 new). Independently parsed JSON summary
for `scripts/dev_tools/schema_loading.py`:

- `num_statements=35`, `covered_lines=30`, `percent_statements_covered=85.71%`
- `num_branches=14`, `covered_branches=13`, `percent_branches_covered=92.86%`

This exactly matches the executor's claimed figures
(`schema-loading-branch-coverage-fix.2026-07-18T16-30.md`) and clears the
uniform 85%/75% threshold in `.claude/rules/quality-tiers.md` with margin.
The missing branch is the residual `http(s)://` fetch-and-cache body
(lines 113-117), out of scope for this remediation per
`remediation-inputs.2026-07-18T16-04.md` Finding 1, and is exercised
indirectly elsewhere (see full-suite run below).

### Full-suite run

Command: `poetry run pytest --cov --cov-branch --cov-report=json:artifacts/python/coverage-full-reaudit.json -q`

Result: `1720 passed` (up from the pre-remediation baseline of 1717 — a
delta of exactly 3, matching the 3 new test functions; no test was removed
or renamed). Independently parsed JSON `totals`:

- Aggregate line (statement) coverage: `88.26%` (`percent_statements_covered`,
  10010/11342 statements) — up from the pre-remediation baseline of 88.21%.
- Aggregate branch coverage: `79.11%` (`percent_branches_covered`,
  3356/4242 branches) — up from the pre-remediation baseline of 79.02%.
- No regression: both aggregate figures moved up, not down.

`scripts/dev_tools/schema_loading.py` in the full-suite context: `100%` line
coverage (35/35) and `100%` branch coverage (14/14) — matches the executor's
claim exactly.

`scripts/dev_tools/validate_json.py` in the full-suite context: `79.59%`
line / `57.89%` branch — identical to the figures recorded in the
pre-remediation `remediation-inputs.2026-07-18T16-04.md`, confirming this
file was untouched by the remediation cycle (consistent with the git-diff
finding below) and that the pre-existing, already-adjudicated
denominator-shrinkage note from the initial review still applies unchanged.

**Coverage verdict: PASS.** The Finding-1 blocking gap
(`schema_loading.py` branch coverage 71.43% < 75%) is closed. Repo-wide
Python coverage (88.26% line / 79.11% branch) clears the uniform 85%/75%
thresholds per `.claude/rules/quality-tiers.md`, and no regression occurred
in any file.

Note on threshold-number reconciliation: this audit applies the uniform
85%-line/75%-branch thresholds stated in `.claude/rules/quality-tiers.md`
(the repo's authoritative, loaded-via-`CLAUDE.md` policy source, which
explicitly states "Tier-specific lower coverage thresholds are not used")
and restated in this feature's own `spec.md`/`user-story.md`, rather than
the differing 90%/80% figures that appear in a separate generic
verification-procedure description. The repo-local policy is authoritative
for this repository's review.

## Evidence Location Compliance

Ran `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .`
— exit code 0, no violations reported. Independently confirmed via
`git diff --name-only d580d5a5..HEAD` that no file under `artifacts/baselines/`,
`artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/` appears in
the remediation-cycle diff. All new evidence artifacts for this remediation
cycle are written under the canonical
`docs/features/active/2026-07-17-legacy-discovery-validators-361/evidence/<kind>/`
tree (`evidence/remediation-baseline/`, `evidence/qa-gates/`), consistent
with the Evidence Location Invariant. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED`
entries were needed.

## Toolchain Reverification (independently re-run, not taken on faith)

| Stage | Command | Result |
|---|---|---|
| Format (Black), scoped | `poetry run black --check scripts/dev_tools/schema_loading.py tests/scripts/dev_tools/test_schema_loading.py` | PASS — "2 files would be left unchanged" |
| Format (Black), full repo | `poetry run black --check .` | PASS — "282 files would be left unchanged" |
| Lint (Ruff), scoped | `poetry run ruff check scripts/dev_tools/schema_loading.py tests/scripts/dev_tools/test_schema_loading.py` | PASS — "All checks passed!" |
| Lint (Ruff), full repo | `poetry run ruff check .` | PASS — "All checks passed!" |
| Type check (Pyright), scoped | `poetry run pyright scripts/dev_tools/schema_loading.py tests/scripts/dev_tools/test_schema_loading.py` | PASS — "0 errors, 0 warnings, 0 informations" |
| Unit tests, full suite | `poetry run pytest --cov --cov-branch --cov-report=json:...` | PASS — 1720 passed, 0 failed |
| Domain-neutrality grep (re-run on remediated files) | `grep -inE "taskmaster\|outlook\|vsto\|tmw"` on the two remediated files | PASS — zero matches |

All figures independently reproduced match the executor's own reported
figures in `final-qc-black-remediation.2026-07-18T16-38.md`,
`final-qc-ruff-remediation.2026-07-18T16-42.md`,
`final-qc-pyright-remediation.2026-07-18T16-45.md`, and
`final-qc-pytest-full-suite-remediation.2026-07-18T16-50.md`.

## Production-Code-Change Constraint Check

`git diff --stat d580d5a5..HEAD -- 'scripts/**'` returns empty — no file
under `scripts/` was changed in this remediation cycle. The only files
changed in `d580d5a5..HEAD` are: one Python test file
(`tests/scripts/dev_tools/test_schema_loading.py`), two AC-source Markdown
files (`spec.md`, `user-story.md`, checkbox/annotation edits only), and
Markdown evidence/plan artifacts. This confirms the executor's claim that no
production code change was required or made.

## Documentation-Finding Correction Verification (Finding 2, non-blocking)

- The new corrective artifact
  `evidence/qa-gates/final-qc-pytest-new-code-correction.2026-07-18T16-32.md`
  states `schema_loading.py`'s pure line coverage (85.71%) and pure branch
  coverage (71.43% pre-remediation / 92.86% post-remediation-in-scoped-run)
  separately from `coverage.py`'s blended `percent_covered` metric, matching
  this reaudit's independently reproduced figures exactly.
- Confirmed via `git diff d580d5a5..HEAD -- evidence/qa-gates/final-qc-pytest-new-code.2026-07-18T10-42.md`
  (empty diff) that the original mislabeled artifact was left byte-identical
  and was not deleted or silently edited. `git log --follow` on that path
  shows only its original creation commit (`d580d5a5`); no later commit
  touches it.

## Process Observation (non-blocking, informational)

The pre-remediation audit (`feature-audit.2026-07-18T16-04.md`) stated that
the spec.md and user-story.md coverage AC checkboxes were "un-checked in
[file] by this review" (changed from `[x]` to `[ ]`). Independent inspection
of git history shows no commit between the feature's Phase-7 completion
(`d580d5a5`) and the remediation check-off commit (`bce0339d`) ever
persisted an unchecked state for either checkbox — both files carried `[x]`
continuously through that interval. The prior review's edit, if made, was
never committed and was effectively superseded by the remediation cycle's
own edit (which added the gap-then-closure annotation on top of the
already-`[x]` line). The net effect on the current, merge-relevant state is
immaterial: both items are now `[x]` with an accurate, evidence-backed
annotation, and the underlying coverage gap was genuinely open during the
interval regardless of the checkbox's literal state. This is recorded here
as a review-process accuracy note for the acceptance-criteria-tracking
protocol, not as a finding against this remediation cycle.

## Overall Policy Verdict

**PASS.** The single blocking finding from the prior review cycle
(`schema_loading.py` branch coverage below the uniform 75% threshold) is
independently confirmed closed. No new blocking or non-blocking policy
violation was introduced by this remediation cycle. Toolchain, coverage,
evidence-location, and domain-neutrality gates all pass on independent
re-run.

**Blocking finding count: 0.**
