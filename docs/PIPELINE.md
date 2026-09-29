# CI/CD Pipeline and Security Automation

Workflow file: `.github/workflows/devsecops.yml`

## Pipeline stages

| # | Job | Tool | Gate rule | Report |
|---|---|---|---|---|
| 1 | Build and Test | npm / grunt | tests must pass | log |
| 2 | SAST | Semgrep (`p/security-audit`, `p/nodejs`, `p/owasp-top-ten`) | any finding fails | `semgrep-report` artifact (SARIF) |
| 3 | SCA | `npm audit` | HIGH or CRITICAL fails | `npm-audit-report` artifact (JSON) + job summary table |
| 4 | Secrets | Gitleaks (full git history) | any leak fails | Gitleaks summary |
| 5 | Container | Trivy on the built Docker image | fixable HIGH or CRITICAL fails | `trivy-report` (SARIF) and `sbom-cyclonedx` (SBOM) artifacts |
| 6 | DAST | OWASP ZAP baseline against `docker compose up` (port 4000) | FAIL-level alert or scan error fails; warnings are reported | `zap-report` artifact (HTML + JSON) |
| 7 | Security Gate Summary | GitHub Actions | fails if any stage failed | job summary table |

## Design decisions

* **Least privilege**: workflow default is `contents: read`. Only SAST and container jobs get `security-events: write`.
* **Report first, gate second**: each scanner writes a report artifact before the step that can fail, so evidence exists even on a red run.
* **Switchable gates**: run the workflow manually (Actions tab > Run workflow) and set `enforce_gates` to `false` to see findings without blocking.
* **Pinned tooling**: Trivy is pinned to a release instead of `@master`. Dependabot keeps npm, Docker and Actions versions current.
* **SARIF upload** to the GitHub Security tab is best-effort. Private repos need GitHub Advanced Security for it, so it never blocks the build.

## Known findings the gates are expected to catch

NodeGoat is intentionally vulnerable. `npm audit` reports outdated components such as `mongodb`, `swig`, `underscore`, `marked` and `forever`, and the Dockerfile uses the end-of-life `node:12-alpine` base image. A red SCA or Trivy stage is therefore the pipeline working as designed, and is documented in `evidence/pipeline/`.

## Security automation extras

* `scripts/security-scan.sh [all|sca|sast|secrets|container]` runs the CI checks locally and saves output to `scan-results/`.
* `.githooks/pre-commit` blocks commits containing secrets. Enable once with `git config core.hooksPath .githooks`.
* `.github/dependabot.yml` opens weekly update PRs for npm, Docker and Actions.
* `.github/pull_request_template.md` adds a security checklist to every PR.
* The SBOM (CycloneDX) is generated from the built image on every run.

## Threat model mapping

| Stage | STRIDE threats it helps detect |
|---|---|
| SAST | T2 injection (vuln-02 style `eval`), T3/T4 access control patterns |
| SCA + SBOM | vulnerable and outdated components |
| Secrets | credential exposure (information disclosure) |
| Container scan | vulnerable base image and OS packages |
| DAST | runtime issues: missing headers, cookie flags, exposed info |

## Local checks before pushing

```bash
npm ci
npm audit --audit-level=high
docker build -t nodegoat-devsecops:local .
docker run --rm aquasec/trivy:latest image --severity HIGH,CRITICAL --ignore-unfixed nodegoat-devsecops:local
docker run --rm -v "$PWD:/src" semgrep/semgrep semgrep scan --config p/nodejs --config p/owasp-top-ten /src
docker run --rm -v "$PWD:/repo" zricethezav/gitleaks:latest detect --source /repo
docker compose up --build
```

## Evidence checklist

1. Green or red run of all six jobs (Actions summary page)
2. Security Gate Summary table
3. `npm audit` count table and downloaded report
4. Trivy table output from the gate step
5. Semgrep result
6. Gitleaks result
7. One run with `enforce_gates = false` showing findings without blocking
