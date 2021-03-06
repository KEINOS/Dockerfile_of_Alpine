[![](https://images.microbadger.com/badges/image/keinos/alpine.svg)](https://microbadger.com/images/keinos/alpine "Get your own image badge on microbadger.com") ![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/keinos/alpine.svg) ![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/keinos/alpine.svg)

# Dockerfile of Alpine

```bash
docker pull keinos/alpine:latest
```

The above image tag works on the architecture below:

- AMD64 (AMD/Intel/x86_64)
- ARM v6 (RaspberryPi ZeroW + Buster)
- ARM v7 (RaspberryPi 3 + Buster)
- ARM64

## Info

- Image info:
  - BaseImage: `alpine:latest` / `arm32v6/alpine:latest`
  - Alpine Version: [View available versions](https://hub.docker.com/r/keinos/alpine/tags))
  - Time Zone: `Asia/Tokyo`
- Repositories:
  - Image: https://hub.docker.com/r/keinos/alpine @ Docker Hub
  - Source: https://github.com/KEINOS/Dockerfile_of_Alpine @ GitHub

## Usage

1. Specify `keinos/alpine:latest` as a base image in the 'FROM:' directive in your Dockerfile of the source repository.

    ```yaml
    FROM keinos/alpine:latest

    # do something ...
    ```

2. Create a repository on Docker Hub and push your files.
    - If your files are on GitHub then link to GitHub's repository.

3. "Manage Repository" and "Configure Automated Builds" at Docker Hub's "Builds" tab.

4. Enable the configuration below:
    - Build configurations
      - REPOSITORY LINKS
        - "Enable for Base Image" -> Enable

5. Then, whenever the `keinos/alpine:latest` is updated, the build in your repsitory on Docker Hub should be triggered as well.
