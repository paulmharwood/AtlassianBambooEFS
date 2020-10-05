## AtlassianBambooEFS

The official Atlassian Bamboo image failed to work with AWS ECS, Fargate, and EFS.  The image was tried on EC2 backed containers, and this seemed to work fine, therefore the assumption is Fargate is the difference here.

When running the official image in EC2 containers, the mounted volume in EFS was created and written to (log files) as expected.  When switching to Fargate, the directory was not created and no files produced.  This switch from EC2 to Fargate was the only difference in approach.

As the Jira server image worked fine in Fargate with EFS, this image uses the user id and group id approach in the docker file that Jira uses.  It specifies user and group 2001 for Linux, instead of relying on the container creating its own 1000 user and group (which does not seem to work).

Refer to the official documentation [here](https://hub.docker.com/r/atlassian/bamboo-server) on how to run the image, as inputs are identical.