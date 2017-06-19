context("AWS Example Test Suite")
# http://docs.aws.amazon.com/general/latest/gr/signature-v4-test-suite.html

test_that("AWS test suite via canonical_request", {
    ex <- "GET
/
foo=Zoo&foo=aha
date:Mon, 09 Sep 2011 23:36:00 GMT
host:host.foo.com

date;host
e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

    r <- canonical_request(verb = "GET",
                           canonical_uri = "/",
                           query_args = list(foo = "Zoo", foo = "aha"),
                           canonical_headers = list(host = "host.foo.com",
                                                    date = "Mon, 09 Sep 2011 23:36:00 GMT"),
                           request_body = "")
    expect_identical(r$canonical, ex, label = "Canonical request matches")
})

test_that("AWS test suite via string_to_sign", {
    ex <- "AWS4-HMAC-SHA256
20110909T233600Z
20110909/us-east-1/host/aws4_request
e25f777ba161a0f1baf778a87faf057187cf5987f17953320e3ca399feb5f00d"
    s <- string_to_sign(algorithm = "AWS4-HMAC-SHA256",
         datetime = "20110909T233600Z",
         region = "us-east-1",
         service = "host",
         request_hash = "e25f777ba161a0f1baf778a87faf057187cf5987f17953320e3ca399feb5f00d")
    expect_identical(s, ex, label = "String to sign matches")
})

test_that("AWS test suite via signature_v4", {
    tosign <- "AWS4-HMAC-SHA256
20110909T233600Z
20110909/us-east-1/host/aws4_request
e25f777ba161a0f1baf778a87faf057187cf5987f17953320e3ca399feb5f00d"
    ex <- "be7148d34ebccdc6423b19085378aa0bee970bdc61d144bd1a8c48c33079ab09"
    s <- signature_v4(secret = "wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY",
                      date = "20110909",
                      region = "us-east-1",
                      service = "host",
                      string_to_sign = tosign, verbose = TRUE)
    expect_identical(s, ex, label = "String to sign matches")
})

test_that("AWS test suite via signature_v4_auth", {
    d <- "20110909T233600Z"
    s <- signature_v4_auth(datetime = d,
                           region = "us-east-1",
                           service = "host",
                           verb = "GET",
                           action = "/",
                           query_args = list(foo = "Zoo", foo = "aha"),
                           canonical_headers = list(host = "host.foo.com",
                                                    date = d),
                           request_body = "",
                           key = "AKIDEXAMPLE",
                           secret = "wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY",
                           query = FALSE,
                           algorithm = "AWS4-HMAC-SHA256")
    expect_identical(s$Credential, "AKIDEXAMPLE/20110909/us-east-1/host/aws4_request", 
                     label = "Credential string matches")
    expect_identical(s$BodyHash, "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855", 
                     label = "Body hash string matches")
    expect_identical(s$SignedHeaders, "date;host", 
                     label = "Signed header string matches")
    #expect_identical(s$Signature, "be7148d34ebccdc6423b19085378aa0bee970bdc61d144bd1a8c48c33079ab09", 
    #                 label = "Signature string matches")
    #expect_identical(s$SignatureHeader, "AWS4-HMAC-SHA256 Credential=AKIDEXAMPLE/20110909/us-east-1/host/aws4_request, SignedHeaders=date;host, Signature=be7148d34ebccdc6423b19085378aa0bee970bdc61d144bd1a8c48c33079ab09", 
    #                 label = "Full authorization string matches")
    
})

test_that("AWS test suite via signature_v2_auth", {
true_string <- "GET
elasticmapreduce.amazonaws.com
/
AWSAccessKeyId=AKIAIOSFODNN7EXAMPLE&Action=DescribeJobFlows&SignatureMethod=HmacSHA256&SignatureVersion=2&Timestamp=2011-10-03T15%3A19%3A30&Version=2009-03-31"
    true_sig <- "i91nKc4PWAt0JJIdXwz9HxZCJDdiy6cf/Mj6vPxyYIs="

    q1 <- 
    list(Action = "DescribeJobFlows",
         Version = "2009-03-31",
         AWSAccessKeyId = "AKIAIOSFODNN7EXAMPLE",
         SignatureVersion = "2",
         SignatureMethod = "HmacSHA256",
         Timestamp = "2011-10-03T15:19:30")

    sig1 <- 
    signature_v2_auth(datetime = "2011-10-03T15:19:30",
                      service = "elasticmapreduce.amazonaws.com",
                      verb = "GET",
                      path = "/",
                      query_args = q1,
                      key = q1$AWSAccessKeyId,
                      secret = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY")
    expect_true(identical(true_string, sig1$CanonicalRequest), label = "v2 CanonicalRequest correct")
    expect_true(identical(true_sig, sig1$Signature), label = "v2 Signature correct")

    q2 <- 
    list(Action = "DescribeJobFlows",
         Version = "2009-03-31",
         Timestamp = "2011-10-03T15:19:30")
    sig2 <- 
    signature_v2_auth(datetime = "2011-10-03T15:19:30",
                      service = "elasticmapreduce.amazonaws.com",
                      verb = "GET",
                      path = "/",
                      query_args = q2,
                      key = "AKIAIOSFODNN7EXAMPLE",
                      secret = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY")
    expect_true(identical(true_string, sig2$CanonicalRequest), label = "v2 CanonicalRequest correct, setting defaults")
    expect_true(identical(true_sig, sig2$Signature), label = "v2 Signature correct, setting defaults")
})
