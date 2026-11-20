# P4-T8 Compatibility focused1 lint

Timestamp: 2026-10-19T11-42
Command: `poetry run python -m ruff check scripts/dev_tools/discovery/analyzer/vsto_office.py scripts/dev_tools/discovery/analyzer/vsto_patterns.py scripts/dev_tools/discovery/analyzer/stack_cli.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/registry.py tests/discovery_runtime/analyzer/test_registry.py tests/scripts/dev_tools/discovery/analyzer/test_vsto_office.py tests/scripts/dev_tools/discovery/analyzer/test_vsto_compatibility.py tests/scripts/dev_tools/discovery/analyzer/test_stack_cli.py tests/scripts/dev_tools/discovery/analyzer/test_stack_neutrality.py tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py`
EXIT_CODE: 1
Output Summary: Isolated development check; exact shared and owned bytes and raw diagnostics are bound in JSON.

```text
E501 Line too long (90 > 88)
  --> scripts\dev_tools\discovery\analyzer\vsto_office.py:32:89
   |
30 | _MIGRATION_ERROR = (
31 |     "Legacy vsto-office execution requires a v2 InventoryCapture and a configured "
32 |     "ProfileV2 enabling office-vsto; use analyze(capture). No files were read or written."
   |                                                                                         ^^
33 | )
   |

F822 Undefined name `CUSTOMUI_URIS` in `__all__`
  --> scripts\dev_tools\discovery\analyzer\vsto_patterns.py:10:5
   |
 9 | __all__ = (
10 |     "CUSTOMUI_URIS",
   |     ^^^^^^^^^^^^^^^
11 |     "CUSTOMUI_ELEMENT_RE",
12 |     "IRIBBON_RE",
   |

F822 Undefined name `CUSTOMUI_ELEMENT_RE` in `__all__`
  --> scripts\dev_tools\discovery\analyzer\vsto_patterns.py:11:5
   |
 9 | __all__ = (
10 |     "CUSTOMUI_URIS",
11 |     "CUSTOMUI_ELEMENT_RE",
   |     ^^^^^^^^^^^^^^^^^^^^^
12 |     "IRIBBON_RE",
13 |     "GETCUSTOMUI_RE",
   |

F822 Undefined name `IRIBBON_RE` in `__all__`
  --> scripts\dev_tools\discovery\analyzer\vsto_patterns.py:12:5
   |
10 |     "CUSTOMUI_URIS",
11 |     "CUSTOMUI_ELEMENT_RE",
12 |     "IRIBBON_RE",
   |     ^^^^^^^^^^^^
13 |     "GETCUSTOMUI_RE",
14 |     "DESIGNER_RIBBON_LITERAL",
   |

F822 Undefined name `GETCUSTOMUI_RE` in `__all__`
  --> scripts\dev_tools\discovery\analyzer\vsto_patterns.py:13:5
   |
11 |     "CUSTOMUI_ELEMENT_RE",
12 |     "IRIBBON_RE",
13 |     "GETCUSTOMUI_RE",
   |     ^^^^^^^^^^^^^^^^
14 |     "DESIGNER_RIBBON_LITERAL",
15 |     "COM_ATTRIBUTE_RES",
   |

F822 Undefined name `DESIGNER_RIBBON_LITERAL` in `__all__`
  --> scripts\dev_tools\discovery\analyzer\vsto_patterns.py:14:5
   |
12 |     "IRIBBON_RE",
13 |     "GETCUSTOMUI_RE",
14 |     "DESIGNER_RIBBON_LITERAL",
   |     ^^^^^^^^^^^^^^^^^^^^^^^^^
15 |     "COM_ATTRIBUTE_RES",
16 |     "GUID_CAPTURE_RE",
   |

F822 Undefined name `COM_ATTRIBUTE_RES` in `__all__`
  --> scripts\dev_tools\discovery\analyzer\vsto_patterns.py:15:5
   |
13 |     "GETCUSTOMUI_RE",
14 |     "DESIGNER_RIBBON_LITERAL",
15 |     "COM_ATTRIBUTE_RES",
   |     ^^^^^^^^^^^^^^^^^^^
16 |     "GUID_CAPTURE_RE",
17 |     "MARSHAL_RE",
   |

F822 Undefined name `GUID_CAPTURE_RE` in `__all__`
  --> scripts\dev_tools\discovery\analyzer\vsto_patterns.py:16:5
   |
14 |     "DESIGNER_RIBBON_LITERAL",
15 |     "COM_ATTRIBUTE_RES",
16 |     "GUID_CAPTURE_RE",
   |     ^^^^^^^^^^^^^^^^^
17 |     "MARSHAL_RE",
18 |     "PROGID_RE",
   |

F822 Undefined name `MARSHAL_RE` in `__all__`
  --> scripts\dev_tools\discovery\analyzer\vsto_patterns.py:17:5
   |
15 |     "COM_ATTRIBUTE_RES",
16 |     "GUID_CAPTURE_RE",
17 |     "MARSHAL_RE",
   |     ^^^^^^^^^^^^
18 |     "PROGID_RE",
19 |     "INTEROP_USING_RE",
   |

F822 Undefined name `PROGID_RE` in `__all__`
  --> scripts\dev_tools\discovery\analyzer\vsto_patterns.py:18:5
   |
16 |     "GUID_CAPTURE_RE",
17 |     "MARSHAL_RE",
18 |     "PROGID_RE",
   |     ^^^^^^^^^^^
19 |     "INTEROP_USING_RE",
20 |     "COMREFERENCE_RE",
   |

F822 Undefined name `INTEROP_USING_RE` in `__all__`
  --> scripts\dev_tools\discovery\analyzer\vsto_patterns.py:19:5
   |
17 |     "MARSHAL_RE",
18 |     "PROGID_RE",
19 |     "INTEROP_USING_RE",
   |     ^^^^^^^^^^^^^^^^^^
20 |     "COMREFERENCE_RE",
21 |     "EMBEDINTEROP_RE",
   |

F822 Undefined name `COMREFERENCE_RE` in `__all__`
  --> scripts\dev_tools\discovery\analyzer\vsto_patterns.py:20:5
   |
18 |     "PROGID_RE",
19 |     "INTEROP_USING_RE",
20 |     "COMREFERENCE_RE",
   |     ^^^^^^^^^^^^^^^^^
21 |     "EMBEDINTEROP_RE",
22 |     "INTEROP_ASSEMBLY_RE",
   |

F822 Undefined name `EMBEDINTEROP_RE` in `__all__`
  --> scripts\dev_tools\discovery\analyzer\vsto_patterns.py:21:5
   |
19 |     "INTEROP_USING_RE",
20 |     "COMREFERENCE_RE",
21 |     "EMBEDINTEROP_RE",
   |     ^^^^^^^^^^^^^^^^^
22 |     "INTEROP_ASSEMBLY_RE",
23 |     "DESCRIPTIONS",
   |

F822 Undefined name `INTEROP_ASSEMBLY_RE` in `__all__`
  --> scripts\dev_tools\discovery\analyzer\vsto_patterns.py:22:5
   |
20 |     "COMREFERENCE_RE",
21 |     "EMBEDINTEROP_RE",
22 |     "INTEROP_ASSEMBLY_RE",
   |     ^^^^^^^^^^^^^^^^^^^^^
23 |     "DESCRIPTIONS",
24 | )
   |

F822 Undefined name `DESCRIPTIONS` in `__all__`
  --> scripts\dev_tools\discovery\analyzer\vsto_patterns.py:23:5
   |
21 |     "EMBEDINTEROP_RE",
22 |     "INTEROP_ASSEMBLY_RE",
23 |     "DESCRIPTIONS",
   |     ^^^^^^^^^^^^^^
24 | )
   |

I001 [*] Import block is un-sorted or un-formatted
  --> tests\scripts\dev_tools\discovery\analyzer\test_stack_cli.py:27:5
   |
26 |   if TYPE_CHECKING:
27 | /     from collections.abc import Callable
28 | |     from pathlib import Path
29 | |     from scripts.dev_tools.discovery.analyzer.pipeline import AnalyzerFileSystem
   | |________________________________________________________________________________^
30 |
31 |       # Both console entry points share this callable shape.
   |
help: Organize imports

S102 Use of `exec` detected
   --> tests\scripts\dev_tools\discovery\analyzer\test_vsto_compatibility.py:103:5
    |
101 |     source = path.read_text(encoding="utf-8")
102 |     _block_optional(monkeypatch)
103 |     exec(
    |     ^^^^
104 |         compile(source, str(path), "exec"),
105 |         {"__name__": "isolated", "__file__": str(path)},
    |

B009 [*] Do not call `getattr` with a constant attribute value. It is not any safer than normal property access.
   --> tests\scripts\dev_tools\discovery\analyzer\test_vsto_compatibility.py:286:9
    |
284 |     _block_optional(monkeypatch)
285 |     with pytest.raises(AttributeError, match="Unknown legacy"):
286 |         getattr(vsto_patterns, "untrusted_module_name")
    |         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    |
help: Replace `getattr` with attribute access

E501 Line too long (112 > 88)
   --> tests\scripts\dev_tools\discovery\analyzer\test_vsto_office.py:311:89
    |
309 |             ('<COMReference Include="GenericLib"/>', "COMReference"),
310 |             (
311 |                 '<COMReference Include="GenericLib"><EmbedInteropTypes>true</EmbedInteropTypes></COMReference>',
    |                                                                                         ^^^^^^^^^^^^^^^^^^^^^^^^
312 |                 "COMReference",
313 |             ),
    |

Found 19 errors.
[*] 2 fixable with the `--fix` option.

```
