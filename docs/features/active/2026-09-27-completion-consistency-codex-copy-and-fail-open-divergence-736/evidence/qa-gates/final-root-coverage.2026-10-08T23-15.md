# final-root-coverage

Timestamp: 2026-10-08T19-02
Command: npm run test:unit:coverage --prefix .
EXIT_CODE: 0
Output Summary: (last 25 lines of combined stdout/stderr; total lines 271)

```text
 agent-a3a8ae98004a68a68/extensions/drm-copilot/test/lib/pr-context                |   98.03 |    94.28 |     100 |   98.03 |                                                                                   
  tree-file-system.ts                                                              |   98.03 |    94.28 |     100 |   98.03 | 139-141                                                                           
 agent-a3a8ae98004a68a68/extensions/drm-copilot/test/lib/push-down                 |   98.36 |     87.5 |     100 |   98.36 |                                                                                   
  config-carriage.test-helpers.ts                                                  |     100 |      100 |     100 |     100 |                                                                                   
  push-down.test-helpers.ts                                                        |   97.72 |    90.32 |     100 |   97.72 | 12-13,123-124                                                                     
  real-bundle-filesystem.test-helpers.ts                                           |   98.96 |    84.21 |     100 |   98.96 | 57-58                                                                             
  seeded-random.test-helpers.ts                                                    |   93.75 |    81.81 |     100 |   93.75 | 47-50,64-65                                                                       
 agent-a3a8ae98004a68a68/extensions/drm-copilot/test/lib/subagent-tree             |   88.72 |    85.18 |   69.23 |   88.72 |                                                                                   
  in-memory-file-system.ts                                                         |   88.72 |    85.18 |   69.23 |   88.72 | 46-48,51-52,74-75,80-81,84-86,119-121                                             
 agent-a3a8ae98004a68a68/extensions/drm-copilot/test/lib/validate                  |   96.83 |    90.72 |    73.8 |   96.83 |                                                                                   
  epic-planner-launch-evidence-test-support.ts                                     |   91.91 |       80 |   47.61 |   91.91 | 19-20,42-43,104-105,112-113,120-121,126-127,132-133,136-137                       
  orchestration-handoff-materializer-test-support.ts                               |   98.76 |    95.45 |     100 |   98.76 | 318-321                                                                           
  parallel-kickoff-fixtures.ts                                                     |     100 |      100 |     100 |     100 |                                                                                   
  parallel-state-test-support.ts                                                   |   97.52 |    78.57 |     100 |   97.52 | 181-182,185-186,223-224                                                           
 agent-a3a8ae98004a68a68/packages/mcp-server                                       |   90.16 |     87.5 |     100 |   90.16 |                                                                                   
  prepack.cjs                                                                      |   90.16 |     87.5 |     100 |   90.16 | 56-61                                                                             
 agent-a3a8ae98004a68a68/src                                                       |     100 |      100 |     100 |     100 |                                                                                   
  hello-typescript.ts                                                              |     100 |      100 |     100 |     100 |                                                                                   
-----------------------------------------------------------------------------------|---------|----------|---------|---------|-----------------------------------------------------------------------------------

Test Suites: 257 passed, 257 total
Tests:       3923 passed, 3923 total
Snapshots:   0 total
Time:        7.84 s
Ran all test suites.
```

Key lines matching /^(File +\||All files|Tests:)/ from the full output:
```text
File                                                                               | % Stmts | % Branch | % Funcs | % Lines | Uncovered Line #s                                                                 
All files                                                                          |   97.76 |    91.42 |   91.42 |   97.76 |                                                                                   
Tests:       3923 passed, 3923 total
```
