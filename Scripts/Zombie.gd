extends KinematicBody

export var speed = 2.5
var dir = Vector3()
var vel = Vector3()
const GRAVITY = -9.8

var life = 80
var dead = false

var following = false


func _physics_process(delta):

	if dead:
		return

	$ZombieModel/AnimationPlayer.queue("WalkAction")

	self.look_at(Game.player.translation, Vector3(0,1,0))

	dir = Game.player.translation - self.translation
	dir.y = 0
	
	# if player is far from zombie, don't follow him
	if not following and (dir.x > 16 or dir.z > 16):
		return
	else:
		following = true
	
	dir = dir.normalized()

	vel.y += GRAVITY * delta

	var tmp_vel = vel
	tmp_vel.y = 0

	# where would the zombie go at max speed
	var target = dir * speed

	# calculate a portion of the distance to go
	tmp_vel = tmp_vel.linear_interpolate(target, 12 * delta)

	vel.x = tmp_vel.x
	vel.z = tmp_vel.z

	vel = move_and_slide(vel, Vector3(0, 1, 0))

func hit(damage, headshot):
	if not dead:
		if headshot:
			damage = damage*3
			
		life -= damage

		hit_particle()
		if life <= 0:
			die()
			return
		$Hit.play()

func die():
	dead = true
	$CollisionShape.disabled = true
	$ZombieModel/AnimationPlayer.stop()
	$ZombieModel/AnimationPlayer.play("DieAction")
	$Die.play()
	$DeadTimer.start()

func hit_particle():
	$HitParticle.emitting = true
	$HitParticle.restart()

func _on_DeadTimer_timeout():
	self.queue_free()


func _on_GrowlTimer_timeout():
	if not dead:
		$Growl.play()
		$GrowlTimer.wait_time = rand_range(2, 5)
		$GrowlTimer.start()
