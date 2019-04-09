output "cache_permanent_peer_public_ip" {
  value = "${aws_instance.cache_permanent_peer.public_ip}"
}

output "point_of_sale_public_ip" {
  value = "${join(",", aws_instance.point_of_sale.*.public_ip)}"
}

output "display_system_public_ip" {
  value = "${join(",", aws_instance.display_system.*.public_ip)}"
}

output "chef_automate_server_public_ip" {
  value = "${aws_instance.chef_automate.public_ip}"
}