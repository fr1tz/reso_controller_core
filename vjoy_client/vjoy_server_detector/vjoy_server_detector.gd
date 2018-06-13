# Copyright © 2017, 2018 Michael Goldener <mg@wasted.ch>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


extends Node

var mServers = null
var mUDP = PacketPeerUDP.new()

func _ready():
	mServers = get_node("servers")
	if mUDP.listen(44001) != 0:
		rcos.log_error(self, "Unable to listen on UDP port 44001")
	else:
		get_node("read_packets_timer").connect("timeout", self, "_read_packets")
		get_node("read_packets_timer").start()

func _read_packets():
	while mUDP.get_available_packet_count() > 0:
		_process_udp_datagram()

func _process_udp_datagram():
	var data = mUDP.get_packet()
	var addr = mUDP.get_packet_ip()
	var port = mUDP.get_packet_port()
	var announce = data.get_string_from_ascii()
	if !announce.to_lower().begins_with("#vjoy-server"):
		return
	var server_node = null
	var server_node_name = "udp!"+addr+"!"+str(port)
	if mServers.has_node(server_node_name):
		server_node = mServers.get_node(server_node_name)
	else:
		server_node = rlib.instance_scene("res://vjoy_client/vjoy_server_detector/vjoy_server.tscn")
		server_node.set_name(server_node_name)
		server_node.init(addr, port)
		mServers.add_child(server_node)
	if server_node:
		server_node.process_announce(announce)

func send_packet(data, addr, port):
	mUDP.set_send_address(addr, port)
	mUDP.put_packet(data)
