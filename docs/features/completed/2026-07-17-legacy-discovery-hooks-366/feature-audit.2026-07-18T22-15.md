# Feature Audit: legacy-discovery-hooks (#366)

**Audit Date:** 2026-07-18
**Feature Folder:** `docs/features/active/2026-07-17-legacy-discovery-hooks-366`
**Base Branch:** `origin/epic/legacy-discovery-and-parity-integration`
**Head Branch:** `feature/legacy-discovery-hooks-366` @ `024cf6290c1a7666eac74aa41e8db99de1036e51`
**Work Mode:** `full-feature` (per `issue.md` `- Work Mode: full-feature`)
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `origin/epic/legacy-discovery-and-parity-integration` (commit `26c24f861594922902b43fd8e04637304f210690`)
- **Head branch/commit:** `feature/legacy-discovery-hooks-366` (commit `024cf6290c1a7666eac74aa41e8db99de1036e51`)
- **Merge base:** `e395efb7cf55953a93088964f10edc4d9dede404`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (regenerated this session)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt` (regenerated this session)
  - Feature evidence: `docs/features/active/2026-07-17-legacy-discovery-hooks-366/evidence/**`
  - Additional evidence: direct source inspection of `.claude/hooks/enforce-discovery-artifact-gate.ps1`, `.claude/hooks/validate-discovery-artifact-gate.ps1`, both Pester test files, `.claude/settings.json`, both `pester.runsettings.psd1` copies; independently regenerated `artifacts/pester/powershell-coverage.xml` and `artifacts/pester/pester-junit.xml`
- **Feature folder used:** `docs/features/active/2026-07-17-legacy-discovery-hooks-366` (unversioned; no `v1/`/`v2/` subfolders present)
- **Requirements source:** `spec.md` and `user-story.md` (both have explicit `## Acceptance Criteria` sections; `full-feature` work mode requires both per the acceptance-criteria-tracking skill)
- **Work mode resolution note:** `issue.md` line 11 reads `- Work Mode: full-feature`, an explicit, well-formed marker — no fail-closed default was needed.
- **Scope note:** PR context artifacts (`artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt`) were missing at session start and were regenerated via `poetry run python -m scripts.dev_tools.pr_context.collector --base origin/epic/legacy-discovery-and-parity-integration --head HEAD`. The local `epic/legacy-discovery-and-parity-integration` branch ref was stale (12 commits behind `origin/`) and was rejected in favor of the freshly fetched `origin/` ref, per `pr-base-branch-merge-base` guardrails against defaulting to a stale local candidate.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-07-17-legacy-discovery-hooks-366/spec.md` — primary source (`## Acceptance Criteria` section)
- `docs/features/active/2026-07-17-legacy-discovery-hooks-366/user-story.md` — co-primary source (`## Acceptance Criteria` section)

### From spec.md

1. One or more PowerShell completion-gate hooks enforce discovery-artifact completion gates by invoking the discovery validators.
2. Hooks follow canonical PreToolUse/SubagentStop I/O conventions and the dot-source guard.
3. Hooks are registered in `.claude/settings.json` under the appropriate event with the standard command form.
4. Hooks are domain-neutral (no domain-specific identifiers in source, comments, or messages).
5. Pester tests are mirrored at `tests/scripts/claude-hooks/<name>.Tests.ps1`.

### From user-story.md

1. One or more PowerShell completion-gate hooks enforce discovery-artifact completion gates by invoking the discovery validators.
2. Hooks follow canonical PreToolUse/SubagentStop I/O conventions and the dot-source guard.
3. Hooks are registered in `.claude/settings.json` under the appropriate event with the standard command form.
4. Hooks are domain-neutral (no domain-specific identifiers in source, comments, or messages).
5. Pester tests are mirrored at `tests/scripts/claude-hooks/<name>.Tests.ps1`.

Both files carry identical AC wording (`spec.md`'s AC section explicitly states "Traced 1:1 to `issue.md`'s Acceptance Criteria"), so this audit evaluates the 5 criteria once and applies the result to both sources.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | One or more PowerShell completion-gate hooks enforce discovery-artifact completion gates by invoking the discovery validators. | PASS | `.claude/hooks/enforce-discovery-artifact-gate.ps1:182` (`Invoke-DiscoveryValidatorExe -ValidatorArgs @($artifactType, $filePath)`) and `.claude/hooks/validate-discovery-artifact-gate.ps1:216` (`Invoke-DiscoveryValidatorExe -ValidatorArgs @($artifactType, $reference)`), both routing to `& python -m scripts.dev_tools.validate_discovery_artifacts @ValidatorArgs 2>&1`. Independently confirmed by direct source read this session. | `Read .claude/hooks/enforce-discovery-artifact-gate.ps1`; `Read .claude/hooks/validate-discovery-artifact-gate.ps1` | Neither hook reimplements validator logic; both delegate exclusively to the external CLI. |
| 2 | Hooks follow canonical PreToolUse/SubagentStop I/O conventions and the dot-source guard. | PASS | Dot-source guard present verbatim in both files (`if ($MyInvocation.InvocationName -eq '.') { return }`, `enforce-...ps1:199`, `validate-...ps1:227`). PreToolUse reads `$env:CLAUDE_TOOL_INPUT` and emits `ConvertTo-Json -Compress -Depth 5` to stdout then `exit 0`/`exit 1`; SubagentStop reads `$env:CLAUDE_HOOK_INPUT` and uses `Write-Error`/`exit 1` or `exit 0`. Both patterns match `spec.md`'s "Inputs / Outputs" section exactly. | `Read .claude/hooks/*.ps1` (entrypoint blocks, lines 198-213 and 226-237) | Both test files successfully dot-source their respective production file in `BeforeAll`, confirming the guard functions as intended for testability. |
| 3 | Hooks are registered in `.claude/settings.json` under the appropriate event with the standard command form. | PASS | `PreToolUse` → matcher `"Write|Edit"` gains `{"type":"command","command":"pwsh -NoProfile -File .claude/hooks/enforce-discovery-artifact-gate.ps1"}` as the last entry. `SubagentStop` → existing broad generic-agent matcher (`atomic-planner\|atomic-executor\|feature-review\|...`) gains `{"type":"command","command":"pwsh -NoProfile -File .claude/hooks/validate-discovery-artifact-gate.ps1"}`. No new matcher group was created in either case. `.claude/settings.json` independently confirmed to parse as valid JSON. | `python -c "import json; d=json.load(open('.claude/settings.json')); ..."` (this session); `git diff origin/epic/legacy-discovery-and-parity-integration...HEAD -- .claude/settings.json` | Independently parsed the JSON and printed the matcher + command list this session; confirmed both entries land in pre-existing matcher groups, matching the AC's "under the appropriate event ... standard command form" requirement exactly. |
| 4 | Hooks are domain-neutral (no domain-specific identifiers in source, comments, or messages). | PASS | `Grep -pattern 'TaskMaster\|TMW\|Outlook\|VSTO' -i` against both hook files returned zero matches, independently run this session. Both files' own domain-neutrality `It` blocks also assert this and pass. | `Grep pattern="TaskMaster\|TMW\|Outlook\|VSTO" -i` against each hook file (this session, zero matches each) | The static `Get-DiscoveryArtifactType` lookup table names only schema-kind tokens (`profile`, `feature-contract`, `coverage-ledger`, etc.), never domain terms, satisfying the AC's intent beyond the literal grep. |
| 5 | Pester tests are mirrored at `tests/scripts/claude-hooks/<name>.Tests.ps1`. | PASS | `tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1` (190 lines, 15 tests) and `tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1` (171 lines, 13 tests) both exist and dot-source their respective production file. Independently re-run this session: 28/28 pass, 0 failures. | `ls tests/scripts/claude-hooks/*discovery-artifact-gate*`; `Invoke-PoshQCTest -Root . -ScanFolders @('scripts','tests/scripts')` | File-naming convention (`<name>.Tests.ps1` under `tests/scripts/claude-hooks/`) mirrors the established pattern used by every other `.claude/hooks/*.ps1` file's test file in this repository. |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 5 criteria (both `spec.md` and `user-story.md`)
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. When #9002 (schema-versioning convention) ships, revisit `Get-DiscoveryArtifactType`'s static path-prefix lookup table in both hook files (marked `# TODO(#9002)`) and replace it per that feature's shipped convention.
2. When #9001 (domain-profile configuration contract) ships, revisit `Get-RequiredDiscoveryArtifactDeclaration`'s `ProfileReader` default (`{ $null }`, marked `# TODO(#9001)`) to wire in the real domain-profile reader; the current fail-open default should remain the behavior when no profile is present.

---

## Acceptance Criteria Check-Off

Both AC source files already had all 5 criteria checked (`- [x]`) at the start of this review — checked off during plan execution per the executor's `evidence/other/ac-verification.2026-07-18T00-30.md`. This audit independently re-verified all 5 criteria as PASS in both files (see Evaluation table above) and confirms no further check-off action is needed; the existing `[x]` marks in both `spec.md` and `user-story.md` are consistent with this audit's independent findings.

### AC Status Summary

- Source: `docs/features/active/2026-07-17-legacy-discovery-hooks-366/spec.md` and `docs/features/active/2026-07-17-legacy-discovery-hooks-366/user-story.md`
- Total AC items: 5 (per file; identical wording in both files)
- Checked off (delivered): 5 (per file)
- Remaining (unchecked): 0
- Items remaining: None

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-07-17-legacy-discovery-hooks-366/spec.md` | 5 | 5 | 0 | Checkbox-backed; already checked prior to this review; independently re-verified PASS for all 5. |
| `docs/features/active/2026-07-17-legacy-discovery-hooks-366/user-story.md` | 5 | 5 | 0 | Checkbox-backed; already checked prior to this review; independently re-verified PASS for all 5. |

No source-file checkbox change was made by this audit: all 5 criteria were already checked off in both files, and this audit's independent evaluation confirms every checked criterion is in fact PASS on the evidence — no correction (unchecking a criterion that should not have been checked) was needed.
