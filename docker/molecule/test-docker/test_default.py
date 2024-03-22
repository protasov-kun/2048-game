def test_docker_installed(host):
    assert host.package("docker.io").is_installed