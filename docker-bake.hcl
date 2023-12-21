variable "DEFAULT_TAG" {
  default = "rtorrent-rutorrent:local"
}

// Special target: https://github.com/docker/metadata-action#bake-definition
target "docker-metadata-action" {
  tags = ["${DEFAULT_TAG}"]
}

// Default target if none specified
group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
}

target "image-local" {
  inherits = ["image"]
  output = ["type=docker"]
}

target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64",
    "linux/arm/v6",
    "linux/arm/v7",
    "linux/arm64"
  ]
}

target "image-amd64" {
  inherits = ["image"]
  platforms = [
    "linux/amd64"
  ]
}

target "image-arm64" {
  inherits = ["image"]
  platforms = [
    "linux/arm64"
  ]
}

target "image-arm-v6" {
  inherits = ["image"]
  platforms = [
    "linux/arm/v6"
  ]
}

target "image-arm-v7" {
  inherits = ["image"]
  platforms = [
    "linux/arm/v7"
  ]
}