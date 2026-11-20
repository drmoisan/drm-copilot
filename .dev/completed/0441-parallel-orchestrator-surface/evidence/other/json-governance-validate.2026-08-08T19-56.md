# JSON Governance — Schema Validation on `core.json`

Timestamp: 2026-08-08T19-56

Working directory: repository root (`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a926e23bcfaa5fb69`)

Argument form resolved from `poetry run python -m scripts.dev_tools.validate_json --help` before
running:

```
usage: validate_json.py [-h] [--verbose] [--cache-dir CACHE_DIR] [paths ...]
Validate governed JSON files against their $schema
positional arguments:
  paths                 Optional specific files/dirs; defaults to governed globs
options:
  --verbose             Print per-file status
  --cache-dir CACHE_DIR Schema cache directory
```

## Command — explicit-path validation

Command: `poetry run python -m scripts.dev_tools.validate_json --verbose extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`

EXIT_CODE: **1**

Output Summary:

```
extensions\drm-copilot\resources\claude-customizations\pack-manifests\core.json: missing $schema
```

The `[P4-T8]` acceptance condition `EXIT_CODE: 0` is **NOT met**. The reported condition is `missing
$schema`, not a schema violation: `core.json` declares no `$schema` key and the validator's contract is
to validate governed JSON files *against their `$schema`*. Two measurements establish that this is
pre-existing and not attributable to this cycle:

1. **`core.json` is outside the governed set.** `scripts/dev_tools/json_config.py` defines
   `GOVERNED_GLOBS` as exactly `("scripts/**/*.json", "docs/**/*.json", "examples/**/*.json")`;
   `extensions/**` is absent, so the repository's own governance run never validates `core.json`.
   Supplying the path explicitly bypasses that filter.
2. **The same result holds at the merge base.** The merge-base version of the file reports
   `missing $schema` and exits 1 under the identical invocation, so the condition predates this branch.

Adding a `$schema` key to `core.json` would modify a file this cycle is required to leave unmodified
(this plan's `## Exit Criteria` item 5) and would define a schema, which the plan's hard constraints
prohibit outright. No such change was made.

## Repository-governed default run (context)

Command: `poetry run python -m scripts.dev_tools.validate_json`

EXIT_CODE: **1**

Output Summary: two files reported `missing $schema`, neither of which is `core.json` and neither of
which is touched by this cycle:

```
docs/features/active/2026-08-04-mixed-promotion-agent-delegation-receipts-435/evidence/other/mixed-complete-checkpoint.2026-08-04T10-46.json: missing $schema
docs/features/active/2026-07-25-orchestrator-completion-hook-false-block-413/evidence/other/completion-passing-checkpoint.2026-07-25T17-19.json: missing $schema
```

This repo-wide condition is pre-existing and out of this cycle's scope. Both non-zero exits are
escalated in the execution report rather than remediated silently.

## Structural Confirmation Actually Achieved

`core.json` parses as valid JSON (both governance commands parsed it successfully before reporting
their governance findings), all three `.claude`-relative parallel-surface paths remain present in it,
and it is byte-identical to its state at HEAD `41633ad5e867070853e3e4501c3457b6641d1efc`. Those facts
are recorded with their commands in `./bundle-parity-verification.2026-08-08T19-50.md` and
`./json-governance-format.2026-08-08T19-56.md`, and the two bundle-parity suites that consume the
manifest are green (`../regression-testing/bundle-parity-pytest.2026-08-08T19-52.md`,
`../regression-testing/bundle-parity-jest.2026-08-08T19-52.md`).
