# P2-T5 — Integration-Branch Reconciliation

- Timestamp: 2026-07-19T07-30
- Command: `git fetch origin epic/legacy-discovery-and-parity-integration`
- EXIT_CODE: 0
- Command: `git merge-base --is-ancestor origin/epic/legacy-discovery-and-parity-integration HEAD`
- EXIT_CODE: 0
- Command: `git ls-tree -d --name-only origin/epic/legacy-discovery-and-parity-integration docs/features/active/`
- EXIT_CODE: 0

## Output Summary

The current branch (`feature/legacy-discovery-documentation-371`) already contains
`origin/epic/legacy-discovery-and-parity-integration`'s HEAD as an ancestor (it was
created from that branch after the fetch-listed features merged). `git ls-tree` against
the fetched integration ref confirms all 13 upstream epic-child feature folders are
present, matching the local working tree exactly:

`legacy-discovery-schemas-359`, `legacy-discovery-config-contract-360`,
`legacy-discovery-validators-361`, `legacy-discovery-init-templates-362`,
`legacy-discovery-analyzer-framework-363`, `legacy-discovery-acceptance-scenarios-364`,
`legacy-discovery-agent-roles-365`, `legacy-discovery-hooks-366`,
`legacy-discovery-skills-367`, `legacy-discovery-reports-368`,
`legacy-discovery-dotnet-vsto-analyzers-369`, `legacy-discovery-mcp-vscode-370`,
`legacy-discovery-publishing-372`.

Cross-checked against `docs/features/epics/legacy-discovery-and-parity/epic-status.md`:
every one of the 13 upstream children shows `merge_status: merged` or `worktree_removed`
(both indicate the child's PR merged into the integration branch). This is a materially
larger set than the three features named in the delegation directive (#367, #370, #372);
in fact every upstream child except this documentation feature itself (#371) has landed.
Because of this, the approach taken was to research real repository state (Poetry script
table, `schemas/discovery/v1/`, `docs/discovery/templates/`, the extension's MCP tool
definitions and VS Code command registrations, the `core.json` pack manifest, and the
`legacy-discovery-publishing` (#372) spec's resolved pack/mirror decision) before
authoring the Phase 1 pages, so Phase 1 was written directly against verified landed state
rather than against the plan's placeholder assumption that all 13 children were absent.
Consequently no Phase-1-authored page required a post-hoc correction during this task;
this artifact documents the verification, not a repair.

## Per-Item Disposition

### Issue-number placeholders

The plan and spec.md were authored against provisional placeholder issue numbers
(`#9001`-`#9012`, `#9014`) because the real upstream issues did not exist at spec-authoring
time. All thirteen have since been filed and merged under their real issue numbers. The
Phase 1 pages were authored using the real issue and feature names only (for example
"the domain-profile configuration-contract feature," "`legacy-discovery-publishing`
(#372)") and do not contain any `#9NNN`-style placeholder (verified: zero matches for
`#9[0-9][0-9][0-9]` across the six pages). Disposition: verified — no placeholder issue
numbers present in the authored pages.

| Placeholder | Real issue | Feature folder | Status |
|---|---|---|---|
| #9001 (domain-profile contract) | #360 | `legacy-discovery-config-contract-360` | merged |
| #9002 (schema versioning) | #359 | `legacy-discovery-schemas-359` | merged |
| #9003 (validators) | #361 | `legacy-discovery-validators-361` | merged |
| #9004 (completion-gate hooks) | #366 | `legacy-discovery-hooks-366` | merged |
| #9005 (init templates) | #362 | `legacy-discovery-init-templates-362` | merged |
| #9006 (analyzer framework) | #363 | `legacy-discovery-analyzer-framework-363` | merged |
| #9007 (agent roles) | #365 | `legacy-discovery-agent-roles-365` | merged |
| #9008 (generic skills) | #367 | `legacy-discovery-skills-367` | merged |
| #9009 (acceptance scenarios) | #364 | `legacy-discovery-acceptance-scenarios-364` | merged |
| #9010 (reports) | #368 | `legacy-discovery-reports-368` | merged |
| #9011 (CLI/MCP/VS Code) | #370 | `legacy-discovery-mcp-vscode-370` | merged |
| #9012 (publishing) | #372 | `legacy-discovery-publishing-372` | merged |
| #9014 (.NET/VSTO analyzers) | #369 | `legacy-discovery-dotnet-vsto-analyzers-369` | merged |

### CLI command names (`running-the-workflow.md`)

Verified against `pyproject.toml` `[tool.poetry.scripts]` (`grep -n "discovery" pyproject.toml`).
All 18 documented `dev.discovery.*` commands and their entry-point module:function targets
match exactly, including the two commands whose module lives outside the
`scripts.dev_tools.discovery` package (`generate-acceptance-scenarios`, and all nine
`validate-*` commands, which route through `scripts.dev_tools.validate_discovery_artifacts`)
and the commands using a non-`main` entry function (`main_dotnet`, `main_vsto`, and the
per-artifact `validate-*` variants). Disposition: verified — no correction required.

### Schema paths (`artifacts-and-schemas.md`)

Verified via `find schemas/discovery -type f`. All seven files present exactly as
documented, matching the seven artifact names in spec.md. Disposition: verified — no
correction required.

### Governed-glob validation claim (`artifacts-and-schemas.md`)

Verified by reading `scripts/dev_tools/json_config.py`: `GOVERNED_GLOBS = ("scripts/**/*.json",
"docs/**/*.json", "examples/**/*.json")`. A repo-root `schemas/**` path is not inside
the default governed-glob scan, contradicting the plan's assumption of a uniform
`$schema`/governed-glob validation path for the schema files themselves. The authored page
states this precisely: `dev.validate-json`'s default scan does not cover `schemas/**`, but
it accepts explicit paths, and the primary/canonical validation path for discovery
artifacts is the dedicated `dev.discovery.validate-*` CLI family
(`scripts/dev_tools/validate_discovery_artifacts.py`), not `dev.validate-json`. Disposition:
verified against real behavior; authored precisely rather than assuming a uniform claim.

### Init-template paths (`domain-profile.md`)

Verified via `find docs/discovery/templates`. The domain-profile template exists at
`docs/discovery/templates/domain-profile/domain-profile.yaml` with the four fields
documented (`legacy_source.root`, `target.root`, `technology_stack.legacy`,
`artifacts.root`, plus `profile_version`). Disposition: verified — no correction
required.

### Domain-profile parser decision (`domain-profile.md`)

Verified against `docs/features/active/2026-07-17-legacy-discovery-config-contract-360/spec.md`:
"Decision: adopt PyYAML via `yaml.safe_load`." The plan assumed this decision would still
be marked planned (`#9001`); it has been resolved and delivered. The authored page states
the resolved decision plainly (PyYAML, not the frontmatter-regex convention) without
restating parser internals. Disposition: corrected from the plan's "planned" assumption
to the delivered, resolved decision — reflected directly in the authored page, no
post-hoc edit needed since the page was authored against the verified state.

### MCP tool names (`running-the-workflow.md`, `consumer-onboarding.md`)

Verified against `extensions/drm-copilot/src/mcp-discovery-tool-definitions.ts` (seven
discovery tools: `validate_discovery_artifacts`, `run_discovery_init`,
`run_discovery_repo_inventory`, `run_discovery_dotnet_analyzer`,
`run_discovery_vsto_analyzer`, `run_discovery_scenario_generation`, `run_discovery_report`)
and `extensions/drm-copilot/src/mcp-tool-definitions.ts` /
`extensions/drm-copilot/src/repo-automation-tool-names.ts` (three push-down tools:
`push_down_copilot_customizations`, `push_down_codex_and_agents_customizations`,
`push_down_claude_customizations`). All names match the authored pages exactly, including
the consolidation of nine CLI validate-* commands behind one `artifact_type`-parameterized
MCP tool and three report CLI commands behind one `report_type`-parameterized MCP tool —
the plan's assumed 1:1 CLI-to-MCP name lockstep does not hold, and the authored page states
the parameterized-consolidation pattern explicitly instead of assuming uniformity.
Disposition: verified; authored precisely rather than assuming naive 1:1 lockstep.

### VS Code command IDs (`running-the-workflow.md`)

Verified against `extensions/drm-copilot/src/discovery-command-registration.ts` and the
`contributes.commands` block in `extensions/drm-copilot/package.json`. All seven
`drmCopilotExtension.*` command IDs and their palette titles match exactly, one-to-one with
the seven MCP tools. Disposition: verified — no correction required.

### `RuntimeKind` (referenced in `running-the-workflow.md`)

Found at `extensions/drm-copilot/src/runtime-detection.ts:14`:
`export type RuntimeKind = "powershell" | "python";`. This is a VS Code extension-internal
plumbing type governing which interpreter family a command needs, not a discovery-domain
artifact type. Its `"python"` branch resolves a Python interpreter in the target
workspace (`.venv`, then `py`, then `python`) because the extension bundles no Python and
the discovery CLI code lives in the consumer workspace. The authored page reflects this
mechanism in the MCP-tools section without over-describing extension-internal plumbing
owned by `legacy-discovery-mcp-vscode` (#370). Disposition: verified; incorporated at
capability level only, per the no-duplication constraint.

### `TextParseResult` (#369 decision)

Verified against `docs/features/active/2026-07-17-legacy-discovery-dotnet-vsto-analyzers-369/coordination/text-parse-result-reconciliation.md`
and `scripts/dev_tools/discovery/analyzer/source_text.py`: a frozen `TextParseResult(ParseResult)`
subtype carries file text between an analyzer's `parse` and `classify` stages. This is an
internal analyzer-framework implementation detail (per-feature, owned by #363/#369), not a
discovery artifact schema or a user-facing command surface, so it is intentionally not
restated in `workflow.md` or `artifacts-and-schemas.md` beyond naming the .NET and VSTO
analyzers as generic, profile-selected stack analyzers (see the P2-T3 domain-neutrality
disposition for the analogous VSTO-naming classification). Disposition: verified; no
doc-page change required — correctly out of scope as per-feature internal detail.

### Push-down tooling names (`consumer-onboarding.md`)

Verified via `find scripts/dev_tools -iname "push_down*"`: all three documented CLI script
names exist exactly as spelled (`push_down_copilot_customizations.py`,
`push_down_codex_and_agents_customizations.py`, `push_down_claude_customizations.py`).
Disposition: verified — no correction required.

### Pack-manifest placement decision (`consumer-onboarding.md`)

Verified against `docs/features/active/2026-07-17-legacy-discovery-publishing-372/spec.md`
("Pack-Manifest Placement... Determination: `core`") and
`extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (which
lists the four discovery agent personas — `legacy-parity-analyst.md`,
`migration-coverage-reviewer.md`, `requirements-reconciler.md`,
`runtime-characterization-analyst.md` — and the two discovery hooks —
`enforce-discovery-artifact-gate.ps1`, `validate-discovery-artifact-gate.ps1` — under
`paths`). This resolves the plan's "planned" pack-decision marking to the delivered
decision: `core`, not a hypothetical separate `discovery` pack. The plan further assumed
schemas and templates would be pushed down through the same `resources/` mirror as agent
personas, skills, and hooks; #372's spec resolves this differently: "Neither `schemas/` nor
`docs/discovery/templates/` is a mirrored root... Both are outside the byte-identical
mirror contract... they are Python source/data distributed to consumers through the
MCP-server npm package, not through the `.claude`/`.codex` push-down publishers."
Disposition: corrected from the plan's assumed uniform push-down-mirrors-everything
model — the authored `consumer-onboarding.md` documents the two-mechanism split (push-down
for agent personas/skills/hooks; MCP-server npm package for schemas/templates) explicitly,
because it was authored against this verified decision rather than the plan's assumption.

### Discovery skills, agents, and hooks (`workflow.md`)

Verified via `ls .claude/skills/ | grep discovery` (seven skills:
`discovery-behavior-reconciliation`, `discovery-coverage-ledger`, `discovery-parity-matrix`,
`discovery-repo-inventory`, `discovery-runtime-characterization`,
`discovery-validate-artifacts`, `discovery-workflow`) and the `core.json` manifest excerpt
above (four agent personas, two hooks). The seven-stage sequence and stage-to-skill mapping
in `workflow.md` were read directly from each skill's `SKILL.md` frontmatter `description`
field (which states each skill's stage number and adjacency). Disposition: verified — no
correction required.

## Items Remaining Marked "Planned"

None of the six pages retains a "planned" marking for a forward reference, because every
upstream dependency named in the doc set has landed on the integration branch (all 13
epic children except this documentation feature itself). This supersedes the plan's Open
Questions assumption that all 13 children were absent at authoring time. No genuinely
undelivered item was identified during this reconciliation pass.

Satisfies spec AC 9 and AC 10 and Definition of Done item 4.
