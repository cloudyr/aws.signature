signature_v2_auth <- 
function(datetime = format(Sys.time(),"%Y%M%dT%H%M%S", tz = "UTC"),
         verb, service, path, query_args = list(),
         key = Sys.getenv("AWS_ACCESS_KEY_ID"),
         secret = Sys.getenv("AWS_SECRET_ACCESS_KEY")) {
    if(is.null(key) || key == ""){
        stop("Missing AWS Access Key ID")
    }
    if(is.null(secret) || secret == ""){
        stop("Missing AWS Secret Access Key")
    }
    
    # set sort locale
    lc <- Sys.getlocale(category = "LC_COLLATE")
    Sys.setlocale(category = "LC_COLLATE", locale = "C")
    on.exit(Sys.setlocale(category = "LC_COLLATE", locale = lc))
    
    # sort query arguments
    if (!"Timestamp" %in% names(query_args)) {
        query_args$Timestamp = datetime
    } else {
        datetime <- query_args$Timestamp
    }
    if (!"SignatureVersion" %in% names(query_args)) {
        query_args$SignatureVersion = "2"
    }
    if (!"SignatureMethod" %in% names(query_args)) {
        query_args$SignatureMethod = "HmacSHA256"
    }
    if (!"AWSAccessKeyId" %in% names(query_args)) {
        query_args$AWSAccessKeyId = key
    }
    query_to_parse <- unlist(query_args[order(names(query_args))])
    a <- paste0(sapply(names(query_to_parse), URLencode, reserved = TRUE), "=", 
                sapply(as.character(query_to_parse), URLencode, reserved = TRUE))
    query_string <- paste(a, sep = "", collapse = "&")
    
    canonical_request <- paste(verb, service, path, query_string, sep = "\n")
    signature <- hmac(key = secret, object = canonical_request, 
                      algo = "sha256", serialize = FALSE, raw = TRUE)
    sig_encoded <- base64encode(signature)
    query_args$Signature <- sig_encoded
    
    # return list
    structure(list(CanonicalRequest = canonical_request,
                   StringToSign = canonical_request,
                   Query = query_args,
                   Signature = sig_encoded), class = "aws_signature_v2")
}

