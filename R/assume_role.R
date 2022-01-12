#' @rdname assume_role_with_web_identity
#' @title Assume Role with AWS Web Identity
#' @description Assume a role from a provided Web Identity Token and ARN using AWS Secure Token Service (STS).
#' @param role_arn A character string containing the AWS Role Amazon Resource Name (ARN). This specifies the permissions you have to access other AWS services.
#' @param token_file A character string containing a path to a Web Identity Token file.
#' @param base_url The AWS STS endpoint to use to retrieve your credentials from.
#' @param session_name A character string optionally specifying the name.
#' @param duration The expiry time on the retrieved credentials. 
#' @param version The AWS STS specification version to use.
#' @param verbose A logical indicating whether to be verbose.
#' @export
assume_role_with_web_identity <- function(
  role_arn, 
  token_file, 
  base_url=Sys.getenv("AWS_STS_ENDPOINT", "https://sts.amazonaws.com"), 
  session_name=NULL, 
  duration=3600,
  version="2011-06-15",
  verbose = getOption("verbose", FALSE)
){
  if (is.null(session_name)) {
    # strip resource ID from arn and use as default session name
    # https://docs.aws.amazon.com/general/latest/gr/aws-arns-and-namespaces.html
    session_name <- gsub("/", "-", utils::tail(strsplit(role_arn, ":")[[1]], 1))
  }
  
  token <- readChar(token_file, file.info(token_file)$size)

  query_params <- list(
    Action="AssumeRoleWithWebIdentity",
    DurationSeconds=duration,
    RoleArn=role_arn,
    RoleSessionName=session_name,
    WebIdentityToken=token,
    Version=version
  )
  query_params_names  <- curl::curl_escape(names(query_params))
  query_params_values <- lapply(query_params, curl::curl_escape)
  query_str  <- paste0(query_params_names, "=", query_params_values, collapse = "&")
  query_url <- paste0(base_url, "/?", query_str)

  handle <- curl::new_handle()  # need to accept json headers
  curl::handle_setheaders(handle, "accept" = "application/json")

  response <- curl::curl_fetch_memory(query_url, handle = handle)
  content <- jsonlite::fromJSON(rawToChar(response$content))
  
  if (response$status_code == 200) {
    if (isTRUE(verbose)) {
      message("Successfully fetched token from web identiy provider.")
    }
    return(content)
  } else {
    stop("Failed to assume role.")
  }
}
