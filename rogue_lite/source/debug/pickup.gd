extends Area2D


func _on_body_entered(body):
	if body is Player:
		var attack_keys = body.attacks.keys()
		var attack = randi() % attack_keys.size()
		body.attack = attack_keys[ attack ]

		self.call_deferred( "queue_free" )
