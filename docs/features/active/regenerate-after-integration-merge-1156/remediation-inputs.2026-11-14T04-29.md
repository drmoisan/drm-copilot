# Remediation Inputs — Issue 1156 (initial feature review)

Timestamp: 2026-11-14T04-29
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Path: full
Issue: 1156
Base: main
Merge-Base: 063504dc4b2ea08a2c5bd39b57d70ce5963815ed
Reviewed-Head: 8533618dd00aa5dc43ee353598fdf1107a76d192
Source review artifacts:
- `docs/features/active/regenerate-after-integration-merge-1156/policy-audit.2026-11-14T04-29.md`
- `docs/features/active/regenerate-after-integration-merge-1156/code-review.2026-11-14T04-29.md`
- `docs/features/active/regenerate-after-integration-merge-1156/feature-audit.2026-11-14T04-29.md`

## Disposition

Two findings require remediation inside this item (OD-6). Both are autonomous and contained. The path is full, not light, because finding R1 edits `quality-tiers.yml`, a file outside the branch diff. All 49 acceptance criteria evaluate PASS and stay checked. Coverage, gates, mirrors, digests, brief copies, and ledger patches pass.

## Finding R1

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: Adding one project entry to quality-tiers.yml on the branch and re-running the tier check needs no external system, owner decision, or CI result.
Finding-Scope: contained
Remediation-Mode: proportionate

- Location: `quality-tiers.yml` (repository root); the branch adds the project folder `.claude/lib/regeneration/`.
- Requirement: `.claude/rules/quality-tiers.md` (`## Source of Truth`): when `quality-tiers.yml` exists, every project is classified, and the `tier-classification` CI step fails for an unclassified project.
- Observed: `python -m scripts.dev_tools.check_quality_tiers` exits 1 with `QT008: discovered project '.claude/lib/regeneration' has no entry` (`evidence/qa-gates/quality-tiers-check.2026-11-14T04-29.md`). CI step `tier-classification` in `.github/workflows/_quality-checks.yml` runs the same module, so `quality-checks7` will fail and skip its later pytest and coverage steps.
- Fix: add an entry for `.claude/lib/regeneration` next to the other `.claude/lib/*` entries, following their precedent (`tier: T3`, rationale "Runtime library shipped in the `.claude` bundle", plus a short description of the regenerate-path modules and entry point).
- Verification: `python -m scripts.dev_tools.check_quality_tiers` exits 0 from the worktree root (the main checkout's venv has `yaml`); `pytest -n auto` stays green.

## Finding R2

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The executable-resolution change or the documented constraint lies entirely in branch files (the adapter, its bundle copy, the skill and rules text, and their tests) and can be verified locally by a real-process probe and the parallel Pester gate.
Finding-Scope: contained
Remediation-Mode: proportionate

- Location: `.claude/lib/regeneration/Invoke-RegenerationPath.ps1` lines 98-116 (`Invoke-RegenerationProcess` `-Invoker` default, decision AD-1) and its byte copy under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/regeneration/`.
- Requirement: spec `### Config file` defines `command` as an argv executed with no shell from the worktree root, and user-story AC3 requires the command to run on the merged tree. Orchestrators in this repository run on Windows.
- Observed: the default starts `argv[0]` with `ProcessStartInfo` and `UseShellExecute = false`, which on Windows resolves only `.exe` names. A real-process probe showed `npm --version` throwing "The system cannot find the file specified" while `Get-Command npm` resolves `npm.ps1`. In an end-to-end Tip run with command `["npm","--version"]`, the result was `not_applied` with `command_exit_code` null (`evidence/other/process-start-probe.2026-11-14T04-29.md`). The call-operator default that AD-1 replaced did resolve such shims. No document states the constraint, and Linux CI cannot observe it.
- AD-1 itself is otherwise correct: stdout stays one JSON object, both streams are read asynchronously before `WaitForExit`, a start failure throws, and the integer exit code is returned. The guard and its allowlist must stay unchanged.
- Fix, choose one:
  - (a) Code: resolve `argv[0]` before the start. On Windows, when the name has no extension and no `.exe` is found, search `PATH` with `PATHEXT`. Start a `.cmd` or `.bat` match through `cmd.exe /d /c` with each argument as its own `ArgumentList` item. Keep zero command-AST nodes in the default so the no-Python guard and check (h) still hold; update check (h) to pin the new statements. Add a direct seam case and copy the file to the bundle.
  - (b) Documentation: state in the orchestrate skill config rules (item 2 of `## Merge-Conflict Remediation`) and in the rules-file section that each argv of `command`, `idempotency_check`, and `unit_gate` must name a directly startable executable, with its extension on Windows (for example `npm.cmd`). Mirror both files to the bundle, add the literal to `regeneration-path-skill-contract.Tests.ps1`, and re-baseline nothing else (neither file has a pinned digest).
  - Keep `Invoke-RegenerationPath.ps1` at or below its current 711 logical lines where possible (700-line advisory tier).
- Verification: repeat the probe (code fix: `["npm","--version"]` returns exit 0 on Windows; documentation fix: the skill-contract case fails when the sentence is removed), then one `Invoke-PoshQCParallelTest` run with the PowerShell static loop.

## Non-remediation notes

- Warning (code review): `Invoke-RegenerationPath.ps1` and its bundle copy are 711 logical lines.
- Minor (code review): `SupportsShouldProcess` is absent on the state-changing adapter functions, consistent with the other orchestration entry points.
- Info (code review): the digest re-baseline comment omits #1174; the digests are correct.
- The reviewer added three new evidence files and the gitignored root `coverage/lcov.info`; commit the evidence files with this review set.

## Context Package

- Canonical primary context: `artifacts/pr_context.summary.txt` (generated at the reviewed head).
- Canonical baseline appendix: `artifacts/pr_context.appendix.txt`.
