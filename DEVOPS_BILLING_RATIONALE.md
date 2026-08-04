# DevOps as a Service — Client Billing Rationale

## TL;DR

Every Wisemen client project ships on top of a shared library of 30+ reusable GitHub Actions workflows and 20+ production-hardened Kubernetes modules, plus self-hosted infrastructure (Turborepo cache, SigNoz observability, Zitadel auth, Matomo analytics, database backups) that Wisemen operates and pays for. Without this, each project team would need roughly 3-6 months of dedicated DevOps engineering before writing a single line of business logic — and would then need to keep patching, upgrading, and rebuilding it forever. The monthly DevOps fee funds the ongoing maintenance, security patching, multi-cloud portability, and parallel-version support (`@v1`, `@v2`, `main`) that keeps every client project shipping safely.

## What Every Client Project Gets For Free (Today)

Every new Wisemen repository inherits the following on day one via a single `uses: wisemen-digital/devops-github-actions/.github/workflows/xxx.yml@v2` line and shared Kustomize module imports:

- **30+ reusable CI/CD workflows** covering build, test, lint, containerize, promote, deploy, and PR preview across Vue, Nuxt, Node/NestJS, Laravel/PHP, and infra config. *Alternative:* every project team writes and hardens their own YAML — typically 4-8 weeks of engineering per repo before the first deploy works reliably.
- **20+ production-hardened Kubernetes Kustomize modules** including `api-node`, `api-php`, `web-vue`, `web-nuxt`, `cms-directus`, `cms-payload`, `redis`, `typesense`, `pgbouncer`, `nats`, `benthos`, `database-backup`, `zitadel`, `go-feature-flag`, `matomo`, `otel-collector-infra`, `otel-collector-proxy`, `otel-auth-proxy`, `signoz-otel-collector`, `common`, `network`. *Alternative:* every project reinvents probes, rolling-update strategies, ExternalSecrets wiring, ingress annotations, and resource limits — and pays for the first production outage that teaches them what those defaults should be.
- **Shared self-hosted infrastructure** — Turborepo remote cache at `cache.turbo.internal.appwi.se`, SigNoz observability at `signoz.internal.appwi.se`, Zitadel identity provider, Matomo analytics, `ghcr.io/wisemen-digital/*` container images (test-nats, database-backup, matomo), and self-hosted GitHub Actions runner pools. *Alternative:* clients pay per-seat SaaS bills (LaunchDarkly, Auth0, Datadog, Vercel remote cache) or run their own copies.
- **Multi-cloud deploy targets already wired** — one `vendor: azure|digitalocean|scaleway` input in `docker-build-and-deploy.yml`, `docker-promote-to-environment.yml`, `infra-k8s-rollout.yml`, and `infra-s3-rollout.yml` switches which cloud is used. *Alternative:* every project locks itself into one cloud, or spends weeks rebuilding pipelines when migrating.
- **Multiple pinned major versions (`v1`, `v2`, `main`)** maintained in parallel so a client project pinned to `@v1` doesn't get forced onto a new contract when Wisemen ships breaking improvements on `@v2`. *Alternative:* every upgrade is a coordinated fleet-wide migration on Wisemen's schedule, not the client's.
- **Battle-tested-by-the-fleet defaults** — every workflow and module has been hardened against real production incidents on other client projects (Directus's non-obvious `/server/health` startup delay, Payload's request-blocking-by-worker footgun, Laravel Reverb's nginx-ingress WebSocket snippet, Zitadel's gRPC ModSecurity rule 949110, tail-sampling's single-replica constraint). *Alternative:* every project rediscovers each gotcha the hard way in production.

## Developer Time Saved Per Project

**A new project starting from scratch would need roughly 12-20 weeks of dedicated DevOps engineering before writing the first line of business logic. With Wisemen's reusable pipelines and modules, that drops to 2-5 days of project-specific overlay configuration.**

Concrete line items from the inventory:

- **Container build + multi-cloud deploy pipeline** (`docker-build-and-deploy.yml`, `docker-promote-to-environment.yml`): ~2-3 weeks saved per project — three separate cloud auth flows, GHA layer caching, monorepo image-variant matrix, multi-arch builds, and safe re-tag-based promotion.
- **Node.js backend CI** (`node-build-and-test.yml`): ~2-4 weeks saved per backend — six-service integration test matrix (Postgres/PostGIS, MySQL, MSSQL, NATS, Redis, Typesense) with correct health-check probes and JUnit reporting.
- **Kubernetes rollout pipeline** (`infra-k8s-rollout.yml`, `infra-k8s-preview.yml`): ~3-5 weeks saved — changed-paths detection, per-env matrix rollout, three cloud auth paths, rendered-manifest diff PR comments.
- **Node.js app runtime module** (`api-node`): ~1-2 weeks saved — split HTTP/worker/scheduler/WebSocket/OTel-reporter pods with correct probes, ExternalSecrets wiring, and rolling-update tuning.
- **Zitadel identity provider module**: ~3-4 weeks saved — hardened self-hosted OIDC/OAuth2 with rate-limited password-reset ingress, gRPC ModSecurity tuning, lockout policy, secret-store integration.
- **Observability stack** (`otel-collector-infra` + `otel-collector-proxy` + `otel-auth-proxy`): ~2-3 weeks saved — cluster-wide logs/metrics/traces collection with tail-based sampling, JWT-authed OTLP ingestion, per-project ingestion keys.
- **Database backup module**: ~3-5 days saved — hourly S3-backed backups with dead-man's-switch monitoring, running the Wisemen-maintained `ghcr.io/wisemen-digital/database-backup` image.
- **Infra config linting** (`infra-lint.yml`): ~3-5 days saved — env-diff across environments (catches the "staging works, prod is missing an env var" bug) plus AWS CORS XSD validation.

Ongoing PR-level savings compound on top of the initial build: Turborepo cache hits alone save 3-8 minutes per PR run on Vue projects and 2-5 minutes on Node projects, ESLint cache saves another 1-2 minutes, and Laravel composer cache saves 1-2 minutes per Laravel PR — across dozens of PRs per project per week fleet-wide.

## Shared Infrastructure We Host & Pay For

- **Turborepo remote cache** (`cache.turbo.internal.appwi.se`) — self-hosted Turborepo cache server (compute + storage + TLS + auth) referenced by every Turbo-aware workflow via `TURBO_API`/`TURBO_TEAM`/`TURBO_TOKEN`. Without it, every CI run rebuilds from scratch and every local developer waits minutes longer per command. A cache outage would slow every Wisemen project's CI simultaneously.
- **SigNoz observability backend** (`signoz.internal.appwi.se`) — ClickHouse cluster + query service + frontend + retention + dashboards + alert rules. Without it, every client would need Datadog/New Relic (per-host SaaS billing) or self-host their own.
- **Zitadel identity provider** — Wisemen sysops-managed OIDC/OAuth2 root account, upgrade cadence across every client instance, and the ExternalSecrets `shared-secret-store` that fronts it. Replaces Auth0/Cognito recurring per-MAU costs across the fleet.
- **Matomo analytics** — central shared Matomo instance (PHP + MariaDB + PVC + backups) that most client projects proxy to via the `link-to-shared` ExternalName Service component. GDPR-friendly replacement for Google Analytics; monthly upgrade cadence with security advisories.
- **`ghcr.io/wisemen-digital/*` container images** — Wisemen-published and Wisemen-patched images including `test-nats` (preconfigured JetStream image used in Node CI), `database-backup` (pg_dump + Scaleway CLI + S3 client, used by every project's hourly backup CronJob), and `matomo`. CVE patching and version bumps live centrally.
- **Backup storage** — every client's Postgres is dumped hourly to S3-compatible object storage with a heartbeat monitor that alerts on missed runs. Compliance/DR baseline that would otherwise be one of the top production risks per project.
- **Self-hosted GitHub Actions runners** — pools referenced via `vars.RUNNER_DEFAULT` and `vars.RUNNER_INFRA` (the infra runner has network reach to private Kubernetes API endpoints so cluster rollouts and previews work at all). Falls back to `ubuntu-latest` when not needed.
- **Wisemen-owned composite Actions** — `wisemen-digital/devops-ga-lint-yaml`, `wisemen-digital/devops-ga-changed-paths-filter`, and the internal `docker/setup`, `docker/validate-and-generate-inputs`, `infra/k8s/rollout`, `infra/k8s/apply`, `infra/s3/apply` composites that encapsulate every cloud's auth/kubeconfig/rollout logic.
- **Shared secret stores and PATs** — `K8S_MODULES_SECRET` PAT that grants CI access to the private `sysops-k8s-modules` repo, the shared `scwsm-secret` Scaleway Secret Manager credentials used by every ExternalSecret, and the `TURBO_TOKEN` distributed to every client repo.
- **Network primitives** — the `sysops@wisemen.digital` Let's Encrypt ACME account tied to the `letsencrypt-prod` ClusterIssuer, plus the pinned ingress-nginx `controller-v1.13.2` reference and cloud-specific load-balancer annotation patches (Azure/DigitalOcean/Scaleway) used by every cluster.

## Reusable Engineering We Maintain

**CI — build, test and lint (10 workflows).** `web-build-and-test.yml`, `nuxt-build-and-test.yml`, `node-build-and-test.yml`, `node-jest-build-and-test.yml`, `laravel-build-and-test.yml`, `lint.yml`, `lint-yaml-and-docker.yml`, `infra-lint.yml`, `lint-infra.yml` (deprecation shim), plus the Turborepo cache client wiring. Clients get lint, typecheck, build, unit test, E2E Playwright (in Microsoft's official container), JUnit reporting, and Turbo/pnpm/composer caching without writing YAML. Ongoing load: quarterly `actions/*` version bumps, Playwright container tag bumps, six-service test-image CVE tracking, `lorisleiva/laravel-docker` external image reviews.

**CI/CD — container build & multi-cloud K8s deploy (9 workflows).** `docker-build-and-deploy.yml` and `docker-promote-to-environment.yml` (vendor-agnostic) plus six legacy per-cloud deprecation wrappers (`workflow-build-and-deploy-azure.yml`, `-digitalocean.yml`, `-scaleway.yml` and matching promote wrappers) that keep older client repos working. Ongoing load: tracking `docker/build-push-action` major versions, `cache-from: type=gha` behavior changes, and each cloud CLI's auth/API drift.

**K8s rollout & PR preview (6 workflows).** `infra-k8s-rollout.yml` and `infra-k8s-preview.yml` (vendor-agnostic) plus per-cloud deprecation shims (`k8s-workflow-rollout-to-azure.yml`, `-digitalocean.yml`, `-scaleway.yml`, `k8s-preview.yml`). Reviewers get the exact rendered Kustomize diff as a sticky PR comment before merge — catches accidental prod changes across the fleet. Ongoing load: `kubectl`/`kustomize` output changes, changed-paths filter action, thollander comment-action bumps.

**Static site & package publishing (6 workflows).** `infra-s3-rollout.yml` with S3 CORS XSD validation (plus per-cloud deprecation shims for DO and Scaleway), `node-publish-package.yml` (tag-driven npm + workspace filter + GitHub Release), `node-publish-docs.yml` (GitHub Pages with OIDC), and `laravel-legacy-deploy.yml` (SSH/rsync path for non-containerized PHP with maintenance-mode gating and correct rsync excludes).

**Kubernetes app runtime modules (4 modules).** `api-node` (HTTP + worker + scheduler + websockets + otel-metrics-reporter + node-doc-processor + custom-api components), `api-php` (init-container migrations + scheduler + queue + websockets), `web-nuxt`, `web-vue`. Every project inherits split-workload deployments, correct probes, ExternalSecrets, rolling updates, and consistent labels for platform tooling.

**Headless CMS modules (2 modules).** `cms-directus` (with the non-obvious `/server/health` vs `/server/ping` probe split and 100s startup tolerance for schema migrations) and `cms-payload` (with pre-baked web/worker split — the pattern most teams discover only after a production incident).

**Data infrastructure modules (6 modules).** `redis` (tuned config, ACLs, PVC, LRU eviction, 5m graceful shutdown), `typesense` (hardened non-root pod, resource-scale-up component), `pgbouncer` (transaction pooling with graceful preStop drain, ExternalSecret creds), `nats` (StatefulSet with JetStream persistence), `benthos` (streaming/ETL runtime scaffold), `database-backup` (hourly CronJob with dead-man's-switch heartbeat). Ongoing load: pinned image version bumps, `edoburu/pgbouncer:latest` drift risk, Typesense reindex-on-major-upgrade planning, pg_dump-major-matches-Postgres-major tracking on the backup image.

**Identity & feature flags (2 modules).** `zitadel` (three-tier rate-limited ingress including 1rps/5rpm on password reset, gRPC ModSecurity rule 949110 disabled, lockout policy, secrets from `shared-secret-store`) and `go-feature-flag` (Postgres retriever via pgbouncer, split traffic/monitoring ports, OTel wiring). Ongoing load: Zitadel ships every 2-4 weeks with occasional breaking config keys or DB migrations.

**Observability & analytics (5 modules).** `otel-auth-proxy` (oauth2-proxy validating Zitadel JWTs in front of OTLP HTTP), `otel-collector-infra` (DaemonSet + cluster-collector with filelog/hostmetrics/kubeletstats/k8sattributes/probabilistic sampling), `otel-collector-proxy` (tail-based sampling keeping all errors + slow traces + 10% probabilistic), `signoz-otel-collector` (legacy variant), and `matomo` (with `link-to-shared` component). Ongoing load: `otelcol-contrib` schema drift across minor versions is the highest-churn area.

**Platform primitives (2 modules).** `common` (nginx ingress skeleton with cert-manager `letsencrypt-prod` annotations, 600s proxy timeouts, unlimited body size, www redirect, plus a Scaleway Secret Manager `SecretStore` component) and `network` (cert-manager install + `letsencrypt-prod` ClusterIssuer + pinned ingress-nginx `controller-v1.13.2` with per-cloud proxy-protocol/forwarded-headers patches). Highest ongoing churn in the module library because ingress-nginx and cert-manager both release frequently with occasional breaking annotation renames.

## Version Support Commitment

Wisemen maintains three active branches in parallel — `main` (trunk / next major, 30 workflows), `v2` (current stable line, 13 workflows), and `v1` (previous stable line, 13 workflows). Every client project pins its `uses:` refs to `@v1` or `@v2`, which means one client can stay on `v1` while another adopts `v2` — the migration happens on the client's schedule, not Wisemen's.

This is a real, measurable commitment, not a marketing claim:

- `v1` and `v2` share a merge base at `d921b40`; `v1` has 13 commits unique to it and `v2` has 8 unique — genuine parallel patching, not one line being a stale mirror.
- `v1` received 40 workflow-touching commits in the last 6 months (86 in the last year), most recently on 2026-07-02. Recent examples include "Add environment scope to validate and generate matrix", "Laravel: add support for testing & deploying front-end", "All: bump action versions", "Add turbo caching".
- `v2` received 35 workflow-touching commits in the last 6 months (81 in the last year), most recently on 2026-06-17. Recent examples include "Docker: ensure we stop build if invalid env", "Docker: fix tag using old env. input", "Docker build & deploy: automatically calculate target environment".
- The two lines have diverged meaningfully: `v2`'s `docker-build-and-deploy.yml` auto-calculates the target environment from git context whereas `v1` requires it as an explicit input; `laravel-build-and-test.yml` is 151 lines on `v1` vs 126 on `v2`; `project-build-and-test.yml` is 284 lines on `v1` vs 233 on `v2`.

**What this means for the client:** dropping `v1` support would leave every `@v1`-pinned repo without security patches, Dependabot action-version rollups, Kubernetes rollout fixes, and Laravel/Docker bug fixes. Migrating to `@v2` is a real code change — v2 removes inputs, auto-calculates environments, and has a different Laravel/project pipeline contract — so each caller workflow must be reviewed. Parallel maintenance is what lets clients defer that migration until they choose. Most agencies simply do not offer this.

## Ongoing Operational Work (Monthly)

- **Security patching & CVE tracking** across every base image (Alpine, PostgreSQL, PostGIS, MySQL, MSSQL, Redis 7, Typesense 26, NATS 2, Node, PHP, Zitadel, Matomo, ingress-nginx, cert-manager, oauth2-proxy, PgBouncer, benthos/redpanda, otelcol-contrib) and every wrapped GitHub Action.
- **Kubernetes version upgrades** — API-group deprecations (`apps/v1`, `batch/v1`, `networking.k8s.io/v1`, `external-secrets.io/v1`), kubelet API changes affecting `kubeletstats`, admission-webhook tweaks in cert-manager, and coordinated rollouts across every client cluster.
- **Dependency bumps** — quarterly `actions/checkout`, `setup-node`, `upload-artifact`, `download-artifact`, `pnpm/action-setup`, `docker/build-push-action`, `softprops/action-gh-release`, `thollander/actions-comment-pull-request`, `shimataro/ssh-key-action` rollups, plus Dependabot "Bump the all-actions group" PRs on both `v1` and `v2`.
- **Cloud provider API/pricing changes** — Azure OIDC service-principal changes, DigitalOcean `doctl` and load-balancer annotation drift, Scaleway CLI and `scw-loadbalancer-*` annotation drift, Scaleway Secret Manager credential rotation.
- **Ingress-nginx & cert-manager releases** — the fastest-churn upstreams. Annotation risk-level changes, snippet-annotation lockdowns, CRD version bumps, ACME endpoint changes, plus periodic controller image bumps validated against every cloud.
- **`otelcol-contrib` schema drift** — frequent breaking changes to receiver/processor config across minor versions require regression-testing the whole observability pipeline.
- **Incident response & fleet-wide fixes** — when one client hits a rollout bug or CI regression, the fix is backported across every affected version branch so the rest of the fleet benefits before they hit it.
- **Cost optimization reviews** — right-sizing resource requests/limits, storage class tiering for backups, Turbo cache eviction tuning, self-hosted runner utilization.
- **On-call for shared infrastructure** — Turborepo cache, SigNoz backend, Zitadel, Matomo, database-backup heartbeat monitor, self-hosted runners, and internal DNS (`*.internal.appwi.se`).
- **Multi-version backporting** — every non-cosmetic fix has to be applied to both `v1` and `v2`, and sometimes `main`. The recent "All: bump action versions" and "Laravel: try to fix version mismatch on upgrades" commits are examples.
- **Secret rotation & credential distribution** — `TURBO_TOKEN`, `K8S_MODULES_SECRET`, per-cloud OIDC/service-principal creds, `scwsm-secret`, Zitadel root, ingestion keys — coordinated across every client repo.
- **Deprecation lifecycle management** — the eight legacy per-cloud wrapper workflows (`workflow-build-and-deploy-*`, `workflow-promote-to-environment-*`, `s3-workflow-rollout-to-*`, `k8s-workflow-rollout-to-*`) and `node-jest-build-and-test.yml` all need to stay in sync with their replacements until every consumer migrates.

## Why Monthly (vs one-time)

- **CVEs and security advisories don't stop.** Zitadel ships every 2-4 weeks, ingress-nginx and cert-manager release monthly, Matomo has monthly security advisories, `otelcol-contrib` and the six test-service images (Postgres, MySQL, MSSQL, NATS, Redis, Typesense) all need continuous patching.
- **Upstream breaking changes are constant.** GitHub Actions deprecate versions (`actions/upload-artifact` v3 sunset was fleet-wide), Kubernetes API groups get removed, cloud CLIs change flags, oauth2-proxy alpha config schemas shift, `otelcol-contrib` renames processor keys between minor releases.
- **Cloud provider deprecations.** Azure, DigitalOcean, and Scaleway all change load-balancer annotations, auth flows, and CLI behavior on their own schedule. The vendor-agnostic pipelines absorb the churn so client projects don't have to.
- **Preview environments must always work.** `infra-k8s-preview.yml` posts a rendered Kustomize diff on every PR — that's a benefit clients only get if the underlying `changed-paths-filter` action, self-hosted runner pool, and `K8S_MODULES_SECRET` PAT are all healthy every day.
- **Rollout safety comes from continuous testing.** Every workflow change is tested on internal projects before it moves from `main` to `v2` to `v1` — a discipline that requires the underlying pipelines to be continuously exercised across the fleet.
- **Parallel version maintenance is a recurring commitment.** As shown in the version audit, 40+ commits landed on `v1` in the last 6 months. That's monthly patch work indefinitely, not a one-time effort.

## Suggested Line Items for Invoice

1. **Shared CI/CD pipeline access & maintenance** — 30+ reusable GitHub Actions workflows (build/test/lint/containerize/promote/deploy/preview) for Vue, Nuxt, Node, Laravel, and infra config.
2. **Kubernetes module library access & upgrades** — 20+ production-hardened Kustomize modules covering app runtimes, headless CMS, data infrastructure, identity, feature flags, observability, and platform primitives.
3. **Multi-cloud portability** — Azure / DigitalOcean / Scaleway build, deploy, promote, S3 rollout, and Kubernetes rollout pipelines maintained as one vendor-agnostic surface.
4. **Turborepo remote cache (self-hosted)** — shared build cache at `cache.turbo.internal.appwi.se` speeding up CI and local development across every project.
5. **Observability backend (self-hosted SigNoz)** — traces, logs, metrics, dashboards and retention at `signoz.internal.appwi.se`, with JWT-authed OTLP ingestion via the shared `otel-auth-proxy`.
6. **Identity provider (self-hosted Zitadel)** — hardened OIDC/OAuth2 with rate-limited auth ingresses, replacing per-MAU SaaS auth costs.
7. **Analytics (shared self-hosted Matomo)** — GDPR-friendly web analytics available via the `link-to-shared` ExternalName Service component.
8. **Database backup service** — hourly S3-backed Postgres dumps via the Wisemen-maintained `ghcr.io/wisemen-digital/database-backup` image with dead-man's-switch heartbeat monitoring.
9. **Multi-version workflow support (`@v1`, `@v2`, `main`)** — parallel maintenance and backporting so client projects upgrade on their own schedule.
10. **Self-hosted GitHub Actions runners & shared secrets** — runner pools (`RUNNER_DEFAULT`, `RUNNER_INFRA`), private container images (`ghcr.io/wisemen-digital/*`), and shared PATs/secrets (`K8S_MODULES_SECRET`, `TURBO_TOKEN`, `scwsm-secret`).
11. **Ingress, TLS, and secret-store platform** — cert-manager + Let's Encrypt (`sysops@wisemen.digital` account), pinned ingress-nginx `controller-v1.13.2` with per-cloud proxy-protocol patches, Scaleway Secret Manager `SecretStore` wiring.
12. **Ongoing security patching, dependency bumps, and incident response** — CVE tracking, Kubernetes API upgrades, cloud API/annotation drift, and fleet-wide fixes backported across active version branches.
