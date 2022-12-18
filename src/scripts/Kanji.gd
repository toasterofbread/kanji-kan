class_name Kanji
extends Reference

const TEXTURE_SCALE: float = 3.0

var literal: String
var codes: Dictionary
var radicals: Array
var meanings: Dictionary

var freq: int
var grade: int
var jlpt: int
var stroke_count: int
var kanjivg: Unzip

func _init(data: Dictionary, kanjivg: Unzip):
	self.kanjivg = kanjivg
	literal = data["literal"]["value"]
	meanings = data.get("reading_meaning", {})
	
	codes = {}
	for code in data["codepoint"]["cp_value"]:
		codes[code["cp_type"]] = code["value"]
	
	var rad = data["radical"]["rad_value"]
	if not rad is Array:
		radicals = [rad]
	else:
		radicals = rad
	
	for key in ["freq", "grade", "jlpt", "stroke_count"]:
		var value = data["misc"].get(key)
		if value is Array:
			value = value[0]
		
		if value != null:
			set(key, value["value"])
		else:
			set(key, null)

func getTexture():
	var data: PoolByteArray = kanjivg.uncompress(codes["ucs"].pad_zeros(5) + ".svg")
	
	var ret = ImageTexture.new()
	ret.create_from_image(GoostImage.render_svg(data.get_string_from_ascii(), TEXTURE_SCALE))
	return ret

static func sorter(a: Kanji, b: Kanji) -> bool:
	return a.codes["ucs"].casecmp_to(b.codes["ucs"]) == 1
