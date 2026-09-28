# Final item-2 prohibited-mechanism verification — issue #598

Timestamp: 2026-08-30T02-40
Task: [P10-T13]

Command:
1. `pwsh -NoProfile -Command "@(Get-ChildItem -Path '.claude/lib' -Filter '*.psm1' -File -Recurse | Select-String -SimpleMatch -Pattern '-DateKind').Count"`
2. `pwsh -NoProfile -Command "@(Get-ChildItem -Path '.claude/lib/orchestrator-state' -Filter '*.psm1' -File | Select-String -SimpleMatch -Pattern 'MinimumPowerShellVersion').Count"`
3. `pwsh -NoProfile -Command "@(Get-ChildItem -Path '.claude/lib/orchestrator-state' -Filter '*.psm1' -File | Select-String -SimpleMatch -Pattern 'ToString(').Count"`
4. `pwsh -NoProfile -Command "@(Get-ChildItem -Path 'extensions/drm-copilot/resources/claude-customizations/.claude/lib' -Filter '*.psm1' -File -Recurse | Select-String -SimpleMatch -Pattern '-DateKind').Count"`
5. `pwsh -NoProfile -Command "@(Get-ChildItem -Path 'extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state' -Filter '*.psm1' -File | Select-String -SimpleMatch -Pattern 'MinimumPowerShellVersion').Count"`
6. `pwsh -NoProfile -Command "@(Get-ChildItem -Path 'extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state' -Filter '*.psm1' -File | Select-String -SimpleMatch -Pattern 'ToString(').Count"`

Commands 4 through 6 are commands 1 through 3 with `.claude/lib` replaced by
`extensions/drm-copilot/resources/claude-customizations/.claude/lib`, so the bundle mirrors are
checked on the same scopes as the repository tree.

EXIT_CODE: 0

All six commands exited 0.

Output Summary:

The six printed integers, in command order:

| # | Scope | Token | Printed |
| --- | --- | --- | --- |
| 1 | `.claude/lib` (recursive) | `-DateKind` | 0 |
| 2 | `.claude/lib/orchestrator-state` | `MinimumPowerShellVersion` | 0 |
| 3 | `.claude/lib/orchestrator-state` | `ToString(` | 0 |
| 4 | bundle `.claude/lib` (recursive) | `-DateKind` | 0 |
| 5 | bundle `.claude/lib/orchestrator-state` | `MinimumPowerShellVersion` | 0 |
| 6 | bundle `.claude/lib/orchestrator-state` | `ToString(` | 0 |

## What the counts establish

Each of the three tokens corresponds to a mechanism `spec.md` prohibits under
"Prohibited mechanisms" and under "Decision: the PowerShell floor is not raised":

- `-DateKind` is the PowerShell 7.5 `ConvertFrom-Json` parameter that would sit above the declared
  7.4 floor. A count of 0 across both trees confirms it was not adopted anywhere in this feature.
- `MinimumPowerShellVersion` is the version-constant name used by
  `.claude/lib/discovery-validation/DiscoveryValidation.psm1`. A count of 0 across the
  orchestrator-state scope in both trees confirms no version constant or version guard was added to
  the orchestrator-state modules.
- `ToString(` is the shape a post-parse `[datetime]`-to-string repair would take. A count of 0 across
  the orchestrator-state scope in both trees confirms no such repair was introduced.

The three tokens each stood at zero occurrences in these scopes before the change, recorded in the
plan's verified-tree-facts table and in `qa-gates/batch-B02-gate.2026-08-29T20-30.md:74-77`. A
non-zero result here could therefore only have been introduced by this feature, which is what makes
the assertion able to fail.

The scope in command 1 and command 4 is `.claude/lib` recursively, so it covers all 28 modules
including the 28th, `.claude/lib/requirements/GeneratedDocumentCounters.psm1`, and its bundle mirror.

## Acceptance evaluation

- All six printed integers are `0`.

The acceptance condition holds.
