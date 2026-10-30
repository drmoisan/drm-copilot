# P7-T3 native translation plan and enforceability ledger

Generated (UTC): 2026-10-21T18:33:10Z

Mode: apply, already authorized by the user's publishing request and approved plan. Status: PREPARATION_ONLY; converter, generation and publication execution remain held for the coordinator's source-freeze release. Route: gateway_p7t3_publication_20261021T182600 / S5_P7T3_publication_preparation. Accepted source head: bfe9999897ef2ed81ac8f3de7569b0038f6ab67d.

This plan applies `.claude/skills/translate-copilot-to-claude/SKILL.md` to the Claude targets and `.agents/skills/translate-claude-to-codex/SKILL.md` to the Codex targets. The former's converted `.agents` copy is not the Claude target authority. `docs/research/20260616-codex-native-ecosystem.2026-06-16T13-32.md`, especially sections D-F, is the retained source for primitive classification; this preparation makes no new host-capability claim.

EVIDENCE_LOCATION_OVERRIDE_REJECTED: the translation skills' suggested `artifacts/translation/<timestamp>/` location is replaced with this feature's `evidence/other/` for the plan and later conversion reports/diffs. No duplicate baseline or source archive is created here.

## Inputs and retained decisions

- `plan.2026-10-17T22-38.md`: P7-T3, Set K/L, P8-T9, P9-T2/T3/T4/T6 and P10-T1.
- `evidence/other/p7t3-routing-publication-preparation.2026-10-21T17-43.md`: routing, publication, active-profile and deferred consumer-merge decisions.
- `evidence/other/p7-service-interface-delta.2026-10-20T17-14.md`: accepted service boundaries and workflow mapping.
- `evidence/qa-gates/p7t1-canonical-agents-freeze.2026-10-21T17-47.json`: exact four canonical role sources and accepted contract proof.
- `evidence/other/p7t2-canonical-skills-source-freeze.2026-10-21T18-09.json`: exact sixteen canonical skill sources; SHA256 c3fa408a67222c98034d2d149488c6abebecb0fa311f852d595641ef4c807153.
- `evidence/qa-gates/p7t2-workflows-freeze.2026-10-21T18-12.json`: accepted 66-case proof; SHA256 439f33b73a409b43f97813cf87545cc51ca9040cdca93c4dc8fd7499cf37ed49. Reused as source-contract proof, not native-publication proof.

The four role names are `legacy-parity-analyst`, `runtime-characterization-analyst`, `requirements-reconciler`, and `migration-coverage-reviewer`. Their sources are `.github/agents/<role>.agent.md`. All four `.claude/agents/<role>.md` targets exist; all four `.codex/agents/<role>.toml` targets are absent in this preparation. Existing native role bodies describe older ownership and broad `Write(discovery/**)` defaults; the accepted P7-T1 contracts explicitly supersede those clauses.

The following closed skill list supplies `.github/skills/<name>/SKILL.md`. Claude actions are relative to `.claude/skills/<name>/SKILL.md`; every corresponding `.agents/skills/<name>/SKILL.md` target is new.

| Skill name | Claude action | Contract retained |
| --- | --- | --- |
| inventory-legacy-system | add | Legacy inventory and exact selected coverage outputs |
| extract-feature-contract | add | Legacy feature contracts and evidence |
| characterize-runtime-behavior | add | Supplied runtime evidence; no application execution |
| reconcile-parity-matrix | add | Reconciler parity ownership |
| review-discovery-coverage | add | Reviewer reports only |
| adjudicate-unspecified-behavior | add | Reconciler proposal, then separate root approval |
| generate-acceptance-scenarios | add | Structured acceptance sources and eligible views |
| initialize-discovery-workspace | add | Root bootstrap, then reviewer |
| validate-discovery-artifacts | add | Explicit validation mode and truthful result |
| discovery-workflow | replace obsolete procedure with accepted dispatch | Explicit canonical skill_id |
| discovery-repo-inventory | replace obsolete procedure with accepted dispatch | Fixed inventory target |
| discovery-coverage-ledger | replace obsolete procedure with accepted dispatch | action=inventory, extract or review |
| discovery-runtime-characterization | replace obsolete procedure with accepted dispatch | Fixed characterization target |
| discovery-parity-matrix | replace obsolete procedure with accepted dispatch | Fixed reconciliation target |
| discovery-behavior-reconciliation | replace obsolete procedure with accepted dispatch | Fixed adjudication target |
| discovery-validate-artifacts | replace obsolete procedure with accepted dispatch | Fixed validation target |

## Section mapping and merge disposition

| Source section or element | Classification | Claude target/action | Codex target/action |
| --- | --- | --- | --- |
| Four role frontmatter, identity and role-specific output boundary | identity/declarative | Merge accepted description, tools, managed memory and exact output ownership into each existing persona; remove superseded broad write grants and hardcoded model choice | Add four base TOML agents through the converter; preserve the declared role contract in developer_instructions |
| Role prepared-input, read/operation, finalization and result procedures | procedural/handoff | Use the accepted workflow skills as the procedure source; keep a short index plus role-specific stop/output restrictions in each persona | Preserve the same skill references and explicit root launch/finalization ordering; no independent scheduler or implicit role launch |
| Nine workflows: use, input, routing, output, prerequisite, workflow and result sections | procedural/declarative | Add nine skills with frontmatter-first name/description and complete accepted workflow bodies | Add nine shared skills using the same converter and the bounded metadata normalization below |
| Seven aliases: inputs, dispatch and result sections | procedural/handoff | Replace the old duplicated workflows with accepted dispatch-only bodies | Add seven dispatch-only shared skills; selectors remain human-facing, not service-request fields |
| Denied shell/general-write/configuration/approval authority; exact grants; required native start/stop | enforceable requirement, currently partly prospective | Retain strict declared tools and blocking stop conditions; actual P8/P9 controls remain pending | Record the tool-allowlist degradation below; embedded prose does not implement a native control |
| Existing standing policies, rules, registered hooks, permission tables, MCP configuration and unrelated agents/skills | outside selected source set | skip; preserve bytes | skip; preserve bytes |

Use the canonical role-to-skill map from the retained interface; do not infer a role from an alias or choose a model. The existing exact resolver and generator own C1/C2/C3/elevated-C3/C4 selection. The generator's base C3 compatibility alias does not authorize launching an unprepared logical role. A Claude persona must not retain an independently selected `sonnet` field as an override of the prepared deployment.

Translate only the declared operation identifiers from `drmcopilotextension/<operation>` to the configured host's exact `drm-copilot` MCP identifier; do not add generic Read/Write/Bash/Task access or wildcard MCP permissions. A missing future operation remains unavailable. Preloading a workflow is not delegation or authorization. Managed memory stays optional and cannot authorize file writes.

Preserve exact kinds, profile keys, IDs, paths, formats, expected hashes, selected members and independent source/baseline pins. Non-reviewer `reports` permits only `required-output-manifest`. Reconciler acceptance output never grants `feature_contracts`. Preserve dry-run omissions, valid failing reviews, pending expectations and blocked native capability as distinct outcomes. No source/configuration/authority/installation writes are granted.

## Exact conversion invocation and ordering

1. After the coordinator releases the frozen inputs, apply the actual Claude translation skill to exactly the twenty canonical source files above. Rules, hooks, settings and standing-instruction stages are explicit no-ops. Apply skills before the persona indexes. Read existing selected targets before writing and retain the finite diff; preserve unrelated sections/assets.
2. Normalize the Claude Markdown role links to explicit root-qualified `.claude/agents/<role>.md` references. For links inside a skill, `../../../.claude/agents/<role>.md` retains the correct relative anchor and exposes the supported converter rewrite. Preserve valid sibling skill links. Do not leave `../../agents/<role>.agent.md` or links that would incorrectly resolve into `.agents/agents/`.
3. Use the required MCP converter surface. The following is the exact argument shape; resolve WORKSPACE to the trusted current worktree and RUN_UTC to the captured execution timestamp. `selected_paths` is the closed twenty-path expansion: four `.claude/agents/<role>.md` files plus sixteen `.claude/skills/<name>/SKILL.md` files listed above. Do not select an entire agents/skills directory.

```json
{
  "tool": "run_codex_native_converter",
  "arguments": {
    "workspace_root": "WORKSPACE",
    "mode": "apply",
    "source_ecosystem": "claude",
    "source_root": ".",
    "destination_root": ".",
    "selected_paths": [
      ".claude/agents/legacy-parity-analyst.md",
      ".claude/agents/runtime-characterization-analyst.md",
      ".claude/agents/requirements-reconciler.md",
      ".claude/agents/migration-coverage-reviewer.md",
      ".claude/skills/inventory-legacy-system/SKILL.md",
      ".claude/skills/extract-feature-contract/SKILL.md",
      ".claude/skills/characterize-runtime-behavior/SKILL.md",
      ".claude/skills/reconcile-parity-matrix/SKILL.md",
      ".claude/skills/review-discovery-coverage/SKILL.md",
      ".claude/skills/adjudicate-unspecified-behavior/SKILL.md",
      ".claude/skills/generate-acceptance-scenarios/SKILL.md",
      ".claude/skills/initialize-discovery-workspace/SKILL.md",
      ".claude/skills/validate-discovery-artifacts/SKILL.md",
      ".claude/skills/discovery-workflow/SKILL.md",
      ".claude/skills/discovery-repo-inventory/SKILL.md",
      ".claude/skills/discovery-coverage-ledger/SKILL.md",
      ".claude/skills/discovery-runtime-characterization/SKILL.md",
      ".claude/skills/discovery-parity-matrix/SKILL.md",
      ".claude/skills/discovery-behavior-reconciliation/SKILL.md",
      ".claude/skills/discovery-validate-artifacts/SKILL.md"
    ],
    "artifact_root": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p7t3-converter-RUN_UTC",
    "enable_repo_prompts": false
  }
}
```

The callable tool is `mcp__drm_copilot__run_codex_native_converter`; its active schema was inspected, not invoked. Its apply mode validates before destination writes. A failure or unavailable tool stops this stage; do not bypass it with the Python CLI. The equivalent established human-operated CLI, useful for documenting the same flags, is `python -m scripts.dev_tools.codex_native_converter apply --source-root . --source-ecosystem claude --destination-root . --selected-path <each-exact-source> --artifact-root <canonical-feature-evidence-root>`.

4. Resolve the deterministic frontmatter prerequisite before invoking step 3. `pipeline.py::_wrap_rendered_target_content` and TypeScript `pipeline-render.ts::wrapRenderedTargetContent` currently put `# Converted skill` and `Applied rewrites` before copied YAML. Python `engine.py::_render_generated_output` returns those strings and `_write_destination_outputs` writes them unchanged; TypeScript `engine-pipeline.ts` mirrors that path. No later normalization stage exists. A manual generated-file repair would fail repeatable regeneration and is not permitted.

   Smallest proposed source prerequisite: modify only the shared-skill wrapping branch in `scripts/dev_tools/codex_native_converter/pipeline.py` (462 lines at inspection) and `extensions/drm-copilot/src/lib/codex-native-converter/pipeline-render.ts` (366 lines). A complete source frontmatter block must remain at byte zero, with the existing generated provenance after its closing delimiter and the rewritten body preserved. Keep non-skill rendering, absent/malformed-header compatibility and the existing parser's delimiter contract unchanged; do not invent metadata. Existing `tests/scripts/dev_tools/codex_native_converter/test_end_to_end.py` (154 lines) and `extensions/drm-copilot/test/lib/codex-native-converter/pipeline.test.ts` (295 lines) can hold finite LF/CRLF, body-separator, empty-body, absent/malformed-header, repeated-same-input and apply-output controls using memory seams. Exact test ownership/release remains coordinator-controlled. The active MCP converter must contain the confirmed correction before generation; changing repository source alone does not update a running provider.
5. Once the shared configuration, four-family inventories, language resolvers and base agents are frozen, use the established generator, then check mode:

```powershell
& .venv/Scripts/python.exe -m scripts.dev_tools.generate_codex_agent_variants
& .venv/Scripts/python.exe -m scripts.dev_tools.generate_codex_agent_variants --check
```

`generate_codex_agent_variants.py::_synchronize` also rewrites existing base aliases, generated families, bundled agents and affected manifests. inventory_analyzers owns exact active-profile before/after hashes. Any changed active profile requires fresh native launch/authority; an assumed unchanged body is insufficient.
6. Refresh only the corresponding checked-in resource mirrors and explicit core entries described in the handoff. Bundle assembly is distinct from consumer push-down. Do not invoke a currently installed publisher against this worktree to overwrite newly authored sources from an older installed bundle.
7. After source/bundle checks and coordinator release, the established builds are `npm --prefix extensions/drm-copilot run build`, `npm --prefix packages/mcp-server run build`, and `npm --prefix packages/mcp-server run prepack`. Build commands compile JavaScript; they do not translate root Claude/Codex assets. `prepack.cjs` copies prepared extension resources and excludes Python. No version bump, npm/VSIX publication or consumer invocation is authorized by this preparation.

## Enforceability preservation ledger

| Element | Source class | Target class in P7 | Status and required control |
| --- | --- | --- | --- |
| Role workflow, output ownership, provenance, managed-memory limits and stop/result prose | prompt-level | prompt-level | PRESERVED as instructions only; do not relabel as native enforcement |
| Existing Claude per-persona tools allowlist; replacement narrows operations | process-enforced native tool selection, with path-specific enforcement not proven by the frontmatter alone | Codex converter embeds YAML in developer_instructions; no equivalent TOML allowlist | DEGRADED. Exact-grant server checks plus native per-session tool/command/write denial are required in P8/P9. No claim of enabled, safely restricted Codex discovery execution is permitted before that verified capability. Existing Claude restriction must remain narrowed, never silently omitted |
| New nine workflows and seven canonical aliases have name/description only | prompt-level; no allowed-tools/context:fork gate exists in these canonical sources | shared skills plus explicit prepared root launch | PRESERVED; no removed mechanical skill gate or automatic fork behavior |
| Resolver-selected exact deployment/model/effort/profile hash | native model fields plus existing routing mechanism; discovery receipt extension is P7 work | existing generated model fields and resolver parity | PRESERVED design, pending P7 proof; protected discovery attestation remains P8/P9, not a consequence of successful routing |
| Existing registered PreToolUse restrictions and permission settings | process/OS controls where actually registered and trusted | current registrations untouched | PRESERVED by exclusion from this conversion; no whole-file settings/config overwrite |
| Discovery-specific finalize/start/stop/one-use grants and freshness | requirement, not yet implemented/registered for these four roles | unavailable protected service operations and documented stop | PENDING, not a lost existing gate. Preserve fail-closed unavailable behavior; P8/P9 must supply and verify controls before activation |
| Existing stop gates for unrelated roles | process-enforced registrations | unchanged existing gates | PRESERVED by exclusion. `.claude/settings.json` discovery validator matcher currently excludes the four selected roles; there is no existing four-role stop registration to remove |
| Future discovery SubagentStop hard rejection | future native gate | Codex continuation plus required external validation | DEGRADED target design per retained research. P9/P10 must identify and verify the required CI/output-consumption backstop; none is claimed installed by P7 |

There is no proposed deletion of an existing registered mechanical gate. The prospective controls above are not accepted proof that a missing mechanism exists. Any actual LOST element discovered in the final selected-source diff blocks that apply row and requires explicit contract resolution; apply authorization alone is not permission to weaken a gate.

## Settings delta, conflicts and scope limits

- P7 settings delta: no hooks, permissions, MCP servers, trust settings, standing catalog entries or CI registrations are added or removed by this conversion slice. P9 owns native registration and capability proof. Trusted project configuration and trusted hook content are prerequisites for later activation; this plan neither changes user trust nor uses a hook-trust bypass.
- Superseded native Write defaults, legacy parity/reviewer ownership and old seven-stage alias procedures are resolved by the already accepted P7-T1/T2 source contract. They are not new user-choice questions.
- The provenance-prefix/frontmatter correction is a concrete proposed shared-converter prerequisite. Record coordinator disposition before editing those two implementation files and their direct tests. Relative-role-link adaptation is permitted only within the declared deterministic canonical-to-Claude conversion, not a manual post-generation patch or service-schema change.
- P7 generated contracts are not P8/P9 capability acceptance or P10 consumer delivery. P10 consumer policy merge remains the finite proposal in the 17:43 preparation; do not implement it here.
- No broad converter/helper taxonomy change is proposed. The native authority/hook/helper mapping expansion remains P8-T9; the new routing helper uses the already established explicit publisher pair mechanism.

## Verification boundary and completion evidence

The later combined gate must prove the selected mapping, valid frontmatter/TOML, correct role links, unchanged unselected policies/profiles, no unresolved native references, exact four-family variants, explicit bundle/core membership and helper/CLI byte identity. Set K updates obsolete native expectations while retaining metadata, neutrality, routing and mirror assertions. Set L and the agreed shared routing corpus remain the language owners' bounded gate.

For helper publication, reuse `test_push_down_codex_and_agents_virtual_paths.py`, the applicable TypeScript `codex-agents-customizations.test.ts` controls and the real-bundle in-memory destination test. Preserve positive full-tree/core selection and negative unmapped-sibling/no-physical-Codex-lib controls. For the proposed converter correction, run its direct renderer/apply controls and affected unchanged conversion cases after ordered language statics; do not expand to a wholesale converter/predecessor replay. The canonical P7-T1/T2 tests supply retained source semantics; they do not substitute for generated/native mapping checks.

At apply completion, retain the converter validation/report and exact before/after selected-source mapping in canonical feature evidence, with native targets classified done/skipped/conflict-unresolved. Report any unimplemented compensation as pending. This preparation executed no converter, generator, test, package, native capability or consumer-publishing command.
