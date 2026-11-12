# Security Policy

RegexMate is a local CLI and MCP server: patterns, subjects and test
cases are processed in-process, the MCP server speaks stdio (not a
socket), and the application's only network use is the self-update
channel. Reports are taken seriously and handled quickly.

## Reporting a vulnerability

Email **security@jrtx.site** (or open a GitHub security advisory on this
repository). Include reproduction steps, affected versions, and your
assessment of impact. You will get an acknowledgment within 72 hours.

Please do not open public issues for security problems.

## Scope

In scope:

- The regex evaluation engine surface: pattern parsing, matching,
  replacement, explanation and lint findings
  (`racket/core/regex-parser.rkt`, `racket/core/regex-engine.rkt`,
  `racket/core/ast.rkt`, `racket/core/linter.rkt`, `racket/core/tester.rkt`). Pathological patterns must not
  hang the process (the lint exists to flag catastrophic backtracking),
  and engine findings surfaced to an agent must not misrepresent the
  match result.
- Update trust: verification of the Ed25519-signed
  `update-manifest.json`, artifact digest/size checks against the
  signed manifest, and key handling (`racket/core/updater.rkt`,
  `scripts/make-update-manifest.sh`, `scripts/check-release-update-key.py`;
  key id `regexmate-2026-10`, trust root embedded in
  `racket/version.rkt`). The update channel resolves against the canonical
  `turlamai/regexmate` GitHub Releases; anything that would redirect it
  elsewhere is a bug.
- The MCP server surface (`racket/server/mcp.rkt`): a stdio server that
  exposes the seven tools to coding agents. It must not open network
  listeners, execute shell commands derived from pattern or subject
  input, or widen access beyond the declared tools.
- The host/backend boundary for the GUI: hosts render and install; the
  Racket backend (`app/backend.rkt`) decides. Crypto or policy sneaking
  into a native host is a bug.

Out of scope: the matching semantics of Racket's `pregexp` engine
itself (that is the upstream engine; our surface is validation,
explanation and lint around it), social engineering, and physical
access attacks.

## Design notes reviewers should know

- **The CLI owns no listening network port.** The MCP server reads and
  writes stdio; outbound network is limited to update checks and
  downloads against GitHub Releases.
- **Hosts never implement crypto.** The Ed25519 signature check, the
  SHA-256/size verification and the trust decision live in the Racket
  engine (Rivet's distribution layer, `rivet/distribution`); the
  native hosts only carry out steps the backend has already decided.
- **Updates and installer trust are different layers.** The updater
  verifies the Ed25519-signed manifest and the downloaded artifact's
  size and SHA-256 before any swap. The GUI deliberately has no
  in-app updater: the CLI swaps itself and restarts.
- The signed update feed **does not imply a publisher-signed
  installer**. macOS builds are ad-hoc signed (not notarized) and
  Windows installers carry no publisher code signature; releases
  publish a checked `SHA256SUMS` covering every versioned package plus
  the signed `update-manifest.json`, and CI publishes build
  provenance attestations. Do not represent the feed signature as an
  independently trusted publisher identity.
- Exit codes are part of the security posture: a failed verification
  aborts the update and the running version keeps working — never a
  silent fallback to unverified bytes.
- No telemetry, no accounts. Patterns and subjects stay on the
  machine and are never uploaded anywhere.

## Supported versions

Security fixes land on `main` first and ship with the next tagged
release. During the 0.x preview there is no LTS branch.
