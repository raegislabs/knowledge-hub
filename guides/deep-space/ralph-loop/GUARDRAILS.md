# Guardrails — Example from a Real Session

## Project Constraints
- Python 3.8+ with async/await patterns
- Ruff linting (line-length 100), black formatting
- mypy strict mode type checking
- pytest with markers: slow, integration, regression, performance
- All new code under the package namespace (`src/<package>/`)
- Keep git subprocess execution async via `asyncio.create_subprocess_exec`
- No GitPython or blocking shell wrappers

## Phase Constraints
- PLAN: No code changes, only design docs and scratchpad
- TEST: Only test files, tests must FAIL before implementation (RED)
- IMPLEMENT: Minimal code to pass tests (GREEN), no test modifications
- REVIEW: Read-only analysis, structured output only
- FIX: Address review findings, no new features, no test deletions

## Safety
- Never commit secrets, API keys, or .env files
- Never push to remote repositories (unless story explicitly requires it)
- Never run destructive git commands
- Follow existing codebase patterns and conventions
