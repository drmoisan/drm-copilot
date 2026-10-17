# No Python in Hooks

Timestamp: 2026-10-08T19-34
Command: (1) git diff --name-status 991aae0a180a09d504b59bc9460ec4b00b85d11b -- .claude/hooks .codex/hooks ; (2) git status --porcelain --untracked-files=all -- .claude/hooks .codex/hooks ; (3) grep -nE "(^|[[:space:]&|;('\"])(python3?|py|poetry)(\.exe)?([[:space:]]|$)" <the nine PS-PROD paths>
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: The anchored diff lists nine paths, none ending in .py; the porcelain listing is empty (all changes committed). The grep over PS-PROD exits 1 with no output, so no changed hook invokes python, py, or poetry.

Step 1 (anchored diff):

```
M	.claude/hooks/enforce-epic-wave-barrier.ps1
M	.claude/hooks/enforce-feature-folder-order.ps1
M	.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
M	.claude/hooks/enforce-parallel-cohort-barrier.ps1
M	.claude/hooks/enforce-parallel-drift-gate.ps1
M	.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1
A	.claude/hooks/feature-folder-resolution.ps1
M	.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
A	.codex/hooks/feature-folder-resolution.ps1
```

Step 2 (porcelain): empty.

Step 3 (grep): EXIT_CODE 1, no output.
