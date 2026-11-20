# 2026-08-16-powershell-branch-coverage-gate-unsatisfiable (Spec)

- **Issue:** #476
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-16T17-50
- **Status:** Implemented — all 16 acceptance criteria verified; awaiting review
- **Version:** 1.0
- **Work Mode:** full-bug (this spec is the sole acceptance-criteria source; no user-story document exists)

## Context

Repository policy requires PowerShell branch coverage `>= 75%`, but Pester — the only PowerShell test and coverage runtime in this repository — cannot measure branch coverage at all. Pester 5.6.1's emitter produces `INSTRUCTION`, `LINE`, `METHOD`, and `CLASS` counters only, and never a `BRANCH` counter, in any output format. The genuine branch denominator is `0`, so the threshold is unevaluable rather than merely unmet. Any feature-review that audits changed PowerShell files therefore raises a permanent Blocking finding that no test authoring can clear. The affected policy files ship to consumer repositories through push-down, so the defect propagates downstream and has already stalled a remediation cycle in a Codex-native consumer repository.

The mechanical gate already agrees with the target policy: `.claude/hooks/validate-feature-review-coverage.ps1` returns `$null` when zero `BRANCH` counters are present and skips the 75% floor check on null values. This change closes a prose/mechanism gap; it does not weaken an operating gate.

Environment:
- OS/version: Windows 11 Pro 10.0.26200; also reproduces on `windows-latest` CI runners.
- Python version: not applicable; the defect is in PowerShell policy and Pester tooling.
- Command/flags used: `Invoke-PoshQCTest -Root <repo>` via `mcp__drm-copilot__run_poshqc_test`, then parse `artifacts/pester/powershell-coverage.xml`.
- Data source or fixture: `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`; Pester 5.6.1.

Impact / Severity:
- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

Any feature-review pass that audits changed PowerShell files is permanently blocked. A downstream consumer repository that inherited this policy through push-down has already stalled a remediation cycle on this finding, having correctly refused to manufacture a passing metric rather than relabel command hits, line hits, or AST positions as branch outcomes.

## Repro & Evidence

Steps to Reproduce:
1. Run the PowerShell toolchain so `artifacts/pester/powershell-coverage.xml` is produced.
2. Parse the report and enumerate `counter` node types and any `BRANCH` counter.
3. Inspect the Pester coverage configuration surface: `(New-PesterConfiguration).CodeCoverage.PSObject.Properties.Name`.
4. Search the installed Pester module source for the string `branch`.
5. Run a feature-review pass that audits PowerShell coverage against `.claude/rules/powershell.md`.

Expected:
Either the toolchain produces a genuine PowerShell branch-coverage number that the `>= 75%` threshold can be evaluated against, or repository policy states that branch coverage is not measurable for PowerShell and does not gate on it — matching how the repository already handles bash.

Actual:
No branch metric exists, and policy still demands one.

- `artifacts/pester/powershell-coverage.xml` contains counter types `CLASS`, `INSTRUCTION`, `LINE`, and `METHOD` only. There are zero `BRANCH` counter nodes, zero `branch="true"` line elements, zero line elements with a positive `mb`+`cb` denominator, and zero condition nodes.
- Pester's `CodeCoverage` configuration exposes `CoveragePercentTarget`, `Enabled`, `ExcludeTests`, `OutputEncoding`, `OutputFormat`, `OutputPath`, `Path`, `RecursePaths`, `SingleHitBreakpoints`, and `UseBreakpoints`. There is no branch property.
- The installed Pester 5.6.1 module source contains **zero** occurrences of the string `branch` across all `.ps1` and `.psm1` files. Pester has no branch-coverage capability in any output format, so changing `OutputFormat` to `JaCoCo` or `Cobertura` does not help.
- The genuine branch denominator is therefore `0`, and a percentage cannot be computed. The threshold is not merely unmet; it is unevaluable.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet:

```text
Pester 5.6.1 at C:\Users\DanMoisan\OneDrive\Documents\PowerShell\Modules\Pester\5.6.1
branch-mentions: 0

powershell-coverage.xml root counters:
  INSTRUCTION  covered=5489 missed=325
  LINE         covered=4040 missed=220
  METHOD       covered=336  missed=27
  CLASS        covered=50   missed=2
  BRANCH       (absent)
```

## Scope & Non-Goals

### Binding decisions (fixed by orchestrator; do not re-litigate)

1. **Resolution route:** align the policy prose with actual tooling capability, structurally paralleling the existing bash carve-out at `.claude/rules/shell.md:68-70`.
2. **Codex surface and README are in scope.** The `.agents/**` restatements and the `README.md:298` consistency edit are included in this change.
3. **The coverage hook is not modified.** `.claude/hooks/validate-feature-review-coverage.ps1` already implements the target policy mechanically (`$null` skip when zero `BRANCH` counters exist).

### In scope — confirmed edit surface (17 files)

Root Claude surface (6), each with a byte-identical mirror under `extensions/drm-copilot/resources/claude-customizations/<same .claude-relative path>` that must be edited in the same change:

| # | Root file | Edit | Pack |
| --- | --- | --- | --- |
| 1 | `.claude/rules/powershell.md:63-65` | Replace the branch line with the Pester carve-out | powershell |
| 2 | `.claude/rules/general-unit-test.md:24` | Qualify the branch threshold to branch-capable languages | core |
| 3 | `.claude/rules/quality-tiers.md:25,34,51` | Same qualification on the uniform statement, matrix row, and rationale | core |
| 4 | `.claude/skills/feature-review-workflow/SKILL.md:111-114` | Scope the branch clause to branch-capable languages | core |
| 5 | `.claude/agents/feature-review.md:112-114` | Same qualification | core |
| 6 | `.claude/skills/powershell-qa-gate/SKILL.md:45` | Remove or qualify the branch clause for PowerShell | powershell |

Codex surface (2), each with a byte-identical mirror under `extensions/drm-copilot/resources/codex-and-agents-customizations/`:

| # | Root file | Edit |
| --- | --- | --- |
| 7 | `.agents/skills/general-unit-test/SKILL.md:29` | Same qualification as file 2 |
| 8 | `.agents/skills/quality-tiers/SKILL.md:30,39,56` | Same qualification as file 3 |

Plus `README.md:298` (non-shipped consistency edit). Total: 8 root files + 8 bundle mirrors + `README.md` = 17 files.

### Out of scope / non-goals

- Building an AST-instrumentation branch collector for PowerShell (recorded as a follow-up in `issue.md`).
- Adopting Pester command coverage as a substitute gated metric (recorded as a follow-up in `issue.md`). The amended text may describe command coverage as what Pester measures, but must not establish a command-coverage gate.
- The opt-in allow-list under `CodeCoverage.Path` in `pester.runsettings.psd1`, which excludes every unlisted production PowerShell file from measurement and appears to conflict with the Coverage Exclusion Policy in `.claude/rules/general-unit-test.md` (separate follow-up per `issue.md`).
- `.claude/hooks/validate-feature-review-coverage.ps1` and its Pester suite `tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1` — unchanged.
- The `.github/**` Copilot surface — research confirmed it never carried a branch threshold; no edit.
- Branch-coverage thresholds for Python, TypeScript, and C# — unchanged at `>= 75%`.
- The bash carve-out at `.claude/rules/shell.md:68-70` — unchanged; it is the structural precedent, not an edit target.
- The dangling `docs/ci.research.md` reference at `.claude/rules/quality-tiers.md:4` — out of scope for #476.
- Historical audit/plan artifacts under `docs/features/**` and `docs/research/**` that record the old threshold — historical records, not edit targets.

### Explicitly excluded systems, integrations, or datasets

- No external system, credential, or network access is required; all verification is local test execution.
- Downstream publication (extension version bump, release, consumer re-push) rides the existing release flow and is post-merge process, outside this fix.

## Root Cause Analysis

The uniform coverage rule was written for languages whose tooling supports branch measurement (pytest `--cov-branch`, Jest, coverlet) and was applied to PowerShell without a capability check.

Conflicting policy sources:

- `.claude/rules/powershell.md:64` — "Branch coverage must remain >= 75% across all tiers (T1–T4)."
- `.claude/rules/general-unit-test.md:24` — "**Branch coverage must remain >= 75% across all tiers (T1–T4).**"
- `.claude/rules/quality-tiers.md:25,34,51` — uniform statement, gate-matrix row "Branch coverage: >= 75%.", and rationale restatement.
- `.claude/skills/feature-review-workflow/SKILL.md:112-114` and `.claude/agents/feature-review.md:112-114` — require branch `>= 75%` for new files, modified files, and repo-wide per language, with "Flag as FAIL otherwise" and no capability carve-out; PowerShell is explicitly enumerated as a coverage language in both files.
- `.claude/skills/powershell-qa-gate/SKILL.md:45` — "line coverage >= 85% and branch coverage >= 75%" for new modules/classes/methods.
- `.agents/skills/general-unit-test/SKILL.md:29` and `.agents/skills/quality-tiers/SKILL.md:30,39,56` — the same requirement restated on the Codex surface.

The repository already resolved this exact class of conflict for bash and never applied the resolution to PowerShell:

- `.claude/rules/shell.md:68-70` — "kcov reports **line coverage only**. The uniform line-coverage threshold (>= 85% per `.claude/rules/quality-tiers.md`) applies. Branch coverage is not measurable by kcov for bash; there is no bash branch-coverage gate."

The research's decisive structural finding (R3): a language-rule-file-only carve-out sufficed for bash only because bash is never enumerated in the review surface — the changed-language detector and both feature-review coverage-language lists omit it. PowerShell is on the wrong side of that asymmetry: it is explicitly enumerated in the hook's language detector, `feature-review-workflow/SKILL.md`, and `agents/feature-review.md`, each with its artifact path and "Flag as FAIL otherwise" thresholds. A carve-out in `.claude/rules/powershell.md` alone would leave the shared files still instructing a reviewer to demand branch `>= 75%` for an enumerated PowerShell audit. The fix therefore touches the shared files as well — a justified, documented deviation from the bash precedent, caused by the enumeration asymmetry, not a contradiction of it.

GitHub Actions is not the failing gate: `.github/workflows/_poshqc.yml` runs format, analyze, and test only, and `pester.runsettings.psd1` sets `CoveragePercentTarget = 0`. The mechanical local hook is also not the failing gate: `.claude/hooks/validate-feature-review-coverage.ps1` returns `$null` when zero `BRANCH` counters exist (line 195) and skips the 75% check on null (lines 323-329). The blocking gate is the prose policy applied by the feature-review agent.

Payload propagation — the affected files ship to consumer repositories:

- `.claude/rules/powershell.md` and `.claude/skills/powershell-qa-gate/SKILL.md` ship in the `powershell` pack.
- `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/skills/feature-review-workflow/SKILL.md`, and `.claude/agents/feature-review.md` ship in the `core` pack.
- Each has a mirrored copy under `extensions/drm-copilot/resources/claude-customizations/.claude/`; the `.agents/**` files have mirrors under `extensions/drm-copilot/resources/codex-and-agents-customizations/`. Root/bundle byte parity applies to every edit.

## Proposed Fix

### Design summary (what changes where):

Prose-only policy alignment across the 17-file edit surface. One structurally parallel carve-out in `.claude/rules/powershell.md`, plus capability qualifications at every other site that binds the branch threshold to PowerShell, root and bundle mirror together.

1. `.claude/rules/powershell.md:63-65` — replace the branch line with a carve-out structurally parallel to the four-part shape of `.claude/rules/shell.md:68-70`:
   1. Name the tool and its actual capability: Pester measures command (instruction) coverage and line coverage.
   2. Preserve the uniform line threshold explicitly, with the `.claude/rules/quality-tiers.md` cross-reference (`>= 85%`).
   3. State the incapability as a fact about the tool: branch coverage is not measurable by Pester for PowerShell.
   4. Disclaim the gate's existence, not merely its threshold: there is no PowerShell branch-coverage gate.
   The line-coverage bullet (line 63) and the changed-lines regression bullet (line 65) are preserved unchanged.
2. `.claude/rules/general-unit-test.md:24` — qualify the branch threshold to languages whose tooling measures branch coverage, naming PowerShell (Pester) and bash (kcov) as the two exceptions where only the line threshold applies. The line-coverage bullet and the no-regression bullet remain unconditional.
3. `.claude/rules/quality-tiers.md:25,34,51` — same qualification on the uniform-thresholds statement, the gate-matrix branch row, and the rationale paragraph. The line-coverage row and the no-regression row remain unconditional.
4. `.claude/skills/feature-review-workflow/SKILL.md:111-114` — qualify the three branch-threshold bullets so the branch clause applies only to branch-capable languages; the line clause and the no-regression clause remain unconditional for all coverage languages including PowerShell.
5. `.claude/agents/feature-review.md:112-114` — same qualification.
6. `.claude/skills/powershell-qa-gate/SKILL.md:45` — remove or qualify the branch clause; the `>= 85%` line clause remains.
7. Bundle mirrors of 1-6 under `extensions/drm-copilot/resources/claude-customizations/.claude/` — byte-identical to their root counterparts.
8. `.agents/skills/general-unit-test/SKILL.md:29` and `.agents/skills/quality-tiers/SKILL.md:30,39,56` — same qualification as items 2-3, plus their byte-identical mirrors under `extensions/drm-copilot/resources/codex-and-agents-customizations/`.
9. `README.md:298` — consistency edit so the toolchain summary no longer states a uniform branch threshold for PowerShell.

Amendment vocabulary (from research R4): Pester performs static AST analysis and instruments every measurable command; `INSTRUCTION` is one unit per command, `LINE` is derived by grouping commands per source line. Pester does not measure branch outcomes in any output format (`CoverageGutters`, `JaCoCo`, `Cobertura` share the same counter aggregation). Command coverage is described as what the tool measures; it is not adopted as a substitute gated metric.

### Boundaries and invariants to preserve:

- The `>= 85%` PowerShell line-coverage threshold is preserved exactly — not lowered, not removed, not made conditional. This is the single most important guard.
- No wording anywhere reads as excluding PowerShell files from coverage *measurement*. Excluding a production file from measurement is prohibited by the Coverage Exclusion Policy in `.claude/rules/general-unit-test.md`; this change removes an unevaluable threshold, not a measurement obligation.
- Branch-capable languages (Python, TypeScript, C#) retain their `>= 75%` branch gate unchanged.
- The no-regression-on-changed-lines clause remains unconditional for all languages.
- The bash carve-out at `.claude/rules/shell.md:68-70` is unchanged.
- Root/bundle byte parity for every edited shipped file.
- No new gated metric is introduced (command coverage remains descriptive, not gated).

### Dependencies or blocked work:

- None. All edits are Markdown files in this repository; verification runs locally.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

The 17 files enumerated in Scope & Non-Goals (8 root Markdown files, their 8 bundle mirrors, and `README.md`). No other file changes.

#### Functions/classes/CLI commands impacted:

- None. No production code, hook, script, test, or configuration file is modified.

#### Data flow and validation changes:

- None at the mechanism level. The prose policy becomes consistent with the existing hook behavior (`Get-JacocoBranchCoverage` returning `$null` for a zero-`BRANCH`-counter report, with the threshold check skipped on null).

#### Error handling and logging updates:

- None.

#### Rollback/feature-flag considerations (if applicable):

- No feature flag. Rollback is a revert of the Markdown edits; the change is prose-only and isolated.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

- Markdown policy text only. The carve-out follows the four-part structure of the bash precedent verbatim in shape, adapted to Pester/PowerShell.

#### Required configuration keys and defaults:

- None. `pester.runsettings.psd1` is not modified.

#### Backward-compatibility expectations:

- Root/bundle byte parity is maintained for every edited shipped file (enforced by `test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` and `test_push_down_codex_and_agents_resource_contracts.py::test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts`).
- No pack-manifest changes: no file is added or removed from any pack; only content of already-listed files changes.
- Consumers receive the corrected payload via the standard release flow (extension version bump, publish, consumer re-run of push-down); this is post-merge process outside this fix.

#### Performance constraints (latency/throughput/memory):

- Not applicable; prose-only change.

## Assumptions, Constraints, Dependencies

- Assumptions: the research inventory (R1) is the complete set of sites binding the branch threshold to PowerShell; no test pins the current branch-coverage wording of any affected file (verified in research R5).
- Constraints: repository tone policy applies to all amended prose; the four-part structural parallel to `shell.md:68-70` is required for the `powershell.md` carve-out; edits are limited to the enumerated 17 files.
- External dependencies: none.

## Data / API / Config Impact

- User-facing or API changes: none at runtime. Downstream consumers receive amended policy prose through the `core` and `powershell` packs (Claude surface) and the full-tree Codex/agents push-down after the next release.
- Data or migration considerations: none.
- Logging/telemetry updates: none.
- Compatibility notes: no CLI flags, config schemas, or versioned contracts change. The extension version bump that publishes the corrected bundle is standard post-merge release process.

## Test Strategy

Seeded from issue:

Align policy with tooling capability, mirroring the existing bash precedent rather than inventing a new mechanism.

- [x] Unit coverage areas: root/bundle parity tests for the edited payload files; pack-manifest completeness tests.
- [x] Integration scenario to retest: run a feature-review pass over a PowerShell-touching diff and confirm it no longer raises an unsatisfiable branch finding while the line-coverage gate still fails a genuinely under-covered file.
- [x] Manual verification notes: confirm the amended text names Pester explicitly, states the measurable metrics, and preserves the `>= 85%` line threshold unchanged.

Explicitly out of scope, to be filed separately:

- Building an AST-instrumentation branch collector for PowerShell.
- The opt-in allow-list under `CodeCoverage.Path` in `pester.runsettings.psd1`, which excludes every unlisted production PowerShell file from measurement and appears to conflict with the Coverage Exclusion Policy in `.claude/rules/general-unit-test.md`.

- Regression tests to add or update: none required by the policy-text route (research R5: no test pins the branch-coverage wording of any affected file). The binding regression suite is the existing parity/completeness set below. If the planner opts to pin the new carve-out wording against future drift, the established mechanism is a content-substring assertion in `test_push_down_claude_resource_contracts.py` (pattern precedent: the C# gate-command substring tests at lines 290-433); optional.
- Binding suites that must pass:
  - `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` — root/bundle byte parity, Claude surface. Fails if any root `.claude/**` edit lacks its byte-identical mirror edit.
  - `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` — pack-manifest completeness, Python side (presence-only; passes because no file is added).
  - Jest completeness twin `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`, via the extension's standard test command.
  - `poetry run pytest tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` — root/bundle byte parity, Codex surface (required because `.agents/**` is edited).
  - The full `poetry run pytest` per the repository loop.
- Edge cases and negative scenarios: verify by grep that no amended file lowers, removes, or conditions the `>= 85%` line threshold; that no amended wording excludes PowerShell from coverage measurement; that Python, TypeScript, and C# branch statements are textually unchanged.
- Error handling and logging verification: not applicable (no code change).
- Coverage impact and targets for changed lines/modules: not applicable; no production or test code changes, so no coverage delta.
- Toolchain commands to run: the changed files are Markdown, so no language toolchain loop is triggered by production-code changes. Run the binding pytest suites, the full pytest run, and the extension Jest suite. The hook Pester suite `tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1` is unaffected because the hook is not modified.
- Manual validation steps (if required): re-read the amended `.claude/rules/powershell.md` carve-out against the four-part structure of `shell.md:68-70`; behavioral integration re-test per the issue — a feature-review pass over a PowerShell-touching diff raises no branch-coverage finding while a genuinely under-covered file still fails the line gate.

## Acceptance Criteria

Each criterion is independently verifiable by the stated command, grep, or read. Check-off is the executor's and reviewer's responsibility.

Verification evidence for every criterion below is stored under `docs/features/active/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476/evidence/`; each check-off cites its artifact by path relative to that folder.

- [x] **AC1 — Carve-out present and structurally parallel.** `.claude/rules/powershell.md` replaces the former line-64 branch requirement with a carve-out that contains all four parts of the bash precedent's structure (`.claude/rules/shell.md:68-70`): (1) it names Pester and states the metrics it actually measures — command (instruction) coverage and line coverage; (2) it preserves the uniform line threshold with the `.claude/rules/quality-tiers.md` cross-reference; (3) it states that branch coverage is not measurable by Pester for PowerShell; (4) it states that there is no PowerShell branch-coverage gate. Verify: read the amended section and match each of the four parts. **Evidence:** `qa-gates/ac1-carveout-structure.2026-08-16T17-25.md` — all four parts mapped to their sentences with quotations; PASS.
- [x] **AC2 — PowerShell line threshold preserved exactly.** In every amended file, the `>= 85%` line-coverage threshold applicable to PowerShell is unchanged: not lowered, not removed, and not made conditional. `.claude/rules/powershell.md:63` (the line-coverage bullet) is textually unchanged. Verify: `git diff` over the edit surface shows no modification to any `>= 85%` line-coverage statement other than, at most, unchanged restatement within qualified sentences that leave the line clause unconditional. **Evidence:** `qa-gates/ac2-ac4-line-threshold-guard.2026-08-16T17-27.md` — Checks A and B; the only removed line in `.claude/rules/powershell.md` is the former line 64, so line 63 is textually unchanged; PASS on all 11 rows.
- [x] **AC3 — Measurement obligation intact.** No amended wording reads as excluding PowerShell files from coverage *measurement*. The change removes an unevaluable threshold, not a measurement obligation: PowerShell production files remain in the coverage denominator per the Coverage Exclusion Policy in `.claude/rules/general-unit-test.md`, and at least one amended statement (in `.claude/rules/powershell.md` or `.claude/rules/general-unit-test.md`) makes this threshold-versus-measurement distinction explicit. Verify: read each amended passage; confirm none states or implies that PowerShell files are excluded from measurement, and locate the explicit distinction. **Evidence:** `qa-gates/ac3-measurement-obligation.2026-08-16T17-29.md` — 0 of 9 amended passages imply exclusion from measurement; the explicit distinction is located at `.claude/rules/powershell.md:64` and restated in `general-unit-test.md:24` and `quality-tiers.md:51`; PASS.
- [x] **AC4 — Shared-file qualifications scoped to the branch clause only.** In `.claude/rules/general-unit-test.md:24`, `.claude/rules/quality-tiers.md:25,34,51`, `.claude/skills/feature-review-workflow/SKILL.md:111-114`, and `.claude/agents/feature-review.md:112-114`, only the branch-coverage clause is qualified to branch-capable languages; the line-coverage clause and the no-regression-on-changed-lines clause remain unconditional for all coverage languages, including PowerShell. Verify: read each amended passage; confirm the qualification attaches to the branch clause and to no other clause. **Evidence:** `qa-gates/ac2-ac4-line-threshold-guard.2026-08-16T17-27.md` — Checks C and D; the no-regression clause is retained unqualified in all four files that restate it, and every introduced qualifier modifies only the words "branch coverage"; PASS.
- [x] **AC5 — Branch-capable languages unweakened.** Python, TypeScript, and C# remain gated at branch coverage `>= 75%`. The amended shared files still state the `>= 75%` branch threshold for branch-capable languages, and `.claude/rules/python.md`, `.claude/rules/typescript.md`, and `.claude/rules/csharp.md` are unmodified. Verify: grep the amended files for the `>= 75%` branch statement scoped to branch-capable languages; `git diff` shows no change to the three language rule files. **Evidence:** `qa-gates/ac5-branch-capable-unweakened.2026-08-16T17-33.md` — the `>= 75%` branch threshold is retained in all eight amended shared files scoped to branch-capable languages, and `python.md`, `typescript.md`, `csharp.md` (and their mirrors) are absent from `git diff --name-only`; PASS.
- [x] **AC6 — PowerShell QA-gate skill aligned.** `.claude/skills/powershell-qa-gate/SKILL.md:45` no longer requires branch coverage `>= 75%` for PowerShell; the `>= 85%` line-coverage requirement at that site is retained. Verify: read the amended line. **Evidence:** P2-T3 edit and `qa-gates/ac16-inventory-sweep.2026-08-16T17-41.md` — the amended line 45 reads "line coverage >= 85% per the uniform tier rule... branch coverage is not measurable for PowerShell, so no branch-coverage gate applies here"; the site is absent from the residual unqualified-binding list; PASS.
- [x] **AC7 — Codex surface aligned.** `.agents/skills/general-unit-test/SKILL.md:29` and `.agents/skills/quality-tiers/SKILL.md:30,39,56` carry the same branch-clause qualification as their `.claude` counterparts (AC4 semantics: branch clause qualified to branch-capable languages; line clause and no-regression clause unconditional). Verify: read the amended passages. **Evidence:** `qa-gates/ac2-ac4-line-threshold-guard.2026-08-16T17-27.md` (rows 9-10 and Check D cover the two Codex files) and `qa-gates/ac5-branch-capable-unweakened.2026-08-16T17-33.md` — both Codex files carry the same branch-only qualification as their `.claude` counterparts; PASS.
- [x] **AC8 — Root/bundle byte parity.** Every edited root file has its bundle mirror edited byte-identically in the same change: the six `.claude/**` files under `extensions/drm-copilot/resources/claude-customizations/`, and the two `.agents/**` files under `extensions/drm-copilot/resources/codex-and-agents-customizations/`. Verify: byte comparison per pair, and AC9's parity suites pass. **Evidence:** `qa-gates/ac8-byte-parity.2026-08-16T17-37.md` — all 8 root/mirror pairs MATCH by SHA256, `FAILED_PAIRS=0`; corroborated mechanically by `qa-gates/final-pytest-parity.2026-08-16T17-43.md`; PASS.
- [x] **AC9 — Parity and completeness suites pass.** `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` passes, and the Jest completeness twin (`extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`) passes via the extension's standard test command. Verify: command exit codes and test output. **Evidence:** `qa-gates/final-pytest-parity.2026-08-16T17-43.md` (20 passed, exit code 0) and `qa-gates/final-jest-coverage.2026-08-16T17-46.md` (185 suites / 2552 tests passed, exit code 0, includes the pack-completeness twin); PASS.
- [x] **AC10 — Coverage hook unmodified.** `.claude/hooks/validate-feature-review-coverage.ps1` is not modified (its `$null`-skip behavior already implements the target policy), and its bundle mirror is likewise unmodified. Verify: `git diff` shows no change to the hook or its mirror. **Evidence:** `qa-gates/ac10-ac11-untouched-surfaces.2026-08-16T17-35.md` — filtering the 17-entry changed-file list for `validate-feature-review-coverage` returns zero rows for both the hook and its mirror; PASS.
- [x] **AC11 — Copilot surface unmodified.** No file under `.github/**` is modified (research confirmed the surface never carried a branch threshold). Verify: `git diff` shows no `.github/**` change. **Evidence:** `qa-gates/ac10-ac11-untouched-surfaces.2026-08-16T17-35.md` — filtering the changed-file list for the `^\.github/` prefix returns zero rows; PASS.
- [x] **AC12 — README consistency edit.** `README.md:298` no longer states a uniform branch-coverage `>= 75%` requirement covering PowerShell; the `>= 85%` line-coverage statement is preserved. Verify: read the amended line. **Evidence:** `qa-gates/ac2-ac4-line-threshold-guard.2026-08-16T17-27.md` (Check A row 11) and `qa-gates/ac16-inventory-sweep.2026-08-16T17-41.md` — the amended line retains "line coverage >= 85%, with no regression on changed lines" and scopes the branch threshold to branch-capable languages, exempting PowerShell and bash; PASS.
- [x] **AC13 — No command-coverage gate introduced.** No amended text establishes Pester command (instruction) coverage as a gated metric with a threshold; command coverage appears only descriptively as what Pester measures. Verify: read each amended passage; confirm no numeric threshold attaches to command or instruction coverage. **Evidence:** `qa-gates/ac13-no-command-gate.2026-08-16T17-31.md` — all four amended mentions are descriptive, two carry an explicit "no threshold attached" disclaimer, and the repository-wide search for a percentage adjacent to a command/instruction-coverage mention returns no matches; PASS.
- [x] **AC14 — Edit surface closed.** Exactly the 17 enumerated files are modified: the 8 root Markdown files, their 8 bundle mirrors, and `README.md`. No hook, script, test, configuration, or `.github/**` file changes. Verify: `git diff --name-only` against the enumerated list. **Evidence:** `qa-gates/ac14-edit-surface.2026-08-16T17-39.md` — `git diff --name-only 687380a6` returns exactly 17 files matching the enumerated list one-for-one, with zero hook, script, test, configuration, or `.github/**` entries; PASS.
- [x] **AC15 — Full test suites pass.** The full `poetry run pytest` run and the extension Jest suite complete without failures. Verify: command exit codes. **Evidence:** `qa-gates/final-pytest-full.2026-08-16T17-45.md` (3785 passed, 5 pre-existing skips, exit code 0; line 92.30%, branch 89.46%), `qa-gates/final-jest-coverage.2026-08-16T17-46.md` (2552 passed, exit code 0; line 96.61%, branch 89.96%), and `qa-gates/coverage-delta.2026-08-16T17-47.md` (zero delta on all 19 compared values); PASS.
- [x] **AC16 — Inventory swept.** A repository grep for statements binding a branch-coverage threshold to PowerShell (for example, case-insensitive `branch coverage` across `.claude/`, `.agents/`, `.codex/`, `README.md`, and both bundle payloads, excluding `docs/features/**` and `docs/research/**` historical artifacts) finds no remaining unqualified requirement that binds branch `>= 75%` to PowerShell. The bash carve-out at `.claude/rules/shell.md:68-70` is unchanged. Verify: grep output plus `git diff` on `shell.md`. **Evidence:** `qa-gates/ac16-inventory-sweep.2026-08-16T17-41.md` — zero remaining unqualified PowerShell branch-threshold bindings; the ten residual unqualified matches all bind to a branch-capable language or to the deliberately unmodified coverage hook; an anchored `(^|/)shell\.md$` filter and `git diff --stat` confirm `shell.md` and its mirror are byte-unchanged; PASS. Baseline for comparison: `baseline/branch-coverage-grep-baseline.2026-08-16T17-14.md`.

## Risks & Mitigations

- **Risk:** the qualification wording accidentally weakens the line-coverage gate or the no-regression clause. **Mitigation:** AC2 and AC4 pin both clauses as unconditional; the diff review compares each amended sentence against the pre-change threshold text.
- **Risk:** the carve-out is read as permission to exclude PowerShell files from coverage measurement, contradicting the Coverage Exclusion Policy. **Mitigation:** AC3 requires an explicit threshold-versus-measurement distinction and a negative read-through of every amended passage.
- **Risk:** a shipped mirror is missed, breaking root/bundle parity. **Mitigation:** the parity suites (AC8, AC9) fail deterministically on any divergent pair; both surfaces' suites are in the binding command set.
- **Risk:** future drift reintroduces an unqualified branch requirement for PowerShell. **Mitigation:** optional content-substring pin in `test_push_down_claude_resource_contracts.py` (planner's decision, per Test Strategy); the carve-out text itself now documents the tooling capability at every binding site.
- **Risk:** a reviewer following older cached policy raises the finding anyway. **Mitigation:** the amendment lands at every enumerated binding site (AC16), removing the ambiguity that previously produced three different audit dispositions.

## Rollout & Follow-up

- Release/rollout steps: standard branch → PR → merge on `bug/powershell-branch-coverage-gate-unsatisfiable-476`. Downstream consumers receive the corrected payload after the next paired extension + mcp-server version bump and publish, followed by a consumer re-run of `push_down_claude_customizations` (Claude surface) and `push_down_codex_and_agents_customizations` (Codex surface). A consumer working from a drm-copilot checkout can run the Python CLI against the updated checkout without waiting for a release.
- Post-fix monitoring or clean-up tasks: on the next feature-review pass over a PowerShell-touching diff, confirm no branch-coverage finding is raised and that the line gate still operates. Separate follow-ups to file per `issue.md`: an AST-instrumentation branch collector for PowerShell, and the `CodeCoverage.Path` opt-in allow-list conflict with the Coverage Exclusion Policy. The dangling `docs/ci.research.md` reference at `.claude/rules/quality-tiers.md:4` remains a known, out-of-scope defect.
- Links: issue [#476](https://github.com/drmoisan/drm-copilot/issues/476); research `docs/features/active/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476/research/2026-08-16T17-30-powershell-branch-coverage-gate-research.md`; bash precedent `.claude/rules/shell.md:68-70`.
