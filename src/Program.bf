using System;
using RaylibBeef;
using static RaylibBeef.Raylib;
using static RaylibBeef.KeyboardKey;

namespace TestGame;

class Program
{
	const int MAX_BUILDINGS = 100;
	const int SCREEN_WIDTH = 800;
	const int SCREEN_HEIGHT = 450;
	public static int Main(String[] args)
	{
		InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, scope $"Raylib Beef {RAYLIB_VERSION_MAJOR}.{RAYLIB_VERSION_MINOR}.{RAYLIB_VERSION_PATCH}");
		InitAudioDevice();

		int spacing = 0;

		Rectangle player = Rectangle(400, 280, 40, 40);
		Rectangle[MAX_BUILDINGS] buildings = .();
		Color[MAX_BUILDINGS] buildColors = .();

		for (int i = 0; i < MAX_BUILDINGS; i++)
		{
			buildings[i].width = (float)GetRandomValue(50, 200);
			buildings[i].height = (float)GetRandomValue(100, 800);
			buildings[i].y = SCREEN_HEIGHT - 130.0f - buildings[i].height;
			buildings[i].x = -6000.0f + spacing;

			spacing += (int)buildings[i].width;

			buildColors[i] = Color((uint8)GetRandomValue(200, 240), (uint8)GetRandomValue(200, 240), (uint8)GetRandomValue(200, 250), 255);
		}

		Camera2D camera;
		camera.target = Vector2(player.x + 20.0f, player.y + 20.0f);
		camera.offset = Vector2(SCREEN_WIDTH / 2.0f, SCREEN_HEIGHT / 2.0f);
		camera.rotation = 0.0f;
		camera.zoom = 1.0f;

		SetTargetFPS(60);

		while (!WindowShouldClose())
		{
			if (IsKeyDown((int32)KEY_RIGHT) || IsKeyDown((int32)KEY_D)) player.x += 2;
			if (IsKeyDown((int32)KEY_LEFT) || IsKeyDown((int32)KEY_A)) player.x -= 2;

			if (IsKeyDown((int32)KEY_UP) || IsKeyDown((int32)KEY_W)) player.y -= 2;
			if (IsKeyDown((int32)KEY_DOWN) || IsKeyDown((int32)KEY_S)) player.y += 2;

			// Camera target follows player
			camera.target = Vector2(player.x + 20, player.y + 20);

			// Camera zoom controls
			camera.zoom += ((float)GetMouseWheelMove() * 0.05f);

			if (camera.zoom > 3.0f) camera.zoom = 3.0f;
			else if (camera.zoom < 0.1f) camera.zoom = 0.1f;

			// Camera reset (zoom and rotation)
			if (IsKeyPressed((int32)KEY_R))
			{
				camera.zoom = 1.0f;
				camera.rotation = 0.0f;
			}

			BeginDrawing();

			ClearBackground(RAYWHITE);
			BeginMode2D(camera);

			DrawRectangle(-6000, 320, 13000, 8000, DARKGRAY);

			for (int i = 0; i < MAX_BUILDINGS; i++)
			{
				DrawRectangleRec(buildings[i], buildColors[i]);
			}

			DrawRectangleRec(player, RED);

			DrawLine((int32)camera.target.x, -SCREEN_HEIGHT * 10, (int32)camera.target.x, SCREEN_HEIGHT * 10, GREEN);
			DrawLine(-SCREEN_WIDTH * 10, (int32)camera.target.y, SCREEN_WIDTH * 10, (int32)camera.target.y, GREEN);

			EndMode2D();

			DrawText("SCREEN AREA", 640, 10, 20, RED);

			DrawRectangle(0, 0, SCREEN_WIDTH, 5, RED);
			DrawRectangle(0, 5, 5, SCREEN_HEIGHT - 10, RED);
			DrawRectangle(SCREEN_WIDTH - 5, 5, 5, SCREEN_HEIGHT - 10, RED);
			DrawRectangle(0, SCREEN_HEIGHT - 5, SCREEN_WIDTH, 5, RED);

			DrawRectangle(10, 10, 250, 113, Fade(SKYBLUE, 0.5f));
			DrawRectangleLines(10, 10, 250, 113, BLUE);

			DrawText("Free 2d camera controls:", 20, 20, 10, BLACK);
			DrawText("- Right/Left to move Offset", 40, 40, 10, DARKGRAY);
			DrawText("- Mouse Wheel to Zoom in-out", 40, 60, 10, DARKGRAY);
			DrawText("- A / S to Rotate", 40, 80, 10, DARKGRAY);
			DrawText("- R to reset Zoom and Rotation", 40, 100, 10, DARKGRAY);

			DrawFPS(20, 20);

			EndDrawing();
		}

		CloseAudioDevice();
		CloseWindow();

		return 0;
	}
}