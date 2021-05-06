#' @rdname locate_credentials
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
#'   \item an instance role (on the running ECS task from which this function is called) as identified by \code{\link[aws.ec2metadata]{metadata}}, if the aws.ec2metadata package is installed
#'   \item an IAM instance role (on the running EC2 instance from which this function is called) as identified by \code{\link[aws.ec2metadata]{metadata}}, if the aws.ec2metadata package is installed
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
#'   \item the default value specified in \code{default_region} (i.e., \dQuote{us-east-1} - this can be overriden with the option \dQuote{cloudyr.aws.default_region})
#' }
#' 
#' As such, user-supplied values of \code{region} always trump any other value.
#' 
#' @seealso \code{\link{signature_v4}}, \code{\link{signature_v2_auth}}, \code{\link{use_credentials}}
#' @export
locate_credentials <-
function(
  key = NULL,
  secret = NULL,
  session_token = NULL,
  region = NULL,
  file = Sys.getenv("AWS_SHARED_CREDENTIALS_FILE", default_credentials_file()),
  profile = NULL,
  default_region = getOption("cloudyr.aws.default_region", "us-east-1"),
  verbose = getOption("verbose", FALSE)
) {

    credentials_feature_flag_on <- getOption("cloudyr.aws.prioritise_passed_profile", TRUE)
    
    if (isTRUE(verbose)) {
        message("Locating credentials")
    }
    
    # check for user-supplied values
    user_supplied_values <- check_for_user_supplied_values(key, secret, region, session_token, default_region, verbose)
    if (!is.null(user_supplied_values)){
      # early return
      return(user_supplied_values)
    }

    # Check for user-supplied profile
    if (credentials_feature_flag_on) {
      user_supplied_profile <- check_for_user_supplied_profile(profile, file, region, session_token, default_region, verbose)
      if (!is.null(user_supplied_profile)){
        # early return
        return(user_supplied_profile)
      }
    }

    # check for env vars needed to get credentials from web identity
    web_identity <- check_for_web_identity(verbose)
    if (!is.null(web_identity)) {
      # early return
      return(web_identity)
    }

    # otherwise use environment variables if no user-supplied values
    env_vars <- check_for_env_vars(region, file, default_region, session_token, verbose)
    if (!is.null(env_vars)){
      # early return
      return(env_vars)
    }

    # lacking that, check for ECS metadata
    ecs_metadata <- check_ecs_metadata(region, default_region, verbose)
    if (!is.null(ecs_metadata)){
      # early return
      return(ecs_metadata)
    }

    # lacking that, check for EC2 metadata
    ec2_metadata <- check_ec2_metadata(region, default_region, verbose)
    if (!is.null(ec2_metadata)){
      # early return
      return(ec2_metadata)
    }

    # lastly, check for credentials file
    creds_file <- check_credentials_file(profile, file, region, default_region, verbose)
    if (!is.null(creds_file)){
      # early return
      return(creds_file)
    }
        
    # if that fails, no credentials can be found anywhere
    if (isTRUE(verbose)) {
        message("No user-supplied credentials, environment variables, instance metadata, or credentials file found!")
    }
    # find region, with fail safes
    region <- find_region_with_failsafe(region = region, default_region = default_region, verbose = verbose)
    
    # return identified values
    return(list(key = key, secret = secret, session_token = session_token, region = region))
}

check_ec2 <- function() {
    ec2 <- FALSE
    if (requireNamespace("aws.ec2metadata", quietly = TRUE)) {
        if (aws.ec2metadata::is_ec2()) {
            ec2 <- TRUE
        }
    }
    return(ec2)
}

check_ecs <- function() {
    ecs <- FALSE
    if (requireNamespace("aws.ec2metadata", quietly = TRUE)) {
        if (aws.ec2metadata::is_ecs()) {
            ecs <- TRUE
        }
    }
    return(ecs)
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
          if (isTRUE(verbose)) {
            warning("No IAM role profile available in instance metadata")
          }
          return(NULL)
        }
        if (isTRUE(verbose)) {
            message("Using EC2 Instance Metadata")
        }
    }
    # return role credentials as list
    out <- try(aws.ec2metadata::metadata$iam_role(role[1L]), silent = TRUE)
    if (inherits(out, "try-error")) {
        out <- NULL
    }
    return(out)
}

credentials_to_list <-
function(
  cred,
  region = NULL,
  default_region = getOption("cloudyr.aws.default_region", "us-east-1"),
  verbose = getOption("verbose", FALSE)
) {
    key <- NULL
    secret <- NULL
    session_token <- NULL

    if (!is.null(cred[["AWS_ACCESS_KEY_ID"]])) {
        key <- cred[["AWS_ACCESS_KEY_ID"]]
        vmsg(verbose, "Using value in credentials file for AWS Access Key ID")
    }
    if (!is.null(cred[["AWS_SECRET_ACCESS_KEY"]])) {
        secret <- cred[["AWS_SECRET_ACCESS_KEY"]]
        vmsg(verbose, "Using value in credentials file for AWS Secret Access Key")
    }
    if (!is.null(cred[["AWS_SESSION_TOKEN"]])) {
        session_token <- cred[["AWS_SESSION_TOKEN"]]
        vmsg(verbose, "Using value in credentials file for AWS Session Token")
    } else {
        session_token <- NULL
    }
    # now find region, with fail safes (including credentials file)
    if (!is_blank(region)||(identical(region, "")&&getOption("cloudyr.aws.allow_empty_region", FALSE))) {
        region <- region
        vmsg(verbose, "Using user-supplied value for AWS Region ('%s')", region)

    } else if (!is.null(cred[["AWS_DEFAULT_REGION"]]) && cred[["AWS_DEFAULT_REGION"]] != "") {
        region <- cred[["AWS_DEFAULT_REGION"]]
        vmsg(verbose, "Using value in credentials file for AWS Region ('%s')", region)
    } else {
        region <- Sys.getenv("AWS_DEFAULT_REGION")
        if (!is.null(region) && region != "") {
          vmsg(verbose, "Using Environment Variable 'AWS_DEFAULT_REGION' for AWS Region ('%s')", region)
        } else {
            region <- default_region
            vmsg(verbose, "Using default value for AWS Region ('%s')", region )
        }
    }
    
    # return values
    return(list(key = key, secret = secret, session_token = session_token, region = region))
}

find_region_with_failsafe <-
function(
  region = NULL,
  default_region = getOption("cloudyr.aws.default_region", "us-east-1"),
  verbose = getOption("verbose", FALSE),
  try_ec2 = FALSE
) {
  # if we have a valid argument, just return it
  if (!is_blank(region)||(identical(region,"")&&getOption("cloudyr.aws.allow_empty_region", FALSE))) {
    vmsg(verbose, "Using user-supplied value for AWS Region ('%s')", region)
    return(region)
  }
  
  # look in the environment
  region <- Sys.getenv("AWS_DEFAULT_REGION")
  if (!is_blank(region)) {
    vmsg(verbose, "Using Environment Variable 'AWS_DEFAULT_REGION' for AWS Region ('%s')", region)
    return(region)
  }
  
  # if we've been asked to, try the ec2 instance metadata
  # this isn't done by default as its expensive if not on EC2
  if (isTRUE(try_ec2)) {
    reg <- try(aws.ec2metadata::instance_document()$region, silent = TRUE)
    if (!inherits(reg, "try-error")&&!is_blank(reg)) {
      region <- reg
      vmsg(verbose, "Using EC2 Instance Metadata for AWS Region ('%s')", region)
      return(region)
    }
    
  }

  # otherwise, use the default region
  region <- default_region
  vmsg(verbose, "Using default value for AWS Region ('%s')", region)
  
  return(region)
}

check_for_user_supplied_values <- function(key, secret, region, session_token, default_region, verbose) {
  if (isTRUE(verbose)) {
      message("Checking for credentials in user-supplied values")
  }
  if (!is_blank(key) && !is_blank(secret)) {
      if (isTRUE(verbose)) {
          message("Using user-supplied value for AWS Access Key ID")
          message("Using user-supplied value for AWS Secret Access Key")
      }
      
      if (!is_blank(session_token)) {
          if (isTRUE(verbose)) {
              message("Using user-supplied value for AWS Session Token")
          }
      }
      # now find region, with fail safes
      region <- find_region_with_failsafe(region = region, default_region = default_region, verbose = verbose)
      
      return(list(key = key, secret = secret, session_token = session_token, region = region))
  } else{
    return(NULL)
  }
}

check_for_user_supplied_profile <- function(profile, file, region, session_token, default_region, verbose) {
    if (is.null(profile)) {
        return(NULL)
    }
    if (isTRUE(verbose)) {
        message("Checking for credentials from user-defined profile")
    }
    profile_creds <- check_credentials_file(profile, file, region, default_region, verbose, require_profile = TRUE)
    if (!is.null(profile_creds)) {
        return(profile_creds)
    } 
    # If we can't find the profile the user gave us, bail out
    if (!is.null(profile)) {
        stop(paste0("Could not find profile matching '", profile, "'. Check that the profile you passed in matches your credentials file."))
    }
    return(NULL)
}


check_for_web_identity <- function(verbose){
  # try to use environment variable specifying web identity
  identity <- list(arn=Sys.getenv("AWS_ROLE_ARN"),
                   token_file=Sys.getenv("AWS_WEB_IDENTITY_TOKEN_FILE"))
  
  if (!is_blank(env$arn) && !is_blank(env$token_file)){
    return(assume_role_with_web_identity(env$arn, env$token_file))
  } else {
    return(NULL)
  }

}


check_for_env_vars <- function(region, file, default_region, session_token, verbose) {

    if (isTRUE(verbose)) {
      message("Checking for credentials in Environment Variables")
    }

    # try to use environment variables if no user-supplied values
    # grab environment variables
    env <- list(key = Sys.getenv("AWS_ACCESS_KEY_ID"),
                secret = Sys.getenv("AWS_SECRET_ACCESS_KEY"),
                profile = Sys.getenv("AWS_PROFILE"),
                session_token = Sys.getenv("AWS_SESSION_TOKEN"),
                region = Sys.getenv("AWS_DEFAULT_REGION"))

    if (!is_blank(env$session_token)) {
        session_token <- env$session_token
        if (isTRUE(verbose)) {
            message("Using Environment Variable 'AWS_SESSION_TOKEN' for AWS Session Token")
        }
    } else {
        if (!is_blank(session_token)) {
            session_token <- session_token
            if (isTRUE(verbose)) {
                message("Using user-supplied value for AWS Session Token")
            }
        }
    }
    
    if (!is_blank(env$key)&&!is_blank(env$secret)) {
        if (isTRUE(verbose)) {
            message("Using Environment Variable 'AWS_ACCESS_KEY_ID' for AWS Access Key ID")
            message("Using Environment Variable 'AWS_SECRET_ACCESS_KEY' for AWS Secret Access Key")
        }
        key <- env$key
        secret <- env$secret

        # now find region, with fail safes
        region <- find_region_with_failsafe(region = region, default_region = default_region, verbose = verbose)
        
        # early return
        return(list(key = key, secret = secret, session_token = session_token, region = region))
    } else if (!is_blank(env$profile)) {
        return(check_credentials_file(env$profile, file, region, default_region, verbose))
    }
    return(NULL)
}

check_ecs_metadata <- function(region, default_region, verbose){
    if (isTRUE(check_ecs())) {
      if (isTRUE(verbose)) {
        message("Checking for credentials in ECS Instance Metadata")
      }
      ecs_meta <- aws.ec2metadata::metadata$ecs_task_role()
      if (!is.null(ecs_meta)) {
        if (isTRUE(verbose)) {
          message(sprintf("Using ECS Instance Metadata for AWS Credentials (IAM Role: %s)", ecs_meta$RoleArn))
        }
        
        key <- ecs_meta[["AccessKeyId"]]
        secret <- ecs_meta[["SecretAccessKey"]]
        session_token <- ecs_meta[["Token"]]
        
        # now find region, with fail safes
        region <- find_region_with_failsafe(region = region,
                                            default_region = default_region,
                                            verbose = verbose,
                                            try_ec2 = TRUE)
        # early return
        return(list(key = key,
                    secret = secret,
                    session_token = session_token,
                    region = region)
               )
      }
    }
    return(NULL)
}

check_ec2_metadata <- function(region, default_region, verbose){
    if (isTRUE(check_ec2())) {
        if (isTRUE(verbose)) {
            message("Checking for credentials in EC2 Instance Metadata")
        }
        role <- try(get_ec2_role(verbose = verbose), silent = TRUE)
        if (!is.null(role)&&!inherits(role, "try-error")) {
          if (isTRUE(verbose)) {
            message("Using EC2 Instance Metadata for credentials")
          }
          key <- role[["AccessKeyId"]]
          secret <- role[["SecretAccessKey"]]
          session_token <- role[["Token"]]
          
          # now find region, with fail safes
          region <- find_region_with_failsafe(region = region,
                                              default_region = default_region,
                                              verbose = verbose,
                                              try_ec2 = TRUE)
          # early return
          return(list(key = key, secret = secret, session_token = session_token, region = region))
        }
    }
    return(NULL)
}

check_credentials_file <- function(profile, file, region, default_region, verbose, require_profile=FALSE) {
    vmsg(verbose, "Searching for credentials file(s)")

    files_to_check <- c(
      file.path(".aws", "credentials"),
      file,
      default_credentials_file()
    )
    files_to_check <- unique(files_to_check)
    
    for (f in files_to_check) {
      vmsg(verbose, sprintf("Attempting to read credentials from '%s'", f))
      
      creds <- read_profile_from_credentials_file(profile, f, region, default_region, verbose, require_profile)
      if (!is.null(creds)) {
        break
      }
    }
    
    return(creds)
}

read_profile_from_credentials_file <- function(profile, file, region, default_region, verbose, require_profile=FALSE) {
  if (!file.exists(file)) return(NULL)
  
  cred <- read_credentials(file)
  
  if (missing(profile)||is.null(profile)) {
    profile <- "default"
  }
  vmsg(verbose, sprintf("Attempting to find profile '%s'", profile))
  
  if (profile %in% names(cred)) {
    cred <- cred[[profile]]
    vmsg(verbose, sprintf("Using profile '%s' from credentials files from '%s'", profile, file))
  } else {
    if (isTRUE(require_profile)) {
      return(NULL)
    } else if ("default" %in% names(cred)) {
      cred <- cred[["default"]]
      vmsg(verbose, sprintf("Using profile '%s' from credentials files from '%s'", "default", file))
    } else {
      return(NULL)
    }
  }
  
  return(credentials_to_list(cred, region = region, default_region = default_region, verbose = verbose))
}
