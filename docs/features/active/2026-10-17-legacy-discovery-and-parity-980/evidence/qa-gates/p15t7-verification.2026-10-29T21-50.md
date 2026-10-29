# P15-T7 verification — observational start hooks and payload-attributed stops

Timestamp: 2026-10-29T21-50
Command: sh SCRATCH/issue-980-p15-pssa.sh <P15-T7 file set>; sh SCRATCH/issue-980-p15-mirror.sh; sh SCRATCH/issue-980-pester.sh tests/scripts/claude-lib/discovery-validation; sh SCRATCH/issue-980-pester.sh <22 hook suites listed below>; git grep -c DRM_DISCOVERY -- .claude/lib .claude/hooks .codex/hooks .github/hooks
EXIT_CODE: 0
Output Summary:
- Static stages (Invoke-Formatter check, then PSScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1): 126 files, 0 reformatted, 0 findings. A re-run over the two test files edited during verification gave 2 files, 0 reformatted, 0 findings.
- Mirror: discovery-validation modules and the discovery hooks copied to extensions/drm-copilot/resources (13 bundle files updated).
- Hook suites: 1573 total, 1573 passed, 0 failed after the two fixes below (first run 1572 total, 1 failed).
- Library suites (tests/scripts/claude-lib/discovery-validation): 443 total, 439 passed, 4 failed. The 4 failures are outside the P15-T7 suite set and are owned by later tasks (see Decision 2).
- File size: every file edited by P15-T7 is at or below 500 lines (largest: DiscoveryStart.psm1 at 440, DiscoveryStop.psm1 at 336).

## Hook suites run

tests/scripts/claude-hooks/{discovery-entrypoints,discovery-output,discovery-start,enforce-discovery-artifact-gate.HelperImportFailure,enforce-discovery-artifact-gate,validate-discovery-artifact-gate,discovery-planning-gate,enforce-gate-suites.EpicStateIsolation.Discovery,hook-dependency-failure.Claude,hook-dependency-failure.SpecialCases}.Tests.ps1;
tests/scripts/codex-hooks/{discovery-entrypoints,discovery-output,discovery-start,discovery-pre-tool,discovery-planning-gate,hook-dependency-failure.Codex}.Tests.ps1;
tests/scripts/copilot-hooks/{discovery-entrypoints,discovery-output,discovery-start,discovery-pre-tool,discovery-planning}.Tests.ps1;
tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1.

## Fixes made during verification

1. tests/scripts/copilot-hooks/discovery-pre-tool.Tests.ps1, `binds a Copilot specialist at its first controlled call when the harness supplied no start identity`: the `-Because` argument read `permissionDecisionReason`, which an `allow` decision does not carry, so strict mode threw before the assertion ran. The argument now serializes the whole decision. The assertion is unchanged (decision `allow`, two writes, invocation `started`).
2. tests/scripts/codex-hooks/discovery-start.Tests.ps1: added `observes two prepared invocations as AMBIGUOUS with a non-blocking start output and no attestation write`. This is the per-host case the task requires for Codex. The Claude and Copilot suites already carried theirs.

## Execution decisions

1. Codex start projection. The Codex SubagentStart hook projects the shared `observe` decision as `routing_valid` false and a non-blocking system message at exit 0. The pre-existing Codex model-routing PreToolUse gate still denies a specialist whose start was not attested. That gate is outside this task's file set and is left unchanged, which keeps the Codex path fail-closed and agrees with the gate's own `AMBIGUOUS` and `NO_INVOCATION` denies from P15-T6.
2. Acceptance grep scope. `git grep -c DRM_DISCOVERY -- .claude/lib .claude/hooks .codex/hooks .github/hooks` still reports `.claude/lib/discovery-validation/DiscoveryCapability.psm1:7`. All seven hits are inside `Get-DiscoverySentinelEnvironment`, which P15-T10 deletes. The grep without that file (`.claude/hooks`, `.codex/hooks`, `.github/hooks` and every other `.claude/lib` file) prints no line. The full-scope grep will be re-run and recorded at P15-T10. The same reasoning covers the 4 library-suite failures: 3 sentinel-environment cases in DiscoveryCapability.Tests.ps1 (replaced by P15-T10 under Set P) and 1 manifest-registration case for DiscoveryObservation.psm1 (registered by P15-T8 per its own task text). The P15-T6 commit created that module early as the gate's delegation target.
