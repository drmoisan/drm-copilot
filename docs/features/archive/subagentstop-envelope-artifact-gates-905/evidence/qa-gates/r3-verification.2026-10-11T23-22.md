# R3 verification: prd-feature and task-researcher hooks and mirrors (plan [P9-T9], AC-31, AC-32, issue #905)

Timestamp: 2026-10-11T23-22
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/r3-check.ps1 -Hook .claude/hooks/validate-prd-feature-output.ps1 -BaseSha 1011d98d7830aea7e53511a972b0868b323d5a44; sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/r3-check.ps1 -Hook .claude/hooks/validate-task-researcher-output.ps1 -BaseSha 1011d98d7830aea7e53511a972b0868b323d5a44; sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/r-hash.ps1
EXIT_CODE: 0
Output Summary: for each hook: BASE-OLD-PATTERN-COUNT: 1, CURRENT-NEW-PATTERN-COUNT: 1, CURRENT-OLD-PATTERN-COUNT: 0, R3-ONLY-CHANGE: YES, and R3-PATTERN lines `entire worktree. | True`, `the whole worktree, all directories. | True`, `entire repository | True`, `the hooks folder | False`. Source and mirror pairs for `validate-prd-feature-output.ps1` and `validate-task-researcher-output.ps1` are `equal` under SHA256 (`Get-FileHash`) and `git hash-object` (r-hash also lists the other two W-HOOKS pairs, also equal). The eight R3 rows passed in [P5-T6] (`evidence/regression-testing/conversion-prd-feature.2026-10-11T23-07.md`, four rows) and [P9-T5] (`evidence/regression-testing/conversion-task-researcher.2026-10-11T23-22.md`, four rows). MERGE_BASE = 1011d98d7830aea7e53511a972b0868b323d5a44.

```text
HOOK: .claude/hooks/validate-prd-feature-output.ps1
BASE: 1011d98d7830aea7e53511a972b0868b323d5a44
BASE-OLD-PATTERN-COUNT: 1
CURRENT-NEW-PATTERN-COUNT: 1
CURRENT-OLD-PATTERN-COUNT: 0
R3-ONLY-CHANGE: YES
R3-PATTERN: entire worktree. | True
R3-PATTERN: the whole worktree, all directories. | True
R3-PATTERN: entire repository | True
R3-PATTERN: the hooks folder | False
```

```text
HOOK: .claude/hooks/validate-task-researcher-output.ps1
BASE: 1011d98d7830aea7e53511a972b0868b323d5a44
BASE-OLD-PATTERN-COUNT: 1
CURRENT-NEW-PATTERN-COUNT: 1
CURRENT-OLD-PATTERN-COUNT: 0
R3-ONLY-CHANGE: YES
R3-PATTERN: entire worktree. | True
R3-PATTERN: the whole worktree, all directories. | True
R3-PATTERN: entire repository | True
R3-PATTERN: the hooks folder | False
```

```text
PAIR: .claude/hooks/validate-discovery-artifact-gate.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1 | sha256 91908B28A9FC610F9C776F63BB062E03FC628BD857A8EF48F20D6A9875B77976 / 91908B28A9FC610F9C776F63BB062E03FC628BD857A8EF48F20D6A9875B77976 | equal | git cae4cc6e21a50d101e32887c2dbecb0f32942cf8 / cae4cc6e21a50d101e32887c2dbecb0f32942cf8 | equal
PAIR: .claude/hooks/validate-pr-author-output.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-pr-author-output.ps1 | sha256 AC2E131D17D8E975CEAFF8F5FC38C02035157F0B8A20479A143DCE49511F8502 / AC2E131D17D8E975CEAFF8F5FC38C02035157F0B8A20479A143DCE49511F8502 | equal | git 78ac52ff9fa5fe153aae86f3210b8f10eabd27db / 78ac52ff9fa5fe153aae86f3210b8f10eabd27db | equal
PAIR: .claude/hooks/validate-prd-feature-output.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-prd-feature-output.ps1 | sha256 88C16F39D3B40A293F19C49B6047518CD6BF5B61113CCE0F1AE74E44AE21CFC2 / 88C16F39D3B40A293F19C49B6047518CD6BF5B61113CCE0F1AE74E44AE21CFC2 | equal | git 9f3ff43cf9c714d535690287f51df6eacd25d6b2 / 9f3ff43cf9c714d535690287f51df6eacd25d6b2 | equal
PAIR: .claude/hooks/validate-task-researcher-output.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1 | sha256 813C3E375C3194F8FD759EE4B3048790AEECD5141EE6F6CB68EF3F59D356EA32 / 813C3E375C3194F8FD759EE4B3048790AEECD5141EE6F6CB68EF3F59D356EA32 | equal | git 1998a9309d111ef73ecda877e4afdcd424eb1ad6 / 1998a9309d111ef73ecda877e4afdcd424eb1ad6 | equal
```
