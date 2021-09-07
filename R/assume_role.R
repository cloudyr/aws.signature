#' @rdname assume_role_with_web_identity
#' @title Assume Role with AWS Web Identity
#' @description Assume a role from a provided Web Identity Token and ARN using AWS Secure Token Service (STS).
#' @param role_arn A character string containing the AWS Role Amazon Resource Name (ARN). This specifies the permissions you have to access other AWS services.
#' @param token_file A character string containing a path to a Web Identity Token file.
#' @param base_url The AWS STS endpoint to use to retrieve your credentials from.
#' @param session_name A character string optionally specifying the name.
#' @param duration The expiry time on the retrieved credentials. 
#' @param version The AWS STS specification version to use.
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
    # strip resource ID from arn and use as default session name
    # https://docs.aws.amazon.com/general/latest/gr/aws-arns-and-namespaces.html
    print("Setting default session name")
    session_name <- tail(strsplit(role_arn, ":")[[1]], 1)
  }
  
  token <- readChar(token_file, file.info(token_file)$size)

  query <- list(
    Action="AssumeRoleWithWebIdentity",
    DurationSeconds=duration,
    RoleArn=role_arn,
    RoleSessionName=session_name,
    WebIdentityToken=token,
    Version=version
  )

  response <- httr::GET(base_url, query=query)
  content <- httr::content(response)

  if (httr::status_code(response) == 200) {
    message("Successfully fetched token.")
    return(content)
  } else {
    stop("Failed to assume role.")
  }
}
