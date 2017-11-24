extends Node

var mConnector = null
var mAddr = null
var mPort = null
var mLastHeartbeatTime = -1
var mInterfaceWidget = null

func _decode_icon(string):
	var data = rlib.base64_decode(string)
	if data == null:
		return null
	var img = Image(40, 40, false, Image.FORMAT_GRAYSCALE_ALPHA)
	var p = 0
	for c in data:
		for b in range(0, 8):
			var x = p % 40
			var y = (p-x) / 40
			var color = Color(1, 1, 1, 1)
			if (c & 128>>b) > 0:
				color = Color(1, 1, 1, 0)
			img.put_pixel(x, y, color)
			p += 1
	var tex = ImageTexture.new()
	tex.create_from_image(img, 0)
	return tex

func init(connector, addr, port):
	mConnector = connector
	mAddr = addr
	mPort = port

func process_packet(data):
	rcos.log_debug(self, ["process_packet()", data])
	var msg = data.get_string_from_ascii()
	if msg.to_lower().begins_with("vrchost-ap.hb"):
		if mLastHeartbeatTime == -1:
			var data = "info_request".to_ascii()
			mConnector.send_packet(data, mAddr, mPort)
		mLastHeartbeatTime = OS.get_unix_time()
	elif msg.to_lower().begins_with("vrchost-ap.info"):
		var host = "Unknown"
		var desc = "No description"
		var icon = null
		var lines = msg.split("\n")
		for line in lines:
			var name = rlib.hd(line)
			var value = rlib.tl(line)
			if name == "" || value == "":
				continue
			if name == "host:":
				host = value
				prints("found host:", host)
			elif name == "desc:":
				desc = value
				prints("found desc:", desc)
			elif name == "icon:":
				icon = _decode_icon(value)
				if icon == null:
					rcos.log_error(self, "unable to decode icon")
					continue
				prints("found icon:", icon)
		mInterfaceWidget = mConnector.gui.add_interface_widget(host)
		var info = rlib.join_array([
			desc,
			"VRC Host Access Point",
			mAddr+":"+str(mPort)
		], "\n")
		mInterfaceWidget.set_info(info)
		if icon != null:
			mInterfaceWidget.set_icon(icon)
		mInterfaceWidget.connect("activated", self, "activate")

func activate():
	var vrc_host = rcos.spawn_module("res://vrc_host/vrc_host.tscn")
	vrc_host.connect_to_interface(mAddr, mPort)
