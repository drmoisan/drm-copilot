# powershell-branch-coverage-gate-unsatisfiable (Issue #476)

- Date captured: 2026-08-16
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/powershell-branch-coverage-gate-unsatisfiable/ (Issue #476)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #476
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/476
- Last Updated: 2026-08-16T17-51
- Work Mode: full-bug

## Summary

Repository policy requires PowerShell branch coverage `>= 75%`, but Pester — the only PowerShell test and coverage runtime in this repository — cannot measure branch coverage at all. The requirement is unsatisfiable by construction, so any feature-review that audits PowerShell raises a permanent Blocking finding that no amount of test authoring can clear. The defect propagates to consumer repositories because the affected policy files ship in the push-down payload.

## Environment

- OS/version: Windows 11 Pro 10.0.26200; also reproduces on `windows-latest` CI runners.
- Python version: not applicable; the defect is in PowerShell policy and Pester tooling.
- Command/flags used: `Invoke-PoshQCTest -Root <repo>` via `mcp__drm-copilot__run_poshqc_test`, then parse `artifacts/pester/powershell-coverage.xml`.
- Data source or fixture: `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`; Pester 5.6.1.

## Steps to Reproduce

1. Run the PowerShell toolchain so `artifacts/pester/powershell-coverage.xml` is produced.
2. Parse the report and enumerate `counter` node types and any `BRANCH` counter.
3. Inspect the Pester coverage configuration surface: `(New-PesterConfiguration).CodeCoverage.PSObject.Properties.Name`.
4. Search the installed Pester module source for the string `branch`.
5. Run a feature-review pass that audits PowerShell coverage against `.claude/rules/powershell.md`.

## Expected Behavior

Either the toolchain produces a genuine PowerShell branch-coverage number that the `>= 75%` threshold can be evaluated against, or repository policy states that branch coverage is not measurable for PowerShell and does not gate on it — matching how the repository already handles bash.

## Actual Behavior

No branch metric exists, and policy still demands one.

- `artifacts/pester/powershell-coverage.xml` contains counter types `CLASS`, `INSTRUCTION`, `LINE`, and `METHOD` only. There are zero `BRANCH` counter nodes, zero `branch="true"` line elements, zero line elements with a positive `mb`+`cb` denominator, and zero condition nodes.
- Pester's `CodeCoverage` configuration exposes `CoveragePercentTarget`, `Enabled`, `ExcludeTests`, `OutputEncoding`, `OutputFormat`, `OutputPath`, `Path`, `RecursePaths`, `SingleHitBreakpoints`, and `UseBreakpoints`. There is no branch property.
- The installed Pester 5.6.1 module source contains **zero** occurrences of the string `branch` across all `.ps1` and `.psm1` files. Pester has no branch-coverage capability in any output format, so changing `OutputFormat` to `JaCoCo` or `Cobertura` does not help.
- The genuine branch denominator is therefore `0`, and a percentage cannot be computed. The threshold is not merely unmet; it is unevaluable.

## Logs / Screenshots

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

## Impact / Severity

- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

Any feature-review pass that audits changed PowerShell files is permanently blocked. A downstream consumer repository that inherited this policy through push-down has already stalled a remediation cycle on this finding, having correctly refused to manufacture a passing metric rather than relabel command hits, line hits, or AST positions as branch outcomes.

## Suspected Cause / Notes

The uniform coverage rule was written for languages whose tooling supports branch measurement (pytest `--cov-branch`, Jest, coverlet) and was applied to PowerShell without a capability check.

Conflicting policy sources:

- `.claude/rules/powershell.md:64` — "Branch coverage must remain >= 75% across all tiers (T1–T4)."
- `.claude/rules/general-unit-test.md:24` — "**Branch coverage must remain >= 75% across all tiers (T1–T4).**"
- `.claude/rules/quality-tiers.md:34` — uniform gate matrix lists "Branch coverage: >= 75%."
- `.claude/skills/feature-review-workflow/SKILL.md:112-114` — requires branch `>= 75%` for new files, modified files, and repo-wide per language, with no capability carve-out.

The repository already resolved this exact class of conflict for a different language and never applied the resolution to PowerShell:

- `.claude/rules/shell.md:68-70` — "kcov reports **line coverage only**. The uniform line-coverage threshold (>= 85% per `.claude/rules/quality-tiers.md`) applies. Branch coverage is not measurable by kcov for bash; there is no bash branch-coverage gate."

Note that GitHub Actions is not the failing gate. `.github/workflows/_poshqc.yml` runs format, analyze, and test only, and `pester.runsettings.psd1` sets `CoveragePercentTarget = 0`. The blocking gate is the local feature-review policy audit.

Payload propagation — the affected files ship to consumer repositories:

- `.claude/rules/powershell.md` ships in the `powershell` pack.
- `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, and `.claude/skills/feature-review-workflow/SKILL.md` ship in the `core` pack.
- Each has a mirrored copy under `extensions/drm-copilot/resources/claude-customizations/.claude/`, so root/bundle parity applies to every edit.

## Proposed Fix / Validation Ideas

Align policy with tooling capability, mirroring the existing bash precedent rather than inventing a new mechanism.

- [x] Unit coverage areas: root/bundle parity tests for the edited payload files; pack-manifest completeness tests.
- [x] Integration scenario to retest: run a feature-review pass over a PowerShell-touching diff and confirm it no longer raises an unsatisfiable branch finding while the line-coverage gate still fails a genuinely under-covered file.
- [x] Manual verification notes: confirm the amended text names Pester explicitly, states the measurable metrics, and preserves the `>= 85%` line threshold unchanged.

Explicitly out of scope, to be filed separately:

- Building an AST-instrumentation branch collector for PowerShell.
- The opt-in allow-list under `CodeCoverage.Path` in `pester.runsettings.psd1`, which excludes every unlisted production PowerShell file from measurement and appears to conflict with the Coverage Exclusion Policy in `.claude/rules/general-unit-test.md`.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch
- [x] Implement the fix on branch `bug/powershell-branch-coverage-gate-unsatisfiable-476` (see Fix Outcome below)

## Fix Outcome

Recorded 2026-08-16T17-51 on branch `bug/powershell-branch-coverage-gate-unsatisfiable-476` (base `main` at `687380a6`).

**Resolution.** The policy prose is now aligned with actual tooling capability, structurally paralleling the existing bash carve-out at `.claude/rules/shell.md:68-70`. `.claude/rules/powershell.md:64` was replaced with a four-part carve-out naming Pester, stating the metrics it measures (command/instruction coverage and line coverage), preserving the uniform `>= 85%` line threshold with its `quality-tiers.md` cross-reference, stating that branch coverage is not measurable by Pester for PowerShell, and disclaiming the existence of a PowerShell branch-coverage gate. Every other site that bound the branch threshold to PowerShell now qualifies that clause to branch-capable languages.

**Hook unchanged.** `.claude/hooks/validate-feature-review-coverage.ps1` and its bundle mirror were not modified. The hook already returns `$null` when a coverage report carries zero `BRANCH` counters and skips the 75% floor check on null, so the mechanism already implemented the target policy. This change closed a prose/mechanism gap; it did not weaken an operating gate. No file under `.github/**` was modified, and `.claude/rules/shell.md` is byte-unchanged.

**Edit surface closed at 17 files.** `git diff --name-only` against base `main` returns exactly the 8 root Markdown files, their 8 bundle mirrors, and `README.md`. No hook, script, test, or configuration file changed; every changed file has the `.md` extension. All 8 root/mirror pairs are byte-identical by SHA256.

**Guards verified.** The `>= 85%` line-coverage threshold was not lowered, removed, or made conditional anywhere; `.claude/rules/powershell.md:63` is textually unchanged. The no-regression-on-changed-lines clause remains unconditional for all coverage languages including PowerShell. No amended passage reads as excluding PowerShell files from coverage measurement, and three amended passages state the threshold-versus-measurement distinction explicitly. Python, TypeScript, and C# remain gated at branch `>= 75%`, and their rule files are unmodified. No command-coverage threshold was introduced.

**Verification.** All 16 acceptance criteria in `spec.md` are checked off, each citing its evidence artifact under `evidence/`. Final QA passed in a single uninterrupted sequence: parity and completeness suites 20 passed (exit 0); full `poetry run pytest --cov --cov-branch` 3785 passed / 5 pre-existing skips (exit 0), line coverage 92.30%, branch coverage 89.46%; extension `npm run test:coverage` 185 suites / 2552 tests passed (exit 0), line coverage 96.61%, branch coverage 89.96%. Coverage delta against baseline is zero on all 19 compared values, as expected for a Markdown-only change.

**Fail-before evidence.** A regression test that fails before the fix is structurally impossible for a prose-only policy defect; no test in `tests/**` or `extensions/drm-copilot/test/**` asserts on the branch-coverage wording of any affected file. The exception dossier at `evidence/regression-testing/fail-before-exception.2026-08-16T17-15.md` records the reasoning and substitutes a before-and-after inventory comparison as the alternative proof.

**Deviations from scope.** None. The 17-file edit surface was not expanded, and no additional phase or task was performed. One methodology correction is recorded in the baseline artifact: the inventory grep requires ripgrep's `--hidden` flag because the bundle mirror paths contain `.claude` and `.agents` as nested hidden directory components; without it the mirrors are silently skipped. Both the baseline and post-change sweeps use the corrected command so the two lists are comparable.

**Follow-ups confirmed still open** (recorded above under Proposed Fix / Validation Ideas, and unchanged by this fix):

1. Building an AST-instrumentation branch collector for PowerShell.
2. The opt-in allow-list under `CodeCoverage.Path` in `pester.runsettings.psd1`, which excludes every unlisted production PowerShell file from measurement and appears to conflict with the Coverage Exclusion Policy in `.claude/rules/general-unit-test.md`.

A third known defect, the dangling `docs/ci.research.md` reference at `.claude/rules/quality-tiers.md:4`, remains out of scope for #476 and was not touched.

**Downstream.** Consumer repositories receive the corrected payload after the next paired extension and mcp-server version bump and publish, followed by a consumer re-run of `push_down_claude_customizations` and `push_down_codex_and_agents_customizations`. That is standard post-merge release process and is outside this fix.
