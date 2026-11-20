# GitHub-Native Inventory

Timestamp: 2026-11-19T07-51
Plan: plan.2026-10-30T18-39.md
Command: git ls-files .github/prompts .github/hooks .github/agents; git hash-object <each file>
EXIT_CODE: 0
Output Summary: .github/prompts 30 files; .github/hooks 6 files; .github/agents (COPILOT-AGENT-FILES) 50 files.

## .github/prompts (30 files)

- `.github/prompts/add-educational-comments.prompt.md` 63a99970fff2b4eb453e5b26cec862c7318e90c8
- `.github/prompts/breakdown-bug-prd.prompt.md` ce47b89e5a616bd428ad5f9b05b6d692010c19d0
- `.github/prompts/breakdown-epic-arch.prompt.md` 3b5a5adad9b3f8ebb1e28d10e3f8a0f149a63a14
- `.github/prompts/breakdown-epic-pm.prompt.md` 8c60e6d24d037f7bdbc180c9eb783422a762cf2e
- `.github/prompts/breakdown-feature-implementation.prompt.md` 8544f734f03fb30a0281b413499c68c8d93b26ab
- `.github/prompts/breakdown-feature-prd.prompt.md` f55a5864d1613dc8b954bda5706a1ae51f19ba88
- `.github/prompts/code-exemplars-blueprint-generator.prompt.md` c427c91713570c362ac7649e7ef82ef1880a1738
- `.github/prompts/drafts/create-github-issues-feature-from-implementation-plan.prompt.md` 8e7d8424e9cfe6ef073e0f2ef7bfdd8e00ee3895
- `.github/prompts/drafts/create-implementation-plan.prompt.md` c99613485752df149161eae742ddbef180022229
- `.github/prompts/drafts/create-technical-spike.prompt.md` f91caa2ee328eaaef3db9a61f7ea03f57b820671
- `.github/prompts/drafts/potential-feature-prd.prompt.md` ffe5d12d3c863e0d9a9f19a87c03757e305eafab
- `.github/prompts/drafts/update-implementation-plan.prompt.md` abfe7e6f0b3a59681f05ce8659b6e7ade288a7c9
- `.github/prompts/execute-hard-lock.prompt.md` 132fa59019307c2d0b214f258171f9be3f974845
- `.github/prompts/execute-plan-template.md` 861231bb03e2848dd6fc7663e5f967d9db0d774b
- `.github/prompts/export-chat.prompt.md` 17e877606614a61c052d8705ad0d3f057c66c296
- `.github/prompts/fillout-prd-feature.prompt.md` 20e3a0c788add361561e830c039f12d0b6e982a5
- `.github/prompts/generate-atomic-plan.prompt.md` e790722050df400d0022efaa444b959aecd63183
- `.github/prompts/generate-commit-message-repo.prompt.md` 184e6ef4b063fb9b752058ea7f0d3d9894a0afba
- `.github/prompts/generate-pr.prompt.md` 905ac070874305bf429cd0a689f26575d9663836
- `.github/prompts/javascript-typescript-jest.prompt.md` 1c10e5f5f1f9274cdc0d71311db4ed332eec51ec
- `.github/prompts/orchestrate-csharp-work.prompt.md` 666be582deea3a3146a5fc54bc14296eb4550e78
- `.github/prompts/orchestrate-powershell-work.prompt.md` 878ad75c1cd9b5a1b6a7d5a2a128fe6e812769bb
- `.github/prompts/orchestrate-python-work.prompt.md` 82a43d63b8fb2dfec98fa45a1dac0c59f73d264c
- `.github/prompts/orchestrate-work.prompt.md` 8c2a89e662369499513c1464a95bc8479a030301
- `.github/prompts/remediate-comments.prompt.md` 4cae344699da628d29ea7cd86c8162a6eb23f1fa
- `.github/prompts/research-issue.prompt.md` 612e133b71599c21e7b01d19a4f4627c7a1124db
- `.github/prompts/review-epic.prompt.md` dddc9f9f4984682e05b397c854431fe92d81c250
- `.github/prompts/review-feature.prompt.md` de2ffef4918c3e0d3e47e104b94989c9afaf1232
- `.github/prompts/review-staged.prompt.md` 8693754a7dcdc7157a187acff473967c95c1ae90
- `.github/prompts/update_status.prompt.md` b32e740001d22e72d2155143a86207cef1623abc

## .github/hooks (6 files)

- `.github/hooks/discovery-agent-start.ps1` deec431e293e640533972eb1ac74998a305491fc
- `.github/hooks/discovery-agent-stop.ps1` 8395aa21b68507a0be9ec164e97e2a16563cd870
- `.github/hooks/discovery-capability-probe.ps1` e4f5be3b42e1ad36a24b11fba907375b688a8657
- `.github/hooks/discovery-planning.ps1` 969bdd2d25f17d9e74e256b00332f004c69b26ae
- `.github/hooks/discovery-pre-tool.ps1` 8ffff930b157bddf7ca51d9f5f257c616791de76
- `.github/hooks/discovery.json` 9b8fbbb75d71109fdc0ae301ca3ce1e4af3f2b7a

## .github/agents (50 files)

- `.github/agents/5.1-Beast-adjusted.agent.md` 22b823cb670b200878ebf6200d910e9658e10d75
- `.github/agents/5.1-Thinking-Beast-Mode-adjusted.agent.md` d85c25cc16bc433f23cb6ad25e371c963cb7bcae
- `.github/agents/Powershell DI Unit Test Engineer.agent.md` 39865d6cad88f7d5699c3b1ebefb7e2b6579ea46
- `.github/agents/api-architect.agent.md` 1739e98f43da1624b144baee5a8b88e27242cf79
- `.github/agents/atomic_executor.agent.md` b1bb7b3c270ee259e216f455cc6dd005813e217d
- `.github/agents/atomic_planning.agent.md` 7fbfab4bb1469246bf856a5ecb027ed4a821b271
- `.github/agents/commentary-remediation.agent.md` cb3e3a3c49a022e8bf3183fa12f8f2d62f2bf0a3
- `.github/agents/commit-steward.agent.md` e904c6bdda282479563b44c03e15981a7899050d
- `.github/agents/csharp-atomic-executor.agent.md` 684cce0abee70b084e78b7c648582266ac414ca7
- `.github/agents/csharp-atomic-planning.agent.md` 52020ac49b55cf34e013b70c41b03501dda9d288
- `.github/agents/csharp-orchestrator.agent.md` 8b60291143ed2024f5d57c1912cac9a5cc197a91
- `.github/agents/csharp-typed-engineer.agent.md` 9a6e925bfc33fb07c9d03ba515db1533e8117cf7
- `.github/agents/discovery-capability-sentinel.agent.md` 3900333d960548cf5ff73e8ce5831b931236ddc0
- `.github/agents/docs-architect.agent.md` a74e5eb7688bebd1942546741a26c6b3a9696328
- `.github/agents/docs-author.agent.md` f73c7ba103f24754c46fb1a91be70fc1f99c6f36
- `.github/agents/docs-coverage-reviewer.agent.md` 2c941fa080036787bdb971433a9928aea7395fd3
- `.github/agents/docs-reconciler.agent.md` c42cbf9c572c13cede8f6a1ad570e2975aac3f84
- `.github/agents/epic-review.agent.md` 0c6343156a2089c5d3b4036ffed11a8fd6ac8c5d
- `.github/agents/expert-nextjs-developer.agent.md` 850cd6382a4c7d0d0775a22d18fbdd95e356c963
- `.github/agents/expert-react-frontend-engineer.agent.md` 11db56673646153dc270e634e22bc1ecb5e363b8
- `.github/agents/feature-review.agent.md` 1ede1734d7d0e252a4ddd915d7ac5d82405186e2
- `.github/agents/gpt-5-beast-mode.agent.md` 508374142ca14fbb0a8a34237946b310fbbde6b5
- `.github/agents/hlbpa.agent.md` 1e0f83b6f9cbec8ef986c8d6c5821f3b4ea33226
- `.github/agents/legacy-parity-analyst.agent.md` c0c44879867e2cc56efe02a9fbddb46b19cdddaf
- `.github/agents/mentor.agent.md` 7adf92418d3a99a0cda924613bcc8768866b88e6
- `.github/agents/migration-coverage-reviewer.agent.md` 76191bf699a4a66e93fef9b6ca7090e3c539b240
- `.github/agents/orchestrator.agent.md` 44c0ce9c585fa2e0ac43c9560bf08f8ef874025d
- `.github/agents/powershell-atomic-executor.agent.md` ba8a20bc4970c82c95ed761564f17f8dc3d84b65
- `.github/agents/powershell-atomic-planning.agent.md` c1d6fb11ad4fafe2f75f20038ec7423dcf397d43
- `.github/agents/powershell-orchestrator.agent.md` 27667f9b4293f066fe2bc3bfcb41a3b22f7e1334
- `.github/agents/powershell-typed-engineer.agent.md` ebd866e2af5fcd584e4925ab006de851bf942781
- `.github/agents/pr-author.agent.md` 09ff047487576cc7ada6401ff16b032b21124265
- `.github/agents/prd-feature.agent.md` 529a88e93e618a3ae3afe164b1a68fce9014a31d
- `.github/agents/prd.agent.md` ea9003cbbc7b8ba63dcad7d10a6254b666587fc3
- `.github/agents/pytest-unit-test-coding.agent.md` ced33825452f400ced91572947f1b1efe34e5b00
- `.github/agents/python-atomic-executor.agent.md` 24c0cee2c3aa0fcfb036737e2dbfd81a5e6e2463
- `.github/agents/python-atomic-planning.agent.md` ac3012413df6be3c3e2bebdd2899ba6828b63635
- `.github/agents/python-execution-only-typed.agent.md` 91e3936913f606496f34c2ee70ea4ad1f118d61a
- `.github/agents/python-orchestrator.agent.md` fc73915bd1cddfecb5989b7d550a1d6b65a2602b
- `.github/agents/python-typed-engineer.agent.md` f531d717fa51c2e225bc4178ef5bf03d247d2453
- `.github/agents/requirements-reconciler.agent.md` 3013146bb09c254fcc596dd8e71f4642488c4b8f
- `.github/agents/runtime-characterization-analyst.agent.md` 33ad9bd3df6e97508589e653688ffa37e81f0086
- `.github/agents/staged-review.agent.md` 15eecf0605899b68055bc1a6cec7314dc624f121
- `.github/agents/status_updater.agent.md` 90a84a39a80f8600c1d8583ebf5d742ffd8cb52f
- `.github/agents/task-researcher.agent.md` 63e94bb14aee716d61a7c105c731df44a2d05bbc
- `.github/agents/tdd-green.agent.md` dbc3c58de63d923dad7407c3c1043d4ad43ec2a5
- `.github/agents/tdd-red.agent.md` a5f746fe8f703ec561250f6e7f61450a92d11443
- `.github/agents/tdd-refactor.agent.md` 9481e1bba4af0954add9577bc69d8053d1e568dd
- `.github/agents/typescript-engineer.agent.md` db0651f0f91a77af873e05b3a724bff6540b6423
- `.github/agents/voidbeast-gpt41enhanced.agent.md` 9f9100fb1ea3fa33e4eafd0e1d42cbf405c5cf40

