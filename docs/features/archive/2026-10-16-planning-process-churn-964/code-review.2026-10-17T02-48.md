# Code Review: Planning-Process Churn (#964)

---

**Review Date:** 2026-10-17
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-16-planning-process-churn-964`
**Feature Folder Selection Rule:** the folder whose name ends in the canonical issue number `964`, named by the caller; no versioned subfolder exists.
**Base Branch:** `main` (merge base `b8fcd7790`, equal to the `origin/main` tip)
**Head Branch:** `bug/planning-process-churn-964` (head `1f017bd4b`)
**Review Type:** Initial review

---

## Executive Summary

The branch changes 260 files against the merge base. The code changes are small and well contained: two new validator modules (`plan_gate_document.py`, `plan-gate-document.ts`) implementing G11 to G13 with verbatim message parity, one new PowerShell helper (`premortem-section.ps1`), additions to three SubagentStop hooks, and three related fixes (Codex native-converter rewrite text, generator manifest newlines, and a Jest module-registry order dependence). The remaining changes are contract and agent prose across the Claude, Codex and Copilot surfaces, their bundle copies, and 44 regenerated Codex variants. Evidence reviewed: the PR context artifacts (fresh at head), the spec, plan and research, all 61 evidence files, a re-parse of the Python, TypeScript and PowerShell coverage artifacts, and check-only re-runs by this review of the generator check, 280 Python contract and new-module tests, three Jest suites, the tier check, the coverage-threshold check, the plan validator, the evidence-location validator, and an 82-pair byte-parity check.

**What changed:**
G11 reports line-number citations (prose, `path:line`, `#L` anchor), G12 reports commit SHAs, G13 reports plans above 40 tasks or 400 lines without a non-empty `## Size Justification`; both runtimes call them after G10. The planner hook now requires a complete `## Pre-Mortem` section and rejects line-reference `CITATION:` locators; the researcher hook requires the section for feature research. The executor hook classifies preflight runs from the delegation prompt in the subagent transcript (`Test-IsPreflightRun`, behind a `ReadTranscriptHead` seam), enforces the single-pass output rules, and allows a combined proportionate run to stop at preflight with no checked task. A new `execution-environment` skill states tool routes, command-text restrictions, the batch budget, hook context, CI shape and contract tests, and is preloaded or referenced on every surface.

**Top 3 risks:**
1. The SubagentStop envelope field `agent_transcript_path` and the transcript JSONL shape are not a documented contract; the reader degrades to the self-declared fallback (plan-file directive or a single `PREFLIGHT:` signal), so a format change silently weakens classification rather than blocking.
2. Branch hook changes are not exercised by isolated subagents until merge; their behavior rests on Pester suites, which pass with 100% line coverage of the executor hook.
3. A few surfaces still carry multi-round preflight wording (CR-1) and one stale CI-shape statement (CR-2), which can reintroduce the behavior this item removes if a planner follows them literally.

**PR readiness recommendation:** **Go** — no Blocker or Major finding; seven Minor, Nit or Info findings are listed for correction in the same pass, and AC-33 and AC-34 remain with the orchestrator.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.claude/skills/atomic-plan-contract/SKILL.md`, `.agents/skills/atomic-plan-contract/SKILL.md`, `.github/skills/atomic-plan-contract/SKILL.md`, `.agents/skills/atomic-planner/SKILL.md`, `.github/agents/atomic_planning.agent.md`, `.codex/agents/atomic-planner.toml`, `.codex/agents/atomic-planning.toml`, `.codex/agents/{python,powershell,csharp}-atomic-planning.toml`, `scripts/dev_tools/codex_native_converter/rewrites.py`, `extensions/drm-copilot/src/lib/codex-native-converter/rewrites-rules.ts`, `tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py` | `## Plan-Path Continuity Contract (Mandatory)` bullet "Planner MUST reuse the same file for all preflight revision iterations."; `atomic-planner` SKILL "reuse that same file for all preflight revision iterations"; `atomic_planning.agent.md` "Reuse that same file for every preflight revision iteration."; Codex planner TOMLs "Reuse the same target plan file for every preflight revision iteration"; the converter's planner-shorthand rewrite and the wrapper-contract pin of the same phrase | CR-1. Plural "every/all preflight revision iterations" remains after the at-most-one-return rule was introduced. | Reword to "reuse the same file for the single permitted preflight revision" (or "for the preflight revision, which occurs at most once") in every canonical surface; update the converter rewrite in both runtimes and the pinned fragment in `test_codex_agent_wrapper_contracts.py` together; regenerate Codex variants and re-run the mirror copy so bundle copies follow. | The phrase implies several revision rounds, which contradicts `### Single-Pass Preflight` and the item's goal. It does not mandate a loop, so it is not blocking. | `Grep` over canonical surfaces at head (13 canonical files plus bundle copies and 20 generated variants) |
| Minor | `.claude/skills/atomic-plan-contract/SKILL.md` (and `.agents`, `.github`, bundle copies) | `## Wrap-Tolerant Assertion Authoring (Mandatory)`, bullet "Name the runner and job for a Pester acceptance criterion." | CR-2. States that `poshqc / PowerShell QC` "runs every suite with coverage on `windows-latest`". Since the PoshQC sharding, suites run in `poshqc / PowerShell QC shard 1..3`, and `poshqc / PowerShell QC` is the aggregator that merges shard coverage, as the new brief's `## CI Shape and Required Checks` states. Pre-existing text (issue #743) in a file this item edits. | Rewrite the bullet to name the shard jobs as the runners and `poshqc / PowerShell QC` as the required aggregator, or replace the CI-shape description with a reference to the brief's `## CI Shape and Required Checks` (the design-level contract assigns CI shape to the brief); re-run the mirror copy and `test_plan_gate_document_docs.py`. | Two contract documents now give different CI shapes; the contract's own rule says the brief owns CI shape. | `.github/workflows/_poshqc.yml` job keys `poshqc-static`, `poshqc-shard`, `poshqc`, `poshqc-linux-hooks`; brief section `## CI Shape and Required Checks` |
| Minor | `scripts/dev_tools/plan_gate_document.py`, `extensions/drm-copilot/src/lib/validate/plan-gate-document.ts`, `.claude/rules/plan-acceptance-gates.md` | `G11_PATH_PATTERN` and `line_citations`/`lineCitations` (`://` skip); rule section `### Known false-positive classes — G11 and G12` | CR-3. A scheme-less `host.tld:port` token (for example `api.github.com:443` or `localhost.example:8080`) matches the G11 path form and is reported, because only tokens containing `://` are skipped. The class is not listed among the documented false-positive classes, and no test pins the behavior in either runtime. | Add a bullet "G11, a host and port written without a URL scheme" to the known false-positive classes in the rule file (and bundle copy), and add one case to `test_plan_gate_document.py` and `plan-gate-document.test.ts` asserting the current behavior (one finding), so the class is documented and both runtimes are held to the same result. | Spec Design 2 requires the documented false-positive classes; an undocumented class surfaces as an unexplained Blocking finding at preflight. | Code inspection of the path pattern and the `://` guard; the existing test covers only `https://example.com:8443/status` |
| Minor | `docs/features/active/2026-10-16-planning-process-churn-964/evidence/qa-gates/toolchain-rerun.2026-10-17T02-28.md` | Output Summary, Pester bullet | CR-4. Reports "Pester over `tests` in one fresh process: Passed=11046 Failed=0 Skipped=10 Total=11056" for the 02-16 to 02-28 window, but `artifacts/pester/pester-junit.xml` was last written at 02-03 UTC and records 11055 tests from the earlier run over `tests/scripts`. The re-run's counts have no on-disk source, and its scope (`tests`) differs from the plan's (`tests/scripts`). | Add a superseding note (new artifact, not an edit of the old one) that states the re-run's JUnit output path or, if it was not retained, that the figures were read from console output, and that the canonical JUnit reflects the 01-44 to 02-03 run over `tests/scripts`. Alternatively re-run Pester over `tests/scripts` and record counts from the JUnit file. | The brief and plan require Pester counts to be read from the JUnit file; an untraceable figure cannot be audited. No PowerShell file changed after 02-03 UTC, so the impact is evidentiary only. | `ls --time-style=full-iso artifacts/pester/`; JUnit totals `tests=11055 failures=0 errors=0 disabled=10` |
| Nit | `.claude/hooks/validate-executor-output.ps1` (and bundle copy) | `Get-JsonPropertyValue`, `Get-TranscriptFirstUserText`, default `ReadTranscriptHead` scriptblock in `Test-IsPreflightRun`; `Test-HasCanonicalBlockedText`; header `.DESCRIPTION` | CR-5. (a) New helpers pack several statements per line, and `Get-JsonPropertyValue` has no `[OutputType]`. (b) The BLOCKED match changed from case-insensitive to case-sensitive (`-cmatch`), so lowercase or title-case "blocked" prose no longer triggers the non-repairable execution-run block. The change is commented in code and tested (`does not treat lowercase blocked prose as a BLOCKED claim`) but is not stated in the hook header list or in `## Blocking Protocol` of `.claude/agents/atomic-executor.md`. | (a) Expand the one-liners to one statement per line and add `[OutputType([object])]`; this keeps the file under 500 lines (449 now). (b) Add one header bullet ("a BLOCKED claim is the uppercase token; lowercase prose is not a claim") and one sentence in the executor's `## Blocking Protocol` stating that the blocked state is reported with the uppercase `BLOCKED` token. | Readability of hook code; an undocumented enforcement change is harder to reason about when a run is unexpectedly allowed. Execution runs that stop early still fail the unchecked-task check, so the exposure is small. | Diff of `.claude/hooks/validate-executor-output.ps1`; `validate-executor-output.Preflight.Tests.ps1` |
| Nit | `tests/scripts/dev_tools/test_plan_gate_document_parity.py` | `test_document_gate_messages_match_expected_rows` | CR-6. Five parity rows are asserted in one loop, so the first failing row hides the others; the TypeScript twin uses `it.each`. | Convert to `@pytest.mark.parametrize("name, text, expected", _ROWS)` and move the apostrophe assertion into its own test. | Per-row isolation and parity of failure reporting with the Jest suite. | File inspection |
| Info | `extensions/drm-copilot/test/repo-automation-dispatch.test.ts` | whole file | CR-7. The file is at exactly 500 physical lines (trailing newline present) after this item's edits. | No change required; the next edit to this file should move cases into a new test file. | Zero headroom under the 500-line limit. | Python byte count: 500 newlines, ends with LF |
| Info | `config/poshqc-coverage.json` | `roots` | Bundle copies of the hooks under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` are not coverage roots. Pre-existing configuration, unchanged by this branch; the copies are byte-identical to the measured canonical hooks. | None for this item. | Recorded for completeness against the Coverage Exclusion Policy. | `config/poshqc-coverage.json`; parity check |
| Info | `docs/features/active/2026-10-16-planning-process-churn-964/evidence/` | most command-step artifacts | Filename stamps record write time and the `Timestamp:` field records run start (for example `isolation-final.2026-10-17T02-04.md` carries `Timestamp: 2026-10-17T01-47`). No convention requires them to match; consumers select by filename. The self-review states 10 Python test files changed; the diff has 9. | None required; optionally state the field's meaning in the evidence convention. | Traceability note only. | Evidence scan by this review |

No Blockers or Major findings.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- `plan_gate_document.py` is pure, context-free, and reuses `split_plan_lines`, `PLAN_WHITESPACE_CLASS` and the G10 `FENCE_RE`, so line numbering and fence handling match G10 and the TypeScript twin.
- G12's adjacency and digit-and-letter conditions are checked in code rather than lookbehind, which keeps the Python and JavaScript regex dialects identical; the bounded `{7,40}` run excludes SHA-256 digests by construction.
- Message builders render values between backticks without `repr`, and a parity test pins the exact strings in both runtimes.
- The generator fix routes manifest writes through `_write_text_preserving_newlines`, and the new write-mode test records writes in memory.

#### Typing and API notes

- All functions are annotated; `PlanGateReport` is imported under `TYPE_CHECKING` only, keeping the runtime import graph acyclic. Public surface: `evaluate_document_gates` plus the constants and helpers re-used by tests.

#### Error handling and logging

- The module raises nothing and has no side effects, as its docstring states.

### TypeScript implementation audit

#### What changed well

- `plan-gate-document.ts` mirrors the Python module function for function; the patterns are exported as `String.raw` constants with the same text.
- The Jest order dependence was fixed on both sides: the POSIX-path tests run inside `jest.isolateModulesAsync` with `jest.dontMock("node:path")` in `finally`, and the harness keeps one primary extension module so a registry reset cannot rebind mocks.

#### Type safety and maintainability

- No `any`, no suppression; severity constants are typed `string` and asserted equal to `"blocking"` by the parity suite. `jest.config.cjs` adds a per-file threshold for the new module and no exclusion.

#### Error handling and logging

- Pure functions; no I/O.

### PowerShell implementation audit

#### What changed well

- `Test-PreMortemSection` is a pure function with no script-scope state, dot-sourced by two hooks through the guarded `Add-HookDependencyFailure` pattern; it reaches 100% line coverage.
- Transcript reading sits behind an injectable `ReadTranscriptHead` scriptblock, and fix-record existence behind `Test-PreflightFixRecord`, so the Pester suites use in-memory content only.
- `Test-HasCanonicalBlockedText` now strips the canonical phrase before looking for a plan delta; previously the `[P0-T1]` inside the canonical phrase satisfied the task-identifier alternative, so the plan-delta check could not fail.

#### API and safety notes

- Approved verbs only; `[CmdletBinding()]` on all new functions; analyzer clean. See CR-5 for line density, `[OutputType]`, and the case-sensitivity documentation gap.

#### Error handling and logging

- A throwing or empty transcript reader degrades to the documented fallback; a research-file read error blocks with a reason. The `preflight-fix-record` path must start with `docs/features/` and exist.

---

## Test Quality Audit

Automated evidence is complete for all three languages, with baselines captured before production edits, a single-pass final QA loop, coverage deltas, and seeded isolation runs. This review re-ran the Python and Jest suites that cover the new code and read the Pester results from the on-disk JUnit and coverage files.

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/test_plan_gate_document.py` (11) and `extensions/drm-copilot/test/lib/validate/plan-gate-document.test.ts` (11) — positive, negative and boundary cases for G11 to G13, including ordering after G10 and context-free execution; pass at head.
- `tests/scripts/dev_tools/test_plan_gate_document_parity.py` (4) and `plan-gate-document-parity.test.ts` (7) — verbatim message rows, apostrophe rendering, severity parity, no representation builtin; pass at head (CR-6 on structure).
- `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` (16), `test_single_pass_preflight_contracts.py` (10), `test_plan_gate_document_docs.py` (5) — byte identity, headings, wiring, required contexts, contract phrases across surfaces; pass at head.
- `tests/scripts/claude-hooks/validate-executor-output.Preflight.Tests.ps1` (29), `premortem-section.Tests.ps1` (17), `validate-planner-output.PreMortem.Tests.ps1` (12), `validate-task-researcher-output.PreMortem.Tests.ps1` (8) — 0 failures in `artifacts/pester/pester-junit.xml`.
- `evidence/regression-testing/isolation-final.2026-10-17T02-04.md` — three Jest seeds, reversed Python order, three Pester file-order seeds, fresh single-process Pester; all pass.
- `evidence/qa-gates/coverage-delta.2026-10-17T02-04.md` — matches this review's re-parse of the coverage artifacts.

### Quality assessment prompts

- **Determinism:** no clock, randomness or network; seams supply transcript and file content.
- **Isolation:** one behavior per test except the parity row loop.
- **Speed:** new Python modules and contract tests run in under 2 s; Jest suites under 1 s.
- **Diagnostics:** assertions print the observed findings or the missing tokens per path.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection; no tokens, keys or credentials added. |
| No unsafe subprocess or command construction | ✅ PASS | No new subprocess call; hooks read files only through `Get-Content -LiteralPath` and `Test-Path -LiteralPath`. |
| Input validation at boundaries | ✅ PASS | Envelope fields read through `Get-JsonPropertyValue` with type checks under StrictMode; transcript lines parsed with `ConvertFrom-Json -ErrorAction Stop` inside `try`. |
| Error handling remains explicit | ✅ PASS | Read failures degrade to documented fallbacks or block with a reason; no silent catch-all beyond the documented transcript fallback. |
| Configuration / path handling is safe | ✅ PASS | Fix-record path normalized and required under `docs/features/`; only an existence check follows, no read or write. Research path must already pass the tracked-root check. |
| Hooks do not invoke Python | ✅ PASS | `enforcement-hooks-no-python-invocation.Tests.ps1` 32 tests, 0 failures. |
| Mirror parity | ✅ PASS | 82 canonical-to-bundle pairs byte-identical; six brief copies share one hash; generator `--check` exit 0. |

---

## Research Log

No external research was required. Repository facts stated in the brief were checked against the tree: `ci.yml` triggers and job keys, `_poshqc.yml` job names, `_quality-checks.yml` steps, `_docs-validation.yml` checks, `.gitattributes`, `config/poshqc-coverage.json`, `run-jest.cjs`, the batch-budget and route hook files and function names, and the `validate-bash.ps1` function names. All matched.

---

## Verdict

The change is ready for normal PR flow. The validator modules, the Pre-Mortem helper and the executor-hook changes are correct against the spec, fully tested, and at or above every coverage threshold; mirrors are byte-identical and the generator is in sync. No Blocker or Major finding exists.

The seven findings are Minor, Nit or Info. CR-1 to CR-3 are consistency fixes in surfaces this item already edits and should be applied in the same pass with a mirror-copy and generator re-run; CR-4 is an evidence-traceability note; CR-5 and CR-6 are readability and documentation improvements. AC-33 (the #962 re-plan) and AC-34 (CI on the final PR head) remain orchestrator-owned.
