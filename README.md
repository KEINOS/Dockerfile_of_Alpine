[![](https://images.microbadger.com/badges/image/keinos/alpine.svg)](https://microbadger.com/images/keinos/alpine "Get your own image badge on microbadger.com") ![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/keinos/alpine.svg) ![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/keinos/alpine.svg)

# Dockerfile of Alpine

**Vanilla Alpine docker container to trigger the "auto-build"** of other Docker Hub repository.

- Docker image: `keinos/alpine:latest` ([Old versions](https://hub.docker.com/r/keinos/alpine/tags))
  - BaseImage: `alpine:latest`
  - Time Zone: `Asia/Tokyo`
- GitHub: <https://github.com/KEINOS/Dockerfile_of_Alpine>
- Docker Hub: <https://hub.docker.com/r/keinos/alpine>

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

- 2019/04/27: At this moment the Base image trigger is not working.
