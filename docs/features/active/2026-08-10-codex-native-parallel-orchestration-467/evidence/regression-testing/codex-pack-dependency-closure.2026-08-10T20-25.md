# Codex Pack Dependency Closure Evidence

Timestamp: `2026-08-10T20-25`

Task: `[P5-T7]`

Command: `npm exec -- prettier --check resources/codex-and-agents-customizations/pack-manifests/core.json`

EXIT_CODE: `0`

Output Summary: The modified Codex core manifest uses the repository Prettier style and parses as JSON.

Command: `poetry run pytest -q tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_pack_selection.py`

EXIT_CODE: `0`

Output Summary: 25 focused Python manifest-completeness and pack-selection tests passed in 0.09 seconds.

Command: `npm run test:unit -- --runInBand test/lib/push-down/codex-pack-selection.test.ts`

EXIT_CODE: `0`

Output Summary: 1 TypeScript suite and 16 pack-selection tests passed in 0.31 seconds.

Command: `read-only manifest closure, source, duplicate, and selected-pack comparator`

EXIT_CODE: `0`

Output Summary: All 10 mechanical checks passed.

## Verified Contract

- The Codex `core.json` manifest contains 127 unique members on 133 physical
  lines and has SHA-256
  `2009cfc43103347db57e1418e80fa4b0057e4026674aa76784e807174d64b8cc`.
- The production delta adds exactly the 43 paths missing from the prior
  84-member manifest, in deterministic existing category order.
- The required dependency closure is 48/48: six parallel skills, two parallel
  agents, fourteen registered or shared hooks, eight launcher/runtime scripts,
  four routing/configuration paths, nine Bash files, and five blast-radius
  PowerShell modules.
- Every effective source exists: 48/48. The routing source is
  `extensions/drm-copilot/resources/config/orchestration-routing.json`; the
  generic blast-radius source is under the Claude resource bundle.
- Internal duplicate membership is 0. Cross-language duplicate closure
  membership is 0 across Python, PowerShell, TypeScript, C# modern, and C#
  legacy manifests.
- Each of the five selected language packs inherits the complete core closure;
  selected-pack inclusion is 5/5.
- Codex core owns exactly the approved fourteen `.claude/lib/**` paths and
  `config/blast-radius.json`; unrelated `.claude/**` membership is 0.
- The Claude portable-source core and all five Codex language manifests are
  unchanged. The Claude core SHA-256 remains
  `fd430131c60481d409e247ad3c9ce0a8b22f253d23a8b084b5764d9b6d5fb519`.
- Eleven executable/dispatcher hooks retain their config registrations; the
  three shared modules remain intentionally unregistered.
- `.claude` diff and status counts are zero, `.codex/state` is absent, and
  `git diff --check` exits 0. The existing `testResults.xml` line-ending warning
  is non-failing.
- `[P5-T8]` was not started.
