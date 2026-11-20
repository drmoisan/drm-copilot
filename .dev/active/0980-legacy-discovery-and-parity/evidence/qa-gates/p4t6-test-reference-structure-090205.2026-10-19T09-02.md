# P4-T6 scoped structural inspection

Timestamp: 2026-10-19T09-02
Command: `poetry run python SCRATCH/issue-980-test-reference-structure.py`
EXIT_CODE: 1
Output Summary: Exact source hashes, line counts, documentation, immediate loop-intent comments and pure in-memory boundaries.

```text
[
  {
    "path": "packages/discovery-runtime/src/drm_copilot_discovery/analyzer/test_references.py",
    "sha256": "cc4d1cdc8b2caf0292da1e94dd0aa375ca39117514fa690eb5d55d7d3b3faa6b",
    "lines": 481,
    "loop_comments": [
      {
        "line": 265,
        "statement": 265,
        "intent_comment": true
      },
      {
        "line": 294,
        "statement": 294,
        "intent_comment": true
      },
      {
        "line": 290,
        "statement": 290,
        "intent_comment": true
      },
      {
        "line": 254,
        "statement": 254,
        "intent_comment": true
      },
      {
        "line": 259,
        "statement": 259,
        "intent_comment": true
      },
      {
        "line": 338,
        "statement": 338,
        "intent_comment": true
      },
      {
        "line": 412,
        "statement": 412,
        "intent_comment": true
      },
      {
        "line": 429,
        "statement": 429,
        "intent_comment": true
      },
      {
        "line": 458,
        "statement": 458,
        "intent_comment": true
      },
      {
        "line": 340,
        "statement": 340,
        "intent_comment": true
      }
    ],
    "imports": [
      "__future__",
      "dataclasses",
      "typing",
      "drm_copilot_discovery.analyzer.csharp_declarations",
      "drm_copilot_discovery.analyzer.csharp_tokens",
      "drm_copilot_discovery.analyzer.findings",
      "drm_copilot_discovery.analyzer.models",
      "drm_copilot_discovery.analyzer.source_text",
      "drm_copilot_discovery.analyzer.test_reference_syntax",
      "drm_copilot_discovery.analyzer.xml_input",
      "drm_copilot_discovery.models",
      "drm_copilot_discovery.snapshot_io",
      "drm_copilot_discovery.analyzer.models",
      "drm_copilot_discovery.profile_v2"
    ]
  },
  {
    "path": "packages/discovery-runtime/src/drm_copilot_discovery/analyzer/test_reference_syntax.py",
    "sha256": "bddc8f8035f42ab743b558e3e928bec432470da99a50c434315790e948b1bb8a",
    "lines": 120,
    "loop_comments": [
      {
        "line": 34,
        "statement": 34,
        "intent_comment": true
      },
      {
        "line": 93,
        "statement": 93,
        "intent_comment": true
      },
      {
        "line": 52,
        "statement": 52,
        "intent_comment": true
      },
      {
        "line": 104,
        "statement": 104,
        "intent_comment": true
      },
      {
        "line": 113,
        "statement": 113,
        "intent_comment": true
      },
      {
        "line": 115,
        "statement": 115,
        "intent_comment": false
      }
    ],
    "imports": [
      "__future__",
      "typing",
      "drm_copilot_discovery.analyzer.csharp_tokens",
      "drm_copilot_discovery.analyzer.xml_input",
      "collections.abc",
      "drm_copilot_discovery.analyzer.csharp_tokens"
    ]
  },
  {
    "path": "tests/discovery_runtime/analyzer/test_test_references.py",
    "sha256": "8e17871369f91f26e2f36d8b4cfa09d7d1f4459baf0014ca24d0517d9c3321b6",
    "lines": 486,
    "loop_comments": [
      {
        "line": 307,
        "statement": 307,
        "intent_comment": true
      },
      {
        "line": 352,
        "statement": 352,
        "intent_comment": true
      },
      {
        "line": 381,
        "statement": 381,
        "intent_comment": true
      },
      {
        "line": 403,
        "statement": 403,
        "intent_comment": true
      },
      {
        "line": 427,
        "statement": 427,
        "intent_comment": true
      }
    ],
    "imports": [
      "__future__",
      "hashlib",
      "dataclasses",
      "typing",
      "pytest",
      "drm_copilot_discovery.analyzer",
      "drm_copilot_discovery.analyzer.emitter",
      "drm_copilot_discovery.analyzer.findings",
      "drm_copilot_discovery.analyzer.models",
      "drm_copilot_discovery.analyzer.test_references",
      "drm_copilot_discovery.models",
      "drm_copilot_discovery.repository_reader",
      "tests.discovery_runtime.analyzer.test_dotnet_projects",
      "tests.discovery_runtime.analyzer.test_dotnet_projects",
      "tests.discovery_runtime.analyzer.test_repository",
      "drm_copilot_discovery.catalog"
    ]
  },
  {
    "path": "tests/discovery_runtime/analyzer/test_test_reference_syntax.py",
    "sha256": "55543e0898ff820b34a3c20ecfb7e3a35096dd77664e2f90fdff01436afe68a4",
    "lines": 309,
    "loop_comments": [
      {
        "line": 271,
        "statement": 271,
        "intent_comment": true
      },
      {
        "line": 273,
        "statement": 273,
        "intent_comment": true
      }
    ],
    "imports": [
      "__future__",
      "typing",
      "pytest",
      "drm_copilot_discovery.analyzer",
      "drm_copilot_discovery.analyzer",
      "drm_copilot_discovery.analyzer.csharp_tokens",
      "drm_copilot_discovery.analyzer.source_text",
      "drm_copilot_discovery.analyzer.test_reference_syntax",
      "drm_copilot_discovery.analyzer.test_references",
      "tests.discovery_runtime.analyzer.test_dotnet_projects",
      "tests.discovery_runtime.analyzer.test_test_references",
      "collections.abc",
      "drm_copilot_discovery.catalog"
    ]
  }
]
Traceback (most recent call last):
  File "SCRATCH\issue-980-test-reference-structure.py", line 57, in <module>
    assert all(item['intent_comment'] for entry in results for item in entry['loop_comments']), 'Immediate loop intent comment missing'
           ~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
AssertionError: Immediate loop intent comment missing

```
