# P4-T3 bounded repair delta

Timestamp: 2026-10-19T05-08
Command: Compare original reviewed and repaired declaration bytes
EXIT_CODE: 0
Output Summary: One production module changed and one regression test module added; all twelve other candidate paths and twelve predecessor caller/fixture paths remain exact.

```diff
--- reviewed/packages/discovery-runtime/src/drm_copilot_discovery/analyzer/csharp_declarations.py
+++ repaired/packages/discovery-runtime/src/drm_copilot_discovery/analyzer/csharp_declarations.py
@@ -26,6 +26,30 @@
 )


+class _ScanWork:
+    """Bound aggregate lookahead across one declaration scan without external I/O.
+
+    Construct once from the token count and share with every prefix helper.
+    remaining tracks deterministic token visits; consume rejects excessive work
+    before another traversal or slice. Only this private counter is mutated.
+    """
+
+    def __init__(self, token_count: int) -> None:
+        """Initialize a linear budget from nonnegative int token_count; return None."""
+        self.remaining = max(32, token_count * 4)
+
+    def consume(self, count: int = 1) -> None:
+        """Charge nonnegative int count token visits; return None, mutate counter.
+
+        Raises SourceScanError before exceeding the aggregate traversal budget.
+        """
+        if count > self.remaining:
+            raise SourceScanError(
+                "source-work-limit", "C# declaration scan limit exceeded."
+            )
+        self.remaining -= count
+
+
 def _detection(
     path: str,
     anchor: Token,
@@ -50,12 +74,15 @@
     )


-def _generic(tokens: tuple[Token, ...], position: int) -> tuple[int, int]:
-    """Return (arity, end index) after optional generic parameters; pure.
+def _generic(
+    tokens: tuple[Token, ...], position: int, work: _ScanWork
+) -> tuple[int, int]:
+    """Return (arity, end index) after optional generic parameters, without I/O.

     tokens (tuple[Token,...]) and position (int) identify the token after a name.
-    SourceScanError rejects an unterminated parameter list. Nested type/attribute
-    syntax is counted lexically, without constraint or semantic evaluation.
+    work (_ScanWork) charges shared token visits. SourceScanError rejects an
+    unterminated list or exhausted budget. Only the private counter is mutated;
+    nested type/attribute syntax is counted without semantic evaluation.
     """
     if position >= len(tokens) or tokens[position].value != "<":
         return 0, position
@@ -64,6 +91,7 @@
     start = position
     # Only outer commas divide parameters; nested generic arguments do not.
     while position < len(tokens):
+        work.consume()
         value = tokens[position].value
         if value == "<":
             depth += 1
@@ -77,16 +105,20 @@
     raise SourceScanError("source-declaration", "Unterminated generic declaration.")


-def _namespace(path: str, tokens: tuple[Token, ...], index: int) -> Detection | None:
-    """Read a literal dotted namespace after int index in immutable tokens; pure.
+def _namespace(
+    path: str, tokens: tuple[Token, ...], index: int, work: _ScanWork
+) -> Detection | None:
+    """Read a literal dotted namespace after int index in immutable tokens.

     path (str) supplies provenance. Returns Detection or None for a nonmatching
-    fragment; namespace scope/alias qualification remains unresolved.
+    fragment; namespace scope/alias qualification remains unresolved. work
+    (_ScanWork) is charged or raises SourceScanError; no caller data is mutated.
     """
     position = index + 1
     names: list[Token] = []
     # Alternate names and dots; whitespace and physical lines are already retained.
     while position < len(tokens) and tokens[position].identifier:
+        work.consume()
         names.append(tokens[position])
         position += 1
         if position >= len(tokens) or tokens[position].value != ".":
@@ -118,14 +150,22 @@
     )


-def _type(path: str, tokens: tuple[Token, ...], index: int) -> Detection | None:
+def _type(
+    path: str, tokens: tuple[Token, ...], index: int, work: _ScanWork
+) -> Detection | None:
     """Read type/record name and generic arity from typed tokens; no I/O.

     path (str) and index (int) anchor a known type keyword. Returns Detection or
-    None; SourceScanError rejects an unterminated generic declaration.
+    None; work (_ScanWork) charges lookahead. SourceScanError rejects an
+    unterminated generic declaration or exhausted budget; only work is mutated.
     """
     kind = tokens[index].value
     position = index + 1
+    # Contextual record can be an ordinary variable/type name in executable text.
+    if kind == "record" and (
+        index and tokens[index - 1].value not in {"{", "}", ";", "]", *_MODIFIERS}
+    ):
+        return None
     if (
         kind == "record"
         and position < len(tokens)
@@ -135,21 +175,30 @@
         position += 1
     if position >= len(tokens) or not tokens[position].identifier:
         return None
-    arity, _ = _generic(tokens, position + 1)
+    arity, end = _generic(tokens, position + 1, work)
+    # A contextual keyword needs an observed declaration header after its name.
+    if kind in {"record", "record_struct"} and (
+        end >= len(tokens) or tokens[end].value not in {"(", "{", ":", ";", "where"}
+    ):
+        return None
     extra: tuple[tuple[str, str | int], ...] = (("generic", arity),) if arity else ()
     return _detection(path, tokens[index], tokens[position], "type", kind, extra)


-def _callable_name(tokens: tuple[Token, ...], start: int, end: int) -> Token | None:
-    """Select the literal name before a signature boundary; pure.
+def _callable_name(
+    tokens: tuple[Token, ...], start: int, end: int, work: _ScanWork
+) -> Token | None:
+    """Select the literal name before a signature boundary with bounded lookahead.

     tokens (tuple[Token,...]), start/end (int) bound a declaration prefix. Returns
-    Token or None; skips generic method parameters without resolving their types.
+    Token or None; skips generic parameters without resolving their types. work
+    (_ScanWork) is charged; SourceScanError rejects excess aggregate lookahead.
     """
     position = end - 1
     depth = 0
     # Generic suffixes belong to the name before '<', not the final parameter.
     while position >= start:
+        work.consume()
         value = tokens[position].value
         if value == ">":
             depth += 1
@@ -162,17 +211,19 @@


 def _event_or_delegate(
-    path: str, tokens: tuple[Token, ...], index: int
+    path: str, tokens: tuple[Token, ...], index: int, work: _ScanWork
 ) -> Detection | None:
     """Extract an event/delegate declaration name from bounded lexical tokens.

     path (str), tokens (tuple[Token,...]) and index (int) identify its keyword.
     Returns Detection or None; anonymous delegates/function pointers are omitted.
-    No type binding, scope inference, I/O or mutation is performed.
+    work (_ScanWork) is charged; SourceScanError rejects excessive traversal.
+    No type binding, scope inference, I/O or caller-data mutation is performed.
     """
     keyword = tokens[index].value
+    # Anonymous delegate bodies/signatures and pointers have no declared name.
     if keyword == "delegate" and (
-        index + 1 >= len(tokens) or tokens[index + 1].value == "*"
+        index + 1 >= len(tokens) or tokens[index + 1].value in {"*", "{", "("}
     ):
         return None
     stop = {";", "=", "{"} if keyword == "event" else {"("}
@@ -180,15 +231,16 @@
     depth = 0
     # Generic commas and type punctuation remain part of the declaration prefix.
     while position < len(tokens):
+        work.consume()
         value = tokens[position].value
-        if depth == 0 and (value in stop or value in {"}", ";"}):
+        if depth == 0 and (value in stop or value in {"{", "}", ";"}):
             break
         if value == "<":
             depth += 1
         elif value == ">":
             depth -= 1
         position += 1
-    name = _callable_name(tokens, index + 1, position)
+    name = _callable_name(tokens, index + 1, position, work)
     if name is None or name.start == tokens[index + 1].start:
         return None
     kind = "event_declaration" if keyword == "event" else "delegate"
@@ -202,12 +254,14 @@
     end: int,
     declaring_type: str,
     boundary: str,
+    work: _ScanWork,
 ) -> Detection | None:
-    """Infer a simple directly enclosed member from a declaration prefix; pure.
+    """Infer a directly enclosed member from a bounded declaration prefix.

     path/type/boundary (str), tokens (tuple[Token,...]) and start/end (int) retain
     lexical placement. Returns Detection or None. Attributes/modifiers are
-    omitted; complex operators/indexers and initializer expressions are not bound.
+    omitted; complex operators/indexers and initializers are not bound. work
+    (_ScanWork) charges name lookahead or raises SourceScanError; no external I/O.
     """
     # Remove attribute brackets before interpreting punctuation in a member prefix.
     depth = 0
@@ -226,7 +280,7 @@
         for token in prefix
     ):
         return None
-    name = _callable_name(tuple(prefix), 0, len(prefix))
+    name = _callable_name(tuple(prefix), 0, len(prefix), work)
     if name is None:
         return None
     # A return/type prefix must precede the member name, except for constructors.
@@ -253,20 +307,20 @@


 def _members(
-    path: str, tokens: tuple[Token, ...], types: dict[int, str]
+    path: str, tokens: tuple[Token, ...], types: dict[int, str], work: _ScanWork
 ) -> list[Detection]:
     """Infer member candidates only inside directly enclosing lexical type braces.

     path (str), immutable tokens and types (keyword-offset/name mapping) originate
     from one masked text. Returns list[Detection]. Does not resolve conditional
     compilation or malformed grammar; every result stays inferred and unbound.
+    work (_ScanWork) bounds prefix allocation or raises SourceScanError; no I/O.
     """
     scopes: list[str | None] = []
     pending: str | None = None
     start = 0
     square = 0
     result: list[Detection] = []
-    work = 0
     # Brace placement prevents ordinary method-local declarations becoming members.
     for index, token in enumerate(tokens):
         value = token.value
@@ -283,12 +337,8 @@
             and square == 0
             and value in {"(", "{", ";", "=", "=>"}
         ):
-            work += index - start
-            if work > max(32, len(tokens) * 4):
-                raise SourceScanError(
-                    "source-work-limit", "C# member scan limit exceeded."
-                )
-            member = _member(path, tokens, start, index, scopes[-1], value)
+            work.consume(index - start)
+            member = _member(path, tokens, start, index, scopes[-1], value, work)
             if member is not None:
                 result.append(member)
         # New type bodies consume their pending declaration; other blocks hide locals.
@@ -317,6 +367,7 @@
     binding, preprocessor evaluation or runtime/behavior claims are performed.
     """
     tokens = tokenize_csharp(strip_comments_and_strings(text), max_tokens=max_tokens)
+    work = _ScanWork(len(tokens))
     result: list[Detection] = []
     types: dict[int, str] = {}
     # Inspect every textual declaration, including multiline and same-line forms.
@@ -325,11 +376,11 @@
         if previous in {".", "?.", "::", ":", "record"}:
             continue
         if token.value == "namespace":
-            candidate = _namespace(path, tokens, index)
+            candidate = _namespace(path, tokens, index, work)
         elif token.value in _TYPE_WORDS:
-            candidate = _type(path, tokens, index)
+            candidate = _type(path, tokens, index, work)
         elif token.value in {"event", "delegate"}:
-            candidate = _event_or_delegate(path, tokens, index)
+            candidate = _event_or_delegate(path, tokens, index, work)
         else:
             continue
         if candidate is not None:
@@ -337,7 +388,7 @@
             if candidate.detection_kind == "type":
                 types[token.start] = candidate.symbol
     if include_members:
-        result.extend(_members(path, tokens, types))
+        result.extend(_members(path, tokens, types, work))
     return tuple(
         sorted(
             result,
```

The new regression file is retained separately with its exact hash in the freeze manifest.
