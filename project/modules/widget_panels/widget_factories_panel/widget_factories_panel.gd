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

extends Panel

onready var mWidgetFactoryList = get_node("scroller_container/widget_factory_list")

func _init():
	add_user_signal("item_selected")

func _on_item_selected(item, task_id):
	emit_signal("item_selected", item)

func update_available_widgets(widget_factory_tasks):
	var isquare = Vector2(rcos.get_isquare_size(), rcos.get_isquare_size())
	for item in mWidgetFactoryList.get_children():
		mWidgetFactoryList.remove_child(item)
		item.free()
	for task_id in widget_factory_tasks:
		var properties = rcos.get_task_properties(task_id)
		if !properties.has("product_name") || !properties.has("product_id"):
			continue
		if properties.has("config_presets"):
			for preset in properties.config_presets:
				var item = rlib.instance_scene("res://modules/widget_panels/widget_factories_panel/widget_factory_item.tscn")
				item.initialize(task_id, preset)
				item.set_custom_minimum_size(isquare)
				item.connect("pressed", self, "_on_item_selected", [item, task_id])
				mWidgetFactoryList.add_child(item)
		else:
			var item = rlib.instance_scene("res://modules/widget_panels/widget_factories_panel/widget_factory_item.tscn")
			item.initialize(task_id)
			item.set_custom_minimum_size(isquare)
			item.connect("pressed", self, "_on_item_selected", [item, task_id])
			mWidgetFactoryList.add_child(item)
