# [P6-T20] Self-review against the policy-audit, code-review and feature-audit templates

Timestamp: 2026-11-05T23-10
Command: walk of `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, `code-review.yyyy-MM-ddTHH-mm.md` and `feature-audit.yyyy-MM-ddTHH-mm.md` against `git diff MERGE_BASE HEAD` (146 files, 11908 insertions, 176 deletions, 34 commits) and every AC; supporting read-only checks: `ruff check --no-cache --select D100,D101,D102,D103,D104,D105,D106,D107` over `PYLIB` and `PYTESTS`, a per-file count of `for`/`while` lines with no comment directly above them, `format_json --check --verbose`, `validate_json --verbose`
EXIT_CODE: 1
Output Summary: RESULT FAIL. Two FAIL rows: policy-audit 2.4 "Docs/docstrings" and 2.4 "Comment why, not what". The twelve `PYLIB` modules and the fifteen `PYTESTS` files do not meet `.claude/rules/self-explanatory-code-commenting.md` (`paths: **/*.py`). The helper has 0 full-line comments, and 97 of its 97 `for`/`while` loops have no intent comment. Its docstrings are single sentences without `Args:`/`Returns:`/`Raises:` sections. Branch chains carry no decision-logic comments. The fix cannot stay inside the plan: `routes.py` (467 logical lines) would pass the 500-line limit [P6-T15] asserts, which forces a module split, and a split adds files, manifest entries, mirror copies and classification rows that no task covers. Per the delegation, execution stops and reports instead of improvising. [P6-T20] stays unchecked. Every other row is PASS or N/A, except four rows marked PENDING-CI with S9/S10/S22 and their user-story pairs.

`MERGE_BASE` = `git merge-base origin/epic/documentation-estate-tooling-integration HEAD`. Scratch helpers are recorded only as `SCRATCH`.

## FAIL rows (blocking)

| Template / item | Status | Evidence | Required correction |
|---|---|---|---|
| policy-audit 2.4 Docs/docstrings | FAIL | `ruff --select D100-D107` over `PYLIB`: "All checks passed!" (every function and class has a docstring). The docstrings are one sentence, for example `"""Run the selected analyzers and return the response object."""` on `run_request` in `protocol.py`. They lack the parameters, returns, raises and side-effects content the commenting rule requires ("Mandatory Function and Method Docstrings", "Mandatory Class Docstrings"). Over `PYTESTS`: 146 findings (38 D101, 104 D102, 4 D103) for test classes and methods. | Expand every helper docstring to the Google-style contract. Test classes and methods: add docstrings, or obtain an owner ruling that descriptive `test_` names satisfy the rule for tests (`general-unit-test.md` "Documentation" accepts "a descriptive name and/or a short docstring"; `tests/scripts/dev_tools` shows 440 findings of the same kind). |
| policy-audit 2.4 Comment why, not what | FAIL | Full-line comment count per helper file: 0 in all twelve. `for`/`while` lines with no comment directly above: architecture 7/7, cli 8/8, cli_argparse 7/7, cli_click 17/17, cli_typer 6/6, imports 3/3, protocol 13/13, public_api 11/11, routes 17/17, source 8/8. Non-trivial comprehensions and `if`/`elif` chains (for example the analyzer dispatch in `run_request`) carry no intent or decision-logic comment. | Add loop-intent, comprehension-intent, decision-logic and meta-what comments per the rule's "Loops and Comprehensions", "Branching" and "Multi-Step Blocks" sections. `routes.py` (467), `imports.py` (370) and others would grow, and `routes.py` would exceed 500. A plan revision therefore has to add a split of `routes.py` (and any other file crossing 500), with its tests, mirror copy, `PYPACK` entry and classification row. Then [P5-T1], [P5-T5] and the Phase 6 loop re-run from [P6-T1]. |

## Policy audit template

| Item | Status | Evidence |
|---|---|---|
| Coverage metrics by language (Python, PowerShell, JSON rows) | PASS | Python baseline 96.67% line / 93.64% branch, post-change 96.79% / 93.82%, new-code per file 96.90 to 100 line and 92.31 to 100 branch (`coverage-delta.2026-11-04T20-43`). PowerShell baseline 93.77%, post-change 94.33%, new modules 100% line. JSON: N/A (data files). Pester branch coverage is not measured (rule exemption). |
| Coverage Evidence Checklist: PowerShell baseline / post-change artifacts, comparison | PASS | `baseline-pester-coverage.2026-11-04T15-53`, `qa-pester-coverage.2026-11-04T20-43`, `coverage-delta.2026-11-04T20-43` |
| Coverage Evidence Checklist: TypeScript artifacts | N/A | No TypeScript production file changed; only the Jest test `discovery-resources.test.ts` (Jest runs in `isolation-jest.2026-11-04T20-44`). |
| Executive summary: policy documents evaluated | PASS | `phase0-instructions-read.2026-11-04T14-04` lists the general, Python, PowerShell and TypeScript policies. |
| Temporary artifacts cleanup | PASS | Every helper script lives under `SCRATCH`, outside the worktree; [P6-T17] porcelain status is empty. |
| 1.1 Independence | PASS | `isolation-python-reversed` (208 passed, reversed), `isolation-pester-shuffled` (3 seeds, 177 passed each), `isolation-jest` (seed 1031). |
| 1.1 Isolation | PASS | One module per helper unit (`test_docs_python_native_<area>.py`). Pester suites per module: protocol, interpreter, parity, inventory. |
| 1.1 Fast execution | PASS | 208 helper tests in 0.87 s; the shuffled Pester runs over 10 suites complete with 177 tests each. |
| 1.1 Determinism | PASS | No real process, clock or network; `InvokeProcess` is a test-local scriptblock; seeded property tests record the seed in `-Because`; `p3-determinism` passed. |
| 1.1 Readability and maintainability | PASS | Descriptive `test_` and `It` names, for example `It 'ships exactly the D3 allowlist entry'`. The docstring gap is recorded under the 2.4 FAIL rows. |
| 1.2 Baseline coverage documented | PASS | `baseline-pytest-coverage.2026-11-04T15-11`, `baseline-pester-coverage.2026-11-04T15-53` |
| 1.2 No coverage regression | PASS | Python +0.12 line, +0.18 branch; PowerShell overall did not decrease; every changed line of the three edited LIB files is covered. |
| 1.2 New code coverage >= 90% | PASS | Lowest new Python file: `cli_click.py` 96.90% line; new PowerShell modules 100%. |
| 1.2 Comprehensive coverage | PASS | Per-file JSON entries for all twelve helper files; four Pester suites cover every exported function of the two new modules. |
| 1.2 Positive flows | PASS | Corpus round trip per identifier (`p3-corpus`); valid protocol round trip (`p3-protocol`). |
| 1.2 Negative flows | PASS | Each request defect in `p3-protocol` (31 passed); each output defect in `p4-protocol` (26 passed). |
| 1.2 Edge cases | PASS | BOM, CRLF/CR, U+2028 and form feed (`p1-source`); edge limit 1000 (`p2-architecture`); depth 17 and cycles (`p2-routes`). |
| 1.2 Error handling | PASS | Exit 2/3/4 paths (`p3-protocol`, `p3-entry`); each reason token (`p4-interpreter`). |
| 1.2 Concurrency | N/A | No concurrent code. |
| 1.2 State transitions | PASS | Candidate fallback order python3, python, py with the later success used (`p4-interpreter`). |
| 1.3 Clear failure messages | PASS | Pester `-Because` texts carry seeds; pytest assertions compare structured facts. |
| 1.3 Arrange-Act-Assert | PASS | Inspected test bodies build inputs, call `main`/`entry` or the function, then assert. |
| 1.3 Document intent | PASS | Test names state the scenario; see the 2.4 FAIL row for docstrings. |
| 1.4 Avoid external dependencies | PASS | No process, network or file access; `qa-test-hygiene.2026-11-05T23-01` |
| 1.4 Use mocks/stubs | PASS | Test-local `InvokeProcess`/`TestFile` scriptblocks and the `Docs.TestSupport.psm1` fake; pytest uses `io.BytesIO`; 0 `Mock` calls in the four new suites. |
| 1.4 Environment stability | PASS | Temporary-file token search empty; `sys.dont_write_bytecode` set in `conftest.py`; `qa-bytecode` empty. |
| 1.5 Pre-submission review | PASS | This self-review; feature review follows. |
| 2.1 Clarify objective / read plans / document plan | PASS | Issue #1031, `spec.md`, the plan and its deviations section. |
| 2.2 Simplicity first | PASS | Standard-library helper over `ast`; thin PowerShell adapter reusing 1020/1022 functions. |
| 2.2 Reusability | PASS | Elements via `New-DocsSurfaceElement`, diagnostics via the 1022 aggregate helpers, JSON via `DocsJson.psm1`; no second digest implementation (`p4-parity` token check). |
| 2.2 Extensibility | PASS | Registry rows per identifier; protocol carries `protocol_version`. |
| 2.2 Separation of concerns | PASS | Pure protocol module (`DocsPythonNativeProtocol.psm1`) separate from the seam module; helper `protocol.py` separate from analyzers. |
| 2.3 Cohesive modules | PASS | One helper module per analyzer family (`cli_argparse`, `cli_click`, `cli_typer`, `routes`, `public_api`, `architecture`). |
| 2.3 At or below the 800-line hard limit | PASS | Largest production file 468 (`Invoke-DocsCommand.ps1`); no file at or above 700 (`qa-tiers-and-size.2026-11-05T22-58`). |
| 2.3 Public vs internal | PASS | Python internals `_`-prefixed (`_Resolved`, `_FileSites`, `_Route`); PowerShell exports through the module. |
| 2.3 No circular dependencies | PASS | Helper imports flow `protocol` to analyzers to `imports`/`source`; Pyright clean. |
| 2.4 Descriptive names | PASS | For example `Invoke-DocsPythonNativeInterpreter`, `module_dotted_name`, `statement_span`. |
| 2.4 Docs/docstrings | FAIL | See FAIL rows. PowerShell: comment-based help per function (13 and 11 `.SYNOPSIS` blocks). |
| 2.4 Comment why, not what | FAIL | See FAIL rows. |
| 2.5 Formatting | PASS | Black "1031 files would be left unchanged."; PoshQC format `formatted=0 already=714`. |
| 2.5 Linting | PASS | Ruff "All checks passed!"; PSScriptAnalyzer `findings=0`. |
| 2.5 Type checking | PASS | Pyright "0 errors, 0 warnings, 0 informations" (`qa-pyright.2026-11-04T19-49`). |
| 2.5 Testing | PENDING-CI | Pytest 16269 passed, 0 failed. Pester single-process: 15406 passed, 409 failed. The same 409 failures appear in the pre-change baseline on the host, and none is attributable to this branch (`qa-pester-coverage`, `isolation-pester-fresh`). The zero-failure result is pending on `poshqc / PowerShell QC` ([P6-T9], [P6-T14]). |
| 2.5 Full toolchain loop | PENDING-CI | Single clean pass for format, lint and type check; the Pester zero-failure gate is pending-CI. A fix for the FAIL rows restarts the loop. |
| 2.5 Explicit reporting | PASS | One artifact per step under `evidence/`. |
| 2.6 Summarize changes / design choices / supporting docs / next steps | PASS | Plan `## Deviations from spec.md`; spec and user-story AC check-offs; next steps in this file. |
| 3A.1 Black / Ruff / Pyright / Pytest | PASS | As in 2.5; Pytest 0 failed. |
| 3A.2 Strong typing | PASS | Pyright strict clean; no `Any` in `PYLIB`. |
| 3A.2 Dataclasses for value objects | PASS | `@dataclass(frozen=True)` for `Fact`, `Request`, `ParsedModule`, `RawDiagnostic` and others. |
| 3A.2 Protocols/ABCs for interfaces | N/A | No interface with multiple implementations; analyzers are functions. |
| 3A.2 Avoid utility classes | PASS | Module-level functions; no static-only class. |
| 3A.3 Specific exceptions | PASS | `RequestError(ValueError)`. The one `except Exception` is in `main` of `protocol.py`, the helper's process boundary. It maps every internal failure to exit 3 with the exception type name and no source text, as [P3-T1] requires. It does not swallow the failure. Ruff passes with no suppression. |
| 3A.3 Logging over print | PASS | No `print` in `PYLIB`; output is the protocol byte stream; no logging is configured in the helper process. |
| 3A.3 Invariants at construction | PASS | `parse_request` validates closed key sets, version and limits before a `Request` exists. |
| 3B.1 Invoke-Formatter / PSScriptAnalyzer / fix all findings | PASS | `formatted=0`; `findings=0`. |
| 3B.1 PowerShell 5.1 and 7.6+ compatible | N/A | Repository policy requires PowerShell 7+ (`.claude/rules/powershell.md` "Compatibility"); 5.1 is not a target. |
| 3B.2 Advanced functions | PASS | `CmdletBinding` on all 12 and 10 functions of the new modules. |
| 3B.2 Parameter validation | PASS | `Mandatory`, typed `[scriptblock]` and `[hashtable]` parameters. |
| 3B.2 Avoid global state | PASS | Script-scope values are constants assigned once (helper path, timeout, candidates, code pattern, stdout bound). |
| 3B.2 Error handling | PASS | `Set-StrictMode -Version Latest`, `$ErrorActionPreference = 'Stop'`. The three `catch` blocks classify a candidate failure into the reason token the spec requires, and the result surfaces as a diagnostic or finding. |
| 3B.3 Size / approved verbs / comment why | PASS | Verbs Get, New, Test, Invoke, ConvertFrom; sizes in 2.3. |
| 3B.4 Format / analyze / test / rerun | PENDING-CI | Same as 2.5 Testing. |
| 3C Bash | N/A | No bash file changed. |
| 3D.1 format_json / validate_json / `$schema` | N/A | The fixture and the two pack manifests lie outside the governed globs. Neither tool lists them, and all three parse as strict JSON. Both tools exit 1 on pre-existing governed files this branch does not touch (`examples/docs/v1/*`, `docs/discovery/templates/v2/*`, `scripts/host-tools.manifest.json`); recorded as Info. |
| 3D.2 Strict JSON / key order | PASS | Strict parse succeeds; the fixture has no CR byte (`native-corpus-census`). |
| 4A.1 Use Pytest / coverage expectation | PASS | 208 helper tests; new code >= 90% line. |
| 4A.2 Focused tests / mocking sparingly / organization | PASS | One test module per helper module; a search for `monkeypatch`, `unittest.mock`, `MagicMock` and `patch(` matches only the substring `patch(` inside the test name `test_all_four_analyzers_dispatch`, so no test uses a mock. The protocol tests inject failures through the `run` parameter of `main`. Tests mirror `PYLIB` under `PYTESTS`. |
| 4A.3 Naming conventions | PASS | `test_edge_limit_drops_edge_properties_but_keeps_the_count` and similar. |
| 4A.3 Docstrings/comments | FAIL | Covered by the 2.4 FAIL rows (146 missing test docstrings; uncommented loops in tests). |
| 4A.4 Use Pytest / no alternative runner | PASS | Pytest only. |
| 4B.1 Pester / PoshQC configuration | PASS | Pester 6 through `Invoke-PoshQCTest`. |
| 4B.1 PowerShell 5.1 compatible | N/A | As 3B.1. |
| 4B.2 Focused tests / behavior over implementation / mocking sparingly | PASS | 0 `Mock` calls in the four new suites; behaviors asserted through outputs and recorded seam calls. |
| 4B.2 Organization (mirror location) | PASS | `TESTS/DocsAnalyzerPythonNative.Tests.ps1` for `LIB/DocsAnalyzerPythonNative.psm1`; `TESTS/DocsPythonNativeProtocol.Tests.ps1` for `LIB/DocsPythonNativeProtocol.psm1`. |
| 4B.3 File naming / structure / grouping / comments | PASS | `*.Tests.ps1`; Describe 2/4/1/1, It 9/15/3/6 (static `It` lines; `-ForEach` expands cases). |
| 4B.4 PoshQC test command / no alternative runner | PENDING-CI | As 2.5 Testing. |
| 5 Test coverage detail | PASS | Per-file pairs in `qa-python-per-file-coverage.2026-11-04T19-59`; Pester per-file in `coverage-delta`. |
| 6 Test execution metrics | PASS | Pytest 16269 passed in 502 s; helper 208 in 0.87 to 2.85 s; Jest 33 passed. |
| 7 Code quality checks | PASS | As 2.5. |
| 8 Gaps and exceptions | PASS | Gaps recorded: the two FAIL rows; pending-CI Pester; the pre-existing JSON-tool failures. |
| 9 Summary of changes | PASS | 34 commits, 146 files (`qa-scope.2026-11-05T23-02`). |
| 10 Compliance verdict | FAIL | Not fully compliant while the 2.4 FAIL rows stand. |

## Code review template

| Item | Status | Evidence |
|---|---|---|
| Findings table | FAIL | Major: commenting-policy gap in `PYLIB` and `PYTESTS` (FAIL rows above). Info: pre-existing governed-JSON failures outside the diff. Info: the two guard files' pre-existing whole-file test-purity decision (`qa-test-hygiene`). |
| Python implementation audit | PASS | Standard library only, `ast.parse` sole parse entry (`p3-safety`), frozen dataclasses, typed public API, single boundary handler. |
| TypeScript implementation audit | N/A | No TypeScript production change. |
| PowerShell implementation audit | PASS | Seam calls only through the `[scriptblock]` parameter; guard class 5 matches exactly the D3 entry (`p4-guard`). |
| C# implementation audit | N/A | No C# file. |
| Test quality audit (determinism, isolation, speed, diagnostics) | PASS | As policy audit 1.1. |
| No secrets in code | PASS | No credential or token literal in the diff; forbidden-token scan clean. |
| No unsafe subprocess or command construction | PASS | No subprocess in `PYLIB` (`p3-safety`); PowerShell starts the interpreter only through `Context.InvokeProcess` with fixed arguments `-I -B -X utf8`. |
| Input validation at boundaries | PASS | Closed key sets, version and limits in `parse_request`; `Test-DocsPythonNativeResponse` validates every response field. |
| Error handling remains explicit | PASS | Exit 2/3/4 protocol errors; reason tokens; no silent catch. |
| Configuration / path handling is safe | PASS | Helper path is a repository-relative literal; packaging carve-out limited to `lib/docs/python` (`p5-packaging`). |
| Research log | N/A | No external research during execution. |
| Verdict / PR readiness | FAIL | Needs revision for the commenting-policy gap before PR. |

## Feature audit template

| Item | Status | Evidence |
|---|---|---|
| Scope and baseline | PASS | Base `epic/documentation-estate-tooling-integration`, `MERGE_BASE` derivation as above, head branch `feature/docs-surface-analyzer-python-native-1031-r2`. |
| Work mode resolution | PASS | `full-feature`; AC sources `spec.md` and `user-story.md`. |
| AC inventory | PASS | 22 + 22 checkbox criteria. |
| AC check-off consistency | PASS | `ac-status.2026-11-05T23-05`: 19/22 per source, text unchanged. |
| Overall feature readiness | FAIL | NEEDS REVISION while the FAIL rows stand. |

## Acceptance criteria rows

| AC | Status | Evidence |
|---|---|---|
| S1 / U1 | PASS | `p3-corpus`, `p4-parity` |
| S2 / U2 | PASS | `p2-*`, `p3-corpus`, `native-corpus-census` |
| S3 / U3 | PASS | `p4-inventory` |
| S4 / U4 | PASS | `p4-protocol`, `p4-interpreter`, `p4-inventory` |
| S5 / U5 | PASS | `p4-native-inventory` |
| S6 / U6 | PASS | `p4-inventory` |
| S7 / U7 | PASS | `p3-safety` |
| S8 / U8 | PASS | `manifests`, `p5-existing-pester`, `p5-push-down-contracts` |
| S9 / U9 | N/A (pending-CI) | Figures meet thresholds (`coverage-delta`); depends on pending-CI [P6-T9]. |
| S10 / U10 | N/A (pending-CI) | Local Black, Ruff and Pyright pass; the 3.11 floor is verified by the CI matrix. |
| S11 / U11 | PASS | `p4-native-inventory`, `p4-inventory` |
| S12 / U12 | PASS | `p3-safety`, `p4-protocol`, `p4-parity` |
| S13 / U13 | PASS | `p4-registry` |
| S14 / U14 | PASS | `bundle-mirror`; 17/17 pairs equal on the current head |
| S15 / U15 | PASS | `qa-bytecode`, `p4-interpreter` |
| S16 / U16 | PASS | `p4-interpreter`, `qa-test-hygiene` |
| S17 / U17 | PASS | `p4-guard` |
| S18 / U18 | PASS | `p5-packaging` |
| S19 / U19 | PASS | `qa-test-hygiene.2026-11-05T23-01` |
| S20 / U20 | PASS | `p3-determinism` |
| S21 / U21 | PASS | `qa-tiers-and-size.2026-11-05T22-58`, `p5-existing-pester` |
| S22 / U22 | N/A (pending-CI) | `poshqc / PowerShell QC` and `quality-checks7` on the PR head |
