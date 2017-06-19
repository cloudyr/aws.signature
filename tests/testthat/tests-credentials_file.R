context("Tests Reading of ./aws/credentials file")
# http://docs.aws.amazon.com/cli/latest/reference/configure/
# https://blogs.aws.amazon.com/security/post/Tx3D6U6WSFGOK2H/A-New-and-Standardized-Way-to-Manage-Credentials-in-the-AWS-SDKs

test_that("read_credentials() works", {
    expect_true(inherits(read_credentials(file = "credentials"), "aws_credentials"), label = "Read credentials correctly")
})

test_that("default_credentials_file() works", {
    expect_true(is.character(default_credentials_file()), label = "default_credentials_file() returns path")
})

