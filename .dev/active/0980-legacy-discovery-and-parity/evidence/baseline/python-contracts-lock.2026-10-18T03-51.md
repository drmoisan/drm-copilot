# python-contracts-lock

Timestamp: 2026-10-18T03-51
Command: poetry check --lock
EXIT_CODE: 0
Output Summary: If you want to define multiple readmes, you should define them in [tool.poetry] and add 'readme' to [project.dynamic].; Warning: [tool.poetry.license] is deprecated. Use [project.license] instead.; Warning: [tool.poetry.authors] is deprecated. Use [project.authors] instead.; Warning: Defining console scripts in [tool.poetry.scripts] is deprecated. Use [project.scripts] instead. ([tool.poetry.scripts] should only be used for scripts of type 'file').

Working directory: .
Started: 2026-10-18T03:51:47.427758+00:00
Duration seconds: 0.668
Phase: P0 baseline; no implementation repair is performed by this command.

## Captured output

```text
Warning: [tool.poetry.name] is deprecated. Use [project.name] instead.
Warning: [tool.poetry.version] is set but 'version' is not in [project.dynamic]. If it is static use [project.version]. If it is dynamic, add 'version' to [project.dynamic].
If you want to set the version dynamically via `poetry build --local-version` or you are using a plugin, which sets the version dynamically, you should define the version in [tool.poetry] and add 'version' to [project.dynamic].
Warning: [tool.poetry.description] is deprecated. Use [project.description] instead.
Warning: [tool.poetry.readme] is set but 'readme' is not in [project.dynamic]. If it is static use [project.readme]. If it is dynamic, add 'readme' to [project.dynamic].
If you want to define multiple readmes, you should define them in [tool.poetry] and add 'readme' to [project.dynamic].
Warning: [tool.poetry.license] is deprecated. Use [project.license] instead.
Warning: [tool.poetry.authors] is deprecated. Use [project.authors] instead.
Warning: Defining console scripts in [tool.poetry.scripts] is deprecated. Use [project.scripts] instead. ([tool.poetry.scripts] should only be used for scripts of type 'file').
```
