# ------------------------------
# S3 OBJECT WITH CHANGEABLE STORAGE CLASS (CLEAN VERSION)
# ------------------------------
resource "aws_s3_object" "sample_object" {
  bucket = aws_s3_bucket.demo_bucket.id
  key    = "example.txt"
  source = "example.txt"

  # <<<<<<<< COST DEMO >>>>>>>>
  # Try changing:
  #   STANDARD       -> STANDARD_IA
  #   STANDARD_IA    -> ONEZONE_IA
  #   ONEZONE_IA     -> GLACIER
  #   GLACIER        -> GLACIER_IR
  storage_class = "STANDARD"
}
