context("Tests Reading of ./aws/credentials file")
# http://docs.aws.amazon.com/cli/latest/reference/configure/
# https://blogs.aws.amazon.com/security/post/Tx3D6U6WSFGOK2H/A-New-and-Standardized-Way-to-Manage-Credentials-in-the-AWS-SDKs

test_that("default_credentials_file() works", {
    expect_true(is.character(default_credentials_file()), label = "default_credentials_file() returns path")
})

test_that("read_credentials() works", {
    expect_true(inherits(read_credentials(file = "credentials"), "aws_credentials"), label = "Read credentials correctly")
    alice <- read_credentials(file = "credentials")[["Alice"]]
    bob <- read_credentials(file = "credentials")[["Bob"]]
    expect_false(identical(alice, bob), label = "Read distinct profiles correctly")
})

test_that("read_credentials() works even absent EOL character", {
    expect_true(inherits(read_credentials(file = "credentials-no-eol-char"), "aws_credentials"), label = "Read credentials correctly")
})

test_that("read_credentials() fails when file is missing", {
    expect_error(read_credentials(file = "foo"), label = "Read credentials fails on missing file")
})
