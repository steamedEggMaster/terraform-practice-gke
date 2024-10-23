# Google Compute Router NAT 설정
resource "google_compute_router_nat" "nat" {
  # NAT 설정의 이름을 지정합니다.
  name = var.nat_name

  # NAT 설정이 속할 라우터를 지정합니다.
  router = google_compute_router.router.name

  # NAT 설정이 위치할 지역을 지정합니다. (한국 지역: asia-northeast3)
  region = var.nat_region

  # NAT를 적용할 서브네트워크 IP 범위를 지정합니다.
  source_subnetwork_ip_ranges_to_nat = var.source_subnetwork_ip_ranges_to_nat

  # NAT IP 할당 옵션을 수동으로 설정합니다.
  nat_ip_allocate_option = "MANUAL_ONLY"
  # Cloud NAT가 사용할 외부 IP 주소를 수동으로 지정해야 한다는 것
  # 사용자는 퍼블릭 IP 주소를 직접 생성 후, Cloud NAT에 할당해야 함

  # 서브네트워크 설정
  subnetwork {
    # NAT를 적용할 서브네트워크 이름을 지정합니다.
    name = google_compute_subnetwork.private.id

    # NAT를 적용할 IP 범위를 지정합니다.
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
    ## ALL_IP_RANGES : 서브네트워크 내에서 외부 내트워크로 나가는 모든 IP가 NAT를 거침
    ## PRIMARY_IP_RANGE : 기본 IP 범위만 NAT, 보조 IP 범위는 적용 X
    ## SECONDARY_IP_RANGE : 보조 IP 범위만 NAT 적용
  }

  # NAT IP 주소를 지정합니다.
  nat_ips = [google_compute_address.nat.self_link]
}

# 외부 IP 주소 생성
resource "google_compute_address" "nat" {
# Google Compute Engine에서 고정 IP주소를 생성하는 리소스 정의

  # 외부 IP 주소의 이름을 지정합니다.
  name = var.nat_name

  # IP 주소 타입을 외부 주소로 설정합니다.
  address_type = "EXTERNAL"
  # INTERNAL : 내부에서만 사용 가능한 Private IP 주소 생성
  
  # 네트워크 계층을 프리미엄으로 설정합니다.
  network_tier = "PREMIUM"
  # PREMIUM : 더 낮은 지연 시간 및 높은 성능
  # STANDARD : 성능 약간 낮지만 비용 저렴, 지역 네트워크 사용
}