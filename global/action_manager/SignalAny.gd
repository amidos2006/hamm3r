class_name SignalAny
extends RefCounted


signal triggered(signal_name)


var _connections = []


func _init(signals: Array):
	for s in signals:
		var callable = Callable(self, "_on_signal").bind(s)
		s.connect(callable)
		_connections.append([s, callable])


func _on_signal(sig):
	# disconnect all
	for c in _connections:
		var s = c[0]
		var caller = c[1]
		if s.is_connected(caller):
			s.disconnect(caller)
	_connections.clear()
	triggered.emit(sig)
