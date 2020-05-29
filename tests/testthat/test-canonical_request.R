test_that("A canonical request is generated", {
  fromDocs <- "POST
/

content-type:application/x-www-form-urlencoded; charset=utf-8
host:iam.amazonaws.com
x-amz-date:20110909T233600Z

content-type;host;x-amz-date
b6359072c78d70ebee1e81adcbab4f01bf2c23245fa365ef83fe8f1f955085e2"

  hdrs <- list(`Content-Type` = "application/x-www-form-urlencoded; charset=utf-8",
               Host = "iam.amazonaws.com",
               `x-amz-date` = "20110909T233600Z")
  r <- canonical_request(verb = "POST",
                         canonical_uri = "/",
                         query_args = list(),
                         canonical_headers = hdrs,
                         request_body = "Action=ListUsers&Version=2010-05-08")

  expect_identical(r$canonical, fromDocs)
})


test_that("A canonical request is generated with a signed body", {
  fromDocs <- "POST
/

content-type:application/x-www-form-urlencoded; charset=utf-8
host:iam.amazonaws.com
x-amz-content-sha256:b6359072c78d70ebee1e81adcbab4f01bf2c23245fa365ef83fe8f1f955085e2
x-amz-date:20110909T233600Z

content-type;host;x-amz-content-sha256;x-amz-date
b6359072c78d70ebee1e81adcbab4f01bf2c23245fa365ef83fe8f1f955085e2"
  
  hdrs <- list(`Content-Type` = "application/x-www-form-urlencoded; charset=utf-8",
               Host = "iam.amazonaws.com",
               `x-amz-date` = "20110909T233600Z")
  r <- canonical_request(verb = "POST",
                         canonical_uri = "/",
                         query_args = list(),
                         canonical_headers = hdrs,
                         signed_body = TRUE,
                         request_body = "Action=ListUsers&Version=2010-05-08")
  
  expect_identical(r$canonical, fromDocs)
})
