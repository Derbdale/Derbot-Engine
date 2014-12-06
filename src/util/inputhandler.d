
class InputHandler {
	static bool falseArray[323] = false;
	static bool keys[323] = false;
	static bool justPressed[323] = false;
	static int mod = 0;
	static int[int][int] axis;
	static bool[int][int] button;

	static float getAxis(int controllerID, int axisID){
		int[int] lz;
		if(axis.get(controllerID, lz) != lz){
			if(axis[controllerID].get(axisID, 0) != 0){
				return axis[controllerID][axisID]/32767;
			}
		}
		return 0;
	}

	static bool getButton(int controllerID, int buttonID){
		bool[int] lz;
		if(button.get(controllerID, lz) != lz){
			if(button[controllerID].get(buttonID, 0) != 0){
				return button[controllerID][buttonID];
			}
		}
		return false;
	}
}