context("Tests Reading of ./aws/credentials file")
# http://docs.aws.amazon.com/cli/latest/reference/configure/
# https://blogs.aws.amazon.com/security/post/Tx3D6U6WSFGOK2H/A-New-and-Standardized-Way-to-Manage-Credentials-in-the-AWS-SDKs

test_that("read_credentials() works", {
    expect_true(inherits(read_credentials(file = "credentials"), "aws_credentials"), label = "Read credentials correctly")
    expect_error(read_credentials(file = "foo"), label = "Read credentials fails on missing file")
})

test_that("default_credentials_file() works", {
    expect_true(is.character(default_credentials_file()), label = "default_credentials_file() returns path")
})


context("Tests locate_credentials()")

test_that("locate_credentials() returns non-default values if requested", {
    e <- Sys.getenv(c("AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY", "AWS_SESSION_TOKEN", "AWS_DEFAULT_REGION"))
    Sys.unsetenv("AWS_ACCESS_KEY_ID")
    Sys.unsetenv("AWS_SECRET_ACCESS_KEY")
    Sys.unsetenv("AWS_SESSION_TOKEN")
    Sys.unsetenv("AWS_DEFAULT_REGION")
    expect_true(locate_credentials(key = "foo")[["key"]] == "foo", label = "locate_credentials(key = 'foo')")
    expect_true(locate_credentials(secret = "foo")[["secret"]] == "foo", label = "locate_credentials(secret = 'foo')")
    # session token cannot be set if key and secret are missing
    expect_true(is.null(locate_credentials(session_token = "foo")[["session_token"]]), label = "locate_credentials(session_token = 'foo') returns NULL")
    expect_true(locate_credentials(region = "foo")[["region"]] == "foo", label = "locate_credentials(region = 'foo')")
    do.call("Sys.setenv", as.list(e))
})

test_that("locate_credentials() returns NULLs when environment variables missing", {
    e <- Sys.getenv(c("AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY", "AWS_SESSION_TOKEN", "AWS_DEFAULT_REGION"))
    Sys.unsetenv("AWS_ACCESS_KEY_ID")
    Sys.unsetenv("AWS_SECRET_ACCESS_KEY")
    Sys.unsetenv("AWS_SESSION_TOKEN")
    Sys.unsetenv("AWS_DEFAULT_REGION")
    cred <- locate_credentials()
    expect_true(is.null(cred[["key"]]))
    expect_true(is.null(cred[["secret"]]))
    expect_true(is.null(cred[["session_token"]]))
    expect_true(cred[["region"]] == "us-east-1")
    do.call("Sys.setenv", as.list(e))
})

test_that("locate_credentials() returns NULLs when environment variables present", {
    e <- Sys.getenv(c("AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY", "AWS_SESSION_TOKEN", "AWS_DEFAULT_REGION"))
    Sys.setenv("AWS_ACCESS_KEY_ID" = "foo-key")
    Sys.setenv("AWS_SECRET_ACCESS_KEY" = "foo-secret")
    Sys.setenv("AWS_SESSION_TOKEN" = "foo-token")
    Sys.setenv("AWS_DEFAULT_REGION" = "foo-region")
    cred <- locate_credentials()
    expect_true(cred[["key"]] == "foo-key")
    expect_true(cred[["secret"]] == "foo-secret")
    expect_true(cred[["session_token"]] == "foo-token")
    expect_true(cred[["region"]] == "foo-region")
    do.call("Sys.setenv", as.list(e))
})

test_that("get_ec2_role() works", {
    if (!requireNamespace("aws.ec2metadata", quietly = TRUE)) {
        expect_true(is.null(aws.signature:::get_ec2_role()), label = "get_ec2_role() returns NULL")
    }
})

