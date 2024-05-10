<!--
SPDX-License-Identifier: Apache-2.0
SPDX-FileCopyrightText: Canonical Ltd
-->
# How to use docker containers in a snap application

This guide illustrates how to build a snap application that leverages the
`docker` snap maintained and supported by Canonical, to bring containers to
IoT, server-side or desktop applications.

## Digression about security aspects

There are two possible avenues, one of which is explored in this guide:

1. Build a complete OCI container runtime into an application snap.
2. Integrate with an external snap, like `docker`, without bundling it. This is
   the approach we choose in this guide.

The key thing to understand is that the equivalent functionality is nearly the
same, there are significant security differences between the two approaches.

While anyone can rebuild the docker snap from source, not everyone is
immediately trusted with the *privileged interfaces* that are required for the
docker snap to function. Due to the nature of containers, some of the
permissions granted to the docker snap allow it to bypass elements of the
security sandbox. This is acceptable because the publisher is trusted and
because applications running inside such containers are further isolated with
the sandbox built by docker itself.

It is therefore a lot easier to create and publish a snap-based application
that talks to docker over the docker socket or uses docker command-line
interface than to build the runtime into the snap directly.

## Application skeleton

Let's look at a skeleton `snapcraft.yaml` file. Parts that are not relevant
to the topic are elided. A complete, working file is found in the corresponding
repository. 

``` yaml
base: core22
confinement: strict
apps:
  hello-docker:
    command: usr/bin/hello-docker
    environment:
      PATH: $SNAP/docker-snap/bin:$PATH
    plugs:
      - docker
      - docker-executables
plugs:
  docker:
    label: Access to the docker communication socket
  docker-executables:
    label: Access to the docker command-line utilities 
    interface: content
    content: docker-executables
    target: $SNAP/docker-snap
    default-provider: docker
```

Let's review the key parts here. We are looking at a strictly-confined snap
package. This type of package is portable across environments, working equally
in IoT-centric ubuntu-core as well as on most commonly used desktop and server
distributions.

The snap has one application, the `hello-docker` application. This application
has uses two snap interface plugs, one called `docker` and the other one called
`docker-executables`. The plugs are defined in more detail and we can see that
while `docker` is one of the built-in interfaces, `docker-executables` is an
example of the `content` interface. The content interface is further specified
to refer to content of type `docker-executables`. This is important as it has
to match what is provided by the `docker` snap available in the store.  

Plugs of the content interface have the `target` attribute which defines where
the corresponding content is made available. In this case it is the directory
`docker-snap` inside the read-only image of our application snap. It is
important that our application snap contains an empty directory with the same
name, so that when the docker snap is installed and the interfaces are
connected, we can get access to docker command-line tools.

The application has an environment variable that causes us to look for docker
executables in the $SNAP/docker-snap/bin sub-directory. This sub-directory will
only exist when the content interface is connected.

Lastly the `default-provider` field tells snapd that if the user does not have
any snap with a compatible interface installed, then upon installation of our
snap, the docker snap is automatically installed and connected.

## Principle of operation 

Our application snap should cleanly build with `snapcraft` and install with
`sudo snap install --dangerous ./hello-docker_1_all.snap`. On first install you
may see that the `core22` base snap and the `docker` snaps are automatically
installed. 

After install you will also need to ensure that there is a connection
relationship with your snap's docker-executables plug and the docker 
snap's docker-executables slot:

```
$ snap connect hello-docker:docker-executables docker:docker-executables
```

Let's explore the runtime environment that our application runs in:

```
$ snap run --shell hello-docker
$ cd $SNAP
$ ls docker-snap/bin
```

If everything is working fine, we should see the `docker` command-line tool,
among other executables. Since it is on `$PATH` we should be able to use
`docker` in our application script for whatever purpose we want.

## Caveats

- Discuss where container storage is 
- Discuss consequence of multiple snaps using the single docker snap
