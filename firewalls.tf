# SSH(22번 포트)를 특정 IP 범위에서만 허용하는 방화벽 규칙
resource "google_compute_firewall" "allow-ssh" {
  name    = var.firewall_name_ssh
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = var.ssh_source_ranges
}

# HTTP(80번 포트) 및 HTTPS(443번 포트)를 모든 IP에서 허용하는 방화벽 규칙
resource "google_compute_firewall" "allow-http-https" {
  name    = var.firewall_name_http_https
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  source_ranges = var.internet_source_ranges
}

## 각각의 범위에 따른 서비스 여러 개를 만들어야 함