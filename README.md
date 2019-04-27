# Dockerfile of Alpine

Simple Alpine docker image to trigger the "auto-build" of other docker images.

- Docker image: `keinos/alpine:latest`

If this image was used in 'FROM' instruction of one's Dockerfile then auto-build of one's image must run when this image was updated.
