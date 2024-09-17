using RaylibBeef;
using System;

using static RaylibBeef.Raylib;
using static RaylibBeef.KeyboardKey;

namespace TestGame;

struct Player
{
	public enum State
	{
		Idle,
		Running,
		Jumping
	}

	public enum Direction
	{
		Left,
		Right,
	}

	public var position = Vector2(0, 0);
	public var velocity = Vector2(0, 0);
	public var grounded = true;
	public var state = State.Idle;
	public var last_state = State.Idle;
	public SpriteSheet sprite_sheet;

	public this(SpriteSheet sprite_sheet) {
		this.sprite_sheet = sprite_sheet;
	}

	public void apply_friction(float friction) mut
	{
		if (velocity.x > 0)
		{
			velocity.x -= friction;
			if (velocity.x < 0) velocity.x = 0; // Stop if friction overtakes velocity
		}
		else if (velocity.x < 0)
		{
			velocity.x += friction;
			if (velocity.x > 0) velocity.x = 0;
		}
	}
	public void apply_gravity(float gravity) mut
	{
		velocity.y += gravity;
	}

	public void update_position() mut
	{
		position += velocity;

		grounded = position.y >= 0;
		if (grounded) velocity.y = 0;

		if (position.y > 0) position.y = 0;
	}

	public void update_state() mut
	{
		var next_state = State.Idle;
		if (grounded)
		{
			if (velocity.x != 0)
			{
				next_state = State.Running;
			}
			else
			{
				next_state = State.Idle;
			}
		}
		else
		{
			next_state = State.Jumping;
		}

		last_state = state;
		state = next_state;
	}

	public void handle_inputs(float acceleration_x_grounded, float acceleration_x_air, float accerleration_y) mut
	{
		let accel_x = grounded ? acceleration_x_grounded : acceleration_x_air;

		if (IsKeyDown((int32)KEY_RIGHT) || IsKeyDown((int32)KEY_D)) velocity.x += accel_x;
		if (IsKeyDown((int32)KEY_LEFT) || IsKeyDown((int32)KEY_A)) velocity.x -= accel_x;

		if (grounded)
		{
			if (IsKeyDown((int32)KEY_SPACE)) velocity.y -= accerleration_y;
		}
	}

	public void animate() mut
	{
		let velocity_sign = Math.Sign(velocity.x);
		if (velocity_sign > 0)
		{
			if (sprite_sheet.frame_rec.width < 0) sprite_sheet.frame_rec.width *= -1;
		} else if (velocity_sign < 0)
		{
			if (sprite_sheet.frame_rec.width > 0) sprite_sheet.frame_rec.width *= -1;
		}

		switch (state) {
		case State.Idle:
			sprite_sheet.frame_rec.x = 2 * sprite_sheet.sprite_width;
		case State.Running:
			sprite_sheet.frame_counter++;

			if (sprite_sheet.frame_counter >= (C.DESIRED_FPS / sprite_sheet.frame_speed))
			{
				sprite_sheet.frame_counter = 0;
				sprite_sheet.current_frame++;

				if (sprite_sheet.current_frame > 1) sprite_sheet.current_frame = 0;

				sprite_sheet.frame_rec.x = (float)sprite_sheet.current_frame * sprite_sheet.sprite_width;
			}
		case State.Jumping:
			sprite_sheet.frame_rec.x = 3 * sprite_sheet.sprite_width;
		}
	}

	public void reset_frame() mut
	{
		sprite_sheet.reset_frame();
	}
}