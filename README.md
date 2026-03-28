# Apache Jena Fuseki Docker

[![Docker Pulls](https://img.shields.io/docker/pulls/psiwon/jena-fuseki-docker)](https://hub.docker.com/r/psiwon/jena-fuseki-docker)
[![Docker Image Size](https://img.shields.io/docker/image-size/psiwon/jena-fuseki-docker)](https://hub.docker.com/r/psiwon/jena-fuseki-docker)
[![License](https://img.shields.io/github/license/siwonpawel/jena-fuseki-docker)](LICENSE)
[![CI](https://img.shields.io/github/actions/workflow/status/siwonpawel/jena-fuseki-docker/docker-image.yaml?label=CI)](https://github.com/siwonpawel/jena-fuseki-docker/actions/workflows/docker-image.yaml)

Docker image for [Apache Jena Fuseki](https://jena.apache.org/documentation/fuseki2/) — a SPARQL 1.1 server backed by the Apache Jena TDB RDF triple store.

**Docker image:** [`psiwon/jena-fuseki-docker`](https://hub.docker.com/r/psiwon/jena-fuseki-docker)  
**Source:** [GitHub](https://github.com/siwonpawel/jena-fuseki-docker) · [Dockerfile](Dockerfile)  
**Base image:** `eclipse-temurin:21-alpine` → `alpine:3.21.2` (with jlink-optimized minimal JRE)  
**Platforms:** `linux/amd64`, `linux/arm64`

## Disclaimer

This repository contains modified files derived from the official Apache Jena Docker tooling published in the Apache Jena source tree at [jena-fuseki2/jena-fuseki-docker](https://github.com/apache/jena/tree/f8ab05095fe532460b77e7d355fc27934eee9edd/jena-fuseki2/jena-fuseki-docker).

Those files were adapted to support this repository's build, packaging, and publishing workflow for the Docker Hub image `psiwon/jena-fuseki-docker`.

This repository is based on Apache Jena materials distributed under the Apache License 2.0. It is an independent derivative work and is not an official Apache Software Foundation release.

## Supported Versions

Only Apache Jena `6.0.0` and newer are supported by this repository and its published Docker images.

Versions older than `6.0.0` are out of scope for this image and are not documented or tested here.

## Overview

This image runs Apache Jena Fuseki in **full server mode with the Web UI enabled by default** (`serverui` mode). The browser-based management interface is available at `http://localhost:3030/` immediately after starting the container — no extra flags needed.

Key design decisions:

- **Web UI on by default** — runs `FusekiServerUICmd` out of the box, giving you the full Fuseki dataset management console.
- **Minimal Alpine image** — the final image is based on `alpine:3.21.2` with a custom JRE built using `jlink`, minimising the image footprint.
- **Maven Central download** — the Fuseki server JAR is downloaded from [Maven Central](https://repo1.maven.org/maven2/org/apache/jena/jena-fuseki-server/) and SHA1-verified at build time.
- **Multi-platform** — published for both `linux/amd64` and `linux/arm64`.
- **Switchable server mode** — the `MAIN` environment variable lets you choose among four Fuseki operating modes without rebuilding.

## Features

- Apache Jena Fuseki Web UI enabled by default
- SPARQL 1.1 query, update, and Graph Store Protocol endpoints
- TDB1 and TDB2 triple-store backends
- Lightweight Alpine base with `jlink`-optimized minimal JRE (Eclipse Temurin 21)
- SHA1-verified JAR download from Maven Central
- Multi-platform: `linux/amd64` and `linux/arm64`
- Persistent storage via Docker volumes (`/fuseki/databases`, `/fuseki/logs`)
- Four configurable server modes via `MAIN` environment variable
- Extensible classpath via `/fuseki/extra/`

## Quick Start

```bash
docker run -p 3030:3030 psiwon/jena-fuseki-docker:6.0.0 --mem /ds
```

The Fuseki Web UI will be available at http://localhost:3030/.

## Pulling the Image

Tags correspond to the Apache Jena release version. Only tags for supported versions (`6.0.0+`) should be considered valid for use:

```bash
docker pull psiwon/jena-fuseki-docker:6.0.0
```

## Running the Container

### Default mode — Fuseki with Web UI

Start Fuseki with an in-memory dataset at `/ds`:

```bash
docker run -p 3030:3030 psiwon/jena-fuseki-docker:6.0.0 --mem /ds
```

Start Fuseki with a persistent TDB2 dataset:

```bash
mkdir -p databases/DB2

docker run -p 3030:3030 \
  --mount type=bind,src="$PWD/databases",dst=/fuseki/databases \
  psiwon/jena-fuseki-docker:6.0.0 \
  --tdb2 --update --loc databases/DB2 /ds
```

### Change the exposed port

```bash
docker run -p 8080:3030 psiwon/jena-fuseki-docker:6.0.0 --mem /ds
```

### Run without Web UI

Switch to headless mode using the `MAIN` environment variable:

```bash
docker run -p 3030:3030 -e MAIN=main psiwon/jena-fuseki-docker:6.0.0 --mem /ds
```

### Run in the background

```bash
docker run -d --name fuseki -p 3030:3030 \
  --mount type=bind,src="$PWD/databases",dst=/fuseki/databases \
  psiwon/jena-fuseki-docker:6.0.0 \
  --tdb2 --update --loc databases/DB2 /ds
```

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `MAIN` | `serverui` | Server mode — see [Server Modes](#server-modes) |
| `JVM_ARGS` | *(unset)* | JVM arguments passed directly to `java` (e.g. `-Xmx4g -Xms1g`) |
| `JAVA_HOME` | `/opt/java-minimal` | Path to the bundled minimal JRE |
| `JENA_VERSION` | *(set at build time)* | Fuseki version baked into the image |
| `FUSEKI_DIR` | `/fuseki` | Fuseki installation directory |
| `FUSEKI_JAR` | *(set at build time)* | Filename of the server JAR |

### Override JVM heap size

```bash
docker run -p 3030:3030 \
  -e JVM_ARGS="-Xmx8g -Xms2g" \
  psiwon/jena-fuseki-docker:6.0.0 --mem /ds
```

## Server Modes

The `MAIN` environment variable controls which Fuseki entry point is used:

| `MAIN` value | Java class | Description |
|---|---|---|
| `serverui` *(default)* | `FusekiServerUICmd` | Full server with Web UI and admin work area |
| `main` | `FusekiMainCmd` | Headless server (no UI, no admin area); includes Prometheus metrics and Shiro authentication |
| `server-plain` / `plain` | `FusekiServerPlainCmd` | Plain server with Fuseki modules, no UI; includes Prometheus and Shiro |
| `basic` | `FusekiBasicCmd` | Minimal server with no additional features |

## Data Persistence

Fuseki data is stored in `/fuseki/databases` inside the container. Without a volume mount, all data is lost when the container stops.

### Named Docker volume (recommended)

```bash
docker volume create fuseki-data

docker run -d --name fuseki -p 3030:3030 \
  --volume fuseki-data:/fuseki/databases \
  psiwon/jena-fuseki-docker:6.0.0 \
  --tdb2 --update --loc databases/DB2 /ds
```

### Bind mount to host directory

```bash
mkdir -p /path/to/data/databases

docker run -d --name fuseki -p 3030:3030 \
  --mount type=bind,src=/path/to/data/databases,dst=/fuseki/databases \
  psiwon/jena-fuseki-docker:6.0.0 \
  --tdb2 --update --loc databases/DB2 /ds
```

> **Note:** The `fuseki` user inside the container runs as UID/GID 1000. If you use a bind mount, ensure the host directory is owned or writable by UID 1000:
> ```bash
> chown -R 1000 /path/to/data/databases
> ```

### Persist logs

Logs are written to `/fuseki/logs`. To persist them:

```bash
docker run -d --name fuseki -p 3030:3030 \
  --volume fuseki-data:/fuseki/databases \
  --mount type=bind,src="$PWD/logs",dst=/fuseki/logs \
  psiwon/jena-fuseki-docker:6.0.0 --mem /ds
```

## Container Layout

| Path | Contents |
|---|---|
| `/opt/java-minimal` | jlink-optimized minimal JRE (Eclipse Temurin 21) |
| `/fuseki` | Fuseki installation root |
| `/fuseki/jena-fuseki-server-*.jar` | Server JAR (downloaded from Maven Central at build time) |
| `/fuseki/entrypoint.sh` | Container entry point |
| `/fuseki/log4j2.properties` | Logging configuration |
| `/fuseki/databases/` | Volume for persistent database storage |
| `/fuseki/logs/` | Volume for log files |
| `/fuseki/extra/` | Optional: additional JARs added to the classpath on startup |

### Adding JARs to the classpath

Mount a directory to `/fuseki/extra`. Any JARs placed there are automatically added to the server classpath at startup.

## Docker Compose

The included [docker-compose.yaml](docker-compose.yaml) mounts `./databases` and `./logs` automatically. Edit the `command:` section for your Fuseki arguments, then:

```bash
# Build (JENA_VERSION is required)
docker-compose build --build-arg JENA_VERSION=6.0.0

# Temporary run — in-memory dataset
docker-compose run --rm --service-ports fuseki --mem /ds

# Persistent TDB2 dataset
mkdir -p databases/DB2
docker-compose run --rm --name MyServer --service-ports fuseki \
  --tdb2 --update --loc databases/DB2 /ds
```

To add `--update` access, include it in the command:

```bash
docker-compose run --rm --name MyServer --service-ports fuseki \
  --tdb2 --update --loc databases/DB2 /ds
```

## Building from Source

```bash
# Single-platform build
docker build --build-arg JENA_VERSION=6.0.0 -t psiwon/jena-fuseki-docker:6.0.0 .

# Multi-platform build with Docker Buildx (push required for multi-platform)
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --build-arg JENA_VERSION=6.0.0 \
  -t psiwon/jena-fuseki-docker:6.0.0 \
  --push .
```

> The `JENA_VERSION` build argument is **required**. Omitting it causes the build to fail with an explicit error.

> Only `JENA_VERSION=6.0.0` or newer is supported.

## Upgrading

Because data lives in an external volume, upgrading only requires swapping the container:

```bash
docker pull psiwon/jena-fuseki-docker:5.4.0
docker stop fuseki
docker rm fuseki
docker run -d --name fuseki -p 3030:3030 \
  --volume fuseki-data:/fuseki/databases \
  psiwon/jena-fuseki-docker:5.4.0 \
  --tdb2 --update --loc databases/DB2 /ds
```

## Managing the Container

```bash
# View logs
docker logs fuseki

# Follow logs in real time
docker logs -f fuseki

# Stop
docker stop fuseki

# Restart (remembers port and volume config)
docker restart fuseki
```

## Fuseki Command-Line Reference

Any [Fuseki server argument](https://jena.apache.org/documentation/fuseki2/fuseki-server.html) can be passed after the image name:

```bash
# In-memory dataset (not persistent)
docker run -p 3030:3030 psiwon/jena-fuseki-docker:6.0.0 --mem /ds

# TDB1 dataset, read-only
docker run -p 3030:3030 \
  --mount type=bind,src="$PWD/databases",dst=/fuseki/databases \
  psiwon/jena-fuseki-docker:6.0.0 --loc databases/DB /ds

# TDB2 dataset, updatable
docker run -p 3030:3030 \
  --mount type=bind,src="$PWD/databases",dst=/fuseki/databases \
  psiwon/jena-fuseki-docker:6.0.0 --tdb2 --update --loc databases/DB2 /ds

# Using a Fuseki configuration file
docker run -p 3030:3030 \
  --mount type=bind,src="$PWD/config",dst=/config \
  psiwon/jena-fuseki-docker:6.0.0 --config /config/fuseki.ttl
```

See the [Fuseki documentation](https://jena.apache.org/documentation/fuseki2/fuseki-server.html) for the full list of options.

## Comparison with stain/jena-fuseki

| Feature | `psiwon/jena-fuseki-docker` | `stain/jena-fuseki` |
|---|---|---|
| Web UI | **Enabled by default** | Optional |
| Final base image | Alpine 3.21.2 | Alpine 3.19 |
| JRE | Custom minimal JRE via `jlink` (Temurin 21) | `eclipse-temurin:21-jre-alpine` |
| JAR source | Maven Central (SHA1 verified) | Apache mirrors / archive.apache.org (SHA512 verified) |
| Admin password management | Not managed by image — configure via CLI or config file | Auto-generated or `-e ADMIN_PASSWORD=...` |
| Shiro authentication | Not configured by image | Pre-configured via `shiro.ini` |
| Server mode switching | `MAIN` env var (4 modes) | Fixed |
| Platforms | `linux/amd64`, `linux/arm64` | `linux/amd64`, `linux/arm64` |

## License

Different components in this image carry different licenses:

| Component | License |
|---|---|
| Dockerfile and scripts in this repository | [Apache License 2.0](LICENSE) |
| Apache Jena Fuseki (`/fuseki/`) | [Apache License 2.0](https://jena.apache.org/getting_involved/index.html) |
| Eclipse Temurin JDK (used at build time only) | GPL 2.0 with Classpath Exception |
| Alpine Linux (base image) | [Various open source licenses](https://alpinelinux.org) |

## Resources

- [Apache Jena Fuseki documentation](https://jena.apache.org/documentation/fuseki2/)
- [Fuseki Main server documentation](https://jena.apache.org/documentation/fuseki2/fuseki-server.html)
- [Fuseki configuration reference](https://jena.apache.org/documentation/fuseki2/fuseki-configuration.html)
- [Apache Jena users mailing list](https://jena.apache.org/help_and_support/index.html)
- [Docker Hub image](https://hub.docker.com/r/psiwon/jena-fuseki-docker)
- [GitHub repository](https://github.com/siwonpawel/jena-fuseki-docker)

## Version Notes

- **Supported baseline**: This repository supports Apache Jena `6.0.0` and newer only.
- Older Apache Jena versions are not tested or documented in this repository.
