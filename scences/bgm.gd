extends AudioStreamPlayer2D


# bgm.gd (autoload)
@onready var player = $AudioStreamPlayer

func _ready():
	player.stream.loop = true   # make sure the stream loops
	player.play()
