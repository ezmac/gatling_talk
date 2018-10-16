import scala.concurrent.duration._

import io.gatling.core.Predef._
import io.gatling.http.Predef._
import io.gatling.jdbc.Predef._
import io.gatling.core.feeder._

import scala.util.parsing.json._
import scala.util.Random

class CustomSimulation extends Simulation {

  val httpProtocol = http
    //.baseURL("https://csyll.classes.cornell.edu")
    .baseURL("https://intentionallybroken.test.classes.cornell.edu")
//    .inferHtmlResources() // use this to test your http layer too.
    .acceptEncodingHeader("gzip, deflate")
    .userAgentHeader("Gatling Load Test")


    // If you're doing a non-fed session, this may be helpful
  var auth_key_val = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx9181304e3ca3a8a41e3e0994"
  var cuwa_token = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx=="
  var cuwa_time = "1509nnnnnn"
  var schedule_key="xxxxxxxxxxxxxxxxxxxxxxxx7480ab23"
  def variable_auth_headers (auth_key: String, cuwa_token: String, cuwa_time: String) = {
    Map(
      "cookie" -> s"""cuwl2famethod="DUO"; cuwltgttime="${cuwa_time}"; CUWALastWeblogin=0; cuweblogin2=${cuwa_token};""",
      "Accept" -> "application/json, text/plain, */*",
      "Authorization" -> s"ClassRoster ${auth_key}",
      "Connection" -> "keep-alive",
      "Content-Type" -> "application/json;charset=UTF-8",
      "Origin" -> "https://test.classes.cornell.edu"
    )
  }
  // use of s prefixed strings: s prefixed strings are for locally scoped variables.  Otherwise, the variables are pulled from the user's session.

  val auth_headers = variable_auth_headers(auth_key_val, cuwa_token, cuwa_time)

  // If you need to use fed values and CUWA, use these headers
  // Feed sets values in the user's session.  So if you're feeding a parameter, do not s prefix it.  If you pass a value as a function argument, s prefix it.
  def session_auth_headers = {
    Map(
      "cookie" -> """cuwl2famethod="DUO"; cuwltgttime="${cuwltgttime}"; CUWALastWeblogin=0; cuweblogin2=${cuweblogin2}; ClassRoster=${apikey}""",
      "Accept" -> "application/json, text/plain, */*",
      "Authorization" -> "ClassRoster ${apikey}",  // specifically, this is here because we need to feed the api key when setting headers. So it was easier to feed CUWA cookies as well.
      "Connection" -> "keep-alive",
      "Content-Type" -> "application/json;charset=UTF-8",
      "Origin" -> "https://test.classes.cornell.edu"
    )
  }
  val rosterFeeder = Array(
    Map("roster" -> "FA18")
  ).random

  val subjectFeeder = csv("subjects.csv").random
  val apiKeyFeeder= csv("apikeys.csv").random
  val cuwaFeeder = csv("cuwa.csv").random
  val queryStringFeeder = Iterator.continually(Map("queryString" -> ( Random.alphanumeric.take(20).mkString) ))

  def viewSubject= feed(subjectFeeder).
    feed(rosterFeeder)
    .exec(
      http("fetching course details")
      .get( "/browse/roster/${roster}/subject/${subject}" )
      .headers(session_auth_headers)
      .check(status.in(200,304,201,202,410))
    )
  def viewSubjectUncached= feed(subjectFeeder)
    feed(queryStringFeeder)
    feed(rosterFeeder)
    .exec(
      http("fetching course details uncached")
      .get( "/browse/roster/${roster}/subject/${subject}?${queryString}" )
      .headers(session_auth_headers)
      .check(status.in(200,304,201,202,410))
    )

  //val subjectViewingUser= scenario("SVU").exec( subjects.map( subject => viewSubject(subject)) )
  val subjectViewingUser= scenario("SubjectViewingUser").feed(cuwaFeeder).feed(apiKeyFeeder)  exec(viewSubject)
  val uncachedSubjectViewingUser= scenario("UncachedSubjectViewingUser").feed(cuwaFeeder).feed(apiKeyFeeder)  exec(viewSubjectUncached)
  val moreComplexScenario= scenario("complex")
    .feed(cuwaFeeder)
    .feed(apiKeyFeeder)
      .exec(viewSubjectUncached)
      .pause(2)
      .exec(viewSubjectUncached)
      .pause(2)
      .exec(viewSubject)


  // getting your users to match your r/s depends on your response time; mean response time is 145ms;
  // so if we want 100r/s, we add a user ~ every 150 ms,, ~7 u/s
    setUp(
        subjectViewingUser.inject(  constantUsersPerSec(2) during(1 minutes)),
        uncachedSubjectViewingUser.inject(  constantUsersPerSec(1) during(1 minutes)),
        moreComplexScenario.inject(  constantUsersPerSec(1) during(1 minutes)),
     )
      .throttle( reachRps(5) in (10 seconds), holdFor(1 minutes))
      .protocols(httpProtocol)
}

