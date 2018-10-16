#!/bin/bash

docker run -it -p 8000:8000 -v $PWD/templates:/opt/gatling/user-files -v $PWD/results:/opt/gatling/results/ gatling
