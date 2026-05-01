# Security Policy

## Supported versions

StemRuntimeSDK follows semantic versioning. Security fixes are applied to the latest released version.

Consumers should track the latest release via Swift Package Manager.

## Reporting a vulnerability

**Please do not file public issues for security vulnerabilities.** Public disclosure before a fix is available puts every consumer at risk.

Report vulnerabilities privately via either channel:

1. **GitHub private vulnerability reporting** — the preferred channel. Open the repository's *Security* tab and click *"Report a vulnerability"*. GitHub forwards the report privately to the maintainer.
2. **Email** — `vkrychun@stemjson.com` with the subject line `[SECURITY] StemRuntimeSDK`.

Include in your report:

- Affected SDK version(s).
- A clear description of the vulnerability and its potential impact.
- A minimal reproduction — a StemJSON payload, host-app code, or configuration that triggers the issue.
- The iOS / Xcode / Swift toolchain versions used to reproduce.
- Any proof-of-concept evidence.
- Your disclosure timeline preferences (see below).

## What to expect

- **Acknowledgement** on a best-effort basis, typically within a few business days.
- **Assessment** — severity classification and confirmation whether the report constitutes a vulnerability.
- **Fix timeline** — communicated after assessment; depends on severity and complexity.
- **Coordinated disclosure** — a public disclosure date is agreed with the reporter; disclosure by default coincides with the fixed release.
- **Credit** — researchers are credited in the CHANGELOG and GitHub security advisory unless they request otherwise.

## Scope

**In scope:**
- Memory-safety or type-safety vulnerabilities exploitable via malformed StemJSON payloads.
- Expression-language parser flaws leading to crash, memory corruption, or unauthorised state access.
- Network-layer issues in the built-in `remote` repository — TLS bypass, request-smuggling, credential exposure.
- `secured` repository / Keychain handling flaws.
- Any path allowing a malicious StemJSON payload to escape its module's state or context isolation.

**Out of scope:**
- Security issues in applications *built with* the SDK that result from your own configuration or integration choices (developer responsibility, per §3 and §10 of the LICENSE).
- Denial-of-service vulnerabilities caused by pathological-but-valid StemJSON payloads (e.g., deeply nested structures). These are bug reports, not security issues.
- Third-party dependencies used by the SDK — report those upstream; we will follow their advisory cadence.
- Suitability of the SDK for critical applications (healthcare, financial, military, aerospace, nuclear, emergency services, autonomous vehicles, critical infrastructure) — see §8 of the LICENSE. The SDK is not designed or certified for those categories.

## No bug bounty

This policy is not a paid bug bounty program. Credit in the CHANGELOG and in any GitHub security advisory is the only acknowledgement offered. No monetary rewards are paid for submissions.

## Safe harbour

Good-faith security research performed in accordance with this policy is welcome. The maintainer will not pursue legal action against researchers who:

- Make a good-faith effort to avoid privacy violations, service disruption, and data destruction.
- Report vulnerabilities privately before disclosing publicly.
- Give reasonable time for a fix to be released.

Research that violates applicable law, destroys data, exfiltrates personally identifiable information, or targets live consumer applications without authorisation is not protected.

---

For non-security support (bug reports, feature requests, questions), see [SUPPORT.md](SUPPORT.md).
