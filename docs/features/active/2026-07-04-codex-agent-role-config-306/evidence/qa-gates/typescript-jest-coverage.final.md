Timestamp: 2026-07-04T14-28
Command: Push-Location extensions/drm-copilot; npm run test:unit -- --coverage; Pop-Location
EXIT_CODE: 0
Output Summary:
- npm run test:unit -- --coverage completed successfully.
- Test Suites: 122 passed, 122 total
- Tests:       1472 passed, 1472 total
- Numeric coverage: All files                                                   |   96.88 |    88.25 |   88.29 |   96.88 |

Raw Output:

> drm-copilot@1.0.7 test:unit
> node run-jest.cjs --coverage

------------------------------------------------------------|---------|----------|---------|---------|---------------------------------------------------------------------------------------------------
File                                                        | % Stmts | % Branch | % Funcs | % Lines | Uncovered Line #s
------------------------------------------------------------|---------|----------|---------|---------|---------------------------------------------------------------------------------------------------
All files                                                   |   96.88 |    88.25 |   88.29 |   96.88 |
 src                                                        |   96.02 |    87.94 |   96.13 |   96.02 |
  claude-worktree-session.ts                                |     100 |      100 |     100 |     100 |
  codex-worktree-session.ts                                 |     100 |      100 |     100 |     100 |
  command-runtime.ts                                        |   92.65 |    83.09 |   94.73 |   92.65 | 118,213-214,221,316-326,355-357,385-390,394-399,403,522-529
  document-workflow-commands.ts                             |    92.7 |    78.26 |     100 |    92.7 | 60-63,76-77,86-89
  extension-command-helpers.ts                              |   99.44 |    93.84 |   94.11 |   99.44 | 39-40
  extension.ts                                              |   97.25 |    90.76 |     100 |   97.25 | 94-95,360-366,401-402,408-409
  mcp-provider.ts                                           |     100 |      100 |     100 |     100 |
  mcp-push-down-schema-properties.ts                        |     100 |      100 |     100 |     100 |
  mcp-repo-automation-tool-definitions.ts                   |     100 |      100 |     100 |     100 |
  mcp-server.ts                                             |   80.14 |       50 |      80 |   80.14 | 41-42,70-73,94-103,124-127,130-136
  mcp-tool-definitions.ts                                   |     100 |      100 |     100 |     100 |
  mcp-tool-inputs-push-down.ts                              |     100 |      100 |     100 |     100 |
  mcp-tool-inputs.ts                                        |   93.11 |    91.66 |   94.73 |   93.11 | 160-161,175-176,197-200,225-229,371-383,421-427
  mcp-tools.ts                                              |   91.08 |       75 |     100 |   91.08 | 68-69,154-157,172-175,178-181,184-185,188-191,228-230
  policy-audit-template-assets.ts                           |   97.29 |       75 |     100 |   97.29 | 68-69
  poshqc-command-registration.ts                            |   91.81 |    76.92 |     100 |   91.81 | 54-55,61-62,71-75
  pr-context-branches.ts                                    |   81.49 |    72.22 |     100 |   81.49 | 64-65,72-73,78-80,99-100,156-188
  remove-worktrees-runner.ts                                |     100 |       85 |     100 |     100 | 69,113,148
  remove-worktrees.ts                                       |   98.41 |    90.32 |     100 |   98.41 | 102-104
  repo-automation-args.ts                                   |     100 |      100 |     100 |     100 |
  repo-automation-command-registration-admin.ts             |   96.79 |    90.16 |     100 |   96.79 | 95-99,279-280,288-289,298-299,323-324
  repo-automation-command-registration-feature-workflows.ts |     100 |    98.14 |     100 |     100 | 267
  repo-automation-command-registration.ts                   |     100 |      100 |     100 |     100 |
  repo-automation-service-push-down.ts                      |   93.45 |    72.72 |      80 |   93.45 | 100-110
  repo-automation-service-support.ts                        |     100 |       50 |     100 |     100 | 132-134
  repo-automation-service-workflows.ts                      |     100 |      100 |     100 |     100 |
  repo-automation-service.ts                                |   98.39 |    86.95 |   93.93 |   98.39 | 252-259
  repo-automation-tool-names.ts                             |     100 |      100 |     100 |     100 |
  workflow-command-arguments.ts                             |   90.41 |    86.36 |   95.23 |   90.41 | 94-97,113-114,194-197,234-235,241-242,245-257,264-265,271-272,322-323,326-329
  workflow-command-invocations.ts                           |   99.24 |    95.65 |     100 |   99.24 | 193-194
 src/lib                                                    |   96.91 |    90.82 |   93.75 |   96.91 |
  collect-commit-context.ts                                 |     100 |    96.96 |     100 |     100 | 199
  file-system.ts                                            |   92.59 |    87.09 |   84.61 |   92.59 | 113-114,116-117,177-180,272-277,285-294
  hello-message.ts                                          |     100 |      100 |     100 |     100 |
  json-config.ts                                            |   96.19 |    83.33 |     100 |   96.19 | 94-95,97-98
  markdown-label-formatter.ts                               |   95.85 |    87.87 |     100 |   95.85 | 59-68
  new-potential-bug-entry-service-call.ts                   |     100 |      100 |     100 |     100 |
  new-potential-bug-entry.ts                                |   95.87 |    82.97 |   91.66 |   95.87 | 263-272,348-351,404-408
  prompt-mode-contract.ts                                   |     100 |    97.82 |     100 |     100 | 111
  subprocess-runner.ts                                      |   98.59 |    94.73 |     100 |   98.59 | 102-103
 src/lib/codex-native-converter                             |   98.87 |    89.06 |   77.98 |   98.87 |
  classifier-claude.ts                                      |     100 |    97.05 |     100 |     100 | 194
  classifier.ts                                             |   98.63 |    94.44 |     100 |   98.63 | 67-70
  cli.ts                                                    |     100 |    94.44 |     100 |     100 | 67,160
  codex-native-converter-service-call.ts                    |     100 |    94.44 |     100 |     100 | 110
  engine-pipeline.ts                                        |   97.73 |       84 |     100 |   97.73 | 137-138,152-153,204-205,251
  engine.ts                                                 |     100 |      100 |     100 |     100 |
  index.ts                                                  |     100 |      100 |       4 |     100 |
  intermediate-state.ts                                     |     100 |       90 |     100 |     100 | 53,81
  inventory.ts                                              |   98.11 |    83.82 |     100 |   98.11 | 60-61,63-64,138-139
  mapping.ts                                                |    99.1 |    94.73 |     100 |    99.1 | 45-46
  models-intermediate.ts                                    |     100 |      100 |     100 |     100 |
  models.ts                                                 |     100 |       95 |   66.66 |     100 | 259
  parser.ts                                                 |     100 |    83.67 |     100 |     100 | 58,106,113,126,226,267,284-285
  pipeline-render.ts                                        |   93.71 |    79.54 |     100 |   93.71 | 158-163,172-186,322-323
  pipeline-traces.ts                                        |   93.44 |    83.33 |     100 |   93.44 | 91-92,112-113,117-120
  pipeline.ts                                               |     100 |    92.68 |      40 |     100 | 57,93
  reporting-render.ts                                       |   96.65 |    83.78 |     100 |   96.65 | 89-92,192,197-198
  reporting-topology.ts                                     |     100 |      100 |     100 |     100 |
  reporting.ts                                              |   99.16 |    81.03 |     100 |   99.16 | 157-158
  rewrites-rules.ts                                         |     100 |      100 |   72.72 |     100 |
  rewrites.ts                                               |     100 |      100 |     100 |     100 |
  section-intent.ts                                         |     100 |      100 |     100 |     100 |
  validation.ts                                             |   99.46 |     86.2 |     100 |   99.46 | 194-195
 src/lib/new-active-feature-folder                          |   99.23 |    91.58 |   65.55 |   99.23 |
  docs.ts                                                   |     100 |      100 |     100 |     100 |
  flow.ts                                                   |   99.54 |     92.1 |     100 |   99.54 | 358-359
  index.ts                                                  |     100 |      100 |   10.34 |     100 |
  io-launcher.ts                                            |   97.87 |    84.61 |      80 |   97.87 | 81-84
  io.ts                                                     |   99.48 |    91.04 |   82.35 |   99.48 | 66-67
  markdown.ts                                               |     100 |     93.1 |     100 |     100 | 93,118,233-234
  models.ts                                                 |   97.36 |    83.33 |   93.33 |   97.36 | 139-140,142-143,209-211,302-304
  new-active-feature-folder-service-call.ts                 |     100 |      100 |     100 |     100 |
 src/lib/potential-to-issue                                 |   99.41 |       84 |     100 |   99.41 |
  content.ts                                                |   99.16 |     88.7 |     100 |   99.16 | 347-348,368-369
  gh-client.ts                                              |     100 |    79.31 |     100 |     100 | 151-157,174,249
  potential-to-issue-service-call.ts                        |     100 |    81.25 |     100 |     100 | 174,188,190
  promotion-filesystem.ts                                   |     100 |    85.71 |     100 |     100 | 61
  promotion.ts                                              |   98.85 |    81.96 |     100 |   98.85 | 151-153,356-357
 src/lib/pr-context                                         |   95.94 |    87.69 |   85.78 |   95.94 |
  collector-core.ts                                         |   97.66 |    86.56 |     100 |   97.66 | 208,227-228,297-299,329,424-425,471-472
  collector-output.ts                                       |   97.55 |    80.51 |     100 |   97.55 | 112,248-251,295-298,369-370
  feature-docs-parsers.ts                                   |   96.89 |    88.52 |     100 |   96.89 | 192-193,247-248,253-254,300-301,311-312
  feature-docs.ts                                           |   94.48 |    87.27 |     100 |   94.48 | 107-108,130-131,135-137,237-244,267-268
  gh-client-core.ts                                         |   96.33 |       80 |     100 |   96.33 | 190-191,198-199,211-212,267-268,278-279,305-306,319-320,361-362
  gh-client-details.ts                                      |   93.96 |    91.35 |   91.66 |   93.96 | 128-136,171-172,179-180,238-239,272-273,324-325,335-337,341-342
  git-client.ts                                             |   99.06 |      100 |   94.11 |   99.06 | 61-62
  models.ts                                                 |     100 |      100 |     100 |     100 |
  pr-context-service-call.ts                                |     100 |      100 |     100 |     100 |
  render-feature-excerpts.ts                                |   95.08 |    84.26 |     100 |   95.08 | 71-72,77-81,101-102,366-367,379-380,384-386,431-432,437-438,442-443
  render-pr-helpers.ts                                      |   88.77 |    93.02 |   88.88 |   88.77 | 109-110,164-165,224-225,249-273,283-303,459-460
  render.ts                                                 |   98.04 |       88 |   22.22 |   98.04 | 230,383-384,388-389,405,407-408
  summary-digests.ts                                        |     100 |    93.61 |     100 |     100 | 196,236-237
  summary-helpers.ts                                        |   93.09 |    87.14 |   88.88 |   93.09 | 72-73,76-77,103-104,107-108,178-180,182-184,236-246
  verification-evidence.ts                                  |   95.56 |       80 |     100 |   95.56 | 106-107,215-216,226-227,237-238,243,245-246
 src/lib/push-down                                          |   98.52 |     89.6 |   96.87 |   98.52 |
  claude-customizations.ts                                  |     100 |    83.33 |     100 |     100 | 90,155,203,237-238
  claude-filesystem-adapter.ts                              |   94.38 |    83.33 |   86.36 |   94.38 | 66-67,69-70,85-86,91-92,186-187,202-204,222-223,235-236
  claude-memory-scope.ts                                    |     100 |    86.36 |     100 |     100 | 63,70,80
  claude-pack-name-translation.ts                           |     100 |      100 |     100 |     100 |
  claude-pack-selection.ts                                  |     100 |       98 |     100 |     100 | 89
  codex-agents-customizations.ts                            |   98.23 |     87.8 |     100 |   98.23 | 83-84,130-131
  codex-pack-selection.ts                                   |   98.33 |     94.2 |     100 |   98.33 | 197-200
  copilot-customizations-engine.ts                          |   97.99 |       82 |     100 |   97.99 | 114-115,136-137,142-143,383-385
  copilot-customizations.ts                                 |     100 |      100 |     100 |     100 |
  filesystem-adapter.ts                                     |   98.03 |    86.95 |     100 |   98.03 | 76-77,79-80
  push-down-service-call.ts                                 |     100 |    95.65 |     100 |     100 | 103
  reference-rewrites.ts                                     |   99.17 |    93.75 |     100 |   99.17 | 197-198
 src/lib/resolve                                            |    96.8 |    83.79 |   95.74 |    96.8 |
  file-prompt-core.ts                                       |   98.67 |       84 |     100 |   98.67 | 186-188
  file-prompt-transforms.ts                                 |     100 |    86.66 |     100 |     100 | 41,103,159,192
  file-prompt-variables.ts                                  |   95.25 |    75.75 |   94.44 |   95.25 | 70-72,109-110,139-141,296-297,346-352
  hard-lock-prompt.ts                                       |   94.33 |    83.58 |    92.3 |   94.33 | 187-193,334-336,355-357,415-416,421-422,436-437,439-440,468-469,471-472,492-494
  resolve-prompts-service-call.ts                           |     100 |      100 |     100 |     100 |
 src/lib/validate                                           |   95.54 |    88.67 |   89.33 |   95.54 |
  epic-orchestrator-state-core.ts                           |   97.33 |     87.2 |     100 |   97.33 | 152-153,161-162,195-196,289-290,342-343,347-348
  evidence-locations.ts                                     |     100 |      100 |     100 |     100 |
  json-validator.ts                                         |   89.13 |       85 |    90.9 |   89.13 | 76-77,131-137,178-179,189-194,305-322
  orchestration-artifacts.ts                                |     100 |      100 |     100 |     100 |
  orchestrator-state-completion.ts                          |   94.94 |    93.02 |     100 |   94.94 | 103-107,139-143
  orchestrator-state-core.ts                                |   98.11 |    93.75 |   45.45 |   98.11 | 208-209,245,247-250
  orchestrator-state-human-interaction.ts                   |   96.99 |     91.3 |     100 |   96.99 | 60-61,63-64
  orchestrator-state-remediation.ts                         |     100 |      100 |     100 |     100 |
  orchestrator-state-routing.ts                             |   91.34 |    81.69 |   91.66 |   91.34 | 43-46,59-60,63-64,101-102,108-109,121-122,154-155,159-160,187-188,192-193,242-243,251-255,289-290
  policy-audit-artifact.ts                                  |   93.07 |    81.31 |     100 |   93.07 | 138-139,173-174,230-231,239-240,333-336,338-341,344-345,356-359,361-364,393-396
  review-artifacts.ts                                       |     100 |      100 |     100 |     100 |
  validate-orchestration-service-call.ts                    |     100 |      100 |     100 |     100 |
 src/mcp-handlers                                           |   88.05 |      100 |   77.77 |   88.05 |
  codex-native-converter-handlers.ts                        |     100 |      100 |     100 |     100 |
  collect-context-handlers.ts                               |     100 |      100 |     100 |     100 |
  feature-entry-handlers.ts                                 |   42.85 |      100 |       0 |   42.85 | 13-18,21-26,29-34,37-42
  poshqc-handlers.ts                                        |     100 |      100 |     100 |     100 |
  push-down-handlers.ts                                     |     100 |      100 |     100 |     100 |
  resolve-execute-hard-lock-prompt-handler.ts               |     100 |      100 |     100 |     100 |
  template-validation-handlers.ts                           |     100 |      100 |     100 |     100 |
 test                                                       |   92.24 |    82.91 |   95.45 |   92.24 |
  collect-commit-context-test-support.ts                    |   97.36 |    89.18 |     100 |   97.36 | 87-88,112
  extension-test-harness.ts                                 |   90.44 |    83.33 |     100 |   90.44 | 82,135,162,207-240,247-248,290,364,404-405,421-422
  new-active-feature-folder-fs-harness.ts                   |   89.84 |    78.12 |   81.81 |   89.84 | 103-104,123,126,140-141,151-160,177-178,193-194
  runtime-test-helpers.ts                                   |   97.26 |    79.31 |     100 |   97.26 | 42-43,46-47
 test/lib                                                   |   94.95 |    84.61 |      70 |   94.95 |
  collect-commit-context.test-helpers.ts                    |   94.95 |    84.61 |      70 |   94.95 | 63-64,67-68,71-72
 test/lib/codex-native-converter                            |   71.91 |     90.9 |   85.71 |   71.91 |
  in-memory-file-system.ts                                  |   71.91 |     90.9 |   85.71 |   71.91 | 37-50,86-87,122-146
 test/lib/new-active-feature-folder                         |   96.62 |    87.09 |     100 |   96.62 |
  fakes.ts                                                  |   96.62 |    87.09 |     100 |   96.62 | 52-53,120-121,141-142
 test/lib/potential-to-issue                                |    96.8 |    85.71 |     100 |    96.8 |
  promotion-test-support.ts                                 |    96.8 |    85.71 |     100 |    96.8 | 36-37,52-53
 test/lib/pr-context                                        |   97.91 |    94.28 |     100 |   97.91 |
  tree-file-system.ts                                       |   97.91 |    94.28 |     100 |   97.91 | 130-132
 test/lib/push-down                                         |   97.72 |    90.32 |     100 |   97.72 |
  push-down.test-helpers.ts                                 |   97.72 |    90.32 |     100 |   97.72 | 12-13,123-124
------------------------------------------------------------|---------|----------|---------|---------|---------------------------------------------------------------------------------------------------

Test Suites: 122 passed, 122 total
Tests:       1472 passed, 1472 total
Snapshots:   0 total
Time:        4.749 s
Ran all test suites.
