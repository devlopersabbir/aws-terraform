# S3 Bucket
resource "aws_s3_bucket" "this" {
    bucket = var.bucket_name
    
    tags = {
        Name = var.bucket_name
        Environment = "Dev"
        ManagedBy = "Terraform"
    }
}

# Ownership controls
resource "aws_s3_bucket_ownership_controls" "this" {
    bucket = aws_s3_bucket.this.id

    rule {
        object_ownership = "BucketOwnerPreferred"
    }
}

# acl
resource "aws_s3_bucket_acl" "this" {
    depends_on = [
        aws_s3_bucket_ownership_controls.this
    ]

    bucket = aws_s3_bucket.this.id
    acl    = "private"
}

# versioning
resource "aws_s3_bucket_versioning" "this" {
    bucket = aws_s3_bucket.this.id

    versioning_configuration {
        status = "Enabled"
    }
}

# server side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
    bucket = aws_s3_bucket.this.id

    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

# Enable public access so that user can get access bucket object from anywhere
resource "aws_s3_bucket_policy" "this" {
    bucket = aws_s3_bucket.this.id

    policy = jsonencode({
        Version = "2012-10-17"
        
        Statement = [
            {
                Sid = "PublicRead"
                Effect = "Allow"
                Principal = "*"

                Action = [
                    "s3:GetObject"
                ]

                Resource = [
                    "${aws_s3_bucket.this.arn}/*"
                ]
            }
        ]
    })
}

