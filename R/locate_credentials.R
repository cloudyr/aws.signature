#' @rdname credentials
#' @title Locate AWS Credentials
#' @description Locate AWS credentials from likely sources
#' @param key An AWS Access Key ID
#' @param secret An AWS Secret Access Key
#' @param session_token Optionally, an AWS Security Token Service (STS) temporary Session Token
#' @param region A character string containing the AWS region for the request. If missing, \dQuote{us-east-1} is assumed.
#' @param file A character string containing a path to a \samp{.aws/credentials} file.
#' @param profile A character string specifing which profile to use from the file. By default, the \dQuote{default} profile is used.
#' @param verbose A logical indicating whether to be verbose.
#' @details These functions locate values of AWS credentials (access key, secret access key, session token, and region) from likely sources. The order in which these are searched is as follows:
#' \enumerate{
#'   \item values passed to the functions
#'   \item a specified profile in a local credentials dot file in the current working directory
#'   \item the default profile in a local credentials dot file in the current working directory
#'   \item a specified profile in a global credentials dot file in, typically in \file{~/.aws/credentials}. See \code{\link{use_credentials}} for details
#'   \item the default profile in a global credentials dot file in, typically in \file{~/.aws/credentials}. See \code{\link{use_credentials}} for details
#'   \item environment variables (\env{AWS_ACCESS_KEY_ID}, \env{AWS_SECRET_ACCESS_KEY}, \env{AWS_SESSION_TOKEN}, \env{AWS_DEFAULT_REGION})
#'   \item an IAM role (on the running EC2 instance from which this function is called) as identified by \code{\link[aws.ec2metadata]{metadata}}
#' }
#' 
#' @seealso \code{\link{signature_v4}}, \code{\link{signature_v2_auth}}, \code{\link{use_credentials}}
#' @import aws.ec2metadata
#' @export
locate_credentials <- 
function(key = NULL, 
         secret = NULL, 
         session_token = NULL, 
         region = NULL, 
         file = NULL, 
         profile = "default", 
         default_region = "us-east-1",
         verbose = FALSE) {
    if (is.null(key)) {
        key <- find_value("key", file = file, profile = profile, verbose = verbose, fail = FALSE)
    }
    if (is.null(secret)) {
        secret <- find_value("secret", file = file, profile = profile, verbose = verbose, fail = FALSE)
    }
    if (is.null(session_token)) {
        session_token <- find_value("session_token", file = file, profile = profile, verbose = verbose, fail = FALSE)
    }
    if (is.null(region)) {
        region <- find_value("region", file = file, profile = profile, verbose = verbose, fail = FALSE)
        if (is.null(region) || region == "") {
            region <- default_region
        }
    }
    list(key = key, secret = secret, session_token = session_token, region = region)
}

find_value <- function(value, file, profile, verbose = FALSE, fail = FALSE) {
    env <- switch(value, "key" = "AWS_ACCESS_KEY_ID", 
                         "secret" = "AWS_SECRET_ACCESS_KEY",
                         "session_token" = "AWS_SESSION_TOKEN",
                         "region" = "AWS_DEFAULT_REGION")
    name <- switch(value, "key" = "AWS Access Key ID", 
                          "secret" = "AWS Secret Access Key",
                          "session_token" = "AWS Session Token",
                          "region" = "AWS Region")
    if (missing(value)) {
        value <- Sys.getenv(env)
        if (is.null(value) || value == "") {
            if (!missing(profile)) {
                profile2 <- "default"
            } else {
                profile2 <- profile
            }
            if (!missing(file)) {
                credentials <- try(read_credentials(file)[[profile]], quiet = TRUE)
            } else {
                credentials <- try(read_credentials(file.path(".aws", "credentials"))[[profile]], quiet = TRUE)
            }
            if (inherits(credentials, "try-error")) {
                credentials <- try(read_credentials()[[profile]], quiet = TRUE)
                if (inherits(credentials, "try-error")) {
                    ec2role <- try(get_ec2_role(), quiet = TRUE)
                    if (inherits(ec2role, "try-error")) {
                        if (value == "region") {
                            value <- "us-east-1"
                            if (isTRUE(verbose)) {
                                message("Using 'us-east-1' for AWS Region")
                            }
                        } else {
                            value <- NULL
                        }
                    } else {
                        value <- ec2role[[env]]
                        if (isTRUE(verbose)) {
                            message(sprintf("Using role profile from EC2 metadata for %s", name))
                        }
                    }
                } else {
                    value <- credentials[[env]]
                    if (isTRUE(verbose)) {
                        message(sprintf("Using '%s' profile in global credentials file for %s", profile2, name))
                    }
                }
            } else {
                value <- credentials[[env]]
                if (isTRUE(verbose)) {
                    message(sprintf("Using '%s' profile in local credentials file for %s", profile2, name))
                }
            }
        } else {
            if (isTRUE(verbose)) {
                message(sprintf("Using environment variable '%s' for %s", env, name))
            }
        }
    } else {
        if (isTRUE(verbose)) {
            message(sprintf("Using user-supplied value for %s", name))
        }
    }
    if ((is.null(value) || value == "")) {
        if (isTRUE(fail)) {
            stop(sprintf("%s not found", name))
        }
    }
    value
}

get_ec2_role <- function(role) {
    if (missing(role)) {
        role <- aws.ec2metadata::metadata$iam_role_names()
        if (!length(role)) {
            stop("No IAM role profile available in instance metadata")
        }
    }
    # return role credentials as list
    aws.ec2metadata::metadata$iam_role(role[1L])
}
