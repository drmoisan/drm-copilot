# P10-T4 Documentation contract

Timestamp: 2026-10-22T19-11
Task: [P10-T4] Document the complete reusable architecture and operational contracts.
Result: PASS

## Documentation delivered (`docs/engineering/legacy-discovery-and-parity`)

- Updated: `README.md` (index, ownership, audiences), `domain-profile.md` (version 2 fields, states, completion gates, planning prerequisite, version 1 note), `artifacts-and-schemas.md` (version 2 kinds, status and version semantics, criteria versus test pass, frozen version 1 schemas, validation modes and receipts, evidence and pins, safe extensions), `workflow.md` (four roles with tools, nine workflows, seven aliases, sequence, planning linkage), `running-the-workflow.md` (gateway contract, CLI, 18 MCP tools, 13 VS Code commands, agent-driven runs, doctor), `consumer-onboarding.md` (three packages, local setup without a checkout, separate repositories, consumer ownership, updating).
- Added: `architecture.md` (Mermaid diagram; engine, gateway client, native hooks per host, protected authority store; no-runtime, manual, semi-automated, combined, separate and multi-client flows; principals and modes), `analyzers.md` (twelve identifiers, guarantees, limits, extension through result manifests), `enforcement.md` (five supported native controls with denial prefixes, protected records, inactive compatibility, planning prerequisite, registrations), `migration.md` (version 1 to 2, snapshot transport, inventory import, runtime version changes), `cli-reference.md` (31 console scripts with options and write behavior, 18 MCP tools with principals, 13 commands, 30 gateway operations and 5 modes, operator scripts), `maintainer-guide.md` (canonical-to-generated table, regeneration, wheel and host package builds, hook rules, adding an analyzer, release verification).
- `docs/engineering/claude-code-architecture.md`: a fourth enforcement boundary describing the four discovery hooks and the planning prerequisite, and a repository-enforceable-controls bullet, both stating that discovery criteria gate planning without asserting an implementation pass.
- Planning-prerequisite linkage in the orchestration skills: `.agents/skills/orchestrator-workflow/SKILL.md` (routing rule 10), `.agents/skills/atomic-planner/SKILL.md` (plan requirements) and `.claude/skills/orchestrate/SKILL.md` (prerequisite 5), each mirrored byte-for-byte into its bundle. The plan names `.github/skills/{orchestrator-workflow,atomic-planner}/SKILL.md` as canonical sources; those paths do not exist in the repository (the two Codex skills are authored directly under `.agents/skills` and have no generator), so the linkage was authored in the three existing skill files and their mirrors, which is the conversion surface the repository actually has. Recorded as a deviation for the closing review.
- Execution-environment facts: none changed. The canonical `.github/skills/execution-environment/SKILL.md` and its five committed copies share SHA-256 `79ea0b5ea41dab833fd155d76b66d7051bd78edccb41756ee5877752ffdc94c7`; the new test pins the six-way identity.

## Proof

- `tests/scripts/dev_tools/test_discovery_documentation_contracts.py` (28 cases) pins page set and index, link resolution, the diagram, console scripts, MCP tools, VS Code commands, gateway operations and modes, artifact kinds, analyzers, prerequisite values, roles, workflows, aliases, hooks and prefixes, the required topics (field, status and version semantics, ownership, local setup, the host flows, safe extensions, evidence and pins, analyzer limits, supported native controls, inactive compatibility, migration, commands, criteria versus test pass), consumer-name absence, no-checkout onboarding, the architecture-document linkage, the skill linkage with current mirrors and the unchanged execution-environment fact.
- `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1` gains the discovery-controls assertion.

## Gates

- Black, Ruff and Pyright clean; pytest 28 passed (new suite) and 8187 passed, 6 skipped (dev_tools folder); PoshQC format and analyze clean; Pester 51/51 over the suites that read the edited skills and documents.

## Carried notes

- `docs/engineering/legacy-discovery-and-parity/examples/` is referenced as inline code and is created by P10-T5 (`examples/taskmaster-tmw.md`); the link checker will then admit a link to it.
- The planning gate's `planning_prerequisite` is read by `DiscoveryPlanning.psm1` from the activated profile text; the documentation describes that behavior and does not alter it.
