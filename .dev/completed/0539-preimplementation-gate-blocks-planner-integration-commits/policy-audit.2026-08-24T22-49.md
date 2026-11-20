# Policy Compliance Audit — Issue #539 (S7 Feature Review)

- Feature: 2026-08-24-preimplementation-gate-blocks-planner-integration-commits-539
- Branch: `bug/preimplementation-gate-blocks-planner-integration-commits-539`
- Base: `main` @ merge base `cdfd69f6b86f15601241c0ed96e99d322af9fb47`
- Head: `7611d576c27edb6ff2c12e1bb879204e5f78c2df` (11 commits, 54 files, +4633/-107)
- Work mode: `full-bug` (AC source: `spec.md` only)
- Reviewer: feature-review agent
- Date: 2026-08-24T22-49

## Scope

Audit scope is the full branch diff `cdfd69f6..7611d576` against `main`, cross-checked against
`artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` (both fresh: they
record the exact head SHA and merge base above).

## Rejected Scope Narrowing

None. The caller supplied the full feature-vs-base scope and no narrowing instruction was
detected.

## Policy Verdicts

| Policy | Verdict | Evidence |
| --- | --- | --- |
| Policy documents unmodified (`.github/instructions/`, `.claude/rules/`) | PASS | `git diff --name-status` for the range contains no path under either tree. |
| Tone policy (agent-authored content) | PASS | New skill prose, hook comments, test comments, and evidence artifacts are factual and neutral; no humor, hyperbole, or decorative metaphor observed. |
| General code change — simplicity, separation of concerns | PASS | The pathspec classifier is pure string logic (no disk, process, network, or environment access), extracted to a dot-sourced sibling helper; the hook change is a minimal allow-side branch in `Test-ImplementationCommand`. |
| File size limit (500 lines) | PASS | Measured: Claude hook 382 content lines, Codex hook 382, both helpers 349, new test suites 267 and 271, `legacy-codex-hook-contracts.Tests.ps1` 494. All <= 500. |
| Fail fast / no silent error swallowing | PASS | Every parse ambiguity returns `$false` (deny); no catch-all handlers added. |
| PowerShell rules — `CmdletBinding()`, approved verbs, `[OutputType([bool])]` on predicates | PASS | `Split-`, `ConvertTo-`, and `Test-` verbs used; all four helper functions carry `CmdletBinding` and `OutputType`; predicates return `[bool]`. |
| Enforcement hooks must not gain a Python leg | PASS | All new hook-side files are `.ps1`; no Python added under `.claude/hooks/` or `.codex/hooks/`. |
| Unit test policy — independence, isolation, determinism, no temp files, no external processes | PASS | Both new suites drive the pure seam `Invoke-OrchestrationPreimplementationGateDecision` with an in-memory not-ready checkpoint; no disk I/O, no child processes, no temporary files. |
| Test file location (`tests/` mirroring production tree) | PASS | `tests/scripts/claude-hooks/...CommandExemption.Tests.ps1` and `tests/scripts/codex-hooks/...command-exemption.Tests.ps1` mirror the hook locations per the established layout. |
| Coverage Exclusion Policy — new production files enter the denominator | PASS | Both helper files listed in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (lines 135, 206) and the bundled mirror; `test_poshqc_bundled_parity.py` passes (re-run this review, part of 11 passed). No production `exclude` entries added. |
| Trigger regex unmodified (out-of-scope guard, spec AC 14) | PASS | Diff hunk shows the git staging trigger pattern text byte-unchanged; only the loop around the pattern array changed. |
| Push-down pair contracts | PASS | Independently hashed all eight files this review: Claude hook pair `bf3fe18d...` identical, Claude helper pair `45c339fd...` identical, Codex hook pair `db69f084...` identical, Codex helper pair `45c339fd...` identical. Matches `evidence/other/pair-hash-recomputed-final.2026-08-24T22-24.md` exactly. |

## Toolchain and Test Verification (re-run this review at HEAD)

- Pester, four suites (both new exemption suites, the unmodified pre-existing Claude suite, the
  Codex contract suite): **194 tests, 0 failures** (`Invoke-Pester`, this review).
- Python parity: `test_push_down_claude_resource_contracts.py` plus
  `test_poshqc_bundled_parity.py` — **11 passed** (this review).
- Executor QA-loop evidence at HEAD accepted for format/analyze: PoshQC format 0 files changed,
  analyze 0 findings (`evidence/qa-gates/final-poshqc-format.2026-08-24T22-08.md`,
  `final-poshqc-analyze.2026-08-24T22-08.md`); full scoped Pester run 1778 tests, 0 failures
  (`evidence/qa-gates/final-pester.2026-08-24T22-24.md`, EXIT_CODE 0).

## Coverage Verification

Languages with changed files in the branch diff: **PowerShell only** (hooks, helpers, tests,
runsettings). No `.py`, `.ts`, or `.cs` file changed; Python/TypeScript/C# coverage is therefore
legitimately not applicable to this branch (zero changed files per language). Markdown and JSON
changes are not coverage languages.

**PowerShell: PASS.**

- Coverage artifact present at `artifacts/pester/powershell-coverage.xml` (JaCoCo shape).
  Parsed this review, keyed on the enclosing `package` element (the four files come in
  same-named pairs):
  - `.claude/hooks` package — `enforce-orchestration-preimplementation-gate.ps1`: 102/113 = **90.3%**
  - `.claude/hooks` package — `...-helpers.ps1` (new): 112/118 = **94.9%**
  - `.codex/hooks` package — `enforce-orchestration-preimplementation-gate.ps1`: 124/125 = **99.2%**
  - `.codex/hooks` package — `...-helpers.ps1` (new): 112/118 = **94.9%**
- New files (both helpers): 94.9% >= 85%. Modified files (both hooks): 90.3% and 99.2% >= 85%,
  and no regression against baseline (Claude 90.0% -> 90.3%, Codex 99.2% -> 99.2%, per
  `evidence/qa-gates/coverage-delta.2026-08-24T22-24.md`; post-change values re-verified against
  the XML this review).
- Branch coverage: not applicable — Pester measures line/command coverage only; per
  `.claude/rules/quality-tiers.md` no branch threshold applies to PowerShell. No FAIL is
  recorded for the absent branch figure.
- Repo-wide note: the committed XML's report-level line total (62.8%) is a **scoped-run
  artifact**, not a repo-wide measurement — the run's `ScanFolders` was limited to the three
  hook/runtime test folders while the coverage denominator lists production files exercised only
  by suites outside that scan set. The per-file figures for all changed and added files, and the
  no-regression comparison, are the applicable gates for this branch and all pass. Repo-wide
  PowerShell coverage enforcement remains with the standing full-run PoshQC gate, which this
  branch does not weaken (it adds files to the denominator together with tests that cover them
  at 94.9%).
- Known tooling caveat (D-EXEC-5, resolved): `mcp__drm-copilot__run_poshqc_test` reads the
  installed extension's runsettings and cannot display the new files' coverage rows. The
  authoritative measurement used the self-hosted module directly. The MCP runner's silence is
  not a coverage failure.

## Evidence Location Compliance

- `scripts/dev_tools/validate_evidence_locations.py --root .` — exit 0, no violations.
- Branch-diff scan for `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`,
  `artifacts/coverage/` — zero matches. All evidence is written under
  `<feature-folder>/evidence/<kind>/` (baseline, qa-gates, regression-testing, other).
- No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` events: no non-canonical evidence path was supplied
  by any caller.

## Fail-Closed Safety Review (adversarial, allow-side widening)

The change widens what the gate admits, so the audited risk is bypass, not false denial.
Findings:

1. **Exemption granted only on a positive parse.** `Test-ExemptOrchestrationStagingCommand`
   returns true only when the whole line splits cleanly, every segment tokenizes with balanced
   quotes, every segment's first token is case-sensitively `git`, the second token is
   case-sensitively `add`/`commit`, every dash token is in the modeled set (message options
   only, `commit` only), at least one operand exists, and every operand passes the five-tree
   prefix test. Every other path returns false, restoring the unchanged deny.
2. **Interpolation/redirection rejected pre-parse.** A dollar sign, backtick, `>` or `<`
   anywhere in the line denies before splitting, so command substitution, variable expansion,
   process substitution, and redirection cannot smuggle operands.
3. **Escaped-quote divergence from bash is safe.** The scanner does not honor backslash quote
   escapes; a bash-escaped quote leaves the scanner's quote count unbalanced (deny), and
   constructed balanced cases produce extra tokens that must each independently pass the prefix
   test. Checked by construction against adversarial spellings; no case was found where the
   scanner's operand view is exempt while bash's real operand set escapes the trees.
4. **Expansion forms cannot escape.** Tilde-prefixed, brace-expansion, `./`-prefixed,
   backslash-escaped-space, and line-continuation spellings all fail the prefix test or
   tokenize into a failing operand; glob operands pass only when the literal prefix before the
   first of `*`, `?`, `[` starts with an exempt tree (so `docs/features/active*` and
   `docs/features/*` deny); any `..` component denies; absolute (leading-slash, drive-letter,
   UNC) spellings deny; every colon-led operand (all pathspec magic) denies.
5. **Message-option modeling is exact.** Only `-m <v>`, `-m<v>`, `--message <v>`, and
   `--message=<v>` are consumed, on `commit` only; `-m` as the final token denies; a
   path-looking message value is consumed as the message, leaving zero operands (deny — verified
   `git commit -m docs/features/active/plan.md` denies). `git add` admits no dash token at all.
   `-am`, `--amend`, option abbreviations, and every unmodeled dash token deny.
6. **Chained lines are all-segments-exempt.** Every segment — including non-trigger segments —
   must independently parse as a recognized all-exempt invocation; the classifier loop
   additionally keeps testing the other implementation patterns, so
   `git add docs/... && poetry run pytest` still classifies as implementation. This is strictly
   more restrictive than a minimal reading of D4 row 13 (deny-direction; see code review,
   non-blocking note N2).
7. **Case handling degrades to deny.** The trigger match is case-insensitive but the parser is
   case-sensitive (`-cne 'git'`), so an upper-cased spelling classifies as implementation and
   denies.

No bypass path was identified. The exemption cannot fire for any operand form outside the five
exempt trees.

## Deviations Reviewed

- **D-EXEC-1 (accepted):** direct authoring instead of `powershell-typed-engineer` delegation.
  Assessed immaterial: the same toolchain gates, file-size cap, and batch budget applied, and
  every gate was re-verified independently at HEAD in this review.
- **D-EXEC-2 (adjudicated this review):** spec documentation defect, non-blocking. See
  `feature-audit.2026-08-24T22-49.md` and `remediation-inputs.2026-08-24T22-49.md`.
- **D-EXEC-3 / D-EXEC-4 / D-EXEC-5 (closed):** bookkeeping-order, superseded-premise, and
  coverage-mechanism deviations; all verified consistent with the delivered evidence.
- **Stale pair-hash artifacts:** `evidence/other/claude-pair-hash.2026-08-24T19-57.md` and
  `evidence/other/codex-pair-hash.2026-08-24T20-06.md` record mid-execution hashes superseded by
  `evidence/other/pair-hash-recomputed-final.2026-08-24T22-24.md`, which matches this review's
  independent hashing. Not a parity failure; non-blocking recommendation recorded in the code
  review (the final artifact already documents the supersession).

## Blocking Findings

None.

## Overall Verdict

**PASS.** No policy violation found in the branch diff. One non-blocking spec documentation
correction is required (D-EXEC-2, detailed in the remediation-inputs artifact).
