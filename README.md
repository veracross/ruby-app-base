# ruby-app-base

A Docker image suitable as a "base" image for Ruby apps.

## Tag Versions

Review this repo's [branch list](https://github.com/veracross/ruby-app-base/branches) for available configurations. Each branch corresponds to an image tag on [Docker Hub](https://hub.docker.com/repository/docker/veracross/ruby-app-base/tags?page=1&ordering=last_updated).

### Rebuilding an existing image tag

Click "Trigger Build" on the list of Docker Hub's Automated Build rules, found [here](https://hub.docker.com/repository/docker/veracross/ruby-app-base/builds). Pushing to a matching branch will also cause that image tag to be rebuilt.

### Updating an existing image tag

To update an image, push a commit to the related branch.

### Adding a new image tag

To add a new image tag, push a new branch with the appropriate branch name format. The branch name will be applied as the image tag per Docker Hub's Automated Build rules, found [here](https://hub.docker.com/repository/docker/veracross/ruby-app-base/builds). Typically, this would be in the format of `ruby-$major_version.$minor_version`.
