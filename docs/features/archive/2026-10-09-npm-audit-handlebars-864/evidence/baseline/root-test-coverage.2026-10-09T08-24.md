# Evidence

Timestamp: 2026-10-09T08-15
Command: npm run test:unit:coverage (root)
EXIT_CODE: 0
Output Summary: Tests: 3923 passed, 3923 total; All files Statements 97.76%, Branches 91.42%, Functions 91.42%, Lines 97.76%.

## Printed output

```text

> drm-copilot@1.0.0 test:unit:coverage
> node run-jest.cjs --coverage

jest-haste-map: Haste module naming collision: drm-copilot
  The following files share their name; please adjust your hasteImpl:
    * <rootDir>\package.json
    * <rootDir>\extensions\drm-copilot\package.json

-------------------------------------------------------------------------------------------|---------|----------|---------|---------|-----------------------------------------------------------------------------------
File                                                                                       | % Stmts | % Branch | % Funcs | % Lines | Uncovered Line #s                                                                 
-------------------------------------------------------------------------------------------|---------|----------|---------|---------|-----------------------------------------------------------------------------------
All files                                                                                  |   97.76 |    91.42 |   91.42 |   97.76 |                                                                                   
 2026-10-09-npm-audit-handlebars                                                           |     100 |      100 |     100 |     100 |                                                                                   
  jest.config.cjs                                                                          |     100 |      100 |     100 |     100 |                                                                                   
 2026-10-09-npm-audit-handlebars/extensions/drm-copilot                                    |     100 |      100 |     100 |     100 |                                                                                   
  jest.config.cjs                                                                          |     100 |      100 |     100 |     100 |                                                                                   
 2026-10-09-npm-audit-handlebars/extensions/drm-copilot/src                                |   96.99 |    89.49 |   94.77 |   96.99 |                                                                                   
  claude-worktree-session.ts                                                               |     100 |       95 |     100 |     100 | 123                                                                               
  codex-worktree-session.ts                                                                |     100 |      100 |     100 |     100 |                                                                                   
  command-runtime.ts                                                                       |   98.64 |    93.33 |   92.85 |   98.64 | 109,192-194,240                                                                   
  discovery-command-registration.ts                                                        |   90.65 |    78.18 |     100 |   90.65 | 36-37,83-84,90-91,137-138,216-217,223-224,230-231,254-255,262-263,269-270,280-293 
  document-workflow-commands.ts                                                            |    92.7 |    78.26 |     100 |    92.7 | 60-63,76-77,86-89                                                                 
  extension-command-helpers.ts                                                             |   99.44 |    93.84 |   94.11 |   99.44 | 39-40                                                                             
  extension.ts                                                                             |   97.37 |     90.9 |     100 |   97.37 | 97-98,367-373,408-409,415-416                                                     
  mcp-discovery-tool-definitions.ts                                                        |     100 |      100 |     100 |     100 |                                                                                   
  mcp-provider.ts                                                                          |     100 |      100 |     100 |     100 |                                                                                   
  mcp-push-down-schema-properties.ts                                                       |     100 |      100 |     100 |     100 |                                                                                   
  mcp-repo-automation-tool-definitions-handoff.ts                                          |     100 |      100 |     100 |     100 |                                                                                   
  mcp-repo-automation-tool-definitions-poshqc.ts                                           |     100 |      100 |     100 |     100 |                                                                                   
  mcp-repo-automation-tool-definitions.ts                                                  |     100 |      100 |       0 |     100 |                                                                                   
  mcp-server.ts                                                                            |   80.14 |    54.54 |      80 |   80.14 | 41-42,70-73,94-103,124-127,130-136                                                
  mcp-tool-definitions.ts                                                                  |     100 |      100 |     100 |     100 |                                                                                   
  mcp-tool-inputs-discovery.ts                                                             |     100 |    96.87 |     100 |     100 | 236                                                                               
  mcp-tool-inputs-potential-to-issue.ts                                                    |     100 |      100 |     100 |     100 |                                                                                   
  mcp-tool-inputs-push-down.ts                                                             |     100 |      100 |     100 |     100 |                                                                                   
  mcp-tool-inputs-subagent-tree.ts                                                         |     100 |      100 |     100 |     100 |                                                                                   
  mcp-tool-inputs.ts                                                                       |   94.61 |    92.95 |   94.73 |   94.61 | 168-169,183-184,205-208,233-237,357-369                                           
  mcp-tools.ts                                                                             |   94.73 |     88.4 |     100 |   94.73 | 98-99,186-187,200-203,218-221,234-237,274-276                                     
  policy-audit-template-assets.ts                                                          |   97.29 |       75 |     100 |   97.29 | 68-69                                                                             
  poshqc-command-registration.ts                                                           |   94.27 |    85.71 |      90 |   94.27 | 85-86,127-128,147-153                                                             
  poshqc-folder-picker.ts                                                                  |     100 |      100 |     100 |     100 |                                                                                   
  poshqc-scan-config.ts                                                                    |   96.49 |    88.57 |     100 |   96.49 | 44-45,133-134,159-162                                                             
  poshqc-terminal-output.ts                                                                |   99.29 |      100 |      90 |   99.29 | 97                                                                                
  pr-context-branches.ts                                                                   |   81.49 |    72.22 |     100 |   81.49 | 64-65,72-73,78-80,99-100,156-188                                                  
  remove-worktrees-runner.ts                                                               |   96.03 |    84.84 |   57.14 |   96.03 | 69,72,75,238-244                                                                  
  remove-worktrees.ts                                                                      |      99 |       90 |     100 |      99 | 116-118                                                                           
  repo-automation-args.ts                                                                  |     100 |      100 |     100 |     100 |                                                                                   
  repo-automation-command-registration-admin.ts                                            |    96.9 |    89.23 |     100 |    96.9 | 97-101,293-294,302-303,312-313,337-338                                            
  repo-automation-command-registration-feature-workflows.ts                                |     100 |    98.14 |     100 |     100 | 267                                                                               
  repo-automation-command-registration.ts                                                  |     100 |      100 |     100 |     100 |                                                                                   
  repo-automation-execute-discovery.ts                                                     |   97.13 |    83.87 |     100 |   97.13 | 167-168,171-172,231-233,297-300,422-423                                           
  repo-automation-execute-script.ts                                                        |     100 |    77.77 |     100 |     100 | 63-69                                                                             
  repo-automation-service-push-down.ts                                                     |   93.45 |    72.72 |      80 |   93.45 | 100-110                                                                           
  repo-automation-service-subagent-tree.ts                                                 |     100 |      100 |     100 |     100 |                                                                                   
  repo-automation-service-support.ts                                                       |     100 |       50 |     100 |     100 | 132-134                                                                           
  repo-automation-service-workflows.ts                                                     |     100 |      100 |     100 |     100 |                                                                                   
  repo-automation-service.ts                                                               |   98.39 |    94.11 |   95.45 |   98.39 | 189-196                                                                           
  repo-automation-tool-names.ts                                                            |     100 |      100 |     100 |     100 |                                                                                   
  runtime-detection.ts                                                                     |   95.05 |    84.74 |     100 |   95.05 | 97-98,105,268-278                                                                 
  subagent-tree-command.ts                                                                 |     100 |    95.45 |     100 |     100 | 109                                                                               
  terminal-writer.ts                                                                       |      99 |      100 |   85.71 |      99 | 81                                                                                
  workflow-command-arguments.ts                                                            |   91.46 |    88.05 |   95.23 |   91.46 | 94-97,194-197,234-235,241-242,245-257,264-265,271-272,346-347,350-353             
  workflow-command-invocations.ts                                                          |   99.24 |    95.55 |     100 |   99.24 | 193-194                                                                           
 2026-10-09-npm-audit-handlebars/extensions/drm-copilot/src/lib                            |   97.97 |     92.1 |   96.22 |   97.97 |                                                                                   
  collect-commit-context.ts                                                                |     100 |    96.96 |     100 |     100 | 199                                                                               
  executable-resolver.ts                                                                   |     100 |      100 |     100 |     100 |                                                                                   
  file-system.ts                                                                           |    95.6 |    85.29 |   92.85 |    95.6 | 133-134,136-137,197-200,292-297,312-313                                           
  hello-message.ts                                                                         |     100 |      100 |     100 |     100 |                                                                                   
  json-config.ts                                                                           |   96.19 |    83.33 |     100 |   96.19 | 94-95,97-98                                                                       
  markdown-label-formatter.ts                                                              |   95.85 |    87.87 |     100 |   95.85 | 59-68                                                                             
  new-potential-bug-entry-service-call.ts                                                  |     100 |      100 |     100 |     100 |                                                                                   
  new-potential-bug-entry.ts                                                               |   97.83 |    87.27 |   91.66 |   97.83 | 272,348-351,404-408                                                               
  prompt-mode-contract.ts                                                                  |     100 |    97.82 |     100 |     100 | 111                                                                               
  subprocess-runner.ts                                                                     |   98.59 |       95 |     100 |   98.59 | 102-103                                                                           
 2026-10-09-npm-audit-handlebars/extensions/drm-copilot/src/lib/codex-native-converter     |   98.87 |    89.06 |   82.66 |   98.87 |                                                                                   
  classifier-claude.ts                                                                     |     100 |    97.05 |     100 |     100 | 194                                                                               
  classifier.ts                                                                            |   98.63 |    94.44 |     100 |   98.63 | 67-70                                                                             
  cli.ts                                                                                   |     100 |    94.44 |     100 |     100 | 67,160                                                                            
  codex-native-converter-service-call.ts                                                   |     100 |    94.44 |     100 |     100 | 110                                                                               
  engine-pipeline.ts                                                                       |   97.73 |       84 |     100 |   97.73 | 137-138,152-153,204-205,251                                                       
  engine.ts                                                                                |     100 |      100 |     100 |     100 |                                                                                   
  index.ts                                                                                 |     100 |      100 |    4.76 |     100 |                                                                                   
  intermediate-state.ts                                                                    |     100 |       90 |     100 |     100 | 53,81                                                                             
  inventory.ts                                                                             |   98.11 |    83.82 |     100 |   98.11 | 60-61,63-64,138-139                                                               
  mapping.ts                                                                               |    99.1 |    94.73 |     100 |    99.1 | 45-46                                                                             
  models-intermediate.ts                                                                   |     100 |      100 |     100 |     100 |                                                                                   
  models.ts                                                                                |     100 |       95 |     100 |     100 | 259                                                                               
  parser.ts                                                                                |     100 |    83.67 |     100 |     100 | 58,106,113,126,226,267,284-285                                                    
  pipeline-render.ts                                                                       |   93.71 |    79.54 |     100 |   93.71 | 158-163,172-186,322-323                                                           
  pipeline-traces.ts                                                                       |   93.44 |    83.33 |     100 |   93.44 | 91-92,112-113,117-120                                                             
  pipeline.ts                                                                              |     100 |    92.68 |      40 |     100 | 57,93                                                                             
  reporting-render.ts                                                                      |   96.65 |    83.78 |     100 |   96.65 | 89-92,192,197-198                                                                 
  reporting-topology.ts                                                                    |     100 |      100 |     100 |     100 |                                                                                   
  reporting.ts                                                                             |   99.16 |    81.03 |     100 |   99.16 | 157-158                                                                           
  rewrites-rules.ts                                                                        |     100 |      100 |   72.72 |     100 |                                                                                   
  rewrites.ts                                                                              |     100 |      100 |     100 |     100 |                                                                                   
  section-intent.ts                                                                        |     100 |      100 |     100 |     100 |                                                                                   
  validation.ts                                                                            |   99.46 |     86.2 |     100 |   99.46 | 194-195                                                                           
 2026-10-09-npm-audit-handlebars/extensions/drm-copilot/src/lib/new-active-feature-folder  |   99.43 |    92.92 |   67.39 |   99.43 |                                                                                   
  docs.ts                                                                                  |     100 |      100 |     100 |     100 |                                                                                   
  flow.ts                                                                                  |   99.59 |    93.33 |     100 |   99.59 | 388-389                                                                           
  index.ts                                                                                 |     100 |      100 |   10.34 |     100 |                                                                                   
  io-launcher.ts                                                                           |     100 |    93.75 |     100 |     100 | 45,51                                                                             
  io.ts                                                                                    |   99.49 |    91.66 |   82.35 |   99.49 | 66-67                                                                             
  markdown.ts                                                                              |     100 |     93.1 |     100 |     100 | 93,118,233-234                                                                    
  models.ts                                                                                |   97.36 |    83.33 |   93.33 |   97.36 | 139-140,142-143,209-211,302-304                                                   
  new-active-feature-folder-service-call.ts                                                |     100 |      100 |     100 |     100 |                                                                                   
 2026-10-09-npm-audit-handlebars/extensions/drm-copilot/src/lib/potential-to-issue         |    99.5 |    86.66 |     100 |    99.5 |                                                                                   
  content.ts                                                                               |   99.16 |    88.88 |     100 |   99.16 | 347-348,368-369                                                                   
  gh-client.ts                                                                             |     100 |    81.81 |     100 |     100 | 159-165,182,263                                                                   
  potential-to-issue-service-call.ts                                                       |     100 |       85 |     100 |     100 | 206,234,236                                                                       
  promotion-filesystem.ts                                                                  |     100 |    85.71 |     100 |     100 | 61                                                                                
  promotion.ts                                                                             |   98.88 |    83.82 |     100 |   98.88 | 151-153,364-365                                                                   
  repo-slug.ts                                                                             |     100 |      100 |     100 |     100 |                                                                                   
 2026-10-09-npm-audit-handlebars/extensions/drm-copilot/src/lib/pr-context                 |   97.17 |     91.4 |   85.86 |   97.17 |                                                                                   
  autoclose.ts                                                                             |     100 |      100 |     100 |     100 |                                                                                   
  collector-core.ts                                                                        |   98.42 |     92.3 |     100 |   98.42 | 216,229-230,308-310                                                               
  collector-output.ts                                                                      |   97.77 |    89.33 |     100 |   97.77 | 116,242-245,289-292,414-415                                                       
  diff-emptiness.ts                                                                        |     100 |    81.81 |     100 |     100 | 86-88                                                                             
  feature-docs-parsers.ts                                                                  |   98.07 |    91.22 |     100 |   98.07 | 198-199,253-254,259-260                                                           
  feature-docs.ts                                                                          |   94.55 |    87.27 |     100 |   94.55 | 111-112,134-135,139-141,241-248,271-272                                           
  gh-client-core.ts                                                                        |   96.33 |    80.72 |     100 |   96.33 | 190-191,198-199,211-212,267-268,278-279,305-306,319-320,361-362                   
  gh-client-details.ts                                                                     |   96.04 |    91.35 |     100 |   96.04 | 152-153,160-161,219-220,253-254,305-306,316-318,322-323                           
  git-client.ts                                                                            |   99.06 |      100 |   94.11 |   99.06 | 61-62                                                                             
  models.ts                                                                                |     100 |      100 |     100 |     100 |                                                                                   
  pr-context-service-call.ts                                                               |     100 |    93.75 |     100 |     100 | 59                                                                                
  render-feature-excerpts.ts                                                               |    97.9 |    89.65 |     100 |    97.9 | 108-109,373-374,386-387,391-393                                                   
  render-pr-helpers.ts                                                                     |   87.08 |    94.28 |    87.5 |   87.08 | 113-114,231-232,256-280,290-310                                                   
  render.ts                                                                                |   99.73 |     92.3 |    12.5 |   99.73 | 232                                                                               
  summary-digests.ts                                                                       |     100 |    97.95 |     100 |     100 | 196                                                                               
  summary-helpers.ts                                                                       |   94.56 |    89.24 |      90 |   94.56 | 73-74,77-78,104-105,108-109,179-181,183-185,237-247                               
  verification-evidence.ts                                                                 |   99.23 |    93.93 |     100 |   99.23 | 134-135                                                                           
 2026-10-09-npm-audit-handlebars/extensions/drm-copilot/src/lib/push-down                  |      99 |    94.45 |   94.91 |      99 |                                                                                   
  claude-blast-radius-derive-core.ts                                                       |     100 |     97.5 |   88.88 |     100 | 315                                                                               
  claude-blast-radius-derive-manifests.ts                                                  |     100 |    95.65 |     100 |     100 | 122                                                                               
  claude-blast-radius-derive.ts                                                            |   97.38 |    94.11 |     100 |   97.38 | 99-100,123-128                                                                    
  claude-blast-radius-overlay.ts                                                           |   99.55 |    95.87 |     100 |   99.55 | 353-354                                                                           
  claude-customizations.ts                                                                 |     100 |    96.82 |   68.18 |     100 | 235,300                                                                           
  claude-exclusion-filter.ts                                                               |    99.4 |    95.74 |     100 |    99.4 | 330-331                                                                           
  claude-exclusion-manifest.ts                                                             |     100 |      100 |     100 |     100 |                                                                                   
  claude-filesystem-adapter.ts                                                             |   94.38 |    83.05 |   86.36 |   94.38 | 66-67,69-70,85-86,91-92,186-187,202-204,222-223,235-236                           
  claude-gitignore-merge.ts                                                                |   98.79 |       95 |     100 |   98.79 | 153-154                                                                           
  claude-memory-scope.ts                                                                   |     100 |    86.36 |     100 |     100 | 63,70,80                                                                          
  claude-pack-name-translation.ts                                                          |     100 |      100 |     100 |     100 |                                                                                   
  claude-pack-selection.ts                                                                 |     100 |       98 |     100 |     100 | 89                                                                                
  claude-routing-merge.ts                                                                  |   99.35 |    96.36 |     100 |   99.35 | 100-101                                                                           
  codex-agents-customizations.ts                                                           |   98.87 |    95.31 |     100 |   98.87 | 125-126,134-135                                                                   
  codex-pack-selection.ts                                                                  |   98.33 |    97.14 |     100 |   98.33 | 197-200                                                                           
  copilot-customizations-engine.ts                                                         |   97.99 |    84.31 |     100 |   97.99 | 114-115,136-137,142-143,383-385                                                   
  copilot-customizations.ts                                                                |     100 |      100 |     100 |     100 |                                                                                   
  filesystem-adapter.ts                                                                    |   98.03 |    88.46 |     100 |   98.03 | 76-77,79-80                                                                       
  push-down-service-call.ts                                                                |     100 |    96.42 |     100 |     100 | 106                                                                               
  reference-rewrites.ts                                                                    |   99.17 |    93.75 |     100 |   99.17 | 197-198                                                                           
 2026-10-09-npm-audit-handlebars/extensions/drm-copilot/src/lib/resolve                    |    96.8 |    83.79 |   95.74 |    96.8 |                                                                                   
  file-prompt-core.ts                                                                      |   98.67 |       84 |     100 |   98.67 | 186-188                                                                           
  file-prompt-transforms.ts                                                                |     100 |    86.66 |     100 |     100 | 41,103,159,192                                                                    
  file-prompt-variables.ts                                                                 |   95.25 |    75.75 |   94.44 |   95.25 | 70-72,109-110,139-141,296-297,346-352                                             
  hard-lock-prompt.ts                                                                      |   94.33 |    83.58 |    92.3 |   94.33 | 187-193,334-336,355-357,415-416,421-422,436-437,439-440,468-469,471-472,492-494   
  resolve-prompts-service-call.ts                                                          |     100 |      100 |     100 |     100 |                                                                                   
 2026-10-09-npm-audit-handlebars/extensions/drm-copilot/src/lib/subagent-tree              |   98.53 |    95.28 |   96.15 |   98.53 |                                                                                   
  index.ts                                                                                 |     100 |      100 |     100 |     100 |                                                                                   
  quick-pick-labels.ts                                                                     |     100 |    94.44 |     100 |     100 | 132                                                                               
  session-transcript-resolver.ts                                                           |     100 |    85.71 |     100 |     100 | 71                                                                                
  transcript-parser.ts                                                                     |   98.44 |    96.29 |     100 |   98.44 | 118-119                                                                           
  transcript-scanner.ts                                                                    |     100 |      100 |     100 |     100 |                                                                                   
  tree-assembler.ts                                                                        |    94.7 |    89.47 |      80 |    94.7 | 97-105,124                                                                        
  tree-formatter.ts                                                                        |     100 |      100 |     100 |     100 |                                                                                   
  workspace-encoding.ts                                                                    |     100 |      100 |     100 |     100 |                                                                                   
 2026-10-09-npm-audit-handlebars/extensions/drm-copilot/src/lib/validate                   |   97.81 |    92.85 |   96.02 |   97.81 |                                                                                   
  build-validate-orchestration-service-call-input.ts                                       |     100 |      100 |     100 |     100 |                                                                                   
  codex-topology-resolver.ts                                                               |   97.38 |    94.73 |     100 |   97.38 | 89-90,94-98                                                                       
  epic-kickoff-artifact.ts                                                                 |   96.33 |    83.16 |     100 |   96.33 | 191-192,219,227-228,236-238,241-244                                               
  epic-orchestrator-state-core.ts                                                          |   97.96 |    91.11 |     100 |   97.96 | 181-182,190-191,290-291,359-360,364-365                                           
  epic-orchestrator-state-launch-binding.ts                                                |    96.1 |    93.27 |     100 |    96.1 | 45-46,56-61,215-217,258-259                                                       
  epic-orchestrator-state-resolution.ts                                                    |   96.16 |    89.83 |     100 |   96.16 | 54-55,57-58,62-63,169-170,173-175                                                 
  epic-planner-git-integrity.ts                                                            |     100 |     93.9 |     100 |     100 | 53,60,67,206,222                                                                  
  epic-planner-launch-evidence.ts                                                          |   92.75 |    84.48 |     100 |   92.75 | 54-57,80-85,90-98,192-193,204-205,214,225-226,271-272,385-386,406-407,413-414     
  epic-planner-readiness-integrity.ts                                                      |   91.62 |    84.28 |     100 |   91.62 | 37-40,42-43,68-73,131-132,177-183,192-193,197-198,224-227,338-339                 
  epic-planner-state-core.ts                                                               |    98.3 |    93.57 |     100 |    98.3 | 69-70,75-76,78-79,273-274                                                         
  epic-wave-computation.ts                                                                 |     100 |    94.11 |     100 |     100 | 41                                                                                
  evidence-locations.ts                                                                    |     100 |      100 |     100 |     100 |                                                                                   
  json-validator.ts                                                                        |   89.13 |       85 |    90.9 |   89.13 | 76-77,131-137,178-179,189-194,305-322                                             
  orchestration-artifacts.ts                                                               |     100 |    97.56 |     100 |     100 | 308,364                                                                           
  orchestration-handoff-authority-service.ts                                               |   98.97 |    90.14 |   92.85 |   98.97 | 57-58,77-78                                                                       
  orchestration-handoff-checkout-context.ts                                                |     100 |      100 |     100 |     100 |                                                                                   
  orchestration-handoff-contract-support.ts                                                |     100 |      100 |     100 |     100 |                                                                                   
  orchestration-handoff-contract.ts                                                        |   98.79 |    90.78 |     100 |   98.79 | 443-448                                                                           
  orchestration-handoff-materializer-production.ts                                         |     100 |     97.5 |     100 |     100 | 39                                                                                
  orchestration-handoff-materializer-request.ts                                            |     100 |      100 |     100 |     100 |                                                                                   
  orchestration-handoff-materializer-support.ts                                            |     100 |    95.23 |     100 |     100 | 30                                                                                
  orchestration-handoff-materializer.ts                                                    |   98.97 |    96.42 |     100 |   98.97 | 214-218                                                                           
  orchestration-handoff-path-boundary.ts                                                   |   98.64 |    84.74 |     100 |   98.64 | 183-184,205                                                                       
  orchestration-handoff-provider-adapters.ts                                               |   99.26 |    95.65 |     100 |   99.26 | 147-148                                                                           
  orchestration-handoff-validation.ts                                                      |   99.19 |    92.59 |     100 |   99.19 | 33-34                                                                             
  orchestrator-state-blocked-reason.ts                                                     |     100 |      100 |     100 |     100 |                                                                                   
  orchestrator-state-codex-model-routing.ts                                                |   95.67 |    93.96 |     100 |   95.67 | 162-163,323-327,337-340,350-354,358,360-363                                       
  orchestrator-state-codex-topology.ts                                                     |   96.27 |    95.04 |     100 |   96.27 | 43-44,55-56,60-67                                                                 
  orchestrator-state-completion.ts                                                         |   92.35 |    91.66 |     100 |   92.35 | 76-77,105-109,132-136                                                             
  orchestrator-state-core.ts                                                               |    98.9 |    96.25 |   63.63 |    98.9 | 308,310-313                                                                       
  orchestrator-state-human-interaction.ts                                                  |   96.99 |     91.3 |     100 |   96.99 | 60-61,63-64                                                                       
  orchestrator-state-issue-adoption.ts                                                     |     100 |      100 |     100 |     100 |                                                                                   
  orchestrator-state-model-routing-existence.ts                                            |     100 |      100 |     100 |     100 |                                                                                   
  orchestrator-state-preparation-terminal.ts                                               |   97.67 |       92 |     100 |   97.67 | 50-51                                                                             
  orchestrator-state-promotion-tools.ts                                                    |     100 |      100 |     100 |     100 |                                                                                   
  orchestrator-state-remediation-accounting.ts                                             |   98.19 |    95.55 |     100 |   98.19 | 89-90,92-93                                                                       
  orchestrator-state-remediation.ts                                                        |     100 |      100 |     100 |     100 |                                                                                   
  orchestrator-state-routing.ts                                                            |   95.93 |    92.45 |   93.75 |   95.93 | 139-142,159-160,220-221,258-259,291-292,350-354,388-389                           
  parallel-kickoff-artifact.ts                                                             |     100 |    88.79 |     100 |     100 | 136-137,193,201-205,217,222,232,245,250,256,307                                   
  parallel-orchestrator-state-cohort-barrier.ts                                            |   99.51 |    98.87 |     100 |   99.51 | 345-346                                                                           
  parallel-orchestrator-state-core.ts                                                      |   99.37 |     92.1 |     100 |   99.37 | 253-254                                                                           
  parallel-planner-state-core.ts                                                           |     100 |    97.95 |     100 |     100 | 446                                                                               
  parallel-planner-state-routing.ts                                                        |     100 |    92.59 |     100 |     100 | 60                                                                                
  parallel-state-records.ts                                                                |     100 |      100 |     100 |     100 |                                                                                   
  parallel-state-shared.ts                                                                 |   97.32 |    97.08 |     100 |   97.32 | 126-130,477-484                                                                   
  parallel-state-structures.ts                                                             |     100 |    98.21 |     100 |     100 | 389-390                                                                           
  plan-gate-commands.ts                                                                    |   95.93 |    84.88 |     100 |   95.93 | 139-146,164-165,168-169,217-218,356-357,399-400                                   
  plan-gate-discrimination.ts                                                              |     100 |    98.14 |      60 |     100 | 210                                                                               
  plan-gate-observability.ts                                                               |   98.38 |    91.91 |     100 |   98.38 | 253-254,413-414,430-431,441-442                                                   
  plan-gate-rules.ts                                                                       |   97.71 |    89.55 |     100 |   97.71 | 162-163,273-274,298-299,374-375,430-431                                           
  policy-audit-artifact.ts                                                                 |   93.07 |    81.31 |     100 |   93.07 | 138-139,173-174,230-231,239-240,333-336,338-341,344-345,356-359,361-364,393-396   
  review-artifacts.ts                                                                      |     100 |      100 |     100 |     100 |                                                                                   
  semantic-mcp-identity.ts                                                                 |     100 |      100 |     100 |     100 |                                                                                   
  validate-orchestration-service-call.ts                                                   |     100 |       95 |     100 |     100 | 92                                                                                
 2026-10-09-npm-audit-handlebars/extensions/drm-copilot/src/mcp-handlers                   |      98 |      100 |      95 |      98 |                                                                                   
  codex-native-converter-handlers.ts                                                       |     100 |      100 |     100 |     100 |                                                                                   
  collect-context-handlers.ts                                                              |     100 |      100 |     100 |     100 |                                                                                   
  discovery-handlers.ts                                                                    |     100 |      100 |     100 |     100 |                                                                                   
  feature-entry-handlers.ts                                                                |   71.42 |      100 |      50 |   71.42 | 13-18,37-42                                                                       
  orchestration-handoff-handlers.ts                                                        |     100 |      100 |     100 |     100 |                                                                                   
  poshqc-handlers.ts                                                                       |     100 |      100 |     100 |     100 |                                                                                   
  push-down-handlers.ts                                                                    |     100 |      100 |     100 |     100 |                                                                                   
  render-subagent-tree-handler.ts                                                          |     100 |      100 |     100 |     100 |                                                                                   
  resolve-execute-hard-lock-prompt-handler.ts                                              |     100 |      100 |     100 |     100 |                                                                                   
  template-validation-handlers.ts                                                          |     100 |      100 |     100 |     100 |                                                                                   
 2026-10-09-npm-audit-handlebars/extensions/drm-copilot/test                               |   94.33 |    84.06 |   95.91 |   94.33 |                                                                                   
  collect-commit-context-test-support.ts                                                   |   97.36 |    89.18 |     100 |   97.36 | 87-88,112                                                                         
  extension-potential-to-issue-test-support.ts                                             |   99.25 |    86.66 |     100 |   99.25 | 122                                                                               
  extension-test-harness.ts                                                                |   90.81 |     83.6 |     100 |   90.81 | 91,144,171,216-249,256-257,299,413-414,430-431                                    
  mcp-server-test-service.ts                                                               |     100 |      100 |     100 |     100 |                                                                                   
  new-active-feature-folder-fs-harness.ts                                                  |   89.84 |    77.41 |   81.81 |   89.84 | 103-104,123,126,140-141,151-160,177-178,193-194                                   
  runtime-test-helpers.ts                                                                  |     100 |    82.85 |     100 |     100 | 34,38,42,46,50,54                                                                 
 2026-10-09-npm-audit-handlebars/extensions/drm-copilot/test/lib                           |   90.83 |    84.61 |   53.84 |   90.83 |                                                                                   
  collect-commit-context.test-helpers.ts                                                   |   90.83 |    84.61 |   53.84 |   90.83 | 63-64,67-68,71-72,75-76,79-80,83-84                                               
 2026-10-09-npm-audit-handlebars/extensions/drm-copilot/test/lib/codex-native-converter    |   71.91 |     90.9 |   85.71 |   71.91 |                                                                                   
  in-memory-file-system.ts                                                                 |   71.91 |     90.9 |   85.71 |   71.91 | 37-50,86-87,122-146                                                               
 2026-10-09-npm-audit-handlebars/extensions/drm-copilot/test/lib/new-active-feature-folder |   97.75 |    90.32 |     100 |   97.75 |                                                                                   
  fakes.ts                                                                                 |   97.75 |    90.32 |     100 |   97.75 | 120-121,141-142                                                                   
 2026-10-09-npm-audit-handlebars/extensions/drm-copilot/test/lib/potential-to-issue        |   98.02 |    82.92 |     100 |   98.02 |                                                                                   
  potential-to-issue-service-call-test-support.ts                                          |   99.37 |    91.66 |     100 |   99.37 | 83                                                                                
  promotion-test-support.ts                                                                |    96.9 |    79.31 |     100 |    96.9 | 36-37,52-53,189-190                                                               
 2026-10-09-npm-audit-handlebars/extensions/drm-copilot/test/lib/pr-context                |   98.03 |    94.28 |     100 |   98.03 |                                                                                   
  tree-file-system.ts                                                                      |   98.03 |    94.28 |     100 |   98.03 | 139-141                                                                           
 2026-10-09-npm-audit-handlebars/extensions/drm-copilot/test/lib/push-down                 |   98.36 |     87.5 |     100 |   98.36 |                                                                                   
  config-carriage.test-helpers.ts                                                          |     100 |      100 |     100 |     100 |                                                                                   
  push-down.test-helpers.ts                                                                |   97.72 |    90.32 |     100 |   97.72 | 12-13,123-124                                                                     
  real-bundle-filesystem.test-helpers.ts                                                   |   98.96 |    84.21 |     100 |   98.96 | 57-58                                                                             
  seeded-random.test-helpers.ts                                                            |   93.75 |    81.81 |     100 |   93.75 | 47-50,64-65                                                                       
 2026-10-09-npm-audit-handlebars/extensions/drm-copilot/test/lib/subagent-tree             |   88.72 |    85.18 |   69.23 |   88.72 |                                                                                   
  in-memory-file-system.ts                                                                 |   88.72 |    85.18 |   69.23 |   88.72 | 46-48,51-52,74-75,80-81,84-86,119-121                                             
 2026-10-09-npm-audit-handlebars/extensions/drm-copilot/test/lib/validate                  |   96.83 |    90.72 |    73.8 |   96.83 |                                                                                   
  epic-planner-launch-evidence-test-support.ts                                             |   91.91 |       80 |   47.61 |   91.91 | 19-20,42-43,104-105,112-113,120-121,126-127,132-133,136-137                       
  orchestration-handoff-materializer-test-support.ts                                       |   98.76 |    95.45 |     100 |   98.76 | 318-321                                                                           
  parallel-kickoff-fixtures.ts                                                             |     100 |      100 |     100 |     100 |                                                                                   
  parallel-state-test-support.ts                                                           |   97.52 |    78.57 |     100 |   97.52 | 181-182,185-186,223-224                                                           
 2026-10-09-npm-audit-handlebars/packages/mcp-server                                       |   90.16 |     87.5 |     100 |   90.16 |                                                                                   
  prepack.cjs                                                                              |   90.16 |     87.5 |     100 |   90.16 | 56-61                                                                             
 2026-10-09-npm-audit-handlebars/src                                                       |     100 |      100 |     100 |     100 |                                                                                   
  hello-typescript.ts                                                                      |     100 |      100 |     100 |     100 |                                                                                   
-------------------------------------------------------------------------------------------|---------|----------|---------|---------|-----------------------------------------------------------------------------------

Test Suites: 257 passed, 257 total
Tests:       3923 passed, 3923 total
Snapshots:   0 total
Time:        8.453 s
Ran all test suites.
```
