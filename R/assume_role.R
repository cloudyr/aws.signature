#' @rdname assume_role_with_web_identity
#' @export
assume_role_with_web_identity <- function(
  role_arn, 
  token_file, 
  base_url=Sys.getenv("AWS_STS_ENDPOINT", "https://sts.amazonaws.com"), 
  session_name=NULL, 
  duration=3600,
  version="2011-06-15"
){
  if (is.null(session_name)) {
    session_name <- Sys.getenv("TENANT", "DataScienceAssumeRoleWithWebIdentity")
  }
  
  token <- as.character(readLines(token_file))
  
  query <- list(
    Action="AssumeRoleWithWebIdentity",
    DurationSeconds=duration,
    RoleArn=role_arn,
    RoleSessionName=session_name,
    WebIdentityToken=token,
    Version=version
  )

  response <- httr::GET(base_url, query=query)
  
  if (httr::status_code(response) == 200) {
    message("Successfully fetched token.")
    return(httr::content(response))
  } else {
    print(httr::content(response))
    stop("Failed to assume role.")
  }
}
