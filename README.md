[![](https://images.microbadger.com/badges/image/keinos/alpine.svg)](https://microbadger.com/images/keinos/alpine "Get your own image badge on microbadger.com") ![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/keinos/alpine.svg) ![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/keinos/alpine.svg)

# Dockerfile of Alpine

**Vanilla Alpine docker image to trigger the "auto-build"** of other Docker Hub repository.

- Docker image: `keinos/alpine:latest` ([Old versions](https://hub.docker.com/r/keinos/alpine/tags))
- GitHub: <https://github.com/KEINOS/Dockerfile_of_Alpine>
- Docker Hub: <https://hub.docker.com/r/keinos/alpine>

## Usage

1. Use `keinos/alpine:latest` in your Dockerfile 'FROM' instruction.

    ```yaml
    FROM keinos/alpine:latest

    # do something ...
    ```

2. Create a repository on Docker Hub and push your files.
    - If your files are on GitHub then link to GitHub's repository.
3. Edit "Configure Automated Builds" at Docker Hub's "build" tab.
4. Enable the configuration below:
    - Build configurations
      - EPOSITORY LINKS
        - "Enable for Base Image" -> Enable

