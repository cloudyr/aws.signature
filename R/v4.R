canonical_request <- 
function(verb,
         canonical_uri = "",
         query_string = "",
         canonical_headers,
         request_body = ""
         ) {
    body_hash <- tolower(digest(request_body, algo = "sha256", serialize = FALSE))
    
    names(canonical_headers) <- tolower(names(canonical_headers))
    canonical_headers <- canonical_headers[order(names(canonical_headers))]
    header_string <- paste0(names(canonical_headers), ":", canonical_headers, "\n", collapse = "")
    # trim leading, trailing, and all non-quoted duplicated spaces
    # gsub("^\\s+|\\s+$", "", x)
    signed_headers <- paste(names(canonical_headers), sep = "", collapse = ";")
    out <- paste(verb, 
                 canonical_uri,
                 query_string,
                 header_string,
                 signed_headers,
                 body_hash,
                 sep = "\n")
    return(list(headers = signed_headers, 
                body = body_hash,
                canonical = out,
                hash = digest(out, algo = "sha256", serialize = FALSE)))
}

string_to_sign <- 
function(algorithm = "AWS4-HMAC-SHA256",
         datetime, # format(Sys.time(),"%Y%M%dT%H%M%SZ", tz = "UTC")
         region,
         service,
         request_hash
         ) {
    paste(algorithm,
          datetime,
          paste(substring(datetime,1,8),
                region,
                service,
                "aws4_request", sep = "/"),
          request_hash, sep = "\n")
}

signature_v4 <- 
function(secret,
         date,
         region = "us-east-1",
         service,
         string_to_sign){
    if(missing(secret)){
        secret <- Sys.getenv("AWS_SECRET_ACCESS_KEY")
    }
    if(missing(date)){
        date <- format(Sys.time(), "%Y%m%d")
    }
    kDate <- hmac(paste0("AWS4", secret), date, "sha256", raw = TRUE)
    kRegion <- hmac(kDate, region, "sha256", raw = TRUE)
    kService <- hmac(kRegion, service, "sha256", raw = TRUE)
    kSigning <- hmac(kService, "aws4_request", "sha256", raw = TRUE)
    signature <- hmac(kSigning, string_to_sign, "sha256")
    return(signature)
}

signature_v4_auth <- 
function(datetime = format(Sys.time(),"%Y%M%dT%H%M%SZ", tz = "UTC"),
         region,
         service,
         verb,
         action,
         query_string = "",
         canonical_headers, # named list
         request_body,
         key,
         secret,
         query = FALSE,
         algorithm = "AWS4-HMAC-SHA256"){
    if(missing(key)){
        key <- Sys.getenv("AWS_ACCESS_KEY_ID")
    }
    if(key == "")
        stop("Missing AWS Access Key ID")
    if(missing(secret)){
        secret <- Sys.getenv("AWS_SECRET_ACCESS_KEY")
    }
    if(secret == "")
        stop("Missing AWS Secret Access Key")
    date <- substring(datetime,1,8)
    
    if(query){
        # handle query-based authorizations, by including relevant parameters
    } 
    
    # Canonical Request
    R <- canonical_request(verb = verb,
                           canonical_uri = action,
                           query_string = query_string,
                           canonical_headers = canonical_headers,
                           request_body = request_body)
    
    # String To Sign
    S <- string_to_sign(algorithm = algorithm,
                        datetime = datetime,
                        region = region,
                        service = service,
                        request_hash = R$hash)
    
    # Signature
    V4 <- signature_v4(secret = secret,
                       date = date,
                       region = region,
                       service = service,
                       string_to_sign = S)
    
    # return list
    credential <- paste(key, date, region, service, "aws4_request", sep="/")
    sigheader <- paste(algorithm,
                       paste(paste0("Credential=", credential),
                             paste0("SignedHeaders=", R$headers),
                             paste0("Signature=", V4),
                             sep = ", "))
    structure(list(Algorithm = algorithm,
                   Credential = credential,
                   Date = date,
                   SignedHeaders = R$headers,
                   BodyHash = R$body,
                   StringToSign = S,
                   Signature = V4,
                   SignatureHeader = sigheader), class = "aws_signature_v4")
}

