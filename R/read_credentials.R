default_credentials_file <- function() {
    if (.Platform[["OS.type"]] == "windows") {
        home <- Sys.getenv("USERPROFILE")
    } else {
        home <- "~"
    }
    suppressWarnings(normalizePath(file.path(home, '.aws', 'credentials')))
}

read_credentials <- function(file = default_credentials_file()) {
    file <- path.expand(file)
    if (!file.exists(file)) {
        stop(paste0("File ", shQuote(file), " does not exist."))
    }
    char <- rawToChar(readBin(file, "raw", n = 1e5L))
    parse_credentials(char)
}

parse_credentials <- function(char) {
    s <- c(gregexpr("\\[", char)[[1]], nchar(char))

    make_named_vec <- function(x) {
        elem <- strsplit(x, " = ")
        out <- lapply(elem, `[`, 2)
        names(out) <- toupper(sapply(elem, `[`, 1))
        out
    }

    creds <- list()
    for (i in seq_along(s)[-1]) {
        tmp <- strsplit(substr(char, s[i-1], s[i]-1), "[\n\r]+")[[1]]
        creds[[i-1]] <- make_named_vec(tmp[-1])
        names(creds)[[i-1]] <- gsub("\\[", "", gsub("\\]", "", tmp[1]))
    }
    structure(creds, class = "aws_credentials")
}

use_credentials <- function(profile = "default", file = default_credentials_file()) {
    if (inherits(file, "aws_credentials")) {
        x <- file
    } else {
        x <- read_credentials(file)
    }
    if ("AWS_ACCESS_KEY_ID" %in% names(x[[profile]])) {
        Sys.setenv("AWS_ACCESS_KEY_ID" = x[[profile]][["AWS_ACCESS_KEY_ID"]])
    }
    if ("AWS_SECRET_ACCESS_KEY" %in% names(x[[profile]])) {
        Sys.setenv("AWS_SECRET_ACCESS_KEY" = x[[profile]][["AWS_SECRET_ACCESS_KEY"]])
    }
    if ("AWS_SESSION_TOKEN" %in% names(x[[profile]])) {
        Sys.setenv("AWS_SESSION_TOKEN" = x[[profile]][["AWS_SESSION_TOKEN"]])
    }
    if ("AWS_DEFAULT_REGION" %in% names(x[[profile]])) {
        Sys.setenv("AWS_DEFAULT_REGION" = x[[profile]][["AWS_DEFAULT_REGION"]])
    }
    invisible(x)
}
