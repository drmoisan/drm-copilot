# P5-T4 generation ruff

Timestamp: 2026-10-20T10-48

Command: `poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/acceptance_generation.py packages/discovery-runtime/src/drm_copilot_discovery/acceptance_generation_context.py tests/discovery_runtime/test_acceptance_generation.py tests/discovery_runtime/test_acceptance_decisions.py`

EXIT_CODE: 1

Output Summary: FAIL or changed bytes; 1.209 seconds.

```text
E501 Line too long (92 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\acceptance_generation.py:419:89
    |
417 |                     scenarios = self.scenarios(source, platform, mode)
418 |                     ctx.budget.work(len(scenarios))
419 |                     # Explicit linked observations discriminate otherwise equal coordinates.
    |                                                                                         ^^^^
420 |                     for scenario in scenarios:
421 |                         self.candidate(
    |

E501 Line too long (104 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\acceptance_generation_context.py:201:89
    |
199 |                     message=message,
200 |                     artifact_path=record.artifact.path if record else None,
201 |                     next_action="Correct the captured inputs or explicit selection and generate again.",
    |                                                                                         ^^^^^^^^^^^^^^^^
202 |                 ),
203 |             )
    |

E501 Line too long (90 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\acceptance_generation_context.py:333:89
    |
331 |             len(self.snapshot.manifest.files) + size * max(1, size.bit_length())
332 |         )
333 |         # Existing authored paths remain immutable, even if generation is requested again.
    |                                                                                         ^^
334 |         existing = {file.path for file in self.snapshot.manifest.files}
335 |         # A temporary in-memory namespace prevents overwriting captured authored rows.
    |

E501 Line too long (91 > 88)
   --> tests\discovery_runtime\test_acceptance_generation.py:157:89
    |
155 |     """
156 |     documents: list[dict[str, object]] = []
157 |     # Rebind bytes and pin objects together so semantic tests do not create stale fixtures.
    |                                                                                         ^^^
158 |     for artifact in snapshot.artifacts:
159 |         assert artifact.document is not None
    |

Found 4 errors.

```
