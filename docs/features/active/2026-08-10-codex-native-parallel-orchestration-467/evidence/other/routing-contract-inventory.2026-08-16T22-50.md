Timestamp: 2026-08-16T22-50
Command: Get-Content -Raw -LiteralPath 'config/orchestration-routing.json'; rg -n --hidden --glob '!artifacts/**' --glob '!docs/features/**' 'model_routing_receipts|codex_model_routing_receipts|commit-steward' scripts config .agents .codex
EXIT_CODE: 0
Output Summary: Canonical routing configuration, generated commit-steward profiles, and local legacy/Codex receipt validators were located without editing inspected files.

Relevant paths:
- config/orchestration-routing.json
- scripts/dev_tools/_orchestrator_state_model_routing.py
- scripts/dev_tools/_orchestrator_state_model_routing_gate.py
- scripts/dev_tools/_orchestrator_state_codex_model_routing.py
- scripts/dev_tools/resolve_delegation_model.py
- scripts/dev_tools/resolve_codex_deployment.py
- .codex/agents/commit-steward.toml
- .codex/agents/commit-steward-c4.toml

Exact output:
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "version": 1,
  "routes": {
    "small": {
      "description": "Minor-audit path for work inside the applicable language budget.",
      "codex_topology_requirement": {
        "receipt_key": "codex_topology_receipts",
        "required_execution_context": "standalone",
        "required_route": "small",
        "delegation_agent_source": "resolved_language_typed_engineer"
      },
      "required_agents": [
        "atomic-planner",
        "atomic-executor",
        "feature-review"
      ],
      "required_skills": [
        "orchestrate",
        "feature-promotion-lifecycle",
        "atomic-plan-contract",
        "acceptance-criteria-tracking",
        "pr-context-artifacts",
        "pr-base-branch-merge-base"
      ],
      "required_mcp_tools": [
        "new_potential_entry",
        "potential_to_issue",
        "new_active_feature_folder",
        "collect_pr_context",
        "validate_orchestration_artifacts"
      ]
    },
    "large": {
      "description": "Full feature or bug path for work outside small-path budget.",
      "requires_pr_gate": true,
      "required_agents": [
        "task-researcher",
        "prd-feature",
        "atomic-planner",
        "atomic-executor",
        "feature-review",
        "pr-author"
      ],
      "required_skills": [
        "orchestrate",
        "feature-promotion-lifecycle",
        "atomic-plan-contract",
        "acceptance-criteria-tracking",
        "pr-context-artifacts",
        "pr-base-branch-merge-base"
      ],
      "required_mcp_tools": [
        "new_potential_entry",
        "potential_to_issue",
        "new_active_feature_folder",
        "collect_pr_context",
        "validate_orchestration_artifacts"
      ]
    },
    "remediation": {
      "description": "Review-triggered remediation loop.",
      "required_agents": [
        "atomic-planner",
        "atomic-executor",
        "feature-review"
      ],
      "required_skills": [
        "orchestrate",
        "atomic-plan-contract",
        "acceptance-criteria-tracking",
        "pr-context-artifacts"
      ],
      "required_mcp_tools": [
        "collect_pr_context",
        "validate_orchestration_artifacts"
      ]
    },
    "preparation": {
      "description": "Epic preparation path driven by epic-planner: promotion, research, feature documents, atomic planning, and preflight clearance only. Atomic execution, PR authoring, and CI monitoring are out of scope and deferred to the epic execution phase, so this route requires no CI gate at completion.",
      "requires_ci_gate": false,
      "required_agents": [
        "task-researcher",
        "prd-feature",
        "atomic-planner",
        "atomic-executor"
      ],
      "required_skills": [
        "orchestrate",
        "feature-promotion-lifecycle",
        "atomic-plan-contract"
      ],
      "required_mcp_tools": [
        "new_potential_entry",
        "potential_to_issue",
        "new_active_feature_folder",
        "validate_orchestration_artifacts"
      ]
    },
    "parallel": {
      "description": "Parallel path for scheduling independent items into blast-radius cohorts across parallel worktrees; each item PRs to main independently with no integration branch.",
      "requires_pr_gate": false,
      "required_agents": [
        "orchestrator",
        "pr-author"
      ],
      "required_skills": [
        "parallel-orchestrate",
        "orchestrate",
        "feature-promotion-lifecycle",
        "atomic-plan-contract",
        "acceptance-criteria-tracking",
        "evidence-and-timestamp-conventions",
        "pr-context-artifacts",
        "pr-base-branch-merge-base"
      ],
      "required_mcp_tools": [
        "collect_pr_context",
        "validate_orchestration_artifacts"
      ]
    },
    "epic": {
      "description": "Epic path for scheduling a dependency graph of child features across parallel worktrees with fan-in via a shared integration branch.",
      "requires_pr_gate": true,
      "required_agents": [
        "orchestrator",
        "pr-author"
      ],
      "required_skills": [
        "epic-orchestrate",
        "orchestrate",
        "feature-promotion-lifecycle",
        "atomic-plan-contract",
        "acceptance-criteria-tracking",
        "evidence-and-timestamp-conventions",
        "pr-context-artifacts",
        "pr-base-branch-merge-base"
      ],
      "required_mcp_tools": [
        "collect_pr_context",
        "validate_orchestration_artifacts"
      ]
    }
  },
  "model_policy": {
    "description": "Judgment-based complexity-band model selection. This block governs only the delegation model tier. It is not a route input, and route is not an input to model selection.",
    "tier_order": [
      "haiku",
      "sonnet",
      "opus",
      "fable"
    ],
    "complexity": {
      "scale": "C1 trivial or mechanical change with no behavior effect. C2 localized feature or bug change confined to a small surface. C3 cross-cutting change that alters an invariant, contract, or behavior across module boundaries. C4 novel, ambiguous, or research-heavy change requiring the most capable tier; C4 is reached only by judgment and is never floor-forced.",
      "signals": [
        {
          "name": "classifier_or_model_logic",
          "floor": true,
          "anchor": "Changes to classifier engines, scoring, or model-affecting logic (T1 modules)."
        },
        {
          "name": "auth_or_token_handling",
          "floor": true,
          "anchor": "Changes to authentication, token handling, or other security-sensitive paths."
        },
        {
          "name": "concurrency_or_ordering",
          "floor": true,
          "anchor": "Introduces or modifies concurrency, ordering, or state-transition invariants."
        },
        {
          "name": "cross_module_contract_change",
          "floor": true,
          "anchor": "Alters a public contract or schema consumed across module boundaries."
        },
        {
          "name": "single_file_localized_edit",
          "floor": false,
          "anchor": "A localized edit confined to one file with no cross-cutting effect."
        },
        {
          "name": "mechanical_rename_or_move",
          "floor": false,
          "anchor": "A mechanical rename, move, or formatting change with no behavior change."
        },
        {
          "name": "docs_or_comment_only",
          "floor": false,
          "anchor": "A documentation-only or comment-only change."
        }
      ]
    },
    "complexity_to_model": {
      "C1": "haiku",
      "C2": "sonnet",
      "C3": "opus",
      "C4": "fable"
    },
    "preferred_overlay": {
      "description": "Applied only under fable_policy preferred. Changes only the C3 cell to fable, and only for the listed agents. No other agent and no other band is affected.",
      "agents": [
        "atomic-planner",
        "prd-feature",
        "feature-review",
        "task-researcher"
      ],
      "band": "C3",
      "model": "fable"
    }
  },
  "model_budget": {
    "description": "Session-level model budget. fable_policy is a three-way switch controlling whether the fable tier is disabled (removed and clamped to opus), available (used as-is), or preferred (applies the preferred_overlay).",
    "fable_policy": "preferred"
  },
  "codex_topology_policy": {
    "description": "Codex-native production-file-count routing. This axis selects the initial implementation topology independently from C1-C4 model selection.",
    "execution_contexts": [
      "standalone",
      "epic_preparation_child",
      "epic_execution_child",
      "parallel_planning",
      "parallel_execution"
    ],
    "language_budgets": {
      "python": {
        "direct_mode_enabled": true,
        "max_production_files": 3,
        "max_test_files": 3,
        "logical_agent": "python-typed-engineer"
      },
      "powershell": {
        "direct_mode_enabled": true,
        "max_production_files": 2,
        "max_test_files": 3,
        "logical_agent": "powershell-typed-engineer"
      },
      "csharp": {
        "direct_mode_enabled": true,
        "max_production_files": 3,
        "max_test_files": 3,
        "logical_agent": "csharp-typed-engineer"
      },
      "typescript": {
        "direct_mode_enabled": false,
        "max_production_files": 0,
        "max_test_files": 0,
        "logical_agent": "typescript-engineer"
      }
    },
    "orchestrator_logical_agent": "orchestrator",
    "epic_child_contexts": [
      "epic_preparation_child",
      "epic_execution_child"
    ],
      "forced_root_personas": [
        "epic-planner",
        "epic-orchestrator",
        "parallel-planner",
        "parallel-orchestrator"
      ],
      "parallel_root_context_personas": {
        "parallel_planning": "parallel-planner",
        "parallel_execution": "parallel-orchestrator"
      },
      "parallelism": {
        "default_max_parallel_features": 4,
        "hard_max_parallel_features": 8
      },
      "escalation_precedence": [
      "epic_child_context",
      "invalid_estimate",
      "cross_language",
      "unsupported_language",
      "cross_cutting",
        "direct_mode_disabled",
        "production_budget_exceeded"
    ],
    "receipt_key": "codex_topology_receipts"
  },
  "codex_model_policy": {
    "description": "Codex-native deployment profiles. Complexity selects model and reasoning independently from the file-count route; exact model slugs are mandatory and unavailable profiles do not fall back silently.",
    "profile_order": [
      "c1",
      "c2",
      "c3",
      "c3-elevated",
      "c4"
    ],
    "execution_contexts": [
      "standalone",
      "epic_preparation_child",
      "epic_execution_child",
      "parallel_planning",
      "parallel_execution"
    ],
    "logical_agent_aliases": {
      "feature-review": "feature-reviewer"
    },
    "complexity_to_profile": {
      "C1": {
        "suffix": "c1",
        "model": "gpt-5.6-luna",
        "model_reasoning_effort": "low"
      },
      "C2": {
        "suffix": "c2",
        "model": "gpt-5.6-terra",
        "model_reasoning_effort": "medium"
      },
      "C3": {
        "suffix": "c3",
        "model": "gpt-5.6-terra",
        "model_reasoning_effort": "high"
      },
      "C4": {
        "suffix": "c4",
        "model": "gpt-5.6-sol",
        "model_reasoning_effort": "max"
      }
    },
      "c3_elevated_profile": {
      "suffix": "c3-elevated",
      "model": "gpt-5.6-sol",
      "model_reasoning_effort": "high",
      "activation": {
        "operator": "any",
        "execution_contexts": [
          "epic_execution_child",
          "epic_preparation_child"
        ],
        "orchestration_complexity_ceiling": "C4"
      }
      },
      "ceiling_transition_policy": {
        "monotonic": true,
        "receipt_key": "ceiling_transition",
        "affected_delegation_ids_required_on_increase": true
      },
      "forced_personas": {
      "epic-planner": {
        "suffix": "",
        "model": "gpt-5.6-sol",
        "model_reasoning_effort": "ultra"
      },
      "epic-orchestrator": {
        "suffix": "",
        "model": "gpt-5.6-sol",
        "model_reasoning_effort": "ultra"
      },
      "parallel-planner": {
        "suffix": "",
        "model": "gpt-5.6-sol",
        "model_reasoning_effort": "ultra"
      },
      "parallel-orchestrator": {
        "suffix": "",
        "model": "gpt-5.6-sol",
        "model_reasoning_effort": "ultra"
      }
    },
    "parallel_root_context_personas": {
      "parallel_planning": "parallel-planner",
      "parallel_execution": "parallel-orchestrator"
    },
    "generated_agent_families": [
      "orchestrator",
      "atomic-planner",
      "atomic-executor",
      "feature-reviewer",
      "task-researcher",
      "prd-feature",
      "pr-author",
      "python-typed-engineer",
      "powershell-typed-engineer",
      "csharp-typed-engineer",
      "typescript-engineer",
      "commit-steward"
    ]
  }
}

config\orchestration-routing.json:377:      "commit-steward"
.codex\scripts\epic-child-launch-contract.ps1:103:    if (@($Checkpoint.PSObject.Properties.Name) -contains 'codex_model_routing_receipts') {
.codex\scripts\epic-child-launch-contract.ps1:104:        $receipts += @($Checkpoint.codex_model_routing_receipts)
.codex\prompts\generate-commit-message-repo.md:2:description: Generate a conventional commit message for the current repository by spawning commit-steward
.codex\prompts\generate-commit-message-repo.md:5:Spawn `commit-steward` to generate a single audit-quality conventional commit message for the current repository.
.codex\prompts\generate-commit-message-repo.md:9:If no commit-context artifact is available, have `commit-steward` inspect staged changes directly and scope the message to staged changes only.
.codex\hooks\codex-agent-profile-attestation.ps1:168:        foreach ($receiptKey in @('codex_model_routing_receipts', 'model_routing_receipts')) {
.agents\skills\codex-model-routing\SKILL.md:63:6. Persist the returned object in `codex_model_routing_receipts[]` with a
.codex\agents\commit-steward-c4.toml:1:name = "commit-steward-c4"
.codex\agents\commit-steward-c3.toml:1:name = "commit-steward-c3"
.codex\agents\commit-steward-c3-elevated.toml:1:name = "commit-steward-c3-elevated"
.codex\agents\commit-steward-c2.toml:1:name = "commit-steward-c2"
.codex\agents\commit-steward-c1.toml:1:name = "commit-steward-c1"
.agents\skills\orchestrator-workflow\SKILL.md:44:  - `commit-steward`
.agents\skills\orchestrator-workflow\SKILL.md:221:  - remediation commit message -> `commit-steward`
.agents\skills\orchestrator-workflow\SKILL.md:240:- commit-steward result:
.agents\skills\orchestrator-workflow\SKILL.md:392:8. Delegate `commit-steward` using `commit-context-path` as the authoritative staged-change input.
.agents\skills\orchestrator-workflow\SKILL.md:393:9. Commit the staged work with the exact message returned by `commit-steward`.
.codex\agents\commit-steward.toml:1:name = "commit-steward"
.codex\agents\orchestrator.toml:99:- `commit-steward`: commit message generation from commit-context artifacts when available.
.codex\agents\orchestrator-c4.toml:99:- `commit-steward`: commit message generation from commit-context artifacts when available.
.codex\agents\orchestrator-c3.toml:99:- `commit-steward`: commit message generation from commit-context artifacts when available.
.codex\agents\orchestrator-c3-elevated.toml:99:- `commit-steward`: commit message generation from commit-context artifacts when available.
.agents\skills\orchestrate\SKILL.md:296:- `commit-steward` — writes commit messages from commit-context artifacts
.codex\agents\orchestrator-c2.toml:99:- `commit-steward`: commit message generation from commit-context artifacts when available.
.codex\agents\orchestrator-c1.toml:99:- `commit-steward`: commit message generation from commit-context artifacts when available.
scripts\dev_tools\generate_codex_agent_variants.py:41:    "commit-steward",
scripts\dev_tools\resolve_delegation_model.py:25:    ``model_routing_receipts[]`` entry; the model-routing validator
scripts\dev_tools\resolve_codex_deployment.py:57:        "commit-steward",
scripts\dev_tools\validate_orchestration_artifacts.py:220:            "model_routing_receipts entry per delegated agent and a "
scripts\dev_tools\validate_orchestration_artifacts.py:230:            "codex_model_routing_receipts entry for each delegated agent."
scripts\dev_tools\validate_epic_orchestrator_state.py:32:    validate_codex_model_routing_receipts,
scripts\dev_tools\validate_epic_orchestrator_state.py:470:            validate_codex_model_routing_receipts(
scripts\dev_tools\validate_epic_planner_state.py:16:    validate_codex_model_routing_receipts,
scripts\dev_tools\validate_epic_planner_state.py:242:        receipt_errors = validate_codex_model_routing_receipts([model_receipt])
scripts\dev_tools\validate_epic_planner_state.py:245:                "Checkpoint codex_model_routing_receipts[0]",
scripts\dev_tools\validate_parallel_codex_readiness.py:22:    validate_codex_model_routing_receipts,
scripts\dev_tools\validate_parallel_codex_readiness.py:408:        for error in validate_codex_model_routing_receipts([model]):
scripts\dev_tools\validate_parallel_codex_readiness.py:411:                    "Checkpoint codex_model_routing_receipts[0]",
scripts\dev_tools\validate_orchestrator_state.py:33:    validate_codex_model_routing_receipts,
scripts\dev_tools\validate_orchestrator_state.py:45:    _validate_model_routing_receipts,
scripts\dev_tools\validate_orchestrator_state.py:451:        (MODEL_ROUTING_RECEIPTS_KEY, _validate_model_routing_receipts),
scripts\dev_tools\validate_orchestrator_state.py:454:            validate_codex_model_routing_receipts,
scripts\dev_tools\_orchestrator_state_codex_model_routing.py:10:CODEX_MODEL_ROUTING_RECEIPTS_KEY = "codex_model_routing_receipts"
scripts\dev_tools\_orchestrator_state_codex_model_routing.py:66:def validate_codex_model_routing_receipts(value: object) -> list[str]:
scripts\dev_tools\_orchestrator_state_codex_model_routing.py:161:    errors = validate_codex_model_routing_receipts(value)
scripts\dev_tools\_orchestrator_state_codex_topology.py:9:    validate_codex_model_routing_receipts,
scripts\dev_tools\_orchestrator_state_codex_topology.py:155:        if validate_codex_model_routing_receipts([receipt]):
scripts\dev_tools\_orchestrator_state_model_routing_gate.py:10:    ``model_routing_receipts[]`` entry, each matched receipt's phase must have a
scripts\dev_tools\_orchestrator_state_model_routing_gate.py:25:    - Per-entry correctness reuses ``_validate_model_routing_receipts`` and
scripts\dev_tools\_orchestrator_state_model_routing_gate.py:46:    _validate_model_routing_receipts,
scripts\dev_tools\_orchestrator_state_model_routing_gate.py:138:        Read the checkpoint's ``model_routing_receipts[]`` array once and return
scripts\dev_tools\_orchestrator_state_model_routing_gate.py:228:        delegated agent has a matching ``model_routing_receipts[]`` entry, that
scripts\dev_tools\_orchestrator_state_model_routing_gate.py:245:        None. Reuses ``_validate_model_routing_receipts`` and
scripts\dev_tools\_orchestrator_state_model_routing_gate.py:268:            "Checkpoint model_routing_receipts is missing a receipt for "
scripts\dev_tools\_orchestrator_state_model_routing_gate.py:280:            f"{phase} referenced by a model_routing_receipts entry."
scripts\dev_tools\_orchestrator_state_model_routing_gate.py:291:            _validate_model_routing_receipts(state_map.get(MODEL_ROUTING_RECEIPTS_KEY))
scripts\dev_tools\_orchestrator_state_model_routing.py:4:    Hold the optional ``model_routing_receipts`` array constants and the
scripts\dev_tools\_orchestrator_state_model_routing.py:5:    ``_validate_model_routing_receipts`` helper so the primary validator module
scripts\dev_tools\_orchestrator_state_model_routing.py:14:    ``_validate_model_routing_receipts`` from this module. The primary
scripts\dev_tools\_orchestrator_state_model_routing.py:16:    ``model_routing_receipts`` key, so an absent key contributes zero errors.
scripts\dev_tools\_orchestrator_state_model_routing.py:45:# ``_validate_model_routing_receipts`` here marks it as a deliberate re-export
scripts\dev_tools\_orchestrator_state_model_routing.py:50:    "_validate_model_routing_receipts",
scripts\dev_tools\_orchestrator_state_model_routing.py:53:MODEL_ROUTING_RECEIPTS_KEY = "model_routing_receipts"
scripts\dev_tools\_orchestrator_state_model_routing.py:57:def _validate_model_routing_receipts(value: object) -> list[str]:
scripts\dev_tools\_orchestrator_state_model_routing.py:58:    """Validate the optional ``model_routing_receipts`` array invariants.
scripts\dev_tools\_orchestrator_state_model_routing.py:62:        checkpoint's optional ``model_routing_receipts`` array, mirroring the
scripts\dev_tools\_orchestrator_state_model_routing.py:69:            ``model_routing_receipts`` key. Callers invoke this helper only
scripts\dev_tools\_orchestrator_state_model_routing.py:89:        errors.append("Checkpoint model_routing_receipts must be a list when present.")
scripts\dev_tools\_orchestrator_state_model_routing.py:98:                f"Checkpoint model_routing_receipts #{index} must be an object."
scripts\dev_tools\_orchestrator_state_model_routing.py:142:            f"Checkpoint model_routing_receipts #{index} complexity_band must "
scripts\dev_tools\_orchestrator_state_model_routing.py:157:            f"Checkpoint model_routing_receipts #{index} model {model} does not "
scripts\dev_tools\_orchestrator_state_model_routing.py:201:            f"Checkpoint model_routing_receipts #{index} model must not be "
scripts\dev_tools\_orchestrator_state_model_routing.py:211:            f"Checkpoint model_routing_receipts #{index} table_model fable "
