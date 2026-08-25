# Claude Hook Pair Byte-Identity — issue #535

Timestamp: 2026-08-23T21-48

Command:
`pwsh -NoProfile -Command "$a = (Get-FileHash -Algorithm SHA256 -LiteralPath '.claude/hooks/enforce-orchestration-preimplementation-gate.ps1'); $b = (Get-FileHash -Algorithm SHA256 -LiteralPath 'extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1'); ..."`

EXIT_CODE: 0

Output Summary:

- canonical `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
  SHA256 = `F57FAE11FB5E98DC3D06214922A1B1CA4AE200D014873CADF03312042537493C`
- bundle `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
  SHA256 = `F57FAE11FB5E98DC3D06214922A1B1CA4AE200D014873CADF03312042537493C`
- Hashes are equal: byte-identity holds, which is what
  `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` requires
  (it compares every repo `.claude/**` file to its bundled counterpart for content
  equality).
- Line counts: canonical 339 lines, bundle 339 lines. Both are under the 500-line limit.
- Method note: the bundle copy was byte-identical to the pre-edit canonical
  (both SHA256 `66fee0fe14619c0037b9d3d5150cbb800936b67aac7d495b0e2a090f75669677`),
  so the same three edit hunks were applied to it rather than performing a file copy.
  The equal post-edit hashes above confirm the result.
