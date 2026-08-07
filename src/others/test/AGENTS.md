# AGENTS

This folder contains Stormworks microcontroller Lua code used for in-game logic and simulation.

## Naming conventions

- Constants must use `CONSTANT_CASE` (uppercase letters with underscores).
  - Example: `MAX_INTERVAL`, `ROCKET_ACL`, `ALT_INTERVAL`
- Variables and functions must use `camelCase`.
  - Example: `local2World`, `screenConnection`, `errorSumPre`

## Style guidance for AI agents

- Preserve existing Lua style and idioms in the current files.
- Prefer `local` variables inside functions when the variable does not need to be global.
- Do not rename unrelated symbols unless the user explicitly requests a refactor.
- When introducing new constants, use names that describe the value in uppercase underscore form.
- When introducing new variables or functions, use descriptive camelCase names.

## Notes

- This folder is part of a multi-root workspace containing many Stormworks Lua projects.
- There is no existing project-level automation file detected in this folder, so keep changes limited to the current script and its immediate dependencies.
