# blast-radius-powershell-calling-convention (Issue #598)

- Date captured: 2026-08-29
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/blast-radius-powershell-calling-convention/ (Issue #598)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #598
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/598
- Last Updated: 2026-08-29
- Work Mode: full-bug

## Summary

The shared PowerShell modules under `.claude/lib/**` have no fail-fast error preference, so an import
or internal failure can continue silently instead of surfacing, and the checkpoint JSON parse in
`.claude/lib/orchestrator-state/OrchestratorState.psm1` lets `ConvertFrom-Json` coerce ISO-8601-looking
strings into `[datetime]`, which breaks a string-typed field contract.

This is Feature A (wave 0) of the `claude-runtime-portability` epic
(`docs/features/epics/claude-runtime-portability/epic.md`). It establishes the calling convention that
Feature C (wave 1) later applies at the three caller sites.

## Environment

- OS/version: Windows 11 Pro 10.0.26200; the `.claude/**` payload also ships to consumer repositories
  via the push-down mechanism.
- Python version: Not applicable. The affected surface is PowerShell; the only Python involvement is
  the bundle-parity test named under Proposed Fix / Validation Ideas.
- Command/flags used: `Import-Module .claude/lib/<area>/<Module>.psm1`; `ConvertFrom-Json` at the three
  parse sites listed under Suspected Cause / Notes.
- Data source or fixture: `artifacts/orchestration/orchestrator-state.json` (the checkpoint object read
  at `OrchestratorState.psm1:175`).

## Steps to Reproduce

1. Import any module under `.claude/lib/**`. No module sets `$ErrorActionPreference`, so a
   non-terminating error inside the module does not stop the caller.
2. Write an orchestrator checkpoint containing an ISO-8601-looking string value (for example a
   `computed_at`, `assessed_at`, or `checked_at` field).
3. Read the checkpoint through `Get-OrchestratorState` (`OrchestratorState.psm1:175`), which calls
   `$raw | ConvertFrom-Json -ErrorAction Stop` with no date-coercion control.
4. Inspect the parsed field's type.

## Expected Behavior

1. An import failure or an internal module failure surfaces as a terminating error rather than being
   swallowed, so a caller cannot proceed on partially-initialized state.
2. A JSON string field parsed out of a checkpoint or radius object stays a `[string]`, matching the
   string-typed contract that `Get-RequiredText` (`BlastRadiusConfig.psm1:52-94`) enforces on the
   validation side.

## Actual Behavior

1. Verified: zero files under `.claude/lib/**` set `$ErrorActionPreference`. The setting appears only
   in `.claude/hooks/*.ps1` (6 files). Module-internal non-terminating errors therefore do not stop
   the caller.
2. `ConvertFrom-Json` materializes an ISO-8601-looking string as `[datetime]` by default. A downstream
   consumer that expects a string then receives a `[datetime]`, and
   `.claude/lib/blast-radius/BlastRadiusValidation.psm1:124` delegates to `Get-RequiredText`, which
   throws `"computed_at must be a string, got <Type>."` on exactly that type mismatch.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet:

```
# Verified against the tree at commit c861ddff:
$ grep -rn 'ErrorActionPreference' .claude/lib/ | wc -l
0
$ grep -rln 'ErrorActionPreference' .claude/hooks/ | wc -l
6

# The three ConvertFrom-Json call sites under .claude/lib/**:
.claude/lib/discovery-validation/DiscoveryValidation.psm1:338
.claude/lib/hook-payload/HookPayload.psm1:262
.claude/lib/orchestrator-state/OrchestratorState.psm1:175
```

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

A silent failure in a shared module surfaces later as a wrong result rather than an error, and a
string-to-`[datetime]` coercion breaks a validated field contract at a module boundary. Both affect
every caller of the shared library, including consumer repositories that receive the pushed-down
payload.

## Suspected Cause / Notes

Verified tree facts, corrected against the epic manifest's restatement:

- **Corrected count.** `.claude/lib/**` holds **36** tracked files across **8** subdirectories, not the
  "37 files across nine subdirectories" the manifest states. The breakdown is 27 `.psm1` modules and 9
  `.sh` scripts, the latter all under `.claude/lib/bash/`. Only the 27 `.psm1` files across 7
  subdirectories can carry `$ErrorActionPreference`; a bash script cannot. The substantive claim (zero
  occurrences) is confirmed.
- **Confirmed.** No module under `.claude/lib/blast-radius/` calls `ConvertFrom-Json`. The three
  matches in `BlastRadiusConfig.psm1` (lines 26, 147, 175) are explanatory comments, not calls. Those
  modules operate on an already-parsed mapping supplied by the caller, so the intake premise that a
  `-DateKind String` helper is needed by "every JSON parse touching a radius object" has no call site.
- **Confirmed.** `-DateKind String` is already used correctly on the test side at
  `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1:318`, with an explanatory comment
  at lines 314-316. It is the only `-DateKind` occurrence in the repository.
- **Confirmed.** `BlastRadiusValidation.psm1:124` delegates to `Get-RequiredText`
  (`BlastRadiusConfig.psm1:52-94`), which enforces a **non-empty** string, not merely a string.
- **New constraint, not in the manifest.** `scripts/powershell/PoshQC/settings/pssa.settings.psd1:10`
  sets `TargetVersions = @('5.1', '7.6')`. `-DateKind` is a PowerShell **7.5+** parameter and
  `-AsHashtable` is 7.0+, so neither exists on the 5.1 leg of the declared compatibility target. This
  conflicts with `.claude/rules/powershell.md:24` ("compatible with PowerShell 7+"). Resolving the
  actual supported floor and selecting a guard that works on it is the primary research question; a
  `-DateKind`-based guard may be unavailable on the declared floor.
- **Already satisfied.** The `if ($result)` truthiness hazard is pinned by
  `tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1:87-108` (asserts
  `$result['conflict']` is `$false` while `[bool]$result` is `$true`, both halves in one `It`
  deliberately) and its companion at lines 110-118 (asserts the comment-based help documents the
  divergence). The warning text at `.claude/lib/blast-radius/BlastRadius.psm1:432-441` is present.
  This is a verification-only item; no new test unless a specific uncovered gap is identified and
  stated.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: the fail-fast import guard on the selected `.claude/lib/**` module scope,
      and the date-coercion guard at the checkpoint parse site
      (`OrchestratorState.psm1:175`), plus whichever of `HookPayload.psm1:262` and
      `DiscoveryValidation.psm1:338` fall inside the justified boundary. Line coverage >= 85% per
      `.claude/rules/quality-tiers.md`; Pester measures no branch coverage, so no branch gate applies.
- [ ] Integration scenario to retest:
      `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
      (lines 101-126) asserts every repository `.claude/**` file, excluding `settings.local.json` and
      the `.claude/agent-memory/**` subtree, is byte-identical to its copy under
      `extensions/drm-copilot/resources/claude-customizations/.claude/**`. The bundle currently mirrors
      all 36 lib files. Every `.claude/**` edit needs the identical edit in the bundle copy in the same
      change, which doubles the production file count and drives the batching.
- [ ] Manual verification notes: confirm the existing truthiness test pair covers the hazard before
      concluding item 3 needs no new test.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch
