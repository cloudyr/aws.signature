.onLoad <- function(libname, pkgname) {
    # If credentials are in environment variables, use those.
    creds <- locate_credentials()
    if (!all(is.null(creds$key), is.null(creds$secret))) {
        return(invisible(NULL))
    }
    # Load default AWS credentials allowing the package to behave like the AWS CLI
    if (file.exists(default_credentials_file())) {
        use_credentials()
    }
    return(invisible(NULL))
}
