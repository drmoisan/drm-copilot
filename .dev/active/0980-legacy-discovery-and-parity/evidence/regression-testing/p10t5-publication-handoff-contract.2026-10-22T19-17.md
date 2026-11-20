# P10-T5 Publication and consumer handoff contract

Timestamp: 2026-10-22T19-17
Task: [P10-T5] Prepare exact publication and separated consumer handoff instructions.
Result: PASS

## Delivered

- `docs/engineering/legacy-discovery-and-parity/examples/taskmaster-tmw.md`: the separated, non-canonical example naming `drmoisan/TaskMaster` (legacy source) and `drmoisan/TMW` (modernization target); the tested package versions (wheel 2.0.0, extension and MCP server 1.1.22) with install commands; the interpreter binding (install the wheel into each repository's `.venv`, which the gateway client selects before `py` or `python`; no separate setting exists); the three installed MCP push-down argument shapes as JSON (`push_down_copilot_customizations {workspace_root}`, `push_down_claude_customizations {workspace_root, packs:["core"], memory_mode:"skip"}`, `push_down_codex_and_agents_customizations {workspace_root, packs:["core"], memory_mode:"skip"}`); the host probe; the dry-run-first initialization, profile completion, activation, inventory and validation sequence; the expected local tree for each role, taken from the specification's case study; and the single-repository `combined` variant.
- `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/handoff.md`: the built artifacts reconciled with the P10-T2 and P10-T3 evidence (wheel SHA-256 `0389c099b612c905340cad1adfd33d67142b7396a21d829de69344725f07661e`, VSIX `d7ad4748cd8936cc4f35d065958987d503085f24e9e32df98d8b150cef6a4ee7`, npm tarball `3681c32cf89a3f8e9a01768e4ffa67d886bbe79d651052cc64ab9ac763464218`, with the note that a rebuild after further commits changes them); the publication prerequisites (review, QA, completion validator, rebuild from the merged head, deliberate separate publication, installed bundles); the per-repository local work in order; every consumer-owned artifact (profile, scope, inventory, contracts, characterization, evidence, unspecified-behavior and decision records, source snapshots, implementation records, parity matrix, acceptance, reports) distinguished from framework output (validated structure, drafts with explicit unknowns, receipts, reports; no catalog, runtime result or verification claim); and the open items the owners must resolve locally (missing source evidence, unresolved decisions, unsupported capability, target implementation and verification work, characterization tooling).
- README and consumer-onboarding links now point at the example page; consumer names appear in no topic page.

## Proof

- `test_discovery_documentation_contracts.py` gains `test_separated_example_is_the_only_consumer_specific_page` and `test_handoff_reconciles_the_built_artifacts`; the existing consumer-name, link-resolution and index tests cover the new links. 30 cases pass; the issue-824 follow-ups, skills contracts and publication contracts suites pass 232.

## Gates

- Black, Ruff and Pyright clean; pytest 30 and 232 passed. No PowerShell or TypeScript changed.

## Carried notes

- Neither consumer repository was inspected, populated or modified; all repository-specific values in the example and handoff are placeholders.
- The handoff's digests are those of the artifacts built in this feature; release publication re-digests the published artifacts (P11 closing work records the final values).
