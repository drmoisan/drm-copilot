Timestamp: 2026-10-19T01:53:36.016635+00:00
Command: poetry run python -m ruff check --fix packages/discovery-runtime/src/drm_copilot_discovery/analyzer/emitter.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/findings.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/input_capture.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/inventory.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/models.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/pipeline.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/registry.py
EXIT_CODE: 1
Output Summary:

```text
E501 Line too long (91 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\input_capture.py:148:89
    |
146 |     rules = exclusion_rules(profile)
147 |     total_bytes = 0
148 |     # A fixed aggregate ceiling prevents many individually bounded reads exhausting memory.
    |                                                                                         ^^^
149 |     byte_budget = min(
150 |         profile.limits.source_files * profile.analyzers.max_file_bytes, 268435456
    |

E501 Line too long (90 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\input_capture.py:182:89
    |
180 |                     path=path,
181 |                     status="unreadable",
182 |                     rationale="Input could not be read within the configured byte limit.",
    |                                                                                         ^^
183 |                 )
184 |             )
    |

E501 Line too long (104 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\inventory.py:278:89
    |
276 |                         "source-revision-unverified",
277 |                         item.path,
278 |                         "Capture matching immutable repository bytes before publishing this inventory.",
    |                                                                                         ^^^^^^^^^^^^^^^^
279 |                     )
280 |                 )
    |

E501 Line too long (89 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\pipeline.py:198:89
    |
196 |     invocation: InvocationContext | None = None,
197 | ) -> MutationPlan:
198 |     """Plan one standalone inventory publication using exact caller-authenticated grants.
    |                                                                                         ^
199 |
200 |     Reconstruct results from the captured baseline before trusting their bytes.
    |


Fixed 3 errors:
- packages\discovery-runtime\src\drm_copilot_discovery\analyzer\emitter.py:
    1 × I001 (unsorted-imports)
- packages\discovery-runtime\src\drm_copilot_discovery\analyzer\input_capture.py:
    1 × I001 (unsorted-imports)
- packages\discovery-runtime\src\drm_copilot_discovery\analyzer\pipeline.py:
    1 × I001 (unsorted-imports)

Found 7 errors (3 fixed, 4 remaining).

```

Elapsed seconds: 0.107461
Source and test bytes unchanged: False

```json
{
  "packages/discovery-runtime/src/drm_copilot_discovery/analyzer/emitter.py": "f45a9618ebd2c159c7d86ebc9f062fd62eca0ad317428f110f9770e8b71996c0",
  "packages/discovery-runtime/src/drm_copilot_discovery/analyzer/findings.py": "7edffaa36d0d3c4ca72d6e6f00e9f48e377205472d3874c8222ad00ece2de01d",
  "packages/discovery-runtime/src/drm_copilot_discovery/analyzer/input_capture.py": "a6c5683bd24f51719b3d3dd3a9441e039e807160046665bf081d806da5a7c3aa",
  "packages/discovery-runtime/src/drm_copilot_discovery/analyzer/inventory.py": "cc0c386f3a565af25f1d88db53713a9d45861c6ba1a4d3dfa7e3273756795f78",
  "packages/discovery-runtime/src/drm_copilot_discovery/analyzer/models.py": "8819429432c644027eabd3b838626a18798bb31ae2d26e5363542367b841de04",
  "packages/discovery-runtime/src/drm_copilot_discovery/analyzer/pipeline.py": "1ad31c82172a1e52da85b96d8839954c15de046f191733316f4862e79edf4530",
  "packages/discovery-runtime/src/drm_copilot_discovery/analyzer/registry.py": "5fe0b51412b45d26faf02476aae93435746efe4d996ad7ff841846d01fc54d97"
}
```
