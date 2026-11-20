# Code Review — legacy-discovery-documentation (#371)

- Reviewed branch: `feature/legacy-discovery-documentation-371` @ `de2cc7f9`
- Timestamp: 2026-07-19T09-20
- Scope: this feature delivers no production code. All six deliverables are Markdown
  documentation files under `docs/engineering/legacy-discovery-and-parity/`. "Code quality"
  here is evaluated as documentation quality: structure, accuracy, internal consistency,
  cross-reference integrity, and adherence to the general-code-change design principles
  applied at the documentation level (simplicity, no duplication, clear scope boundaries).

## File Inventory

| File | Lines | Purpose |
|---|---|---|
| `README.md` | 52 | Index, domain-neutrality invariant, audience guide, topic-page table |
| `workflow.md` | 72 | End-to-end 7-stage workflow, terminal outputs |
| `domain-profile.md` | 55 | Domain-profile contract fields, authoring guidance, parser deferral |
| `artifacts-and-schemas.md` | 75 | Seven schemas, versioning, validation paths, completion gates |
| `running-the-workflow.md` | 92 | CLI/MCP/VS Code surfaces in lockstep, in that order |
| `consumer-onboarding.md` | 85 | Push-down delivery mechanism, TaskMaster/TMW worked example |

Line counts match the PR-context diff stats exactly (`+52/-0`, `+72/-0`, `+55/-0`,
`+75/-0`, `+92/-0`, `+85/-0`).

## Structural Quality

- **Simplicity and readability**: each page is single-purpose, scoped to one capability
  area, and uses tables for enumerable data (command lists, schema lists, MCP tool
  mappings) rather than prose lists — appropriate given the data is inherently tabular
  (name-to-name mappings). Good.
- **No duplication**: every page contains an explicit statement of what it does *not*
  cover and where that content is owned (e.g., `workflow.md`'s "What This Page Does Not
  Cover" section; `artifacts-and-schemas.md`'s "it does not restate individual schema field
  tables..."; `domain-profile.md`'s "Parser Internals (Deferred)" section). This is a
  deliberate, well-executed pattern that satisfies the no-per-feature-duplication
  constraint structurally, not just by assertion.
- **Cross-reference integrity**: 32 relative markdown links across the six pages, all
  resolving to files present in the same directory (independently verified; see
  policy-audit). No dangling or forward-marked-"planned" links remain, consistent with the
  reconciliation evidence's claim that all 13 upstream dependencies have landed.
- **Kebab-case naming**: all six filenames are kebab-case as required
  (`artifacts-and-schemas.md`, `running-the-workflow.md`, `consumer-onboarding.md`, etc.).
- **README as index**: `README.md` correctly functions as a pure index/overview — it does
  not restate detail owned by the topic pages, and its topic-page table and audience guide
  both link out rather than duplicate.

## Accuracy Findings (the substantive code-review content for a docs-only feature)

Because this feature's entire "correctness" surface is factual accuracy against a live,
fast-moving integration branch, the accuracy of technical claims is the primary code-review
concern, and it was independently re-verified against source rather than trusted from the
executor's own evidence artifacts. Full detail in `feature-audit.2026-07-19T09-20.md`.

**Strengths (high accuracy bar met in most of the doc set):**
- The 18-row `dev.discovery.*` CLI table in `running-the-workflow.md` is a byte-for-byte
  match against `pyproject.toml`'s `[tool.poetry.scripts]` section, including the
  non-obvious detail that several commands route through non-`main` entry functions
  (`main_dotnet`, `main_vsto`, and the nine `validate-*` variants) and that
  `generate-acceptance-scenarios` lives outside the `scripts.dev_tools.discovery` package.
  The page correctly states that `poetry run dev.discovery.<command>` is the reliable
  invocation form and that a guessed `python -m ...` equivalent is not reliable for every
  command — this is a precise, well-hedged claim rather than an over-generalization.
- The seven-MCP-tool-to-CLI mapping table in `running-the-workflow.md` accurately documents
  a real asymmetry: nine CLI `validate-*` commands consolidate behind one
  `validate_discovery_artifacts` MCP tool parameterized by `artifact_type`, and three report
  CLI commands consolidate behind one `run_discovery_report` tool parameterized by
  `report_type`. The page explicitly calls out that this is *not* a naive 1:1 name mirror,
  which is accurate and prevents a misleading impression.
- The domain-profile contract-field table matches
  `scripts/dev_tools/discovery/domain_profile_models.py`'s dataclass fields exactly
  (`legacy_source.root`, `target.root`, `technology_stack.legacy`, `artifacts.root`,
  `profile_version`).
- The `GOVERNED_GLOBS` claim in `artifacts-and-schemas.md` is a verbatim match to
  `scripts/dev_tools/json_config.py`'s tuple contents, including the correct, non-obvious
  detail that a repo-root `schemas/**` path is *not* covered by `dev.validate-json`'s
  default scan.

**Defect (Blocking):**
- `consumer-onboarding.md`'s "What Is Delivered, and How" section (item 2) asserts, in
  present-tense declarative language, that the seven discovery JSON schemas and the
  initialization templates "reach a consumer repository as Python source/data through the
  `@danmoisan/drm-copilot-mcp` npm package." This claim was checked against
  `packages/mcp-server/package.json` (`files: ["out/mcp-server.js", "resources"]`) and
  `packages/mcp-server/prepack.cjs` (which explicitly excludes every `.py` file and any
  `scripts/`-segment path when copying `extensions/drm-copilot/resources/` into the
  packaged `resources/` directory) and against `extensions/drm-copilot/resources/**`
  (neither `schemas/discovery/v1/` nor `docs/discovery/templates/` appears anywhere in that
  tree). No code path in the current branch copies, bundles, or otherwise ships the seven
  schema files or the init templates through the MCP-server npm package. The documented
  delivery mechanism does not exist in the landed codebase. Full detail and remediation
  target in `remediation-inputs.2026-07-19T09-20.md`.
- This defect traces back to the executor's reconciliation evidence
  (`evidence/other/integration-reconciliation.2026-07-19T07-30.md`, "Pack-manifest
  placement decision" entry) citing `legacy-discovery-publishing-372`'s spec.md prose as the
  verification source for this claim, rather than independently checking the actual
  packaging code. `legacy-discovery-publishing-372`'s own spec.md states the schema/template
  distribution mechanism as a design "Resolved" decision but its own Acceptance Criteria
  explicitly scope that feature's delivered work to "explicitly documented as out of
  mirror-contract scope" (no mirror copy, no manifest entry) rather than to building any
  actual distribution mechanism. The documentation feature (#371) inherited an unbuilt
  design intention and presented it as landed, working behavior.

## Minor Observations (non-blocking)

- `workflow.md` names several skills and agent personas by exact identifier (e.g.
  `discovery-coverage-ledger` skill, `runtime-characterization-analyst` agent). These were
  independently spot-checked and match real, landed assets under `.claude/skills/` and
  `.claude/agents/`. This level of naming precision is good for a capability-level
  documentation page and does not constitute per-feature duplication, since it names rather
  than restates each asset's internal behavior.
- `running-the-workflow.md`'s Python-interpreter-resolution sentence ("the workspace `.venv`
  interpreter, then `py`, then `python` on PATH") is a verbatim paraphrase of the doc
  comment in `extensions/drm-copilot/src/runtime-detection.ts`. Accurate.
- No file approaches the 500-line limit (all Markdown files are exempt from that limit per
  policy in any case; the largest is 92 lines).

## Overall Code-Review Verdict

**PARTIAL.** Documentation structure, cross-reference integrity, and the large majority of
factual claims are accurate and well-hedged. One Blocking accuracy defect exists in
`consumer-onboarding.md` regarding the schema/init-template distribution mechanism, which
must be corrected (or explicitly re-marked as planned/undelivered) before this feature can
be considered GO. See `remediation-inputs.2026-07-19T09-20.md`.
