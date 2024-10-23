# Kubernetes 클러스터를 위한 서비스 계정 생성
resource "google_service_account" "kubernetes" {
  # 서비스 계정의 ID를 지정합니다.
  account_id = var.kubernetes_service_account_id
  # 클러스터의 노드가 Google Cloud API에 접근 시 사용됨
}

# Kubernetes 클러스터의 일반 노드 풀 설정
resource "google_container_node_pool" "general" {
  # 노드 풀의 이름을 지정합니다.
  name = var.node_pool_name

  # 이 노드 풀이 속할 Kubernetes 클러스터를 지정합니다.
  cluster = google_container_cluster.primary.id

  # 노드 풀의 초기 노드 개수를 지정합니다.
  node_count = 2

  # 노드 관리 설정
  management {
    # 노드 자동 복구를 활성화합니다.
    auto_repair = true

    # 노드 자동 업그레이드를 활성화합니다.
    auto_upgrade = true
  }

  # 노드 구성 설정
  node_config {
    # 노드를 비프리엠티블로 설정합니다.
    preemptible = false

    # 머신 타입을 지정합니다.
    machine_type = "e2-medium"

    # 노드 풀의 모든 노드에 적용할 레이블을 지정합니다.
    # 특정 워크로드를 해당 레이블을 가진 노드에 배치 가능
    labels = {
      role = "general"
    }

    # 서비스 계정을 지정합니다.
    # 노드가 Google Cloud API에 접근 가능케 함
    service_account = google_service_account.kubernetes.email

    # OAuth 스코프를 지정합니다.
    oauth_scopes = var.oauth_scopes

    # 각 노드의 디스크 크기 지정(최소 30GB)
    disk_size_gb = 50
  }
}

resource "google_container_node_pool" "spot" {
  name    = "spot"
  cluster = google_container_cluster.primary.id

  # 초기 노드 개수 지정
  initial_node_count = 1

  management {
    # 노드 문제 발생 시 자동 복구
    auto_repair  = true
    # 노드 자동 업그레이드
    auto_upgrade = true
  }

  autoscaling {
    # 최소 노드 개수 지정
    min_node_count = 1
    # 부하 증가 시 최대 노드 개수
    max_node_count = 10
  }

  node_config {
    # 언제든 멈출 수 있는 노드 => 비용 저렴
    preemptible  = true
    machine_type = "e2-medium"

    # devops 시에 사용할 노드인듯
    labels = {
      team = "devops"
    }

    # 특정 노드에 특정 조건을 만족하는 Pod만 스케줄링되도록 함
    taint {
      # 해당 taint의 조건 이름
      key    = "instance_type"
      # 해당 노드가 spot 인스턴스임을 나타냄
      value  = "spot"
      # 아무 Pod가 실행되지 않도록 함
      effect = "NO_SCHEDULE"
    }

    service_account = google_service_account.kubernetes.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}