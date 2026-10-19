# P4-T6 initial-check lint

Timestamp: 2026-10-19T08-49
Command: `poetry run python -m ruff check packages/discovery-runtime/src/drm_copilot_discovery/analyzer/test_references.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/test_reference_syntax.py tests/discovery_runtime/analyzer/test_test_references.py tests/discovery_runtime/analyzer/test_test_reference_syntax.py`
EXIT_CODE: 1
Output Summary: Scoped development check with exact source bindings and raw diagnostics retained in JSON.

```text
E501 Line too long (116 > 88)
  --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\test_references.py:84:89
   |
82 |         code,
83 |         path,
84 |         "Inspect configured scope, retained syntax and exact source pins; binding and execution remain unresolved.",
   |                                                                                         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
85 |         analyzer=_IDENTIFIER,
86 |         blocking=blocking,
   |

TC003 Move standard library import `collections.abc.Iterator` into a type-checking block
 --> tests\discovery_runtime\analyzer\test_test_reference_syntax.py:5:29
  |
3 | from __future__ import annotations
4 |
5 | from collections.abc import Iterator
  |                             ^^^^^^^^
6 | from typing import cast
  |
help: Move into type-checking block

E501 Line too long (101 > 88)
  --> tests\discovery_runtime\analyzer\test_test_reference_syntax.py:65:89
   |
63 |     "xml",
64 |     [
65 |         '<Project><Target><ItemGroup><ProjectReference Include="x"/></ItemGroup></Target></Project>',
   |                                                                                         ^^^^^^^^^^^^^
66 |         '<Project><ProjectReference Include="x"/></Project>',
67 |         '<Project><ItemGroup><Other Include="x"/></ItemGroup></Project>',
   |

E501 Line too long (102 > 88)
  --> tests\discovery_runtime\analyzer\test_test_reference_syntax.py:68:89
   |
66 |         '<Project><ProjectReference Include="x"/></Project>',
67 |         '<Project><ItemGroup><Other Include="x"/></ItemGroup></Project>',
68 |         '<Project><ItemGroup><ProjectReference xmlns="urn:other" Include="x"/></ItemGroup></Project>',
   |                                                                                         ^^^^^^^^^^^^^^
69 |     ],
70 | )
   |

E501 Line too long (125 > 88)
   --> tests\discovery_runtime\analyzer\test_test_reference_syntax.py:159:89
    |
157 |     Attributes remain literal without project target evaluation or I/O.
158 |     """
159 |     content = b'<Project>\r\n<ItemGroup><ProjectReference Include="x"/><ProjectReference Include="x"/></ItemGroup></Project>'
    |                                                                                         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
160 |     sites = tuple(project_reference_sites(content, max_bytes=1024, limit=100))
161 |     assert sites == (
    |

E501 Line too long (249 > 88)
   --> tests\discovery_runtime\analyzer\test_test_reference_syntax.py:180:89
    |
178 | …
179 | …
180 | …p{attribute if condition == "group" else ""}><ProjectReference {operation}="../src/app.csproj"{attribute if condition == "reference" else ""}/></ItemGroup></Project>'
    |       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
181 | …
182 | …
    |

E501 Line too long (104 > 88)
   --> tests\discovery_runtime\analyzer\test_test_references.py:156:89
    |
154 |     Returns None; observed same-spelling type contexts retain unresolved binding.
155 |     """
156 |     text = "using Widget = Other.Type; class Test { class Widget {} }\n#if FALSE\nnew Widget();\n#endif"
    |                                                                                         ^^^^^^^^^^^^^^^^
157 |     result = analyze(catalog, text)
158 |     assert (
    |

E501 Line too long (93 > 88)
   --> tests\discovery_runtime\analyzer\test_test_references.py:232:89
    |
230 |     Returns None; no raw values or value-derived IDs are exposed.
231 |     """
232 |     xml = f'<Project><ItemGroup><ProjectReference Include="{target}"/></ItemGroup></Project>'
    |                                                                                         ^^^^^
233 |     result = ReferenceAnalyzer().analyze(
234 |         inputs(catalog, (("tests/a.csproj", xml.encode()),))
    |

E501 Line too long (95 > 88)
   --> tests\discovery_runtime\analyzer\test_test_references.py:248:89
    |
246 |         "<Project><ItemGroup><ProjectReference/></ItemGroup></Project>",
247 |         '<Project><ItemGroup><ProjectReference Include=" "/></ItemGroup></Project>',
248 |         '<Project><ItemGroup><ProjectReference Include="x" Update="y"/></ItemGroup></Project>',
    |                                                                                         ^^^^^^^
249 |         '<!DOCTYPE Project [<!ENTITY x "VALUE_SENTINEL">]><Project/>',
250 |         "<Project VALUE_SENTINEL",
    |

Found 9 errors.
No fixes available (1 hidden fix can be enabled with the `--unsafe-fixes` option).

```
