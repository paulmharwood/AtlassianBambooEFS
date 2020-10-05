# AtlassianBambooEFS

## Background
The official Atlassian Bamboo image failed to work with AWS ECS, EFS, and __Fargate__.  The image was tried on EC2 backed containers, and this worked successfully.

When running the official image in EC2 containers, the mounted volume in EFS was created and written to (log files) as expected.  When switching to Fargate, the directory was not created and no files were produced.  This switch from EC2 to Fargate was the only difference in approach.

As the _Jira_ server image worked fine in Fargate with EFS, this image uses the same user and group id approach; specifying a linux UID and GID (2001).  The official image does not specify a UID or GID, and consequently UID and GID 1000 is used.  This appears to be related to the issue of no files being written in AWS EFS.

## Run
See this images docker hub page [here](https://hub.docker.com/r/paulmharwood/atlassian-bamboo-efs).  Refer to the official documentation [here](https://hub.docker.com/r/atlassian/bamboo-server) on how to run the image, as inputs are identical.

## Build
To build the docker image, specify the required bamboo version as an argument:
```
docker build --build-arg BAMBOO_VERSION=7.0.6 . 
```
