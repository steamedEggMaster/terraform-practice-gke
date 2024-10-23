# Google Artifact Registry Repository (개발 환경)
resource "google_artifact_registry_repository" "repo_dev" {
  provider = google
  location = var.repo_location
  # 리전 설정
  repository_id = var.repo_dev_id
  description = var.repo_dev_description
  format = "DOCKER"
  # 도커 이미지 저장을 위한 레포지토리 형식 지정
}

# Google Artifact Registry Repository (운영 환경)
resource "google_artifact_registry_repository" "repo_prd" {
  provider = google
  location = var.repo_location
  repository_id = var.repo_prd_id
  description = var.repo_prd_description
  format = "DOCKER"
}