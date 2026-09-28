# B4 PoshQC Batch Toolchain ([P4-T8])

Timestamp: 2026-09-27T07-18
Command: sh <SCRATCHPAD>/x707p1-run.sh x707p4-t8 (fresh process, working directory <WORKSPACE_ROOT>: SHA-256 of every B4 PowerShell file; Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCFormat -Root $root; Invoke-PoshQCAnalyze -Root $root; SHA-256 again)
EXIT_CODE: 0
Output Summary: Final run (pass 2): Formatted: count 0; Already formatted: count 538; analyzer printed `PSScriptAnalyzer passed: no findings under <WORKSPACE_ROOT>`; all three hashes unchanged. Pass 1 reported two analyzer findings in Suite C, which were fixed; [P4-T7] was re-run green before pass 2. This batch writes no mirror.

## Pass 1

Timestamp: 2026-09-27T07-15
EXIT_CODE: 1

- `Formatted: ` count: 0
- `Already formatted: ` count: 538
- Analyzer: threw `PSScriptAnalyzer reported 2 issue(s).`
- Findings, identified by `Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` over the three B4 files (sh <SCRATCHPAD>/x707p1-run.sh x707p4-pssadiag):
  - `tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1:29` PSReviewUnusedParameter (Warning): the parameter `p` has been declared but not used.
  - `tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1:31` PSReviewUnusedParameter (Warning): the parameter `Path` has been declared but not used.
  - The transport and legacy suites reported zero findings.

Hash Delta (pass 1):

| File | Before SHA-256 | After SHA-256 | Mark |
| --- | --- | --- | --- |
| tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 | 5157384270A90D3AA1CFC4803E555941FAC654DF0F5447981C9C95C6EEAB93A0 | 5157384270A90D3AA1CFC4803E555941FAC654DF0F5447981C9C95C6EEAB93A0 | unchanged |
| tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | 91398F084637930422A8A28495B54B77860710FCD2A5D9F938A730EA14B3D95A | 91398F084637930422A8A28495B54B77860710FCD2A5D9F938A730EA14B3D95A | unchanged |
| tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1 | C958063C46FA1AC835087B95CC95F7F5A6126FE27B95C3717136972C82D7D319 | C958063C46FA1AC835087B95CC95F7F5A6126FE27B95C3717136972C82D7D319 | unchanged |

Fix (powershell-typed-engineer standards): the `-FolderExistsCheck` and `-CheckpointReader` seams in Suite C ignore their argument by design (plan section 4.3). Each scriptblock keeps its declared parameter and now discards it explicitly (`$null = $p`, `$null = $Path`), under a one-line comment. Return values are unchanged. The diagnostic was re-run and reported zero findings for all three files. [P4-T7] was then re-run at 2026-09-27T07-16: 121 passed, 0 failed (evidence/qa-gates/b4-scoped-pester.md).

## Pass 2 (final)

Timestamp: 2026-09-27T07-18
EXIT_CODE: 0

- `Formatted: ` count: 0
- `Already formatted: ` count: 538
- Analyzer: PSScriptAnalyzer passed: no findings under <WORKSPACE_ROOT>

Hash Delta:

| File | Before SHA-256 | After SHA-256 | Mark |
| --- | --- | --- | --- |
| tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 | 5157384270A90D3AA1CFC4803E555941FAC654DF0F5447981C9C95C6EEAB93A0 | 5157384270A90D3AA1CFC4803E555941FAC654DF0F5447981C9C95C6EEAB93A0 | unchanged |
| tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | 91398F084637930422A8A28495B54B77860710FCD2A5D9F938A730EA14B3D95A | 91398F084637930422A8A28495B54B77860710FCD2A5D9F938A730EA14B3D95A | unchanged |
| tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1 | 0E349C2258F1492BF333D5212FF64D7E20863F518708A4E3411B24FE38C2F0E9 | 0E349C2258F1492BF333D5212FF64D7E20863F518708A4E3411B24FE38C2F0E9 | unchanged |
