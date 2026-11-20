# PoshQC Pester Test Final-QC Evidence

- Timestamp: 2026-06-21T12-06
- Issue: #221
- Task: [P2-T3]

## Command

```
mcp__drm-copilot__run_poshqc_test
```

- Scan folders: scripts/dev-tools, tests/scripts/dev-tools
- EXIT_CODE: 0

Supplemental targeted coverage measurement (per-file numeric coverage; the MCP gate above remains authoritative for pass/fail):

```
Invoke-Pester -Configuration (
  Run.Path = tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1;
  CodeCoverage.Path = scripts/dev-tools/Invoke-FullRelease.ps1;
  CodeCoverage.OutputFormat = JaCoCo
)
```

- EXIT_CODE: 0
- JaCoCo output: artifacts/pester/fullrelease-postchange-coverage.xml

## Output Summary

- MCP test run: `ok: true`. All tests passed. Full suite: 319 tests, 0 failures, 0 errors (one more
  test than the 318 baseline, the new push-failure negative-path test). Invoke-FullRelease suite:
  22 tests, 0 failures, 0 errors.
- Post-change per-file coverage for `scripts/dev-tools/Invoke-FullRelease.ps1`:
  - LINE coverage: 92.11% (covered 70, missed 6, total 76).
  - INSTRUCTION coverage: 89.22% (covered 91, missed 11, total 102).
  - METHOD coverage: 62.50% (covered 5, missed 3, total 8).
- Branch coverage: Pester's coverage model does not emit a distinct JaCoCo BRANCH counter.
  Instruction coverage (89.22%) is the closest available decision-path-discriminating metric.
  LINE coverage 92.11% exceeds the >= 85% threshold.
- The 11 missed instructions are all inside the external wrapper-seam bodies
  (`Invoke-GitExe`/`Invoke-NpmExe`/`Invoke-GhExe`, lines 69-70, 88-89, 107-108). These are the
  intentionally-mocked external executable boundaries per the wrapper-seam isolation policy and
  carry no decision logic. None are part of the inserted push step.

## Changed-Line Coverage (inserted push step, lines 248-252)

All inserted push-step lines are covered:
- line 248 `$push = Invoke-GitExe -GitArgs @('push', '-u', 'origin', $branchName)` — covered (0 missed instructions).
- line 249 `if ($push.ExitCode -ne 0) {` — covered (0 missed instructions).
- line 250 `Write-StderrLine -Message "Failed to push release branch ..."` — covered (0 missed instructions).
- line 251 `return 1` — covered (0 missed instructions).
- line 252 `}` — closing brace, no instructions.

Both the success path (updated "bumps both manifests and opens a PR against main" test) and the
failure path (new "returns 1 and does not open a PR when 'git push -u origin <branch>' fails" test)
exercise the inserted step. No coverage regression on changed lines.

## Toolchain Re-run After Documentation Edit

The `.DESCRIPTION` comment block in `scripts/dev-tools/Invoke-FullRelease.ps1` was updated to include
the new push step (step 5) and renumber the PR step (step 6) so the documentation matches the new
behavior (spec.md acceptance criterion: "Docs/config references updated to match the new behavior").
This is a comment-only edit. The full toolchain loop was re-run: format `ok: true`, analyze
`ok: true` (0 diagnostics), test `ok: true` (319 tests, 0 failures). Comments are not instrumented,
so the per-file coverage figures above are unchanged. File length: 272 lines (under the 500-line limit).
