context("Tests reading of a credentials file")
# http://docs.aws.amazon.com/cli/latest/reference/configure/
# https://blogs.aws.amazon.com/security/post/Tx3D6U6WSFGOK2H/A-New-and-Standardized-Way-to-Manage-Credentials-in-the-AWS-SDKs

test_that("default_credentials_file() works", {
    skip_on_cran()
    expect_is(default_credentials_file(), "character", label = "default_credentials_file() returns path")
})

test_that("read_credentials() works", {
    skip_on_cran()
    expect_is(read_credentials(file = "credentials"), "aws_credentials", label = "Read credentials correctly")
    alice <- read_credentials(file = "credentials")[["Alice"]]
    bob <- read_credentials(file = "credentials")[["Bob"]]
    expect_equal(bob[["AWS_SECRET_ACCESS_KEY"]], "Bob_secret_access_key", label = "final line value read correctly")
    expect_false(identical(alice, bob), label = "Read distinct profiles correctly")
    expect_false("[" %in% names(alice))
    expect_false("[" %in% names(bob))
})

test_that("read_credentials() works even absent EOL character", {
    skip_on_cran()
    cred <- read_credentials(file = "credentials-no-eol-char")
    expect_is(cred, "aws_credentials", label = "Read credentials successfully")
    expect_equal(cred[["Bob"]][["AWS_SECRET_ACCESS_KEY"]], "Bob_secret_access_key", label = "final line value read correctly")
})

test_that("read_credentials() fails when file is missing", {
    skip_on_cran()
    expect_error(read_credentials(file = "foo"), label = "Read credentials fails on missing file")
})


context("Tests use_credentials()")

test_that("use_credentials() sets environment variables correctly", {
    
    skip_on_cran()
    
    # save environment variables
    e <- Sys.getenv(c("AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY", "AWS_SESSION_TOKEN", "AWS_DEFAULT_REGION"))
    
    # unset environment variables
    Sys.unsetenv("AWS_ACCESS_KEY_ID")
    Sys.unsetenv("AWS_SECRET_ACCESS_KEY")
    Sys.unsetenv("AWS_SESSION_TOKEN")
    Sys.unsetenv("AWS_DEFAULT_REGION")
    
    # tests
    use_credentials(profile = "default", file = "credentials")
    expect_equal(Sys.getenv("AWS_ACCESS_KEY_ID"), "ACCESS_KEY")
    expect_equal(Sys.getenv("AWS_SECRET_ACCESS_KEY"), "SECRET_KEY")
    expect_equal(Sys.getenv("AWS_SESSION_TOKEN"), "TOKEN")
    expect_equal(Sys.getenv("AWS_DEFAULT_REGION"), "")
    
    # restore environment variables
    do.call("Sys.setenv", as.list(e))
})
