extends Control
class_name Canvas

var hint_char: Kanji = null setget setHintChar
var current_line: Line2D = null
var current_line_length: float = 0.0
var prev_speed: Vector2 = null

var kanji_data: Dictionary

func _ready():
	setHintChar(null)
	onCanvasResized()

func setHintChar(value: Kanji):
	hint_char = value
	
	$HintCharTextureRect.visible = hint_char != null
	if hint_char != null:
		$HintCharTextureRect.texture = hint_char.getTexture()

func createNewStroke() -> Line2D:
	var ret = AntialiasedLine2D.new()
	ret.width = 0.025
	return ret

class TweenMethodInterpolator extends Object:
	var object: Object
	var method: String
	var args: Array
	var i_index: int
	
	func _init(tween: Tween, object: Object, method: String, initial_val, final_val, duration: float, args: Array, i_arg_index: int, trans_type: int = 0, ease_type: int = 2, delay: float = 0):
		self.object = object
		self.method = method
		self.i_index = i_arg_index
		self.args = args
		if i_arg_index + 1 > args.size():
			args.resize(i_arg_index + 1)
		tween.interpolate_method(self, "interpolate", initial_val, final_val, duration, trans_type, ease_type, delay)
	
	func interpolate(value):
		args[i_index] = value
		object.callv(method, args)

func currentLineHane(length_squared: float):
	if current_line_length == 0:
		return
	
	if current_line.width_curve == null:
		current_line.width_curve = Curve.new()
	else:
		current_line.width_curve.clear_points()
	
	var curve: Curve = current_line.width_curve
	curve.add_point(Vector2(0.0, 1.0))
	
	if length_squared == 0.0:
		curve.add_point(Vector2(1.0, 1.0))
	else:
		curve.add_point(Vector2(1.0 - ((length_squared * 2.0) / current_line_length), 1.0))
		curve.add_point(Vector2(1.0, 0.0))

func _gui_input(event: InputEvent):
	if event is InputEventScreenTouch:
		current_line = null
	elif event is InputEventScreenDrag:
		if current_line == null or current_line.get_point_count() > 100:
			if current_line != null:
				currentLineHane(0.0)
			
			current_line_length = 0.0
			current_line = createNewStroke()
			current_line.add_point((event.position - event.relative) / rect_size - Vector2(0.5, 0.5))
			$Lines.add_child(current_line)
		
		current_line.add_point(event.position / rect_size - Vector2(0.5, 0.5))
		current_line_length += (event.relative / rect_size).length_squared()
		
		currentLineHane((event.relative / rect_size).length_squared())

func onCanvasResized():
	$Lines.rect_scale = Vector2.ONE * min(rect_size.x, rect_size.y)
