# Code Review: Codex-Native Parallel Orchestration (#467)

**Review Date:** 2026-08-12
**Reviewer:** generated `feature-reviewer-c4`
**Feature Folder:** `docs/features/active/2026-08-10-codex-native-parallel-orchestration-467`
**Feature Folder Selection Rule:** The fresh PR-context bundle and explicit full-feature scope identify this active issue-467 folder.
**Base Branch:** `main`
**Head Branch:** `feature/codex-native-parallel-orchestration-467` at `35323f412f752467f3d787326399218d9564c8b2`
**Review Type:** Initial full-feature review

---

## Executive Summary

The full `main...HEAD` diff was reviewed without scope narrowing. It adds Codex-native parallel planning and execution personas, deterministic readiness/cohort/mutation/drift validation, isolated worktree launch and resume enforcement, completion receipts, portable publishing assets, root/bundle parity controls, and broad cross-runtime tests. Current reviewer checks pass for TypeScript formatting/lint/type checking, Python formatting/lint/type checking, generator consistency, root/bundle parity, file-size limits, suppressions, and diff hygiene. Retained exact-code evidence reports green TypeScript, Python, PowerShell, and Bash tests.

Five material findings prevent PR readiness. Three concern mandatory coverage rules, one is a contradictory permission authority in both forced parallel persona prompts, and one is broad Python documentation/comment non-compliance. These findings require planned remediation and a complete post-remediation re-review.

**What changed:** 1,038 paths across Python, TypeScript, PowerShell, Bash, workflow/configuration, tests, Codex customization roots/bundles, feature documentation, and retained evidence. The comparison contains 694,210 insertions and 1,069 deletions, much of it generated coverage evidence. The `.claude/` tree has no feature diff, and 40/40 changed root/bundle customization pairs are byte-identical.

**Top 3 risks:**

1. Changed PowerShell runtime behavior is not present in the source coverage denominator for 24 of 25 files.
2. Forced planner/orchestrator prompts identify the wrong sandbox authority despite correct dedicated profile defaults.
3. Python and TypeScript per-file coverage contracts are not satisfied, and added Python source does not meet mandatory documentation/comment requirements.

**PR readiness recommendation:** **Needs Revision** — complete the canonical remediation plan and repeat the full review before PR readiness is asserted.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | Added and modified Python production modules | Coverage artifact | Five of seven added modules are below 90%, including `push_down_codex_routing_merge.py` at 79.43%; three modified modules regress from baseline. | Add deterministic tests for uncovered branches, regenerate coverage, and require every added file to reach 90% and every modified file to avoid regression. | The general unit-test and full-feature review contracts require per-file numeric compliance; aggregate 92.16% does not supersede it. | `evidence/qa-gates/commit-steward-python-coverage.2026-08-10T20-25.json`; baseline comparison. |
| Blocker | `.codex/hooks/*.ps1`, `.codex/scripts/*.ps1` and bundled mirrors | PowerShell coverage XML | Only 27 changed lines in `enforce-completion-consistency.ps1` are source-attributed. The other 24 changed runtime files are absent from source nodes. | Extend instrumentation or use an approved deterministic source-attribution mechanism for all changed runtime files; then enforce per-file thresholds. | External-process Pester contract tests prove behavior but do not supply required numeric source coverage. | `artifacts/pester/powershell-coverage.xml`; `evidence/qa-gates/powershell-pester-coverage.2026-08-10T20-25.md`. |
| Major | Five modified TypeScript production files | Coverage artifact | Line coverage regresses in `claude-routing-merge.ts`, `codex-topology-resolver.ts`, `orchestration-artifacts.ts`, `orchestrator-state-codex-model-routing.ts`, and `parallel-kickoff-artifact.ts`. | Add focused branch tests and regenerate LCOV until each modified file is non-regressing. | The feature review contract requires both the repository threshold and no modified-file regression. | `evidence/qa-gates/commit-steward-typescript-coverage.2026-08-10T20-25/lcov.info`; baseline LCOV evidence. |
| Major | `.codex/agents/parallel-planner.toml`; `.codex/agents/parallel-orchestrator.toml` and bundled copies | Developer instruction bodies | Both profiles set the correct dedicated `default_permissions`, but their developer prompts state the exact sandbox authority is `orchestrator-workspace`. Entry skills require `parallel-planner-workspace` and `parallel-orchestrator-workspace`. Existing tests assert only profile defaults. | Correct both prompt bodies and byte-identical bundles; add tests that compare the prompt authority to the dedicated profile and skill authority. | The forced persona can fail closed or persist a contradictory authority receipt even though the TOML default is correct. | Planner TOML line 30; orchestrator TOML line 33; `parallel-plan/SKILL.md` line 33; `parallel-run/SKILL.md` line 19; `parallel-orchestrate/SKILL.md` line 24. |
| Major | Seven added Python production modules | Docstrings and intent comments | Ten functions/methods lack docstrings; other new production callables lack the complete required contract; 67 loop/comprehension nodes lack immediate intent comments. | Apply the `self-explanatory-code-commenting` contract across all added Python production code and affected test helpers; audit non-trivial branching and multi-step blocks as part of remediation. | Repository policy mandates complete contract docstrings and immediate intent comments for loops/comprehensions. | AST review of the seven added production modules; representative locations include `_parallel_orchestrator_state_resume_truth.py:120`, `parallel_codex_readiness_filesystem.py:33`, and `validate_parallel_codex_readiness.py:91`. |
| Info | `.github/workflows/**` and AC sources | Hosted CI | No exact-current-head hosted CI result exists before the orchestrator-owned branch-push/PR boundary. | Keep the three hosted-current-head criteria unchecked and verify them after the reviewed remediation head is pushed. | The review mandate explicitly defers these three criteria until hosted CI exists. | `issue.md`, `spec.md:341`, `user-story.md:147`. |

---

## Implementation Audit

### Python implementation audit

#### What changed well

- Readiness filesystem access, receipt validation, cohort normalization, mutation/drift decisions, and publisher merge behavior are separated into focused modules with explicit protocols.
- Cross-runtime parity fixtures cover core decision behavior, and Pyright reports no typing errors or warnings.

#### Typing and API notes

- Public inputs and state records are strongly typed. No new Python typing or lint suppressions were added.
- Documentation is not policy-complete: missing docstrings include nested `ordering`, protocol methods, filesystem repository constructors/helpers, and merge adapter constructors. Existing docstrings also omit required contract sections.

#### Error handling and logging

- Validators fail explicitly on invalid state, missing repository objects, and receipt mismatches.
- No new broad silent exception handling was identified. Remediation should preserve deterministic error text while adding coverage for currently uncovered paths.

### TypeScript implementation audit

#### What changed well

- TypeScript mirrors Python state-validation boundaries and uses explicit interfaces and deterministic normalized outputs.
- All nine added production files meet the 90% line target; Prettier, ESLint, and `tsc` pass.

#### Type safety and maintainability

- No added TypeScript suppressions were found. Exported state and validation contracts remain explicit.
- Five modified files regress line coverage and require targeted tests; no production redesign is indicated by the reviewed evidence.

#### Error handling and logging

- Boundary validators reject inconsistent state rather than defaulting silently. Error messages are exercised by parity and validation suites.

### PowerShell implementation audit

#### What changed well

- Process-level tests exercise actual hook registrations, malformed/missing input, poisoned environment variables, exact streams, exit codes, launch binding, resume, and completion behavior.
- Changed scripts remain within the 500-line cap, and canonical analyzer evidence is clean.

#### API and safety notes

- Launch and lifecycle scripts enforce repository, branch, worktree, profile, model, authority, and hash bindings.
- The prompt-level authority mismatch weakens this contract for both forced root personas and is not covered by current provenance tests.

#### Error handling and logging

- Hooks use deterministic native allow/deny/error envelopes and fail closed for malformed state.
- Coverage instrumentation does not expose the executable source paths for 24 changed runtime files, so unexecuted error branches cannot be quantified.

### Bash and workflow audit

- Portable Bash validation and cohort behavior meet retained owner coverage thresholds and pass 255 tests.
- The workflow change reuses `_poshqc.yml`. Its hosted execution is correctly deferred until a PR exists; local configuration inspection does not substitute for hosted status.

---

## Test Quality Audit

The feature includes extensive automated contract tests and cross-runtime parity evidence. Retained exact-code receipts report TypeScript 193 suites/2,678 tests, Python 3,934 passed/5 skipped, PowerShell 2,285 passed/9 disabled, and Bash 255/255. These results support functional breadth, but coverage policy is a separate mandatory gate: Python new/modified files, TypeScript modified files, and PowerShell source attribution fail that gate.

### Reviewed test and QA artifacts

- `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` — primary complete-scope and diff/baseline evidence; hashes match the caller-provided fresh receipts.
- `evidence/qa-gates/full-regression.2026-08-10T20-25.md` — four-language regression summary.
- `evidence/qa-gates/commit-steward-python-coverage.2026-08-10T20-25.json` — authoritative current Python per-file coverage.
- `evidence/qa-gates/commit-steward-typescript-coverage.2026-08-10T20-25/lcov.info` — authoritative current TypeScript per-file coverage.
- `artifacts/pester/powershell-coverage.xml` — PowerShell aggregate and source-attribution evidence.
- `evidence/qa-gates/bash-bats-coverage.2026-08-10T20-25.md` — Bash test and coverage evidence.
- `evidence/issue-updates/issue-467.2026-08-10T20-25.md` — named E01-E19 acceptance evidence mapping.

### Quality assessment prompts

- **Determinism:** PASS. State, process, transport, and parity fixtures use explicit inputs and normalized outputs.
- **Isolation:** PASS. Unit and contract suites separate filesystem, Git, process, and runtime boundaries through adapters or subprocess harnesses.
- **Speed:** PASS based on retained QA completion receipts; no timeout qualification is recorded.
- **Diagnostics:** PASS for explicit validator and hook errors; PARTIAL for coverage diagnostics because 24 changed PowerShell source files are absent from the measurement report.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Full diff inspection and PR-context evidence identified no credential material. |
| No unsafe subprocess or command construction | PASS | Launch/process inputs are validated and exercised by security and transport suites; no unquoted string-built shell command finding was confirmed. |
| Input validation at boundaries | PASS | Manifest, state, receipt, hook transport, worktree, Git, and GitHub boundary validation is covered by named suites. |
| Error handling remains explicit | PASS | Invalid and inconsistent states produce deterministic rejections. |
| Configuration/path handling is safe | PARTIAL | Runtime path validation is extensive, but the forced persona prompt authority contradicts profile/skill configuration. |
| Source coverage supports critical path claims | FAIL | PowerShell changed-source attribution is missing for 24 runtime files. |

---

## Research Log

No external research was required. The repository policies, feature requirements, fresh PR-context bundle, retained exact-code QA evidence, machine-readable coverage artifacts, and full branch diff were sufficient.

---

## Verdict

**REMEDIATION REQUIRED.** The feature is not ready for normal PR flow. Correct the dedicated authority prompt contract, bring all changed-language coverage into policy compliance with source-attributable evidence, and remediate the Python documentation/comment violations. After the atomic remediation plan is executed, regenerate fresh PR context and complete a full post-remediation feature review. The three hosted-current-head CI criteria remain separately unchecked and deferred until a PR exists.
