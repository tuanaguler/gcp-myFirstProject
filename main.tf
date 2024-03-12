provider "google" {
  project = "best-project-ever1010" //Project ID
  region  = "europe-west1" //Project Region
}

//Cloud Storage Backend - Step E
terraform {
 backend "gcs" {
    bucket         = "best-bucket-terraform"     
    prefix         = "terraform/state"              
  }
}

//VPC Network Step A.1
resource "google_compute_network" "vpc_network" {
  name                    = "best-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_firewall" "http_firewall" {
  name    = "allow-http-ssh"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22","80"]
  }


source_ranges = ["0.0.0.0/0"]
}

//Subnet in europe-west1 Step A.2
resource "google_compute_subnetwork" "subnet" {
  name          = "best-subnet"
  ip_cidr_range = "11.1.1.0/24"
  region        = "europe-west1"
  network       = google_compute_network.vpc_network.self_link
}

//Cloud Router and NAT Step A.3
resource "google_compute_router" "router" {
  name    = "best-router"
  region  = "europe-west1"
  network = google_compute_network.vpc_network.name
}

resource "google_compute_router_nat" "nat" {
  name   = "best-nat"
  router = google_compute_router.router.name
  region = google_compute_router.router.region

  nat_ip_allocate_option              = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

//Instance Templete Step A.4
resource "google_compute_instance_template" "template" {
  name_prefix  = "best-instance-template-"
  machine_type = "e2-micro"

  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network = google_compute_network.vpc_network.self_link
    subnetwork = google_compute_subnetwork.subnet.self_link
  }

  metadata_startup_script = <<SCRIPT
  apt-get update
  apt-get install -y apache2
  echo 'I applied to your summer internship. Pls hire me. I am good' > /var/www/html/index.html
  SCRIPT

  lifecycle {
    create_before_destroy = true
  }
}

//Managed Instance Group Step A.5
resource "google_compute_instance_group_manager" "manager" {
  name               = "best-instance-group-manager"
  base_instance_name = "best-instance"
  zone               = "europe-west1-d"
  target_size        = 1

  version {
    instance_template = google_compute_instance_template.template.self_link
  }

  named_port {
    name = "http"
    port = 80
  }
}

//Autoscaller Step A.6
resource "google_compute_autoscaler" "autoscaler" {
  name   = "best-autoscaler"
  zone   = "europe-west1-d"
  target = google_compute_instance_group_manager.manager.instance_group

  autoscaling_policy {
    max_replicas    = 5
    min_replicas    = 1
    cooldown_period = 60

    cpu_utilization {
      target = 0.5
    }
  }
}

//Load Balancer Step A.7
resource "google_compute_health_check" "http_health_check" {
  name               = "http-health-check"
  check_interval_sec = 10
  timeout_sec        = 5
  healthy_threshold  = 2
  unhealthy_threshold = 2
  http_health_check {
    request_path = "/"
    port         = 80
  }
}

resource "google_compute_backend_service" "backend_service" {
  name = "backend-service"
  backend {
    group = google_compute_instance_group_manager.manager.instance_group
  }
   health_checks = [google_compute_health_check.http_health_check.self_link]
  protocol      = "HTTP"
  port_name     = "http"
}

resource "google_compute_url_map" "url_map" {
  name            = "url-map"
  default_service = google_compute_backend_service.backend_service.self_link
}

resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "http-proxy"
  url_map = google_compute_url_map.url_map.self_link
}

resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  name       = "forwarding-rule"
  target     = google_compute_target_http_proxy.http_proxy.self_link
  port_range = "80"
}
