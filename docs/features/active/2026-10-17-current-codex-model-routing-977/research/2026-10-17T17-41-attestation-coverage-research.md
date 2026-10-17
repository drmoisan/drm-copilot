<!-- markdownlint-disable-file -->

# Task Research Notes: Bundled routing-attestation coverage diagnosis (#977)

## Research Executed

### File Analysis

- `.codex/hooks/record-subagent-routing-attestation.ps1` and its bundled counterpart
  - Pure receipt/identity/attestation behavior shares the file with direct persistence, authority-receipt consumption, and command entry. Dot-sourcing returns before command entry.
- `tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1`, `epic-provenance.Tests.ps1`, and `epic-child-launch-attestation.Tests.ps1`
  - Existing baseline executed these 50 tests against the actual bundled hook. The first two invoke hook functions; the third mainly exercises its separate launch-authority helper.
- `tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1`
  - Explicitly excludes `record-subagent-routing-attestation.ps1` because it is a SubagentStart registration. Its process probes exercise PreToolUse hooks, not this hook.
- `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1`
  - Checks registration, packaging, and file contents; does not execute the missed record-hook paths.
- `evidence/baseline/powershell-bundle-coverage.2026-10-17T17-39.md` and executor-produced JaCoCo XML
  - Baseline records actual bundled-file coverage of 103/192 lines (53.6458%). Method counters were inspected read-only; no additional tests were run during this diagnosis.

### Code Search Results

- `record-subagent-routing-attestation|Get-CodexSubagentAttestation|Test-RootEpicReceipt`
  - Only the five suites above reference the hook or invoke its functions in `tests/scripts`.
- `ConvertFrom-SubagentAttestationJson|Get-SubagentAttestationKey|Get-CodexSubagentAttestationFromAuthority|Write-CodexSubagentAttestation`
  - No test directly invokes these functions. The key helper is already indirectly covered.

### External Research

- #githubRepo:"drmoisan/drm-copilot routing attestation Pester coverage"
  - Local repository and executor-generated coverage artifacts inspected; no external repository search or web claim is required for this diagnosis.
- #fetch:https://github.com/drmoisan/drm-copilot/issues/977
  - Parent-supplied issue context defines the migration scope; no additional page retrieval was needed for the local coverage diagnosis.

### Project Conventions

- Standards referenced: research-only assignment; test isolation and no temporary files; actual-file coverage requirements in `execution-environment`.
- Instructions followed: no production/test edits, no duplicated executor runs, no added framework, no source transformation to manufacture coverage.

## Key Discoveries

### Project Structure

| Method | Covered lines | Missed lines |
| --- | ---: | ---: |
| Script body | 5 | 36 |
| `ConvertFrom-SubagentAttestationJson` | 0 | 8 |
| `Get-SubagentAttestationKey` | 3 | 0 |
| `Test-RootEpicReceipt` | 37 | 7 |
| `Get-CodexSubagentAttestation` | 58 | 3 |
| `Write-CodexSubagentAttestation` | 0 | 13 |
| `Get-CodexSubagentAttestationFromAuthority` | 0 | 22 |

85% requires at least 164 of 192 lines, or 61 additional covered lines. Filling all missed JSON/root-receipt/attestation lines adds only 18 lines. The authority wrapper has a small mockable early-return path, but its remaining path opens and updates an exclusive filesystem stream.

### Implementation Patterns

Meaningful additions that require no production change or temporary file:

- JSON parser: optional blank/malformed input returns null; required blank/malformed input throws the named enforcement marker; valid JSON returns parsed identity.
- Root receipt: null receipt, consumed metadata despite `consumed=false`, unsupported persona/entry combination, blank required epic reference, mismatched kickoff, non-run unexpected kickoff, invalid dates/lifetime. Clone a valid in-memory receipt from existing `Get-RootEpicInvocationReceipt` setup and mutate one invariant per case.
- Attestation: missing agent identity throws; mock `Get-CodexAgentProfileAttestation` to throw and verify `routing_valid=false` plus diagnostic propagation. Existing profile mismatch tests already cover positive binding and incorrect model/reasoning.
- Authority wrapper: non-epic start and missing epic receipt delegate to `Get-CodexSubagentAttestation` with null root receipt. Mock `Test-Path` and the delegated function; assert arguments and returned attestation without opening a stream.
- Key semantics: transcript identity takes priority; blank transcript uses agent ID; same identity hashes consistently. These improve behavioral assurance but add no previously missed lines in the baseline.

### Complete Examples

```powershell
Mock Get-CodexAgentProfileAttestation { throw 'profile unavailable' }
# Call Get-CodexSubagentAttestation with a routed payload and in-memory checkpoint.
# Assert routing_valid is false and profile_validation_error contains the cause.
```

This demonstrates an existing command seam; it is a proposed test approach, not newly implemented test code.

### API and Schema Documentation

`Write-CodexSubagentAttestation` directly invokes `[System.IO.Directory]::CreateDirectory` and `[System.IO.File]::Open`, then constructs/disposes its writer. `Get-CodexSubagentAttestationFromAuthority` directly invokes `[System.IO.File]::Open`, reads a root receipt, updates consumption fields, truncates/writes/flushes the same stream. Pester command mocks do not replace those static method calls.

Command entry reads `[Console]::In`, reads checkpoints, invokes git, calls the persistence functions, and uses `exit`. Existing dot-source seams intentionally skip it. Do not claim executing altered source text or AST-extracted blocks measures the original command entry. This diagnosis does not assert that `exit` alone prevents every PowerShell harness; the decisive barriers here are unseamed static persistence and the current source-entry structure.

### Configuration Examples

```text
Current actual bundled-file baseline: 103/192 = 53.6458%
Required minimum at 85%:             164/192
Pure JSON/root/attestation misses:    18 lines
```

### Technical Requirements

**No broader existing suite was found that supplies the missing actual-file execution.** Adding the two content/probe suites cannot improve this hook's coverage. Adding meaningful pure tests can improve coverage and assurance but cannot by itself supply the required 61 additional lines.

**Full persistence coverage cannot be implemented with ordinary in-memory Pester command mocks under the current production API.** A new stream/directory seam, a scope-authorized integration test, or a bounded coverage exception is required for that boundary. No such change or exception is authorized by this research assignment.

## Recommended Approach

Report the existing coverage deficit explicitly. If the parent authorizes additional test work, add only the meaningful pure-function/early-return cases above and measure the real source and bundled files. Retain the full-file denominator. Request a scoped decision on production I/O seams or a bounded coverage exception before claiming the 85% requirement can be satisfied.

Rejected alternatives: additional unrelated suite execution does not cover the missed code; temporary authority files violate isolation policy; replacing static .NET types, rewriting source text, excluding persistence/entry lines, or measuring extracted scriptblocks would change the measurement contract.

## Implementation Guidance

- **Objectives**: improve assurance around unchanged error behavior while identifying the actual barrier to the mandatory whole-file gate.
- **Key Tasks**: parent/executor own any approved test edits and runs; retain initial fail-before coverage; preserve exact tested bundled-file identity; choose a separately authorized solution for persistence coverage.
- **Dependencies**: no new dependency or framework needed for proposed pure tests.
- **Success Criteria**: honest coverage measurements, deterministic tests, and an explicit disposition for unseamed persistence rather than unsupported completion claims.

## Pre-Mortem

- Review checklists: tests added only to increase a number may miss the migrated forced-model branch; retain the existing exact-model epic attestation tests and explain additional invariant cases.
- Coverage: pure cases cannot supply the whole-file minimum; preserve 192-line measurement and record the bounded blocker.
- Mirror parity: root-hook tests do not automatically measure bundled bytes; use the existing executor harness that loads the actual bundled target and preserve source/bundle parity.
- File size: existing hook is below 500 lines; no production expansion is proposed, and any new test file must remain below the limit.
- Test isolation: mocks and environment state can leak; restore mocks/state and run required randomized Pester ordering if tests are added.
- CI-only behavior: direct profile reads and platform-specific paths can differ on Linux; use existing canonical path helpers and in-memory behavior seams.
- Evidence: coverage from helpers or source transformations could be mistaken for bundled coverage; record the actual target path, numerator/denominator, suite selection, and limitations.
