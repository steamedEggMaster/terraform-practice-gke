# Google Kubernetes Engine 클러스터 설정
resource "google_container_cluster" "primary" {
  # 클러스터 이름을 지정합니다.
  name = var.cluster_name

  # 클러스터가 위치할 지역을 지정합니다. (한국 지역: asia-northeast3-a)
  location = var.cluster_location

  # 기본 노드 풀을 제거합니다.
  # 커스텀 node-pool 추가 가능해짐
  remove_default_node_pool = true

  # 초기 노드 개수를 설정합니다.
  initial_node_count = 1

  # 클러스터가 속할 VPC 네트워크를 지정합니다.
  network = google_compute_network.main.self_link

  # 클러스터가 속할 서브네트워크를 지정합니다.
  subnetwork = google_compute_subnetwork.private.self_link

  # 네트워킹 모드를 VPC 네이티브 모드로 설정합니다.
  # Kubernetes Pod가 VPC 네트워크와 직접적으로 통합되어 
  # VPC의 IP 주소 범위 사용
  # => 클러스터 내 모든 Pod가 고유한 IP 주소를 가지고 통신 가능
  networking_mode = "VPC_NATIVE"
  
  # 릴리즈 채널 설정
  ## 릴리즈 채널 : 클러스터의 버전 안정성 설정
  release_channel {
    # 릴리즈 채널을 정규 채널로 설정합니다.
    channel = "REGULAR"
    ## RAPID, STABLE 존재
  }

  # 워크로드 아이덴티티 설정
  workload_identity_config {
    # 워크로드 풀을 설정합니다.
    # service-account에서 만들고 권한을 부여한 서비스 계정에
    # 접근가능하게 한 Kubernetes 서비스 계정을 pool로 설정
    workload_pool = var.workload_pool
  }

  # IP 할당 정책 설정
  ip_allocation_policy {
    # 클러스터의 세컨더리 IP 범위 이름을 지정합니다.
    cluster_secondary_range_name = var.cluster_secondary_range_name
    # Pod가 사용하는 IP 주소를 위한 범위

    # 서비스의 세컨더리 IP 범위 이름을 지정합니다.
    services_secondary_range_name = var.services_secondary_range_name
    # 서비스(LoadBalancer 나 ClusterIP)같은 Kubernetes 서비스에
    # 할당되는 IP 범위
  }

  # 프라이빗 클러스터 설정
  private_cluster_config {
    # 프라이빗 노드를 활성화합니다.
    # 모든 노드는 Private IP만을 사용함
    # => 노드에 외부에서 직접 접근 불가
    enable_private_nodes = true

    # 프라이빗 엔드포인트를 비활성화합니다.
    # 마스터 노드가 외부에서 직접 접근하는 것 비활성화
    # 마스터 노드도 Private IP를 통해서만 접근하게 함
    enable_private_endpoint = false

    # 마스터 노드의 IPv4 CIDR 블록을 지정합니다.
    # => 클러스터(워커 노드)와 마스터 노드 간 통신이 안전하게 설정됨
    # => 네트워크에서 IP 충돌 방지
    master_ipv4_cidr_block = var.master_ipv4_cidr_block
  }

  # 애드온 설정
  # : GKE 클러스터에서 특정 기능 활성화 or 비활성화
  addons_config {
    # 기본적으로 제공하는 Google Cloud HTTP 로드 밸런싱을 비활성화합니다.
    # 커스텀 LoadBalancer나 Ingress 리소스를 통해 하고자 할때 비활성화
    http_load_balancing {
      disabled = true
    }

    # 수평 파드 오토스케일링을 활성화합니다.
    # 부하에 맞춰 자동으로 Pod 수 조정
    horizontal_pod_autoscaling {
      disabled = false
    }
  }
}