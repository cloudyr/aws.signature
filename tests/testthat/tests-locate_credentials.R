context("Tests locate_credentials()")

if (file.exists(".aws/credentials")) {
    
    test_that("locate_credentials() returns envvar values when environment variables and credentials file present", {
        
        skip_on_cran()
        
        # save environment variables
        e <- Sys.getenv(c("AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY", "AWS_SESSION_TOKEN", "AWS_DEFAULT_REGION"))
        
        # set environment variables
        Sys.setenv("AWS_ACCESS_KEY_ID" = "foo-key")
        Sys.setenv("AWS_SECRET_ACCESS_KEY" = "foo-secret")
        Sys.setenv("AWS_SESSION_TOKEN" = "foo-token")
        Sys.setenv("AWS_DEFAULT_REGION" = "foo-region")
        
        # tests
        cred <- locate_credentials()
        expect_equal(cred[["key"]], "foo-key")
        expect_equal(cred[["secret"]], "foo-secret")
        expect_equal(cred[["session_token"]], "foo-token")
        expect_equal(cred[["region"]], "foo-region")
        
        # restore environment variables
        do.call("Sys.setenv", as.list(e))
    })
    
    test_that("locate_credentials() returns non-default values if requested when environment variables and credentials file present", {
        
        skip_on_cran()
        
        # save environment variables
        e <- Sys.getenv(c("AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY", "AWS_SESSION_TOKEN", "AWS_DEFAULT_REGION"))
        
        # set environment variables
        Sys.setenv("AWS_ACCESS_KEY_ID" = "foo-key")
        Sys.setenv("AWS_SECRET_ACCESS_KEY" = "foo-secret")
        Sys.setenv("AWS_SESSION_TOKEN" = "foo-token")
        Sys.setenv("AWS_DEFAULT_REGION" = "foo-region")
        
        # tests
        cred <- locate_credentials(key = "foo1", secret = "foo2", session_token = "foo3", region = "foo4")
        expect_equal(cred[["key"]], "foo1", label = "locate_credentials(key = 'foo1')")
        expect_equal(cred[["secret"]], "foo2", label = "locate_credentials(secret = 'foo2')")
        expect_equal(cred[["session_token"]], "foo3", label = "locate_credentials(session_token = 'foo3')")
        expect_equal(cred[["region"]], "foo4", label = "locate_credentials(region = 'foo4')")
        
        # restore environment variables
        do.call("Sys.setenv", as.list(e))
    })
    
    test_that("locate_credentials() returns credentials file values when environment variables missing and credentials file present", {
        
        skip_on_cran()
        
        # save environment variables
        e <- Sys.getenv(c("AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY", "AWS_SESSION_TOKEN", "AWS_DEFAULT_REGION"))
        
        # unset environment variables
        Sys.unsetenv("AWS_ACCESS_KEY_ID")
        Sys.unsetenv("AWS_SECRET_ACCESS_KEY")
        Sys.unsetenv("AWS_SESSION_TOKEN")
        Sys.unsetenv("AWS_DEFAULT_REGION")
        
        # tests
        cred <- locate_credentials()
        expect_equal(cred[["key"]], "ACCESS_KEY")
        expect_equal(cred[["secret"]], "SECRET_KEY")
        expect_equal(cred[["session_token"]], "TOKEN")
        expect_equal(cred[["region"]], "us-east-1")
        
        # restore environment variables
        do.call("Sys.setenv", as.list(e))
    })
    
    test_that("locate_credentials() returns non-default values if requested, when environment variables missing and credentials file absent", {
        
        skip_on_cran()
        
        # move credentials file
        tmp <- tempfile(tmpdir = ".aws")
        file.rename(".aws/credentials", tmp)
        
        # save environment variables
        e <- Sys.getenv(c("AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY", "AWS_SESSION_TOKEN", "AWS_DEFAULT_REGION"))
        
        # unset environment variables
        Sys.unsetenv("AWS_ACCESS_KEY_ID")
        Sys.unsetenv("AWS_SECRET_ACCESS_KEY")
        Sys.unsetenv("AWS_SESSION_TOKEN")
        Sys.unsetenv("AWS_DEFAULT_REGION")
        
        # tests
        cred <- locate_credentials(key = "foo1", secret = "foo2", session_token = "foo3", region = "foo4")
        expect_equal(cred[["key"]], "foo1", label = "locate_credentials(key = 'foo1')")
        expect_equal(cred[["secret"]], "foo2", label = "locate_credentials(secret = 'foo2')")
        expect_equal(cred[["session_token"]], "foo3", label = "locate_credentials(session_token = 'foo3')")
        expect_equal(cred[["region"]], "foo4", label = "locate_credentials(region = 'foo4')")
        
        # restore credentials file
        file.rename(tmp, ".aws/credentials")
        
        # restore environment variables
        do.call("Sys.setenv", as.list(e))
    })
    
    test_that("locate_credentials() returns NULLs when environment variables missing and credentials file absent", {
        
        skip_on_cran()
        
        # move credentials file
        tmp <- tempfile(tmpdir = ".aws")
        file.rename(".aws/credentials", tmp)
        
        # save environment variables
        e <- Sys.getenv(c("AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY", "AWS_SESSION_TOKEN", "AWS_DEFAULT_REGION"))
        
        # unset environment variables
        Sys.unsetenv("AWS_ACCESS_KEY_ID")
        Sys.unsetenv("AWS_SECRET_ACCESS_KEY")
        Sys.unsetenv("AWS_SESSION_TOKEN")
        Sys.unsetenv("AWS_DEFAULT_REGION")
        
        # tests
        cred <- locate_credentials()
        expect_null(cred[["key"]])
        expect_null(cred[["secret"]])
        expect_null(cred[["session_token"]])
        expect_equal(cred[["region"]], "us-east-1")
        
        # restore credentials file
        file.rename(tmp, ".aws/credentials")
        
        # restore environment variables
        do.call("Sys.setenv", as.list(e))
    })

    test_that("locate_credentials() uses options default for region", {

        skip_on_cran()

        # save environment variables
        e <- Sys.getenv(c("AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY", "AWS_SESSION_TOKEN", "AWS_DEFAULT_REGION"))

        # unset environment variables
        Sys.unsetenv("AWS_ACCESS_KEY_ID")
        Sys.unsetenv("AWS_SECRET_ACCESS_KEY")
        Sys.unsetenv("AWS_SESSION_TOKEN")
        Sys.unsetenv("AWS_DEFAULT_REGION")
        cloudyr_region <- getOption("cloudyr.aws.default_region")
        options(cloudyr.aws.default_region = "eu-west-1")

        # tests
        cred <- locate_credentials()
        expect_equal(cred[["key"]], "ACCESS_KEY")
        expect_equal(cred[["secret"]], "SECRET_KEY")
        expect_equal(cred[["session_token"]], "TOKEN")
        expect_equal(cred[["region"]], "eu-west-1")

        # restore environment variables
        do.call("Sys.setenv", as.list(e))
        options(cloudyr.aws.default_region = cloudyr_region)
    })

    test_that("locate_credentials() allows empty region with allow_empty_set", {

        skip_on_cran()

        # save environment variables
        e <- Sys.getenv(c("AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY", "AWS_SESSION_TOKEN", "AWS_DEFAULT_REGION"))

        # unset environment variables
        Sys.unsetenv("AWS_ACCESS_KEY_ID")
        Sys.unsetenv("AWS_SECRET_ACCESS_KEY")
        Sys.unsetenv("AWS_SESSION_TOKEN")
        Sys.unsetenv("AWS_DEFAULT_REGION")
        cloudyr_region <- getOption("cloudyr.aws.allow_empty_region")
        options(cloudyr.aws.allow_empty_region = TRUE)

        # tests
        cred <- locate_credentials(region="")
        expect_equal(cred[["key"]], "ACCESS_KEY")
        expect_equal(cred[["secret"]], "SECRET_KEY")
        expect_equal(cred[["session_token"]], "TOKEN")
        expect_equal(cred[["region"]], "")

        # restore environment variables
        do.call("Sys.setenv", as.list(e))
        options(cloudyr.aws.allow_empty_region = cloudyr_region)
    })
    
    test_that("locate_credentials() works with allow_empty_set", {
        
        skip_on_cran()
        
        # save environment variables
        e <- Sys.getenv(c("AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY", "AWS_SESSION_TOKEN", "AWS_DEFAULT_REGION"))
        
        # unset environment variables
        Sys.unsetenv("AWS_ACCESS_KEY_ID")
        Sys.unsetenv("AWS_SECRET_ACCESS_KEY")
        Sys.unsetenv("AWS_SESSION_TOKEN")
        Sys.unsetenv("AWS_DEFAULT_REGION")
        cloudyr_region <- getOption("cloudyr.aws.allow_empty_region")
        options(cloudyr.aws.allow_empty_region = TRUE)
        
        # tests
        cred <- locate_credentials(region=NULL)
        expect_equal(cred[["key"]], "ACCESS_KEY")
        expect_equal(cred[["secret"]], "SECRET_KEY")
        expect_equal(cred[["session_token"]], "TOKEN")
        expect_equal(cred[["region"]], "us-east-1")
        
        # restore environment variables
        do.call("Sys.setenv", as.list(e))
        options(cloudyr.aws.allow_empty_region = cloudyr_region)
    })

    test_that("locate_credentials() prioritizes profile argument when conflicting env-vars are set", {

        skip_on_cran()

        # save environment variables
        e <- Sys.getenv(c("AWS_ACCESS_KEY_ID",
                          "AWS_SECRET_ACCESS_KEY",
                          "AWS_SESSION_TOKEN",
                          "AWS_DEFAULT_REGION"
                          ))
        
        # set environment variables
        Sys.setenv("AWS_ACCESS_KEY_ID" = "foo-key")
        Sys.setenv("AWS_SECRET_ACCESS_KEY" = "foo-secret")
        Sys.setenv("AWS_SESSION_TOKEN" = "foo-token")
        Sys.setenv("AWS_DEFAULT_REGION" = "foo-region")

        # tests
        cred <- locate_credentials(profile = 'Alice')
        expect_equal(cred[["key"]], "Alice_access_key_ID")
        expect_equal(cred[["secret"]], "Alice_secret_access_key")
        
        # restore environment variables
        do.call("Sys.setenv", as.list(e))
    })

}
