# Remediation Diff Additive-Only — Command-Exemption Suites (issue #671, R1)

Timestamp: 2026-09-17T10-00
Task: [P5-T3]
Command: `git diff --numstat 79fd5a95c00cd99238b69a3195788206ae96f4cd -- tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`
EXIT_CODE: 0

## Output (verbatim)

```
135	0	tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1
136	0	tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
```

Output Summary: both rows show a removed-line count of 0 (Claude +135/-0, Codex +136/-0) against the merge base. The L3a/L3b command replacements change lines that this branch itself added after the merge base, so relative to `79fd5a95…` the suites stay additive only. No pre-existing assertion was removed or reversed. PASS.
