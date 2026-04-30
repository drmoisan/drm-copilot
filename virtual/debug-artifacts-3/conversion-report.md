# Conversion Report

- Mode: `review`
- Source ecosystem: `github-copilot`
- Source root: `.`
- Destination root: `review-only`
- Artifact root: `virtual/debug-artifacts-3`
- Mapping records: 105
- Validation findings: 0 (0 blocking)

## Mapping Topology

### Shared Destination Nodes

Source and destination nodes are both deduplicated in this view.

```mermaid
graph LR
    source_0[".github/agents/5.1-Beast-adjusted.agent.md"]
    destination_0[".agents/skills/github-actions/SKILL.md"]
    source_0 --> destination_0
    destination_1[".agents/skills/powershell-code-change/SKILL.md"]
    source_0 --> destination_1
    destination_2[".agents/skills/powershell-unit-test/SKILL.md"]
    source_0 --> destination_2
    destination_3[".agents/skills/python-code-change/SKILL.md"]
    source_0 --> destination_3
    destination_4[".agents/skills/python-unit-test/SKILL.md"]
    source_0 --> destination_4
    destination_5[".codex/agents/5.1-Beast-adjusted.toml"]
    source_0 --> destination_5
    destination_6["AGENTS.md"]
    source_0 --> destination_6
    source_7[".github/agents/5.1-Thinking-Beast-Mode-adjusted.agent.md"]
    source_7 --> destination_0
    source_7 --> destination_1
    source_7 --> destination_2
    source_7 --> destination_3
    source_7 --> destination_4
    destination_12[".codex/agents/5.1-Thinking-Beast-Mode-adjusted.toml"]
    source_7 --> destination_12
    source_7 --> destination_6
    source_14[".github/agents/Powershell DI Unit Test Engineer.agent.md"]
    destination_14[".codex/agents/Powershell DI Unit Test Engineer.toml"]
    source_14 --> destination_14
    source_15[".github/agents/api-architect.agent.md"]
    destination_15[".codex/agents/api-architect.toml"]
    source_15 --> destination_15
    source_16[".github/agents/atomic_executor.agent.md"]
    destination_16[".codex/agents/atomic-executor.toml"]
    source_16 --> destination_16
    source_16 --> destination_6
    source_18[".github/agents/atomic_planning.agent.md"]
    destination_18[".codex/agents/atomic-planning.toml"]
    source_18 --> destination_18
    source_19[".github/agents/commentary-remediation.agent.md"]
    source_19 --> destination_3
    destination_20[".agents/skills/self-explanatory-code-commenting/SKILL.md"]
    source_19 --> destination_20
    destination_21[".codex/agents/commentary-remediation.toml"]
    source_19 --> destination_21
    source_19 --> destination_6
    source_23[".github/agents/commit-steward.agent.md"]
    destination_23[".codex/agents/commit-steward.toml"]
    source_23 --> destination_23
    source_24[".github/agents/csharp-atomic-executor.agent.md"]
    destination_24[".agents/skills/csharp-code-change/SKILL.md"]
    source_24 --> destination_24
    destination_25[".agents/skills/csharp-unit-test/SKILL.md"]
    source_24 --> destination_25
    destination_26[".codex/agents/csharp-atomic-executor.toml"]
    source_24 --> destination_26
    source_24 --> destination_6
    source_28[".github/agents/csharp-atomic-planning.agent.md"]
    destination_28[".codex/agents/csharp-atomic-planning.toml"]
    source_28 --> destination_28
    source_29[".github/agents/csharp-orchestrator.agent.md"]
    destination_29[".agents/skills/atomic-plan-contract/SKILL.md"]
    source_29 --> destination_29
    destination_30[".codex/agents/csharp-orchestrator.toml"]
    source_29 --> destination_30
    destination_31[".codex/agents/feature-review.toml"]
    source_29 --> destination_31
    source_32[".github/agents/csharp-typed-engineer.agent.md"]
    source_32 --> destination_29
    source_32 --> destination_24
    source_32 --> destination_25
    destination_35[".codex/agents/csharp-typed-engineer.toml"]
    source_32 --> destination_35
    source_32 --> destination_6
    source_37[".github/agents/epic-review.agent.md"]
    destination_37[".codex/agents/epic-review.toml"]
    source_37 --> destination_37
    source_38[".github/agents/expert-nextjs-developer.agent.md"]
    destination_38[".codex/agents/expert-nextjs-developer.toml"]
    source_38 --> destination_38
    source_39[".github/agents/expert-react-frontend-engineer.agent.md"]
    destination_39[".codex/agents/expert-react-frontend-engineer.toml"]
    source_39 --> destination_39
    source_40[".github/agents/feature-review.agent.md"]
    source_40 --> destination_29
    source_40 --> destination_31
    source_42[".github/agents/gpt-5-beast-mode.agent.md"]
    destination_42[".codex/agents/gpt-5-beast-mode.toml"]
    source_42 --> destination_42
    source_43[".github/agents/hlbpa.agent.md"]
    destination_43[".codex/agents/hlbpa.toml"]
    source_43 --> destination_43
    source_44[".github/agents/mentor.agent.md"]
    destination_44[".codex/agents/mentor.toml"]
    source_44 --> destination_44
    source_45[".github/agents/orchestrator.agent.md"]
    source_45 --> destination_29
    source_45 --> destination_31
    destination_47[".codex/agents/orchestrator.toml"]
    source_45 --> destination_47
    source_48[".github/agents/powershell-atomic-executor.agent.md"]
    source_48 --> destination_1
    source_48 --> destination_2
    destination_50[".codex/agents/powershell-atomic-executor.toml"]
    source_48 --> destination_50
    source_48 --> destination_6
    source_52[".github/agents/powershell-atomic-planning.agent.md"]
    destination_52[".codex/agents/powershell-atomic-planning.toml"]
    source_52 --> destination_52
    source_53[".github/agents/powershell-orchestrator.agent.md"]
    source_53 --> destination_29
    source_53 --> destination_31
    destination_55[".codex/agents/powershell-orchestrator.toml"]
    source_53 --> destination_55
    source_56[".github/agents/powershell-typed-engineer.agent.md"]
    source_56 --> destination_29
    source_56 --> destination_1
    source_56 --> destination_2
    destination_59[".codex/agents/powershell-typed-engineer.toml"]
    source_56 --> destination_59
    source_56 --> destination_6
    source_61[".github/agents/pr-author.agent.md"]
    destination_61[".codex/agents/pr-author.toml"]
    source_61 --> destination_61
    source_62[".github/agents/prd-feature.agent.md"]
    destination_62[".codex/agents/prd-feature.toml"]
    source_62 --> destination_62
    source_63[".github/agents/prd.agent.md"]
    destination_63[".codex/agents/prd.toml"]
    source_63 --> destination_63
    source_64[".github/agents/pytest-unit-test-coding.agent.md"]
    destination_64[".codex/agents/pytest-unit-test-coding.toml"]
    source_64 --> destination_64
    source_65[".github/agents/python-atomic-executor.agent.md"]
    source_65 --> destination_3
    destination_66[".agents/skills/python-suppressions/SKILL.md"]
    source_65 --> destination_66
    source_65 --> destination_4
    destination_68[".codex/agents/python-atomic-executor.toml"]
    source_65 --> destination_68
    source_65 --> destination_6
    source_70[".github/agents/python-atomic-planning.agent.md"]
    destination_70[".codex/agents/python-atomic-planning.toml"]
    source_70 --> destination_70
    source_71[".github/agents/python-execution-only-typed.agent.md"]
    source_71 --> destination_3
    source_71 --> destination_4
    destination_73[".codex/agents/python-execution-only-typed.toml"]
    source_71 --> destination_73
    source_71 --> destination_6
    source_75[".github/agents/python-orchestrator.agent.md"]
    source_75 --> destination_29
    source_75 --> destination_31
    destination_77[".codex/agents/python-orchestrator.toml"]
    source_75 --> destination_77
    source_78[".github/agents/python-typed-engineer.agent.md"]
    source_78 --> destination_3
    source_78 --> destination_4
    destination_80[".codex/agents/python-typed-engineer.toml"]
    source_78 --> destination_80
    source_78 --> destination_6
    source_82[".github/agents/staged-review.agent.md"]
    source_82 --> destination_0
    source_82 --> destination_1
    source_82 --> destination_2
    source_82 --> destination_3
    source_82 --> destination_4
    destination_87[".codex/agents/staged-review.toml"]
    source_82 --> destination_87
    source_82 --> destination_6
    source_89[".github/agents/status_updater.agent.md"]
    destination_89[".codex/agents/status-updater.toml"]
    source_89 --> destination_89
    source_89 --> destination_6
    source_91[".github/agents/task-researcher.agent.md"]
    destination_91[".codex/agents/task-researcher.toml"]
    source_91 --> destination_91
    source_92[".github/agents/tdd-green.agent.md"]
    destination_92[".codex/agents/tdd-green.toml"]
    source_92 --> destination_92
    source_93[".github/agents/tdd-red.agent.md"]
    destination_93[".codex/agents/tdd-red.toml"]
    source_93 --> destination_93
    source_94[".github/agents/tdd-refactor.agent.md"]
    destination_94[".codex/agents/tdd-refactor.toml"]
    source_94 --> destination_94
    source_95[".github/agents/typescript-engineer.agent.md"]
    destination_95[".agents/skills/typescript-code-change/SKILL.md"]
    source_95 --> destination_95
    destination_96[".agents/skills/typescript-suppressions/SKILL.md"]
    source_95 --> destination_96
    destination_97[".agents/skills/typescript-unit-test/SKILL.md"]
    source_95 --> destination_97
    destination_98[".codex/agents/typescript-engineer.toml"]
    source_95 --> destination_98
    source_95 --> destination_6
    source_100[".github/agents/voidbeast-gpt41enhanced.agent.md"]
    destination_100[".codex/agents/voidbeast-gpt41enhanced.toml"]
    source_100 --> destination_100
    source_101[".github/copilot-instructions.md"]
    source_101 --> destination_6
    source_102[".github/instructions/csharp-code-change.instructions.md"]
    source_102 --> destination_24
    source_103[".github/instructions/csharp-unit-test.instructions.md"]
    source_103 --> destination_25
    source_104[".github/instructions/general-code-change.instructions.md"]
    source_104 --> destination_6
    source_105[".github/instructions/general-unit-test.instructions.md"]
    source_105 --> destination_6
    source_106[".github/instructions/github-actions-ci-cd-best-practices.instructions.md"]
    destination_106[".agents/skills/github-actions-ci-cd-best-practices/SKILL.md"]
    source_106 --> destination_106
    source_107[".github/instructions/github-actions.instructions.md"]
    source_107 --> destination_0
    source_108[".github/instructions/powershell-code-change.instructions.md"]
    source_108 --> destination_1
    source_109[".github/instructions/powershell-unit-test.instructions.md"]
    source_109 --> destination_2
    source_110[".github/instructions/python-code-change.instructions.md"]
    source_110 --> destination_3
    source_111[".github/instructions/python-suppressions.instructions.md"]
    source_111 --> destination_66
    source_112[".github/instructions/python-unit-test.instructions.md"]
    source_112 --> destination_4
    source_113[".github/instructions/self-explanatory-code-commenting.instructions.md"]
    source_113 --> destination_20
    source_114[".github/instructions/tonality.instructions.md"]
    source_114 --> destination_6
    source_115[".github/instructions/typescript-code-change.instructions.md"]
    source_115 --> destination_95
    source_116[".github/instructions/typescript-suppressions.instructions.md"]
    source_116 --> destination_96
    source_117[".github/instructions/typescript-unit-test.instructions.md"]
    source_117 --> destination_97
    source_118[".github/prompts/add-educational-comments.prompt.md"]
    destination_118[".agents/skills/add-educational-comments/SKILL.md"]
    source_118 --> destination_118
    source_118 --> destination_118
    destination_120["[no target]"]
    source_118 --> destination_120
    source_121[".github/prompts/breakdown-bug-prd.prompt.md"]
    destination_121[".agents/skills/breakdown-bug-prd/SKILL.md"]
    source_121 --> destination_121
    source_121 --> destination_121
    source_121 --> destination_120
    source_124[".github/prompts/breakdown-epic-arch.prompt.md"]
    destination_124[".agents/skills/breakdown-epic-arch/SKILL.md"]
    source_124 --> destination_124
    source_124 --> destination_124
    source_124 --> destination_120
    source_127[".github/prompts/breakdown-epic-pm.prompt.md"]
    destination_127[".agents/skills/breakdown-epic-pm/SKILL.md"]
    source_127 --> destination_127
    source_127 --> destination_127
    source_127 --> destination_127
    source_127 --> destination_120
    source_131[".github/prompts/breakdown-feature-implementation.prompt.md"]
    destination_131[".agents/skills/breakdown-feature-implementation/SKILL.md"]
    source_131 --> destination_131
    source_131 --> destination_131
    source_131 --> destination_131
    source_131 --> destination_120
    source_135[".github/prompts/breakdown-feature-prd.prompt.md"]
    destination_135[".agents/skills/breakdown-feature-prd/SKILL.md"]
    source_135 --> destination_135
    source_135 --> destination_135
    source_135 --> destination_135
    source_135 --> destination_120
    source_139[".github/prompts/code-exemplars-blueprint-generator.prompt.md"]
    destination_139[".agents/skills/code-exemplars-blueprint-generator/SKILL.md"]
    source_139 --> destination_139
    source_139 --> destination_120
    source_141[".github/prompts/drafts/create-github-issues-feature-from-implementation-plan.prompt.md"]
    destination_141[".agents/skills/create-github-issues-feature-from-implementation-plan/SKILL.md"]
    source_141 --> destination_141
    source_141 --> destination_120
    source_143[".github/prompts/drafts/create-implementation-plan.prompt.md"]
    destination_143[".agents/skills/create-implementation-plan/SKILL.md"]
    source_143 --> destination_143
    source_143 --> destination_120
    source_145[".github/prompts/drafts/create-technical-spike.prompt.md"]
    destination_145[".agents/skills/create-technical-spike/SKILL.md"]
    source_145 --> destination_145
    source_145 --> destination_145
    source_145 --> destination_145
    source_145 --> destination_145
    source_145 --> destination_120
    source_150[".github/prompts/drafts/potential-feature-prd.prompt.md"]
    destination_150[".agents/skills/potential-feature-prd/SKILL.md"]
    source_150 --> destination_150
    source_150 --> destination_150
    source_150 --> destination_120
    source_153[".github/prompts/drafts/update-implementation-plan.prompt.md"]
    destination_153[".agents/skills/update-implementation-plan/SKILL.md"]
    source_153 --> destination_153
    source_153 --> destination_120
    source_155[".github/prompts/execute-hard-lock.prompt.md"]
    destination_155[".codex/hooks/execute-hard-lock.ps1"]
    source_155 --> destination_155
    source_155 --> destination_120
    source_157[".github/prompts/execute-plan-template.md"]
    destination_157[".agents/skills/execute-plan-template/SKILL.md"]
    source_157 --> destination_157
    source_157 --> destination_157
    source_157 --> destination_120
    source_160[".github/prompts/export-chat.prompt.md"]
    source_160 --> destination_120
    source_161[".github/prompts/fillout-prd-feature.prompt.md"]
    destination_161[".agents/skills/fillout-prd-feature/SKILL.md"]
    source_161 --> destination_161
    source_161 --> destination_161
    source_161 --> destination_120
    source_164[".github/prompts/generate-atomic-plan.prompt.md"]
    source_164 --> destination_120
    source_165[".github/prompts/generate-commit-message-repo.prompt.md"]
    destination_165[".agents/skills/generate-commit-message-repo/SKILL.md"]
    source_165 --> destination_165
    source_165 --> destination_165
    source_165 --> destination_120
    source_168[".github/prompts/generate-pr.prompt.md"]
    destination_168[".agents/skills/generate-pr/SKILL.md"]
    source_168 --> destination_168
    source_168 --> destination_168
    source_168 --> destination_168
    source_168 --> destination_168
    destination_172[".codex/hooks/generate-pr.ps1"]
    source_168 --> destination_172
    source_168 --> destination_172
    source_168 --> destination_120
    source_175[".github/prompts/javascript-typescript-jest.prompt.md"]
    source_175 --> destination_120
    source_176[".github/prompts/orchestrate-csharp-work.prompt.md"]
    destination_176[".agents/skills/orchestrate-csharp-work/SKILL.md"]
    source_176 --> destination_176
    source_176 --> destination_176
    source_176 --> destination_120
    source_179[".github/prompts/orchestrate-powershell-work.prompt.md"]
    destination_179[".agents/skills/orchestrate-powershell-work/SKILL.md"]
    source_179 --> destination_179
    source_179 --> destination_179
    source_179 --> destination_120
    source_182[".github/prompts/orchestrate-python-work.prompt.md"]
    destination_182[".agents/skills/orchestrate-python-work/SKILL.md"]
    source_182 --> destination_182
    source_182 --> destination_182
    source_182 --> destination_120
    source_185[".github/prompts/orchestrate-work.prompt.md"]
    destination_185[".agents/skills/orchestrate-work/SKILL.md"]
    source_185 --> destination_185
    source_185 --> destination_185
    source_185 --> destination_120
    source_188[".github/prompts/remediate-comments.prompt.md"]
    destination_188[".agents/skills/remediate-comments/SKILL.md"]
    source_188 --> destination_188
    source_188 --> destination_188
    source_188 --> destination_188
    source_188 --> destination_188
    source_188 --> destination_188
    source_188 --> destination_120
    source_194[".github/prompts/research-issue.prompt.md"]
    destination_194[".agents/skills/research-issue/SKILL.md"]
    source_194 --> destination_194
    source_194 --> destination_194
    source_194 --> destination_120
    source_197[".github/prompts/review-epic.prompt.md"]
    destination_197[".agents/skills/review-epic/SKILL.md"]
    source_197 --> destination_197
    source_197 --> destination_197
    source_197 --> destination_197
    source_197 --> destination_197
    destination_201[".codex/hooks/review-epic.ps1"]
    source_197 --> destination_201
    source_197 --> destination_120
    source_203[".github/prompts/review-feature.prompt.md"]
    destination_203[".agents/skills/review-feature/SKILL.md"]
    source_203 --> destination_203
    source_203 --> destination_203
    source_203 --> destination_203
    source_203 --> destination_203
    destination_207[".codex/hooks/review-feature.ps1"]
    source_203 --> destination_207
    source_203 --> destination_207
    source_203 --> destination_120
    source_210[".github/prompts/review-staged.prompt.md"]
    destination_210[".agents/skills/review-staged/SKILL.md"]
    source_210 --> destination_210
    source_210 --> destination_210
    source_210 --> destination_210
    source_210 --> destination_210
    source_210 --> destination_120
    source_215[".github/prompts/update_status.prompt.md"]
    destination_215[".agents/skills/update-status/SKILL.md"]
    source_215 --> destination_215
    source_215 --> destination_120
    source_217[".github/skills/README.md"]
    source_217 --> destination_120
    source_218[".github/skills/acceptance-criteria-tracking/SKILL.md"]
    destination_218[".agents/skills/acceptance-criteria-tracking/SKILL.md"]
    source_218 --> destination_218
    source_219[".github/skills/atomic-plan-contract/SKILL.md"]
    source_219 --> destination_29
    source_220[".github/skills/csharp-change-budget-router/SKILL.md"]
    destination_220[".agents/skills/csharp-change-budget-router/SKILL.md"]
    source_220 --> destination_220
    source_221[".github/skills/csharp-orchestration-state-machine/SKILL.md"]
    destination_221[".agents/skills/csharp-orchestration-state-machine/SKILL.md"]
    source_221 --> destination_221
    source_222[".github/skills/evidence-and-timestamp-conventions/SKILL.md"]
    destination_222[".agents/skills/evidence-and-timestamp-conventions/SKILL.md"]
    source_222 --> destination_222
    source_223[".github/skills/feature-promotion-lifecycle/SKILL.md"]
    destination_223[".agents/skills/feature-promotion-lifecycle/SKILL.md"]
    source_223 --> destination_223
    source_224[".github/skills/feature-review-workflow/SKILL.md"]
    destination_224[".agents/skills/feature-review-workflow/SKILL.md"]
    source_224 --> destination_224
    source_225[".github/skills/make-skill-template/SKILL.md"]
    destination_225[".agents/skills/make-skill-template/SKILL.md"]
    source_225 --> destination_225
    source_226[".github/skills/policy-audit-template-usage/SKILL.md"]
    destination_226[".agents/skills/policy-audit-template-usage/SKILL.md"]
    source_226 --> destination_226
    source_227[".github/skills/policy-compliance-order/SKILL.md"]
    source_227 --> destination_0
    destination_228[".agents/skills/policy-compliance-order/SKILL.md"]
    source_227 --> destination_228
    source_227 --> destination_1
    source_227 --> destination_2
    source_227 --> destination_3
    source_227 --> destination_4
    source_227 --> destination_6
    source_234[".github/skills/powershell-change-budget-router/SKILL.md"]
    destination_234[".agents/skills/powershell-change-budget-router/SKILL.md"]
    source_234 --> destination_234
    source_235[".github/skills/powershell-orchestration-state-machine/SKILL.md"]
    destination_235[".agents/skills/powershell-orchestration-state-machine/SKILL.md"]
    source_235 --> destination_235
    source_236[".github/skills/pr-base-branch-merge-base/SKILL.md"]
    destination_236[".agents/skills/pr-base-branch-merge-base/SKILL.md"]
    source_236 --> destination_236
    source_237[".github/skills/pr-context-artifacts/SKILL.md"]
    destination_237[".agents/skills/pr-context-artifacts/SKILL.md"]
    source_237 --> destination_237
    source_238[".github/skills/remediation-handoff-atomic-planner/SKILL.md"]
    destination_238[".agents/skills/remediation-handoff-atomic-planner/SKILL.md"]
    source_238 --> destination_238
    source_239[".github/skills/skill-canonical-location-audit/SKILL.md"]
    destination_239[".agents/skills/skill-canonical-location-audit/SKILL.md"]
    source_239 --> destination_239
```

### Repeated Destination Nodes

Destination nodes may repeat in this source-to-destination view so fan-in stays legible.
```mermaid
graph LR
    source_0[".github/agents/5.1-Beast-adjusted.agent.md"]
    destination_0[".agents/skills/github-actions/SKILL.md"]
    source_0 --> destination_0
    destination_1[".agents/skills/powershell-code-change/SKILL.md"]
    source_0 --> destination_1
    destination_2[".agents/skills/powershell-unit-test/SKILL.md"]
    source_0 --> destination_2
    destination_3[".agents/skills/python-code-change/SKILL.md"]
    source_0 --> destination_3
    destination_4[".agents/skills/python-unit-test/SKILL.md"]
    source_0 --> destination_4
    destination_5[".codex/agents/5.1-Beast-adjusted.toml"]
    source_0 --> destination_5
    destination_6["AGENTS.md"]
    source_0 --> destination_6
    source_7[".github/agents/5.1-Thinking-Beast-Mode-adjusted.agent.md"]
    destination_7[".agents/skills/github-actions/SKILL.md"]
    source_7 --> destination_7
    destination_8[".agents/skills/powershell-code-change/SKILL.md"]
    source_7 --> destination_8
    destination_9[".agents/skills/powershell-unit-test/SKILL.md"]
    source_7 --> destination_9
    destination_10[".agents/skills/python-code-change/SKILL.md"]
    source_7 --> destination_10
    destination_11[".agents/skills/python-unit-test/SKILL.md"]
    source_7 --> destination_11
    destination_12[".codex/agents/5.1-Thinking-Beast-Mode-adjusted.toml"]
    source_7 --> destination_12
    destination_13["AGENTS.md"]
    source_7 --> destination_13
    source_14[".github/agents/Powershell DI Unit Test Engineer.agent.md"]
    destination_14[".codex/agents/Powershell DI Unit Test Engineer.toml"]
    source_14 --> destination_14
    source_15[".github/agents/api-architect.agent.md"]
    destination_15[".codex/agents/api-architect.toml"]
    source_15 --> destination_15
    source_16[".github/agents/atomic_executor.agent.md"]
    destination_16[".codex/agents/atomic-executor.toml"]
    source_16 --> destination_16
    destination_17["AGENTS.md"]
    source_16 --> destination_17
    source_18[".github/agents/atomic_planning.agent.md"]
    destination_18[".codex/agents/atomic-planning.toml"]
    source_18 --> destination_18
    source_19[".github/agents/commentary-remediation.agent.md"]
    destination_19[".agents/skills/python-code-change/SKILL.md"]
    source_19 --> destination_19
    destination_20[".agents/skills/self-explanatory-code-commenting/SKILL.md"]
    source_19 --> destination_20
    destination_21[".codex/agents/commentary-remediation.toml"]
    source_19 --> destination_21
    destination_22["AGENTS.md"]
    source_19 --> destination_22
    source_23[".github/agents/commit-steward.agent.md"]
    destination_23[".codex/agents/commit-steward.toml"]
    source_23 --> destination_23
    source_24[".github/agents/csharp-atomic-executor.agent.md"]
    destination_24[".agents/skills/csharp-code-change/SKILL.md"]
    source_24 --> destination_24
    destination_25[".agents/skills/csharp-unit-test/SKILL.md"]
    source_24 --> destination_25
    destination_26[".codex/agents/csharp-atomic-executor.toml"]
    source_24 --> destination_26
    destination_27["AGENTS.md"]
    source_24 --> destination_27
    source_28[".github/agents/csharp-atomic-planning.agent.md"]
    destination_28[".codex/agents/csharp-atomic-planning.toml"]
    source_28 --> destination_28
    source_29[".github/agents/csharp-orchestrator.agent.md"]
    destination_29[".agents/skills/atomic-plan-contract/SKILL.md"]
    source_29 --> destination_29
    destination_30[".codex/agents/csharp-orchestrator.toml"]
    source_29 --> destination_30
    destination_31[".codex/agents/feature-review.toml"]
    source_29 --> destination_31
    source_32[".github/agents/csharp-typed-engineer.agent.md"]
    destination_32[".agents/skills/atomic-plan-contract/SKILL.md"]
    source_32 --> destination_32
    destination_33[".agents/skills/csharp-code-change/SKILL.md"]
    source_32 --> destination_33
    destination_34[".agents/skills/csharp-unit-test/SKILL.md"]
    source_32 --> destination_34
    destination_35[".codex/agents/csharp-typed-engineer.toml"]
    source_32 --> destination_35
    destination_36["AGENTS.md"]
    source_32 --> destination_36
    source_37[".github/agents/epic-review.agent.md"]
    destination_37[".codex/agents/epic-review.toml"]
    source_37 --> destination_37
    source_38[".github/agents/expert-nextjs-developer.agent.md"]
    destination_38[".codex/agents/expert-nextjs-developer.toml"]
    source_38 --> destination_38
    source_39[".github/agents/expert-react-frontend-engineer.agent.md"]
    destination_39[".codex/agents/expert-react-frontend-engineer.toml"]
    source_39 --> destination_39
    source_40[".github/agents/feature-review.agent.md"]
    destination_40[".agents/skills/atomic-plan-contract/SKILL.md"]
    source_40 --> destination_40
    destination_41[".codex/agents/feature-review.toml"]
    source_40 --> destination_41
    source_42[".github/agents/gpt-5-beast-mode.agent.md"]
    destination_42[".codex/agents/gpt-5-beast-mode.toml"]
    source_42 --> destination_42
    source_43[".github/agents/hlbpa.agent.md"]
    destination_43[".codex/agents/hlbpa.toml"]
    source_43 --> destination_43
    source_44[".github/agents/mentor.agent.md"]
    destination_44[".codex/agents/mentor.toml"]
    source_44 --> destination_44
    source_45[".github/agents/orchestrator.agent.md"]
    destination_45[".agents/skills/atomic-plan-contract/SKILL.md"]
    source_45 --> destination_45
    destination_46[".codex/agents/feature-review.toml"]
    source_45 --> destination_46
    destination_47[".codex/agents/orchestrator.toml"]
    source_45 --> destination_47
    source_48[".github/agents/powershell-atomic-executor.agent.md"]
    destination_48[".agents/skills/powershell-code-change/SKILL.md"]
    source_48 --> destination_48
    destination_49[".agents/skills/powershell-unit-test/SKILL.md"]
    source_48 --> destination_49
    destination_50[".codex/agents/powershell-atomic-executor.toml"]
    source_48 --> destination_50
    destination_51["AGENTS.md"]
    source_48 --> destination_51
    source_52[".github/agents/powershell-atomic-planning.agent.md"]
    destination_52[".codex/agents/powershell-atomic-planning.toml"]
    source_52 --> destination_52
    source_53[".github/agents/powershell-orchestrator.agent.md"]
    destination_53[".agents/skills/atomic-plan-contract/SKILL.md"]
    source_53 --> destination_53
    destination_54[".codex/agents/feature-review.toml"]
    source_53 --> destination_54
    destination_55[".codex/agents/powershell-orchestrator.toml"]
    source_53 --> destination_55
    source_56[".github/agents/powershell-typed-engineer.agent.md"]
    destination_56[".agents/skills/atomic-plan-contract/SKILL.md"]
    source_56 --> destination_56
    destination_57[".agents/skills/powershell-code-change/SKILL.md"]
    source_56 --> destination_57
    destination_58[".agents/skills/powershell-unit-test/SKILL.md"]
    source_56 --> destination_58
    destination_59[".codex/agents/powershell-typed-engineer.toml"]
    source_56 --> destination_59
    destination_60["AGENTS.md"]
    source_56 --> destination_60
    source_61[".github/agents/pr-author.agent.md"]
    destination_61[".codex/agents/pr-author.toml"]
    source_61 --> destination_61
    source_62[".github/agents/prd-feature.agent.md"]
    destination_62[".codex/agents/prd-feature.toml"]
    source_62 --> destination_62
    source_63[".github/agents/prd.agent.md"]
    destination_63[".codex/agents/prd.toml"]
    source_63 --> destination_63
    source_64[".github/agents/pytest-unit-test-coding.agent.md"]
    destination_64[".codex/agents/pytest-unit-test-coding.toml"]
    source_64 --> destination_64
    source_65[".github/agents/python-atomic-executor.agent.md"]
    destination_65[".agents/skills/python-code-change/SKILL.md"]
    source_65 --> destination_65
    destination_66[".agents/skills/python-suppressions/SKILL.md"]
    source_65 --> destination_66
    destination_67[".agents/skills/python-unit-test/SKILL.md"]
    source_65 --> destination_67
    destination_68[".codex/agents/python-atomic-executor.toml"]
    source_65 --> destination_68
    destination_69["AGENTS.md"]
    source_65 --> destination_69
    source_70[".github/agents/python-atomic-planning.agent.md"]
    destination_70[".codex/agents/python-atomic-planning.toml"]
    source_70 --> destination_70
    source_71[".github/agents/python-execution-only-typed.agent.md"]
    destination_71[".agents/skills/python-code-change/SKILL.md"]
    source_71 --> destination_71
    destination_72[".agents/skills/python-unit-test/SKILL.md"]
    source_71 --> destination_72
    destination_73[".codex/agents/python-execution-only-typed.toml"]
    source_71 --> destination_73
    destination_74["AGENTS.md"]
    source_71 --> destination_74
    source_75[".github/agents/python-orchestrator.agent.md"]
    destination_75[".agents/skills/atomic-plan-contract/SKILL.md"]
    source_75 --> destination_75
    destination_76[".codex/agents/feature-review.toml"]
    source_75 --> destination_76
    destination_77[".codex/agents/python-orchestrator.toml"]
    source_75 --> destination_77
    source_78[".github/agents/python-typed-engineer.agent.md"]
    destination_78[".agents/skills/python-code-change/SKILL.md"]
    source_78 --> destination_78
    destination_79[".agents/skills/python-unit-test/SKILL.md"]
    source_78 --> destination_79
    destination_80[".codex/agents/python-typed-engineer.toml"]
    source_78 --> destination_80
    destination_81["AGENTS.md"]
    source_78 --> destination_81
    source_82[".github/agents/staged-review.agent.md"]
    destination_82[".agents/skills/github-actions/SKILL.md"]
    source_82 --> destination_82
    destination_83[".agents/skills/powershell-code-change/SKILL.md"]
    source_82 --> destination_83
    destination_84[".agents/skills/powershell-unit-test/SKILL.md"]
    source_82 --> destination_84
    destination_85[".agents/skills/python-code-change/SKILL.md"]
    source_82 --> destination_85
    destination_86[".agents/skills/python-unit-test/SKILL.md"]
    source_82 --> destination_86
    destination_87[".codex/agents/staged-review.toml"]
    source_82 --> destination_87
    destination_88["AGENTS.md"]
    source_82 --> destination_88
    source_89[".github/agents/status_updater.agent.md"]
    destination_89[".codex/agents/status-updater.toml"]
    source_89 --> destination_89
    destination_90["AGENTS.md"]
    source_89 --> destination_90
    source_91[".github/agents/task-researcher.agent.md"]
    destination_91[".codex/agents/task-researcher.toml"]
    source_91 --> destination_91
    source_92[".github/agents/tdd-green.agent.md"]
    destination_92[".codex/agents/tdd-green.toml"]
    source_92 --> destination_92
    source_93[".github/agents/tdd-red.agent.md"]
    destination_93[".codex/agents/tdd-red.toml"]
    source_93 --> destination_93
    source_94[".github/agents/tdd-refactor.agent.md"]
    destination_94[".codex/agents/tdd-refactor.toml"]
    source_94 --> destination_94
    source_95[".github/agents/typescript-engineer.agent.md"]
    destination_95[".agents/skills/typescript-code-change/SKILL.md"]
    source_95 --> destination_95
    destination_96[".agents/skills/typescript-suppressions/SKILL.md"]
    source_95 --> destination_96
    destination_97[".agents/skills/typescript-unit-test/SKILL.md"]
    source_95 --> destination_97
    destination_98[".codex/agents/typescript-engineer.toml"]
    source_95 --> destination_98
    destination_99["AGENTS.md"]
    source_95 --> destination_99
    source_100[".github/agents/voidbeast-gpt41enhanced.agent.md"]
    destination_100[".codex/agents/voidbeast-gpt41enhanced.toml"]
    source_100 --> destination_100
    source_101[".github/copilot-instructions.md"]
    destination_101["AGENTS.md"]
    source_101 --> destination_101
    source_102[".github/instructions/csharp-code-change.instructions.md"]
    destination_102[".agents/skills/csharp-code-change/SKILL.md"]
    source_102 --> destination_102
    source_103[".github/instructions/csharp-unit-test.instructions.md"]
    destination_103[".agents/skills/csharp-unit-test/SKILL.md"]
    source_103 --> destination_103
    source_104[".github/instructions/general-code-change.instructions.md"]
    destination_104["AGENTS.md"]
    source_104 --> destination_104
    source_105[".github/instructions/general-unit-test.instructions.md"]
    destination_105["AGENTS.md"]
    source_105 --> destination_105
    source_106[".github/instructions/github-actions-ci-cd-best-practices.instructions.md"]
    destination_106[".agents/skills/github-actions-ci-cd-best-practices/SKILL.md"]
    source_106 --> destination_106
    source_107[".github/instructions/github-actions.instructions.md"]
    destination_107[".agents/skills/github-actions/SKILL.md"]
    source_107 --> destination_107
    source_108[".github/instructions/powershell-code-change.instructions.md"]
    destination_108[".agents/skills/powershell-code-change/SKILL.md"]
    source_108 --> destination_108
    source_109[".github/instructions/powershell-unit-test.instructions.md"]
    destination_109[".agents/skills/powershell-unit-test/SKILL.md"]
    source_109 --> destination_109
    source_110[".github/instructions/python-code-change.instructions.md"]
    destination_110[".agents/skills/python-code-change/SKILL.md"]
    source_110 --> destination_110
    source_111[".github/instructions/python-suppressions.instructions.md"]
    destination_111[".agents/skills/python-suppressions/SKILL.md"]
    source_111 --> destination_111
    source_112[".github/instructions/python-unit-test.instructions.md"]
    destination_112[".agents/skills/python-unit-test/SKILL.md"]
    source_112 --> destination_112
    source_113[".github/instructions/self-explanatory-code-commenting.instructions.md"]
    destination_113[".agents/skills/self-explanatory-code-commenting/SKILL.md"]
    source_113 --> destination_113
    source_114[".github/instructions/tonality.instructions.md"]
    destination_114["AGENTS.md"]
    source_114 --> destination_114
    source_115[".github/instructions/typescript-code-change.instructions.md"]
    destination_115[".agents/skills/typescript-code-change/SKILL.md"]
    source_115 --> destination_115
    source_116[".github/instructions/typescript-suppressions.instructions.md"]
    destination_116[".agents/skills/typescript-suppressions/SKILL.md"]
    source_116 --> destination_116
    source_117[".github/instructions/typescript-unit-test.instructions.md"]
    destination_117[".agents/skills/typescript-unit-test/SKILL.md"]
    source_117 --> destination_117
    source_118[".github/prompts/add-educational-comments.prompt.md"]
    destination_118[".agents/skills/add-educational-comments/SKILL.md"]
    source_118 --> destination_118
    destination_119[".agents/skills/add-educational-comments/SKILL.md"]
    source_118 --> destination_119
    destination_120["[no target]"]
    source_118 --> destination_120
    source_121[".github/prompts/breakdown-bug-prd.prompt.md"]
    destination_121[".agents/skills/breakdown-bug-prd/SKILL.md"]
    source_121 --> destination_121
    destination_122[".agents/skills/breakdown-bug-prd/SKILL.md"]
    source_121 --> destination_122
    destination_123["[no target]"]
    source_121 --> destination_123
    source_124[".github/prompts/breakdown-epic-arch.prompt.md"]
    destination_124[".agents/skills/breakdown-epic-arch/SKILL.md"]
    source_124 --> destination_124
    destination_125[".agents/skills/breakdown-epic-arch/SKILL.md"]
    source_124 --> destination_125
    destination_126["[no target]"]
    source_124 --> destination_126
    source_127[".github/prompts/breakdown-epic-pm.prompt.md"]
    destination_127[".agents/skills/breakdown-epic-pm/SKILL.md"]
    source_127 --> destination_127
    destination_128[".agents/skills/breakdown-epic-pm/SKILL.md"]
    source_127 --> destination_128
    destination_129[".agents/skills/breakdown-epic-pm/SKILL.md"]
    source_127 --> destination_129
    destination_130["[no target]"]
    source_127 --> destination_130
    source_131[".github/prompts/breakdown-feature-implementation.prompt.md"]
    destination_131[".agents/skills/breakdown-feature-implementation/SKILL.md"]
    source_131 --> destination_131
    destination_132[".agents/skills/breakdown-feature-implementation/SKILL.md"]
    source_131 --> destination_132
    destination_133[".agents/skills/breakdown-feature-implementation/SKILL.md"]
    source_131 --> destination_133
    destination_134["[no target]"]
    source_131 --> destination_134
    source_135[".github/prompts/breakdown-feature-prd.prompt.md"]
    destination_135[".agents/skills/breakdown-feature-prd/SKILL.md"]
    source_135 --> destination_135
    destination_136[".agents/skills/breakdown-feature-prd/SKILL.md"]
    source_135 --> destination_136
    destination_137[".agents/skills/breakdown-feature-prd/SKILL.md"]
    source_135 --> destination_137
    destination_138["[no target]"]
    source_135 --> destination_138
    source_139[".github/prompts/code-exemplars-blueprint-generator.prompt.md"]
    destination_139[".agents/skills/code-exemplars-blueprint-generator/SKILL.md"]
    source_139 --> destination_139
    destination_140["[no target]"]
    source_139 --> destination_140
    source_141[".github/prompts/drafts/create-github-issues-feature-from-implementation-plan.prompt.md"]
    destination_141[".agents/skills/create-github-issues-feature-from-implementation-plan/SKILL.md"]
    source_141 --> destination_141
    destination_142["[no target]"]
    source_141 --> destination_142
    source_143[".github/prompts/drafts/create-implementation-plan.prompt.md"]
    destination_143[".agents/skills/create-implementation-plan/SKILL.md"]
    source_143 --> destination_143
    destination_144["[no target]"]
    source_143 --> destination_144
    source_145[".github/prompts/drafts/create-technical-spike.prompt.md"]
    destination_145[".agents/skills/create-technical-spike/SKILL.md"]
    source_145 --> destination_145
    destination_146[".agents/skills/create-technical-spike/SKILL.md"]
    source_145 --> destination_146
    destination_147[".agents/skills/create-technical-spike/SKILL.md"]
    source_145 --> destination_147
    destination_148[".agents/skills/create-technical-spike/SKILL.md"]
    source_145 --> destination_148
    destination_149["[no target]"]
    source_145 --> destination_149
    source_150[".github/prompts/drafts/potential-feature-prd.prompt.md"]
    destination_150[".agents/skills/potential-feature-prd/SKILL.md"]
    source_150 --> destination_150
    destination_151[".agents/skills/potential-feature-prd/SKILL.md"]
    source_150 --> destination_151
    destination_152["[no target]"]
    source_150 --> destination_152
    source_153[".github/prompts/drafts/update-implementation-plan.prompt.md"]
    destination_153[".agents/skills/update-implementation-plan/SKILL.md"]
    source_153 --> destination_153
    destination_154["[no target]"]
    source_153 --> destination_154
    source_155[".github/prompts/execute-hard-lock.prompt.md"]
    destination_155[".codex/hooks/execute-hard-lock.ps1"]
    source_155 --> destination_155
    destination_156["[no target]"]
    source_155 --> destination_156
    source_157[".github/prompts/execute-plan-template.md"]
    destination_157[".agents/skills/execute-plan-template/SKILL.md"]
    source_157 --> destination_157
    destination_158[".agents/skills/execute-plan-template/SKILL.md"]
    source_157 --> destination_158
    destination_159["[no target]"]
    source_157 --> destination_159
    source_160[".github/prompts/export-chat.prompt.md"]
    destination_160["[no target]"]
    source_160 --> destination_160
    source_161[".github/prompts/fillout-prd-feature.prompt.md"]
    destination_161[".agents/skills/fillout-prd-feature/SKILL.md"]
    source_161 --> destination_161
    destination_162[".agents/skills/fillout-prd-feature/SKILL.md"]
    source_161 --> destination_162
    destination_163["[no target]"]
    source_161 --> destination_163
    source_164[".github/prompts/generate-atomic-plan.prompt.md"]
    destination_164["[no target]"]
    source_164 --> destination_164
    source_165[".github/prompts/generate-commit-message-repo.prompt.md"]
    destination_165[".agents/skills/generate-commit-message-repo/SKILL.md"]
    source_165 --> destination_165
    destination_166[".agents/skills/generate-commit-message-repo/SKILL.md"]
    source_165 --> destination_166
    destination_167["[no target]"]
    source_165 --> destination_167
    source_168[".github/prompts/generate-pr.prompt.md"]
    destination_168[".agents/skills/generate-pr/SKILL.md"]
    source_168 --> destination_168
    destination_169[".agents/skills/generate-pr/SKILL.md"]
    source_168 --> destination_169
    destination_170[".agents/skills/generate-pr/SKILL.md"]
    source_168 --> destination_170
    destination_171[".agents/skills/generate-pr/SKILL.md"]
    source_168 --> destination_171
    destination_172[".codex/hooks/generate-pr.ps1"]
    source_168 --> destination_172
    destination_173[".codex/hooks/generate-pr.ps1"]
    source_168 --> destination_173
    destination_174["[no target]"]
    source_168 --> destination_174
    source_175[".github/prompts/javascript-typescript-jest.prompt.md"]
    destination_175["[no target]"]
    source_175 --> destination_175
    source_176[".github/prompts/orchestrate-csharp-work.prompt.md"]
    destination_176[".agents/skills/orchestrate-csharp-work/SKILL.md"]
    source_176 --> destination_176
    destination_177[".agents/skills/orchestrate-csharp-work/SKILL.md"]
    source_176 --> destination_177
    destination_178["[no target]"]
    source_176 --> destination_178
    source_179[".github/prompts/orchestrate-powershell-work.prompt.md"]
    destination_179[".agents/skills/orchestrate-powershell-work/SKILL.md"]
    source_179 --> destination_179
    destination_180[".agents/skills/orchestrate-powershell-work/SKILL.md"]
    source_179 --> destination_180
    destination_181["[no target]"]
    source_179 --> destination_181
    source_182[".github/prompts/orchestrate-python-work.prompt.md"]
    destination_182[".agents/skills/orchestrate-python-work/SKILL.md"]
    source_182 --> destination_182
    destination_183[".agents/skills/orchestrate-python-work/SKILL.md"]
    source_182 --> destination_183
    destination_184["[no target]"]
    source_182 --> destination_184
    source_185[".github/prompts/orchestrate-work.prompt.md"]
    destination_185[".agents/skills/orchestrate-work/SKILL.md"]
    source_185 --> destination_185
    destination_186[".agents/skills/orchestrate-work/SKILL.md"]
    source_185 --> destination_186
    destination_187["[no target]"]
    source_185 --> destination_187
    source_188[".github/prompts/remediate-comments.prompt.md"]
    destination_188[".agents/skills/remediate-comments/SKILL.md"]
    source_188 --> destination_188
    destination_189[".agents/skills/remediate-comments/SKILL.md"]
    source_188 --> destination_189
    destination_190[".agents/skills/remediate-comments/SKILL.md"]
    source_188 --> destination_190
    destination_191[".agents/skills/remediate-comments/SKILL.md"]
    source_188 --> destination_191
    destination_192[".agents/skills/remediate-comments/SKILL.md"]
    source_188 --> destination_192
    destination_193["[no target]"]
    source_188 --> destination_193
    source_194[".github/prompts/research-issue.prompt.md"]
    destination_194[".agents/skills/research-issue/SKILL.md"]
    source_194 --> destination_194
    destination_195[".agents/skills/research-issue/SKILL.md"]
    source_194 --> destination_195
    destination_196["[no target]"]
    source_194 --> destination_196
    source_197[".github/prompts/review-epic.prompt.md"]
    destination_197[".agents/skills/review-epic/SKILL.md"]
    source_197 --> destination_197
    destination_198[".agents/skills/review-epic/SKILL.md"]
    source_197 --> destination_198
    destination_199[".agents/skills/review-epic/SKILL.md"]
    source_197 --> destination_199
    destination_200[".agents/skills/review-epic/SKILL.md"]
    source_197 --> destination_200
    destination_201[".codex/hooks/review-epic.ps1"]
    source_197 --> destination_201
    destination_202["[no target]"]
    source_197 --> destination_202
    source_203[".github/prompts/review-feature.prompt.md"]
    destination_203[".agents/skills/review-feature/SKILL.md"]
    source_203 --> destination_203
    destination_204[".agents/skills/review-feature/SKILL.md"]
    source_203 --> destination_204
    destination_205[".agents/skills/review-feature/SKILL.md"]
    source_203 --> destination_205
    destination_206[".agents/skills/review-feature/SKILL.md"]
    source_203 --> destination_206
    destination_207[".codex/hooks/review-feature.ps1"]
    source_203 --> destination_207
    destination_208[".codex/hooks/review-feature.ps1"]
    source_203 --> destination_208
    destination_209["[no target]"]
    source_203 --> destination_209
    source_210[".github/prompts/review-staged.prompt.md"]
    destination_210[".agents/skills/review-staged/SKILL.md"]
    source_210 --> destination_210
    destination_211[".agents/skills/review-staged/SKILL.md"]
    source_210 --> destination_211
    destination_212[".agents/skills/review-staged/SKILL.md"]
    source_210 --> destination_212
    destination_213[".agents/skills/review-staged/SKILL.md"]
    source_210 --> destination_213
    destination_214["[no target]"]
    source_210 --> destination_214
    source_215[".github/prompts/update_status.prompt.md"]
    destination_215[".agents/skills/update-status/SKILL.md"]
    source_215 --> destination_215
    destination_216["[no target]"]
    source_215 --> destination_216
    source_217[".github/skills/README.md"]
    destination_217["[no target]"]
    source_217 --> destination_217
    source_218[".github/skills/acceptance-criteria-tracking/SKILL.md"]
    destination_218[".agents/skills/acceptance-criteria-tracking/SKILL.md"]
    source_218 --> destination_218
    source_219[".github/skills/atomic-plan-contract/SKILL.md"]
    destination_219[".agents/skills/atomic-plan-contract/SKILL.md"]
    source_219 --> destination_219
    source_220[".github/skills/csharp-change-budget-router/SKILL.md"]
    destination_220[".agents/skills/csharp-change-budget-router/SKILL.md"]
    source_220 --> destination_220
    source_221[".github/skills/csharp-orchestration-state-machine/SKILL.md"]
    destination_221[".agents/skills/csharp-orchestration-state-machine/SKILL.md"]
    source_221 --> destination_221
    source_222[".github/skills/evidence-and-timestamp-conventions/SKILL.md"]
    destination_222[".agents/skills/evidence-and-timestamp-conventions/SKILL.md"]
    source_222 --> destination_222
    source_223[".github/skills/feature-promotion-lifecycle/SKILL.md"]
    destination_223[".agents/skills/feature-promotion-lifecycle/SKILL.md"]
    source_223 --> destination_223
    source_224[".github/skills/feature-review-workflow/SKILL.md"]
    destination_224[".agents/skills/feature-review-workflow/SKILL.md"]
    source_224 --> destination_224
    source_225[".github/skills/make-skill-template/SKILL.md"]
    destination_225[".agents/skills/make-skill-template/SKILL.md"]
    source_225 --> destination_225
    source_226[".github/skills/policy-audit-template-usage/SKILL.md"]
    destination_226[".agents/skills/policy-audit-template-usage/SKILL.md"]
    source_226 --> destination_226
    source_227[".github/skills/policy-compliance-order/SKILL.md"]
    destination_227[".agents/skills/github-actions/SKILL.md"]
    source_227 --> destination_227
    destination_228[".agents/skills/policy-compliance-order/SKILL.md"]
    source_227 --> destination_228
    destination_229[".agents/skills/powershell-code-change/SKILL.md"]
    source_227 --> destination_229
    destination_230[".agents/skills/powershell-unit-test/SKILL.md"]
    source_227 --> destination_230
    destination_231[".agents/skills/python-code-change/SKILL.md"]
    source_227 --> destination_231
    destination_232[".agents/skills/python-unit-test/SKILL.md"]
    source_227 --> destination_232
    destination_233["AGENTS.md"]
    source_227 --> destination_233
    source_234[".github/skills/powershell-change-budget-router/SKILL.md"]
    destination_234[".agents/skills/powershell-change-budget-router/SKILL.md"]
    source_234 --> destination_234
    source_235[".github/skills/powershell-orchestration-state-machine/SKILL.md"]
    destination_235[".agents/skills/powershell-orchestration-state-machine/SKILL.md"]
    source_235 --> destination_235
    source_236[".github/skills/pr-base-branch-merge-base/SKILL.md"]
    destination_236[".agents/skills/pr-base-branch-merge-base/SKILL.md"]
    source_236 --> destination_236
    source_237[".github/skills/pr-context-artifacts/SKILL.md"]
    destination_237[".agents/skills/pr-context-artifacts/SKILL.md"]
    source_237 --> destination_237
    source_238[".github/skills/remediation-handoff-atomic-planner/SKILL.md"]
    destination_238[".agents/skills/remediation-handoff-atomic-planner/SKILL.md"]
    source_238 --> destination_238
    source_239[".github/skills/skill-canonical-location-audit/SKILL.md"]
    destination_239[".agents/skills/skill-canonical-location-audit/SKILL.md"]
    source_239 --> destination_239
```

### Repeated Source Nodes

Source nodes may repeat in this destination-to-source view so fan-out stays legible.
```mermaid
graph LR
    destination_0[".agents/skills/github-actions/SKILL.md"]
    source_0[".github/agents/5.1-Beast-adjusted.agent.md"]
    destination_0 --> source_0
    destination_1[".agents/skills/powershell-code-change/SKILL.md"]
    source_1[".github/agents/5.1-Beast-adjusted.agent.md"]
    destination_1 --> source_1
    destination_2[".agents/skills/powershell-unit-test/SKILL.md"]
    source_2[".github/agents/5.1-Beast-adjusted.agent.md"]
    destination_2 --> source_2
    destination_3[".agents/skills/python-code-change/SKILL.md"]
    source_3[".github/agents/5.1-Beast-adjusted.agent.md"]
    destination_3 --> source_3
    destination_4[".agents/skills/python-unit-test/SKILL.md"]
    source_4[".github/agents/5.1-Beast-adjusted.agent.md"]
    destination_4 --> source_4
    destination_5[".codex/agents/5.1-Beast-adjusted.toml"]
    source_5[".github/agents/5.1-Beast-adjusted.agent.md"]
    destination_5 --> source_5
    destination_6["AGENTS.md"]
    source_6[".github/agents/5.1-Beast-adjusted.agent.md"]
    destination_6 --> source_6
    source_7[".github/agents/5.1-Thinking-Beast-Mode-adjusted.agent.md"]
    destination_0 --> source_7
    source_8[".github/agents/5.1-Thinking-Beast-Mode-adjusted.agent.md"]
    destination_1 --> source_8
    source_9[".github/agents/5.1-Thinking-Beast-Mode-adjusted.agent.md"]
    destination_2 --> source_9
    source_10[".github/agents/5.1-Thinking-Beast-Mode-adjusted.agent.md"]
    destination_3 --> source_10
    source_11[".github/agents/5.1-Thinking-Beast-Mode-adjusted.agent.md"]
    destination_4 --> source_11
    destination_12[".codex/agents/5.1-Thinking-Beast-Mode-adjusted.toml"]
    source_12[".github/agents/5.1-Thinking-Beast-Mode-adjusted.agent.md"]
    destination_12 --> source_12
    source_13[".github/agents/5.1-Thinking-Beast-Mode-adjusted.agent.md"]
    destination_6 --> source_13
    destination_14[".codex/agents/Powershell DI Unit Test Engineer.toml"]
    source_14[".github/agents/Powershell DI Unit Test Engineer.agent.md"]
    destination_14 --> source_14
    destination_15[".codex/agents/api-architect.toml"]
    source_15[".github/agents/api-architect.agent.md"]
    destination_15 --> source_15
    destination_16[".codex/agents/atomic-executor.toml"]
    source_16[".github/agents/atomic_executor.agent.md"]
    destination_16 --> source_16
    source_17[".github/agents/atomic_executor.agent.md"]
    destination_6 --> source_17
    destination_18[".codex/agents/atomic-planning.toml"]
    source_18[".github/agents/atomic_planning.agent.md"]
    destination_18 --> source_18
    source_19[".github/agents/commentary-remediation.agent.md"]
    destination_3 --> source_19
    destination_20[".agents/skills/self-explanatory-code-commenting/SKILL.md"]
    source_20[".github/agents/commentary-remediation.agent.md"]
    destination_20 --> source_20
    destination_21[".codex/agents/commentary-remediation.toml"]
    source_21[".github/agents/commentary-remediation.agent.md"]
    destination_21 --> source_21
    source_22[".github/agents/commentary-remediation.agent.md"]
    destination_6 --> source_22
    destination_23[".codex/agents/commit-steward.toml"]
    source_23[".github/agents/commit-steward.agent.md"]
    destination_23 --> source_23
    destination_24[".agents/skills/csharp-code-change/SKILL.md"]
    source_24[".github/agents/csharp-atomic-executor.agent.md"]
    destination_24 --> source_24
    destination_25[".agents/skills/csharp-unit-test/SKILL.md"]
    source_25[".github/agents/csharp-atomic-executor.agent.md"]
    destination_25 --> source_25
    destination_26[".codex/agents/csharp-atomic-executor.toml"]
    source_26[".github/agents/csharp-atomic-executor.agent.md"]
    destination_26 --> source_26
    source_27[".github/agents/csharp-atomic-executor.agent.md"]
    destination_6 --> source_27
    destination_28[".codex/agents/csharp-atomic-planning.toml"]
    source_28[".github/agents/csharp-atomic-planning.agent.md"]
    destination_28 --> source_28
    destination_29[".agents/skills/atomic-plan-contract/SKILL.md"]
    source_29[".github/agents/csharp-orchestrator.agent.md"]
    destination_29 --> source_29
    destination_30[".codex/agents/csharp-orchestrator.toml"]
    source_30[".github/agents/csharp-orchestrator.agent.md"]
    destination_30 --> source_30
    destination_31[".codex/agents/feature-review.toml"]
    source_31[".github/agents/csharp-orchestrator.agent.md"]
    destination_31 --> source_31
    source_32[".github/agents/csharp-typed-engineer.agent.md"]
    destination_29 --> source_32
    source_33[".github/agents/csharp-typed-engineer.agent.md"]
    destination_24 --> source_33
    source_34[".github/agents/csharp-typed-engineer.agent.md"]
    destination_25 --> source_34
    destination_35[".codex/agents/csharp-typed-engineer.toml"]
    source_35[".github/agents/csharp-typed-engineer.agent.md"]
    destination_35 --> source_35
    source_36[".github/agents/csharp-typed-engineer.agent.md"]
    destination_6 --> source_36
    destination_37[".codex/agents/epic-review.toml"]
    source_37[".github/agents/epic-review.agent.md"]
    destination_37 --> source_37
    destination_38[".codex/agents/expert-nextjs-developer.toml"]
    source_38[".github/agents/expert-nextjs-developer.agent.md"]
    destination_38 --> source_38
    destination_39[".codex/agents/expert-react-frontend-engineer.toml"]
    source_39[".github/agents/expert-react-frontend-engineer.agent.md"]
    destination_39 --> source_39
    source_40[".github/agents/feature-review.agent.md"]
    destination_29 --> source_40
    source_41[".github/agents/feature-review.agent.md"]
    destination_31 --> source_41
    destination_42[".codex/agents/gpt-5-beast-mode.toml"]
    source_42[".github/agents/gpt-5-beast-mode.agent.md"]
    destination_42 --> source_42
    destination_43[".codex/agents/hlbpa.toml"]
    source_43[".github/agents/hlbpa.agent.md"]
    destination_43 --> source_43
    destination_44[".codex/agents/mentor.toml"]
    source_44[".github/agents/mentor.agent.md"]
    destination_44 --> source_44
    source_45[".github/agents/orchestrator.agent.md"]
    destination_29 --> source_45
    source_46[".github/agents/orchestrator.agent.md"]
    destination_31 --> source_46
    destination_47[".codex/agents/orchestrator.toml"]
    source_47[".github/agents/orchestrator.agent.md"]
    destination_47 --> source_47
    source_48[".github/agents/powershell-atomic-executor.agent.md"]
    destination_1 --> source_48
    source_49[".github/agents/powershell-atomic-executor.agent.md"]
    destination_2 --> source_49
    destination_50[".codex/agents/powershell-atomic-executor.toml"]
    source_50[".github/agents/powershell-atomic-executor.agent.md"]
    destination_50 --> source_50
    source_51[".github/agents/powershell-atomic-executor.agent.md"]
    destination_6 --> source_51
    destination_52[".codex/agents/powershell-atomic-planning.toml"]
    source_52[".github/agents/powershell-atomic-planning.agent.md"]
    destination_52 --> source_52
    source_53[".github/agents/powershell-orchestrator.agent.md"]
    destination_29 --> source_53
    source_54[".github/agents/powershell-orchestrator.agent.md"]
    destination_31 --> source_54
    destination_55[".codex/agents/powershell-orchestrator.toml"]
    source_55[".github/agents/powershell-orchestrator.agent.md"]
    destination_55 --> source_55
    source_56[".github/agents/powershell-typed-engineer.agent.md"]
    destination_29 --> source_56
    source_57[".github/agents/powershell-typed-engineer.agent.md"]
    destination_1 --> source_57
    source_58[".github/agents/powershell-typed-engineer.agent.md"]
    destination_2 --> source_58
    destination_59[".codex/agents/powershell-typed-engineer.toml"]
    source_59[".github/agents/powershell-typed-engineer.agent.md"]
    destination_59 --> source_59
    source_60[".github/agents/powershell-typed-engineer.agent.md"]
    destination_6 --> source_60
    destination_61[".codex/agents/pr-author.toml"]
    source_61[".github/agents/pr-author.agent.md"]
    destination_61 --> source_61
    destination_62[".codex/agents/prd-feature.toml"]
    source_62[".github/agents/prd-feature.agent.md"]
    destination_62 --> source_62
    destination_63[".codex/agents/prd.toml"]
    source_63[".github/agents/prd.agent.md"]
    destination_63 --> source_63
    destination_64[".codex/agents/pytest-unit-test-coding.toml"]
    source_64[".github/agents/pytest-unit-test-coding.agent.md"]
    destination_64 --> source_64
    source_65[".github/agents/python-atomic-executor.agent.md"]
    destination_3 --> source_65
    destination_66[".agents/skills/python-suppressions/SKILL.md"]
    source_66[".github/agents/python-atomic-executor.agent.md"]
    destination_66 --> source_66
    source_67[".github/agents/python-atomic-executor.agent.md"]
    destination_4 --> source_67
    destination_68[".codex/agents/python-atomic-executor.toml"]
    source_68[".github/agents/python-atomic-executor.agent.md"]
    destination_68 --> source_68
    source_69[".github/agents/python-atomic-executor.agent.md"]
    destination_6 --> source_69
    destination_70[".codex/agents/python-atomic-planning.toml"]
    source_70[".github/agents/python-atomic-planning.agent.md"]
    destination_70 --> source_70
    source_71[".github/agents/python-execution-only-typed.agent.md"]
    destination_3 --> source_71
    source_72[".github/agents/python-execution-only-typed.agent.md"]
    destination_4 --> source_72
    destination_73[".codex/agents/python-execution-only-typed.toml"]
    source_73[".github/agents/python-execution-only-typed.agent.md"]
    destination_73 --> source_73
    source_74[".github/agents/python-execution-only-typed.agent.md"]
    destination_6 --> source_74
    source_75[".github/agents/python-orchestrator.agent.md"]
    destination_29 --> source_75
    source_76[".github/agents/python-orchestrator.agent.md"]
    destination_31 --> source_76
    destination_77[".codex/agents/python-orchestrator.toml"]
    source_77[".github/agents/python-orchestrator.agent.md"]
    destination_77 --> source_77
    source_78[".github/agents/python-typed-engineer.agent.md"]
    destination_3 --> source_78
    source_79[".github/agents/python-typed-engineer.agent.md"]
    destination_4 --> source_79
    destination_80[".codex/agents/python-typed-engineer.toml"]
    source_80[".github/agents/python-typed-engineer.agent.md"]
    destination_80 --> source_80
    source_81[".github/agents/python-typed-engineer.agent.md"]
    destination_6 --> source_81
    source_82[".github/agents/staged-review.agent.md"]
    destination_0 --> source_82
    source_83[".github/agents/staged-review.agent.md"]
    destination_1 --> source_83
    source_84[".github/agents/staged-review.agent.md"]
    destination_2 --> source_84
    source_85[".github/agents/staged-review.agent.md"]
    destination_3 --> source_85
    source_86[".github/agents/staged-review.agent.md"]
    destination_4 --> source_86
    destination_87[".codex/agents/staged-review.toml"]
    source_87[".github/agents/staged-review.agent.md"]
    destination_87 --> source_87
    source_88[".github/agents/staged-review.agent.md"]
    destination_6 --> source_88
    destination_89[".codex/agents/status-updater.toml"]
    source_89[".github/agents/status_updater.agent.md"]
    destination_89 --> source_89
    source_90[".github/agents/status_updater.agent.md"]
    destination_6 --> source_90
    destination_91[".codex/agents/task-researcher.toml"]
    source_91[".github/agents/task-researcher.agent.md"]
    destination_91 --> source_91
    destination_92[".codex/agents/tdd-green.toml"]
    source_92[".github/agents/tdd-green.agent.md"]
    destination_92 --> source_92
    destination_93[".codex/agents/tdd-red.toml"]
    source_93[".github/agents/tdd-red.agent.md"]
    destination_93 --> source_93
    destination_94[".codex/agents/tdd-refactor.toml"]
    source_94[".github/agents/tdd-refactor.agent.md"]
    destination_94 --> source_94
    destination_95[".agents/skills/typescript-code-change/SKILL.md"]
    source_95[".github/agents/typescript-engineer.agent.md"]
    destination_95 --> source_95
    destination_96[".agents/skills/typescript-suppressions/SKILL.md"]
    source_96[".github/agents/typescript-engineer.agent.md"]
    destination_96 --> source_96
    destination_97[".agents/skills/typescript-unit-test/SKILL.md"]
    source_97[".github/agents/typescript-engineer.agent.md"]
    destination_97 --> source_97
    destination_98[".codex/agents/typescript-engineer.toml"]
    source_98[".github/agents/typescript-engineer.agent.md"]
    destination_98 --> source_98
    source_99[".github/agents/typescript-engineer.agent.md"]
    destination_6 --> source_99
    destination_100[".codex/agents/voidbeast-gpt41enhanced.toml"]
    source_100[".github/agents/voidbeast-gpt41enhanced.agent.md"]
    destination_100 --> source_100
    source_101[".github/copilot-instructions.md"]
    destination_6 --> source_101
    source_102[".github/instructions/csharp-code-change.instructions.md"]
    destination_24 --> source_102
    source_103[".github/instructions/csharp-unit-test.instructions.md"]
    destination_25 --> source_103
    source_104[".github/instructions/general-code-change.instructions.md"]
    destination_6 --> source_104
    source_105[".github/instructions/general-unit-test.instructions.md"]
    destination_6 --> source_105
    destination_106[".agents/skills/github-actions-ci-cd-best-practices/SKILL.md"]
    source_106[".github/instructions/github-actions-ci-cd-best-practices.instructions.md"]
    destination_106 --> source_106
    source_107[".github/instructions/github-actions.instructions.md"]
    destination_0 --> source_107
    source_108[".github/instructions/powershell-code-change.instructions.md"]
    destination_1 --> source_108
    source_109[".github/instructions/powershell-unit-test.instructions.md"]
    destination_2 --> source_109
    source_110[".github/instructions/python-code-change.instructions.md"]
    destination_3 --> source_110
    source_111[".github/instructions/python-suppressions.instructions.md"]
    destination_66 --> source_111
    source_112[".github/instructions/python-unit-test.instructions.md"]
    destination_4 --> source_112
    source_113[".github/instructions/self-explanatory-code-commenting.instructions.md"]
    destination_20 --> source_113
    source_114[".github/instructions/tonality.instructions.md"]
    destination_6 --> source_114
    source_115[".github/instructions/typescript-code-change.instructions.md"]
    destination_95 --> source_115
    source_116[".github/instructions/typescript-suppressions.instructions.md"]
    destination_96 --> source_116
    source_117[".github/instructions/typescript-unit-test.instructions.md"]
    destination_97 --> source_117
    destination_118[".agents/skills/add-educational-comments/SKILL.md"]
    source_118[".github/prompts/add-educational-comments.prompt.md"]
    destination_118 --> source_118
    source_119[".github/prompts/add-educational-comments.prompt.md"]
    destination_118 --> source_119
    destination_120["[no target]"]
    source_120[".github/prompts/add-educational-comments.prompt.md"]
    destination_120 --> source_120
    destination_121[".agents/skills/breakdown-bug-prd/SKILL.md"]
    source_121[".github/prompts/breakdown-bug-prd.prompt.md"]
    destination_121 --> source_121
    source_122[".github/prompts/breakdown-bug-prd.prompt.md"]
    destination_121 --> source_122
    source_123[".github/prompts/breakdown-bug-prd.prompt.md"]
    destination_120 --> source_123
    destination_124[".agents/skills/breakdown-epic-arch/SKILL.md"]
    source_124[".github/prompts/breakdown-epic-arch.prompt.md"]
    destination_124 --> source_124
    source_125[".github/prompts/breakdown-epic-arch.prompt.md"]
    destination_124 --> source_125
    source_126[".github/prompts/breakdown-epic-arch.prompt.md"]
    destination_120 --> source_126
    destination_127[".agents/skills/breakdown-epic-pm/SKILL.md"]
    source_127[".github/prompts/breakdown-epic-pm.prompt.md"]
    destination_127 --> source_127
    source_128[".github/prompts/breakdown-epic-pm.prompt.md"]
    destination_127 --> source_128
    source_129[".github/prompts/breakdown-epic-pm.prompt.md"]
    destination_127 --> source_129
    source_130[".github/prompts/breakdown-epic-pm.prompt.md"]
    destination_120 --> source_130
    destination_131[".agents/skills/breakdown-feature-implementation/SKILL.md"]
    source_131[".github/prompts/breakdown-feature-implementation.prompt.md"]
    destination_131 --> source_131
    source_132[".github/prompts/breakdown-feature-implementation.prompt.md"]
    destination_131 --> source_132
    source_133[".github/prompts/breakdown-feature-implementation.prompt.md"]
    destination_131 --> source_133
    source_134[".github/prompts/breakdown-feature-implementation.prompt.md"]
    destination_120 --> source_134
    destination_135[".agents/skills/breakdown-feature-prd/SKILL.md"]
    source_135[".github/prompts/breakdown-feature-prd.prompt.md"]
    destination_135 --> source_135
    source_136[".github/prompts/breakdown-feature-prd.prompt.md"]
    destination_135 --> source_136
    source_137[".github/prompts/breakdown-feature-prd.prompt.md"]
    destination_135 --> source_137
    source_138[".github/prompts/breakdown-feature-prd.prompt.md"]
    destination_120 --> source_138
    destination_139[".agents/skills/code-exemplars-blueprint-generator/SKILL.md"]
    source_139[".github/prompts/code-exemplars-blueprint-generator.prompt.md"]
    destination_139 --> source_139
    source_140[".github/prompts/code-exemplars-blueprint-generator.prompt.md"]
    destination_120 --> source_140
    destination_141[".agents/skills/create-github-issues-feature-from-implementation-plan/SKILL.md"]
    source_141[".github/prompts/drafts/create-github-issues-feature-from-implementation-plan.prompt.md"]
    destination_141 --> source_141
    source_142[".github/prompts/drafts/create-github-issues-feature-from-implementation-plan.prompt.md"]
    destination_120 --> source_142
    destination_143[".agents/skills/create-implementation-plan/SKILL.md"]
    source_143[".github/prompts/drafts/create-implementation-plan.prompt.md"]
    destination_143 --> source_143
    source_144[".github/prompts/drafts/create-implementation-plan.prompt.md"]
    destination_120 --> source_144
    destination_145[".agents/skills/create-technical-spike/SKILL.md"]
    source_145[".github/prompts/drafts/create-technical-spike.prompt.md"]
    destination_145 --> source_145
    source_146[".github/prompts/drafts/create-technical-spike.prompt.md"]
    destination_145 --> source_146
    source_147[".github/prompts/drafts/create-technical-spike.prompt.md"]
    destination_145 --> source_147
    source_148[".github/prompts/drafts/create-technical-spike.prompt.md"]
    destination_145 --> source_148
    source_149[".github/prompts/drafts/create-technical-spike.prompt.md"]
    destination_120 --> source_149
    destination_150[".agents/skills/potential-feature-prd/SKILL.md"]
    source_150[".github/prompts/drafts/potential-feature-prd.prompt.md"]
    destination_150 --> source_150
    source_151[".github/prompts/drafts/potential-feature-prd.prompt.md"]
    destination_150 --> source_151
    source_152[".github/prompts/drafts/potential-feature-prd.prompt.md"]
    destination_120 --> source_152
    destination_153[".agents/skills/update-implementation-plan/SKILL.md"]
    source_153[".github/prompts/drafts/update-implementation-plan.prompt.md"]
    destination_153 --> source_153
    source_154[".github/prompts/drafts/update-implementation-plan.prompt.md"]
    destination_120 --> source_154
    destination_155[".codex/hooks/execute-hard-lock.ps1"]
    source_155[".github/prompts/execute-hard-lock.prompt.md"]
    destination_155 --> source_155
    source_156[".github/prompts/execute-hard-lock.prompt.md"]
    destination_120 --> source_156
    destination_157[".agents/skills/execute-plan-template/SKILL.md"]
    source_157[".github/prompts/execute-plan-template.md"]
    destination_157 --> source_157
    source_158[".github/prompts/execute-plan-template.md"]
    destination_157 --> source_158
    source_159[".github/prompts/execute-plan-template.md"]
    destination_120 --> source_159
    source_160[".github/prompts/export-chat.prompt.md"]
    destination_120 --> source_160
    destination_161[".agents/skills/fillout-prd-feature/SKILL.md"]
    source_161[".github/prompts/fillout-prd-feature.prompt.md"]
    destination_161 --> source_161
    source_162[".github/prompts/fillout-prd-feature.prompt.md"]
    destination_161 --> source_162
    source_163[".github/prompts/fillout-prd-feature.prompt.md"]
    destination_120 --> source_163
    source_164[".github/prompts/generate-atomic-plan.prompt.md"]
    destination_120 --> source_164
    destination_165[".agents/skills/generate-commit-message-repo/SKILL.md"]
    source_165[".github/prompts/generate-commit-message-repo.prompt.md"]
    destination_165 --> source_165
    source_166[".github/prompts/generate-commit-message-repo.prompt.md"]
    destination_165 --> source_166
    source_167[".github/prompts/generate-commit-message-repo.prompt.md"]
    destination_120 --> source_167
    destination_168[".agents/skills/generate-pr/SKILL.md"]
    source_168[".github/prompts/generate-pr.prompt.md"]
    destination_168 --> source_168
    source_169[".github/prompts/generate-pr.prompt.md"]
    destination_168 --> source_169
    source_170[".github/prompts/generate-pr.prompt.md"]
    destination_168 --> source_170
    source_171[".github/prompts/generate-pr.prompt.md"]
    destination_168 --> source_171
    destination_172[".codex/hooks/generate-pr.ps1"]
    source_172[".github/prompts/generate-pr.prompt.md"]
    destination_172 --> source_172
    source_173[".github/prompts/generate-pr.prompt.md"]
    destination_172 --> source_173
    source_174[".github/prompts/generate-pr.prompt.md"]
    destination_120 --> source_174
    source_175[".github/prompts/javascript-typescript-jest.prompt.md"]
    destination_120 --> source_175
    destination_176[".agents/skills/orchestrate-csharp-work/SKILL.md"]
    source_176[".github/prompts/orchestrate-csharp-work.prompt.md"]
    destination_176 --> source_176
    source_177[".github/prompts/orchestrate-csharp-work.prompt.md"]
    destination_176 --> source_177
    source_178[".github/prompts/orchestrate-csharp-work.prompt.md"]
    destination_120 --> source_178
    destination_179[".agents/skills/orchestrate-powershell-work/SKILL.md"]
    source_179[".github/prompts/orchestrate-powershell-work.prompt.md"]
    destination_179 --> source_179
    source_180[".github/prompts/orchestrate-powershell-work.prompt.md"]
    destination_179 --> source_180
    source_181[".github/prompts/orchestrate-powershell-work.prompt.md"]
    destination_120 --> source_181
    destination_182[".agents/skills/orchestrate-python-work/SKILL.md"]
    source_182[".github/prompts/orchestrate-python-work.prompt.md"]
    destination_182 --> source_182
    source_183[".github/prompts/orchestrate-python-work.prompt.md"]
    destination_182 --> source_183
    source_184[".github/prompts/orchestrate-python-work.prompt.md"]
    destination_120 --> source_184
    destination_185[".agents/skills/orchestrate-work/SKILL.md"]
    source_185[".github/prompts/orchestrate-work.prompt.md"]
    destination_185 --> source_185
    source_186[".github/prompts/orchestrate-work.prompt.md"]
    destination_185 --> source_186
    source_187[".github/prompts/orchestrate-work.prompt.md"]
    destination_120 --> source_187
    destination_188[".agents/skills/remediate-comments/SKILL.md"]
    source_188[".github/prompts/remediate-comments.prompt.md"]
    destination_188 --> source_188
    source_189[".github/prompts/remediate-comments.prompt.md"]
    destination_188 --> source_189
    source_190[".github/prompts/remediate-comments.prompt.md"]
    destination_188 --> source_190
    source_191[".github/prompts/remediate-comments.prompt.md"]
    destination_188 --> source_191
    source_192[".github/prompts/remediate-comments.prompt.md"]
    destination_188 --> source_192
    source_193[".github/prompts/remediate-comments.prompt.md"]
    destination_120 --> source_193
    destination_194[".agents/skills/research-issue/SKILL.md"]
    source_194[".github/prompts/research-issue.prompt.md"]
    destination_194 --> source_194
    source_195[".github/prompts/research-issue.prompt.md"]
    destination_194 --> source_195
    source_196[".github/prompts/research-issue.prompt.md"]
    destination_120 --> source_196
    destination_197[".agents/skills/review-epic/SKILL.md"]
    source_197[".github/prompts/review-epic.prompt.md"]
    destination_197 --> source_197
    source_198[".github/prompts/review-epic.prompt.md"]
    destination_197 --> source_198
    source_199[".github/prompts/review-epic.prompt.md"]
    destination_197 --> source_199
    source_200[".github/prompts/review-epic.prompt.md"]
    destination_197 --> source_200
    destination_201[".codex/hooks/review-epic.ps1"]
    source_201[".github/prompts/review-epic.prompt.md"]
    destination_201 --> source_201
    source_202[".github/prompts/review-epic.prompt.md"]
    destination_120 --> source_202
    destination_203[".agents/skills/review-feature/SKILL.md"]
    source_203[".github/prompts/review-feature.prompt.md"]
    destination_203 --> source_203
    source_204[".github/prompts/review-feature.prompt.md"]
    destination_203 --> source_204
    source_205[".github/prompts/review-feature.prompt.md"]
    destination_203 --> source_205
    source_206[".github/prompts/review-feature.prompt.md"]
    destination_203 --> source_206
    destination_207[".codex/hooks/review-feature.ps1"]
    source_207[".github/prompts/review-feature.prompt.md"]
    destination_207 --> source_207
    source_208[".github/prompts/review-feature.prompt.md"]
    destination_207 --> source_208
    source_209[".github/prompts/review-feature.prompt.md"]
    destination_120 --> source_209
    destination_210[".agents/skills/review-staged/SKILL.md"]
    source_210[".github/prompts/review-staged.prompt.md"]
    destination_210 --> source_210
    source_211[".github/prompts/review-staged.prompt.md"]
    destination_210 --> source_211
    source_212[".github/prompts/review-staged.prompt.md"]
    destination_210 --> source_212
    source_213[".github/prompts/review-staged.prompt.md"]
    destination_210 --> source_213
    source_214[".github/prompts/review-staged.prompt.md"]
    destination_120 --> source_214
    destination_215[".agents/skills/update-status/SKILL.md"]
    source_215[".github/prompts/update_status.prompt.md"]
    destination_215 --> source_215
    source_216[".github/prompts/update_status.prompt.md"]
    destination_120 --> source_216
    source_217[".github/skills/README.md"]
    destination_120 --> source_217
    destination_218[".agents/skills/acceptance-criteria-tracking/SKILL.md"]
    source_218[".github/skills/acceptance-criteria-tracking/SKILL.md"]
    destination_218 --> source_218
    source_219[".github/skills/atomic-plan-contract/SKILL.md"]
    destination_29 --> source_219
    destination_220[".agents/skills/csharp-change-budget-router/SKILL.md"]
    source_220[".github/skills/csharp-change-budget-router/SKILL.md"]
    destination_220 --> source_220
    destination_221[".agents/skills/csharp-orchestration-state-machine/SKILL.md"]
    source_221[".github/skills/csharp-orchestration-state-machine/SKILL.md"]
    destination_221 --> source_221
    destination_222[".agents/skills/evidence-and-timestamp-conventions/SKILL.md"]
    source_222[".github/skills/evidence-and-timestamp-conventions/SKILL.md"]
    destination_222 --> source_222
    destination_223[".agents/skills/feature-promotion-lifecycle/SKILL.md"]
    source_223[".github/skills/feature-promotion-lifecycle/SKILL.md"]
    destination_223 --> source_223
    destination_224[".agents/skills/feature-review-workflow/SKILL.md"]
    source_224[".github/skills/feature-review-workflow/SKILL.md"]
    destination_224 --> source_224
    destination_225[".agents/skills/make-skill-template/SKILL.md"]
    source_225[".github/skills/make-skill-template/SKILL.md"]
    destination_225 --> source_225
    destination_226[".agents/skills/policy-audit-template-usage/SKILL.md"]
    source_226[".github/skills/policy-audit-template-usage/SKILL.md"]
    destination_226 --> source_226
    source_227[".github/skills/policy-compliance-order/SKILL.md"]
    destination_0 --> source_227
    destination_228[".agents/skills/policy-compliance-order/SKILL.md"]
    source_228[".github/skills/policy-compliance-order/SKILL.md"]
    destination_228 --> source_228
    source_229[".github/skills/policy-compliance-order/SKILL.md"]
    destination_1 --> source_229
    source_230[".github/skills/policy-compliance-order/SKILL.md"]
    destination_2 --> source_230
    source_231[".github/skills/policy-compliance-order/SKILL.md"]
    destination_3 --> source_231
    source_232[".github/skills/policy-compliance-order/SKILL.md"]
    destination_4 --> source_232
    source_233[".github/skills/policy-compliance-order/SKILL.md"]
    destination_6 --> source_233
    destination_234[".agents/skills/powershell-change-budget-router/SKILL.md"]
    source_234[".github/skills/powershell-change-budget-router/SKILL.md"]
    destination_234 --> source_234
    destination_235[".agents/skills/powershell-orchestration-state-machine/SKILL.md"]
    source_235[".github/skills/powershell-orchestration-state-machine/SKILL.md"]
    destination_235 --> source_235
    destination_236[".agents/skills/pr-base-branch-merge-base/SKILL.md"]
    source_236[".github/skills/pr-base-branch-merge-base/SKILL.md"]
    destination_236 --> source_236
    destination_237[".agents/skills/pr-context-artifacts/SKILL.md"]
    source_237[".github/skills/pr-context-artifacts/SKILL.md"]
    destination_237 --> source_237
    destination_238[".agents/skills/remediation-handoff-atomic-planner/SKILL.md"]
    source_238[".github/skills/remediation-handoff-atomic-planner/SKILL.md"]
    destination_238 --> source_238
    destination_239[".agents/skills/skill-canonical-location-audit/SKILL.md"]
    source_239[".github/skills/skill-canonical-location-audit/SKILL.md"]
    destination_239 --> source_239
```

## Mappings

| Source path | Conversion class | Target role | Target path | Notes |
| --- | --- | --- | --- | --- |
| `.github/agents/5.1-Beast-adjusted.agent.md` | `decomposed` | `subagent` | `.codex/agents/5.1-Beast-adjusted.toml` |  |
| `.github/agents/5.1-Thinking-Beast-Mode-adjusted.agent.md` | `decomposed` | `subagent` | `.codex/agents/5.1-Thinking-Beast-Mode-adjusted.toml` |  |
| `.github/agents/Powershell DI Unit Test Engineer.agent.md` | `decomposed` | `subagent` | `.codex/agents/Powershell DI Unit Test Engineer.toml` | Agent manifest contains handoff semantics that require validation before apply mode. |
| `.github/agents/api-architect.agent.md` | `decomposed` | `subagent` | `.codex/agents/api-architect.toml` |  |
| `.github/agents/atomic_executor.agent.md` | `decomposed` | `subagent` | `.codex/agents/atomic-executor.toml` | Agent manifest contains handoff semantics that require validation before apply mode. |
| `.github/agents/atomic_planning.agent.md` | `decomposed` | `subagent` | `.codex/agents/atomic-planning.toml` | Agent manifest contains handoff semantics that require validation before apply mode. |
| `.github/agents/commentary-remediation.agent.md` | `decomposed` | `subagent` | `.codex/agents/commentary-remediation.toml` |  |
| `.github/agents/commit-steward.agent.md` | `decomposed` | `subagent` | `.codex/agents/commit-steward.toml` |  |
| `.github/agents/csharp-atomic-executor.agent.md` | `decomposed` | `subagent` | `.codex/agents/csharp-atomic-executor.toml` |  |
| `.github/agents/csharp-atomic-planning.agent.md` | `decomposed` | `subagent` | `.codex/agents/csharp-atomic-planning.toml` | Agent manifest contains handoff semantics that require validation before apply mode. |
| `.github/agents/csharp-orchestrator.agent.md` | `decomposed` | `subagent` | `.codex/agents/csharp-orchestrator.toml` | Agent manifest contains handoff semantics that require validation before apply mode. |
| `.github/agents/csharp-typed-engineer.agent.md` | `decomposed` | `subagent` | `.codex/agents/csharp-typed-engineer.toml` | Agent manifest contains handoff semantics that require validation before apply mode. |
| `.github/agents/epic-review.agent.md` | `decomposed` | `subagent` | `.codex/agents/epic-review.toml` | Agent manifest contains handoff semantics that require validation before apply mode. |
| `.github/agents/expert-nextjs-developer.agent.md` | `decomposed` | `subagent` | `.codex/agents/expert-nextjs-developer.toml` |  |
| `.github/agents/expert-react-frontend-engineer.agent.md` | `decomposed` | `subagent` | `.codex/agents/expert-react-frontend-engineer.toml` |  |
| `.github/agents/feature-review.agent.md` | `decomposed` | `subagent` | `.codex/agents/feature-review.toml` | Agent manifest contains handoff semantics that require validation before apply mode. |
| `.github/agents/gpt-5-beast-mode.agent.md` | `decomposed` | `subagent` | `.codex/agents/gpt-5-beast-mode.toml` |  |
| `.github/agents/hlbpa.agent.md` | `decomposed` | `subagent` | `.codex/agents/hlbpa.toml` |  |
| `.github/agents/mentor.agent.md` | `decomposed` | `subagent` | `.codex/agents/mentor.toml` |  |
| `.github/agents/orchestrator.agent.md` | `decomposed` | `subagent` | `.codex/agents/orchestrator.toml` | Agent manifest contains handoff semantics that require validation before apply mode. |
| `.github/agents/powershell-atomic-executor.agent.md` | `decomposed` | `subagent` | `.codex/agents/powershell-atomic-executor.toml` |  |
| `.github/agents/powershell-atomic-planning.agent.md` | `decomposed` | `subagent` | `.codex/agents/powershell-atomic-planning.toml` | Agent manifest contains handoff semantics that require validation before apply mode. |
| `.github/agents/powershell-orchestrator.agent.md` | `decomposed` | `subagent` | `.codex/agents/powershell-orchestrator.toml` | Agent manifest contains handoff semantics that require validation before apply mode. |
| `.github/agents/powershell-typed-engineer.agent.md` | `decomposed` | `subagent` | `.codex/agents/powershell-typed-engineer.toml` | Agent manifest contains handoff semantics that require validation before apply mode. |
| `.github/agents/pr-author.agent.md` | `decomposed` | `subagent` | `.codex/agents/pr-author.toml` |  |
| `.github/agents/prd-feature.agent.md` | `decomposed` | `subagent` | `.codex/agents/prd-feature.toml` | Agent manifest contains handoff semantics that require validation before apply mode. |
| `.github/agents/prd.agent.md` | `decomposed` | `subagent` | `.codex/agents/prd.toml` |  |
| `.github/agents/pytest-unit-test-coding.agent.md` | `decomposed` | `subagent` | `.codex/agents/pytest-unit-test-coding.toml` | Agent manifest contains handoff semantics that require validation before apply mode. |
| `.github/agents/python-atomic-executor.agent.md` | `decomposed` | `subagent` | `.codex/agents/python-atomic-executor.toml` |  |
| `.github/agents/python-atomic-planning.agent.md` | `decomposed` | `subagent` | `.codex/agents/python-atomic-planning.toml` | Agent manifest contains handoff semantics that require validation before apply mode. |
| `.github/agents/python-execution-only-typed.agent.md` | `decomposed` | `subagent` | `.codex/agents/python-execution-only-typed.toml` | Agent manifest contains handoff semantics that require validation before apply mode. |
| `.github/agents/python-orchestrator.agent.md` | `decomposed` | `subagent` | `.codex/agents/python-orchestrator.toml` | Agent manifest contains handoff semantics that require validation before apply mode. |
| `.github/agents/python-typed-engineer.agent.md` | `decomposed` | `subagent` | `.codex/agents/python-typed-engineer.toml` | Agent manifest contains handoff semantics that require validation before apply mode. |
| `.github/agents/staged-review.agent.md` | `decomposed` | `subagent` | `.codex/agents/staged-review.toml` | Agent manifest contains handoff semantics that require validation before apply mode. |
| `.github/agents/status_updater.agent.md` | `decomposed` | `subagent` | `.codex/agents/status-updater.toml` | Agent manifest contains handoff semantics that require validation before apply mode. |
| `.github/agents/task-researcher.agent.md` | `decomposed` | `subagent` | `.codex/agents/task-researcher.toml` | Agent manifest contains handoff semantics that require validation before apply mode. |
| `.github/agents/tdd-green.agent.md` | `decomposed` | `subagent` | `.codex/agents/tdd-green.toml` |  |
| `.github/agents/tdd-red.agent.md` | `decomposed` | `subagent` | `.codex/agents/tdd-red.toml` |  |
| `.github/agents/tdd-refactor.agent.md` | `decomposed` | `subagent` | `.codex/agents/tdd-refactor.toml` |  |
| `.github/agents/typescript-engineer.agent.md` | `decomposed` | `subagent` | `.codex/agents/typescript-engineer.toml` | Agent manifest contains handoff semantics that require validation before apply mode. |
| `.github/agents/voidbeast-gpt41enhanced.agent.md` | `decomposed` | `subagent` | `.codex/agents/voidbeast-gpt41enhanced.toml` |  |
| `.github/copilot-instructions.md` | `direct` | `standing-guidance` | `AGENTS.md` |  |
| `.github/instructions/csharp-code-change.instructions.md` | `decomposed` | `shared-skill` | `.agents/skills/csharp-code-change/SKILL.md` | Path-scoped instruction requires decomposition into shared skills or standing guidance. |
| `.github/instructions/csharp-unit-test.instructions.md` | `decomposed` | `shared-skill` | `.agents/skills/csharp-unit-test/SKILL.md` | Path-scoped instruction requires decomposition into shared skills or standing guidance. |
| `.github/instructions/general-code-change.instructions.md` | `decomposed` | `standing-guidance` | `AGENTS.md` | Repo-wide instruction applies to all files and merges into standing guidance. |
| `.github/instructions/general-unit-test.instructions.md` | `decomposed` | `standing-guidance` | `AGENTS.md` | Repo-wide instruction applies to all files and merges into standing guidance. |
| `.github/instructions/github-actions-ci-cd-best-practices.instructions.md` | `decomposed` | `shared-skill` | `.agents/skills/github-actions-ci-cd-best-practices/SKILL.md` | Path-scoped instruction requires decomposition into shared skills or standing guidance. |
| `.github/instructions/github-actions.instructions.md` | `decomposed` | `shared-skill` | `.agents/skills/github-actions/SKILL.md` | Path-scoped instruction requires decomposition into shared skills or standing guidance. |
| `.github/instructions/powershell-code-change.instructions.md` | `decomposed` | `shared-skill` | `.agents/skills/powershell-code-change/SKILL.md` | Path-scoped instruction requires decomposition into shared skills or standing guidance. |
| `.github/instructions/powershell-unit-test.instructions.md` | `decomposed` | `shared-skill` | `.agents/skills/powershell-unit-test/SKILL.md` | Path-scoped instruction requires decomposition into shared skills or standing guidance. |
| `.github/instructions/python-code-change.instructions.md` | `decomposed` | `shared-skill` | `.agents/skills/python-code-change/SKILL.md` | Path-scoped instruction requires decomposition into shared skills or standing guidance. |
| `.github/instructions/python-suppressions.instructions.md` | `decomposed` | `shared-skill` | `.agents/skills/python-suppressions/SKILL.md` | Path-scoped instruction requires decomposition into shared skills or standing guidance. |
| `.github/instructions/python-unit-test.instructions.md` | `decomposed` | `shared-skill` | `.agents/skills/python-unit-test/SKILL.md` | Path-scoped instruction requires decomposition into shared skills or standing guidance. |
| `.github/instructions/self-explanatory-code-commenting.instructions.md` | `decomposed` | `shared-skill` | `.agents/skills/self-explanatory-code-commenting/SKILL.md` | Path-scoped instruction requires decomposition into shared skills or standing guidance. |
| `.github/instructions/tonality.instructions.md` | `decomposed` | `standing-guidance` | `AGENTS.md` | Repo-wide instruction applies to all files and merges into standing guidance. |
| `.github/instructions/typescript-code-change.instructions.md` | `decomposed` | `shared-skill` | `.agents/skills/typescript-code-change/SKILL.md` | Path-scoped instruction requires decomposition into shared skills or standing guidance. |
| `.github/instructions/typescript-suppressions.instructions.md` | `decomposed` | `shared-skill` | `.agents/skills/typescript-suppressions/SKILL.md` | Path-scoped instruction requires decomposition into shared skills or standing guidance. |
| `.github/instructions/typescript-unit-test.instructions.md` | `decomposed` | `shared-skill` | `.agents/skills/typescript-unit-test/SKILL.md` | Path-scoped instruction requires decomposition into shared skills or standing guidance. |
| `.github/prompts/add-educational-comments.prompt.md` | `unsupported` | `unsupported` | `` | Launcher prompts map only to the repository-convention .codex/prompts surface when explicitly enabled.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/breakdown-bug-prd.prompt.md` | `unsupported` | `unsupported` | `` | Launcher prompts map only to the repository-convention .codex/prompts surface when explicitly enabled.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/breakdown-epic-arch.prompt.md` | `unsupported` | `unsupported` | `` | Launcher prompts map only to the repository-convention .codex/prompts surface when explicitly enabled.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/breakdown-epic-pm.prompt.md` | `unsupported` | `unsupported` | `` | Launcher prompts map only to the repository-convention .codex/prompts surface when explicitly enabled.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/breakdown-feature-implementation.prompt.md` | `unsupported` | `unsupported` | `` | Launcher prompts map only to the repository-convention .codex/prompts surface when explicitly enabled.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/breakdown-feature-prd.prompt.md` | `unsupported` | `unsupported` | `` | Launcher prompts map only to the repository-convention .codex/prompts surface when explicitly enabled.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/code-exemplars-blueprint-generator.prompt.md` | `unsupported` | `unsupported` | `` | Launcher prompts map only to the repository-convention .codex/prompts surface when explicitly enabled.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/drafts/create-github-issues-feature-from-implementation-plan.prompt.md` | `unsupported` | `unsupported` | `` | Launcher prompts map only to the repository-convention .codex/prompts surface when explicitly enabled.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/drafts/create-implementation-plan.prompt.md` | `unsupported` | `unsupported` | `` | Launcher prompts map only to the repository-convention .codex/prompts surface when explicitly enabled.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/drafts/create-technical-spike.prompt.md` | `unsupported` | `unsupported` | `` | Launcher prompts map only to the repository-convention .codex/prompts surface when explicitly enabled.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/drafts/potential-feature-prd.prompt.md` | `unsupported` | `unsupported` | `` | Launcher prompts map only to the repository-convention .codex/prompts surface when explicitly enabled.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/drafts/update-implementation-plan.prompt.md` | `unsupported` | `unsupported` | `` | Launcher prompts map only to the repository-convention .codex/prompts surface when explicitly enabled.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/execute-hard-lock.prompt.md` | `unsupported` | `unsupported` | `` | Launcher prompts map only to the repository-convention .codex/prompts surface when explicitly enabled.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/execute-plan-template.md` | `unsupported` | `unsupported` | `` | Launcher prompts map only to the repository-convention .codex/prompts surface when explicitly enabled.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/export-chat.prompt.md` | `unsupported` | `unsupported` | `` | Launcher prompts map only to the repository-convention .codex/prompts surface when explicitly enabled.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/fillout-prd-feature.prompt.md` | `unsupported` | `unsupported` | `` | Launcher prompts map only to the repository-convention .codex/prompts surface when explicitly enabled.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/generate-atomic-plan.prompt.md` | `unsupported` | `unsupported` | `` | Launcher prompts map only to the repository-convention .codex/prompts surface when explicitly enabled.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/generate-commit-message-repo.prompt.md` | `unsupported` | `unsupported` | `` | Launcher prompts map only to the repository-convention .codex/prompts surface when explicitly enabled.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/generate-pr.prompt.md` | `unsupported` | `unsupported` | `` | Launcher prompts map only to the repository-convention .codex/prompts surface when explicitly enabled.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/javascript-typescript-jest.prompt.md` | `unsupported` | `unsupported` | `` | Launcher prompts map only to the repository-convention .codex/prompts surface when explicitly enabled.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/orchestrate-csharp-work.prompt.md` | `unsupported` | `unsupported` | `` | Launcher prompts map only to the repository-convention .codex/prompts surface when explicitly enabled.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/orchestrate-powershell-work.prompt.md` | `unsupported` | `unsupported` | `` | Launcher prompts map only to the repository-convention .codex/prompts surface when explicitly enabled.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/orchestrate-python-work.prompt.md` | `unsupported` | `unsupported` | `` | Launcher prompts map only to the repository-convention .codex/prompts surface when explicitly enabled.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/orchestrate-work.prompt.md` | `unsupported` | `unsupported` | `` | Launcher prompts map only to the repository-convention .codex/prompts surface when explicitly enabled.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/remediate-comments.prompt.md` | `unsupported` | `unsupported` | `` | Launcher prompts map only to the repository-convention .codex/prompts surface when explicitly enabled.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/research-issue.prompt.md` | `unsupported` | `unsupported` | `` | Launcher prompts map only to the repository-convention .codex/prompts surface when explicitly enabled.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/review-epic.prompt.md` | `unsupported` | `unsupported` | `` | Launcher prompts map only to the repository-convention .codex/prompts surface when explicitly enabled.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/review-feature.prompt.md` | `unsupported` | `unsupported` | `` | Launcher prompts map only to the repository-convention .codex/prompts surface when explicitly enabled.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/review-staged.prompt.md` | `unsupported` | `unsupported` | `` | Launcher prompts map only to the repository-convention .codex/prompts surface when explicitly enabled.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/update_status.prompt.md` | `unsupported` | `unsupported` | `` | Launcher prompts map only to the repository-convention .codex/prompts surface when explicitly enabled.<br>Repository-convention prompt output is disabled for this run. |
| `.github/skills/README.md` | `unsupported` | `unsupported` | `` | Skills index documentation has no native runtime surface in v1. |
| `.github/skills/acceptance-criteria-tracking/SKILL.md` | `direct` | `shared-skill` | `.agents/skills/acceptance-criteria-tracking/SKILL.md` |  |
| `.github/skills/atomic-plan-contract/SKILL.md` | `direct` | `shared-skill` | `.agents/skills/atomic-plan-contract/SKILL.md` |  |
| `.github/skills/csharp-change-budget-router/SKILL.md` | `direct` | `shared-skill` | `.agents/skills/csharp-change-budget-router/SKILL.md` |  |
| `.github/skills/csharp-orchestration-state-machine/SKILL.md` | `direct` | `shared-skill` | `.agents/skills/csharp-orchestration-state-machine/SKILL.md` |  |
| `.github/skills/evidence-and-timestamp-conventions/SKILL.md` | `direct` | `shared-skill` | `.agents/skills/evidence-and-timestamp-conventions/SKILL.md` |  |
| `.github/skills/feature-promotion-lifecycle/SKILL.md` | `direct` | `shared-skill` | `.agents/skills/feature-promotion-lifecycle/SKILL.md` |  |
| `.github/skills/feature-review-workflow/SKILL.md` | `direct` | `shared-skill` | `.agents/skills/feature-review-workflow/SKILL.md` |  |
| `.github/skills/make-skill-template/SKILL.md` | `direct` | `shared-skill` | `.agents/skills/make-skill-template/SKILL.md` |  |
| `.github/skills/policy-audit-template-usage/SKILL.md` | `direct` | `shared-skill` | `.agents/skills/policy-audit-template-usage/SKILL.md` |  |
| `.github/skills/policy-compliance-order/SKILL.md` | `direct` | `shared-skill` | `.agents/skills/policy-compliance-order/SKILL.md` |  |
| `.github/skills/powershell-change-budget-router/SKILL.md` | `direct` | `shared-skill` | `.agents/skills/powershell-change-budget-router/SKILL.md` |  |
| `.github/skills/powershell-orchestration-state-machine/SKILL.md` | `direct` | `shared-skill` | `.agents/skills/powershell-orchestration-state-machine/SKILL.md` |  |
| `.github/skills/pr-base-branch-merge-base/SKILL.md` | `direct` | `shared-skill` | `.agents/skills/pr-base-branch-merge-base/SKILL.md` |  |
| `.github/skills/pr-context-artifacts/SKILL.md` | `direct` | `shared-skill` | `.agents/skills/pr-context-artifacts/SKILL.md` |  |
| `.github/skills/remediation-handoff-atomic-planner/SKILL.md` | `direct` | `shared-skill` | `.agents/skills/remediation-handoff-atomic-planner/SKILL.md` |  |
| `.github/skills/skill-canonical-location-audit/SKILL.md` | `direct` | `shared-skill` | `.agents/skills/skill-canonical-location-audit/SKILL.md` |  |

## Section Mappings

| Source path | Section | Intent | Target role | Target path | Notes |
| --- | --- | --- | --- | --- | --- |
| `.github/prompts/add-educational-comments.prompt.md` | `Launcher Surface` | `launcher-only` | `launcher` | `` | Prompt launcher wrapper maps only to the repository-convention launcher surface.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/add-educational-comments.prompt.md` | `Objectives` | `shared-workflow` | `shared-skill` | `.agents/skills/add-educational-comments/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/add-educational-comments.prompt.md` | `Workflow` | `shared-workflow` | `shared-skill` | `.agents/skills/add-educational-comments/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/breakdown-bug-prd.prompt.md` | `Launcher Surface` | `launcher-only` | `launcher` | `` | Prompt launcher wrapper maps only to the repository-convention launcher surface.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/breakdown-bug-prd.prompt.md` | `Goal` | `shared-workflow` | `shared-skill` | `.agents/skills/breakdown-bug-prd/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/breakdown-bug-prd.prompt.md` | `Output Format` | `shared-workflow` | `shared-skill` | `.agents/skills/breakdown-bug-prd/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/breakdown-epic-arch.prompt.md` | `Launcher Surface` | `launcher-only` | `launcher` | `` | Prompt launcher wrapper maps only to the repository-convention launcher surface.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/breakdown-epic-arch.prompt.md` | `Goal` | `shared-workflow` | `shared-skill` | `.agents/skills/breakdown-epic-arch/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/breakdown-epic-arch.prompt.md` | `Output Format` | `shared-workflow` | `shared-skill` | `.agents/skills/breakdown-epic-arch/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/breakdown-epic-pm.prompt.md` | `2. Goal` | `shared-workflow` | `shared-skill` | `.agents/skills/breakdown-epic-pm/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/breakdown-epic-pm.prompt.md` | `Launcher Surface` | `launcher-only` | `launcher` | `` | Prompt launcher wrapper maps only to the repository-convention launcher surface.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/breakdown-epic-pm.prompt.md` | `Goal` | `shared-workflow` | `shared-skill` | `.agents/skills/breakdown-epic-pm/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/breakdown-epic-pm.prompt.md` | `Output Format` | `shared-workflow` | `shared-skill` | `.agents/skills/breakdown-epic-pm/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/breakdown-feature-implementation.prompt.md` | `Launcher Surface` | `launcher-only` | `launcher` | `` | Prompt launcher wrapper maps only to the repository-convention launcher surface.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/breakdown-feature-implementation.prompt.md` | `Goal` | `shared-workflow` | `shared-skill` | `.agents/skills/breakdown-feature-implementation/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/breakdown-feature-implementation.prompt.md` | `Goal` | `shared-workflow` | `shared-skill` | `.agents/skills/breakdown-feature-implementation/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/breakdown-feature-implementation.prompt.md` | `Output Format` | `shared-workflow` | `shared-skill` | `.agents/skills/breakdown-feature-implementation/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/breakdown-feature-prd.prompt.md` | `3. Goal` | `shared-workflow` | `shared-skill` | `.agents/skills/breakdown-feature-prd/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/breakdown-feature-prd.prompt.md` | `Launcher Surface` | `launcher-only` | `launcher` | `` | Prompt launcher wrapper maps only to the repository-convention launcher surface.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/breakdown-feature-prd.prompt.md` | `Goal` | `shared-workflow` | `shared-skill` | `.agents/skills/breakdown-feature-prd/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/breakdown-feature-prd.prompt.md` | `Output Format` | `shared-workflow` | `shared-skill` | `.agents/skills/breakdown-feature-prd/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/code-exemplars-blueprint-generator.prompt.md` | `Launcher Surface` | `launcher-only` | `launcher` | `` | Prompt launcher wrapper maps only to the repository-convention launcher surface.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/code-exemplars-blueprint-generator.prompt.md` | `${SCAN_DEPTH == "Comprehensive" ? "7" : "6"}. Output Format` | `shared-workflow` | `shared-skill` | `.agents/skills/code-exemplars-blueprint-generator/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/drafts/create-github-issues-feature-from-implementation-plan.prompt.md` | `Launcher Surface` | `launcher-only` | `launcher` | `` | Prompt launcher wrapper maps only to the repository-convention launcher surface.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/drafts/create-github-issues-feature-from-implementation-plan.prompt.md` | `Process` | `shared-workflow` | `shared-skill` | `.agents/skills/create-github-issues-feature-from-implementation-plan/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/drafts/create-implementation-plan.prompt.md` | `2. Implementation Steps` | `shared-workflow` | `shared-skill` | `.agents/skills/create-implementation-plan/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/drafts/create-implementation-plan.prompt.md` | `Launcher Surface` | `launcher-only` | `launcher` | `` | Prompt launcher wrapper maps only to the repository-convention launcher surface.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/drafts/create-technical-spike.prompt.md` | `Launcher Surface` | `launcher-only` | `launcher` | `` | Prompt launcher wrapper maps only to the repository-convention launcher surface.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/drafts/create-technical-spike.prompt.md` | `Best Practices for AI Agents` | `shared-workflow` | `shared-skill` | `.agents/skills/create-technical-spike/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/drafts/create-technical-spike.prompt.md` | `Phase 1: Information Gathering` | `shared-workflow` | `shared-skill` | `.agents/skills/create-technical-spike/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/drafts/create-technical-spike.prompt.md` | `Phase 2: Validation & Testing` | `shared-workflow` | `shared-skill` | `.agents/skills/create-technical-spike/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/drafts/create-technical-spike.prompt.md` | `Phase 3: Decision & Documentation` | `shared-workflow` | `shared-skill` | `.agents/skills/create-technical-spike/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/drafts/potential-feature-prd.prompt.md` | `Launcher Surface` | `launcher-only` | `launcher` | `` | Prompt launcher wrapper maps only to the repository-convention launcher surface.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/drafts/potential-feature-prd.prompt.md` | `Goal` | `shared-workflow` | `shared-skill` | `.agents/skills/potential-feature-prd/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/drafts/potential-feature-prd.prompt.md` | `Output Format` | `shared-workflow` | `shared-skill` | `.agents/skills/potential-feature-prd/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/drafts/update-implementation-plan.prompt.md` | `2. Implementation Steps` | `shared-workflow` | `shared-skill` | `.agents/skills/update-implementation-plan/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/drafts/update-implementation-plan.prompt.md` | `Launcher Surface` | `launcher-only` | `launcher` | `` | Prompt launcher wrapper maps only to the repository-convention launcher surface.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/execute-hard-lock.prompt.md` | `Launcher Surface` | `launcher-only` | `launcher` | `` | Prompt launcher wrapper maps only to the repository-convention launcher surface.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/execute-hard-lock.prompt.md` | `Body` | `hook-candidate` | `hook` | `.codex/hooks/execute-hard-lock.ps1` | Section contains hard-gate or forbidden-action language that resembles a native validation hook. |
| `.github/prompts/execute-plan-template.md` | `Launcher Surface` | `launcher-only` | `launcher` | `` | Prompt launcher wrapper maps only to the repository-convention launcher surface.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/execute-plan-template.md` | `**Authoritative Documents:**` | `shared-workflow` | `shared-skill` | `.agents/skills/execute-plan-template/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/execute-plan-template.md` | `Task Execution` | `shared-workflow` | `shared-skill` | `.agents/skills/execute-plan-template/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/export-chat.prompt.md` | `Launcher Surface` | `launcher-only` | `launcher` | `` | Prompt launcher wrapper maps only to the repository-convention launcher surface.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/fillout-prd-feature.prompt.md` | `Launcher Surface` | `launcher-only` | `launcher` | `` | Prompt launcher wrapper maps only to the repository-convention launcher surface.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/fillout-prd-feature.prompt.md` | `Objective` | `shared-workflow` | `shared-skill` | `.agents/skills/fillout-prd-feature/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/fillout-prd-feature.prompt.md` | `Steps` | `shared-workflow` | `shared-skill` | `.agents/skills/fillout-prd-feature/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/generate-atomic-plan.prompt.md` | `Launcher Surface` | `launcher-only` | `launcher` | `` | Prompt launcher wrapper maps only to the repository-convention launcher surface.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/generate-commit-message-repo.prompt.md` | `Launcher Surface` | `launcher-only` | `launcher` | `` | Prompt launcher wrapper maps only to the repository-convention launcher surface.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/generate-commit-message-repo.prompt.md` | `Core Objectives` | `shared-workflow` | `shared-skill` | `.agents/skills/generate-commit-message-repo/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/generate-commit-message-repo.prompt.md` | `Prioritization Rules` | `shared-workflow` | `shared-skill` | `.agents/skills/generate-commit-message-repo/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/generate-pr.prompt.md` | `Launcher Surface` | `launcher-only` | `launcher` | `` | Prompt launcher wrapper maps only to the repository-convention launcher surface.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/generate-pr.prompt.md` | `Core Objectives` | `hook-candidate` | `hook` | `.codex/hooks/generate-pr.ps1` | Section contains hard-gate or forbidden-action language that resembles a native validation hook. |
| `.github/prompts/generate-pr.prompt.md` | `GitHub Auto-close (strict)` | `shared-workflow` | `shared-skill` | `.agents/skills/generate-pr/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/generate-pr.prompt.md` | `Hard Prohibitions (Non-negotiable)` | `hook-candidate` | `hook` | `.codex/hooks/generate-pr.ps1` | Section contains hard-gate or forbidden-action language that resembles a native validation hook. |
| `.github/prompts/generate-pr.prompt.md` | `How to Use `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt`` | `shared-workflow` | `shared-skill` | `.agents/skills/generate-pr/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/generate-pr.prompt.md` | `Output Format (GitHub-flavored Markdown only)` | `shared-workflow` | `shared-skill` | `.agents/skills/generate-pr/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/generate-pr.prompt.md` | `Section Rules` | `shared-workflow` | `shared-skill` | `.agents/skills/generate-pr/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/javascript-typescript-jest.prompt.md` | `Launcher Surface` | `launcher-only` | `launcher` | `` | Prompt launcher wrapper maps only to the repository-convention launcher surface.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/orchestrate-csharp-work.prompt.md` | `Launcher Surface` | `launcher-only` | `launcher` | `` | Prompt launcher wrapper maps only to the repository-convention launcher surface.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/orchestrate-csharp-work.prompt.md` | `Objective` | `shared-workflow` | `shared-skill` | `.agents/skills/orchestrate-csharp-work/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/orchestrate-csharp-work.prompt.md` | `Required orchestration behavior` | `shared-workflow` | `shared-skill` | `.agents/skills/orchestrate-csharp-work/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/orchestrate-powershell-work.prompt.md` | `Launcher Surface` | `launcher-only` | `launcher` | `` | Prompt launcher wrapper maps only to the repository-convention launcher surface.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/orchestrate-powershell-work.prompt.md` | `Objective` | `shared-workflow` | `shared-skill` | `.agents/skills/orchestrate-powershell-work/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/orchestrate-powershell-work.prompt.md` | `Required orchestration behavior` | `shared-workflow` | `shared-skill` | `.agents/skills/orchestrate-powershell-work/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/orchestrate-python-work.prompt.md` | `Launcher Surface` | `launcher-only` | `launcher` | `` | Prompt launcher wrapper maps only to the repository-convention launcher surface.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/orchestrate-python-work.prompt.md` | `Objective` | `shared-workflow` | `shared-skill` | `.agents/skills/orchestrate-python-work/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/orchestrate-python-work.prompt.md` | `Required orchestration behavior` | `shared-workflow` | `shared-skill` | `.agents/skills/orchestrate-python-work/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/orchestrate-work.prompt.md` | `Launcher Surface` | `launcher-only` | `launcher` | `` | Prompt launcher wrapper maps only to the repository-convention launcher surface.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/orchestrate-work.prompt.md` | `Objective` | `shared-workflow` | `shared-skill` | `.agents/skills/orchestrate-work/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/orchestrate-work.prompt.md` | `Required orchestration behavior` | `shared-workflow` | `shared-skill` | `.agents/skills/orchestrate-work/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/remediate-comments.prompt.md` | `Launcher Surface` | `launcher-only` | `launcher` | `` | Prompt launcher wrapper maps only to the repository-convention launcher surface.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/remediate-comments.prompt.md` | `Completion Criteria` | `shared-workflow` | `shared-skill` | `.agents/skills/remediate-comments/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/remediate-comments.prompt.md` | `Execution Rules` | `shared-workflow` | `shared-skill` | `.agents/skills/remediate-comments/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/remediate-comments.prompt.md` | `Launch Template` | `shared-workflow` | `shared-skill` | `.agents/skills/remediate-comments/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/remediate-comments.prompt.md` | `Policy Order` | `shared-workflow` | `shared-skill` | `.agents/skills/remediate-comments/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/remediate-comments.prompt.md` | `Workflow` | `shared-workflow` | `shared-skill` | `.agents/skills/remediate-comments/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/research-issue.prompt.md` | `Launcher Surface` | `launcher-only` | `launcher` | `` | Prompt launcher wrapper maps only to the repository-convention launcher surface.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/research-issue.prompt.md` | `Goal` | `shared-workflow` | `shared-skill` | `.agents/skills/research-issue/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/research-issue.prompt.md` | `What to Investigate` | `shared-workflow` | `shared-skill` | `.agents/skills/research-issue/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/review-epic.prompt.md` | `Launcher Surface` | `launcher-only` | `launcher` | `` | Prompt launcher wrapper maps only to the repository-convention launcher surface.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/review-epic.prompt.md` | `Conditional deliverables (only if remediation is required)` | `shared-workflow` | `shared-skill` | `.agents/skills/review-epic/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/review-epic.prompt.md` | `Evidence provenance and freshness rules (blocking metrics)` | `shared-workflow` | `shared-skill` | `.agents/skills/review-epic/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/review-epic.prompt.md` | `Goal` | `shared-workflow` | `shared-skill` | `.agents/skills/review-epic/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/review-epic.prompt.md` | `Output format` | `shared-workflow` | `shared-skill` | `.agents/skills/review-epic/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/review-epic.prompt.md` | `Required deliverables` | `hook-candidate` | `hook` | `.codex/hooks/review-epic.ps1` | Section contains hard-gate or forbidden-action language that resembles a native validation hook. |
| `.github/prompts/review-feature.prompt.md` | `Launcher Surface` | `launcher-only` | `launcher` | `` | Prompt launcher wrapper maps only to the repository-convention launcher surface.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/review-feature.prompt.md` | `Atomic planner delegation requirements (mandatory when remediation is triggered)` | `shared-workflow` | `shared-skill` | `.agents/skills/review-feature/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/review-feature.prompt.md` | `Conditional deliverables (only if remediation is required)` | `shared-workflow` | `shared-skill` | `.agents/skills/review-feature/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/review-feature.prompt.md` | `Goal` | `shared-workflow` | `shared-skill` | `.agents/skills/review-feature/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/review-feature.prompt.md` | `Minor-audit integrity gate (mandatory when `issue.md` declares `- Work Mode: minor-audit`)` | `hook-candidate` | `hook` | `.codex/hooks/review-feature.ps1` | Section contains hard-gate or forbidden-action language that resembles a native validation hook. |
| `.github/prompts/review-feature.prompt.md` | `Output Format` | `shared-workflow` | `shared-skill` | `.agents/skills/review-feature/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/review-feature.prompt.md` | `Required deliverables` | `hook-candidate` | `hook` | `.codex/hooks/review-feature.ps1` | Section contains hard-gate or forbidden-action language that resembles a native validation hook. |
| `.github/prompts/review-staged.prompt.md` | `Launcher Surface` | `launcher-only` | `launcher` | `` | Prompt launcher wrapper maps only to the repository-convention launcher surface.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/review-staged.prompt.md` | `Conditional deliverables (only if remediation is required)` | `shared-workflow` | `shared-skill` | `.agents/skills/review-staged/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/review-staged.prompt.md` | `Goal` | `shared-workflow` | `shared-skill` | `.agents/skills/review-staged/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/review-staged.prompt.md` | `Output Format` | `shared-workflow` | `shared-skill` | `.agents/skills/review-staged/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/review-staged.prompt.md` | `Required deliverables` | `shared-workflow` | `shared-skill` | `.agents/skills/review-staged/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/update_status.prompt.md` | `Launcher Surface` | `launcher-only` | `launcher` | `` | Prompt launcher wrapper maps only to the repository-convention launcher surface.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/update_status.prompt.md` | `Goal` | `shared-workflow` | `shared-skill` | `.agents/skills/update-status/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |

## Validation Findings

- None
