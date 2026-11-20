# p4t5-com-focused1-lint

Timestamp: 2026-10-19T07-13
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/analyzer/com_interop.py tests/discovery_runtime/analyzer/test_com_interop.py tests/discovery_runtime/analyzer/test_com_candidates.py
EXIT_CODE: 1
Output Summary: FAIL scoped COM stage 2; duration 1.192 seconds. Exact bytes and original command output are in the paired JSON.

```text
E501 Line too long (175 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\com_interop.py:306:89
    |
304 | …
305 | …
306 | …, preprocessing, conditions, binding and runtime execution remain unresolved. Argument values are withheld.",
    |                        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
307 | …
308 | …
    |

E501 Line too long (115 > 88)
   --> tests\discovery_runtime\analyzer\test_com_candidates.py:132:89
    |
130 |     Neither earlier nor adjacent GUID argument values are retained in candidates.
131 |     """
132 |     source = 'var x = "[Guid(OLD_SECRET)]"; /* [ComImport] */\r\n[ComImport, Guid("NEW_SECRET")] interface Real {}'
    |                                                                                         ^^^^^^^^^^^^^^^^^^^^^^^^^^^
133 |     result = com_source_candidates("src/sample.cs", source)
134 |     assert len(result) == 1 and result[0].symbol == "ComImport"
    |

E501 Line too long (278 > 88)
   --> tests\discovery_runtime\analyzer\test_com_candidates.py:199:89
    |
197 | …
198 | …
199 | …"><ItemGroup Condition="VALUE_SENTINEL">\n<{element} Include="VALUE_SENTINEL"><Guid>VALUE_SENTINEL</Guid><EmbedInteropTypes>{value}</EmbedInteropTypes></{element}></ItemGroup></Project>'.encode()
    |       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
200 | …
201 | … == 2
    |

E501 Line too long (389 > 88)
   --> tests\discovery_runtime\analyzer\test_com_candidates.py:213:89
    |
211 | ….
212 | …
213 | …ndition="secret">false</EmbedInteropTypes></COMReference><COMReference Update="A" Remove="B"><EmbedInteropTypes>true</EmbedInteropTypes><EmbedInteropTypes>false</EmbedInteropTypes></COMReference><COMFileReference Remove="C"/></ItemGroup><ItemDefinitionGroup><COMReference/></ItemDefinitionGroup></Project>'
    |       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
214 | …
215 | …
    |

E501 Line too long (137 > 88)
   --> tests\discovery_runtime\analyzer\test_com_candidates.py:241:89
    |
239 | …
240 | …secret"/> --></Project>',
241 | …e="secret"><EmbedInteropTypes>true</EmbedInteropTypes></Reference></ItemGroup></Project>',
    |                                           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
242 | …>secret</COMReference></PropertyGroup></Project>",
243 | …
    |

E501 Line too long (89 > 88)
   --> tests\discovery_runtime\analyzer\test_com_candidates.py:293:89
    |
291 |             "<Project>"
292 |             + newline
293 |             + '<ItemGroup><COMReference Include="VALUE_SENTINEL"/></ItemGroup></Project>'
    |                                                                                         ^
294 |         ).encode()
295 |         assert com_project_candidates("src/a.csproj", xml) == com_project_candidates(
    |

E501 Line too long (93 > 88)
   --> tests\discovery_runtime\analyzer\test_com_interop.py:101:89
    |
 99 |     payload = (
100 |         bom
101 |         + '\r\nSystem.Runtime.InteropServices.Marshal.IsComObject("VALUE_SENTINEL");'.encode(
    |                                                                                         ^^^^^
102 |             encoding
103 |         )
    |

Found 7 errors.
```
