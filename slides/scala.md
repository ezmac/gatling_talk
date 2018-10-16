# Keeping it below 💯

## Scala and gatling strings and interpolations

 - s prefixed `s"${cuwa_token}"`: local scope interpolation.
 - unprefixed `"${cuwa_token}"`:  Session scope; follows "user" or "scenario"; use if value comes from a feeder
 - triple quotes `s"""cuwl2famethod="DUO"; cuwltgttime="${cuwa_time}"; CUWALastWeblogin=0; cuweblogin2=${cuwa_token}; ClassRoster=${auth_key}"""`
      useful to not escape quotes. Can be s prefixed or not.
 - scala is strongly typed and functional.  Matching types is essential
