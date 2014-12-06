import std.random;

class Camera{
	int realMouseX;
	int realMouseY;
	int gameMouseX = 0;
	int gameMouseY = 0;

	float x;
	float y;
	float offsetX = 0;
	float offsetY = 0;

	float width;
	float height;

	float mouseX = 0;
	float mouseY = 0;
	float moveSpeed = 2.5;
	float rotSpeed = 1;

	this(float x, float y, float width, float height){
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}

	void shake(int magnitude){
		this.offsetX -= uniform(0, magnitude*2 + 1)-magnitude;
		this.offsetY -= uniform(0, magnitude*2 + 1)-magnitude;
	}
}