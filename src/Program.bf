using System;
using RaylibBeef;
using System.Diagnostics;

using static RaylibBeef.Raylib;

namespace TestGame;

class D
{
#define DEBUG_ASSERT
	public static void Assert(bool condition, String error = Compiler.CallerExpression[0], String filePath = Compiler.CallerFilePath, int line = Compiler.CallerLineNum)
	{
#if DEBUG_ASSERT
		Debug.Assert(condition, error, filePath, line);
#else
		Runtime.Assert(condition, error, filePath, line);
#endif
	}
}
using static TestGame.D;

class C
{
	public const int MAX_SPEED_X = 25;
	public const int SCREEN_WIDTH = 800;
	public const int SCREEN_HEIGHT = 450;
	public const int ACCELERATION_X_GROUNDED = 3;
	public const int ACCELERATION_X_AIR = 2;
	public const int ACCELERATION_Y = 25;
	public const float FRICTION = 1f;
	public const float GRAVITY = 0.98f;
	public const int DESIRED_FPS = 60;
}
using static TestGame.C;


class Program
{
	public static int Main(String[] args)
	{
		InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, scope $"Raylib Beef {RAYLIB_VERSION_MAJOR}.{RAYLIB_VERSION_MINOR}.{RAYLIB_VERSION_PATCH}");
		InitAudioDevice();

		let tileset = LoadTexture("assets/tiles.png");
		let sprite_width_tiles = (float)tileset.width / 6;

		var player = Player(SpriteSheet(LoadTexture("assets/main.png"), 8, 4, 1));
		defer UnloadTexture(player.sprite_sheet.texture);

		Camera2D camera;
		camera.target = Vector2(player.position.x + player.sprite_sheet.sprite_width_half, player.position.y + player.sprite_sheet.sprite_width_half);
		camera.offset = Vector2(SCREEN_WIDTH / 2.0f, SCREEN_HEIGHT / 2.0f);
		camera.rotation = 0.0f;
		camera.zoom = 0.5f;

		SetTargetFPS(DESIRED_FPS);

		while (!WindowShouldClose())
		{
			// inputs
			player.handle_inputs(ACCELERATION_X_GROUNDED, ACCELERATION_X_AIR, ACCELERATION_Y);

			// physics
			player.velocity.x = System.Math.Clamp(player.velocity.x, -MAX_SPEED_X, MAX_SPEED_X);

			if (player.grounded)
			{
				player.apply_friction(FRICTION);
			}
			else
			{
				player.apply_gravity(GRAVITY);
			}

			player.update_position();

			player.update_state();

			if (player.state == Player.State.Running && player.last_state != Player.State.Running)
			{
				player.reset_frame();
			}


			// animation
			player.animate();

			// Camera target follows player
			camera.target = Vector2(player.position.x + player.sprite_sheet.sprite_width_half, player.position.y + player.sprite_sheet.sprite_width_half);

			BeginDrawing();

			ClearBackground(RAYWHITE);
			BeginMode2D(camera);

			DrawTextureRec(player.sprite_sheet.texture, player.sprite_sheet.frame_rec, player.position - Vector2(player.sprite_sheet.sprite_width_half, player.sprite_sheet.sprite_width), WHITE);
			DrawLine(-10000, 0, 10000, 0, BLACK);

			for (int32 i = -100; i < 100; i++)
			{
				var frame_rec_tiles = Rectangle(((i + 100) % 5) * sprite_width_tiles, 0, sprite_width_tiles, sprite_width_tiles);
				DrawTextureRec(tileset, frame_rec_tiles, Vector2(i * sprite_width_tiles, 0), BROWN);
				DrawRectangleLinesEx(Rectangle(i * sprite_width_tiles, 0, sprite_width_tiles, sprite_width_tiles), 1f, BLACK);
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