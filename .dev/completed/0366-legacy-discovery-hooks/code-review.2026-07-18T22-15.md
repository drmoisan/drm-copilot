# Code Review: legacy-discovery-hooks (#366)

**Review Date:** 2026-07-18
**Reviewer:** feature-review agent (Claude Code)
**Feature Folder:** `docs/features/active/2026-07-17-legacy-discovery-hooks-366`
**Feature Folder Selection Rule:** Selected feature folder suffix (`-366`) matches the branch name issue number (`feature/legacy-discovery-hooks-366`).
**Base Branch:** `origin/epic/legacy-discovery-and-parity-integration` (merge-base `e395efb7cf55953a93088964f10edc4d9dede404`)
**Head Branch:** `feature/legacy-discovery-hooks-366` @ `024cf6290c1a7666eac74aa41e8db99de1036e51`
**Review Type:** Initial review

---

## Executive Summary

This change adds two domain-neutral PowerShell completion-gate hooks (`enforce-discovery-artifact-gate.ps1`, PreToolUse; `validate-discovery-artifact-gate.ps1`, SubagentStop) that invoke an already-merged Python validator CLI (`python -m scripts.dev_tools.validate_discovery_artifacts`) to enforce discovery-artifact schema conformance at write time and at subagent-termination time. Both hooks are registered in `.claude/settings.json` under existing matcher groups. Two mirrored Pester test files (28 tests total) and two mirrored coverage-allowlist edits to `pester.runsettings.psd1` round out the change. Scope is small (2 production files, 2 test files, 1 config-registration edit, 2 mirrored coverage-allowlist edits) and stays within the repository's 2-production-file direct-mode change budget for PowerShell.

**What changed:**
Two new `.ps1` hook files implement a thin-entrypoint pattern: a mockable `Invoke-DiscoveryValidatorExe` wrapper around the validator CLI, a static `Get-DiscoveryArtifactType` path-to-type lookup (explicitly marked as a replaceable `# TODO(#9002)` seam), a `Get-RequiredDiscoveryArtifactDeclaration` fail-open seam for a not-yet-shipped domain-profile config (`# TODO(#9001)`), and a decision/validation function per hook that the entrypoint block calls. `.claude/settings.json` gains two new command entries in already-existing matcher groups (no new matcher group created). Both `pester.runsettings.psd1` copies (canonical and bundled-mirror) add the two new files to the coverage `CodeCoverage.Path` allowlist.

**Top 3 risks:**
1. The two hook files duplicate an identical ~60-line block (`Invoke-DiscoveryValidatorExe`, `Get-DiscoveryArtifactType`, `Get-RequiredDiscoveryArtifactDeclaration`) verbatim. This is a deliberate, documented trade-off against the repo's 2-production-file PowerShell change budget (see `spec.md` "File-count / change budget"), not an oversight, but it does mean any future fix to the shared logic must be applied twice.
2. `Get-DiscoveryArtifactType`'s static path-lookup table is an explicitly temporary `# TODO(#9002)` seam tied to a schema-versioning convention owned by a separate, not-yet-shipped feature. It is documented and tested (fail-open on no match), but it is real technical debt that must be revisited when #9002 ships.
3. Branch coverage cannot be numerically verified for either new file because this repository's PoshQC/Pester coverage pipeline does not emit `BRANCH` counters at all (a pre-existing, repo-wide tooling gap, not introduced by this change).

**PR readiness recommendation:** **Go** — the implementation is small, well-tested, matches its own spec precisely, and the one architectural trade-off (wrapper duplication) is explicitly justified against a documented repository constraint.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `.claude/hooks/enforce-discovery-artifact-gate.ps1`, `.claude/hooks/validate-discovery-artifact-gate.ps1` | `Invoke-DiscoveryValidatorExe`, `Get-DiscoveryArtifactType`, `Get-RequiredDiscoveryArtifactDeclaration` (both files) | Identical ~60-line block duplicated verbatim across both hook files rather than factored into a shared module. | No action required now; track as a follow-up if a third discovery-hook file is ever added (would tip the change over the 2-production-file budget and justify a shared-helper extraction). | Documented, deliberate trade-off against `.claude/rules/powershell.md`'s 2-production-file direct-mode change budget, explicitly called out in `spec.md`'s "File-count / change budget" section. | `spec.md` lines 234-240; `git diff --name-status` confirms exactly 2 production `.ps1` files were added, no third shared file. |
| Info | `.claude/hooks/enforce-discovery-artifact-gate.ps1` | `Get-DiscoveryArtifactType`, lines 54-97 | Static path-prefix lookup table is a temporary seam pending #9002's schema-versioning convention. | No action required in this feature; flag for follow-up when #9002 ships, per the existing `# TODO(#9002)` marker. | Explicitly documented as an "open seam" in `spec.md` Constraints & Risks; not a defect, a scoped placeholder. | `.claude/hooks/enforce-discovery-artifact-gate.ps1:65-68`, `.claude/hooks/validate-discovery-artifact-gate.ps1:68-71`. |
| Info | `artifacts/pester/powershell-coverage.xml` (tooling, not this feature's code) | N/A | Branch coverage is not emitted by the repo's PoshQC/Pester JaCoCo pipeline for any file, so branch-coverage compliance cannot be numerically verified for either new hook file. | No action required within this feature's scope; this is a repo-wide tooling gap. | Independently confirmed this session: no `BRANCH` counter type appears anywhere in the regenerated coverage XML. Also documented in the P0-T9 baseline and in feature #365's baseline evidence. | `artifacts/pester/powershell-coverage.xml` (regenerated this session); `docs/features/active/2026-07-17-legacy-discovery-hooks-366/evidence/baseline/pester-baseline.2026-07-18T00-15.md`. |
| Nit | `.claude/hooks/enforce-discovery-artifact-gate.ps1` | `Invoke-DiscoveryArtifactGateDecision`, lines 146-160 | The "no `file_path`" and "empty `ToolInputRaw`" branches both return the identical allow-hashtable literal, duplicated three times within the same function (lines 147, 159, 168, 173, 179, 195 all construct the same `[ordered]@{ hookSpecificOutput = ... 'allow' }` literal). | Could be factored into a small local helper (e.g., `$allowDecision = { [ordered]@{...} }`) to reduce repetition, purely cosmetic. | Minor readability/DRY nit; does not affect correctness or test coverage. | `.claude/hooks/enforce-discovery-artifact-gate.ps1:147,159,168,173,179,195`. |

No Blocker or Major findings.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The thin-entrypoint pattern is applied consistently: all decision logic lives in named, independently testable functions (`Invoke-DiscoveryArtifactGateDecision`, `Invoke-DiscoveryArtifactGateValidation`); only the code below the dot-source guard touches `$env:`, `ConvertTo-Json`, or `exit`. This exactly matches the pattern documented in `spec.md`'s "Decision functions (thin-entrypoint pattern)" section and enables the Pester tests to dot-source the file and exercise the decision functions directly.
- The `Invoke-DiscoveryValidatorExe` wrapper follows the repository's established wrapper-seam convention (`.claude/rules/powershell.md`, "Design Seams (Minimal DI)", option 1), modeled explicitly on `Invoke-GitExe`. Its parameter name (`ValidatorArgs`, not `Args`) avoids the automatic-variable collision the rule warns about.
- Fail-open defaults for both not-yet-shipped upstream dependencies (`# TODO(#9001)` domain profile, `# TODO(#9002)` artifact-type lookup) are implemented as narrow, injectable seams (`ProfileReader` scriptblock parameter, `RequiredArtifactReader` scriptblock parameter) rather than hardcoded assumptions, and each fail-open path has a dedicated regression test.
- The two-hook (PreToolUse + SubagentStop) design is well-motivated in `spec.md`: PreToolUse alone cannot catch non-`Write`/`Edit`-produced artifacts (e.g., a `Bash` command writing JSON) or pre-existing non-conforming state; SubagentStop alone forfeits early, per-write feedback. This mirrors an existing pattern already in the repo (`enforce-completion-consistency.ps1` + `validate-orchestrator-output.ps1`).
- `Edit`-call handling (`enforce-discovery-artifact-gate.ps1`, lines 162-169) makes a deliberate, well-reasoned trade-off: `Edit` calls carry only a partial patch, not full content, so validating them at PreToolUse time would require reconstructing the post-edit file; instead, `Edit` calls are allowed unconditionally and the SubagentStop gate is documented as the authoritative backstop. This is called out explicitly in both the code comment and `spec.md`, and is covered by a dedicated test.

#### API and safety notes

- `Invoke-DiscoveryValidatorExe`'s `[OutputType([hashtable])]` and consistent `@{ ExitCode = ...; Output = ... }` return shape give callers a stable, typed contract.
- `Get-DiscoveryArtifactType`'s regex-based prefix match (`"(^|/)$([regex]::Escape($prefix))"`) correctly escapes the literal prefix before embedding it in a regex, avoiding a regex-injection-style bug from unescaped special characters in path segments.
- Both hooks correctly normalize path separators (`$Path -replace '\\', '/'`) before matching, making the lookup work identically on Windows and POSIX-style paths.
- No `ShouldProcess`/`SupportsShouldProcess` implementation is present in either hook — correctly, since both hooks are documented as read-only validation gates (`.NOTES: Read-only validation gate`) with no state-changing side effects of their own.

#### Error handling and logging

- `enforce-discovery-artifact-gate.ps1`'s entrypoint uses `try { ... } catch { Write-Error $_; exit 1 }` around the decision call, and `Invoke-DiscoveryArtifactGateDecision` throws a specific, informative message on malformed JSON (`"enforce-discovery-artifact-gate hook received malformed JSON in CLAUDE_TOOL_INPUT: $_"`), matching the `Write-Error`/`exit 1` convention documented in `spec.md`.
- `validate-discovery-artifact-gate.ps1` uses a distinct convention appropriate to its different I/O contract: `Invoke-DiscoveryArtifactGateValidation` returns an `{ Ok; Message }` result rather than throwing, and the entrypoint maps `Ok = $false` to `Write-Error $result.Message; exit 1`. This is intentional (per `spec.md`'s Inputs/Outputs section) and is not an inconsistency between the two files — each hook's error-surfacing convention matches its own documented I/O contract.
- Both `DISCOVERY_ARTIFACT_GATE_BLOCKED:`-prefixed messages embed the validator's captured output verbatim, satisfying the spec's requirement that the subagent/tool-caller receive the validator's specific failure reason rather than a generic message.
- No broad catch-all exception handling is present; the single `catch` block in `enforce-discovery-artifact-gate.ps1` immediately surfaces the error via `Write-Error` and exits non-zero, consistent with the repository's "fail fast and explicitly" policy.

---

## Test Quality Audit

Both new test suites were independently re-run this session (not merely re-read) via `Invoke-PoshQCTest` and produced 15/15 and 13/13 passing tests respectively, with 0 failures, consistent with the executor's reported figures.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1` — exercises `Invoke-DiscoveryArtifactGateDecision`, `Get-DiscoveryArtifactType`, `Get-RequiredDiscoveryArtifactDeclaration`, and a genuine child-process end-to-end smoke test of the full script. All 15 tests independently re-run and passing.
- `tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1` — exercises `Invoke-DiscoveryArtifactGateValidation`, `Find-DiscoveryArtifactReference`, `Get-RequiredDiscoveryArtifactDeclaration`, and a genuine child-process end-to-end smoke test. All 13 tests independently re-run and passing.
- `artifacts/pester/powershell-coverage.xml` (regenerated this session) — confirms 87.27%/87.93% new-file line coverage, matching the executor's reported figures exactly.
- `docs/features/active/2026-07-17-legacy-discovery-hooks-366/evidence/other/ac-verification.2026-07-18T00-30.md` — traces each of the 5 AC items to specific line numbers in the two hook files; spot-checked against the actual source this session and found accurate.

### Quality assessment prompts

- **Determinism:** No wall-clock, network, or filesystem-temp-file dependency in any unit-level test. `Invoke-DiscoveryValidatorExe` is mocked for every scenario except the two genuine end-to-end child-process tests per file, which are process-boundary smoke tests (an established pattern already used elsewhere in this repo's hook test suite), not flaky external dependencies.
- **Isolation:** Each `It` targets exactly one behavior with a clear, scenario-named `Context` grouping.
- **Speed:** Full 1338-test suite (including these 28 new tests) completed in 51.53s in this session's independent run — no evidence of slow tests among the new suites.
- **Diagnostics:** Assertions use specific `Should` matchers (`-BeLike 'DISCOVERY_ARTIFACT_GATE_BLOCKED:*'`, `-Match ([regex]::Escape(...))`, `-Invoke ... -Times 1 -Exactly`) that would produce actionable failure messages if a regression were introduced.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No credentials, tokens, or hardcoded paths outside the documented validator-module invocation form. |
| No unsafe subprocess or command construction | ✅ PASS | `& python -m scripts.dev_tools.validate_discovery_artifacts @ValidatorArgs 2>&1` splats an array parameter into a fixed executable name; no string concatenation or shell interpolation of untrusted input into a command line. |
| Input validation at boundaries | ✅ PASS | Both entrypoints validate/guard `$env:CLAUDE_TOOL_INPUT`/`$env:CLAUDE_HOOK_INPUT` for empty/absent/malformed-JSON cases before any further processing, with explicit, tested branches for each condition. |
| Error handling remains explicit | ✅ PASS | See "Error handling and logging" above; no silent swallowing of errors in either hook. |
| Configuration / path handling is safe | ✅ PASS | `Get-DiscoveryArtifactType` regex-escapes path-segment literals before embedding them in a match pattern (see "API and safety notes" above), preventing regex-metacharacter injection from attacker-influenced `file_path` values. |

---

## Research Log

No external research was required for this review. All verification was performed by direct inspection of the branch diff, direct execution of the repository's own toolchain (PoshQC format/analyze/test via PowerShell module functions; `python -m scripts.dev_tools.validate_evidence_locations`; `python -m scripts.dev_tools.pr_context.collector`), and direct reading of the feature folder's `issue.md`/`spec.md`/`user-story.md`/`plan.2026-07-17T14-38.md`/evidence artifacts.

---

## Verdict

The implementation is small, focused, and closely tracks its own specification. Every design decision that might otherwise look like a compromise (duplicated wrapper functions across two files, a static path-lookup seam, unconditional-allow on `Edit` calls) is explicitly documented and justified in `spec.md` against a real repository constraint (the 2-production-file PowerShell change budget) or a real upstream dependency gap (#9001/#9002 not yet shipped), and each such decision is covered by a dedicated regression test. No Blocker or Major findings were identified. The findings recorded above are Info/Nit-level observations for future maintainers, not corrective actions required before merge.

This change is ready for normal PR flow.
