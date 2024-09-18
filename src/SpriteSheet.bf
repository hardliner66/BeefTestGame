using RaylibBeef;

namespace TestGame;

struct SpriteSheet {
	public Texture texture;
	
	public float sprite_width;
	public float sprite_width_half;
	public float sprite_height;
	public float sprite_height_half;
	public Rectangle frame_rec;
	
	public int frame_speed;
	public var frame_counter = 0;
	public var current_frame = 0;

	public this(Texture texture, int frame_speed, int horizontal_sprite_count, int vertical_sprite_count) {
		this.texture = texture;
		this.frame_speed = frame_speed;

		sprite_width = (float)texture.width / horizontal_sprite_count;
		sprite_height = (float)texture.height / vertical_sprite_count;

		sprite_width_half = sprite_width / 2;
		sprite_height_half = sprite_height / 2;

		frame_rec = Rectangle(0, 0, sprite_width, sprite_height);
	}

	public void reset_frame() mut
	{
		current_frame = 0;
		frame_counter = 0;
	}
}