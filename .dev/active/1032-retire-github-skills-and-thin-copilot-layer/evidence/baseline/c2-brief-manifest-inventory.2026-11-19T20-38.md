# C2 Brief and Manifest Inventory ([P0-T2])

Timestamp: 2026-11-19T20-38
Plan: remediation-plan.2026-11-19T19-58.md
Command: git diff <IMB> origin/epic/shared-agent-harness-layer-integration -- <both RETIRED-BRIEF-COPIES>; Grep of each fact token over every execution-environment/SKILL.md in the working tree; git diff --no-index -U0 .claude/skills/execution-environment/SKILL.md <each retired working-tree copy>; git hash-object <four REMAINING-BRIEF-COPIES>; git diff -U0 <IMB> origin/epic/shared-agent-harness-layer-integration -- <three incoming pack manifests>; Grep of the saved INCOMING-DELTA for docs/engineering/process-reductions/; read of the greatest ledger-region-map.*.md
EXIT_CODE: 0
Output Summary: the incoming side added three facts to the retired brief copies, and each is present in all four remaining copies; no incoming wording states six copies or names RETIRED-PATH; the four copies share one hash; the incoming Copilot core.json adds one entry, which is retired, and removes none; LedgerRegion: none.

State: merge in progress (P0-T1); working tree read after the merge stopped.

## (a) Facts added or changed by the incoming side in RETIRED-BRIEF-COPIES

The incoming diff of each retired copy holds the same three changes (the source copy and the Copilot bundle copy were byte-identical on the incoming side apart from their pre-existing six-copy wording).

| # | Section heading | Short token | PresentInFour |
| --- | --- | --- | --- |
| 1 | `## MCP Surfaces Run the Installed Extension` | `The push-down integration tools (#1051` (new bullet after the docs-tools bullet) | yes |
| 2 | `## CI Shape and Required Checks` | `Destination CI data (#1050)` (new bullet after the refresh rule) | yes |
| 3 | `## Coverage and File-Size Gates` | `except under the vendored push-down exception` (changed first bullet, #1049) | yes |

Evidence: each token occurs once in each of `.agents/skills/execution-environment/SKILL.md`, `.claude/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md` (3 matches per file). A `--no-index` comparison of the `.claude` copy with each retired working-tree copy differs only in the branch's own copy-count statements (S1 to S5: four versus six), so no further incoming fact is missing.

## (b) Six-copy wording and retired-path names

SixCopyWording: none

- No incoming addition, in the four copies or in the incoming retired copies, states six copies or names RETIRED-PATH. The only six-copy lines in the incoming retired copies are the pre-existing S1 to S5 source wording, which the deletion of those copies removes.
- The two remaining "six" tokens in the four copies are unrelated to copy counts (`the six artifact hooks`, `six shards since issue #1190`).

## (c) Hash of each of the four working-tree copies

| Copy | git hash-object |
| --- | --- |
| `.agents/skills/execution-environment/SKILL.md` | a566b17e4fb95bde750603ccf1728eeb7ace83d1 |
| `.claude/skills/execution-environment/SKILL.md` | a566b17e4fb95bde750603ccf1728eeb7ace83d1 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md` | a566b17e4fb95bde750603ccf1728eeb7ace83d1 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md` | a566b17e4fb95bde750603ccf1728eeb7ace83d1 |

## (d) core.json and other pack manifests

`extensions/drm-copilot/resources/customizations/pack-manifests/core.json`, incoming relative to the pre-merge IMB:

| Change | Entry | Retired |
| --- | --- | --- |
| added | `.github/skills/push-down-integration/SKILL.md` | yes (IncomingRetiredAdds) |

Removed entries: none. Other incoming changes to the file: none.

Other pack manifests in INCOMING-DELTA (outside COPILOT-MANIFESTS, auto-merged, no retired entry):

- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`: added `.claude/skills/push-down-integration/SKILL.md`.
- `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/shared.json`: added `.agents/skills/push-down-integration/SKILL.md` and `.agents/skills/push-down-integration/references/standard.md`.

No other COPILOT-MANIFESTS file (`csharp.json`, `powershell.json`, `python.json`, `typescript.json`) is in INCOMING-DELTA.

## (e) Ledger

- INCOMING-DELTA files under `docs/engineering/process-reductions/`: none.
- The sections of (a) are not REGION-MAP regions (the region map lists the S2, S4 and S5 statements of the brief, in `## Preflight Defect Classes the Validator Cannot See` and `## Contract Tests That Pin Mirrored Files`); (b) has no item.

LedgerRegion: none
