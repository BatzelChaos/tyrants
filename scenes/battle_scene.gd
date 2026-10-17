class_name BattleScene
extends CanvasLayer

## Emitted once when the battle ends; game.gd decides what happens next.
signal finished(outcome: int)

enum Outcome { VICTORY, DEFEAT, FLED }


@onready var player_label: Label = $UI/MarginContainer/HBoxContainer/VBoxContainer/PlayerLabel
@onready var enemy_label: Label = $UI/MarginContainer3/HBoxContainer/VBoxContainer/EnemyLabel
@onready var enemy_bar: ProgressBar = $UI/MarginContainer3/HBoxContainer/VBoxContainer/EnemyHPBar
@onready var player_bar: ProgressBar = $UI/MarginContainer/HBoxContainer/VBoxContainer/PlayerHPBar
@onready var battle_log: Label = $UI/MarginContainer/Panel/BattleLog
@onready var player_hp_label: Label = $UI/MarginContainer/HBoxContainer/VBoxContainer/PlayerHP
@onready var enemy_hp_label: Label = $UI/MarginContainer3/HBoxContainer/VBoxContainer/EnemyHP
@onready var fight_button: Button = $UI/MarginContainer2/VBoxContainer/HBoxContainer/FightButton
@onready var talk_button: Button = $UI/MarginContainer2/VBoxContainer/HBoxContainer2/TalkButton
@onready var items_button: Button = $UI/MarginContainer2/VBoxContainer/HBoxContainer/ItemButton
@onready var run_button: Button = $UI/MarginContainer2/VBoxContainer/HBoxContainer2/RunButton

var enemy: Enemy    # set in setup(); name and stats are read straight from it
var player: Player  # set in setup(); the player node's health is the source of truth

var enemy_hp := 30
var enemy_max_hp := 30

var _busy := false
var _lines: Array[String] = []


func _ready() -> void:
	# The world is paused during a battle; this scene must keep running.
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	fight_button.pressed.connect(_on_fight)
	talk_button.pressed.connect(_on_talk)
	items_button.pressed.connect(_on_items)
	run_button.pressed.connect(_on_run)
	# Locked until setup() hands us real nodes - also makes F6 on this scene safe.
	for button in [fight_button, talk_button, items_button, run_button]:
		button.disabled = true
	_refresh()


## Call AFTER the battle scene was added to the tree (game.gd does this).
func setup(p_enemy: Enemy, p_player: Player) -> void:
	enemy = p_enemy
	player = p_player
	enemy_max_hp = enemy.max_health
	enemy_hp = enemy.health
	_lines.clear()
	_log("A wild %s appears!" % enemy.display_name)
	_refresh()
	for button in [fight_button, talk_button, items_button, run_button]:
		button.disabled = false


func _on_fight() -> void:
	if _busy:
		return
	_busy = true
	var damage := randi_range(8, 18)
	enemy_hp = maxi(enemy_hp - damage, 0)
	_log("You hit the %s for %d damage!" % [enemy.display_name, damage])
	if enemy_hp == 0:
		_end(Outcome.VICTORY)
		return
	var retaliation := randi_range(enemy.attack_damage.x, enemy.attack_damage.y)
	player.health = maxi(player.health - retaliation, 0)
	_log("The %s hits you for %d damage!" % [enemy.display_name, retaliation])
	if player.health == 0:
		_end(Outcome.DEFEAT)
		return
	_busy = false
	_refresh()


func _on_talk() -> void:
	if _busy:
		return
	_busy = true
	if randf() < 0.4:
		_log("The %s calms down and lets you pass." % enemy.display_name)
		_end(Outcome.FLED)  # peaceful end: the enemy stays on the map
		return
	var hit := randi_range(enemy.attack_damage.x, enemy.attack_damage.y)
	player.health = maxi(player.health - hit, 0)
	_log("The %s doesn't want to talk and hits you for %d!" % [enemy.display_name, hit])
	if player.health == 0:
		_end(Outcome.DEFEAT)
		return
	_busy = false
	_refresh()


func _on_items() -> void:
	if _busy:
		return
	# Placeholder until you have an inventory - hook your item system here.
	player.health = mini(player.health + 20, player.max_health)
	_log("You eat a snack. (+20 HP)")
	_refresh()


func _on_run() -> void:
	if _busy:
		return
	_busy = true
	if randf() < 0.5:
		_log("You got away safely!")
		_end(Outcome.FLED)
		return
	var hit := randi_range(enemy.attack_damage.x, enemy.attack_damage.y)
	player.health = maxi(player.health - hit, 0)
	_log("You couldn't escape! The %s hits you for %d." % [enemy.display_name, hit])
	if player.health == 0:
		_end(Outcome.DEFEAT)
		return
	_busy = false
	_refresh()


func _end(outcome: int) -> void:
	_refresh()
	# Let the last lines sink in before the map returns.
	await get_tree().create_timer(0.9).timeout
	finished.emit(outcome)


func _log(message: String) -> void:
	_lines.append(message)
	while _lines.size() > 4:
		_lines.pop_front()
	battle_log.text = "\n".join(_lines)


func _refresh() -> void:
	if enemy == null or player == null:
		return  # setup() hasn't run yet
	player_label.text = "%s" % [player.name]
	enemy_label.text = "%s" % [enemy.display_name]
	player_hp_label.text = "%d/%d HP" % [player.health, player.max_health]
	enemy_hp_label.text = "%d/%d HP" % [enemy_hp, enemy_max_hp]
	# HP bars — same values the labels show
	player_bar.max_value = player.max_health
	player_bar.value = player.health
	enemy_bar.max_value = enemy_max_hp
	enemy_bar.value = enemy_hp
