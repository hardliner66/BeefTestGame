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