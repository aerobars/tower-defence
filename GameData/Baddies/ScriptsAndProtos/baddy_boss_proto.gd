@abstract
class_name BaddyBossProto extends Baddy

##When setting up boss script, include function that will call boss_effect
##Example:
##func _process():
##super()
##boss_effect()
@abstract func boss_effect() -> void
