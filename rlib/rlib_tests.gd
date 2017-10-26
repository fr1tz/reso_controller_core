extends Node

var rlib = preload("rlib.gd").new()
var mFailCounter

func _ready():
	mFailCounter = 0
	base64_test1()
	var msg = {
		"button": 1,
		"pressed": true,
		"text": "yay\nwoo\nSWAG",
		"args": [ "[,\"1\",]", 2, 3, 4 ]
	}
	print(msg.text)
	var obj = {
		"level": "debug",
		"source": "vrc_host/tcp_connections/tcp!127.0.0.1!1234",
		"msg": msg
	}
	print(obj.to_json())
	if mFailCounter > 0:
		prints(mFailCounter, "FAILURES!")
	else:
		print("All tests succeeded")

func base64_test1():
	print("base64_test1")
	var test_vectors_plain = [ "", "f", "fo", "foo", "foob", "fooba", "foobar" ]
	var test_vectors_encoded = [ "", "Zg==", "Zm8=", "Zm9v", "Zm9vYg==", "Zm9vYmE=", "Zm9vYmFy" ]
	for i in range(0, test_vectors_plain.size()):
		var tv_plain = test_vectors_plain[i]
		var tv_encoded = test_vectors_encoded[i]
		var plain = rlib.base64_decode(tv_encoded).get_string_from_ascii()
		if plain == tv_plain:
			prints(tv_encoded, "=>", plain, "==", tv_plain, "->", "OK")
		else:
			prints(tv_encoded, "=>", plain, "!=", tv_plain, "->", "FAILED!")
			mFailCounter += 1
