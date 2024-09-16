using System;
using RaylibBeef;
using static RaylibBeef.Raylib;
using static RaylibBeef.KeyboardKey;

namespace TestGame;

enum State
{
	Idle,
	Running,
	Jumping
}

enum Direction
{
	Left,
	Right,
}

class Program
{
	const int MAX_SPEED_X = 25;
	const int SCREEN_WIDTH = 800;
	const int SCREEN_HEIGHT = 450;
	const int ACCELERATION_X_GROUNDED = 3;
	const int ACCELERATION_X_JUMPING = 2;
	const int ACCELERATION_Y = 25;
	const float FRICTION = 0.6f;
	const float GRAVITY = 0.98f;

	public static int Main(String[] args)
	{
		InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, scope $"Raylib Beef {RAYLIB_VERSION_MAJOR}.{RAYLIB_VERSION_MINOR}.{RAYLIB_VERSION_PATCH}");
		InitAudioDevice();


		var state = State.Idle;
		var direction = Direction.Right;
		
		var player = Vector2(0, 0);
		
		let tileset = LoadTexture("assets/tiles.png");
		let sprite_width_tiles = (float)tileset.width / 6;

		let player_sprite_sheet = LoadTexture("assets/main.png");
		let sprite_width_player = (float)player_sprite_sheet.width / 4;
		let sprite_width_player_half = sprite_width_player / 2;
		var frame_rec_player = Rectangle(0, 0, sprite_width_player, (float)player_sprite_sheet.height);

		int frames_counter = 0;
		int frames_speed = 8;
		int current_frame = 0;
		bool grounded = true;

		Camera2D camera;
		camera.target = Vector2(player.x + sprite_width_player_half, player.y + sprite_width_player_half);
		camera.offset = Vector2(SCREEN_WIDTH / 2.0f, SCREEN_HEIGHT / 2.0f);
		camera.rotation = 0.0f;
		camera.zoom = 0.5f;

		var velocity = Vector2(0, 0);

		SetTargetFPS(60);

		while (!WindowShouldClose())
		{
			// inputs
			let accel_x = grounded ? ACCELERATION_X_GROUNDED : ACCELERATION_X_JUMPING;

			if (IsKeyDown((int32)KEY_RIGHT) || IsKeyDown((int32)KEY_D)) velocity.x += accel_x;
			if (IsKeyDown((int32)KEY_LEFT) || IsKeyDown((int32)KEY_A)) velocity.x -= accel_x;

			if (grounded)
			{
				if (IsKeyDown((int32)KEY_SPACE)) velocity.y -= ACCELERATION_Y;
			}

			// physics
			velocity.x = System.Math.Clamp(velocity.x, -MAX_SPEED_X, MAX_SPEED_X);

			if (grounded)
			{
				if (velocity.x > 0)
				{
					velocity.x -= FRICTION;
					if (velocity.x < 0) velocity.x = 0; // Stop if friction overtakes velocity
				}
				else if (velocity.x < 0)
				{
					velocity.x += FRICTION;
					if (velocity.x > 0) velocity.x = 0;
				}
			} else
			{
				velocity.y += GRAVITY;
			}

			player += velocity;

			grounded = player.y >= 0;
			if (grounded) velocity.y = 0;

			if (player.y > 0) player.y = 0;

			if (grounded)
			{
				if (velocity.x != 0)
				{
					if (state != State.Running)
					{
						current_frame = 0;
						frames_counter = 0;
						state = State.Running;
					}
				}
				else
				{
					if (state != State.Idle)
					{
						state = State.Idle;
					}
				}
			}
			else
			{
				if (state != State.Jumping)
				{
					state = State.Jumping;
				}
			}

			let velocity_sign = Math.Sign(velocity.x);
			if (velocity_sign > 0)
			{
				direction = Direction.Right;
				if (frame_rec_player.width < 0) frame_rec_player.width *= -1;
			} else if (velocity_sign < 0)
			{
				direction = Direction.Left;
				if (frame_rec_player.width > 0) frame_rec_player.width *= -1;
			}

			// animation
			switch (state) {
			case State.Idle:
				frame_rec_player.x = 2 * sprite_width_player;
			case State.Running:
				frames_counter++;

				if (frames_counter >= (60 / frames_speed))
				{
					frames_counter = 0;
					current_frame++;

					if (current_frame > 1) current_frame = 0;

					frame_rec_player.x = (float)current_frame * sprite_width_player;
				}
			case State.Jumping:
				frame_rec_player.x = 3 * sprite_width_player;
			}

			// Camera target follows player
			camera.target = Vector2(player.x + sprite_width_player / 2, player.y + sprite_width_player / 2);

			BeginDrawing();

			ClearBackground(RAYWHITE);
			BeginMode2D(camera);

			DrawTextureRec(player_sprite_sheet, frame_rec_player, player - Vector2(sprite_width_player_half, sprite_width_player), WHITE);
			DrawLine(-10000, 0, 10000, 0, BLACK);

			for (int32 i = -100; i < 100; i++)
			{
				var frame_rec_tiles = Rectangle(((i + 100) % 5) * sprite_width_tiles, 0, sprite_width_tiles, sprite_width_tiles);
				DrawTextureRec(tileset, frame_rec_tiles, Vector2(i * sprite_width_tiles, 0), BROWN);
				DrawRectangleLinesEx(Rectangle(i*sprite_width_tiles,0,sprite_width_tiles,sprite_width_tiles), 1f, BLACK);
			}

			EndDrawing();
		}

		CloseAudioDevice();
		CloseWindow();

		return 0;
	}
}

namespace RaylibBeef
{
	extension Vector2
	{
		public static Vector2 operator -(Vector2 lhs, Vector2 rhs)
		{
			return .(lhs.x - rhs.x, lhs.y - rhs.y);
		}

		public static Vector2 operator +(Vector2 lhs, Vector2 rhs)
		{
			return .(lhs.x + rhs.x, lhs.y + rhs.y);
		}

		public void operator +=(Vector2 rhs) mut
		{
			this = this + rhs;
		}

		public void operator -=(Vector2 rhs) mut
		{
			this = this - rhs;
		}

	}
	extension Rectangle
	{
		public static Rectangle operator -(Rectangle lhs, Vector2 rhs)
		{
			return .(lhs.x - rhs.x, lhs.y - rhs.y, lhs.width, lhs.width);
		}

		public static Rectangle operator +(Rectangle lhs, Vector2 rhs)
		{
			return .(lhs.x + rhs.x, lhs.y + rhs.y, lhs.width, lhs.width);
		}

		public void operator +=(Vector2 rhs) mut
		{
			this = this + rhs;
		}

		public void operator -=(Vector2 rhs) mut
		{
			this = this - rhs;
		}

	}
}