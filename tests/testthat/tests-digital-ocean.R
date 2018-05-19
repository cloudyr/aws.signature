context("Digital Ocean Example Test Suite")
# https://developers.digitalocean.com/documentation/spaces/#authentication

test_that("Digital Ocean test suite via canonical_request", {
    ex <- "GET
/
acl=
host:static-images.nyc3.digitaloceanspaces.com
x-amz-content-sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
x-amz-date:20170804T221549Z

host;x-amz-content-sha256;x-amz-date
e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

    r <- canonical_request(verb = "GET",
                           canonical_uri = "/",
                           query_args = list(acl = ""),
                           canonical_headers = list(host = "static-images.nyc3.digitaloceanspaces.com",
                                                    'x-amz-content-sha256' = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
                                                    'x-amz-date' = "20170804T221549Z"),
                           request_body = "")
    expect_identical(r$canonical, ex, label = "Digital Ocean canonical request matches")
})
