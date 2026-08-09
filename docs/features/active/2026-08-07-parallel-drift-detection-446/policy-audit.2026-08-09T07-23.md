# Policy Audit — F8 Radius Drift Detection (issue #446), Remediation Cycle 1 Exit Reaudit

- Timestamp: 2026-08-09T07-23
- Branch: `feature/parallel-drift-detection-446`, head `2266e1ab`
- Full feature diff base: `c939b5b8` (wave-4 epic integration head)
- Commits in scope: `bcf2de15` (implementation) and `2266e1ab` (remediation cycle 1)
- Work mode: `full-feature` (AC sources: `spec.md` and `user-story.md`)
- Cycle-entry artifacts reaudited: `policy-audit.2026-08-09T00-01.md`,
  `code-review.2026-08-09T00-01.md`, `feature-audit.2026-08-09T00-01.md`,
  `remediation-inputs.2026-08-09T00-01.md`
- Remediation plan: `remediation-plan.2026-08-09T00-01.md` (80 tasks, all checked off)

## Exit-Gate Verdict

**Total Blocking count: 0.**

Both Blocking findings raised at cycle entry are closed and verified closed by independent
re-execution, not by reading the executor's claims. The exit condition `blocking_count == 0` is
satisfied and the remediation loop may exit.

## Audit Scope Statement

The audited scope is the full branch diff `git diff c939b5b8..HEAD`: 90 files, 15,499 insertions,
68 deletions. The cycle-1 delta `git diff bcf2de15..HEAD` (59 files) was examined separately to
attribute closure evidence, but no verdict in this artifact is limited to it.

## Rejected Scope Narrowing

None. The delegation prompt directed a whole-feature review against `c939b5b8`, named the cycle-1
delta only as an attribution aid, and did not mark any language, file subset, or toolchain check as
out of scope. No narrowing was attempted and none was rejected.

## Evidence Location Compliance

- `git diff --name-only c939b5b8..HEAD | grep -E '^artifacts/(baselines|qa|evidence|coverage)/'` —
  **no matches**. No evidence artifact was written to a non-canonical path.
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` — **EXIT 0**.
- Every evidence artifact in the diff is under
  `docs/features/active/2026-08-07-parallel-drift-detection-446/evidence/<kind>/`, with `<kind>` in
  `{baseline, qa-gates, remediation-baseline, other}`.

**Verdict: PASS.** No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` condition arose.

## Language Coverage Verdicts (mandatory, one per language with changed files)

| Language | Changed files in branch diff | Coverage artifact | Verdict |
| --- | --- | --- | --- |
| Python | 12 production + 12 test | `artifacts/python/lcov.info` (regenerated this audit) | **PASS** |
| PowerShell | 4 production (2 hooks + 2 mirrored) + 2 test | `artifacts/pester/powershell-coverage.xml` (regenerated this audit) | **PASS** |
| TypeScript | **0** | n/a | N/A — zero changed files, verified by `grep -E '\.tsx?$'` over the diff file list returning no matches |
| C# | **0** | n/a | N/A — zero changed files |

### Python coverage — verified by re-execution

Command: `poetry run pytest --cov --cov-branch --cov-report=term`, then `poetry run coverage json`
for exact per-file figures rather than the rounded terminal row.

- Suite: **3201 passed, 0 failed, 0 errored, 0 skipped**, EXIT 0.
- Repo-wide: **92.04% line (12795/13902)**, **84.14% branch (4296/5106)**. Both clear the uniform
  thresholds of `.claude/rules/quality-tiers.md` (line >= 85%, branch >= 75%).
- All seven Python production modules of this feature at 100% line and 100% branch:

| File | Line | Branch | New or modified |
| --- | --- | --- | --- |
| `scripts/dev_tools/parallel_drift_detection.py` | 100.00% (94/94) | 100.00% (32/32) | new |
| `scripts/dev_tools/parallel_drift_detection_cli.py` | 100.00% (74/74) | 100.00% (10/10) | new |
| `scripts/dev_tools/parallel_drift_halt.py` | 100.00% (42/42) | 100.00% (6/6) | new |
| `scripts/dev_tools/parallel_drift_resolution.py` | 100.00% (15/15) | 100.00% (0/0) | new (cycle 1) |
| `scripts/dev_tools/_parallel_drift_shape.py` | 100.00% (51/51) | 100.00% (26/26) | new |
| `scripts/dev_tools/_parallel_drift_cli_io.py` | 100.00% (41/41) | 100.00% (18/18) | new |
| `scripts/dev_tools/_parallel_orchestrator_state_drift.py` | 100.00% (44/44) | 100.00% (14/14) | new |
| `scripts/dev_tools/validate_parallel_orchestrator_state.py` | 97.62% (82/84) | 94.12% (32/34) | modified (+2 lines) |

`parallel_drift_resolution.py` reports a zero branch denominator because both of its functions are
straight-line. The figure is reported as measured, not invented; the file has no branch arcs to
cover.

The one modified pre-existing file, `validate_parallel_orchestrator_state.py`, holds its cycle-entry
97.62% / 94.12% exactly. Its two added lines (one import, one dispatch call) are both covered — the
denominator rose from 82 to 84 statements with covered rising in step, so there is no regression on
changed lines.

### Python coverage exclusions

`pyproject.toml` `[tool.coverage.run] omit` contains only `tests/*`, `*/tests/*`,
`*/__pycache__/*`, `*/site-packages/*`. **No production path is excluded.** This satisfies the
Coverage Exclusion Policy of `.claude/rules/general-unit-test.md`; no `exclude` entry matches a
production source path, so the Blocking condition that policy defines does not arise.

### PowerShell coverage — verified by re-execution

Command: `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force;
Invoke-PoshQCTest -Root (Get-Location).Path"` (the repo-root path, for the provenance reason in
finding F8-N15 below).

- Suite: **2089 passed, 1 failed, 9 skipped** — 2099 tests total. **48 files** analyzed.
- Report-level LINE: 94.99% (3735/3932). INSTRUCTION 94.63% (5,401 commands analyzed).
- Per-file, read directly from `artifacts/pester/powershell-coverage.xml`:

| File | LINE | INSTRUCTION |
| --- | --- | --- |
| `.claude/hooks/enforce-parallel-drift-gate.ps1` | 94.95% (94/99) | 94.53% (121/128) |
| `.claude/hooks/enforce-parallel-drift-gate-helpers.ps1` | 100.00% (66/66) | 100.00% (106/106) |
| **Union of the two** | **96.97% (160/165)** | 97.02% (227/234) |

Both files independently clear the 85% line floor. The union clears the pre-split single-file
benchmark of 96.53% (139/144). Both files are present among the 48 measured sourcefiles, so neither
is excluded from the denominator — verified by enumerating the XML's `sourcefile` nodes.

### PowerShell branch coverage

Counter types present in `artifacts/pester/powershell-coverage.xml`, enumerated directly: exactly
`CLASS`, `INSTRUCTION`, `LINE`, `METHOD`. **No `BRANCH` counter is emitted anywhere in the report.**
This reconfirms F8-I2 as a verified toolchain limitation of Pester v5 plus the PoshQC conversion
step, not a threshold waiver and not an omission of this feature. `INSTRUCTION` is the finest
analogue the toolchain produces and is reported above. No branch figure was invented, estimated, or
substituted.

## Mandatory Toolchain Loop — independently re-executed

| Stage | Command | Result |
| --- | --- | --- |
| Python format | `poetry run black --check .` | **EXIT 0** — 391 files unchanged |
| Python lint | `poetry run ruff check .` | **EXIT 0** — "All checks passed!" |
| Python type check | `poetry run pyright` | **EXIT 0** — 0 errors, 0 warnings, 0 informations |
| Python unit tests | `poetry run pytest --cov --cov-branch` | **EXIT 0** — 3201 passed / 0 failed |
| PowerShell format | recorded `mcp__drm-copilot__run_poshqc_format` EXIT 0 | UNVERIFIED by re-execution; the MCP tool is not in this reviewer's tool allowlist. Corroborated indirectly: `Invoke-PoshQCTest` ran clean and PSSA reported no findings during the same module session |
| PowerShell analyze | recorded `mcp__drm-copilot__run_poshqc_analyze` EXIT 0 | Same as above; the run log shows "PSScriptAnalyzer passed: no findings" |
| PowerShell tests | `Invoke-PoshQCTest` (repo root) | 2089 / 1 / 9 — the one failure is pre-existing, see below |
| Contract / schema | `pytest tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` | **EXIT 0** — 36 passed |

Suppression audit: `git diff c939b5b8..HEAD -- '*.py' | grep '^\+.*(# noqa|# type: ignore|pragma: no
cover)'` returns **no matches**. The feature adds zero suppressions, so no
`.claude/rules/python-suppressions.md` authorization is required.

### The single PowerShell failure is pre-existing

Confirmed by targeted re-execution
(`Invoke-Pester -Path tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`):

```
[-] enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file
    artifacts/pr_body_12.md when context exists
 at $decision.hookSpecificOutput.permissionDecision | Should -Be 'allow', ...:142
 Expected: 'allow'  But was: 'deny'
```

Same test, same assertion, same line 142 as the Phase 0 baseline. The file
`tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` is **absent from the branch diff**
(verified). It reads the real gitignored `artifacts/orchestration/orchestrator-state.json` instead of
a mocked seam, so it fails whenever an orchestrated run is live. Recorded as F8-I3, out of scope, and
correctly **not** edited to force a green gate.

## File Size Limit (`.claude/rules/general-code-change.md`, 500 lines)

Every non-Markdown file in the branch diff, measured by `wc -l`:

| File | Lines |
| --- | --- |
| `scripts/dev_tools/parallel_drift_detection.py` | **499** |
| `tests/scripts/dev_tools/test_parallel_drift_detection.py` | 454 |
| `scripts/dev_tools/parallel_drift_detection_cli.py` | 473 |
| `tests/scripts/dev_tools/test_parallel_drift_detection_conflicts.py` | 420 |
| `tests/scripts/dev_tools/test_parallel_drift_detection_cli.py` | 401 |
| `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_drift.py` | 401 |
| `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1` | 386 |
| `.claude/hooks/enforce-parallel-drift-gate.ps1` | 359 |
| `tests/scripts/dev_tools/test_parallel_drift_halt.py` | 350 |
| `scripts/dev_tools/validate_parallel_orchestrator_state.py` | 338 |
| all remaining | < 300 |

**Verdict: PASS.** No file exceeds 500 lines. F8-N10's zero-headroom condition on the PowerShell hook
and its suite is resolved (359 and 386, from 500 and 500). Recorded as F8-I13: the Python module
`parallel_drift_detection.py` now sits at 499 lines with one line of headroom, recreating the same
condition on the other surface.

## Wave-4 Confinement — independently verified, not accepted on the executor's word

F6 (issue #442) and F7 (issue #440) are executing concurrently against the same integration branch.
Per `.claude/rules/parallel-orchestration.md` `## Enum Ownership` and `## F7 Seam`, the relevant test
is edit **confinement**, not the absence of shared-file edits.

### `.claude/skills/parallel-orchestrate/SKILL.md` — PASS

Method: `git show c939b5b8:<path>` and `git show HEAD:<path>` were split on level-2 headings and
compared per section by SHA-256.

- Level-2 heading count: **16 at base, 16 at head**; the ordered heading list is **equal**.
- Fifteen of sixteen sections are **byte-identical**. The only changed section is
  `## Radius Drift Detection (F8)`, which grew from 3 to 297 lines.
- `## Mutation Protocol (F6)` — **byte-identical** (SHA-256 match).
- `## Enforcement Hooks (F7)` — **byte-identical** (SHA-256 match).
- Relative order preserved: F6 at index 13, F7 at index 14, F8 at index 15, at both base and head.

### `scripts/dev_tools/validate_parallel_orchestrator_state.py` — PASS

`git diff c939b5b8..HEAD` shows **exactly two added lines, zero removed**:

1. `from scripts.dev_tools._parallel_orchestrator_state_drift import validate_drift_gate`
2. `errors.extend(validate_drift_gate(state_map, CONTEXT))`

The dispatch call sits immediately after `_validate_collections` and immediately **before** the
`# BEGIN F7 EXTENSION SEAM -- PARALLEL_COHORT_BARRIER_VIOLATION` comment, so nothing was added inside
F7's reserved seam. Verified by reading the diff context directly.

### `.claude/settings.json` — PASS (append-only)

`+4 / -0`: one object appended to the end of the `Agent`-matcher hook array, registering
`.claude/hooks/enforce-parallel-drift-gate.ps1`. No existing entry reordered or altered.

### `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` — PASS (append-only)

`+7 / -0`: two coverage paths appended to the end of the `CodeCoverage.Path` list, each with an
explanatory comment naming issue #446. No existing entry removed or reordered. Both added paths are
the two drift-gate hooks, which is what keeps them inside the coverage denominator (see item d
below).

### Forbidden path classes — PASS

`git diff --name-only c939b5b8..HEAD` filtered by
`^\.claude/rules/|^\.github/instructions/|^\.claude/skills/orchestrate/SKILL\.md$|\.tsx?$` returns
**no matches**. No policy rule file, no Copilot instruction file, no orchestrate skill, and no
TypeScript or TSX file appears anywhere in the branch diff.

### The two named hook test files — PASS (untouched)

`git diff --name-only c939b5b8..HEAD -- tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1
tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` returns **empty**. Neither was
edited.

### Bundled mirror parity — PASS

SHA-256 comparison of each repo-root file against its
`extensions/drm-copilot/resources/claude-customizations/` mirror:

| File | Result |
| --- | --- |
| `.claude/hooks/enforce-parallel-drift-gate.ps1` | IDENTICAL |
| `.claude/hooks/enforce-parallel-drift-gate-helpers.ps1` | IDENTICAL |
| `.claude/settings.json` | IDENTICAL |
| `.claude/skills/parallel-orchestrate/SKILL.md` | IDENTICAL |

`extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` received the
same `+4` append (a subset of the repo-root `+7`, which additionally carries the comment lines) and
`pack-manifests/core.json` gained the two hook entries. Both are compelled by named repository parity
tests.

**Wave-4 confinement overall verdict: PASS on every constraint, independently verified.**

## Rule-by-Rule Compliance

| Rule | Verdict | Evidence |
| --- | --- | --- |
| `.claude/rules/tonality.md` | PASS | Sampled the SKILL.md additions, all module and function docstrings of the seven Python modules, both PowerShell hook headers, and the evidence artifacts. Language is literal and measured. The `#### Layer-1 Narrowing` section states the limitation plainly rather than minimizing it, and the CLI module docstring records its own residual gap explicitly |
| `.claude/rules/general-code-change.md` — design principles | PASS with one note | Pure logic is separated from I/O: `_parallel_drift_cli_io.py` holds the only filesystem reads, `default_timestamp()` is the only clock read, and every derivation takes timestamps as arguments. The new `parallel_drift_resolution.py` is a cohesive two-function module. Note recorded as F8-N12: the F8-B2 exclusion left the later-started comparator unreachable from the CLI production path |
| `.claude/rules/general-code-change.md` — file size | PASS | See the table above; maximum 499 |
| `.claude/rules/general-code-change.md` — error handling | PASS | `ParallelDriftInputError` and `DriftCliInputError` are specific; the hook's only broad `catch` re-throws with context (`throw "...received malformed JSON in CLAUDE_TOOL_INPUT: $_"`) or converts an unreadable checkpoint into an explicit fail-closed deny |
| `.claude/rules/general-code-change.md` — no new dependencies | PASS | The diff adds no dependency. `re` (stdlib) is the only new import |
| `.claude/rules/general-unit-test.md` — determinism | PASS | Every checkpoint is in memory, every timestamp is an explicit argument or module constant. No `sleep`, retry, or wall-clock wait |
| `.claude/rules/general-unit-test.md` — no temp files | PASS | Verified by inspection of all 12 Python test files and both Pester suites. The Pester suites mock `Test-Path` and `Get-ChildItem` rather than writing directories |
| `.claude/rules/general-unit-test.md` — no external processes | **FAIL, carried forward as F8-N8** | `enforce-parallel-drift-gate-helpers.Tests.ps1` `BeforeAll` resolves `python`/`py` from machine PATH and spawns it. The deviation is legitimate on the merits (it is the run-time seam binding this epic needs) but the required recording comment is still absent — see the finding ledger |
| `.claude/rules/general-unit-test.md` — coverage exclusions | PASS | No production path in any `omit`/`exclude` list; both new PowerShell hooks were affirmatively **added** to the coverage denominator |
| `.claude/rules/general-unit-test.md` — test file location | PASS | Every test mirrors its source: `tests/scripts/dev_tools/...`, `tests/scripts/claude-hooks/...`. No colocation |
| `.claude/rules/python.md` — toolchain | PASS | black, ruff, pyright, pytest all EXIT 0 in a single pass, re-executed |
| `.claude/rules/python.md` — typing | PASS | pyright strict, 0 errors, 0 `# type: ignore` added |
| `.claude/rules/python-suppressions.md` | PASS | Zero suppressions added |
| `.claude/rules/self-explanatory-code-commenting.md` | PASS with notes | Docstrings are present and contract-oriented on every class and function including private helpers; loops and branches carry intent comments (for example the candidate-list comment in `halted_item_keys` explains why no zero-candidate branch exists). Three stale or inaccurate comments recorded as F8-I10, F8-I11, F8-I12 |
| `.claude/rules/powershell.md` — 7+, advanced functions | PASS | Every function uses `[CmdletBinding()]`, `[OutputType()]`, and named parameters. `EventAt` uses `[Parameter(Mandatory)]` |
| `.claude/rules/powershell.md` — seams | PASS | Both read boundaries (`Get-ParallelDriftGateCheckpointContent`, `Test-ParallelDriftFindingPresent`) are injectable wrapper functions the tests mock |
| `.claude/rules/powershell.md` — deterministic tests, no PATH dependence | **FAIL, F8-N8** | As above. The hook suite's own `pwsh` resolution correctly prefers `(Get-Process -Id $PID).Path` over PATH; the helpers suite's Python resolution has no equivalent protection |
| `.claude/rules/parallel-orchestration.md` — enum ownership | PASS | No enum extended. `observed` was already a `blast_radius.source` member; `drift_events[].action` gained no `resolved` member; the resolution is derived from `items[].blast_radius` alone |
| `.claude/rules/parallel-orchestration.md` — no schema field added | PASS | `observed_radius` is a **stdout payload** key, not a checkpoint field. `blast_radius` already carries the six invariant-9 keys |
| `.claude/rules/parallel-orchestration.md` — prohibited keys | PASS | No `depends_on` or `integration_branch` produced anywhere |
| `.claude/rules/parallel-orchestration.md` — F7 seam | PASS | Verified empty of F8 content, above |
| `.claude/rules/parallel-orchestration.md` — no JSON Schema | PASS | Enforcement is validator logic plus prose. No schema file authored or read |
| `.claude/rules/quality-tiers.md` — uniform coverage | PASS | 92.04% line / 84.14% branch repo-wide; every new file at 100% line |
| `.claude/rules/quality-tiers.md` — tier classification | Carried forward as F8-I1 | `quality-tiers.yml` is absent at the repository root, verified absent at `c939b5b8`. A repository-level gap, not caused by and not fixable within F8 |
| `.claude/rules/ci-workflows.md` | N/A | No workflow YAML in the diff |
| `.claude/rules/benchmark-baselines.md` | N/A | No file under `scripts/benchmarks/**` in the diff |
| `.claude/rules/orchestrator-state.md` | N/A | The standard orchestrator-state validator is untouched |

## Finding Ledger

### Blocking — none

| ID | Status |
| --- | --- |
| F8-B1 | **CLOSED.** See `code-review.2026-08-09T07-23.md` `## F8-B1 Closure` for the verification method and the deadlock analysis |
| F8-B2 | **CLOSED.** See `code-review.2026-08-09T07-23.md` `## F8-B2 Closure` |

### Closed this cycle — explicitly not carried forward

| ID | Closure |
| --- | --- |
| F8-N1 | CLOSED. `docs/features/potential/2026-08-09-parallel-drift-gate-typescript-parity-divergence.md` exists, matches `docs/features/potential/template.md` heading-for-heading, and records the missing dispatch, the divergent error set, the insertion point outside the F7 seam, and Python's interim authority. No `.claude/rules/**` and no TypeScript file was edited |
| F8-N2 | CLOSED. The SKILL.md `#### Layer-1 Narrowing` section now names the recovery action for a spurious deny: re-record the radius from the later observed diff, which satisfies both runtimes because it is disjunct (b) |
| F8-N3 | CLOSED. Verified below |
| F8-N4 | CLOSED. Verified below |
| F8-N6 | CLOSED. The IC-6a amendment is appended to `evidence/other/upstream-contract-reconciliation.2026-08-08T21-19.md` under its own dated heading, stating the delivered two-argument signature and its derivation from IC-3a |
| F8-N9 | CLOSED. `evidence/qa-gates/acceptance-criteria-checkoff.2026-08-09T00-01.md` splits US-4 into three clauses with two named owners and states that the earlier disposition deflected the "never halted" clause to F6 in error |
| F8-N10 | CLOSED. The hook is 359 lines and its suite 386, from 500 and 500. Split parity verified below (item d) |

### F8-N3 closure — verified

- `Test-ParallelDriftFindingPresent` now declares
  `[Parameter(Mandatory)][AllowEmptyString()][string] $EventAt`. **Mandatory: confirmed.**
- It rejects a non-canonical `EventAt` before touching the filesystem
  (`if (-not (Test-ParallelDriftGateCanonicalTimestamp -Value $EventAt)) { return $false }`), so an
  unusable reference timestamp denies rather than being compared across shapes.
- For each candidate entry it requires the embedded substring to be canonical **and**
  `[string]::CompareOrdinal($stamp, $EventAt) -ge 0` — "at or after", as specified.
- **Layer-1 contract preserved.** `grep -nE '\bgit\b|Invoke-GitExe|-Filter|-like|Get-Content|
  Select-String'` over the hook and its helpers returns: one `Get-Content` (the checkpoint read
  seam, which is the gate's own input, not a finding file), one `[regex]::Matches` (prompt scanning
  for the feature-folder token, not path-glob matching), and three prose mentions inside comments.
  **No git invocation. No path-glob match. No finding-file content read** — only `$entry.Name` is
  inspected, via `StartsWith`/`EndsWith` with `StringComparison.Ordinal` and a fixed-offset
  `Substring`.
- **Fail-closed when `LatestAt` is absent: confirmed.** `Get-ParallelDriftGateUnresolvedState`
  returns `LatestAt = @{}` whenever `Malformed` is true. The call site sets `$eventAt = ''` when the
  key is absent, and `if ($eventAt -and (Test-ParallelDriftFindingPresent ...))` short-circuits to
  false, falling through to `Get-ParallelDriftGateBlockDecision`. There is no bare-presence fallback
  path. A dedicated test asserts the non-canonical-`EventAt` denial.

**Verdict: PASS.**

### F8-N4 closure — verified

- Both runtimes now gate the disjunct-(b) ordinal comparison on a canonical shape:
  `CANONICAL_TIMESTAMP_RE = r"^\d{4}-\d{2}-\d{2}T\d{2}-\d{2}$"` in
  `scripts/dev_tools/_parallel_drift_shape.py`, and
  `$script:CanonicalTimestampPattern = '^\d{4}-\d{2}-\d{2}T\d{2}-\d{2}$'` in the PowerShell helpers.
  The pattern text is character-identical. PowerShell uses `-cmatch` so the literal `T` is
  case-sensitive in both runtimes, matching Python's `re.match`.
- **Seam binding is genuine.** `$script:ParityRows` is one shared table of 21 JSON literals. The
  concatenated table is piped over stdin into a live Python process that calls
  `unresolved_drift_item_keys` and returns one verdict per row; the **same** rows are then evaluated
  through `Get-ParallelDriftGateUnresolvedState` and disagreements are collected. Python's verdicts
  are computed at run time. **Neither side carries a frozen expectation.** The table grew from 17 to
  21 rows, confirmed by counting.
- **New-row discrimination, evaluated per row:**

| Row | Pre-fix verdict | Post-fix verdict | Discriminating? |
| --- | --- | --- | --- |
| colon-bearing `computed_at` (`2026-01-02T00:00`) against hyphen-bearing `at` (`2026-01-02T00-00`) | resolved — `:` (0x3A) > `-` (0x2D) at index 13, so the raw `>` reported later | unresolved | **YES** |
| colon-bearing `at` against hyphen-bearing `computed_at` (`2026-01-03T00-00`) | resolved — index 9 `'3' > '2'` | unresolved | **YES** |
| truncated `computed_at` (`2026-01-03T00`) | resolved — index 9 `'3' > '2'` | unresolved | **YES** |
| non-string `computed_at` (`20260103`) | unresolved — the prior `is_non_empty_string` guard already rejected it | unresolved | **NO** |

  The executor's statement that one of the four rows is non-discriminating is **accurate**, and the
  table's own comment records it ("The fourth is unresolved by shape alone"). Three of four rows
  genuinely separate pre-fix from post-fix behavior.
- A second `It` block asserts the four canonical rows are unresolved **directly**, not only as
  agreement with Python, so a regression that made both runtimes fail open together would still
  fail. This is the correct construction and is worth noting as a strength.
- A reverse binding exists in `test_parallel_drift_timestamps.py`:
  `re.match(CANONICAL_TIMESTAMP_RE, default_timestamp())` binds the CLI's live clock format to the
  predicate's shape, so changing `TIMESTAMP_FORMAT` becomes a test failure instead of a silent
  universal resolution failure.

**Verdict: PASS.**

### Non-blocking — carried forward, still open

| ID | Title | Status |
| --- | --- | --- |
| F8-N5 | No run-time binding between the documented CLI surface in SKILL.md `#### CLI Invocation` and `build_parser()` / `evaluate_drift`'s key set | **OPEN.** The executor declared it out of scope with no task planned or executed, which is transparent. Verified still absent: no test extracts the fenced block. The unbound surface **grew** this cycle — the documented JSON payload gained a ninth key, `observed_radius`, and the parser gained `--computed-at`, both now documented in prose with no run-time check |
| F8-N7 | No code appends the `mutations[]` entry or increments `recolor_generation` | **OPEN, F6-owned.** No F8 action is possible; closes when F6 (issue #442) lands. Recorded so the SP-7 check-off is not read as a delivered checkpoint write |
| F8-N8 | Cross-runtime seam test spawns `python` resolved from machine PATH against two rules, with no recorded exception | **OPEN.** Verified by grep: neither Pester suite contains any reference to `general-unit-test`, `powershell.md`, "external process", or "machine PATH". The required deviation comment was not added. Declared out of scope by the executor |

### Non-blocking — new this cycle

| ID | Title |
| --- | --- |
| F8-N11 | SKILL.md step 7 does not state how the parent obtains a `computed_at` strictly later than the event's `at`; the CLI defaults `--computed-at` to `--at` |
| F8-N12 | The F8-B2 exclusion leaves the later-started comparator unreachable from the CLI production path |
| F8-N13 | Two evidence artifacts mischaracterize the seam test's fail-closed invariant as holding for the `ConvertFrom-Json` coercion divergence |
| F8-N14 | Now-public `halted_item_keys` no longer validates a pair endpoint absent from `items[]` |
| F8-N15 | The MCP PoshQC coverage-denominator divergence has no durable repo-level record and silently understates coverage obligations for F6 and F7 |

Each is stated in full with its evidence in `code-review.2026-08-09T07-23.md`.

### Informational

| ID | Item |
| --- | --- |
| F8-I1 | `quality-tiers.yml` absent at the repository root; verified absent at `c939b5b8`. Repository-level |
| F8-I2 | PowerShell branch coverage not emitted; verified by counter-type enumeration at this audit. Toolchain limitation |
| F8-I3 | The `enforce-pr-author-skill` Pester failure; verified pre-existing and correctly not edited |
| F8-I4 | Property-test density satisfied for the tier the rule file's examples imply for dev tooling (T4, density "none") |
| F8-I5 | Section-title deviation from `## Radius Drift Detection and Drift Gate`; the reserved title is `## Radius Drift Detection (F8)` and filling it in place was mandatory |
| F8-I6 through F8-I9 | Carried forward unchanged from cycle entry for the wave-4 integrator |
| F8-I10 | Helper count stated as "seven" in the runsettings comment and the hook test header, "eight" in the hook `.NOTES`, the helpers module header, and the helpers test header. Eight is correct now; "seven" was correct for the number **moved** |
| F8-I11 | The hook's dot-source comment claims "Guarded so a missing file produces a clear error", but no `Test-Path` check or `try/catch` guards `. $script:ParallelDriftGateHelpersPath` |
| F8-I12 | `select_halted_item`'s new docstring names the call site `_halted_item_keys`, the pre-rename identifier |
| F8-I13 | `scripts/dev_tools/parallel_drift_detection.py` at 499 lines, one line of headroom — the F8-N10 condition recreated on the Python surface |
| F8-I14 | `powershell-test-baseline.2026-08-09T00-01.md` states a 47-file denominator and `coverage-delta.2026-08-09T00-01.md` states 48, without cross-referencing that the helpers module was added between the two captures. Both are internally correct; this audit measured 48 |
| F8-I15 | `evidence/other/shared-file-edit-confinement.2026-08-09T03-19.md` verifies confinement against `HEAD` rather than `c939b5b8` and quotes a stale `3176 passed`. This audit verified confinement against `c939b5b8` directly and it passes |
| F8-I16 | `pack-manifests/core.json` places `enforce-parallel-drift-gate-helpers.ps1` after `enforce-parallel-drift-gate.ps1`, which is not ordinal sort order (`-` 0x2D sorts below `.` 0x2E). No parity test failed, so the list's ordering convention is evidently not strictly ordinal |

## Overall Policy Verdict

**PASS with 8 open Non-blocking findings and 16 Informational items. Blocking count: 0.**

The two Blocking findings are genuinely closed, verified by re-executing the derivations rather than
by reading the claims. Both fail-open paths are closed. Wave-4 confinement holds on every constraint
under independent verification. No regression. The exit gate is satisfied.
