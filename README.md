# DevOps Intern Final Assessment

[![CI](https://github.com/REPLACE_WITH_GITHUB_OWNER/devops-intern-final/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/REPLACE_WITH_GITHUB_OWNER/devops-intern-final/actions/workflows/ci.yml)

**Author:** Prem K  
**Submission date:** 2026-09-02

This repository builds a non-root NGINX static site, tests it in GitHub Actions, publishes it to GHCR, deploys it through Nomad, and ships its Docker logs to Grafana Loki.

```text
source ──> GitHub Actions (lint/build/test) ──> GHCR
                                               │
                                               v
                                      Nomad + Consul ──> NGINX
                                                            │ logs
                                                            v
                                                    Promtail ──> Loki ──> Grafana
```

## Prerequisites

Use Docker Engine 27.5.1, Nomad 1.9.6, Consul 1.20.2, and ShellCheck 0.10.0 (or the pinned GitHub Actions runners). A GitHub repository named `devops-intern-final`, GitHub Container Registry permission, and a Nomad cluster with Consul integration are required for the deployment stages.

## Quick Start

```sh
git clone https://github.com/REPLACE_WITH_GITHUB_OWNER/devops-intern-final.git
cd devops-intern-final
docker build --build-arg BUILD_SHA="$(git rev-parse --short HEAD)" -t devops-intern-final:local app
docker run -d --rm --name nginx-app -p 8080:8080 devops-intern-final:local
./scripts/healthcheck.sh http://localhost:8080
curl -i http://localhost:8080/
curl -i http://localhost:8080/healthz
docker compose -f monitoring/docker-compose.yaml up -d
nomad job validate -var='image_tag=REPLACE_WITH_SHA' nomad/nginx-app.nomad.hcl
nomad job run -var='image_tag=REPLACE_WITH_SHA' nomad/nginx-app.nomad.hcl
```

## 1. Source control

Create the public GitHub repository, work from `feature/initial-pipeline`, and use conventional commits such as `feat: add non-root nginx image`, `ci: add validation workflow`, and `docs: document deployment`. Open and self-review a PR into `main`, then tag its merged commit:

```sh
git tag -a v1.0.0 -m 'Release v1.0.0'
git push origin main --tags
```

The supplied `.gitignore` excludes IDE metadata and local monitoring data.

## 2. Linux scripts

```sh
./scripts/sysinfo.sh
./scripts/healthcheck.sh http://localhost:8080
shellcheck scripts/sysinfo.sh scripts/healthcheck.sh
```

Example health-check output: `OK: http://localhost:8080/healthz returned HTTP 200`.

## 3. Container image

```sh
docker build --build-arg BUILD_SHA=local-test -t devops-intern-final:local app
docker run -d --rm --name nginx-app -p 8080:8080 devops-intern-final:local
docker images devops-intern-final:local
curl -i http://localhost:8080/
curl -i http://localhost:8080/healthz
```

The pinned `nginx:1.27.5-alpine` image runs as the `nginx` user. The image exposes port 8080, includes an in-container health check, and injects `BUILD_SHA` into the page during build. Record the observed `docker images` size and curl output in the submission evidence after running these commands.

## 4. Continuous integration and delivery

The workflow runs lint, build, test, then publish. The test job starts the image and gates promotion on `scripts/healthcheck.sh`. On pushes to `main`, `GITHUB_TOKEN` has only `packages: write` for the publish job and sends both the immutable commit-SHA tag and `latest` to GHCR. Replace both `REPLACE_WITH_GITHUB_OWNER` strings before pushing.

## 5. Nomad

Replace `REPLACE_WITH_GITHUB_OWNER` in `nomad/nginx-app.nomad.hcl`, then run:

```sh
nomad job validate -var='image_tag=REPLACE_WITH_SHA' nomad/nginx-app.nomad.hcl
nomad job plan -var='image_tag=REPLACE_WITH_SHA' nomad/nginx-app.nomad.hcl
nomad job run -var='image_tag=REPLACE_WITH_SHA' nomad/nginx-app.nomad.hcl
nomad job status nginx-app
```

The job is a service with one Docker task, dynamic `http` port allocation to 8080, a Consul HTTP check, rolling update policy, restart policy, and rescheduling. It intentionally uses the requested 100 MHz CPU and 64 MB memory allocations.

## 6. Loki

Use the commands and LogQL verification in [monitoring/loki_setup.md](monitoring/loki_setup.md). Add the required Grafana Explore screenshot at `docs/screenshots/grafana-explore-nginx-404.png` and reference it here before submission:

`![Grafana Explore: NGINX 404 query](docs/screenshots/grafana-explore-nginx-404.png)`

## Troubleshooting

* **Port 8080 is in use:** stop the existing container or choose another host mapping, for example `-p 18080:8080`, then pass that port to the health check.
* **Docker daemon unavailable:** start Docker Desktop/Engine and verify with `docker info`; `sysinfo.sh` reports this condition without failing.
* **Nomad cannot pull GHCR image:** verify the owner placeholder is replaced, the SHA tag exists in GHCR, and configure registry credentials on Nomad clients for private packages.
* **No Loki logs:** generate HTTP traffic and inspect Promtail logs as described in the Loki setup guide.

## Known limitations

The repository cannot create a public GitHub repo, PR, release tag, GHCR package, Nomad allocation, or real Grafana screenshot without access to those external accounts and services. The owner placeholders and screenshot must be completed in that environment. The Grafana credentials are development defaults; production would use secret management, TLS, persistent managed storage, alerting, resource tuning, and a hardened network policy.
