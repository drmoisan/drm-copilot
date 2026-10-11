# Upstream Merge Verification (C1a #824, C2 #565)

Timestamp: 2026-10-09T02-45
Task: [P0-T6]
Command: git log --format=%H%x09%s origin/epic/enforcement-hook-precision-integration -- .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
EXIT_CODE: 0
C1A_LOG_COMMAND: git log --format=%H%x09%s origin/epic/enforcement-hook-precision-integration -- .claude/hooks/hook-command-invocation.ps1 .claude/hooks/hook-command-scanner.ps1
C1A_LOG_EXIT: 0
FOLDER_COMMAND: git ls-tree -d -r --name-only origin/epic/enforcement-hook-precision-integration -- docs/features
FOLDER_EXIT: 0

## First log (C1a files)

```text
5abb5568cb2c5af12570ee88e1652903a3f76c46	feat(824): structural invocation matcher and operand target resolver
9ed1d4e820e2639b3a85ed637979e23655a1b78a	feat(824): payload extraction and PowerShell adapter
992f656a56096b4d76779b2c4247dec18fcef304	feat(824): scanner delimiter capture and heredoc module
06d166e0f47e4c377618384c8d2904ac0ab1a306	fix(545): close raw-scan fail-open in scope-filter call sites
237c4d07a4b368b36d320cb97828e2b17a2b189f	feat(545): add shared command-line parser for enforcement hooks
```

## Second log (modes file)

```text
29269337a0af09fea34f95ec11c558e6269d335d	fix(565): restrict the -modes tie-break to the keyed issue number
2aa326cc4878c152e3d56d24777b2d7078f2e57e	fix(565): close the final QC loop and record acceptance status
1372e427a2c503f8220f69da11832b72b0ffecf7	fix(565): select the preimplementation gate target through the shared resolver
4886478d4e9aa74fd1b14c96246e5e81c2f35710	fix(preimplementation-gate): resolve bare-hash mode records
4e534e7abac866a92abb037476711b0556e7b597	fix(hooks): add pure modes sibling for preimplementation gate (#554)
```

C1A_MERGED: 5abb5568cb2c5af12570ee88e1652903a3f76c46 feat(824): structural invocation matcher and operand target resolver
C2_MERGED: 29269337a0af09fea34f95ec11c558e6269d335d fix(565): restrict the -modes tie-break to the keyed issue number
C1A_FOLDER: docs/features/active/promotion-hook-raw-containment-false-positive-deny-824
C2_FOLDER: docs/features/active/2026-08-26-epic-wave-barrier-resolves-nested-artifact-as-feature-folder-565

Output Summary: both upstream children have hook-file commits carrying their identity on the integration branch (C1a 5abb5568, C2 29269337); both feature folders are present. The [P0-T9] behavioural probe follows.
