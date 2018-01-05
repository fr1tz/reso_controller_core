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

var mData;

func _init(vrc_data):
	mData = vrc_data

func _write_file(root_dir_path, file_name, data):
	if !root_dir_path.ends_with("/"):
		root_dir_path = root_dir_path + "/"
	var dir = Directory.new()
	var file_path = root_dir_path + "/" + file_name
	var dir_path = file_path.get_base_dir()
	if !dir.dir_exists(dir_path):
		dir.make_dir_recursive(dir_path)
	var ext = file_path.extension()
	if ext == "gd" || ext == "tscn" || ext == "xml":
		var txt = data.get_string_from_utf8()
		txt = txt.replace("res://", root_dir_path)
		data = txt.to_utf8()
	var file = File.new()
	file.open(file_path, File.WRITE)
	file.store_buffer(data)
	file.close()

func unpack(dir_path):
	#prints("Unpacking", mData.size(), "bytes of VRC data...")
	var offset = 0
	while offset < mData.size():
		var buf = RawArray()
		for i in range(124, 136):
			buf.append(mData[offset+i])
		var file_size_string = buf.get_string_from_ascii()
		if int(file_size_string) == 0:
			offset += 512
			continue
		var s = file_size_string.length()
		var n = s-1
		var file_size = int(file_size_string[n])
		while n > 0:
			n -= 1
			var pos = (s-n-1)
			file_size += int(file_size_string[n]) * pow(8,pos)
		buf.resize(0)
		for i in range(0, 100):
			buf.append(mData[offset+i])
		var file_name = buf.get_string_from_ascii()
		buf.resize(0)
		for i in range(512, 512+file_size):
			buf.append(mData[offset+i])
		_write_file(dir_path, file_name, buf)
		var padding = 512 - (int(file_size) % 512)
		offset += 512+file_size+padding
