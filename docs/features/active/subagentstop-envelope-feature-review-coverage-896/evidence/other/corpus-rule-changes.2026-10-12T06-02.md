# Corpus Rule Changes (P4-T4, v1.8 restart)

Timestamp: 2026-10-12T06-02
CorpusSha: 2ef8d361e978ca8b7733a545d76a87e8418005ce
InitialArtifact: docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/other/corpus-run.initial.2026-10-12T00-11.md
RestartOf: docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/other/corpus-rule-changes.2026-10-12T00-18.md
FIX-CLASSES: 4
E4-CORPUS-ROWS: 8

Derivation of k (re-derived from P4-T2): the initial run prints 29 `CORPUS-FORM:` lines, of which four carry `classes=FALSE-POSITIVE`, in this order: `rule1|docs/features/active/<F>/audit/9999-99-99T99-99/<stem>.md` (folders=3, rejections=24), `rule3|PowerShell|NARROWING|sanctioned` (folders=15, rejections=17), `rule3|Python|NARROWING|sanctioned` (folders=2, rejections=2), `rule3|TypeScript|NARROWING|sanctioned` (folders=2, rejections=2). Their rejections total 45, which equals `CORPUS-FALSE-POSITIVE: 45`. The restart re-applies every fix from FIX-1, because the BLOCKED procedure restored `.claude/hooks`, `tests/scripts/claude-hooks`, and the Claude bundle hooks to HEAD.

Upstream merge note: merge commit `8258fd2f1` (origin/epic/subagentstop-envelope-integration at `486e8c06e`) entered the branch after P4-T3. `git diff --name-only b6e96cfc6 8258fd2f1` lists none of H1-H6, T1-T11, or their mirrors; the only file in this plan's scope it touched is P1 `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, which gained the unrelated entry `.claude/hooks/validate-orchestrator-output-routing.ps1`. The corpus inputs (CorpusSha, P4-T2 `CORPUS-LANG:` lines) are unaffected.

OutOfCorpusObservation: conflict. `.claude/skills/remediation-handoff-atomic-planner/SKILL.md:71` names the remediation inputs `docs/features/active/<slug>/remediation/<entry-ts>/remediation-inputs.md`: the file name carries no timestamp, the folder is `<slug>/remediation/<entry-ts>`, and `<entry-ts>` is the cycle-entry timestamp, which `SKILL.md:81-82` distinguishes from the audit `<exit-ts>`. The H1 comparison (base lines 417-429) requires `remediation-inputs-path` to match `docs/features/active/.../remediation-inputs.<timestamp>.md` and to share the policy audit's feature folder and timestamp. A path that follows the skill is therefore rejected as outside the required location, and a skill-conformant remediation folder would also fail the folder and timestamp comparison. Recorded for the orchestrator; no change is made (D8).

## FIX-1

FormKey: rule1|docs/features/active/<F>/audit/9999-99-99T99-99/<stem>.md
Rule: rule1
Basis: SANCTIONED-S3 (folders=3)
Governing: `.claude/skills/remediation-handoff-atomic-planner/SKILL.md:69-82` (D6 S3: review artifacts at `docs/features/active/<slug>/audit/<yyyy-MM-ddTHH-mm>/<stem>.md`)
Rejections: 24
Exemplar: docs/features/completed/2026-07-02-local-preflight-orchestrator-state-gate-272/audit/2026-07-02T20-15/code-review.md (first `CORPUS-REJECT:` line carrying this form key, initial artifact line 569)
TargetFile: .claude/hooks/validate-feature-review-coverage-rules.ps1
TargetFunction: Get-ReviewArtifactInfo
Change: When the existing `<folder>/<stem>.<timestamp>.md` pattern does not match, `Get-ReviewArtifactInfo` tries `^docs/features/active/(?<Folder>[^/]+)/audit/(?<Timestamp>\d{4}-\d{2}-\d{2}T\d{2}-\d{2})/<Stem>\.md$`, taking the folder from the slug segment and the timestamp from the audit folder segment.
Rationale: the remediation-handoff skill names review artifacts this way, so the location rule rejected artifacts that follow a governing skill. The second pattern still requires the `docs/features/active/` prefix, a single slug segment, and a `yyyy-MM-ddTHH-mm` audit folder, so an undated audit folder stays rejected.
PolicyEditRequired: no
NewFunctionRequired: no
CodexParity: no equivalent rule. H5 has no `Get-ReviewArtifactInfo`; it locates the latest audit with `Get-ChildItem -Filter 'policy-audit.*.md'` (line 58), which does not match a file named `policy-audit.md`. Informational only (C5).
Tests: E4-CORPUS-1
Rows: 2
Status: APPLIED

## FIX-2

FormKey: rule3|PowerShell|NARROWING|sanctioned
Rule: rule3
Basis: SANCTIONED-S1-S2
Governing: S1 `.claude/rules/general-unit-test.md:25`, `.claude/rules/quality-tiers.md:38`, `.claude/skills/feature-review-workflow/SKILL.md:111`; S2 `.claude/skills/feature-review-workflow/SKILL.md:180`
Rejections: 17
Exemplar: docs/features/completed/2026-06-16-propagate-claude-ecosystem-hardening-187/policy-audit.2026-06-16T16-45.md
ExemplarForm: FULL
ExemplarGuard: REPRODUCED | narrows scope
TargetFile: .claude/hooks/validate-feature-review-coverage-rules.ps1
TargetFunction: Test-LanguageCoverageRow
Change: The narrowing check skips every line inside a `## Rejected Scope Narrowing` section (S2, all languages) and, for PowerShell, every line that matches `(?i)\bbranch\b` and does not match `(?i)\bline\s+coverage\b` (S1, the two D6 S1 regexes and no other test).
Rationale: Pester measures no branch coverage, so a PowerShell row that marks branch coverage N/A is the governed form; and caller narrowing text must be recorded verbatim in the Rejected Scope Narrowing section, so text there is not a narrowing by the audit. The `narrows scope` failure return and its fragment are unchanged (C2).
PolicyEditRequired: no
NewFunctionRequired: no
CodexParity: yes. H5 `Test-LanguageCoverageRow` (lines 178-186) applies the same narrowing pattern with no S1 or S2 exclusion. Informational only (C5).
Tests: E4-CORPUS-2
Rows: 2
Status: APPLIED
ExemplarCommand: route=scratchpad; $CorpusSha = '2ef8d361e978ca8b7733a545d76a87e8418005ce'; $InitialArtifact = 'docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/other/corpus-run.initial.2026-10-12T00-11.md'; $FormKey = 'rule3|PowerShell|NARROWING|sanctioned'; process exit code 0

### CR-EXEMPLAR output

```
PURITY-PATTERNS: 17
EXEMPLAR-CANDIDATES: rule3|PowerShell|NARROWING|sanctioned | 17
EXEMPLAR-CANDIDATE: rule3|PowerShell|NARROWING|sanctioned | FULL | docs/features/archive/2026-03-11-expose-placeholder-commands-92/policy-audit.2026-03-14T21-22.md | lines=37 | non-ascii | guard=NOT-EVALUATED
EXEMPLAR-CANDIDATE: rule3|PowerShell|NARROWING|sanctioned | FULL | docs/features/completed/2026-06-16-bump-and-publish-task-191/policy-audit.2026-06-17T01-05.md | lines=42 | non-ascii,lines=42 | guard=NOT-EVALUATED
EXEMPLAR-CANDIDATE: rule3|PowerShell|NARROWING|sanctioned | FULL | docs/features/completed/2026-06-16-propagate-claude-ecosystem-hardening-187/policy-audit.2026-06-16T15-30.md | lines=59 | non-ascii,lines=59 | guard=NOT-EVALUATED
EXEMPLAR-CANDIDATE: rule3|PowerShell|NARROWING|sanctioned | FULL | docs/features/completed/2026-06-16-propagate-claude-ecosystem-hardening-187/policy-audit.2026-06-16T16-45.md | lines=37 | QUALIFIES | guard=REPRODUCED
EXEMPLAR-GUARD: rule3|PowerShell|NARROWING|sanctioned | FULL | docs/features/completed/2026-06-16-propagate-claude-ecosystem-hardening-187/policy-audit.2026-06-16T16-45.md | HEAD Test-LanguageCoverageRow | REPRODUCED | narrows scope | PowerShell has changed files on the branch but a coverage-scoped row narrows scope: '**Note:** No C# source files and no TypeScript source files were changed in the branch diff. C# and TypeScript coverage verdicts are N/A because those languages have zero changed files on the branch (acceptable per scope invariant). The repo-root `coverage.xml` is a Pester (PowerShell) JACOCO report, not a C# artifact.'. Scope narrowing is not permitted for languages with changed files.
EXEMPLAR: rule3|PowerShell|NARROWING|sanctioned | ExemplarForm=FULL | docs/features/completed/2026-06-16-propagate-claude-ecosystem-hardening-187/policy-audit.2026-06-16T16-45.md | lines=37
EXEMPLAR-LINE: - `coverage.xml` (regenerated Pester JACOCO artifact, repo root, pre-existing tracked file)
EXEMPLAR-LINE: | PowerShell | 4 files | 36 tests | PASS 36 pass, 0 fail | n/a (per-hook) | orch-output 89.0% line; task-researcher 88.1% line | covered by 36 new/updated tests |
EXEMPLAR-LINE: **Note:** No C# source files and no TypeScript source files were changed in the branch diff. C# and TypeScript coverage verdicts are N/A because those languages have zero changed files on the branch (acceptable per scope invariant). The repo-root `coverage.xml` is a Pester (PowerShell) JACOCO report, not a C# artifact.
EXEMPLAR-LINE: - PowerShell coverage artifact: `artifacts/pester/powershell-coverage.xml` (PRESENT, but scopes other hooks); changed-hook coverage is in repo-root `coverage.xml` (JACOCO): `validate-orchestrator-output` LINE 65/73 = 89.0%; `validate-task-researcher-output` LINE 52/59 = 88.1%.
EXEMPLAR-LINE: **Non-negotiable verdict rule:** This audit reports PASS only with numeric baseline and post-change coverage for every language in scope (Python, PowerShell), verified from coverage artifacts.
EXEMPLAR-LINE: ## Executive Summary
EXEMPLAR-LINE: All applicable toolchain stages pass: Black (clean), Ruff (clean), Pyright (clean), Pytest (25 pass), Pester (36 pass), bundle-sync contract tests (13 pass). Mirror parity is satisfied: all 8 changed canonical `.claude` files are byte-identical in both bundled mirrors. Coverage thresholds are met for all changed files in both languages.
EXEMPLAR-LINE: - PASS `powershell.md`
EXEMPLAR-LINE: - PASS PowerShell: `powershell-code-change` + `powershell-unit-test`
EXEMPLAR-LINE: ## Rejected Scope Narrowing
EXEMPLAR-LINE: ## 1. General Unit Test Policy Compliance
EXEMPLAR-LINE: | Independence | PASS | Python tests use isolated text fixtures; PowerShell tests dot-source the hook and pass per-test in-memory objects. 25 + 36 tests pass in any order. |
EXEMPLAR-LINE: | Fast execution | PASS | Python suite 0.05s; Pester suite 1.51s. |
EXEMPLAR-LINE: | Baseline Coverage Documented | PASS | `evidence/baseline/baseline-python.2026-06-16T11-00.md` (validator 85.21% line / 77.42% branch); `evidence/baseline/baseline-pester.2026-06-16T11-00.md`. |
EXEMPLAR-LINE: | Comprehensive Coverage | PASS | `_validate_human_interaction` branches: non-object block, non-list requirements, non-object requirement, response-outside-enum, exception-empty-runbook, exception-missing-runbook, well-formed scope_change + runbook-backed exception. PowerShell: six rejection branches plus absent-key and runbook-exists paths. |
EXEMPLAR-LINE: - PowerShell: Post-change `validate-orchestrator-output.ps1` 89.0% line (65/73), `validate-task-researcher-output.ps1` 88.1% line (52/59) from repo-root `coverage.xml` JACOCO. Pester reports line/command coverage; a separate branch counter is not emitted by the Pester JACOCO format for these files, so branch coverage is not separately measurable under this toolchain. Line thresholds met. Disposition: PASS. Evidence: `coverage.xml`, `evidence/qa-gates/p7-poshqc-final.2026-06-16T11-00.md`.
EXEMPLAR-LINE: ## 2. General Code Change Policy Compliance
EXEMPLAR-LINE: | Simplicity first | PASS | Validator follows the established helper-plus-error-list pattern; PowerShell hook uses a single linear rejection-order loop. |
EXEMPLAR-LINE: ## 3. Language-Specific Code Change Policy Compliance
EXEMPLAR-LINE: ### 3.2 PowerShell (`powershell.md`)
EXEMPLAR-LINE: ## 4. Language-Specific Unit Test Policy Compliance
EXEMPLAR-LINE: | PowerShell Pester 5, injectable seams | PASS | `$FileExistsCheck` and `$ReadFileContent` seams used; no temporary files. 36 tests pass. |
EXEMPLAR-LINE: ## 5. Test Coverage Detail
EXEMPLAR-LINE: - PowerShell `validate-orchestrator-output.ps1`: 65/73 lines (89.0%). PASS.
EXEMPLAR-LINE: - PowerShell `validate-task-researcher-output.ps1`: 52/59 lines (88.1%). PASS.
EXEMPLAR-LINE: ## 6. Test Execution Metrics
EXEMPLAR-LINE: | Pester (two changed hooks) | `Invoke-Pester` on the two hook test files | 36 passed, 0 failed | 1.51s |
EXEMPLAR-LINE: ## 7. Code Quality Checks
EXEMPLAR-LINE: ## Evidence Location Compliance
EXEMPLAR-LINE: ## 8. Gaps and Exceptions
EXEMPLAR-LINE: - PowerShell branch coverage is not separately measurable: the Pester JACOCO export emits a LINE counter (line/command coverage) but no distinct BRANCH counter for these hook files. Line coverage (89.0% / 88.1%) exceeds the >= 85% threshold; branch coverage cannot be independently asserted under the current PowerShell toolchain. This is a tooling limitation documented in `evidence/qa-gates/p7-coverage-delta.2026-06-16T11-00.md`, not a coverage shortfall. Verdict for PowerShell coverage is PASS on the available metric.
EXEMPLAR-LINE: ## 9. Summary of Changes
EXEMPLAR-LINE: ## 10. Compliance Verdict
EXEMPLAR-LINE: **PASS.** Both prior remediation findings (F1 file-size, F2 schema reference) are resolved. All applicable toolchain stages pass for every language with changed files. Coverage thresholds are met for all new and modified files in Python and PowerShell. Mirror parity is satisfied. No scope narrowing was attempted. No blocking findings remain.
EXEMPLAR-LINE: ## Appendix A: Test Inventory
EXEMPLAR-LINE: ## Appendix B: Toolchain Commands Reference
EXEMPLAR-LINE: Invoke-Pester (tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1, validate-task-researcher-output.Tests.ps1)
EXIT_CODE_COMPUTED: 0
```

## FIX-3

FormKey: rule3|Python|NARROWING|sanctioned
Rule: rule3
Basis: SANCTIONED-S1-S2 (S2 applies; S1 is PowerShell-only)
Governing: S2 `.claude/skills/feature-review-workflow/SKILL.md:180`
Rejections: 2
Exemplar: docs/features/completed/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/2026-08-22T02-58-audit/policy-audit.2026-08-22T02-58.md
ExemplarForm: REDUCED
ExemplarGuard: REPRODUCED | narrows scope
TargetFile: .claude/hooks/validate-feature-review-coverage-rules.ps1
TargetFunction: Test-LanguageCoverageRow
Change: No further edit; the S2 exclusion added under FIX-2 applies to every language and accepts this form key.
Rationale: caller narrowing text recorded verbatim inside `## Rejected Scope Narrowing` is required by the governing skill and is not a scope narrowing by the audit.
PolicyEditRequired: no
NewFunctionRequired: no
CodexParity: yes (same narrowing rule in H5 lines 178-186, no S2 exclusion). Informational only (C5).
Tests: E4-CORPUS-3
Rows: 2
Status: APPLIED
ExemplarCommand: route=scratchpad; $CorpusSha = '2ef8d361e978ca8b7733a545d76a87e8418005ce'; $InitialArtifact = 'docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/other/corpus-run.initial.2026-10-12T00-11.md'; $FormKey = 'rule3|Python|NARROWING|sanctioned'; process exit code 0

### CR-EXEMPLAR output

```
PURITY-PATTERNS: 17
EXEMPLAR-CANDIDATES: rule3|Python|NARROWING|sanctioned | 2
EXEMPLAR-CANDIDATE: rule3|Python|NARROWING|sanctioned | FULL | docs/features/completed/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/2026-08-22T02-58-audit/policy-audit.2026-08-22T02-58.md | lines=77 | non-ascii,lines=77 | guard=NOT-EVALUATED
EXEMPLAR-CANDIDATE: rule3|Python|NARROWING|sanctioned | FULL | docs/features/completed/2026-08-31-portable-prepared-orchestration-handoff-614/policy-audit.2026-09-07T08-00.md | lines=80 | lines=80 | guard=NOT-EVALUATED
EXEMPLAR-CANDIDATE: rule3|Python|NARROWING|sanctioned | REDUCED | docs/features/completed/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/2026-08-22T02-58-audit/policy-audit.2026-08-22T02-58.md | lines=32 | QUALIFIES | guard=REPRODUCED
EXEMPLAR-GUARD: rule3|Python|NARROWING|sanctioned | REDUCED | docs/features/completed/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/2026-08-22T02-58-audit/policy-audit.2026-08-22T02-58.md | HEAD Test-LanguageCoverageRow | REPRODUCED | narrows scope | Python has changed files on the branch but a coverage-scoped row narrows scope: 'The delegating prompt supplied five orientation questions but stated verbatim that they are "Offered as orientation, not as scope limits or conclusions to ratify." It separately directed that "Every language with changed files in the branch diff is in scope for its full toolchain and coverage check. The diff touches Python, TypeScript, PowerShell, JSON, and Markdown," and that the audit must cover "the full branch diff against the merge base, not only the remediation delta." No instruction attempted to narrow the audit to a plan, task, phase, or file subset, and no instruction marked any language's coverage as out of scope, informational only, or not applicable.'. Scope narrowing is not permitted for languages with changed files.
EXEMPLAR: rule3|Python|NARROWING|sanctioned | ExemplarForm=REDUCED | docs/features/completed/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/2026-08-22T02-58-audit/policy-audit.2026-08-22T02-58.md | lines=32
EXEMPLAR-LINE: ## Rejected Scope Narrowing
EXEMPLAR-LINE: The delegating prompt supplied five orientation questions but stated verbatim that they are "Offered as orientation, not as scope limits or conclusions to ratify." It separately directed that "Every language with changed files in the branch diff is in scope for its full toolchain and coverage check. The diff touches Python, TypeScript, PowerShell, JSON, and Markdown," and that the audit must cover "the full branch diff against the merge base, not only the remediation delta." No instruction attempted to narrow the audit to a plan, task, phase, or file subset, and no instruction marked any language's coverage as out of scope, informational only, or not applicable.
EXEMPLAR-LINE: ## Executive Summary
EXEMPLAR-LINE: This is the re-audit of remediation cycle 1. The branch corrects the blast-radius truth table that the Claude push-down publishes into a destination workspace, corrects the exported constant that supplies a destination's payload modules, adds four read-by-mandate exclusions to both committed copies, amends the governing rule with its byte-identical bundled mirror, and adds a three-class key-partition drift gate in Python mirrored in PowerShell and complemented by two TypeScript assertions. The remediation commit `a95ae362` additionally added a directional separator-free invariant in both language mirrors, corrected the Pester byte-equality comparison form, corrected two acceptance-criterion texts, corrected a risk-mitigation sentence, and corrected an evidence artifact's recorded command.
EXEMPLAR-LINE: - **R4 is delivered and closes the gap generally for its stated scope, not only for one witness.** Injecting `Directory.Build.props` into the self-hosted `shared_surfaces` now fails the Python case with `assert not ['Directory.Build.props']` and fails the Pester case with `Expected $null or empty, but got 'Directory.Build.props'`. The two assert the same relation, computed the same way, and both were observed failing on the same injected witness in this review.
EXEMPLAR-LINE: ## 1. General Unit Test Policy Compliance
EXEMPLAR-LINE: | **Independence** | PASS | The new Python cases read two committed files at module import and assert over frozensets. No case mutates shared state or depends on another's ordering. The new Pester case reads `$script:CommittedConfig` and `$script:BundledConfig` from the Describe-level `BeforeAll` and accumulates into a locally constructed list. |
EXEMPLAR-LINE: | **Baseline Coverage Documented** | PASS | Python baseline 92.60% statements and 85.19% branches in `evidence/baseline/python-pytest-coverage.2026-08-21T22-51.md`. TypeScript baseline 96.66% lines and 90.04% branches in `evidence/baseline/typescript-jest-coverage.2026-08-21T22-52.md`. PowerShell baseline 96.21% lines in `evidence/baseline/powershell-poshqc-test.2026-08-21T23-03.md`. All three were captured in Phase 0 before any edit. |
EXEMPLAR-LINE: | **No Coverage Regression** | PASS | The reviewer reran all three coverage commands at branch head `a95ae362`. Python post-change 92.60% statements and 85.19% branches, delta 0.00 and 0.00. TypeScript post-change 96.66% lines and 90.04% branches, delta 0.00 and 0.00. PowerShell post-change 96.21% lines with LINE covered 5792 and missed 228, delta 0.00. |
EXEMPLAR-LINE: | **New Code Coverage** | PASS | The only changed production file is `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts`, whose lcov record at head reads `LF:468 LH:468`, that is 100.00% lines, and `BRF:48 BRH:46`, that is 95.83% branches. The two new Python modules and the changed PowerShell file are test code and sit outside the coverage denominator by construction. |
EXEMPLAR-LINE: - Python: Baseline: 92.60% statements -> Post-change: 92.60% statements. Change: 0.00 points on statements and 0.00 points on branches, branches holding at 85.19%. New/changed-code coverage: 100.00% of changed production lines, of which there are zero. Disposition: PASS. Evidence: `evidence/qa-gates/reviewer-toolchain-rerun.2026-08-22T02-58.md` and `artifacts/python/coverage.json` regenerated at head.
EXEMPLAR-LINE: | **Actionable failure messages** | PASS | The Python directional case names the missing entries, the self-hosted label, and the bundled label. The reviewer observed the rendered message: `config/blast-radius.json separator-free shared_surfaces entries ['Directory.Build.props'] are missing from extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json separator-free shared_surfaces`. The Pester case accumulates into a list so its message names all missing entries rather than the first. |
EXEMPLAR-LINE: | **Uniform tier thresholds applied** | PASS | Line coverage >= 85% and branch coverage >= 75% were applied uniformly to Python and TypeScript. PowerShell was held to the line threshold only, per the Pester exemption recorded in `.claude/rules/quality-tiers.md` and `.claude/rules/powershell.md`. No tier-specific lower threshold was used. |
EXEMPLAR-LINE: ## 2. General Code Change Policy Compliance
EXEMPLAR-LINE: | **Naming conventions** | PASS | `snake_case` Python functions, `SCREAMING_SNAKE_CASE` module constants, `PascalCase` PowerShell variables in the Pester file matching the file's existing style, `camelCase` TypeScript locals. |
EXEMPLAR-LINE: | **Docstring coverage** | PASS | Both new Python modules carry module docstrings with Purpose, Responsibilities, Side effects, and Naming sections. Every public function carries an Args, Returns, and where applicable Raises block. |
EXEMPLAR-LINE: ## 5. Test Coverage Detail
EXEMPLAR-LINE: ### Directional separator-free invariant (1 pytest case, 1 Pester case, added by the remediation)
EXEMPLAR-LINE: Python `test_every_separator_free_self_hosted_shared_surface_reaches_the_bundle` computes the separator-free subset of each copy's `shared_surfaces` and asserts `self_hosted - bundled` is empty. The Pester case `requires every separator-free self-hosted shared surface to reach the bundled copy` computes the same two subsets and accumulates every self-hosted entry not in the bundled subset with `-cnotcontains`. The two compute the same relation.
EXEMPLAR-LINE: | Perturbation | Python | Pester |
EXEMPLAR-LINE: ### Three-class key partition (15 pytest cases, 5 Pester cases)
EXEMPLAR-LINE: ## 6. Test Execution Metrics
EXEMPLAR-LINE: | Python full | `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term --cov-report=json:artifacts/python/coverage.json --cov-report=lcov:artifacts/python/lcov.info` | 4077 passed, 5 skipped | 20.60s | 0 |
EXEMPLAR-LINE: Test-count deltas against the pre-remediation head: Python 4076 to 4077 and Pester 3110 to 3111, each accounted for by exactly one added case. Skipped-test accounting: the five Python skips are pre-existing `test_parallel_manifest_bash_parity.py` cases that declare no accessor expectation; the nine Pester skips are likewise pre-existing. None is in the changed area.
EXEMPLAR-LINE: ## 8. Gaps and Exceptions
EXEMPLAR-LINE: **G8 - Informational. The two directional mirrors differ in their malformed-key behaviour.** The Python case reads through the `shared_surfaces` accessor, which returns an empty tuple for an absent or non-list key, so a renamed key would make it pass vacuously; the separate non-vacuity floor case is what catches that. The Pester case indexes the hashtable directly, so a renamed key raises rather than passing. Both fail loudly overall, but not in the same way and not through the same case. The Pester file carries no non-vacuity floor of its own.
EXEMPLAR-LINE: ## 10. Compliance Verdict
EXEMPLAR-LINE: | Python line coverage | 92.60% | >= 85% | PASS |
EXEMPLAR-LINE: | Python branch coverage | 85.19% | >= 75% | PASS |
EXEMPLAR-LINE: ## Appendix B: Toolchain Commands Reference
EXEMPLAR-LINE:   --cov-report=json:artifacts/python/coverage.json \
EXEMPLAR-LINE:   --cov-report=lcov:artifacts/python/lcov.info
EXIT_CODE_COMPUTED: 0
```

## FIX-4

FormKey: rule3|TypeScript|NARROWING|sanctioned
Rule: rule3
Basis: SANCTIONED-S1-S2 (S2 applies; S1 is PowerShell-only)
Governing: S2 `.claude/skills/feature-review-workflow/SKILL.md:180`
Rejections: 2
Exemplar: docs/features/completed/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/2026-08-22T02-58-audit/policy-audit.2026-08-22T02-58.md
ExemplarForm: REDUCED
ExemplarGuard: REPRODUCED | narrows scope
TargetFile: .claude/hooks/validate-feature-review-coverage-rules.ps1
TargetFunction: Test-LanguageCoverageRow
Change: No further edit; the S2 exclusion added under FIX-2 applies to every language and accepts this form key.
Rationale: as FIX-3.
PolicyEditRequired: no
NewFunctionRequired: no
CodexParity: yes (same narrowing rule in H5 lines 178-186, no S2 exclusion). Informational only (C5).
Tests: E4-CORPUS-4
Rows: 2
Status: APPLIED
ExemplarCommand: route=scratchpad; $CorpusSha = '2ef8d361e978ca8b7733a545d76a87e8418005ce'; $InitialArtifact = 'docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/other/corpus-run.initial.2026-10-12T00-11.md'; $FormKey = 'rule3|TypeScript|NARROWING|sanctioned'; process exit code 0

### CR-EXEMPLAR output

```
PURITY-PATTERNS: 17
EXEMPLAR-CANDIDATES: rule3|TypeScript|NARROWING|sanctioned | 2
EXEMPLAR-CANDIDATE: rule3|TypeScript|NARROWING|sanctioned | FULL | docs/features/completed/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/2026-08-22T02-58-audit/policy-audit.2026-08-22T02-58.md | lines=40 | non-ascii | guard=NOT-EVALUATED
EXEMPLAR-CANDIDATE: rule3|TypeScript|NARROWING|sanctioned | FULL | docs/features/completed/2026-08-31-portable-prepared-orchestration-handoff-614/policy-audit.2026-09-07T08-00.md | lines=57 | lines=57 | guard=NOT-EVALUATED
EXEMPLAR-CANDIDATE: rule3|TypeScript|NARROWING|sanctioned | REDUCED | docs/features/completed/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/2026-08-22T02-58-audit/policy-audit.2026-08-22T02-58.md | lines=18 | QUALIFIES | guard=REPRODUCED
EXEMPLAR-GUARD: rule3|TypeScript|NARROWING|sanctioned | REDUCED | docs/features/completed/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/2026-08-22T02-58-audit/policy-audit.2026-08-22T02-58.md | HEAD Test-LanguageCoverageRow | REPRODUCED | narrows scope | TypeScript has changed files on the branch but a coverage-scoped row narrows scope: 'The delegating prompt supplied five orientation questions but stated verbatim that they are "Offered as orientation, not as scope limits or conclusions to ratify." It separately directed that "Every language with changed files in the branch diff is in scope for its full toolchain and coverage check. The diff touches Python, TypeScript, PowerShell, JSON, and Markdown," and that the audit must cover "the full branch diff against the merge base, not only the remediation delta." No instruction attempted to narrow the audit to a plan, task, phase, or file subset, and no instruction marked any language's coverage as out of scope, informational only, or not applicable.'. Scope narrowing is not permitted for languages with changed files.
EXEMPLAR: rule3|TypeScript|NARROWING|sanctioned | ExemplarForm=REDUCED | docs/features/completed/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/2026-08-22T02-58-audit/policy-audit.2026-08-22T02-58.md | lines=18
EXEMPLAR-LINE: - TypeScript baseline coverage artifact: `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/evidence/baseline/typescript-jest-coverage.2026-08-21T22-52.md`
EXEMPLAR-LINE: - TypeScript post-change coverage artifact: `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/evidence/qa-gates/reviewer-toolchain-rerun.2026-08-22T02-58.md`, which regenerated `extensions/drm-copilot/coverage/lcov.info` at branch head `a95ae362`
EXEMPLAR-LINE: ## Rejected Scope Narrowing
EXEMPLAR-LINE: The delegating prompt supplied five orientation questions but stated verbatim that they are "Offered as orientation, not as scope limits or conclusions to ratify." It separately directed that "Every language with changed files in the branch diff is in scope for its full toolchain and coverage check. The diff touches Python, TypeScript, PowerShell, JSON, and Markdown," and that the audit must cover "the full branch diff against the merge base, not only the remediation delta." No instruction attempted to narrow the audit to a plan, task, phase, or file subset, and no instruction marked any language's coverage as out of scope, informational only, or not applicable.
EXEMPLAR-LINE: That artifact is an executor-side scoping record for the remediation cycle, not an instruction to this agent, but the audit treats it as non-binding regardless. TypeScript has five changed files in the branch diff against the merge base, so its full toolchain and its coverage figures were rerun by the reviewer at branch head and carry an explicit PASS verdict in section 1.2.1. The audit was performed as a full feature-versus-base review of `fb30a9a5..a95ae362`.
EXEMPLAR-LINE: ## Executive Summary
EXEMPLAR-LINE: This is the re-audit of remediation cycle 1. The branch corrects the blast-radius truth table that the Claude push-down publishes into a destination workspace, corrects the exported constant that supplies a destination's payload modules, adds four read-by-mandate exclusions to both committed copies, amends the governing rule with its byte-identical bundled mirror, and adds a three-class key-partition drift gate in Python mirrored in PowerShell and complemented by two TypeScript assertions. The remediation commit `a95ae362` additionally added a directional separator-free invariant in both language mirrors, corrected the Pester byte-equality comparison form, corrected two acceptance-criterion texts, corrected a risk-mitigation sentence, and corrected an evidence artifact's recorded command.
EXEMPLAR-LINE: ## 1. General Unit Test Policy Compliance
EXEMPLAR-LINE: | **Baseline Coverage Documented** | PASS | Python baseline 92.60% statements and 85.19% branches in `evidence/baseline/python-pytest-coverage.2026-08-21T22-51.md`. TypeScript baseline 96.66% lines and 90.04% branches in `evidence/baseline/typescript-jest-coverage.2026-08-21T22-52.md`. PowerShell baseline 96.21% lines in `evidence/baseline/powershell-poshqc-test.2026-08-21T23-03.md`. All three were captured in Phase 0 before any edit. |
EXEMPLAR-LINE: | **No Coverage Regression** | PASS | The reviewer reran all three coverage commands at branch head `a95ae362`. Python post-change 92.60% statements and 85.19% branches, delta 0.00 and 0.00. TypeScript post-change 96.66% lines and 90.04% branches, delta 0.00 and 0.00. PowerShell post-change 96.21% lines with LINE covered 5792 and missed 228, delta 0.00. |
EXEMPLAR-LINE: - TypeScript: Baseline: 96.66% lines -> Post-change: 96.66% lines. Change: 0.00 points on lines and 0.00 points on branches, branches holding at 90.04%. New/changed-code coverage: 100.00% lines and 95.83% branches on `claude-blast-radius-derive-core.ts`. Disposition: PASS. Evidence: `extensions/drm-copilot/coverage/lcov.info`, record `SF:src\lib\push-down\claude-blast-radius-derive-core.ts` reading `LF:468 LH:468 BRF:48 BRH:46`.
EXEMPLAR-LINE: | **Uniform tier thresholds applied** | PASS | Line coverage >= 85% and branch coverage >= 75% were applied uniformly to Python and TypeScript. PowerShell was held to the line threshold only, per the Pester exemption recorded in `.claude/rules/quality-tiers.md` and `.claude/rules/powershell.md`. No tier-specific lower threshold was used. |
EXEMPLAR-LINE: ## 2. General Code Change Policy Compliance
EXEMPLAR-LINE: | **Naming conventions** | PASS | `snake_case` Python functions, `SCREAMING_SNAKE_CASE` module constants, `PascalCase` PowerShell variables in the Pester file matching the file's existing style, `camelCase` TypeScript locals. |
EXEMPLAR-LINE: | 8 Unit tests, TypeScript | `npm run test:coverage` | 195 suites, 2656 tests passed | 0 |
EXEMPLAR-LINE: ## 10. Compliance Verdict
EXEMPLAR-LINE: | TypeScript line coverage | 96.66% | >= 85% | PASS |
EXEMPLAR-LINE: | TypeScript branch coverage | 90.04% | >= 75% | PASS |
EXIT_CODE_COMPUTED: 0
```

## T1 test text

`E4-CORPUS-1` through `E4-CORPUS-4` sit in `Context 'E4-CORPUS (issue #896 corpus gate)'`, the last Context of the T1 `Describe`. Each rule3 `It` assigns its here-string once as `$auditText` (built from the `EXEMPLAR-LINE:` values in output order, prefix removed); the rows are `@{ Rule = 'rule3'; Kind = 'Accept' }` and `@{ Rule = 'rule3'; Kind = 'Reject' }`, and the body applies the S1-and-S2 Reject transformation when `$Kind -eq 'Reject'`. The FIX-1 `It` derives the Reject path from the Accept path by replacing the timestamp with `undated`. The new T1 content was checked against the 17 `$forbiddenPatterns` of `.claude/hooks/check-powershell-test-purity.ps1` (read by AST): `PURITY-HITS: 0`. A T1-only micro-run printed `NAMED: E4-CORPUS-* | Passed=8 | Failed=0 | NotRun=0 | Total=8`.

## P4-T4 acceptance

Command: scratchpad route; CR-PARSE with `<LIST>` = H1, H3, T1 and `<IT-PATTERNS>` = `E4-CORPUS-*`; then CR-TEXT with the two P4-T4 checks.
EXIT_CODE: 0

```
PARSE: .claude/hooks/validate-feature-review-coverage.ps1 | errors=0 | functions=Invoke-FeatureReviewCoverageValidation
IT-COUNT: .claude/hooks/validate-feature-review-coverage.ps1 | E4-CORPUS-* | 0
PARSE: .claude/hooks/validate-feature-review-coverage-rules.ps1 | errors=0 | functions=Get-ChangedLanguageSet,Get-ReviewArtifactInfo,Get-ReviewArtifactPathFromOutput,Test-LanguageCoverageRow
IT-COUNT: .claude/hooks/validate-feature-review-coverage-rules.ps1 | E4-CORPUS-* | 0
PARSE: tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 | errors=0 | functions=
IT-COUNT: tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 | E4-CORPUS-* | 4
PARSE-ERROR-COUNT: 0
EXIT_CODE_COMPUTED: 0
TEXT-FILE: .claude/hooks/validate-feature-review-coverage-rules.ps1 | exists=True
TEXT-PRESENT: .claude/hooks/validate-feature-review-coverage-rules.ps1 | does not mention | True
TEXT-PRESENT: .claude/hooks/validate-feature-review-coverage-rules.ps1 | no coverage-scoped row | True
TEXT-PRESENT: .claude/hooks/validate-feature-review-coverage-rules.ps1 | narrows scope | True
TEXT-PRESENT: .claude/hooks/validate-feature-review-coverage-rules.ps1 | neither a PASS nor a FAIL | True
TEXT-PRESENT: .claude/hooks/validate-feature-review-coverage-rules.ps1 | line coverage floor | True
TEXT-PRESENT: .claude/hooks/validate-feature-review-coverage-rules.ps1 | branch coverage floor | True
TEXT-FILE: .claude/hooks/validate-feature-review-coverage.ps1 | exists=True
TEXT-PRESENT: .claude/hooks/validate-feature-review-coverage.ps1 | must share the same feature folder and timestamp | True
TEXT-CHECK-FAILURES: 0
EXIT_CODE_COMPUTED: 0
```

Output Summary: CR-PARSE `PARSE-ERROR-COUNT: 0`, H1 and H3 function lists unchanged, T1 `IT-COUNT ... E4-CORPUS-* | 4` equals `FIX-CLASSES: 4`; CR-TEXT `TEXT-CHECK-FAILURES: 0`. Every `## FIX-` section reads `Status: APPLIED`.

## Newly visible true positives

None. The P4-T7 final run (`docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/qa-gates/corpus-run.final.2026-10-12T06-14.md`) printed `CORPUS-TP-ADDED: 0` and no `CORPUS-TP-ADDED-ITEM:` line. The first P4-T7 run met its acceptance, so no re-entry was used.

## Gate verdict (P4-T9)

InitialFalsePositives: 45
FinalFalsePositives: 0
FinalArtifact: docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/qa-gates/corpus-run.final.2026-10-12T06-14.md
SuitesGateArtifact: docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/qa-gates/phase4-corpus-pester.2026-10-12T06-16.md
CorpusGate: PASS

Basis: P4-T5 (`docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/other/phase4-mirror.2026-10-12T06-10.md`, COPY-DIFFER-COUNT 0, SHA-DIFFER-COUNT 0), P4-T6 (`docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/qa-gates/phase4-file-size.2026-10-12T06-11.md`, T1 count=347 at most 400, LINES-OVER-CAP 0), P4-T7, and P4-T8 each met their acceptance.
