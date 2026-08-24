Timestamp: 2026-07-19T05-40

SearchScope: `.claude/`, `.codex/`, `.agents/` (mirrored roots per the push-down contract tests),
then `scripts/` (the non-mirrored root speculated in `spec.md`), then the full repository root for
any other landing location, at this worktree's current HEAD (branched from
`origin/epic/legacy-discovery-and-parity-integration` after PRs #374, #383, #380, #376, #381
merged).

SearchPatterns: `find .claude .codex .agents -iname "*schema*"`,
`find .claude .codex .agents -iname "*template*"`, `find scripts -iname "*schema*"`,
`find schemas -maxdepth 5`, `find docs/discovery -maxdepth 4`,
`grep -rn "template" scripts/dev_tools/discovery/init_cli.py scripts/dev_tools/discovery/init_flow.py scripts/dev_tools/discovery/init_models.py`.

SearchResult:

- No new schema or template file exists under `.claude/`, `.codex/`, or `.agents/` (only two
  pre-existing, unrelated skill folders named `*template*` were found:
  `.claude/skills/make-skill-template`, `.claude/skills/policy-audit-template-usage`, and their
  `.agents/skills/` Codex-converted twins — neither is a `legacy-discovery-schemas` or
  `legacy-discovery-init-templates` asset).
- The seven `legacy-discovery-schemas` (#359) JSON Schema files were found at
  `schemas/discovery/v1/coverage-ledger.schema.json`,
  `schemas/discovery/v1/evidence-reference.schema.json`,
  `schemas/discovery/v1/feature-contract.schema.json`,
  `schemas/discovery/v1/parity-matrix.schema.json`,
  `schemas/discovery/v1/product-decision-record.schema.json`,
  `schemas/discovery/v1/runtime-characterization-scenario.schema.json`,
  `schemas/discovery/v1/unspecified-behavior-record.schema.json` — a repo-root `schemas/`
  directory, not under `scripts/` as `spec.md`'s speculative placement guessed, and not under any
  mirrored root.
- The `legacy-discovery-init-templates` (#362) assets were found at two locations: (a) Python
  source implementing the init-workspace flow at `scripts/dev_tools/discovery/init_cli.py`,
  `init_flow.py`, `init_models.py` (a `scripts/`-relative, non-mirrored-root path, consistent with
  `spec.md`'s speculation), and (b) the actual template data files it reads, resolved by
  `init_models.resolve_default_template_root()` to a repo-root `docs/discovery/templates/` tree
  (`docs/discovery/templates/domain-profile/domain-profile.yaml` and seven
  `docs/discovery/templates/artifacts/*.template.json` files) — also a repo-root directory, not
  under `scripts/`, and not under any mirrored root.
- Neither the `schemas/` root nor the `docs/discovery/templates/` root is `.claude/`, `.codex/`,
  or `.agents/`. Both are outside the byte-identical mirror contract enforced by
  `test_push_down_claude_resource_contracts.py` and
  `test_push_down_codex_and_agents_resource_contracts.py` (both of which scope their file
  enumeration to `SCOPED_ROOTS == (Path(".claude"),)` / the `.codex`/`.agents` equivalent).

Decision: scripts-non-mirrored

Decision note (execution-time reconciliation): `spec.md`'s and this plan's binary enum
(`mirrored-root` vs `scripts-non-mirrored`) was authored before the real upstream asset paths
were known (per the plan's Preparation-Mode Note). The literal verified landing roots are
`schemas/` and `docs/discovery/templates/`, not literally `scripts/`, but both are non-mirrored
repo-root directories functionally identical in kind to the `scripts/`-branch of the conditional
rule in `spec.md`'s "Schema/Init-Template Placement" section: neither is `.claude/`, `.codex/`,
or `.agents/`, so neither is subject to the byte-identical mirror obligation or a `core.json`
manifest entry. `scripts-non-mirrored` is recorded as the closest literal enum value representing
"non-mirrored-root, out of push-down mirror-contract scope," with the exact verified paths (not a
literal `scripts/` prefix) cited above and repeated in the `spec.md` resolution section added
under P5-T5.
