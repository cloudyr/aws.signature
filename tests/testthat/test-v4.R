test_that("A GET request is correctly signed", {
  key <- "AKIAIOSFODNN7EXAMPLE"
  secret <- "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
  region <- "us-east-1"
  
  
  
  signed <- signature_v4_auth(
    datetime = "20130524T000000Z",
    service = "s3",
    verb = "GET",
    action = "/test.txt",
    canonical_headers = list(
      "Host"= "examplebucket.s3.amazonaws.com",
      "Range"= "bytes=0-9",
      "X-AMZ-Date"="20130524T000000Z"
    ),
    request_body = "",
    signed_body=TRUE,
    key = key,
    secret= secret,
    region = region
  )
  
  expect_identical(signed$SignatureHeader, "AWS4-HMAC-SHA256 Credential=AKIAIOSFODNN7EXAMPLE/20130524/us-east-1/s3/aws4_request,SignedHeaders=host;range;x-amz-content-sha256;x-amz-date,Signature=f0e8bdb87c964420e857bd35b5d6ed310bd44f0170aba48dd91039c6036bdb41")
})
