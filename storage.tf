# Google Cloud Storage 버킷 (개발 환경)
## == AWS의 S3
resource "google_storage_bucket" "static_assets_dev" {
  name          = var.storage_name_dev
  location      = var.storage_location
  force_destroy = true
  # 버킷을 삭제할 때, 버킷 안에 파일이 남아있어도 강제 삭제
}

# Google Cloud Storage 버킷 (운영 환경)
resource "google_storage_bucket" "static_assets_prd" {
  name          = var.storage_name_prd
  location      = var.storage_location
  force_destroy = true
}