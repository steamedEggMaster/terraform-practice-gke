# Compute Engine API 활성화
resource "google_project_service" "compute" {
# compute : 해당 리소스의 이름
  # Compute Engine API를 활성화하여 GCP 프로젝트에서 사용할 수 있도록 설정합니다.
  service = "compute.googleapis.com"
  # 활성화할 API 이름
  disable_dependent_services = true
  # Compute Engine에 의존하는 다른 서비스 존재 시 해당 서비스들도 비활성화돰
  disable_on_destroy = false
  # 리소스 삭제 시, Compute Engine API는 여전히 활성화되어 있게 함
}

# Kubernetes Engine API 활성화
resource "google_project_service" "container" {
  # Kubernetes Engine API를 활성화하여 GCP 프로젝트에서 사용할 수 있도록 설정합니다.
  service = "container.googleapis.com"
  # Kubernets Engine API 활성화할 이름
  disable_dependent_services = true
  # Kubernetes Engine에 의존하는 다른 서비스도 함께 비활성화
  disable_on_destroy = false
  # 리소스 삭제 시, Kubernetes Engine API를 비활성화하지 않도록 함
}

# VPC 네트워크 설정
resource "google_compute_network" "main" {
# main : 해당 리소스의 이름
  # VPC 네트워크의 이름을 지정합니다.
  name = var.vpc_network_name

  # 네트워크의 라우팅 모드를 지역적으로 설정합니다.
  # 네트워크 트래픽이 하나의 리전 내에서만 분산하여 처리
  routing_mode = "REGIONAL"
  # GLOBAL : 트래픽을 모든 리전으로 분산

  # 자동 서브넷 생성 비활성화
  # 네트워크에 서브넷을 자동으로 생성하지 않도록 설정합니다.
  # 기본적으로 GCP는 새로운 네트워크 생성 시, 자동으로 서브넷 생성
  # but false를 통해 사용자 정의 서브넷을 수동으로 생성
  auto_create_subnetworks = false

  # 최대 전송 단위(MTU)를 1460으로 설정합니다.
  mtu = 1460

  # 기본 경로 삭제 비활성화
  # 네트워크 생성 시 기본 경로를 삭제하지 않도록 설정합니다.
  delete_default_routes_on_create = false

  # VPC 네트워크 리소스가 
  # Compute Engine API와 Kubernetes Engine API가 활성화되어야 생성되게 함
  depends_on = [ 
    google_project_service.compute,   # Compute Engine API가 활성화된 후에 생성
    google_project_service.container  # Kubernetes Engine API가 활성화된 후에 생성
  ]
}