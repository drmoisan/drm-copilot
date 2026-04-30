# Conversion Report

- Mode: `apply`
- Source ecosystem: `github-copilot`
- Source root: `tests/fixtures/codex_native_converter/github_copilot`
- Destination root: `virtual/destination`
- Artifact root: `virtual/apply-artifacts-debug`
- Mapping records: 7
- Validation findings: 2 (2 blocking)

## Mapping Topology

### Shared Destination Nodes

Source and destination nodes are both deduplicated in this view.

```mermaid
graph LR
    source_0[".github/agents/beast-topology.agent.md"]
    destination_0[".agents/skills/review-workflow/SKILL.md"]
    source_0 --> destination_0
    destination_1[".codex/agents/beast-topology.toml"]
    source_0 --> destination_1
    destination_2["AGENTS.md"]
    source_0 --> destination_2
    source_3[".github/agents/orchestrator.agent.md"]
    destination_3[".codex/agents/orchestrator.toml"]
    source_3 --> destination_3
    source_4[".github/copilot-instructions.md"]
    source_4 --> destination_2
    source_5[".github/instructions/general-code-change.instructions.md"]
    source_5 --> destination_2
    source_6[".github/prompts/launch-review.prompt.md"]
    destination_6["[no target]"]
    source_6 --> destination_6
    source_7[".github/prompts/mixed-runtime.prompt.md"]
    destination_7[".agents/skills/mixed-runtime/SKILL.md"]
    source_7 --> destination_7
    source_7 --> destination_7
    destination_9[".codex/hooks/mixed-runtime.py"]
    source_7 --> destination_9
    source_7 --> destination_6
    source_11[".github/skills/review-workflow/SKILL.md"]
    source_11 --> destination_0
```

### Repeated Destination Nodes

Destination nodes may repeat in this source-to-destination view so fan-in stays legible.
```mermaid
graph LR
    source_0[".github/agents/beast-topology.agent.md"]
    destination_0[".agents/skills/review-workflow/SKILL.md"]
    source_0 --> destination_0
    destination_1[".codex/agents/beast-topology.toml"]
    source_0 --> destination_1
    destination_2["AGENTS.md"]
    source_0 --> destination_2
    source_3[".github/agents/orchestrator.agent.md"]
    destination_3[".codex/agents/orchestrator.toml"]
    source_3 --> destination_3
    source_4[".github/copilot-instructions.md"]
    destination_4["AGENTS.md"]
    source_4 --> destination_4
    source_5[".github/instructions/general-code-change.instructions.md"]
    destination_5["AGENTS.md"]
    source_5 --> destination_5
    source_6[".github/prompts/launch-review.prompt.md"]
    destination_6["[no target]"]
    source_6 --> destination_6
    source_7[".github/prompts/mixed-runtime.prompt.md"]
    destination_7[".agents/skills/mixed-runtime/SKILL.md"]
    source_7 --> destination_7
    destination_8[".agents/skills/mixed-runtime/SKILL.md"]
    source_7 --> destination_8
    destination_9[".codex/hooks/mixed-runtime.py"]
    source_7 --> destination_9
    destination_10["[no target]"]
    source_7 --> destination_10
    source_11[".github/skills/review-workflow/SKILL.md"]
    destination_11[".agents/skills/review-workflow/SKILL.md"]
    source_11 --> destination_11
```

### Repeated Source Nodes

Source nodes may repeat in this destination-to-source view so fan-out stays legible.
```mermaid
graph LR
    destination_0[".agents/skills/review-workflow/SKILL.md"]
    source_0[".github/agents/beast-topology.agent.md"]
    destination_0 --> source_0
    destination_1[".codex/agents/beast-topology.toml"]
    source_1[".github/agents/beast-topology.agent.md"]
    destination_1 --> source_1
    destination_2["AGENTS.md"]
    source_2[".github/agents/beast-topology.agent.md"]
    destination_2 --> source_2
    destination_3[".codex/agents/orchestrator.toml"]
    source_3[".github/agents/orchestrator.agent.md"]
    destination_3 --> source_3
    source_4[".github/copilot-instructions.md"]
    destination_2 --> source_4
    source_5[".github/instructions/general-code-change.instructions.md"]
    destination_2 --> source_5
    destination_6["[no target]"]
    source_6[".github/prompts/launch-review.prompt.md"]
    destination_6 --> source_6
    destination_7[".agents/skills/mixed-runtime/SKILL.md"]
    source_7[".github/prompts/mixed-runtime.prompt.md"]
    destination_7 --> source_7
    source_8[".github/prompts/mixed-runtime.prompt.md"]
    destination_7 --> source_8
    destination_9[".codex/hooks/mixed-runtime.py"]
    source_9[".github/prompts/mixed-runtime.prompt.md"]
    destination_9 --> source_9
    source_10[".github/prompts/mixed-runtime.prompt.md"]
    destination_6 --> source_10
    source_11[".github/skills/review-workflow/SKILL.md"]
    destination_0 --> source_11
```

## Mappings

| Source path | Conversion class | Target role | Target path | Notes |
| --- | --- | --- | --- | --- |
| `.github/agents/beast-topology.agent.md` | `decomposed` | `subagent` | `.codex/agents/beast-topology.toml` |  |
| `.github/agents/orchestrator.agent.md` | `decomposed` | `subagent` | `.codex/agents/orchestrator.toml` | Agent manifest contains handoff semantics that require validation before apply mode. |
| `.github/copilot-instructions.md` | `direct` | `standing-guidance` | `AGENTS.md` |  |
| `.github/instructions/general-code-change.instructions.md` | `decomposed` | `standing-guidance` | `AGENTS.md` | Repo-wide instruction applies to all files and merges into standing guidance. |
| `.github/prompts/launch-review.prompt.md` | `unsupported` | `unsupported` | `` | Launcher prompts map only to the repository-convention .codex/prompts surface when explicitly enabled.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/mixed-runtime.prompt.md` | `unsupported` | `unsupported` | `` | Launcher prompts map only to the repository-convention .codex/prompts surface when explicitly enabled.<br>Repository-convention prompt output is disabled for this run. |
| `.github/skills/review-workflow/SKILL.md` | `direct` | `shared-skill` | `.agents/skills/review-workflow/SKILL.md` |  |

## Section Mappings

| Source path | Section | Intent | Target role | Target path | Notes |
| --- | --- | --- | --- | --- | --- |
| `.github/prompts/launch-review.prompt.md` | `Launcher Surface` | `launcher-only` | `launcher` | `` | Prompt launcher wrapper maps only to the repository-convention launcher surface.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/mixed-runtime.prompt.md` | `Launcher Surface` | `launcher-only` | `launcher` | `` | Prompt launcher wrapper maps only to the repository-convention launcher surface.<br>Repository-convention prompt output is disabled for this run. |
| `.github/prompts/mixed-runtime.prompt.md` | `Hard Gate` | `hook-candidate` | `hook` | `.codex/hooks/mixed-runtime.py` | Section contains hard-gate or forbidden-action language that resembles a native validation hook. |
| `.github/prompts/mixed-runtime.prompt.md` | `Launch Template` | `shared-workflow` | `shared-skill` | `.agents/skills/mixed-runtime/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |
| `.github/prompts/mixed-runtime.prompt.md` | `Workflow` | `shared-workflow` | `shared-skill` | `.agents/skills/mixed-runtime/SKILL.md` | Section contains reusable workflow or output-contract content that maps more naturally to a shared skill. |

## Validation Findings

- `lingering-source-runtime-reference`: Generated output retains unresolved source-runtime references: GitHub Copilot runtime path
- `lingering-source-runtime-reference`: Generated output retains unresolved source-runtime references: GitHub Copilot runtime path
