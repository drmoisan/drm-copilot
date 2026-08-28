# Policy Compliance Audit — collect-pr-context reports ok without writing (Issue #574)

- Timestamp: 2026-08-28T13-48
- Feature folder: `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574`
- Branch: `bug/collect-pr-context-reports-ok-without-writing-574-r2`
- Base branch: `main` (`origin/main` = `d8b81f81cf194d337fe9e61e8c10ac8278c043fd`)
- Merge base: `e546e814e246d814474d35067f0674590b0e41ff`
- Work mode: `full-bug` (marker read from `issue.md` line 12)
- Reviewer evidence model: every verdict below was reproduced by executing the named command in this
  worktree. No verdict is carried over from the executor's artifacts without independent execution,
  except where explicitly labelled ARTIFACT-ONLY.

## Verdict Summary

| Area | Verdict |
| --- | --- |
| Scope integrity (branch diff vs base) | PASS |
| Evidence location compliance | PASS |
| Reading order / policy-document immutability | PASS |
| Seven-stage toolchain, TypeScript | PASS |
| Seven-stage toolchain, Python | PASS (one pre-authorized unrelated failure) |
| Coverage — TypeScript | PASS |
| Coverage — Python | PASS |
| Coverage — PowerShell | N/A (zero changed PowerShell files on the branch) |
| Coverage — C# | N/A (zero changed C# files on the branch) |
| File-size limit (500 lines) | PASS |
| Unit-test policy (`.claude/rules/general-unit-test.md`) | PASS |
| Suppression policy | PASS |
| Plan acceptance gates (`.claude/rules/plan-acceptance-gates.md`) | PASS |
| Tonality policy | PASS |

**Blocking findings: 0.**

---

## Rejected Scope Narrowing

The caller prompt contained the following instruction, quoted verbatim:

> `origin/main` was merged into this branch at execution start. A bare `git diff origin/main...HEAD`
> therefore also reports another feature's work that arrived through that merge (the epic
> worktree-removal gate change for issue #573, under
> `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, `.claude/skills/parallel-orchestrate/`,
> `.claude/rules/parallel-orchestration.md`, `tests/scripts/claude-hooks/`, and
> `docs/features/active/2026-08-28-epic-worktree-removal-gate-blocks-parallel-runs-573/`). That work
> is NOT under review here and must not produce findings against this feature. Review only the paths
> this branch's own work authored.

Per the non-negotiable Scope Invariant, this instruction was not relied upon. The audit scope used
is the full branch diff against the resolved base: `git diff origin/main...HEAD`.

Justification and outcome: the narrowing was moot. `git diff origin/main...HEAD` is a symmetric-
difference diff computed against the merge base, so content that entered `HEAD` through the merge
commit `e9add4d3` and is also reachable from `origin/main` is already excluded by the diff itself.
The full three-dot diff was executed and returned **53 paths**, none of which is a `#573` path. The
full-scope diff and the caller's claimed authored set are therefore the same set, and no narrowing
was applied to reach it.

Verification, verbatim non-documentation portion of `git diff --name-only origin/main...HEAD`
(23 paths, matching the declared authored set exactly):

```
.agents/skills/pr-context-artifacts/SKILL.md
.claude/skills/pr-context-artifacts/SKILL.md
.github/skills/pr-context-artifacts/SKILL.md
extensions/drm-copilot/jest.config.cjs
extensions/drm-copilot/resources/claude-customizations/.claude/skills/pr-context-artifacts/SKILL.md
extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/pr-context-artifacts/SKILL.md
extensions/drm-copilot/resources/customizations/.github/skills/pr-context-artifacts/SKILL.md
extensions/drm-copilot/src/lib/pr-context/collector-output.ts
extensions/drm-copilot/src/lib/pr-context/pr-context-service-call.ts
extensions/drm-copilot/src/lib/pr-context/summary-helpers.ts
extensions/drm-copilot/test/extension.collect-pr-context.test.ts
extensions/drm-copilot/test/extension.integration.test.ts
extensions/drm-copilot/test/lib/pr-context/collector-output-freshness.test.ts
extensions/drm-copilot/test/lib/pr-context/collector-output.test.ts
extensions/drm-copilot/test/lib/pr-context/pr-context-service-call.test.ts
extensions/drm-copilot/test/lib/pr-context/summary-helpers.test.ts
extensions/drm-copilot/test/lib/pr-context/tree-file-system.ts
extensions/drm-copilot/test/repo-automation-dispatch-pr-context-verification.test.ts
extensions/drm-copilot/test/repo-automation-dispatch.test.ts
scripts/dev_tools/pr_context/collector.py
scripts/dev_tools/pr_context/collector_documents.py
scripts/dev_tools/pr_context/summary_helpers.py
tests/scripts/dev_tools/test_pr_context_freshness.py
```

The remaining 30 paths are the feature folder's own documents, research, and evidence subtree.

**Languages with changed files on the branch:** TypeScript (11 files), Python (4 files), Markdown
(6 skill copies + feature documents), JavaScript config (1 file). **Zero** PowerShell files and
**zero** C# files appear anywhere in the branch diff, so `N/A` is the correct and permitted verdict
for those two coverage languages.

---

## Evidence Location Compliance

- `python scripts/dev_tools/validate_evidence_locations.py --root .` — **EXIT 0**, no violations
  reported.
- `git diff --name-only origin/main...HEAD | grep -E "^artifacts/(baselines|qa|coverage|evidence)/"`
  returned no matches. No file is written to a non-canonical evidence path.
- All 25 evidence artifacts are under the canonical
  `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/<kind>/`
  with kinds `baseline`, `qa-gates`, `regression-testing`, and `other`.
- The plan directs each Python coverage JSON to `artifacts/python/`, which is a tool output
  consumed during the run rather than an evidence artifact, and is `.gitignore`d. It does not appear
  in the branch diff. This is not an evidence-location violation.

**Verdict: PASS.** No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` was necessary.

---

## Policy-Document Immutability

`git diff --name-only origin/main...HEAD` contains no path under `.claude/rules/`,
`.github/instructions/`, or `.github/copilot-instructions.md`. The only `.claude/` path in the diff
is `.claude/skills/pr-context-artifacts/SKILL.md`, which is a consumer-guidance skill, not a policy
document, and is edited by design as one of the six enumerated copies.

`git diff --name-only origin/main...HEAD -- .claude/hooks/` returned empty, satisfying the spec's
explicit non-goal that `enforce-pr-author-skill.ps1` and `enforce-pr-author-skill-helpers.ps1` are
untouched.

**Verdict: PASS.**

---

## Seven-Stage Toolchain — TypeScript (`.claude/rules/typescript.md`)

All commands executed by the reviewer from `extensions/drm-copilot`.

| Stage | Command | Exit | Verdict |
| --- | --- | --- | --- |
| 1 Formatting | `npx prettier --check "src/**/*.ts" "test/**/*.ts" jest.config.cjs` | 0 (`All matched files use Prettier code style!`) | PASS |
| 2 Linting | `npm run lint` | 0 | PASS |
| 3 Type checking | `npm run typecheck` | 0 | PASS |
| 4 Architecture boundary | no command configured in this repository | UNVERIFIED | see note |
| 5 Unit tests | `npm run test:coverage -- --coverageReporters=text` | 0 — `Test Suites: 201 passed, 201 total`, `Tests: 2722 passed, 2722 total` | PASS |
| 6 Contract / schema | no schema-diff command configured; the MCP tool schema is unchanged by this diff | PASS by inspection |
| 7 Integration tests | `extension.integration.test.ts` runs inside the Jest suite above | PASS |

Stage 4 note: neither `package.json` in this repository defines a dependency-cruiser or equivalent
architecture-boundary script (`npm run` script lists inspected in the root manifest and in
`extensions/drm-copilot/package.json`). This is a **pre-existing repository condition unrelated to
this change**, recorded as UNVERIFIED with a concrete reason rather than as a finding against this
feature.

Determinism (`.claude/rules/typescript.md` injected clock): `appendGenerationTimestamp`
(`extensions/drm-copilot/src/lib/pr-context/summary-helpers.ts:351-367`) takes `clock: () => Date`
with a real-clock default, and every test supplies a fixed clock
(`FIXED_CLOCK` in `collector-output.test.ts:22` and `collector-output-freshness.test.ts`). No
`Date.now()`, `setTimeout`, or wall-clock wait appears on any added line.

**Verdict: PASS.**

---

## Seven-Stage Toolchain — Python (`.claude/rules/python.md`)

All commands executed by the reviewer from the repository root.

| Stage | Command | Exit | Verdict |
| --- | --- | --- | --- |
| 1 Formatting | `poetry run black --check .` | 0 | PASS |
| 2 Linting | `poetry run ruff check .` | 0 | PASS |
| 3 Type checking | `poetry run pyright` | 0 | PASS |
| 5/7 Tests + coverage | `poetry run pytest --cov --cov-branch --cov-report=json:...` | 1 — `1 failed, 4197 passed, 5 skipped` | PASS under bounded exemption |

### Bounded-exemption verification (three conditions, all checked against the reviewer's own run)

The plan grants a bounded exemption for one pre-existing failure. The reviewer verified all three
conditions independently rather than accepting the artifact's assertion:

1. **Exactly one failure.** Reviewer's run reported `1 failed, 4197 passed, 5 skipped`. Condition
   holds.
2. **That exact node ID.**
   `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`.
   Condition holds.
3. **Assertion message names a path under `.claude/state/`.** Verbatim from the reviewer's run:
   `AssertionError: Repo file missing from bundle: .claude\state\python-batch-budget.default.json`.
   Condition holds.

The failing file is a gitignored local state file with no bundled counterpart. It is unrelated to
this diff (the diff touches no push-down payload other than the three bundled `SKILL.md` copies,
and the codex/agents contract file passes). The failure is therefore not a finding against this
feature.

**Verdict: PASS (bounded exemption verified live, not accepted on assertion).**

---

## Coverage Verification

Coverage was verified by executing the coverage commands in this worktree and reading the reporter
output directly, then cross-checking against the executor's recorded artifacts.

### TypeScript — `coverage/lcov.info` producer, run reproduced

Command: `npm run test:coverage -- --coverageReporters=text` from `extensions/drm-copilot`, EXIT 0.

Repo-wide (`All files` row), verbatim from the reviewer's run:

```
All files    |   96.71 |    90.15 |   89.88 |   96.71 |
```

- Repo-wide line **96.71** >= 85. PASS.
- Repo-wide branch **90.15** >= 75. PASS.

Per changed production file, verbatim from the reviewer's run:

| File | Tier | Line | >= 85 | Branch | >= 75 | Regression vs baseline |
| --- | --- | --- | --- | --- | --- | --- |
| `src/lib/pr-context/pr-context-service-call.ts` | modified | **100** | yes | **87.5** | yes | line 100 -> 100 (none); branch 100 -> 87.5 (see note) |
| `src/lib/pr-context/collector-output.ts` | modified | **97.73** | yes | **82.27** | yes | line 97.57 -> 97.73 (rose); branch 81.01 -> 82.27 (rose) |
| `src/lib/pr-context/summary-helpers.ts` | modified | **93.55** | yes | **87.83** | yes | line 93.09 -> 93.55 (rose); branch 87.14 -> 87.83 (rose) |

Note on `pr-context-service-call.ts` branch coverage moving 100 -> 87.5: this is a **denominator
change, not a loss of coverage on previously covered behaviour**. At baseline the file contained no
branching code beyond one optional-log spread, so its branch denominator was trivially satisfied.
The change adds genuinely branching verification code (`catch` arm, `error instanceof Error`
narrowing, content-inequality arm). The single uncovered line is
`pr-context-service-call.ts:56` — the non-`Error` arm of the `instanceof` narrowing, reachable only
if the injected filesystem throws a non-`Error` value, which neither `RealFileSystem` nor any test
double does. 87.5 is above the uniform 75 floor. All three added negative paths are covered by named
tests and proved live by mutation (see `## Read-Back Verification Integrity`). **This does not
constitute a regression under `.claude/rules/general-unit-test.md`, which prohibits reducing coverage
for the lines that were changed — the changed lines are covered; the metric moved because new
branches entered the denominator.**

Per-file threshold enforcement: `extensions/drm-copilot/jest.config.cjs` carries three added
entries, each `lines: 85, branches: 75`. The gate is **live, not inert** — the executor's `[P5-T5]`
artifact records a negative probe that raised one entry to 100 and observed Jest exit 1 printing
`Jest: Coverage for branches (87.5%) does not meet "./src/lib/pr-context/pr-context-service-call.ts" threshold (100%)`,
naming the added key exactly. That is ARTIFACT-ONLY; the reviewer did not re-run the probe, but did
confirm the committed configuration carries 75 and that the run exits 0 with no `threshold` string
in its output.

**Verdict: PASS.**

### Python — `artifacts/python/lcov.info` producer, run reproduced

Reviewer command:
`poetry run pytest --cov=scripts.dev_tools.pr_context.collector --cov=scripts.dev_tools.pr_context.summary_helpers --cov=scripts.dev_tools.pr_context.collector_documents --cov-branch --cov-report=json:... --cov-report=term`.
The `--cov` operands are **dotted module names**, not filesystem paths, so gates G1 and G2 of
`.claude/rules/plan-acceptance-gates.md` are not triggered, and the `=` form is used throughout so
G4 is not triggered. `Coverage LCOV written to file artifacts/python/lcov.info` confirms the
mandated artifact is produced.

Repo-wide, computed from the JSON `totals` object of a full `--cov --cov-branch` run:

- Repo-wide line **92.70778537611783** >= 85. PASS.
- Repo-wide branch **85.29939046253138** >= 75. PASS.

These two figures match the executor's `coverage-delta` artifact to fourteen decimal places.

Per changed production file, read from the JSON `summary` object of each file entry (never derived
from the terminal `BrPart` column):

| File | Tier | Line | >= 85 | Branch | >= 75 | Regression vs baseline |
| --- | --- | --- | --- | --- | --- | --- |
| `scripts/dev_tools/pr_context/collector.py` | modified | **93.54838709677419** | yes | **86.36363636363636** | yes | line 92.444 -> 93.548 (rose); branch 84.884 -> 86.364 (rose) |
| `scripts/dev_tools/pr_context/summary_helpers.py` | modified | **91.30434782608695** | yes | **81.42857142857143** | yes | line 90.909 -> 91.304 (rose); branch flat at 81.429 (not a regression) |
| `scripts/dev_tools/pr_context/collector_documents.py` | **new** | **91.66666666666667** | yes | **86.36363636363636** | yes | no baseline (file created by this change) |

Raw terminal columns from the reviewer's run, which match the executor's artifact exactly:

```
scripts\dev_tools\pr_context\collector.py               186     12     66      9    92%
scripts\dev_tools\pr_context\collector_documents.py      60      5     22      3    90%
scripts\dev_tools\pr_context\summary_helpers.py         161     14     70      9    88%
```

**Verdict: PASS.**

### Phase 8 restart claim — verified

The executor reported that an earlier Phase 8 pass measured `collector.py` branch coverage at
`84.84848484848484` against a baseline of `84.88372093023256`, a 0.035-point regression, and that it
was repaired by extending a test stub rather than by changing production code. The reviewer verified
this against the commit rather than against the prose:

`git show --stat 4f179480` touches exactly one file,
`tests/scripts/dev_tools/test_pr_context_freshness.py`, `8 insertions(+), 2 deletions(-)`. The change
adds a second changed path (`assets/logo.svg`) to the git stub's `--name-status` and `--numstat`
returns so the collector's changed-file bucketing loop takes its no-bucket fall-through exit. **No
production file appears in that commit.** The repair is a genuine coverage improvement, not a
threshold relaxation and not a production-code edit to move a number.

**Verdict: PASS.**

### Coverage exclusion policy

`extensions/drm-copilot/jest.config.cjs` gains three `coverageThreshold` entries and **no**
`coveragePathIgnorePatterns` or `collectCoverageFrom` change. No production source path was added to
any exclusion list in either runtime. The new Python module
`scripts/dev_tools/pr_context/collector_documents.py` is in the coverage denominator and is measured
above both thresholds.

**Verdict: PASS.**

---

## File-Size Limit (`.claude/rules/general-code-change.md`, 500 lines)

Every non-Markdown file in the branch diff, line counts read by the reviewer:

```
 260  extensions/drm-copilot/jest.config.cjs
 485  extensions/drm-copilot/src/lib/pr-context/collector-output.ts
 142  extensions/drm-copilot/src/lib/pr-context/pr-context-service-call.ts
 388  extensions/drm-copilot/src/lib/pr-context/summary-helpers.ts
 483  extensions/drm-copilot/test/extension.collect-pr-context.test.ts
 463  extensions/drm-copilot/test/extension.integration.test.ts
 460  extensions/drm-copilot/test/lib/pr-context/collector-output.test.ts
 171  extensions/drm-copilot/test/lib/pr-context/collector-output-freshness.test.ts
 276  extensions/drm-copilot/test/lib/pr-context/pr-context-service-call.test.ts
 294  extensions/drm-copilot/test/lib/pr-context/summary-helpers.test.ts
 153  extensions/drm-copilot/test/lib/pr-context/tree-file-system.ts
 491  extensions/drm-copilot/test/repo-automation-dispatch.test.ts
 127  extensions/drm-copilot/test/repo-automation-dispatch-pr-context-verification.test.ts
 474  scripts/dev_tools/pr_context/collector.py
 345  scripts/dev_tools/pr_context/collector_documents.py
 416  scripts/dev_tools/pr_context/summary_helpers.py
 308  tests/scripts/dev_tools/test_pr_context_freshness.py
```

Maximum is 491. `scripts/dev_tools/pr_context/collector.py` exceeded the limit at baseline and is now
474, repaired by extracting two document-assembly blocks into
`scripts/dev_tools/pr_context/collector_documents.py` (345 lines). The extraction is behaviour-
preserving: `collector_documents.py` writes no file and resolves no path, and its module docstring
records that constraint explicitly (lines 9-12).

**Verdict: PASS.**

---

## Unit-Test Policy (`.claude/rules/general-unit-test.md`)

- **No temporary files.** The Python test uses the repository's `mem_fs_path` fixture
  (`tests/conftest.py:145`), which is an in-memory `pathlib.Path` store explicitly created to enforce
  the no-temp-file rule, and it additionally monkeypatches `write_output` so nothing is written at
  all. Every TypeScript test uses either `TreeFileSystem` (in-memory) or a jest `node:fs` mock. No
  `tmp_path`, `tmpdir`, `os.tmpdir`, or `mkdtemp` appears on any added line. PASS.
- **Test file location.** `tests/scripts/dev_tools/test_pr_context_freshness.py` mirrors
  `scripts/dev_tools/pr_context/`. The TypeScript suites live under
  `extensions/drm-copilot/test/`, which is that package's established test tree (all 201 suites in
  the package live there) — not colocation in `src/`. PASS.
- **Determinism.** Fixed injected clocks throughout; the fixture SHA is a constant; the scripted
  command runners are deterministic; no banned timing API is used. PASS.
- **Arrange-Act-Assert.** Added tests carry explicit `// Arrange` / `// Act` / `// Assert` or
  `# Arrange` / `# Act` / `# Assert` comments and descriptive names. PASS.
- **Scenario completeness.** Positive path, discarded write, stale-file-plus-discarded-write, partial
  write naming the appendix, dispatch-boundary `ok: false`, gh-unavailable degradation, missing head
  SHA, and log-line content are each covered by a named test. PASS.
- **No assertion deleted rather than corrected.** The reviewer read the full diff of all five
  modified test files. Every removed assertion is replaced in place by a stronger assertion of the
  intended behaviour (relative write key -> workspace-joined key; two independent literals -> one set
  equality). No assertion was dropped. PASS.

**Verdict: PASS.**

---

## Suppression Policy

Scan of every added line in the branch diff for `noqa`, `type: ignore`, `pyright: ignore`,
`eslint-disable`, `@ts-ignore`, `@ts-expect-error`, `istanbul ignore`, `.skip(`, `.only(`, `xit(`,
`xdescribe`, and `pytest.mark.skip` returned **only prose mentions inside evidence artifacts**
asserting that none was added. No suppression directive was added to any source or test file.

The two specific diagnostics named in the review directive were confirmed fixed at source:

- **Ruff `S105`** — the constant is named `UNKNOWN_HEAD_SHA_PLACEHOLDER` in both runtimes
  (`summary-helpers.ts:329`, `summary_helpers.py`). This is a rename that removes the
  hardcoded-password heuristic trigger, not a suppression. `poetry run ruff check .` exits 0 with no
  `# noqa` anywhere in the diff.
- **ESLint `preserve-caught-error`** — fixed by attaching the caught error as `cause` at
  `pr-context-service-call.ts:57-60`:
  `throw new Error(\`Failed to verify PR context artifact ...\`, { cause: error })`. The underlying
  filesystem error is preserved and propagates upstream. `npm run lint` exits 0 with no
  `eslint-disable` in the diff.

**Verdict: PASS.**

---

## Plan Acceptance Gates (`.claude/rules/plan-acceptance-gates.md`)

The reviewer applied G1-G6 reasoning to the acceptance conditions actually recorded in the evidence,
looking specifically for conditions that could not have failed.

- **G1/G2/G3 (coverage operands).** Every `--cov` operand in the plan and in the recorded commands is
  a dotted module name (`scripts.dev_tools.pr_context.collector`, `...summary_helpers`,
  `...collector_documents`). None ends in `.py`; none contains a path separator. The reviewer
  re-executed the commands and confirmed each collected non-zero data for the named module. No G1,
  G2, or G3 condition is met. PASS.
- **G4 (space-separated `--cov`).** Every operand uses the `=` form. PASS.
- **Coverage-number provenance.** The plan's Python coverage-reading convention (plan lines 23-25)
  explicitly rejects deriving branch coverage from the terminal `BrPart` column and states, with
  measured counter-examples, that `(Branch - BrPart) / Branch` overstates branch coverage — in one
  measured case yielding 75.7 against a true 61.4, which would have passed a threshold the module
  genuinely fails by 13.6 points. Every recorded Python percentage is read from the JSON reporter's
  `percent_statements_covered` / `percent_branches_covered` keys. The reviewer independently
  recomputed all five per-file figures and both run-level figures from a fresh JSON report and got
  identical values. **This is the correct provenance and the recorded numbers are real.** PASS.
- **Write-mode commands judged by tree observation, not exit code.** Both `npm run format` and
  `poetry run black .` are write-mode commands that exit 0 whether or not they rewrote a file. Both
  gates record `git status --porcelain` before and after and compare the two listings
  (`final-ts-format.2026-08-28T12-47.md` lines 53-71; `final-py-black.2026-08-28T12-47.md` lines
  17-57). The TypeScript gate additionally records that this observation was **load-bearing**: an
  earlier pass exited 0 while rewriting three tracked files, which only the before-and-after listing
  made visible, and which forced a phase restart. The reviewer independently confirmed the end state
  with the check-mode equivalents (`prettier --check` exit 0, `black --check` exit 0). PASS.
- **G5/G6 (search literals).** The two `git grep` acceptance conditions in the evidence
  (`Freshness Cross-Check`, `summary_path = out`) are single-line, non-interpolated literals with no
  placeholder marker. The reviewer confirmed both are genuinely present and both were verified
  against the **staged/tracked** tree (`skill-copies-cross-check` records that the six files were
  `git add`ed first, which is what makes a `git grep` non-vacuous). Neither is a self-hit against the
  plan document. PASS.
- **Fail-first evidence is genuine.** `fail-first-service-seam.2026-08-28T12-47.md` records
  `ExpectedExitCode: 1` and the verbatim Jest diff showing the written set as the bare relative pair
  against the reported set as the workspace-joined pair. That is the defect itself, observed. It
  could not have been produced by a test that cannot fail. PASS.

**No acceptance condition was found that could not have failed. Verdict: PASS.**

---

## Read-Back Verification Integrity (core of the defect under repair)

This was audited with particular care, per the review directive.

**The production code compares content, not existence.**
`extensions/drm-copilot/src/lib/pr-context/pr-context-service-call.ts:47-67` reads the artifact back
through the injected `FileSystem` and compares `actual !== expected`, where `expected` is the exact
string `collectAndWrite` returned for that path in this invocation. `collectAndWrite` was changed
from `void` to returning `{ summaryText, appendixText }`
(`collector-output.ts:340-394`) precisely so the comparison operand is the rendered text rather than
a re-render. There is no `fs.exists` or `fs.isFile` call anywhere on the verification path.

**Path identity is structural, not merely corrected.** Each absolute path is evaluated exactly once
(`pr-context-service-call.ts:114-119`) and the same variable is the write target, the verification
read target, the log-line value, and the reported artifact entry. Normalization is applied **before**
the write rather than after, so a Windows backslash join cannot make the written string and the
reported string differ. No second expression exists that could drift.

**A stale prior-invocation file does not satisfy the check.** The discriminating test is
`pr-context-service-call.test.ts:192-217`: it pre-seeds both target paths with
`"PRIOR INVOCATION SUMMARY"` / `"PRIOR INVOCATION APPENDIX"`, asserts `isFile` is true for both
(so an existence-only check would pass), injects a write that accepts and discards, and asserts the
call raises. This is the exact hazard the issue reports.

**The recorded mutation evidence is genuine.**
`evidence/regression-testing/readback-mutation-check.2026-08-28T12-47.md` records removing the two
verification calls and re-running the suite: `EXIT_CODE: 1`, `ExpectedExitCode: 1`,
`Tests: 3 failed, 5 passed, 8 total`, with the three named failing tests being exactly the three
negative tests. The companion `readback-mutation-check-restored.2026-08-28T12-47.md` records exit 0
with 8 passed and — importantly — verifies the restoration was **exact rather than equivalent** by
`git status --porcelain` on the production file returning empty. The two artifacts are split because
they declare different `ExpectedExitCode` values, which is correct practice. The reviewer confirmed
the current committed state passes all 8 tests as part of the full 2722-test run.

**Verdict: PASS.** The verification is a real content comparison, is proved live by mutation, and
discriminates a stale file from a fresh one.

---

## Six Skill Copies — Byte Parity of the Added Wording

The reviewer hashed the `### Freshness Cross-Check` block of each of the six copies:

| Copy | Block SHA-256 (first 16) | Block bytes | Whole-file SHA-256 (first 16) |
| --- | --- | --- | --- |
| `.agents/skills/pr-context-artifacts/SKILL.md` | `83e183925b837a6e` | 1392 | `867c7e1a69bbabb1` |
| `.claude/skills/pr-context-artifacts/SKILL.md` | `f1745c11619bf33a` | 1393 | `ebb71432b9a32fec` |
| `.github/skills/pr-context-artifacts/SKILL.md` | `83e183925b837a6e` | 1392 | `867c7e1a69bbabb1` |
| `resources/claude-customizations/.claude/.../SKILL.md` | `f1745c11619bf33a` | 1393 | `ebb71432b9a32fec` |
| `resources/codex-and-agents-customizations/.agents/.../SKILL.md` | `83e183925b837a6e` | 1392 | `867c7e1a69bbabb1` |
| `resources/customizations/.github/.../SKILL.md` | `83e183925b837a6e` | 1392 | `867c7e1a69bbabb1` |

- **Every self-hosted / bundled pair is byte-identical at the whole-file level.** The `.claude` pair
  both hash `ebb71432b9a32fec`; the `.github` and `.agents` copies and both their bundles all hash
  `867c7e1a69bbabb1`. Push-down parity holds.
- The one-byte difference between the `.claude` copies and the other four is a **single trailing
  newline that pre-dates this change**: at `origin/main` the `.claude` copy was 1228 bytes ending
  `...provided.\n\n` while the `.github` and `.agents` copies were 1227 bytes ending
  `...provided.\n`. The reviewer confirmed the two blocks share an identical common prefix and differ
  only in that trailing byte. **The added wording itself is byte-identical across all six copies.**
- `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`
  reports `1 failed, 18 passed`; the single failure is the pre-authorized `.claude/state/` exemption
  and is not a skill-copy parity failure.

**Verdict: PASS.**

---

## Tonality Policy

The three modified/added skill copies, the new Python module docstring, the added TypeScript
docstrings, and the 25 evidence artifacts were read for tone. All use neutral, factual, measured
language. No humor, hyperbole, celebratory phrasing, emoji, or decorative metaphor was found. The
evidence artifacts state limits explicitly (for example the `coverage-delta` artifact states the one
branch decrease plainly rather than glossing it, and the `ts-coverage-thresholds` artifact states
that exit code 0 alone does not distinguish a passing threshold from an unloaded one).

**Verdict: PASS.**

---

## Findings Register

**Blocking: 0.**

**Non-blocking: 0.**

**Observations: 6.** Recorded in `code-review.2026-08-28T13-48.md` sections O1 through O6. None
requires action before merge.

## Remediation

No remediation is required. No `remediation-inputs` artifact is produced.
