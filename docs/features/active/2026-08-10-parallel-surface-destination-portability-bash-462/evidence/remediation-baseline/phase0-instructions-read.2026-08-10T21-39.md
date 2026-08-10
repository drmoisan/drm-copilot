# Phase 0 — Policy Reads (Remediation Cycle 1)

Timestamp: 2026-08-10T21-39
Issue: #462
Plan: `docs/features/active/2026-08-10-parallel-surface-destination-portability-bash-462/remediation-plan.2026-08-10T21-03.md`
Task: [P0-T1]

## Policy Order

Read in the order prescribed by `.claude/skills/policy-compliance-order/SKILL.md`, extended with the
shell-lane and tonality rules that apply to the files in scope for this cycle.

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/shell.md`
5. `.claude/rules/tonality.md`
6. `docs/features/active/2026-08-10-parallel-surface-destination-portability-bash-462/remediation-inputs.2026-08-10T21-03.md`

## Files Read (explicit list, six files)

| # | Path | Purpose in this cycle |
| --- | --- | --- |
| 1 | `CLAUDE.md` | Standing instructions, tone policy, policy compliance reading order, architecture |
| 2 | `.claude/rules/general-code-change.md` | Cross-language code change policy, toolchain loop, 500-line file limit |
| 3 | `.claude/rules/general-unit-test.md` | Cross-language unit test policy, coverage thresholds |
| 4 | `.claude/rules/shell.md` | Shell toolchain (shfmt / shellcheck / bats / kcov), suppression policy, `\|\| rc=$?` capture rule, CI-vs-local version drift |
| 5 | `.claude/rules/tonality.md` | Required professional tone for all authored content |
| 6 | `<FEATURE>/remediation-inputs.2026-08-10T21-03.md` | RI-1 through RI-5, read in full |

Additionally loaded as standing context (auto-loaded rule files, not part of the required six):
`.claude/rules/parallel-orchestration.md`, `.claude/rules/orchestrator-state.md`,
`.claude/rules/quality-tiers.md`, `.claude/rules/benchmark-baselines.md`, `.claude/rules/ci-workflows.md`.

## Rule Excerpts Directly Governing This Cycle

- `.claude/rules/shell.md` line 81-83: "Tools that legitimately return non-zero (shfmt diff mode,
  shellcheck, bats, kcov) must be captured with `|| rc=$?` so an intended non-zero exit does not
  abort under `set -e`." This is the rule that the RI-3 suppression comments misquoted. It governs
  the two retained sites (`shell_qc_lib.sh` pre-edit lines 263 and 361), which are NOT in RI-3 scope.
- `.claude/rules/shell.md` line 84-85: "Suppressions are permitted only when justified inline with a
  `# shellcheck disable=SCxxxx` comment stating the reason." RI-3 concludes no suppression is
  warranted; no replacement suppression of any scope is added.
- `.claude/rules/shell.md` line 72-77: CI pins shfmt 3.8.0 and apt-packaged shellcheck; CI versions
  are canonical and local disagreement defers to CI.
- `.claude/rules/general-code-change.md`: no shell file may exceed 500 lines.

## Verbatim Restatement — Binding Environment Constraints (plan section, five constraints)

1. **Bash cannot be fully verified locally.** `bats` and `kcov` are unavailable in this environment.
   Verification of shell changes is `gh workflow run _shell-coverage.yml --ref drm-copilot-wt-2026-08-10T09-25`,
   polled to completion, with the run URL and the printed `Bash coverage (lines): NN.N%` line recorded
   under `<FEATURE>/evidence/qa-gates/`.
2. **Local `shellcheck` 0.11.0 and `shfmt` are available** and may be used as a fast pre-check, but
   local shellcheck does not reproduce the CI SC2015 finding (verified: zero findings on the current
   files even with the suppressions removed, at `-S style`), because CI installs the older
   apt-packaged shellcheck. A clean local shellcheck run is NOT sufficient evidence for RI-3.
3. **`poetry run python -c` with a multi-line string silently produces no output and exits 0 here.**
   Use a single-line `-c` form only. A command returning no output has not run.
4. **`python -m scripts.dev_tools.validate_orchestrator_state` exits 0 without validating.** It must
   never be used as evidence.
5. **npm root scripts do not reach `extensions/**`.** Use `npm --prefix extensions/drm-copilot run <script>`
   if an extension script is ever needed; the extension script is `test:coverage`, not
   `test:unit:coverage`. (No task in this plan requires an npm lane; no TypeScript, Python, or
   PowerShell production file changes in this cycle.)

## Additional Operator Constraints Recorded for This Execution

- PoshQC MCP tools (`run_poshqc_analyze`, `run_poshqc_format`, `run_poshqc_analyze_autofix`,
  `run_poshqc_suite`) are prohibited for this cycle. A prior run scoped to `scripts/bash` reformatted
  84 unrelated tracked JSON files repo-wide while returning `ok: true`. `shellcheck` and `shfmt` are
  invoked directly instead. No task in this plan requires PoshQC.
- `gh run list --commit <sha>` requires the full 40-character SHA; the abbreviated form returns `[]`
  with exit 0.
- The coverage line must be matched with the digit-anchored pattern
  `grep -E "Bash coverage \(lines\): [0-9]"`. The unanchored form also matches the `shell-qc.sh`
  usage banner, whose literal text contains the placeholder `NN.N%`.
- `scripts/bash/shell_qc_lib.sh` pre-edit lines 263 and 361 must not be modified.

EXIT_CODE: 0

Output Summary: All six required policy/input files were read in the prescribed order prior to any
edit. The shell-lane suppression and exit-code-capture rules that govern RI-3 were located and are
quoted above. The five Binding Environment Constraints are restated verbatim. No policy file was
modified.
