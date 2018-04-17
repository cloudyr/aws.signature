#' @rdname credentials
#' @title Locate AWS Credentials
#' @description Locate AWS credentials from likely sources
#' @param key An AWS Access Key ID
#' @param secret An AWS Secret Access Key
#' @param session_token Optionally, an AWS Security Token Service (STS) temporary Session Token
#' @param region A character string containing the AWS region for the request. If missing, \dQuote{us-east-1} is assumed.
#' @param file A character string containing a path to a centralized \samp{.aws/credentials} file.
#' @param profile A character string specifying which profile to use from the file. By default, the profile named in \env{AWS_PROFILE} is used, otherwise the \dQuote{default} profile is used.
#' @param default_region A character string specifying a default string to use of no user-supplied value is found.
#' @param verbose A logical indicating whether to be verbose.
#' @details These functions locate values of AWS credentials (access key, secret access key, session token, and region) from likely sources. The order in which these are searched is as follows:
#' \enumerate{
#'   \item user-supplied values passed to the function
#'   \item environment variables (\env{AWS_ACCESS_KEY_ID}, \env{AWS_SECRET_ACCESS_KEY}, \env{AWS_DEFAULT_REGION}, and \env{AWS_SESSION_TOKEN})
#'   \item an IAM instance role (on the running EC2 instance from which this function is called) as identified by \code{\link[aws.ec2metadata]{metadata}}, if the aws.ec2metadtaa package is installed
#'   \item a profile in a local credentials dot file in the current working directory, using the profile specified by \env{AWS_PROFILE}
#'   \item the default profile in that local credentials file
#'   \item a profile in a global credentials dot file in a location set by \env{AWS_SHARED_CREDENTIALS_FILE} or defaulting typically to \file{~/.aws/credentials} (or another OS-specific location), using the profile specified by \env{AWS_PROFILE}
#'   \item the default profile in that global credentials file
#' }
#' 
#' If \env{AWS_ACCESS_KEY_ID} and \env{AWS_SECRET_ACCESS_KEY} environment variables are not present when the package is loaded, then \code{use_credentials} is invoked using the file specified in \env{AWS_SHARED_CREDENTIALS_FILE} (or another default location) and the profile specified in \env{AWS_PROFILE} (or, if missing, the \dQuote{default} profile).
#' 
#' To use this (and any cloudyr package) on AWS EC2 instances, users will also need to install the \href{https://cran.r-project.org/package=aws.ec2metadata}{aws.ec2metadata} package, which allows \code{locate_credentials} to know it is running in an instance and check for relevant values. If this package is not installed, instance metadata is not checked.
#' 
#' Because region is often handled slightly differently from credentials and is required for most requests (whereas some services allow anonymous requests without specifying credentials), the value of region is searched for in the same order as the above but lacking a value there fails safe with the following preference ranking of possible region values (regardless of location of other credentials):
#' \enumerate{
#'   \item a user-supplied value
#'   \item the \env{AWS_DEFAULT_REGION} environment variable
#'   \item (only on EC2 instances) a region declared in the instance metadata
#'   \item (if a credentials file is being used) the value specified therein
#'   \item the default value specified in \code{default_region} (i.e., \dQuote{us-east-1})
#' }
#' 
#' As such, user-supplied values of \code{region} always trump any other value.
#' 
#' @seealso \code{\link{signature_v4}}, \code{\link{signature_v2_auth}}, \code{\link{use_credentials}}
#' @export
locate_credentials <- 
function(key = NULL,
         secret = NULL,
         session_token = NULL,
         region = NULL,
         file = Sys.getenv("AWS_SHARED_CREDENTIALS_FILE", default_credentials_file()),
         profile = Sys.getenv("AWS_PROFILE", "default"),
         default_region = "us-east-1",
         verbose = FALSE) {
    
    # grab environment variables
    env <- list(key = Sys.getenv("AWS_ACCESS_KEY_ID"),
                secret = Sys.getenv("AWS_SECRET_ACCESS_KEY"),
                session_token = Sys.getenv("AWS_SESSION_TOKEN"),
                region = Sys.getenv("AWS_DEFAULT_REGION"))
    
    ec2 <- FALSE
    if (requireNamespace("aws.ec2metadata", quietly = TRUE)) {
        if (aws.ec2metadata::is_ec2()) {
            ec2 <- TRUE
        }
    }
    
    # check for user-supplied values
    if (isTRUE(verbose)) {
        message("Checking for credentials in user-supplied values")
    }
    if ((!is.null(key) && key != "") || (!is.null(secret) && secret != "")) {
        if (!is.null(key) && key != "") {
            if (isTRUE(verbose)) {
                message("Using user-supplied value for AWS Access Key ID")
            }
        }
        if (!is.null(secret) && secret != "") {
            if (isTRUE(verbose)) {
                message("Using user-supplied value for AWS Secret Access Key")
            }
        }
        if (!is.null(session_token) && session_token != "") {
            if (isTRUE(verbose)) {
                message("Using user-supplied value for AWS Session Token")
            }
        }
        # now find region, with fail safes
        if (!is.null(region) && region != "") {
            region <- region
            if (isTRUE(verbose)) {
                message(sprintf("Using user-supplied value for AWS Region ('%s')", region))
            }
        } else if (!is.null(env$region) && env$region != "") {
            region <- env$region
            if (isTRUE(verbose)) {
                message(sprintf("Using Environment Variable 'AWS_DEFAULT_REGION' for AWS Region ('%s')", region))
            }
        } else {
            region <- default_region
            if (isTRUE(verbose)) {
                message(sprintf("Using default value for AWS Region ('%s')", region))
            }
        }
    } else if ((!is.null(env$key) && env$key != "") || (!is.null(env$secret) && env$secret != "")) {
        # otherwise use environment variables if no user-supplied values
        if (isTRUE(verbose)) {
            message("Checking for credentials in Environment Variables")
        }
        if (!is.null(env$key) && env$key != "") {
            key <- env$key
            if (isTRUE(verbose)) {
                message("Using Environment Variable 'AWS_ACCESS_KEY_ID' for AWS Access Key ID")
            }
        } else {
            if (!is.null(key) && key != "") {
                key <- key
                if (isTRUE(verbose)) {
                    message("Using user-supplied value for AWS Access Key ID")
                }
            }
        }
        if (!is.null(env$secret) && env$secret != "") {
            secret <- env$secret
            if (isTRUE(verbose)) {
                message("Using Environment Variable 'AWS_SECRET_ACCESS_KEY' for AWS Secret Access Key")
            }
        } else {
            if (!is.null(secret) && secret != "") {
                secret <- secret
                if (isTRUE(verbose)) {
                    message("Using user-supplied value for AWS Secret Access Key")
                }
            }
        }
        if (!is.null(env$session_token) && env$session_token != "") {
            session_token <- env$session_token
            if (isTRUE(verbose)) {
                message("Using Environment Variable 'AWS_SESSION_TOKEN' for AWS Session Token")
            }
        } else {
            if (!is.null(session_token) && session_token != "") {
                session_token <- session_token
                if (isTRUE(verbose)) {
                    message("Using user-supplied value for AWS Session Token")
                }
            }
        }
        # now find region, with fail safes
        if (!is.null(region) && region != "") {
            region <- region
            if (isTRUE(verbose)) {
                message(sprintf("Using user-supplied value for AWS Region ('%s')", region))
            }
        } else if (!is.null(env$region) && env$region != "") {
            region <- env$region
            if (isTRUE(verbose)) {
                message(sprintf("Using Environment Variable 'AWS_DEFAULT_REGION' for AWS Region ('%s')", region))
            }
        } else {
            region <- default_region
            if (isTRUE(verbose)) {
                message(sprintf("Using default value for AWS Region ('%s')", region))
            }
        }
    } else if (isTRUE(ec2)) {
        # lacking that, check for EC2 metadata
        if (isTRUE(verbose)) {
            message("Checking for credentials in EC2 Instance Metadata")
        }
        role <- try(get_ec2_role(verbose = verbose), silent = TRUE)
        if (!inherits(role, "try-error")) {
            if (!is.null(role[["AccessKeyId"]])) {
                key <- role[["AccessKeyId"]]
                if (isTRUE(verbose)) {
                    message("Using EC2 Instance Metadata for AWS Access Key ID")
                }
            }
            if (!is.null(role[["SecretAccessKey"]])) {
                secret <- role[["SecretAccessKey"]]
                if (isTRUE(verbose)) {
                    message("Using EC2 Instance Metadata for AWS Secret Access Key")
                }
            }
            if (!is.null(role[["Token"]])) {
                session_token <- role[["Token"]]
                if (isTRUE(verbose)) {
                    message("Using EC2 Instance Metadata for AWS Session Token")
                }
            }
        }
        # now find region, with fail safes
        if (!is.null(region) && region != "") {
            region <- region
            if (isTRUE(verbose)) {
                message(sprintf("Using user-supplied value for AWS Region ('%s')", region))
            }
        } else if (!is.null(env$region) && env$region != "") {
            region <- env$region
            if (isTRUE(verbose)) {
                message(sprintf("Using Environment Variable 'AWS_DEFAULT_REGION' for AWS Region ('%s')", region))
            }
        } else {
            # check instance metadata for region
            reg <- try(aws.ec2metadata::instance_document()$region, silent = TRUE)
            if (!inherits(reg, "try-error") && !is.null(reg) && reg != "") {
                region <- reg
                if (isTRUE(verbose)) {
                    message(sprintf("Using EC2 Instance Metadata for AWS Region ('%s')", region))
                }
            } else {
                region <- default_region
                if (isTRUE(verbose)) {
                    message(sprintf("Using default value for AWS Region ('%s')", region))
                }
            }
        }
    } else {
        # lastly, check for credentials file
        if (isTRUE(verbose)) {
            message("Searching for credentials file(s)")
        }
        if (file.exists(file.path(".aws", "credentials"))) {
            ## in working directory
            cred <- read_credentials(file.path(".aws", "credentials"))[[profile]]
            if (profile %in% names(cred)) {
                cred <- cred[[profile]]
            } else {
                cred <- cred[["default"]]
                if (isTRUE(verbose)) {
                    warning(sprintf("Requested profile '%s' not found in file. Using 'default' profile.", profile))
                }
            }
            if (isTRUE(verbose)) {
                message(sprintf("Using profile '%s' from local credentials files from '%s'", profile, file.path(".aws", "credentials")))
            }
        } else if (file.exists(file) || file.exists(default_credentials_file())) {
            ## in specified location
            if (file.exists(file)) {
                cred <- read_credentials(file = file)[[profile]]
            } else {
                ## otherwise, default to default location
                cred <- read_credentials(file = default_credentials_file())[[profile]]
            }
            if (profile %in% names(cred)) {
                cred <- cred[[profile]]
            } else {
                cred <- cred[["default"]]
                if (isTRUE(verbose)) {
                    warning(sprintf("Requested profile '%s' not found in file. Using 'default' profile.", profile))
                }
            }
            if (isTRUE(verbose)) {
                message(sprintf("Using profile '%s' from global credentials files from '%s'", profile, default_credentials_file()))
            }
        } else {
            # if that fails, no credentials can be found anywhere
            if (isTRUE(verbose)) {
                message("No user-supplied credentials, environment variables, instance metadata, or credentials file found!")
            }
            # now find region, with fail safes
            if (!is.null(region) && region != "") {
                region <- region
                if (isTRUE(verbose)) {
                    message(sprintf("Using user-supplied value for AWS Region ('%s')", region))
                }
            } else if (!is.null(env$region) && env$region != "") {
                region <- env$region
                if (isTRUE(verbose)) {
                    message(sprintf("Using Environment Variable 'AWS_DEFAULT_REGION' for AWS Region ('%s')", region))
                }
            } else {
                region <- default_region
                if (isTRUE(verbose)) {
                    message(sprintf("Using default value for AWS Region ('%s')", region))
                }
            }
            # return early with list of empty values!
            return(list(key = NULL, secret = NULL, session_token = NULL, region = region))
        }
        if (!is.null(cred[["AWS_ACCESS_KEY_ID"]])) {
            key <- cred[["AWS_ACCESS_KEY_ID"]]
            if (isTRUE(verbose)) {
                message("Using value in credentials file for AWS Access Key ID")
            }
        }
        if (!is.null(cred[["AWS_SECRET_ACCESS_KEY"]])) {
            secret <- cred[["AWS_SECRET_ACCESS_KEY"]]
            if (isTRUE(verbose)) {
                message("Using value in credentials file for AWS Secret Access Key")
            }
        }
        if (!is.null(cred[["AWS_SESSION_TOKEN"]])) {
            session_token <- cred[["AWS_SESSION_TOKEN"]]
            if (isTRUE(verbose)) {
                message("Using value in credentials file for AWS Session Token")
            }
        }
        # now find region, with fail safes
        if (!is.null(region) && region != "") {
            region <- region
            if (isTRUE(verbose)) {
                message(sprintf("Using user-supplied value for AWS Region ('%s')", region))
            }
        } else if (!is.null(cred[["AWS_DEFAULT_REGION"]]) && cred[["AWS_DEFAULT_REGION"]] != "") {
            region <- cred[["AWS_DEFAULT_REGION"]]
            if (isTRUE(verbose)) {
                message(sprintf("Using value in credentials file for AWS Region ('%s')", region))
            }
        } else if (!is.null(env$region) && env$region != "") {
            region <- env$region
            if (isTRUE(verbose)) {
                message(sprintf("Using Environment Variable 'AWS_DEFAULT_REGION' for AWS Region ('%s')", region))
            }
        } else {
            region <- default_region
            if (isTRUE(verbose)) {
                message(sprintf("Using default value for AWS Region ('%s')", region))
            }
        }
    }
    # return identified values
    list(key = key, secret = secret, session_token = session_token, region = region)
}

get_ec2_role <- function(role, verbose = getOption("verbose", FALSE)) {
    if (!requireNamespace("aws.ec2metadata", quietly = TRUE)) {
        return(NULL)
    }
    if (!isTRUE(aws.ec2metadata::is_ec2())) {
        return(NULL)
    }
    if (missing(role)) {
        role <- try(aws.ec2metadata::metadata$iam_role_names(), silent = TRUE)
        if (!length(role)) {
            stop("No IAM role profile available in instance metadata")
        }
        if (isTRUE(verbose)) {
            message("Using EC2 Instance Metadata")
        }
    }
    # return role credentials as list
    out <- try(aws.ec2metadata::metadata$iam_role(role[1L]), silent = TRUE)
    if (inherits(out, "try-errror")) {
        out <- NULL
    }
    out
}
