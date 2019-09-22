tool
extends MMGenBase
class_name MMGenRemote

"""
Remote can be used to control parameters from several generators in the same graph
"""

var widgets = null

func set_widgets(w):
	widgets = w
	var i = 0
	for w in widgets:
		var param_name = "param"+str(i)
		if !parameters.has(param_name):
			parameters["param"+str(i)] = 0
		i += 1

func get_type():
	return "remot"

func get_type_name():
	return "Remote"

func get_parameter_defs():
	var rv = []
	var i = 0
	for w in widgets:
		match w.type:
			"config_control":
				var p = { name="param"+str(i), label=w.label, type="enum", values=[] }
				for c in w.configurations:
					p.values.push_back({ name=c, value=c })
				rv.append(p)
				i += 1
			"linked_control":
				var linked = w.linked_widgets[0]
				var gen = get_parent().get_node(linked.node)
				if gen != null:
					var gen_params = gen.get_parameter_defs()
					for pd in gen_params:
						if pd.name == linked.widget:
							var p = pd.duplicate(true)
							p.name = "param"+str(i)
							p.label = w.label
							rv.append(p)
							break
				i += 1
			_:
				print(w.type)
	return rv

func set_parameter(p, v):
	.set_parameter(p, v)
	var parent = get_parent()
	var param_index = p.trim_prefix("param").to_int()
	var widget = widgets[param_index]
	match widget.type:
		"linked_control":
			for w in widget.linked_widgets:
				parent.get_node(w.node).set_parameter(w.widget, v)
		"config_control":
			for w in widget.configurations[widget.configurations.keys()[v]]:
				parent.get_node(w.node).set_parameter(w.widget, w.value)

func _serialize(data):
	data.type = "remote"
	data.widgets = widgets
	return data
