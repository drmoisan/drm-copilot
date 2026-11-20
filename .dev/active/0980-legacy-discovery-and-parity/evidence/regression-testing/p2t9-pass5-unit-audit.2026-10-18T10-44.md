# p2t9-pass5-unit-audit

Timestamp: 2026-10-18T10-44
Command: poetry run python SCRATCH/issue-980-p2t9-preaudit.py
EXIT_CODE: 1
Output Summary:       "percent": 84.61538461538461;     };   ]; }

Working directory: .
Started: 2026-10-18T10:44:51.512973+00:00
Duration seconds: 0.865
Phase: P2-T9 validation composition and role outputs; focused task verification.

## Captured output

```text
{
  "units": [
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/agent_output.py",
      "name": "InvocationContext",
      "covered": 10,
      "total": 10,
      "percent": 100.0
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/agent_output.py",
      "name": "OutputValidation",
      "covered": 3,
      "total": 3,
      "percent": 100.0
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/agent_output.py",
      "name": "required_output_digest",
      "covered": 3,
      "total": 3,
      "percent": 100.0
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/agent_output.py",
      "name": "historical_report",
      "covered": 5,
      "total": 5,
      "percent": 100.0
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/agent_output.py",
      "name": "_OutputRules",
      "covered": 93,
      "total": 94,
      "percent": 98.93617021276596
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/agent_output.py",
      "name": "validate_agent_output",
      "covered": 8,
      "total": 8,
      "percent": 100.0
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/agent_output.py",
      "name": "__post_init__",
      "covered": 2,
      "total": 2,
      "percent": 100.0
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/agent_output.py",
      "name": "__init__",
      "covered": 6,
      "total": 6,
      "percent": 100.0
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/agent_output.py",
      "name": "add",
      "covered": 2,
      "total": 2,
      "percent": 100.0
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/agent_output.py",
      "name": "manifest",
      "covered": 15,
      "total": 15,
      "percent": 100.0
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/agent_output.py",
      "name": "output",
      "covered": 30,
      "total": 31,
      "percent": 96.7741935483871
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/agent_output.py",
      "name": "preserve_members",
      "covered": 14,
      "total": 14,
      "percent": 100.0
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/agent_output.py",
      "name": "changes",
      "covered": 25,
      "total": 25,
      "percent": 100.0
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/completion_rules.py",
      "name": "CompletionValidation",
      "covered": 2,
      "total": 2,
      "percent": 100.0
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/completion_rules.py",
      "name": "_CompletionRules",
      "covered": 44,
      "total": 44,
      "percent": 100.0
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/completion_rules.py",
      "name": "validate_completion",
      "covered": 15,
      "total": 15,
      "percent": 100.0
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/completion_rules.py",
      "name": "__init__",
      "covered": 4,
      "total": 4,
      "percent": 100.0
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/completion_rules.py",
      "name": "prerequisites",
      "covered": 15,
      "total": 15,
      "percent": 100.0
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/completion_rules.py",
      "name": "runtime",
      "covered": 5,
      "total": 5,
      "percent": 100.0
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/completion_rules.py",
      "name": "feature",
      "covered": 19,
      "total": 19,
      "percent": 100.0
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/validation.py",
      "name": "_findings",
      "covered": 5,
      "total": 5,
      "percent": 100.0
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/validation.py",
      "name": "SnapshotValidation",
      "covered": 12,
      "total": 12,
      "percent": 100.0
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/validation.py",
      "name": "_Validation",
      "covered": 43,
      "total": 45,
      "percent": 95.55555555555556
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/validation.py",
      "name": "validate_snapshot",
      "covered": 39,
      "total": 39,
      "percent": 100.0
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/validation.py",
      "name": "report_projection",
      "covered": 7,
      "total": 7,
      "percent": 100.0
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/validation.py",
      "name": "ok",
      "covered": 2,
      "total": 2,
      "percent": 100.0
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/validation.py",
      "name": "__init__",
      "covered": 15,
      "total": 15,
      "percent": 100.0
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/validation.py",
      "name": "evaluate",
      "covered": 11,
      "total": 13,
      "percent": 84.61538461538461
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/validation.py",
      "name": "complete",
      "covered": 12,
      "total": 12,
      "percent": 100.0
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/validation.py",
      "name": "report",
      "covered": 4,
      "total": 4,
      "percent": 100.0
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/validation_inputs.py",
      "name": "input_problem",
      "covered": 2,
      "total": 2,
      "percent": 100.0
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/validation_inputs.py",
      "name": "validate_inputs",
      "covered": 32,
      "total": 32,
      "percent": 100.0
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/validation_inputs.py",
      "name": "report_input_digest",
      "covered": 7,
      "total": 7,
      "percent": 100.0
    }
  ],
  "failures": [
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/validation.py",
      "name": "evaluate",
      "covered": 11,
      "total": 13,
      "percent": 84.61538461538461
    }
  ]
}
```
