# Consistency checks — main-sync cycle 1 ([P1-T12])

Timestamp: 2026-11-14T07-52
Command: sh SCRATCH/issue-1159-c1-consistency.sh -- git merge-base origin/main HEAD; registry regeneration at the merge base with SCRATCH/issue-1159-genreg.ps1 and cmp against both committed registries; sha256sum of the six execution-environment brief copies and of every repository/bundle pair of the .claude and .codex paths that differ from the merge base (plus the lib-root DiscoveryCapability.psm1 copy); wc -l of every file differing from the merge base and of every file this cycle changed; git diff --name-status against the merge base (working tree) and git status --porcelain; git diff --name-status of the three cost-artifact patterns against the cycle-start commit (subject 'docs(1159): record main-sync remediation cycle 1 inputs'); comparison of the name-status path set with the pre-cycle set (previous merge base to the commit whose subject is 'docs(1159): record consistency, self-review and AC check-off ([P7-T8], [P7-T9])')
EXIT_CODE: 0
Output Summary: Merge base 2c8dee6dd3a82f210561d9efe623767ae902de51. Both registries equal, in group and hook order, the PreToolUse blocks of .claude/settings.json and .codex/config.toml at the merge base. The six brief copies share SHA-256 467bd7f95c0c066eccf45be3232d02928af04af5e4489f7e3245164fe3128672. 52 repository/bundle pairs are byte-equal, and 0 differ or lack a bundle copy. Those 52 pairs cover the approved [P6-T1] and [P7-T1] pairs and the [P1-T6] pairs, including the edited enforce-model-routing-receipt-docs.ps1. The largest file this cycle changed is 238 lines (enforce-model-routing-receipt-docs.ps1 and its bundle copy), so no file above 800 lines. The one non-Markdown file above 800 lines in the branch diff is the stored ledger patch docs/engineering/process-reductions/patches/0010-early-dependent-starts.patch (3492 lines, patch data), unchanged by this cycle and recorded identically by the pre-cycle consistency record. The name-status diff against the merge base (working tree) has 219 paths. Against the pre-cycle set, 18 paths were added and 0 removed. The added paths are the edited hook, its bundle copy, the remediation inputs and plan, and this cycle's evidence files, all named by the plan or listed by main-integration.2026-11-14T07-28.md. git status --porcelain shows only those paths, since the cycle is uncommitted at this point. Unnamed paths: none. Cost artifacts (evidence/regression-testing/hook-process-cost.*.md, evidence/baseline/hook-process-cost.*.md, evidence/other/pr-cost-summary.*.md): no diff against the cycle-start commit.

## Brief copies (SHA-256)
- `.claude/skills/execution-environment/SKILL.md`: 467bd7f95c0c066eccf45be3232d02928af04af5e4489f7e3245164fe3128672
- `.agents/skills/execution-environment/SKILL.md`: 467bd7f95c0c066eccf45be3232d02928af04af5e4489f7e3245164fe3128672
- `.github/skills/execution-environment/SKILL.md`: 467bd7f95c0c066eccf45be3232d02928af04af5e4489f7e3245164fe3128672
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`: 467bd7f95c0c066eccf45be3232d02928af04af5e4489f7e3245164fe3128672
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`: 467bd7f95c0c066eccf45be3232d02928af04af5e4489f7e3245164fe3128672
- `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md`: 467bd7f95c0c066eccf45be3232d02928af04af5e4489f7e3245164fe3128672

## Repository/bundle pairs (SHA-256 of the pair)
- equal `.claude/hooks/check-powershell-test-purity.ps1`: 2caf28d0a3cbfcf9f05a7affa5fdf323254146b6d4ed3b914a2e758930a362ed
- equal `.claude/hooks/check-python-test-purity.ps1`: 389f864c56f11c194c3dfe012c37264435224b1c2a5aef0db7301f3ca0d42c2d
- equal `.claude/hooks/enforce-checkpoint-monotonic.ps1`: afbf7cf7d5e7ee0329a5b877df6059d7403f0334eda2d6c3d0ab6f76ee40bbd9
- equal `.claude/hooks/enforce-completion-consistency.ps1`: 0217119cfa2edfb51950d1ca0aea5e47ee1906d96d46f1f1fabdae2a33835880
- equal `.claude/hooks/enforce-discovery-artifact-gate.ps1`: 6e43b02e9e1e8f5623ac526d77495918ddfb3fe30694de87fea1d9ce1aa9f67c
- equal `.claude/hooks/enforce-discovery-planning-gate.ps1`: 190c3bc41bc088d9a60c966e0948b66b031465d481adf80de320845b95b8db2a
- equal `.claude/hooks/enforce-docs-complete-gate.ps1`: 64f663e9da3fdcb49613dbd77c9182b75fceaa49d520e5c7355015c46ec4fbdd
- equal `.claude/hooks/enforce-docs-role-write-scope.ps1`: 3e045baba4ad08fef7bc2fa38766a7da9f6b4f7d49abbd678ac2808d1ae021ee
- equal `.claude/hooks/enforce-epic-invocation-origin.ps1`: 1d3dcb87783a7a54db3ac08c18aac96b0b727a3cbae29452718f7ba91e69e5b4
- equal `.claude/hooks/enforce-epic-merge-gate-resolution.ps1`: a2eee93306d201a80a8e7bf524ec50b4c4b6534f064ac00f6f02115be8a5f53c
- equal `.claude/hooks/enforce-epic-merge-gate.ps1`: 9893837b36570b0545af37e744c386fc6b8ad43e4b6f47a2cdf7155214b842dd
- equal `.claude/hooks/enforce-epic-wave-barrier.ps1`: eeedcad6bdf4d95c81a14a40960f28adbccd3013e67a93d26432a7f5443a78fb
- equal `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1`: 6afa0e9d955c7bb53bd12d71a364a6fc087f3cfb4afb4f1c1ecdfa9468702400
- equal `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`: 2c2eedd8981f0ecb4123a16b617cee78bc6272eb51ff73dd75a1a8fd656b13e2
- equal `.claude/hooks/enforce-evidence-locations.ps1`: fe4573e1cf18667eeaf8b6c3ad1191470539f1693cdbb666d63a5be06da509a2
- equal `.claude/hooks/enforce-feature-folder-order.ps1`: 2db3807014f77379cfaa8bf921610d04ce2f44606d0e72996c860f6442192a47
- equal `.claude/hooks/enforce-file-size-limit.ps1`: bec3c4a191089fa4752543850194321928559707e5d08ca5e36416c0034d810a
- equal `.claude/hooks/enforce-mermaid-validation.ps1`: 49c9e2cd3b25468387e49802441ac1b47f88939487ec7a63ea1edd88ba7d413b
- equal `.claude/hooks/enforce-model-routing-receipt-docs.ps1`: 125d4210a39309d71d6dcf2bd51d67c03cab4ddc86c6e1f846940e18c5ed8d74
- equal `.claude/hooks/enforce-model-routing-receipt.ps1`: e74a6a54bd8d85ba75266a859e6afd308cfaca287454a185f69a4d8e084e6539
- equal `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`: 43f67d56ebdc8684f90918a9d90adaf61a70fff08723320e8011b7e5547cb2a9
- equal `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`: 0e148e5f34460646d6279c67157e3c585d8e409f3fce1d1c8dc69ad3774ebae1
- equal `.claude/hooks/enforce-owner-directive-pass-down.ps1`: 3f1b6c40e73d347d9bfbea31dfbef65d381340c8e82f39e68949219f5e4628d3
- equal `.claude/hooks/enforce-parallel-abandon-gate.ps1`: 0bdf11627bcdf99e87f4f5393aa229b29b7850b6dfd062933c956a8c0dbdbf2b
- equal `.claude/hooks/enforce-parallel-cohort-barrier.ps1`: 560bf93a001a0e57ea1500e4189f37973b9d31c0da2ac82cdff2a91abc667b07
- equal `.claude/hooks/enforce-parallel-drift-gate.ps1`: 70e42227306b663ac7dacf94865515b6d6f205aac413ad8888c3618fa45d3956
- equal `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`: 38f1df0e90301f5a5cc3d093dcd4f4c7836c526134290e2c170ffe0b96cf6f3a
- equal `.claude/hooks/enforce-powershell-batch-budget.ps1`: 8aaf1b6d27b7e695ee0e961a13ef3640f50ab58c740ca4fb9adb19f5d5d81ec4
- equal `.claude/hooks/enforce-pr-author-skill.cleanup.ps1`: 3dd5ea23c2de1bbc60e603d5d9e084e5289ee0c250e2b984306701db71c91589
- equal `.claude/hooks/enforce-pr-author-skill.ps1`: 4ce22f0db76992297badb834d369ea183e6036d7d6399473dc282054c1454f2d
- equal `.claude/hooks/enforce-prd-feature-before-planner.ps1`: 2edd33d351c58d1896bf8c67ad1ec83177a7941d00c66349164a25b3ca5bd4a0
- equal `.claude/hooks/enforce-promotion-mcp-only.ps1`: 14fbb123e5ce329eb9d1010b5343554c7aef686a892125720300d05ce63ab7b8
- equal `.claude/hooks/enforce-python-batch-budget.ps1`: f2c9cc613ad288c99451174ae358eb03f8c419eb1623779e967e1e99f0a6a210
- equal `.claude/hooks/enforce-worktree-poetry-venv.ps1`: 622ecb0c18ac7de895f309331f6035a7d57fe2c389c87737c3ae259486e0401b
- equal `.claude/hooks/invoke-pretooluse-dispatch.ps1`: 440d4183e14d52522dacb5c95de8243487d058803ccc621091395e1e2957c4e4
- equal `.claude/hooks/pretooluse-dispatch.json`: e6995349ba70cb93be0e0878cdf5061fcab3b4888ff5c9699348ace4cb7590f2
- equal `.claude/hooks/subagentstop-target-worktree.ps1`: 37f868cd5fd64c19eb72a9f042f5ccefc5d43013698139b0d1f131ca3ef5b450
- equal `.claude/hooks/validate-bash.ps1`: 2707e5c6f8fa0079005e45dfe3572c1546162d737fac1b90c7e33cef43f8433e
- equal `.claude/lib/discovery-validation/DiscoveryCapability.psm1`: 908c99a20168bc714f9761945cea4b3aa362996b4b86aace297de8e3e0b99820
- equal `.claude/lib/hook-dispatch/HookDispatch.psm1`: 41ce68603650829be3984cf7cbec14701f19cb31e4d0a6a4d98f13f4726c7758
- equal `.claude/lib/hook-dispatch/HookDispatchRunner.psm1`: 007fdde97e0d93cae3dce3519d1a720481a56989fc468e26e672287bcdad7980
- equal `.claude/settings.json`: 634ef99e582db29f6df83af859c3cd78efa0d66e74635610d80c20370a33a750
- equal `.claude/skills/execution-environment/SKILL.md`: 467bd7f95c0c066eccf45be3232d02928af04af5e4489f7e3245164fe3128672
- equal `.codex/config.toml`: bd5714d898f7723d9579afe88c754be38e6b468975e2bec9e2f0a235a2cc5037
- equal `.codex/hooks/enforce-discovery-artifact-gate.ps1`: 3fa605f5726a9c9376c707f24e1587500d3ce35486b225cd14ee248ce442c037
- equal `.codex/hooks/enforce-discovery-planning-gate.ps1`: 0bfb12e3c16aaba87e53dd27776f4839f66bf2c8960f8e8b54b9d3deb26bfef1
- equal `.codex/hooks/enforce-evidence-locations.ps1`: 46b0e3fd384fda366ae78f248acfb3ae3269ea278aa7c60c07100c4bd7c4e197
- equal `.codex/hooks/enforce-file-size-limit.ps1`: 221dc5f3749ba23c536dee0562a8130c000ce7bd84570c99d167695bfcab5fe3
- equal `.codex/hooks/hook-dispatch.ps1`: 58c78a2142a3f11bd7b870898638c51c9487d774b277ce1d2626e97e9b751119
- equal `.codex/hooks/invoke-pretooluse-dispatch.ps1`: e5b7253cb855efb1aa7cf2b038d234e0e322a34febfa2e4058ad029852605133
- equal `.codex/hooks/pretooluse-dispatch.json`: dbd2497812b8ba3f1d2b69ed6f532ca6ea5af6b2d9c648906fadbe3e82ad9afe
- equal `extensions/drm-copilot/resources/lib/discovery-validation/DiscoveryCapability.psm1`: 908c99a20168bc714f9761945cea4b3aa362996b4b86aace297de8e3e0b99820

## Physical line counts of files this cycle changed
- 238 `.claude/hooks/enforce-model-routing-receipt-docs.ps1`
- 46 `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/baseline/d13-tail-output.2026-11-14T07-19.md`
- 19 `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/other/d6-module-audit.2026-11-14T07-19.md`
- 12 `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/other/main-sync-registrations.2026-11-14T07-09.md`
- 23 `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/other/main-sync-sets.2026-11-14T07-17.md`
- 16 `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/other/preflight-fixes.2026-11-14T07-05.md`
- 6 `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/other/task-check.cycle1.P0-T1.2026-11-14T07-07.md`
- 6 `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/other/task-check.cycle1.P0-T2.2026-11-14T07-08.md`
- 6 `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/other/task-check.cycle1.P0-T3.2026-11-14T07-09.md`
- 6 `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/other/task-check.cycle1.P0-T4.2026-11-14T07-17.md`
- 6 `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/other/task-check.cycle1.P0-T5.2026-11-14T07-19.md`
- 6 `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/other/task-check.cycle1.P0-T6.2026-11-14T07-19.md`
- 35 `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/remediation-baseline/main-sync-merge.2026-11-14T07-05.md`
- 35 `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/remediation-baseline/main-sync-merge.2026-11-14T07-06.md`
- 31 `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/remediation-baseline/powershell-static.2026-11-14T07-08.md`
- 61 `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/remediation-plan.2026-11-14T06-51.md`
- 238 `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-model-routing-receipt-docs.ps1`
- 42 `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/other/main-integration.2026-11-14T07-28.md`
- 10 `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/other/task-check.cycle1.P1-T1.2026-11-14T07-26.md`
- 6 `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/other/task-check.cycle1.P1-T10.2026-11-14T07-50.md`
- 6 `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/other/task-check.cycle1.P1-T11.2026-11-14T07-51.md`
- 6 `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/other/task-check.cycle1.P1-T2.2026-11-14T07-26.md`
- 6 `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/other/task-check.cycle1.P1-T3.2026-11-14T07-26.md`
- 6 `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/other/task-check.cycle1.P1-T4.2026-11-14T07-26.md`
- 15 `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/other/task-check.cycle1.P1-T5.2026-11-14T07-27.md`
- 6 `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/other/task-check.cycle1.P1-T6.2026-11-14T07-28.md`
- 6 `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/other/task-check.cycle1.P1-T7.2026-11-14T07-29.md`
- 6 `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/other/task-check.cycle1.P1-T8.2026-11-14T07-29.md`
- 6 `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/other/task-check.cycle1.P1-T9.2026-11-14T07-45.md`
- 6 `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/qa-gates/leak-scan.2026-11-14T07-51.md`
- 68 `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/qa-gates/pester.2026-11-14T07-45.md`
- 12 `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/qa-gates/powershell-static.2026-11-14T07-29.md`
- 6 `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/qa-gates/pytest.2026-11-14T07-50.md`
- 12 `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/qa-gates/python-static.2026-11-14T07-29.md`
- 6 `docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/regression-testing/d13-remediation.2026-11-14T07-26.md`

## Paths added to the name-status diff relative to the pre-cycle set
- .claude/hooks/enforce-model-routing-receipt-docs.ps1
- docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/baseline/d13-tail-output.2026-11-14T07-19.md
- docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/other/d6-module-audit.2026-11-14T07-19.md
- docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/other/main-sync-registrations.2026-11-14T07-09.md
- docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/other/main-sync-sets.2026-11-14T07-17.md
- docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/other/preflight-fixes.2026-11-14T07-05.md
- docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/other/task-check.cycle1.P0-T1.2026-11-14T07-07.md
- docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/other/task-check.cycle1.P0-T2.2026-11-14T07-08.md
- docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/other/task-check.cycle1.P0-T3.2026-11-14T07-09.md
- docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/other/task-check.cycle1.P0-T4.2026-11-14T07-17.md
- docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/other/task-check.cycle1.P0-T5.2026-11-14T07-19.md
- docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/other/task-check.cycle1.P0-T6.2026-11-14T07-19.md
- docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/remediation-baseline/main-sync-merge.2026-11-14T07-05.md
- docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/remediation-baseline/main-sync-merge.2026-11-14T07-06.md
- docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/remediation-baseline/powershell-static.2026-11-14T07-08.md
- docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/remediation-inputs.2026-11-14T06-51.md
- docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/remediation-plan.2026-11-14T06-51.md
- extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-model-routing-receipt-docs.ps1

## git status --porcelain at check time
     M .claude/hooks/enforce-model-routing-receipt-docs.ps1
     M docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/remediation-plan.2026-11-14T06-51.md
     M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-model-routing-receipt-docs.ps1
    ?? docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/other/main-integration.2026-11-14T07-28.md
    ?? docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/other/task-check.cycle1.P1-T1.2026-11-14T07-26.md
    ?? docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/other/task-check.cycle1.P1-T10.2026-11-14T07-50.md
    ?? docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/other/task-check.cycle1.P1-T11.2026-11-14T07-51.md
    ?? docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/other/task-check.cycle1.P1-T2.2026-11-14T07-26.md
    ?? docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/other/task-check.cycle1.P1-T3.2026-11-14T07-26.md
    ?? docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/other/task-check.cycle1.P1-T4.2026-11-14T07-26.md
    ?? docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/other/task-check.cycle1.P1-T5.2026-11-14T07-27.md
    ?? docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/other/task-check.cycle1.P1-T6.2026-11-14T07-28.md
    ?? docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/other/task-check.cycle1.P1-T7.2026-11-14T07-29.md
    ?? docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/other/task-check.cycle1.P1-T8.2026-11-14T07-29.md
    ?? docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/other/task-check.cycle1.P1-T9.2026-11-14T07-45.md
    ?? docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/qa-gates/leak-scan.2026-11-14T07-51.md
    ?? docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/qa-gates/pester.2026-11-14T07-45.md
    ?? docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/qa-gates/powershell-static.2026-11-14T07-29.md
    ?? docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/qa-gates/pytest.2026-11-14T07-50.md
    ?? docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/qa-gates/python-static.2026-11-14T07-29.md
    ?? docs/features/active/2026-11-09-hook-dispatcher-process-cost-1159/evidence/regression-testing/d13-remediation.2026-11-14T07-26.md
