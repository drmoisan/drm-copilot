# Skill Identity Pass (P1-T1)

Timestamp: 2026-11-16T01-20
Command: pwsh -NoProfile -File SCRATCH/issue-1025-skill-identity.ps1
EXIT_CODE: 0
Output Summary: 65 multi-tree names; byte-identical 14, wording-only 23, substantive 28.

Method: each copy is hashed with `git hash-object`. Normalized text removes heading markers, collapses whitespace and drops blank lines. Class `byte-identical` when every hash is equal; `wording-only` when the normalized texts are equal, or when every pair has the same normalized heading set and at most 10% of normalized lines differ (`DiffRatio`, worst pair: differing lines over the sum of both line counts); otherwise `substantive`.

Rows: 65

| Skill | Claude hash | Codex hash | Copilot hash | Normalized | DiffRatio | Class |
| --- | --- | --- | --- | --- | --- | --- |
| acceptance-criteria-tracking | 4fbae4889c31daefd20cd22a9621cb33b8d0c349 | 8ccf8ba25d2bf950cc37eec352b0c9b54793b4a8 | 8ccf8ba25d2bf950cc37eec352b0c9b54793b4a8 | differs | 0.007 | wording-only |
| adjudicate-unspecified-behavior | 04a8003bde187d153a57dfd8da77660fa217899c | 81186740765a4ec14a5606c09559107bfb97daed | 8aabe32e25ddf0e0c2ed7a66706d99b88bd09f4b | differs | 0.009 | wording-only |
| atomic-plan-contract | e7b55a48064d616922cc1bff5da258e7cc141471 | 4fa2ccc48351f30e0e6f90b40b4fdc5128c465fc | 13d6922c2363f1f3cb1aac165897e8ab811e0680 | differs | 0.216 | substantive |
| characterize-runtime-behavior | 7f116d9143467bd4313fcd1d8566e364fef921da | c8e43357d9a7a9a18cc6bc348563f25681947a58 | 90e3e0df72115c0ef02f9b67d4aa4d787633178b | differs | 0.009 | wording-only |
| commit-message | fde6c37f1a831d1131ca701105162d5d1b79dbca | a3848f0542f24903359a04b06c68afb4258582ef | - | differs | 0.101 | substantive |
| csharp-change-budget-router | fe516c7d4f2d48f7041dcb40d3b9380bad2e52a8 | 8ff4d254756d36c513895d829b098fe6081aebd6 | 878fa4bf034be8a664ffaa7abb5f71ad0efc5a12 | differs | 0.347 | substantive |
| csharp-orchestration-state-machine | e6f14aa6106c06ac1adc4ec9a7a8d0d40aac0d19 | b1916d4e8b91711ea79a64c02a966506fb991300 | 87629fb506a31702501b950c2391278745ccd9ce | differs | 0.011 | wording-only |
| csharp-qa-gate | 64783879f225085a411142dc809a52a1bb7df302 | 54fda084fc94a69ffd6096b96a468fd679abaf2f | - | differs | 0.25 | substantive |
| discovery-behavior-reconciliation | c02078ef0d094d1e25b8f5986dde58262ac01437 | c02078ef0d094d1e25b8f5986dde58262ac01437 | c02078ef0d094d1e25b8f5986dde58262ac01437 | equal | 0 | byte-identical |
| discovery-coverage-ledger | d44820f4d0264675dd07f999a53b6be660942287 | d44820f4d0264675dd07f999a53b6be660942287 | d44820f4d0264675dd07f999a53b6be660942287 | equal | 0 | byte-identical |
| discovery-parity-matrix | a687f8c398d1cfc41f86740726362fea83fe40a7 | a687f8c398d1cfc41f86740726362fea83fe40a7 | a687f8c398d1cfc41f86740726362fea83fe40a7 | equal | 0 | byte-identical |
| discovery-repo-inventory | beeaeb7808f56bb8e5e52b4f08f7e7b416e37683 | beeaeb7808f56bb8e5e52b4f08f7e7b416e37683 | beeaeb7808f56bb8e5e52b4f08f7e7b416e37683 | equal | 0 | byte-identical |
| discovery-runtime-characterization | 1b134819832f15c47c1efe2a7289e1a15ac914ab | 1b134819832f15c47c1efe2a7289e1a15ac914ab | 1b134819832f15c47c1efe2a7289e1a15ac914ab | equal | 0 | byte-identical |
| discovery-validate-artifacts | 9c3355fe4e396a651067af7a2b547575b6d35316 | 9c3355fe4e396a651067af7a2b547575b6d35316 | 9c3355fe4e396a651067af7a2b547575b6d35316 | equal | 0 | byte-identical |
| discovery-workflow | 1fc7661e517dfec4c88617459b875dcc075471f4 | 1fc7661e517dfec4c88617459b875dcc075471f4 | 1fc7661e517dfec4c88617459b875dcc075471f4 | equal | 0 | byte-identical |
| docs-author-page | 423766abd2b4b3f05465b4e6bfb918ca007d2b07 | 593edaaefe7ac578f544bb5abf6579eff59fcefd | 88f5e07b223e4d161c4c10383fdf2e993b63af39 | differs | 0.054 | wording-only |
| docs-init | c9da0972a2e65069794cf8859833877240d1010d | 933959f5b3c6419f8e8ac7fbe9b51c2afc5beead | 933959f5b3c6419f8e8ac7fbe9b51c2afc5beead | differs | 0.089 | wording-only |
| docs-inventory-surface | 7cbb60225d566fe611bff0a5ba607f12eec8234e | 4b04e3fcc5acc3f2cd72021b4e7d94621e0d5c61 | 2a867afb7297a1b57d5ea68a21b1b0c2724ae572 | differs | 0.103 | substantive |
| docs-plan-ia | 1e093024214e99efd20a763fe8d0481d4a920528 | 3bd87aab2058848a1c41cab93ccd03aace7bbadf | 5ecb364077defce457428ea4912c913ce7695ece | differs | 0.069 | wording-only |
| docs-reconcile-behavior | f903a8dccf492b6ecc782dd3826c9a3cba525cfa | cd1fcaf98dc8b1e7147333d5d86cceb01e0148ce | e9ab33431c900e3be9caf6c3e61124f861840244 | differs | 0.056 | wording-only |
| docs-review-coverage | b0877bdd41c691a2e9fc986bb4fc59c5eb12027b | e9be663eec814d3c1b832308d924f6ffa6bde054 | 42a173eec51c827e485dfdd6b1fd47dc3938b792 | differs | 0.103 | substantive |
| docs-validate | 75961839c987755c8378a2f0cd5ea5ddb8101e24 | eaa526d1fa517539eb2d85608f306d5593fca2e2 | 015fd5747a0ee3dd0737e0106dde2b60648fa2e1 | differs | 0.136 | substantive |
| documentation-workflow | 6bfbea904710c12801811e1bf9417a85c451fc16 | 3e4dfc1e7eb199b5b67cf7c3c62d600303b7d7b5 | 12e3ad6d61f878c5c5f196095edf76d5b231935d | differs | 0.1 | wording-only |
| epic-orchestrate | fa8fdad18ef3454e1957e1852c6e5eee869d186f | 334cb9f5b3754f84089d43098feb13c28a0d137c | - | differs | 0.698 | substantive |
| epic-plan | e3f300106ebbda9b1ef1f9f403e4580859281f9c | 436fedf47d26eeda50a806b5ebe6b45cd5b90213 | - | differs | 0.834 | substantive |
| epic-run | 8968e6e97cdccfaf5643e8204438f51025aae62b | 53be1dd3366eb7381ecb5d797bcb2bdd559a1eda | - | differs | 0.788 | substantive |
| evidence-and-timestamp-conventions | 8017e70f865cfdfee9abc00320bbd1baaec485ae | 5b9f72cc968a01eec9e0728827e71a8fd16e6151 | d84850c71e49d15109193dc34cdf664e875ef1b2 | differs | 0.089 | substantive |
| execute-hard-lock | b5cc4cfd6e69fef8a818226dda3a147cbd0b5d58 | 78b4109bffffda5502cf646d5b979550affa6f60 | - | differs | 0.107 | substantive |
| execution-environment | b0ca4b7dba5c439204cb9201f959fc368a88a00a | b0ca4b7dba5c439204cb9201f959fc368a88a00a | b0ca4b7dba5c439204cb9201f959fc368a88a00a | equal | 0 | byte-identical |
| extract-feature-contract | 731804feb2bc685da9c763ab4645c72a239c2b75 | 483f5bbeefbc5ccd7885cba203ae07a7b3bed114 | c0a68d2f24cb86b2f7bea00a17ced3d2dd8d0a3d | differs | 0.009 | wording-only |
| feature-promotion-lifecycle | 5cc2c5d721b1edd345afb5780bfee93a8550c9b8 | 649eb6452b7e33ee11a4eb7e2a0c6922e0e3fa18 | 2d91df2ea56e71aa2fec479bd1beae33bfeccf40 | differs | 0.483 | substantive |
| feature-review-workflow | 9476e14cbb5fa66de5f543637c8fd5b9759e1209 | 62a90eb12a8296ee18cd7e1c2d4614dee591cfd8 | 245b22070a47defddee39d85f50439493ea2e9cf | differs | 0.181 | substantive |
| fill-feature-docs | ed723f21ce9656fc9a367f02b35c0a8a89f84816 | 6093853c98a577261be0a3950f9cbf43d1e7f6d1 | - | differs | 0.067 | wording-only |
| generate-acceptance-scenarios | 2fc96c37ae5a10e4e206d749ba0b5c55db99ecd6 | 95bb8fd323a624861a67bdcf188e0e47cd3326aa | 2befb267c2ff76e0130a0e7bba91088b6fba0185 | differs | 0.009 | wording-only |
| human-exception-runbook | 1cae5214cfe358f018d72e4e25403ebcb851053c | 98b5ba9f3c7b1ed500d25f723c6190f9ca72f5a2 | - | differs | 0.085 | wording-only |
| initialize-discovery-workspace | c13a1ce616c494cd8ba3916fab53e4ad604e9575 | c240d0844f45b2d2e3e788957c2cde72ef925a50 | f8dc58e4252b745b042fdbd79a6f8b1a6ff528a4 | differs | 0.009 | wording-only |
| inventory-legacy-system | 6f87a65c442a7c15ce42881c53fc9d04ada848f7 | 93a8a1dbca90d68401f72234dee137346abf1c93 | 519862520c16e35f1bcc4e0716136eeba31f4a1d | differs | 0.009 | wording-only |
| invoke-csharp-engineer | 3e0e99c62531df29103388d2b6c130097e8d6878 | bc7fcc9e4670a43db5181d710c2531e7e745377c | - | differs | 0.16 | substantive |
| invoke-powershell-engineer | 8d93eb1af273243b95df3df8de0d098314dab018 | ca3fda98b02e188227444d4f074b55efad5b08b0 | - | differs | 0.2 | substantive |
| invoke-python-engineer | d4a351a82ccaf8928f75dd864b3c80669008ade2 | c9bf834f6db5b7319d5dcdb03dce36d7ee2be12b | - | differs | 0.184 | substantive |
| make-skill-template | 663487f75491ab2464e0294d235c5aaef3bb4f06 | 663487f75491ab2464e0294d235c5aaef3bb4f06 | 3c83f634bbfc5e5a935a851f90c27ec0b2bf4ea8 | equal | 0 | wording-only |
| orchestrate | 2af6887d35c04055dcc18ff6cd4efdc072e6211b | 453ab24752cbfe066c7921105077c71b6559b595 | - | differs | 0.789 | substantive |
| owner-directives | 71f2fae78102af5ad198b58f87d96096fc8524cb | 71f2fae78102af5ad198b58f87d96096fc8524cb | 71f2fae78102af5ad198b58f87d96096fc8524cb | equal | 0 | byte-identical |
| policy-audit-template-usage | f1b00fbf95c160795cef297610676d2b2cf0139d | b64bc0cc3b7a0d9f3d456d0b7060d46e65358239 | 8603c5e9ecfeb2eddfe9d30ebea660b4e1a5dd74 | differs | 0.105 | substantive |
| policy-compliance-order | f1876b2a8a67a09880db3de4890311eb93b3a0d7 | d90f9464c31582cfd20b45d23dbba741a125eefb | 3ca55a376a1c203deb7f073bef1d8df161be9267 | differs | 0.345 | substantive |
| powershell-change-budget-router | 1786a58f2e9533afec979e3b965ed52f9d17441a | 879f897e08b9ee71e615ea1dc6e81e24373f5588 | 95626fbf1d7bd5c7612cbd8d60720e759421a966 | differs | 0.229 | substantive |
| powershell-orchestration-state-machine | bc7dea6e965973a42c5852b86ca020ea106ae6b7 | 18b3b7161da98992a2f6fd28d618b0e91d1ae702 | 3cb224a01f5bd0186840201da439011539525bd4 | differs | 0.221 | substantive |
| powershell-qa-gate | 91da1c0d00969c159b361809b392dfc4f2ef224d | d764f7bb1c420d05f4c70d34b02f5d6886552e8f | - | differs | 0.093 | wording-only |
| pr-author | f4150c65b3eb45de299f5d59c3a5d75175e2c381 | dbbba68744f11914f973838fb9351e9e9a331ac2 | - | differs | 0.447 | substantive |
| pr-base-branch-merge-base | 61a32708c90b56bd800fa1de6df9da959ddb1dcd | 7c6c1453d6f79bd037e8e3da387123e835aad6de | a8215797e18b859738f87857160b4139254df97b | differs | 0.103 | substantive |
| pr-context-artifacts | c92099871eb0d4bbcdcb80e7774b389718aef527 | 2735c040e2d38512af910d95f6bd2da04a14e620 | 2735c040e2d38512af910d95f6bd2da04a14e620 | equal | 0 | wording-only |
| python-change-budget-router | 95a671b80054220ba7b031fd94ab8f2971f95cfd | 5365f863e621280c9218b7695c30de6fca0595c6 | - | differs | 0.132 | substantive |
| python-qa-gate | 283acf4c8c46fe55acb30f0abf70566daae43aee | 373b4a2707a8fbab73acacdd05b08516b02fef62 | - | differs | 0.093 | wording-only |
| reconcile-parity-matrix | c7591ce6698db59620003ba0d53899b7d839b8eb | e43278205f3d30c1820afff93850d3c2b3b36030 | 7acf8909de79d16000b4da2674f55d69c3c1651d | differs | 0.009 | wording-only |
| remediation-handoff-atomic-planner | b1bdfa3d5b94f8f5260164a23644a904a713d948 | df7d440b6beb58e8291188d4927962cd1fd9e912 | 8b4aaaea62dbb969c056222f536f97eab7b4d05e | differs | 0.798 | substantive |
| research-issue | 9dfa29898739b1acd8499aaafb7f2ad81273b62e | 0068912c05de423587d2a9ff41c8b3f434fdb49f | - | differs | 0.188 | substantive |
| review-discovery-coverage | 3e4758d125ebcb85b2c72159f777a631ae01bd64 | 1ba159fcee49f8a57015b2b3ecf3ced06e672316 | d233e94eb1348a0d108aacdf3e7604333e9ae728 | differs | 0.01 | wording-only |
| review-epic | 874938d5d89c3a487b4838c28d08a867dfac96cf | 874938d5d89c3a487b4838c28d08a867dfac96cf | - | equal | 0 | byte-identical |
| review-feature | 13458d0431a564439b71767c8cac1626822f0b50 | 13458d0431a564439b71767c8cac1626822f0b50 | - | equal | 0 | byte-identical |
| review-staged | bf13314a0f8a8973e8dd47f28fd4ae06a0ec1fe6 | bf13314a0f8a8973e8dd47f28fd4ae06a0ec1fe6 | - | equal | 0 | byte-identical |
| skill-canonical-location-audit | 2da5e0ddd94972d137fae53b66b66a8e55704e3e | a9b3578df75668f62ee2638968716b511b588c51 | 81a40c7d1f32a3410f276f5327053c27a60efd10 | differs | 0.03 | wording-only |
| test-execution-policy | f5f082a39bbeccccaef1aad9fc99b8c1296af904 | f5f082a39bbeccccaef1aad9fc99b8c1296af904 | f5f082a39bbeccccaef1aad9fc99b8c1296af904 | equal | 0 | byte-identical |
| translate-copilot-to-claude | 428c961a18c7ae23ca32a6c184502812ed1b4e85 | 94f8354d108abee952f0665681b26cf092991fb1 | - | differs | 0.249 | substantive |
| update-status | f8148330d40b41cf591965eb45924ee30ce823c3 | f8148330d40b41cf591965eb45924ee30ce823c3 | - | equal | 0 | byte-identical |
| validate-discovery-artifacts | a366e99663cfdd71e68321341270ce933434fe3f | 40e146b8dda1b93f1098335d0e52063628e3f02c | cd4fbcf341c0321485ce75309d8d99e5c8f4e389 | differs | 0.01 | wording-only |
