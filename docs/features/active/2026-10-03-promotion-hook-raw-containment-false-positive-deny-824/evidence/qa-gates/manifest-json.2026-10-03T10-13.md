# P6-T7 Manifest JSON validity

Timestamp: 2026-10-03T10-13
Command: foreach ($m in @('extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json', 'extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json')) { $p = (Get-Content -Raw -LiteralPath $m | ConvertFrom-Json).paths; "$m paths=... unique=... raw=..." }
EXIT_CODE: 0
Output Summary:
- extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json paths=203 unique=203 raw=1
- extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json paths=118 unique=118 raw=1
- Result: PASS (no duplicate entry; exactly one raw-invocation entry per manifest)
