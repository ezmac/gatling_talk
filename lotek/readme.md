# LOad TEsting toolKit (LO-TEK)

Since it's now acceptable to pick letters in a name to make an acronym as long as it has meaning.

Lotek is a collection of quickly written "tools".  If you're decent in shell and docker, they'll save you half to a full hour.

But it's a good start on running load tests

## Assumptions:
 - you have docker in a relatively standard configuration.
 - you run linux or osx that will hopefully act like linux
 - you have chrome or chromium that will be found by 'which'
 - you use AWS ELB and have ruby



## Entrypoints:

`./gatling-recorder.sh` (starts gatling-recorder in docker and a chrome configured to use it as a proxy)

`./user_stats.rb -s ELB_LOG_FILE` use user_stats.rb to visualize how your users actually use your app!
  - sorts requests by users and time and prints them out in semi-digestible chunks. useful in making user scenarios
  - will also take `-d DIRECTORY` and analyze many log files

`./uri_stats.rb -s ELB_LOG_FILE` use to get stats on requests per second for paths ordered by frequency in a second.
  - useful in creating load profiles from ELB logs
  - will also take `-d DIRECTORY` and analyze many log files

user-files/ 
A very stripped down test showing how to use cuwa and feeders to test your application.  A single laptop running gatling on wifi can take down servers.  
  You have been warned.






## Refs and hat tips:

- https://gist.github.com/jibing57/ea180bfc3f7cb96e4a1fa67aa7a7c0c2
