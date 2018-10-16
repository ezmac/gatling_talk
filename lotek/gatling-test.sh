#!/bin/bash

# use this for hand writing simulations; compilation is cached when the container stays running.
docker run -it -p 8000:8000 -v $PWD/user-files:/opt/gatling/user-files -v $PWD/results:/opt/gatling/results/ --entrypoint bash gatling
