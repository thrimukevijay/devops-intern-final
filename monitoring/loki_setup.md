# Loki setup and verification

Start the stack from the repository root:

```sh
docker compose -f monitoring/docker-compose.yaml up -d
docker run -d --name nginx-app -p 8080:8080 devops-intern-final:local
curl -i http://localhost:8080/missing
```

Open Grafana at <http://localhost:3000> (default credentials: `admin` / `admin`), add Loki at `http://loki:3100`, then use Explore.

Promtail applies `job=docker`, `container=<container name>`, and `service=<Compose service when present>`. For Docker CLI containers, the `container` label identifies `nginx-app`; that is the meaningful workload label when no Compose service exists.

Queries used:

```logql
{job="docker", container="nginx-app"}
{job="docker", container="nginx-app"} |~ "HTTP/[0-9.]+\" 404 "
```

The second query returns the deliberate request to `/missing` with status 404. Capture that Explore result as `../docs/screenshots/grafana-explore-nginx-404.png` before submission.

Troubleshooting observed during setup:

* If Promtail cannot read Docker logs, ensure Docker Desktop is running and the Docker socket mount is available to Linux containers.
* If Explore shows no streams, wait briefly after generating traffic, then inspect `docker compose -f monitoring/docker-compose.yaml logs promtail`.
* If Grafana cannot reach Loki, use `http://loki:3100` inside the Compose network—not `localhost`.
