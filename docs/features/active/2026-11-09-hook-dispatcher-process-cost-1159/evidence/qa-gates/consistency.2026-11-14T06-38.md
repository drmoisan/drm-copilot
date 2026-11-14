# End-state consistency checks ([P7-T8])

Timestamp: 2026-11-14T06-38
Command: sh SCRATCH/issue-1159-consistency.sh -- git merge-base origin/main HEAD; registry regeneration from the merge base with SCRATCH/issue-1159-genreg.ps1 and cmp against both committed registries; sha256sum of the six brief copies and of each repository/bundle pair of the branch's .claude and .codex changes plus the second DiscoveryCapability.psm1 bundle copy; wc -l over every new or changed file; git diff --name-status <merge base> HEAD; git status --porcelain
EXIT_CODE: 0
Output Summary: merge base 063504dc4b2ea08a2c5bd39b57d70ce5963815ed (recomputed after [P7-T1]). Both registries equal, in group and hook order, the PreToolUse blocks of .claude/settings.json and .codex/config.toml at the merge base (byte-equal regeneration). Six brief copies share SHA-256 689652247366b3202d8c589ecbffbfd7ec2347cd90634ce82ac6591d40650e90. 51 repository/bundle pairs are byte-equal; 0 differ or lack a bundle copy. No code, test or configuration file exceeds 800 physical lines (largest .ps1: 593, tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1); the one non-Markdown file above 800 lines is the stored ledger patch docs/engineering/process-reductions/patches/0010-early-dependent-starts.patch (3492 lines, patch data, same line count as at the merge base). 200 paths in the name-status diff, git status --porcelain empty; every path is named by the plan, belongs to a [P0-T2] derived set, or is listed by main-integration.2026-11-14T06-37.md.

## Registry reproduction (AC 2)
- .claude/hooks/pretooluse-dispatch.json: equal to the hooks.PreToolUse groups of .claude/settings.json at 063504dc4 (6 groups, owner-directive group last).
- .codex/hooks/pretooluse-dispatch.json: equal to the [[hooks.PreToolUse]] tables of .codex/config.toml at 063504dc4 (4 groups).

## Brief copies (SHA-256)
- `.claude/skills/execution-environment/SKILL.md`: 689652247366b3202d8c589ecbffbfd7ec2347cd90634ce82ac6591d40650e90
- `.agents/skills/execution-environment/SKILL.md`: 689652247366b3202d8c589ecbffbfd7ec2347cd90634ce82ac6591d40650e90
- `.github/skills/execution-environment/SKILL.md`: 689652247366b3202d8c589ecbffbfd7ec2347cd90634ce82ac6591d40650e90
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`: 689652247366b3202d8c589ecbffbfd7ec2347cd90634ce82ac6591d40650e90
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`: 689652247366b3202d8c589ecbffbfd7ec2347cd90634ce82ac6591d40650e90
- `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md`: 689652247366b3202d8c589ecbffbfd7ec2347cd90634ce82ac6591d40650e90

## Repository/bundle pairs (SHA-256 of the repository file; the bundle copy is byte-equal)
- `.claude/hooks/check-powershell-test-purity.ps1`: 2caf28d0a3cbfcf9f05a7affa5fdf323254146b6d4ed3b914a2e758930a362ed
- `.claude/hooks/check-python-test-purity.ps1`: 389f864c56f11c194c3dfe012c37264435224b1c2a5aef0db7301f3ca0d42c2d
- `.claude/hooks/enforce-checkpoint-monotonic.ps1`: afbf7cf7d5e7ee0329a5b877df6059d7403f0334eda2d6c3d0ab6f76ee40bbd9
- `.claude/hooks/enforce-completion-consistency.ps1`: 0217119cfa2edfb51950d1ca0aea5e47ee1906d96d46f1f1fabdae2a33835880
- `.claude/hooks/enforce-discovery-artifact-gate.ps1`: 6e43b02e9e1e8f5623ac526d77495918ddfb3fe30694de87fea1d9ce1aa9f67c
- `.claude/hooks/enforce-discovery-planning-gate.ps1`: 190c3bc41bc088d9a60c966e0948b66b031465d481adf80de320845b95b8db2a
- `.claude/hooks/enforce-docs-complete-gate.ps1`: ed63928555c02e2108b4186d9e9db215a621b477cc4f0ce38ec9a1d630e685e6
- `.claude/hooks/enforce-docs-role-write-scope.ps1`: 3e045baba4ad08fef7bc2fa38766a7da9f6b4f7d49abbd678ac2808d1ae021ee
- `.claude/hooks/enforce-epic-invocation-origin.ps1`: 1d3dcb87783a7a54db3ac08c18aac96b0b727a3cbae29452718f7ba91e69e5b4
- `.claude/hooks/enforce-epic-merge-gate-resolution.ps1`: a2eee93306d201a80a8e7bf524ec50b4c4b6534f064ac00f6f02115be8a5f53c
- `.claude/hooks/enforce-epic-merge-gate.ps1`: 9893837b36570b0545af37e744c386fc6b8ad43e4b6f47a2cdf7155214b842dd
- `.claude/hooks/enforce-epic-wave-barrier.ps1`: eeedcad6bdf4d95c81a14a40960f28adbccd3013e67a93d26432a7f5443a78fb
- `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1`: 6afa0e9d955c7bb53bd12d71a364a6fc087f3cfb4afb4f1c1ecdfa9468702400
- `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`: 2c2eedd8981f0ecb4123a16b617cee78bc6272eb51ff73dd75a1a8fd656b13e2
- `.claude/hooks/enforce-evidence-locations.ps1`: fe4573e1cf18667eeaf8b6c3ad1191470539f1693cdbb666d63a5be06da509a2
- `.claude/hooks/enforce-feature-folder-order.ps1`: 2db3807014f77379cfaa8bf921610d04ce2f44606d0e72996c860f6442192a47
- `.claude/hooks/enforce-file-size-limit.ps1`: bec3c4a191089fa4752543850194321928559707e5d08ca5e36416c0034d810a
- `.claude/hooks/enforce-mermaid-validation.ps1`: 49c9e2cd3b25468387e49802441ac1b47f88939487ec7a63ea1edd88ba7d413b
- `.claude/hooks/enforce-model-routing-receipt.ps1`: 1bb0fe73752118d72c50ff62599816c547c14c0afa4ec0f595f2228b3bee00b6
- `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`: 43f67d56ebdc8684f90918a9d90adaf61a70fff08723320e8011b7e5547cb2a9
- `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`: 691a46e2c4bd6b7c5db142c9678b5f8ef41857e85021ced3d8ac5f8ea24d90e2
- `.claude/hooks/enforce-owner-directive-pass-down.ps1`: 3f1b6c40e73d347d9bfbea31dfbef65d381340c8e82f39e68949219f5e4628d3
- `.claude/hooks/enforce-parallel-abandon-gate.ps1`: 0bdf11627bcdf99e87f4f5393aa229b29b7850b6dfd062933c956a8c0dbdbf2b
- `.claude/hooks/enforce-parallel-cohort-barrier.ps1`: 560bf93a001a0e57ea1500e4189f37973b9d31c0da2ac82cdff2a91abc667b07
- `.claude/hooks/enforce-parallel-drift-gate.ps1`: 70e42227306b663ac7dacf94865515b6d6f205aac413ad8888c3618fa45d3956
- `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`: 38f1df0e90301f5a5cc3d093dcd4f4c7836c526134290e2c170ffe0b96cf6f3a
- `.claude/hooks/enforce-powershell-batch-budget.ps1`: 8aaf1b6d27b7e695ee0e961a13ef3640f50ab58c740ca4fb9adb19f5d5d81ec4
- `.claude/hooks/enforce-pr-author-skill.cleanup.ps1`: 3dd5ea23c2de1bbc60e603d5d9e084e5289ee0c250e2b984306701db71c91589
- `.claude/hooks/enforce-pr-author-skill.ps1`: 4ce22f0db76992297badb834d369ea183e6036d7d6399473dc282054c1454f2d
- `.claude/hooks/enforce-prd-feature-before-planner.ps1`: 2edd33d351c58d1896bf8c67ad1ec83177a7941d00c66349164a25b3ca5bd4a0
- `.claude/hooks/enforce-promotion-mcp-only.ps1`: 14fbb123e5ce329eb9d1010b5343554c7aef686a892125720300d05ce63ab7b8
- `.claude/hooks/enforce-python-batch-budget.ps1`: f2c9cc613ad288c99451174ae358eb03f8c419eb1623779e967e1e99f0a6a210
- `.claude/hooks/enforce-worktree-poetry-venv.ps1`: 622ecb0c18ac7de895f309331f6035a7d57fe2c389c87737c3ae259486e0401b
- `.claude/hooks/invoke-pretooluse-dispatch.ps1`: 440d4183e14d52522dacb5c95de8243487d058803ccc621091395e1e2957c4e4
- `.claude/hooks/pretooluse-dispatch.json`: e6995349ba70cb93be0e0878cdf5061fcab3b4888ff5c9699348ace4cb7590f2
- `.claude/hooks/subagentstop-target-worktree.ps1`: 37f868cd5fd64c19eb72a9f042f5ccefc5d43013698139b0d1f131ca3ef5b450
- `.claude/hooks/validate-bash.ps1`: 2707e5c6f8fa0079005e45dfe3572c1546162d737fac1b90c7e33cef43f8433e
- `.claude/lib/discovery-validation/DiscoveryCapability.psm1`: 908c99a20168bc714f9761945cea4b3aa362996b4b86aace297de8e3e0b99820
- `.claude/lib/hook-dispatch/HookDispatch.psm1`: 41ce68603650829be3984cf7cbec14701f19cb31e4d0a6a4d98f13f4726c7758
- `.claude/lib/hook-dispatch/HookDispatchRunner.psm1`: 007fdde97e0d93cae3dce3519d1a720481a56989fc468e26e672287bcdad7980
- `.claude/settings.json`: 634ef99e582db29f6df83af859c3cd78efa0d66e74635610d80c20370a33a750
- `.claude/skills/execution-environment/SKILL.md`: 689652247366b3202d8c589ecbffbfd7ec2347cd90634ce82ac6591d40650e90
- `.codex/config.toml`: bd5714d898f7723d9579afe88c754be38e6b468975e2bec9e2f0a235a2cc5037
- `.codex/hooks/enforce-discovery-artifact-gate.ps1`: 3fa605f5726a9c9376c707f24e1587500d3ce35486b225cd14ee248ce442c037
- `.codex/hooks/enforce-discovery-planning-gate.ps1`: 0bfb12e3c16aaba87e53dd27776f4839f66bf2c8960f8e8b54b9d3deb26bfef1
- `.codex/hooks/enforce-evidence-locations.ps1`: 46b0e3fd384fda366ae78f248acfb3ae3269ea278aa7c60c07100c4bd7c4e197
- `.codex/hooks/enforce-file-size-limit.ps1`: 221dc5f3749ba23c536dee0562a8130c000ce7bd84570c99d167695bfcab5fe3
- `.codex/hooks/hook-dispatch.ps1`: 58c78a2142a3f11bd7b870898638c51c9487d774b277ce1d2626e97e9b751119
- `.codex/hooks/invoke-pretooluse-dispatch.ps1`: e5b7253cb855efb1aa7cf2b038d234e0e322a34febfa2e4058ad029852605133
- `.codex/hooks/pretooluse-dispatch.json`: dbd2497812b8ba3f1d2b69ed6f532ca6ea5af6b2d9c648906fadbe3e82ad9afe
- `extensions/drm-copilot/resources/lib/discovery-validation/DiscoveryCapability.psm1`: 908c99a20168bc714f9761945cea4b3aa362996b4b86aace297de8e3e0b99820

## Largest new or changed files (physical lines)
- 3492 `docs/engineering/process-reductions/patches/0010-early-dependent-starts.patch`
- 593 `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`
- 573 `tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1`
- 535 `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1`
- 535 `.claude/hooks/enforce-python-batch-budget.ps1`
- 532 `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1`
- 532 `.claude/hooks/enforce-powershell-batch-budget.ps1`
- 505 `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-consistency.ps1`
- 505 `.claude/hooks/enforce-completion-consistency.ps1`
- 501 `extensions/drm-copilot/resources/lib/discovery-validation/DiscoveryCapability.psm1`
- 501 `extensions/drm-copilot/resources/claude-customizations/.claude/lib/discovery-validation/DiscoveryCapability.psm1`
- 501 `.claude/lib/discovery-validation/DiscoveryCapability.psm1`

## Path classification of the name-status diff
- Plan-named: the Phase 0-7 file sets (dispatcher modules, entry scripts, registries, settings and config, DiscoveryCapability.psm1, measurement tool, Phase 4 re-targeted tests, parity suite and corpus, README.md, docs/engineering/claude-code-architecture.md, six brief copies, bundle copies and both core.json manifests, feature-folder evidence and plan).
- [P0-T2] derived sets: the D6 set hooks and helpers and the D13 set hooks, with their suites where tail coverage rows were added.
- Listed by main-integration.2026-11-14T06-37.md: .claude/hooks/enforce-owner-directive-pass-down.ps1, .claude/hooks/subagentstop-target-worktree.ps1, the five 1163-changed set-(b) files, tests/scripts/claude-runtime/owner-directive-pass-down.Registration.Tests.ps1, docs/engineering/process-reductions/patches/0010-early-dependent-starts.patch, tests/fixtures/dev-tools/hook-process-cost/stdin-exit-hook.ps1.
- Unnamed: none.
