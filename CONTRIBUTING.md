# Contributing to RegexMate

Thank you for looking under the hood. RegexMate is source-available
(BUSL-1.1, see [LICENSE](LICENSE)): by submitting a pull request you
agree your contribution is licensed under BUSL-1.1, with the same MIT
change date (2030-10-22) as the rest of the Work.

## Ground rules

1. **The schema is the contract.** `rivet-schema.json` describes the
   versioned JSON surface every command speaks; validate any change to
   it with `raco rivet schema check rivet-schema.json --json`. If the
   JSON shape changes, bump the schema version, update the generator
   and the tests in the same commit, and say why.
2. **Exit codes never lie.** 0 = ok, 1 = invalid regex, 2 = usage
   error, 3 = valid pattern with zero matches / zero replacements.
   Identical argv must produce identical stdout/stderr/exit codes on
   every platform. Never weaken a requirement in
   `rivet-acceptance.rktd` to make a change green.
3. **The six version sources agree.** `VERSION`, `info.rkt`,
   `version.rkt`, `rivet.rktd` and the shields.io badges in both
   READMEs must state the same version —
   `racket scripts/check-version.rkt` enforces it, and a tagged
   release additionally requires the git tag and a `## [x.y.z]`
   CHANGELOG section to match.
4. **Bilingual is one product.** User-facing engine strings live in
   `core/i18n.rkt` (en default, zh opt-in); an English string added or
   changed gets its Chinese counterpart in the same commit.
5. **Fail honestly.** A failed update verification aborts the update
   and the running version keeps working. Report what failed and what
   to do next. No silent fallbacks.
6. **Tests pin contracts.** If you change behavior a test covers,
   change the test in the same commit and say why.

## Before you push

```bash
raco make main.rkt run-tests.rkt          # compile engine + tests
racket run-tests.rkt                      # core contract tests
racket scripts/check-version.rkt          # six-source version gate
raco rivet schema check rivet-schema.json --json
bash scripts/smoke.sh                     # CLI smoke
```

These mirror the CI `test` job. First-time setup installs the pinned
Rivet and crypto packages (see [AGENTS.md](AGENTS.md)). If you touch
`macos-host/`, `windows/` or `linux/`, say whether you were able to
build that host locally — those legs compile in their own CI jobs.

## Areas that especially want help

- Lint findings: more deterministic static checks for
  catastrophic-backtracking shapes, with precise evidence
- Keeping the Chinese user path in lockstep with the English one
  (`README.zh-CN.md`, `docs/USER-GUIDE.zh-CN.md`) and the zh engine
  strings

## Reporting issues

Include: OS + version, RegexMate version (`regexmate --version`),
installation shape (installer / portable archive / standalone exe /
`raco pkg` checkout), steps to reproduce, and the exact argv plus the
JSON error when applicable. Security issues go through
[SECURITY.md](SECURITY.md), not public issues.
