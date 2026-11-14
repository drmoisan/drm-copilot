"""Python-native surface analyzers for the documentation estate (issue 1031).

The package is run only by run_docs_python_native.py, which the PowerShell adapter
DocsAnalyzerPythonNative.psm1 starts through the command-context InvokeProcess seam. It
parses consumer sources with ast.parse and never imports or executes them; it emits raw
facts (kind, path, declaration, line span) and PowerShell computes every identifier and
digest.
"""
