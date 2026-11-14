# Task check [P6-T1]

Timestamp: 2026-11-14T04-49
Command: sh SCRATCH/issue-1159-mirror.sh (cp + cmp per pair); sh SCRATCH/issue-1159-p6t1.sh (poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check; pytest -n auto over the push-down contract tests); sh SCRATCH/issue-1159-taskcheck.sh over the edited entry scripts and the bundle-dependent Pester suites
EXIT_CODE: 0
Output Summary: 11 bundle copies byte-identical (cmp); generator --check exit 0; pytest 89 passed, 0 failed (resource contracts, manifest completeness, dependency closure, codex core closure, discovery publication, planning integrity); entry-script check format 0, analyzer 0, Pester 791 passed; bundle-dependent Pester suites 80 passed, 1 failed (the [P7-T1] owner-directive arrival).

## Copied (repository -> bundle)
- .claude/settings.json, .claude/hooks/invoke-pretooluse-dispatch.ps1, .claude/hooks/pretooluse-dispatch.json, .claude/lib/hook-dispatch/HookDispatch.psm1, .claude/lib/hook-dispatch/HookDispatchRunner.psm1, .claude/lib/discovery-validation/DiscoveryCapability.psm1 -> extensions/drm-copilot/resources/claude-customizations/
- .claude/lib/discovery-validation/DiscoveryCapability.psm1 -> extensions/drm-copilot/resources/lib/discovery-validation/DiscoveryCapability.psm1
- .codex/config.toml, .codex/hooks/invoke-pretooluse-dispatch.ps1, .codex/hooks/hook-dispatch.ps1, .codex/hooks/pretooluse-dispatch.json -> extensions/drm-copilot/resources/codex-and-agents-customizations/
- D6- and D13-edited hooks: already byte-identical with their bundle copies (mirrored in Phases 1 and 3; cmp verified).

## Manifests
- claude core.json: + .claude/hooks/invoke-pretooluse-dispatch.ps1, .claude/hooks/pretooluse-dispatch.json, .claude/lib/hook-dispatch/HookDispatch.psm1, .claude/lib/hook-dispatch/HookDispatchRunner.psm1
- codex core.json: + .codex/hooks/hook-dispatch.ps1, .codex/hooks/invoke-pretooluse-dispatch.ps1, .codex/hooks/pretooluse-dispatch.json

## Related fix
test_every_psscriptroot_occurrence_is_recognized reported the two '-HooksDirectory $PSScriptRoot' arguments of the entry scripts as unrecognized; both entry scripts now assign '$ScriptRoot = $PSScriptRoot' (a form the scanner names) and pass $ScriptRoot. Behavior is unchanged (entry-script suites and guard completeness pass).

## Remaining expected failure
- claude-settings: registers a single PreToolUse dispatcher entry without a timeout key ([P7-T1] moves enforce-owner-directive-pass-down.ps1 into the registry).
