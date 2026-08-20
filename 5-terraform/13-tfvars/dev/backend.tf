
    bucket       = "azdevopsvenkat.site-dev" # Replace with your unique S3 bucket name
    key          = "tfvars.tfstate"  # Path inside the bucket where the file will sit
    region       = "us-east-1"           # Your AWS Region
    encrypt      = true                  # Encrypts the state file at rest
    use_lockfile = true                  # Enabiling native state locking file
